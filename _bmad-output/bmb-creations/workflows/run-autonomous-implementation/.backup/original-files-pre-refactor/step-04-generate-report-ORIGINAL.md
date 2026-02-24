---
name: 'step-04-generate-report'
description: 'Generate comprehensive validation report and save to file'
---

# Step 04: Generate Validation Report (VALIDATE Mode)

## STEP GOAL:
Generate comprehensive validation report combining all validation results (state, implementation, circuit breaker) and save to file.

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: Report Generator (consolidation and output)
- ✅ Collaborative dialogue: None (automated report generation)
- ✅ You bring: Report formatting, result aggregation
- ✅ User brings: Validation results from steps 01-03

### Step-Specific:
- 🎯 Focus: Comprehensive, actionable validation report
- 🚫 Forbidden: Making repairs or modifications
- 💬 Approach: Clear report with recommendations

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Generate report file in project directory
- 📖 This is a FINAL step (no nextStepFile)

---

## CONTEXT BOUNDARIES:
- Available: All validation results from steps 01-03 (exported vars)
- Focus: Report generation and file output
- Limits: Read-only, does not modify tracking files
- Dependencies: Requires validation results from steps 01-03

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Report Generation Banner

```
═══════════════════════════════════════════════════════
  GENERATING VALIDATION REPORT
  Consolidating All Validation Results
═══════════════════════════════════════════════════════
```

---

### 2. Load All Validation Results

**Import results from previous steps:**

```bash
echo ""
echo "Loading validation results..."

# State validation (step-01)
STATE_PASSED=${STATE_VALIDATION_PASSED:-0}
STATE_FAILED=${STATE_VALIDATION_FAILED:-0}
STATE_WARNINGS=${STATE_VALIDATION_WARNINGS:-0}
STATE_TOTAL=${STATE_VALIDATION_TOTAL:-0}
STATE_RESULT=${STATE_VALIDATION_RESULT:-UNKNOWN}

# Implementation validation (step-02)
IMPL_PASSED=${IMPL_VALIDATION_PASSED:-0}
IMPL_FAILED=${IMPL_VALIDATION_FAILED:-0}
IMPL_WARNINGS=${IMPL_VALIDATION_WARNINGS:-0}
IMPL_TOTAL=${IMPL_VALIDATION_TOTAL:-0}
IMPL_RESULT=${IMPL_VALIDATION_RESULT:-UNKNOWN}

# Circuit breaker validation (step-03)
CB_PASSED=${CB_VALIDATION_PASSED:-0}
CB_FAILED=${CB_VALIDATION_FAILED:-0}
CB_WARNINGS=${CB_VALIDATION_WARNINGS:-0}
CB_TOTAL=${CB_VALIDATION_TOTAL:-0}
CB_RESULT=${CB_VALIDATION_RESULT:-UNKNOWN}

# Overall totals
TOTAL_CHECKS=$((STATE_TOTAL + IMPL_TOTAL + CB_TOTAL))
TOTAL_PASSED=$((STATE_PASSED + IMPL_PASSED + CB_PASSED))
TOTAL_FAILED=$((STATE_FAILED + IMPL_FAILED + CB_FAILED))
TOTAL_WARNINGS=$((STATE_WARNINGS + IMPL_WARNINGS + CB_WARNINGS))

# Overall result
if [[ $TOTAL_FAILED -eq 0 ]]; then
    OVERALL_RESULT="PASS"
else
    OVERALL_RESULT="FAIL"
fi

echo "✓ Validation results loaded"
echo "  Total Checks: $TOTAL_CHECKS"
echo "  Overall Result: $OVERALL_RESULT"
echo ""
```

---

### 3. Generate Report File

**Create comprehensive validation report:**

