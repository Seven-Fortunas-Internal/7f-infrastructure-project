---
name: 'step-06-initializer-complete'
description: 'Display Initializer completion summary and guide to Session 2'
featureListFile: '{project_folder}/feature_list.json'
progressFile: '{project_folder}/claude-progress.txt'
buildLogFile: '{project_folder}/autonomous_build_log.md'
initScriptFile: '{project_folder}/init.sh'
---

# Step 06: Initializer Complete

## STEP GOAL:
Display completion summary for Session 1 (Initializer), finalize tracking files, and provide clear instructions for starting Session 2 (Coding Agent).

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: Session Completion Handler
- ✅ Collaborative dialogue: None (final summary only)
- ✅ You bring: Status summary, next steps guidance
- ✅ User brings: Completed Initializer session

### Step-Specific:
- 🎯 Focus: Finalize Session 1, guide to Session 2
- 🚫 Forbidden: Starting Session 2 automatically
- 💬 Approach: Clear summary with actionable next steps

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Finalize progress tracking files
- 📖 This is a FINAL step (no nextStepFile)

---

## CONTEXT BOUNDARIES:
- Available: All created files (feature_list.json, progress files, init.sh)
- Focus: Session completion, next steps guidance
- Limits: Does not start Session 2 (user must do that)
- Dependencies: Requires all Initializer steps complete

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Completion Banner

```
═══════════════════════════════════════════════════════
  SESSION 1 COMPLETE: INITIALIZER
  Foundation Ready for Autonomous Implementation
═══════════════════════════════════════════════════════
```

---

### 2. Verify All Files Created

**Check that all expected files exist:**

```bash
FEATURE_LIST="{featureListFile}"
PROGRESS_FILE="{progressFile}"
BUILD_LOG="{buildLogFile}"
INIT_SCRIPT="{initScriptFile}"

echo "Verifying created files..."
echo ""

# Check each file
FILES_OK=true

if [[ -f "$FEATURE_LIST" ]]; then
    echo "✓ feature_list.json ($(du -h "$FEATURE_LIST" | cut -f1))"
else
    echo "❌ feature_list.json MISSING"
    FILES_OK=false
fi

if [[ -f "$PROGRESS_FILE" ]]; then
    echo "✓ claude-progress.txt ($(du -h "$PROGRESS_FILE" | cut -f1))"
else
    echo "❌ claude-progress.txt MISSING"
    FILES_OK=false
fi

if [[ -f "$BUILD_LOG" ]]; then
    echo "✓ autonomous_build_log.md ($(du -h "$BUILD_LOG" | cut -f1))"
else
    echo "❌ autonomous_build_log.md MISSING"
    FILES_OK=false
fi

if [[ -f "$INIT_SCRIPT" ]]; then
    echo "✓ init.sh ($(du -h "$INIT_SCRIPT" | cut -f1))"
    if [[ -x "$INIT_SCRIPT" ]]; then
        echo "  (executable)"
    else
        echo "  ⚠️  Not executable - run: chmod +x $INIT_SCRIPT"
    fi
else
    echo "❌ init.sh MISSING"
    FILES_OK=false
fi

echo ""

if [[ "$FILES_OK" != "true" ]]; then
    echo "⚠️  Some files are missing - Initializer may not have completed properly"
fi
```

---

### 3. Display Implementation Summary

**Show what was created:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  INITIALIZER SUMMARY"
echo "─────────────────────────────────────────────────────"
echo ""

# Feature statistics
if [[ -f "$FEATURE_LIST" ]]; then
    TOTAL_FEATURES=$(jq -r '.metadata.total_features' "$FEATURE_LIST")
    PROJECT_NAME=$(jq -r '.metadata.project_name' "$FEATURE_LIST")

    echo "Project: $PROJECT_NAME"
    echo "Features: $TOTAL_FEATURES"
    echo ""

    echo "Features by Category:"
    jq -r '.features | group_by(.category) | .[] | "  - \(.[0].category): \(length) features"' "$FEATURE_LIST"
    echo ""

    echo "Features by Status:"
    PENDING_COUNT=$(jq -r '.features[] | select(.status == "pending") | .id' "$FEATURE_LIST" | wc -l)
    echo "  - Pending: $PENDING_COUNT (all features)"
    echo ""

    # Check for dependencies
    DEPS_COUNT=$(jq -r '.features | map(select(.dependencies | length > 0)) | length' "$FEATURE_LIST")
    if [[ $DEPS_COUNT -gt 0 ]]; then
        echo "Dependencies:"
        echo "  - $DEPS_COUNT features have dependencies"
        echo "  - These will be implemented after their prerequisites"
    fi
