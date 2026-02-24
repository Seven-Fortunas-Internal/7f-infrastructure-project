---
name: 'step-01-validate-init'
description: 'Load assessment for validation'

nextStepFile: './step-02-run-validation.md'
outputFolder: '{output_folder}'
---

# Step 1 (Validate Mode): Load Assessment for Validation

## STEP GOAL:

To load an existing readiness assessment and prepare for quality validation.

## MANDATORY SEQUENCE

### 1. Discover Assessment File

"**Validate Mode: Quality Check Existing Assessment**

This mode validates that a readiness assessment is complete, accurate, and follows quality standards.

Please provide the path to the assessment to validate:

**Path:**"

Wait for user input. Store as `assessment_path`.

### 2. Load Assessment

Load file at `{assessment_path}`.

Validate basic structure:
- Frontmatter present
- Required sections exist
- Scores present

If valid: "✅ Assessment loaded for validation"
If invalid: "❌ Assessment structure invalid"

### 3. Present Validation Overview

"**Validation Checks:**

This validation will check:
1. **Completeness** - All required sections present
2. **Score Accuracy** - Scores calculated correctly
3. **Evidence Quality** - Analysis backed by specific evidence
4. **Recommendation Quality** - Actionable recommendations provided
5. **Go/No-Go Logic** - Decision consistent with scores

**Ready to proceed?** [C] Continue"

### 4. Present MENU OPTIONS

Display: [C] Continue to Validation

#### EXECUTION RULES:

- ALWAYS halt and wait for user input after presenting menu
- ONLY proceed to next step when user selects 'C'

#### Menu Handling Logic:
- IF C: Load {nextStepFile}

**Master Rule:** Load and validate structure before detailed validation checks.
