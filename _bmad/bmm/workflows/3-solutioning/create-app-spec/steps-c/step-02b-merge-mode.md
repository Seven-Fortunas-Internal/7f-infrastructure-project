---
name: 'step-02b-merge-mode'
description: 'Merge existing app_spec with new PRD (evolutionary restart)'

nextStepFile: './step-07-final-review.md'
outputFile: '{output_folder}/app_spec.txt'
advancedElicitationTask: '{project-root}/_bmad/core/workflows/advanced-elicitation/workflow.xml'
partyModeWorkflow: '{project-root}/_bmad/core/workflows/party-mode/workflow.md'
---

# Step 2b: Merge Mode (Evolutionary Restart)

## STEP GOAL:

To intelligently merge an existing app_spec.txt with updated PRD content, preserving manual edits while adding new features and updating changed requirements.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`
- ⚙️ TOOL/SUBPROCESS FALLBACK: If subprocess unavailable, perform analysis in main thread

### Role Reinforcement:

- ✅ You are a Business Analyst performing intelligent document merging
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in change detection and merge strategies
- ✅ User brings updated PRD and preserves valuable existing work

### Step-Specific Rules:

- 🎯 Focus on preserving existing quality while incorporating new content
- 🚫 FORBIDDEN to delete content without user confirmation
- 💬 Use subprocess Pattern 2 for PRD analysis (parallel reading if multi-file)
- 🚪 This is evolutionary restart - add/update, don't replace everything

## EXECUTION PROTOCOLS:

- 🎯 Load existing app_spec, analyze PRD, perform intelligent diff
- 💾 Update existing app_spec with merged content
- 📖 Track what was added, changed, flagged for review
- 🚫 Skip to step-07 (final review) - bypass normal extraction steps

## CONTEXT BOUNDARIES:

- Available: Existing app_spec.txt, PRD path from step 01
- Focus: Merge strategy and change detection
- Limits: Don't regenerate everything - merge intelligently
- Dependencies: Valid existing app_spec.txt with features

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Load Existing App Spec

Read {outputFile} completely:
- Parse all 10 XML sections
- Extract existing features with IDs, names, categories, verification criteria
- Extract metadata, tech stack, success criteria
- Store count of existing features

Display: "Loaded existing app_spec with {count} features"

### 2. Analyze Updated PRD

Read PRD from `prd_path` (same process as step-02-prd-analysis):
- Parse PRD structure
- Identify feature sections
- Extract technology stack
- Extract non-functional requirements

**If multi-file PRD:** Use subprocess Pattern 2 for parallel reading

### 3. Perform Diff Analysis

Compare PRD requirements vs existing app_spec features:

**Identify changes:**
- **New in PRD:** Features/requirements that don't exist in app_spec
- **Changed in PRD:** Features that exist but have updated requirements
- **Removed from PRD:** Features in app_spec not mentioned in new PRD
- **Unchanged:** Features that match between PRD and app_spec

**Change detection strategy:**
- Match by feature name similarity (fuzzy matching)
- Match by requirement text similarity
- Match by section/category alignment

Store all changes categorized.

### 4. Present Merge Summary

"**Merge Analysis Complete**

Comparing existing app_spec ({existing_count} features) with updated PRD:

**New features to add:** {count}
{list first 5 with IDs to be assigned}

**Features to update:** {count}
{list first 5 with existing IDs}

**Features potentially removed:** {count}
{list with existing IDs - will be flagged, not deleted}

**Unchanged features:** {count}
{preserve as-is}

**How should we proceed?**

[P] Proceed with merge - Add new, update changed, flag removed
[R] Review detailed changes before merging
[C] Cancel merge - return to normal create flow"

Wait for user selection.

### 5. Execute Merge (If User Selects P or after R)

**For new features:**
- Extract from PRD (same as step-03-feature-extraction)
- Assign new feature IDs continuing sequence (e.g., if last = FEATURE_030, start at FEATURE_031)
- Auto-categorize (same as step-04)
- Generate verification criteria (same as step-05)
- Add to appropriate category groups

**For changed features:**
- Update description/requirements from PRD
- Preserve verification criteria if still valid
- Add comment: `<!-- Updated from PRD on {date} -->`
- If criteria no longer valid, regenerate

**For removed features:**
- Keep in app_spec but add comment: `<!-- TODO: Not found in updated PRD - review for removal -->`
- Do NOT auto-delete (user must confirm)

**For unchanged features:**
- Keep completely as-is
- Preserve all manual edits

### 6. Update App Spec Metadata

Update frontmatter and metadata section:
- Increment version or add merge date
- Update `stepsCompleted` to include 'step-02b-merge-mode'
- Set `feature_count` to new total
- Add `merge_date` and `merge_summary`

### 7. Present Merge Results

"**Merge Complete**

✅ Added {count} new features (IDs: FEATURE_XXX to FEATURE_YYY)
✅ Updated {count} existing features
⚠️  Flagged {count} features for review (not in updated PRD)
✅ Preserved {count} unchanged features

**Total features now:** {new_total}

**Next:** Review merged app_spec before saving."

### 8. Present MENU OPTIONS

Display: **[A] Advanced Elicitation [P] Party Mode [C] Continue to Final Review**

#### EXECUTION RULES:

- ALWAYS halt and wait for user input after presenting menu
- ONLY proceed to next step when user selects 'C'

#### Menu Handling Logic:

- IF A: Execute {advancedElicitationTask}, and when finished redisplay menu
- IF P: Execute {partyModeWorkflow}, and when finished redisplay menu
- IF C: Update {outputFile} with merged content, update frontmatter, then load, read entire file, then execute {nextStepFile}
- IF Any other: "Please select A, P, or C.", redisplay menu

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS:

- Existing app_spec loaded and parsed
- PRD analyzed for changes
- Intelligent diff performed
- Merge strategy presented to user
- Merge executed with proper categorization
- New feature IDs assigned sequentially
- Removed features flagged, not deleted
- Metadata updated
- Ready for final review

### ❌ SYSTEM FAILURE:

- Deleting existing content without user confirmation
- Not preserving manual edits
- Not flagging removed features
- Incorrect feature ID sequencing
- Not using subprocess for multi-file PRD
- Regenerating everything instead of merging

**Master Rule:** Evolutionary restart preserves existing work while incorporating new content.
