---
workflowName: transcribe-audio
stepsCompleted: ['step-01-discovery', 'step-02-classification', 'step-03-requirements', 'step-04-tools', 'step-05-plan-review', 'step-06-design', 'step-07-foundation']
created: 2026-02-14
status: FOUNDATION_COMPLETE
approvedDate: 2026-02-14
designCompletedDate: 2026-02-14
foundationCompletedDate: 2026-02-14
---

# Workflow Creation Plan

## Discovery Notes

**User's Vision:**
Create a general-purpose audio transcription workflow using OpenAI Whisper (locally installed) that converts audio files to text transcripts. The workflow should handle both single and multiple audio files, with optional AI-powered analysis (summaries, action items, themes, key quotes) after transcription. Primary use case is transcribing Signal audio feedback (AAC format) for presentation updates, but designed as a portable utility for any audio transcription needs.

**Who It's For:**
- Primary: Jorge and team members transcribing audio feedback, meeting recordings, voice memos
- Secondary: Any BMAD project user needing audio transcription capabilities
- Audience: Technical users comfortable with command-line tools

**What It Produces:**
- Text transcripts (.txt, .srt, .vtt, .json formats)
- Optional AI analysis reports:
  - Summaries (configurable: type, duration, format, focus)
  - Action items (todos, decisions, next steps)
  - Themes & key points (main topics)
  - Key quotes (memorable/important quotes)
  - Custom analysis (user-defined prompts)
- Organized output in dated directories

**Key Insights:**

1. **Technical Validation Completed:**
   - Whisper installed at `/home/ladmin/.local/bin/whisper`
   - FFmpeg dependency required (now installed)
   - Signal AAC audio files tested successfully
   - Base model provides good quality, fast transcription

2. **Workflow Requirements:**
   - Prerequisites check (Whisper + FFmpeg validation)
   - Single file, multiple files, or directory input modes
   - Model selection (base/small/medium for quality/speed tradeoff)
   - Language selection (auto-detect or explicit)
   - Output format options (txt, srt, vtt, json, all)

3. **AI Analysis Design:**
   - Multi-select menu (Option B chosen)
   - User selects multiple analysis types upfront
   - Process all selections sequentially
   - Each analysis type configurable
   - Skip analysis option for transcription-only

4. **Portability Requirements:**
   - Package as BMM module workflow (most universal)
   - Category: "utilities" or "anytime"
   - Deploy to:
     - seven-fortunas-brain (version control)
     - gd-nc project (immediate use)
     - Any future BMAD project
   - No external dependencies beyond Whisper + FFmpeg

5. **Scope (V1):**
   - IN: Prerequisites validation, transcription, AI analysis, output management
   - OUT: Integration with other workflows, speaker diarization, calendar integration

6. **Output Organization:**
   - Transcripts: `{output_folder}/transcriptions/YYYY-MM-DD/`
   - Analysis: `{output_folder}/transcriptions/YYYY-MM-DD/analysis/`
   - Preserve audio filenames in outputs

---

## Classification Decisions

**Workflow Name:** transcribe-audio
**Target Path:** `_bmad/bmm/workflows/utilities/transcribe-audio/`

**4 Key Decisions:**
1. **Document Output:** Document-Producing (markdown report + raw transcript files)
2. **Module Affiliation:** BMM (Business Method Module)
3. **Session Type:** Single-Session (5-15 minutes typical)
4. **Lifecycle Support:** Tri-Modal (Create + Edit + Validate)

**Structure Implications:**
- Needs `steps-c/` (create mode), `steps-e/` (edit mode), `steps-v/` (validate mode)
- Single-session means standard `step-01-init.md` (no continuation logic)
- Document-producing means markdown output template needed
- BMM module means access to `planning_artifacts` and other BMM variables
- Tri-modal means each mode is self-contained with shared `data/` folder

