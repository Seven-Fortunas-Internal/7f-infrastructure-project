---
name: 'step-02-run-validation'
description: 'Run comprehensive validation checks and generate findings'

nextStepFile: './step-03-validation-report.md'
---

# Step 2 (Validate): Run Validation Checks

## STEP GOAL:

To execute comprehensive validation checks across 8 quality dimensions and generate detailed findings.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Quality Assurance expert executing validation protocols
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in quality metrics and agent-readiness criteria
- ✅ User brings the expectation of objective analysis

### Step-Specific Rules:

- 🎯 Execute ALL 8 validation categories - no shortcuts
- 🚫 FORBIDDEN to skip validation checks or give false positives
- 💬 This is automated validation - objective analysis only
- 🚪 This step auto-proceeds after validation (no A/P menu)

## EXECUTION PROTOCOLS:

- 🎯 Run all 8 validation checks systematically
- 💾 Generate findings with severity levels (Critical/Warning/Info)
- 📖 Calculate overall quality score
- 🚫 Be objective - report issues honestly

## CONTEXT BOUNDARIES:

- Available: Loaded app_spec from step 01
- Focus: Quality validation and findings generation
- Limits: This is analysis only, no fixes applied
- Dependencies: app_spec.txt loaded and parsed

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Initialize Validation

Display: "**Running Comprehensive Validation**

Executing 8 quality checks..."

Initialize findings collection:
```
findings = {
  critical: [],
  warnings: [],
  info: [],
  passed: []
}
```

### 2. Validation Check 1: XML Structure Integrity

**Goal:** Verify all 10 required sections present and well-formed

**Checks:**
- All 10 sections present: metadata, overview, technology_stack, coding_standards, core_features, non_functional_requirements, testing_strategy, deployment_instructions, reference_documentation, success_criteria
- All opening tags have matching closing tags
- Proper XML nesting
- No syntax errors

**Scoring:**
- Missing section: CRITICAL (10 points deducted per section)
- Malformed XML: CRITICAL (20 points deducted)
- Well-formed: +10 points

**Record findings:**
- If any section missing: Add to findings.critical
- If XML errors: Add to findings.critical
- If all pass: Add to findings.passed

### 3. Validation Check 2: Feature Granularity

**Goal:** Verify features are atomic, independently implementable

**Checks:**
- Each feature has clear, single-purpose name
- Description is 1-3 sentences (not a paragraph)
- Requirements are concrete and specific (2-5 requirements per feature)
- No features that are clearly too broad ("Build entire authentication system")
- No features that are clearly too trivial ("Add a variable")

**Scoring:**
- Too broad features: WARNING (2 points deducted per feature)
- Too trivial features: WARNING (2 points deducted per feature)
- Appropriate granularity: +10 points

**Record findings:**
- Flag features that seem too broad or trivial
- Add to findings.warnings if issues found
- Add to findings.passed if all appropriate

### 4. Validation Check 3: Category Distribution

**Goal:** Verify features distributed appropriately across 7 domains

**Checks:**
- All features assigned to one of 7 valid categories
- No custom categories
- No single category dominates (>60% of features)
- Infrastructure category present (for any non-trivial project)
- At least 3 categories represented (for complex projects)

**Scoring:**
- Custom categories: CRITICAL (10 points deducted per occurrence)
- Single category >60%: WARNING (5 points deducted)
- <3 categories for complex project: WARNING (5 points deducted)
- Balanced distribution: +10 points

**Record findings:**
- Distribution percentages for all categories
- Add warnings/criticals as appropriate
- Add to findings.passed if balanced

### 5. Validation Check 4: Verification Criteria Quality

**Goal:** Verify all criteria are measurable, testable, and specific

**Checks:**
For each feature:
- Has at least 3 verification criteria (functional, technical, integration)
- No generic statements ("feature works", "looks good", "performs well")
- No vague terms without definition ("properly", "correctly", "adequately")
- Each criterion has clear pass/fail condition
- Criteria reference specific requirements or standards

**Scoring:**
- Missing criteria: CRITICAL (3 points deducted per feature)
- Generic criteria: WARNING (1 point deducted per criterion)
- Vague criteria: WARNING (1 point deducted per criterion)
- All criteria high quality: +15 points

**Record findings:**
- List features with missing/generic/vague criteria
- Add to findings.critical or findings.warnings
- Add to findings.passed if all criteria high quality

### 6. Validation Check 5: Dependency Completeness

