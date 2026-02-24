---
nextStepFile: './step-04b-display-validation-report.md'
---

# STEP GOAL

Generate comprehensive validation report summarizing all checks, overall score, identified issues, and recommendations. Prepare report structure for final display.

---

# MANDATORY EXECUTION RULES

1. **READ COMPLETELY** - Read entire step before acting
2. **FOLLOW SEQUENCE** - Execute all sections in order
3. **AUTO-PROCEED** - No user menu, continue to display

---

# MANDATORY SEQUENCE

## 1. Retrieve Context

Get from workflow context:
- `report_path`, `report_filename`, `report_metadata`
- `validation_checklist` (complete with all results)
- `total_validation_score` (0-100)
- All subscores (prerequisites, file_structure, report_quality, content_quality)
- `issues_found`, `recommendations`

## 2. Determine Overall Status

Based on `total_validation_score`:

```
if score >= 90:
    status = "VALID", icon = "✅"
    description = "Excellent - All checks passed"
elif score >= 75:
    status = "VALID", icon = "✅"
    description = "Good - Minor issues, transcription usable"
elif score >= 60:
    status = "NEEDS ATTENTION", icon = "⚠️"
    description = "Some problems, review recommended"
else:
    status = "FAILED", icon = "❌"
    description = "Significant issues, consider re-transcription"
```

Store: `validation_status`, `status_description`

## 3. Collect Issues and Recommendations

Scan `validation_checklist` for failures/warnings.

For each check that failed or partially passed:
- Add to `issues_found` with severity (High/Medium/Low)

Generate `recommendations` based on issues:
- Whisper not installed → "Install Whisper"
- FFmpeg not installed → "Install FFmpeg"
- Files missing → "Re-generate missing files"
- Frontmatter incomplete → "Update frontmatter"
- Sections missing → "Add missing sections"
- Transcript empty → "Re-transcribe audio"
- Analysis missing → "Regenerate analysis"
- Score < 90 → "Run Edit mode to improve"
- Score < 60 → "Re-run transcription from scratch"

## 4. Present Report Header

Generate header text:

```
# 📊 Transcription Validation Report

**Report:** [report_filename]
**Validated:** [current_timestamp]
**Path:** `[report_path]`

---

## Overall Assessment

**Status:** [icon] **[status]**
**Score:** [total_score]/100
**Assessment:** [status_description]

---
```

Store in: `report_header`

## 5. Generate Score Breakdown

Create score breakdown table:

```
## Score Breakdown

| Category | Score | Max | Percentage | Status |
|----------|-------|-----|------------|--------|
| Prerequisites | [score] | 20 | [%] | [icon] |
| File Structure | [score] | 20 | [%] | [icon] |
| Report Quality | [score] | 30 | [%] | [icon] |
| Content Quality | [score] | 30 | [%] | [icon] |
| **TOTAL** | **[score]** | **100** | **[%]** | **[icon]** |

**Rating Scale:**
- 90-100: Excellent ✅
- 75-89: Good ✅
- 60-74: Needs Attention ⚠️
- 0-59: Failed ❌

---
```

Store in: `score_breakdown_table`

## 6. Generate Detailed Check Results

Create detailed results for each category:

**Prerequisites:**
```
### Prerequisites (20 points)

**Whisper:** [✅/❌] [Installed/Not Found] - [10 or 0]/10
**FFmpeg:** [✅/❌] [Installed/Not Found] - [10 or 0]/10

---
```

**File Structure:**
```
### File Structure (20 points)

**Report:** ✅ Exists - 5/5
**Dated Directory:** [✅/❌] [status] - [5 or 0]/5
**Raw Files:** [✅/⚠️/❌] [status] - [5/2/0]/5
**Organization:** [✅/❌] [status] - [5 or 0]/5

---
```

**Report Quality:**
```
### Report Quality (30 points)

**Markdown Syntax:** [✅/❌] [status] - [10 or 0]/10
**Frontmatter:** [✅/⚠️/❌] [status] - [10/5/0]/10
**Sections:** [✅/⚠️/❌] [status] - [10/5/0]/10

---
```

**Content Quality:**
```
### Content Quality (30 points)

**Transcript:** [✅/⚠️/❌] [status], [word_count] words - [10/3/0]/10
**Word Count:** [✅/⚠️/?] [status] - [5 or 2]/5
**Analysis:** [✅/⚠️/❌/N/A] [status] - [10/5/0]/10
**Metadata:** [✅/⚠️/❌] [status] - [5/3/0]/5

---
```

Store in: `detailed_check_results`

## 7. Generate Issues Section

If issues exist:

```
## ⚠️ Issues Identified

[For each issue:]
**[X].** [Issue description]
   - Severity: [High/Medium/Low]
   - Impact: [Description]
   - Affected: [What is affected]

---
```

If no issues:

```
## ✅ No Issues Found

All validation checks passed successfully.

---
```

Store in: `issues_section`

## 8. Generate Recommendations Section

```
## 💡 Recommendations

[If recommendations exist:]
[For each recommendation:]
**[X].** [Recommendation text]
   - Action: [Specific action]
   - Priority: [High/Medium/Low]

[If no recommendations:]
**No improvements needed.** Transcription is excellent.

---
```

Store in: `recommendations_section`

## 9. Store Report Components

Store all generated report components in workflow context:
- `report_header`
- `score_breakdown_table`
- `detailed_check_results`
- `issues_section`
- `recommendations_section`
- `validation_status`
- `total_validation_score`

## 10. Load Next Step

```
Load and execute: @{workflow-dir}/step-04b-display-validation-report.md
```

Display: "Validation report generated. Displaying results..."

---

# SUCCESS METRICS

**Succeeds when:**
- ✅ Overall status determined
- ✅ Issues and recommendations collected
- ✅ Report components generated
- ✅ All components stored
- ✅ Next step loaded

---

**Step Type:** Report Generation (Auto-proceed)
**Output:** Complete report structure ready for display
