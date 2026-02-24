---
name: 'step-07-load-session-state'
description: 'Load current implementation state and display session context'
nextStepFile: './step-08-select-next-feature.md'
featureListFile: '{project_folder}/feature_list.json'
progressFile: '{project_folder}/claude-progress.txt'
---

# Step 07: Load Session State

## STEP GOAL:
Read feature_list.json and claude-progress.txt to understand current implementation status, then prepare for feature selection.

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: State Loader (Coding Agent mode entry)
- ✅ Collaborative dialogue: None (automated state loading)
- ✅ You bring: State parsing, statistics calculation
- ✅ User brings: Existing implementation state

### Step-Specific:
- 🎯 Focus: Load state, calculate statistics, display context
- 🚫 Forbidden: Modifying state files (read-only)
- 💬 Approach: Comprehensive state analysis with clear display

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Do NOT modify state files (read-only step)
- 📖 Load complete state into memory for next steps

---

## CONTEXT BOUNDARIES:
- Available: feature_list.json, claude-progress.txt
- Focus: State loading and analysis
- Limits: Does not select or implement features
- Dependencies: Requires valid state files from Session 1 or previous sessions

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Session Start Banner

```bash
# Increment session count for display
CURRENT_SESSION=$(grep '^session_count=' "{progressFile}" | cut -d= -f2)
NEXT_SESSION=$((CURRENT_SESSION + 1))

echo "═══════════════════════════════════════════════════════"
echo "  SESSION $NEXT_SESSION: CODING AGENT"
echo "  Autonomous Feature Implementation"
echo "═══════════════════════════════════════════════════════"
```

---

### 2. Load feature_list.json

**Read complete feature list into memory:**

```bash
FEATURE_LIST_FILE="{featureListFile}"

echo ""
echo "Loading feature_list.json..."

if [[ ! -f "$FEATURE_LIST_FILE" ]]; then
    echo "❌ ERROR: feature_list.json not found"
    echo "   Expected: $FEATURE_LIST_FILE"
    exit 31
fi

# Validate JSON
if ! jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then
    echo "❌ ERROR: feature_list.json contains invalid JSON"
    exit 32
fi

# Load into memory
FEATURE_LIST=$(cat "$FEATURE_LIST_FILE")
TOTAL_FEATURES=$(echo "$FEATURE_LIST" | jq -r '.metadata.total_features')
PROJECT_NAME=$(echo "$FEATURE_LIST" | jq -r '.metadata.project_name')

echo "✓ Loaded: $TOTAL_FEATURES features"
echo "  Project: $PROJECT_NAME"
```

---

### 3. Calculate Feature Statistics

**Count features by status:**

```bash
echo ""
echo "Analyzing feature statuses..."

# Count by status
PASS_COUNT=$(echo "$FEATURE_LIST" | jq -r '.features[] | select(.status == "pass") | .id' | wc -l)
PENDING_COUNT=$(echo "$FEATURE_LIST" | jq -r '.features[] | select(.status == "pending") | .id' | wc -l)
FAIL_COUNT=$(echo "$FEATURE_LIST" | jq -r '.features[] | select(.status == "fail") | .id' | wc -l)
BLOCKED_COUNT=$(echo "$FEATURE_LIST" | jq -r '.features[] | select(.status == "blocked") | .id' | wc -l)
IN_PROGRESS_COUNT=$(echo "$FEATURE_LIST" | jq -r '.features[] | select(.status == "in_progress") | .id' | wc -l)

# Calculate actionable features (pending + fail with attempts < 3)
RETRY_ELIGIBLE=$(echo "$FEATURE_LIST" | jq -r '.features[] | select(.status == "fail" and .attempts < 3) | .id' | wc -l)
ACTIONABLE_COUNT=$((PENDING_COUNT + RETRY_ELIGIBLE))

# Calculate completion percentage
COMPLETE_COUNT=$PASS_COUNT
PERCENTAGE=$((COMPLETE_COUNT * 100 / TOTAL_FEATURES))

echo "✓ Statistics calculated"
```

---

### 4. Load Circuit Breaker State

**Read progress file metadata:**

```bash
PROGRESS_FILE="{progressFile}"

echo ""
echo "Loading circuit breaker state..."

if [[ ! -f "$PROGRESS_FILE" ]]; then
    echo "⚠️  Warning: claude-progress.txt not found"
    echo "  Will create with default values"

    # Set defaults
    SESSION_COUNT=1
    CONSECUTIVE_FAILURES=0
    CIRCUIT_BREAKER_STATUS="HEALTHY"
    THRESHOLD=5
else
    # Parse metadata
    SESSION_COUNT=$(grep '^session_count=' "$PROGRESS_FILE" | cut -d= -f2)
    CONSECUTIVE_FAILURES=$(grep '^consecutive_failures=' "$PROGRESS_FILE" | cut -d= -f2)
    CIRCUIT_BREAKER_STATUS=$(grep '^circuit_breaker_status=' "$PROGRESS_FILE" | cut -d= -f2)
    THRESHOLD=$(grep '^circuit_breaker_threshold=' "$PROGRESS_FILE" | cut -d= -f2)
    LAST_SESSION_SUCCESS=$(grep '^last_session_success=' "$PROGRESS_FILE" | cut -d= -f2)

    # Defaults if not found
    SESSION_COUNT=${SESSION_COUNT:-1}
    CONSECUTIVE_FAILURES=${CONSECUTIVE_FAILURES:-0}
    CIRCUIT_BREAKER_STATUS=${CIRCUIT_BREAKER_STATUS:-HEALTHY}
    THRESHOLD=${THRESHOLD:-5}
    LAST_SESSION_SUCCESS=${LAST_SESSION_SUCCESS:-true}

    echo "✓ Circuit breaker state loaded"
fi
```

