# Restart Variations Guide for App Spec

This document explains the three restart variation patterns supported by the create-app-spec workflow.

## Purpose

When an app_spec.txt already exists and the user runs the workflow again, the system must intelligently handle the restart. This guide defines three distinct restart patterns and when to use each.

**Key Insight:** Not all restarts are the same. The desired behavior depends on:
- Whether the PRD has changed
- Whether manual edits to app_spec should be preserved
- Whether the goal is incremental improvement or complete regeneration

---

## The Three Restart Variations

### 1. Clean Slate Restart

**Pattern:** Delete existing app_spec.txt and regenerate completely from scratch.

**When to use:**
- PRD has been substantially rewritten
- Existing app_spec has structural issues
- User wants to start fresh with new approach
- Previous app_spec was experimental/draft

**User trigger:**
- Workflow detects existing app_spec.txt
- Presents menu: [O]verwrite / [M]erge / [C]ancel
- User selects **O (Overwrite)**

**Workflow behavior:**
1. Confirm overwrite with warning: "This will delete the existing app_spec and regenerate from scratch. All manual edits will be lost."
2. Delete existing app_spec.txt
3. Proceed with standard CREATE mode (step-01 → step-02 → ... → step-07)
4. Generate completely new feature IDs starting from FEATURE_001

**Advantages:**
- Clean break from previous version
- Applies latest patterns and learnings
- No legacy structure carried forward

**Disadvantages:**
- Loses all manual edits to existing app_spec
- Loses any custom verification criteria
- Feature IDs reset (breaks external references)

**Best for:**
- Major PRD revisions
- Experimental initial attempts
- Learning from mistakes

---

### 2. Evolutionary Restart (Merge Mode)

**Pattern:** Keep existing app_spec.txt, analyze PRD changes, intelligently merge updates while preserving manual edits.

**When to use:**
- PRD has been updated (features added, removed, or modified)
- Existing app_spec has manual edits worth preserving
- User wants incremental updates, not complete regeneration
- Feature IDs referenced elsewhere (docs, tracking systems)

**User trigger:**
- Workflow detects existing app_spec.txt
- Presents menu: [O]verwrite / [M]erge / [C]ancel
- User selects **M (Merge)**

**Workflow behavior:**
1. Load existing app_spec.txt (parse all features, IDs, criteria, categories)
2. Route to **step-02b-merge-mode.md** (special merge step)
3. Analyze PRD changes:
   - **New features:** Extract from PRD sections not in existing spec
   - **Changed features:** Detect modified requirements in PRD
   - **Removed features:** Identify features in spec but not in PRD
   - **Unchanged features:** Features that match existing spec
4. Present merge plan to user:
   ```
   **Merge Analysis:**
   - New features detected: 5
   - Changed features detected: 3
   - Removed features detected: 2
   - Unchanged features: 23

   **Merge Strategy:**
   - Add 5 new features (assign sequential IDs after existing)
   - Update 3 changed features (preserve manual edits where possible)
   - Flag 2 removed features for review (not auto-deleted)
   - Keep 23 unchanged features as-is
   ```
