---
name: 'step-02-run-validation'
description: 'Run validation checks on assessment'

nextStepFile: './step-03-validation-report.md'
---

# Step 2 (Validate Mode): Run Validation Checks

## STEP GOAL:

To execute validation checks on the readiness assessment.

## MANDATORY SEQUENCE

### 1. Check Completeness

**Verify all required sections present:**
- [ ] Document Inventory
- [ ] PRD Analysis
- [ ] App Spec Coverage Analysis
- [ ] Architecture Alignment Assessment
- [ ] Feature Quality Review
- [ ] Overall Readiness Assessment
- [ ] Action Items
- [ ] Recommendations

**Completeness Score:** {sections_present}/{total_sections} * 100

### 2. Check Score Accuracy

**Verify scores are calculated correctly:**
- Check overall score = weighted average of dimensions
- Verify dimension scores are within 0-100 range
- Ensure scores align with described findings

**Score Accuracy:** ✅ Accurate / ⚠️ Minor issues / ❌ Calculation errors

### 3. Check Evidence Quality

**For each analysis section, verify:**
- Specific examples provided (not generic)
- PRD/app_spec.txt references included
- Gaps identified with requirement IDs
- Scores justified by evidence

**Evidence Quality:** {sections_with_evidence}/{total_sections}

### 4. Check Recommendation Quality

**Verify recommendations are:**
- Specific and actionable
- Prioritized (Critical/High/Medium/Low)
- Mapped to specific findings
- Realistic and achievable

**Recommendation Quality:** ✅ Good / ⚠️ Adequate / ❌ Insufficient

### 5. Check Go/No-Go Logic

**Verify decision is consistent:**
- GO requires: Score ≥75, No critical blockers, Coverage ≥70
- CONDITIONAL GO: Score 60-74 OR 1-2 blockers with mitigation
- NO-GO: Score <60 OR 3+ blockers OR Coverage <60

**Decision Consistency:** ✅ Consistent / ❌ Inconsistent

### 6. Store Validation Results

Store all validation findings for report generation.

### 7. Present MENU OPTIONS

Display: [C] Continue to Validation Report

#### EXECUTION RULES:

- ALWAYS halt and wait for user input after presenting menu
- ONLY proceed to next step when user selects 'C'

#### Menu Handling Logic:
- IF C: Load {nextStepFile}

**Master Rule:** All validation checks must be evidence-based.
