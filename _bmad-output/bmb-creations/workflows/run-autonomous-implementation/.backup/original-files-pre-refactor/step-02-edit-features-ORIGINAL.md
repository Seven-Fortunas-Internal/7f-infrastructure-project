---
name: 'step-02-edit-features'
description: 'Interactive feature editing - modify status, attempts, blocked reasons'
backStepFile: './step-01-assess.md'
completeStepFile: './step-04-complete.md'
featureListFile: '{project_folder}/feature_list.json'
progressFile: '{project_folder}/claude-progress.txt'
---

# Step 02: Edit Features (EDIT Mode)

## STEP GOAL:
Interactively edit feature properties: status, attempts counter, blocked reasons, or dependencies.

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: State Editor (controlled modifications)
- ✅ Collaborative dialogue: Interactive editing session
- ✅ You bring: Atomic updates, validation, rollback
- ✅ User brings: Editing decisions

### Step-Specific:
- 🎯 Focus: Safe, validated feature modifications
- 🚫 Forbidden: Corrupting JSON, losing data
- 💬 Approach: Backup → Edit → Validate → Commit or Rollback

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Create backup before every edit
- 📖 Validate JSON after every edit
- 🔄 Allow multiple edits in single session

---

## CONTEXT BOUNDARIES:
- Available: feature_list.json (read/write)
- Focus: Feature property modifications
- Limits: Does not edit circuit breaker (that's step-03)
- Dependencies: Requires feature_list.json from step-01

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Feature Editing Banner

```
═══════════════════════════════════════════════════════
  EDIT FEATURES
  Modify Feature Status, Attempts, or Blocked Reasons
═══════════════════════════════════════════════════════
```

---

### 2. Load Feature List

**Read current features:**

```bash
FEATURE_LIST_FILE="{featureListFile}"

echo ""
echo "Loading features..."

# Get all feature IDs
FEATURE_IDS=($(jq -r '.features[].id' "$FEATURE_LIST_FILE"))
TOTAL_FEATURES=${#FEATURE_IDS[@]}

if [[ $TOTAL_FEATURES -eq 0 ]]; then
    echo "❌ ERROR: No features found in feature_list.json"
    exit 5
fi

echo "✓ Loaded $TOTAL_FEATURES features"
echo ""
```

---

### 3. Display Feature Selection Menu

**Show all features with current status:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  AVAILABLE FEATURES"
echo "─────────────────────────────────────────────────────"
echo ""

# Display features with status indicators
jq -r '.features[] |
    "\(.id) | \(.name) | Status: \(.status) | Attempts: \(.attempts)"' \
    "$FEATURE_LIST_FILE"

echo ""
echo "─────────────────────────────────────────────────────"
echo ""
```

---

### 4. Feature Selection Loop

**Allow user to select and edit multiple features:**

```bash
# Initialize loop
CONTINUE_EDITING=true

while [[ "$CONTINUE_EDITING" == "true" ]]; do
    echo "═══════════════════════════════════════════════════════"
    echo "  SELECT FEATURE TO EDIT"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo "Enter feature ID to edit (or 'back' to return to main menu):"
    echo ""
    read -p "→ Feature ID: " SELECTED_ID

    # Check for back command
    if [[ "$SELECTED_ID" == "back" || "$SELECTED_ID" == "BACK" ]]; then
        echo ""
        echo "Returning to assessment..."
        echo ""
        load_and_execute "{backStepFile}"
        exit 0
    fi

    # Validate feature exists
    FEATURE_EXISTS=$(jq -r --arg id "$SELECTED_ID" \
        '.features[] | select(.id == $id) | .id' \
        "$FEATURE_LIST_FILE")

    if [[ -z "$FEATURE_EXISTS" ]]; then
        echo ""
        echo "❌ ERROR: Feature '$SELECTED_ID' not found"
        echo "   Please select a valid feature ID from the list above"
        echo ""
        continue
    fi

    # Load feature details
    FEATURE_NAME=$(jq -r --arg id "$SELECTED_ID" \
        '.features[] | select(.id == $id) | .name' \
        "$FEATURE_LIST_FILE")
    FEATURE_STATUS=$(jq -r --arg id "$SELECTED_ID" \
        '.features[] | select(.id == $id) | .status' \
        "$FEATURE_LIST_FILE")
    FEATURE_ATTEMPTS=$(jq -r --arg id "$SELECTED_ID" \
        '.features[] | select(.id == $id) | .attempts' \
        "$FEATURE_LIST_FILE")
    FEATURE_BLOCKED_REASON=$(jq -r --arg id "$SELECTED_ID" \
        '.features[] | select(.id == $id) | .blocked_reason // "N/A"' \
        "$FEATURE_LIST_FILE")

    echo ""
    echo "─────────────────────────────────────────────────────"
    echo "  SELECTED FEATURE"
    echo "─────────────────────────────────────────────────────"
    echo ""
    echo "ID: $SELECTED_ID"
    echo "Name: $FEATURE_NAME"
    echo "Status: $FEATURE_STATUS"
    echo "Attempts: $FEATURE_ATTEMPTS"
    echo "Blocked Reason: $FEATURE_BLOCKED_REASON"
    echo ""

    # Present editing options
    echo "─────────────────────────────────────────────────────"
    echo "  WHAT TO EDIT?"
    echo "─────────────────────────────────────────────────────"
    echo ""
    echo "[S] Status          - Change status (pending/pass/fail/blocked/in_progress)"
    echo "[A] Attempts        - Reset or modify attempts counter"
    echo "[R] Blocked Reason  - Set or update blocked reason"
    echo "[B] Back            - Return to feature selection"
    echo ""
    read -p "→ Select option [S/A/R/B]: " EDIT_OPTION

    case "$EDIT_OPTION" in
        S|s)
            # Edit status
            echo ""
            echo "Current status: $FEATURE_STATUS"
            echo ""
            echo "Valid statuses: pending, pass, fail, blocked, in_progress"
            echo ""
            read -p "→ New status: " NEW_STATUS

            # Validate status
            if [[ ! "$NEW_STATUS" =~ ^(pending|pass|fail|blocked|in_progress)$ ]]; then
                echo ""
                echo "❌ ERROR: Invalid status '$NEW_STATUS'"
                echo "   Must be one of: pending, pass, fail, blocked, in_progress"
                echo ""
                continue
            fi

            # Create backup
            echo ""
            echo "Creating backup..."
            cp "$FEATURE_LIST_FILE" "${FEATURE_LIST_FILE}.backup"

            # Update status
            jq --arg id "$SELECTED_ID" \
               --arg status "$NEW_STATUS" \
               '(.features[] | select(.id == $id)) |= .status = $status' \
               "$FEATURE_LIST_FILE" > "${FEATURE_LIST_FILE}.tmp"

            # Validate and commit
            if jq empty "${FEATURE_LIST_FILE}.tmp" 2>/dev/null; then
                mv "${FEATURE_LIST_FILE}.tmp" "$FEATURE_LIST_FILE"
                rm -f "${FEATURE_LIST_FILE}.backup"
                echo "✓ Status updated: $FEATURE_STATUS → $NEW_STATUS"
            else
                echo "❌ ERROR: Update failed (invalid JSON)"
                mv "${FEATURE_LIST_FILE}.backup" "$FEATURE_LIST_FILE"
            fi
            ;;

        A|a)
            # Edit attempts
            echo ""
            echo "Current attempts: $FEATURE_ATTEMPTS"
            echo ""
            read -p "→ New attempts count (0-99): " NEW_ATTEMPTS

            # Validate attempts
            if ! [[ "$NEW_ATTEMPTS" =~ ^[0-9]+$ ]] || [[ $NEW_ATTEMPTS -gt 99 ]]; then
                echo ""
                echo "❌ ERROR: Invalid attempts '$NEW_ATTEMPTS'"
                echo "   Must be a number between 0-99"
                echo ""
                continue
            fi

            # Create backup
            echo ""
            echo "Creating backup..."
            cp "$FEATURE_LIST_FILE" "${FEATURE_LIST_FILE}.backup"

            # Update attempts
            jq --arg id "$SELECTED_ID" \
               --argjson attempts "$NEW_ATTEMPTS" \
               '(.features[] | select(.id == $id)) |= .attempts = $attempts' \
               "$FEATURE_LIST_FILE" > "${FEATURE_LIST_FILE}.tmp"

            # Validate and commit
            if jq empty "${FEATURE_LIST_FILE}.tmp" 2>/dev/null; then
                mv "${FEATURE_LIST_FILE}.tmp" "$FEATURE_LIST_FILE"
                rm -f "${FEATURE_LIST_FILE}.backup"
                echo "✓ Attempts updated: $FEATURE_ATTEMPTS → $NEW_ATTEMPTS"
            else
                echo "❌ ERROR: Update failed (invalid JSON)"
                mv "${FEATURE_LIST_FILE}.backup" "$FEATURE_LIST_FILE"
            fi
            ;;

        R|r)
            # Edit blocked reason
            echo ""
            echo "Current blocked reason: $FEATURE_BLOCKED_REASON"
            echo ""
            echo "Enter new blocked reason (or 'clear' to remove):"
            echo ""
            read -p "→ " NEW_BLOCKED_REASON

            # Create backup
            echo ""
            echo "Creating backup..."
            cp "$FEATURE_LIST_FILE" "${FEATURE_LIST_FILE}.backup"

            # Update blocked reason
            if [[ "$NEW_BLOCKED_REASON" == "clear" ]]; then
                # Remove blocked_reason field
                jq --arg id "$SELECTED_ID" \
                   '(.features[] | select(.id == $id)) |= del(.blocked_reason)' \
                   "$FEATURE_LIST_FILE" > "${FEATURE_LIST_FILE}.tmp"
            else
                # Set blocked_reason
                jq --arg id "$SELECTED_ID" \
                   --arg reason "$NEW_BLOCKED_REASON" \
                   '(.features[] | select(.id == $id)) |= .blocked_reason = $reason' \
                   "$FEATURE_LIST_FILE" > "${FEATURE_LIST_FILE}.tmp"
            fi

            # Validate and commit
            if jq empty "${FEATURE_LIST_FILE}.tmp" 2>/dev/null; then
                mv "${FEATURE_LIST_FILE}.tmp" "$FEATURE_LIST_FILE"
                rm -f "${FEATURE_LIST_FILE}.backup"
                if [[ "$NEW_BLOCKED_REASON" == "clear" ]]; then
                    echo "✓ Blocked reason cleared"
                else
                    echo "✓ Blocked reason updated"
                fi
            else
                echo "❌ ERROR: Update failed (invalid JSON)"
                mv "${FEATURE_LIST_FILE}.backup" "$FEATURE_LIST_FILE"
            fi
            ;;

        B|b)
            # Back to feature selection (loop continues)
            echo ""
            echo "Returning to feature selection..."
            echo ""
            continue
            ;;

        *)
            echo ""
            echo "❌ Invalid option: $EDIT_OPTION"
            echo ""
            continue
            ;;
    esac

    # Ask if user wants to edit more features
    echo ""
    echo "─────────────────────────────────────────────────────"
    echo ""
    echo "Edit another feature? [Y/N]"
    echo ""
    read -p "→ " CONTINUE_CHOICE

    if [[ ! "$CONTINUE_CHOICE" =~ ^[Yy] ]]; then
        CONTINUE_EDITING=false
    fi

    echo ""