**File Structure:**
```
transcribe-audio/
├── workflow.md                  # Entry point
├── data/                        # Shared data (prerequisites, models, formats)
├── templates/
│   └── transcript-report.md     # Markdown output template
├── steps-c/                     # Create mode
│   ├── step-01-init.md
│   ├── step-02-validate-prerequisites.md
│   ├── step-03-input-discovery.md
│   ├── step-04-configuration.md
│   ├── step-05-transcription.md
│   ├── step-06-ai-analysis.md
│   └── step-07-output-summary.md
├── steps-e/                     # Edit mode
│   ├── step-01-edit-init.md
│   ├── step-02-edit-options.md
│   └── step-03-edit-complete.md
└── steps-v/                     # Validate mode
    ├── step-01-validate-init.md
    ├── step-02-validate-prerequisites.md
    ├── step-03-validate-outputs.md
    └── step-04-validate-report.md
```

---

## Requirements

**Flow Structure:**
- Pattern: Linear with branching
- Phases:
  1. Prerequisites validation
  2. Input discovery (branch: single/multiple/directory)
  3. Configuration (model, language, formats)
  4. Transcription execution
  5. AI analysis (branch: multi-select options)
  6. Output summary and completion
- Estimated steps: 7 for create mode, 3 for edit mode, 4 for validate mode

**User Interaction:**
- Style: Guided/Mixed (structured menus with helpful guidance)
- Decision points:
  - Input mode selection (single/multiple/directory)
  - Model selection (base/small/medium)
  - Language selection (auto-detect or specify)
  - Output formats (txt, srt, vtt, json, all)
  - AI analysis types (multi-select: summary, action items, themes, quotes, custom)
- Checkpoint frequency: After each major phase (transcription complete, analysis complete)

**Inputs Required:**
- Required:
  - Audio file path(s) - single file, multiple files, or directory path
  - Whisper installation (prerequisite validation)
  - FFmpeg installation (prerequisite validation)
- Optional:
  - Model preference (default: small)
  - Language code (default: auto-detect)
  - Output format preference (default: txt + markdown)
  - Analysis preferences (selected during workflow)
- Prerequisites:
  - OpenAI Whisper installed at `/home/ladmin/.local/bin/whisper`
  - FFmpeg installed and in PATH

**Output Specifications:**
- Type: Document (markdown report + raw transcript files)
- Format: Structured markdown with clear sections
- Sections:
  - Frontmatter (metadata: audio file, date, duration, model, language, analysis types)
  - Metadata summary
  - Full transcript
  - AI Analysis (conditional sections based on selections)
  - Raw files reference
- Frequency: One markdown report per audio file (or combined for batch)
- Raw files: txt, srt, vtt, json as requested
- Organization: `{output_folder}/transcriptions/YYYY-MM-DD/`

**Success Criteria:**
- Transcription: Audio files successfully processed, transcripts generated without errors, quality is readable
- AI Analysis: Selected analyses completed and included in report, results are relevant and actionable
- Output: Markdown report created with all sections, files organized in dated directories, paths displayed to user
- Edit Mode: Can regenerate with different settings, can re-run analysis, can update reports
- Validate Mode: Prerequisites verified, audio formats supported, output quality checked

**Instruction Style:**
- Overall: Mixed
- Prescriptive for: Configuration menus (input mode, model selection, format options, analysis multi-select) - ensures consistency
- Intent-based for: User guidance, error handling, output presentation - allows flexibility
- Notes: Technical workflows benefit from structured choices while maintaining conversational helpfulness

---

## Tools Configuration

**Core BMAD Tools:**
- **Party Mode:** Excluded - Not needed for technical utility workflow
- **Advanced Elicitation:** Excluded - Straightforward inputs/outputs, no complex elicitation needed
- **Brainstorming:** Excluded - Execution workflow, not ideation

**LLM Features:**
- **Web-Browsing:** Excluded - Local processing only, no web data needed
- **File I/O:** ✅ **Included** - Required for all phases
  - Integration points:
    - Phase 2: Validate audio file paths
    - Phase 4: Read audio files, write transcript files (via Bash calling Whisper)
    - Phase 5: Read transcripts, generate analysis
    - Phase 6: Create markdown reports, organize output files
- **Sub-Agents:** Excluded - Sequential processing sufficient for V1
- **Sub-Processes:** Excluded - Adds complexity, not needed for V1

**Memory:**
- Type: Single-session (no complex memory needed)
- Tracking: Basic execution state during workflow run
- No continuation logic required

