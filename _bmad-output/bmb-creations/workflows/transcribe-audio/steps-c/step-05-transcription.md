---
nextStepFile: './step-06-ai-analysis.md'
parallelProcessingGuide: '../data/parallel-processing-guide.md'
---

# STEP GOAL

Execute OpenAI Whisper transcription on all validated audio files using the configured settings. For multiple files, use parallel processing to maximize speed. Display progress, handle any errors, and save all output files to organized directories. Prepare transcript content for optional AI analysis in the next step.

---

# MANDATORY EXECUTION RULES

1. **READ COMPLETELY** - Read this entire step file before taking any action
2. **FOLLOW SEQUENCE** - Execute all numbered sections in MANDATORY SEQUENCE exactly as written
3. **NO OPTIMIZATION** - Do not skip steps, reorder actions, or "optimize" the sequence
4. **SINGLE STEP FOCUS** - This is step 05 only. Do not look ahead or reference future steps
5. **PROCESS ALL FILES** - Transcribe each file in the `audio_files` array
6. **AUTO-PROCEED** - No user menu during transcription, auto-proceed on completion

---

# ROLE REINFORCEMENT

**You are:** A Technical Facilitator executing audio transcription

**Your demeanor:**
- Focused on execution
- Provides clear progress updates
- Handles errors gracefully
- Celebrates successful completion

**Your communication style:**
- Progress indicators for each file
- Technical details when relevant
- Clear error messages if issues occur
- Concise success confirmations

---

# MANDATORY SEQUENCE

## 1. Preparation

**Retrieve from workflow context:**
- `audio_files` - Array of file paths to transcribe
- `model` - Whisper model to use
- `language` - Language setting
- `output_format` - Format(s) to generate
- `file_count` - Number of files

**Create output directory:**

Get today's date: `date +%Y-%m-%d` → Store in `transcription_date`

Create output directory path:
```
output_dir = [output_folder]/transcriptions/[transcription_date]
```

Execute using Bash:
```bash
mkdir -p "[output_dir]"
```

## 2. Announce Transcription Start

Present this message:

```
## Transcription Execution

**Starting transcription...**

**Configuration:**
- Files: [file_count]
- Model: [model]
- Language: [language or "Auto-detect"]
- Output: [output_format]
- Processing: [If file_count > 1: "Parallel (faster)" else: "Sequential"]

**Output directory:**
`[output_dir]`

---
```

## 3. Determine Processing Mode

**IF file_count > 1:**
- Set `processing_mode = "parallel"`
- Execute section 3A (Parallel Processing)

**IF file_count == 1:**
- Set `processing_mode = "sequential"`
- Execute section 3B (Sequential Processing)

## 3A. Parallel Processing (Multiple Files)

**Reference:** Load {parallelProcessingGuide} for complete parallel processing instructions.

**Execute parallel transcription following the guide:**

1. **Determine concurrency** (see guide section "Determine Concurrency")
   - Calculate: min(file_count, CPU_cores), max 4
   - Check for --max-parallel override

2. **Build commands** (see guide section "Build Whisper Commands")
   - Construct whisper command for each file
   - Include all configuration parameters

3. **Execute in parallel** (see guide section "Execute in Parallel")
   - Use background processes with & and wait (Option A - recommended)
   - Display progress during execution

4. **Collect results** (see guide section "Result Collection")
   - Wait for all jobs to complete
   - Read transcript files in original order
   - Build transcripts array with metadata
   - Handle any failures gracefully

**Display progress** (see guide section "Progress Display"):
```
🚀 Parallel Processing Mode
Transcribing [file_count] files with [concurrent_jobs] workers...
Running: X/N | Completed: Y/N
```

**File safety guaranteed** (see guide section "File Safety"):
- Unique output filenames prevent race conditions
- Same directory is thread-safe

**Proceed to section 4 (Transcription Summary)**

## 3B. Sequential Processing (Single File or Fallback)

**For each file in `audio_files` array:**

### 3B-1. Display Progress (Per File)

```
### Processing [X of N]: [filename]

🎙️ Transcribing...
```

### 3B-2. Build Whisper Command

**Base command:**
```
whisper "[file_path]" --model [model] --output_dir "[output_dir]" --output_format [output_format]
```

**Add language flag (if not auto-detect):**
- If `language != "auto"`: Add `--language [language]`
- If `language == "auto"`: Omit language flag

**Add verbose flag for progress:**
Add `--verbose False` to reduce output noise

**Final command example:**
```bash
whisper "/path/to/audio.mp3" --model small --output_dir "/output/path" --output_format txt --verbose False
```

### 3B-3. Execute Transcription

Execute Whisper command using Bash tool.

**Capture:**
- stdout (transcription progress and results)
- stderr (any errors or warnings)
- Exit code (success/failure)

**Timeout:** Set appropriate timeout based on file size (default: 10 minutes per file)

### 3B-4. Process Result

**If successful (exit code 0):**

