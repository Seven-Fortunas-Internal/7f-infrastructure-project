---
name: 'step-04-appspec-coverage'
description: 'Validate app_spec.txt coverage of PRD requirements'

nextStepFile: './step-05-architecture-alignment.md'
outputFile: '{output_folder}/readiness-assessment-{project_name}.md'
coverageChecklist: '../data/coverage-checklist.md'
appspecStructureValidation: '../data/appspec-structure-validation.md'
coverageScoringFormulas: '../data/coverage-scoring-formulas.md'
coverageAnalysisOutputTemplate: '../data/coverage-analysis-output-template.md'

advancedElicitationTask: '{project-root}/_bmad/core/workflows/advanced-elicitation/workflow.xml'
partyModeWorkflow: '{project-root}/_bmad/core/workflows/party-mode/workflow.md'
---

# Step 4: App Spec Coverage Validation

## STEP GOAL:

To validate that app_spec.txt provides comprehensive coverage of PRD requirements by mapping features to functional/non-functional requirements and identifying coverage gaps.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Software Architect validating implementation coverage
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in requirements traceability
- ✅ User brings domain knowledge to clarify feature mappings
- ✅ Together we ensure complete PRD coverage

### Step-Specific Rules:

- 🎯 Focus ONLY on coverage mapping - quality comes in step-06
- 🚫 FORBIDDEN to skip requirements without explicit mapping decision
- 💬 Use specific requirement IDs and feature names in mappings
- 🎯 Build traceability matrix: PRD requirement → app_spec feature

## EXECUTION PROTOCOLS:

- 🎯 Create requirement-to-feature traceability matrix
- 💾 Append coverage analysis section to output file
- 📖 Update frontmatter with appspec_coverage_score
- 🚫 Keep focus on coverage completeness, not implementation quality

## CONTEXT BOUNDARIES:

- Available: PRD analysis from step-03, app_spec.txt content
- Focus: Coverage completeness and traceability
- Limits: Don't analyze feature quality yet - that's step-06
- Dependencies: PRD requirements list from step-03

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Load PRD Requirements and app_spec.txt

Read `{outputFile}` frontmatter to get `prd_path` and `appspec_path`.

Load both files.

Display: "**Validating app_spec.txt coverage of PRD requirements...**"

### 2. Validate app_spec.txt Structure

**Before analyzing coverage, validate basic structure per {appspecStructureValidation}:**

- Check for 10 required XML sections
- Verify XML well-formedness (properly nested tags, all tags closed)
- Validate frontmatter completeness
- Check feature ID sequential numbering

**Present structure validation findings using template from {appspecStructureValidation}.**

**IF structure fails:** Note as critical issue, continue with available content.

### 3. Extract PRD Requirements List

From PRD, extract all functional and non-functional requirements:

**Functional Requirements (FRs):**
- List all FR IDs and brief descriptions
- Example: FR-1: User authentication, FR-2: Data export, etc.

**Non-Functional Requirements (NFRs):**
- List all NFR IDs and brief descriptions
- Example: NFR-SEC-1: OAuth 2.0, NFR-PERF-1: <2s response time

Present extracted requirements:

"**PRD Requirements Extracted:**
- Functional Requirements: {count} identified
- Non-Functional Requirements: {count} identified
- Total Requirements: {total_count}"

### 4. Extract app_spec.txt Features

From app_spec.txt, extract all defined features:

**Features List:**
- List feature IDs (FEATURE_001, FEATURE_002, etc.)
- Brief description of each feature
- Any explicit PRD requirement references in app_spec.txt
- Check for sequential IDs (no gaps)

**Feature ID validation:**
- Sequential: {✅ FEATURE_001, 002, 003... / ⚠️ Gaps found: {list}}
- Format consistent: {✅ Yes / ❌ No}

Present extracted features:

"**app_spec.txt Features Extracted:**
- Total Features: {count} identified
- Feature ID Range: FEATURE_001 to FEATURE_{max_id}
- Sequential IDs: {✅ No gaps / ⚠️ Gaps at: {list}}
- Named Features: {list first 5-10 feature names with IDs}"

### 5. Build Traceability Matrix

For each PRD requirement (FR and NFR), determine if it's covered by app_spec.txt:

**Mapping Logic:**
1. For each requirement, search app_spec.txt for related features
2. Classify coverage:
   - **✅ Fully Covered:** Feature specification addresses requirement completely
   - **⚠️ Partially Covered:** Feature touches requirement but incomplete
   - **❌ Not Covered:** No feature addresses this requirement

**Build matrix:**
```
FR-1: User Authentication
  ✅ Covered by: Feature "Auth Module" in app_spec.txt

FR-2: Data Export
  ⚠️ Partially Covered by: Feature "Export Tools" (missing CSV format)

FR-3: Real-time Updates
  ❌ Not Covered: No feature addresses real-time functionality
```

