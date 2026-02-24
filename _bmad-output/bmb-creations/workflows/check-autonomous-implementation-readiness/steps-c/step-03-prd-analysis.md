---
name: 'step-03-prd-analysis'
description: 'Analyze PRD completeness and quality'

nextStepFile: './step-04-appspec-coverage.md'
outputFile: '{output_folder}/readiness-assessment-{project_name}.md'
analysisCriteria: '../data/analysis-criteria.md'
prdQualityAssessmentCriteria: '../data/prd-quality-assessment-criteria.md'
prdScoringFormulas: '../data/prd-scoring-formulas.md'
prdAnalysisOutputTemplate: '../data/prd-analysis-output-template.md'

advancedElicitationTask: '{project-root}/_bmad/core/workflows/advanced-elicitation/workflow.xml'
partyModeWorkflow: '{project-root}/_bmad/core/workflows/party-mode/workflow.md'
---

# Step 3: PRD Analysis

## STEP GOAL:

To analyze PRD completeness and quality across key dimensions: requirements clarity, success criteria, domain requirements, functional requirements, and non-functional requirements.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Technical Program Manager evaluating requirements quality
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in PRD quality assessment
- ✅ User brings domain knowledge to clarify ambiguities
- ✅ Together we identify PRD strengths and gaps

### Step-Specific Rules:

- 🎯 Focus ONLY on PRD analysis - app_spec.txt comes next
- 🚫 FORBIDDEN to make assumptions - note ambiguities explicitly
- 💬 Use evidence-based analysis with specific PRD references
- 🎯 Score each dimension objectively (0-100 scale)

## EXECUTION PROTOCOLS:

- 🎯 Analyze PRD against established quality criteria
- 💾 Append PRD analysis section to output file
- 📖 Update frontmatter with prd_analysis_score
- 🚫 Keep analysis focused on completeness and quality, not implementation

## CONTEXT BOUNDARIES:

- Available: PRD content loaded in step-02
- Focus: Requirements quality and completeness
- Limits: Don't analyze app_spec.txt yet
- Dependencies: Document inventory from step-02

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Re-load PRD for Analysis

Read `{outputFile}` frontmatter to get `prd_path`.

Load PRD file at `{prd_path}`.

Display: "**Analyzing PRD for completeness and quality...**"

### 2. Analyze PRD Structure and Completeness

**Reference:** Use criteria from `{prdQualityAssessmentCriteria}` - "PRD Structure Completeness" section.

Check for required sections and score 0-100 using scoring bands.

Present findings:

"**PRD Completeness Score:** {score}/100

**Sections Present:**
✅ {list of present sections}

**Sections Missing or Insufficient:**
❌ {list of missing/thin sections}"

### 3. Analyze Functional Requirements Quality

**Reference:** Use criteria from `{prdQualityAssessmentCriteria}` - "Functional Requirements Quality Dimensions" section.

Evaluate FRs for clarity, testability, completeness, and acceptance criteria. Score 0-100 using scoring bands.

Present findings:

"**Functional Requirements Quality:** {score}/100

**Strengths:**
- {list high-quality FR examples with FR IDs}

**Concerns:**
- {list ambiguous/untestable FRs with specific issues}"

### 4. Analyze Non-Functional Requirements Quality

**Reference:** Use criteria from `{prdQualityAssessmentCriteria}` - "Non-Functional Requirements Quality Dimensions" section.

Evaluate NFRs for coverage, specificity, feasibility, and priority. Score 0-100 using scoring bands.

Present findings:

"**Non-Functional Requirements Quality:** {score}/100

**NFR Coverage:**
✅ Security: {present/absent - specific NFR IDs}
✅ Performance: {present/absent - specific NFR IDs}
✅ Scalability: {present/absent - specific NFR IDs}
✅ Reliability: {present/absent - specific NFR IDs}

**Concerns:**
- {list vague or missing critical NFRs}"

### 5. Analyze Success Criteria and Goals

**Reference:** Use criteria from `{prdQualityAssessmentCriteria}` - "Success Criteria Quality Dimensions" section.

Evaluate success criteria for clarity, alignment, and feasibility. Score 0-100 using scoring bands.

Present findings:

"**Success Criteria Quality:** {score}/100

**Defined Success Metrics:**
- {list success metrics from PRD}

**Gaps:**
- {list areas without clear success criteria}"

### 6. Identify PRD Gaps and Ambiguities

List specific gaps found during analysis:

"**PRD Gaps Identified:**

1. {Specific gap with PRD section reference}
2. {Specific gap with PRD section reference}
3. ...

**Ambiguities Requiring Clarification:**

1. {Ambiguous requirement with FR/NFR ID}
2. {Ambiguous requirement with FR/NFR ID}
3. ..."

### 7. Calculate Overall PRD Score

**Reference:** Use formulas from `{prdScoringFormulas}` - "Overall PRD Score Calculation" section.

Calculate weighted average and interpret using score ratings.

**Overall PRD Score:** {weighted_average}/100

### 8. Append PRD Analysis to Output File

**Reference:** Use template from `{prdAnalysisOutputTemplate}`.

Update `{outputFile}` by appending the markdown section and updating frontmatter with all scores as specified in template.

### 9. Present Findings and Confirm

**Reference:** Use summary format from `{prdAnalysisOutputTemplate}` - "User Summary Presentation" section.

Present findings to user with all scores and assessment.

### 10. Present MENU OPTIONS

Display: **Select an Option:** [A] Advanced Elicitation [P] Party Mode [C] Continue to App Spec Coverage

#### EXECUTION RULES:

- ALWAYS halt and wait for user input after presenting menu
- ONLY proceed to next step when user selects 'C'
- After other menu items execution, return to this menu
- User can chat or ask questions - always respond and redisplay menu

#### Menu Handling Logic:

- IF A: Execute {advancedElicitationTask}, and when finished redisplay the menu
- IF P: Execute {partyModeWorkflow}, and when finished redisplay the menu
- IF C: Update frontmatter analysis_phase to 'appspec-coverage', then load, read entire file, then execute {nextStepFile}
- IF Any other: Help user respond, then redisplay menu

## 🚨 SYSTEM SUCCESS/FAILURE METRICS:

### ✅ SUCCESS:

- PRD analyzed across all quality dimensions
- Scores calculated objectively with evidence
- Specific gaps and ambiguities identified with references
- Analysis appended to output file
- Frontmatter updated with scores
- User understands PRD quality state

### ❌ SYSTEM FAILURE:

- Subjective scoring without evidence
- Missing analysis dimensions
- Not identifying specific gaps with references
- Not appending analysis to output file
- Not updating frontmatter
- Making assumptions instead of noting ambiguities

**Master Rule:** All analysis must be evidence-based with specific PRD references. Generic comments like "mostly good" are FORBIDDEN - provide specific examples and scores.
