---
name: 'step-03-apply-edits'
description: 'Update document paths in assessment'

outputFile: '{output_folder}/readiness-assessment-{project_name}.md'
---

# Step 3 (Edit Mode): Apply Document Path Updates

## STEP GOAL:

To update document paths in the assessment frontmatter when files have been moved.

## MANDATORY SEQUENCE

### 1. Load Current Assessment

Read {outputFile} frontmatter to get current paths:
- `prd_path`
- `appspec_path`
- `architecture_docs`

Display current paths.

### 2. Gather New Paths

"**Update Document Paths**

**Current PRD Path:** {prd_path}
**New PRD Path** (or press Enter to keep): "

Wait for input. If provided, update prd_path.

"**Current app_spec Path:** {appspec_path}
**New app_spec Path** (or press Enter to keep): "

Wait for input. If provided, update appspec_path.

"**Current Architecture Docs:** {architecture_docs}
**New Architecture Docs** (comma-separated, or Enter to keep): "

Wait for input. If provided, update architecture_docs.

### 3. Update Assessment Frontmatter

Update {outputFile} frontmatter with new paths.

Confirm: "✅ Document paths updated successfully."

### 4. Offer Additional Edits

"**Would you like to make additional edits?**

[Y] Yes - return to edit menu
[N] No - exit edit mode

Please select: [Y/N]"

**IF Y:** Return to step-01-edit-init
**IF N:** Exit workflow

**Master Rule:** Only update paths that user explicitly changes.
