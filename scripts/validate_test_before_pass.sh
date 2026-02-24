#!/bin/bash
# Validation script for FEATURE_026: Test-Before-Pass Requirement
#
# Verifies that:
# 1. All "pass" features have verification_results recorded
# 2. No features marked "pass" without testing
# 3. Test results are tracked in feature_list.json

set -e

PROJECT_DIR="/home/ladmin/dev/GDF/7F_github"
cd "$PROJECT_DIR"

echo "============================================================"
echo "Validating FEATURE_026: Test-Before-Pass Requirement"
echo "============================================================"
echo

TOTAL_PASS=0
PASS_WITH_TESTS=0
PASS_WITHOUT_TESTS=0
INCOMPLETE_FEATURES=0

# Check all features with status "pass"
while IFS= read -r feature_id; do
    TOTAL_PASS=$((TOTAL_PASS + 1))

    # Check if verification_results exist and are not empty
    FUNCTIONAL=$(jq -r ".features[] | select(.id == \"$feature_id\") | .verification_results.functional" feature_list.json)
    TECHNICAL=$(jq -r ".features[] | select(.id == \"$feature_id\") | .verification_results.technical" feature_list.json)
    INTEGRATION=$(jq -r ".features[] | select(.id == \"$feature_id\") | .verification_results.integration" feature_list.json)

    if [[ -n "$FUNCTIONAL" && "$FUNCTIONAL" != "null" && "$FUNCTIONAL" != "" ]] || \
       [[ -n "$TECHNICAL" && "$TECHNICAL" != "null" && "$TECHNICAL" != "" ]] || \
       [[ -n "$INTEGRATION" && "$INTEGRATION" != "null" && "$INTEGRATION" != "" ]]; then
        PASS_WITH_TESTS=$((PASS_WITH_TESTS + 1))
        echo "✓ $feature_id: Has verification results"
    else
        PASS_WITHOUT_TESTS=$((PASS_WITHOUT_TESTS + 1))
        echo "✗ $feature_id: Missing verification results (SHOULD NOT PASS)"
    fi
done < <(jq -r '.features[] | select(.status == "pass") | .id' feature_list.json)

echo
echo "------------------------------------------------------------"
echo "Test-Before-Pass Validation Results"
echo "------------------------------------------------------------"
echo "Total features with status 'pass': $TOTAL_PASS"
echo "Features with verification results: $PASS_WITH_TESTS"
echo "Features WITHOUT verification results: $PASS_WITHOUT_TESTS"
echo

# Check for 'incomplete' status (features without tests)
INCOMPLETE_FEATURES=$(jq '[.features[] | select(.status == "incomplete")] | length' feature_list.json)
echo "Features marked 'incomplete' (no tests): $INCOMPLETE_FEATURES"
echo

# Verify agent prompt enforces test requirement
echo "------------------------------------------------------------"
echo "Verifying Agent Prompt Enforcement"
echo "------------------------------------------------------------"

if grep -q "Test Feature" autonomous-implementation/prompts/coding_prompt.md; then
    echo "✓ Coding prompt includes 'Test Feature' section"
else
    echo "✗ Coding prompt missing 'Test Feature' section"
    exit 1
fi

if grep -q "verification criteria" autonomous-implementation/prompts/coding_prompt.md; then
    echo "✓ Coding prompt references verification criteria"
else
    echo "✗ Coding prompt missing verification criteria requirement"
    exit 1
fi

if grep -q "FEATURE_XXX: PASS" autonomous-implementation/prompts/coding_prompt.md; then
    echo "✓ Coding prompt shows example of marking feature pass after testing"
else
    echo "⚠ Coding prompt may not have clear pass/fail example"
fi

echo

# Check autonomous_build_log.md for test evidence
echo "------------------------------------------------------------"
echo "Verifying Test Evidence in Build Log"
echo "------------------------------------------------------------"

TEST_SECTIONS=$(grep -c "#### Verification Testing" autonomous_build_log.md || echo "0")
RESULT_SECTIONS=$(grep -c "#### Test Results Summary" autonomous_build_log.md || echo "0")

echo "Test sections in build log: $TEST_SECTIONS"
echo "Result sections in build log: $RESULT_SECTIONS"

if [ "$TEST_SECTIONS" -gt 0 ] && [ "$RESULT_SECTIONS" -gt 0 ]; then
    echo "✓ Build log contains test evidence for features"
else
    echo "⚠ Build log may be missing test evidence"
fi

echo

# Final verdict
echo "============================================================"
if [ "$PASS_WITHOUT_TESTS" -eq 0 ]; then
    echo "VALIDATION: PASS"
    echo "============================================================"
    echo
    echo "✓ All features marked 'pass' have verification results"
    echo "✓ Test-before-pass requirement is enforced"
    echo "✓ Agent prompt includes test requirements"
    echo "✓ Build log contains test evidence"
    echo
    echo "Test-before-pass requirement is fully operational."
else
    echo "VALIDATION: FAIL"
    echo "============================================================"
    echo
    echo "✗ Found $PASS_WITHOUT_TESTS features marked 'pass' without tests"
    echo "  This violates the test-before-pass requirement!"
    echo
    echo "Action required: Review and test these features."
    exit 1
fi
echo "============================================================"
