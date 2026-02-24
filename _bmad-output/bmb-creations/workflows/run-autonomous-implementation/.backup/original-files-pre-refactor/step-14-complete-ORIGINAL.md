---
name: 'step-14-complete'
description: 'Display implementation completion summary and final statistics'
featureListFile: '{project_folder}/feature_list.json'
progressFile: '{project_folder}/claude-progress.txt'
buildLogFile: '{project_folder}/autonomous_build_log.md'
---

# Step 14: Implementation Complete

## STEP GOAL:
Display final completion summary, statistics, and next steps for the completed autonomous implementation.

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: Completion Handler (final summary)
- ✅ Collaborative dialogue: None (final summary only)
- ✅ You bring: Statistics calculation, summary generation
- ✅ User brings: Completed implementation

### Step-Specific:
- 🎯 Focus: Comprehensive completion summary
- 🚫 Forbidden: Starting new work
- 💬 Approach: Clear summary with actionable next steps

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Finalize tracking files
- 📖 This is a FINAL step (no nextStepFile)

---

## CONTEXT BOUNDARIES:
- Available: All tracking files (feature_list.json, progress files)
- Focus: Final summary and next steps
- Limits: Does not start new sessions
- Dependencies: Requires all features complete or blocked

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Completion Banner

```
═══════════════════════════════════════════════════════
  AUTONOMOUS IMPLEMENTATION COMPLETE
  All Features Implemented Successfully
═══════════════════════════════════════════════════════
```

---

### 2. Load Final State

**Read complete implementation statistics:**

```bash
FEATURE_LIST_FILE="{featureListFile}"
PROGRESS_FILE="{progressFile}"
BUILD_LOG_FILE="{buildLogFile}"

echo ""
echo "Loading final state..."

# Feature statistics
TOTAL_FEATURES=$(jq -r '.metadata.total_features' "$FEATURE_LIST_FILE")
PROJECT_NAME=$(jq -r '.metadata.project_name' "$FEATURE_LIST_FILE")
PASS_COUNT=$(jq -r '.features[] | select(.status == "pass") | .id' "$FEATURE_LIST_FILE" | wc -l)
PENDING_COUNT=$(jq -r '.features[] | select(.status == "pending") | .id' "$FEATURE_LIST_FILE" | wc -l)
FAIL_COUNT=$(jq -r '.features[] | select(.status == "fail") | .id' "$FEATURE_LIST_FILE" | wc -l)
BLOCKED_COUNT=$(jq -r '.features[] | select(.status == "blocked") | .id' "$FEATURE_LIST_FILE" | wc -l)

# Session statistics
TOTAL_SESSIONS=$(grep '^session_count=' "$PROGRESS_FILE" | cut -d= -f2)
CONSECUTIVE_FAILURES=$(grep '^consecutive_failures=' "$PROGRESS_FILE" | cut -d= -f2)

# Time statistics
GENERATED_DATE=$(jq -r '.metadata.generated_date' "$FEATURE_LIST_FILE")
COMPLETION_DATE=$(date -u +%Y-%m-%d)

echo "✓ Statistics calculated"
echo ""
```

---

### 3. Display Implementation Summary

```
─────────────────────────────────────────────────────
  IMPLEMENTATION SUMMARY
─────────────────────────────────────────────────────

Project: $PROJECT_NAME
Started: $GENERATED_DATE
Completed: $COMPLETION_DATE
Total Sessions: $TOTAL_SESSIONS

Feature Statistics ($TOTAL_FEATURES total):
  ✓ Pass:    $PASS_COUNT ($(( PASS_COUNT * 100 / TOTAL_FEATURES ))%)
  ⏳ Pending: $PENDING_COUNT ($(( PENDING_COUNT * 100 / TOTAL_FEATURES ))%)
  ❌ Fail:    $FAIL_COUNT ($(( FAIL_COUNT * 100 / TOTAL_FEATURES ))%)
  🚫 Blocked: $BLOCKED_COUNT ($(( BLOCKED_COUNT * 100 / TOTAL_FEATURES ))%)

Implementation Success Rate: $(( PASS_COUNT * 100 / TOTAL_FEATURES ))%
```

---

### 4. Display Features by Category

**Show completion by domain:**

```bash
echo ""
echo "Completion by Category:"
echo ""

jq -r '.features | group_by(.category) | .[] |
    "\(.[0].category):\n  Total: \(length)\n  Pass: \(map(select(.status == \"pass\")) | length)\n  Blocked: \(map(select(.status == \"blocked\")) | length)"' \
    "$FEATURE_LIST_FILE"

echo ""
```

---

### 5. Display Blocked Features (if any)

**Show what couldn't be completed:**

```bash
if [[ $BLOCKED_COUNT -gt 0 ]]; then
    echo "─────────────────────────────────────────────────────"
    echo "  BLOCKED FEATURES ($BLOCKED_COUNT)"
    echo "─────────────────────────────────────────────────────"
    echo ""
    echo "These features could not be completed automatically:"
    echo ""

    jq -r '.features[] | select(.status == "blocked") |
        "- **\(.id)**: \(.name)\n  Category: \(.category)\n  Reason: \(.blocked_reason)\n  Attempts: \(.attempts)\n"' \
        "$FEATURE_LIST_FILE"

    echo ""
    echo "These may require manual implementation or fixing external dependencies."
    echo ""
fi
```

---

### 6. Display Implementation Highlights

**Show notable achievements:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  IMPLEMENTATION HIGHLIGHTS"
echo "─────────────────────────────────────────────────────"
echo ""

# Features completed on first attempt
FIRST_ATTEMPT=$(jq -r '.features[] | select(.status == "pass" and .attempts == 1) | .id' "$FEATURE_LIST_FILE" | wc -l)
echo "✓ $FIRST_ATTEMPT features completed on first attempt"

