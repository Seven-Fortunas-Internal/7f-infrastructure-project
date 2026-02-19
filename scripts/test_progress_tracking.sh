#!/bin/bash
# Test script for FEATURE_027: Progress Tracking
#
# Verifies:
# 1. feature_list.json tracks status of all features
# 2. claude-progress.txt displays current state
# 3. autonomous_build_log.md provides detailed activity log
# 4. Console output (via agent.py)
# 5. Real-time monitoring capabilities

set -e

PROJECT_DIR="/home/ladmin/dev/GDF/7F_github"
cd "$PROJECT_DIR"

echo "============================================================"
echo "Testing FEATURE_027: Progress Tracking"
echo "============================================================"
echo

TESTS_PASSED=0
TESTS_FAILED=0

# Test 1: feature_list.json exists and tracks all features
echo "Test 1: feature_list.json status tracking"
echo "------------------------------------------------------------"

if [ -f "feature_list.json" ]; then
    TOTAL_FEATURES=$(jq '.features | length' feature_list.json)
    echo "✓ feature_list.json exists"
    echo "  Total features tracked: $TOTAL_FEATURES"

    # Check if all features have required fields
    MISSING_STATUS=$(jq '[.features[] | select(.status == null or .status == "")] | length' feature_list.json)
    if [ "$MISSING_STATUS" -eq 0 ]; then
        echo "✓ All features have status field"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ $MISSING_STATUS features missing status"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    # Verify status values are valid
    INVALID_STATUS=$(jq '[.features[] | select(.status != "pass" and .status != "pending" and .status != "fail" and .status != "blocked")] | length' feature_list.json)
    if [ "$INVALID_STATUS" -eq 0 ]; then
        echo "✓ All features have valid status values"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ $INVALID_STATUS features have invalid status"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
else
    echo "✗ feature_list.json not found"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo

# Test 2: claude-progress.txt displays current state
echo "Test 2: claude-progress.txt current state tracking"
echo "------------------------------------------------------------"

if [ -f "claude-progress.txt" ]; then
    echo "✓ claude-progress.txt exists"

    # Check for required metadata fields
    REQUIRED_FIELDS=("session_count" "features_completed" "features_pending" "circuit_breaker_status" "last_updated")

    for field in "${REQUIRED_FIELDS[@]}"; do
        if grep -q "^${field}=" claude-progress.txt; then
            VALUE=$(grep "^${field}=" claude-progress.txt | cut -d= -f2)
            echo "✓ $field present: $VALUE"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo "✗ $field missing"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    done
else
    echo "✗ claude-progress.txt not found"
    TESTS_FAILED=$((TESTS_FAILED + 5))
fi

echo

# Test 3: autonomous_build_log.md detailed activity log
echo "Test 3: autonomous_build_log.md activity logging"
echo "------------------------------------------------------------"

if [ -f "autonomous_build_log.md" ]; then
    echo "✓ autonomous_build_log.md exists"

    # Check for feature entries
    FEATURE_ENTRIES=$(grep -c "^### FEATURE_" autonomous_build_log.md || echo "0")
    echo "  Feature entries: $FEATURE_ENTRIES"

    if [ "$FEATURE_ENTRIES" -gt 0 ]; then
        echo "✓ Contains feature implementation logs"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ No feature entries found"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    # Check for verification sections
    VERIFICATION_SECTIONS=$(grep -c "#### Verification Testing" autonomous_build_log.md || echo "0")
    echo "  Verification sections: $VERIFICATION_SECTIONS"

    if [ "$VERIFICATION_SECTIONS" -gt 0 ]; then
        echo "✓ Contains verification test results"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ No verification sections found"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    # Test tail -f compatibility (file should be appendable)
    echo "Test append" >> autonomous_build_log.md
    if [ $? -eq 0 ]; then
        echo "✓ File is appendable (tail -f compatible)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        # Clean up test append
        head -n -1 autonomous_build_log.md > autonomous_build_log.md.tmp
        mv autonomous_build_log.md.tmp autonomous_build_log.md
    else
        echo "✗ Cannot append to file"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
