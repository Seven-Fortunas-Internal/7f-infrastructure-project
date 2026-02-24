# 7f-skill-creator

**Seven Fortunas Custom Skill** - Generate new Claude Code skills from YAML definitions

---

## Metadata

```yaml
source_bmad_skill: bmad-bmb-workflow-builder
adapted_by: Seven Fortunas Infrastructure Team
version: 1.0.0
created: 2026-02-17
integration: .claude/commands/
```

---

## Purpose

Automate the creation of new Claude Code skills following Seven Fortunas conventions and BMAD patterns. Generate skill markdown files from structured YAML definitions.

---

## Usage

```bash
/7f-skill-creator <skill-definition.yaml>
```

**Arguments:**
- `<skill-definition.yaml>`: Path to YAML file defining the skill

---

## Workflow

### 0. Search Before Create (IMPORTANT!)

**Before creating a new skill, search existing skills to avoid duplication.**

**Search steps:**
1. Check `.claude/commands/README.md` for skills by category
2. Search `skills-registry.yaml` for similar use cases:
   ```bash
   grep -i "keyword" .claude/commands/skills-registry.yaml
   ```
3. List category directories:
   ```bash
   ls .claude/commands/{7f,bmm,bmb,cis}/
   ```

**Create only if:**
- ✅ No existing skill covers the use case
- ✅ Existing skill is too generic (need specialization)
- ✅ New workflow pattern from repeated tasks
- ✅ Seven Fortunas-specific customization needed

**DON'T create if:**
- ❌ Similar skill exists (adapt it instead)
- ❌ One-time or rare use case
- ❌ <3 distinct use cases
- ❌ Can add as option to existing skill

### 1. Parse YAML Definition

**Example skill-definition.yaml:**
```yaml
skill:
  name: 7f-example-skill
  purpose: Brief description of what the skill does
  category: Infrastructure # or Integration, Documentation, Security

  source:
    bmad_skill: bmad-module-workflow-name # if adapted from BMAD
    original: true # if brand new skill

  usage:
    command: /7f-example-skill <arg1> [--flag]
    arguments:
      - name: arg1
        type: required
        description: Description of argument
    flags:
      - name: --flag
        description: Optional flag
        default: false

  workflow_steps:
    - step: 1
      title: Initialize
      actions:
        - Prompt for required information
        - Validate inputs
    - step: 2
      title: Process
      actions:
        - Perform main task
        - Generate output
    - step: 3
      title: Save & Verify
      actions:
        - Save to appropriate location
        - Run verification checks

  integration:
    second_brain: Concepts/ # or Processes/, Outputs/, etc.
    bmad_library: true
    dependencies:
      - FR-3.1
      - FR-2.1

  error_handling:
    - error: Input validation failure
      action: Prompt for correct input
    - error: Output directory missing
      action: Create directory automatically

  examples:
    - description: Basic usage
      command: /7f-example-skill input.txt
    - description: With flags
      command: /7f-example-skill input.txt --flag --output custom.md
```

### 2. Validate YAML Structure

Check for required fields:
- skill.name (must start with 7f-)
- skill.purpose
- skill.usage.command
- skill.workflow_steps (at least 1 step)

### 3. Generate Skill Markdown

Create skill file at:
```
.claude/commands/[skill-name].md
```

**Generated Structure:**
```markdown
# [skill-name]

**Seven Fortunas Custom Skill** - [purpose]

---

## Metadata

```yaml
source_bmad_skill: [if adapted]
adapted_by: Seven Fortunas Infrastructure Team
version: 1.0.0
created: [date]
integration: [integration point]
```

---

## Purpose

[Detailed purpose from YAML]

---

## Usage

```bash
[usage command from YAML]
```

**Arguments:**
[Generated from YAML arguments section]

**Flags:**
[Generated from YAML flags section]

---

## Workflow

[Generated from workflow_steps in YAML]

---

## Error Handling

[Generated from error_handling in YAML]

---

## Integration Points

[Generated from integration section]

---

## Example Usage

[Generated from examples in YAML]

---

## Dependencies

[Generated from dependencies list]

---

## Notes

[Auto-generated notes about the skill]
```

### 4. Create Skill Stub (if BMAD-based)

