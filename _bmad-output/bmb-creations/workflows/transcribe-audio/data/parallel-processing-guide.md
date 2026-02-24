# Parallel Processing Guide

**Purpose:** Instructions for parallel audio transcription using Whisper.

---

## When to Use Parallel Processing

**Criteria:**
- Multiple audio files (file_count > 1)
- System has multiple CPU cores
- Files can be processed independently

**Benefits:**
- 3-5x faster than sequential processing
- Efficient use of system resources
- Same output quality as sequential

---

## Architecture

### Phase 1: Parallel Transcription
- All files transcribe simultaneously
- Each file writes to unique output file
- No race conditions (separate outputs)

### Phase 2: Sequential Collection
- Wait for all parallel jobs to complete
- Collect results in original order
- Build transcripts array for next step

---

## Implementation

### Determine Concurrency

**Default calculation:**
```
concurrent_jobs = min(file_count, CPU_cores)
```

**Limits:**
- Maximum: 4 concurrent jobs (balances speed vs. memory)
- Can override with `--max-parallel` flag
- Minimum: 1 (fallback to sequential)

### Build Whisper Commands

**For each audio file, construct:**
```bash
whisper "[file_path]" \
  --model [model] \
  --output_dir "[output_dir]" \
  --output_format [output_format] \
  [--language [language] if not auto] \
  --verbose False
```

### Execute in Parallel

**Option A: Background processes (bash)**
```bash
# Spawn all jobs
whisper "file1.mp3" --model small --output_dir "/out" --output_format txt &
PID1=$!

whisper "file2.mp3" --model small --output_dir "/out" --output_format txt &
PID2=$!

whisper "file3.mp3" --model small --output_dir "/out" --output_format txt &
PID3=$!

# Wait for all to complete
wait $PID1 $PID2 $PID3
echo "All transcriptions complete"
```

**Option B: GNU parallel (if available)**
```bash
parallel -j [concurrent_jobs] \
  whisper {} \
    --model [model] \
    --output_dir "[output_dir]" \
    --output_format [output_format] \
  ::: [file1] [file2] [file3]
```

**Recommendation:** Use Option A (background processes) - more portable, no dependencies

---

## Progress Display

**During parallel execution:**
```
🚀 Parallel Processing Mode

Transcribing [file_count] files with [concurrent_jobs] concurrent workers...

Progress:
  Running: 3/5 | Completed: 2/5
  Elapsed: 2m 15s
```

**Update strategy:**
- Poll job status every 5-10 seconds
- Show running vs. completed count
- Display total elapsed time

---

## Result Collection

**After all parallel jobs complete:**

```
✅ All transcriptions complete!

Processing results...
```

**For each file (in original order):**

1. **Check transcript file exists:**
   ```bash
   test -f "[output_dir]/[audio_filename].txt"
   ```

2. **Read transcript content:**
   ```bash
   cat "[output_dir]/[audio_filename].txt"
   ```

3. **Extract metadata** (if available from Whisper output):
   - Duration (seconds/minutes)
   - Detected language
   - Processing time

4. **Build transcript object:**
   ```json
   {
     "filename": "audio.mp3",
     "transcript_file": "/path/to/output.txt",
     "transcript_content": "[full text content]",
     "duration": "2m 30s",
     "language": "en",
     "status": "success"
   }
   ```

5. **Handle failures:**
   - If transcript file missing: status = "failed"
   - Include error message if available
   - Continue processing other files

6. **Store in transcripts array:**
   - Append to `transcripts` variable
   - Maintain original file order
   - Pass to next step

---

## File Safety

**Thread-safe design:**
- Each file writes to: `[audio_filename].txt` (unique)
- No shared output files during parallel phase
- Same directory is safe (unique filenames)
- No race conditions possible

**Directory structure during execution:**
```
output_dir/
├── audio1.txt  (Job 1 writing)
├── audio2.txt  (Job 2 writing)
├── audio3.txt  (Job 3 writing)
└── audio4.txt  (Job 4 writing)
```

**After completion:**
```
output_dir/
├── audio1.txt  ✅
├── audio2.txt  ✅
├── audio3.txt  ✅
├── audio4.txt  ✅
└── combined-analysis-2026-02-14.md  (created later by step-07)
```

---

## Error Handling

**If parallel job fails:**
1. Other jobs continue (don't block)
2. Mark failed file in results: status = "failed"
3. Include error message if captured
4. Continue to next step with partial results

**If all jobs fail:**
1. Report complete failure
2. Provide diagnostic information
3. Suggest troubleshooting (check Whisper install, file formats)
4. Halt workflow

---

## Performance Notes

**Expected speedup:**
- 2 files: ~1.8x faster
- 4 files: ~3.5x faster
- 8 files: ~4x faster (max 4 concurrent)
- 10+ files: ~4x faster (max 4 concurrent)

**Memory considerations:**
- Each Whisper instance: ~1-2GB RAM
- Max 4 concurrent = ~4-8GB RAM usage
- Small model: Lower memory footprint
- Medium/large model: Higher memory usage

**Recommended system specs:**
- Minimum: 4 CPU cores, 8GB RAM
- Optimal: 8+ CPU cores, 16GB+ RAM
- Works on less powerful systems (fallback to sequential)

---

## Fallback to Sequential

**When to fallback:**
- Only 1 audio file
- System has 1 CPU core
- Memory constraints detected
- User specifies `--sequential` flag

**Fallback process:**
- Detect condition during preparation
- Display: "Using sequential processing (single file/system constraint)"
- Route to sequential processing section
- Same quality, just slower

---

## Testing Notes

**Verify parallel processing:**
```bash
# During transcription, check running processes
ps aux | grep whisper

# Should see multiple whisper processes
```

**Measure performance:**
```bash
# Time the transcription
time /bmad-bmm-transcribe-audio --autonomous --directory ~/audio

# Compare to sequential
time /bmad-bmm-transcribe-audio --autonomous --sequential --directory ~/audio
```
