#!/bin/bash
# Baseline Secret Detection Test Runner
# Validates ≥99.5% detection rate using multiple detection tools

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_SUITE="$SCRIPT_DIR/baseline/test-patterns.txt"
RESULTS_DIR="$SCRIPT_DIR/results"

mkdir -p "$RESULTS_DIR"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT="$RESULTS_DIR/baseline-test-$TIMESTAMP.json"

echo "=== Secret Detection Baseline Test ==="
echo "Test Suite: $TEST_SUITE"
echo "Report: $REPORT"
echo ""

# Count total test cases (non-comment, non-empty lines)
TOTAL_CASES=$(grep -v '^#' "$TEST_SUITE" | grep -v '^$' | wc -l)
echo "Total test cases: $TOTAL_CASES"
echo ""

# Test with gitleaks
echo "1. Testing with gitleaks..."
GITLEAKS_DETECTED=0
if command -v gitleaks &>/dev/null; then
    # Create temp file for testing
    TEMP_FILE=$(mktemp)
    cp "$TEST_SUITE" "$TEMP_FILE"

    # Run gitleaks
    if gitleaks detect --no-git --source "$TEMP_FILE" --report-path "$RESULTS_DIR/gitleaks-$TIMESTAMP.json" &>/dev/null; then
        echo "  No secrets detected (unexpected)"
    else
        # Count detections
        if [[ -f "$RESULTS_DIR/gitleaks-$TIMESTAMP.json" ]]; then
            GITLEAKS_DETECTED=$(jq 'length' "$RESULTS_DIR/gitleaks-$TIMESTAMP.json" 2>/dev/null || echo "0")
        fi
        echo "  Detected: $GITLEAKS_DETECTED secrets"
    fi
    rm -f "$TEMP_FILE"
else
    echo "  ⚠ gitleaks not installed"
fi
echo ""

# Test with TruffleHog
echo "2. Testing with TruffleHog..."
TRUFFLEHOG_DETECTED=0
if command -v trufflehog &>/dev/null; then
    TEMP_FILE=$(mktemp)
    cp "$TEST_SUITE" "$TEMP_FILE"

    # Run TruffleHog
    TRUFFLEHOG_OUTPUT=$(trufflehog filesystem "$TEMP_FILE" --json 2>/dev/null | jq -s 'length' || echo "0")
    TRUFFLEHOG_DETECTED=$TRUFFLEHOG_OUTPUT
    echo "  Detected: $TRUFFLEHOG_DETECTED secrets"
    rm -f "$TEMP_FILE"
else
    echo "  ⚠ trufflehog not installed"
fi
echo ""

# Test with detect-secrets
echo "3. Testing with detect-secrets..."
DETECT_SECRETS_DETECTED=0
if command -v detect-secrets &>/dev/null; then
    TEMP_FILE=$(mktemp)
    cp "$TEST_SUITE" "$TEMP_FILE"

    # Run detect-secrets
    DETECT_SECRETS_OUTPUT=$(detect-secrets scan "$TEMP_FILE" 2>/dev/null | jq '.results | to_entries | length' || echo "0")
    DETECT_SECRETS_DETECTED=$DETECT_SECRETS_OUTPUT
    echo "  Detected: $DETECT_SECRETS_DETECTED secrets"
    rm -f "$TEMP_FILE"
else
    echo "  ⚠ detect-secrets not installed"
fi
echo ""

# Calculate detection rates
echo "=== Detection Rate Analysis ==="
echo ""

# Gitleaks
if [[ $GITLEAKS_DETECTED -gt 0 ]]; then
    GITLEAKS_RATE=$(awk "BEGIN {printf \"%.2f\", ($GITLEAKS_DETECTED / $TOTAL_CASES) * 100}")
    echo "Gitleaks:"
    echo "  Detected: $GITLEAKS_DETECTED / $TOTAL_CASES"
    echo "  Rate: $GITLEAKS_RATE%"
    echo ""
