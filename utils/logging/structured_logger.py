#!/usr/bin/env python3
"""
Structured JSON Logger for Seven Fortunas Infrastructure
Compliant with NFR-8.1 Structured Logging Standard
"""

import json
import sys
from datetime import datetime, timezone


class StructuredLogger:
    """
    Emit structured JSON logs with consistent format.

    Usage:
        logger = StructuredLogger("my-component")
        logger.info("Operation successful", user_id="123", duration_ms=500)
        logger.error("Operation failed", error_code=404, retry_count=3)
    """

    def __init__(self, component: str):
        """
        Initialize logger with component name.

        Args:
            component: Name of the system/service (e.g., "dashboard-updater")
        """
        self.component = component

    def _log(self, severity: str, message: str, context: dict = None):
        """
        Emit a structured log entry.

        Args:
            severity: Log level (DEBUG, INFO, WARN, ERROR, FATAL)
            message: Human-readable description
            context: Structured metadata (optional)
        """
        log_entry = {
            "timestamp": datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.%f')[:-3] + 'Z',
            "severity": severity,
            "component": self.component,
            "message": message,
            "context": context or {}
        }
        print(json.dumps(log_entry), file=sys.stdout, flush=True)

    def debug(self, message: str, **context):
        """Log DEBUG level message"""
        self._log("DEBUG", message, context)

    def info(self, message: str, **context):
        """Log INFO level message"""
        self._log("INFO", message, context)

    def warn(self, message: str, **context):
        """Log WARN level message"""
        self._log("WARN", message, context)

    def error(self, message: str, **context):
        """Log ERROR level message"""
        self._log("ERROR", message, context)

    def fatal(self, message: str, **context):
        """Log FATAL level message"""
        self._log("FATAL", message, context)


def main():
    """Example usage and testing"""
    logger = StructuredLogger("structured-logger-test")

    # Test each severity level
    logger.debug("Debug message example", variable="test_value", line_number=42)
    logger.info("Info message example", operation="test", status="success")
    logger.warn("Warning message example", threshold_percentage=90, current_value=4500)
    logger.error("Error message example", error_code=404, retry_attempt=2)
    logger.fatal("Fatal message example", reason="unrecoverable_error", exit_code=1)

    print("\n--- All log levels tested successfully ---", file=sys.stderr)


if __name__ == '__main__':
    main()
