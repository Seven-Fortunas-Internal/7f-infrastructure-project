#!/bin/bash
# Resilient API Wrappers with Retry Logic and Circuit Breakers
# Combines rate limiting with retry logic for robust external API calls

source "$(dirname "$0")/rate_limiter.sh"
source "$(dirname "$0")/retry_with_backoff.sh"

# Resilient GitHub API call
# Usage: gh_api_resilient [gh api arguments...]
gh_api_resilient() {
    # First check rate limits
    throttle_api_call "github_api" "hourly" 5000

    # Then execute with retry logic
    retry_with_backoff "github_api" gh api "$@"
}

# Resilient Reddit API call
# Usage: reddit_api_resilient "subreddit" ["filter"]
reddit_api_resilient() {
    local subreddit="$1"
    local filter="${2:-.json}"

    # Check rate limits
    throttle_api_call "reddit_api" "minute" 60

    # Execute with retry logic
    retry_with_backoff "reddit_api" curl -sf -H "User-Agent: SevenFortunas/1.0" \
        "https://www.reddit.com/r/${subreddit}/${filter}"
}

# Resilient Claude API call
# Usage: claude_api_resilient [arguments...]
claude_api_resilient() {
    # Check rate limits
    throttle_api_call "claude_api_minute" "minute" 50
    throttle_api_call "claude_api_daily" "daily" 40000

    # Execute with retry logic
    retry_with_backoff "claude_api" "$@"
}

# Resilient API call with degraded fallback
# Usage: api_call_with_fallback "service_name" "fallback_data" command [args...]
api_call_with_fallback() {
    local service="$1"
    local fallback_data="$2"
    shift 2
    local command=("$@")

    # Try the API call with retry logic
    if ! retry_with_backoff "$service" "${command[@]}"; then
        # If all retries fail, fall back to degraded mode
        fallback_to_degraded_mode "$service" "Using cached/fallback data"
        echo "$fallback_data"
        return 2  # Special exit code indicating degraded mode
    fi
}

# Export functions
export -f gh_api_resilient
export -f reddit_api_resilient
export -f claude_api_resilient
export -f api_call_with_fallback
