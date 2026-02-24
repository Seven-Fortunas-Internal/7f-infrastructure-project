# 7f-brand-system-generator

**Seven Fortunas Custom Skill** - Generate comprehensive brand system documentation

---

## Metadata

```yaml
source_bmad_skill: bmad-cis-storytelling-brand-narrative
adapted_by: Seven Fortunas Infrastructure Team
version: 1.0.0
created: 2026-02-17
integration: Second Brain (Concepts/Brand-System/)
```

---

## Purpose

Generate a comprehensive brand system document including:
- Brand narrative and positioning
- Voice and tone guidelines
- Visual identity specifications
- Messaging framework
- Usage examples

---

## Usage

```bash
/7f-brand-system-generator [--voice]
```

**Flags:**
- `--voice`: Enable voice input mode (requires OpenAI Whisper)

---

## Workflow

### 1. Input Collection

**Interactive Mode (default):**
- Prompt for brand name
- Ask about company mission and values
- Gather target audience information
- Collect competitive positioning

**Voice Mode (`--voice` flag):**
- Invoke voice-input-handler.sh script
- Display: "Recording... Press Ctrl+C to stop"
- Record audio for 5-10 minutes
- Transcribe using OpenAI Whisper
- Display confidence score (warn if <80%)
- Offer review and re-record option
- Fallback to text mode on error (press 'T')
- Script location: `scripts/voice-input-handler.sh`

### 2. Brand System Generation

Generate structured markdown document with:

```markdown
# [Brand Name] Brand System

## Brand Narrative
[Compelling story about the brand]

## Mission & Values
- Mission: [Core purpose]
- Values: [3-5 key values]

## Voice & Tone
- Personality: [Brand personality traits]
- Voice: [How the brand speaks]
- Tone variations: [Formal, casual, technical, etc.]

## Visual Identity
- Color palette
- Typography
- Logo usage
- Imagery style

## Messaging Framework
- Tagline
- Value propositions
- Key messages by audience

## Usage Examples
- Social media posts
- Email templates
- Marketing copy
```

### 3. Save to Second Brain

Save output to:
```
~/seven-fortunas-workspace/seven-fortunas-brain/Concepts/Brand-System/[brand-name]-brand-system.md
```

### 4. Verification

- Validate YAML frontmatter
- Check markdown structure
- Ensure all sections present
- Verify file saved to correct location

---

## Error Handling

**Voice Mode Failures:**
1. **No microphone:** Auto-fallback to text input
2. **Whisper missing:** Prompt for installation, fallback to text
3. **Poor audio quality:** Display confidence warning, offer re-record
4. **Silence detected:** Offer re-record option
5. **Manual fallback:** Press 'T' during recording to switch to text

**File System Failures:**
- Create missing directories automatically
- Warn if file already exists, offer to overwrite
- Validate write permissions

---

## Integration Points

- **Second Brain:** Saves to Concepts/Brand-System/
- **BMAD Library:** Leverages CIS storytelling patterns
- **Voice Input:** Optional Whisper integration

---

## Example Usage

```bash
# Text input mode
/7f-brand-system-generator

# Voice input mode
/7f-brand-system-generator --voice
```

---

## Dependencies

- BMAD Library (FR-3.1) ✅
- Second Brain Structure (FR-2.1) ✅
- Voice Input System (FR-2.3) ✅
- OpenAI Whisper (optional, for --voice flag)
- voice-input-handler.sh script (included)

---

## Notes

This skill adapts BMAD's storytelling and brand narrative workflows for the Seven Fortunas ecosystem. It follows the progressive disclosure pattern and integrates with the Second Brain knowledge structure.
