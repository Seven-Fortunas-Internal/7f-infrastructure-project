---
name: 'pptx-generator'
description: 'Generate PowerPoint presentations from markdown content (adapted from BMAD)'
source_bmad_skill: 'bmad-bmm-create-presentation'
---

# PowerPoint Generator

**Skill ID:** 7f-pptx-generator
**Purpose:** Generate professional PowerPoint presentations from markdown
**Owner:** Seven Fortunas Team
**Type:** Adapted BMAD Skill

---

## Overview

This skill converts markdown documents into professional PowerPoint presentations:
- Automatic slide generation from markdown headers
- Theme application (Seven Fortunas branding)
- Image and diagram insertion
- Speaker notes from comments
- Export to PPTX format

---

## Usage

Invoke this skill from Claude Code:
```
/7f-pptx-generator <markdown-file>
```

---

## Implementation

When invoked, this skill:

1. **Parses markdown file** - Extracts structure, content, images
2. **Generates slide outline** - Maps headers to slides
3. **Applies brand theme** - Seven Fortunas colors, fonts, logo
4. **Creates presentation** - Builds PPTX with python-pptx library
5. **Exports file** - Saves to `presentations/` directory

---

## Outputs

- `presentations/<filename>.pptx` - Generated PowerPoint file
- `presentations/<filename>-notes.md` - Speaker notes reference

---

## Integration

- Reads from: Markdown files, brand assets
- Writes to: presentations/ directory
- Dependencies: python-pptx library, brand theme templates

---

**Note:** This is an adapted BMAD skill specialized for Seven Fortunas presentations.
Invoke with `/7f-pptx-generator` from the Claude Code interface.
