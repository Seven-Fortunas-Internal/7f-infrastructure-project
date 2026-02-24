#!/usr/bin/env python3
"""
API Rate Limiter

Enforces rate limits for all external API calls (NFR-6.1).

Features:
- Per-API rate limiting (GitHub, Claude, Reddit, OpenAI, X)
- Header parsing and automatic limit detection
- Request throttling and queueing
- Rate limit usage tracking
- Violation logging
"""

import time
import json
import threading
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, Optional, Tuple
from collections import deque


class RateLimiter:
    """Rate limiter for external API calls."""

    # Rate limit configurations (requests, period_seconds)
    RATE_LIMITS = {
        'github': {
            'requests_per_hour': 5000,
            'period_seconds': 3600,
            'header_remaining': 'x-ratelimit-remaining',
            'header_reset': 'x-ratelimit-reset'
        },
        'claude': {
            'requests_per_minute': 50,
            'requests_per_day': 40000,
            'period_seconds': 60,
            'day_period_seconds': 86400
        },
        'reddit': {
            'requests_per_minute': 60,
            'period_seconds': 60
        },
        'openai_whisper': {
            'requests_per_minute': 50,  # Conservative default
            'period_seconds': 60
        },
        'x_api': {
            'requests_per_month': 10000,
            'period_seconds': 2592000  # 30 days
        }
    }

    def __init__(self, api_name: str, metrics_file: Optional[Path] = None):
        """
        Initialize rate limiter for specific API.

        Args:
            api_name: Name of API ('github', 'claude', 'reddit', etc.)
            metrics_file: Optional path to save metrics
        """
        self.api_name = api_name
        self.config = self.RATE_LIMITS.get(api_name.lower(), {})
        self.metrics_file = metrics_file or Path(
            'compliance/rate-limits/metrics/api-usage.jsonl'
        )

        # Request tracking
        self.requests = deque()
        self.daily_requests = deque() if 'requests_per_day' in self.config else None
        self.monthly_requests = deque() if 'requests_per_month' in self.config else None

        # Lock for thread safety
        self.lock = threading.Lock()

        # Metrics
        self.total_requests = 0
        self.throttled_requests = 0
        self.violations = 0

    def _clean_old_requests(self):
        """Remove requests outside the rate limit window."""
        now = time.time()

        # Clean minute/hour window
        if 'period_seconds' in self.config:
            period = self.config['period_seconds']
            while self.requests and (now - self.requests[0]) > period:
                self.requests.popleft()

        # Clean daily window
        if self.daily_requests is not None:
            day_period = self.config.get('day_period_seconds', 86400)
            while self.daily_requests and (now - self.daily_requests[0]) > day_period:
                self.daily_requests.popleft()

        # Clean monthly window
        if self.monthly_requests is not None:
            month_period = self.config.get('period_seconds', 2592000)
            while self.monthly_requests and (now - self.monthly_requests[0]) > month_period:
                self.monthly_requests.popleft()

    def check_limit(self) -> Tuple[bool, float]:
        """
        Check if request can be made within rate limits.

        Returns:
            Tuple of (can_proceed, wait_seconds)
        """
        with self.lock:
            self._clean_old_requests()

            # Check minute/hour limit
            if 'requests_per_hour' in self.config:
                max_requests = self.config['requests_per_hour']
            elif 'requests_per_minute' in self.config:
                max_requests = self.config['requests_per_minute']
            else:
                max_requests = float('inf')

            if len(self.requests) >= max_requests:
                # Calculate wait time
                oldest_request = self.requests[0]
                period = self.config['period_seconds']
                wait_seconds = period - (time.time() - oldest_request)
                return False, max(0, wait_seconds)

            # Check daily limit (Claude API)
            if self.daily_requests is not None:
                max_daily = self.config['requests_per_day']
                if len(self.daily_requests) >= max_daily:
                    oldest_request = self.daily_requests[0]
                    wait_seconds = 86400 - (time.time() - oldest_request)
                    return False, max(0, wait_seconds)

            # Check monthly limit (X API)
            if self.monthly_requests is not None:
                max_monthly = self.config['requests_per_month']
                if len(self.monthly_requests) >= max_monthly:
                    oldest_request = self.monthly_requests[0]
                    wait_seconds = 2592000 - (time.time() - oldest_request)
                    return False, max(0, wait_seconds)

            return True, 0

    def wait_if_needed(self) -> float:
        """
        Wait if rate limit would be exceeded.

        Returns:
            Seconds waited (0 if no wait needed)
        """
        can_proceed, wait_seconds = self.check_limit()

        if not can_proceed:
            print(f"⏳ Rate limit reached for {self.api_name}, waiting {wait_seconds:.1f}s")
            self.throttled_requests += 1
            time.sleep(wait_seconds)
            return wait_seconds

        return 0

    def record_request(self, response_headers: Optional[Dict] = None):
        """
        Record a request and update rate limit tracking.

        Args:
            response_headers: Optional API response headers for limit detection
        """
        with self.lock:
            now = time.time()

            # Record request timestamp
            self.requests.append(now)
            if self.daily_requests is not None:
                self.daily_requests.append(now)
            if self.monthly_requests is not None:
                self.monthly_requests.append(now)

            self.total_requests += 1

            # Parse rate limit headers (GitHub)
            if response_headers and self.api_name == 'github':
                remaining_header = self.config.get('header_remaining')
                reset_header = self.config.get('header_reset')

                if remaining_header in response_headers:
                    remaining = int(response_headers[remaining_header])
                    if remaining == 0:
                        self.violations += 1
                        self._log_violation(response_headers)

            # Save metrics
            self._save_metrics()

    def _log_violation(self, response_headers: Dict):
        """
        Log rate limit violation.

        Args:
            response_headers: API response headers
        """
        violation = {
            'timestamp': datetime.utcnow().isoformat(),
            'api': self.api_name,
            'violation_type': 'rate_limit_exceeded',
            'headers': dict(response_headers)
        }

        violations_file = Path('compliance/rate-limits/metrics/violations.jsonl')
        violations_file.parent.mkdir(parents=True, exist_ok=True)

        with open(violations_file, 'a') as f:
            f.write(json.dumps(violation) + '\n')

        print(f"⚠️ Rate limit violation logged for {self.api_name}")

    def _save_metrics(self):
        """Save rate limit usage metrics."""
        self.metrics_file.parent.mkdir(parents=True, exist_ok=True)

        metric = {
            'timestamp': datetime.utcnow().isoformat(),
            'api': self.api_name,
            'total_requests': self.total_requests,
            'throttled_requests': self.throttled_requests,
            'violations': self.violations,
            'current_window_requests': len(self.requests),
            'daily_requests': len(self.daily_requests) if self.daily_requests else None,
            'monthly_requests': len(self.monthly_requests) if self.monthly_requests else None
        }

        with open(self.metrics_file, 'a') as f:
            f.write(json.dumps(metric) + '\n')

    def get_usage_stats(self) -> Dict:
        """
        Get current usage statistics.

        Returns:
            Dictionary containing usage stats
        """
        with self.lock:
            self._clean_old_requests()

            stats = {
                'api': self.api_name,
                'total_requests': self.total_requests,
                'throttled_requests': self.throttled_requests,
                'violations': self.violations,
                'current_window': {
                    'requests': len(self.requests),
                    'limit': self.config.get('requests_per_hour') or self.config.get('requests_per_minute'),
                    'period': self.config.get('period_seconds')
                }
            }

            if self.daily_requests is not None:
                stats['daily'] = {
                    'requests': len(self.daily_requests),
                    'limit': self.config.get('requests_per_day')
                }

            if self.monthly_requests is not None:
                stats['monthly'] = {
                    'requests': len(self.monthly_requests),
                    'limit': self.config.get('requests_per_month')
                }

            return stats


