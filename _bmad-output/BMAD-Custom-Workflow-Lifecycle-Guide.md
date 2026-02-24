# BMAD Custom Workflow Lifecycle Guide

**Version:** 1.0
**Date:** 2026-02-14
**Purpose:** Complete process for creating, validating, distributing, and registering custom BMAD workflows

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Phase 1: Creating Custom Workflows](#phase-1-creating-custom-workflows)
4. [Phase 2: Validating Workflows](#phase-2-validating-workflows)
5. [Phase 3: Distributing Workflows](#phase-3-distributing-workflows)
6. [Phase 4: Registry Process](#phase-4-registry-process)
7. [Complete Example Walkthrough](#complete-example-walkthrough)
8. [Troubleshooting](#troubleshooting)
9. [Best Practices](#best-practices)

---

## Overview

This guide documents the **official BMAD-sanctioned process** for managing custom workflows from creation to distribution. Follow these steps exactly to ensure compliance with BMAD standards.

**The Four Phases:**

| Phase | Tool/Process | Output |
|-------|-------------|--------|
| 1. Create | `/bmad-bmb-create-workflow` | Workflow files in `_bmad-output/bmb-creations/workflows/` |
| 2. Validate | `/bmad-bmb-validate-workflow` | Validation report with compliance score |
| 3. Distribute | Manual `cp` commands | Workflow deployed to target project(s) |
| 4. Register | Manual edit of `bmad-help.csv` | Workflow discoverable via `/bmad-help` |

**Critical Rule:** ❌ **NEVER** create workflows manually or use made-up processes. ✅ **ALWAYS** use official BMAD workflows.

---

## Prerequisites

### Required BMAD Installation

Ensure BMAD is installed in your project:

```bash
cd /path/to/your/project
npx bmad-method install
```

### Verify BMAD Skills

Check that workflow creation/validation skills are available:

```bash
ls .claude/commands/bmad-bmb-*.md
```

You should see:
- `bmad-bmb-create-workflow.md`
- `bmad-bmb-validate-workflow.md`
- `bmad-bmb-edit-workflow.md`

### Required Knowledge

Before creating custom workflows, familiarize yourself with:
- BMAD tri-modal workflow structure (Create/Edit/Validate)
- BMAD step patterns (Init, Middle, Branch, Validation, Final)
- Frontmatter standards
- Menu handling standards
- File size guidelines (<200 lines recommended, 250 max)

---

## Phase 1: Creating Custom Workflows

### Step 1.1: Invoke the Creation Workflow

**In Claude Code, run:**

```
/bmad-bmb-create-workflow
```

**What this does:**
- Launches official BMAD workflow-create-workflow.md
- Guides you through 12+ steps of structured workflow design
- Ensures compliance with BMAD standards from the start

### Step 1.2: Follow the Creation Steps

The workflow will guide you through:

1. **Discovery** - Define what your workflow does
2. **Classification** - Determine module (BMM/BMB/CIS) and category
3. **Requirements Gathering** - Specify inputs, outputs, and constraints
4. **Tool Selection** - Choose which Claude tools the workflow needs
5. **Design** - Plan step sequence and decision points
6. **Foundation** - Create workflow.md with frontmatter
7. **Build Steps** - Create individual step files (step-01-init.md, step-02-..., etc.)

### Step 1.3: Output Location

Workflows are created in:

```
_bmad-output/bmb-creations/workflows/{workflow-name}/
```

**Standard structure:**
```
workflow-name/
├── workflow.md              # Main workflow entry point
├── steps-c/                 # Create mode steps
│   ├── step-01-init.md
│   ├── step-02-...
│   └── step-XX-final.md
├── steps-e/                 # Edit mode steps (if applicable)
├── steps-v/                 # Validate mode steps (if applicable)
├── data/                    # Reference data files
└── templates/               # Output templates
```

### Step 1.4: Critical Creation Rules

**Frontmatter Requirements:**

Every workflow.md must have:
```yaml
---
name: 'workflow-name'
description: 'Brief description (1-2 sentences)'
module: 'bmm|bmb|cis'
category: 'category-name'
modes: ['create', 'edit', 'validate']  # As applicable
version: '1.0'
---
```

Every step file must have:
```yaml
---
name: 'step-XX-name'
description: 'Step purpose'
nextStepFile: './step-XX-next.md'  # If not final step
---
```

**Menu Handling Requirements:**

After every menu display, add:
```markdown
#### Menu Handling Logic:

**EXECUTION RULES:**
- ALWAYS halt and wait for user input after presenting menu
- Process selection and route appropriately
```

**File Size Limits:**
- Recommended: <200 lines per file
- Maximum: 250 lines per file
- If exceeding, split into multiple steps

### Step 1.5: Example: Transcribe Audio Workflow

**Discovery answers:**
- Purpose: Transform audio files into structured markdown transcripts
- Module: BMM (Business Method Module)
- Category: Utilities
- Modes: Create, Edit, Validate

**Created structure:**
```
transcribe-audio/
├── workflow.md
├── steps-c/
│   ├── step-01-init.md
│   ├── step-02-validate-prerequisites.md
│   ├── step-03-input-discovery.md
│   ├── step-04-configuration.md
│   ├── step-05-transcription.md
│   ├── step-06-ai-analysis.md
│   └── step-07-output-summary.md
├── steps-e/
│   ├── step-01e-edit-init.md
│   ├── step-02e-select-transcript.md
│   └── step-03e-edit-complete.md
├── steps-v/
│   ├── step-01v-validate-init.md
│   ├── step-02v-run-validation.md
│   └── step-04b-display-validation-report.md
├── data/
│   ├── whisper-models.md
│   ├── language-codes.md
│   ├── output-formats.md
│   └── autonomous-mode-handling.md
└── templates/
    └── transcript-report-template.md
```

Total: 24 files created through the workflow

---

## Phase 2: Validating Workflows

### Step 2.1: Invoke the Validation Workflow

**In Claude Code, run:**

```
/bmad-bmb-validate-workflow
```

**What this does:**
- Launches official BMAD workflow-validate-workflow.md
- Performs 13 validation sections
- Generates compliance report with score

### Step 2.2: Provide Workflow Path

When prompted, provide the full absolute path:

```
/home/ladmin/dev/GDF/7F_github/_bmad-output/bmb-creations/workflows/transcribe-audio
```

### Step 2.3: Validation Sections

The workflow executes 13 validation checks:

| Section | Check | Pass Criteria |
|---------|-------|---------------|
| 01 | Structure Validation | Required directories and files exist |
| 02 | Frontmatter Validation | All required fields present |
| 03 | Workflow Entry Point | workflow.md is valid entry point |
| 04 | Step Sequence | Steps numbered correctly, no gaps |
| 05 | Step Type Patterns | Init/Middle/Branch/Final patterns correct |
| 06 | Cross-References | File references valid, no dead links |
| 07 | Menu Handling | Menus have proper handling sections |
| 08 | Tri-Modal Compliance | Modes declared match directories |
| 09 | File Size Standards | Files under recommended limits |
| 10 | Role Consistency | Agent roles consistent across workflow |
| 11 | Autonomous Mode Support | Autonomous handling if applicable |
| 12 | Critical Path Validation | End-to-end path walkable |
| 13 | Module Awareness | Module-specific standards met |

### Step 2.4: Validation Report Output

Report saved to:
```
_bmad-output/bmb-creations/workflows/{workflow-name}/validation-report-{date}.md
```

**Report format:**
```yaml
---
validationDate: 2026-02-14
workflowName: transcribe-audio
validationStatus: COMPLETE
validationScore: 87/100
overallStatus: APPROVED_WITH_REQUIRED_FIXES
criticalIssues: 3
warnings: 21
sectionsCompleted: 13
---
```

### Step 2.5: Interpreting Results

**Validation Status Levels:**

| Score | Status | Action Required |
|-------|--------|-----------------|
| 95-100 | APPROVED_EXCELLENT | None - ready to deploy |
| 85-94 | APPROVED_WITH_WARNINGS | Address warnings if feasible |
| 70-84 | APPROVED_WITH_REQUIRED_FIXES | Must fix critical issues before deploy |
| <70 | REJECTED | Major rework needed |

**Common Issues:**

1. **Frontmatter Issues (CRITICAL)**
   - Missing `name` or `description` fields
   - Empty frontmatter (`---\n---`)
   - Fix: Add complete frontmatter to all files

2. **Menu Handling Issues (WARNING)**
   - Menus missing "Menu Handling Logic" section
   - Fix: Add standardized menu handling sections

3. **File Size Issues (WARNING)**
   - Files exceeding 250 lines
   - Fix: Split into multiple steps if possible

### Step 2.6: Example: Transcribe Audio Validation

**Initial validation results:**
- Score: 87/100
- Status: APPROVED_WITH_REQUIRED_FIXES
- Critical issues: 3 (frontmatter violations)
- Warnings: 21 (15 menu handling, 6 file size)

**Fixes applied:**
1. Added complete frontmatter to 3 files
2. Added menu handling sections to 6 menus across 4 files

**Post-fix results:**
- Score: ~91/100
- Status: APPROVED_WITH_WARNINGS
- Frontmatter compliance: 100%
- Menu handling compliance: ~75%
- Ready for deployment

---

## Phase 3: Distributing Workflows

### Step 3.1: Manual Distribution Process

**IMPORTANT:** There is NO official BMAD workflow for distribution/packaging. The **BMAD-sanctioned method** is manual copying using `cp` commands.

### Step 3.2: Create Skill Stub

**Location:** `.claude/commands/bmad-{module}-{workflow-name}.md`

**Example:** `.claude/commands/bmad-bmm-transcribe-audio.md`

**Content:**
```markdown
# bmad-bmm-transcribe-audio

Transform audio files into structured markdown transcripts with optional AI-powered analysis using OpenAI Whisper.

**Module:** BMM (Business Method Module)
**Category:** Utilities
**Modes:** Create | Edit | Validate

## What This Workflow Does

- Transcribe audio files (MP3, M4A, WAV, AAC, etc.) into text
- Generate multiple output formats (TXT, SRT, VTT, JSON)
- Optional AI-powered analysis (summaries, action items, themes, quotes)
- Process single files, multiple files, or entire directories
- Autonomous mode for batch processing

## Usage

```
/bmad-bmm-transcribe-audio
```

Or with autonomous mode:
```
/bmad-bmm-transcribe-audio --autonomous --directory ~/audio-files
```

## Workflow Reference

Load and execute: @{project-root}/_bmad/bmm/workflows/utilities/transcribe-audio/workflow.md
```

**Key elements:**
- Brief description of what workflow does
- Module and category
- Usage examples
- Reference to workflow file using `@{project-root}/_bmad/...` path

### Step 3.3: Copy Workflow Directory

**Command structure:**

```bash
cp -r SOURCE_PATH TARGET_PATH
```

**Example:**

```bash
# Source: Where workflow was created
SOURCE="/home/ladmin/dev/GDF/7F_github/_bmad-output/bmb-creations/workflows/transcribe-audio"

# Target: Destination project's BMAD directory
TARGET="/home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/_bmad/bmm/workflows/utilities/"

# Copy workflow directory
cp -r "$SOURCE" "$TARGET"
```

**Path structure in target:**
```
{project-root}/_bmad/{module}/workflows/{category}/{workflow-name}/
```

### Step 3.4: Copy Skill Stub

**Command structure:**

```bash
cp SKILL_STUB_PATH TARGET_COMMANDS_DIR
```

**Example:**

```bash
# Source: Skill stub
SKILL="/home/ladmin/dev/GDF/7F_github/.claude/commands/bmad-bmm-transcribe-audio.md"

# Target: Destination project's commands directory
TARGET_CMDS="/home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/.claude/commands/"

# Copy skill stub
cp "$SKILL" "$TARGET_CMDS"
```

### Step 3.5: Verify Deployment

**Check workflow files:**

```bash
ls -la /path/to/target/_bmad/bmm/workflows/utilities/transcribe-audio/
```

**Check skill stub:**

```bash
ls -la /path/to/target/.claude/commands/bmad-bmm-transcribe-audio.md
```

**Test invocation:**

In Claude Code (in target project):
```
/bmad-bmm-transcribe-audio
```

Should load workflow.md and start step-01-init.md

### Step 3.6: Distribution Checklist

Before considering distribution complete:

- [ ] Skill stub created with proper content
- [ ] Workflow directory copied to target `_bmad/{module}/workflows/{category}/`
- [ ] Skill stub copied to target `.claude/commands/`
- [ ] Files verified at destination (ls -la)
- [ ] Skill invocation tested in target project
- [ ] Workflow loads and executes step-01-init.md

---

## Phase 4: Registry Process

### Step 4.1: Understanding BMAD Help Catalog

The `/bmad-help` skill uses `_bmad/_config/bmad-help.csv` to catalog all available workflows.

**Purpose:**
- Makes workflows discoverable
- Provides searchable catalog
- Shows usage examples
- Links to documentation

### Step 4.2: Locate bmad-help.csv

**File location:**
```
{project-root}/_bmad/_config/bmad-help.csv
```

**Note:** Some older BMAD installations may have this at `_bmad/core/data/bmad-help.csv`. Check both locations.

**If distributing to multiple projects, update each project's CSV.**

### Step 4.3: CSV Format

**Columns:**

| Column | Description | Example |
|--------|-------------|---------|
| module | BMAD module | bmm |
| phase | Workflow phase/category | anytime (or 1-analysis, 2-planning, etc.) |
| name | Display name | Transcribe Audio |
| code | Short code | TA |
| sequence | Sort order (numeric) | 10, 20, 30, etc. (leave empty for custom workflows) |
| workflow-file | Path to workflow.md | _bmad/bmm/workflows/utilities/transcribe-audio/workflow.md |
| command | Skill invocation name | bmad-bmm-transcribe-audio |
| required | Required workflow (true/false) | false |
| agent-name | Default agent for workflow | analyst |
| agent-command | Agent activation command | bmad:...:agent:analyst |
| agent-display-name | Agent display name | Mary |
| agent-title | Agent title | 📊 Business Analyst |
| options | Available modes/options | Create\|Edit\|Validate Mode |
| description | Brief description (1-2 sentences) | Transform audio files into structured markdown transcripts with optional AI-powered analysis using OpenAI Whisper. |
| output-location | Output directory variable | output_folder |
| outputs | Output artifacts | transcript reports |

### Step 4.4: Add Registry Entry

**Open the CSV file:**

```bash
# Read current file
cat _bmad/_config/bmad-help.csv
```

**Add new row at the end:**

Example entry for transcribe-audio workflow:
```csv
bmm,anytime,Transcribe Audio,TA,,_bmad/bmm/workflows/utilities/transcribe-audio/workflow.md,bmad-bmm-transcribe-audio,false,analyst,bmad:- Channel expert business analysis frameworks: draw upon Porter's Five Forces:agent:analyst,Mary,📊 Business Analyst,Create|Edit|Validate Mode,Transform audio files into structured markdown transcripts with optional AI-powered analysis using OpenAI Whisper. Supports single/multiple files with configurable models and output formats.,output_folder,transcript reports
```

**Field explanations for this example:**
- `module`: bmm (Business Method Module)
- `phase`: anytime (can be run anytime, not tied to specific project phase)
- `name`: Transcribe Audio (display name)
- `code`: TA (short code for quick reference)
- `sequence`: (empty - custom workflow, no specific order)
- `workflow-file`: Path from project root to workflow.md
- `command`: bmad-bmm-transcribe-audio (skill invocation)
- `required`: false (optional workflow)
- `agent-name`: analyst (Mary, the Business Analyst)
- `options`: Create|Edit|Validate Mode (available modes)
- `description`: Full description of capabilities
- `output-location`: output_folder (uses project's output folder)
- `outputs`: transcript reports (what it produces)

**Formatting rules:**
- Columns separated by commas
- No quotes needed unless field contains commas
- Modes separated by pipe `|` in options field
- Boolean fields: `true` or `false`
- Paths relative to project root (no leading slash)

### Step 4.5: Verify Registry Entry

**Test the help system:**

```
/bmad-help
```

Search for your workflow:
```
search: transcribe
```

Should return your new workflow in results.

### Step 4.6: Registry Checklist

Before considering registry complete:

- [ ] bmad-help.csv located
- [ ] New row added with all columns filled
- [ ] CSV syntax validated (no broken rows)
- [ ] `/bmad-help` invoked successfully
- [ ] Workflow appears in search results
- [ ] Description and keywords accurate

---

## Complete Example Walkthrough

### Scenario: Creating "Transcribe Audio" Workflow

#### Phase 1: Creation (2-4 hours)

**Step 1:** Invoke creation workflow
```
/bmad-bmb-create-workflow
```

**Step 2:** Answer discovery questions
- Name: transcribe-audio
- Module: bmm
- Category: utilities
- Purpose: Transform audio files into structured markdown transcripts

**Step 3:** Follow 12-step creation process
- Discovery → Classification → Requirements → Tools → Design → Foundation → Build steps

**Step 4:** Verify output
```bash
ls _bmad-output/bmb-creations/workflows/transcribe-audio/
```

**Result:** 24 files created (workflow.md, 17 step files, 4 data files, 3 directories, 1 template)

#### Phase 2: Validation (30-60 minutes)

**Step 1:** Invoke validation workflow
```
/bmad-bmb-validate-workflow
```

**Step 2:** Provide path
```
/home/ladmin/dev/GDF/7F_github/_bmad-output/bmb-creations/workflows/transcribe-audio
```

**Step 3:** Review validation report
```bash
cat _bmad-output/bmb-creations/workflows/transcribe-audio/validation-report-2026-02-14-v4-bmad-official.md
```

**Result:** 87/100 - APPROVED_WITH_REQUIRED_FIXES
- 3 critical (frontmatter)
- 21 warnings (15 menu handling, 6 file size)

**Step 4:** Fix critical issues

Fix empty frontmatter in 3 files:
- step-07-output-summary.md
- step-03-edit-complete.md
- step-04b-display-validation-report.md

**Step 5:** Fix easy warnings (optional)

Add menu handling sections to 4 files (6 menus total)

**Result:** ~91/100 - APPROVED_WITH_WARNINGS

#### Phase 3: Distribution (10-15 minutes)

**Step 1:** Create skill stub

File: `.claude/commands/bmad-bmm-transcribe-audio.md`

Content includes:
- Description
- Usage examples
- Workflow reference path

**Step 2:** Copy workflow directory

```bash
cp -r /home/ladmin/dev/GDF/7F_github/_bmad-output/bmb-creations/workflows/transcribe-audio \
      /home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/_bmad/bmm/workflows/utilities/
```

**Step 3:** Copy skill stub

```bash
cp /home/ladmin/dev/GDF/7F_github/.claude/commands/bmad-bmm-transcribe-audio.md \
   /home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/.claude/commands/
```

**Step 4:** Verify deployment

```bash
ls -la /home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/_bmad/bmm/workflows/utilities/transcribe-audio/
ls -la /home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/.claude/commands/bmad-bmm-transcribe-audio.md
```

**Result:** Files deployed successfully

#### Phase 4: Registry (5 minutes)

**Step 1:** Open bmad-help.csv

```bash
cat /home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/_bmad/_config/bmad-help.csv
```

**Step 2:** Add registry entry

```csv
bmm,anytime,Transcribe Audio,TA,,_bmad/bmm/workflows/utilities/transcribe-audio/workflow.md,bmad-bmm-transcribe-audio,false,analyst,bmad:- Channel expert business analysis frameworks: draw upon Porter's Five Forces:agent:analyst,Mary,📊 Business Analyst,Create|Edit|Validate Mode,Transform audio files into structured markdown transcripts with optional AI-powered analysis using OpenAI Whisper. Supports single/multiple files with configurable models and output formats.,output_folder,transcript reports
```

**Step 3:** Verify

```
/bmad-help
search: transcribe
```

**Result:** Workflow appears in search results

**Total time:** ~3-5 hours for complete lifecycle

---

## Troubleshooting

### Issue: Validation fails with low score (<70)

**Cause:** Major structural issues

**Solution:**
1. Review validation report section-by-section
2. Focus on CRITICAL issues first
3. May need to re-run `/bmad-bmb-edit-workflow` to fix structure
4. Re-validate after each major fix

### Issue: Skill invocation doesn't work in target project

**Cause:** Incorrect path in skill stub or missing workflow files

**Solution:**
1. Verify workflow files copied: `ls -la {target}/_bmad/{module}/workflows/{category}/{workflow-name}/`
2. Verify skill stub copied: `ls -la {target}/.claude/commands/bmad-*.md`
3. Check skill stub path uses `@{project-root}/_bmad/...` format
4. Test workflow.md exists at referenced path

### Issue: Workflow not appearing in `/bmad-help` search

**Cause:** CSV syntax error or missing entry

**Solution:**
1. Check CSV file for syntax errors: `cat _bmad/_config/bmad-help.csv`
2. Verify no broken rows (mismatched quotes or commas)
3. Ensure description contains relevant search terms
4. Verify command field matches skill stub name
5. Re-invoke `/bmad-help` after fixing

### Issue: File size warnings (>250 lines)

**Cause:** Step files too large

**Solution:**
1. Split large steps into multiple smaller steps
2. Move repetitive content to data files
3. Use references instead of duplicating content
4. Note: Files up to 250 lines still functional, just not ideal

### Issue: Menu handling warnings

**Cause:** Missing standardized menu handling sections

**Solution:**
Add after each menu display:
```markdown
#### Menu Handling Logic:

**EXECUTION RULES:**
- ALWAYS halt and wait for user input after presenting menu
- Process selection and route appropriately
```

---

## Best Practices

### Creating Workflows

✅ **DO:**
- Use official `/bmad-bmb-create-workflow` workflow
- Keep step files under 200 lines when possible
- Add menu handling sections after every menu
- Include comprehensive frontmatter
- Plan tri-modal structure if applicable (Create/Edit/Validate)
- Use data files for reference information
- Use templates for output formats

❌ **DON'T:**
- Create workflows manually (breaks compliance)
- Skip validation step
- Exceed 250 lines per file
- Forget menu handling sections
- Use empty or minimal frontmatter
- Duplicate content across multiple files

### Validating Workflows

✅ **DO:**
- Run validation after initial creation
- Fix all CRITICAL issues before distribution
- Address easy warnings (frontmatter, menu handling)
- Re-validate after major changes
- Keep validation reports for documentation

❌ **DON'T:**
- Skip validation workflow
- Ignore critical issues
- Deploy with score <70
- Use manual validation (not BMAD-compliant)

### Distributing Workflows

✅ **DO:**
- Create descriptive skill stub with examples
- Use absolute paths in cp commands
- Verify files at destination before considering complete
- Test skill invocation in target project
- Document deployment locations

❌ **DON'T:**
- Make up distribution scripts (not BMAD-sanctioned)
- Copy to wrong module/category directory
- Skip skill stub creation
- Forget to copy skill stub to .claude/commands/
- Assume deployment worked without verification

### Registry Process

✅ **DO:**
- Add entry to every target project's bmad-help.csv
- Fill all required columns (module, phase, name, workflow-file, command)
- Include comprehensive description for discoverability
- Test `/bmad-help` search after adding entry
- Use consistent formatting with existing entries
- Set appropriate phase (anytime for utilities, or specific phase)
- Specify correct agent if workflow has preferred facilitator

❌ **DON'T:**
- Skip registry step (workflow won't be discoverable)
- Add malformed CSV rows (breaks help system)
- Use vague or generic descriptions
- Leave command field empty or mismatched
- Forget to test help system after adding
- Use absolute paths (paths should be relative to project root)

---

## Conclusion

This guide provides the **official BMAD-sanctioned process** for managing custom workflows. Following these four phases ensures:

- ✅ **Compliance** with BMAD standards
- ✅ **Quality** through official validation
- ✅ **Discoverability** via registry
- ✅ **Reusability** across projects

**Remember:**
- Always use official BMAD workflows (never make up processes)
- Validate before distributing
- Manual copying is the sanctioned distribution method
- Registry makes workflows discoverable

**Key Workflows:**
- Create: `/bmad-bmb-create-workflow`
- Validate: `/bmad-bmb-validate-workflow`
- Edit: `/bmad-bmb-edit-workflow`
- Help: `/bmad-help`

---

**Document Version:** 1.0
**Last Updated:** 2026-02-14
**Maintainer:** BMAD Method Community
**License:** Use freely within BMAD-enabled projects