---

### 5. Display Current Status

```
─────────────────────────────────────────────────────
  CURRENT IMPLEMENTATION STATUS
─────────────────────────────────────────────────────

Project: $PROJECT_NAME
Session: $((SESSION_COUNT + 1))
Progress: $COMPLETE_COUNT/$TOTAL_FEATURES ($PERCENTAGE%)

Features by Status:
  ✓ Pass:        $PASS_COUNT
  ⏳ Pending:     $PENDING_COUNT
  ❌ Fail:        $FAIL_COUNT (retry eligible: $RETRY_ELIGIBLE)
  🚫 Blocked:     $BLOCKED_COUNT
  🔄 In Progress: $IN_PROGRESS_COUNT

Actionable Features: $ACTIONABLE_COUNT

Circuit Breaker:
  Status: $CIRCUIT_BREAKER_STATUS
  Consecutive failures: $CONSECUTIVE_FAILURES/$THRESHOLD
  Last session: $(if [[ "$LAST_SESSION_SUCCESS" == "true" ]]; then echo "SUCCESS"; else echo "FAILED"; fi)
$(if [[ $CONSECUTIVE_FAILURES -gt 0 ]]; then
    echo ""
    echo "  ⚠️  Warning: $CONSECUTIVE_FAILURES consecutive failure(s)"
    if [[ $((CONSECUTIVE_FAILURES + 1)) -ge $THRESHOLD ]]; then
        echo "  ⚠️  NEXT FAILURE WILL TRIGGER CIRCUIT BREAKER!"
    fi
fi)
```

---

### 6. Check If Work Remains

**Determine if there are features to implement:**

```bash
echo ""

if [[ $ACTIONABLE_COUNT -eq 0 ]]; then
    if [[ $BLOCKED_COUNT -gt 0 ]]; then
        echo "⚠️  No actionable features remaining"
        echo ""
        echo "  All features are either complete or blocked."
        echo ""
        echo "  Blocked features: $BLOCKED_COUNT"
        echo "  $(echo "$FEATURE_LIST" | jq -r '.features[] | select(.status == "blocked") | "  - \(.id): \(.name)"')"
        echo ""
        echo "  Options:"
        echo "  1. Use EDIT mode to unblock features"
        echo "  2. Manually fix blocking issues"
        echo "  3. Accept current state as complete"
        echo ""
        exit 0
    elif [[ $PASS_COUNT -eq $TOTAL_FEATURES ]]; then
        echo "🎉 All features complete!"
        echo ""
        echo "  Implementation is 100% complete."
        echo "  All $TOTAL_FEATURES features have passed verification."
        echo ""
        echo "  Proceeding to completion step..."
        load_and_execute "./step-14-complete.md"
        exit 0
    fi
fi

echo "✓ Actionable features available: $ACTIONABLE_COUNT"
```

---

### 7. Display Recent Activity

**Show last few completed features:**

```bash
echo ""
echo "Recent Activity:"

# Get last 5 completed features
RECENT=$(echo "$FEATURE_LIST" | jq -r '.features[] | select(.status == "pass" and .last_updated != null) | {id, name, updated: .last_updated} | "\(.updated): \(.id) - \(.name)"' | sort -r | head -5)

if [[ -n "$RECENT" ]]; then
    echo "$RECENT" | while read line; do
        echo "  ✓ $line"
    done
else
    echo "  (No features completed yet)"
fi

echo ""
```

---

### 8. State Loading Complete

```
─────────────────────────────────────────────────────
  STATE LOADED SUCCESSFULLY
─────────────────────────────────────────────────────

Ready to select next feature for implementation.

Proceeding to feature selection...
```

---

### 9. Proceed to Next Step

**Menu Handling Logic:**
- This step uses **Auto-proceed** (no menu)
- State is now loaded into memory
- Next step will use this state to select a feature

**Execution:**

```
→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- feature_list.json loaded and validated
- Feature statistics calculated (pass/pending/fail/blocked counts)
- Actionable features identified (pending + fail with attempts < 3)
- Circuit breaker state loaded
- Completion percentage calculated
- Current status displayed
- Recent activity shown
- Confirmed work remains (actionable features > 0)
- Ready for step-08 (feature selection)

### ❌ FAILURE:
- feature_list.json not found (exit code 31)
- feature_list.json invalid JSON (exit code 32)
- No actionable features (exit 0 with message)
- All features complete (route to step-14 instead)

**Master Rule:** Must load and validate state before selecting features.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
