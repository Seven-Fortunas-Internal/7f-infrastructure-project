#!/bin/bash
# Analyze dashboard auto-update performance from logs

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$PROJECT_ROOT/dashboards/performance/logs"

echo "=== Dashboard Auto-Update Performance Analysis ==="
echo ""

# Check if logs exist
if [[ ! -d "$LOG_DIR" ]] || [[ -z "$(ls -A "$LOG_DIR" 2>/dev/null)" ]]; then
    echo "No performance logs found in $LOG_DIR"
    echo "Run dashboard auto-update workflow first."
    exit 0
fi

echo "1. Analyzing workflow performance logs..."
LOG_COUNT=$(ls -1 "$LOG_DIR"/workflow-*.json 2>/dev/null | wc -l)
echo "  Total workflow runs: $LOG_COUNT"
echo ""

# Calculate statistics
if [[ $LOG_COUNT -gt 0 ]]; then
    echo "2. Performance statistics:"

    # Average duration
    AVG_DURATION=$(jq -s 'map(.duration_seconds) | add / length' "$LOG_DIR"/workflow-*.json)
    AVG_MINUTES=$(awk "BEGIN {printf \"%.2f\", $AVG_DURATION / 60}")
    echo "  Average duration: $AVG_MINUTES minutes ($AVG_DURATION seconds)"

    # Min duration
    MIN_DURATION=$(jq -s 'map(.duration_seconds) | min' "$LOG_DIR"/workflow-*.json)
    MIN_MINUTES=$(awk "BEGIN {printf \"%.2f\", $MIN_DURATION / 60}")
    echo "  Fastest run: $MIN_MINUTES minutes ($MIN_DURATION seconds)"

    # Max duration
    MAX_DURATION=$(jq -s 'map(.duration_seconds) | max' "$LOG_DIR"/workflow-*.json)
    MAX_MINUTES=$(awk "BEGIN {printf \"%.2f\", $MAX_DURATION / 60}")
    echo "  Slowest run: $MAX_MINUTES minutes ($MAX_DURATION seconds)"

    # Performance status (pass/fail count)
    PASS_COUNT=$(jq -s '[.[] | select(.performance_status == "pass")] | length' "$LOG_DIR"/workflow-*.json)
    FAIL_COUNT=$(jq -s '[.[] | select(.performance_status == "fail")] | length' "$LOG_DIR"/workflow-*.json)

    if [[ $LOG_COUNT -gt 0 ]]; then
        COMPLIANCE_RATE=$(awk "BEGIN {printf \"%.2f\", ($PASS_COUNT / $LOG_COUNT) * 100}")
    else
        COMPLIANCE_RATE="0.00"
    fi

    echo "  Runs within target (<10 min): $PASS_COUNT"
    echo "  Runs exceeding target (≥10 min): $FAIL_COUNT"
    echo "  Compliance rate: $COMPLIANCE_RATE%"
    echo ""

    # Target compliance check
    if (( $(echo "$COMPLIANCE_RATE >= 95.0" | bc -l) )); then
        echo "✓ Performance target compliance: $COMPLIANCE_RATE% ≥ 95%"
    else
        echo "⚠ Performance degradation: $COMPLIANCE_RATE% < 95%"
        echo "  Action: Investigate slow workflow runs"
    fi

    echo ""
    echo "3. Recent workflow runs (last 10):"
    jq -s 'sort_by(.timestamp) | reverse | .[:10] | .[] | {
      timestamp,
      duration_minutes,
      status: .performance_status
    }' "$LOG_DIR"/workflow-*.json
fi
