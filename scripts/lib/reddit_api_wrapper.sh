#!/bin/bash
# Reddit JSON API Wrapper with Rate Limiting
# Ensures all Reddit API calls respect rate limits

source "$(dirname "$0")/rate_limiter.sh"

# Reddit API rate limit: 60 requests/minute (unauthenticated)
REDDIT_LIMIT=60
REDDIT_WINDOW="minute"

# Wrapper for Reddit JSON API calls
reddit_api_rate_limited() {
    local subreddit="$1"
    local filter="${2:-.json}"  # Default to .json if not specified

    # Check rate limit before making request
    throttle_api_call "reddit_api" "$REDDIT_WINDOW" "$REDDIT_LIMIT"

    # Make the actual API call
    local url="https://www.reddit.com/r/${subreddit}/${filter}"
    local response
    local exit_code

    response=$(curl -sf -H "User-Agent: SevenFortunas/1.0" "$url" 2>&1)
    exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        echo "$response"
    else
        log_rate_limit_violation "reddit_api" "Failed to fetch: $url"
        return $exit_code
    fi
}

# Fetch top posts from subreddit
reddit_fetch_top_rate_limited() {
    local subreddit="$1"
    local time_filter="${2:-week}"  # hour, day, week, month, year, all

    throttle_api_call "reddit_api" "$REDDIT_WINDOW" "$REDDIT_LIMIT"

    curl -sf -H "User-Agent: SevenFortunas/1.0" \
         "https://www.reddit.com/r/${subreddit}/top.json?t=${time_filter}&limit=25"
}

# Export wrapper functions
export -f reddit_api_rate_limited
export -f reddit_fetch_top_rate_limited
