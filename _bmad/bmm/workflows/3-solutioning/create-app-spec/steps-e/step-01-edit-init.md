---
name: 'step-01-edit-init'
description: 'Load existing app_spec.txt for editing'

nextStepFile: './step-02-edit-menu.md'
---

# Step 1 (Edit): Load Existing App Spec

## STEP GOAL:

To load an existing app_spec.txt file, validate its structure, and prepare for editing.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Technical Editor preparing to modify specifications
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in XML structure validation
- ✅ User brings editing requirements

### Step-Specific Rules:

- 🎯 Focus on loading and validating existing app_spec.txt
- 🚫 FORBIDDEN to make edits yet - this is preparation only
- 💬 This is automated loading - minimal user input
- 🚪 This step auto-proceeds after loading (no A/P menu)

## EXECUTION PROTOCOLS:

- 🎯 Request path to existing app_spec.txt
- 💾 Load file, validate structure, parse XML
- 📖 Extract statistics and prepare editing context
- 🚫 This is loading only - edits happen in next steps

## CONTEXT BOUNDARIES:

- Available: Existing app_spec.txt file path from user
- Focus: File loading and structure validation
- Limits: No edits yet, only preparation
- Dependencies: Valid app_spec.txt must exist

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Request App Spec Path

Display: "**Edit Existing App Spec**

Please provide the path to the app_spec.txt file you want to edit:

(You can provide an absolute path or relative path from project root)"

Wait for user input.

### 2. Validate File Exists

Check if file exists at provided path.

**If file NOT found:**
- Display: "❌ **File not found:** {path}

  Please verify the path and try again."
- Return to step 1 (request path again)

**If file exists:**
- Proceed to step 3

### 3. Load and Parse App Spec

Load the complete app_spec.txt file.

Display: "Loading app_spec.txt from: {path}..."

**Parse frontmatter:**
- Extract: created_date, user_name, project_name, prd_path, feature_count, workflow_status
- Store in memory for use in edit operations

**Parse XML structure:**
- Identify all 10 required sections
- Extract all features with IDs, names, descriptions, categories, criteria
- Build feature index for quick lookup
- Validate XML well-formedness

**If parsing errors:**
- Display: "⚠️  **XML Parsing Issues Detected:**
  {list issues}

  This file may have structural problems. You can:
  [C]ontinue editing anyway
  [A]bort and fix manually first"
- Wait for user selection
- If A: Exit workflow
- If C: Proceed with warnings

### 4. Extract Statistics

Calculate current state:
- Total feature count
- Features per category (distribution)
- Total verification criteria count
- File size in KB
- Last modification date (if available)
- Workflow status from frontmatter

### 5. Display Load Summary

"✅ **App Spec Loaded Successfully**

**File:** {path}

**Current State:**
- Project: {project_name}
- Created: {created_date}
- Features: {feature_count}
- Status: {workflow_status}

**Feature Distribution:**
- Infrastructure & Foundation: {count} features
- User Interface: {count} features
- Business Logic: {count} features
- Integration: {count} features
- DevOps & Deployment: {count} features
- Security & Compliance: {count} features
- Testing & Quality: {count} features

**File Statistics:**
- Total criteria: {criteria_count}
- File size: {size} KB
- PRD source: {prd_path}

**Ready for editing.**"

### 6. Prepare Editing Context

Store in memory for edit operations:
- Complete feature list with all details
- Category assignments
- Verification criteria for each feature
- Original frontmatter
- File path for saving edits

### 7. Auto-Proceed to Edit Menu

**No menu - this step auto-proceeds after loading.**

Display: "**Loading edit menu...**"

Load, read entire file, then execute {nextStepFile}.

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS:

- File path provided and validated
- app_spec.txt loaded successfully
- Frontmatter parsed correctly
- XML structure validated
- All features extracted and indexed
- Statistics calculated
- Editing context prepared
- Auto-proceeded to edit menu

### ❌ SYSTEM FAILURE:

- File not found and no retry offered
- Proceeding with invalid XML without warning
- Not parsing frontmatter
- Not extracting complete feature list
- Not calculating statistics
- Not preparing editing context
- Not auto-proceeding to edit menu

**Master Rule:** Validate before editing. Must have clean structure to proceed safely.
