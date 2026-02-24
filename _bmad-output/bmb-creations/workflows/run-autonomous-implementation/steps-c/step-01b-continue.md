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
**Universal:** See global CLAUDE.md (read complete step, no generation without input, facilitator role)

**Role:** Autonomous Implementation Orchestrator (Continuation Handler)
- No user dialogue (fully automated)
- State validation + circuit breaker checks

**Step-Specific:**
- 🎯 Focus: Validate existing state and route to Coding mode
- 🚫 Forbidden: Skipping circuit breaker check, ignoring corrupted state
- 💾 Read-only validation (no state modifications)

---

## CONTEXT BOUNDARIES:
- Available: feature_list.json, claude-progress.txt (if exists)
- Focus: State validation, circuit breaker status
- Limits: Does not implement features or modify state
- Dependencies: Valid feature_list.json required

---

## MANDATORY SEQUENCE

### 1. Display Continuation Banner

```
═══════════════════════════════════════════════════════
  CONTINUING AUTONOMOUS IMPLEMENTATION
  Coding Agent Mode (Session 2+)
═══════════════════════════════════════════════════════
```

---

### 2. Validate feature_list.json

```bash
PROJECT_FOLDER="{project_folder}"
FEATURE_LIST="${PROJECT_FOLDER}/feature_list.json"

# Verify file exists
[[ ! -f "$FEATURE_LIST" ]] && echo "❌ ERROR: feature_list.json not found (routing error)" && exit 11

# Verify valid JSON
if ! jq empty "$FEATURE_LIST" 2>/dev/null; then
    echo "❌ ERROR: feature_list.json contains invalid JSON"
    echo "   Recovery: git checkout HEAD feature_list.json OR delete and restart"
    exit 12
fi

# Verify features array
FEATURE_COUNT=$(jq '.features | length' "$FEATURE_LIST" 2>/dev/null)
[[ -z "$FEATURE_COUNT" || "$FEATURE_COUNT" -eq 0 ]] && echo "❌ ERROR: No features found" && exit 13

echo "✓ feature_list.json is valid ($FEATURE_COUNT features)"
```

---

### 3. Check Progress File and Parse Circuit Breaker

```bash
PROGRESS_FILE="${PROJECT_FOLDER}/claude-progress.txt"

if [[ ! -f "$PROGRESS_FILE" ]]; then
    echo "⚠️  claude-progress.txt not found (will recreate in step-07)"
    CONSECUTIVE_FAILURES=0
    SESSION_COUNT=1
    CIRCUIT_BREAKER_STATUS="UNKNOWN"
else
    echo "✓ claude-progress.txt found"

    # Parse metadata (use defaults if missing)
    CONSECUTIVE_FAILURES=$(grep '^consecutive_failures=' "$PROGRESS_FILE" | cut -d= -f2)
    THRESHOLD=$(grep '^circuit_breaker_threshold=' "$PROGRESS_FILE" | cut -d= -f2)
    CIRCUIT_BREAKER_STATUS=$(grep '^circuit_breaker_status=' "$PROGRESS_FILE" | cut -d= -f2)
    SESSION_COUNT=$(grep '^session_count=' "$PROGRESS_FILE" | cut -d= -f2)
    LAST_SESSION_SUCCESS=$(grep '^last_session_success=' "$PROGRESS_FILE" | cut -d= -f2)

    CONSECUTIVE_FAILURES=${CONSECUTIVE_FAILURES:-0}
    THRESHOLD=${THRESHOLD:-5}
    CIRCUIT_BREAKER_STATUS=${CIRCUIT_BREAKER_STATUS:-HEALTHY}
    SESSION_COUNT=${SESSION_COUNT:-1}
    LAST_SESSION_SUCCESS=${LAST_SESSION_SUCCESS:-true}

    echo ""
    echo "Circuit Breaker: $CIRCUIT_BREAKER_STATUS ($CONSECUTIVE_FAILURES/$THRESHOLD failures)"
    echo "Sessions: $SESSION_COUNT | Last success: $LAST_SESSION_SUCCESS"
fi
```

---

### 4. Check Circuit Breaker Status

