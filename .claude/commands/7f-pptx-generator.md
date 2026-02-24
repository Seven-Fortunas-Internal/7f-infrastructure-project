---
description: "Generate PowerPoint presentations with Seven Fortunas branding"
tags: ["powerpoint", "presentation", "slides", "branding"]
source: "Adapted from BMAD CIS workflows"
---

# PowerPoint Generator Skill

Generate professional PowerPoint presentations with Seven Fortunas branding applied automatically.

## Usage

**Generate Presentation:**
```bash
# Interactive mode
/7f-pptx-generator

# With outline file
/7f-pptx-generator --outline="presentation-outline.md"

# Quick pitch deck
/7f-pptx-generator --type="pitch" --slides=10
```

## Features

- ✅ **Brand Application:** Applies Seven Fortunas colors, fonts, and logo automatically
- ✅ **Template Library:** Choose from multiple presentation types (pitch, technical, training)
- ✅ **Markdown Input:** Convert markdown outlines to slides
- ✅ **Export Formats:** PPTX and PDF

## Output

```
docs/presentations/
├── {project-name}.pptx
└── {project-name}.pdf
```

## Integration

- **Uses:** 7f-brand-system-generator for brand guidelines
- **Integrates with:** Google Slides (export compatible)
- **Based on:** BMAD Creative Intelligence System workflows

---

**Status:** MVP (Placeholder - Full implementation pending)
**Source:** Adapted from BMAD cis/workflows/create-presentation
