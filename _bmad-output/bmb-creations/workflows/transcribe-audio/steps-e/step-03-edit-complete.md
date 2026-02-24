---
name: 'step-03-edit-complete'
description: 'Display edit summary and provide next steps guidance'
workflowComplete: true
finalStep: true
---

# STEP GOAL

Generate and save the updated markdown report with all edits applied, display a comprehensive summary of changes made, show updated file locations, and provide guidance for next steps. This is the final step that completes the Edit mode workflow.

---

# MANDATORY EXECUTION RULES

1. **READ COMPLETELY** - Read this entire step file before taking any action
2. **FOLLOW SEQUENCE** - Execute all numbered sections in order, never skip or reorder
3. **PRESERVE HISTORY** - Track all edits in frontmatter
4. **NO MENU** - This is completion step, workflow ends after this

---

# MANDATORY SEQUENCE

## 1. Retrieve Context

**Get from workflow context:**
- `report_path`, `report_content`, `report_metadata`
- `new_transcript_content`, `new_analysis_results`
- `new_model`, `new_language`, `new_analysis_types`
- `edit_timestamp`, `changes_summary`, `output_dir`

## 2. Load Report Template

Read template: `@{workflow-dir}/templates/transcript-report-template.md`
Store in `report_template`.

## 3. Prepare Updated Metadata

Build updated frontmatter with edit history:

```yaml
---
audio_file: [original audio_file]
date: [original date]
duration: [original or updated duration]
model: [new_model or original]
language: [new_language or original]
analysis_types: [new_analysis_types or original]
edit_history:
  - timestamp: [edit_timestamp]
    changes: [brief summary]
    previous_model: [original model if changed]
    previous_analysis: [original analyses if changed]
---
```

## 4. Generate Updated Report

**Populate template variables:**

**Frontmatter & Metadata:**
- `{{audio_filename}}`, `{{transcription_date}}`, `{{audio_duration}}`
- `{{whisper_model}}`, `{{detected_language}}`, `{{selected_analyses}}`

**Transcript Section:**
- `{{full_transcript_text}}` → new_transcript_content OR original

**AI Analysis Sections:**
Use `new_analysis_results` if regenerated, otherwise preserve original.
- `{{summary_content}}`, `{{action_items_content}}`, `{{themes_content}}`
- `{{key_quotes_content}}`, `{{custom_analysis_content}}`

Remove sections for analyses not in new_analysis_types.

**Raw Files Section:**
List all current transcript files (including newly generated).

## 5. Create Backup and Save

**Backup original:**
```bash
cp "[report_path]" "[report_path].backup.[timestamp]"
```

**Write updated report** using Write tool:
- File path: `report_path` (overwrite original)
- Content: Fully populated template

## 6. Display Changes Summary

```
# ✅ Edit Complete!

## Changes Summary
**Report:** [report_filename]
**Edited:** [edit_timestamp]
**Backup:** [backup_path]

## What Changed

**Transcription:**
[If re-transcribed: Show model/language/word count changes]
[If unchanged: "○ Transcript unchanged"]

**AI Analysis:**
[If regenerated: Show added/removed/regenerated types]
[If unchanged: "○ Analysis unchanged"]

**Files:**
[List new files: .txt, .srt, .vtt, .json with sizes]
[Show updated report and backup with sizes]
```

## 7. File Locations and Structure

```
## File Locations
**Updated Report:** [report_path]
**Original Backup:** [backup_path]
**Output Directory:** [output_dir]

## All Files
```

Execute:
```bash
ls -lh "[output_dir]" | grep -v "^total" | awk '{print "- " $9 " (" $5 ")"}'
tree "[output_dir]" -L 2 -h --du || ls -lhR "[output_dir]"
```

## 8. Before/After Comparison

**If transcript re-transcribed:**
Show first 200 words of original vs updated, highlight improvements.

## 9. Usage Guidance

```
## Next Steps

**View Updated Report:**
cat "[report_path]"

**Compare with Original:**
diff "[backup_path]" "[report_path]"

**Further Editing:**
/bmad-bmm-transcribe-audio --mode edit

**Validation:**
/bmad-bmm-transcribe-audio --mode validate

**Restore Original:**
cp "[backup_path]" "[report_path]"
```

## 10. Success Message

```
## ✅ Edit Workflow Complete

Your transcript has been successfully updated!

**Summary:**
- ✅ Changes applied and saved
- ✅ Original backed up
- ✅ Edit history tracked in frontmatter
- ✅ All files organized and accessible

Thank you for using the Audio Transcription Workflow! 🎙️→📝
```

## 11. Workflow Completion

Set workflow status: `COMPLETE`

Store final state:
- `updated_report_path`, `backup_path`
- `completion_timestamp`, `edit_summary`

**END WORKFLOW** - No next step.

---

**Step Type:** Final step (Edit completion)
**Next Step:** None (workflow complete)
**Critical Output:** Updated markdown report with edit history preserved
