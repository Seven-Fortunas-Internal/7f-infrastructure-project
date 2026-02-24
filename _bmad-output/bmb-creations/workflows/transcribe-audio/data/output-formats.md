# Output Format Options

## Available Formats

### TXT - Plain Text (Default)
- **Extension:** `.txt`
- **Content:** Plain text transcript, no timestamps
- **Use when:** Just need the text content
- **Command flag:** `--output_format txt` (default)
- **Example:**
  ```
  Hey, Jorge. Maybe best if I just read this...
  So the first thing is RWA tokenization meets Guatemala.
  We want to say Latin America.
  ```

### SRT - SubRip Subtitles
- **Extension:** `.srt`
- **Content:** Numbered segments with timestamps
- **Use when:** Need subtitles for video, time-synced text
- **Command flag:** `--output_format srt`
- **Example:**
  ```
  1
  00:00:00,000 --> 00:00:09,960
  Hey, Jorge. Maybe best if I just read this...

  2
  00:00:09,960 --> 00:00:16,720
  So the first thing is RWA tokenization meets Guatemala.
  ```

### VTT - WebVTT Subtitles
- **Extension:** `.vtt`
- **Content:** Web standard subtitle format with timestamps
- **Use when:** Web video players, HTML5 video
- **Command flag:** `--output_format vtt`
- **Example:**
  ```
  WEBVTT

  00:00:00.000 --> 00:00:09.960
  Hey, Jorge. Maybe best if I just read this...

  00:00:09.960 --> 00:00:16.720
  So the first thing is RWA tokenization meets Guatemala.
  ```

### JSON - Structured Data
- **Extension:** `.json`
- **Content:** Complete data structure with word-level timestamps
- **Use when:** Need programmatic access, detailed timing data
- **Command flag:** `--output_format json`
- **Example:**
  ```json
  {
    "text": "Hey, Jorge...",
    "segments": [
      {
        "id": 0,
        "start": 0.0,
        "end": 9.96,
        "text": "Hey, Jorge. Maybe best if I just read this...",
        "words": [...]
      }
    ],
    "language": "en"
  }
  ```

### ALL - Generate All Formats
- **Extensions:** `.txt`, `.srt`, `.vtt`, `.json`
- **Content:** All four formats generated simultaneously
- **Use when:** Unsure which format needed, want maximum flexibility
- **Command flag:** `--output_format all`

## Format Selection Guide

**For this workflow:**
- **Default:** TXT + Markdown report (sufficient for most uses)
- **If need timestamps:** TXT + SRT or VTT
- **If need detailed data:** TXT + JSON
- **If unsure:** ALL (generates everything)

**Recommendation:**
- **Quick transcriptions:** TXT only (fastest, simplest)
- **Meeting notes:** TXT + SRT (can reference timestamps)
- **Development/Integration:** JSON (programmatic access)
- **Video subtitles:** SRT or VTT (depending on platform)

## Performance Impact

- TXT: Fastest (no extra processing)
- SRT/VTT: Slight overhead (formatting timestamps)
- JSON: Most overhead (detailed structure)
- ALL: ~2x processing time (generates all formats)

## Output Location

All formats saved to: `{output_folder}/transcriptions/YYYY-MM-DD/`

Example:
```
transcriptions/2026-02-14/
├── signal-audio.txt
├── signal-audio.srt
├── signal-audio.vtt
├── signal-audio.json
└── signal-audio.md  (markdown report with analysis)
```
