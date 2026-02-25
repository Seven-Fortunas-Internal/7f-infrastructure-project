---
description: "Generate comprehensive brand system guidelines for Seven Fortunas projects"
tags: ["branding", "design-system", "guidelines", "seven-fortunas"]
source: "Adapted from BMAD CIS workflows"
---

# Brand System Generator Skill

Generate comprehensive brand system guidelines for Seven Fortunas projects, including:
- **Brand Identity:** Logo usage, color palette, typography
- **Voice & Tone:** Communication style guidelines
- **Visual Guidelines:** Image styles, icon usage, spacing rules
- **Application Examples:** Web, mobile, print materials

## Usage

This skill guides you through creating a complete brand system document.

**Generate Brand System:**
```bash
# Interactive mode - asks questions about your brand
/7f-brand-system-generator
```

**With Parameters:**
```bash
# For specific project or product
/7f-brand-system-generator --project="Seven Fortunas Platform"

# Voice Mode - use voice input instead of typing
/7f-brand-system-generator --voice
```

## Features

- ✅ **Interactive Questionnaire:** Gathers brand attributes through guided prompts
- ✅ **Voice Mode:** Use OpenAI Whisper for voice-to-text input (see Voice Input section)
- ✅ **Comprehensive Output:** Generates complete brand system markdown document
- ✅ **Seven Fortunas Standards:** Follows Seven Fortunas design language
- ✅ **Export Formats:** Markdown, PDF, and web-ready HTML

## Voice Input

Use `--voice` flag to enable voice input mode powered by OpenAI Whisper.

**Workflow:**
1. Start recording: displays "Recording... Press Ctrl+C to stop"
2. Speak for 5-10 minutes
3. Press Ctrl+C to stop recording
4. Review transcript with confidence score
5. Confirm or re-record

**Failure Handling:**
- **No microphone:** Auto-fallback to text input
- **Whisper missing:** Installation prompt, then text fallback
- **Poor audio (confidence < 80%):** Warning displayed, option to re-record
- **Silence detected:** Offer to re-record or switch to text
- **Manual fallback:** Press 'T' during recording to switch to text input

**Implementation:** Uses `scripts/voice-input-handler.sh`

## Output

Brand system document saved to:
```
docs/brand/brand-system-{project-name}.md
```

## Integration

- **Works with:** 7f-pptx-generator (applies brand to presentations)
- **References:** Seven Fortunas brand assets in `docs/brand/assets/`
- **Based on:** BMAD Creative Intelligence System (CIS) workflows

---

**Status:** MVP (Placeholder - Full implementation pending)
**Source:** Adapted from BMAD bmm/workflows/create-brand-system
