---
name: 'step-04b-display-validation-report'
description: 'Display validation report and provide recommendations'
workflowComplete: true
finalStep: true
---

# STEP GOAL

Display the complete validation report with next steps guidance, available commands, metadata summary, and success message. Complete the Validate mode workflow.

---

# MANDATORY EXECUTION RULES

1. **READ COMPLETELY** - Read entire step before acting
2. **FOLLOW SEQUENCE** - Execute all sections in order
3. **NO MENU** - This is completion step, workflow ends

---

# MANDATORY SEQUENCE

## 1. Retrieve Report Components

Get from workflow context:
- `report_header`
- `score_breakdown_table`
- `detailed_check_results`
- `issues_section`
- `recommendations_section`
- `validation_status`
- `total_validation_score`
- `report_path`, `report_dir`, `report_metadata`

## 2. Display Complete Report

Present the full validation report:

```
[report_header]

[score_breakdown_table]

[detailed_check_results]

[issues_section]

[recommendations_section]
```

## 3. Display Next Steps

Based on `validation_status`:

**If VALID (score >= 75):**
```
## Next Steps

✅ **Your transcription is [excellent/good]!**
- [No action required / Minor improvements possible]
- [Files well-organized / Review recommendations when convenient]
- Ready for use in your workflow
```

**If NEEDS ATTENTION (score 60-74):**
```
## Next Steps

⚠️ **Review recommended.**
- Some quality issues identified
- Transcription may be usable depending on needs
- **Recommended:**
  - Review issues list above
  - Run Edit mode: `/bmad-bmm-transcribe-audio --mode edit`
  - Address high-priority recommendations
```

**If FAILED (score < 60):**
```
## Next Steps

❌ **Significant issues detected.**
- Quality below acceptable standards
- **Recommended:**
  1. Review all issues above
  2. Re-run transcription from scratch
  3. Verify audio file quality
  4. Check prerequisites (Whisper, FFmpeg)
  5. Use higher quality model if re-transcribing
```

## 4. Display Available Commands

```
---

## Available Actions

**Edit Transcription:**
```bash
/bmad-bmm-transcribe-audio --mode edit
```

**Create New Transcription:**
```bash
/bmad-bmm-transcribe-audio --mode create
```

**Validate Another Report:**
```bash
/bmad-bmm-transcribe-audio --mode validate
```

**View Report:**
```bash
cat "[report_path]"
```

**Access Directory:**
```bash
cd "[report_dir]"
```

---
```

## 5. Display Report Metadata

```
## Report Metadata

**Audio File:** [audio_file]
**Transcription Date:** [date]
**Duration:** [duration or "Not recorded"]
**Model:** [model]
**Language:** [language]
**Analysis:** [analysis_types or "None"]
**Edits:** [edit_count or "None"]

**File Statistics:**
- Report Size: [file_size]
- Word Count: [word_count]
- Character Count: [char_count]

---
```

## 6. Display Success Message

```
## ✅ Validation Complete

Comprehensive quality assessment performed.

**Summary:**
- Total Checks: [count_all]
- Passed: [count_passed]
- Failed: [count_failed]
- Warnings: [count_warnings]

**Overall:** [icon] **[status]** ([score]/100)

[Status-specific closing message]

---

Thank you for using Audio Transcription Workflow validation! 🎙️→📝→✅
```

## 7. Store Final State

Store in workflow context:
- `validation_report` - Complete report text
- `validation_status` - VALID/NEEDS ATTENTION/FAILED
- `total_validation_score` - Final score
- `completion_timestamp` - Current datetime
- `issues_count` - Number of issues
- `recommendations_count` - Number of recommendations

## 8. Mark Workflow Complete

Set workflow status: `COMPLETE`

**END WORKFLOW** - No next step to load.

---

# SUCCESS METRICS

**Succeeds when:**
- ✅ Complete report displayed
- ✅ Next steps guidance provided
- ✅ Available commands shown
- ✅ Metadata summary displayed
- ✅ Success message shown
- ✅ Final state stored
- ✅ Workflow marked COMPLETE

---

**Step Type:** Final step (Completion)
**Next Step:** None (workflow complete)
**Output:** Complete validation assessment delivered
