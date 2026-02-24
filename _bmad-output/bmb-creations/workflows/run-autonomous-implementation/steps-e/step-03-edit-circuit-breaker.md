---
name: 'step-03-edit-circuit-breaker'
description: 'Interactive circuit breaker editing - reset failures, change threshold'
backStepFile: './step-01-assess.md'
completeStepFile: './step-04-complete.md'
progressFile: '{project_folder}/claude-progress.txt'
---

# Step 03: Edit Circuit Breaker (EDIT Mode)

## STEP GOAL:
Interactively edit circuit breaker settings: reset consecutive failures, change threshold, or modify status.

---

## EXECUTION RULES:

See `_bmad/core/universal-rules.md`. Key: Read complete step, facilitator role, never generate without input.

**Role:** State Editor (circuit breaker management) | **Approach:** Display → Edit → Validate → Commit | **Forbidden:** Invalid states, losing tracking data

**Context:** claude-progress.txt (read/write), circuit breaker metadata only, requires step-01 initialization

---

## MANDATORY SEQUENCE

### 1. Display Banner

```
═══════════════════════════════════════════════════════
  EDIT CIRCUIT BREAKER
  Reset Failures, Change Threshold, Modify Status
═══════════════════════════════════════════════════════
```

---

### 2. Load & Display Current State

```bash
PROGRESS_FILE="{progressFile}"
echo "Loading circuit breaker state..."

SESSION_COUNT=$(grep '^session_count=' "$PROGRESS_FILE" | cut -d= -f2)
CONSECUTIVE_FAILURES=$(grep '^consecutive_failures=' "$PROGRESS_FILE" | cut -d= -f2)
THRESHOLD=$(grep '^circuit_breaker_threshold=' "$PROGRESS_FILE" | cut -d= -f2)
CB_STATUS=$(grep '^circuit_breaker_status=' "$PROGRESS_FILE" | cut -d= -f2)

SESSION_COUNT=${SESSION_COUNT:-0}
CONSECUTIVE_FAILURES=${CONSECUTIVE_FAILURES:-0}
THRESHOLD=${THRESHOLD:-5}
CB_STATUS=${CB_STATUS:-HEALTHY}

echo "✓ Circuit breaker state loaded"
echo ""
echo "─────────────────────────────────────────────────────"
echo "  CURRENT STATE"
echo "─────────────────────────────────────────────────────"
echo "Session Count:         $SESSION_COUNT"
echo "Consecutive Failures:  $CONSECUTIVE_FAILURES"
echo "Threshold:             $THRESHOLD"
echo "Status:                $(if [[ "$CB_STATUS" == "TRIGGERED" ]]; then echo "🔴 TRIGGERED"; else echo "✓ $CB_STATUS"; fi)"
echo ""
if [[ "$CB_STATUS" == "TRIGGERED" ]]; then
    echo "⚠️  TRIGGERED - workflow exits until reset"
elif [[ $CONSECUTIVE_FAILURES -gt 0 ]]; then
    echo "⚠️  $CONSECUTIVE_FAILURES failure(s) - $((THRESHOLD - CONSECUTIVE_FAILURES)) until trigger"
else
    echo "✓ Healthy (no consecutive failures)"
fi
```

---

### 3. Circuit Breaker Editing Loop

