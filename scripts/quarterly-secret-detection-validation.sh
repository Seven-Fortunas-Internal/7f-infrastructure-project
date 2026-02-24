#!/bin/bash
# Quarterly Secret Detection Validation
# Re-runs test suite after pattern updates

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== Quarterly Secret Detection Validation ==="
echo "Date: $(date)"
echo ""

# Run baseline tests
echo "Running baseline test suite..."
"$PROJECT_ROOT/tests/secret-detection/run-baseline-tests.sh"
echo ""

# Check if adversarial tests exist
if [[ -x "$PROJECT_ROOT/tests/secret-detection/run-adversarial-tests.sh" ]]; then
    echo "Running adversarial test suite..."
    "$PROJECT_ROOT/tests/secret-detection/run-adversarial-tests.sh"
    echo ""
fi

# Generate summary report
LATEST_BASELINE=$(ls -t "$PROJECT_ROOT/tests/secret-detection/results/baseline-test-"*.json | head -1)

if [[ -f "$LATEST_BASELINE" ]]; then
    echo "=== Quarterly Validation Summary ==="
    jq '{
      timestamp,
      combined: .combined,
      status
    }' "$LATEST_BASELINE"
    echo ""

    # Check if targets met
    DETECTION_RATE=$(jq -r '.combined.detection_rate' "$LATEST_BASELINE" | sed 's/%//')
    if (( $(echo "$DETECTION_RATE >= 99.5" | bc -l) )); then
        echo "✓ Quarterly validation PASSED"
    else
        echo "✗ Quarterly validation FAILED"
        echo "  Action required: Review false negatives and update detection patterns"
    fi
fi
