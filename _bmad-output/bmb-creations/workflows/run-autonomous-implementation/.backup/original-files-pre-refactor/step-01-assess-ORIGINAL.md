---
name: 'step-01-assess'
description: 'Display current implementation state and present editing options'
nextStepFile: './step-02-edit-features.md'
circuitBreakerStepFile: './step-03-edit-circuit-breaker.md'
completeStepFile: './step-04-complete.md'
featureListFile: '{project_folder}/feature_list.json'
progressFile: '{project_folder}/claude-progress.txt'
---

# Step 01: Assess Current State (EDIT Mode)

## STEP GOAL:
Display complete implementation state (features, circuit breaker, sessions) and present menu for editing options.

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: State Inspector (read-only assessment)
- ✅ Collaborative dialogue: Menu-based navigation
- ✅ You bring: State loading, display formatting
- ✅ User brings: Decision on what to edit

### Step-Specific:
- 🎯 Focus: Comprehensive state display
- 🚫 Forbidden: Making changes (that's steps 2-3)
- 💬 Approach: Clear presentation with editing options

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Read-only mode (no file modifications)
- 📖 Present menu after state display

---

## CONTEXT BOUNDARIES:
- Available: All tracking files (feature_list.json, claude-progress.txt)
- Focus: State assessment and option presentation
- Limits: Does not edit (routes to appropriate edit step)
- Dependencies: Requires existing implementation (feature_list.json)

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display EDIT Mode Banner

```
═══════════════════════════════════════════════════════
  EDIT MODE - Implementation State Assessment
  Review and Modify Tracking State
═══════════════════════════════════════════════════════
```

---

### 2. Validate Tracking Files Exist

**Check prerequisites:**

```bash
FEATURE_LIST_FILE="{featureListFile}"
PROGRESS_FILE="{progressFile}"

echo ""
echo "Validating tracking files..."

# Check feature_list.json
if [[ ! -f "$FEATURE_LIST_FILE" ]]; then
    echo "❌ ERROR: feature_list.json not found"
    echo "   Path: $FEATURE_LIST_FILE"
    echo ""
    echo "EDIT mode requires an existing implementation."
    echo "Run CREATE mode first to initialize tracking."
    exit 1
fi

# Check claude-progress.txt
if [[ ! -f "$PROGRESS_FILE" ]]; then
    echo "❌ ERROR: claude-progress.txt not found"
    echo "   Path: $PROGRESS_FILE"
    echo ""
    echo "Progress file missing. Cannot assess state."
    exit 2
fi

# Validate JSON syntax
if ! jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then
    echo "❌ ERROR: feature_list.json is corrupted (invalid JSON)"
    echo ""
    echo "File may have been manually edited incorrectly."
    echo "Fix JSON syntax or restore from backup."
    exit 3
fi

echo "✓ Tracking files validated"
echo ""
```

---

### 3. Load Implementation State

**Read current status:**

```bash
echo "Loading implementation state..."

# Feature statistics
TOTAL_FEATURES=$(jq -r '.metadata.total_features' "$FEATURE_LIST_FILE")
PROJECT_NAME=$(jq -r '.metadata.project_name' "$FEATURE_LIST_FILE")
GENERATED_DATE=$(jq -r '.metadata.generated_date' "$FEATURE_LIST_FILE")

PASS_COUNT=$(jq -r '.features[] | select(.status == "pass") | .id' "$FEATURE_LIST_FILE" | wc -l)
PENDING_COUNT=$(jq -r '.features[] | select(.status == "pending") | .id' "$FEATURE_LIST_FILE" | wc -l)
FAIL_COUNT=$(jq -r '.features[] | select(.status == "fail") | .id' "$FEATURE_LIST_FILE" | wc -l)
BLOCKED_COUNT=$(jq -r '.features[] | select(.status == "blocked") | .id' "$FEATURE_LIST_FILE" | wc -l)
IN_PROGRESS_COUNT=$(jq -r '.features[] | select(.status == "in_progress") | .id' "$FEATURE_LIST_FILE" | wc -l)

# Circuit breaker state
SESSION_COUNT=$(grep '^session_count=' "$PROGRESS_FILE" | cut -d= -f2)
CONSECUTIVE_FAILURES=$(grep '^consecutive_failures=' "$PROGRESS_FILE" | cut -d= -f2)
THRESHOLD=$(grep '^circuit_breaker_threshold=' "$PROGRESS_FILE" | cut -d= -f2)
CB_STATUS=$(grep '^circuit_breaker_status=' "$PROGRESS_FILE" | cut -d= -f2)

# Defaults
SESSION_COUNT=${SESSION_COUNT:-0}
CONSECUTIVE_FAILURES=${CONSECUTIVE_FAILURES:-0}
THRESHOLD=${THRESHOLD:-5}
CB_STATUS=${CB_STATUS:-HEALTHY}

# Last session
LAST_SESSION_SUCCESS=$(grep '^last_session_success=' "$PROGRESS_FILE" | cut -d= -f2)
LAST_SESSION_DATE=$(grep '^last_session_date=' "$PROGRESS_FILE" | cut -d= -f2)

echo "✓ State loaded"
echo ""
```

---

### 4. Display Project Overview

```
─────────────────────────────────────────────────────
  PROJECT OVERVIEW
─────────────────────────────────────────────────────

Project: $PROJECT_NAME
Generated: $GENERATED_DATE
Total Features: $TOTAL_FEATURES
Sessions Completed: $SESSION_COUNT

Last Session:
  Date: ${LAST_SESSION_DATE:-N/A}
  Success: ${LAST_SESSION_SUCCESS:-N/A}
```

---

### 5. Display Feature Status

```
─────────────────────────────────────────────────────
  FEATURE STATUS
─────────────────────────────────────────────────────

Status Distribution ($TOTAL_FEATURES total):
  ✓ Pass:        $PASS_COUNT ($(( PASS_COUNT * 100 / TOTAL_FEATURES ))%)
  ⏳ Pending:     $PENDING_COUNT ($(( PENDING_COUNT * 100 / TOTAL_FEATURES ))%)
  🔄 In Progress: $IN_PROGRESS_COUNT
  ❌ Fail:        $FAIL_COUNT
  🚫 Blocked:     $BLOCKED_COUNT

Progress: $(( (PASS_COUNT + BLOCKED_COUNT) * 100 / TOTAL_FEATURES ))% complete or blocked
```

---

### 6. Display Feature Details by Status

**Show features grouped by status:**

```bash
echo ""
echo "─────────────────────────────────────────────────────"
echo "  FEATURE DETAILS"
echo "─────────────────────────────────────────────────────"
echo ""

# Pass
if [[ $PASS_COUNT -gt 0 ]]; then
    echo "✓ PASSED FEATURES ($PASS_COUNT):"
    echo ""
    jq -r '.features[] | select(.status == "pass") |
        "  \(.id) - \(.name) (attempts: \(.attempts))"' \
        "$FEATURE_LIST_FILE"
    echo ""
fi

# Pending
if [[ $PENDING_COUNT -gt 0 ]]; then
    echo "⏳ PENDING FEATURES ($PENDING_COUNT):"
    echo ""
    jq -r '.features[] | select(.status == "pending") |
        "  \(.id) - \(.name)"' \
        "$FEATURE_LIST_FILE"
    echo ""
fi

# In Progress
if [[ $IN_PROGRESS_COUNT -gt 0 ]]; then
    echo "🔄 IN PROGRESS FEATURES ($IN_PROGRESS_COUNT):"
    echo ""
    jq -r '.features[] | select(.status == "in_progress") |
        "  \(.id) - \(.name) (attempts: \(.attempts))"' \
        "$FEATURE_LIST_FILE"
    echo ""
fi

# Fail
if [[ $FAIL_COUNT -gt 0 ]]; then
    echo "❌ FAILED FEATURES ($FAIL_COUNT):"
    echo ""
    jq -r '.features[] | select(.status == "fail") |
        "  \(.id) - \(.name) (attempts: \(.attempts)/3)\n    Note: \(.implementation_notes // "No notes")"' \
        "$FEATURE_LIST_FILE"
    echo ""
fi

# Blocked
if [[ $BLOCKED_COUNT -gt 0 ]]; then
    echo "🚫 BLOCKED FEATURES ($BLOCKED_COUNT):"
    echo ""
    jq -r '.features[] | select(.status == "blocked") |
        "  \(.id) - \(.name) (attempts: \(.attempts))\n    Reason: \(.blocked_reason // "No reason specified")"' \
        "$FEATURE_LIST_FILE"
    echo ""
fi
```

---

### 7. Display Circuit Breaker State

```
─────────────────────────────────────────────────────
  CIRCUIT BREAKER STATE
─────────────────────────────────────────────────────

Status: $(if [[ "$CB_STATUS" == "TRIGGERED" ]]; then echo "🔴 TRIGGERED"; else echo "✓ $CB_STATUS"; fi)
Consecutive Failures: $CONSECUTIVE_FAILURES / $THRESHOLD
Threshold: $THRESHOLD sessions

$(if [[ "$CB_STATUS" == "TRIGGERED" ]]; then
    echo "⚠️  Circuit breaker is TRIGGERED - workflow will exit immediately"
    echo "   Reset consecutive_failures to 0 to resume implementation"
elif [[ $CONSECUTIVE_FAILURES -gt 0 ]]; then
    REMAINING=$((THRESHOLD - CONSECUTIVE_FAILURES))
    echo "⚠️  Warning: $CONSECUTIVE_FAILURES consecutive failure(s)"
    echo "   $REMAINING more failure(s) until circuit breaker triggers"
else
    echo "✓ No consecutive failures - healthy state"
fi)
```

---

### 8. Display Actionable Insights

**Suggest what user might want to edit:**

```bash
echo ""
echo "─────────────────────────────────────────────────────"
echo "  ACTIONABLE INSIGHTS"
echo "─────────────────────────────────────────────────────"
echo ""

# Calculate actionable work
RETRY_ELIGIBLE=$(jq -r '.features[] | select(.status == "fail" and .attempts < 3) | .id' "$FEATURE_LIST_FILE" | wc -l)
ACTIONABLE=$((PENDING_COUNT + RETRY_ELIGIBLE))

if [[ $ACTIONABLE -gt 0 ]]; then
    echo "✓ $ACTIONABLE features available for implementation"
    echo "  ($PENDING_COUNT pending + $RETRY_ELIGIBLE eligible for retry)"
fi

if [[ $BLOCKED_COUNT -gt 0 ]]; then
    echo ""
    echo "⚠️  $BLOCKED_COUNT blocked features may need manual intervention"
    echo "   Consider resetting status to 'pending' or 'fail' to retry"
fi

if [[ $IN_PROGRESS_COUNT -gt 0 ]]; then
    echo ""
    echo "⚠️  $IN_PROGRESS_COUNT features stuck 'in_progress'"
    echo "   Implementation may have been interrupted"
    echo "   Reset to 'pending' or 'fail' to retry"
fi

if [[ "$CB_STATUS" == "TRIGGERED" ]]; then
    echo ""
    echo "🔴 Circuit breaker is blocking further implementation"
    echo "   Reset consecutive_failures to resume workflow"
fi

if [[ $FAIL_COUNT -gt 0 && $RETRY_ELIGIBLE -eq 0 ]]; then
    echo ""
    echo "⚠️  $FAIL_COUNT failed features have exhausted retries (3 attempts)"
    echo "   Reset attempts counter to allow retry"
fi

echo ""
```

---

### 9. Present Editing Menu

**Menu Handling Logic:**
- This step uses **User Menu** (wait for selection)
- Options: [F] Features, [C] Circuit Breaker, [X] Exit
- Route based on user choice

```
═══════════════════════════════════════════════════════
  EDIT OPTIONS
═══════════════════════════════════════════════════════

What would you like to edit?

[F] Features       - Modify feature status, attempts, or blocked reasons
[C] Circuit Breaker - Reset consecutive failures or change threshold
[X] Exit           - Save and exit EDIT mode

Select option [F/C/X]:
```

**Execution:**

```bash
read -p "→ " EDIT_CHOICE

case "$EDIT_CHOICE" in
    F|f)
        echo ""
        echo "Proceeding to feature editing..."
        echo ""
        load_and_execute "{nextStepFile}"
        ;;
    C|c)
        echo ""
        echo "Proceeding to circuit breaker editing..."
        echo ""
        load_and_execute "{circuitBreakerStepFile}"
        ;;
    X|x)
        echo ""
        echo "Exiting EDIT mode..."
        echo ""
        load_and_execute "{completeStepFile}"
        ;;
    *)
        echo ""
        echo "❌ Invalid option: $EDIT_CHOICE"
        echo "   Please select F, C, or X"
        exit 4
        ;;
esac
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- Tracking files validated (exist, valid JSON)
- Implementation state loaded (features, circuit breaker, sessions)
- Project overview displayed
- Feature status summary shown
- Feature details by status listed
- Circuit breaker state displayed
- Actionable insights provided
- Editing menu presented
- User choice routed to appropriate step

### ❌ FAILURE:
- feature_list.json not found (exit code 1)
- claude-progress.txt not found (exit code 2)
- feature_list.json corrupted (invalid JSON) (exit code 3)
- Invalid menu selection (exit code 4)

**Master Rule:** EDIT mode provides read-only assessment before routing to modification steps.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
