---
nextStepFile: './step-02-validate-prerequisites.md'
---

# STEP GOAL

Load an existing transcription markdown report, explain the validation process and criteria, initialize a validation checklist, and prepare the workflow to perform comprehensive quality checks on the transcription and its outputs.

---

# MANDATORY EXECUTION RULES

1. **READ COMPLETELY** - Read this entire step file before taking any action
2. **FOLLOW SEQUENCE** - Execute all numbered sections in order, never skip or reorder
3. **HALT AT MENU** - Stop at menu presentation and wait for user input
4. **LOAD TARGET REPORT** - Must successfully load report before proceeding

---

# MANDATORY SEQUENCE

## 1. Welcome to Validate Mode

```
# Audio Transcription Workflow - Validate Mode

Welcome! This mode performs comprehensive quality checks on existing transcriptions.

## What Validation Checks

**Prerequisites:** Whisper/FFmpeg installed, tool versions documented
**File Structure:** All expected files exist, correct directory structure
**Report Quality:** Valid markdown, complete frontmatter, required sections
**Content Completeness:** Non-empty transcript, analysis present (if configured), file sizes reasonable
**Overall Assessment:** Score (0-100), status, issues, recommendations
```

## 2. Explain Validation Criteria

```
## Validation Criteria

**Scoring:**
- 90-100: Excellent (no issues)
- 75-89: Good (minor issues)
- 60-74: Needs Attention (review recommended)
- <60: Failed (significant issues)

**Checks (100 points):**
1. Prerequisites (20): Whisper 10, FFmpeg 10
2. File Structure (20): Report 5, Directory 5, Raw files 5, Organization 5
3. Report Quality (30): Markdown 10, Frontmatter 10, Sections 10
4. Content Quality (30): Non-empty 10, Word count 5, Analysis 10, Metadata 5
```

## 3. Report Discovery

```
## Load Report for Validation

**Option 1:** Provide full path
Example: /path/to/transcriptions/2026-02-14/meeting-notes.md

**Option 2:** Enter 'S' to scan recent reports

**Your selection:**
```

**Wait for user input.**

**If file path:** Validate exists, proceed to section 4
**If 'S' (search):**
```bash
find [output_folder]/transcriptions -name "*.md" -type f -mtime -30 | sort -r | head -20
```
Display numbered list, wait for selection or 'Q' to provide path manually.

## 4. Load Report

Read markdown report using Read tool.
Store in `report_content`.

Parse path info: `report_filename`, `report_dir`

## 5. Parse Report Metadata

**Extract from frontmatter:**
`audio_file`, `date`, `duration`, `model`, `language`, `analysis_types`, `edit_history`

**Parse report sections:**
Identify: Metadata, Transcript, AI Analysis (Summary/Actions/Themes/Quotes/Custom), Raw Files

Store in `report_metadata` object.

**Calculate metrics:**
Word count, character count, analysis section count, file size
Store in `content_metrics` object.

## 6. Initialize Validation Checklist

```yaml
validation_checklist:
  prerequisites:
    whisper_installed: null
    ffmpeg_installed: null
  file_structure:
    report_exists: true
    dated_directory: null
    raw_files_exist: null
    organization_correct: null
  report_quality:
    valid_markdown: null
    complete_frontmatter: null
    required_sections: null
  content_quality:
    transcript_not_empty: null
    reasonable_word_count: null
    analysis_present: null
    metadata_accurate: null
```

## 7. Display Report Summary

```
## Report Loaded for Validation

**File:** [report_filename]
**Path:** [full_path]
**Size:** [file_size]

**Metadata:**
| Field | Value |
|-------|-------|
| Audio File | [audio_file] |
| Date | [date] |
| Duration | [duration] |
| Model | [model] |
| Language | [language] |
| Analysis Types | [analysis_types or "None"] |

**Content Metrics:**
- Transcript: [word_count] words, [char_count] characters
- Analysis Sections: [count]
- Edit History: [count or "None"]

**Status:** Ready to begin
```

## 8. Present Menu

```
## Ready to Validate?

[A] Advanced Elicitation - Questions about specific concerns
[P] Party Mode - Celebrate quality assurance! 🎉
[C] Continue - Proceed to validation checks

**Selection:**
```

## 9. Process Menu Selection

Wait for input.

**[A] - Advanced Elicitation:**
Ask questions about concerns, purpose, known issues, useful validation criteria.
Use responses to emphasize checks or add custom criteria.
Return to menu with [P] and [C] only.

**[P] - Party Mode:**
Activate celebratory tone, encouraging messages, celebrate passing checks.
Proceed to section 10.

**[C] - Continue:**
Proceed to section 10.

## 10. Store State

Store in workflow context:
- `report_path`, `report_content`, `report_metadata`
- `content_metrics`, `report_filename`, `report_dir`
- `validation_checklist`, `validation_score` (init to 0)

## 11. Load Next Step

```
Load and execute: @{workflow-dir}/step-02-validate-prerequisites.md
```

---

**Step Type:** Initialize (Validate mode)
**Next Step:** step-02-validate-prerequisites.md
**Menu Options:** [A] Advanced Elicitation, [P] Party Mode, [C] Continue
**Critical Output:** Loaded report data and initialized validation checklist
