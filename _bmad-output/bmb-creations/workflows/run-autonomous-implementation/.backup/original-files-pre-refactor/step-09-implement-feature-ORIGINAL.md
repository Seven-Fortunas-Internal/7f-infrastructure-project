---
name: 'step-09-implement-feature'
description: 'Implement selected feature using bounded retry strategy'
nextStepFile: './step-10-test-feature.md'
featureListFile: '{project_folder}/feature_list.json'
buildLogFile: '{project_folder}/autonomous_build_log.md'
advancedElicitationTask: '{workflow_path}/../../../cis/advanced-elicitation/workflow.xml'
partyModeWorkflow: '{workflow_path}/../../../cis/party-mode/workflow.md'
---

# Step 09: Implement Feature

## STEP GOAL:
Implement the selected feature using appropriate strategy based on attempt number (standard → simplified → minimal), with optional Advanced Elicitation or Party Mode for refinement.

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: Feature Implementer (autonomous coding agent)
- ✅ Collaborative dialogue: Available via A/P menu
- ✅ You bring: Implementation logic, bounded retry strategy
- ✅ User brings: Selected feature data from step-08

### Step-Specific:
- 🎯 Focus: Implement feature per requirements, adapt strategy by attempt
- 🚫 Forbidden: Implementing without reading requirements, ignoring retry strategy
- 💬 Approach: Progressive degradation (standard → simplified → minimal)

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Create/modify files as needed for implementation
- 📖 Log all actions to autonomous_build_log.md

---

## CONTEXT BOUNDARIES:
- Available: Selected feature data (from step-08), app_spec.txt, project files
- Focus: Feature implementation (code, config, files)
- Limits: Does not test (that's step-10) or commit (that's step-12)
- Dependencies: Requires selected feature from step-08

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Implementation Start

```bash
echo "═══════════════════════════════════════════════════════"
echo "  IMPLEMENTING FEATURE"
echo "  $SELECTED_FEATURE_ID: $FEATURE_NAME"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Category: $FEATURE_CATEGORY"
echo "Attempt: $(($FEATURE_ATTEMPTS + 1))/3"
echo ""
```

---

### 2. Determine Implementation Approach

**Select strategy based on attempt number:**

```bash
echo "Determining implementation approach..."

case $FEATURE_ATTEMPTS in
    0)
        APPROACH="STANDARD"
        echo "  Strategy: STANDARD (full implementation per app_spec.txt)"
        echo "  Time budget: 5-10 minutes"
        echo "  Scope: All requirements, all verification criteria"
        ;;
    1)
        APPROACH="SIMPLIFIED"
        echo "  Strategy: SIMPLIFIED (skip optional requirements)"
        echo "  Time budget: 3-5 minutes"
        echo "  Scope: Core requirements only, minimal configuration"
        echo "  ⚠️  Attempt 2 - using alternative approach"
        ;;
    2)
        APPROACH="MINIMAL"
        echo "  Strategy: MINIMAL (bare essentials only)"
        echo "  Time budget: 1-2 minutes"
        echo "  Scope: Absolute minimum, placeholders acceptable"
        echo "  ⚠️  Attempt 3 - last try before blocking"
        ;;
    *)
        echo "❌ ERROR: Feature has $FEATURE_ATTEMPTS attempts (should have been blocked)"
        exit 36
        ;;
esac

echo ""
```

---

### 3. Display Feature Requirements

**Show what needs to be implemented:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  FEATURE REQUIREMENTS"
echo "─────────────────────────────────────────────────────"
echo ""
echo "$FEATURE_DESCRIPTION"
echo ""

if [[ -n "$FEATURE_REQUIREMENTS" ]]; then
    echo "Detailed Requirements:"
    echo "$FEATURE_REQUIREMENTS"
    echo ""
fi

if [[ -n "$IMPLEMENTATION_NOTES" ]]; then
    echo "Implementation Notes:"
    echo "$IMPLEMENTATION_NOTES"
    echo ""
fi

echo "Verification Criteria:"
if [[ -n "$FUNCTIONAL_CRITERIA" ]]; then
    echo "  ✓ Functional: $FUNCTIONAL_CRITERIA"
fi
if [[ -n "$TECHNICAL_CRITERIA" ]]; then
    echo "  ✓ Technical: $TECHNICAL_CRITERIA"
