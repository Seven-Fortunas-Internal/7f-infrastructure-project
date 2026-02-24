# bmad-bmm-transcribe-audio

Transform audio files into structured markdown transcripts with optional AI-powered analysis using OpenAI Whisper.

**Module:** BMM (Business Method Module)
**Category:** Utilities
**Modes:** Create | Edit | Validate

## What This Workflow Does

- Transcribe audio files (MP3, M4A, WAV, AAC, etc.) into text
- Generate multiple output formats (TXT, SRT, VTT, JSON)
- Optional AI-powered analysis (summaries, action items, themes, quotes)
- Process single files, multiple files, or entire directories
- Autonomous mode for batch processing
- Parallel processing for multiple files (3-5x speedup)

## Usage

```
/bmad-bmm-transcribe-audio
```

Or with autonomous mode:
```
/bmad-bmm-transcribe-audio --autonomous --directory ~/audio-files
```

## Workflow Reference

Load and execute: @{project-root}/_bmad/bmm/workflows/utilities/transcribe-audio/workflow.md
