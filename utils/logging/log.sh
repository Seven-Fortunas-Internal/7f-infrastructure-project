#!/bin/bash
#
# Structured JSON Logging Functions for Bash Scripts
# Compliant with NFR-8.1 Structured Logging Standard
#
# Usage:
#   source utils/logging/log.sh
#   log_info "my-component" "Operation successful" user=jorge duration_ms=500
#   log_error "my-component" "Operation failed" error=timeout retry=3
#
# Note: This is a wrapper around the Python structured_logger.py for guaranteed JSON validity

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_LOGGER="$SCRIPT_DIR/structured_logger.py"

# Function to emit structured log entry
_log_with_python() {
  local severity="$1"
  local component="$2"
  local message="$3"
  shift 3

  # Convert remaining args to Python kwargs
  local py_cmd="from structured_logger import StructuredLogger; logger = StructuredLogger('$component'); logger.${severity,,}('$message'"
  for arg in "$@"; do
    key="${arg%%=*}"
    val="${arg#*=}"
    py_cmd="$py_cmd, $key='$val'"
  done
  py_cmd="$py_cmd)"

  python3 -c "import sys; sys.path.insert(0, '$SCRIPT_DIR'); $py_cmd"
}

# Convenience functions for each severity level

log_debug() {
  _log_with_python "DEBUG" "$@"
}

log_info() {
  _log_with_python "INFO" "$@"
}

log_warn() {
  _log_with_python "WARN" "$@"
}

log_error() {
  _log_with_python "ERROR" "$@"
}

log_fatal() {
  _log_with_python "FATAL" "$@"
}

# If script is executed directly (not sourced), run tests
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Testing structured logging functions..." >&2
  echo "" >&2

  log_debug "log-test" "Debug message example" variable=test_value line=42
  log_info "log-test" "Info message example" operation=test status=success
  log_warn "log-test" "Warning message example" threshold_pct=90 current=4500
  log_error "log-test" "Error message example" error_code=404 retry=2
  log_fatal "log-test" "Fatal message example" reason=unrecoverable exit_code=1

  echo "" >&2
  echo "All log levels tested successfully" >&2
fi
