---
description: "Meta-skill: Create new Seven Fortunas skills from YAML specifications"
tags: ["meta-skill", "skill-creation", "automation", "bmad"]
source: "Adapted from BMAD workflow-create-workflow"
---

# Skill Creator Skill (Meta-Skill)

Create new Seven Fortunas skills from YAML specifications. This is a "meta-skill" that generates other skills.

## Usage

**Create Skill:**
```bash
# Interactive mode - asks questions about the skill
/7f-skill-creator

# From YAML specification
/7f-skill-creator --spec="skill-spec.yaml"

# Quick skill from description
/7f-skill-creator --name="my-skill" --description="Does something useful"
```

## Features

- ✅ **YAML-Driven:** Define skills declaratively
- ✅ **Template Library:** Reuse patterns from existing skills
- ✅ **Duplicate Prevention:** Searches existing skills before creating
- ✅ **BMAD Integration:** Can reference BMAD workflows
- ✅ **Validation:** Checks skill structure and conventions

## YAML Specification Format

```yaml
skill:
  name: "7f-my-skill"
  description: "Short description of what the skill does"
  tags: ["tag1", "tag2"]

  usage:
    command: "/7f-my-skill"
    parameters:
      - name: "--input"
        description: "Input file path"
        required: true

  implementation:
    type: "script"  # or "bmad-workflow"
    path: "scripts/my_skill.py"

  integration:
    - "FR-X.Y: Related feature"
```

## Output

```
.claude/commands/7f-{skill-name}.md
```

If implementation specified:
```
scripts/{skill-name}.py
```

## Skill Search

Before creating a new skill, the skill creator:
1. Searches existing .claude/commands/7f-*.md files
2. Searches BMAD library for similar workflows
3. Suggests existing skills if duplicates found
4. Prevents duplicate skill creation

## Integration

- **BMAD Library:** Can reference and wrap BMAD workflows
- **Skill Governance:** Follows governance rules (SKILL-GOVERNANCE.md)
- **Based on:** BMAD bmb/workflows/workflow/workflow-create-workflow

## Implementation

The skill creator is implemented as a Python script with fuzzy matching:

```bash
python3 scripts/create-skill.py
```

**Modes:**
- **Interactive:** Prompts for skill details with search-before-create validation
- **Quick:** `--name "7f-my-skill" --description "..." --tags "..."`
- **YAML Spec:** `--spec="skill-spec.yaml"`
- **Search Only:** `--search "dashboard"` (find similar skills)
- **List All:** `--list` (see all existing skills)

**Fuzzy Matching:** Uses Python's difflib to find similar skills by name and description

---

**Status:** ✅ FULLY IMPLEMENTED (create-skill.py with fuzzy matching)
**Source:** /home/ladmin/dev/GDF/7F_github/scripts/create-skill.py