**External Integrations:**
- **Whisper (OpenAI):** Required - Speech-to-text engine
  - Location: `/home/ladmin/.local/bin/whisper`
  - Validation: Phase 1 prerequisites check
  - Usage: Phase 4 transcription execution
- **FFmpeg:** Required - Audio processing dependency for Whisper
  - Validation: Phase 1 prerequisites check
  - Usage: Whisper backend dependency

**Installation Requirements:**
- Whisper: ✅ Already installed
- FFmpeg: ✅ Already installed
- File I/O: ✅ Built-in BMAD capability
- No additional installations needed

---

## Workflow Design

### Create Mode (steps-c/) - 7 Steps

**Step 01: Initialize**
- Goal: Welcome user, explain workflow capabilities and flow
- Type: Init step (single-session, no continuation logic)
- Menu: Standard [A] Advanced Elicitation [P] Party Mode [C] Continue
- Actions: Set context, explain what the workflow will do
- Output: Initialize workflow context (optionally create output document with frontmatter)

**Step 02: Validate Prerequisites**
- Goal: Verify Whisper and FFmpeg are installed and accessible
- Type: Validation step (autonomous execution)
- Actions:
  - Test `whisper --version` command
  - Test `ffmpeg -version` command
  - Display installation paths and versions
  - If either missing: Display installation instructions and HALT
- Menu: Auto-proceed if pass, halt with instructions if fail
- Output: Prerequisites validation report (PASS/FAIL)

**Step 03: Input Discovery**
- Goal: Determine input mode and gather audio file paths
- Type: Branch step (prescriptive menu)
- Menu: Input mode selection
  - [S] Single audio file
  - [M] Multiple audio files (list)
  - [D] Directory scan (recursively find audio files)
- Actions:
  - Prompt for file path(s) based on selection
  - Validate files exist and are readable
  - Detect audio format (AAC, MP3, M4A, WAV, etc.)
- Menu: [C] Continue after validation
- Output: List of validated audio file paths stored in state

**Step 04: Configuration**
- Goal: Configure transcription settings (model, language, output formats)
- Type: Middle step (multiple prescriptive menus)
- Menus:
  1. Model selection: [B]ase (fast) / [S]mall (balanced, default) / [M]edium (accurate)
  2. Language: [A]uto-detect (default) / [E]nglish / [S]panish / [O]ther (prompt for code)
  3. Output formats: [T]xt only (default) / [S]rt / [V]tt / [J]son / [A]ll formats
- Actions: Store configuration choices in state
- Menu: [C] Continue after configuration
- Output: Configuration summary displayed to user

**Step 05: Transcription Execution**
- Goal: Execute Whisper transcription on audio files (autonomous processing)
- Type: Middle step (execution, autonomous)
- Actions:
  - For each audio file:
    - Display "Transcribing [filename]..." progress message
    - Execute Whisper via Bash: `whisper [file] --model [model] --language [lang] --output_dir [dir] --output_format [formats]`
    - Capture output and any errors
  - Save raw transcript files to `{output_folder}/transcriptions/YYYY-MM-DD/`
  - Parse transcript content for markdown report
- Menu: Auto-proceed (no user input during transcription)
- Output: Raw transcript files (.txt, .srt, .vtt, .json as configured)

**Step 06: AI Analysis (Optional)**
- Goal: Offer AI-powered analysis of transcripts
- Type: Branch step (multi-select menu)
- Menu: Multi-select analysis options (user can select multiple):
  - [ ] Summary (with sub-prompts: length preference, focus areas)
  - [ ] Action Items (extract todos, decisions, next steps)
  - [ ] Themes & Key Points (identify main topics)
  - [ ] Key Quotes (extract memorable/important quotes)
  - [ ] Custom Analysis (user provides custom prompt)
  - [ ] Skip Analysis (transcription only)
- Actions:
  - For each selected analysis type:
    - Read transcript content
    - Generate analysis using Claude
    - Append analysis section to markdown report
  - If "Skip Analysis" selected: Proceed without analysis
- Menu: [C] Continue after analysis complete
- Output: AI analysis sections added to markdown report

