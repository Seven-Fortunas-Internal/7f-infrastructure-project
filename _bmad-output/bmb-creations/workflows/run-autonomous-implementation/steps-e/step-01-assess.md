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
See universal rules in workflow.md. Role: State Inspector (read-only). No file modifications.

---

## CONTEXT BOUNDARIES:
- Available: feature_list.json, claude-progress.txt
- Focus: State assessment and option presentation
- Limits: Routes to edit steps; no direct modifications
- Dependencies: Requires existing feature_list.json

---

## MANDATORY SEQUENCE

### 1. Display EDIT Mode Banner

```
═══════════════════════════════════════════════════════
  EDIT MODE - Implementation State Assessment
  Review and Modify Tracking State
═══════════════════════════════════════════════════════
```

---

### 2. Validate Tracking Files

```bash
FEATURE_LIST_FILE="{featureListFile}"
PROGRESS_FILE="{progressFile}"

echo "" && echo "Validating tracking files..."

[[ ! -f "$FEATURE_LIST_FILE" ]] && { echo "❌ ERROR: feature_list.json not found at $FEATURE_LIST_FILE"; echo "Run CREATE mode first."; exit 1; }
[[ ! -f "$PROGRESS_FILE" ]] && { echo "❌ ERROR: claude-progress.txt not found at $PROGRESS_FILE"; exit 2; }
jq empty "$FEATURE_LIST_FILE" 2>/dev/null || { echo "❌ ERROR: Invalid JSON in feature_list.json"; exit 3; }

echo "✓ Tracking files validated" && echo ""
```

---

### 3. Load Implementation State

```bash
echo "Loading implementation state..."

# Single-pass statistics extraction (combined query)
read TOTAL_FEATURES PROJECT_NAME GENERATED_DATE PASS_COUNT PENDING_COUNT FAIL_COUNT BLOCKED_COUNT IN_PROGRESS_COUNT <<< \
$(jq -r '[.metadata.total_features, .metadata.project_name, .metadata.generated_date,
          ([.features[] | select(.status == "pass")] | length),
          ([.features[] | select(.status == "pending")] | length),
          ([.features[] | select(.status == "fail")] | length),
          ([.features[] | select(.status == "blocked")] | length),
          ([.features[] | select(.status == "in_progress")] | length)] | @tsv' "$FEATURE_LIST_FILE")

# Load circuit breaker (compact with defaults)
while IFS='=' read -r key val; do
  case $key in
    session_count) SESSION_COUNT=${val:-0};;
    consecutive_failures) CONSECUTIVE_FAILURES=${val:-0};;
    circuit_breaker_threshold) THRESHOLD=${val:-5};;
    circuit_breaker_status) CB_STATUS=${val:-HEALTHY};;
    last_session_success) LAST_SESSION_SUCCESS=$val;;
    last_session_date) LAST_SESSION_DATE=$val;;
  esac
done < "$PROGRESS_FILE"

echo "✓ State loaded" && echo ""
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
Sessions: $SESSION_COUNT | Last: ${LAST_SESSION_DATE:-N/A} (${LAST_SESSION_SUCCESS:-N/A})
```

---

### 5. Display Feature Status Summary

```
─────────────────────────────────────────────────────
  FEATURE STATUS
─────────────────────────────────────────────────────

Status ($TOTAL_FEATURES total):
  ✓ Pass: $PASS_COUNT ($(( PASS_COUNT * 100 / TOTAL_FEATURES ))%) | ⏳ Pending: $PENDING_COUNT ($(( PENDING_COUNT * 100 / TOTAL_FEATURES ))%)
  🔄 In Progress: $IN_PROGRESS_COUNT | ❌ Fail: $FAIL_COUNT | 🚫 Blocked: $BLOCKED_COUNT

Progress: $(( (PASS_COUNT + BLOCKED_COUNT) * 100 / TOTAL_FEATURES ))% complete or blocked
```

---

### 6. Display Feature Details

