#!/bin/bash
# Rate Limit Library: Track and enforce API rate limits

check_github_rate_limit() {
    RATE_LIMIT=$(gh api rate_limit --jq '.rate')
    REMAINING=$(echo "$RATE_LIMIT" | jq -r '.remaining')
    LIMIT=$(echo "$RATE_LIMIT" | jq -r '.limit')
    RESET=$(echo "$RATE_LIMIT" | jq -r '.reset')

    echo "GitHub API: $REMAINING/$LIMIT remaining (resets: $(date -d @$RESET))"

    if [ $REMAINING -lt $((LIMIT / 5)) ]; then
        echo "⚠ WARNING: GitHub rate limit below 20%"
        return 1
    fi
    return 0
}
