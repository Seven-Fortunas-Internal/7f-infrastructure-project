# Edit Operations Workflows

**Purpose:** Detailed workflows for each edit operation in step-02-edit-menu.md

---

## [A] Add Features Operation

**Prompt:**
"**Add New Features**

How many features do you want to add? (1-10): "

**Workflow:**
1. Wait for count
2. For each feature to add:
   - Display: "**Adding Feature {next_sequential_id}**"
   - Request: Name, Description, Requirements (list), Category selection
   - Request: Acceptance criteria (or auto-generate option)
   - Add to feature list with next sequential ID
   - Update feature count

3. Display: "✅ Added {count} new features. Total features: {new_total}"
4. Return to edit menu

---

## [D] Delete Features Operation

**Prompt:**
"**Delete Features**

Enter feature IDs to delete (comma-separated, e.g., FEATURE_005, FEATURE_012): "

**Workflow:**
1. Wait for input
2. For each specified feature:
   - Display current feature details
   - Request confirmation: "Delete {feature_id} ({name})? [Y/N]"
   - If Y: Mark for deletion
   - If N: Skip

3. After all confirmations:
   - Remove marked features
   - Renumber remaining features sequentially (maintain order)
   - Update all dependency references
   - Update feature count

4. Display: "✅ Deleted {count} features. Renumbered remaining features. Total: {new_total}"
5. Return to edit menu

---

## [M] Modify Features Operation

**Prompt:**
"**Modify Feature Details**

Enter feature ID to modify: "

**Workflow:**
1. Wait for feature ID
2. Display current feature:
   ```
   FEATURE_{ID}: {name}
   Description: {description}
   Requirements:
   - {req1}
   - {req2}
   Category: {category}
   ```

3. Present modification menu:
   "**What do you want to modify?**
   [N]ame
   [D]escription
   [R]equirements
   [A]ll of the above
   [C]ancel"

4. Wait for selection:
   - **If N:** Request new name, update feature
   - **If D:** Request new description, update feature
   - **If R:** Request new requirements list, update feature
   - **If A:** Request all three, update feature
   - **If C:** Return to menu without changes

5. Display: "✅ Updated {feature_id}"
6. Ask: "**Modify another feature? [Y/N]**"
   - If Y: Repeat from step 1
   - If N: Return to edit menu

---

## [R] Recategorize Operation

**Prompt:**
"**Recategorize Features**

Enter feature IDs to recategorize (comma-separated): "

**Workflow:**
1. Wait for input
2. For each specified feature:
   - Display current feature and category
   - Display 7 available categories with descriptions
   - Request new category selection
   - Update feature category

3. After all recategorizations:
   - Regenerate category distribution stats
   - Display new distribution

4. Display: "✅ Recategorized {count} features"
5. Return to edit menu

---

## [U] Update Criteria Operation

**Prompt:**
"**Update Verification Criteria**

Enter feature ID: "

**Workflow:**
1. Wait for feature ID
2. Display current criteria:
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

3. Present criteria type menu:
   "**Select criteria type to edit:**
   [F]unctional
   [T]echnical
   [I]ntegration
   [A]ll types
   [C]ancel"

4. Wait for selection
5. For selected type(s):
   - Display current criteria
   - Offer: [E]dit existing / [A]dd new / [D]elete / [R]eplace all
   - Execute selected operation
   - Validate criteria quality (measurable, testable, specific)

6. Display: "✅ Updated criteria for {feature_id}"
7. Ask: "**Update criteria for another feature? [Y/N]**"
   - If Y: Repeat from step 1
   - If N: Return to edit menu

---

## [G] Granularity Adjust Operation

**Prompt:**
"**Adjust Feature Granularity**

Enter feature ID: "

**Workflow:**
1. Wait for feature ID
2. Display current feature details
3. Present adjustment menu:
   "**Granularity adjustment:**
   [S]plit into multiple features - Break down complex feature
   [M]erge with another - Combine overly granular features
   [C]ancel"

4. Wait for selection

### If S (Split):
- Request: "How many features should this split into? (2-5): "
- For each new feature: Request name, description, requirements
- Generate criteria for each new feature
- Assign sequential IDs (insert after original ID)
- Remove original feature
- Renumber subsequent features

### If M (Merge):
- Request: "Enter feature ID to merge with: "
- Display both features
- Request: New combined name, description, requirements
- Combine criteria from both features
- Keep first feature ID, remove second
- Renumber subsequent features

5. Display: "✅ Granularity adjusted. Total features: {new_total}"
6. Ask: "**Adjust another feature? [Y/N]**"
   - If Y: Repeat from step 1
   - If N: Return to edit menu

---

## [E] Elicitation Review Operation

**Prompt:**
"**Launching Advanced Elicitation for quality review...**"

**Workflow:**
1. Launch {advancedElicitationTask} with context:
   - "Review this app_spec.txt for: feature quality, criteria measurability, completeness, consistency"
   - Provide current in-memory version (with unsaved edits)

2. After Advanced Elicitation completes:
   - Return to edit menu

---

## [S] Save Changes Operation

**Prompt:**
"**Saving changes to app_spec.txt...**"

**Workflow:**
1. Proceed to step 3 (save and validation)

---

## [C] Cancel Operation

**Prompt:**
"**Cancel editing? All unsaved changes will be lost.**

Confirm cancel: [Y/N]"

**Workflow:**
1. Wait for input
2. **If Y:**
   - Display: "Editing cancelled. No changes saved."
   - Exit workflow

3. **If N:**
   - Return to edit menu

---

## Invalid Selection Handler

**Display:** "Invalid selection. Please choose A, D, M, R, U, G, E, S, or C."

**Action:** Return to edit menu
