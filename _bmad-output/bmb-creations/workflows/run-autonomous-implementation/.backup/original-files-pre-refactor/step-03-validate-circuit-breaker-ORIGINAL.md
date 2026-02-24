---
name: 'step-03-validate-circuit-breaker'
description: 'Validate circuit breaker logic and state consistency'
nextStepFile: './step-04-generate-report.md'
progressFile: '{project_folder}/claude-progress.txt'
featureListFile: '{project_folder}/feature_list.json'
---

# Step 03: Validate Circuit Breaker (VALIDATE Mode)

## STEP GOAL:
Validate circuit breaker logic consistency, threshold correctness, and status accuracy.

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: Logic Validator (circuit breaker consistency checker)
- ✅ Collaborative dialogue: None (automated validation)
- ✅ You bring: Logic validation, consistency checking
- ✅ User brings: Circuit breaker state to validate

### Step-Specific:
- 🎯 Focus: Circuit breaker state and logic consistency
- 🚫 Forbidden: Making corrections (report only)
- 💬 Approach: Systematic logic checks with clear results

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Read-only validation (no modifications)
- 📖 Collect circuit breaker issues for final report

---

## CONTEXT BOUNDARIES:
- Available: claude-progress.txt, feature_list.json (read-only)
- Focus: Circuit breaker logic and consistency validation
- Limits: Does not generate final report (that's step-04)
- Dependencies: Requires state and implementation validation from steps 01-02

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Circuit Breaker Validation Banner

```
═══════════════════════════════════════════════════════
  VALIDATE CIRCUIT BREAKER
  Verifying Logic and State Consistency
═══════════════════════════════════════════════════════
```

---

### 2. Initialize Validation Results

**Prepare result tracking:**

```bash
echo ""
echo "Initializing circuit breaker validation..."

# Validation result arrays
CB_VALIDATION_PASSED=()
CB_VALIDATION_FAILED=()
CB_VALIDATION_WARNINGS=()

CB_TOTAL_CHECKS=0
CB_PASSED_CHECKS=0
CB_FAILED_CHECKS=0
CB_WARNING_COUNT=0

echo "✓ Circuit breaker validation initialized"
echo ""
```

---

### 3. Load Circuit Breaker State

**Read current circuit breaker metadata:**

```bash
PROGRESS_FILE="{progressFile}"

echo "Loading circuit breaker state..."

# Load current values
SESSION_COUNT=$(grep '^session_count=' "$PROGRESS_FILE" | cut -d= -f2)
CONSECUTIVE_FAILURES=$(grep '^consecutive_failures=' "$PROGRESS_FILE" | cut -d= -f2)
THRESHOLD=$(grep '^circuit_breaker_threshold=' "$PROGRESS_FILE" | cut -d= -f2)
CB_STATUS=$(grep '^circuit_breaker_status=' "$PROGRESS_FILE" | cut -d= -f2)
LAST_SESSION_SUCCESS=$(grep '^last_session_success=' "$PROGRESS_FILE" | cut -d= -f2)

# Defaults
SESSION_COUNT=${SESSION_COUNT:-0}
CONSECUTIVE_FAILURES=${CONSECUTIVE_FAILURES:-0}
THRESHOLD=${THRESHOLD:-5}
CB_STATUS=${CB_STATUS:-UNKNOWN}
LAST_SESSION_SUCCESS=${LAST_SESSION_SUCCESS:-unknown}

echo "✓ Circuit breaker state loaded"
echo "  Session Count: $SESSION_COUNT"
echo "  Consecutive Failures: $CONSECUTIVE_FAILURES"
echo "  Threshold: $THRESHOLD"
echo "  Status: $CB_STATUS"
echo ""
```

---

### 4. Validate Threshold Range

**Check threshold is within valid range:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 1: THRESHOLD RANGE"
echo "─────────────────────────────────────────────────────"
echo ""

CB_TOTAL_CHECKS=$((CB_TOTAL_CHECKS + 1))

if [[ $THRESHOLD -ge 1 && $THRESHOLD -le 99 ]]; then
    echo "✓ Threshold ($THRESHOLD) is within valid range (1-99)"
    CB_VALIDATION_PASSED+=("Threshold: Valid range ($THRESHOLD)")
    CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
else
    echo "❌ Threshold ($THRESHOLD) is OUT OF RANGE"
    echo "   Valid range: 1-99"
    CB_VALIDATION_FAILED+=("Threshold: Out of range ($THRESHOLD)")
    CB_FAILED_CHECKS=$((CB_FAILED_CHECKS + 1))
fi

# Check if threshold is reasonable (recommended 3-10)
CB_TOTAL_CHECKS=$((CB_TOTAL_CHECKS + 1))

if [[ $THRESHOLD -ge 3 && $THRESHOLD -le 10 ]]; then
    echo "✓ Threshold ($THRESHOLD) is in recommended range (3-10)"
    CB_VALIDATION_PASSED+=("Threshold: Recommended range ($THRESHOLD)")
    CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
else
    echo "⚠️  Threshold ($THRESHOLD) outside recommended range (3-10)"
    if [[ $THRESHOLD -lt 3 ]]; then
        echo "   Very low threshold may cause premature circuit breaker triggers"
    else
        echo "   High threshold may allow too many failures before intervention"
    fi
    CB_VALIDATION_WARNINGS+=("Threshold: Outside recommended range ($THRESHOLD)")
    CB_WARNING_COUNT=$((CB_WARNING_COUNT + 1))
fi

echo ""
```

---

### 5. Validate Consecutive Failures Range

**Check consecutive_failures is non-negative and reasonable:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 2: CONSECUTIVE FAILURES RANGE"
echo "─────────────────────────────────────────────────────"
echo ""

CB_TOTAL_CHECKS=$((CB_TOTAL_CHECKS + 1))

if [[ $CONSECUTIVE_FAILURES -ge 0 && $CONSECUTIVE_FAILURES -le 99 ]]; then
    echo "✓ Consecutive failures ($CONSECUTIVE_FAILURES) is within valid range (0-99)"
    CB_VALIDATION_PASSED+=("Consecutive failures: Valid range ($CONSECUTIVE_FAILURES)")
    CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
else
    echo "❌ Consecutive failures ($CONSECUTIVE_FAILURES) is OUT OF RANGE"
    echo "   Valid range: 0-99"
    CB_VALIDATION_FAILED+=("Consecutive failures: Out of range ($CONSECUTIVE_FAILURES)")
    CB_FAILED_CHECKS=$((CB_FAILED_CHECKS + 1))
fi

echo ""
```

---

### 6. Validate Status Consistency

**Check circuit_breaker_status matches consecutive_failures vs threshold:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 3: STATUS CONSISTENCY"
echo "─────────────────────────────────────────────────────"
echo ""

CB_TOTAL_CHECKS=$((CB_TOTAL_CHECKS + 1))

# Determine expected status based on consecutive_failures and threshold
if [[ $CONSECUTIVE_FAILURES -ge $THRESHOLD ]]; then
    EXPECTED_STATUS="TRIGGERED"
elif [[ $CB_STATUS == "COMPLETE" ]]; then
    EXPECTED_STATUS="COMPLETE"
else
    EXPECTED_STATUS="HEALTHY"
fi

if [[ "$CB_STATUS" == "$EXPECTED_STATUS" ]]; then
    echo "✓ Status ($CB_STATUS) is consistent with consecutive_failures ($CONSECUTIVE_FAILURES) and threshold ($THRESHOLD)"
    CB_VALIDATION_PASSED+=("Status: Consistent ($CB_STATUS)")
    CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
else
    echo "❌ Status ($CB_STATUS) is INCONSISTENT"
    echo "   Expected: $EXPECTED_STATUS"
    echo "   Reason: consecutive_failures=$CONSECUTIVE_FAILURES, threshold=$THRESHOLD"
    CB_VALIDATION_FAILED+=("Status: Inconsistent ($CB_STATUS, expected $EXPECTED_STATUS)")
    CB_FAILED_CHECKS=$((CB_FAILED_CHECKS + 1))
fi

echo ""
```

---

### 7. Validate Status Value

**Check circuit_breaker_status is a valid enum:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 4: STATUS VALUE"
echo "─────────────────────────────────────────────────────"
echo ""

VALID_STATUSES=("HEALTHY" "TRIGGERED" "COMPLETE" "UNKNOWN")

CB_TOTAL_CHECKS=$((CB_TOTAL_CHECKS + 1))

if [[ " ${VALID_STATUSES[@]} " =~ " ${CB_STATUS} " ]]; then
    echo "✓ Status ($CB_STATUS) is a valid value"
    CB_VALIDATION_PASSED+=("Status: Valid enum ($CB_STATUS)")
    CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
else
    echo "❌ Status ($CB_STATUS) is INVALID"
    echo "   Valid values: HEALTHY, TRIGGERED, COMPLETE, UNKNOWN"
    CB_VALIDATION_FAILED+=("Status: Invalid enum ($CB_STATUS)")
    CB_FAILED_CHECKS=$((CB_FAILED_CHECKS + 1))
fi

echo ""
```

---

### 8. Validate Session Count Progression

**Check session_count is non-negative and reasonable:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 5: SESSION COUNT"
echo "─────────────────────────────────────────────────────"
echo ""

CB_TOTAL_CHECKS=$((CB_TOTAL_CHECKS + 1))

if [[ $SESSION_COUNT -ge 0 ]]; then
    echo "✓ Session count ($SESSION_COUNT) is valid (non-negative)"
    CB_VALIDATION_PASSED+=("Session count: Valid ($SESSION_COUNT)")
    CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
else
    echo "❌ Session count ($SESSION_COUNT) is NEGATIVE"
    CB_VALIDATION_FAILED+=("Session count: Negative ($SESSION_COUNT)")
    CB_FAILED_CHECKS=$((CB_FAILED_CHECKS + 1))
fi

# Check if session_count matches implementation progress
FEATURE_LIST_FILE="{featureListFile}"
PASS_COUNT=$(jq -r '.features[] | select(.status == "pass") | .id' "$FEATURE_LIST_FILE" 2>/dev/null | wc -l)

CB_TOTAL_CHECKS=$((CB_TOTAL_CHECKS + 1))

if [[ $SESSION_COUNT -eq 0 && $PASS_COUNT -gt 0 ]]; then
    echo "⚠️  Session count is 0 but $PASS_COUNT features passed"
    echo "   This indicates sessions were executed but not counted"
    CB_VALIDATION_WARNINGS+=("Session count: Zero but features passed")
    CB_WARNING_COUNT=$((CB_WARNING_COUNT + 1))
elif [[ $SESSION_COUNT -gt 0 ]]; then
    echo "✓ Session count ($SESSION_COUNT) indicates sessions were executed"
    CB_VALIDATION_PASSED+=("Session count: Sessions executed ($SESSION_COUNT)")
    CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
else
    echo "✓ Session count matches no-progress state"
    CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
fi

echo ""
```

---

### 9. Validate Last Session Success Tracking

**Check last_session_success is consistent with consecutive_failures:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 6: LAST SESSION SUCCESS TRACKING"
echo "─────────────────────────────────────────────────────"
echo ""

CB_TOTAL_CHECKS=$((CB_TOTAL_CHECKS + 1))

if [[ "$LAST_SESSION_SUCCESS" == "true" && $CONSECUTIVE_FAILURES -gt 0 ]]; then
    echo "⚠️  Last session marked 'success' but consecutive_failures > 0"
    echo "   This indicates tracking may be out of sync"
    CB_VALIDATION_WARNINGS+=("Last session: Success but failures > 0")
    CB_WARNING_COUNT=$((CB_WARNING_COUNT + 1))
elif [[ "$LAST_SESSION_SUCCESS" == "false" && $CONSECUTIVE_FAILURES -eq 0 ]]; then
    echo "⚠️  Last session marked 'fail' but consecutive_failures = 0"
    echo "   This may indicate manual reset"
    CB_VALIDATION_WARNINGS+=("Last session: Fail but failures = 0")
    CB_WARNING_COUNT=$((CB_WARNING_COUNT + 1))
else
    echo "✓ Last session success tracking consistent with consecutive_failures"
    CB_VALIDATION_PASSED+=("Last session: Consistent tracking")
    CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
fi

echo ""
```

---

### 10. Validate Circuit Breaker Trigger Logic

**Verify circuit breaker would trigger correctly:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 7: CIRCUIT BREAKER TRIGGER LOGIC"
echo "─────────────────────────────────────────────────────"
echo ""

CB_TOTAL_CHECKS=$((CB_TOTAL_CHECKS + 1))

# Logic: If consecutive_failures >= threshold, status should be TRIGGERED
# Exception: If status is COMPLETE, that overrides TRIGGERED

if [[ "$CB_STATUS" == "COMPLETE" ]]; then
    echo "✓ Status is COMPLETE (workflow finished)"
    CB_VALIDATION_PASSED+=("Trigger logic: Status COMPLETE")
    CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
elif [[ $CONSECUTIVE_FAILURES -ge $THRESHOLD && "$CB_STATUS" != "TRIGGERED" ]]; then
    echo "❌ Circuit breaker SHOULD BE TRIGGERED but status is $CB_STATUS"
    echo "   consecutive_failures ($CONSECUTIVE_FAILURES) >= threshold ($THRESHOLD)"
    CB_VALIDATION_FAILED+=("Trigger logic: Should be TRIGGERED")
    CB_FAILED_CHECKS=$((CB_FAILED_CHECKS + 1))
elif [[ $CONSECUTIVE_FAILURES -lt $THRESHOLD && "$CB_STATUS" == "TRIGGERED" ]]; then
    echo "❌ Circuit breaker is TRIGGERED but consecutive_failures < threshold"
    echo "   consecutive_failures ($CONSECUTIVE_FAILURES) < threshold ($THRESHOLD)"
    CB_VALIDATION_FAILED+=("Trigger logic: Should NOT be TRIGGERED")
    CB_FAILED_CHECKS=$((CB_FAILED_CHECKS + 1))
else
    echo "✓ Circuit breaker trigger logic is correct"
    CB_VALIDATION_PASSED+=("Trigger logic: Correct")
    CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
fi

echo ""
```

---

### 11. Display Circuit Breaker Validation Summary

```
─────────────────────────────────────────────────────
  CIRCUIT BREAKER VALIDATION SUMMARY
─────────────────────────────────────────────────────

Total Checks: $CB_TOTAL_CHECKS
  ✓ Passed:  $CB_PASSED_CHECKS
  ❌ Failed:  $CB_FAILED_CHECKS
  ⚠️  Warnings: $CB_WARNING_COUNT

Overall Result: $(if [[ $CB_FAILED_CHECKS -eq 0 ]]; then echo "✓ PASS"; else echo "❌ FAIL"; fi)

$(if [[ $CB_FAILED_CHECKS -gt 0 ]]; then
    echo ""
    echo "Critical Issues Found:"
    for failure in "${CB_VALIDATION_FAILED[@]}"; do
        echo "  - $failure"
    done
fi)

$(if [[ $CB_WARNING_COUNT -gt 0 ]]; then
    echo ""
    echo "Warnings:"
    for warning in "${CB_VALIDATION_WARNINGS[@]}"; do
        echo "  - $warning"
    done
fi)

Next: Generate comprehensive validation report
```

---

### 12. Store Results for Final Report

**Export validation data for step-04:**

```bash
# Export for final report
export CB_VALIDATION_PASSED=$CB_PASSED_CHECKS
export CB_VALIDATION_FAILED=$CB_FAILED_CHECKS
export CB_VALIDATION_WARNINGS=$CB_WARNING_COUNT
export CB_VALIDATION_TOTAL=$CB_TOTAL_CHECKS
export CB_VALIDATION_RESULT=$(if [[ $CB_FAILED_CHECKS -eq 0 ]]; then echo "PASS"; else echo "FAIL"; fi)

# Also export circuit breaker state for report
export CB_SESSION_COUNT=$SESSION_COUNT
export CB_CONSECUTIVE_FAILURES=$CONSECUTIVE_FAILURES
export CB_THRESHOLD=$THRESHOLD
export CB_STATUS=$CB_STATUS

echo ""
echo "✓ Results stored for final report"
echo ""
```

---

### 13. Proceed to Next Step

**Menu Handling Logic:**
- This step uses **Auto-proceed** (no menu)
- Circuit breaker validation complete, proceed to report generation

**Execution:**

```
Proceeding to report generation...

→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- Circuit breaker validation initialized
- Circuit breaker state loaded
- Threshold range validated (1-99, recommended 3-10)
- Consecutive failures range validated (0-99)
- Status consistency checked (matches consecutive_failures vs threshold logic)
- Status value validated (valid enum)
- Session count validated (non-negative, consistent with progress)
- Last session success tracking validated
- Circuit breaker trigger logic validated
- Circuit breaker validation summary displayed
- Results exported for final report
- Ready for step-04 (report generation)

### ❌ FAILURE:
- (None - validation always completes)
- Failures and warnings recorded in validation results for reporting

**Master Rule:** Circuit breaker validation must verify logic consistency and state correctness.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
