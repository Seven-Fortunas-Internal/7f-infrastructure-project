---
name: 'step-01-edit-init'
description: 'Load existing readiness assessment for editing'

nextStepFile: './step-02-select-dimension.md'
outputFolder: '{output_folder}'
---

# Step 1 (Edit Mode): Load Assessment for Editing

## STEP GOAL:

To load an existing readiness assessment report and present edit options to the user.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:
- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator

### Role Reinforcement:
- ✅ You are a Technical Program Manager facilitating assessment updates
- ✅ We engage in collaborative dialogue
- ✅ You help users refine their readiness assessments

### Step-Specific Rules:
- 🎯 Focus ONLY on discovering and loading existing assessment
- 🚫 FORBIDDEN to modify assessment yet - that comes in next steps
- 💬 Present clear edit options to user

## EXECUTION PROTOCOLS:
- 🎯 Discover existing assessment file
- 💾 Load and validate assessment
- 📖 Present assessment summary and edit options

## MANDATORY SEQUENCE

### 1. Discover Existing Assessment

"**Edit Mode: Load Existing Assessment**

Please provide the path to the readiness assessment you want to edit.

**Expected location:** {output_folder}/readiness-assessment-{project_name}.md

**Path:**"

Wait for user input. Store as `assessment_path`.

### 2. Load and Validate Assessment

Load file at `{assessment_path}`.

Validate it's a readiness assessment:
- Check frontmatter has required fields
- Verify analysis sections present

If valid: "✅ Assessment loaded: {assessment_path}"
If invalid: "❌ Invalid assessment file. Please provide correct path."

### 3. Present Assessment Summary

Extract and display current state:

"**Current Assessment Summary:**

**Project:** {project_name}
**Created:** {created_date}
**Overall Score:** {readiness_score}/100
**Decision:** {go_no_go}

**Dimension Scores:**
- PRD Quality: {prd_quality_score}/100
- App Spec Coverage: {appspec_coverage_score}/100
- Architecture Alignment: {architecture_alignment_score}/100
- Feature Quality: {feature_quality_score}/100"

### 4. Present Edit Options

"**What would you like to edit?**

[1] Re-analyze PRD (if PRD has changed)
[2] Re-analyze App Spec Coverage (if app_spec.txt has changed)
[3] Re-analyze Architecture Alignment (if architecture changed)
[4] Re-analyze Feature Quality (if features refined)
[5] Regenerate Final Assessment (after dimension updates)
[6] Update Document Paths (if files moved)
[X] Cancel edit

Please select: [1/2/3/4/5/6/X]"

Store selection for next step.

### 5. Present MENU OPTIONS

Display: [C] Continue to Edit Dimension

#### EXECUTION RULES:

- ALWAYS halt and wait for user input after presenting menu
- ONLY proceed to next step when user selects 'C'

#### Menu Handling Logic:
- IF C: Load {nextStepFile} with user's selection
- IF Any other: Help user, redisplay menu

## 🚨 SYSTEM SUCCESS/FAILURE METRICS:

### ✅ SUCCESS:
- Assessment file loaded successfully
- Current state displayed accurately
- User understands edit options
- Selection captured for next step

### ❌ SYSTEM FAILURE:
- Not validating assessment file
- Missing current state display
- Unclear edit options

**Master Rule:** Load existing assessment before allowing edits.
