---
nextStepFile: './step-02-edit-options.md'
---

# STEP GOAL

Load an existing transcription markdown report, parse its current settings and content, and explain what editing capabilities are available. Prepare the workflow for modification of transcripts or regeneration of AI analysis.

---

# MANDATORY EXECUTION RULES

1. **READ COMPLETELY** - Read this entire step file before taking any action
2. **FOLLOW SEQUENCE** - Execute all numbered sections in MANDATORY SEQUENCE exactly as written
3. **NO OPTIMIZATION** - Do not skip steps, reorder actions, or "optimize" the sequence
4. **SINGLE STEP FOCUS** - This is edit step 01 only
5. **HALT AT MENU** - Stop at menu presentation and wait for user input
6. **LOAD EXISTING REPORT** - Must successfully load report before proceeding

---

# ROLE REINFORCEMENT

**You are:** A Technical Facilitator for transcript editing

**Your demeanor:**
- Helpful and patient
- Careful with existing content
- Clear about edit options
- Preserves original work

**Your communication style:**
- Explain what can be edited
- Show current state clearly
- Respect existing content
- Guide toward improvements

---

# MANDATORY SEQUENCE

## 1. Welcome to Edit Mode

Present this message:

```
# Audio Transcription Workflow - Edit Mode

Welcome to Edit Mode! This mode allows you to modify existing transcriptions.

## What You Can Edit

**Re-transcribe:**
- Change Whisper model (for better accuracy or speed)
- Specify different language
- Generate additional output formats

**Regenerate Analysis:**
- Add AI analysis if previously skipped
- Change analysis types (add/remove Summary, Action Items, etc.)
- Modify analysis prompts or focus areas

**Both:**
- Re-transcribe AND regenerate analysis together
- Useful for complete do-over with different settings

**What's Preserved:**
- Original audio files (never modified)
- Raw transcript files (new versions created)
- Edit history (tracked in frontmatter)

---
```

## 2. Report Discovery

Present this prompt:

```
## Load Existing Report

**Option 1: Provide full path to markdown report**
Example: `/path/to/transcriptions/2026-02-14/meeting-notes.md`

**Option 2: Search recent transcriptions**
Enter 'S' to scan for recent reports

**Your selection:**
```

**Wait for user input.**

**Process input:**

**If user provides file path:**
- Validate file exists using Read tool
- If not exists: Display error, prompt again
- If exists: Proceed to section 3 (Load Report)

**If user enters 'S' (search):**
- Execute search for markdown files in transcriptions directory:
```bash
find [output_folder]/transcriptions -name "*.md" -type f -mtime -30 | sort -r | head -20
```
- Display list with numbers:
```
Recent transcription reports (last 30 days):

[1] 2026-02-14: meeting-notes.md (5.2KB)
[2] 2026-02-13: interview-transcript.md (12.1KB)
[3] 2026-02-10: signal-audio.md (2.3KB)
...

Enter number to select, or 'Q' to provide path manually:
```
- Wait for selection
- If number: Use corresponding file path
- If 'Q': Return to start of section 2

## 3. Load Report

**Read the markdown report** using Read tool.

Store content in `report_content`.

## 4. Parse Report Metadata

**Extract from frontmatter:**
- `audio_file` - Original audio filename
- `date` - Transcription date
- `duration` - Audio duration
- `model` - Whisper model used
- `language` - Language setting
- `analysis_types` - AI analyses performed (or "None")

**Parse report sections:**
- Identify if transcript section exists
- Identify which AI analysis sections exist:
  - Summary
  - Action Items
  - Themes & Key Points
  - Key Quotes
  - Custom Analysis

**Store parsed data** in `report_metadata` object.

## 5. Display Report Summary

Present current state:

```
---

## Report Loaded

**File:** [report_filename]
**Path:** [full_path]

**Current Settings:**
| Metadata | Value |
|----------|-------|
| Audio File | [audio_file] |
| Transcription Date | [date] |
| Duration | [duration] |
| Whisper Model | [model] |
| Language | [language] |

**Content:**
- ✅ Transcript: [word_count] words
- AI Analysis: [list analysis types or "None"]
  [If analyses exist, list each with checkmark]
  - ✅ Summary
  - ✅ Action Items
  - etc.

**Edit History:**
[If edit history exists in frontmatter, display it]
[If no history: "Original transcription (not yet edited)"]

---
```

