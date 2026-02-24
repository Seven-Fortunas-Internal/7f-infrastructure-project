---
name: 'step-03-prd-analysis'
description: 'Analyze PRD completeness and quality'

nextStepFile: './step-04-appspec-coverage.md'
outputFile: '{output_folder}/readiness-assessment-{project_name}.md'
analysisCriteria: '../data/analysis-criteria.md'

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

**Check for required sections:**
- Executive Summary / Overview
- Success Criteria / Goals
- User Journeys / Use Cases
- Functional Requirements
- Non-Functional Requirements
- Domain Requirements / Business Rules
- Out of Scope / Constraints

**Score Completeness: 0-100**
- All required sections present and substantive: 90-100
- Most sections present, some thin: 70-89
- Several missing sections: 50-69
- Major sections missing: 0-49

Present findings:

"**PRD Completeness Score:** {score}/100

**Sections Present:**
✅ {list of present sections}

**Sections Missing or Insufficient:**
❌ {list of missing/thin sections}"

### 3. Analyze Functional Requirements Quality

Evaluate functional requirements (FRs) for:

**Criteria:**
- **Clarity:** Are FRs specific and unambiguous?
- **Testability:** Can each FR be verified/tested?
- **Completeness:** Do FRs cover all user journeys?
- **Acceptance Criteria:** Does each FR have clear AC?

**Score FR Quality: 0-100**
- All FRs clear, testable, complete: 90-100
- Most FRs high quality, some ambiguous: 70-89
- Many FRs lack clarity or testability: 50-69
- FRs severely lacking in quality: 0-49

Present findings:

"**Functional Requirements Quality:** {score}/100

**Strengths:**
- {list high-quality FR examples with FR IDs}

**Concerns:**
- {list ambiguous/untestable FRs with specific issues}"

### 4. Analyze Non-Functional Requirements Quality

Evaluate non-functional requirements (NFRs) for:

**Criteria:**
- **Coverage:** Security, performance, scalability, reliability covered?
- **Specificity:** Are NFRs measurable (not vague)?
- **Feasibility:** Are NFRs realistic and achievable?
- **Priority:** Are critical NFRs identified?

**Score NFR Quality: 0-100**

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

Evaluate success criteria for:

**Criteria:**
- **Clarity:** Are success metrics clear and measurable?
- **Alignment:** Do success criteria align with requirements?
- **Feasibility:** Are goals realistic?

**Score Success Criteria: 0-100**

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

Calculate weighted average:
- Completeness: 25%
- FR Quality: 30%
- NFR Quality: 25%
- Success Criteria: 20%

**Overall PRD Score:** {weighted_average}/100

### 8. Append PRD Analysis to Output File

Update `{outputFile}` by appending:

```markdown
## Assessment Dimensions

### 1. PRD Analysis

**Completeness Score:** {score}/100
**Quality Score:** {overall_score}/100

**Strengths:**
- {Key strengths identified}

**Gaps:**
- {Gaps or ambiguities identified}

**Functional Requirements:**
- Quality Score: {fr_score}/100
- {Brief summary}

**Non-Functional Requirements:**
- Quality Score: {nfr_score}/100
- {Brief summary}

**Success Criteria:**
- Quality Score: {sc_score}/100
- {Brief summary}

**Recommendation:**
- {Specific recommendations for PRD improvements}

---
```

Update frontmatter:
```yaml
analysis_phase: 'prd-analysis-complete'
prd_completeness_score: {completeness_score}
prd_quality_score: {overall_score}
```

### 9. Present Findings and Confirm

Present summary to user:

"**PRD Analysis Complete**

**Overall PRD Score:** {overall_score}/100

**Key Findings:**
- Completeness: {score}/100
- Functional Requirements: {score}/100
- Non-Functional Requirements: {score}/100
- Success Criteria: {score}/100

**Critical Gaps:** {count} identified
**Ambiguities:** {count} require clarification

**Assessment:** {PRD is ready/needs revision before proceeding}

**Next:** App Spec Coverage Validation - We'll verify how well app_spec.txt covers these PRD requirements."

### 10. Present MENU OPTIONS

Display: **Select an Option:** [A] Advanced Elicitation [P] Party Mode [C] Continue to App Spec Coverage

#### EXECUTION RULES:

- ALWAYS halt and wait for user input after presenting menu
- ONLY proceed to next step when user selects 'C'
- After other menu items execution, return to this menu
- User can chat or ask questions - always respond and redisplay menu

#### Menu Handling Logic:

- IF A: Execute {advancedElicitationTask}
- IF P: Execute {partyModeWorkflow}
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