# Features that required retry
RETRY_SUCCESS=$(jq -r '.features[] | select(.status == "pass" and .attempts > 1) | .id' "$FEATURE_LIST_FILE" | wc -l)
if [[ $RETRY_SUCCESS -gt 0 ]]; then
    echo "✓ $RETRY_SUCCESS features succeeded after retry"
fi

# Circuit breaker status
if [[ $CONSECUTIVE_FAILURES -eq 0 ]]; then
    echo "✓ No circuit breaker failures (smooth implementation)"
else
    echo "⚠️  $CONSECUTIVE_FAILURES consecutive failure(s) at completion"
fi

# Total commits
COMMIT_COUNT=$(cd "{project_folder}" && git rev-list --count HEAD 2>/dev/null || echo "unknown")
echo "✓ $COMMIT_COUNT git commits created"

echo ""
```

---

### 7. Finalize Progress Files

**Mark implementation complete:**

```bash
echo "Finalizing tracking files..."

# Update progress file
sed -i "s/^circuit_breaker_status=.*/circuit_breaker_status=COMPLETE/" "$PROGRESS_FILE"

# Add completion log to progress file
cat >> "$PROGRESS_FILE" <<EOF

## Implementation Complete ($(date -u +%Y-%m-%d %H:%M:%S))
- Total sessions: $TOTAL_SESSIONS
- Features completed: $PASS_COUNT/$TOTAL_FEATURES ($(( PASS_COUNT * 100 / TOTAL_FEATURES ))%)
- Blocked features: $BLOCKED_COUNT
- Status: COMPLETE
EOF

# Add completion entry to build log
cat >> "$BUILD_LOG_FILE" <<EOF

---

## Implementation Complete

**Completion Date:** $(date -u +%Y-%m-%d %H:%M:%S)
**Total Duration:** $GENERATED_DATE to $COMPLETION_DATE
**Total Sessions:** $TOTAL_SESSIONS

### Final Statistics

- **Features Implemented:** $PASS_COUNT/$TOTAL_FEATURES ($(( PASS_COUNT * 100 / TOTAL_FEATURES ))%)
- **Blocked Features:** $BLOCKED_COUNT
- **Circuit Breaker Failures:** $CONSECUTIVE_FAILURES
- **Git Commits:** $COMMIT_COUNT

### Status

Implementation workflow completed successfully.

$(if [[ $BLOCKED_COUNT -gt 0 ]]; then
    echo "$BLOCKED_COUNT features remain blocked and may require manual intervention."
else
    echo "All features completed successfully."
fi)

---

**End of Autonomous Implementation Log**

EOF

echo "✓ Tracking files finalized"
echo ""
```

---

### 8. Display Next Steps

```
─────────────────────────────────────────────────────
  NEXT STEPS
─────────────────────────────────────────────────────

$(if [[ $BLOCKED_COUNT -gt 0 ]]; then
    cat <<'NEXTEOF'
1. **Review Blocked Features**

   View details:
   jq '.features[] | select(.status == "blocked")' feature_list.json

   Options:
   - Manually implement blocked features
   - Fix external dependencies and use EDIT mode to reset
   - Accept current state as complete

NEXTEOF
fi)

2. **Review Implementation**

   Check git history:
   git log --oneline

   View recent commits:
   git log -10 --stat

   Review specific feature:
   git show <commit-hash>

3. **Test Implemented Features**

   Run integration tests (if applicable)
   Manually verify critical features
   Check verification criteria were met

4. **Deploy or Use Implementation**

   $(if [[ "$PROJECT_NAME" =~ "Infrastructure" ]]; then
       echo "Deploy infrastructure to target environment"
       echo "Verify all services are operational"
   else
       echo "Deploy application to target environment"
       echo "Run end-to-end tests"
   fi)

5. **Generate Documentation (optional)**

   Create README with implementation summary:
   cp autonomous_build_log.md IMPLEMENTATION_LOG.md

   Document any manual steps needed:
   - Blocked features requiring attention
   - Configuration that needs customization
   - Credentials/secrets to be added

─────────────────────────────────────────────────────
```

---

### 9. Display Final Completion Message

```
═══════════════════════════════════════════════════════
  AUTONOMOUS IMPLEMENTATION COMPLETE
═══════════════════════════════════════════════════════

Project: $PROJECT_NAME
Status: ✅ COMPLETE

✓ $PASS_COUNT/$TOTAL_FEATURES features implemented ($(( PASS_COUNT * 100 / TOTAL_FEATURES ))%)
✓ $TOTAL_SESSIONS sessions executed
✓ $COMMIT_COUNT commits created
$(if [[ $BLOCKED_COUNT -gt 0 ]]; then echo "⚠️  $BLOCKED_COUNT features blocked (manual attention needed)"; fi)

Implementation artifacts:
  - feature_list.json (final status)
  - claude-progress.txt (session history)
  - autonomous_build_log.md (detailed log)
  - Git history (all commits)

Thank you for using autonomous implementation workflow!

═══════════════════════════════════════════════════════
```

---

### 10. No Next Step (Final Step)

**This is a final step - workflow ends here.**

Implementation is complete. No further autonomous sessions needed unless:
- User wants to retry blocked features (restart workflow)
- User wants to implement additional features (add to app_spec.txt, regenerate feature_list.json)

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- Final statistics calculated
- Implementation summary displayed
- Features by category shown
- Blocked features listed (if any)
- Implementation highlights shown
- Progress files finalized (marked COMPLETE)
- Next steps provided
- Final completion message displayed

### ❌ FAILURE:
- (None - completion summary always succeeds)

**Master Rule:** Completion summary must provide clear next steps for user.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete (FINAL STEP for entire workflow)
