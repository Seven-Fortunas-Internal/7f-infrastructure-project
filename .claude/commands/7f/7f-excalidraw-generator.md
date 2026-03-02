---
description: "Generate Excalidraw diagrams for architecture, workflows, and system designs"
tags: ["excalidraw", "diagrams", "architecture", "visualization"]
source: "Adapted from BMAD CIS workflows"
---

# Excalidraw Generator Skill

Generate professional Excalidraw diagrams for:
- **System Architecture:** Infrastructure diagrams, service maps
- **Workflows:** Process flows, user journeys
- **Data Models:** Database schemas, data flow diagrams
- **UI/UX:** Wireframes, user interface mockups

## Usage

**Generate Diagram:**
```bash
# Interactive mode
/7f-excalidraw-generator

# Specific diagram type
/7f-excalidraw-generator --type="architecture" --project="Seven Fortunas Platform"

# From description
/7f-excalidraw-generator --description="User authentication flow with OAuth"
```

## Features

- ✅ **Template Library:** Pre-built templates for common diagram types
- ✅ **AI-Assisted Layout:** Intelligent component placement and routing
- ✅ **Brand Colors:** Uses Seven Fortunas color palette
- ✅ **Export Formats:** .excalidraw, PNG, SVG

## Output

```
docs/diagrams/
├── {diagram-name}.excalidraw
├── {diagram-name}.png
└── {diagram-name}.svg
```

## Integration

- **Editable:** Import .excalidraw files into Excalidraw.com
- **Documentation:** Embed diagrams in markdown docs
- **Based on:** BMAD Creative Intelligence System workflows

---

**Status:** MVP (Placeholder - Full implementation pending)
**Source:** Adapted from BMAD cis/workflows/create-diagram
