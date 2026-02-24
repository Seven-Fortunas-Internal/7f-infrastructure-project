---
name: 'step-01b-continue'
description: 'Handle workflow continuation and route to Coding Agent mode'
nextStepFile: './step-07-load-session-state.md'
outputFile: '{project_folder}/feature_list.json'
progressFile: '{project_folder}/claude-progress.txt'
workflowFile: '{workflow_path}/workflow.md'
---

# Step 01b: Continuation - Route to Coding Agent Mode

## STEP GOAL:
Detect existing workflow, load state, verify circuit breaker status, and route to Coding Agent mode (Session 2+).

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: Autonomous Implementation Orchestrator (Continuation Handler)
- ✅ Collaborative dialogue: None (fully automated)
- ✅ You bring: State validation, circuit breaker checks
- ✅ User brings: Existing implementation state

### Step-Specific:
- 🎯 Focus: Validate existing state and route to Coding mode
- 🚫 Forbidden: Skipping circuit breaker check, ignoring corrupted state
- 💬 Approach: Automated validation with clear status messages

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 This step does NOT modify state files (read-only validation)
- 📖 Always route to step-07 (load session state) after validation

---

## CONTEXT BOUNDARIES:
- Available: feature_list.json, claude-progress.txt (if exists)
- Focus: State validation, circuit breaker status
- Limits: Does not implement features or modify state
- Dependencies: Valid feature_list.json required

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Continuation Banner

```
═══════════════════════════════════════════════════════
  CONTINUING AUTONOMOUS IMPLEMENTATION
  Coding Agent Mode (Session 2+)
═══════════════════════════════════════════════════════
```

---

### 2. Validate feature_list.json

**Read and validate existing workflow state:**

```bash
PROJECT_FOLDER="{project_folder}"
FEATURE_LIST="${PROJECT_FOLDER}/feature_list.json"

# Verify file exists (should always be true if we got here)
if [[ ! -f "$FEATURE_LIST" ]]; then
    echo "❌ ERROR: feature_list.json not found"
    echo "   Expected: $FEATURE_LIST"
    echo "   This should not happen (routing error)"
    exit 11
fi

# Verify valid JSON
if ! jq empty "$FEATURE_LIST" 2>/dev/null; then
    echo "❌ ERROR: feature_list.json contains invalid JSON"
    echo ""
    echo "   File: $FEATURE_LIST"
    echo ""
    echo "   Recovery options:"
    echo "   1. Restore from git: git checkout HEAD feature_list.json"
    echo "   2. Start fresh: Delete file and restart workflow"
    echo ""
    exit 12
fi

# Verify features array exists
FEATURE_COUNT=$(jq '.features | length' "$FEATURE_LIST" 2>/dev/null)

if [[ -z "$FEATURE_COUNT" || "$FEATURE_COUNT" -eq 0 ]]; then
    echo "❌ ERROR: feature_list.json has no features"
    echo ""
    echo "   File appears empty or malformed."
    echo "   Consider starting fresh (delete file and restart)."
    echo ""
    exit 13
fi

echo "✓ feature_list.json is valid ($FEATURE_COUNT features)"
```

---

### 3. Check for claude-progress.txt

**Verify progress tracking file exists:**

```bash
PROGRESS_FILE="${PROJECT_FOLDER}/claude-progress.txt"

if [[ ! -f "$PROGRESS_FILE" ]]; then
    echo "⚠️  Warning: claude-progress.txt not found"
    echo ""
    echo "   This file should exist if workflow was started properly."
    echo "   It will be recreated in step-07 with default values."
    echo ""

    # Set defaults for circuit breaker check
    CONSECUTIVE_FAILURES=0
    SESSION_COUNT=1
    CIRCUIT_BREAKER_STATUS="UNKNOWN"
else
    echo "✓ claude-progress.txt found"
fi
```

---

### 4. Parse Circuit Breaker State

**Read circuit breaker metadata from claude-progress.txt:**

```bash
if [[ -f "$PROGRESS_FILE" ]]; then
    # Parse metadata header
    CONSECUTIVE_FAILURES=$(grep '^consecutive_failures=' "$PROGRESS_FILE" 2>/dev/null | cut -d= -f2)
    THRESHOLD=$(grep '^circuit_breaker_threshold=' "$PROGRESS_FILE" 2>/dev/null | cut -d= -f2)
    CIRCUIT_BREAKER_STATUS=$(grep '^circuit_breaker_status=' "$PROGRESS_FILE" 2>/dev/null | cut -d= -f2)
    SESSION_COUNT=$(grep '^session_count=' "$PROGRESS_FILE" 2>/dev/null | cut -d= -f2)
    LAST_SESSION_SUCCESS=$(grep '^last_session_success=' "$PROGRESS_FILE" 2>/dev/null | cut -d= -f2)

    # Defaults if not found
    CONSECUTIVE_FAILURES=${CONSECUTIVE_FAILURES:-0}
    THRESHOLD=${THRESHOLD:-5}
    CIRCUIT_BREAKER_STATUS=${CIRCUIT_BREAKER_STATUS:-HEALTHY}
    SESSION_COUNT=${SESSION_COUNT:-1}
    LAST_SESSION_SUCCESS=${LAST_SESSION_SUCCESS:-true}

    echo ""
    echo "Circuit Breaker Status:"
    echo "  - Consecutive failures: $CONSECUTIVE_FAILURES"
    echo "  - Threshold: $THRESHOLD"
    echo "  - Status: $CIRCUIT_BREAKER_STATUS"
    echo "  - Session count: $SESSION_COUNT"
    echo "  - Last session success: $LAST_SESSION_SUCCESS"
fi
```

---

### 5. Check if Circuit Breaker is Triggered

