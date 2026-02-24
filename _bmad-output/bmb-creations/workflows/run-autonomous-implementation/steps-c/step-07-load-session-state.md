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

@_bmad/core/universal-rules.md

### Role & Protocols:
- ✅ Role: State Loader (Coding Agent mode entry) - Automated state loading
- 🎯 Focus: Load state, calculate statistics, display context
- 🚫 Forbidden: Modifying state files (read-only step)

---

## MANDATORY SEQUENCE

### 1. Display Session Banner

```bash
CURRENT_SESSION=$(grep '^session_count=' "{progressFile}" | cut -d= -f2)
echo "═══════════════════════════════════════════════════════"
echo "  SESSION $((CURRENT_SESSION + 1)): CODING AGENT"
echo "  Autonomous Feature Implementation"
echo "═══════════════════════════════════════════════════════"
```

---

### 2. Load and Validate State Files

```bash
FEATURE_LIST_FILE="{featureListFile}"
PROGRESS_FILE="{progressFile}"

echo ""
echo "Loading feature_list.json..."

# Validate feature list
[[ ! -f "$FEATURE_LIST_FILE" ]] && echo "❌ ERROR: feature_list.json not found" && exit 31
jq empty "$FEATURE_LIST_FILE" 2>/dev/null || (echo "❌ ERROR: Invalid JSON" && exit 32)

# Load into memory
FEATURE_LIST=$(cat "$FEATURE_LIST_FILE")
TOTAL_FEATURES=$(echo "$FEATURE_LIST" | jq -r '.metadata.total_features')
PROJECT_NAME=$(echo "$FEATURE_LIST" | jq -r '.metadata.project_name')

echo "✓ Loaded: $TOTAL_FEATURES features (Project: $PROJECT_NAME)"
```

---

### 3. Calculate Statistics

```bash
echo ""
echo "Analyzing feature statuses..."

# Status counts using consolidated jq queries
PASS_COUNT=$(echo "$FEATURE_LIST" | jq '[.features[] | select(.status == "pass")] | length')
PENDING_COUNT=$(echo "$FEATURE_LIST" | jq '[.features[] | select(.status == "pending")] | length')
FAIL_COUNT=$(echo "$FEATURE_LIST" | jq '[.features[] | select(.status == "fail")] | length')
BLOCKED_COUNT=$(echo "$FEATURE_LIST" | jq '[.features[] | select(.status == "blocked")] | length')
IN_PROGRESS_COUNT=$(echo "$FEATURE_LIST" | jq '[.features[] | select(.status == "in_progress")] | length')
RETRY_ELIGIBLE=$(echo "$FEATURE_LIST" | jq '[.features[] | select(.status == "fail" and .attempts < 3)] | length')

ACTIONABLE_COUNT=$((PENDING_COUNT + RETRY_ELIGIBLE))
PERCENTAGE=$((PASS_COUNT * 100 / TOTAL_FEATURES))

echo "✓ Statistics calculated"
```

---

### 4. Load Circuit Breaker State

```bash
echo ""
echo "Loading circuit breaker state..."

if [[ ! -f "$PROGRESS_FILE" ]]; then
    SESSION_COUNT=1; CONSECUTIVE_FAILURES=0; CIRCUIT_BREAKER_STATUS="HEALTHY"; THRESHOLD=5; LAST_SESSION_SUCCESS=true
else
    SESSION_COUNT=$(grep '^session_count=' "$PROGRESS_FILE" | cut -d= -f2)
    CONSECUTIVE_FAILURES=$(grep '^consecutive_failures=' "$PROGRESS_FILE" | cut -d= -f2)
    CIRCUIT_BREAKER_STATUS=$(grep '^circuit_breaker_status=' "$PROGRESS_FILE" | cut -d= -f2)
    THRESHOLD=$(grep '^circuit_breaker_threshold=' "$PROGRESS_FILE" | cut -d= -f2)
    LAST_SESSION_SUCCESS=$(grep '^last_session_success=' "$PROGRESS_FILE" | cut -d= -f2)

    # Apply defaults
    SESSION_COUNT=${SESSION_COUNT:-1}; CONSECUTIVE_FAILURES=${CONSECUTIVE_FAILURES:-0}
    CIRCUIT_BREAKER_STATUS=${CIRCUIT_BREAKER_STATUS:-HEALTHY}; THRESHOLD=${THRESHOLD:-5}
    LAST_SESSION_SUCCESS=${LAST_SESSION_SUCCESS:-true}
fi

echo "✓ Circuit breaker state loaded"
```

