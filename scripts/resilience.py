#!/usr/bin/env python3
"""
External Dependency Resilience Module (NFR-6.2)

Implements retry logic, circuit breaker pattern, and error logging
for external dependencies.

Features:
- Exponential backoff (1s, 2s, 4s, 8s)
- Max 5 retries per operation
- Circuit breaker pattern (trips after 5 consecutive failures)
- Comprehensive error logging
- Fallback to degraded mode
"""

import time
import functools
import logging
from datetime import datetime, timedelta
from enum import Enum
from typing import Callable, Any, Optional, Dict
from pathlib import Path


# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)


class CircuitState(Enum):
    """Circuit breaker states."""
    CLOSED = "closed"      # Normal operation
    OPEN = "open"          # Failing, reject requests
    HALF_OPEN = "half_open"  # Testing if service recovered


class CircuitBreaker:
    """
    Circuit breaker pattern implementation.

    Trips after configured number of consecutive failures,
    preventing cascading failures.
    """

    def __init__(
        self,
        name: str,
        failure_threshold: int = 5,
        recovery_timeout: int = 60,
        half_open_max_calls: int = 3
    ):
        """
        Initialize circuit breaker.

        Args:
            name: Circuit breaker name (e.g., "github_api")
            failure_threshold: Number of failures before opening circuit
            recovery_timeout: Seconds to wait before attempting recovery
            half_open_max_calls: Max calls to test in half-open state
        """
        self.name = name
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.half_open_max_calls = half_open_max_calls

        # State tracking
        self.state = CircuitState.CLOSED
        self.failure_count = 0
        self.success_count = 0
        self.last_failure_time = None
        self.half_open_calls = 0

        # Logging
        self.logger = logging.getLogger(f"circuit_breaker.{name}")

    def call(self, func: Callable, *args, **kwargs) -> Any:
        """
        Execute function through circuit breaker.

        Args:
            func: Function to execute
            *args: Function arguments
            **kwargs: Function keyword arguments

        Returns:
            Function result

        Raises:
            Exception: If circuit is OPEN or function fails
        """
        # Check circuit state
        if self.state == CircuitState.OPEN:
            if self._should_attempt_reset():
                self._transition_to_half_open()
            else:
                raise CircuitBreakerOpenError(
                    f"Circuit breaker '{self.name}' is OPEN"
                )

        try:
            # Execute function
            result = func(*args, **kwargs)

            # Record success
            self._on_success()

            return result

        except Exception as e:
            # Record failure
            self._on_failure(e)
            raise

    def _should_attempt_reset(self) -> bool:
        """Check if enough time has passed to attempt reset."""
        if self.last_failure_time is None:
            return False

        elapsed = (datetime.utcnow() - self.last_failure_time).total_seconds()
        return elapsed >= self.recovery_timeout

    def _transition_to_half_open(self):
        """Transition to HALF_OPEN state to test recovery."""
        self.state = CircuitState.HALF_OPEN
        self.half_open_calls = 0
        self.logger.info(f"Circuit breaker '{self.name}' entering HALF_OPEN state")

    def _on_success(self):
        """Record successful call."""
        if self.state == CircuitState.HALF_OPEN:
            self.success_count += 1
            self.half_open_calls += 1

            if self.success_count >= self.half_open_max_calls:
                self._reset()
        else:
            self.success_count += 1
            self.failure_count = 0  # Reset failure count on success

    def _on_failure(self, error: Exception):
        """Record failed call."""
        self.failure_count += 1
        self.success_count = 0
        self.last_failure_time = datetime.utcnow()

        self.logger.error(
            f"Circuit breaker '{self.name}' failure #{self.failure_count}: {error}"
        )

        if self.state == CircuitState.HALF_OPEN:
            self._trip()
        elif self.failure_count >= self.failure_threshold:
            self._trip()

    def _trip(self):
        """Trip circuit breaker to OPEN state."""
        self.state = CircuitState.OPEN
        self.logger.error(
            f"Circuit breaker '{self.name}' TRIPPED "
            f"({self.failure_count} consecutive failures)"
        )

        # Log to file
        self._log_trip()

    def _reset(self):
        """Reset circuit breaker to CLOSED state."""
        self.state = CircuitState.CLOSED
        self.failure_count = 0
        self.success_count = 0
        self.half_open_calls = 0
        self.logger.info(f"Circuit breaker '{self.name}' RESET to CLOSED state")

    def _log_trip(self):
        """Log circuit breaker trip event."""
        log_file = Path('compliance/resilience/circuit-breaker-trips.log')
        log_file.parent.mkdir(parents=True, exist_ok=True)

        with open(log_file, 'a') as f:
            f.write(
                f"{datetime.utcnow().isoformat()} - "
                f"Circuit breaker '{self.name}' TRIPPED "
                f"(failures: {self.failure_count})\n"
            )

    def get_state(self) -> Dict:
        """Get current circuit breaker state."""
        return {
            'name': self.name,
            'state': self.state.value,
            'failure_count': self.failure_count,
            'success_count': self.success_count,
            'last_failure_time': (
                self.last_failure_time.isoformat()
                if self.last_failure_time else None
            )
        }


class CircuitBreakerOpenError(Exception):
    """Exception raised when circuit breaker is open."""
    pass


class RetryError(Exception):
    """Exception raised when retries are exhausted."""
    pass


