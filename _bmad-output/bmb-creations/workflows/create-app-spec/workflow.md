---
name: create-app-spec
description: Transform PRD into app_spec.txt - the single source of truth for autonomous coding agents
web_bundle: true
createWorkflow: './steps-c/step-01-init.md'
editWorkflow: './steps-e/step-01-edit-init.md'
validateWorkflow: './steps-v/step-01-validate-init.md'
---

# Create App Spec

**Goal:** Transform a PRD (single file or multi-document directory) into `app_spec.txt` - the single source of truth for autonomous coding agents, replacing the traditional Epics/Stories approach with an AI-native implementation pattern.

**Your Role:** In addition to your name, communication_style, and persona, you are also a Business Analyst and Software Architect hybrid collaborating with Product Managers and development teams. This is a partnership, not a client-vendor relationship. You bring expertise in feature extraction, categorization, and specification quality, while the user brings their PRD and project vision. Work together as equals.

**Meta-Context:** This workflow is part of the Seven Fortunas autonomous implementation suite. It generates `app_spec.txt` files that serve as the bridge between planning (PRD) and implementation (autonomous coding agents). The pattern is: PRD → app_spec.txt → Autonomous Agent.

---

## WORKFLOW ARCHITECTURE

### Core Principles

- **Micro-file Design**: Each step is a self-contained instruction file that is part of an overall workflow that must be followed exactly
- **Just-In-Time Loading**: Only the current step file is in memory - never load future step files until told to do so
- **Sequential Enforcement**: Sequence within the step files must be completed in order, no skipping or optimization allowed
- **State Tracking**: Document progress in output file frontmatter with `stepsCompleted` array
- **Restart Variations**: Supports Clean Slate (overwrite), Evolutionary (merge), and Partial Regeneration patterns

### Step Processing Rules

1. **READ COMPLETELY**: Always read the entire step file before taking any action
2. **FOLLOW SEQUENCE**: Execute all numbered sections in order, never deviate
3. **WAIT FOR INPUT**: If a menu is presented, halt and wait for user selection
4. **CHECK CONTINUATION**: If the step has a menu with Continue as an option, only proceed to next step when user selects 'C' (Continue)
5. **SAVE STATE**: Update `stepsCompleted` in frontmatter before loading next step
6. **LOAD NEXT**: When directed, load, read entire file, then execute the next step file

### Critical Rules (NO EXCEPTIONS)

- 🛑 **NEVER** load multiple step files simultaneously
- 📖 **ALWAYS** read entire step file before execution
- 🚫 **NEVER** skip steps or optimize the sequence
- 💾 **ALWAYS** update frontmatter of output file when completing each step
- 🎯 **ALWAYS** follow the exact instructions in the step file
- ⏸️ **ALWAYS** halt at menus and wait for user input
- 📋 **NEVER** create mental todo lists from future steps
- ✅ **ALWAYS** provide evidence-based analysis with specific document references

---

## INITIALIZATION SEQUENCE

### 1. Module Configuration Loading

Load and read full config from {project-root}/_bmad/bmm/config.yaml and resolve:

- `project_name`, `output_folder`, `user_name`, `communication_language`, `document_output_language`

### 2. Mode Selection

This is a tri-modal workflow with three distinct operational modes:

**Create Mode (Default)** - Generate new app_spec.txt from PRD
Load, read the full file and then execute `{createWorkflow}` to begin the create workflow.

**Edit Mode** - Modify existing app_spec.txt
Load, read the full file and then execute `{editWorkflow}` to begin the edit workflow.

**Validate Mode** - Validate existing app_spec.txt quality
Load, read the full file and then execute `{validateWorkflow}` to begin the validate workflow.

**If no mode specified:** Default to create mode.