```bash
REPORT_FILE="{project_folder}/validation_report.md"

echo "Generating validation report..."
echo ""

cat > "$REPORT_FILE" <<EOF
# Validation Report - Autonomous Implementation Workflow

**Generated:** $(date -u +%Y-%m-%d %H:%M:%S)
**Workflow:** run-autonomous-implementation
**Mode:** VALIDATE

---

## Executive Summary

**Overall Result:** $(if [[ "$OVERALL_RESULT" == "PASS" ]]; then echo "✓ **PASS**"; else echo "❌ **FAIL**"; fi)

**Validation Statistics:**
- Total Checks: $TOTAL_CHECKS
- Passed: $TOTAL_PASSED ($(( TOTAL_PASSED * 100 / TOTAL_CHECKS ))%)
- Failed: $TOTAL_FAILED
- Warnings: $TOTAL_WARNINGS

$(if [[ "$OVERALL_RESULT" == "PASS" ]]; then
    cat <<'SUMMARYEOF'

✓ All critical validation checks passed.
The implementation tracking state is consistent and ready for continued execution.

SUMMARYEOF
else
    cat <<'SUMMARYEOF'

❌ Critical validation failures detected.
Review the failures below and take corrective action before resuming implementation.

SUMMARYEOF
fi)

---

## State Validation (Tracking File Integrity)

**Result:** $(if [[ "$STATE_RESULT" == "PASS" ]]; then echo "✓ PASS"; else echo "❌ FAIL"; fi)

**Checks:** $STATE_TOTAL
- Passed: $STATE_PASSED
- Failed: $STATE_FAILED
- Warnings: $STATE_WARNINGS

### What Was Validated

1. **File Existence** - feature_list.json, claude-progress.txt, build log
2. **JSON Syntax** - feature_list.json structure
3. **Required Fields** - metadata, features array, critical fields
4. **Feature Structure** - All features have required fields (id, name, status, etc.)
5. **Status Values** - All status values are valid enums
6. **Metadata Consistency** - total_features matches features array length
7. **Progress File Format** - claude-progress.txt has required metadata

$(if [[ $STATE_FAILED -gt 0 || $STATE_WARNINGS -gt 0 ]]; then
    cat <<'ISSUESEOF'

### Issues Found

Refer to step-01 validation output for detailed failure/warning messages.

ISSUESEOF
fi)

---

## Implementation Validation (Reality vs Tracking)

**Result:** $(if [[ "$IMPL_RESULT" == "PASS" ]]; then echo "✓ PASS"; else echo "❌ FAIL"; fi)

**Checks:** $IMPL_TOTAL
- Passed: $IMPL_PASSED
- Failed: $IMPL_FAILED
- Warnings: $IMPL_WARNINGS

### What Was Validated

1. **Git Repository** - Repository exists, has commits
2. **Passed Features Have Commits** - Features marked "pass" have git commits
3. **In-Progress Feature Status** - Detection of stuck "in_progress" features
4. **Verification Results** - Passed features have verification_results
5. **Attempts Consistency** - Attempts counter consistent with status
6. **Blocked Reasons** - Blocked features have blocked_reason

$(if [[ $IMPL_FAILED -gt 0 || $IMPL_WARNINGS -gt 0 ]]; then
    cat <<'ISSUESEOF'

### Issues Found

Refer to step-02 validation output for detailed failure/warning messages.

ISSUESEOF
fi)

---

## Circuit Breaker Validation (Logic Consistency)

**Result:** $(if [[ "$CB_RESULT" == "PASS" ]]; then echo "✓ PASS"; else echo "❌ FAIL"; fi)

**Checks:** $CB_TOTAL
- Passed: $CB_PASSED
- Failed: $CB_FAILED
- Warnings: $CB_WARNINGS

### What Was Validated

1. **Threshold Range** - Valid range (1-99), recommended range (3-10)
2. **Consecutive Failures Range** - Non-negative, within bounds (0-99)
3. **Status Consistency** - Status matches consecutive_failures vs threshold logic
4. **Status Value** - Status is valid enum (HEALTHY/TRIGGERED/COMPLETE)
5. **Session Count** - Non-negative, consistent with progress
6. **Last Session Success Tracking** - Consistent with consecutive_failures
7. **Circuit Breaker Trigger Logic** - Trigger conditions correct

### Circuit Breaker State

- Session Count: ${CB_SESSION_COUNT:-N/A}
- Consecutive Failures: ${CB_CONSECUTIVE_FAILURES:-N/A}
- Threshold: ${CB_THRESHOLD:-N/A}
- Status: ${CB_STATUS:-N/A}

$(if [[ ${CB_STATUS:-UNKNOWN} == "TRIGGERED" ]]; then
    cat <<'CBEOF'

⚠️ **Circuit Breaker is TRIGGERED**

The workflow will exit immediately when run.
Reset consecutive_failures to 0 using EDIT mode to resume implementation.

CBEOF
fi)

$(if [[ $CB_FAILED -gt 0 || $CB_WARNINGS -gt 0 ]]; then
    cat <<'ISSUESEOF'

### Issues Found

Refer to step-03 validation output for detailed failure/warning messages.

ISSUESEOF
fi)

---

## Recommendations

$(if [[ "$OVERALL_RESULT" == "PASS" ]]; then
    cat <<'RECEOF'

✓ **Validation passed - No critical issues found.**

### Next Steps

1. **Resume Implementation (if needed):**
   \`\`\`bash
   /bmad-bmm-run-autonomous-implementation
   \`\`\`

2. **Review Progress:**
   - Check feature_list.json for feature statuses
   - Review claude-progress.txt for session history
   - Check autonomous_build_log.md for detailed logs

3. **Deploy (if complete):**
   - If all features are implemented, proceed to deployment
   - Run integration tests
   - Review git history

RECEOF
else
    cat <<'RECEOF'

❌ **Validation failed - Critical issues require attention.**

### Corrective Actions

1. **Review Validation Output:**
   - Read detailed failure messages in validation output
   - Identify root causes of failures

2. **Fix Critical Issues:**

   **If state/tracking files corrupted:**
   - Restore from backup (if available)
   - Regenerate feature_list.json from app_spec.txt
   - Reinitialize claude-progress.txt

   **If implementation inconsistent:**
   - Review git history for anomalies
   - Check for manual edits to tracking files
   - Reset stuck "in_progress" features using EDIT mode

   **If circuit breaker logic inconsistent:**
   - Use EDIT mode to correct circuit breaker state
   - Reset consecutive_failures if needed
   - Adjust threshold if appropriate

3. **Use EDIT Mode to Fix Issues:**
   \`\`\`bash
   /bmad-bmm-run-autonomous-implementation --mode=edit
   \`\`\`

4. **Re-validate After Fixes:**
   \`\`\`bash
   /bmad-bmm-run-autonomous-implementation --mode=validate
   \`\`\`

RECEOF
fi)

$(if [[ $TOTAL_WARNINGS -gt 0 ]]; then
    cat <<'WARNEOF'

### Warnings Review

While not critical failures, the following warnings should be reviewed:

- **In-progress features:** Features stuck "in_progress" may need manual reset
- **Missing verification results:** Features marked "pass" should have verification_results
- **Missing blocked reasons:** Blocked features should have blocked_reason
- **Threshold recommendations:** Consider adjusting circuit breaker threshold
- **Session tracking inconsistencies:** May indicate manual resets or interrupted sessions

Use EDIT mode to address warnings if needed.

WARNEOF
fi)

---

## Validation Details

### File Paths Validated

- **feature_list.json:** {project_folder}/feature_list.json
- **claude-progress.txt:** {project_folder}/claude-progress.txt
- **autonomous_build_log.md:** {project_folder}/autonomous_build_log.md
- **Git repository:** {project_folder}/.git

### Validation Timestamp

**Started:** Step-01 execution time
**Completed:** $(date -u +%Y-%m-%d %H:%M:%S)

---

## Report Metadata

- **Workflow:** run-autonomous-implementation
- **Mode:** VALIDATE
- **Report Version:** 1.0.0
- **Generated By:** BMAD Workflow Engine

---

**End of Validation Report**

EOF

if [[ $? -eq 0 ]]; then
    echo "✓ Validation report generated: $REPORT_FILE"
else
    echo "❌ ERROR: Failed to generate report file"
    exit 21
fi

echo ""
```

