---
name: 'step-02-edit-menu'
description: 'Present editing options and handle edit operations'

nextStepFile: './step-03-save-edits.md'
appSpecFile: '{user_provided_path}' # Set by step-01
advancedElicitationTask: '{project-root}/_bmad/core/workflows/advanced-elicitation/workflow.xml'
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

**Execute selected operation, then return to step 1 (present menu again) unless S or C selected.**

#### IF A (Add Features):

"**Add New Features**

How many features do you want to add? (1-10): "

Wait for count.

For each feature to add:
  - Display: "**Adding Feature {next_sequential_id}**"
  - Request: Name, Description, Requirements (list), Category selection
  - Request: Acceptance criteria (or auto-generate option)
  - Add to feature list with next sequential ID
  - Update feature count

Display: "✅ Added {count} new features. Total features: {new_total}"

Return to step 1 (present menu).

#### IF D (Delete Features):

"**Delete Features**

Enter feature IDs to delete (comma-separated, e.g., FEATURE_005, FEATURE_012): "

Wait for input.

For each specified feature:
  - Display current feature details
  - Request confirmation: "Delete {feature_id} ({name})? [Y/N]"
  - If Y: Mark for deletion
  - If N: Skip

After all confirmations:
  - Remove marked features
  - Renumber remaining features sequentially (maintain order)
  - Update all dependency references
  - Update feature count

Display: "✅ Deleted {count} features. Renumbered remaining features. Total: {new_total}"

Return to step 1 (present menu).

#### IF M (Modify Features):

"**Modify Feature Details**

Enter feature ID to modify: "

Wait for feature ID.

Display current feature:
```
FEATURE_{ID}: {name}
Description: {description}
Requirements:
- {req1}
- {req2}
Category: {category}
```

"**What do you want to modify?**
[N]ame
[D]escription
[R]equirements
[A]ll of the above
[C]ancel"

Wait for selection.

**If N:** Request new name, update feature
**If D:** Request new description, update feature
**If R:** Request new requirements list, update feature
**If A:** Request all three, update feature
**If C:** Return to menu without changes

Display: "✅ Updated {feature_id}"

"**Modify another feature? [Y/N]**"

If Y: Repeat from "Enter feature ID to modify"
If N: Return to step 1 (present menu)

#### IF R (Recategorize):

"**Recategorize Features**

Enter feature IDs to recategorize (comma-separated): "

Wait for input.

For each specified feature:
  - Display current feature and category
  - Display 7 available categories with descriptions
  - Request new category selection
  - Update feature category

After all recategorizations:
  - Regenerate category distribution stats
  - Display new distribution

Display: "✅ Recategorized {count} features"

Return to step 1 (present menu).

#### IF U (Update Criteria):

"**Update Verification Criteria**

Enter feature ID: "

Wait for feature ID.

Display current criteria:
```
FEATURE_{ID}: {name}

**Functional Verification:**
- {criterion1}
- {criterion2}

**Technical Verification:**
- {criterion1}
- {criterion2}

**Integration Verification:**
- {criterion1}
```

"**Select criteria type to edit:**
[F]unctional
[T]echnical
[I]ntegration
[A]ll types
[C]ancel"

Wait for selection.

For selected type(s):
  - Display current criteria
  - Offer: [E]dit existing / [A]dd new / [D]elete / [R]eplace all
  - Execute selected operation
  - Validate criteria quality (measurable, testable, specific)

Display: "✅ Updated criteria for {feature_id}"

"**Update criteria for another feature? [Y/N]**"

If Y: Repeat from "Enter feature ID"
If N: Return to step 1 (present menu)

#### IF G (Granularity Adjust):

"**Adjust Feature Granularity**

Enter feature ID: "

Wait for feature ID.

Display current feature details.

"**Granularity adjustment:**
[S]plit into multiple features - Break down complex feature
[M]erge with another - Combine overly granular features
[C]ancel"

Wait for selection.

**If S (Split):**
  - Request: "How many features should this split into? (2-5): "
  - For each new feature: Request name, description, requirements
  - Generate criteria for each new feature
  - Assign sequential IDs (insert after original ID)
  - Remove original feature
  - Renumber subsequent features

**If M (Merge):**
  - Request: "Enter feature ID to merge with: "
  - Display both features
  - Request: New combined name, description, requirements
  - Combine criteria from both features
  - Keep first feature ID, remove second
  - Renumber subsequent features

Display: "✅ Granularity adjusted. Total features: {new_total}"

"**Adjust another feature? [Y/N]**"

If Y: Repeat from "Enter feature ID"
If N: Return to step 1 (present menu)

#### IF E (Elicitation Review):

"**Launching Advanced Elicitation for quality review...**"

Launch {advancedElicitationTask} with context:
  - "Review this app_spec.txt for: feature quality, criteria measurability, completeness, consistency"
  - Provide current in-memory version (with unsaved edits)

After Advanced Elicitation completes:
  - Return to step 1 (present menu)

#### IF S (Save Changes):

"**Saving changes to app_spec.txt...**"

Proceed to step 3 (save and validation).

#### IF C (Cancel):

"**Cancel editing? All unsaved changes will be lost.**

Confirm cancel: [Y/N]"

Wait for input.

**If Y:**
  - Display: "Editing cancelled. No changes saved."
  - Exit workflow

**If N:**
  - Return to step 1 (present menu)

#### IF Any other:

Display: "Invalid selection. Please choose A, D, M, R, U, G, E, S, or C."

Return to step 1 (present menu).

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