done
```

---

### 5. Update Progress File Metadata

**Recalculate feature counts after edits:**

```bash
PROGRESS_FILE="{progressFile}"

echo "Updating progress file metadata..."

# Recalculate counts
PASS_COUNT=$(jq -r '.features[] | select(.status == "pass") | .id' "$FEATURE_LIST_FILE" | wc -l)
PENDING_COUNT=$(jq -r '.features[] | select(.status == "pending") | .id' "$FEATURE_LIST_FILE" | wc -l)
FAIL_COUNT=$(jq -r '.features[] | select(.status == "fail") | .id' "$FEATURE_LIST_FILE" | wc -l)
BLOCKED_COUNT=$(jq -r '.features[] | select(.status == "blocked") | .id' "$FEATURE_LIST_FILE" | wc -l)

# Update metadata
sed -i "s/^features_completed=.*/features_completed=$PASS_COUNT/" "$PROGRESS_FILE"
sed -i "s/^features_pending=.*/features_pending=$PENDING_COUNT/" "$PROGRESS_FILE"
sed -i "s/^features_fail=.*/features_fail=$FAIL_COUNT/" "$PROGRESS_FILE"
sed -i "s/^features_blocked=.*/features_blocked=$BLOCKED_COUNT/" "$PROGRESS_FILE"

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
sed -i "s/^last_updated=.*/last_updated=$TIMESTAMP/" "$PROGRESS_FILE"

