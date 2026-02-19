#!/bin/bash
# Monthly Workflow Reliability Report
# Calculates 99% success rate compliance

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT="$PROJECT_ROOT/compliance/workflow-reliability/reports/workflow-reliability-$TIMESTAMP.json"

echo "=== Monthly Workflow Reliability Report ==="
echo "Date: $(date)"
echo "Report: $REPORT"
echo ""

# Verify GitHub authentication
if ! gh auth status &>/dev/null; then
    echo "ERROR: GitHub CLI not authenticated"
    exit 1
fi

# Repositories to track
REPOS=(
    "Seven-Fortunas-Internal/7f-infrastructure-project"
    "Seven-Fortunas-Internal/seven-fortunas-brain"
    "Seven-Fortunas/dashboards"
)

TOTAL_RUNS=0
SUCCESSFUL_RUNS=0
FAILED_RUNS=0

echo "1. Collecting workflow run data (last 30 days)..."

for REPO in "${REPOS[@]}"; do
    echo "  Processing: $REPO"

    # Get workflow runs from last 30 days
    RUNS=$(gh api "repos/$REPO/actions/runs?per_page=100&created=>=$(date -d '30 days ago' -u +%Y-%m-%dT%H:%M:%SZ)" --jq '.workflow_runs[] | {
      id,
      status,
      conclusion,
      name: .name,
      created_at
    }' 2>/dev/null || echo "[]")

    if [[ -n "$RUNS" ]]; then
        # Count completed runs only
        REPO_TOTAL=$(echo "$RUNS" | jq -s '[.[] | select(.status == "completed")] | length')
        REPO_SUCCESS=$(echo "$RUNS" | jq -s '[.[] | select(.status == "completed" and .conclusion == "success")] | length')
        REPO_FAILED=$(echo "$RUNS" | jq -s '[.[] | select(.status == "completed" and .conclusion != "success")] | length')

        TOTAL_RUNS=$((TOTAL_RUNS + REPO_TOTAL))
        SUCCESSFUL_RUNS=$((SUCCESSFUL_RUNS + REPO_SUCCESS))
        FAILED_RUNS=$((FAILED_RUNS + REPO_FAILED))

        echo "    Runs: $REPO_TOTAL | Success: $REPO_SUCCESS | Failed: $REPO_FAILED"
    fi
done

echo ""
echo "2. Calculating reliability metrics..."

# Calculate success rate
if [[ $TOTAL_RUNS -gt 0 ]]; then
    SUCCESS_RATE=$(awk "BEGIN {printf \"%.2f\", ($SUCCESSFUL_RUNS / $TOTAL_RUNS) * 100}")
    FAILURE_RATE=$(awk "BEGIN {printf \"%.2f\", ($FAILED_RUNS / $TOTAL_RUNS) * 100}")
else
    SUCCESS_RATE="0.00"
    FAILURE_RATE="0.00"
fi

echo "  Total workflow runs: $TOTAL_RUNS"
echo "  Successful runs: $SUCCESSFUL_RUNS"
echo "  Failed runs: $FAILED_RUNS"
echo "  Success rate: $SUCCESS_RATE%"
echo "  Failure rate: $FAILURE_RATE%"
echo ""

# Check target compliance
if (( $(echo "$SUCCESS_RATE >= 99.0" | bc -l) )); then
    COMPLIANCE_STATUS="COMPLIANT"
    echo "✓ Workflow reliability target met: $SUCCESS_RATE% ≥ 99%"
else
    COMPLIANCE_STATUS="NON_COMPLIANT"
    echo "✗ Workflow reliability below target: $SUCCESS_RATE% < 99%"
fi

echo ""

# Generate JSON report
cat > "$REPORT" << JSON
{
  "report_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "measurement_period": "last_30_days",
  "owner": "Jorge (VP AI-SecOps)",
  "repositories": [
    $(printf '"%s"' "${REPOS[@]}" | paste -sd, -)
  ],
  "metrics": {
    "total_workflow_runs": $TOTAL_RUNS,
    "successful_runs": $SUCCESSFUL_RUNS,
    "failed_runs": $FAILED_RUNS,
    "failed_runs_internal": $FAILED_RUNS,
    "failed_runs_external": 0,
    "success_rate": $SUCCESS_RATE,
    "failure_rate": $FAILURE_RATE,
    "internal_failure_rate": $FAILURE_RATE
  },
  "targets": {
    "success_rate": 99.0,
    "exclude_external_outages": true
  },
  "compliance": {
    "status": "$COMPLIANCE_STATUS",
    "met_target": $([ "$COMPLIANCE_STATUS" == "COMPLIANT" ] && echo "true" || echo "false")
  },
  "recommendations": [
    $(if [[ "$COMPLIANCE_STATUS" == "NON_COMPLIANT" ]]; then echo '"Investigate failed workflow runs for root cause", "Classify failures as internal vs external", "Implement fixes for internal failures"'; else echo '"Maintain current reliability", "Continue monthly monitoring"'; fi)
  ]
}
JSON

echo "3. Report generated: $REPORT"
echo ""

# Summary
if [[ "$COMPLIANCE_STATUS" == "COMPLIANT" ]]; then
    echo "✓ Workflow reliability compliant ($SUCCESS_RATE% ≥ 99%)"
else
    echo "⚠ Action required: Workflow reliability below target"
    echo "  Current: $SUCCESS_RATE%"
    echo "  Target: 99.0%"
    echo "  Failed runs to investigate: $FAILED_RUNS"
fi