If skill references a BMAD workflow, create stub:
```markdown
# [skill-name]

This skill invokes the BMAD workflow:
@[project-root]/_bmad/[module]/workflows/[workflow-name]/
```

### 5. Verification

- Validate markdown syntax
- Check file created successfully
- Verify skill is invocable (/skill-name)
- Test basic functionality

### 6. Documentation

Append to skill registry:
```
.claude/commands/SKILL-REGISTRY.md
```

With entry:
```markdown
### [skill-name]
- **Category:** [category]
- **Purpose:** [purpose]
- **Command:** /[skill-name]
- **Created:** [date]
- **Source:** [BMAD/Original]
```

---

## Validation Rules

**Skill Name:**
- Must start with `7f-`
- Lowercase with hyphens
- No spaces or special characters
- Maximum 50 characters

**Purpose:**
- 1-2 sentences
- Clear and actionable
- No jargon without definition

**Workflow Steps:**
- Numbered sequentially
- Each step has title and actions
- Actions are specific and testable

**Examples:**
- At least 1 example required
- Examples must be valid command syntax
- Examples should cover common use cases

---

## Error Handling

**YAML Errors:**
- Invalid syntax: Display line number and error
- Missing required fields: List missing fields
- Invalid structure: Show expected structure

**Generation Errors:**
- File already exists: Prompt for overwrite
- Directory write denied: Display permission error
- Invalid markdown generated: Attempt to fix, fallback to manual

**Verification Errors:**
- Skill not invocable: Check file location and syntax
- BMAD workflow not found: Verify workflow path
- Dependency not satisfied: List unsatisfied dependencies

---

## Integration Points

- **Claude Code:** Creates .claude/commands/ skills
- **BMAD Library:** Can reference BMAD workflows
- **Second Brain:** Skills integrate with Brain structure

---

## Example Usage

```bash
# Create skill from YAML definition
/7f-skill-creator ~/docs/new-skill.yaml

# Validate YAML without generating
/7f-skill-creator ~/docs/new-skill.yaml --validate-only

# Force overwrite existing skill
/7f-skill-creator ~/docs/new-skill.yaml --force
```

---

## Example YAML Files

**Example 1: Simple Documentation Skill**
```yaml
skill:
  name: 7f-release-notes
  purpose: Generate release notes from git commits
  category: Documentation
  source:
    original: true
  usage:
    command: /7f-release-notes <from-tag> <to-tag>
    arguments:
      - name: from-tag
        type: required
        description: Starting git tag
      - name: to-tag
        type: required
        description: Ending git tag
  workflow_steps:
    - step: 1
      title: Fetch Commits
      actions:
        - Run git log between tags
        - Parse commit messages
    - step: 2
      title: Categorize
      actions:
        - Group by type (feat, fix, docs)
        - Sort by impact
    - step: 3
      title: Generate Notes
      actions:
        - Create markdown document
        - Save to Outputs/Release-Notes/
  integration:
    second_brain: Outputs/Release-Notes/
    bmad_library: false
```

**Example 2: BMAD-Adapted Skill**
```yaml
skill:
  name: 7f-architecture-doc
  purpose: Generate architecture documentation from system description
  category: Documentation
  source:
    bmad_skill: bmad-bmm-architecture
  usage:
    command: /7f-architecture-doc [--template <type>]
  workflow_steps:
    - step: 1
      title: Discover System
      actions:
        - Load BMAD architecture workflow
        - Gather system information
    - step: 2
      title: Generate Diagrams
      actions:
        - Create Excalidraw diagrams
        - Generate C4 models
    - step: 3
      title: Document Architecture
      actions:
        - Write architecture decision records
        - Save to Second Brain
  integration:
    second_brain: Concepts/Architecture/
    bmad_library: true
    dependencies:
      - FR-3.1
```

---

## Dependencies

- BMAD Library (FR-3.1) ✅
- YAML parser (PyYAML)
- Markdown validator

---

## Notes

This meta-skill automates skill creation, ensuring consistency across all Seven Fortunas custom skills. It enforces naming conventions, structure, and documentation standards.

The generated skills are immediately usable and follow the same patterns as BMAD workflows, making them familiar to users already working with BMAD.

**Pro Tip:** Use this skill to rapidly prototype new capabilities and iterate on skill designs. The YAML format makes it easy to version control and review skill definitions.
