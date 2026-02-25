#!/bin/bash
# Example: Resilient API Calls with Retry Logic and Circuit Breakers

set -e

SCRIPT_DIR="$(dirname "$0")/.."
source "${SCRIPT_DIR}/lib/resilient_api_wrappers.sh"

echo "═══════════════════════════════════════════════════════"
echo "  Resilient API Usage Examples"
echo "═══════════════════════════════════════════════════════"
echo ""

# Example 1: Resilient GitHub API call
echo "Example 1: Resilient GitHub API call with retry"
echo "─────────────────────────────────────────────────────"
if gh_api_resilient /repos/Seven-Fortunas/dashboards 2>/dev/null | jq -r '.name' 2>/dev/null; then
    echo "  ✓ GitHub API call succeeded"
else
    echo "  ✗ GitHub API call failed after retries"
fi
echo ""

# Example 2: API call with fallback to cached data
echo "Example 2: API call with degraded mode fallback"
echo "─────────────────────────────────────────────────────"
FALLBACK_DATA='{"name": "cached-data", "description": "Fallback data from cache"}'
RESULT=$(api_call_with_fallback "test_service" "$FALLBACK_DATA" \
    gh api /repos/Seven-Fortunas/dashboards 2>/dev/null)
EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
    echo "  ✓ API call succeeded (live data)"
elif [[ $EXIT_CODE -eq 2 ]]; then
    echo "  ⚠️  API call failed - using fallback data (degraded mode)"
else
    echo "  ✗ API call and fallback both failed"
fi
echo ""

# Example 3: Check circuit breaker status
echo "Example 3: Circuit breaker status"
echo "─────────────────────────────────────────────────────"
get_circuit_breaker_stats
echo ""

# Example 4: Retry with exponential backoff
echo "Example 4: Exponential backoff in action"
echo "─────────────────────────────────────────────────────"
echo "Demonstrating retry logic (watch the timing)..."
# This will fail intentionally to show retry behavior
retry_with_backoff "demo_service" /bin/false 2>&1 | head -5 || echo "  Retries exhausted (as expected for demo)"
echo ""

echo "═══════════════════════════════════════════════════════"
echo "All resilience examples completed"
echo "═══════════════════════════════════════════════════════"
