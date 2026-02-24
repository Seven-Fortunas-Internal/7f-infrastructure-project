---
name: 'step-02-edit-menu'
description: 'Present editing options and handle edit operations'

nextStepFile: './step-03-save-edits.md'
appSpecFile: '{user_provided_path}' # Set by step-01
advancedElicitationTask: '{project-root}/_bmad/core/workflows/advanced-elicitation/workflow.xml'
operationsGuide: '../data/edit-operations-workflows.md'
---

# Step 2 (Edit): Edit Menu & Operations

## STEP GOAL:

To present editing options, execute selected edit operations, and manage iterative editing until user saves or cancels.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Technical Editor facilitating specification modifications
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in safe document editing
- ✅ User brings editing requirements

### Step-Specific Rules:

- 🎯 Focus on safe, reversible edits
- 🚫 FORBIDDEN to save without user explicit save command
- 💬 This is interactive editing - user drives all changes
- 🚪 Menu loops until [S]ave or [C]ancel selected

## EXECUTION PROTOCOLS:

- 🎯 Present edit menu with 8 options
- 💾 Execute selected edit operations
- 📖 Return to menu after each operation
- 🚫 Changes held in memory until explicit save

## CONTEXT BOUNDARIES:

- Available: Complete app_spec loaded from step 01, all features indexed
- Focus: Edit operations management
- Limits: All edits in memory until save, can cancel and lose changes
- Dependencies: app_spec.txt loaded in step 01

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Present Edit Menu

"**Edit App Spec Menu**

**Current state:** {feature_count} features across {category_count} categories

**Select an operation:**

**[A]dd Features** - Manually add new features to the spec
  - Assign next sequential feature ID
  - Specify category and criteria

**[D]elete Features** - Remove features by ID
  - Prompts for confirmation
  - Renumbers subsequent features

**[M]odify Features** - Edit feature details
  - Change name, description, or requirements
  - Preserves ID and category

**[R]ecategorize** - Change feature categories
  - Move features between the 7 domain categories
  - Updates category distribution

**[U]pdate Criteria** - Modify verification criteria
  - Edit functional, technical, or integration criteria
  - Add or remove criteria

**[G]ranularity Adjust** - Split or merge features
  - Split large features into atomic tasks
  - Merge overly granular features
  - Renumbers as needed

**[E]licitation Review** - Advanced quality review
  - Launch Advanced Elicitation for deep analysis
  - Returns to this menu after review

**[S]ave Changes** - Write changes to file and exit
  - Updates frontmatter with edit timestamp
  - Validates XML before writing
  - Proceeds to save step

**[C]ancel** - Exit without saving changes
  - All edits discarded
  - Original file unchanged

**Select: [A/D/M/R/U/G/E/S/C]**"

Wait for user selection.

### 2. Handle Menu Selections

**Execute selected operation following workflows in `{operationsGuide}`, then return to step 1 (present menu again) unless S or C selected.**

**Operation Workflows Reference:**
- [A] Add Features - Add 1-10 new features with sequential IDs
- [D] Delete Features - Remove features with confirmation, renumber remaining
- [M] Modify Features - Edit name, description, or requirements
- [R] Recategorize - Move features between 7 domain categories
- [U] Update Criteria - Modify functional, technical, or integration verification
- [G] Granularity Adjust - Split complex features or merge granular ones
- [E] Elicitation Review - Launch Advanced Elicitation for quality review
- [S] Save Changes - Proceed to step 3 (save and validation)
- [C] Cancel - Exit without saving (requires confirmation)

**Critical Rules for All Operations:**
- Return to step 1 (menu) after each operation except S/C
- Maintain sequential feature IDs after add/delete/split/merge operations
- Update category distribution after recategorization
- Validate criteria quality (measurable, testable, specific) when updating
- All edits held in memory until explicit save
- For invalid selections: Display error and return to menu

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS:

- Menu presented clearly with all 8 options
- Each operation executes correctly
- Changes held in memory until explicit save
- Validation applied to edits (criteria quality, ID integrity)
- Menu loops until S or C selected
- Sequential feature IDs maintained
- Category distribution updated after changes
- Advanced Elicitation integration functional

### ❌ SYSTEM FAILURE:

- Saving without user selecting [S]
- Not returning to menu after operations
- Allowing invalid edits (malformed IDs, broken XML)
- Not renumbering after deletions
- Not updating dependencies after ID changes
- Proceeding to save without user selection
- Not offering cancel option

**Master Rule:** All edits in memory until explicit save. User always in control.
