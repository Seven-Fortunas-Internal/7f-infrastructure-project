---
name: 'step-11-update-tracking'
description: 'Update feature_list.json and claude-progress.txt with test results'
nextStepFile: './step-12-commit-work.md'
featureListFile: '{project_folder}/feature_list.json'
progressFile: '{project_folder}/claude-progress.txt'
---

# Step 11: Update Tracking

## STEP GOAL:
Update feature_list.json with test results (status, attempts, verification_results), increment attempts counter, and log to claude-progress.txt.

---

## MANDATORY EXECUTION RULES:

See: `@~/.claude/rules/bmad-universal-execution.md` (Universal, Role, Step-Specific)

**Role:** State Manager (atomic tracking updates)

**Step-Specific:**
- 🎯 Focus: Atomic updates with validation and rollback
- 🚫 Forbidden: Direct editing without backup, losing test results
- 💬 Approach: Backup → Update → Validate → Rollback on error

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Create backups before modifications
- 📖 Validate JSON after updates, rollback if invalid

---

## CONTEXT BOUNDARIES:
- Available: Test results from step-10, feature_list.json
- Focus: Tracking file updates
- Limits: Does not commit to git (that's step-12)
- Dependencies: Requires test results from step-10

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Update Start

```
═══════════════════════════════════════════════════════
  UPDATING TRACKING FILES
  Recording Test Results
═══════════════════════════════════════════════════════
```

---

### 2. Create Backup

```bash
FEATURE_LIST_FILE="{featureListFile}"
echo "Creating backup..."
cp "$FEATURE_LIST_FILE" "${FEATURE_LIST_FILE}.backup" || { echo "❌ Backup failed"; exit 38; }
echo "✓ Backup created"
```

---

### 3. Update Feature Status

**Atomic update: status, attempts, verification_results, timestamp, notes**

```bash
echo "Updating feature status..."

# Determine status
if [[ "$OVERALL_STATUS" == "pass" ]]; then
    NEW_STATUS="pass"
else
    NEW_STATUS="fail"
fi

NEW_ATTEMPTS=$((FEATURE_ATTEMPTS + 1))
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Build implementation note if failed
IMPL_NOTE=""
if [[ "$NEW_STATUS" == "fail" ]]; then
    IMPL_NOTE="Attempt $NEW_ATTEMPTS failed: $(IFS='; '; echo "${FAIL_REASONS[*]}")"
fi

echo "  Status: $FEATURE_STATUS → $NEW_STATUS"
echo "  Attempts: $FEATURE_ATTEMPTS → $NEW_ATTEMPTS"

# Single atomic update
jq --arg id "$SELECTED_FEATURE_ID" \
   --arg status "$NEW_STATUS" \
   --argjson attempts "$NEW_ATTEMPTS" \
   --arg func "$FUNCTIONAL_RESULT" \
   --arg tech "$TECHNICAL_RESULT" \
   --arg integ "$INTEGRATION_RESULT" \
   --arg timestamp "$TIMESTAMP" \
   --arg note "$IMPL_NOTE" \
   '(.features[] | select(.id == $id)) |= (
     .status = $status |
     .attempts = $attempts |
     .verification_results = {
       "functional": $func,
       "technical": $tech,
       "integration": $integ
     } |
     .last_updated = $timestamp |
     (if $note != "" then .implementation_notes = $note else . end)
   )' \
   "$FEATURE_LIST_FILE" > "${FEATURE_LIST_FILE}.tmp" || {
    echo "❌ Update failed"
    mv "${FEATURE_LIST_FILE}.backup" "$FEATURE_LIST_FILE"
    exit 39
}

mv "${FEATURE_LIST_FILE}.tmp" "$FEATURE_LIST_FILE"
echo "✓ Feature updated"
```

---

### 4. Validate Updated JSON

```bash
echo "Validating..."

if ! jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then
    echo "❌ Invalid JSON, rolling back..."
    mv "${FEATURE_LIST_FILE}.backup" "$FEATURE_LIST_FILE"
    exit 41
fi

# Verify update
UPDATED_STATUS=$(jq -r --arg id "$SELECTED_FEATURE_ID" \
                 '.features[] | select(.id == $id) | .status' \
                 "$FEATURE_LIST_FILE")

if [[ "$UPDATED_STATUS" != "$NEW_STATUS" ]]; then
    echo "❌ Status mismatch, rolling back..."
    mv "${FEATURE_LIST_FILE}.backup" "$FEATURE_LIST_FILE"
    exit 40
fi

echo "✓ Validation passed"
rm -f "${FEATURE_LIST_FILE}.backup"
```

---

### 5. Update claude-progress.txt Metadata

```bash
PROGRESS_FILE="{progressFile}"
echo "Updating progress metadata..."

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
sed -i "s/^last_updated=.*/last_updated=$TIMESTAMP/" "$PROGRESS_FILE"

echo "✓ Progress updated (Pass: $PASS_COUNT, Pending: $PENDING_COUNT, Fail: $FAIL_COUNT, Blocked: $BLOCKED_COUNT)"
```

---

### 6. Display Summary

```
─────────────────────────────────────────────────────
  TRACKING UPDATE COMPLETE
─────────────────────────────────────────────────────

Feature: $SELECTED_FEATURE_ID
Status: $FEATURE_STATUS → $NEW_STATUS
Attempts: $FEATURE_ATTEMPTS → $NEW_ATTEMPTS

Verification Results:
  Functional:   $FUNCTIONAL_RESULT
  Technical:    $TECHNICAL_RESULT
  Integration:  $INTEGRATION_RESULT

Updated Files:
  ✓ feature_list.json
  ✓ claude-progress.txt

$(if [[ "$NEW_STATUS" == "pass" ]]; then
    echo "✓ Feature completed successfully"
else
    echo "⚠️  Feature failed (attempt $NEW_ATTEMPTS/3)"
    if [[ $NEW_ATTEMPTS -ge 3 ]]; then
        echo "   Will be blocked in next session (retry limit reached)"
    else
        echo "   Eligible for retry in next session"
    fi
fi)

Next: Commit changes to git
```

---

### 7. Auto-Proceed to Step 12

```
Proceeding to git commit...

→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- Backup created → Atomic update applied → JSON validated → Backup removed
- Feature status, attempts, verification_results, timestamp, notes updated
- claude-progress.txt metadata synced
- Ready for step-12 (commit)

### ❌ FAILURE:
- Exit 38: Backup failed
- Exit 39: jq update failed (rollback performed)
- Exit 40: Status mismatch (rollback performed)
- Exit 41: Invalid JSON (rollback performed)

**Master Rule:** Tracking updates must be atomic and validated before proceeding.

---

**Step Version:** 1.1.0 (Refactored)
**Created:** 2026-02-17
**Status:** Complete
