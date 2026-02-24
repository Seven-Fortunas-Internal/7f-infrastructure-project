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

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: State Manager (atomic tracking updates)
- ✅ Collaborative dialogue: None (automated updates)
- ✅ You bring: Atomic update logic, rollback capability
- ✅ User brings: Test results from step-10

### Step-Specific:
- 🎯 Focus: Update tracking files safely with rollback protection
- 🚫 Forbidden: Direct editing without backup, losing test results
- 💬 Approach: Atomic updates with validation

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

### 2. Create Backup of feature_list.json

**Safety measure before modifications:**

```bash
FEATURE_LIST_FILE="{featureListFile}"

echo ""
echo "Creating backup..."

cp "$FEATURE_LIST_FILE" "${FEATURE_LIST_FILE}.backup"

if [[ $? -eq 0 ]]; then
    echo "✓ Backup created: ${FEATURE_LIST_FILE}.backup"
else
    echo "❌ ERROR: Failed to create backup"
    exit 38
fi

echo ""
```

---

### 3. Update Feature Status

**Set status based on test results:**

```bash
echo "Updating feature status..."

# Determine new status
if [[ "$OVERALL_STATUS" == "pass" ]]; then
    NEW_STATUS="pass"
else
    NEW_STATUS="fail"
fi

echo "  New status: $NEW_STATUS"

# Update status field
jq --arg id "$SELECTED_FEATURE_ID" \
   --arg status "$NEW_STATUS" \
   '(.features[] | select(.id == $id)) |= .status = $status' \
   "$FEATURE_LIST_FILE" > "${FEATURE_LIST_FILE}.tmp"

if [[ $? -ne 0 ]]; then
    echo "❌ ERROR: jq command failed"
    mv "${FEATURE_LIST_FILE}.backup" "$FEATURE_LIST_FILE"
    exit 39
fi

mv "${FEATURE_LIST_FILE}.tmp" "$FEATURE_LIST_FILE"
echo "✓ Status updated"
```

---

### 4. Increment Attempts Counter

**Track retry count:**

```bash
echo ""
echo "Incrementing attempts counter..."

NEW_ATTEMPTS=$((FEATURE_ATTEMPTS + 1))
echo "  Attempts: $FEATURE_ATTEMPTS → $NEW_ATTEMPTS"

jq --arg id "$SELECTED_FEATURE_ID" \
   --argjson attempts "$NEW_ATTEMPTS" \
   '(.features[] | select(.id == $id)) |= .attempts = $attempts' \
   "$FEATURE_LIST_FILE" > "${FEATURE_LIST_FILE}.tmp"

mv "${FEATURE_LIST_FILE}.tmp" "$FEATURE_LIST_FILE"
echo "✓ Attempts updated"
```

---

### 5. Update Verification Results

**Store detailed test outcomes:**

```bash
echo ""
echo "Updating verification results..."

# Build verification_results object
jq --arg id "$SELECTED_FEATURE_ID" \
   --arg func "$FUNCTIONAL_RESULT" \
   --arg tech "$TECHNICAL_RESULT" \
   --arg integ "$INTEGRATION_RESULT" \
   '(.features[] | select(.id == $id)) |=
    .verification_results = {
      "functional": $func,
      "technical": $tech,
      "integration": $integ
    }' \
   "$FEATURE_LIST_FILE" > "${FEATURE_LIST_FILE}.tmp"

mv "${FEATURE_LIST_FILE}.tmp" "$FEATURE_LIST_FILE"
echo "✓ Verification results updated"
```

---

### 6. Update Timestamps and Notes

**Add last_updated and implementation notes:**

```bash
echo ""
echo "Updating timestamps..."

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Update last_updated
jq --arg id "$SELECTED_FEATURE_ID" \
   --arg timestamp "$TIMESTAMP" \
   '(.features[] | select(.id == $id)) |= .last_updated = $timestamp' \
   "$FEATURE_LIST_FILE" > "${FEATURE_LIST_FILE}.tmp"

mv "${FEATURE_LIST_FILE}.tmp" "$FEATURE_LIST_FILE"

# Add implementation notes if failed
if [[ "$OVERALL_STATUS" == "fail" ]]; then
    IMPL_NOTE="Attempt $NEW_ATTEMPTS failed: $(IFS='; '; echo "${FAIL_REASONS[*]}")"

    jq --arg id "$SELECTED_FEATURE_ID" \
       --arg note "$IMPL_NOTE" \
       '(.features[] | select(.id == $id)) |= .implementation_notes = $note' \
       "$FEATURE_LIST_FILE" > "${FEATURE_LIST_FILE}.tmp"

    mv "${FEATURE_LIST_FILE}.tmp" "$FEATURE_LIST_FILE"
    echo "✓ Implementation notes added"
fi

echo "✓ Timestamps updated"
```

