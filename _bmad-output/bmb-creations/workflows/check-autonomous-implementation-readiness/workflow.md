---
name: check-autonomous-implementation-readiness
description: Validate PRD readiness for autonomous agent implementation by checking app_spec.txt coverage and architecture alignment
web_bundle: true
createWorkflow: './steps-c/step-01-init.md'
editWorkflow: './steps-e/step-01-edit-init.md'
validateWorkflow: './steps-v/step-01-validate-init.md'
---

# Check Autonomous Implementation Readiness

**Goal:** Validate that a PRD is ready for autonomous agent implementation by assessing app_spec.txt coverage, architecture alignment, and feature specification quality.

**Your Role:** In addition to your name, communication_style, and persona, you are also a Technical Program Manager and Software Architect hybrid collaborating with development teams. This is a partnership, not a client-vendor relationship. You bring expertise in implementation readiness assessment, quality gates, and autonomous agent orchestration patterns, while the user brings their PRD, app_spec.txt, and architecture documentation. Work together as equals to ensure implementation readiness.

**Meta-Context:** This workflow adapts BMAD's standard implementation readiness check for teams using autonomous agents instead of the traditional Epics/Stories approach. The flow is PRD → app_spec.txt → Autonomous Agent, validating that the app_spec.txt serves as an effective bridge document.

---

## WORKFLOW ARCHITECTURE

### Core Principles

- **Micro-file Design**: Each step is a self-contained instruction file that is part of an overall workflow that must be followed exactly
- **Just-In-Time Loading**: Only the current step file is in memory - never load future step files until told to do so
- **Sequential Enforcement**: Sequence within the step files must be completed in order, no skipping or optimization allowed
- **State Tracking**: Document progress in output file frontmatter with analysis_phase status
- **Evidence-Based Analysis**: All assessments must be backed by specific evidence from documents

### Step Processing Rules

1. **READ COMPLETELY**: Always read the entire step file before taking any action
2. **FOLLOW SEQUENCE**: Execute all numbered sections in order, never deviate
3. **WAIT FOR INPUT**: If a menu is presented, halt and wait for user selection
4. **CHECK CONTINUATION**: If the step has a menu with Continue as an option, only proceed to next step when user selects 'C' (Continue)
5. **SAVE STATE**: Update analysis_phase in frontmatter before loading next step
6. **LOAD NEXT**: When directed, load, read entire file, then execute the next step file

### Critical Rules (NO EXCEPTIONS)

- 🛑 **NEVER** load multiple step files simultaneously
- 📖 **ALWAYS** read entire step file before execution
- 🚫 **NEVER** skip steps or optimize the sequence
- 💾 **ALWAYS** update frontmatter of output file when completing each analysis phase
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

**Create Mode (Default)** - Generate new readiness assessment
Load, read the full file and then execute `{createWorkflow}` to begin the create workflow.

**Edit Mode** - Modify existing readiness assessment
Load, read the full file and then execute `{editWorkflow}` to begin the edit workflow.

**Validate Mode** - Validate existing readiness assessment quality
Load, read the full file and then execute `{validateWorkflow}` to begin the validate workflow.

**If no mode specified:** Default to create mode.
