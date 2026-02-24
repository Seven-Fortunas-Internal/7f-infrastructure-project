---
nextStepFile: './step-03a-validate-file-structure.md'
---

# STEP GOAL

Verify that Whisper and FFmpeg are still installed and accessible on the system. Compare current versions with the versions used during original transcription (if recorded). Update validation checklist with prerequisites check results.

---

# MANDATORY EXECUTION RULES

1. **READ COMPLETELY** - Read this entire step file before taking any action
2. **FOLLOW SEQUENCE** - Execute all numbered sections in MANDATORY SEQUENCE exactly as written
3. **NO OPTIMIZATION** - Do not skip steps, reorder actions, or "optimize" the sequence
4. **SINGLE STEP FOCUS** - This is validate step 02 only
5. **AUTO-PROCEED** - No user menu, auto-proceed after checks complete
6. **UPDATE CHECKLIST** - Mark checklist items as PASS/FAIL

---

# ROLE REINFORCEMENT

**You are:** A Quality Assurance Facilitator performing system checks

**Your demeanor:**
- Systematic and thorough
- Factual in reporting
- Non-judgmental
- Clear about findings

**Your communication style:**
- Report facts objectively
- Show version information
- Note any discrepancies
- Provide context for findings

---

# MANDATORY SEQUENCE

## 1. Retrieve Context

**Get from workflow context:**
- `report_metadata` - Original transcription metadata
- `validation_checklist` - Checklist to update
- `validation_score` - Running score (currently 0)

**Extract original tool versions (if available):**
- Original Whisper version (from metadata if recorded)
- Original FFmpeg version (from metadata if recorded)

## 2. Announce Validation

Present this message:

```
## Prerequisites Validation

Checking system for required tools...

**Checking:**
- Whisper (OpenAI speech-to-text engine)
- FFmpeg (audio processing library)

Validating now...
```

## 3. Test Whisper Installation

Execute this command using Bash tool:

```bash
whisper --version 2>&1
```

**Store result** in `whisper_check`.

**Analyze result:**
- If command succeeds: Whisper is installed ✅
  - Extract version number
  - Set `whisper_installed = true`
  - Add 10 points to `validation_score`
- If command fails: Whisper is missing ❌
  - Set `whisper_installed = false`
  - Add 0 points to `validation_score`

**Update checklist:**
```yaml
validation_checklist:
  prerequisites:
    whisper_installed: [true/false]
```

## 4. Test FFmpeg Installation

Execute this command using Bash tool:

```bash
ffmpeg -version 2>&1 | head -n 1
```

**Store result** in `ffmpeg_check`.

**Analyze result:**
- If command succeeds: FFmpeg is installed ✅
  - Extract version number
  - Set `ffmpeg_installed = true`
  - Add 10 points to `validation_score`
- If command fails: FFmpeg is missing ❌
  - Set `ffmpeg_installed = false`
  - Add 0 points to `validation_score`

**Update checklist:**
```yaml
validation_checklist:
  prerequisites:
    ffmpeg_installed: [true/false]
```

## 5. Version Comparison

**If original versions were recorded in metadata:**

Compare current vs. original:

**For Whisper:**
- Original version: [from metadata]
- Current version: [from whisper_check]
- Status: [Same/Upgraded/Downgraded/Different]

**For FFmpeg:**
- Original version: [from metadata]
- Current version: [from ffmpeg_check]
- Status: [Same/Upgraded/Downgraded/Different]

**Store comparison** in `version_comparison` object.

**If no original versions recorded:**
- Note: "Original versions not recorded in metadata"
- This is informational only, doesn't affect score

## 6. Display Prerequisites Report

Present comprehensive report:

```
---

## Prerequisites Validation Results

**Whisper:**
```

**If whisper_installed == true:**
```
✅ INSTALLED
   - Version: [current_version]
   - Location: [run `which whisper` and display]
   [If version comparison available:]
   - Original version: [original_version]
   - Status: [comparison_status]
   - Points: 10/10
```

**If whisper_installed == false:**
```
❌ NOT FOUND
   - Status: Missing
   - Impact: Cannot re-transcribe without Whisper
   - Points: 0/10

   **Installation Instructions:**
   ```bash
   # Install using pip
   pip install -U openai-whisper

   # Or using pipx
   pipx install openai-whisper
   ```
```

**FFmpeg:**
```

**If ffmpeg_installed == true:**
```
✅ INSTALLED
   - Version: [current_version]
   - Location: [run `which ffmpeg` and display]
   [If version comparison available:]
   - Original version: [original_version]
   - Status: [comparison_status]
   - Points: 10/10
```

**If ffmpeg_installed == false:**
```
❌ NOT FOUND
   - Status: Missing
   - Impact: Whisper requires FFmpeg as dependency
   - Points: 0/10

   **Installation Instructions:**
   ```bash
   # Ubuntu/Debian
   sudo apt-get install ffmpeg

   # macOS
   brew install ffmpeg
   ```
```

**Prerequisites Score: [prerequisites_score]/20**

[If any tool missing:]
**⚠️ Warning:** Missing prerequisites may prevent future re-transcription or editing of this report.

---
```

## 7. Store Updated State

**Update workflow context:**
- `whisper_installed` - Boolean
- `ffmpeg_installed` - Boolean
- `whisper_version` - Current version string
- `ffmpeg_version` - Current version string
- `version_comparison` - Comparison object (if available)
- `validation_checklist` - Updated with prerequisites results
- `validation_score` - Updated score

**Calculate prerequisites subscore:**
```
prerequisites_score = points earned (0-20)
prerequisites_percentage = (prerequisites_score / 20) * 100
```

Store: `prerequisites_subscore`

## 8. Transition Message

```
---

Prerequisites validation complete.

**Next:** Validating output files and report quality...
```

## 9. Load Next Step

Execute exactly:

```
Load and execute: @{workflow-dir}/step-03a-validate-file-structure.md
```

---

# SUCCESS METRICS

**This step succeeds when:**
- ✅ Whisper installation checked
- ✅ FFmpeg installation checked
- ✅ Current versions extracted (if installed)
- ✅ Version comparison performed (if original versions available)
- ✅ Validation checklist updated
- ✅ Validation score updated
- ✅ Results displayed clearly
- ✅ Next step loaded

**This step fails if:**
- ❌ Commands not executed
- ❌ Installation status not determined
- ❌ Checklist not updated
- ❌ Score not calculated
- ❌ Results not reported

---

# VALIDATION CHECKLIST

Before loading next step, confirm:
- [ ] Prerequisites announcement displayed
- [ ] Whisper version command executed
- [ ] FFmpeg version command executed
- [ ] Installation status determined for both tools
- [ ] Current versions extracted (if installed)
- [ ] Version comparison performed (if original metadata available)
- [ ] Validation checklist updated:
  - [ ] whisper_installed (true/false)
  - [ ] ffmpeg_installed (true/false)
- [ ] Validation score updated (added 0-20 points)
- [ ] Prerequisites report displayed with:
  - [ ] Installation status for each tool
  - [ ] Versions and locations (if installed)
  - [ ] Version comparison (if applicable)
  - [ ] Installation instructions (if missing)
  - [ ] Subscore calculation
- [ ] Transition message displayed
- [ ] Ready to load step-03-validate-outputs.md

---

**Step Type:** Validation step (Autonomous execution)
**Next Step:** step-03-validate-outputs.md
**Auto-proceed:** Yes
**Subscore:** 20 points maximum
