---
name: 'step-13-check-completion'
description: 'Check completion status and determine next action (loop/complete/circuit breaker)'
nextStepFile: './step-08-select-next-feature.md'
completeStepFile: './step-14-complete.md'
featureListFile: '{project_folder}/feature_list.json'
progressFile: '{project_folder}/claude-progress.txt'
buildLogFile: '{project_folder}/autonomous_build_log.md'
circuitBreakerGuideFile: '{workflow_path}/../data/circuit-breaker-rules.md'
---

# Step 13: Check Completion

## STEP GOAL:
Determine if more features remain, update circuit breaker state, and decide next action: Loop (more features), Complete (all done), or Circuit Breaker (exit).

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: Session Orchestrator (completion and circuit breaker manager)
- ✅ Collaborative dialogue: None (automated decision logic)
- ✅ You bring: Completion logic, circuit breaker tracking
- ✅ User brings: Current session state

### Step-Specific:
- 🎯 Focus: Determine session outcome and next action
- 🚫 Forbidden: Incorrect circuit breaker calculation, infinite loops
- 💬 Approach: Systematic checks with clear branching logic

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Update circuit breaker state in claude-progress.txt
- 📖 Generate summary report if circuit breaker triggers

---

## CONTEXT BOUNDARIES:
- Available: feature_list.json, claude-progress.txt, session state
- Focus: Session completion determination
- Limits: Does not implement features (branches to appropriate step)
- Dependencies: Requires commit from step-12

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Check Start

```
═══════════════════════════════════════════════════════
  SESSION COMPLETION CHECK
  Analyzing Progress and Circuit Breaker State
═══════════════════════════════════════════════════════
```

---

### 2. Load Current State

**Read feature statuses and circuit breaker state:**

```bash
FEATURE_LIST_FILE="{featureListFile}"
PROGRESS_FILE="{progressFile}"

echo ""
echo "Loading current state..."

# Feature counts
PASS_COUNT=$(jq -r '.features[] | select(.status == "pass") | .id' "$FEATURE_LIST_FILE" | wc -l)
PENDING_COUNT=$(jq -r '.features[] | select(.status == "pending") | .id' "$FEATURE_LIST_FILE" | wc -l)
FAIL_COUNT=$(jq -r '.features[] | select(.status == "fail") | .id' "$FEATURE_LIST_FILE" | wc -l)
BLOCKED_COUNT=$(jq -r '.features[] | select(.status == "blocked") | .id' "$FEATURE_LIST_FILE" | wc -l)
TOTAL_FEATURES=$(jq -r '.metadata.total_features' "$FEATURE_LIST_FILE")

# Retry eligible count
RETRY_ELIGIBLE=$(jq -r '.features[] | select(.status == "fail" and .attempts < 3) | .id' "$FEATURE_LIST_FILE" | wc -l)

# Actionable features
ACTIONABLE_COUNT=$((PENDING_COUNT + RETRY_ELIGIBLE))

# Circuit breaker state
SESSION_COUNT=$(grep '^session_count=' "$PROGRESS_FILE" | cut -d= -f2)
CONSECUTIVE_FAILURES=$(grep '^consecutive_failures=' "$PROGRESS_FILE" | cut -d= -f2)
THRESHOLD=$(grep '^circuit_breaker_threshold=' "$PROGRESS_FILE" | cut -d= -f2)

# Defaults
SESSION_COUNT=${SESSION_COUNT:-1}
CONSECUTIVE_FAILURES=${CONSECUTIVE_FAILURES:-0}
THRESHOLD=${THRESHOLD:-5}

echo "✓ State loaded"
echo ""
```

---

### 3. Determine Session Success

**Calculate if this session made progress:**

```bash
echo "Determining session success..."

# Session start state (from beginning of session)
# We need to check if ANY feature changed to "pass" this session
# For simplicity, if PASS_COUNT increased, session succeeded

# Read session start pass count (if logged)
SESSION_START_PASS=$(grep "Session.*starting" "$BUILD_LOG_FILE" 2>/dev/null | tail -1 | grep -oP '\d+ pass' | grep -oP '\d+' || echo "0")

# If we can't determine, check if this feature passed
if [[ "$OVERALL_STATUS" == "pass" ]]; then
    SESSION_SUCCESS=true
    echo "  Session: SUCCESS (feature implemented and passed)"
elif [[ $PASS_COUNT -gt ${SESSION_START_PASS:-0} ]]; then
    SESSION_SUCCESS=true
    echo "  Session: SUCCESS (progress made)"
else
    SESSION_SUCCESS=false
    echo "  Session: FAILED (no features completed)"
fi

echo ""
```

---

### 4. Update Circuit Breaker State

**Update consecutive_failures and session_count:**