**Step 07: Output Summary & Completion**
- Goal: Finalize markdown report, display output paths, provide next steps
- Type: Final step
- Actions:
  - Generate structured markdown report with:
    - Frontmatter (metadata: audio file, date, duration, model, language, analysis types)
    - Metadata section
    - Full transcript
    - AI Analysis sections (if generated)
    - Raw files reference
  - Save report to `{output_folder}/transcriptions/YYYY-MM-DD/[filename].md`
  - Display output file paths (markdown report + raw transcripts)
  - Offer guidance: "To edit: run Edit mode. To validate: run Validate mode."
- Menu: None (workflow complete)
- Output: Complete structured markdown report + organized file structure

---

### Edit Mode (steps-e/) - 3 Steps

**Step 01-edit: Edit Initialize**
- Goal: Load existing transcript/report and explain edit capabilities
- Type: Init step for edit mode
- Actions:
  - Prompt for markdown report path (or discover from recent transcriptions)
  - Load existing markdown report
  - Parse current settings (model, language, analysis types)
  - Display current transcript metadata
- Menu: Standard [A] [P] [C]
- Output: Current report summary displayed

**Step 02-edit: Edit Options**
- Goal: Present edit options and execute requested changes
- Type: Branch step (prescriptive menu)
- Menu: Edit action selection
  - [R] Re-transcribe with different settings (change model, language, formats)
  - [A] Regenerate AI analysis (change analysis types or prompts)
  - [B] Both (re-transcribe AND regenerate analysis)
- Actions:
  - Based on selection, gather new configuration (reuse Step 04/06 patterns)
  - Re-run Whisper transcription if [R] or [B]
  - Re-run AI analysis if [A] or [B]
  - Update markdown report with new content
  - Preserve version history (append edit timestamp to frontmatter)
- Menu: [C] Continue after processing complete
- Output: Updated transcript and/or analysis

**Step 03-edit: Edit Complete**
- Goal: Save updated report and display changes summary
- Type: Final step
- Actions:
  - Save updated markdown report (overwrite or version)
  - Display summary of changes made
  - Show updated file paths
- Menu: None (edit complete)
- Output: Updated markdown report with edit history

---

### Validate Mode (steps-v/) - 4 Steps

**Step 01-validate: Validate Initialize**
- Goal: Explain validation process and load target for validation
- Type: Init step for validate mode
- Actions:
  - Prompt for markdown report path (or discover from recent transcriptions)
  - Load target markdown report
  - Initialize validation checklist
  - Explain validation criteria
- Menu: Standard [A] [P] [C]
- Output: Validation checklist initialized

**Step 02-validate: Prerequisites Check**
- Goal: Verify prerequisites (Whisper + FFmpeg) are still installed
- Type: Validation step (autonomous)
- Actions:
  - Test `whisper --version` command
  - Test `ffmpeg -version` command
  - Compare versions with original transcription metadata
  - Report installation status
- Menu: Auto-proceed
- Output: Prerequisites validation results (PASS/FAIL with details)

**Step 03-validate: Output Quality Check**
- Goal: Validate transcript quality, completeness, and structure
- Type: Validation step (autonomous checks)
- Checks:
  - ✓ Markdown report exists and is readable
  - ✓ Frontmatter is valid YAML with required fields
  - ✓ Transcript section is present and not empty
  - ✓ Audio file metadata is accurate (filename, duration, model)
  - ✓ Analysis sections present if configured in frontmatter
  - ✓ Raw transcript files exist and match configured formats
  - ✓ File organization follows standard structure (dated directories)
- Actions: Run each check, score results
- Menu: Auto-proceed
- Output: Quality validation results with individual check scores

**Step 04-validate: Validation Report**
- Goal: Present comprehensive validation report with overall assessment
- Type: Final step
- Output: Validation summary including:
  - Overall Score: X/100 (weighted average of all checks)
  - Prerequisites: PASS/FAIL
  - Quality Checks: PASS/FAIL per check
  - Issues Found: List of any problems (if any)
  - Recommendations: Suggested improvements
  - Status: VALID / NEEDS ATTENTION / FAILED
- Menu: None (validation complete)

---

### Design Aspects

**Continuation Support:** ❌ Not needed
- Single-session workflow (5-15 minutes typical)
- No complex state requiring persistence between sessions
- No step-01b-continue.md needed