```bash
# Unified edit function
edit_cb() {
    local field=$1 current=$2 prompt=$3 validation=$4
    echo "" && echo "Current $field: $current" && echo "$prompt"
    read -p "→ New value: " NEW_VALUE
    eval "$validation" || { echo "❌ Invalid value '$NEW_VALUE'"; return 1; }
    cp "$PROGRESS_FILE" "${PROGRESS_FILE}.backup"
    sed -i "s/^$field=.*/$field=$NEW_VALUE/" "$PROGRESS_FILE"
    echo "✓ $field updated: $current → $NEW_VALUE"
    rm -f "${PROGRESS_FILE}.backup"
    return 0
}

CONTINUE_EDITING=true

while [[ "$CONTINUE_EDITING" == "true" ]]; do
    echo "" && echo "═══════════════════════════════════════════════════════"
    echo "  EDITING OPTIONS"
    echo "═══════════════════════════════════════════════════════"
    echo "[F] Reset Consecutive Failures  [T] Change Threshold"
    echo "[S] Reset Status                [A] Reset All"
    echo "[B] Back to Main Menu"
    read -p "→ Select [F/T/S/A/B]: " CB_OPTION

    case "$CB_OPTION" in
        F|f)
            edit_cb "consecutive_failures" "$CONSECUTIVE_FAILURES" \
                "Enter new value (0-99):" \
                "[[ '$NEW_VALUE' =~ ^[0-9]+$ ]] && [[ $NEW_VALUE -le 99 ]]" && {
                CONSECUTIVE_FAILURES=$NEW_VALUE
                [[ $NEW_VALUE -eq 0 ]] && {
                    sed -i "s/^circuit_breaker_status=.*/circuit_breaker_status=HEALTHY/" "$PROGRESS_FILE"
                    echo "✓ status auto-reset to HEALTHY"
                    CB_STATUS="HEALTHY"
                }
            }
            ;;

        T|t)
            echo "Recommended: 3-10 (lower = more sensitive)"
            edit_cb "circuit_breaker_threshold" "$THRESHOLD" \
                "Enter threshold (1-99):" \
                "[[ '$NEW_VALUE' =~ ^[0-9]+$ ]] && [[ $NEW_VALUE -ge 1 ]] && [[ $NEW_VALUE -le 99 ]]" && {
                THRESHOLD=$NEW_VALUE
                if [[ $CONSECUTIVE_FAILURES -ge $NEW_VALUE ]] && [[ "$CB_STATUS" != "TRIGGERED" ]]; then
                    sed -i "s/^circuit_breaker_status=.*/circuit_breaker_status=TRIGGERED/" "$PROGRESS_FILE"
                    echo "⚠️  Now TRIGGERED"; CB_STATUS="TRIGGERED"
                elif [[ $CONSECUTIVE_FAILURES -lt $NEW_VALUE ]] && [[ "$CB_STATUS" == "TRIGGERED" ]]; then
                    sed -i "s/^circuit_breaker_status=.*/circuit_breaker_status=HEALTHY/" "$PROGRESS_FILE"
                    echo "✓ Now HEALTHY"; CB_STATUS="HEALTHY"
                fi
            }
            ;;

        S|s)
            echo "Valid: HEALTHY, TRIGGERED, COMPLETE"
            edit_cb "circuit_breaker_status" "$CB_STATUS" \
                "Enter status:" \
                "[[ '$NEW_VALUE' =~ ^(HEALTHY|TRIGGERED|COMPLETE)$ ]]" && CB_STATUS=$NEW_VALUE
            ;;

        A|a)
            echo "" && echo "⚠️  Reset: consecutive_failures → 0, status → HEALTHY"
            read -p "Continue? [Y/N]: " CONFIRM
            [[ "$CONFIRM" =~ ^[Yy] ]] && {
                cp "$PROGRESS_FILE" "${PROGRESS_FILE}.backup"
                sed -i "s/^consecutive_failures=.*/consecutive_failures=0/" "$PROGRESS_FILE"
                sed -i "s/^circuit_breaker_status=.*/circuit_breaker_status=HEALTHY/" "$PROGRESS_FILE"
                echo "✓ Circuit breaker fully reset"
                CONSECUTIVE_FAILURES=0; CB_STATUS="HEALTHY"
                rm -f "${PROGRESS_FILE}.backup"
            }
            ;;

        B|b)
            echo "Returning to assessment..."
            load_and_execute "{backStepFile}"
            exit 0
            ;;

        *)
            echo "❌ Invalid option: $CB_OPTION"
            continue
            ;;
    esac

    echo "" && read -p "Make another change? [Y/N] → " CONTINUE_CHOICE
    [[ ! "$CONTINUE_CHOICE" =~ ^[Yy] ]] && CONTINUE_EDITING=false
done
```

---

### 4. Display Edit Summary & Proceed

```
─────────────────────────────────────────────────────
  EDITING COMPLETE
─────────────────────────────────────────────────────

Updated State:
  Session Count:         $SESSION_COUNT
  Consecutive Failures:  $CONSECUTIVE_FAILURES
  Threshold:             $THRESHOLD
  Status:                $(if [[ "$CB_STATUS" == "TRIGGERED" ]]; then echo "🔴 TRIGGERED"; else echo "✓ $CB_STATUS"; fi)

All changes saved to claude-progress.txt

$(if [[ $CONSECUTIVE_FAILURES -eq 0 ]]; then
    echo "✓ Circuit breaker reset - workflow can resume"
elif [[ "$CB_STATUS" == "TRIGGERED" ]]; then
    echo "⚠️  Still TRIGGERED - reset to 0 to resume"
else
    echo "⚠️  $((THRESHOLD - CONSECUTIVE_FAILURES)) more failure(s) until trigger"
fi)

Proceeding to completion...

→ Load, read entire file, then execute {completeStepFile}
```

---

## SUCCESS/FAILURE:

**✅ SUCCESS:** State loaded/displayed, backup created, fields validated/updated, status auto-adjusted, multiple edits allowed, changes saved

**❌ FAILURE:** Invalid values (loop continues with error message)

**Master Rule:** Circuit breaker edits maintain state consistency and enable workflow resumption.

---

**Step Version:** 1.0.0 | **Created:** 2026-02-17 | **Status:** Complete