fi
```

---

### 4. Finalize claude-progress.txt

**Update Session 1 log to COMPLETE:**

```bash
echo ""
echo "Finalizing progress tracking..."

# Update Session 1 log status
sed -i 's/Status: IN_PROGRESS/Status: COMPLETE/' "$PROGRESS_FILE"

# Update last_session_success to true
sed -i 's/^last_session_success=.*/last_session_success=true/' "$PROGRESS_FILE"

echo "✓ Session 1 status: COMPLETE"
```

---

### 5. Finalize autonomous_build_log.md

**Update Session 1 to complete:**

```bash
cat >> "$BUILD_LOG" <<EOF

### Session Status: COMPLETE

Session 1 (Initializer) completed successfully at $(date -u +%Y-%m-%d %H:%M:%S).

All foundation files created and verified:
- feature_list.json: $TOTAL_FEATURES features ready
- claude-progress.txt: Progress tracking initialized
- autonomous_build_log.md: Detailed logging active
- init.sh: Environment validation script ready

Next session will begin autonomous implementation.

---

EOF

echo "✓ Build log finalized"
```

---

### 6. Display Next Steps

```
─────────────────────────────────────────────────────
  NEXT STEPS: START SESSION 2 (CODING AGENT)
─────────────────────────────────────────────────────

The foundation is ready. To begin autonomous implementation:

1. **Review Generated Files** (optional but recommended)

   View feature list:
   cat $FEATURE_LIST | jq '.features[] | {id, name, category}'

   View progress:
   cat $PROGRESS_FILE

   View detailed log:
   tail -50 $BUILD_LOG

2. **Verify Environment** (optional)

   Run environment checks:
   bash $INIT_SCRIPT

3. **Start Session 2 (Coding Agent)**

   Run the workflow again to continue:
   /bmad-bmm-run-autonomous-implementation

   Session detection will automatically route to Coding Agent mode
   and begin implementing features from feature_list.json.

4. **Continue Sessions Until Complete**

   Each session will:
   - Load current state from feature_list.json
   - Select next pending feature
   - Implement → Test → Update → Commit
   - Loop until context fills up or all features complete

   Repeat Session N+1 until implementation is complete.

5. **Monitor Progress**

   Track progress in real-time:
   tail -f $BUILD_LOG

   Check circuit breaker status:
   grep '^consecutive_failures=' $PROGRESS_FILE

   View feature statuses:
   jq '.features[] | select(.status != "pending")' $FEATURE_LIST

─────────────────────────────────────────────────────
  IMPORTANT NOTES
─────────────────────────────────────────────────────

- **Session 2 is automatic:** Just run the workflow again
- **No manual intervention needed:** Coding Agent will detect state and continue
- **Circuit breaker protects you:** After 5 failed sessions, workflow stops
- **Progress is persistent:** State survives context resets
- **Each session is fresh:** New context, reads state from files
- **Commits preserve work:** Git commits after each feature

─────────────────────────────────────────────────────
```

---

### 7. Final Completion Message

```
═══════════════════════════════════════════════════════
  SESSION 1 (INITIALIZER) COMPLETE
═══════════════════════════════════════════════════════

✓ Foundation created successfully
✓ $TOTAL_FEATURES features ready for implementation
✓ Progress tracking initialized
✓ Environment setup complete

Ready to start Session 2 (Coding Agent).

Run: /bmad-bmm-run-autonomous-implementation

═══════════════════════════════════════════════════════
```

---

### 8. No Next Step (Final Step)

**This is a final step - workflow ends here.**

Session 1 (Initializer) is complete. User must manually start Session 2 by running the workflow again, which will automatically detect the existing feature_list.json and route to Coding Agent mode.

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- All created files verified (feature_list.json, progress files, init.sh)
- Feature statistics displayed
- Progress files finalized (Session 1 status = COMPLETE)
- Build log updated with completion entry
- Clear next steps provided
- User knows how to start Session 2

### ❌ FAILURE:
- Missing files detected (workflow steps may have failed)

**Master Rule:** Session 1 must be fully complete before Session 2 can start.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete (FINAL STEP for Initializer path)