5. User approves or adjusts merge strategy
6. Execute merge:
   - Add new features with next sequential IDs (e.g., existing ends at FEATURE_023, new start at FEATURE_024)
   - Update changed features:
     - Preserve manual criteria edits if still relevant
     - Update requirements from PRD
     - Flag conflicts for user review
   - Flag removed features (mark as "removed_from_prd" in frontmatter, don't delete)
   - Keep unchanged features untouched
7. Skip standard extraction steps (step-03, step-04, step-05) since features already exist
8. Route directly to **step-07-final-review** for user approval

**Advantages:**
- Preserves manual edits and custom criteria
- Maintains feature ID continuity
- Incremental updates (not all-or-nothing)
- Respects human effort invested in existing spec

**Disadvantages:**
- More complex merge logic
- Potential for merge conflicts
- May accumulate technical debt over time
- Requires careful diff analysis

**Best for:**
- Mature app_specs with manual refinements
- PRD updates during active development
- Preserving feature ID references
- Continuous improvement workflow

---

### 3. Partial Regeneration (Edit Mode)

**Pattern:** Keep existing app_spec.txt, allow selective editing of specific sections or features.

**When to use:**
- User wants to modify specific features without touching PRD
- Need to adjust categories, criteria, or granularity
- Quality improvements to existing spec
- No PRD changes, just refinement

**User trigger:**
- User explicitly runs workflow with EDIT mode flag
- Or: From CREATE mode final review, user selects [E]dit

**Workflow behavior:**
1. Load existing app_spec.txt
2. Present edit menu with options:
   - [A]dd Features - Manually add new features
   - [D]elete Features - Remove specific features by ID
   - [M]odify Features - Edit name/description/requirements
   - [R]ecategorize - Change feature categories
   - [U]pdate Criteria - Modify verification criteria
   - [G]ranularity Adjust - Split or merge features
   - [S]ave Changes - Write changes to file
3. User performs edits iteratively
4. Validate edits before save
5. Update frontmatter with edit history
6. Save modified app_spec.txt

**Advantages:**
- Surgical precision (change only what needs changing)
- No PRD required
- Full control over edits
- Preserves everything not explicitly edited

**Disadvantages:**
- Manual work required
- No automatic sync with PRD updates
- Can drift from PRD over time

**Best for:**
- Quality refinements
- Post-validation fixes
- Category rebalancing
- Criteria quality improvements

---

## Decision Matrix

| Scenario | PRD Changed? | Manual Edits to Preserve? | Recommended Pattern |
|----------|--------------|---------------------------|---------------------|
| Initial creation | N/A (no existing spec) | N/A | CREATE mode (standard) |
| PRD substantially rewritten | Yes (major) | No | Clean Slate Restart |
| PRD has small updates | Yes (minor) | Yes | Evolutionary Restart |
| No PRD changes, just refinement | No | Yes | Partial Regeneration (Edit) |
| Existing spec has issues | N/A | No | Clean Slate Restart |
| Preserving feature IDs critical | N/A | Yes | Evolutionary Restart or Edit |
| Learning from mistakes | N/A | No | Clean Slate Restart |
| Continuous improvement | Yes | Yes | Evolutionary Restart |

---

## Implementation in Workflow

### Step-01-init.md Detection Logic

**When workflow starts:**

1. Check if app_spec.txt exists at configured output path
2. **If NOT exists:** Standard CREATE mode (proceed to step-02-prd-analysis)
3. **If EXISTS:**
   - Parse frontmatter to get stepsCompleted
   - **If stepsCompleted is incomplete:** Route to step-01b-continue.md (resume session)
   - **If stepsCompleted is complete:** Restart variation detected

**Restart variation menu:**
```
⚠️  **Existing app_spec.txt detected**

This app_spec was previously generated:
- Project: {project_name}
- Created: {created_date}
- Features: {feature_count}
- Status: {workflow_status}

**How would you like to proceed?**

[O]verwrite - Delete existing spec and regenerate from scratch
  - Use when PRD substantially changed
  - Loses all manual edits
  - Generates new feature IDs

[M]erge - Intelligently merge PRD updates with existing spec
  - Use when PRD has updates to incorporate
  - Preserves manual edits where possible
  - Maintains feature ID continuity

[C]ancel - Exit without changes
  - Use Edit mode workflow for manual refinements
  - Or review existing spec first

**Select: [O/M/C]**
```

Wait for user selection.

**IF O:** Delete file, proceed to step-02-prd-analysis (standard CREATE)
**IF M:** Keep file, route to step-02b-merge-mode.md (evolutionary)
**IF C:** Exit workflow

### Step-02b-merge-mode.md Logic

**This special step handles evolutionary restart:**

1. Load existing app_spec.txt (parse all features)
2. Load PRD (current version)
3. **Diff analysis:**
   - Compare PRD feature sections with existing app_spec features
   - Identify new, changed, removed, unchanged
4. **Merge strategy generation:**
   - New → extract and assign sequential IDs after existing
   - Changed → update requirements, flag manual criteria edits
   - Removed → flag for review, don't auto-delete
   - Unchanged → keep as-is
5. Present merge plan to user (with counts and examples)
6. User approves or requests adjustments
7. Execute merge:
   - Apply changes in memory
   - Preserve feature ID sequence
   - Update frontmatter with merge metadata
8. Route directly to step-07-final-review (skip extraction steps)

### Edit Mode (Separate Workflow Entry)

**Accessed via:**
- Explicit EDIT mode flag: `bmad-bmm-create-app-spec --mode=edit`
- Or from CREATE mode final review: user selects [E]dit option

**Flow:**
- step-01-edit-init.md → step-02-edit-menu.md → step-03-save-edits.md

---

## User Guidance

### When to Choose Clean Slate

**Choose Overwrite if:**
- "I rewrote the PRD from scratch"
- "The existing spec has major structural issues"
- "I want to start fresh and apply new patterns"
- "I don't care about preserving feature IDs"

### When to Choose Evolutionary

**Choose Merge if:**
- "I updated the PRD with new features"
- "I manually refined criteria and want to keep them"
- "Feature IDs are referenced in external docs/tools"
- "I want incremental updates, not complete regeneration"

### When to Use Edit Mode

**Choose Edit Mode if:**
- "PRD hasn't changed, I just want to refine the spec"
- "I need to adjust categories or granularity"
- "I'm fixing issues found in validation"
- "I want surgical precision, not bulk regeneration"

---

## Best Practices

### 1. Backup Before Restart

**Before selecting Overwrite or Merge:**
- Save a copy of existing app_spec.txt
- Especially if manual edits were invested

**Workflow should warn:**
```
⚠️  **Recommended:** Backup your existing app_spec before proceeding.
Copy to: app_spec-backup-{date}.txt

Proceed without backup? [Y/N]
```

### 2. Review Merge Plan

**Before executing merge:**
- Always review the merge plan
- Check for unexpected "removed" features (might be false positives)
- Verify new feature IDs don't conflict

### 3. Use Edit Mode for Polish

**After CREATE or Merge:**
- Use validation workflow to identify issues
- Use edit mode to fix specific problems
- Avoid running CREATE/Merge repeatedly for minor fixes

### 4. Version Control

**Commit to git after each major change:**
- After initial creation
- After merge
- After significant edits

**Enables:**
- Rollback if merge goes wrong
- Track evolution over time
- Compare versions

---

## Edge Cases

### Case 1: Merge with No PRD Changes

**Scenario:** User runs Merge but PRD hasn't changed.

**Behavior:**
- Merge analysis shows: 0 new, 0 changed, 0 removed, all unchanged
- Display: "No PRD changes detected. Existing app_spec is up to date."
- Offer: [E]dit mode / [C]ancel

### Case 2: Merge with All Features Removed

**Scenario:** PRD was completely rewritten, no features match existing.

**Behavior:**
- Merge analysis shows: many new, 0 changed, all removed, 0 unchanged
- Display warning: "PRD appears completely rewritten. Consider Clean Slate instead?"
- Offer: [O]verwrite recommended / [M]erge anyway / [C]ancel

### Case 3: Continuation vs Restart

**Scenario:** User starts workflow, existing app_spec has incomplete stepsCompleted.

**Differentiation:**
- **Continuation:** stepsCompleted = ['step-01-init', 'step-02-prd-analysis', ...]
  - Route to step-01b-continue.md
  - Resume from last completed step
- **Restart:** stepsCompleted = ['step-01-init', ..., 'step-07-final-review'] (complete)
  - This is a restart variation
  - Present [O]verwrite / [M]erge / [C]ancel menu

### Case 4: Manual Edits Conflict with PRD Changes

**Scenario:** Feature criteria manually refined, but PRD requirements changed significantly.

**Behavior (Merge mode):**
- Detect conflict: PRD requirements diverge from existing feature
- Flag feature for review: "FEATURE_005 has manual edits but PRD requirements changed"
- Present options:
  - [K]eep manual edits (ignore PRD changes)
  - [U]pdate from PRD (lose manual edits)
  - [R]eview manually (show both versions)

---

## Technical Implementation Notes

### Diff Algorithm (for Merge Mode)

**Feature matching heuristic:**
1. Exact name match (case-insensitive)
2. Fuzzy name match (>80% similarity)
3. Section context match (same PRD section)
4. Manual review if uncertain

**Change detection:**
- Compare requirements lists (added, removed, modified)
- Compare descriptions (significant text change)
- Flag as "changed" if any divergence >20%

### Sequential ID Preservation

**Critical for Merge mode:**
- Never renumber existing features
- New features append after highest existing ID
- If deletions create gaps, keep gaps (document in frontmatter)

**Rationale:**
- External references to feature IDs remain valid
- Audit trail preserved
- Continuity maintained

---

## Usage in Workflow

This guide is referenced by:
- **step-01-init.md** - Restart variation detection and menu
- **step-02b-merge-mode.md** - Merge logic implementation
- **workflow.md** - Mode routing decisions

---

**Version:** 1.0
**Last Updated:** 2026-02-13
**Used By:** create-app-spec workflow (step-01, step-02b)
**Inspired By:** Autonomous Workflow Guide patterns for restart variations