**Goal:** Verify feature dependencies are identified and valid

**Checks:**
- All dependency references (FEATURE_XXX) exist
- No circular dependencies
- Dependencies make logical sense
- Hard dependencies clearly marked

**Scoring:**
- Invalid dependency reference: CRITICAL (5 points deducted per occurrence)
- Circular dependencies: CRITICAL (10 points deducted)
- Missing obvious dependencies: WARNING (2 points deducted)
- Dependencies complete and valid: +10 points

**Record findings:**
- List invalid references or circular deps
- Add to findings.critical or findings.warnings
- Add to findings.passed if all valid

### 7. Validation Check 6: Metadata Completeness

**Goal:** Verify all required metadata present and valid

**Checks:**
- project_name present and non-empty
- generated_from references valid PRD path
- generated_date valid format
- generated_by present
- autonomous_agent_ready = true
- Frontmatter includes: stepsCompleted, feature_count, workflow_status

**Scoring:**
- Missing required metadata: CRITICAL (5 points deducted per field)
- Invalid format: WARNING (2 points deducted per field)
- All metadata complete: +10 points

**Record findings:**
- List missing or invalid metadata fields
- Add to findings.critical or findings.warnings
- Add to findings.passed if all complete

### 8. Validation Check 7: Technology Stack Clarity

**Goal:** Verify tech stack section provides clear guidance

**Checks:**
- Languages specified
- Frameworks specified
- Database(s) specified (if applicable)
- Deployment target specified
- Key libraries specified (if applicable)
- No vague terms like "modern framework" or "industry standard"

**Scoring:**
- Missing critical tech stack info: WARNING (3 points deducted per item)
- Vague specifications: WARNING (2 points deducted)
- Clear and specific: +10 points

**Record findings:**
- List missing or vague specifications
- Add to findings.warnings
- Add to findings.passed if clear

### 9. Validation Check 8: Agent Readiness

**Goal:** Verify spec is ready for autonomous agent consumption

**Checks:**
- All features have unique, sequential IDs (FEATURE_001, FEATURE_002, ...)
- No gaps in feature ID sequence
- Each feature has actionable requirements (not just goals)
- Success criteria section includes measurable completion definition
- Coding standards section provides concrete guidance (not just "follow best practices")
- No ambiguous language that requires human interpretation

**Scoring:**
- Non-sequential IDs: CRITICAL (10 points deducted)
- Gaps in sequence: WARNING (3 points deducted)
- Ambiguous language: WARNING (2 points deducted per occurrence, max 10)
- Fully agent-ready: +15 points

**Record findings:**
- List agent-readiness issues
- Add to findings.critical or findings.warnings
- Add to findings.passed if fully ready

### 10. Calculate Overall Quality Score

**Scoring formula:**
- Start: 0 points
- Maximum possible: 100 points (10+10+10+15+10+10+10+15 = 90 base + 10 bonus for excellence)
- Deduct points for each finding based on severity
- Minimum score: 0

**Calculate:**
```
base_score = sum of all "passed" scores
deductions = sum of all critical and warning point deductions
final_score = max(0, base_score - deductions)
```

**Quality rating:**
- 90-100: Excellent (Production ready)
- 75-89: Good (Minor improvements recommended)
- 60-74: Fair (Several issues to address)
- 40-59: Poor (Significant rework needed)
- 0-39: Critical (Not ready for use)

### 11. Present Validation Summary

Display: "✅ **Validation Complete**

**Overall Quality Score: {score}/100**
**Rating: {rating}**

**Findings Summary:**
- ❌ Critical Issues: {count}
- ⚠️  Warnings: {count}
- ℹ️  Info: {count}
- ✅ Checks Passed: {count}

**Generating detailed validation report...**"

### 12. Auto-Proceed to Report

**No menu - this step auto-proceeds after validation.**

Store all findings and score in memory for report generation.

Load, read entire file, then execute {nextStepFile}.

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS:

- All 8 validation checks executed
- Findings categorized by severity (Critical/Warning/Info)
- Quality score calculated objectively
- No validation checks skipped
- Auto-proceeded to report generation

### ❌ SYSTEM FAILURE:

- Skipping any of the 8 validation checks
- Not categorizing findings by severity
- Giving false positives to avoid reporting issues
- Not calculating quality score
- Not proceeding to report

**Master Rule:** Execute all checks objectively. Report issues honestly. Autonomous agents depend on quality.