def retry_with_backoff(
    max_retries: int = 5,
    backoff_sequence: tuple = (1, 2, 4, 8),
    circuit_breaker: Optional[CircuitBreaker] = None,
    fallback: Optional[Callable] = None,
    logger: Optional[logging.Logger] = None
):
    """
    Decorator for retrying functions with exponential backoff.

    Args:
        max_retries: Maximum number of retry attempts (default: 5)
        backoff_sequence: Backoff delays in seconds (default: 1, 2, 4, 8)
        circuit_breaker: Optional circuit breaker to use
        fallback: Optional fallback function to call if retries exhausted
        logger: Optional logger instance

    Returns:
        Decorator function

    Example:
        @retry_with_backoff(max_retries=5, backoff_sequence=(1, 2, 4, 8))
        def fetch_data():
            response = requests.get(url)
            response.raise_for_status()
            return response.json()
    """
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            _logger = logger or logging.getLogger(func.__name__)

            # Try through circuit breaker if provided
            if circuit_breaker:
                try:
                    return circuit_breaker.call(
                        _retry_logic,
                        func, max_retries, backoff_sequence,
                        fallback, _logger, *args, **kwargs
                    )
                except CircuitBreakerOpenError as e:
                    _logger.error(f"Circuit breaker open: {e}")
                    if fallback:
                        _logger.info("Falling back to degraded mode")
                        return fallback(*args, **kwargs)
                    raise
            else:
                return _retry_logic(
                    func, max_retries, backoff_sequence,
                    fallback, _logger, *args, **kwargs
                )

        return wrapper
    return decorator


def _retry_logic(
    func: Callable,
    max_retries: int,
    backoff_sequence: tuple,
    fallback: Optional[Callable],
    logger: logging.Logger,
    *args,
    **kwargs
) -> Any:
    """
    Core retry logic with exponential backoff.

    Args:
        func: Function to retry
        max_retries: Maximum retry attempts
        backoff_sequence: Backoff delays
        fallback: Fallback function
        logger: Logger instance
        *args: Function arguments
        **kwargs: Function keyword arguments

    Returns:
        Function result

    Raises:
        RetryError: If all retries exhausted
    """
    last_exception = None

    for attempt in range(max_retries + 1):
        try:
            result = func(*args, **kwargs)
            if attempt > 0:
                logger.info(f"{func.__name__} succeeded after {attempt} retries")
            return result

        except Exception as e:
            last_exception = e

            if attempt < max_retries:
                # Calculate backoff delay
                backoff_index = min(attempt, len(backoff_sequence) - 1)
                delay = backoff_sequence[backoff_index]

                logger.warning(
                    f"{func.__name__} failed (attempt {attempt + 1}/{max_retries + 1}): "
                    f"{type(e).__name__}: {e}. Retrying in {delay}s..."
                )

                # Log detailed error
                _log_retry_error(func.__name__, attempt, e, delay)

                time.sleep(delay)
            else:
                logger.error(
                    f"{func.__name__} failed after {max_retries} retries: "
                    f"{type(e).__name__}: {e}"
                )

    # All retries exhausted
    if fallback:
        logger.info(f"Falling back to degraded mode for {func.__name__}")
        try:
            return fallback(*args, **kwargs)
        except Exception as fallback_error:
            logger.error(f"Fallback failed: {fallback_error}")
            raise RetryError(
                f"All retries exhausted and fallback failed for {func.__name__}"
            ) from last_exception
    else:
        raise RetryError(
            f"All retries exhausted for {func.__name__}"
        ) from last_exception


def _log_retry_error(func_name: str, attempt: int, error: Exception, delay: float):
    """
    Log retry error with context.

    Args:
        func_name: Function name
        attempt: Attempt number
        error: Exception that occurred
        delay: Backoff delay
    """
    log_file = Path('compliance/resilience/retry-errors.log')
    log_file.parent.mkdir(parents=True, exist_ok=True)

    with open(log_file, 'a') as f:
        f.write(
            f"{datetime.utcnow().isoformat()} - "
            f"Function: {func_name} | "
            f"Attempt: {attempt + 1} | "
            f"Error: {type(error).__name__}: {error} | "
            f"Backoff: {delay}s\n"
        )


# Global circuit breakers for common dependencies
_circuit_breakers = {}


def get_circuit_breaker(name: str, **kwargs) -> CircuitBreaker:
    """
    Get or create a circuit breaker.

    Args:
        name: Circuit breaker name
        **kwargs: CircuitBreaker initialization arguments

    Returns:
        CircuitBreaker instance
    """
    if name not in _circuit_breakers:
        _circuit_breakers[name] = CircuitBreaker(name, **kwargs)
    return _circuit_breakers[name]


def get_all_circuit_breakers() -> Dict[str, CircuitBreaker]:
    """Get all registered circuit breakers."""
    return _circuit_breakers.copy()


if __name__ == '__main__':
    # Example usage
    import random

    # Example function that randomly fails
    @retry_with_backoff(
        max_retries=5,
        backoff_sequence=(1, 2, 4, 8),
        circuit_breaker=get_circuit_breaker('example_api'),
        fallback=lambda: {'status': 'degraded', 'data': None}
    )
    def fetch_data():
        if random.random() < 0.7:  # 70% failure rate
            raise Exception("API temporarily unavailable")
        return {'status': 'success', 'data': [1, 2, 3]}

    # Test
    try:
        result = fetch_data()
        print(f"Result: {result}")
    except RetryError as e:
        print(f"Failed: {e}")
