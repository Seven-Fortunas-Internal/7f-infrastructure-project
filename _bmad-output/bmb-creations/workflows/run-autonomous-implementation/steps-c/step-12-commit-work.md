---
name: 'step-12-commit-work'
description: 'Commit feature implementation and tracking updates to git'
nextStepFile: './step-13-check-completion.md'
featureListFile: '{project_folder}/feature_list.json'
progressFile: '{project_folder}/claude-progress.txt'
buildLogFile: '{project_folder}/autonomous_build_log.md'
gitStandardsFile: '{workflow_path}/../data/git-commit-standards.md'
---

# Step 12: Commit Work

## STEP GOAL:
Commit implemented feature and updated tracking files to git with descriptive message following standard format.

---

## EXECUTION RULES:

**Universal:** See `{workflow_path}/../data/universal-step-rules.md`

**Role:** Version Control Manager (git operations)

**Step-Specific:**
- 🎯 Commit changes with proper message format
- 🚫 Never commit without message, never push automatically
- 💬 Standard commit format with Co-Authored-By tag

**Protocols:**
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Commit all changes (implementation + tracking files)
- 📖 Use standard commit message format (see gitStandardsFile)

---

## CONTEXT BOUNDARIES:
- Available: Git repository, implemented feature, tracking files
- Focus: Git commit operation
- Limits: Does not push to remote (user decision)
- Dependencies: Requires tracking updates from step-11

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Commit Start

```
═══════════════════════════════════════════════════════
  COMMITTING TO GIT
  $SELECTED_FEATURE_ID: $FEATURE_NAME
═══════════════════════════════════════════════════════
```

---

### 2. Verify Git Repository

```bash
PROJECT_FOLDER="{project_folder}"
cd "$PROJECT_FOLDER" || exit 42

[[ ! -d ".git" ]] && { echo "❌ ERROR: Not a git repository"; exit 42; }
echo "✓ In git repository: $PROJECT_FOLDER"
```

---

### 3. Check and Stage Changes

```bash
echo "Checking git status..."
git status --short
CHANGED_FILES=$(git status --short | wc -l)

[[ $CHANGED_FILES -eq 0 ]] && echo "⚠️  No changes to commit (tracking files only?)"
echo "Files to commit: $CHANGED_FILES"

git add -A || { echo "❌ ERROR: git add failed"; exit 43; }
echo "✓ Changes staged"
```

---

### 4. Build Commit Message

**Format:** `{type}({feature_id}): {short_desc}`

See `{gitStandardsFile}` for full standards.

```bash
# Determine type and description
if [[ "$OVERALL_STATUS" == "pass" ]]; then
    COMMIT_TYPE="feat"
    SHORT_DESC="$FEATURE_NAME"
    DETAILS="Implemented and verified feature.

Verification results:
- Functional: $FUNCTIONAL_RESULT
- Technical: $TECHNICAL_RESULT
- Integration: $INTEGRATION_RESULT"
else
    COMMIT_TYPE="fix"
    SHORT_DESC="$FEATURE_NAME (attempt $NEW_ATTEMPTS)"
    DETAILS="Implementation attempt $NEW_ATTEMPTS failed.

Failure reasons:"
    for reason in "${FAIL_REASONS[@]}"; do
        DETAILS="$DETAILS
- $reason"
    done
    DETAILS="$DETAILS

$([[ $NEW_ATTEMPTS -lt 3 ]] && echo "Feature will retry in next session." || echo "Feature will be blocked (retry limit reached).")"
fi

# Build message
COMMIT_MESSAGE="$COMMIT_TYPE($SELECTED_FEATURE_ID): $SHORT_DESC

$DETAILS

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

echo "✓ Commit message prepared"
```

---

### 5. Display and Execute Commit

```bash
echo "─────────────────────────────────────────────────────"
echo "  COMMIT MESSAGE"
echo "─────────────────────────────────────────────────────"
echo "$COMMIT_MESSAGE"
echo "─────────────────────────────────────────────────────"

# Commit
git commit -m "$COMMIT_MESSAGE" || {
    git diff --cached --quiet && {
        echo "⚠️  No changes staged (expected if only tracking files changed)"
    } || exit 44
}

COMMIT_HASH=$(git rev-parse --short HEAD)
echo "✓ Commit created: $COMMIT_HASH"
```

---

### 6. Verify and Log Commit

```bash
LAST_COMMIT=$(git log -1 --oneline)
echo "✓ Last commit: $LAST_COMMIT"

# Log to build log
BUILD_LOG_FILE="{buildLogFile}"
cat >> "$BUILD_LOG_FILE" <<EOF

#### Git Commit

**Commit Hash:** $COMMIT_HASH
**Type:** $COMMIT_TYPE
**Feature:** $SELECTED_FEATURE_ID
**Status:** $OVERALL_STATUS
**Message:**
\`\`\`
$COMMIT_MESSAGE
\`\`\`

EOF

echo "✓ Commit logged to build log"
```

---

### 7. Display Commit Summary

```
─────────────────────────────────────────────────────
  COMMIT COMPLETE
─────────────────────────────────────────────────────

Feature: $SELECTED_FEATURE_ID
Status: $OVERALL_STATUS
Commit: $COMMIT_HASH

Changes Committed:
  - Implementation files/code
  - feature_list.json (status updated)
  - claude-progress.txt (metadata updated)
  - autonomous_build_log.md (actions logged)

$([[ "$OVERALL_STATUS" == "pass" ]] && echo "✓ Feature implementation persisted" || echo "⚠️  Failed attempt persisted (for retry analysis)")

Note: Changes committed locally only (not pushed to remote)

Next: Check completion status and determine next action
```

---

### 8. Proceed to Next Step

**Auto-proceed** (no menu). Changes committed to git. Next step determines loop/complete/circuit breaker.

```
Proceeding to completion check...

→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- In correct git repository
- All changes staged and committed
- Commit message follows standard format
- Commit logged to build log
- Ready for step-13 (completion check)

### ❌ FAILURE:
- Not a git repository (exit code 42)
- git add failed (exit code 43)
- git commit failed (exit code 44, unless no changes)

**Master Rule:** All feature work must be committed to git before proceeding.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
