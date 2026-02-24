---
name: 'step-07-output-summary'
description: 'Generate markdown report and display completion summary'
workflowComplete: true
finalStep: true
---

# STEP GOAL

Generate a comprehensive structured markdown report combining transcript content, metadata, and optional AI analysis. Save the report with organized file outputs. Display all output locations and provide guidance for next steps. This is the final step that completes the Create mode workflow.

---

# MANDATORY EXECUTION RULES

1. **READ COMPLETELY** - Read this entire step file before taking any action
2. **FOLLOW SEQUENCE** - Execute all numbered sections in order, never skip or reorder
3. **GENERATE REPORT** - Create complete markdown report using template
4. **NO MENU** - This is completion step, workflow ends after this

---

# MANDATORY SEQUENCE

## 1. Retrieve Context

**Get from workflow context:**
- `transcripts` array, `output_dir`, `transcription_date`
- `model`, `language`, `output_format`
- `analysis_results`, `analysis_types`, `skip_analysis`
- `file_count`

## 2. Load Report Template

Read template: `@{workflow-dir}/templates/transcript-report-template.md`
Store in `report_template`.

## 3. Generate Markdown Reports

**For each successful transcript:**

### 3A. Prepare Metadata

Extract: `filename`, `transcript_file`, `transcript_content`, `duration`, `language`
Calculate: word count, character count

### 3B. Populate Template Variables

**Frontmatter:**
- `{{audio_filename}}`, `{{transcription_date}}`, `{{audio_duration}}`
- `{{whisper_model}}`, `{{detected_language}}`, `{{selected_analyses}}`

**Transcript Section:**
- `{{full_transcript_text}}` → `transcript_content`

**AI Analysis Sections:**
If `skip_analysis == false` and `analysis_results` exists:
- `{{summary_content}}`, `{{action_items_content}}`, `{{themes_content}}`
- `{{key_quotes_content}}`, `{{custom_analysis_content}}`

If analysis not present: Remove sections or insert "Not generated"
If `skip_analysis == true`: Remove all AI Analysis sections

**Raw Files Section:**
List all generated files: `.txt`, `.srt`, `.vtt`, `.json`

### 3C. Generate Report Filename

```
report_filename = [audio_filename_without_extension] + ".md"
```

### 3D. Save Report File

Write using Write tool:
- File path: `[output_dir]/[report_filename]`
- Content: Populated template

Store `report_path` in `generated_reports` array.

### 3E. Repeat for All Transcripts

Continue until all successful transcripts have reports.

## 4. Generate Combined Report (If Multiple Files)

**If `file_count > 1` AND combined analysis:**
- Filename: `combined-analysis-[transcription_date].md`
- Content: Frontmatter + all transcripts + combined analysis
- Save to `output_dir`

## 5. Display Completion Summary

```
# 🎉 Transcription Complete!

## Summary
**Files Processed:** [file_count]
**Successful:** [successful_count]
**Failed:** [failed_count]

**Configuration:**
- Model: [model]
- Language: [language or "Auto-detected"]
- Output Formats: [output_format]
- AI Analysis: [analysis_types or "None"]

## Output Files
**Location:** [output_dir]
**Markdown Reports:** [count]
[List reports with sizes]

**Raw Transcript Files:** [count]
TXT files: [list with sizes]
[If applicable: SRT, VTT, JSON files with sizes]

**Total Output Size:** [du -sh output_dir]
```

## 6. Display File Tree

```
## Directory Structure
[Execute: tree "[output_dir]" -L 2 -h --du || ls -lhR "[output_dir]"]
```

## 7. Usage Guidance

```
## Using Your Transcripts

**Markdown Reports:**
- Read directly (formatted with metadata and analysis)
- Import to note apps (Obsidian, Notion, etc.)
- Edit: /bmad-bmm-transcribe-audio --mode edit

**Raw Files:**
- TXT: Plain text reading, word processors
- SRT/VTT: Video subtitles
- JSON: Programmatic access

**Editing:**
/bmad-bmm-transcribe-audio --mode edit

**Validating:**
/bmad-bmm-transcribe-audio --mode validate

**Workflow Modes:**
- Create (current): Generate new transcripts ✅
- Edit: Modify existing or add analysis
- Validate: Check quality and completeness
```

## 8. Success Message

```
## ✅ Workflow Complete

All transcripts generated and saved.

**Quick Access:**
cat "[first_report_path]"
ls -lh "[output_dir]"
cd "[output_dir]"

**Need Help?**
- Edit: /bmad-bmm-transcribe-audio --mode edit
- Validate: /bmad-bmm-transcribe-audio --mode validate
- New transcription: /bmad-bmm-transcribe-audio

Thank you for using the Audio Transcription Workflow! 🎙️→📝
```

## 9. Workflow Completion

Set workflow status: `COMPLETE`

Store final state:
- `generated_reports`, `output_dir`, `completion_timestamp`

**END WORKFLOW** - No next step.

---

**Step Type:** Final step (Completion)
**Next Step:** None (workflow complete)
**Critical Output:** Complete structured markdown reports with all content
