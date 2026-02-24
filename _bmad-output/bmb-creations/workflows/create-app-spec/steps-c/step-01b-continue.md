---
name: 'step-01b-continue'
description: 'Resume workflow from previous session'

outputFile: '{output_folder}/app_spec.txt'
---

# Step 1b: Continue Workflow

## STEP GOAL:

To resume the app_spec creation workflow from where it was left off in a previous session.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Business Analyst and Software Architect hybrid
- ✅ We're resuming a previous session
- ✅ You bring continuity and progress tracking
- ✅ User brings their continued commitment to the project

### Step-Specific Rules:

- 🎯 Focus ONLY on resuming from last checkpoint
- 🚫 FORBIDDEN to restart from beginning
- 💬 Display clear progress summary
- 🚪 Route to correct next step based on stepsCompleted

## EXECUTION PROTOCOLS:

- 🎯 Read stepsCompleted from output file
- 💾 Identify last completed step
- 📖 Route to appropriate next step
- 🚫 FORBIDDEN to skip progress tracking

## CONTEXT BOUNDARIES:

- Available: Existing app_spec.txt with progress
- Focus: Continuation and routing
- Limits: No re-initialization
- Dependencies: Output file must exist with stepsCompleted

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Welcome Back

"**Welcome back!**

Resuming app_spec creation workflow. Let me check your progress..."

### 2. Read stepsCompleted from Output

Load {outputFile} and read frontmatter:
- Extract `stepsCompleted` array
- Extract `lastStep` value
- Extract `project_name`
- Extract `prd_path`
- Extract `feature_count` (current progress)

### 3. Display Progress Summary

"**Progress Summary:**

Project: {project_name}
PRD: {prd_path}
Features extracted: {feature_count}

**Steps completed:**
{list stepsCompleted array with ✅ for each}

**Last completed:** {lastStep}

Resuming from next step..."

### 4. Determine Next Step

Based on the last completed step in `stepsCompleted`, identify the next step to load:

**Step mapping:**
- IF last step = 'step-01-init' → Next: ./step-02-prd-analysis.md
- IF last step = 'step-02-prd-analysis' → Next: ./step-03-feature-extraction.md
- IF last step = 'step-02b-merge-mode' → Next: ./step-07-final-review.md
- IF last step = 'step-03-feature-extraction' → Next: ./step-04-auto-categorization.md
- IF last step = 'step-04-auto-categorization' → Next: ./step-05-criteria-generation.md
- IF last step = 'step-05-criteria-generation' → Next: ./step-06-template-population.md
- IF last step = 'step-06-template-population' → Next: ./step-07-final-review.md
- IF last step = 'step-07-final-review' → Workflow complete, no next step

Store the next step file path as `nextStepPath`.

### 5. Route to Next Step

**If nextStepPath exists:**
"**Continuing to:** {next step name}

Loading step file..."

Load, read entire file, then execute the next step file at `nextStepPath`.

**If workflow is complete (no next step):**
"**Workflow Complete!**

Your app_spec.txt has been successfully created and saved.

File location: {outputFile}

**Next steps:**
1. Run the `check-autonomous-implementation-readiness` workflow to validate this app_spec
2. Use this app_spec as input for your autonomous coding agent

Workflow session ended."

### 6. Handle Errors

**If stepsCompleted is empty or missing:**
"**Error:** No progress found in app_spec.txt. The stepsCompleted array is empty.

This might mean:
- The workflow was never started properly
- The output file is corrupted

**Recommendation:** Run the workflow in create mode (default) to start fresh, or check the output file manually.

Workflow cannot continue."

**If lastStep is not recognized:**
"**Error:** Unrecognized last step: {lastStep}

The workflow state appears to be corrupted. Cannot determine next step.

**Recommendation:** Review the output file manually or restart the workflow in create mode.

Workflow cannot continue."

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS:

- stepsCompleted read correctly from output file
- Progress summary displayed accurately
- Next step determined correctly
- User routed to appropriate next step file
- OR workflow completion detected and confirmed

### ❌ SYSTEM FAILURE:

- Not reading stepsCompleted from output file
- Not displaying progress summary
- Routing to wrong next step
- Not handling completion case
- Not handling error cases

**Master Rule:** Continuation must preserve all progress and route correctly based on state.
