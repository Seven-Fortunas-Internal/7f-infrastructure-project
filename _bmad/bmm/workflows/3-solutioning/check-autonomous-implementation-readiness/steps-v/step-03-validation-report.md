---
name: 'step-03-validation-report'
description: 'Generate validation report'

outputFolder: '{output_folder}'
---

# Step 3 (Validate Mode): Validation Report

## STEP GOAL:

To generate a validation report summarizing quality assessment findings.

## MANDATORY SEQUENCE

### 1. Compile Validation Results

Gather all validation results from step-02.

### 2. Generate Validation Report

Create validation summary:

"**═══════════════════════════════════════**
**   ASSESSMENT VALIDATION REPORT   **
**═══════════════════════════════════════**

**Assessment File:** {assessment_path}
**Validation Date:** {current_date}

**Validation Results:**

**1. Completeness:** {completeness_score}/100
   - All required sections: {✅/❌}
   - Missing sections: {list if any}

**2. Score Accuracy:** {✅ Accurate / ⚠️ Issues / ❌ Errors}
   - Overall score calculation: {✅/❌}
   - Dimension scores valid: {✅/❌}
   - Issues found: {list if any}

**3. Evidence Quality:** {evidence_score}/100
   - Sections with evidence: {count}/{total}
   - Specific examples provided: {✅/❌}
   - PRD/app_spec references: {✅/❌}
   - Gaps with IDs: {✅/❌}

**4. Recommendation Quality:** {✅ Good / ⚠️ Adequate / ❌ Insufficient}
   - Recommendations specific: {✅/❌}
   - Recommendations prioritized: {✅/❌}
   - Recommendations actionable: {✅/❌}

**5. Go/No-Go Logic:** {✅ Consistent / ❌ Inconsistent}
   - Decision aligns with scores: {✅/❌}
   - Decision rationale clear: {✅/❌}

**═══════════════════════════════════════**

**Overall Validation Assessment:**
{PASS / PASS WITH CONCERNS / FAIL}

**Issues Identified:**
{List any validation failures or concerns}

**Recommendations for Improvement:**
{Specific recommendations to improve assessment quality}

**═══════════════════════════════════════**"

### 3. Save Validation Report

Save report to: `{outputFolder}/validation-report-{timestamp}.md`

Confirm: "✅ Validation report saved: {report_path}"

### 4. Present Next Steps

"**Validation Complete**

{IF PASS: Assessment quality is good. Ready to use for decision-making.}
{IF PASS WITH CONCERNS: Assessment is usable but has quality concerns. Consider addressing issues.}
{IF FAIL: Assessment has significant quality issues. Re-run assessment or use edit mode to fix.}

**Validation workflow complete.**"

**Master Rule:** Validation report must be specific about all quality issues found.