```
✅ Transcription complete
   - Duration: [extract from Whisper output if available]
   - Detected language: [extract from Whisper output if available]
   - Output: [list generated files]
```

**Read transcript content:**
- Read the generated .txt file
- Store full transcript in `transcripts` array:
  ```
  {
    "filename": "original_audio_name.mp3",
    "transcript_file": "/path/to/output.txt",
    "transcript_content": "[full text content]",
    "duration": "[if available]",
    "language": "[detected language]",
    "status": "success"
  }
  ```

**If failed (exit code != 0):**

```
❌ Transcription failed
   Error: [stderr output]
```

Store error in `transcripts` array:
```
{
  "filename": "original_audio_name.mp3",
  "status": "failed",
  "error": "[error message]"
}
```

**Continue to next file** (don't halt entire workflow on single file failure)

### 3E. Repeat for All Files

Continue loop until all files in `audio_files` have been processed.

## 4. Transcription Summary

After all files processed, present summary:

```
---

## Transcription Complete

**Results:**
- ✅ Successful: [count of successful transcriptions]
- ❌ Failed: [count of failed transcriptions]
- 📄 Total output files: [count all generated files in output_dir]

**Successful Transcriptions:**
[List each successful file with size and detected language]

[If any failures:]
**Failed Transcriptions:**
[List each failed file with error message]

**Output Location:**
`[output_dir]`

**Files Generated:**
```

**List all generated files:**
Execute using Bash:
```bash
ls -lh "[output_dir]" | grep -v "^total" | awk '{print "- " $9 " (" $5 ")"}'
```

## 5. Prepare for AI Analysis

**Check successful transcriptions:**
- If `successful_count > 0`: AI analysis is available
- If `successful_count == 0`: Skip AI analysis (workflow ends at step 7)

**Determine transcript combination strategy:**
- If `file_count == 1`: Single transcript for analysis
- If `file_count > 1`: Offer combined or individual analysis in next step

**Store for next step:**
- `transcripts` array (with all metadata)
- `output_dir` (for saving analysis)
- `successful_count` (to determine if analysis available)
- `transcription_date` (for markdown report)

## 6. Transition Message

```
---

**Next:** Optional AI-powered analysis of your transcripts

Available analysis types:
- Summary (configurable length and focus)
- Action Items (todos, decisions, next steps)
- Themes & Key Points (main topics)
- Key Quotes (memorable statements)
- Custom Analysis (your own prompt)

Proceeding to analysis options...
```

## 7. Load Next Step

**If `successful_count > 0`:**
```
Load and execute: @{workflow-dir}/step-06-ai-analysis.md
```

**If `successful_count == 0`:**
```
Load and execute: @{workflow-dir}/step-07-output-summary.md
```
(Skip AI analysis, go straight to final summary)

---

# ERROR HANDLING

## Common Whisper Errors

**"Model not found"**
- First run downloads model automatically
- May take 2-5 minutes
- Show download progress to user
- Retry transcription after download

**"FFmpeg not found"**
- Should have been caught in step-02 prerequisites
- If it occurs here, display error and recommend re-running prerequisites

**"Unable to read file" / "File not found"**
- Should have been caught in step-03 input discovery
- Display file path and recommend checking file permissions

**"Out of memory"**
- Large audio file with large model
- Recommend: Use smaller model (base instead of medium)
- Or: Process files in smaller batches

**"Unsupported format"**
- Display supported formats
- Recommend: Convert file using FFmpeg first

## Error Recovery Strategy

**Single file failure:**
- Log error
- Continue with remaining files
- Report failure in summary

**All files failed:**
- Display comprehensive error report
- Offer troubleshooting steps
- Do NOT proceed to AI analysis
- Load step-07 (output summary) with error context

---

# SUCCESS METRICS

**This step succeeds when:**
- ✅ All audio files processed (attempted transcription)
- ✅ At least one successful transcription
- ✅ All output files saved to organized directory
- ✅ Transcript content captured for analysis
- ✅ Progress updates provided throughout
- ✅ Next step loaded appropriately

**This step fails if:**
- ❌ Whisper command not executed
- ❌ Output files not saved
- ❌ Transcript content not captured
- ❌ Errors not handled gracefully
- ❌ User not informed of progress

---

# VALIDATION CHECKLIST

Before loading next step, confirm:
- [ ] Output directory created
- [ ] All files in `audio_files` array processed
- [ ] Whisper commands executed with correct parameters
- [ ] Transcript content read and stored
- [ ] Success/failure tracked for each file
- [ ] Summary displayed with results
- [ ] `transcripts` array populated with metadata
- [ ] Error handling executed if needed
- [ ] Appropriate next step determined (step-06 or step-07)
- [ ] Ready to load next step

---

**Step Type:** Middle step (Autonomous execution)
**Next Step:** step-06-ai-analysis.md (if successful) or step-07-output-summary.md (if all failed)
**Critical Output:** Transcripts with content and metadata for analysis
**Auto-proceed:** Yes (no user menu during transcription)
