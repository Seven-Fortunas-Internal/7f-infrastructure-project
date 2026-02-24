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
@~/.claude/rules/universal-step-rules.md

### Role:
- ✅ Session Orchestrator (completion and circuit breaker manager)
- ✅ Automated decision logic (no user input)

### Step-Specific:
- 🎯 Focus: Determine session outcome and next action
- 🚫 Forbidden: Incorrect circuit breaker calculation, infinite loops

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

### 2. Load State, Determine Success, Update Circuit Breaker

```bash
FEATURE_LIST="{featureListFile}"
PROGRESS="{progressFile}"
BUILD_LOG="{buildLogFile}"

echo ""
echo "Loading state and updating circuit breaker..."

# Feature counts
PASS=$(jq -r '[.features[] | select(.status == "pass")] | length' "$FEATURE_LIST")
PENDING=$(jq -r '[.features[] | select(.status == "pending")] | length' "$FEATURE_LIST")
FAIL=$(jq -r '[.features[] | select(.status == "fail")] | length' "$FEATURE_LIST")
BLOCKED=$(jq -r '[.features[] | select(.status == "blocked")] | length' "$FEATURE_LIST")
TOTAL=$(jq -r '.metadata.total_features' "$FEATURE_LIST")
RETRY=$(jq -r '[.features[] | select(.status == "fail" and .attempts < 3)] | length' "$FEATURE_LIST")
ACTIONABLE=$((PENDING + RETRY))

# Circuit breaker state
SESSION_COUNT=$(grep '^session_count=' "$PROGRESS" | cut -d= -f2)
CONSEC_FAIL=$(grep '^consecutive_failures=' "$PROGRESS" | cut -d= -f2)
THRESHOLD=$(grep '^circuit_breaker_threshold=' "$PROGRESS" | cut -d= -f2)
SESSION_COUNT=${SESSION_COUNT:-1}
CONSEC_FAIL=${CONSEC_FAIL:-0}
THRESHOLD=${THRESHOLD:-5}

# Session success: check if feature passed or progress made
SESSION_START_PASS=$(grep "Session.*starting" "$BUILD_LOG" 2>/dev/null | tail -1 | grep -oP '\d+ pass' | grep -oP '\d+' || echo "0")
if [[ "$OVERALL_STATUS" == "pass" ]] || [[ $PASS -gt ${SESSION_START_PASS:-0} ]]; then
    SESSION_SUCCESS=true
    NEW_CONSEC_FAIL=0
    echo "  Session: SUCCESS (reset failures to 0)"
else
    SESSION_SUCCESS=false
    NEW_CONSEC_FAIL=$((CONSEC_FAIL + 1))
    echo "  Session: FAILED (failures: $CONSEC_FAIL → $NEW_CONSEC_FAIL)"
fi

NEW_SESSION_COUNT=$((SESSION_COUNT + 1))

# Update progress file
sed -i "s/^session_count=.*/session_count=$NEW_SESSION_COUNT/" "$PROGRESS"
sed -i "s/^consecutive_failures=.*/consecutive_failures=$NEW_CONSEC_FAIL/" "$PROGRESS"
sed -i "s/^last_session_success=.*/last_session_success=$SESSION_SUCCESS/" "$PROGRESS"
sed -i "s/^last_session_date=.*/last_session_date=$(date -u +%Y-%m-%d)/" "$PROGRESS"

# Check circuit breaker threshold
if [[ $NEW_CONSEC_FAIL -ge $THRESHOLD ]]; then
    CB_TRIGGERED=true
    echo ""
    echo "🔴 CIRCUIT BREAKER TRIGGERED"
    echo "  Consecutive failures: $NEW_CONSEC_FAIL / Threshold: $THRESHOLD"
    sed -i "s/^circuit_breaker_status=.*/circuit_breaker_status=TRIGGERED/" "$PROGRESS"
else
    CB_TRIGGERED=false
    echo "  Circuit breaker: HEALTHY ($NEW_CONSEC_FAIL/$THRESHOLD)"
    [[ $NEW_CONSEC_FAIL -gt 0 ]] && echo "  ⚠️  $(( THRESHOLD - NEW_CONSEC_FAIL )) failures until trigger"
fi

echo "✓ State loaded and circuit breaker updated"
echo ""
```

---

### 3. Display Progress & Determine Next Action

