---
name: 'step-04-complete'
description: 'Exit EDIT mode with summary of changes made'
---

# Step 04: Complete EDIT Mode

## STEP GOAL:
Display summary of all edits made during EDIT mode session and exit cleanly.

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: Session Closer (summary and exit)
- ✅ Collaborative dialogue: None (final summary only)
- ✅ You bring: Summary generation
- ✅ User brings: Completed editing session

### Step-Specific:
- 🎯 Focus: Clear exit summary
- 🚫 Forbidden: Making additional changes
- 💬 Approach: Confirm changes saved, provide next steps

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Verify all changes persisted
- 📖 This is a FINAL step (no nextStepFile)

---

## CONTEXT BOUNDARIES:
- Available: All tracking files (read-only)
- Focus: Exit confirmation
- Limits: No modifications in this step
- Dependencies: None (can exit from any EDIT step)

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Completion Banner

```
═══════════════════════════════════════════════════════
  EDIT MODE COMPLETE
  All Changes Saved Successfully
═══════════════════════════════════════════════════════
```

---

### 2. Verify File Integrity

**Final validation check:**

```bash
FEATURE_LIST_FILE="{project_folder}/feature_list.json"
PROGRESS_FILE="{project_folder}/claude-progress.txt"

echo ""
echo "Verifying file integrity..."

# Verify feature_list.json is valid JSON
if ! jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then
    echo "❌ WARNING: feature_list.json may be corrupted"
    echo "   Recommend restoring from backup if available"
else
    echo "✓ feature_list.json is valid"
fi

# Verify progress file exists
if [[ -f "$PROGRESS_FILE" ]]; then
    echo "✓ claude-progress.txt exists"
else
    echo "⚠️  WARNING: claude-progress.txt not found"
fi

echo ""
```

---

### 3. Display Current State Summary

**Show final state after edits:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CURRENT IMPLEMENTATION STATE"
echo "─────────────────────────────────────────────────────"
echo ""

# Feature counts
PASS_COUNT=$(jq -r '.features[] | select(.status == "pass") | .id' "$FEATURE_LIST_FILE" 2>/dev/null | wc -l)
PENDING_COUNT=$(jq -r '.features[] | select(.status == "pending") | .id' "$FEATURE_LIST_FILE" 2>/dev/null | wc -l)
FAIL_COUNT=$(jq -r '.features[] | select(.status == "fail") | .id' "$FEATURE_LIST_FILE" 2>/dev/null | wc -l)
BLOCKED_COUNT=$(jq -r '.features[] | select(.status == "blocked") | .id' "$FEATURE_LIST_FILE" 2>/dev/null | wc -l)
TOTAL_FEATURES=$(jq -r '.metadata.total_features' "$FEATURE_LIST_FILE" 2>/dev/null)

# Circuit breaker
CONSECUTIVE_FAILURES=$(grep '^consecutive_failures=' "$PROGRESS_FILE" 2>/dev/null | cut -d= -f2)
THRESHOLD=$(grep '^circuit_breaker_threshold=' "$PROGRESS_FILE" 2>/dev/null | cut -d= -f2)
CB_STATUS=$(grep '^circuit_breaker_status=' "$PROGRESS_FILE" 2>/dev/null | cut -d= -f2)

# Defaults
CONSECUTIVE_FAILURES=${CONSECUTIVE_FAILURES:-0}
THRESHOLD=${THRESHOLD:-5}
CB_STATUS=${CB_STATUS:-UNKNOWN}

echo "Features ($TOTAL_FEATURES total):"
echo "  ✓ Pass:    $PASS_COUNT"
echo "  ⏳ Pending: $PENDING_COUNT"
echo "  ❌ Fail:    $FAIL_COUNT"
echo "  🚫 Blocked: $BLOCKED_COUNT"
echo ""
echo "Circuit Breaker:"
echo "  Status: $(if [[ "$CB_STATUS" == "TRIGGERED" ]]; then echo "🔴 TRIGGERED"; else echo "✓ $CB_STATUS"; fi)"
echo "  Consecutive Failures: $CONSECUTIVE_FAILURES / $THRESHOLD"
echo ""
```

---

### 4. Display Modified Files

```
─────────────────────────────────────────────────────
  MODIFIED FILES
─────────────────────────────────────────────────────

The following files may have been modified during this EDIT session:

  ✓ feature_list.json
    - Feature statuses, attempts, blocked reasons

  ✓ claude-progress.txt
    - Feature counts, circuit breaker state, metadata

All changes have been saved to disk.
```

---

### 5. Display Next Steps

```
─────────────────────────────────────────────────────
  NEXT STEPS
─────────────────────────────────────────────────────

$(if [[ $CONSECUTIVE_FAILURES -eq 0 && $PENDING_COUNT -gt 0 ]]; then
    cat <<'NEXTEOF'
✓ Ready to resume implementation

To continue autonomous implementation:
  /bmad-bmm-run-autonomous-implementation

The workflow will automatically detect existing state
and resume from where it left off.

NEXTEOF
elif [[ "$CB_STATUS" == "TRIGGERED" ]]; then
    cat <<'NEXTEOF'
⚠️  Circuit breaker is still TRIGGERED

Before resuming implementation:
1. Review blocked/failed features in feature_list.json
2. Fix external dependencies or issues causing failures
3. Use EDIT mode to reset circuit breaker:
   /bmad-bmm-run-autonomous-implementation --mode=edit
   Select [C] Circuit Breaker, then [A] Reset All

NEXTEOF
elif [[ $PENDING_COUNT -eq 0 && $FAIL_COUNT -eq 0 ]]; then
    cat <<'NEXTEOF'
✓ All actionable work complete

Options:
- Review git history: git log --oneline
- Test implementation
- Deploy to target environment
- Generate documentation

NEXTEOF
else
    cat <<'NEXTEOF'
📊 Review implementation state

Options:
1. **Resume Implementation:**
   /bmad-bmm-run-autonomous-implementation

2. **Validate Current State:**
   /bmad-bmm-run-autonomous-implementation --mode=validate

3. **Make More Edits:**
   /bmad-bmm-run-autonomous-implementation --mode=edit

4. **Review Tracking Files:**
   - feature_list.json (feature status details)
   - claude-progress.txt (session history)
   - autonomous_build_log.md (detailed logs)

NEXTEOF
fi)

─────────────────────────────────────────────────────
```

---

### 6. Display Final Exit Message

```
═══════════════════════════════════════════════════════
  EDIT MODE EXIT
═══════════════════════════════════════════════════════

All edits have been saved successfully.

$(if [[ $CONSECUTIVE_FAILURES -eq 0 ]]; then
    echo "✓ Circuit breaker is healthy"
    echo "✓ Ready to resume autonomous implementation"
else
    echo "⚠️  Circuit breaker: $CONSECUTIVE_FAILURES consecutive failure(s)"
fi)

Thank you for using EDIT mode.

═══════════════════════════════════════════════════════
```

---

### 7. No Next Step (Final Step)

**This is a final step - workflow ends here.**

EDIT mode is complete. User can:
- Run CREATE mode to resume implementation
- Run VALIDATE mode to check state
- Run EDIT mode again to make more changes
- Exit workflow entirely

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- File integrity verified (JSON valid)
- Current state summary displayed
- Modified files listed
- Next steps provided based on current state
- Final exit message displayed
- Clean exit from EDIT mode

### ❌ FAILURE:
- (None - completion always succeeds)
- Warnings displayed if files corrupted, but step completes

**Master Rule:** EDIT mode must exit cleanly with clear guidance for next actions.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete (FINAL STEP for EDIT mode)
