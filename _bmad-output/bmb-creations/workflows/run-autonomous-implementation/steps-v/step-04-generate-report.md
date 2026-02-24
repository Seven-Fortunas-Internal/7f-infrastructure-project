---
name: 'step-04-generate-report'
description: 'Generate comprehensive validation report and save to file'
reportTemplate: '{workflow_path}/templates/validation-report-template.md'
---

# Step 04: Generate Validation Report (VALIDATE Mode)

## STEP GOAL:
Generate comprehensive validation report combining all validation results and save to file.

**Execution Rules:** See {workflow_path}/data/universal-step-rules.md

---

## Role & Context

**Role:** Report Generator (consolidation and output)
**Focus:** Generate actionable validation report
**Dependencies:** Validation results from steps 01-03

---

## MANDATORY SEQUENCE

### 1. Display Banner

```
═══════════════════════════════════════════════════════
  GENERATING VALIDATION REPORT
  Consolidating All Validation Results
═══════════════════════════════════════════════════════
```

---

### 2. Load Validation Results

```bash
echo ""
echo "Loading validation results..."

# State validation
STATE_PASSED=${STATE_VALIDATION_PASSED:-0}
STATE_FAILED=${STATE_VALIDATION_FAILED:-0}
STATE_WARNINGS=${STATE_VALIDATION_WARNINGS:-0}
STATE_TOTAL=${STATE_VALIDATION_TOTAL:-0}
STATE_RESULT=${STATE_VALIDATION_RESULT:-UNKNOWN}

# Implementation validation
IMPL_PASSED=${IMPL_VALIDATION_PASSED:-0}
IMPL_FAILED=${IMPL_VALIDATION_FAILED:-0}
IMPL_WARNINGS=${IMPL_VALIDATION_WARNINGS:-0}
IMPL_TOTAL=${IMPL_VALIDATION_TOTAL:-0}
IMPL_RESULT=${IMPL_VALIDATION_RESULT:-UNKNOWN}

# Circuit breaker validation
CB_PASSED=${CB_VALIDATION_PASSED:-0}
CB_FAILED=${CB_VALIDATION_FAILED:-0}
CB_WARNINGS=${CB_VALIDATION_WARNINGS:-0}
CB_TOTAL=${CB_VALIDATION_TOTAL:-0}
CB_RESULT=${CB_VALIDATION_RESULT:-UNKNOWN}

# Calculate totals
TOTAL_CHECKS=$((STATE_TOTAL + IMPL_TOTAL + CB_TOTAL))
TOTAL_PASSED=$((STATE_PASSED + IMPL_PASSED + CB_PASSED))
TOTAL_FAILED=$((STATE_FAILED + IMPL_FAILED + CB_FAILED))
TOTAL_WARNINGS=$((STATE_WARNINGS + IMPL_WARNINGS + CB_WARNINGS))

# Determine overall result
OVERALL_RESULT="PASS"
[[ $TOTAL_FAILED -gt 0 ]] && OVERALL_RESULT="FAIL"

echo "✓ Results loaded: $OVERALL_RESULT"
echo ""
```

---

### 3. Generate Report from Template

**Load template and substitute variables:**

