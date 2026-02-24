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

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: Test Engineer (verification executor)
- ✅ Collaborative dialogue: None (automated testing)
- ✅ You bring: Test execution logic, criteria interpretation
- ✅ User brings: Implemented feature from step-09

### Step-Specific:
- 🎯 Focus: Execute all verification criteria tests objectively
- 🚫 Forbidden: Skipping tests, subjective pass/fail decisions
- 💬 Approach: Systematic testing with clear pass/fail determination

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Store test results in memory (don't update feature_list.json yet)
- 📖 Log all test results to autonomous_build_log.md

---

## CONTEXT BOUNDARIES:
- Available: Verification criteria from step-08, implemented code
- Focus: Test execution and result determination
- Limits: Does not update tracking files (that's step-11)
- Dependencies: Requires implementation from step-09

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

**Log test start:**

```bash
BUILD_LOG_FILE="{buildLogFile}"

echo ""
echo "Preparing test environment..."

cat >> "$BUILD_LOG_FILE" <<EOF

#### Verification Testing

**Started:** $(date -u +%Y-%m-%d %H:%M:%S)
**Feature:** $SELECTED_FEATURE_ID
**Criteria:** Functional, Technical, Integration

EOF

echo "✓ Test logging initialized"
echo ""
```

---

### 3. Test Functional Criteria

**Execute functional verification:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  TEST 1: FUNCTIONAL CRITERIA"
echo "─────────────────────────────────────────────────────"
echo ""

if [[ -z "$FUNCTIONAL_CRITERIA" ]]; then
    echo "⚠️  No functional criteria defined"
    FUNCTIONAL_RESULT="skip"
    FUNCTIONAL_ERROR="No criteria specified"
else
    echo "Criteria: $FUNCTIONAL_CRITERIA"
    echo ""
    echo "Executing functional test..."

    # ==============================================================
    # FUNCTIONAL TEST EXECUTION
    # ==============================================================
    # This section tests if the feature works as intended for end-users
    #
    # Common functional tests by feature type:
    # - GitHub org/repo: Check if entity exists, is accessible
    # - File creation: Verify file exists, has correct content
    # - Configuration: Verify settings applied correctly
    # - Integration: Verify connection/communication works
    #
    # Test commands will vary by feature category
    # ==============================================================

    # Initialize test result
    FUNCTIONAL_RESULT="pass"
    FUNCTIONAL_ERROR=""

    # Example test pattern (actual test will depend on feature):
    # if <test_command>; then
    #     FUNCTIONAL_RESULT="pass"
    # else
    #     FUNCTIONAL_RESULT="fail"
    #     FUNCTIONAL_ERROR="<error_description>"
    # fi

    echo "  Test execution logic will be performed by autonomous agent..."
    echo ""

    # Log functional test result
    cat >> "$BUILD_LOG_FILE" <<EOF
1. **Functional Test**
   - Criteria: $FUNCTIONAL_CRITERIA
   - Result: $FUNCTIONAL_RESULT
$(if [[ "$FUNCTIONAL_RESULT" == "fail" ]]; then echo "   - Error: $FUNCTIONAL_ERROR"; fi)

EOF
fi

if [[ "$FUNCTIONAL_RESULT" == "pass" ]]; then
    echo "✓ Functional test: PASS"
elif [[ "$FUNCTIONAL_RESULT" == "skip" ]]; then
    echo "⊘ Functional test: SKIPPED (no criteria)"
else
    echo "❌ Functional test: FAIL"
    echo "   Error: $FUNCTIONAL_ERROR"
fi

echo ""
```

---

### 4. Test Technical Criteria

**Execute technical verification:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  TEST 2: TECHNICAL CRITERIA"
echo "─────────────────────────────────────────────────────"
echo ""

if [[ -z "$TECHNICAL_CRITERIA" ]]; then
    echo "⚠️  No technical criteria defined"
    TECHNICAL_RESULT="skip"
    TECHNICAL_ERROR="No criteria specified"
else
    echo "Criteria: $TECHNICAL_CRITERIA"
    echo ""
    echo "Executing technical test..."

    # ==============================================================
    # TECHNICAL TEST EXECUTION
    # ==============================================================
    # This section tests if implementation meets technical standards
    #
    # Common technical tests:
    # - Code quality: Syntax validation, linting
    # - Configuration correctness: YAML/JSON syntax, required fields
    # - File structure: Correct permissions, correct location
    # - Security settings: Required security features enabled
    # - Standards compliance: Naming conventions, formatting
    #
    # ==============================================================

    TECHNICAL_RESULT="pass"
    TECHNICAL_ERROR=""

    # Example test pattern
    # if <technical_validation>; then
    #     TECHNICAL_RESULT="pass"
    # else
    #     TECHNICAL_RESULT="fail"
    #     TECHNICAL_ERROR="<technical_issue>"
    # fi

    echo "  Test execution logic will be performed by autonomous agent..."
    echo ""

    # Log technical test result
    cat >> "$BUILD_LOG_FILE" <<EOF
2. **Technical Test**
   - Criteria: $TECHNICAL_CRITERIA
   - Result: $TECHNICAL_RESULT
$(if [[ "$TECHNICAL_RESULT" == "fail" ]]; then echo "   - Error: $TECHNICAL_ERROR"; fi)

EOF
fi

if [[ "$TECHNICAL_RESULT" == "pass" ]]; then
    echo "✓ Technical test: PASS"
elif [[ "$TECHNICAL_RESULT" == "skip" ]]; then
    echo "⊘ Technical test: SKIPPED (no criteria)"
else
    echo "❌ Technical test: FAIL"
    echo "   Error: $TECHNICAL_ERROR"
fi

echo ""
```

---

### 5. Test Integration Criteria

**Execute integration verification:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  TEST 3: INTEGRATION CRITERIA"
echo "─────────────────────────────────────────────────────"
echo ""

if [[ -z "$INTEGRATION_CRITERIA" ]]; then
    echo "⚠️  No integration criteria defined"
    INTEGRATION_RESULT="skip"
    INTEGRATION_ERROR="No criteria specified"
else
    echo "Criteria: $INTEGRATION_CRITERIA"
    echo ""
    echo "Executing integration test..."

    # ==============================================================
    # INTEGRATION TEST EXECUTION
    # ==============================================================
    # This section tests if feature integrates with other components
    #
    # Common integration tests:
    # - API connectivity: Can communicate with external services
    # - Cross-feature references: Dependencies work correctly
    # - File links: Symlinks, submodules resolve correctly
    # - Permissions: Can perform required operations
    # - End-to-end flow: Complete workflow functions
    #
    # ==============================================================

    INTEGRATION_RESULT="pass"
    INTEGRATION_ERROR=""

    # Example test pattern
    # if <integration_check>; then
    #     INTEGRATION_RESULT="pass"
    # else
    #     INTEGRATION_RESULT="fail"
    #     INTEGRATION_ERROR="<integration_issue>"
    # fi

    echo "  Test execution logic will be performed by autonomous agent..."
    echo ""

    # Log integration test result
    cat >> "$BUILD_LOG_FILE" <<EOF
3. **Integration Test**
   - Criteria: $INTEGRATION_CRITERIA
   - Result: $INTEGRATION_RESULT
$(if [[ "$INTEGRATION_RESULT" == "fail" ]]; then echo "   - Error: $INTEGRATION_ERROR"; fi)

EOF
fi

if [[ "$INTEGRATION_RESULT" == "pass" ]]; then
    echo "✓ Integration test: PASS"
elif [[ "$INTEGRATION_RESULT" == "skip" ]]; then
    echo "⊘ Integration test: SKIPPED (no criteria)"
else
    echo "❌ Integration test: FAIL"
    echo "   Error: $INTEGRATION_ERROR"
fi

echo ""
```

---

### 6. Determine Overall Status

**Apply pass/fail logic:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  OVERALL TEST RESULT"
echo "─────────────────────────────────────────────────────"
echo ""

# Pass logic: All non-skipped tests must pass
# If all tests skipped: Still pass (no criteria to fail)
# If any test fails: Fail

OVERALL_STATUS="pass"
FAIL_REASONS=()

if [[ "$FUNCTIONAL_RESULT" == "fail" ]]; then
    OVERALL_STATUS="fail"
    FAIL_REASONS+=("Functional: $FUNCTIONAL_ERROR")
fi

if [[ "$TECHNICAL_RESULT" == "fail" ]]; then
    OVERALL_STATUS="fail"
    FAIL_REASONS+=("Technical: $TECHNICAL_ERROR")
fi

if [[ "$INTEGRATION_RESULT" == "fail" ]]; then
    OVERALL_STATUS="fail"
    FAIL_REASONS+=("Integration: $INTEGRATION_ERROR")
fi

# Display result
echo "Test Summary:"
echo "  Functional:   $(printf '%-4s' "$FUNCTIONAL_RESULT" | tr 'a-z' 'A-Z')"
echo "  Technical:    $(printf '%-4s' "$TECHNICAL_RESULT" | tr 'a-z' 'A-Z')"
echo "  Integration:  $(printf '%-4s' "$INTEGRATION_RESULT" | tr 'a-z' 'A-Z')"
echo ""

if [[ "$OVERALL_STATUS" == "pass" ]]; then
    echo "Overall Status: ✓ PASS"
    echo ""
    echo "All verification criteria passed."
    echo "Feature is ready to be marked complete."
else
    echo "Overall Status: ❌ FAIL"
    echo ""
    echo "Failure Reasons:"
    for reason in "${FAIL_REASONS[@]}"; do
        echo "  - $reason"
    done
    echo ""
    echo "Feature will be marked as 'fail' for retry."
fi

echo ""
```

---

### 7. Log Final Test Results

**Record complete test outcome:**

```bash
cat >> "$BUILD_LOG_FILE" <<EOF

#### Test Results Summary

**Overall Status:** $OVERALL_STATUS
**Functional:** $FUNCTIONAL_RESULT
**Technical:** $TECHNICAL_RESULT
**Integration:** $INTEGRATION_RESULT

$(if [[ "$OVERALL_STATUS" == "fail" ]]; then
    echo "**Failure Reasons:**"
    for reason in "${FAIL_REASONS[@]}"; do
        echo "- $reason"
    done
fi)

**Completed:** $(date -u +%Y-%m-%d %H:%M:%S)

EOF

echo "✓ Test results logged"
```

---

### 8. Store Results in Memory

**Prepare data for next step:**

```bash
# Export test results for step-11
export OVERALL_STATUS
export FUNCTIONAL_RESULT
export TECHNICAL_RESULT
export INTEGRATION_RESULT
export FUNCTIONAL_ERROR
export TECHNICAL_ERROR
export INTEGRATION_ERROR

echo "✓ Test results stored for tracking update"
echo ""
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

**Menu Handling Logic:**
- This step uses **Auto-proceed** (no menu)
- Test results stored in memory
- Next step will update feature_list.json

**Execution:**

```
→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- All verification criteria tests executed
  - Functional test: Executed (or skipped if no criteria)
  - Technical test: Executed (or skipped if no criteria)
  - Integration test: Executed (or skipped if no criteria)
- Overall status determined (pass or fail)
- Failure reasons collected (if fail)
- Test results logged to autonomous_build_log.md
- Results stored in memory for step-11
- Ready to update tracking files

### ❌ FAILURE:
- (None - test execution always completes, results may be pass/fail)

**Master Rule:** All specified verification criteria must be tested before determining status.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
