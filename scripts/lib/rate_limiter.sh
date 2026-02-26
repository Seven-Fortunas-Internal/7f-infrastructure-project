#!/bin/bash
# Rate Limiter Library for Seven Fortunas API Integrations
# Enforces rate limits for all external APIs

# Rate limit configuration file
RATE_LIMIT_CONFIG="${RATE_LIMIT_CONFIG:-/home/ladmin/dev/GDF/7F_github/config/rate_limits.json}"
RATE_LIMIT_STATE="${RATE_LIMIT_STATE:-/tmp/7f_rate_limit_state.json}"

# Initialize rate limit state file
init_rate_limiter() {
    if [[ ! -f "$RATE_LIMIT_STATE" ]]; then
        echo '{}' > "$RATE_LIMIT_STATE"
    fi
}

# Get current timestamp in seconds
get_timestamp() {
    date +%s
}

# Check if API call is allowed based on rate limits
# Usage: check_rate_limit "github_api" "hourly" 5000
check_rate_limit() {
    local api_name="$1"
    local window="$2"    # "minute", "hourly", "daily"
    local limit="$3"

    init_rate_limiter

    local current_time=$(get_timestamp)
    local window_seconds=60

    case "$window" in
        "minute")
            window_seconds=60
            ;;
        "hourly")
            window_seconds=3600
            ;;
        "daily")
            window_seconds=86400
            ;;
    esac

    # Get API state from JSON
    local api_state=$(jq -r --arg api "$api_name" '.[$api] // {}' "$RATE_LIMIT_STATE")
    local last_reset=$(echo "$api_state" | jq -r '.last_reset // 0')
    local request_count=$(echo "$api_state" | jq -r '.request_count // 0')

    # Check if we need to reset the window
    if (( current_time - last_reset >= window_seconds )); then
        # Reset window
        jq --arg api "$api_name" \
           --argjson time "$current_time" \
           '.[$api] = {"last_reset": $time, "request_count": 0}' \
           "$RATE_LIMIT_STATE" > "${RATE_LIMIT_STATE}.tmp" && \
           mv "${RATE_LIMIT_STATE}.tmp" "$RATE_LIMIT_STATE"
        request_count=0
    fi

    # Check if we're under the limit
    if (( request_count < limit )); then
        # Increment request count
        jq --arg api "$api_name" \
           '.[$api].request_count += 1' \
           "$RATE_LIMIT_STATE" > "${RATE_LIMIT_STATE}.tmp" && \
           mv "${RATE_LIMIT_STATE}.tmp" "$RATE_LIMIT_STATE"
        return 0  # Allowed
    else
        # Calculate wait time
        local wait_time=$((window_seconds - (current_time - last_reset)))
        echo "RATE_LIMIT_EXCEEDED: $api_name - Wait ${wait_time}s before next request" >&2
        return 1  # Rate limit exceeded
    fi
}

# Throttle API call - wait if necessary to respect rate limits
# Usage: throttle_api_call "github_api" "hourly" 5000
throttle_api_call() {
    local api_name="$1"
    local window="$2"
    local limit="$3"

    while ! check_rate_limit "$api_name" "$window" "$limit"; do
        echo "Throttling $api_name API call - rate limit reached" >&2
        sleep 5  # Wait 5 seconds before retrying
    done
}

# Parse rate limit headers from API response
# Usage: parse_rate_limit_headers "$response_headers" "github"
parse_rate_limit_headers() {
    local headers="$1"
    local api_type="$2"

    case "$api_type" in
        "github")
            local remaining=$(echo "$headers" | grep -i "x-ratelimit-remaining:" | cut -d: -f2 | tr -d ' \r')
            local reset=$(echo "$headers" | grep -i "x-ratelimit-reset:" | cut -d: -f2 | tr -d ' \r')
            echo "GitHub API - Remaining: $remaining, Reset: $reset" >&2
            ;;
        "claude")
            local remaining=$(echo "$headers" | grep -i "anthropic-ratelimit-requests-remaining:" | cut -d: -f2 | tr -d ' \r')
            local reset=$(echo "$headers" | grep -i "anthropic-ratelimit-requests-reset:" | cut -d: -f2 | tr -d ' \r')
            echo "Claude API - Remaining: $remaining, Reset: $reset" >&2
            ;;
    esac
}

# Log rate limit violation
# Usage: log_rate_limit_violation "github_api" "5000 req/hour exceeded"
log_rate_limit_violation() {
    local api_name="$1"
    local message="$2"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    echo "[${timestamp}] RATE_LIMIT_VIOLATION: ${api_name} - ${message}" >> /home/ladmin/dev/GDF/7F_github/logs/rate_limit_violations.log
}

# Get rate limit usage statistics
# Usage: get_rate_limit_stats
get_rate_limit_stats() {
    init_rate_limiter
    cat "$RATE_LIMIT_STATE" | jq '.'
}

# Export functions for use in other scripts
export -f init_rate_limiter
export -f check_rate_limit
export -f throttle_api_call
export -f parse_rate_limit_headers
export -f log_rate_limit_violation
export -f get_rate_limit_stats