```bash
if [[ "$CIRCUIT_BREAKER_STATUS" == "TRIGGERED" ]] || [[ $CONSECUTIVE_FAILURES -ge $THRESHOLD ]]; then
    cat << 'EOF'

🔴 CIRCUIT BREAKER TRIGGERED

═══════════════════════════════════════════════════════
  WORKFLOW STOPPED - REPEATED FAILURES DETECTED
═══════════════════════════════════════════════════════

Status: $CONSECUTIVE_FAILURES consecutive failed sessions (threshold: $THRESHOLD)

Review: ${PROJECT_FOLDER}/autonomous_summary_report.md

To Resume:
  1. Fix external blockers (API auth, dependencies, etc)
  2. Reset circuit breaker:
     /bmad-bmm-run-autonomous-implementation --mode=edit
     Select [C] Circuit Breaker → Set consecutive_failures=0
  3. Restart: /bmad-bmm-run-autonomous-implementation

EOF
    exit 42
fi

# Warning if approaching threshold
if [[ $CONSECUTIVE_FAILURES -gt 0 ]]; then
    echo "⚠️  Warning: $CONSECUTIVE_FAILURES/$THRESHOLD failures"
    [[ $((CONSECUTIVE_FAILURES + 1)) -ge $THRESHOLD ]] && echo "   ⚠️  NEXT FAILURE TRIGGERS CIRCUIT BREAKER!"
else
    echo "✓ Circuit Breaker: HEALTHY"
fi
```

---

### 5. Display Implementation Status

```bash
echo ""
echo "─────────────────────────────────────────────────────"
echo "  CURRENT IMPLEMENTATION STATUS"
echo "─────────────────────────────────────────────────────"

# Count by status
PASS_COUNT=$(jq -r '[.features[] | select(.status == "pass")] | length' "$FEATURE_LIST")
PENDING_COUNT=$(jq -r '[.features[] | select(.status == "pending")] | length' "$FEATURE_LIST")
FAIL_COUNT=$(jq -r '[.features[] | select(.status == "fail")] | length' "$FEATURE_LIST")
BLOCKED_COUNT=$(jq -r '[.features[] | select(.status == "blocked")] | length' "$FEATURE_LIST")
IN_PROGRESS_COUNT=$(jq -r '[.features[] | select(.status == "in_progress")] | length' "$FEATURE_LIST")

echo ""
echo "  ✓ Pass: $PASS_COUNT | ⏳ Pending: $PENDING_COUNT | ❌ Fail: $FAIL_COUNT"
echo "  🚫 Blocked: $BLOCKED_COUNT | 🔄 In Progress: $IN_PROGRESS_COUNT"
echo ""
echo "Total: $FEATURE_COUNT | Progress: $PASS_COUNT/$FEATURE_COUNT ($((PASS_COUNT * 100 / FEATURE_COUNT))%)"

# Show last session info
if [[ -f "$PROGRESS_FILE" ]]; then
    LAST_SESSION_DATE=$(grep '^last_session_date=' "$PROGRESS_FILE" | cut -d= -f2)
    [[ -n "$LAST_SESSION_DATE" ]] && echo "Last Session: $LAST_SESSION_DATE (Session #$SESSION_COUNT)"
fi
```

---

### 6. Route to Coding Mode

```
─────────────────────────────────────────────────────
  VALIDATION COMPLETE
─────────────────────────────────────────────────────

Session Type: Coding Agent (Session $((SESSION_COUNT + 1)))
Circuit Breaker: HEALTHY
Ready to continue implementation.

Proceeding to load session state...
```

---

### 7. Load Next Step

**Auto-proceed (no menu):** → Load, read entire file, then execute {nextStepFile}

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- feature_list.json validated (valid JSON, features present)
- claude-progress.txt checked (created if missing)
- Circuit breaker status: HEALTHY (not triggered)
- Ready to route to step-07 (load session state)

### ❌ FAILURE:
- Exit 11-13: feature_list.json corrupted/empty
- Exit 42: Circuit breaker already triggered

**Master Rule:** Must validate state before proceeding to Coding mode.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