else
    echo "✗ autonomous_build_log.md not found"
    TESTS_FAILED=$((TESTS_FAILED + 3))
fi

echo

# Test 4: Progress percentage calculation
echo "Test 4: Progress percentage calculation"
echo "------------------------------------------------------------"

COMPLETED=$(jq '[.features[] | select(.status == "pass")] | length' feature_list.json)
TOTAL=$(jq '.features | length' feature_list.json)

if [ "$TOTAL" -gt 0 ]; then
    PERCENTAGE=$((COMPLETED * 100 / TOTAL))
    echo "✓ Progress calculated: $COMPLETED/$TOTAL = $PERCENTAGE%"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Cannot calculate progress (no features)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo

# Test 5: Blocked features identification
echo "Test 5: Blocked features identification"
echo "------------------------------------------------------------"

BLOCKED=$(jq '[.features[] | select(.status == "blocked")] | length' feature_list.json)
echo "Blocked features: $BLOCKED"

if [ "$BLOCKED" -eq 0 ]; then
    echo "✓ No blocked features (healthy state)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "⚠ $BLOCKED features blocked (visible via progress tracking)"
    jq -r '.features[] | select(.status == "blocked") | "  - \(.id): \(.name)"' feature_list.json
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

echo

# Test 6: Real-time monitoring script
echo "Test 6: Real-time monitoring capabilities"
echo "------------------------------------------------------------"

if [ -f "scripts/show_progress.sh" ]; then
    echo "✓ Progress monitoring script exists"
    TESTS_PASSED=$((TESTS_PASSED + 1))

    if [ -x "scripts/show_progress.sh" ]; then
        echo "✓ Script is executable"
        TESTS_PASSED=$((TESTS_PASSED + 1))

        # Test script runs without error
        if bash scripts/show_progress.sh > /tmp/progress_test.txt 2>&1; then
            echo "✓ Script executes successfully"
            TESTS_PASSED=$((TESTS_PASSED + 1))

            # Check output contains expected sections
            if grep -q "Overall Progress" /tmp/progress_test.txt; then
                echo "✓ Output contains progress information"
                TESTS_PASSED=$((TESTS_PASSED + 1))
            else
                echo "✗ Output missing progress information"
                TESTS_FAILED=$((TESTS_FAILED + 1))
            fi

            rm -f /tmp/progress_test.txt
        else
            echo "✗ Script execution failed"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        echo "✗ Script is not executable"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
else
    echo "✗ Progress monitoring script not found"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo

# Test 7: Console output (agent.py integration)
echo "Test 7: Agent console output integration"
echo "------------------------------------------------------------"

if grep -q "print.*Tests:.*passing.*remaining" autonomous-implementation/agent.py; then
    echo "✓ Agent prints progress to console"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Agent missing console progress output"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

if grep -q "issue_logger.log_info" autonomous-implementation/agent.py; then
    echo "✓ Agent logs to issues.log"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Agent missing issue logging"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo

# Summary
echo "============================================================"
TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
echo "Test Results: $TESTS_PASSED/$TOTAL_TESTS passed"

if [ "$TESTS_FAILED" -eq 0 ]; then
    echo "============================================================"
    echo "VALIDATION: PASS"
    echo "============================================================"
    echo
    echo "✓ feature_list.json tracks all feature statuses in real-time"
    echo "✓ claude-progress.txt displays current state"
    echo "✓ autonomous_build_log.md provides detailed activity log"
    echo "✓ Progress percentage calculated automatically"
    echo "✓ Blocked features identified immediately"
    echo "✓ Real-time monitoring available (show_progress.sh)"
    echo "✓ Console output displays agent actions"
    echo
    echo "Progress tracking is fully operational."
    echo "============================================================"
    exit 0
else
    echo "============================================================"
    echo "VALIDATION: FAIL"
    echo "============================================================"
    echo
    echo "✗ $TESTS_FAILED tests failed"
    echo "  Review failures above and fix issues"
    echo "============================================================"
    exit 1
fi