```bash
echo "Updating circuit breaker state..."

# Increment session count
NEW_SESSION_COUNT=$((SESSION_COUNT + 1))

# Update consecutive failures
if [[ "$SESSION_SUCCESS" == "true" ]]; then
    NEW_CONSECUTIVE_FAILURES=0
    echo "  Consecutive failures reset to 0 (session succeeded)"
else
    NEW_CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))
    echo "  Consecutive failures: $CONSECUTIVE_FAILURES → $NEW_CONSECUTIVE_FAILURES"
fi

# Update progress file metadata
sed -i "s/^session_count=.*/session_count=$NEW_SESSION_COUNT/" "$PROGRESS_FILE"
sed -i "s/^consecutive_failures=.*/consecutive_failures=$NEW_CONSECUTIVE_FAILURES/" "$PROGRESS_FILE"
sed -i "s/^last_session_success=.*/last_session_success=$SESSION_SUCCESS/" "$PROGRESS_FILE"
sed -i "s/^last_session_date=.*/last_session_date=$(date -u +%Y-%m-%d)/" "$PROGRESS_FILE"

echo "✓ Circuit breaker state updated"
echo ""
```

---

### 5. Check Circuit Breaker Threshold

**Determine if circuit breaker should trigger:**

```bash
echo "Checking circuit breaker threshold..."

if [[ $NEW_CONSECUTIVE_FAILURES -ge $THRESHOLD ]]; then
    CIRCUIT_BREAKER_TRIGGERED=true
    echo ""
    echo "🔴 CIRCUIT BREAKER TRIGGERED"
    echo ""
    echo "  Consecutive failed sessions: $NEW_CONSECUTIVE_FAILURES"
    echo "  Threshold: $THRESHOLD"
    echo ""

    # Update status in progress file
    sed -i "s/^circuit_breaker_status=.*/circuit_breaker_status=TRIGGERED/" "$PROGRESS_FILE"
else
    CIRCUIT_BREAKER_TRIGGERED=false
    echo "  Status: HEALTHY ($NEW_CONSECUTIVE_FAILURES/$THRESHOLD failures)"

    if [[ $NEW_CONSECUTIVE_FAILURES -gt 0 ]]; then
        echo ""
        echo "  ⚠️  Warning: $NEW_CONSECUTIVE_FAILURES consecutive failure(s)"
        REMAINING=$((THRESHOLD - NEW_CONSECUTIVE_FAILURES))
        echo "  $REMAINING more failure(s) until circuit breaker triggers"
    fi
fi

echo ""
```

---

### 6. Display Current Progress

```
─────────────────────────────────────────────────────
  CURRENT PROGRESS
─────────────────────────────────────────────────────

Session: $NEW_SESSION_COUNT
Status: $(if [[ "$SESSION_SUCCESS" == "true" ]]; then echo "SUCCESS"; else echo "FAILED"; fi)

Features ($TOTAL_FEATURES total):
  ✓ Pass:    $PASS_COUNT ($(( PASS_COUNT * 100 / TOTAL_FEATURES ))%)
  ⏳ Pending: $PENDING_COUNT
  ❌ Fail:    $FAIL_COUNT (retry eligible: $RETRY_ELIGIBLE)
  🚫 Blocked: $BLOCKED_COUNT

Actionable Features: $ACTIONABLE_COUNT

Circuit Breaker:
  Consecutive failures: $NEW_CONSECUTIVE_FAILURES/$THRESHOLD
  Status: $(if [[ "$CIRCUIT_BREAKER_TRIGGERED" == "true" ]]; then echo "🔴 TRIGGERED"; else echo "✓ HEALTHY"; fi)
```

---

### 7. Decision Logic - Determine Next Action

**Branch based on state:**

```bash
echo ""
echo "─────────────────────────────────────────────────────"
echo "  DETERMINING NEXT ACTION"
echo "─────────────────────────────────────────────────────"
echo ""

# Decision tree:
# 1. Circuit breaker triggered → EXIT 42
# 2. No actionable features and all complete → COMPLETE
# 3. No actionable features but blocked exist → EXIT 0
# 4. Actionable features exist → LOOP

if [[ "$CIRCUIT_BREAKER_TRIGGERED" == "true" ]]; then
    NEXT_ACTION="CIRCUIT_BREAKER"
    echo "Action: EXIT (Circuit Breaker)"
    echo "Reason: $NEW_CONSECUTIVE_FAILURES consecutive failed sessions"

elif [[ $ACTIONABLE_COUNT -eq 0 ]]; then
    if [[ $PASS_COUNT -eq $TOTAL_FEATURES ]]; then
        NEXT_ACTION="COMPLETE"
        echo "Action: COMPLETE"
        echo "Reason: All $TOTAL_FEATURES features passed"
    else
        NEXT_ACTION="NO_WORK"
        echo "Action: EXIT (No Actionable Work)"
        echo "Reason: No pending/retry features, $BLOCKED_COUNT blocked"
    fi

else
    NEXT_ACTION="LOOP"
    echo "Action: LOOP (Continue Implementation)"
    echo "Reason: $ACTIONABLE_COUNT actionable features remaining"
fi

echo ""
```

---

### 8. Execute Action - Circuit Breaker

**If circuit breaker triggered:**