---

### 4. Display Report Summary

```
─────────────────────────────────────────────────────
  VALIDATION REPORT GENERATED
─────────────────────────────────────────────────────

Report File: validation_report.md

Overall Result: $(if [[ "$OVERALL_RESULT" == "PASS" ]]; then echo "✓ PASS"; else echo "❌ FAIL"; fi)

Validation Breakdown:
  State Validation:          $(if [[ "$STATE_RESULT" == "PASS" ]]; then echo "✓ PASS"; else echo "❌ FAIL"; fi) ($STATE_PASSED/$STATE_TOTAL checks, $STATE_WARNINGS warnings)
  Implementation Validation: $(if [[ "$IMPL_RESULT" == "PASS" ]]; then echo "✓ PASS"; else echo "❌ FAIL"; fi) ($IMPL_PASSED/$IMPL_TOTAL checks, $IMPL_WARNINGS warnings)
  Circuit Breaker Validation: $(if [[ "$CB_RESULT" == "PASS" ]]; then echo "✓ PASS"; else echo "❌ FAIL"; fi) ($CB_PASSED/$CB_TOTAL checks, $CB_WARNINGS warnings)

Total: $TOTAL_PASSED/$TOTAL_CHECKS checks passed, $TOTAL_WARNINGS warnings

$(if [[ "$OVERALL_RESULT" == "PASS" ]]; then
    cat <<'NEXTEOF'

✓ All critical validation checks passed.
Implementation tracking is consistent and ready for continued execution.

NEXTEOF
else
    cat <<'NEXTEOF'

❌ Critical validation failures detected.
Review validation_report.md for details and corrective actions.

NEXTEOF
fi)

Review the full report: {project_folder}/validation_report.md
```