fi

# TruffleHog
if [[ $TRUFFLEHOG_DETECTED -gt 0 ]]; then
    TRUFFLEHOG_RATE=$(awk "BEGIN {printf \"%.2f\", ($TRUFFLEHOG_DETECTED / $TOTAL_CASES) * 100}")
    echo "TruffleHog:"
    echo "  Detected: $TRUFFLEHOG_DETECTED / $TOTAL_CASES"
    echo "  Rate: $TRUFFLEHOG_RATE%"
    echo ""
fi

# detect-secrets
if [[ $DETECT_SECRETS_DETECTED -gt 0 ]]; then
    DETECT_SECRETS_RATE=$(awk "BEGIN {printf \"%.2f\", ($DETECT_SECRETS_DETECTED / $TOTAL_CASES) * 100}")
    echo "detect-secrets:"
    echo "  Detected: $DETECT_SECRETS_DETECTED / $TOTAL_CASES"
    echo "  Rate: $DETECT_SECRETS_RATE%"
    echo ""
fi

# Combined (best of all tools)
COMBINED_DETECTED=$GITLEAKS_DETECTED
[[ $TRUFFLEHOG_DETECTED -gt $COMBINED_DETECTED ]] && COMBINED_DETECTED=$TRUFFLEHOG_DETECTED
[[ $DETECT_SECRETS_DETECTED -gt $COMBINED_DETECTED ]] && COMBINED_DETECTED=$DETECT_SECRETS_DETECTED

COMBINED_RATE=$(awk "BEGIN {printf \"%.2f\", ($COMBINED_DETECTED / $TOTAL_CASES) * 100}")
FALSE_NEGATIVE_RATE=$(awk "BEGIN {printf \"%.2f\", (($TOTAL_CASES - $COMBINED_DETECTED) / $TOTAL_CASES) * 100}")

echo "Combined (Best of All Tools):"
echo "  Detected: $COMBINED_DETECTED / $TOTAL_CASES"
echo "  Detection Rate: $COMBINED_RATE%"
echo "  False Negative Rate: $FALSE_NEGATIVE_RATE%"
echo ""

# Check if target met
if (( $(echo "$COMBINED_RATE >= 99.5" | bc -l) )); then
    STATUS="PASS ✓"
    echo "✓ Target met: ≥99.5% detection rate"
else
    STATUS="FAIL ✗"
    echo "✗ Target NOT met: $COMBINED_RATE% < 99.5%"
fi

if (( $(echo "$FALSE_NEGATIVE_RATE <= 0.5" | bc -l) )); then
    echo "✓ Target met: ≤0.5% false negative rate"
else
    echo "✗ Target NOT met: $FALSE_NEGATIVE_RATE% > 0.5%"
    STATUS="FAIL ✗"
fi

echo ""

# Generate JSON report
cat > "$REPORT" << JSON
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "test_suite": "baseline",
  "total_cases": $TOTAL_CASES,
  "tools": {
    "gitleaks": {
      "detected": $GITLEAKS_DETECTED,
      "rate": ${GITLEAKS_RATE:-0}
    },
    "trufflehog": {
      "detected": $TRUFFLEHOG_DETECTED,
      "rate": ${TRUFFLEHOG_RATE:-0}
    },
    "detect_secrets": {
      "detected": $DETECT_SECRETS_DETECTED,
      "rate": ${DETECT_SECRETS_RATE:-0}
    }
  },
  "combined": {
    "detected": $COMBINED_DETECTED,
    "detection_rate": $COMBINED_RATE,
    "false_negative_rate": $FALSE_NEGATIVE_RATE
  },
  "targets": {
    "detection_rate": "≥99.5%",
    "false_negative_rate": "≤0.5%"
  },
  "status": "$STATUS"
}
JSON

echo "Report saved: $REPORT"
echo ""
