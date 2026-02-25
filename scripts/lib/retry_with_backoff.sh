#!/bin/bash
# Retry Library with Exponential Backoff
# Implements NFR-6.2: External Dependency Resilience

# Retry configuration
MAX_RETRIES=${MAX_RETRIES:-5}
INITIAL_BACKOFF=${INITIAL_BACKOFF:-1}
ERROR_LOG="${ERROR_LOG:-/home/ladmin/dev/GDF/7F_github/logs/dependency_errors.log}"
CIRCUIT_BREAKER_STATE="${CIRCUIT_BREAKER_STATE:-/tmp/7f_circuit_breaker_state.json}"

# Initialize circuit breaker state
init_circuit_breaker() {
    if [[ ! -f "$CIRCUIT_BREAKER_STATE" ]]; then
        echo '{}' > "$CIRCUIT_BREAKER_STATE"
    fi
}

# Check circuit breaker status for a service
# Usage: check_circuit_breaker "service_name"
# Returns: 0 if circuit is closed (OK), 1 if circuit is open (tripped)
check_circuit_breaker() {
    local service="$1"
    init_circuit_breaker

    local state=$(jq -r --arg svc "$service" '.[$svc] // {}' "$CIRCUIT_BREAKER_STATE")
    local is_open=$(echo "$state" | jq -r '.is_open // false')
    local consecutive_failures=$(echo "$state" | jq -r '.consecutive_failures // 0')

    if [[ "$is_open" == "true" ]]; then
        echo "CIRCUIT_BREAKER_OPEN: $service is unavailable (too many failures)" >&2
        return 1
    fi

    return 0
}

# Trip circuit breaker for a service
# Usage: trip_circuit_breaker "service_name"
trip_circuit_breaker() {
    local service="$1"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    init_circuit_breaker

    jq --arg svc "$service" \
       --arg time "$timestamp" \
       --argjson open true \
       '.[$svc] = {"is_open": $open, "tripped_at": $time, "consecutive_failures": 5}' \
       "$CIRCUIT_BREAKER_STATE" > "${CIRCUIT_BREAKER_STATE}.tmp" && \
       mv "${CIRCUIT_BREAKER_STATE}.tmp" "$CIRCUIT_BREAKER_STATE"

    log_dependency_error "$service" "CIRCUIT_BREAKER_TRIPPED" "Circuit breaker opened after 5 consecutive failures"
}

# Reset circuit breaker for a service
# Usage: reset_circuit_breaker "service_name"
reset_circuit_breaker() {
    local service="$1"

    init_circuit_breaker

    jq --arg svc "$service" \
       --argjson open false \
       '.[$svc] = {"is_open": $open, "consecutive_failures": 0}' \
       "$CIRCUIT_BREAKER_STATE" > "${CIRCUIT_BREAKER_STATE}.tmp" && \
       mv "${CIRCUIT_BREAKER_STATE}.tmp" "$CIRCUIT_BREAKER_STATE"
}

# Increment failure counter for a service
# Usage: increment_failure_counter "service_name"
increment_failure_counter() {
    local service="$1"

    init_circuit_breaker

    local current_failures=$(jq -r --arg svc "$service" '.[$svc].consecutive_failures // 0' "$CIRCUIT_BREAKER_STATE")
    local new_failures=$((current_failures + 1))

    if [[ $new_failures -ge 5 ]]; then
        trip_circuit_breaker "$service"
        return 1
    else
        jq --arg svc "$service" \
           --argjson failures "$new_failures" \
           '.[$svc].consecutive_failures = $failures' \
           "$CIRCUIT_BREAKER_STATE" > "${CIRCUIT_BREAKER_STATE}.tmp" && \
           mv "${CIRCUIT_BREAKER_STATE}.tmp" "$CIRCUIT_BREAKER_STATE"
    fi

    return 0
}

# Log dependency error with context
# Usage: log_dependency_error "service_name" "error_type" "error_message" ["context"]
log_dependency_error() {
    local service="$1"
    local error_type="$2"
    local error_message="$3"
    local context="${4:-}"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    mkdir -p "$(dirname "$ERROR_LOG")"

    local log_entry="[${timestamp}] SERVICE: ${service} | TYPE: ${error_type} | MESSAGE: ${error_message}"
    if [[ -n "$context" ]]; then
        log_entry="${log_entry} | CONTEXT: ${context}"
    fi

    echo "$log_entry" >> "$ERROR_LOG"
}

# Retry function with exponential backoff
# Usage: retry_with_backoff "service_name" command [args...]
# Returns: Exit code of command (0 on success, non-zero on failure)
retry_with_backoff() {
    local service="$1"
    shift
    local command=("$@")

    # Check circuit breaker
    if ! check_circuit_breaker "$service"; then
        log_dependency_error "$service" "CIRCUIT_OPEN" "Request blocked - circuit breaker is open"
        return 1
    fi

    local attempt=1
    local backoff=$INITIAL_BACKOFF
    local exit_code=0

    while [[ $attempt -le $MAX_RETRIES ]]; do
        # Execute command
        if "${command[@]}"; then
            # Success - reset circuit breaker
            reset_circuit_breaker "$service"
            return 0
        else
            exit_code=$?
            log_dependency_error "$service" "RETRY_ATTEMPT_${attempt}" "Command failed with exit code $exit_code" "${command[*]}"

            # Increment failure counter
            if ! increment_failure_counter "$service"; then
                log_dependency_error "$service" "MAX_FAILURES" "Circuit breaker tripped after $attempt failures"
                return 1
            fi

            if [[ $attempt -lt $MAX_RETRIES ]]; then
                echo "Retry attempt $attempt/$MAX_RETRIES failed for $service. Waiting ${backoff}s..." >&2
                sleep "$backoff"
                # Exponential backoff: double the wait time
                backoff=$((backoff * 2))
            else
                echo "All $MAX_RETRIES retry attempts exhausted for $service" >&2
                log_dependency_error "$service" "MAX_RETRIES_EXCEEDED" "All $MAX_RETRIES attempts failed" "${command[*]}"
            fi

            ((attempt++))
        fi
    done

    return $exit_code
}

# Fallback to degraded mode
# Usage: fallback_to_degraded_mode "service_name" "fallback_message"
fallback_to_degraded_mode() {
    local service="$1"
    local message="$2"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    log_dependency_error "$service" "DEGRADED_MODE" "Entering degraded mode: $message"

    echo "[$timestamp] WARNING: $service unavailable - operating in degraded mode" >&2
    echo "$message" >&2
}

# Get circuit breaker statistics
# Usage: get_circuit_breaker_stats
get_circuit_breaker_stats() {
    init_circuit_breaker
    cat "$CIRCUIT_BREAKER_STATE" | jq '.'
}

# Export functions
export -f init_circuit_breaker
export -f check_circuit_breaker
export -f trip_circuit_breaker
export -f reset_circuit_breaker
export -f increment_failure_counter
export -f log_dependency_error
export -f retry_with_backoff
export -f fallback_to_degraded_mode
export -f get_circuit_breaker_stats