echo "✓ Progress metadata updated"
echo "  Pass: $PASS_COUNT, Pending: $PENDING_COUNT, Fail: $FAIL_COUNT, Blocked: $BLOCKED_COUNT"
echo ""
```

---

### 6. Display Edit Summary

```
─────────────────────────────────────────────────────
  FEATURE EDITING COMPLETE
─────────────────────────────────────────────────────

All changes saved successfully.

Updated Files:
  ✓ feature_list.json
  ✓ claude-progress.txt (metadata)

Next: Return to main menu or exit EDIT mode
```

---

### 7. Proceed to Completion

**Menu Handling Logic:**
- This step uses **Auto-proceed** (no menu)
- Edits complete, route to completion step

**Execution:**

```
Proceeding to completion...

→ Load, read entire file, then execute {completeStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- Feature list loaded successfully
- User able to select features by ID
- Feature details displayed accurately
- Backup created before each edit
- Status/attempts/blocked_reason updated correctly
- JSON validated after each update
- Rollback performed if validation fails
- Progress file metadata updated (feature counts)
- Multiple edits allowed in single session
- Changes saved to feature_list.json

### ❌ FAILURE:
- No features found (exit code 5)
- Invalid feature ID selected (loop continues)
- Invalid status value (loop continues)
- Invalid attempts value (loop continues)
- JSON validation fails (rollback performed)

**Master Rule:** All feature edits must be atomic, validated, and reversible.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