class RateLimitManager:
    """Manages rate limiters for all APIs."""

    def __init__(self):
        """Initialize rate limit manager."""
        self.limiters: Dict[str, RateLimiter] = {}
        self.lock = threading.Lock()

    def get_limiter(self, api_name: str) -> RateLimiter:
        """
        Get or create rate limiter for API.

        Args:
            api_name: Name of API

        Returns:
            RateLimiter instance
        """
        with self.lock:
            if api_name not in self.limiters:
                self.limiters[api_name] = RateLimiter(api_name)
            return self.limiters[api_name]

    def get_all_stats(self) -> Dict[str, Dict]:
        """
        Get usage statistics for all APIs.

        Returns:
            Dictionary mapping API names to stats
        """
        return {
            name: limiter.get_usage_stats()
            for name, limiter in self.limiters.items()
        }


# Global rate limit manager
_rate_limit_manager = RateLimitManager()


def get_rate_limiter(api_name: str) -> RateLimiter:
    """
    Get rate limiter for specified API.

    Args:
        api_name: Name of API ('github', 'claude', 'reddit', etc.)

    Returns:
        RateLimiter instance
    """
    return _rate_limit_manager.get_limiter(api_name)


def wait_for_rate_limit(api_name: str) -> float:
    """
    Wait if rate limit would be exceeded.

    Args:
        api_name: Name of API

    Returns:
        Seconds waited
    """
    limiter = get_rate_limiter(api_name)
    return limiter.wait_if_needed()


def record_api_request(api_name: str, response_headers: Optional[Dict] = None):
    """
    Record an API request.

    Args:
        api_name: Name of API
        response_headers: Optional response headers
    """
    limiter = get_rate_limiter(api_name)
    limiter.record_request(response_headers)


if __name__ == '__main__':
    # Example usage
    print("Rate Limiter Configuration:")
    print("=" * 50)

    for api_name, config in RateLimiter.RATE_LIMITS.items():
        print(f"\n{api_name.upper()}:")
        for key, value in config.items():
            if not key.startswith('header_'):
                print(f"  {key}: {value}")