### 6. Calculate Coverage Scores

**Calculate coverage scores per {coverageScoringFormulas}:**

- FR Coverage Score = ((Fully × 1.0) + (Partially × 0.5)) / Total FRs × 100
- NFR Coverage Score = ((Fully × 1.0) + (Partially × 0.5)) / Total NFRs × 100
- Overall Coverage Score = (FR Score × 0.7) + (NFR Score × 0.3)

**Present coverage scores with breakdown of fully/partially/not covered counts.**

### 7. Identify Coverage Gaps

List all requirements not fully covered:

"**Coverage Gaps Identified:**

**Functional Requirements Not Covered:**
1. {FR-ID}: {Description} - No corresponding feature in app_spec.txt
2. {FR-ID}: {Description} - No corresponding feature in app_spec.txt

**Functional Requirements Partially Covered:**
1. {FR-ID}: {Description} - Covered by {Feature}, missing: {specific gap}
2. {FR-ID}: {Description} - Covered by {Feature}, missing: {specific gap}

**Non-Functional Requirements Not Covered:**
1. {NFR-ID}: {Description} - Not addressed in app_spec.txt
2. {NFR-ID}: {Description} - Not addressed in app_spec.txt"

### 8. Identify Unmapped Features

List features in app_spec.txt NOT mapped to any PRD requirement:

"**Features Without PRD Mapping:**

1. {Feature Name} - No corresponding PRD requirement
2. {Feature Name} - No corresponding PRD requirement

**Note:** Features without PRD mapping may indicate:
- Scope creep (out-of-scope features added)
- Missing PRD requirements
- Implementation details (acceptable if supporting core features)"

### 9. Append Coverage Analysis to Output File

**Use {coverageAnalysisOutputTemplate} to format output:**

Update `{outputFile}` by appending the coverage analysis section with:
- Overall coverage score and feature mapping completeness percentage
- Structure validation results
- Coverage breakdown (FR and NFR scores)
- Well-covered requirements (top 3-5)
- Coverage gaps (not covered and partially covered requirements)
- Features without PRD mapping
- Specific recommendations for improvements

**Update frontmatter per template specifications:**
- analysis_phase: 'appspec-coverage-complete'
- appspec_coverage_score
- fr_coverage, nfr_coverage
- coverage_gaps_count
- Structure validation flags (appspec_structure_valid, appspec_xml_wellformed, appspec_feature_id_sequential)

### 10. Present Findings and Confirm

Present summary:

"**App Spec Coverage Validation Complete**

**Overall Coverage Score:** {overall_coverage_score}/100

**Coverage Analysis:**
- Functional Requirements: {fr_coverage_score}/100
- Non-Functional Requirements: {nfr_coverage_score}/100

**Critical Gaps:** {critical_gap_count} requirements not covered
**Partial Coverage:** {partial_count} requirements need completion

**Assessment:** {app_spec.txt provides adequate coverage / significant gaps require addressing}

**Next:** Architecture Alignment - We'll verify alignment with architectural constraints."

### 11. Present MENU OPTIONS

Display: **Select an Option:** [A] Advanced Elicitation [P] Party Mode [C] Continue to Architecture Alignment

#### EXECUTION RULES:

- ALWAYS halt and wait for user input after presenting menu
- ONLY proceed to next step when user selects 'C'
- After other menu items execution, return to this menu
- User can chat or ask questions - always respond and redisplay menu

#### Menu Handling Logic:

- IF A: Execute {advancedElicitationTask}, and when finished redisplay the menu
- IF P: Execute {partyModeWorkflow}, and when finished redisplay the menu
- IF C: Update frontmatter analysis_phase to 'architecture-alignment', then load, read entire file, then execute {nextStepFile}
- IF Any other: Help user respond, then redisplay menu

## 🚨 SYSTEM SUCCESS/FAILURE METRICS:

### ✅ SUCCESS:

- All PRD requirements extracted and listed
- All app_spec.txt features extracted
- Complete traceability matrix built (requirement → feature)
- Coverage scores calculated with evidence
- Specific gaps identified with requirement IDs
- Analysis appended to output file
- Frontmatter updated with scores

### ❌ SYSTEM FAILURE:

- Incomplete requirements extraction
- Missing traceability mappings
- Vague coverage assessment without specific mappings
- Not identifying unmapped features
- Not appending analysis to output file
- Not updating frontmatter

**Master Rule:** Every PRD requirement must have an explicit coverage determination (fully/partially/not covered). Generic statements like "mostly covered" are FORBIDDEN - provide specific traceability mappings.