---

### 7. Validate Updated JSON

**Ensure file integrity:**

```bash
echo ""
echo "Validating updated feature_list.json..."

if jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then
    echo "✓ JSON is valid"

    # Verify feature was actually updated
    UPDATED_STATUS=$(jq -r --arg id "$SELECTED_FEATURE_ID" \
                     '.features[] | select(.id == $id) | .status' \
                     "$FEATURE_LIST_FILE")

    if [[ "$UPDATED_STATUS" == "$NEW_STATUS" ]]; then
        echo "✓ Feature update confirmed"

        # Remove backup
        rm -f "${FEATURE_LIST_FILE}.backup"
    else
        echo "❌ ERROR: Feature status not updated correctly"
        echo "   Expected: $NEW_STATUS"
        echo "   Found: $UPDATED_STATUS"
        mv "${FEATURE_LIST_FILE}.backup" "$FEATURE_LIST_FILE"
        exit 40
    fi
else
    echo "❌ ERROR: Updated JSON is invalid"
    echo "   Rolling back..."
    mv "${FEATURE_LIST_FILE}.backup" "$FEATURE_LIST_FILE"
    exit 41
fi

echo ""
```

---

### 8. Update claude-progress.txt Metadata

**Update feature counts in metadata header:**

```bash
PROGRESS_FILE="{progressFile}"

echo "Updating claude-progress.txt metadata..."

# Recalculate feature counts
PASS_COUNT=$(jq -r '.features[] | select(.status == "pass") | .id' "$FEATURE_LIST_FILE" | wc -l)
PENDING_COUNT=$(jq -r '.features[] | select(.status == "pending") | .id' "$FEATURE_LIST_FILE" | wc -l)
FAIL_COUNT=$(jq -r '.features[] | select(.status == "fail") | .id' "$FEATURE_LIST_FILE" | wc -l)
BLOCKED_COUNT=$(jq -r '.features[] | select(.status == "blocked") | .id' "$FEATURE_LIST_FILE" | wc -l)

# Update metadata header
sed -i "s/^features_completed=.*/features_completed=$PASS_COUNT/" "$PROGRESS_FILE"
sed -i "s/^features_pending=.*/features_pending=$PENDING_COUNT/" "$PROGRESS_FILE"
sed -i "s/^features_fail=.*/features_fail=$FAIL_COUNT/" "$PROGRESS_FILE"
sed -i "s/^features_blocked=.*/features_blocked=$BLOCKED_COUNT/" "$PROGRESS_FILE"
sed -i "s/^last_updated=.*/last_updated=$TIMESTAMP/" "$PROGRESS_FILE"

echo "✓ Progress metadata updated"
echo "  Pass: $PASS_COUNT, Pending: $PENDING_COUNT, Fail: $FAIL_COUNT, Blocked: $BLOCKED_COUNT"
```

---

### 9. Display Update Summary

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
        echo "   This feature will be blocked in next session (retry limit reached)"
    else
        echo "   Feature eligible for retry in next session"
    fi
fi)

Next: Commit changes to git
```

---

### 10. Proceed to Next Step

**Menu Handling Logic:**
- This step uses **Auto-proceed** (no menu)
- Tracking files updated successfully
- Next step will commit changes to git

**Execution:**

```
Proceeding to git commit...

→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- Backup created successfully
- Feature status updated (pass or fail)
- Attempts counter incremented
- Verification results stored (functional, technical, integration)
- Timestamps updated
- Implementation notes added (if failed)
- Updated JSON validated (syntax correct)
- Feature update confirmed (status matches expected)
- claude-progress.txt metadata updated (feature counts)
- Backup removed (update successful)
- Ready for step-12 (git commit)

### ❌ FAILURE:
- Backup creation failed (exit code 38)
- jq command failed (exit code 39)
- Feature status not updated correctly (exit code 40, rollback performed)
- Updated JSON invalid (exit code 41, rollback performed)

**Master Rule:** Tracking updates must be atomic and validated before proceeding.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
