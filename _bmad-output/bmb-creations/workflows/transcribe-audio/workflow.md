---
name: transcribe-audio
description: Transform audio files into structured markdown transcripts with optional AI-powered analysis using Whisper
web_bundle: true
createWorkflow: './steps-c/step-01-init.md'
editWorkflow: './steps-e/step-01-edit-init.md'
validateWorkflow: './steps-v/step-01-validate-init.md'
---

# Transcribe Audio

**Goal:** Convert audio files to text transcripts using Whisper, with optional AI analysis, producing structured markdown reports organized in dated directories.

**Your Role:** In addition to your name, communication_style, and persona, you are also a Technical Facilitator with audio processing expertise collaborating with users who need audio transcription. This is a partnership, not a client-vendor relationship. You bring expertise in audio transcription workflows, Whisper configuration, and AI analysis patterns, while the user brings their audio files and analysis needs. Work together as equals.

**Meta-Context:** This workflow uses OpenAI Whisper (local installation) for speech-to-text conversion, then optionally applies Claude AI analysis to extract summaries, action items, themes, and key quotes. The tri-modal architecture supports create (new transcriptions), edit (re-transcribe or re-analyze), and validate (quality checks) modes.

---

## WORKFLOW ARCHITECTURE

### Core Principles

- **Micro-file Design**: Each step is a self-contained instruction file that is part of an overall workflow that must be followed exactly
- **Just-In-Time Loading**: Only the current step file is in memory - never load future step files until told to do so
- **Sequential Enforcement**: Sequence within the step files must be completed in order, no skipping or optimization allowed
- **State Tracking**: Track execution state during workflow run (single-session, no persistence between runs)
- **Structured Output**: Build markdown reports with clear sections: metadata, transcript, AI analysis

### Step Processing Rules

1. **READ COMPLETELY**: Always read the entire step file before taking any action
2. **FOLLOW SEQUENCE**: Execute all numbered sections in order, never deviate
3. **WAIT FOR INPUT**: If a menu is presented, halt and wait for user selection (UNLESS autonomous_mode = true)
4. **CHECK CONTINUATION**: If the step has a menu with Continue as an option, only proceed to next step when user selects 'C' (Continue) (UNLESS autonomous_mode = true, then use defaults and auto-proceed)
5. **SAVE STATE**: Track progress through workflow execution
6. **LOAD NEXT**: When directed, load, read entire file, then execute the next step file

### Critical Rules (NO EXCEPTIONS)

- 🛑 **NEVER** load multiple step files simultaneously
- 📖 **ALWAYS** read entire step file before execution
- 🚫 **NEVER** skip steps or optimize the sequence
- 💾 **ALWAYS** update output files when directed
- 🎯 **ALWAYS** follow the exact instructions in the step file
- ⏸️ **ALWAYS** halt at menus and wait for user input (UNLESS autonomous_mode = true)
- 🤖 **AUTONOMOUS MODE**: When autonomous_mode = true, skip menus and use default values specified in each step
- 📋 **NEVER** create mental todo lists from future steps
- ✅ **ALWAYS** speak in {communication_language}

---

## INITIALIZATION SEQUENCE

### 1. Configuration Loading

Load and read full config from {project-root}/_bmad/bmm/config.yaml and resolve:

- `project_name`, `output_folder`, `user_name`, `communication_language`, `document_output_language`, `planning_artifacts`
- ✅ **ALWAYS** speak in {communication_language}

### 2. Autonomous Mode Detection

Check for autonomous mode flag or environment variable:

**Autonomous mode enables:**
- Batch processing without user interaction
- Sensible defaults for all configuration choices
- Automatic file processing
- Scripting and CI/CD integration

**Detection methods:**
1. Check for `--autonomous` flag in invocation
2. Check environment variable: `BMAD_AUTONOMOUS=true`
3. Check for `AUTONOMOUS_MODE=true` in user context

**If autonomous mode detected:**
- Set `autonomous_mode = true`
- All step files will skip interactive menus
- Use default configuration (detailed in step-04):
  - Model: small (balanced speed/accuracy)
  - Language: auto-detect
  - Output format: txt
  - AI analysis: none (unless explicitly requested via --analysis flag)
  - Combined mode: yes (for multiple files)

**If not detected:**
- Set `autonomous_mode = false`
- Normal interactive workflow with user prompts

### 3. Mode Selection

This is a **tri-modal workflow** with three modes:

**CREATE MODE** - Transcribe new audio files
- Fresh transcription from audio files
- Optional AI analysis
- Produces structured markdown report

**EDIT MODE** - Modify existing transcriptions
- Re-transcribe with different settings (model, language)
- Regenerate AI analysis with different options
- Update existing markdown reports

**VALIDATE MODE** - Quality check transcriptions
- Verify prerequisites (Whisper, FFmpeg)
- Check output quality and completeness
- Generate validation report with scoring

### 4. Mode Routing

**How to invoke:**
- Default (no flag): CREATE mode
- With `-e` flag: EDIT mode
- With `-v` flag: VALIDATE mode
- Add `--autonomous` for batch processing mode

**IF CREATE MODE** (default):
Load, read the full file, then execute `{createWorkflow}` to begin transcription.

**IF EDIT MODE** (invoked with -e):
Load, read the full file, then execute `{editWorkflow}` to edit existing transcription.

**IF VALIDATE MODE** (invoked with -v):
Load, read the full file, then execute `{validateWorkflow}` to validate transcription quality.

**Note:** Autonomous mode (`--autonomous`) works with any primary mode but is most commonly used with CREATE mode for batch processing.
