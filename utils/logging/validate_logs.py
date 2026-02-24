#!/usr/bin/env python3
"""
Log Validation Script for Seven Fortunas Structured Logs
Validates logs against NFR-8.1 Structured Logging Standard

Usage:
    cat logfile.jsonl | python3 validate_logs.py
    python3 validate_logs.py < logfile.jsonl
    echo '{"timestamp":"...","severity":"INFO",...}' | python3 validate_logs.py
"""

import json
import sys
from typing import Tuple


VALID_SEVERITIES = ['DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL']
REQUIRED_FIELDS = ['timestamp', 'severity', 'component', 'message', 'context']


def validate_log_entry(log_line: str) -> Tuple[bool, str]:
    """
    Validate a single log entry against the standard.

    Args:
        log_line: JSON log entry as string

    Returns:
        Tuple of (is_valid: bool, message: str)
    """
    # Parse JSON
    try:
        entry = json.loads(log_line)
    except json.JSONDecodeError as e:
        return False, f"Invalid JSON: {e}"

    # Check required fields
    for field in REQUIRED_FIELDS:
        if field not in entry:
            return False, f"Missing required field: {field}"

    # Check severity level
    if entry['severity'] not in VALID_SEVERITIES:
        return False, f"Invalid severity: {entry['severity']} (must be one of {VALID_SEVERITIES})"

    # Check timestamp format (basic check for UTC)
    if not entry['timestamp'].endswith('Z'):
        return False, "Timestamp must be in UTC (end with 'Z')"

    # Check component is non-empty string
    if not isinstance(entry['component'], str) or not entry['component']:
        return False, "Component must be a non-empty string"

    # Check message is non-empty string
    if not isinstance(entry['message'], str) or not entry['message']:
        return False, "Message must be a non-empty string"

    # Check context is an object
    if not isinstance(entry['context'], dict):
        return False, "Context must be a JSON object (dict)"

    # Check for secrets in context (basic check)
    context_str = json.dumps(entry['context']).lower()
    dangerous_keys = ['password', 'token', 'secret', 'api_key', 'apikey']
    for key in dangerous_keys:
        if key in context_str:
            return False, f"Warning: Potential secret in context (found '{key}')"

    return True, "Valid"


def main():
    """Validate logs from stdin"""
    total = 0
    valid = 0
    invalid = 0

    for line_num, line in enumerate(sys.stdin, 1):
        line = line.strip()
        if not line:
            continue  # Skip empty lines

        total += 1
        is_valid, message = validate_log_entry(line)

        if is_valid:
            valid += 1
        else:
            invalid += 1
            print(f"Line {line_num}: INVALID - {message}", file=sys.stderr)
            print(f"  Content: {line[:100]}...", file=sys.stderr)

    # Print summary
    print(f"\n--- Validation Summary ---", file=sys.stderr)
    print(f"Total entries: {total}", file=sys.stderr)
    print(f"Valid: {valid} ({100*valid//total if total > 0 else 0}%)", file=sys.stderr)
    print(f"Invalid: {invalid} ({100*invalid//total if total > 0 else 0}%)", file=sys.stderr)

    # Exit with error code if any invalid entries
    sys.exit(0 if invalid == 0 else 1)


if __name__ == '__main__':
    main()
