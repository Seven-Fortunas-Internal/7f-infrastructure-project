---
name: 'step-03-feature-extraction'
description: 'Extract atomic, independently implementable features from PRD'

nextStepFile: './step-04-auto-categorization.md'
outputFile: '{output_folder}/app_spec.txt'
advancedElicitationTask: '{project-root}/_bmad/core/workflows/advanced-elicitation/workflow.xml'
partyModeWorkflow: '{project-root}/_bmad/core/workflows/party-mode/workflow.md'
---

# Step 3: Feature Extraction

## STEP GOAL:

To extract atomic, independently implementable features from the PRD, applying Anthropic's principle "one feature = one atomic task".

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Business Analyst expert in feature decomposition
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in breaking down complex requirements into atomic tasks
- ✅ User brings domain knowledge and project context

### Step-Specific Rules:

- 🎯 Focus on atomic task breakdown - one feature = one independently implementable task
- 🚫 FORBIDDEN to create features that depend on multiple others to function
- 💬 Intent-based: "Extract atomic, independently implementable features"
- 🚪 Flexible feature count - granularity matters more than hitting a target number
- 💬 Use subprocess Pattern 4 for parallel extraction if multiple feature sections (3+ sections)
- ⚙️ If subprocess unavailable, extract features sequentially in main thread

## EXECUTION PROTOCOLS:

- 🎯 Apply Anthropic's atomic task principle rigorously
- 💾 Store extracted features in memory with sequential IDs
- 📖 Identify dependencies between features
- 🚫 This is extraction only - categorization happens in step 04

## CONTEXT BOUNDARIES:

- Available: PRD analysis from step 02, feature sections identified
- Focus: Feature extraction and atomic task breakdown
- Limits: Don't categorize yet, don't generate criteria yet
- Dependencies: PRD structure analyzed in step 02

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Recall PRD Analysis

From step 02, recall:
- Feature-bearing sections identified
- Project scope assessment (simple/medium/complex)
- Mental model of project type and domain

Display: "Extracting features from {count} PRD sections..."

### 2. Determine Extraction Approach

Check feature section count from step 02 analysis:

**If 1-2 feature sections:**
- Extract features sequentially (Pattern 4 not needed for small workload)
- Continue to step 3 (sequential extraction)

**If 3+ feature sections:**
- Use subprocess Pattern 4 for parallel extraction
- Display: "Multiple feature sections detected. Extracting features in parallel from {count} sections..."
- Continue to step 3 (parallel extraction)

### 3. Extract Features with Subprocess Pattern 4 (Parallel Execution)

**For sequential extraction (1-2 sections):**

Load PRD and read all identified feature-bearing sections:
- Read each section completely
- Apply atomic task principle (see below)
- Continue to step 4

**For parallel extraction (3+ sections):**

**SUBPROCESS PATTERN 4 - Parallel Execution:**
- Launch ALL subprocesses simultaneously (one per feature section)
- Each subprocess:
  - Reads its assigned PRD section
  - Applies atomic task principle to extract features
  - Returns extracted features with temporary IDs
- Wait for ALL subprocesses to complete
- Aggregate features from all subprocesses
- Display: "✅ Parallel extraction complete - {total_features} features from {count} sections"
- Continue to step 4

**Subprocess return structure (one per section):**
```
{
  "section": "3.2 User Management",
  "features": [
    {
      "name": "User Authentication",
      "description": "User can login with email and password",
      "requirements": ["Accept email input", "Validate credentials", ...],
      "acceptance_criteria": ["Redirect on success", ...],
      "dependencies": []
    },
    ...
  ]
}
```

**Atomic task principle (applied by each subprocess or main thread):**

For each requirement/feature found:

**Ask: Is this one atomic, independently implementable task?**

**If YES (atomic):**
- Extract as single feature
- Example: "User can login with email and password"

**If NO (too complex):**
- Break down into atomic sub-features
- Example: "User management system" breaks down to:
  - User can register new account
  - User can login with credentials
  - User can reset forgotten password
  - User can update profile information
  - User can delete account

**Atomic task criteria:**
- Can be implemented without requiring other features to be complete first (minimal dependencies)
- Has clear, testable acceptance criteria
- Represents one specific capability
- Can be completed in a single focused coding session
- Autonomous agent can implement without ambiguity

