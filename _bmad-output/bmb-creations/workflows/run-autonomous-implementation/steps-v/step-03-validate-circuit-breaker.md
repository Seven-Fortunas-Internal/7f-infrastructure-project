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

**Execution Rules:** See {workflow_path}/data/universal-step-rules.md

**Role:** Logic Validator (circuit breaker consistency checker)
**Protocol:** Read-only validation, collect issues for final report
**Context:** claude-progress.txt, feature_list.json (read-only)
**Dependencies:** State and implementation validation from steps 01-02

---

## MANDATORY SEQUENCE

### 1. Display Banner & Initialize

```
═══════════════════════════════════════════════════════
  VALIDATE CIRCUIT BREAKER
  Verifying Logic and State Consistency
═══════════════════════════════════════════════════════
```

```bash
echo "Initializing circuit breaker validation..."
CB_VALIDATION_PASSED=(); CB_VALIDATION_FAILED=(); CB_VALIDATION_WARNINGS=()
CB_TOTAL_CHECKS=0; CB_PASSED_CHECKS=0; CB_FAILED_CHECKS=0; CB_WARNING_COUNT=0
echo "✓ Circuit breaker validation initialized"
```

---

### 2. Load Circuit Breaker State

```bash
PROGRESS_FILE="{progressFile}"
SESSION_COUNT=$(grep '^session_count=' "$PROGRESS_FILE" | cut -d= -f2)
CONSECUTIVE_FAILURES=$(grep '^consecutive_failures=' "$PROGRESS_FILE" | cut -d= -f2)
THRESHOLD=$(grep '^circuit_breaker_threshold=' "$PROGRESS_FILE" | cut -d= -f2)
CB_STATUS=$(grep '^circuit_breaker_status=' "$PROGRESS_FILE" | cut -d= -f2)
LAST_SESSION_SUCCESS=$(grep '^last_session_success=' "$PROGRESS_FILE" | cut -d= -f2)
SESSION_COUNT=${SESSION_COUNT:-0}; CONSECUTIVE_FAILURES=${CONSECUTIVE_FAILURES:-0}
THRESHOLD=${THRESHOLD:-5}; CB_STATUS=${CB_STATUS:-UNKNOWN}; LAST_SESSION_SUCCESS=${LAST_SESSION_SUCCESS:-unknown}
echo "✓ State: Sessions=$SESSION_COUNT | Failures=$CONSECUTIVE_FAILURES | Threshold=$THRESHOLD | Status=$CB_STATUS"
```

---

### 3. Validate Threshold Range

```bash
echo "CHECK 1: THRESHOLD RANGE"
CB_TOTAL_CHECKS=$((CB_TOTAL_CHECKS + 2))
if [[ $THRESHOLD -ge 1 && $THRESHOLD -le 99 ]]; then
    echo "✓ Threshold ($THRESHOLD) valid (1-99)"; CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
else
    echo "❌ Threshold OUT OF RANGE"; CB_VALIDATION_FAILED+=("Threshold: Out of range ($THRESHOLD)"); CB_FAILED_CHECKS=$((CB_FAILED_CHECKS + 1))
fi
if [[ $THRESHOLD -ge 3 && $THRESHOLD -le 10 ]]; then
    echo "✓ Recommended range (3-10)"; CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
else
    echo "⚠️  Outside recommended range"; CB_VALIDATION_WARNINGS+=("Threshold: Outside recommended range"); CB_WARNING_COUNT=$((CB_WARNING_COUNT + 1))
fi
```

---

### 4. Validate Consecutive Failures Range

```bash
echo "CHECK 2: CONSECUTIVE FAILURES RANGE"
CB_TOTAL_CHECKS=$((CB_TOTAL_CHECKS + 1))
if [[ $CONSECUTIVE_FAILURES -ge 0 && $CONSECUTIVE_FAILURES -le 99 ]]; then
    echo "✓ Consecutive failures ($CONSECUTIVE_FAILURES) valid"; CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
else
    echo "❌ OUT OF RANGE"; CB_VALIDATION_FAILED+=("Consecutive failures: Out of range"); CB_FAILED_CHECKS=$((CB_FAILED_CHECKS + 1))
fi
```

---

### 5. Validate Status Consistency

```bash
echo "CHECK 3: STATUS CONSISTENCY"
CB_TOTAL_CHECKS=$((CB_TOTAL_CHECKS + 1))
if [[ $CONSECUTIVE_FAILURES -ge $THRESHOLD ]]; then EXPECTED_STATUS="TRIGGERED"
elif [[ $CB_STATUS == "COMPLETE" ]]; then EXPECTED_STATUS="COMPLETE"
else EXPECTED_STATUS="HEALTHY"; fi

if [[ "$CB_STATUS" == "$EXPECTED_STATUS" ]]; then
    echo "✓ Status consistent"; CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
else
    echo "❌ INCONSISTENT (Expected: $EXPECTED_STATUS)"; CB_VALIDATION_FAILED+=("Status: Inconsistent, expected $EXPECTED_STATUS"); CB_FAILED_CHECKS=$((CB_FAILED_CHECKS + 1))
fi
```

---

### 6. Validate Status Value

```bash
echo "CHECK 4: STATUS VALUE"
VALID_STATUSES=("HEALTHY" "TRIGGERED" "COMPLETE" "UNKNOWN")
CB_TOTAL_CHECKS=$((CB_TOTAL_CHECKS + 1))
if [[ " ${VALID_STATUSES[@]} " =~ " ${CB_STATUS} " ]]; then
    echo "✓ Valid enum"; CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
else
    echo "❌ INVALID"; CB_VALIDATION_FAILED+=("Status: Invalid enum ($CB_STATUS)"); CB_FAILED_CHECKS=$((CB_FAILED_CHECKS + 1))
fi
```