fi
if [[ -n "$INTEGRATION_CRITERIA" ]]; then
    echo "  ✓ Integration: $INTEGRATION_CRITERIA"
fi
echo ""
```

---

### 4. Mark Feature as In Progress

**Update status in feature_list.json:**

```bash
FEATURE_LIST_FILE="{featureListFile}"

echo "Marking feature as in_progress..."

# Create backup
cp "$FEATURE_LIST_FILE" "${FEATURE_LIST_FILE}.backup"

# Update status
jq --arg id "$SELECTED_FEATURE_ID" \
   '(.features[] | select(.id == $id)) |= .status = "in_progress"' \
   "$FEATURE_LIST_FILE" > "${FEATURE_LIST_FILE}.tmp"

if jq empty "${FEATURE_LIST_FILE}.tmp" 2>/dev/null; then
    mv "${FEATURE_LIST_FILE}.tmp" "$FEATURE_LIST_FILE"
    rm -f "${FEATURE_LIST_FILE}.backup"
    echo "✓ Status updated to in_progress"
else
    echo "❌ ERROR: Failed to update status"
    mv "${FEATURE_LIST_FILE}.backup" "$FEATURE_LIST_FILE"
    exit 37
fi

echo ""
```

---

### 5. Execute Implementation

**Implement based on selected approach:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  EXECUTING IMPLEMENTATION"
echo "─────────────────────────────────────────────────────"
echo ""

# Log implementation start
BUILD_LOG_FILE="{buildLogFile}"
cat >> "$BUILD_LOG_FILE" <<EOF

### $SELECTED_FEATURE_ID: $FEATURE_NAME

**Started:** $(date -u +%Y-%m-%d %H:%M:%S)
**Approach:** $APPROACH (attempt $(($FEATURE_ATTEMPTS + 1)))
**Category:** $FEATURE_CATEGORY

#### Implementation Actions:

EOF

# IMPLEMENTATION LOGIC SECTION
# This is where the actual feature implementation happens
# The agent will execute the appropriate actions based on:
# - Feature requirements from app_spec.txt
# - Selected approach (STANDARD/SIMPLIFIED/MINIMAL)
# - Feature category (Infrastructure, Integration, UI, etc.)

echo "Starting implementation..."
echo ""

# Example implementation patterns by approach:

if [[ "$APPROACH" == "STANDARD" ]]; then
    echo "Approach: STANDARD - Full implementation"
    echo ""
    echo "Following all requirements from app_spec.txt:"
    echo "  - Implementing all core functionality"
    echo "  - Configuring all settings as specified"
    echo "  - Setting up all integrations"
    echo "  - Ensuring all verification criteria can be tested"
    echo ""

    # STANDARD IMPLEMENTATION
    # The autonomous agent will:
    # 1. Read complete feature requirements
    # 2. Implement all functionality as specified
    # 3. Configure all settings
    # 4. Create necessary files/code/configs
    # 5. Set up integrations
    # 6. Prepare for all 3 verification criteria tests

elif [[ "$APPROACH" == "SIMPLIFIED" ]]; then
    echo "Approach: SIMPLIFIED - Core requirements only"
    echo ""
    echo "Simplifications from STANDARD:"
    echo "  - Skipping optional configurations"
    echo "  - Using alternative tools if primary approach failed"
    echo "  - Minimal configuration (essentials only)"
    echo "  - Focus on functional criteria, relax technical criteria"
    echo ""

    # SIMPLIFIED IMPLEMENTATION
    # The autonomous agent will:
    # 1. Identify core requirements only
    # 2. Skip optional features
    # 3. Use simpler alternatives (e.g., direct clone vs submodule)
    # 4. Minimal configuration
    # 5. Ensure functional criteria can be tested (may skip some technical)

elif [[ "$APPROACH" == "MINIMAL" ]]; then
    echo "Approach: MINIMAL - Bare essentials"
    echo ""
    echo "Minimal implementation strategy:"
    echo "  - Absolute bare minimum to satisfy functional criteria"
    echo "  - Placeholders acceptable (e.g., TODO comments)"
    echo "  - Skip technical polish"
    echo "  - Document what needs manual completion"
    echo "  - Create stub files if full implementation impossible"
    echo ""

    # MINIMAL IMPLEMENTATION
    # The autonomous agent will:
    # 1. Implement only what's needed for functional criteria
    # 2. Create placeholder files if needed
    # 3. Add TODO comments for manual completion
    # 4. Document limitations
    # 5. Accept that technical/integration criteria may not pass
fi

# ==============================================================
# ACTUAL IMPLEMENTATION HAPPENS HERE
# ==============================================================
# This section is intentionally left for the autonomous agent
# to execute based on the specific feature requirements.
#
# The agent will use available tools:
# - Bash commands (gh, git, mkdir, cat, etc.)
# - File operations (Write, Edit, Read)
# - Web browsing (for API docs, examples) if needed
#
# Implementation will vary based on feature category:
# - Infrastructure: Create repos, orgs, configure settings
# - Integration: Add submodules, create symlinks, configure APIs
# - UI: Create components, styling, interactions
# - Data: Create schemas, seed data, migrations
# - Security: Configure auth, secrets, permissions
# - Documentation: Create README, guides, API docs
# ==============================================================

echo ""
echo "Implementation details will be executed by autonomous agent..."
echo ""

# Log placeholder for implementation details
cat >> "$BUILD_LOG_FILE" <<EOF
1. **Analyzed requirements**
   - Feature category: $FEATURE_CATEGORY
   - Approach: $APPROACH
   - Attempt: $(($FEATURE_ATTEMPTS + 1))

2. **Implementation executed**
   (Implementation details logged by autonomous agent during execution)

EOF

echo "✓ Implementation logic executed"
echo ""
```

