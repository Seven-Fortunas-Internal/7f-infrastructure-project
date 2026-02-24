---
name: 'skill-creator'
description: 'Generate new Claude Code skills from YAML specifications (adapted from BMAD workflow-creator)'
source_bmad_skill: 'bmad-bmb-create-workflow'
---

# Skill Creator

**Skill ID:** 7f-skill-creator
**Purpose:** Generate new Claude Code skills from YAML specifications
**Owner:** Seven Fortunas Team
**Type:** Adapted BMAD Skill

---

## Overview

This skill creates new Claude Code skills by:
- Parsing YAML skill specifications
- Generating skill markdown stub files
- Creating workflow/implementation files (if needed)
- Validating skill structure
- Registering skills in skills-registry.yaml

---

## Usage

Invoke this skill from Claude Code:
```
/7f-skill-creator <skill-spec.yaml>
```

---

## YAML Skill Specification Format

```yaml
skill:
  id: "7f-example-skill"
  name: "Example Skill"
  description: "Brief description of what this skill does"
  owner: "Team Name"
  type: "custom | adapted"
  source_bmad_skill: "bmad-skill-name"  # if adapted

  inputs:
    - name: "input1"
      description: "Description of input"
      required: true

  outputs:
    - name: "output1"
      path: "path/to/output"
      format: "markdown | json | yaml"

  implementation:
    type: "script | workflow | manual"
    path: "scripts/example.py"  # if script

  integration:
    reads_from: []
    writes_to: []
    dependencies: []
```

---

## Implementation

When invoked, this skill:

1. **Parses YAML spec** - Validates structure and required fields
2. **Generates skill stub** - Creates .claude/commands/<skill-id>.md
3. **Creates implementation files** - Scripts, workflows (if specified)
4. **Validates skill** - Checks references, dependencies
5. **Updates registry** - Adds to skills-registry.yaml
6. **Outputs documentation** - Generates skill README

---

## Outputs

- `.claude/commands/<skill-id>.md` - Skill stub file
- `scripts/<skill-id>.py` - Implementation script (if applicable)
- `docs/skills/<skill-id>.md` - Skill documentation
- Updated `skills-registry.yaml` - Registry entry

---

## Integration

- Reads from: YAML skill specifications
- Writes to: .claude/commands/, scripts/, docs/skills/
- Validates: Skill structure, dependencies, BMAD compliance

---

## Example

```bash
# Create skill from YAML spec
/7f-skill-creator skill-specs/7f-custom-analyzer.yaml

# Output:
# ✓ Parsed YAML specification
# ✓ Generated skill stub: .claude/commands/7f-custom-analyzer.md
# ✓ Created implementation: scripts/7f-custom-analyzer.py
# ✓ Updated skills registry
# ✓ Generated documentation: docs/skills/7f-custom-analyzer.md
```

---

**Note:** This is an adapted BMAD skill specialized for Seven Fortunas skill creation.
Invoke with `/7f-skill-creator` from the Claude Code interface.