---

### 5. Display Status Dashboard

```
─────────────────────────────────────────────────────
  CURRENT IMPLEMENTATION STATUS
─────────────────────────────────────────────────────

Project: $PROJECT_NAME
Session: $((SESSION_COUNT + 1))
Progress: $PASS_COUNT/$TOTAL_FEATURES ($PERCENTAGE%)

Features by Status:
  ✓ Pass: $PASS_COUNT  |  ⏳ Pending: $PENDING_COUNT  |  ❌ Fail: $FAIL_COUNT (retry: $RETRY_ELIGIBLE)
  🚫 Blocked: $BLOCKED_COUNT  |  🔄 In Progress: $IN_PROGRESS_COUNT

Actionable Features: $ACTIONABLE_COUNT

Circuit Breaker: $CIRCUIT_BREAKER_STATUS ($CONSECUTIVE_FAILURES/$THRESHOLD failures)
Last Session: $(if [[ "$LAST_SESSION_SUCCESS" == "true" ]]; then echo "SUCCESS"; else echo "FAILED"; fi)
$(if [[ $((CONSECUTIVE_FAILURES + 1)) -ge $THRESHOLD ]]; then echo "⚠️  NEXT FAILURE WILL TRIGGER CIRCUIT BREAKER!"; fi)
```

---

### 6. Check Work Remaining

```bash
echo ""

if [[ $ACTIONABLE_COUNT -eq 0 ]]; then
    if [[ $BLOCKED_COUNT -gt 0 ]]; then
        echo "⚠️  No actionable features remaining (Blocked: $BLOCKED_COUNT)"
        echo "$(echo "$FEATURE_LIST" | jq -r '.features[] | select(.status == "blocked") | "  - \(.id): \(.name)"')"
        echo ""
        echo "Options: (1) Use EDIT mode to unblock (2) Manually fix (3) Accept current state"
        exit 0
    elif [[ $PASS_COUNT -eq $TOTAL_FEATURES ]]; then
        echo "🎉 All features complete! Proceeding to completion step..."
        load_and_execute "./step-14-complete.md"
        exit 0
    fi
fi

echo "✓ Actionable features available: $ACTIONABLE_COUNT"
```

---

### 7. Display Recent Activity

```bash
echo ""
echo "Recent Activity:"
RECENT=$(echo "$FEATURE_LIST" | jq -r '.features[] | select(.status == "pass" and .last_updated != null) | "\(.updated): \(.id) - \(.name)"' | sort -r | head -5)
if [[ -n "$RECENT" ]]; then
    echo "$RECENT" | while read line; do echo "  ✓ $line"; done
else
    echo "  (No features completed yet)"
fi
echo ""
```

---

### 8. Complete State Load & Proceed

```
─────────────────────────────────────────────────────
STATE LOADED SUCCESSFULLY - Proceeding to feature selection...
─────────────────────────────────────────────────────
```

**Auto-proceed (no menu):**

```
→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
State files loaded/validated → Statistics calculated → Circuit breaker confirmed → Actionable features identified → Ready for step-08

### ❌ FAILURE:
- feature_list.json not found (exit 31) | Invalid JSON (exit 32)
- No actionable features (exit 0 with options) | All complete (route to step-14)

**Master Rule:** Must load and validate state before selecting features.

---

**Step Version:** 1.0.0 | **Created:** 2026-02-17 | **Status:** Complete
