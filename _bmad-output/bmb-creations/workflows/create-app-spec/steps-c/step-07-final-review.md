---
name: 'step-07-final-review'
description: 'Review complete app_spec, allow edits, and save'

outputFile: '{output_folder}/app_spec.txt'
advancedElicitationTask: '{project-root}/_bmad/core/workflows/advanced-elicitation/workflow.xml'
---

# Step 7: Final Review & Save

## STEP GOAL:

To present the complete app_spec.txt to the user, allow review and adjustments, and save the final version.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Business Analyst finalizing the specification
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring quality assurance and completeness validation
- ✅ User brings final review and approval authority

### Step-Specific Rules:

- 🎯 Focus on presenting complete app_spec for user review
- 🚫 FORBIDDEN to save without user approval
- 💬 This is final checkpoint - user can request adjustments
- 🚪 Custom menu: [S]ave / [E]dit / [A]djust / [R]eview with AE / [P]review / [C]ancel

## EXECUTION PROTOCOLS:

- 🎯 Present app_spec summary and statistics
- 💾 Allow user to review and request changes
- 📖 Save only when user approves
- 🚫 This is the final step - no next step after save

## CONTEXT BOUNDARIES:

- Available: Complete app_spec.txt with all sections populated
- Focus: Final review and approval
- Limits: This is the last CREATE mode step
- Dependencies: All prior steps complete (template populated)

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Load Complete App Spec

Read {outputFile} completely.

Display: "Loading complete app_spec.txt for final review..."

### 2. Display Statistics

"**App Spec Generation Complete!**

**Statistics:**
- Total Features: {feature_count}
- Feature Groups: {category_count}
- Total Verification Criteria: {criteria_count}
- PRD Source: {prd_path}
- File Size: {size} KB

**Feature Distribution by Category:**
- Infrastructure & Foundation: {count} features
- User Interface: {count} features
- Business Logic: {count} features
- Integration: {count} features
- DevOps & Deployment: {count} features
- Security & Compliance: {count} features
- Testing & Quality: {count} features

**File Location:** {outputFile}"

### 3. Display Summary Preview

**If file is <500 lines:**
- Display complete app_spec content

**If file is 500+ lines:**
- Display summary:
  - Metadata section
  - Overview section
  - Feature group headers with counts
  - Sample features (first 3)
  - Success criteria section

### 4. Present Review Menu

"**Review Complete App Spec**

**Options:**

**[S]ave** - Save app_spec.txt and complete workflow
  - Marks workflow complete
  - Saves final version
  - Ready for autonomous agent use

**[E]dit Categories** - Adjust feature categorization
  - Recategorize specific features
  - Returns to step-04 after edits

**[A]djust Granularity** - Split or merge features
  - Refine feature breakdown
  - Returns to step-03 after adjustments

**[R]eview with Advanced Elicitation** - Deep quality review
  - Launches Advanced Elicitation for thorough analysis
  - Reviews granularity, criteria quality, completeness
  - Returns to this menu after review

**[P]review Full Content** - Display complete app_spec
  - Shows entire file content
  - Returns to this menu

**[C]ancel** - Exit without saving final version
  - Preserves work in progress
  - Can resume later with continuation

**Select: [S/E/A/R/P/C]**"

Wait for user selection.

### 5. Handle Menu Selections

**IF S (Save):**
- Proceed to step 6 (Save and Complete)

**IF E (Edit Categories):**
- Display: "Which features should be recategorized?"
- Get feature IDs from user
- For each feature:
  - Display current category
  - Display available categories
  - Get new category selection
  - Update feature in app_spec
- After all edits: "Categories updated. Regenerating XML..."
- Regenerate core_features section with new categories
- Return to step 4 (present menu again)

**IF A (Adjust Granularity):**
- Display: "Which features need granularity adjustment?"
- Get feature IDs from user
- For each feature:
  - Display current feature details
  - Ask: [S]plit into multiple features / [M]erge with another / [R]efine description
  - Apply adjustments
- Renumber features if needed (maintain sequential IDs)
- Regenerate criteria for new/modified features
- Return to step 4 (present menu again)

**IF R (Review with Advanced Elicitation):**
- Launch {advancedElicitationTask} with context:
  - "Review this app_spec.txt for: feature granularity, verification criteria quality, completeness, agent-readiness"
- After Advanced Elicitation completes: Return to step 4 (present menu again)

**IF P (Preview Full Content):**
- Display complete app_spec.txt content
- Return to step 4 (present menu again)

**IF C (Cancel):**
- Display: "Workflow cancelled. Work saved in progress at: {outputFile}"
- Display: "You can resume later by running the workflow again (continuation will be detected)"
- Exit workflow

**IF Any other:**
- Display: "Invalid selection. Please choose S, E, A, R, P, or C."
- Return to step 4 (present menu again)

### 6. Save and Complete Workflow

**When user selects S (Save):**

Update {outputFile} frontmatter:
```yaml
---
stepsCompleted: ['step-01-init', 'step-02-prd-analysis', 'step-03-feature-extraction', 'step-04-auto-categorization', 'step-05-criteria-generation', 'step-06-template-population', 'step-07-final-review']
lastStep: 'step-07-final-review'
created_date: '{original_date}'
completed_date: '{current_date}'
user_name: '{user_name}'
project_name: '{project_name}'
prd_path: '{prd_path}'
prd_files: [{list}]
feature_count: {final_count}
workflow_status: 'completed'
---
```

Display: "✅ **App Spec Saved Successfully!**

**File:** {outputFile}
**Features:** {feature_count}
**Status:** Ready for autonomous agent use

**Next Steps:**

1. **Validate Quality:**
   Run the `check-autonomous-implementation-readiness` workflow to validate this app_spec:
   - Checks completeness
   - Validates feature granularity
   - Ensures agent-readiness
   - Provides quality score

2. **Use with Autonomous Agent:**
   This app_spec.txt is now ready to be used as the "single source of truth" for your autonomous coding agent:
   - Initializer agent will generate feature_list.json from this spec
   - Coding agent will implement features using this as reference

3. **Edit Later:**
   You can modify this app_spec anytime using Edit mode:
   - Run workflow with edit flag
   - Add/remove/modify features
   - Update verification criteria

**Workflow Complete!**"

Exit workflow (no next step - this is final).

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS:

- Complete app_spec presented with statistics
- User given multiple review options
- Edit/adjust options allow refinement
- Advanced Elicitation integration for quality review
- Save only occurs with user approval
- Final file marked as completed
- Next steps clearly communicated
- Workflow exits cleanly after save

### ❌ SYSTEM FAILURE:

- Saving without user approval
- Not offering edit/adjust options
- Not displaying statistics
- No preview option for large files
- Not updating frontmatter on save
- Not communicating next steps
- Proceeding past save (no next step exists)

**Master Rule:** User approval required for save. This is the final checkpoint.
