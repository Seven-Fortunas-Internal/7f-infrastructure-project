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

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: State Editor (circuit breaker management)
- ✅ Collaborative dialogue: Interactive editing session
- ✅ You bring: Safe metadata updates, validation
- ✅ User brings: Circuit breaker adjustments

### Step-Specific:
- 🎯 Focus: Circuit breaker state modifications
- 🚫 Forbidden: Creating invalid states, losing tracking data
- 💬 Approach: Display → Edit → Validate → Commit

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Create backup before modifications
- 📖 Validate progress file after edits
- 🔄 Allow multiple edits in single session

---

## CONTEXT BOUNDARIES:
- Available: claude-progress.txt (read/write)
- Focus: Circuit breaker metadata modifications
- Limits: Does not edit features (that's step-02)
- Dependencies: Requires claude-progress.txt from step-01

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Circuit Breaker Editing Banner

```
═══════════════════════════════════════════════════════
  EDIT CIRCUIT BREAKER
  Reset Failures, Change Threshold, Modify Status
═══════════════════════════════════════════════════════
```

---

### 2. Load Current Circuit Breaker State

**Read current settings:**

```bash
PROGRESS_FILE="{progressFile}"

echo ""
echo "Loading circuit breaker state..."

# Load current values
SESSION_COUNT=$(grep '^session_count=' "$PROGRESS_FILE" | cut -d= -f2)
CONSECUTIVE_FAILURES=$(grep '^consecutive_failures=' "$PROGRESS_FILE" | cut -d= -f2)
THRESHOLD=$(grep '^circuit_breaker_threshold=' "$PROGRESS_FILE" | cut -d= -f2)
CB_STATUS=$(grep '^circuit_breaker_status=' "$PROGRESS_FILE" | cut -d= -f2)
LAST_SESSION_SUCCESS=$(grep '^last_session_success=' "$PROGRESS_FILE" | cut -d= -f2)

# Defaults
SESSION_COUNT=${SESSION_COUNT:-0}
CONSECUTIVE_FAILURES=${CONSECUTIVE_FAILURES:-0}
THRESHOLD=${THRESHOLD:-5}
CB_STATUS=${CB_STATUS:-HEALTHY}
LAST_SESSION_SUCCESS=${LAST_SESSION_SUCCESS:-N/A}

echo "✓ Circuit breaker state loaded"
echo ""
```

---

### 3. Display Current State

```
─────────────────────────────────────────────────────
  CURRENT CIRCUIT BREAKER STATE
─────────────────────────────────────────────────────

Session Count:         $SESSION_COUNT
Consecutive Failures:  $CONSECUTIVE_FAILURES
Threshold:             $THRESHOLD
Status:                $(if [[ "$CB_STATUS" == "TRIGGERED" ]]; then echo "🔴 TRIGGERED"; else echo "✓ $CB_STATUS"; fi)
Last Session Success:  $LAST_SESSION_SUCCESS

$(if [[ "$CB_STATUS" == "TRIGGERED" ]]; then
    echo "⚠️  Circuit breaker is TRIGGERED"
    echo "   Workflow will exit immediately until consecutive_failures is reset"
elif [[ $CONSECUTIVE_FAILURES -gt 0 ]]; then
    REMAINING=$((THRESHOLD - CONSECUTIVE_FAILURES))
    echo "⚠️  Warning: $CONSECUTIVE_FAILURES consecutive failure(s)"
    echo "   $REMAINING more failure(s) until circuit breaker triggers"
else
    echo "✓ Circuit breaker is healthy (no consecutive failures)"
fi)
```

---

### 4. Circuit Breaker Editing Loop

**Allow user to make multiple edits:**

```bash
# Initialize loop
CONTINUE_EDITING=true

while [[ "$CONTINUE_EDITING" == "true" ]]; do
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  CIRCUIT BREAKER EDITING OPTIONS"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo "[F] Reset Consecutive Failures  - Set consecutive_failures to 0"
    echo "[T] Change Threshold            - Modify circuit_breaker_threshold"
    echo "[S] Reset Status                - Change circuit_breaker_status"
    echo "[A] Reset All                   - Reset failures to 0, status to HEALTHY"
    echo "[B] Back                        - Return to main menu"
    echo ""
    read -p "→ Select option [F/T/S/A/B]: " CB_OPTION

    case "$CB_OPTION" in
        F|f)
            # Reset consecutive failures
            echo ""
            echo "Current consecutive_failures: $CONSECUTIVE_FAILURES"
            echo ""
            read -p "→ New value (0-99): " NEW_FAILURES

            # Validate
            if ! [[ "$NEW_FAILURES" =~ ^[0-9]+$ ]] || [[ $NEW_FAILURES -gt 99 ]]; then
                echo ""
                echo "❌ ERROR: Invalid value '$NEW_FAILURES'"
                echo "   Must be a number between 0-99"
                echo ""
                continue
            fi

            # Create backup
            echo ""
            echo "Creating backup..."
            cp "$PROGRESS_FILE" "${PROGRESS_FILE}.backup"

            # Update consecutive_failures
            sed -i "s/^consecutive_failures=.*/consecutive_failures=$NEW_FAILURES/" "$PROGRESS_FILE"

            # Auto-reset status if setting to 0
            if [[ $NEW_FAILURES -eq 0 ]]; then
                sed -i "s/^circuit_breaker_status=.*/circuit_breaker_status=HEALTHY/" "$PROGRESS_FILE"
                echo "✓ consecutive_failures updated: $CONSECUTIVE_FAILURES → $NEW_FAILURES"
                echo "✓ circuit_breaker_status auto-reset to HEALTHY"
                CB_STATUS="HEALTHY"
            else
                echo "✓ consecutive_failures updated: $CONSECUTIVE_FAILURES → $NEW_FAILURES"
            fi

            CONSECUTIVE_FAILURES=$NEW_FAILURES
            rm -f "${PROGRESS_FILE}.backup"
            ;;

        T|t)
            # Change threshold
            echo ""
            echo "Current threshold: $THRESHOLD"
            echo ""
            echo "Recommended values: 3-10 (lower = more sensitive)"
            echo ""
            read -p "→ New threshold (1-99): " NEW_THRESHOLD

            # Validate
            if ! [[ "$NEW_THRESHOLD" =~ ^[0-9]+$ ]] || [[ $NEW_THRESHOLD -lt 1 ]] || [[ $NEW_THRESHOLD -gt 99 ]]; then
                echo ""
                echo "❌ ERROR: Invalid threshold '$NEW_THRESHOLD'"
                echo "   Must be a number between 1-99"
                echo ""
                continue
            fi

            # Create backup
            echo ""
            echo "Creating backup..."
            cp "$PROGRESS_FILE" "${PROGRESS_FILE}.backup"

            # Update threshold
            sed -i "s/^circuit_breaker_threshold=.*/circuit_breaker_threshold=$NEW_THRESHOLD/" "$PROGRESS_FILE"

            echo "✓ threshold updated: $THRESHOLD → $NEW_THRESHOLD"
            THRESHOLD=$NEW_THRESHOLD

            # Check if status should change based on new threshold
            if [[ $CONSECUTIVE_FAILURES -ge $NEW_THRESHOLD ]] && [[ "$CB_STATUS" != "TRIGGERED" ]]; then
                sed -i "s/^circuit_breaker_status=.*/circuit_breaker_status=TRIGGERED/" "$PROGRESS_FILE"
                echo "⚠️  Circuit breaker now TRIGGERED (consecutive_failures >= new threshold)"
                CB_STATUS="TRIGGERED"
            elif [[ $CONSECUTIVE_FAILURES -lt $NEW_THRESHOLD ]] && [[ "$CB_STATUS" == "TRIGGERED" ]]; then
                sed -i "s/^circuit_breaker_status=.*/circuit_breaker_status=HEALTHY/" "$PROGRESS_FILE"
                echo "✓ Circuit breaker now HEALTHY (consecutive_failures < new threshold)"
                CB_STATUS="HEALTHY"
            fi

            rm -f "${PROGRESS_FILE}.backup"
            ;;

        S|s)
            # Reset status
            echo ""
            echo "Current status: $CB_STATUS"
            echo ""
            echo "Valid statuses: HEALTHY, TRIGGERED, COMPLETE"
            echo ""
            read -p "→ New status: " NEW_STATUS

            # Validate
            if [[ ! "$NEW_STATUS" =~ ^(HEALTHY|TRIGGERED|COMPLETE)$ ]]; then
                echo ""
                echo "❌ ERROR: Invalid status '$NEW_STATUS'"
                echo "   Must be one of: HEALTHY, TRIGGERED, COMPLETE"
                echo ""
                continue
            fi

            # Create backup
            echo ""
            echo "Creating backup..."
            cp "$PROGRESS_FILE" "${PROGRESS_FILE}.backup"

            # Update status
            sed -i "s/^circuit_breaker_status=.*/circuit_breaker_status=$NEW_STATUS/" "$PROGRESS_FILE"

            echo "✓ status updated: $CB_STATUS → $NEW_STATUS"
            CB_STATUS=$NEW_STATUS
            rm -f "${PROGRESS_FILE}.backup"
            ;;

        A|a)
            # Reset all
            echo ""
            echo "⚠️  This will reset:"
            echo "  - consecutive_failures → 0"
            echo "  - circuit_breaker_status → HEALTHY"
            echo ""
            read -p "Continue? [Y/N]: " CONFIRM

            if [[ ! "$CONFIRM" =~ ^[Yy] ]]; then
                echo "Cancelled."
                continue
            fi

            # Create backup
            echo ""
            echo "Creating backup..."
            cp "$PROGRESS_FILE" "${PROGRESS_FILE}.backup"

            # Reset both
            sed -i "s/^consecutive_failures=.*/consecutive_failures=0/" "$PROGRESS_FILE"
            sed -i "s/^circuit_breaker_status=.*/circuit_breaker_status=HEALTHY/" "$PROGRESS_FILE"

            echo "✓ Circuit breaker fully reset"
            echo "  consecutive_failures: $CONSECUTIVE_FAILURES → 0"
            echo "  status: $CB_STATUS → HEALTHY"

            CONSECUTIVE_FAILURES=0
            CB_STATUS="HEALTHY"
            rm -f "${PROGRESS_FILE}.backup"
            ;;

        B|b)
            # Back to main menu
            echo ""
            echo "Returning to assessment..."
            echo ""
            load_and_execute "{backStepFile}"
            exit 0
            ;;

        *)
            echo ""
            echo "❌ Invalid option: $CB_OPTION"
            echo ""
            continue
            ;;
    esac

    # Ask if user wants to make more changes
    echo ""
    echo "─────────────────────────────────────────────────────"
    echo ""
    echo "Make another change? [Y/N]"
    echo ""
    read -p "→ " CONTINUE_CHOICE

    if [[ ! "$CONTINUE_CHOICE" =~ ^[Yy] ]]; then
        CONTINUE_EDITING=false
    fi

    echo ""
done
```

---

### 5. Display Edit Summary

```
─────────────────────────────────────────────────────
  CIRCUIT BREAKER EDITING COMPLETE
─────────────────────────────────────────────────────

Updated Circuit Breaker State:
  Session Count:         $SESSION_COUNT
  Consecutive Failures:  $CONSECUTIVE_FAILURES
  Threshold:             $THRESHOLD
  Status:                $(if [[ "$CB_STATUS" == "TRIGGERED" ]]; then echo "🔴 TRIGGERED"; else echo "✓ $CB_STATUS"; fi)

All changes saved to claude-progress.txt

$(if [[ $CONSECUTIVE_FAILURES -eq 0 ]]; then
    echo "✓ Circuit breaker reset - workflow can now resume"
elif [[ "$CB_STATUS" == "TRIGGERED" ]]; then
    echo "⚠️  Circuit breaker is still TRIGGERED"
    echo "   Reset consecutive_failures to 0 to allow workflow to run"
else
    REMAINING=$((THRESHOLD - CONSECUTIVE_FAILURES))
    echo "⚠️  $REMAINING more failure(s) until circuit breaker triggers"
fi)

Next: Exit EDIT mode or return to main menu
```

---

### 6. Proceed to Completion

**Menu Handling Logic:**
- This step uses **Auto-proceed** (no menu)
- Circuit breaker edits complete, route to completion step

**Execution:**

```
Proceeding to completion...

→ Load, read entire file, then execute {completeStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- Circuit breaker state loaded successfully
- Current state displayed clearly
- Backup created before each edit
- consecutive_failures updated (if selected)
- circuit_breaker_threshold updated (if selected)
- circuit_breaker_status updated (if selected)
- Full reset performed (if selected)
- Status automatically adjusted based on threshold changes
- Multiple edits allowed in single session
- Changes saved to claude-progress.txt
- Edit summary displayed

### ❌ FAILURE:
- Invalid consecutive_failures value (loop continues)
- Invalid threshold value (loop continues)
- Invalid status value (loop continues)

**Master Rule:** Circuit breaker edits must maintain state consistency and allow workflow resumption.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
