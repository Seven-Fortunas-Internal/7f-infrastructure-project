---
name: 'brand-system-generator'
description: 'Generate comprehensive brand system from company information (adapted from BMAD)'
source_bmad_skill: 'bmad-bmm-create-brand-system'
---

# Brand System Generator

**Skill ID:** 7f-brand-system-generator
**Purpose:** Generate comprehensive brand system for Seven Fortunas
**Owner:** Henry
**Type:** Adapted BMAD Skill

---

## Overview

This skill generates a complete brand system including:
- Brand identity (logo, colors, typography)
- Brand messaging (mission, vision, values, taglines)
- Brand voice and tone guidelines
- Brand positioning and differentiation
- Visual identity system

---

## Usage

Invoke this skill from Claude Code:
```
/7f-brand-system-generator
```

---

## Implementation

When invoked, this skill:

1. **Collects company information** - Name, industry, target audience, values
2. **Analyzes competitive landscape** - Key competitors and differentiation
3. **Generates brand elements** - Identity, messaging, voice, positioning
4. **Creates brand guide document** - Comprehensive brand system documentation
5. **Outputs to Second Brain** - Saves to `second-brain-core/brand/`

---

## Outputs

- `second-brain-core/brand/brand-system.md` - Complete brand system
- `second-brain-core/brand/tone-of-voice.md` - Voice and tone guidelines
- `second-brain-core/brand/README.md` - Brand guide index

---

## Integration

- Reads from: Company information, competitive analysis
- Writes to: Second Brain brand directory
- References: BMAD brand creation workflows

---

**Note:** This is an adapted BMAD skill specialized for Seven Fortunas brand creation.
Invoke with `/7f-brand-system-generator` from the Claude Code interface.