```bash
display_features() {
    local status=$1 emoji=$2 label=$3 count=$4
    [[ $count -eq 0 ]] && return
    echo "$emoji $label ($count):" && echo ""
    jq -r ".features[] | select(.status == \"$status\") |
        \"  \(.id) - \(.name)\" +
        (if .attempts then \" (attempts: \(.attempts)\" + (if \"$status\" == \"fail\" then \"/3)\" else \")\") end else \"\" end) +
        (if .blocked_reason then \"\n    Reason: \(.blocked_reason)\" else \"\" end) +
        (if .implementation_notes and \"$status\" == \"fail\" then \"\n    Note: \(.implementation_notes)\" else \"\" end)" \
        "$FEATURE_LIST_FILE"
    echo ""
}

echo "" && echo "─────────────────────────────────────────────────────"
echo "  FEATURE DETAILS" && echo "─────────────────────────────────────────────────────" && echo ""

for status_type in "pass:✓:PASSED:$PASS_COUNT" "pending:⏳:PENDING:$PENDING_COUNT" "in_progress:🔄:IN PROGRESS:$IN_PROGRESS_COUNT" "fail:❌:FAILED:$FAIL_COUNT" "blocked:🚫:BLOCKED:$BLOCKED_COUNT"; do
    IFS=':' read -r status emoji label count <<< "$status_type"
    display_features "$status" "$emoji" "$label" "$count"
done
```

---

### 7. Display Circuit Breaker State

```
─────────────────────────────────────────────────────
  CIRCUIT BREAKER STATE
─────────────────────────────────────────────────────

Status: $(if [[ "$CB_STATUS" == "TRIGGERED" ]]; then echo "🔴 TRIGGERED"; else echo "✓ $CB_STATUS"; fi)
Consecutive Failures: $CONSECUTIVE_FAILURES / $THRESHOLD

$(if [[ "$CB_STATUS" == "TRIGGERED" ]]; then
    echo "🔴 TRIGGERED - workflow exits immediately. Reset consecutive_failures to 0."
elif [[ $CONSECUTIVE_FAILURES -gt 0 ]]; then
    echo "⚠️  $CONSECUTIVE_FAILURES failure(s) - $((THRESHOLD - CONSECUTIVE_FAILURES)) more until trigger"
else
    echo "✓ Healthy"
fi)
```

---

### 8. Display Actionable Insights

```bash
echo "" && echo "─────────────────────────────────────────────────────"
echo "  ACTIONABLE INSIGHTS" && echo "─────────────────────────────────────────────────────" && echo ""

RETRY_ELIGIBLE=$(jq '[.features[] | select(.status == "fail" and .attempts < 3)] | length' "$FEATURE_LIST_FILE")
ACTIONABLE=$((PENDING_COUNT + RETRY_ELIGIBLE))

[[ $ACTIONABLE -gt 0 ]] && echo "✓ $ACTIONABLE features available ($PENDING_COUNT pending + $RETRY_ELIGIBLE retry-eligible)"
[[ $BLOCKED_COUNT -gt 0 ]] && echo "" && echo "⚠️  $BLOCKED_COUNT blocked features need intervention"
[[ $IN_PROGRESS_COUNT -gt 0 ]] && echo "" && echo "⚠️  $IN_PROGRESS_COUNT features stuck 'in_progress' (interrupted session?)"
[[ "$CB_STATUS" == "TRIGGERED" ]] && echo "" && echo "🔴 Circuit breaker blocking implementation"
[[ $FAIL_COUNT -gt 0 && $RETRY_ELIGIBLE -eq 0 ]] && echo "" && echo "⚠️  $FAIL_COUNT failed features exhausted retries"

echo ""
```

---

### 9. Present Editing Menu

**Menu (User selection required):**

```
═══════════════════════════════════════════════════════
  EDIT OPTIONS
═══════════════════════════════════════════════════════

[F] Features       - Modify status/attempts/reasons
[C] Circuit Breaker - Reset failures or change threshold
[X] Exit           - Save and exit

Select [F/C/X]:
```

**Route to next step:**

```bash
read -p "→ " EDIT_CHOICE

case "$EDIT_CHOICE" in
    F|f) echo "" && echo "Proceeding to feature editing..." && echo "" && load_and_execute "{nextStepFile}" ;;
    C|c) echo "" && echo "Proceeding to circuit breaker editing..." && echo "" && load_and_execute "{circuitBreakerStepFile}" ;;
    X|x) echo "" && echo "Exiting EDIT mode..." && echo "" && load_and_execute "{completeStepFile}" ;;
    *) echo "" && echo "❌ Invalid option: $EDIT_CHOICE (use F, C, or X)" && exit 4 ;;
esac
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- Tracking files validated (exist, valid JSON)
- State loaded and displayed (features, circuit breaker, sessions)
- Menu presented and user choice routed

### ❌ FAILURE:
- Exit 1: feature_list.json not found
- Exit 2: claude-progress.txt not found
- Exit 3: Invalid JSON in feature_list.json
- Exit 4: Invalid menu selection

**Master Rule:** Read-only assessment before routing to modification steps.

---

**Step Version:** 1.0.2-ultra-refactored
**Created:** 2026-02-17
**Refactored:** 2026-02-17 (pass 2)
**Lines:** 220