```bash
REPORT_FILE="{project_folder}/validation_report.md"
TEMPLATE="{reportTemplate}"

echo "Generating report from template..."

# Use template with variable substitution
sed -e "s/TIMESTAMP/$(date -u +%Y-%m-%d\ %H:%M:%S)/g" \
    -e "s/OVERALL_RESULT/$OVERALL_RESULT/g" \
    -e "s/TOTAL_CHECKS/$TOTAL_CHECKS/g" \
    -e "s/PASSED_CHECKS/$TOTAL_PASSED/g" \
    -e "s/FAILED_CHECKS/$TOTAL_FAILED/g" \
    -e "s/WARNING_COUNT/$TOTAL_WARNINGS/g" \
    -e "s/PERCENTAGE/$(( TOTAL_PASSED * 100 / TOTAL_CHECKS ))/g" \
    -e "s/STATE_RESULT/$STATE_RESULT/g" \
    -e "s/STATE_TOTAL/$STATE_TOTAL/g" \
    -e "s/STATE_PASSED/$STATE_PASSED/g" \
    -e "s/STATE_FAILED/$STATE_FAILED/g" \
    -e "s/STATE_WARNINGS/$STATE_WARNINGS/g" \
    -e "s/IMPL_RESULT/$IMPL_RESULT/g" \
    -e "s/IMPL_TOTAL/$IMPL_TOTAL/g" \
    -e "s/IMPL_PASSED/$IMPL_PASSED/g" \
    -e "s/IMPL_FAILED/$IMPL_FAILED/g" \
    -e "s/IMPL_WARNINGS/$IMPL_WARNINGS/g" \
    -e "s/CB_RESULT/$CB_RESULT/g" \
    -e "s/CB_TOTAL/$CB_TOTAL/g" \
    -e "s/CB_PASSED/$CB_PASSED/g" \
    -e "s/CB_FAILED/$CB_FAILED/g" \
    -e "s/CB_WARNINGS/$CB_WARNINGS/g" \
    -e "s/SESSION_COUNT/${CB_SESSION_COUNT:-N\/A}/g" \
    -e "s/CONSECUTIVE_FAILURES/${CB_CONSECUTIVE_FAILURES:-N\/A}/g" \
    -e "s/THRESHOLD/${CB_THRESHOLD:-N\/A}/g" \
    -e "s/CB_STATUS/${CB_STATUS:-N\/A}/g" \
    -e "s|PROJECT_FOLDER|{project_folder}|g" \
    "$TEMPLATE" > "$REPORT_FILE"

# Add summary message
if [[ "$OVERALL_RESULT" == "PASS" ]]; then
    sed -i 's/SUMMARY_MESSAGE/✓ All critical validation checks passed./' "$REPORT_FILE"
else
    sed -i 's/SUMMARY_MESSAGE/❌ Critical validation failures detected./' "$REPORT_FILE"
fi

# Add recommendations based on result
if [[ "$OVERALL_RESULT" == "PASS" ]]; then
    RECOMMENDATIONS="✓ Validation passed. Workflow ready for deployment."
else
    RECOMMENDATIONS="❌ Review failures and take corrective action before deployment."
fi
sed -i "s/RECOMMENDATIONS/$RECOMMENDATIONS/g" "$REPORT_FILE"

echo "✓ Report generated: $REPORT_FILE"
echo ""
```

---

### 4. Display Summary

```
─────────────────────────────────────────────────────
  VALIDATION REPORT GENERATED
─────────────────────────────────────────────────────

Report: validation_report.md
Result: $OVERALL_RESULT

Stats:
  - Total Checks: $TOTAL_CHECKS
  - Passed: $TOTAL_PASSED ($(( TOTAL_PASSED * 100 / TOTAL_CHECKS ))%)
  - Failed: $TOTAL_FAILED
  - Warnings: $TOTAL_WARNINGS

$(if [[ "$OVERALL_RESULT" == "PASS" ]]; then
    echo "✓ All critical checks passed"
else
    echo "❌ Critical failures - review report"
fi)
```

---

### 5. Display Next Steps

**Guide user based on result:**

```
─────────────────────────────────────────────────────
  NEXT STEPS
─────────────────────────────────────────────────────

$(if [[ "$OVERALL_RESULT" == "PASS" ]]; then
    cat <<'PASSEOF'
✓ Validation successful

1. Resume implementation:
   /bmad-bmm-run-autonomous-implementation

2. Review warnings (if any):
   cat {project_folder}/validation_report.md

3. Deploy when ready

PASSEOF
else
    cat <<'FAILEOF'
❌ Validation failed

1. Review report:
   cat {project_folder}/validation_report.md

2. Fix issues using EDIT mode:
   /bmad-bmm-run-autonomous-implementation --mode=edit

3. Re-validate after fixes:
   /bmad-bmm-run-autonomous-implementation --mode=validate

FAILEOF
fi)
```

---

### 6. Final Exit Message

```
═══════════════════════════════════════════════════════
  VALIDATE MODE COMPLETE
═══════════════════════════════════════════════════════

Result: $OVERALL_RESULT
Report: validation_report.md

$(if [[ "$OVERALL_RESULT" == "PASS" ]]; then
    echo "✓ Implementation state is valid"
else
    echo "⚠️ Review report for issues"
fi)

Thank you for using VALIDATE mode.
═══════════════════════════════════════════════════════
```

---

## SUCCESS/FAILURE

**See {workflow_path}/data/universal-step-rules.md for standard criteria**

### ✅ SUCCESS:
- All validation results loaded
- Report generated from template
- Report saved successfully
- Summary displayed
- Clean exit

### ❌ FAILURE:
- Report generation fails (exit 21)

---

**Step Version:** 1.0.1 (Refactored)
**Created:** 2026-02-17
**Status:** Complete (FINAL STEP for VALIDATE mode)
