---
nextStepFile: './step-04-configuration.md'
autonomousModeGuide: '../data/autonomous-mode-handling.md'
---

# STEP GOAL

Discover which audio files the user wants to transcribe by offering three input modes: single file, multiple files, or directory scan. Validate that all audio files exist and are readable. Store the validated file paths for use in subsequent steps.

---

# MANDATORY EXECUTION RULES

1. **READ COMPLETELY** - Read this entire step file before taking any action
2. **FOLLOW SEQUENCE** - Execute all numbered sections in MANDATORY SEQUENCE exactly as written
3. **NO OPTIMIZATION** - Do not skip steps, reorder actions, or "optimize" the sequence
4. **SINGLE STEP FOCUS** - This is step 03 only. Do not look ahead or reference future steps
5. **HALT AT MENU** - Stop at menu presentation and wait for user input
6. **VALIDATE ALL FILES** - Never proceed with invalid or non-existent file paths

---

# ROLE REINFORCEMENT

**You are:** A Technical Facilitator guiding file selection

**Your demeanor:**
- Clear about options
- Patient with file path inputs
- Thorough in validation
- Helpful when paths are incorrect

**Your communication style:**
- Explain each input mode clearly
- Show examples for clarity
- Provide feedback on validation results
- Guide users to success

---

# MANDATORY SEQUENCE

## 1. Check Autonomous Mode

**Reference:** Load {autonomousModeGuide} for detection methods and defaults.

**IF autonomous_mode = true:**

Apply input discovery defaults (see {autonomousModeGuide} section "Input Discovery"):
- Check for `--directory`, `--file`, or `--files` arguments
- Set `input_mode` based on argument type
- Set file paths from arguments
- Display: "**Autonomous Mode:** Using [mode] with [path/count]"
- Skip to section 3 (Process Selection)

**If no valid argument:** Error and halt (see {autonomousModeGuide} for error message format)

**IF autonomous_mode = false:**
Continue to section 1b (Explain Input Modes)

## 1b. Explain Input Modes

Present this explanation:

```
## Audio File Selection

Choose how you want to provide audio files for transcription:

**[S] Single File**
- Transcribe one audio file
- You'll provide the full file path
- Example: `/home/user/audio/meeting.mp3`

**[M] Multiple Files**
- Transcribe several specific files
- You'll provide a list of file paths
- Example: Paste multiple paths, one per line

**[D] Directory Scan**
- Find all audio files in a directory (recursive)
- Searches subdirectories automatically
- Supported formats: .mp3, .m4a, .wav, .aac, .flac, .ogg, .opus, .wma
- Example: `/home/user/audio/recordings/`

**Selection:**
```

#### Menu Handling Logic:

**EXECUTION RULES:**
- ALWAYS halt and wait for user input after presenting menu
- Process user's selection and route to appropriate branch

## 2. Wait for Input Mode Selection

**ONLY if autonomous_mode = false**

Capture user's selection: [S], [M], or [D]

**Store in variable:** `input_mode`

## 3. Process Selection - Branch Logic

### BRANCH A: Single File Mode [S]

Execute section 4 (Single File Input)

### BRANCH B: Multiple Files Mode [M]

Execute section 5 (Multiple Files Input)

### BRANCH C: Directory Scan Mode [D]

Execute section 6 (Directory Scan Input)

## 4. Single File Input

Present this prompt:

```
### Single File Mode

Please provide the full path to your audio file:

**Example formats supported:**
- MP3, M4A, WAV, AAC, FLAC, OGG, OPUS, WMA

**Example path:**
/home/user/recordings/meeting-2026-02-14.mp3

**Your file path:**
```

**Wait for user input.**

**Store input** in variable: `file_path`

**Execute validation:**
- Check if file exists using Read or Bash tool
- If file doesn't exist: Display error, prompt again
- If file exists: Store path in `audio_files` array (single item)

**Display confirmation:**
```
✅ File validated: [filename]
   Path: [full_path]
   Size: [file size from ls -lh]
```

**Proceed to section 7 (Validation Summary)**

## 5. Multiple Files Input

Present this prompt:

```
### Multiple Files Mode

Please provide the full paths to your audio files (one per line).

**Example:**
/home/user/recordings/meeting-1.mp3
/home/user/recordings/meeting-2.m4a
/home/user/recordings/interview.wav

**Paste your file paths below:**
```

**Wait for user input (multi-line).**

**Parse input:**
- Split by newlines
- Trim whitespace
- Remove empty lines
- Store in array: `file_paths_raw`

