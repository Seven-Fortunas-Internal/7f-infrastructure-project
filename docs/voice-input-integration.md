# Voice Input System Integration Guide

**Feature:** FR-2.3 - OpenAI Whisper Voice Input System
**Purpose:** Enable voice-based content creation for Claude skills
**Key Use Case:** Henry's "aha moment" - speaking brand values instead of typing them

---

## Overview

The Voice Input System provides speech-to-text transcription using OpenAI Whisper, enabling users to speak their inputs instead of typing. This is particularly valuable for:

- Brand value articulation (7f-brand-system-generator skill)
- Long-form content creation
- Brainstorming sessions
- Accessibility (users who prefer speaking to typing)

---

## Installation

### Prerequisites

```bash
# Install OpenAI Whisper
pip install openai-whisper

# Verify installation
whisper --help

# Test audio devices
arecord -l
```

### Required Audio Tools

- **arecord** (ALSA recording tool) - Usually pre-installed on Linux
- **ffmpeg** - For audio format conversion
- Alternative: **parecord** (PulseAudio)

---

## Usage

### Basic Usage

```bash
# Record and transcribe (press Ctrl+C to stop)
./scripts/voice-input.sh

# Specify output file
./scripts/voice-input.sh --output my-brand-values.txt

# Use smaller/faster model
./scripts/voice-input.sh --model tiny

# Specify language (skip auto-detection)
./scripts/voice-input.sh --language en

# Limit recording duration (5 minutes)
./scripts/voice-input.sh --duration 300
```

### Advanced Options

```bash
# Full example
./scripts/voice-input.sh \
  --model small \
  --output brand-input.txt \
  --language en \
  --duration 600
```

---

## Integration with Claude Skills

### 7f-brand-system-generator Integration

**Scenario:** Henry wants to articulate Seven Fortunas brand values by speaking instead of typing.

#### Step 1: Record Voice Input

```bash
cd /path/to/seven-fortunas-brain

# Start voice recording
./scripts/voice-input.sh --output .claude/brand-voice-input.txt
```

**User experience:**
```
==========================================
Voice Input System - OpenAI Whisper
==========================================

Model: base
Language: auto
Max Duration: 600 seconds (10 minutes)

Recording... Press Ctrl+C to stop

Speak clearly into your microphone.
Press Ctrl+C when finished speaking.

```

#### Step 2: Speak Your Content

Henry speaks for 5-7 minutes, articulating:
- Core values
- Brand personality
- Target audience
- Vision and mission

#### Step 3: Stop Recording

Press **Ctrl+C** to stop recording. The system will:
1. Save the audio file
2. Transcribe using Whisper
3. Check confidence score
4. Save transcript to `.claude/brand-voice-input.txt`

#### Step 4: Review Transcript

If confidence < 80%, the system prompts:

```
⚠️  WARNING: Low transcription confidence
Confidence score: 75%

Transcript preview:
-------------------
Seven Fortunas is about digital inclusion for marginalized
communities. We believe everyone deserves access to AI tools
and financial services...
-------------------

Options:
1. Accept transcript as-is (press Enter)
2. Edit transcript (type 'edit')
3. Re-record (type 'retry')

Choice:
```

#### Step 5: Feed to Brand Generator Skill

```bash
# Use transcribed content with brand generator skill
cat .claude/brand-voice-input.txt | /path/to/7f-brand-system-generator
```

Or manually copy content into Claude conversation.

---

## Failure Scenarios & Recovery

### 1. Whisper Not Installed

**Error:**
```
✗ ERROR: OpenAI Whisper is not installed

Fallback: Please install Whisper or use typing mode

Installation: pip install openai-whisper

Switching to typing mode...
Enter your text (Ctrl+D when done):
```

**Recovery:** Install Whisper or type content manually

---

### 2. No Audio Device Found

**Error:**
```
✗ ERROR: No audio recording device found

Troubleshooting:
1. Check if microphone is connected
2. Verify permissions: usermod -a -G audio $USER
3. Test with: arecord -l
4. Check PulseAudio: pactl list sources

Fallback: Switching to typing mode...
```

**Recovery:**
```bash
# Check audio devices
arecord -l

# List PulseAudio sources
pactl list sources

# Add user to audio group
sudo usermod -a -G audio $USER
```

---

### 3. Recording Interrupted

**Scenario:** User accidentally presses Ctrl+C mid-sentence

**Behavior:**
```
Recording interrupted. Processing partial audio...
✓ Recording completed. Transcribing...
```

**Result:** Partial transcript is still generated and saved

---

### 4. Transcription Failed

**Error:**
```
✗ ERROR: Transcription failed

Audio file preserved: /tmp/voice-recording-1677123456.wav

Retry options:
1. Try with smaller model: --model tiny
2. Specify language: --language en
3. Check audio quality: play /tmp/voice-recording-1677123456.wav

Fallback: Please type your content manually
```

**Recovery:**
```bash
# Try again with smaller model
./scripts/voice-input.sh --model tiny

# Or manually play and type
play /tmp/voice-recording-1677123456.wav
```

---

### 5. Low Confidence (<80%)

**Warning:**
```
⚠️  WARNING: Low transcription confidence
Confidence score: 72%
```

**Options:**
1. **Accept** - Use transcript as-is
2. **Edit** - Opens transcript in text editor for manual correction
3. **Retry** - Re-record audio

---

## Model Selection Guide

| Model  | Speed | Accuracy | Memory | Use Case |
|--------|-------|----------|--------|----------|
| tiny   | 32x   | Lower    | 39MB   | Quick notes, testing |
| base   | 16x   | Good     | 74MB   | **Default** - balanced |
| small  | 6x    | Better   | 244MB  | High-quality transcription |
| medium | 2x    | High     | 769MB  | Professional use |
| large  | 1x    | Highest  | 1550MB | Maximum accuracy |

**Recommendation:** Use `base` model for most cases. Upgrade to `small` if accuracy is critical.

---

## Performance Characteristics

- **Recording:** Real-time (limited by `--duration` parameter)
- **Transcription:** ~10-30 seconds per minute of audio (depends on model)
- **Confidence:** Typically 85-95% for clear speech in quiet environment

---

## Troubleshooting

### Audio Quality Issues

```bash
# Test microphone
arecord -d 5 test.wav && play test.wav

# Adjust recording quality (if needed)
# Edit voice-input.sh, line with 'arecord -f cd'
# Options: -f cd (CD quality), -f dat (DAT quality)
```

### Whisper Model Download

First run will download model files (~74MB for base model):

```
Downloading model...
100%|████████████████████████████████| 74MB/74MB
```

Models are cached in `~/.cache/whisper/`

---

## Integration Checklist

- [x] OpenAI Whisper installed and functional
- [x] Audio recording devices configured
- [x] Voice input script created and executable
- [x] 5 failure scenarios handled with fallbacks
- [x] Confidence scoring implemented (<80% warning)
- [x] Typing mode fallback available
- [x] Documentation completed

---

## Future Enhancements (Phase 2)

- [ ] Real-time transcription (streaming)
- [ ] Speaker diarization (multi-speaker support)
- [ ] Custom vocabulary/prompt for domain-specific terms
- [ ] Integration with Claude Desktop app
- [ ] Voice commands for skill invocation

---

**Last Updated:** 2026-02-26
**Maintainer:** Jorge (VP AI-SecOps)
