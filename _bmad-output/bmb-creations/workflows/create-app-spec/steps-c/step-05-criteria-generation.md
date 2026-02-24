---
name: 'step-05-criteria-generation'
description: 'Generate verification criteria for each feature'

nextStepFile: './step-06-template-population.md'
outputFile: '{output_folder}/app_spec.txt'
criteriaDataFile: '../data/verification-criteria-patterns.md'
advancedElicitationTask: '{project-root}/_bmad/core/workflows/advanced-elicitation/workflow.xml'
partyModeWorkflow: '{project-root}/_bmad/core/workflows/party-mode/workflow.md'
---

# Step 5: Verification Criteria Generation

## STEP GOAL:

To auto-generate measurable, testable verification criteria for each feature, ensuring autonomous agent success validation.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`
- ⚙️ TOOL/SUBPROCESS FALLBACK: If subprocess unavailable, generate in main thread

### Role Reinforcement:

- ✅ You are a Quality Assurance expert in test criteria design
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in creating testable acceptance criteria
- ✅ User brings project context and quality standards

### Step-Specific Rules:

- 🎯 Use subprocess Pattern 4 for parallel generation if 30+ features
- 💬 Subprocess launches in parallel, each generates criteria for features, returns results
- 🚫 FORBIDDEN to create generic criteria - must be specific and testable
- ⚙️ If subprocess unavailable, generate criteria sequentially

## EXECUTION PROTOCOLS:

- 🎯 Load verification patterns from research (4 app_spec examples)
- 💾 Generate 3 types of criteria per feature (functional, technical, integration)
- 📖 Ensure all criteria are measurable with clear pass/fail
- 🚫 This is criteria generation only - template population happens in step 06

## CONTEXT BOUNDARIES:

- Available: Categorized features from step 04
- Focus: Verification criteria generation
- Limits: Don't populate XML yet, don't modify features
- Dependencies: Features extracted and categorized in steps 03-04

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Load Verification Patterns

Load {criteriaDataFile} which contains patterns from 4 example app_specs analyzed during research.

**Criteria patterns:**
- Functional verification (tests feature requirement implementation)
- Technical verification (tests coding standards, coverage, quality)
- Integration verification (tests dependencies, compatibility, no regressions)

Display: "Loaded verification criteria patterns from research"

### 2. Determine Generation Approach

Check feature count:

**If 30+ features:** Use subprocess Pattern 4 for parallel generation
**If <30 features:** Generate sequentially in main thread

### 3. Generate Verification Criteria for Each Feature

**For each feature, generate 3 types of criteria:**

**A. Functional Verification (2-3 criteria):**
- "Feature implements {specific requirement from PRD} as specified"
- "Feature handles {edge case} correctly"
- "Feature produces {expected output} given {input}"

**Example for FEATURE_001 (User login):**
- "User can login with valid email and password credentials"
- "System displays error message for invalid credentials"
- "System creates session token and redirects to dashboard on successful login"

**B. Technical Verification (2-3 criteria):**
- "Code follows {coding standard from PRD}"
- "Unit tests achieve {coverage threshold}%"
- "Implementation uses {specified technology/pattern}"
- "No security vulnerabilities detected by static analysis"

**Example for FEATURE_001:**
- "Authentication code follows secure password hashing standards (bcrypt/argon2)"
- "Unit tests cover login success, failure, and edge cases (90%+ coverage)"
- "No hardcoded credentials or secrets in code"

**C. Integration Verification (1-2 criteria):**
- "Feature integrates with {dependency feature} correctly"
- "Feature does not break {existing functionality}"
- "Feature works with {specified external service/API}"

**Example for FEATURE_001:**
- "Login integrates with session management (FEATURE_002)"
- "Login does not affect registration or password reset flows"

**Criteria quality requirements:**
- **Measurable:** Can be objectively tested (not "looks good")
- **Testable:** Clear pass/fail condition
- **Specific:** References concrete requirements, not generic statements
- **Actionable:** Autonomous agent knows exactly what to verify

**If using subprocess (30+ features):**
- Launch subprocesses in parallel
- Each subprocess generates criteria for a subset of features
- Aggregate results from all subprocesses

**Subprocess return structure:**
```
{
  "feature_id": "FEATURE_001",
  "functional_verification": [
    "User can login with valid credentials",
    "Error displayed for invalid credentials"
  ],
  "technical_verification": [
    "Code follows secure hashing standards",
    "Unit tests achieve 90%+ coverage"
  ],
  "integration_verification": [
    "Integrates with session management correctly"
  ]
}
```

### 4. Validate Criteria Quality

For each feature's criteria, validate:

**Quality checks:**
- All criteria are specific (not generic like "feature works")
- All criteria are testable (clear pass/fail)
- All criteria reference specific requirements or standards
- No vague terms like "properly", "correctly", "well" without definition

**If quality issues found:** Flag for regeneration

### 5. Store Criteria with Features

Update feature objects with generated criteria:

```
{
  id: "FEATURE_001",
  name: "User Authentication",
  description: "...",
  category: "Infrastructure & Foundation",
  verification_criteria: {
    functional: ["criterion 1", "criterion 2", "criterion 3"],
    technical: ["criterion 1", "criterion 2"],
    integration: ["criterion 1"]
  }
}
```

### 6. Present Generation Summary

"**Verification Criteria Generation Complete**

Generated criteria for {count} features:
- {total_functional} functional verification criteria
- {total_technical} technical verification criteria
- {total_integration} integration verification criteria

**Total criteria:** {total_count}

**Sample criteria for FEATURE_001 ({name}):**

*Functional:*
- {criterion 1}
- {criterion 2}

*Technical:*
- {criterion 1}
- {criterion 2}

*Integration:*
- {criterion 1}

✅ All criteria are measurable and testable

**Next:** Populate XML template with all features and criteria."

### 7. Present MENU OPTIONS

Display: **[A] Advanced Elicitation [P] Party Mode [C] Continue to Template Population**

#### EXECUTION RULES:

- ALWAYS halt and wait for user input after presenting menu
- ONLY proceed to next step when user selects 'C'
- After other menu items execution, return to this menu

#### Menu Handling Logic:

- IF A: Execute {advancedElicitationTask}, and when finished redisplay menu
- IF P: Execute {partyModeWorkflow}, and when finished redisplay menu
- IF C: Update {outputFile} frontmatter (add 'step-05-criteria-generation' to stepsCompleted), then load, read entire file, then execute {nextStepFile}
- IF Any other: "Please select A, P, or C.", redisplay menu

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS:

- All features have verification criteria (functional, technical, integration)
- Subprocess Pattern 4 used for 30+ features
- All criteria are measurable with clear pass/fail
- All criteria are specific and reference concrete requirements
- Criteria quality validated
- Ready to proceed to template population

### ❌ SYSTEM FAILURE:

- Features missing verification criteria
- Generic criteria (e.g., "feature works correctly")
- Non-testable criteria (e.g., "looks good")
- Not using subprocess for large feature sets
- Criteria not specific to feature requirements
- Proceeding without quality validation

**Master Rule:** Every criterion must be measurable, testable, and specific. No generic statements.
