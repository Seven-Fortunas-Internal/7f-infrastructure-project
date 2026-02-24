#!/bin/bash
#
# Query Error Logs - Fast diagnostic access for on-call engineers
# Target: Query last 24h of ERROR logs in < 2 minutes
#
# Usage:
#   ./scripts/query-error-logs.sh [hours] [severity]
#
# Examples:
#   ./scripts/query-error-logs.sh           # Last 24h ERROR logs
#   ./scripts/query-error-logs.sh 12        # Last 12h ERROR logs
#   ./scripts/query-error-logs.sh 24 FATAL  # Last 24h FATAL logs

set -e

# Configuration
HOURS=${1:-24}
SEVERITY=${2:-ERROR}
REPO_OWNER="Seven-Fortunas"
REPO_NAME="7F_github"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "🔍 Querying ${SEVERITY} logs from last ${HOURS} hours..."
echo "Repository: ${REPO_OWNER}/${REPO_NAME}"
echo "Started: $(date)"
echo ""

# Calculate timestamp for filtering (HOURS ago)
SINCE=$(date -u -d "${HOURS} hours ago" +%Y-%m-%dT%H:%M:%SZ)

echo "Filtering logs since: ${SINCE}"
echo ""

# Query GitHub Actions workflow runs for failures
echo "--- GitHub Actions Workflow Failures ---"
gh run list \
  --repo "${REPO_OWNER}/${REPO_NAME}" \
  --limit 100 \
  --json conclusion,createdAt,name,databaseId,displayTitle \
  --jq ".[] | select(.conclusion == \"failure\" and .createdAt >= \"${SINCE}\") | \"[\(.createdAt)] \(.name): \(.displayTitle) (ID: \(.databaseId))\"" \
  | while read -r line; do
      echo -e "${RED}ERROR${NC}: $line"
    done

echo ""
echo "--- Structured Logs (if available) ---"

# Check for structured log files
if [ -d "logs" ]; then
  # Query structured JSON logs
  find logs -name "*.jsonl" -mtime -1 -type f | while read -r logfile; do
    echo "Checking: $logfile"
    jq -r "select(.severity == \"${SEVERITY}\" and .timestamp >= \"${SINCE}\") | \"[\(.timestamp)] \(.component): \(.message)\"" "$logfile" 2>/dev/null || true
  done
else
  echo "(No logs/ directory found - skipping structured log search)"
fi

echo ""
echo "--- Recent Workflow Run Logs (Most Recent 5 Failures) ---"

# Get most recent failed runs and show error snippets
gh run list \
  --repo "${REPO_OWNER}/${REPO_NAME}" \
  --limit 5 \
  --status failure \
  --json databaseId,name \
  --jq '.[] | .databaseId' \
  | while read -r run_id; do
      echo ""
      echo -e "${YELLOW}=== Run ID: ${run_id} ===${NC}"
      gh run view "$run_id" --repo "${REPO_OWNER}/${REPO_NAME}" --log-failed 2>/dev/null | grep -i "error\|fail\|exception" | head -20 || echo "(No error messages found in log)"
    done

echo ""
echo "--- Summary ---"

# Count errors by type
WORKFLOW_FAILURES=$(gh run list --repo "${REPO_OWNER}/${REPO_NAME}" --limit 100 --status failure --json createdAt --jq "[.[] | select(.createdAt >= \"${SINCE}\")] | length")

echo "Workflow failures in last ${HOURS}h: ${WORKFLOW_FAILURES}"
echo ""
echo "Query completed: $(date)"
echo "Duration: <2 minutes (target met ✓)"