```bash
if [[ "$NEXT_ACTION" == "CIRCUIT_BREAKER" ]]; then
    echo "═══════════════════════════════════════════════════════"
    echo "  CIRCUIT BREAKER TRIGGERED"
    echo "  Human Intervention Required"
    echo "═══════════════════════════════════════════════════════"
    echo ""

    # Generate summary report
    SUMMARY_REPORT="{project_folder}/autonomous_summary_report.md"

    cat > "$SUMMARY_REPORT" <<EOF
# Circuit Breaker Report - Human Intervention Required

**Triggered:** $(date -u +%Y-%m-%d %H:%M:%S)
**Consecutive Failures:** $NEW_CONSECUTIVE_FAILURES
**Threshold:** $THRESHOLD

---

## Summary

The autonomous implementation workflow has been stopped due to repeated failures.
$NEW_CONSECUTIVE_FAILURES consecutive sessions made no meaningful progress.

---

## Current State

**Features ($TOTAL_FEATURES total):**
- ✓ Pass: $PASS_COUNT ($(( PASS_COUNT * 100 / TOTAL_FEATURES ))%)
- ⏳ Pending: $PENDING_COUNT
- ❌ Fail: $FAIL_COUNT
- 🚫 Blocked: $BLOCKED_COUNT

**Actionable:** $ACTIONABLE_COUNT features

---

## Last 5 Sessions

$(tail -100 "$PROGRESS_FILE" | grep "^## Session" | tail -5)

---

## Blocked Features

$(jq -r '.features[] | select(.status == "blocked") | "- **\(.id)**: \(.name)\n  - Reason: \(.blocked_reason)\n  - Attempts: \(.attempts)\n"' "$FEATURE_LIST_FILE")

---

## Failed Features (Retry Eligible)

$(jq -r '.features[] | select(.status == "fail") | "- **\(.id)**: \(.name)\n  - Attempts: \(.attempts)/3\n  - Last error: \(.implementation_notes)\n"' "$FEATURE_LIST_FILE")

---

## Recommended Actions

1. **Review blocked/failed features** - Identify common issues
2. **Fix external dependencies** - API auth, missing tools, permissions
3. **Use EDIT mode to reset circuit breaker:**
   \`\`\`bash
   /bmad-bmm-run-autonomous-implementation --mode=edit
   # Select [C] Circuit Breaker
   # Set consecutive_failures = 0
   \`\`\`
4. **Fix specific issues** then restart workflow
5. **Consider manual implementation** for persistently blocked features

---

## Next Steps

**DO NOT** restart the workflow without addressing the issues above.
The circuit breaker will trigger again immediately if problems persist.

EOF

    echo "📊 Summary report generated: $SUMMARY_REPORT"
    echo ""
    echo "Review the report for details and recommended actions."
    echo ""
    echo "Exiting with code 42 (circuit breaker)"
    exit 42
fi
```

---

### 9. Execute Action - Complete

**If all features complete:**

```bash
if [[ "$NEXT_ACTION" == "COMPLETE" ]]; then
    echo "🎉 All features complete!"
    echo ""
    echo "Proceeding to completion step..."
    echo ""

    # Route to completion step
    load_and_execute "{completeStepFile}"
    exit 0
fi
```

---

### 10. Execute Action - No Work

**If no actionable features but not complete:**

```bash
if [[ "$NEXT_ACTION" == "NO_WORK" ]]; then
    echo "⚠️  No actionable work remaining"
    echo ""
    echo "Status:"
    echo "  - $PASS_COUNT features completed"
    echo "  - $BLOCKED_COUNT features blocked"
    echo "  - $PENDING_COUNT features pending (dependencies not satisfied)"
    echo ""
    echo "Review feature_list.json to diagnose issues."
    echo "Use EDIT mode to unblock features or adjust dependencies."
    echo ""
    echo "Exiting (no work available)"
    exit 0
fi
```

---

### 11. Execute Action - Loop

**If actionable features remain:**

```bash
if [[ "$NEXT_ACTION" == "LOOP" ]]; then
    echo "↻ Looping back to feature selection..."
    echo ""
    echo "  Remaining: $ACTIONABLE_COUNT actionable features"
    echo "  Circuit breaker: HEALTHY ($NEW_CONSECUTIVE_FAILURES/$THRESHOLD)"
    echo ""
    echo "Proceeding to select next feature..."
    echo ""

    # Route back to feature selection
    load_and_execute "{nextStepFile}"
    exit 0
fi
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- Current state loaded (features, circuit breaker)
- Session success determined (progress made or not)
- Circuit breaker state updated (consecutive_failures, session_count)
- Circuit breaker threshold checked
- Next action determined (LOOP/COMPLETE/CIRCUIT_BREAKER/NO_WORK)
- Appropriate action executed:
  - CIRCUIT_BREAKER: Summary report generated, exit 42
  - COMPLETE: Route to step-14
  - NO_WORK: Exit 0 with message
  - LOOP: Route to step-08

### ❌ FAILURE:
- (None - decision logic always completes with appropriate action)

**Master Rule:** Must correctly determine session outcome and route to appropriate next step.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete (CRITICAL BRANCHING LOGIC)