---

### 7. Validate Session Count

```bash
echo "CHECK 5: SESSION COUNT"
CB_TOTAL_CHECKS=$((CB_TOTAL_CHECKS + 2))
if [[ $SESSION_COUNT -ge 0 ]]; then
    echo "✓ Valid ($SESSION_COUNT)"; CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
else
    echo "❌ NEGATIVE"; CB_VALIDATION_FAILED+=("Session count: Negative"); CB_FAILED_CHECKS=$((CB_FAILED_CHECKS + 1))
fi

FEATURE_LIST_FILE="{featureListFile}"
PASS_COUNT=$(jq -r '.features[] | select(.status == "pass") | .id' "$FEATURE_LIST_FILE" 2>/dev/null | wc -l)
if [[ $SESSION_COUNT -eq 0 && $PASS_COUNT -gt 0 ]]; then
    echo "⚠️  Zero but $PASS_COUNT features passed"; CB_VALIDATION_WARNINGS+=("Session count: Zero but features passed"); CB_WARNING_COUNT=$((CB_WARNING_COUNT + 1))
elif [[ $SESSION_COUNT -gt 0 ]]; then
    echo "✓ Matches execution"; CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
else
    echo "✓ Matches no-progress"; CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
fi
```

---

### 8. Validate Last Session Success Tracking

```bash
echo "CHECK 6: LAST SESSION SUCCESS TRACKING"
CB_TOTAL_CHECKS=$((CB_TOTAL_CHECKS + 1))
if [[ "$LAST_SESSION_SUCCESS" == "true" && $CONSECUTIVE_FAILURES -gt 0 ]]; then
    echo "⚠️  Success but failures>0"; CB_VALIDATION_WARNINGS+=("Last session: Success but failures>0"); CB_WARNING_COUNT=$((CB_WARNING_COUNT + 1))
elif [[ "$LAST_SESSION_SUCCESS" == "false" && $CONSECUTIVE_FAILURES -eq 0 ]]; then
    echo "⚠️  Fail but failures=0"; CB_VALIDATION_WARNINGS+=("Last session: Fail but failures=0"); CB_WARNING_COUNT=$((CB_WARNING_COUNT + 1))
else
    echo "✓ Consistent"; CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
fi
```

---

### 9. Validate Circuit Breaker Trigger Logic

```bash
echo "CHECK 7: CIRCUIT BREAKER TRIGGER LOGIC"
CB_TOTAL_CHECKS=$((CB_TOTAL_CHECKS + 1))
if [[ "$CB_STATUS" == "COMPLETE" ]]; then
    echo "✓ Status COMPLETE"; CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
elif [[ $CONSECUTIVE_FAILURES -ge $THRESHOLD && "$CB_STATUS" != "TRIGGERED" ]]; then
    echo "❌ Should be TRIGGERED"; CB_VALIDATION_FAILED+=("Trigger logic: Should be TRIGGERED"); CB_FAILED_CHECKS=$((CB_FAILED_CHECKS + 1))
elif [[ $CONSECUTIVE_FAILURES -lt $THRESHOLD && "$CB_STATUS" == "TRIGGERED" ]]; then
    echo "❌ Should NOT be TRIGGERED"; CB_VALIDATION_FAILED+=("Trigger logic: Should NOT be TRIGGERED"); CB_FAILED_CHECKS=$((CB_FAILED_CHECKS + 1))
else
    echo "✓ Correct"; CB_PASSED_CHECKS=$((CB_PASSED_CHECKS + 1))
fi
```

---

### 10. Display Summary & Store Results

```
─────────────────────────────────────────────────────
  CIRCUIT BREAKER VALIDATION SUMMARY
─────────────────────────────────────────────────────

Total Checks: $CB_TOTAL_CHECKS
  ✓ Passed:  $CB_PASSED_CHECKS
  ❌ Failed:  $CB_FAILED_CHECKS
  ⚠️  Warnings: $CB_WARNING_COUNT

Overall Result: $(if [[ $CB_FAILED_CHECKS -eq 0 ]]; then echo "✓ PASS"; else echo "❌ FAIL"; fi)

$(if [[ $CB_FAILED_CHECKS -gt 0 ]]; then echo "Critical Issues:"; for failure in "${CB_VALIDATION_FAILED[@]}"; do echo "  - $failure"; done; fi)
$(if [[ $CB_WARNING_COUNT -gt 0 ]]; then echo "Warnings:"; for warning in "${CB_VALIDATION_WARNINGS[@]}"; do echo "  - $warning"; done; fi)
```

```bash
export CB_VALIDATION_PASSED=$CB_PASSED_CHECKS CB_VALIDATION_FAILED=$CB_FAILED_CHECKS CB_VALIDATION_WARNINGS=$CB_WARNING_COUNT CB_VALIDATION_TOTAL=$CB_TOTAL_CHECKS
export CB_VALIDATION_RESULT=$(if [[ $CB_FAILED_CHECKS -eq 0 ]]; then echo "PASS"; else echo "FAIL"; fi)
export CB_SESSION_COUNT=$SESSION_COUNT CB_CONSECUTIVE_FAILURES=$CONSECUTIVE_FAILURES CB_THRESHOLD=$THRESHOLD CB_STATUS=$CB_STATUS
echo "✓ Results stored for final report"
```

---

### 11. Proceed to Next Step

**Auto-proceed** (no menu) - validation complete, proceeding to report generation.

```
Proceeding to report generation...

→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

**Success/Failure criteria:** See {workflow_path}/data/universal-step-rules.md

**Master Rule:** Circuit breaker validation must verify logic consistency and state correctness.

---

**Step Version:** 1.0.0 | **Created:** 2026-02-17 | **Status:** Complete