---

### 6. Log Implementation Completion

**Record actions taken:**

```bash
echo "Logging implementation completion..."

cat >> "$BUILD_LOG_FILE" <<EOF
3. **Implementation completed**
   - Approach: $APPROACH
   - Status: Ready for verification
   - Next: Testing verification criteria

**Completed:** $(date -u +%Y-%m-%d %H:%M:%S)

EOF

echo "✓ Implementation logged"
echo ""
```

---

### 7. Display Implementation Summary

```
─────────────────────────────────────────────────────
  IMPLEMENTATION COMPLETE
─────────────────────────────────────────────────────

Feature: $SELECTED_FEATURE_ID - $FEATURE_NAME
Approach: $APPROACH
Attempt: $(($FEATURE_ATTEMPTS + 1))/3

Actions Taken:
  (Implementation details logged in autonomous_build_log.md)

Status: Ready for verification testing

Next Step: Test verification criteria
```

---

### 8. Present MENU OPTIONS

**CRITICAL:** This is the ONLY interactive step in the Coding loop

```
**Select an Option:**
[A] Advanced Elicitation (refine implementation approach)
[P] Party Mode (brainstorm alternative solutions)
[C] Continue (proceed to verification testing)
```

---

### 9. Menu Handling Logic

**Handle user selection:**

```bash
#### Menu Handling Logic:

- IF A: Execute {advancedElicitationTask}, and when finished redisplay the menu
  (Use case: Implementation is complex, need to analyze approach before testing)

- IF P: Execute {partyModeWorkflow}, and when finished redisplay the menu
  (Use case: Implementation failed previously, brainstorm new approaches)

- IF C: Save implementation status, update autonomous_build_log.md, then load, read entire file, then execute {nextStepFile}
  (Proceed to verification testing)

- IF Any other: "Invalid selection. Choose [A] Advanced Elicitation, [P] Party Mode, or [C] Continue", then [Redisplay Menu Options](#8-present-menu-options)
```

---

### 10. EXECUTION RULES

```bash
#### EXECUTION RULES:
- ALWAYS halt and wait for user input after presenting menu
- ONLY proceed to next step when user selects 'C'
- After Advanced Elicitation or Party Mode execution, return to this menu
- Do NOT auto-proceed (this is the only decision point for user refinement)
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- Implementation approach determined (STANDARD/SIMPLIFIED/MINIMAL)
- Feature requirements displayed
- Status updated to "in_progress" in feature_list.json
- Implementation executed based on approach
- Actions logged to autonomous_build_log.md
- Implementation summary displayed
- Menu presented (A/P/C)
- User makes selection
- If C: Ready for step-10 (verification testing)

### ❌ FAILURE:
- Feature has ≥3 attempts (should have been blocked) (exit code 36)
- Failed to update status to in_progress (exit code 37)

**Master Rule:** Implementation must be executed before proceeding to verification.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete (ONLY interactive step in Coding loop)
