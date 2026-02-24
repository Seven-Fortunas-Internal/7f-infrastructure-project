---
name: 'excalidraw-generator'
description: 'Generate Excalidraw diagrams from text descriptions (adapted from BMAD)'
source_bmad_skill: 'bmad-bmm-create-diagram'
---

# Excalidraw Generator

**Skill ID:** 7f-excalidraw-generator
**Purpose:** Generate Excalidraw diagrams from natural language descriptions
**Owner:** Seven Fortunas Team
**Type:** Adapted BMAD Skill

---

## Overview

This skill generates Excalidraw diagrams from text descriptions:
- System architecture diagrams
- Workflow flowcharts
- Entity relationship diagrams
- Network diagrams
- Process flows

---

## Usage

Invoke this skill from Claude Code:
```
/7f-excalidraw-generator <description> <diagram-type>
```

---

## Implementation

When invoked, this skill:

1. **Parses description** - Extracts entities, relationships, flow
2. **Determines diagram type** - Architecture, flowchart, ERD, etc.
3. **Generates Excalidraw JSON** - Creates diagram structure
4. **Applies styling** - Seven Fortunas color scheme
5. **Exports file** - Saves to `docs/diagrams/` directory

---

## Outputs

- `docs/diagrams/<name>.excalidraw` - Excalidraw diagram file
- `docs/diagrams/<name>.png` - PNG export (if requested)

---

## Integration

- Reads from: Text descriptions, architecture documents
- Writes to: docs/diagrams/ directory
- Format: Excalidraw JSON format

---

**Note:** This is an adapted BMAD skill specialized for Seven Fortunas diagram generation.
Invoke with `/7f-excalidraw-generator` from the Claude Code interface.
