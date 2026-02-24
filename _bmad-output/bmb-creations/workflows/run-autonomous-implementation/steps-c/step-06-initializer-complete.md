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

## EXECUTION RULES:

**Universal:** See Global CLAUDE.md - Standard workflow execution rules apply.

**Role:** Session Completion Handler - Summarize Session 1, guide to Session 2
**Focus:** Finalize Session 1, clear next steps
**Forbidden:** Starting Session 2 automatically

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

FILES_OK=true

[[ -f "$FEATURE_LIST" ]] && echo "✓ feature_list.json ($(du -h "$FEATURE_LIST" | cut -f1))" || { echo "❌ feature_list.json MISSING"; FILES_OK=false; }
[[ -f "$PROGRESS_FILE" ]] && echo "✓ claude-progress.txt ($(du -h "$PROGRESS_FILE" | cut -f1))" || { echo "❌ claude-progress.txt MISSING"; FILES_OK=false; }
[[ -f "$BUILD_LOG" ]] && echo "✓ autonomous_build_log.md ($(du -h "$BUILD_LOG" | cut -f1))" || { echo "❌ autonomous_build_log.md MISSING"; FILES_OK=false; }

if [[ -f "$INIT_SCRIPT" ]]; then
    echo "✓ init.sh ($(du -h "$INIT_SCRIPT" | cut -f1))"
    [[ -x "$INIT_SCRIPT" ]] && echo "  (executable)" || echo "  ⚠️  Not executable - run: chmod +x $INIT_SCRIPT"
else
    echo "❌ init.sh MISSING"
    FILES_OK=false
fi

[[ "$FILES_OK" != "true" ]] && echo "⚠️  Some files are missing - Initializer may not have completed properly"
```

---

### 3. Display Implementation Summary

```bash
echo "─────────────────────────────────────────────────────"
echo "  INITIALIZER SUMMARY"
echo "─────────────────────────────────────────────────────"
echo ""

if [[ -f "$FEATURE_LIST" ]]; then
    TOTAL_FEATURES=$(jq -r '.metadata.total_features' "$FEATURE_LIST")
    PROJECT_NAME=$(jq -r '.metadata.project_name' "$FEATURE_LIST")

    echo "Project: $PROJECT_NAME"
    echo "Features: $TOTAL_FEATURES"
    echo ""

    echo "Features by Category:"
    jq -r '.features | group_by(.category) | .[] | "  - \(.[0].category): \(length) features"' "$FEATURE_LIST"
    echo ""

    echo "Status: All features pending (ready for Session 2)"

    DEPS_COUNT=$(jq -r '.features | map(select(.dependencies | length > 0)) | length' "$FEATURE_LIST")
    [[ $DEPS_COUNT -gt 0 ]] && echo "Dependencies: $DEPS_COUNT features have dependencies (will be ordered automatically)"
fi
```

---

### 4. Finalize Tracking Files

```bash
echo ""
echo "Finalizing progress tracking..."

# Update Session 1 status and success flag
sed -i 's/Status: IN_PROGRESS/Status: COMPLETE/' "$PROGRESS_FILE"
sed -i 's/^last_session_success=.*/last_session_success=true/' "$PROGRESS_FILE"

# Append completion entry to build log
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

echo "✓ Session 1 status: COMPLETE"
echo "✓ Tracking files finalized"
```

---

### 5. Display Next Steps

```
─────────────────────────────────────────────────────
  NEXT STEPS: START SESSION 2 (CODING AGENT)
─────────────────────────────────────────────────────

The foundation is ready. To begin autonomous implementation:

1. **Start Session 2 (Coding Agent)**

   Run the workflow again:
   /bmad-bmm-run-autonomous-implementation

   Session detection will automatically route to Coding Agent mode
   and begin implementing features from feature_list.json.

2. **Continue Sessions Until Complete**

   Each session will:
   - Load state from feature_list.json
   - Select next pending feature
   - Implement → Test → Update → Commit
   - Loop until context fills up or all features complete

   Repeat Session N+1 until all features complete.

3. **Monitor Progress (Optional)**

   Track progress:
   tail -f $BUILD_LOG

   Check feature statuses:
   jq '.features[] | {id, name, status}' $FEATURE_LIST

   View circuit breaker status:
   grep '^consecutive_failures=' $PROGRESS_FILE

─────────────────────────────────────────────────────
  KEY NOTES
─────────────────────────────────────────────────────

- Session 2 is automatic: Just run the workflow again
- No manual intervention needed: Coding Agent detects state
- Circuit breaker protects: After 5 failed sessions, stops
- Progress is persistent: State survives context resets
- Commits preserve work: Git commits after each feature

─────────────────────────────────────────────────────
```

---

### 6. Final Completion Message

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

### 7. No Next Step (Final Step)

**This is a final step - workflow ends here.**

Session 1 (Initializer) is complete. User must manually start Session 2 by running the workflow again, which will automatically detect the existing feature_list.json and route to Coding Agent mode.

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- All created files verified
- Feature statistics displayed
- Progress files finalized (Session 1 status = COMPLETE)
- Clear next steps provided

### ❌ FAILURE:
- Missing files detected (workflow steps may have failed)

**Master Rule:** Session 1 must be fully complete before Session 2 can start.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete (FINAL STEP for Initializer path)