**Interaction Patterns:**
- Prescriptive menus for configuration choices (Steps 03, 04, 06, Edit-02)
- Intent-based guidance for explanations and help
- Auto-proceed for autonomous execution (Steps 02, 05, Validate checks)
- Standard [A] [P] [C] menu for major transition points

**Data Flow:**
1. Input Discovery → File paths stored in state
2. Configuration → Settings stored in state
3. Transcription → Raw files written to disk, content loaded to state
4. AI Analysis → Analysis results appended to markdown
5. Output → Complete markdown report written with all sections
6. Edit → Load existing report, modify, save updated version
7. Validate → Load existing report, run checks, generate validation report

**File Structure:**
```
transcribe-audio/
├── workflow.md                          # Entry point with mode routing
├── data/                                # Shared reference data
│   ├── whisper-models.md                # Model descriptions (base/small/medium)
│   ├── language-codes.md                # Supported language codes
│   └── output-formats.md                # Format descriptions (txt/srt/vtt/json)
├── templates/
│   └── transcript-report-template.md    # Markdown output template
├── steps-c/                             # Create mode (7 steps)
├── steps-e/                             # Edit mode (3 steps)
└── steps-v/                             # Validate mode (4 steps)
```

**AI Role & Persona:**
- Expertise: Technical facilitator with audio/video processing knowledge
- Communication: Clear, concise, helpful without being verbose
- Tone: Professional but friendly, supportive
- Style: Mixed - Prescriptive menus for choices, intent-based for guidance and error handling

**Validation & Error Handling:**
- Prerequisites validation in Step 02 (create) and Step 02 (validate)
- File path validation in Step 03 (input discovery)
- Whisper execution error handling in Step 05 (catch errors, display helpful messages)
- Format validation in Validate mode
- Quality scoring in Validate mode (0-100 scale)

**Subprocess Optimization:**
- Not applicable for V1 (Whisper handles transcription, Claude handles analysis)
- Could optimize in V2 with parallel transcription for multiple files (Pattern 4)

**Special Features:**
- Multi-select AI analysis menu (Step 06)
- Tri-modal architecture (Create/Edit/Validate)
- Structured markdown output with conditional sections
- Dated directory organization
- Version history tracking in Edit mode
- Comprehensive validation scoring

---

## Foundation Build Complete

**Created on:** 2026-02-14

**Folder Structure:**
```
transcribe-audio/
├── workflow.md                          ✅ Created
├── data/                                ✅ Created
│   ├── whisper-models.md                ✅ Created
│   ├── language-codes.md                ✅ Created
│   └── output-formats.md                ✅ Created
├── templates/                           ✅ Created
│   └── transcript-report-template.md    ✅ Created
├── steps-c/                             ✅ Created (empty, ready for step files)
├── steps-e/                             ✅ Created (empty, ready for step files)
└── steps-v/                             ✅ Created (empty, ready for step files)
```

**Configuration:**
- Workflow name: transcribe-audio
- Continuable: No (single-session)
- Document output: Yes (structured markdown)
- Mode: Tri-modal (Create/Edit/Validate)
- Module: BMM (Business Method Module)
- Target deployment: `_bmad/bmm/workflows/utilities/transcribe-audio/`

**Files Created:**
1. **workflow.md** - Main entry point with tri-modal routing
   - Create mode → `./steps-c/step-01-init.md`
   - Edit mode → `./steps-e/step-01-edit-init.md`
   - Validate mode → `./steps-v/step-01-validate-init.md`

2. **templates/transcript-report-template.md** - Structured markdown output template
   - Frontmatter with metadata
   - Sections: Metadata, Transcript, AI Analysis, Raw Files

3. **data/whisper-models.md** - Model selection reference (base/small/medium)
4. **data/language-codes.md** - Language options and codes
5. **data/output-formats.md** - Format descriptions (txt/srt/vtt/json/all)

**Next Steps:**
- Step 8: Build step-01-init.md (Create mode initialization)
- Step 9: Build remaining Create mode steps (2-7)
- Step 9: Build Edit mode steps (1-3)
- Step 9: Build Validate mode steps (1-4)
- Step 10: Confirmation and completion
