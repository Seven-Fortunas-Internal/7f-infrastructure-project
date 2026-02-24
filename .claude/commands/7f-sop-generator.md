---
name: 'sop-generator'
description: 'Generate Standard Operating Procedures from process descriptions (adapted from BMAD)'
source_bmad_skill: 'bmad-bmm-create-sop'
---

# SOP Generator

**Skill ID:** 7f-sop-generator
**Purpose:** Generate comprehensive Standard Operating Procedures
**Owner:** Jorge (VP AI-SecOps)
**Type:** Adapted BMAD Skill

---

## Overview

This skill generates structured SOPs with:
- Purpose and scope definition
- Step-by-step procedures
- Prerequisites and requirements
- Safety and security considerations
- Verification and validation steps
- Troubleshooting guide

---

## Usage

Invoke this skill from Claude Code:
```
/7f-sop-generator <process-name> <process-description>
```

---

## Implementation

When invoked, this skill:

1. **Analyzes process** - Breaks down into discrete steps
2. **Identifies requirements** - Prerequisites, tools, permissions
3. **Structures SOP** - Applies standard SOP template
4. **Adds safety checks** - Security and compliance considerations
5. **Outputs to Second Brain** - Saves to `second-brain-core/operations/`

---

## Outputs

- `second-brain-core/operations/<process-name>-sop.md` - Complete SOP
- YAML frontmatter with context-level, relevant-for, author, status fields

---

## Integration

- Reads from: Process descriptions, runbook templates
- Writes to: Second Brain operations directory
- Format: Markdown with YAML frontmatter (FR-2.2 compliant)

---

**Note:** This is an adapted BMAD skill specialized for Seven Fortunas operational procedures.
Invoke with `/7f-sop-generator` from the Claude Code interface.
