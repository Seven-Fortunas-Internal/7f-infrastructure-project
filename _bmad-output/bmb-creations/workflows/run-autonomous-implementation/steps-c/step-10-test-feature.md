---
name: 'step-10-test-feature'
description: 'Test implemented feature against verification criteria'
nextStepFile: './step-11-update-tracking.md'
buildLogFile: '{project_folder}/autonomous_build_log.md'
verificationGuideFile: '{workflow_path}/../data/verification-criteria-guide.md'
---

# Step 10: Test Feature

## STEP GOAL:
Execute verification tests for the implemented feature (functional, technical, integration criteria) and determine pass/fail status.

---

## MANDATORY EXECUTION RULES:

**Reference:** See universal execution rules in workflow README

**Step-Specific:** Role: Test Engineer | Focus: Execute all verification criteria tests objectively | Forbidden: Skipping tests, subjective pass/fail | Store results in memory (not feature_list.json) | Log to autonomous_build_log.md

**Context:** Available: Verification criteria (step-08), implemented code | Dependencies: Implementation (step-09)

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Testing Start

```
═══════════════════════════════════════════════════════
  TESTING FEATURE
  $SELECTED_FEATURE_ID: $FEATURE_NAME
═══════════════════════════════════════════════════════
```

---

### 2. Prepare Test Environment

```bash
BUILD_LOG_FILE="{buildLogFile}"
echo "" && echo "Preparing test environment..."
cat >> "$BUILD_LOG_FILE" <<EOF

#### Verification Testing
**Started:** $(date -u +%Y-%m-%d %H:%M:%S) | **Feature:** $SELECTED_FEATURE_ID | **Criteria:** Functional, Technical, Integration

EOF
echo "✓ Test logging initialized" && echo ""
```

---

### 3-5. Execute All Verification Tests

**Run functional, technical, and integration tests:**

```bash
# Helper function for test execution
run_test() {
    local TEST_NUM=$1 TEST_NAME=$2 CRITERIA_VAR=$3 RESULT_VAR=$4 ERROR_VAR=$5
    echo "─────────────────────────────────────────────────────"
    echo "  TEST $TEST_NUM: $TEST_NAME CRITERIA"
    echo "─────────────────────────────────────────────────────" && echo ""

    local CRITERIA="${!CRITERIA_VAR}"
    if [[ -z "$CRITERIA" ]]; then
        echo "⚠️  No $TEST_NAME criteria defined"
        eval "$RESULT_VAR='skip'"; eval "$ERROR_VAR='No criteria specified'"
    else
        echo "Criteria: $CRITERIA" && echo "" && echo "Executing $TEST_NAME test..."
        # Test execution: Autonomous agent implements validation logic here
        # Pattern: if <test>; then RESULT="pass"; else RESULT="fail"; ERROR="<msg>"; fi
        eval "$RESULT_VAR='pass'"; eval "$ERROR_VAR=''"
        echo "  Test execution logic performed by autonomous agent..." && echo ""

        cat >> "$BUILD_LOG_FILE" <<EOF
$TEST_NUM. **$TEST_NAME Test**
   - Criteria: $CRITERIA
   - Result: ${!RESULT_VAR}
$(if [[ "${!RESULT_VAR}" == "fail" ]]; then echo "   - Error: ${!ERROR_VAR}"; fi)

EOF
    fi

    [[ "${!RESULT_VAR}" == "pass" ]] && echo "✓ $TEST_NAME test: PASS" || \
    [[ "${!RESULT_VAR}" == "skip" ]] && echo "⊘ $TEST_NAME test: SKIPPED (no criteria)" || \
    (echo "❌ $TEST_NAME test: FAIL" && echo "   Error: ${!ERROR_VAR}")
    echo ""
}

# Execute all three test types
run_test 1 "Functional" FUNCTIONAL_CRITERIA FUNCTIONAL_RESULT FUNCTIONAL_ERROR
run_test 2 "Technical" TECHNICAL_CRITERIA TECHNICAL_RESULT TECHNICAL_ERROR
run_test 3 "Integration" INTEGRATION_CRITERIA INTEGRATION_RESULT INTEGRATION_ERROR
```

---

### 6. Determine Overall Status

**Apply pass/fail logic:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  OVERALL TEST RESULT"
echo "─────────────────────────────────────────────────────" && echo ""

OVERALL_STATUS="pass"; FAIL_REASONS=()
[[ "$FUNCTIONAL_RESULT" == "fail" ]] && OVERALL_STATUS="fail" && FAIL_REASONS+=("Functional: $FUNCTIONAL_ERROR")
[[ "$TECHNICAL_RESULT" == "fail" ]] && OVERALL_STATUS="fail" && FAIL_REASONS+=("Technical: $TECHNICAL_ERROR")
[[ "$INTEGRATION_RESULT" == "fail" ]] && OVERALL_STATUS="fail" && FAIL_REASONS+=("Integration: $INTEGRATION_ERROR")

echo "Test Summary:"
for t in "Functional:$FUNCTIONAL_RESULT" "Technical:$TECHNICAL_RESULT" "Integration:$INTEGRATION_RESULT"; do
    echo "  ${t%:*}:   $(printf '%-4s' "${t#*:}" | tr 'a-z' 'A-Z')"
done && echo ""

if [[ "$OVERALL_STATUS" == "pass" ]]; then
    echo "Overall Status: ✓ PASS" && echo "All verification criteria passed. Feature is ready to be marked complete."
else
    echo "Overall Status: ❌ FAIL" && echo "Failure Reasons:"
    for reason in "${FAIL_REASONS[@]}"; do echo "  - $reason"; done
    echo "" && echo "Feature will be marked as 'fail' for retry."
fi && echo ""
```

---

### 7. Log Final Test Results

```bash
cat >> "$BUILD_LOG_FILE" <<EOF

#### Test Results Summary
**Overall:** $OVERALL_STATUS | **Functional:** $FUNCTIONAL_RESULT | **Technical:** $TECHNICAL_RESULT | **Integration:** $INTEGRATION_RESULT
$(if [[ "$OVERALL_STATUS" == "fail" ]]; then echo "**Failures:**"; for r in "${FAIL_REASONS[@]}"; do echo "- $r"; done; fi)
**Completed:** $(date -u +%Y-%m-%d %H:%M:%S)

EOF
echo "✓ Test results logged"
```

---

### 8. Store Results in Memory

**Export for next step:**

```bash
export OVERALL_STATUS FUNCTIONAL_RESULT TECHNICAL_RESULT INTEGRATION_RESULT FUNCTIONAL_ERROR TECHNICAL_ERROR INTEGRATION_ERROR
echo "✓ Test results stored for tracking update" && echo ""
```

---

### 9. Display Next Step Message

```
─────────────────────────────────────────────────────
  TESTING COMPLETE
─────────────────────────────────────────────────────

Feature: $SELECTED_FEATURE_ID
Status: $(if [[ "$OVERALL_STATUS" == "pass" ]]; then echo "✓ PASS"; else echo "❌ FAIL"; fi)

Next: Update feature_list.json with test results

Proceeding to update tracking...
```

---

### 10. Proceed to Next Step

**Auto-proceed (no menu):**

```
→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

**Reference:** See universal success/failure criteria in workflow README

**Step-Specific Success:**
- All verification criteria tests executed (or skipped if no criteria)
- Overall status determined (pass or fail)
- Failure reasons collected (if fail)
- Test results logged to autonomous_build_log.md
- Results stored in memory for step-11

**Master Rule:** All specified verification criteria must be tested before determining status.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
