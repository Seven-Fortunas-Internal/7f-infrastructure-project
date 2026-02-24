---
audio_file: {{audio_filename}}
date: {{transcription_date}}
duration: {{audio_duration}}
model: {{whisper_model}}
language: {{detected_language}}
analysis_types: {{selected_analyses}}
---

# Audio Transcription Report

## Metadata
- **File:** {{audio_filename}}
- **Date:** {{transcription_date}}
- **Duration:** {{audio_duration}}
- **Model:** Whisper {{whisper_model}}
- **Language:** {{detected_language}}

## Transcript

{{full_transcript_text}}

## AI Analysis

### Summary
{{summary_content}}

### Action Items
{{action_items_content}}

### Themes & Key Points
{{themes_content}}

### Key Quotes
{{key_quotes_content}}

### Custom Analysis
{{custom_analysis_content}}

## Raw Files
- Transcript: `{{audio_filename}}.txt`
- Subtitles: `{{audio_filename}}.srt` (if generated)
- WebVTT: `{{audio_filename}}.vtt` (if generated)
- JSON: `{{audio_filename}}.json` (if generated)
