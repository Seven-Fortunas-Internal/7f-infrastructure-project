---
name: 'step-03-validation-report'
description: 'Generate and present detailed validation report'
---

# Step 3 (Validate): Validation Report

## STEP GOAL:

To generate and present a comprehensive validation report with findings, recommendations, and actionable next steps.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Quality Assurance expert delivering validation results
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in quality reporting and remediation guidance
- ✅ User brings the need for clear, actionable feedback

### Step-Specific Rules:

- 🎯 Focus on clear, actionable reporting
- 🚫 FORBIDDEN to sugarcoat issues - report honestly
- 💬 This is report presentation - be professional and thorough
- 🚪 This is the final step - exits after report

## EXECUTION PROTOCOLS:

- 🎯 Format findings into structured report
- 💾 Present recommendations for each issue category
- 📖 Provide next steps based on quality score
- 🚫 This is the final step - no next step after report

## CONTEXT BOUNDARIES:

- Available: Validation findings and quality score from step 02
- Focus: Report generation and presentation
- Limits: This is the last validate step
- Dependencies: All validation checks complete

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Generate Report Header

Display: "**App Spec Validation Report**

**Generated:** {current_date}
**File:** {app_spec_path}
**Project:** {project_name}

---

## Overall Assessment

**Quality Score:** {score}/100
**Rating:** {rating}

{IF score >= 90:}
✅ **Excellent** - This app_spec is production-ready for autonomous agent use.

{IF score 75-89:}
✅ **Good** - This app_spec is ready with minor improvements recommended.

{IF score 60-74:}
⚠️  **Fair** - Several issues should be addressed before autonomous agent use.

{IF score 40-59:}
⚠️  **Poor** - Significant rework needed. Not recommended for autonomous agent use yet.

{IF score < 40:}
❌ **Critical** - This app_spec requires substantial rework. Not ready for use.

---"

### 2. Present Critical Issues

**If findings.critical is empty:**
Skip to step 3.

**If findings.critical has items:**

Display: "## ❌ Critical Issues ({count})

**These issues must be resolved before using this app_spec with autonomous agents:**

{FOR EACH critical finding:}
**{finding_number}. {issue_title}**
- **Category:** {validation_check_category}
- **Details:** {issue_description}
- **Impact:** {impact_on_autonomous_agent}
- **Recommendation:** {how_to_fix}
- **Affected:** {features/sections/items}

{END FOR EACH}

---"

### 3. Present Warnings

**If findings.warnings is empty:**
Skip to step 4.

**If findings.warnings has items:**

Display: "## ⚠️  Warnings ({count})

**These issues should be addressed to improve app_spec quality:**

{FOR EACH warning:}
**{finding_number}. {issue_title}**
- **Category:** {validation_check_category}
- **Details:** {issue_description}
- **Impact:** {impact_on_quality}
- **Recommendation:** {how_to_improve}
- **Affected:** {features/sections/items}

{END FOR EACH}

---"

### 4. Present Passed Checks

Display: "## ✅ Checks Passed ({count})

**These quality dimensions passed validation:**

{FOR EACH passed check:}
- ✅ {check_name}: {brief_summary}

{END FOR EACH}

---"

### 5. Present Statistics

Display: "## 📊 Statistics

**Features:**
- Total count: {feature_count}
- Average requirements per feature: {avg}
- Average criteria per feature: {avg}

**Category Distribution:**
{FOR EACH category:}
- {category_name}: {count} features ({percentage}%)

**Verification Criteria:**
- Total criteria: {total_count}
- Functional: {count}
- Technical: {count}
- Integration: {count}

**Dependencies:**
- Features with dependencies: {count}
- Average dependencies per feature: {avg}

---"

### 6. Generate Recommendations

**Based on quality score, provide targeted recommendations:**

Display: "## 🎯 Recommendations

{IF score < 60:}
**Immediate Actions Required:**
1. Resolve all critical issues before proceeding
2. Review and address warnings systematically
3. Consider running EDIT mode to fix issues
4. Re-run validation after fixes