```bash
echo ""
echo "─────────────────────────────────────────────────────"
echo "  PROGRESS: Session $NEW_SESSION_COUNT | Pass: $PASS/$TOTAL ($(( PASS * 100 / TOTAL ))%)"
echo "  Pending: $PENDING | Fail: $FAIL (retry: $RETRY) | Blocked: $BLOCKED | Actionable: $ACTIONABLE"
echo "  Circuit Breaker: $NEW_CONSEC_FAIL/$THRESHOLD $(if [[ "$CB_TRIGGERED" == "true" ]]; then echo "🔴 TRIGGERED"; else echo "✓ HEALTHY"; fi)"
echo "─────────────────────────────────────────────────────"

# Decision tree: CB → EXIT 42 | All complete → COMPLETE | No work → EXIT 0 | Actionable → LOOP
if [[ "$CB_TRIGGERED" == "true" ]]; then
    NEXT_ACTION="CIRCUIT_BREAKER"
    echo "Action: EXIT (Circuit Breaker - $NEW_CONSEC_FAIL consecutive failures)"
elif [[ $ACTIONABLE -eq 0 ]]; then
    if [[ $PASS -eq $TOTAL ]]; then
        NEXT_ACTION="COMPLETE"
        echo "Action: COMPLETE (All $TOTAL features passed)"
    else
        NEXT_ACTION="NO_WORK"
        echo "Action: EXIT (No actionable work, $BLOCKED blocked)"
    fi
else
    NEXT_ACTION="LOOP"
    echo "Action: LOOP ($ACTIONABLE actionable features remaining)"
fi
echo ""
```

---

### 4. Execute Action

```bash
if [[ "$NEXT_ACTION" == "CIRCUIT_BREAKER" ]]; then
    echo "═══════════════════════════════════════════════════════"
    echo "  CIRCUIT BREAKER TRIGGERED - Human Intervention Required"
    echo "═══════════════════════════════════════════════════════"

    REPORT="{project_folder}/autonomous_summary_report.md"
    cat > "$REPORT" <<EOF
# Circuit Breaker Report - Human Intervention Required

**Triggered:** $(date -u +%Y-%m-%d %H:%M:%S) | **Failures:** $NEW_CONSEC_FAIL / **Threshold:** $THRESHOLD

## Summary
$NEW_CONSEC_FAIL consecutive sessions made no progress. Autonomous workflow stopped.

## Current State
**Features ($TOTAL):** Pass: $PASS ($(( PASS * 100 / TOTAL ))%) | Pending: $PENDING | Fail: $FAIL | Blocked: $BLOCKED | Actionable: $ACTIONABLE

## Last 5 Sessions
$(tail -100 "$PROGRESS" | grep "^## Session" | tail -5)

## Blocked Features
$(jq -r '.features[] | select(.status == "blocked") | "- **\(.id)**: \(.name) | Reason: \(.blocked_reason) | Attempts: \(.attempts)"' "$FEATURE_LIST")

## Failed Features (Retry Eligible)
$(jq -r '.features[] | select(.status == "fail") | "- **\(.id)**: \(.name) | Attempts: \(.attempts)/3 | Error: \(.implementation_notes)"' "$FEATURE_LIST")

## Recommended Actions
1. Review blocked/failed features for common issues
2. Fix external dependencies (API auth, tools, permissions)
3. Reset circuit breaker: \`/bmad-bmm-run-autonomous-implementation --mode=edit\` → [C] Circuit Breaker → Set \`consecutive_failures = 0\`
4. Fix specific issues then restart workflow
5. Consider manual implementation for persistent blocks

**DO NOT restart without addressing issues.** Circuit breaker will trigger immediately if problems persist.
EOF

    echo "📊 Report: $REPORT | Exiting with code 42 (circuit breaker)"
    exit 42

elif [[ "$NEXT_ACTION" == "COMPLETE" ]]; then
    echo "🎉 All features complete! Proceeding to completion step..."
    load_and_execute "{completeStepFile}"
    exit 0

elif [[ "$NEXT_ACTION" == "NO_WORK" ]]; then
    echo "⚠️  No actionable work remaining"
    echo "Status: $PASS completed | $BLOCKED blocked | $PENDING pending"
    echo "Review feature_list.json or use EDIT mode. Exiting."
    exit 0

else # LOOP
    echo "↻ Looping back to feature selection ($ACTIONABLE actionable, CB: $NEW_CONSEC_FAIL/$THRESHOLD)"
    load_and_execute "{nextStepFile}"
    exit 0
fi
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- Current state loaded (features, circuit breaker)
- Session success determined and circuit breaker updated
- Next action determined and executed (LOOP/COMPLETE/CB/NO_WORK)

### ❌ FAILURE:
- (None - decision logic always completes with appropriate action)

**Master Rule:** Must correctly determine session outcome and route to appropriate next step.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete (CRITICAL BRANCHING LOGIC)
