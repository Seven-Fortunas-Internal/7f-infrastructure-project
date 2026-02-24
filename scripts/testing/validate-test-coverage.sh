#!/usr/bin/env bash
# validate-test-coverage.sh
# Validates that all "pass" features have verification tests

set -euo pipefail

# Configuration
FEATURE_LIST="${FEATURE_LIST:-feature_list.json}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Test Coverage Validation ===${NC}"
echo "Feature list: ${FEATURE_LIST}"
echo ""

# Check if feature_list.json exists
if [ ! -f "$FEATURE_LIST" ]; then
    echo -e "${RED}✗ feature_list.json not found${NC}"
    exit 1
fi

# Count features by status
TOTAL_FEATURES=$(jq '.features | length' "$FEATURE_LIST")
PASS_FEATURES=$(jq '[.features[] | select(.status == "pass")] | length' "$FEATURE_LIST")
PENDING_FEATURES=$(jq '[.features[] | select(.status == "pending")] | length' "$FEATURE_LIST")
FAIL_FEATURES=$(jq '[.features[] | select(.status == "fail")] | length' "$FEATURE_LIST")
BLOCKED_FEATURES=$(jq '[.features[] | select(.status == "blocked")] | length' "$FEATURE_LIST")

echo "Feature Status:"
echo "  Total: ${TOTAL_FEATURES}"
echo "  Pass: ${PASS_FEATURES}"
echo "  Pending: ${PENDING_FEATURES}"
echo "  Fail: ${FAIL_FEATURES}"
echo "  Blocked: ${BLOCKED_FEATURES}"
echo ""

# Validate "pass" features have tests
echo -e "${BLUE}=== Validating Pass Features ===${NC}"

VIOLATIONS=0
UNTESTED_FEATURES=()
INCOMPLETE_TESTS=()

# Check each "pass" feature
jq -r '.features[] | select(.status == "pass") | .id' "$FEATURE_LIST" | while read -r FEATURE_ID; do
    FEATURE=$(jq ".features[] | select(.id == \"$FEATURE_ID\")" "$FEATURE_LIST")
    
    # Check if verification_results exists
    if ! echo "$FEATURE" | jq -e '.verification_results' > /dev/null 2>&1; then
        echo -e "${RED}✗ $FEATURE_ID: Missing verification_results${NC}"
        UNTESTED_FEATURES+=("$FEATURE_ID")
        VIOLATIONS=$((VIOLATIONS + 1))
        continue
    fi
    
    # Get verification results
    FUNCTIONAL=$(echo "$FEATURE" | jq -r '.verification_results.functional // "missing"')
    TECHNICAL=$(echo "$FEATURE" | jq -r '.verification_results.technical // "missing"')
    INTEGRATION=$(echo "$FEATURE" | jq -r '.verification_results.integration // "missing"')
    
    # Check if all tests passed
    if [ "$FUNCTIONAL" != "pass" ] || [ "$TECHNICAL" != "pass" ] || [ "$INTEGRATION" != "pass" ]; then
        echo -e "${YELLOW}⚠️  $FEATURE_ID: Incomplete tests (F:$FUNCTIONAL, T:$TECHNICAL, I:$INTEGRATION)${NC}"
        INCOMPLETE_TESTS+=("$FEATURE_ID")
        VIOLATIONS=$((VIOLATIONS + 1))
    else
        if [ "${VERBOSE:-false}" = "true" ]; then
            echo -e "${GREEN}✓ $FEATURE_ID: All tests passed${NC}"
        fi
    fi
done

# Summary
echo ""
echo -e "${BLUE}=== Test Coverage Summary ===${NC}"

if [ $PASS_FEATURES -eq 0 ]; then
    echo "No pass features to validate"
    exit 0
fi

TESTED_FEATURES=$((PASS_FEATURES - VIOLATIONS))
COVERAGE=$((TESTED_FEATURES * 100 / PASS_FEATURES))

echo "Pass Features: ${PASS_FEATURES}"
echo "Tested Features: ${TESTED_FEATURES}"
echo "Untested Features: ${#UNTESTED_FEATURES[@]}"
echo "Incomplete Tests: ${#INCOMPLETE_TESTS[@]}"
echo "Test Coverage: ${COVERAGE}%"

echo ""
if [ $VIOLATIONS -eq 0 ]; then
    echo -e "${GREEN}✅ All pass features have complete tests (100% coverage)${NC}"
    exit 0
else
    echo -e "${RED}❌ ${VIOLATIONS} pass features have missing or incomplete tests${NC}"
    echo ""
    echo "Violations:"
    
    if [ ${#UNTESTED_FEATURES[@]} -gt 0 ]; then
        echo "  Untested (missing verification_results):"
        for feature in "${UNTESTED_FEATURES[@]}"; do
            echo "    - $feature"
        done
    fi
    
    if [ ${#INCOMPLETE_TESTS[@]} -gt 0 ]; then
        echo "  Incomplete tests (not all categories pass):"
        for feature in "${INCOMPLETE_TESTS[@]}"; do
            echo "    - $feature"
        done
    fi
    
    exit 1
fi