{IF score 60-74:}
**Improvements Recommended:**
1. Address critical issues if any
2. Review warnings and fix high-impact items
3. Consider running EDIT mode for targeted fixes
4. Re-validate after improvements

{IF score 75-89:}
**Minor Improvements:**
1. Review warnings and address if feasible
2. Consider fine-tuning verification criteria
3. Optional: Run EDIT mode for polish
4. App_spec is ready for autonomous agent use

{IF score >= 90:}
**Excellent Quality:**
1. No immediate action required
2. Ready for autonomous agent use
3. Consider this a quality benchmark for future specs

---"

### 7. Present Next Steps

Display: "## 🚀 Next Steps

**Based on your validation results:**

{IF score < 60:}
**1. Fix Critical Issues**
   Run EDIT mode workflow to address critical findings:
   - Load app_spec in EDIT mode
   - Fix reported issues systematically
   - Re-run validation to confirm fixes

**2. Consider Regeneration**
   If issues are extensive, consider regenerating from PRD:
   - Run CREATE mode with Clean Slate restart
   - Apply lessons learned from this validation

{IF score >= 60 AND score < 90:}
**1. Review Findings**
   Decide which warnings to address based on project priorities

**2. Apply Fixes (Optional)**
   Run EDIT mode to improve specific areas:
   - Enhance verification criteria quality
   - Adjust feature granularity if needed
   - Balance category distribution

**3. Proceed with Confidence**
   Current quality is acceptable for autonomous agent use

{IF score >= 90:}
**1. Proceed with Autonomous Agent**
   This app_spec is ready for use:
   - Initialize autonomous agent project
   - Generate feature_list.json from this spec
   - Begin implementation phase

**2. Use as Template**
   This high-quality spec can serve as a model for future projects

---"

### 8. Offer Export Options

Display: "## 💾 Export Options

Would you like to export this validation report?

**[M]arkdown** - Save report as markdown file
**[J]SON** - Save findings as JSON for programmatic use
**[N]o** - Display only (no export)

**Select: [M/J/N]**"

Wait for user selection.

#### IF M (Markdown):

"**Export path (or press Enter for default: validation-report-{date}.md):**"

Wait for path input.

Generate markdown report with all sections.

Write to file.

Display: "✅ Report exported to: {path}"

#### IF J (JSON):

"**Export path (or press Enter for default: validation-findings-{date}.json):**"

Wait for path input.

Generate JSON structure:
```json
{
  "validation_date": "{date}",
  "app_spec_path": "{path}",
  "project_name": "{name}",
  "quality_score": {score},
  "rating": "{rating}",
  "findings": {
    "critical": [{issue}, ...],
    "warnings": [{issue}, ...],
    "passed": [{check}, ...]
  },
  "statistics": {...},
  "recommendations": [...]
}
```

Write to file.

Display: "✅ Findings exported to: {path}"

#### IF N (No export):

Display: "Report displayed above. No file exported."

### 9. Present Workflow Completion

Display: "

---

✅ **Validation Workflow Complete**

**Summary:**
- Quality Score: {score}/100
- Critical Issues: {count}
- Warnings: {count}
- Checks Passed: {count}

{IF score < 60:}
⚠️  **Action Required:** Address critical issues before using this app_spec.

{IF score >= 60:}
✅ **Ready:** This app_spec can be used with autonomous agents.

**Thank you for using the app_spec validation workflow!**"

Exit workflow (no next step - this is final).

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS:

- Complete validation report presented
- All findings categorized and explained
- Recommendations provided based on score
- Next steps clearly communicated
- Export options offered
- Professional, actionable reporting
- Workflow exits cleanly

### ❌ SYSTEM FAILURE:

- Incomplete report (missing sections)
- Findings not explained clearly
- No recommendations provided
- Sugarcoating issues instead of honest reporting
- Not offering export options
- No next steps guidance

**Master Rule:** Report honestly, recommend actionably, guide user to next steps.