**CRITICAL:** Prevent starting new session if circuit breaker already triggered

```bash
if [[ "$CIRCUIT_BREAKER_STATUS" == "TRIGGERED" ]] || [[ $CONSECUTIVE_FAILURES -ge $THRESHOLD ]]; then
    echo ""
    echo "🔴 CIRCUIT BREAKER ALREADY TRIGGERED"
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  WORKFLOW STOPPED DUE TO REPEATED FAILURES"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo "Status: $CONSECUTIVE_FAILURES consecutive failed sessions"
    echo "Threshold: $THRESHOLD"
    echo ""
    echo "This workflow was stopped because multiple sessions made no progress."
    echo ""
    if [[ -f "${PROJECT_FOLDER}/autonomous_summary_report.md" ]]; then
        echo "Review the summary report for details:"
        echo "  ${PROJECT_FOLDER}/autonomous_summary_report.md"
        echo ""
    fi
    echo "To resume implementation:"
    echo "  1. Review blocked features in feature_list.json"
    echo "  2. Fix external blockers (API authentication, missing dependencies)"
    echo "  3. Use EDIT mode to reset circuit breaker:"
    echo "     /bmad-bmm-run-autonomous-implementation --mode=edit"
    echo "     Select [C] Circuit Breaker"
    echo "     Set consecutive_failures = 0"
    echo "  4. Restart workflow:"
    echo "     /bmad-bmm-run-autonomous-implementation"
    echo ""
    echo "Exiting with code 42 (circuit breaker triggered)"
    exit 42
fi

# Circuit breaker OK
if [[ $CONSECUTIVE_FAILURES -gt 0 ]]; then
    echo ""
    echo "⚠️  Circuit Breaker Warning: $CONSECUTIVE_FAILURES/$THRESHOLD failures"
    echo "   If this session fails, consecutive failures will be $((CONSECUTIVE_FAILURES + 1))"
    if [[ $((CONSECUTIVE_FAILURES + 1)) -ge $THRESHOLD ]]; then
        echo "   ⚠️  NEXT FAILURE WILL TRIGGER CIRCUIT BREAKER!"
    fi
else
    echo ""
    echo "✓ Circuit Breaker: HEALTHY (0 consecutive failures)"
fi
```

---

### 6. Display Current Implementation Status

**Show quick summary of features:**

```bash
echo ""
echo "─────────────────────────────────────────────────────"
echo "  CURRENT IMPLEMENTATION STATUS"
echo "─────────────────────────────────────────────────────"

# Count features by status
PASS_COUNT=$(jq -r '.features[] | select(.status == "pass") | .id' "$FEATURE_LIST" | wc -l)
PENDING_COUNT=$(jq -r '.features[] | select(.status == "pending") | .id' "$FEATURE_LIST" | wc -l)
FAIL_COUNT=$(jq -r '.features[] | select(.status == "fail") | .id' "$FEATURE_LIST" | wc -l)
BLOCKED_COUNT=$(jq -r '.features[] | select(.status == "blocked") | .id' "$FEATURE_LIST" | wc -l)
IN_PROGRESS_COUNT=$(jq -r '.features[] | select(.status == "in_progress") | .id' "$FEATURE_LIST" | wc -l)

echo ""
echo "Features by Status:"
echo "  ✓ Pass:        $PASS_COUNT"
echo "  ⏳ Pending:     $PENDING_COUNT"
echo "  ❌ Fail:        $FAIL_COUNT"
echo "  🚫 Blocked:     $BLOCKED_COUNT"
echo "  🔄 In Progress: $IN_PROGRESS_COUNT"
echo ""
echo "Total Features: $FEATURE_COUNT"
echo ""

# Calculate completion percentage
COMPLETE_COUNT=$PASS_COUNT
PERCENTAGE=$((COMPLETE_COUNT * 100 / FEATURE_COUNT))
echo "Progress: $COMPLETE_COUNT/$FEATURE_COUNT ($PERCENTAGE%)"
```

---

### 7. Display Last Session Info

**Show when last session ran:**

```bash
if [[ -f "$PROGRESS_FILE" ]]; then
    LAST_SESSION_DATE=$(grep '^last_session_date=' "$PROGRESS_FILE" 2>/dev/null | cut -d= -f2)

    if [[ -n "$LAST_SESSION_DATE" ]]; then
        echo ""
        echo "Last Session: $LAST_SESSION_DATE"
        echo "Session Count: $SESSION_COUNT"

        # Show last session log entry
        LAST_SESSION_LOG=$(grep "^## Session" "$PROGRESS_FILE" | tail -1)
        if [[ -n "$LAST_SESSION_LOG" ]]; then
            echo "Last Entry: $LAST_SESSION_LOG"
        fi
    fi
fi
```

---

### 8. Validation Complete - Route to Coding Mode

```
─────────────────────────────────────────────────────
  VALIDATION COMPLETE
─────────────────────────────────────────────────────

Session Type: Coding Agent (Session $(($SESSION_COUNT + 1)))
Circuit Breaker: HEALTHY
Ready to continue implementation.

Proceeding to load session state...
```

---

### 9. Load Next Step

**Menu Handling Logic:**
- This step uses **Auto-proceed** (no menu)
- After validation completes, automatically route to Coding mode

**Execution:**

```
→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- feature_list.json validated (valid JSON, features present)
- claude-progress.txt checked (created if missing)
- Circuit breaker status: HEALTHY (not triggered)
- Current status displayed
- Ready to route to step-07 (load session state)

### ❌ FAILURE:
- feature_list.json corrupted or empty (exit code 11-13)
- Circuit breaker already triggered (exit code 42)

**Master Rule:** Must validate state before proceeding to Coding mode.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