**Performance benefit:** For N sections, Pattern 4 processes all in ~1x time instead of N×time.
**Example:** 5-section PRD completes extraction in ~2 minutes instead of ~10 minutes.

### 4. Generate Sequential Feature IDs

Assign IDs to all extracted features:
- Format: FEATURE_001, FEATURE_002, FEATURE_003, etc.
- Sequential numbering (zero-padded to 3 digits)
- Store features with structure:
  ```
  {
    id: "FEATURE_001",
    name: "User Authentication",
    description: "User can login with email and password",
    prd_section: "3.2 User Management",
    requirements: [
      "Accept email and password input",
      "Validate credentials against database",
      "Create session on successful login",
      "Display error message on failure"
    ],
    acceptance_criteria_from_prd: [
      "User redirected to dashboard on successful login",
      "Error message displayed for invalid credentials"
    ],
    dependencies: [],
    category: "" // Will be assigned in step 04
  }
  ```

### 5. Identify Feature Dependencies

For each feature, check if it depends on other features:
- Look for logical dependencies (Feature B requires Feature A to exist first)
- Store dependency references by feature ID
- Example: FEATURE_015 (Update user profile) depends on FEATURE_001 (User authentication)

**Dependency types:**
- **Hard dependency:** Feature cannot function without another (e.g., logout requires login)
- **Soft dependency:** Feature enhanced by another but can work independently

Store only hard dependencies.

### 6. Validate Feature Count and Granularity

Check extracted features:
- **Count:** Flexible - no strict target, but typical projects have 30-50+ features
- **Too few (<15):** Likely features are too broad - review for further breakdown
- **Too many (>100):** Likely features are too granular - consider if some should be combined

**Granularity check:**
- Each feature should be one autonomous agent coding session
- Not too trivial (e.g., "Add a variable" is too small)
- Not too complex (e.g., "Build entire authentication system" is too large)

**If granularity concerns:**
- Flag features for user review
- Offer to adjust before proceeding

### 7. Present Feature Summary

"**Feature Extraction Complete**

Extracted {count} atomic features from PRD

**Granularity assessment:** {appropriate / needs review}
**Dependencies identified:** {count} features with dependencies

**Sample features:**
- FEATURE_001: {name}
- FEATURE_002: {name}
- FEATURE_003: {name}
- ...
- FEATURE_{N}: {name}

{IF granularity concerns:}
⚠️  **Granularity Review Needed:**
{list features that seem too broad or too granular}

{IF no concerns:}
✅ Feature granularity looks good - each represents one atomic task.

**Next:** Auto-categorize features into 7 domain categories."

### 8. Present MENU OPTIONS

Display: **[A] Advanced Elicitation [P] Party Mode [C] Continue to Auto-Categorization**

#### EXECUTION RULES:

- ALWAYS halt and wait for user input after presenting menu
- ONLY proceed to next step when user selects 'C'
- After other menu items execution, return to this menu

#### Menu Handling Logic:

- IF A: Execute {advancedElicitationTask}, and when finished redisplay menu
- IF P: Execute {partyModeWorkflow}, and when finished redisplay menu
- IF C: Update {outputFile} frontmatter (add 'step-03-feature-extraction' to stepsCompleted, set feature_count to {count}), then load, read entire file, then execute {nextStepFile}
- IF Any other: "Please select A, P, or C.", redisplay menu

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS:

- All feature sections from PRD processed (using subprocess Pattern 4 if 3+ sections)
- Subprocess Pattern 4 used for parallel extraction when appropriate (3+ sections)
- All subprocesses launched simultaneously for multi-section extraction
- Complex features broken down into atomic tasks
- Sequential feature IDs assigned (FEATURE_001, etc.) after aggregation
- Dependencies identified and stored
- Granularity validated (each feature = one atomic task)
- Feature count appropriate for project complexity
- Feature summary presented
- Ready to proceed to categorization

### ❌ SYSTEM FAILURE:

- Not using subprocess Pattern 4 for multi-section extraction (sequential instead of parallel)
- Features too broad (not atomic)
- Features too granular (trivial tasks)
- Missing dependencies
- Non-sequential or malformed feature IDs after aggregation
- Not applying atomic task principle
- Extracting fewer than 10 features for complex project
- Proceeding without granularity validation
- Not launching all subprocesses in parallel (performance loss)

**Master Rule:** One feature = one atomic, independently implementable task. Granularity matters more than count.
