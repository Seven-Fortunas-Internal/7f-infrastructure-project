---
name: 'step-01-init'
description: 'Initialize readiness assessment and discover document locations'

nextStepFile: './step-02-document-discovery.md'
outputFile: '{output_folder}/readiness-assessment-{project_name}.md'
templateFile: '../templates/readiness-report-template.md'

advancedElicitationTask: '{project-root}/_bmad/core/workflows/advanced-elicitation/workflow.xml'
partyModeWorkflow: '{project-root}/_bmad/core/workflows/party-mode/workflow.md'
---

# Step 1: Initialization

## STEP GOAL:

To welcome the user, explain the autonomous implementation readiness assessment process, and gather paths to required documents (PRD, app_spec.txt, architecture documentation).

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Technical Program Manager and Software Architect hybrid
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in implementation readiness assessment and quality gates
- ✅ User brings their PRD, app_spec.txt, and architecture documentation
- ✅ Together we validate autonomous implementation readiness

### Step-Specific Rules:

- 🎯 Focus ONLY on explaining the process and gathering document paths
- 🚫 FORBIDDEN to analyze documents yet - that comes in subsequent steps
- 💬 Be clear about the 6 assessment dimensions and what to expect
- 🚪 Validate that paths are accessible before proceeding

## EXECUTION PROTOCOLS:

- 🎯 Explain the readiness assessment process clearly
- 💾 Create output file from template with gathered paths
- 📖 Initialize frontmatter with document locations
- 🚫 This is the init step - sets up everything that follows

## CONTEXT BOUNDARIES:

- This is the first step - no prior context available
- Focus: Document discovery and user orientation
- Limits: Do not analyze documents yet
- Dependencies: None - this is the entry point

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Welcome and Process Overview

Present the assessment overview:

"**Welcome to the Autonomous Implementation Readiness Assessment!**

This workflow validates that your PRD is ready for autonomous agent implementation by assessing:

1. **PRD Analysis** - Completeness and quality of requirements
2. **App Spec Coverage** - How well app_spec.txt covers PRD requirements
3. **Architecture Alignment** - Compliance with architectural constraints
4. **Feature Quality** - Specification quality for autonomous execution
5. **Overall Readiness** - Synthesis and go/no-go recommendation

**Time Required:** ~30-45 minutes
**Output:** Comprehensive readiness report with actionable recommendations

This assessment follows the Seven Fortunas pattern: **PRD → app_spec.txt → Autonomous Agent**"

### 2. Discover PRD Location

"**Let's start by locating your PRD.**

Please provide the full path to your Product Requirements Document (PRD).

**Example formats:**
- `_bmad-output/planning-artifacts/prd/prd.md`
- `/home/user/project/docs/prd-v1.0.md`

**Path to PRD:**"

Wait for user response. Store as `prd_path`.

**Validate path exists:**
- If file exists: Confirm "✅ PRD found at {prd_path}"
- If not found: "❌ File not found. Please provide correct path."
- Loop until valid path provided

### 3. Discover app_spec.txt Location

"**Next, let's locate your app_spec.txt file.**

This file should contain feature specifications for autonomous agent implementation.

**Path to app_spec.txt:**"

Wait for user response. Store as `appspec_path`.

**Validate path exists:**
- If file exists: Confirm "✅ app_spec.txt found at {appspec_path}"
- If not found: "❌ File not found. Please provide correct path."
- Loop until valid path provided

### 4. Discover Architecture Documentation (Optional)

"**Do you have architecture documentation to include in the assessment?**

This is optional but recommended. Architecture docs help validate alignment with technical constraints.

**Types of architecture documentation:**
- Architecture Decision Records (ADRs)
- Design documents
- Technical specifications
- System architecture diagrams

**Options:**
- **[Y]es** - I have architecture docs to include
- **[N]o** - Skip architecture documentation
- **[L]ist** - Provide multiple architecture doc paths

Please select: [Y/N/L]"

Wait for user response.

**IF Y:**
"Please provide the path to your primary architecture document:"
- Store path in `architecture_docs` array
- Validate file exists
- Ask: "Any additional architecture docs? [Y/N]"
- If Y, repeat; if N, continue

**IF L:**
"Please provide paths to architecture documents (one per line, or comma-separated):"
- Parse multiple paths
- Validate each path
- Store in `architecture_docs` array

**IF N:**
"Understood. Proceeding without architecture documentation.
**Note:** Architecture alignment assessment will be limited without architecture docs."

### 5. Confirm Document Inventory

Present summary of gathered documents:

"**Document Inventory Confirmed:**

✅ **PRD:** {prd_path}
✅ **App Spec:** {appspec_path}
{architecture_docs_status}

**Ready to begin assessment?**

The assessment will analyze these documents across 6 dimensions and generate a comprehensive readiness report."

### 6. Create Output File from Template

Load `{templateFile}` and create `{outputFile}` with initialized frontmatter:

```yaml
---
analysis_phase: 'init'
created_date: '{current_date}'
user_name: '{user_name}'
project_name: '{project_name}'
prd_path: '{prd_path}'
appspec_path: '{appspec_path}'
architecture_docs: ['{architecture_docs}']
readiness_score: 0
go_no_go: 'PENDING'
---
```

Copy template content below frontmatter.

Confirm: "✅ Readiness assessment report initialized at: {outputFile}"

### 7. Present MENU OPTIONS

Display: **Select an Option:** [A] Advanced Elicitation [P] Party Mode [C] Continue to Document Discovery

#### EXECUTION RULES:

- ALWAYS halt and wait for user input after presenting menu
- ONLY proceed to next step when user selects 'C'
- After other menu items execution, return to this menu
- User can chat or ask questions - always respond and redisplay menu

#### Menu Handling Logic:

- IF A: Execute {advancedElicitationTask}
- IF P: Execute {partyModeWorkflow}
- IF C: Update frontmatter analysis_phase to 'document-discovery', then load, read entire file, then execute {nextStepFile}
- IF Any other: Help user respond, then redisplay menu

## 🚨 SYSTEM SUCCESS/FAILURE METRICS:

### ✅ SUCCESS:

- User understands the assessment process
- PRD path validated and accessible
- app_spec.txt path validated and accessible
- Architecture docs gathered (or noted as unavailable)
- Output file created with initialized frontmatter
- Ready to proceed to document discovery

### ❌ SYSTEM FAILURE:

- Not validating file paths before proceeding
- Skipping architecture documentation discussion
- Not creating output file from template
- Not initializing frontmatter with document paths
- Proceeding without user confirmation

**Master Rule:** All document paths must be validated before proceeding to document discovery. Skipping validation is FORBIDDEN.
