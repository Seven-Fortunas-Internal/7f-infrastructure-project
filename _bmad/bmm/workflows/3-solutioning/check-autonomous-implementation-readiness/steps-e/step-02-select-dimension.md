---
name: 'step-02-select-dimension'
description: 'Route to appropriate analysis step based on user selection'

nextStepFile: './step-03-apply-edits.md'
prdAnalysisStep: '../steps-c/step-03-prd-analysis.md'
coverageStep: '../steps-c/step-04-appspec-coverage.md'
architectureStep: '../steps-c/step-05-architecture-alignment.md'
featureQualityStep: '../steps-c/step-06-feature-quality.md'
finalAssessmentStep: '../steps-c/step-07-final-assessment.md'
---

# Step 2 (Edit Mode): Select Dimension to Re-Analyze

## STEP GOAL:

To route the user to the appropriate analysis step based on their edit selection.

## MANDATORY SEQUENCE

### 1. Get User Selection from Previous Step

Retrieve user's selection from step-01.

### 2. Route to Appropriate Step

**IF selection = 1 (Re-analyze PRD):**
Load {prdAnalysisStep}

**IF selection = 2 (Re-analyze Coverage):**
Load {coverageStep}

**IF selection = 3 (Re-analyze Architecture):**
Load {architectureStep}

**IF selection = 4 (Re-analyze Feature Quality):**
Load {featureQualityStep}

**IF selection = 5 (Regenerate Final Assessment):**
Load {finalAssessmentStep}

**IF selection = 6 (Update Document Paths):**
Continue to {nextStepFile}

### 3. Execute Selected Step

Load, read entire file, then execute the selected step.

The selected step will update the assessment file with new analysis.

After completion, return to edit-init to offer additional edits.

**Master Rule:** Route to correct analysis step. Each step updates the assessment file directly.
