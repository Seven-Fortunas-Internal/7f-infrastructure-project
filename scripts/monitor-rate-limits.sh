#!/bin/bash
# Rate Limit Monitoring Dashboard
# Displays current rate limit usage across all APIs

source "$(dirname "$0")/lib/rate_limiter.sh"

CONFIG_FILE="/home/ladmin/dev/GDF/7F_github/config/rate_limits.json"

echo "═══════════════════════════════════════════════════════"
echo "  Seven Fortunas API Rate Limit Monitoring Dashboard"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# Display current rate limit state
echo "Current Rate Limit Usage:"
echo "─────────────────────────────────────────────────────"
get_rate_limit_stats | jq -r 'to_entries[] | "  \(.key): \(.value.request_count) requests (last reset: \(.value.last_reset | strftime("%Y-%m-%d %H:%M:%S")))"'
echo ""

# Display configured limits
echo "Configured API Limits:"
echo "─────────────────────────────────────────────────────"
jq -r '.apis | to_entries[] | "  \(.value.name):"' "$CONFIG_FILE"
jq -r '.apis | to_entries[] | "    \(.value.limits | to_entries[] | "- \(.key): \(.value)")"' "$CONFIG_FILE"
echo ""

# Check for recent violations
VIOLATIONS_LOG="/home/ladmin/dev/GDF/7F_github/logs/rate_limit_violations.log"
if [[ -f "$VIOLATIONS_LOG" ]]; then
    echo "Recent Rate Limit Violations (last 10):"
    echo "─────────────────────────────────────────────────────"
    tail -10 "$VIOLATIONS_LOG" 2>/dev/null || echo "  No violations recorded"
else
    echo "Recent Rate Limit Violations:"
    echo "─────────────────────────────────────────────────────"
    echo "  No violations recorded (log file not found)"
fi
echo ""

# Calculate usage percentages
echo "Usage Analysis:"
echo "─────────────────────────────────────────────────────"

# GitHub API usage
github_usage=$(jq -r '.github_api.request_count // 0' "$RATE_LIMIT_STATE" 2>/dev/null || echo "0")
github_limit=$(jq -r '.apis.github.limits.requests_per_hour' "$CONFIG_FILE")
if [[ -n "$github_limit" && "$github_limit" != "null" ]]; then
    github_pct=$(echo "scale=1; ($github_usage / $github_limit) * 100" | bc)
    echo "  GitHub API: ${github_usage}/${github_limit} requests (${github_pct}%)"
    if (( $(echo "$github_pct > 90" | bc -l) )); then
        echo "    ⚠️  WARNING: Usage exceeds 90% threshold!"
    fi
fi

# Claude API usage (minute)
claude_minute_usage=$(jq -r '.claude_api_minute.request_count // 0' "$RATE_LIMIT_STATE" 2>/dev/null || echo "0")
claude_minute_limit=$(jq -r '.apis.claude.limits.requests_per_minute' "$CONFIG_FILE")
if [[ -n "$claude_minute_limit" && "$claude_minute_limit" != "null" ]]; then
    claude_minute_pct=$(echo "scale=1; ($claude_minute_usage / $claude_minute_limit) * 100" | bc)
    echo "  Claude API (per minute): ${claude_minute_usage}/${claude_minute_limit} requests (${claude_minute_pct}%)"
    if (( $(echo "$claude_minute_pct > 90" | bc -l) )); then
        echo "    ⚠️  WARNING: Usage exceeds 90% threshold!"
    fi
fi

# Claude API usage (daily)
claude_daily_usage=$(jq -r '.claude_api_daily.request_count // 0' "$RATE_LIMIT_STATE" 2>/dev/null || echo "0")
claude_daily_limit=$(jq -r '.apis.claude.limits.requests_per_day' "$CONFIG_FILE")
if [[ -n "$claude_daily_limit" && "$claude_daily_limit" != "null" ]]; then
    claude_daily_pct=$(echo "scale=1; ($claude_daily_usage / $claude_daily_limit) * 100" | bc)
    echo "  Claude API (per day): ${claude_daily_usage}/${claude_daily_limit} requests (${claude_daily_pct}%)"
    if (( $(echo "$claude_daily_pct > 90" | bc -l) )); then
        echo "    ⚠️  WARNING: Usage exceeds 90% threshold!"
    fi
fi

# Reddit API usage
reddit_usage=$(jq -r '.reddit_api.request_count // 0' "$RATE_LIMIT_STATE" 2>/dev/null || echo "0")
reddit_limit=$(jq -r '.apis.reddit.limits.requests_per_minute' "$CONFIG_FILE")
if [[ -n "$reddit_limit" && "$reddit_limit" != "null" ]]; then
    reddit_pct=$(echo "scale=1; ($reddit_usage / $reddit_limit) * 100" | bc)
    echo "  Reddit API: ${reddit_usage}/${reddit_limit} requests (${reddit_pct}%)"
    if (( $(echo "$reddit_pct > 90" | bc -l) )); then
        echo "    ⚠️  WARNING: Usage exceeds 90% threshold!"
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo "Tip: Run this script regularly to monitor API usage"
echo "Integration: Metrics feed into NFR-9.1 (Cost Management)"
echo "═══════════════════════════════════════════════════════"
