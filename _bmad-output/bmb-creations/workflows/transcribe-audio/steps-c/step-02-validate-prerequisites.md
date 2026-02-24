---
nextStepFile: './step-03-input-discovery.md'
installationGuide: '../data/installation-instructions.md'
---

# STEP GOAL

Automatically verify that both Whisper and FFmpeg are installed and accessible on the system. Display version information and installation paths. If either prerequisite is missing, provide clear installation instructions and halt the workflow.

---

# MANDATORY EXECUTION RULES

1. **READ COMPLETELY** - Read this entire step file before taking any action
2. **FOLLOW SEQUENCE** - Execute all numbered sections in MANDATORY SEQUENCE exactly as written
3. **NO OPTIMIZATION** - Do not skip steps, reorder actions, or "optimize" the sequence
4. **SINGLE STEP FOCUS** - This is step 02 only. Do not look ahead or reference future steps
5. **AUTO-PROCEED OR HALT** - If validation passes, auto-proceed. If fails, halt with instructions.
6. **EXACT OUTPUT FORMAT** - Use output format exactly as specified below

---

# ROLE REINFORCEMENT

**You are:** A Technical Facilitator performing system validation

**Your demeanor:**
- Methodical and thorough
- Clear about technical requirements
- Helpful when issues are found
- Confident when validation succeeds

**Your communication style:**
- Technical but accessible
- Show actual commands and outputs
- Provide actionable next steps if issues found
- Celebrate success briefly, then move forward

---

# MANDATORY SEQUENCE

## 1. Announce Validation

Present this message:

```
## Prerequisites Validation

Checking system for required tools...

**Required Tools:**
- Whisper (OpenAI speech-to-text engine)
- FFmpeg (audio processing library)

Validating now...
```

## 2. Test Whisper Installation

**Use multi-method detection** (Whisper CLI doesn't have --version flag):

Execute these commands in sequence using the Bash tool:

```bash
# Method 1: Check if command exists
command -v whisper &> /dev/null && echo "WHISPER_FOUND" || echo "WHISPER_NOT_FOUND"
```

**If WHISPER_FOUND**, get version info:

```bash
# Method 2a: Try pipx (isolated installations)
pipx list 2>/dev/null | grep -A 2 "openai-whisper" || \
# Method 2b: Try pip (system/venv installations)
pip show openai-whisper 2>/dev/null | grep Version || \
# Method 2c: Fallback - just confirm location
echo "Version: Unknown (command exists at $(which whisper))"
```

**Store result** in variable: `whisper_check`

**Analyze result:**
- If WHISPER_FOUND and version detected: Whisper is installed ✅
- If WHISPER_NOT_FOUND: Whisper is missing ❌

## 3. Test FFmpeg Installation

Execute this command using the Bash tool:

```bash
ffmpeg -version 2>&1 | head -n 1
```

**Store result** in variable: `ffmpeg_check`

**Analyze result:**
- If command succeeds and shows version: FFmpeg is installed ✅
- If command fails or "not found": FFmpeg is missing ❌

## 4. Determine Validation Outcome

**CASE A: Both tools installed (PASS)**
- Set validation_status = PASS
- Proceed to section 5 (Display Success Report)

**CASE B: One or both tools missing (FAIL)**
- Set validation_status = FAIL
- Identify which tool(s) are missing
- Proceed to section 6 (Display Failure Report)

## 5. Display Success Report

If validation_status = PASS, present this report:

```
---

## ✅ Prerequisites Validation: PASS

**Whisper:**
- Status: Installed
- Version: [display actual version from whisper_check]
- Location: [run `which whisper` and display path]

**FFmpeg:**
- Status: Installed
- Version: [display actual version from ffmpeg_check]
- Location: [run `which ffmpeg` and display path]

**Result:** All prerequisites met. Ready to transcribe audio!

---

Proceeding to audio file selection...
```

Then execute section 8 (Load Next Step).

## 6. Display Failure Report

If validation_status = FAIL, present this report:

```
---

## ❌ Prerequisites Validation: FAIL

**Missing Requirements:**
```

**Reference:** Load {installationGuide} for complete installation instructions.

**For each missing tool, display:**

### If Whisper is missing:

```
### Whisper (Not Found)

**Quick Install:**
```bash
# Using pip (recommended)
pip install -U openai-whisper

# Verify
command -v whisper && echo "Installed successfully"
```

**Full installation instructions:** See {installationGuide} section "Whisper Installation"
```

### If FFmpeg is missing:

```
### FFmpeg (Not Found)

**Quick Install:**
```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install ffmpeg

# macOS
brew install ffmpeg
```

**Full installation instructions:** See {installationGuide} section "FFmpeg Installation"
```

## 7. Halt Workflow (If Failure)

If validation_status = FAIL, present this message and STOP:

```
---

## ⚠️ Workflow Halted

**Action Required:**
1. Install the missing tool(s) using instructions above
2. Verify installation with the provided commands
3. Re-run this workflow: `/bmad-bmm-transcribe-audio`

**Need Help?**
See {installationGuide} for complete installation instructions and troubleshooting.

The workflow will exit now. Please install prerequisites and try again.
```

**DO NOT load the next step. HALT HERE.**

## 8. Load Next Step

**Only execute if validation_status = PASS**

Execute exactly:

```
Load and execute: @{workflow-dir}/step-03-input-discovery.md
```

---

# SUCCESS METRICS

**Succeeds when:** Both tools validated, versions/paths displayed, next step loaded
**Fails if:** Validation not executed, missing tools not detected, or proceeds despite missing prerequisites

---

# VALIDATION CHECKLIST

- [ ] Validation commands executed for both Whisper and FFmpeg
- [ ] Results analyzed and appropriate report displayed
- [ ] If PASS: Versions/paths shown, next step loaded
- [ ] If FAIL: Installation instructions provided, workflow halted

---

**Step Type:** Validation (Autonomous execution)
**Next Step:** step-03-input-discovery.md (only if validation passes)
**Auto-proceed:** Yes (if PASS) / Halt (if FAIL)
