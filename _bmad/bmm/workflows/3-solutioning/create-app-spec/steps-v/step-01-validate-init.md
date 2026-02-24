---
name: 'step-01-validate-init'
description: 'Load existing app_spec.txt for validation'

nextStepFile: './step-02-run-validation.md'
---

# Step 1 (Validate): Load App Spec for Validation

## STEP GOAL:

To load an existing app_spec.txt file and prepare for comprehensive quality validation.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Quality Assurance expert in specification validation
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in quality standards and agent-readiness criteria
- ✅ User brings the specification to validate

### Step-Specific Rules:

- 🎯 Focus on loading file for validation - no judgments yet
- 🚫 FORBIDDEN to skip validation checks in next steps
- 💬 This is automated loading - minimal user input
- 🚪 This step auto-proceeds after loading (no A/P menu)

## EXECUTION PROTOCOLS:

- 🎯 Request path to app_spec.txt
- 💾 Load file and parse structure
- 📖 Prepare validation context
- 🚫 This is loading only - validation happens in next step

## CONTEXT BOUNDARIES:

- Available: app_spec.txt file path from user
- Focus: File loading and initial parsing
- Limits: No validation yet, only preparation
- Dependencies: Valid app_spec.txt must exist

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Request App Spec Path

Display: "**Validate App Spec Quality**

This workflow validates an app_spec.txt against quality standards and autonomous agent readiness criteria.

Please provide the path to the app_spec.txt file you want to validate:

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

### 3. Load App Spec

Load the complete app_spec.txt file.

Display: "Loading app_spec.txt from: {path}..."

**Parse frontmatter:**
- Extract all metadata
- Note workflow_status, feature_count, project_name

**Parse XML structure:**
- Identify all sections present
- Extract all features
- Count verification criteria
- Check for structural issues

Store in memory for validation.

### 4. Display Load Confirmation

"✅ **App Spec Loaded**

**File:** {path}
**Project:** {project_name}
**Features:** {feature_count}
**Status:** {workflow_status}

**Preparing comprehensive validation...**"

### 5. Auto-Proceed to Validation

**No menu - this step auto-proceeds after loading.**

Load, read entire file, then execute {nextStepFile}.

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS:

- File path provided and validated
- app_spec.txt loaded successfully
- Frontmatter and XML parsed
- Validation context prepared
- Auto-proceeded to validation step

### ❌ SYSTEM FAILURE:

- File not found and no retry offered
- Not loading complete file
- Not parsing structure
- Not auto-proceeding to validation

**Master Rule:** Load completely before validation. All checks happen in next step.
