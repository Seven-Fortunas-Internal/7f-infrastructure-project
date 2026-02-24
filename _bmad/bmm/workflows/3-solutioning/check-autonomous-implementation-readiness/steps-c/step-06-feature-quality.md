---
name: 'step-06-feature-quality'
description: 'Evaluate feature specifications for autonomous agent execution'

nextStepFile: './step-07-final-assessment.md'
outputFile: '{output_folder}/readiness-assessment-{project_name}.md'
qualityRubric: '../data/quality-rubric.md'

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

### 3. Evaluate Each Feature Against Quality Rubric

For each feature, assess against 5 quality dimensions:

**Dimension 1: Clarity (0-100)**
- Is the feature specification clear and unambiguous?
- Can an autonomous agent understand what to build?
- Are technical terms defined?

**Dimension 2: Completeness (0-100)**
- Does it specify all required components?
- Are edge cases addressed?
- Are error handling patterns defined?

**Dimension 3: Acceptance Criteria (0-100)**
- Are acceptance criteria specific and testable?
- Can autonomous agents verify completion?
- Are success/failure conditions clear?

**Dimension 4: Autonomous Readiness (0-100)**
- Does it include bounded retry logic?
- Are failure recovery patterns specified?
- Can it be implemented without human clarification?

**Dimension 5: Technical Feasibility (0-100)**
- Is the feature technically feasible as specified?
- Are dependencies and integrations clear?
- Are performance expectations realistic?

### 4. Score Features

For each feature, calculate:

**Feature Quality Score** = Average of 5 dimensions

**Classification:**
- **High Quality (80-100):** Ready for autonomous implementation
- **Medium Quality (60-79):** Needs minor refinement
- **Low Quality (0-59):** Needs significant work before autonomous implementation

Present scoring:

"**Feature Quality Scores:**

**High Quality Features ({count}):**
- {Feature Name}: {score}/100 - {Brief reason}

**Medium Quality Features ({count}):**
- {Feature Name}: {score}/100 - {Concerns}

**Low Quality Features ({count}):**
- {Feature Name}: {score}/100 - {Critical gaps}"

### 5. Identify Common Quality Issues

Identify patterns across features:

"**Common Quality Issues Found:**

1. **{Issue Category}** - Affects {count} features
   - Example: {Feature name} - {Specific issue}
   - Impact: {Impact on autonomous execution}
   - Recommendation: {How to fix}

2. **{Issue Category}** - Affects {count} features
   - Example: {Feature name} - {Specific issue}
   - Impact: {Impact on autonomous execution}
   - Recommendation: {How to fix}"

### 6. Evaluate Autonomous Agent Success Patterns

Check for autonomous agent best practices:

**Best Practices Checklist:**
- ✅/❌ Bounded retry logic specified
- ✅/❌ Failure recovery patterns defined
- ✅/❌ Error messages and logging requirements clear
- ✅/❌ Rollback/undo procedures specified
- ✅/❌ Validation steps defined
- ✅/❌ Integration points clear
- ✅/❌ Testing requirements specified

**Score:** {patterns_present}/{total_patterns} patterns present

### 7. Calculate Overall Feature Quality Score

**Overall Feature Quality Score:**
- Average of all feature scores: {average_score}/100
- Weighted by feature complexity (if applicable)

**Autonomous Agent Readiness:**
- High-quality features / Total features: {percentage}%
- Autonomous Readiness Score: {score}/100

### 8. Identify Critical Blockers for Autonomous Implementation

List features that CANNOT be implemented autonomously without specification improvements:

"**Critical Blockers ({count} features):**

1. **{Feature Name}** - {score}/100
   - Blocker: {Specific specification gap}
   - Required Fix: {What needs to be added/clarified}
   - Priority: {Critical/High}

2. **{Feature Name}** - {score}/100
   - Blocker: {Specific specification gap}
   - Required Fix: {What needs to be added/clarified}
   - Priority: {Critical/High}"

### 9. Append Feature Quality Review to Output File

Update `{outputFile}` by appending:

```markdown
### 4. Feature Quality Review

**Feature Specification Quality Score:** {overall_score}/100
**Autonomous Agent Readiness:** {readiness_score}/100

**Quality Breakdown:**
- High-Quality Features: {count} ({percentage}%)
- Medium-Quality Features: {count} ({percentage}%)
- Low-Quality Features: {count} ({percentage}%)

**High-Quality Features:**
- {Feature Name}: {score}/100 - Ready for autonomous implementation

**Quality Concerns:**
- {Feature Name}: {score}/100 - {Specific concerns}

**Common Quality Issues:**
1. {Issue Category}: Affects {count} features
   - Recommendation: {How to fix}

**Autonomous Agent Patterns:**
- Bounded retry logic: {present/absent}
- Failure recovery: {present/absent}
- Error handling: {present/absent}
- Validation steps: {present/absent}

**Critical Blockers ({count}):**
- {Feature Name}: {Blocker description}

**Recommendation:**
- {Specific recommendations for feature specification improvements}

---
```

Update frontmatter:
```yaml
analysis_phase: 'feature-quality-complete'
feature_quality_score: {overall_score}
autonomous_readiness_score: {readiness_score}
critical_blockers_count: {count}
high_quality_features_count: {count}
```

### 10. Present Findings and Confirm

Present summary:

"**Feature Quality Review Complete**

**Overall Feature Quality:** {overall_score}/100
**Autonomous Readiness:** {readiness_score}/100

**Feature Quality Distribution:**
- High Quality: {count} features ({percentage}%)
- Medium Quality: {count} features ({percentage}%)
- Low Quality: {count} features ({percentage}%)

**Critical Blockers:** {count} features require specification improvements before autonomous implementation

**Assessment:** {Features are ready for autonomous implementation / Significant quality improvements needed}

**Next:** Final Assessment - We'll synthesize all findings into a comprehensive readiness report with go/no-go decision."

### 11. Present MENU OPTIONS

Display: **Select an Option:** [A] Advanced Elicitation [P] Party Mode [C] Continue to Final Assessment

#### EXECUTION RULES:

- ALWAYS halt and wait for user input after presenting menu
- ONLY proceed to next step when user selects 'C'
- After other menu items execution, return to this menu
- User can chat or ask questions - always respond and redisplay menu

#### Menu Handling Logic:

- IF A: Execute {advancedElicitationTask} - Use this for deeper feature quality assessment
- IF P: Execute {partyModeWorkflow}
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
