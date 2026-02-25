#!/bin/bash
# GitHub API Wrapper with Rate Limiting
# Ensures all GitHub API calls respect rate limits

source "$(dirname "$0")/rate_limiter.sh"

# GitHub API rate limit: 5,000 requests/hour (authenticated)
GITHUB_LIMIT=5000
GITHUB_WINDOW="hourly"

# Wrapper for gh api command
gh_api_rate_limited() {
    # Check rate limit before making request
    throttle_api_call "github_api" "$GITHUB_WINDOW" "$GITHUB_LIMIT"

    # Make the actual API call
    local response
    local exit_code

    response=$(gh api "$@" -i 2>&1)
    exit_code=$?

    # Parse rate limit headers from response
    if [[ $exit_code -eq 0 ]]; then
        parse_rate_limit_headers "$response" "github"
    else
        # Check if error is rate limit related
        if echo "$response" | grep -q "rate limit"; then
            log_rate_limit_violation "github_api" "Rate limit exceeded during API call: $*"
        fi
    fi

    # Return response (strip headers if -i was used)
    echo "$response" | sed '1,/^$/d'
    return $exit_code
}

# Wrapper for gh repo view
gh_repo_view_rate_limited() {
    throttle_api_call "github_api" "$GITHUB_WINDOW" "$GITHUB_LIMIT"
    gh repo view "$@"
}

# Wrapper for gh pr list
gh_pr_list_rate_limited() {
    throttle_api_call "github_api" "$GITHUB_WINDOW" "$GITHUB_LIMIT"
    gh pr list "$@"
}

# Wrapper for gh issue list
gh_issue_list_rate_limited() {
    throttle_api_call "github_api" "$GITHUB_WINDOW" "$GITHUB_LIMIT"
    gh issue list "$@"
}

# Export wrapper functions
export -f gh_api_rate_limited
export -f gh_repo_view_rate_limited
export -f gh_pr_list_rate_limited
export -f gh_issue_list_rate_limited
