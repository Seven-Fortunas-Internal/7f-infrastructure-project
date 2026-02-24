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

**Reference: Universal Rules (CLAUDE.md)** - Apply all standard workflow protocols.

### Role:
- ✅ State Editor (controlled modifications) | Collaborative dialogue | Backup → Edit → Validate → Commit/Rollback

### Step-Specific:
- 🎯 Safe, validated feature modifications | 🚫 Forbidden: JSON corruption | 💾 Backup before edit | 📖 Validate after edit

---

## CONTEXT BOUNDARIES:
Available: feature_list.json (read/write) | Focus: Feature property modifications | Limits: Does not edit circuit breaker | Dependencies: Requires feature_list.json from step-01

---

## MANDATORY SEQUENCE

---

### 1. Display Banner & Load Features

```
═══════════════════════════════════════════════════════
  EDIT FEATURES
  Modify Feature Status, Attempts, or Blocked Reasons
═══════════════════════════════════════════════════════
```

```bash
FEATURE_LIST_FILE="{featureListFile}"
echo -e "\nLoading features..."
FEATURE_IDS=($(jq -r '.features[].id' "$FEATURE_LIST_FILE"))
TOTAL_FEATURES=${#FEATURE_IDS[@]}
[[ $TOTAL_FEATURES -eq 0 ]] && { echo "❌ ERROR: No features found"; exit 5; }
echo -e "✓ Loaded $TOTAL_FEATURES features\n"
```

---

### 2. Display Feature Menu & Edit Loop

```bash
echo -e "─────────────────────────────────────────────────────\n  AVAILABLE FEATURES\n─────────────────────────────────────────────────────\n"
jq -r '.features[] | "\(.id) | \(.name) | Status: \(.status) | Attempts: \(.attempts)"' "$FEATURE_LIST_FILE"
echo -e "\n─────────────────────────────────────────────────────\n"

update_feature() {
    local field=$1 value=$2 is_string=$3
    echo -e "\nCreating backup..."
    cp "$FEATURE_LIST_FILE" "${FEATURE_LIST_FILE}.backup"
    if [[ "$is_string" == "true" ]]; then
        jq --arg id "$SELECTED_ID" --arg val "$value" "(.features[] | select(.id == \$id)) |= .$field = \$val" "$FEATURE_LIST_FILE" > "${FEATURE_LIST_FILE}.tmp"
    else
        jq --arg id "$SELECTED_ID" --argjson val "$value" "(.features[] | select(.id == \$id)) |= .$field = \$val" "$FEATURE_LIST_FILE" > "${FEATURE_LIST_FILE}.tmp"
    fi
    if jq empty "${FEATURE_LIST_FILE}.tmp" 2>/dev/null; then
        mv "${FEATURE_LIST_FILE}.tmp" "$FEATURE_LIST_FILE" && rm -f "${FEATURE_LIST_FILE}.backup" && echo "✓ $field updated"
    else
        echo "❌ ERROR: Update failed (invalid JSON)" && mv "${FEATURE_LIST_FILE}.backup" "$FEATURE_LIST_FILE"
    fi
}

CONTINUE_EDITING=true
while [[ "$CONTINUE_EDITING" == "true" ]]; do
    echo -e "═══════════════════════════════════════════════════════\n  SELECT FEATURE TO EDIT\n═══════════════════════════════════════════════════════\n"
    read -p "Enter feature ID to edit (or 'back' to return to main menu): " SELECTED_ID

    [[ "$SELECTED_ID" =~ ^(back|BACK)$ ]] && { echo -e "\nReturning to assessment...\n"; load_and_execute "{backStepFile}"; exit 0; }

    FEATURE_EXISTS=$(jq -r --arg id "$SELECTED_ID" '.features[] | select(.id == $id) | .id' "$FEATURE_LIST_FILE")
    if [[ -z "$FEATURE_EXISTS" ]]; then
        echo -e "\n❌ ERROR: Feature '$SELECTED_ID' not found\n   Please select a valid feature ID\n"
        continue
    fi

    FEATURE_DATA=$(jq -r --arg id "$SELECTED_ID" '.features[] | select(.id == $id) | "\(.name)|\(.status)|\(.attempts)|\(.blocked_reason // "N/A")"' "$FEATURE_LIST_FILE")
    IFS='|' read -r FEATURE_NAME FEATURE_STATUS FEATURE_ATTEMPTS FEATURE_BLOCKED_REASON <<< "$FEATURE_DATA"

    echo -e "\n─────────────────────────────────────────────────────\n  SELECTED FEATURE\n─────────────────────────────────────────────────────\n"
    echo -e "ID: $SELECTED_ID\nName: $FEATURE_NAME\nStatus: $FEATURE_STATUS\nAttempts: $FEATURE_ATTEMPTS\nBlocked Reason: $FEATURE_BLOCKED_REASON\n"
    echo -e "─────────────────────────────────────────────────────\n  WHAT TO EDIT?\n─────────────────────────────────────────────────────\n"
    echo -e "[S] Status          - Change status (pending/pass/fail/blocked/in_progress)\n[A] Attempts        - Reset or modify attempts counter\n[R] Blocked Reason  - Set or update blocked reason\n[B] Back            - Return to feature selection\n"
    read -p "→ Select option [S/A/R/B]: " EDIT_OPTION

    case "$EDIT_OPTION" in
        S|s)
            echo -e "\nCurrent status: $FEATURE_STATUS\nValid statuses: pending, pass, fail, blocked, in_progress\n"
            read -p "→ New status: " NEW_STATUS
            [[ ! "$NEW_STATUS" =~ ^(pending|pass|fail|blocked|in_progress)$ ]] && { echo -e "\n❌ ERROR: Invalid status '$NEW_STATUS'\n"; continue; }
            update_feature "status" "$NEW_STATUS" "true"
            ;;
        A|a)
            echo -e "\nCurrent attempts: $FEATURE_ATTEMPTS\n"
            read -p "→ New attempts count (0-99): " NEW_ATTEMPTS
            { ! [[ "$NEW_ATTEMPTS" =~ ^[0-9]+$ ]] || [[ $NEW_ATTEMPTS -gt 99 ]]; } && { echo -e "\n❌ ERROR: Invalid attempts '$NEW_ATTEMPTS'\n"; continue; }
            update_feature "attempts" "$NEW_ATTEMPTS" "false"
            ;;
        R|r)
            echo -e "\nCurrent blocked reason: $FEATURE_BLOCKED_REASON\nEnter new blocked reason (or 'clear' to remove):\n"
            read -p "→ " NEW_BLOCKED_REASON
            cp "$FEATURE_LIST_FILE" "${FEATURE_LIST_FILE}.backup"
            if [[ "$NEW_BLOCKED_REASON" == "clear" ]]; then
                jq --arg id "$SELECTED_ID" '(.features[] | select(.id == $id)) |= del(.blocked_reason)' "$FEATURE_LIST_FILE" > "${FEATURE_LIST_FILE}.tmp"
            else
                jq --arg id "$SELECTED_ID" --arg reason "$NEW_BLOCKED_REASON" '(.features[] | select(.id == $id)) |= .blocked_reason = $reason' "$FEATURE_LIST_FILE" > "${FEATURE_LIST_FILE}.tmp"
            fi
            if jq empty "${FEATURE_LIST_FILE}.tmp" 2>/dev/null; then
                mv "${FEATURE_LIST_FILE}.tmp" "$FEATURE_LIST_FILE" && rm -f "${FEATURE_LIST_FILE}.backup"
                [[ "$NEW_BLOCKED_REASON" == "clear" ]] && echo "✓ Blocked reason cleared" || echo "✓ Blocked reason updated"
            else
                echo "❌ ERROR: Update failed" && mv "${FEATURE_LIST_FILE}.backup" "$FEATURE_LIST_FILE"
            fi
            ;;
        B|b) echo -e "\nReturning to feature selection...\n"; continue ;;
        *) echo -e "\n❌ Invalid option: $EDIT_OPTION\n"; continue ;;
    esac

    echo -e "\n─────────────────────────────────────────────────────\n\nEdit another feature? [Y/N]\n"
    read -p "→ " CONTINUE_CHOICE
    [[ ! "$CONTINUE_CHOICE" =~ ^[Yy] ]] && CONTINUE_EDITING=false
    echo ""
done
```

