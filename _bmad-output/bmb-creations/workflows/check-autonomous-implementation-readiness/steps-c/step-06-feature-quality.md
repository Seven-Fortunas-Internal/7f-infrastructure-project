---
name: 'step-06-feature-quality'
description: 'Evaluate feature specifications for autonomous agent execution'

nextStepFile: './step-07-final-assessment.md'
outputFile: '{output_folder}/readiness-assessment-{project_name}.md'
qualityRubric: '../data/quality-rubric.md'
featureStructureValidation: '../data/feature-structure-validation.md'
criteriaQualityStandards: '../data/criteria-quality-standards.md'
featureScoringDimensions: '../data/feature-scoring-dimensions.md'
categoryDistributionStandards: '../data/category-distribution-standards.md'
dependencyValidationStandards: '../data/dependency-validation-standards.md'
featureQualityOutputTemplate: '../data/feature-quality-output-template.md'

advancedElicitationTask: '{project-root}/_bmad/core/workflows/advanced-elicitation/workflow.xml'
partyModeWorkflow: '{project-root}/_bmad/core/workflows/party-mode/workflow.md'
---

# Step 6: Feature Quality Review

## STEP GOAL:

To evaluate feature specifications in app_spec.txt for autonomous agent execution readiness by assessing clarity, completeness, acceptance criteria quality, and autonomous execution patterns.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Technical Architect evaluating autonomous agent readiness
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in autonomous agent patterns and quality assessment
- ✅ User brings domain knowledge and feature understanding
- ✅ **Advanced Elicitation is highly recommended for deep quality assessment**

### Step-Specific Rules:

- 🎯 Focus on feature specification QUALITY for autonomous execution
- 🚫 FORBIDDEN to assess implementation - focus on specification readiness
- 💬 Evaluate against autonomous agent success patterns
- 🎯 Use Advanced Elicitation for deep critical assessment

## EXECUTION PROTOCOLS:

- 🎯 Evaluate each feature against autonomous readiness rubric
- 💾 Append feature quality review section to output file
- 📖 Update frontmatter with feature_quality_score
- 🚫 Keep focus on specification quality, not architecture or coverage

## CONTEXT BOUNDARIES:

- Available: app_spec.txt features, quality rubric
- Focus: Specification quality for autonomous agents
- Limits: Don't re-analyze architecture or coverage
- Dependencies: Coverage mapping from step-04

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Load app_spec.txt and Quality Rubric

Read `{outputFile}` frontmatter to get `appspec_path`.

Load app_spec.txt.

**Note to user:**

"**Feature Quality Review**

This step evaluates how well feature specifications support autonomous agent execution.

**💡 Recommendation:** Use **[A] Advanced Elicitation** for deeper quality assessment through:
- Socratic questioning to find specification gaps
- Role-playing to test edge cases
- Counterfactual analysis to identify assumptions

This is the MOST CRITICAL step for autonomous implementation success.

Display menu: [A] Advanced Elicitation [C] Continue with Standard Review"

Wait for user selection. If [A], execute Advanced Elicitation first, then return here.

### 2. Extract Feature List from app_spec.txt

Parse app_spec.txt to identify all features:

"**Features Identified in app_spec.txt:**

1. {Feature Name/ID}: {Brief description}
2. {Feature Name/ID}: {Brief description}
...

**Total Features:** {count}"

### 3. Validate Feature Structure and Components

For each feature in app_spec.txt, check required components per {featureStructureValidation}.

Present structural findings as specified in validation standards.

### 4. Evaluate Verification Criteria Quality

For each feature's acceptance_criteria, assess quality per {criteriaQualityStandards}.

Present criteria quality findings as specified in standards.

### 5. Evaluate Each Feature Against Quality Rubric

For each feature, assess against 5 quality dimensions per {featureScoringDimensions}.

### 6. Validate Feature Category Distribution

Check feature categorization per {categoryDistributionStandards}.

### 7. Validate Feature Dependencies

Check dependency management quality per {dependencyValidationStandards}.

### 8. Evaluate Feature Completeness

Check if app_spec.txt adequately covers project scope (feature count appropriate, PRD sections covered, non-functional requirements, testing strategy).

Calculate **Completeness Score:** {0-100}

### 9. Score Features

For each feature, calculate **Feature Quality Score** (average of 5 dimensions) and classify per {featureScoringDimensions}.

Present feature scores grouped by quality classification (High/Medium/Low).

### 10. Identify Common Quality Issues

Identify patterns across features. For each issue category, provide: affected feature count, example, impact on autonomous execution, and recommendation.

### 11. Evaluate Autonomous Agent Success Patterns

Check for autonomous agent best practices (bounded retry logic, failure recovery, error handling, rollback procedures, validation, integration points, testing).

Calculate **Score:** {patterns_present}/{total_patterns} patterns present

### 12. Calculate Overall Feature Quality Score

Calculate and present:
- **Overall Feature Quality Score:** Average of all feature scores
- **Component Scores:** Structure, Criteria, Distribution, Dependency, Completeness, Rubric-Based
- **Composite Quality Score:** Average of 6 component scores
- **Autonomous Agent Readiness:** Percentage of high-quality features
- **Overall Quality Rating:** Per {featureScoringDimensions} rating scale

### 13. Identify Critical Blockers for Autonomous Implementation

List features that CANNOT be implemented autonomously without specification improvements. For each: feature name, score, specific blocker, required fix, and priority.

### 14. Append Feature Quality Review to Output File

Update `{outputFile}` by appending content per {featureQualityOutputTemplate}.

Update frontmatter fields as specified in template.

### 15. Present Findings and Confirm

Present summary with overall feature quality score, autonomous readiness score, quality distribution, critical blockers count, and readiness assessment.

Inform user: "**Next:** Final Assessment - We'll synthesize all findings into a comprehensive readiness report with go/no-go decision."

### 16. Present MENU OPTIONS

Display: **Select an Option:** [A] Advanced Elicitation [P] Party Mode [C] Continue to Final Assessment

#### EXECUTION RULES:

- ALWAYS halt and wait for user input after presenting menu
- ONLY proceed to next step when user selects 'C'
- After other menu items execution, return to this menu
- User can chat or ask questions - always respond and redisplay menu

#### Menu Handling Logic:

- IF A: Execute {advancedElicitationTask} - Use this for deeper feature quality assessment, and when finished redisplay the menu
- IF P: Execute {partyModeWorkflow}, and when finished redisplay the menu
- IF C: Update frontmatter analysis_phase to 'final-assessment', then load, read entire file, then execute {nextStepFile}
- IF Any other: Help user respond, then redisplay menu

## 🚨 SYSTEM SUCCESS/FAILURE METRICS:

### ✅ SUCCESS:

- All features evaluated against 5 quality dimensions
- Feature quality scores calculated with evidence
- Common quality issues identified across features
- Autonomous agent patterns checked
- Critical blockers identified with specific fixes
- Analysis appended to output file
- Frontmatter updated with scores

### ❌ SYSTEM FAILURE:

- Subjective quality assessment without rubric
- Not evaluating autonomous agent readiness patterns
- Missing critical blocker identification
- Generic recommendations without specific fixes
- Not appending analysis to output file

**Master Rule:** Feature quality assessment must be evidence-based using the autonomous agent readiness rubric. Generic assessments like "features look good" are FORBIDDEN. Advanced Elicitation is highly recommended for thorough evaluation.
