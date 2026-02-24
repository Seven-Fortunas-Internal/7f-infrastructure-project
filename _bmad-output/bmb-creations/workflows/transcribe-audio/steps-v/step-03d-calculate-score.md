---
nextStepFile: './step-04a-generate-validation-report.md'
---

# STEP GOAL

Calculate the total validation score from all subscores, display progress summary, and prepare for final validation report generation. This is the fourth and final validation check step.

---

# MANDATORY EXECUTION RULES

1. **READ COMPLETELY** - Read entire step before acting
2. **FOLLOW SEQUENCE** - Execute all sections in order
3. **AUTO-PROCEED** - No user menu, continue to report

---

# MANDATORY SEQUENCE

## 1. Retrieve Context

Get from workflow context:
- `validation_score` (cumulative from all checks)
- `prerequisites_subscore` (from step-02)
- `file_structure_subscore` (from step-03a)
- `report_quality_subscore` (from step-03b)
- `content_quality_subscore` (from step-03c)
- `validation_checklist` (complete with all results)

## 2. Calculate Total Score

Sum all subscores:

```
total_score = prerequisites_subscore
            + file_structure_subscore
            + report_quality_subscore
            + content_quality_subscore
```

This should equal `validation_score` (verification check).

Store: `total_validation_score`

## 3. Collect Issues

Scan `validation_checklist` for failures or partial passes.

For each check that failed or partially passed:
- Add to `issues_found` array with description
- Categorize severity (High/Medium/Low)

Example issues:
- High: Transcript empty, required files missing
- Medium: Frontmatter incomplete, some analysis missing
- Low: Word count questionable, metadata minor issues

## 4. Generate Recommendations

Based on issues found, create `recommendations` array:

```
if whisper not installed:
    recommendations.append("Install Whisper")
if ffmpeg not installed:
    recommendations.append("Install FFmpeg")
if dated_directory == false:
    recommendations.append("Move to dated directory")
if raw_files missing:
    recommendations.append("Re-generate missing files")
if frontmatter incomplete:
    recommendations.append("Update frontmatter")
if sections missing:
    recommendations.append("Add missing sections")
if transcript empty:
    recommendations.append("Re-transcribe audio")
if analysis missing:
    recommendations.append("Regenerate analysis")
if metadata inaccurate:
    recommendations.append("Correct metadata")
if score < 90:
    recommendations.append("Run Edit mode to improve")
if score < 60:
    recommendations.append("Re-run transcription from scratch")
```

## 5. Display Progress

```
---

## Validation Checks Complete

**Score Breakdown:**
- Prerequisites: [score]/20
- File Structure: [score]/20
- Report Quality: [score]/30
- Content Quality: [score]/30

**Total Score: [total]/100**

Generating final validation report...
```

## 6. Store Complete State

Update workflow context with final state:
- `total_validation_score` - Final score
- `validation_checklist` - Complete with all results
- `issues_found` - Array of identified issues
- `recommendations` - Array of improvement suggestions
- `all_subscores` - Object with all subscore values

## 7. Load Next Step

```
Load and execute: @{workflow-dir}/step-04a-generate-validation-report.md
```

Display: "All validation checks complete. Generating comprehensive report..."

---

# SUCCESS METRICS

**Succeeds when:**
- ✅ Total score calculated correctly
- ✅ Issues collected and categorized
- ✅ Recommendations generated
- ✅ Progress displayed
- ✅ Complete state stored
- ✅ Next step loaded

---

**Step Type:** Validation (Auto-proceed)
**Output:** Complete validation results ready for reporting
