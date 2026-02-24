---
name: 'step-01-init'
description: 'Initialize workflow, detect continuation/restart variations, gather PRD path'

continueFile: './step-01b-continue.md'
nextStepFile: './step-02-prd-analysis.md'
mergeStepFile: './step-02b-merge-mode.md'
outputFile: '{output_folder}/app_spec.txt'
templateFile: '../templates/app-spec-frontmatter.yaml'
---

# Step 1: Initialize App Spec Creation

## STEP GOAL:

To initialize the workflow, detect continuation or restart variations, gather PRD path (file or directory), and create the output file.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Business Analyst and Software Architect hybrid
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in feature extraction and specification quality
- ✅ User brings their PRD and project vision
- ✅ Together we create autonomous-agent-ready specifications

### Step-Specific Rules:

- 🎯 Focus ONLY on initialization and setup
- 🚫 FORBIDDEN to analyze PRD content yet - that's step 02
- 💬 Detect continuation and restart variations first
- 🚪 Support multi-file PRD directories (Seven Fortunas pattern)

## EXECUTION PROTOCOLS:

- 🎯 Check for existing app_spec.txt FIRST
- 💾 Create output file with frontmatter template
- 📖 This is the init step - sets up everything
- 🚫 FORBIDDEN to proceed without valid PRD path

## CONTEXT BOUNDARIES:

- Available: BMM config variables, user input
- Focus: Setup and initialization only
- Limits: No PRD analysis yet
- Dependencies: None - this is the first step

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Check for Existing Workflow

Check if {outputFile} exists:

**If app_spec.txt exists with stepsCompleted array:**
- Read frontmatter to check stepsCompleted
- If stepsCompleted is NOT empty: "**Resuming workflow...** Loading continuation step."
- Load, read entire file, then execute {continueFile}
- STOP HERE (do not continue to step 2)

**If app_spec.txt exists WITHOUT stepsCompleted (or empty array):**
- Continue to step 2 (restart variation detection)

**If app_spec.txt does NOT exist:**
- Continue to step 2 (normal initialization)

### 2. Restart Variation Detection (If Existing File)

**If app_spec.txt exists but has no progress (empty or no stepsCompleted):**

"**Existing app_spec.txt detected!**

An app_spec.txt file already exists at this location:
- File: {outputFile}
- This workflow will create a new app_spec.txt

**How should we proceed?**

**[O]verwrite (Clean Slate)**
- Delete existing app_spec.txt
- Regenerate completely from PRD
- All previous content lost
- Use when: PRD changed fundamentally, want fresh start

**[M]erge (Evolutionary)**
- Keep existing app_spec.txt as base
- Analyze PRD for changes
- Add new features, update existing
- Preserve manual edits where possible
- Use when: PRD has updates, want to preserve work

**[C]ancel**
- Exit workflow without changes
- Use Edit mode to modify existing app_spec

**Select: [O/M/C]**"

Wait for user selection:
- **IF O:** Delete {outputFile}, display "Deleted existing file. Starting fresh...", continue to step 3
- **IF M:** Display "Loading existing app_spec for merge...", load, read entire file, then execute {mergeStepFile}, STOP HERE
- **IF C:** Display "Workflow cancelled.", exit workflow, STOP HERE
- **IF Any other:** "Invalid selection. Please choose O, M, or C.", redisplay menu

### 3. Welcome User

"**Welcome to App Spec Creation!**

This workflow transforms your PRD into `app_spec.txt` - the single source of truth for autonomous coding agents.

**What this workflow will do:**
1. Analyze your PRD (single file or multi-document directory)
2. Extract atomic, independently implementable features
3. Auto-categorize features into 7 domain categories
4. Generate verification criteria for each feature
5. Build structured XML with 10 required sections
6. Produce autonomous-agent-ready specification

**Output:** `app_spec.txt` at {outputFile}

Ready to begin!"

### 4. Gather PRD Path

"**Please provide your PRD path:**

You can provide:
- **Single file:** `/path/to/prd.md`
- **Directory:** `/path/to/prd/` (all .md files will be processed)

**Example (Seven Fortunas pattern):**
```
prd/
├── prd.md
├── architecture.md
├── user-personas.md
└── non-functional-reqs.md
```

**Enter PRD path:**"

Wait for user input. Store as `prd_path`.

### 5. Validate PRD Path

Check `prd_path`:

**If file:**
- Check if file exists: `test -f {prd_path}`
- If NOT exists: "Error: File not found at {prd_path}. Please provide a valid path.", return to step 4
- If exists: Continue to step 6

**If directory:**
- Check if directory exists: `test -d {prd_path}`
- If NOT exists: "Error: Directory not found at {prd_path}. Please provide a valid path.", return to step 4
- If exists: Discover all .md files in directory
  - Use: `find {prd_path} -name "*.md" -type f`
  - Store list as `prd_files`
  - If no .md files found: "Error: No .md files found in {prd_path}. Please provide a directory with markdown files.", return to step 4
  - Display: "Found {count} PRD files: {list filenames}"
  - Continue to step 6

### 6. Create Output File

Load {templateFile} and create {outputFile} with frontmatter:

```yaml
---
stepsCompleted: ['step-01-init']
lastStep: 'step-01-init'
created_date: '{current_date}'
user_name: '{user_name}'
project_name: '{project_name}'
prd_path: '{prd_path}'
prd_files: [list if directory, empty if single file]
feature_count: 0
workflow_status: 'in_progress'
---
```

Confirm: "✅ Created app_spec.txt at {outputFile}"

### 7. Display Next Steps

"**Initialization complete!**

✅ PRD path validated: {prd_path}
✅ Output file created: {outputFile}
{IF directory: ✅ Found {count} PRD documents}

**Next:** Analyze PRD structure and identify feature sections."

### 8. Present MENU OPTIONS

Display: **[C] Continue to PRD Analysis**

#### EXECUTION RULES:

- ALWAYS halt and wait for user input
- ONLY proceed when user selects 'C'

#### Menu Handling Logic:

- IF C: Update {outputFile} frontmatter (confirm stepsCompleted includes 'step-01-init'), then load, read entire file, then execute {nextStepFile}
- IF Any other: "Please select C to continue.", redisplay menu

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS:

- Existing workflow detected and routed correctly
- Restart variation menu presented if needed
- PRD path validated (file or directory)
- Output file created with correct frontmatter
- User ready to proceed to PRD analysis

### ❌ SYSTEM FAILURE:

- Not checking for existing workflow first
- Not presenting restart variation menu
- Not validating PRD path
- Hardcoding paths instead of using variables
- Proceeding without user confirmation

**Master Rule:** Skipping steps is FORBIDDEN. Follow sequence exactly.
