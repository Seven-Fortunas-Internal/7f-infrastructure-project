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
```

## Features

- ✅ **Interactive Questionnaire:** Gathers brand attributes through guided prompts
- ✅ **Comprehensive Output:** Generates complete brand system markdown document
- ✅ **Seven Fortunas Standards:** Follows Seven Fortunas design language
- ✅ **Export Formats:** Markdown, PDF, and web-ready HTML

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