---

### 5. Display Next Steps

```
─────────────────────────────────────────────────────
  NEXT STEPS
─────────────────────────────────────────────────────

$(if [[ "$OVERALL_RESULT" == "PASS" ]]; then
    cat <<'PASSEOF'

✓ **Validation Successful**

1. **Resume Implementation (if needed):**
   /bmad-bmm-run-autonomous-implementation

2. **Review Warnings (if any):**
   Check validation_report.md for non-critical warnings
   Use EDIT mode to address warnings if needed

3. **Continue Workflow:**
   If features remain, continue autonomous implementation
   If complete, proceed to deployment and testing

PASSEOF
else
    cat <<'FAILEOF'

❌ **Validation Failed - Action Required**

1. **Review Detailed Report:**
   cat {project_folder}/validation_report.md

2. **Fix Critical Issues:**
   Use EDIT mode to correct tracking state:
   /bmad-bmm-run-autonomous-implementation --mode=edit

3. **Re-validate After Fixes:**
   /bmad-bmm-run-autonomous-implementation --mode=validate

4. **DO NOT Resume Implementation Until Validation Passes**

FAILEOF
fi)

─────────────────────────────────────────────────────
```

---

### 6. Display Final Exit Message

```
═══════════════════════════════════════════════════════
  VALIDATE MODE COMPLETE
═══════════════════════════════════════════════════════

Validation Result: $(if [[ "$OVERALL_RESULT" == "PASS" ]]; then echo "✓ PASS"; else echo "❌ FAIL"; fi)

Report saved to: validation_report.md

$(if [[ "$OVERALL_RESULT" == "PASS" ]]; then
    echo "✓ Implementation state is consistent and valid"
else
    echo "⚠️  Implementation state has critical issues - review report"
fi)

Thank you for using VALIDATE mode.

═══════════════════════════════════════════════════════
```

---

### 7. No Next Step (Final Step)

**This is a final step - workflow ends here.**

VALIDATE mode is complete. User should:
- Review validation_report.md for detailed results
- Fix issues if validation failed
- Resume implementation if validation passed
- Use EDIT mode if corrections needed

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- All validation results loaded
- Overall result calculated (PASS/FAIL)
- Comprehensive validation report generated
- Report saved to validation_report.md
- Report summary displayed
- Next steps provided based on validation result
- Final exit message displayed
- Clean exit from VALIDATE mode

### ❌ FAILURE:
- Report generation fails (exit code 21)

**Master Rule:** Validation report must consolidate all results and provide clear, actionable recommendations.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete (FINAL STEP for VALIDATE mode)