---

### 3. Update Progress Metadata

```bash
PROGRESS_FILE="{progressFile}"
echo "Updating progress file metadata..."

PASS_COUNT=$(jq -r '.features[] | select(.status == "pass") | .id' "$FEATURE_LIST_FILE" | wc -l)
PENDING_COUNT=$(jq -r '.features[] | select(.status == "pending") | .id' "$FEATURE_LIST_FILE" | wc -l)
FAIL_COUNT=$(jq -r '.features[] | select(.status == "fail") | .id' "$FEATURE_LIST_FILE" | wc -l)
BLOCKED_COUNT=$(jq -r '.features[] | select(.status == "blocked") | .id' "$FEATURE_LIST_FILE" | wc -l)

sed -i -e "s/^features_completed=.*/features_completed=$PASS_COUNT/" \
       -e "s/^features_pending=.*/features_pending=$PENDING_COUNT/" \
       -e "s/^features_fail=.*/features_fail=$FAIL_COUNT/" \
       -e "s/^features_blocked=.*/features_blocked=$BLOCKED_COUNT/" \
       -e "s/^last_updated=.*/last_updated=$(date -u +%Y-%m-%dT%H:%M:%SZ)/" \
       "$PROGRESS_FILE"

echo -e "✓ Progress metadata updated\n  Pass: $PASS_COUNT, Pending: $PENDING_COUNT, Fail: $FAIL_COUNT, Blocked: $BLOCKED_COUNT\n"
```

---

### 4. Display Completion Summary

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

### 5. Auto-Proceed to Completion

**Menu Handling:** Auto-proceed (no menu)

**Execution:**
```
Proceeding to completion...

→ Load, read entire file, then execute {completeStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
Feature list loaded, user selects features by ID | Feature details displayed accurately | Backup created before each edit | Status/attempts/blocked_reason updated correctly | JSON validated after each update | Rollback performed if validation fails | Progress metadata updated | Multiple edits allowed

### ❌ FAILURE:
No features found (exit 5) | Invalid ID/status/attempts (loop continues, prompt again) | JSON validation fails (rollback performed)

**Master Rule:** All feature edits must be atomic, validated, and reversible.

---

**Step Version:** 1.0.2-ultra-refactored
**Created:** 2026-02-17
**Status:** Complete
