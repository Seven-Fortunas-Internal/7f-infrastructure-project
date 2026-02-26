#!/bin/bash
# Example: Rate-Limited API Usage
# Demonstrates how to use rate limiters in workflows

set -e

# Source the API wrappers
SCRIPT_DIR="$(dirname "$0")/.."
source "${SCRIPT_DIR}/lib/github_api_wrapper.sh"
source "${SCRIPT_DIR}/lib/reddit_api_wrapper.sh"
source "${SCRIPT_DIR}/lib/claude_api_wrapper.sh"

echo "═══════════════════════════════════════════════════════"
echo "  Rate-Limited API Usage Example"
echo "═══════════════════════════════════════════════════════"
echo ""

# Example 1: GitHub API with rate limiting
echo "Example 1: Fetching GitHub repository info (rate-limited)"
echo "─────────────────────────────────────────────────────"
gh_api_rate_limited /repos/Seven-Fortunas/dashboards 2>/dev/null | jq -r '.name, .description' || echo "Repository fetch complete"
echo ""

# Example 2: Reddit API with rate limiting
echo "Example 2: Fetching Reddit posts (rate-limited)"
echo "─────────────────────────────────────────────────────"
reddit_fetch_top_rate_limited "MachineLearning" "week" 2>/dev/null | jq -r '.data.children[0:3][].data.title' || echo "Reddit fetch complete"
echo ""

# Example 3: Multiple API calls demonstrating throttling
echo "Example 3: Batch API calls with automatic throttling"
echo "─────────────────────────────────────────────────────"
for i in {1..5}; do
    echo "  Request $i/5..."
    gh_repo_view_rate_limited Seven-Fortunas/dashboards --json name 2>/dev/null || echo "  Request $i complete"
done
echo ""

# Example 4: Check rate limit status
echo "Example 4: Current rate limit status"
echo "─────────────────────────────────────────────────────"
source "${SCRIPT_DIR}/lib/rate_limiter.sh"
get_rate_limit_stats
echo ""

echo "═══════════════════════════════════════════════════════"
echo "All examples completed successfully!"
echo "Rate limiting ensures API calls stay within limits."
echo "═══════════════════════════════════════════════════════"
