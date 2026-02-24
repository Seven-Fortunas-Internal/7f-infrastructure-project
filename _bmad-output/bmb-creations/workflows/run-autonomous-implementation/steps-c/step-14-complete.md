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

**Apply universal rules from project CLAUDE.md**

### Role:
- ✅ Role: Completion Handler (final summary)
- ✅ You bring: Statistics calculation, summary generation
- ✅ User brings: Completed implementation

### Step-Specific:
- 🎯 Focus: Comprehensive completion summary
- 🚫 Forbidden: Starting new work
- 💬 Approach: Clear summary with actionable next steps

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

### 2. Execute Completion Sequence

**Calculate statistics, display summary, finalize files:**

```bash
FEATURE_LIST_FILE="{featureListFile}"
PROGRESS_FILE="{progressFile}"
BUILD_LOG_FILE="{buildLogFile}"

# Extract statistics
TOTAL_FEATURES=$(jq -r '.metadata.total_features' "$FEATURE_LIST_FILE")
PROJECT_NAME=$(jq -r '.metadata.project_name' "$FEATURE_LIST_FILE")
GENERATED_DATE=$(jq -r '.metadata.generated_date' "$FEATURE_LIST_FILE")
PASS_COUNT=$(jq '[.features[] | select(.status == "pass")] | length' "$FEATURE_LIST_FILE")
BLOCKED_COUNT=$(jq '[.features[] | select(.status == "blocked")] | length' "$FEATURE_LIST_FILE")
FIRST_ATTEMPT=$(jq '[.features[] | select(.status == "pass" and .attempts == 1)] | length' "$FEATURE_LIST_FILE")
TOTAL_SESSIONS=$(grep '^session_count=' "$PROGRESS_FILE" | cut -d= -f2)
CONSECUTIVE_FAILURES=$(grep '^consecutive_failures=' "$PROGRESS_FILE" | cut -d= -f2)
COMPLETION_DATE=$(date -u +%Y-%m-%d)
COMMIT_COUNT=$(cd "{project_folder}" && git rev-list --count HEAD 2>/dev/null || echo "unknown")
SUCCESS_RATE=$(( PASS_COUNT * 100 / TOTAL_FEATURES ))

# Display summary
cat <<EOF

─────────────────────────────────────────────────────
  IMPLEMENTATION SUMMARY
─────────────────────────────────────────────────────

Project: $PROJECT_NAME
Started: $GENERATED_DATE | Completed: $COMPLETION_DATE
Sessions: $TOTAL_SESSIONS | Commits: $COMMIT_COUNT

Features ($TOTAL_FEATURES total):
  ✓ Pass: $PASS_COUNT ($SUCCESS_RATE%)
  🚫 Blocked: $BLOCKED_COUNT

Highlights:
  ✓ $FIRST_ATTEMPT features on first attempt
  $([ $CONSECUTIVE_FAILURES -eq 0 ] && echo "✓ No circuit breaker failures" || echo "⚠️  $CONSECUTIVE_FAILURES consecutive failures")

Completion by Category:
$(jq -r '.features | group_by(.category) | .[] | "\(.[0].category): \(map(select(.status == "pass")) | length)/\(length)"' "$FEATURE_LIST_FILE")

EOF

# Display blocked features
if [[ $BLOCKED_COUNT -gt 0 ]]; then
    echo "─────────────────────────────────────────────────────"
    echo "  BLOCKED FEATURES ($BLOCKED_COUNT)"
    echo "─────────────────────────────────────────────────────"
    echo ""
    jq -r '.features[] | select(.status == "blocked") | "- \(.id): \(.name) (\(.blocked_reason))"' "$FEATURE_LIST_FILE"
    echo ""
fi

# Finalize tracking files
sed -i "s/^circuit_breaker_status=.*/circuit_breaker_status=COMPLETE/" "$PROGRESS_FILE"
echo "" >> "$PROGRESS_FILE"
echo "## Implementation Complete ($(date -u +%Y-%m-%d %H:%M:%S))" >> "$PROGRESS_FILE"
echo "- Sessions: $TOTAL_SESSIONS | Pass: $PASS_COUNT/$TOTAL_FEATURES ($SUCCESS_RATE%) | Blocked: $BLOCKED_COUNT" >> "$PROGRESS_FILE"

cat >> "$BUILD_LOG_FILE" <<EOF

---

## Implementation Complete

**Date:** $(date -u +%Y-%m-%d) | **Duration:** $GENERATED_DATE to $COMPLETION_DATE | **Sessions:** $TOTAL_SESSIONS
**Features:** $PASS_COUNT/$TOTAL_FEATURES ($SUCCESS_RATE%) | **Blocked:** $BLOCKED_COUNT | **Commits:** $COMMIT_COUNT

$([ $BLOCKED_COUNT -gt 0 ] && echo "$BLOCKED_COUNT features blocked - may require manual intervention." || echo "All features completed successfully.")

---
**End of Autonomous Implementation Log**
EOF
```

---

### 3. Display Next Steps and Completion

```bash
cat <<EOF
─────────────────────────────────────────────────────
  NEXT STEPS
─────────────────────────────────────────────────────

$([ $BLOCKED_COUNT -gt 0 ] && echo "1. Review Blocked: jq '.features[] | select(.status == \"blocked\")' feature_list.json")
2. Review: git log --oneline
3. Test: Run integration tests, verify critical features
4. Deploy: Deploy to target environment, run E2E tests
5. Document: cp autonomous_build_log.md IMPLEMENTATION_LOG.md (optional)

═══════════════════════════════════════════════════════
  AUTONOMOUS IMPLEMENTATION COMPLETE
═══════════════════════════════════════════════════════

Project: $PROJECT_NAME | Status: ✅ COMPLETE

✓ $PASS_COUNT/$TOTAL_FEATURES features ($SUCCESS_RATE%)
✓ $TOTAL_SESSIONS sessions | $COMMIT_COUNT commits
$([ $BLOCKED_COUNT -gt 0 ] && echo "⚠️  $BLOCKED_COUNT features blocked")

Artifacts: feature_list.json, claude-progress.txt, autonomous_build_log.md, git history

═══════════════════════════════════════════════════════
EOF
```

---

### 4. No Next Step (Final Step)

**Workflow ends. Implementation complete.**

To continue: Retry blocked features (restart workflow) or add features (update app_spec.txt, regenerate feature_list.json).

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
Statistics displayed, progress finalized (COMPLETE), next steps shown.

### ❌ FAILURE:
(None - completion always succeeds)

**Master Rule:** Provide clear next steps for user.

---

**Step Version:** 1.0.0 | **Created:** 2026-02-17 | **Status:** FINAL STEP
