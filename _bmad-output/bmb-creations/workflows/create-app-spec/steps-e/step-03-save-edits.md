---
name: 'step-03-save-edits'
description: 'Validate changes, regenerate XML, and save to file'

appSpecFile: '{user_provided_path}' # Set by step-01
---

# Step 3 (Edit): Save Changes

## STEP GOAL:

To validate all edits, regenerate the complete XML structure, update frontmatter, and save the modified app_spec.txt.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Technical Editor finalizing document changes
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in safe file operations and validation
- ✅ User brings final approval authority

### Step-Specific Rules:

- 🎯 Focus on validation and safe file writing
- 🚫 FORBIDDEN to save invalid XML or malformed structure
- 💬 This is automated save - user already approved via [S] selection
- 🚪 This is the final step - exits after save

## EXECUTION PROTOCOLS:

- 🎯 Validate all changes before writing
- 💾 Regenerate complete XML structure
- 📖 Update frontmatter with edit metadata
- 🚫 This is the final step - no next step after save

## CONTEXT BOUNDARIES:

- Available: Modified feature list from step 02, original file path
- Focus: Validation and file writing
- Limits: This is the last edit step
- Dependencies: All edits complete and in memory

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Validate Changes

Display: "**Validating changes before saving...**"

**Validation checks:**

**A. Feature ID Integrity:**
- All feature IDs sequential (FEATURE_001, FEATURE_002, ...)
- No gaps in sequence
- No duplicate IDs

**If ID issues found:** Auto-renumber features sequentially

**B. Category Validity:**
- All features assigned to one of 7 domain categories
- No custom categories
- No empty categories

**If category issues found:** Flag and request user correction

**C. Verification Criteria Quality:**
- All features have at least 3 criteria (functional, technical, integration)
- All criteria are non-empty strings
- No generic statements like "feature works"

**If criteria issues found:** Flag and request user correction

**D. XML Well-Formedness:**
- All required sections present
- No syntax errors in structure
- Proper nesting maintained

**If XML issues found:** Report and abort save

**If any critical issues (B, C, or D):**
- Display: "⚠️  **Validation Issues Found:**
  {list issues with feature IDs}

  **Cannot save until issues resolved.**

  Options:
  [F]ix manually now (return to edit menu)
  [A]bort save (exit without saving)"

- Wait for selection
- If F: Return to step-02-edit-menu.md
- If A: Exit workflow with "Save aborted. No changes written."

**If validation passes:**
- Display: "✅ All validation checks passed"
- Proceed to step 2

### 2. Calculate Edit Statistics

Compare original state (from step 01 load) with current state:

- Features added: {count}
- Features deleted: {count}
- Features modified: {count}
- Features recategorized: {count}
- Criteria updated: {count features}
- Total features: {original_count} → {new_count}

Store statistics for display.

### 3. Regenerate Complete XML Structure

Build complete app_spec.txt content:

**A. Update Frontmatter:**
```yaml
---
stepsCompleted: {original_stepsCompleted + ['edit-mode']}
lastStep: 'step-03-save-edits'
created_date: '{original_date}'
last_edited_date: '{current_date}'
user_name: '{user_name}'
project_name: '{project_name}'
prd_path: '{prd_path}'
prd_files: [{list}]
feature_count: {new_count}
workflow_status: 'edited'
edit_history:
  - date: '{current_date}'
    changes: 'Added {X}, Deleted {Y}, Modified {Z}, Recategorized {W}'
---
```

**B. Regenerate All 10 XML Sections:**

Using the same structure from create mode step-06-template-population:

1. metadata - Update generated_date to include "last edited {date}"
2. overview - Preserve original
3. technology_stack - Preserve original
4. coding_standards - Preserve original
5. core_features - Regenerate with all edited features grouped by category
6. non_functional_requirements - Preserve original
7. testing_strategy - Preserve original
8. deployment_instructions - Preserve original
9. reference_documentation - Preserve original
10. success_criteria - Update feature count

**CRITICAL:** Ensure all features included with updated details.

### 4. Validate Generated XML

Before writing, validate complete XML:
- All opening tags have closing tags
- Proper nesting maintained
- No syntax errors
- All 10 sections present

**If validation fails:**
- Display: "❌ **XML Generation Error**
  {error details}

  This is a system error. Cannot save. Please report this issue."
- Exit workflow

**If validation passes:**
- Proceed to step 5

### 5. Write to File

Display: "Writing changes to file..."

**Write complete content to {appSpecFile}:**
- Frontmatter
- Complete XML structure

**Verify write success:**
- File exists at path
- File size > 0
- Can read file back

**If write fails:**
- Display: "❌ **Write Error**
  Could not write to {appSpecFile}
  Error: {error_message}

  Changes not saved. Please check file permissions."
- Exit workflow

**If write succeeds:**
- Proceed to step 6

### 6. Display Save Confirmation

"✅ **Changes Saved Successfully!**

**File:** {appSpecFile}

**Changes Applied:**
- Features added: {count}
- Features deleted: {count}
- Features modified: {count}
- Features recategorized: {count}
- Criteria updated: {count features}

**New Statistics:**
- Total features: {new_count}
- Feature groups: {category_count}
- Total criteria: {criteria_count}
- File size: {size} KB

**Edit timestamp:** {current_date}

**Next Steps:**

1. **Validate Quality (Recommended):**
   Run `check-autonomous-implementation-readiness` workflow to validate edited app_spec:
   - Ensures all changes maintain quality standards
   - Validates agent-readiness after edits

2. **Use with Autonomous Agent:**
   This app_spec.txt is ready for use with your autonomous coding agent

3. **Edit Again:**
   You can run this workflow again anytime to make additional edits

**Workflow Complete!**"

Exit workflow (no next step - this is final).

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS:

- All validation checks passed before save
- Complete XML structure regenerated correctly
- Frontmatter updated with edit history
- File written successfully
- Statistics calculated and displayed
- Next steps communicated clearly
- Workflow exits cleanly

### ❌ SYSTEM FAILURE:

- Saving without validation
- Writing invalid XML
- Not updating frontmatter
- Not preserving edit history
- Write operation fails without clear error
- Not verifying write success
- Not displaying confirmation

**Master Rule:** Validate before writing. Never save invalid structure. Always confirm success.