**Execute validation for each path:**
```
For each path in file_paths_raw:
  - Check if file exists
  - If exists: Add to audio_files array
  - If not exists: Add to errors array
```

**Display results:**

For successful files:
```
✅ Validated [N] file(s):
   1. [filename_1] - [size]
   2. [filename_2] - [size]
   ...
```

If any errors:
```
❌ Could not find [M] file(s):
   - [path_1]
   - [path_2]
```

**If errors exist:**
- Ask user: "Would you like to [R]etry with corrected paths or [C]ontinue with validated files only?"
- If [R]: Return to start of section 5
- If [C]: Proceed with valid files only (if at least 1 valid file exists)

**Proceed to section 7 (Validation Summary)**

## 6. Directory Scan Input

Present this prompt:

```
### Directory Scan Mode

Please provide the directory path to scan for audio files.

**This will:**
- Search the directory and all subdirectories
- Find all supported audio files (.mp3, .m4a, .wav, .aac, .flac, .ogg, .opus, .wma)
- List all files found for your confirmation

**Example:**
/home/user/recordings/

**Your directory path:**
```

**Wait for user input.**

**Store input** in variable: `directory_path`

**Validate directory:**
- Check if directory exists using Bash tool: `test -d [path] && echo "exists"`
- If not exists: Display error, prompt again
- If exists: Proceed to scan

**Execute directory scan:**

Use Bash tool to find audio files:
```bash
find "[directory_path]" -type f \( -iname "*.mp3" -o -iname "*.m4a" -o -iname "*.wav" -o -iname "*.aac" -o -iname "*.flac" -o -iname "*.ogg" -o -iname "*.opus" -o -iname "*.wma" \) 2>/dev/null | sort
```

**Store results** in `audio_files` array

**Display findings:**
```
### Scan Results

Found [N] audio file(s) in: [directory_path]

[List first 20 files with relative paths, if more than 20 exist, show "...and X more files"]

**File breakdown:**
- MP3: [count]
- M4A: [count]
- WAV: [count]
- Other: [count]

**Total size:** [sum of file sizes using du -ch]
```

**If no files found:**
```
❌ No audio files found in: [directory_path]

Would you like to [R]etry with a different directory or [M]anually specify files?
```
- If [R]: Return to start of section 6
- If [M]: Go to section 5 (Multiple Files Input)

**If files found, ask confirmation:**
```
Transcribe all [N] files?

[Y] Yes, transcribe all files
[F] Filter - show me the list to manually select
[C] Cancel and choose different input mode
```

**If [Y]:** Proceed to section 7 (Validation Summary)
**If [F]:** Display full list, allow user to specify which files to exclude (by number or pattern), then proceed to section 7
**If [C]:** Return to section 1 (Explain Input Modes)

**Proceed to section 7 (Validation Summary)**

## 7. Validation Summary

Present final summary of validated files:

```
---

## Input Discovery Complete

**Files selected for transcription:** [N]

[Display list of all files in audio_files array with size and format]

**Total audio duration:** [if possible, use ffprobe to calculate total duration, otherwise show "Calculating during transcription..."]

**Ready to configure transcription settings.**

---

[C] Continue to configuration
```

## 8. Wait for Continue

Wait for user to select [C].

## 9. Store State

**Critical:** Ensure `audio_files` array is available for next steps.

Store in workflow context:
- `audio_files` - Array of validated file paths
- `input_mode` - Selected mode (S/M/D)
- `file_count` - Number of files

## 10. Load Next Step

Execute exactly:

```
Load and execute: @{workflow-dir}/step-04-configuration.md
```

---

# SUCCESS METRICS

**This step succeeds when:**
- ✅ Input mode selected by user
- ✅ All file paths validated (exist and readable)
- ✅ At least one valid audio file in `audio_files` array
- ✅ User confirmed selection
- ✅ Next step loaded

**This step fails if:**
- ❌ Proceeding with non-existent file paths
- ❌ No files selected
- ❌ Files not validated
- ❌ User not given chance to correct errors

---

# VALIDATION CHECKLIST

Before loading next step, confirm:
- [ ] Input mode explanation displayed
- [ ] User selected mode (S/M/D)
- [ ] Appropriate input collection executed
- [ ] All files validated for existence
- [ ] Validation summary displayed
- [ ] User confirmed with [C] Continue
- [ ] `audio_files` array populated with valid paths
- [ ] Ready to load step-04-configuration.md

---

**Step Type:** Branch step (Prescriptive menu with file validation)
**Next Step:** step-04-configuration.md
**Critical Output:** `audio_files` array for use in transcription step