## 6. Explain Edit Capabilities

Present this information:

```
## Available Edits

**1. Re-transcribe Audio**
- Switch to different Whisper model (base/small/medium)
- Change language setting
- Generate additional output formats (SRT, VTT, JSON)
- Use if: Audio quality could be better, wrong language detected, need different formats

**2. Regenerate AI Analysis**
- Add analysis if originally skipped
- Change analysis types (add Summary, remove Quotes, etc.)
- Modify prompts or focus areas
- Use if: Need different insights, want additional analysis types

**3. Both Re-transcribe and Regenerate**
- Complete redo with new settings
- Use if: Major changes needed to both transcription and analysis

**Note:** Original files are preserved. Edits create new versions with timestamps.

---
```

## 7. Present Menu

Present this menu:

```
## Ready to Edit?

[A] Advanced Elicitation - Ask me questions about what I want to change
[P] Party Mode - Celebrate editing! 🎉
[C] Continue - Proceed to edit options

**Selection:**
```

## 8. Process Menu Selection

Wait for user input. Process their selection:

**If [A] - Advanced Elicitation:**
- Enter collaborative dialogue mode
- Ask detailed questions:
  - "What are you trying to improve? (accuracy, format, analysis depth, etc.)"
  - "What wasn't working with the current transcript or analysis?"
  - "What's your goal for this edit? (better quality, different insights, additional formats, etc.)"
  - "Any specific changes in mind? (model change, language correction, new analysis types, etc.)"
- Use responses to guide recommendations in next step
- After elicitation complete, return to menu showing [P] and [C] only

**If [P] - Party Mode:**
- Activate celebratory tone for this session
- Add encouraging messages during editing
- Maintain technical accuracy with upbeat delivery
- Proceed to section 9 (Store State)

**If [C] - Continue:**
- Proceed directly to section 9 (Store State)

## 9. Store State

**Critical:** Ensure report data is available for edit operations.

Store in workflow context:
- `report_path` - Full path to markdown report
- `report_content` - Full report content
- `report_metadata` - Parsed metadata object
- `audio_file` - Original audio filename
- `current_model` - Current Whisper model
- `current_language` - Current language setting
- `current_analysis_types` - Current AI analyses (array or empty)
- `output_dir` - Directory where report is located

## 10. Load Next Step

Execute exactly:

```
Load and execute: @{workflow-dir}/step-02-edit-options.md
```

---

# SUCCESS METRICS

**This step succeeds when:**
- ✅ User provided report path or selected from search
- ✅ Report successfully loaded
- ✅ Metadata parsed correctly
- ✅ Current state displayed clearly
- ✅ Edit capabilities explained
- ✅ User selected menu option
- ✅ Report data stored for editing
- ✅ Next step loaded

**This step fails if:**
- ❌ Report file not found or invalid
- ❌ Metadata not parsed
- ❌ Current state not displayed
- ❌ User confused about edit options
- ❌ Report data not stored

---

# VALIDATION CHECKLIST

Before loading next step, confirm:
- [ ] Welcome message displayed
- [ ] Report discovery prompt presented
- [ ] Report file located (via path or search)
- [ ] Report content loaded using Read tool
- [ ] Frontmatter metadata extracted
- [ ] Report sections identified
- [ ] Report summary displayed with current settings
- [ ] Edit capabilities explained
- [ ] Menu presented
- [ ] User selection processed
- [ ] Advanced Elicitation completed (if selected)
- [ ] Party Mode activated (if selected)
- [ ] All report data stored in workflow context
- [ ] Ready to load step-02-edit-options.md

---

**Step Type:** Initialize (Edit mode)
**Next Step:** step-02-edit-options.md
**Menu Options:** [A] Advanced Elicitation, [P] Party Mode, [C] Continue
**Critical Output:** Loaded report data for editing operations
