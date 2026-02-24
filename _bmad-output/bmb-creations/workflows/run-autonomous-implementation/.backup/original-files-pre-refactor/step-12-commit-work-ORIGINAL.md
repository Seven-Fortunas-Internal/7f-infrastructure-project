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

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: Version Control Manager (git operations)
- ✅ Collaborative dialogue: None (automated commit)
- ✅ You bring: Git commit logic, message formatting
- ✅ User brings: Implemented and tested feature

### Step-Specific:
- 🎯 Focus: Commit changes with proper message format
- 🚫 Forbidden: Committing without message, pushing to remote automatically
- 💬 Approach: Standard commit format with Co-Authored-By tag

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Commit all changes (implementation + tracking files)
- 📖 Use standard commit message format

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

### 2. Change to Project Directory

**Ensure we're in the correct git repository:**

```bash
PROJECT_FOLDER="{project_folder}"

echo ""
echo "Changing to project directory..."
cd "$PROJECT_FOLDER"

if [[ ! -d ".git" ]]; then
    echo "❌ ERROR: Not a git repository"
    echo "   Directory: $PROJECT_FOLDER"
    exit 42
fi

echo "✓ In git repository: $PROJECT_FOLDER"
echo ""
```

---

### 3. Check Git Status

**See what changes will be committed:**

```bash
echo "Checking git status..."
echo ""

git status --short

echo ""

# Count changes
CHANGED_FILES=$(git status --short | wc -l)

if [[ $CHANGED_FILES -eq 0 ]]; then
    echo "⚠️  No changes to commit"
    echo "   This may indicate implementation didn't create/modify files."
    echo "   Proceeding anyway (tracking files may have changed)."
fi

echo "Files to commit: $CHANGED_FILES"
echo ""
```

---

### 4. Stage All Changes

**Add all modified/new files:**

```bash
echo "Staging changes..."

# Stage all changes (implementation + tracking files)
git add -A

if [[ $? -eq 0 ]]; then
    echo "✓ Changes staged"
else
    echo "❌ ERROR: git add failed"
    exit 43
fi

echo ""
```

---

### 5. Build Commit Message

**Follow standard format:**

```bash
echo "Building commit message..."

# Determine commit type
if [[ "$OVERALL_STATUS" == "pass" ]]; then
    COMMIT_TYPE="feat"
    SHORT_DESC="$FEATURE_NAME"
else
    COMMIT_TYPE="fix"
    SHORT_DESC="$FEATURE_NAME (attempt $NEW_ATTEMPTS)"
fi

# Build detailed message
COMMIT_MESSAGE=$(cat <<EOF
$COMMIT_TYPE($SELECTED_FEATURE_ID): $SHORT_DESC

$(if [[ "$OVERALL_STATUS" == "pass" ]]; then
    echo "Implemented and verified feature."
    echo ""
    echo "Verification results:"
    echo "- Functional: $FUNCTIONAL_RESULT"
    echo "- Technical: $TECHNICAL_RESULT"
    echo "- Integration: $INTEGRATION_RESULT"
else
    echo "Implementation attempt $NEW_ATTEMPTS failed."
    echo ""
    echo "Failure reasons:"
    for reason in "${FAIL_REASONS[@]}"; do
        echo "- $reason"
    done
    echo ""
    if [[ $NEW_ATTEMPTS -lt 3 ]]; then
        echo "Feature will retry in next session."
    else
        echo "Feature will be blocked (retry limit reached)."
    fi
fi)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)

echo "✓ Commit message prepared"
echo ""
```

---

### 6. Display Commit Message

**Show what will be committed:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  COMMIT MESSAGE"
echo "─────────────────────────────────────────────────────"
echo ""
echo "$COMMIT_MESSAGE"
echo ""
echo "─────────────────────────────────────────────────────"
echo ""
```

---

### 7. Execute Commit

**Create the commit:**

```bash
echo "Creating commit..."

# Use heredoc to handle multiline message properly
git commit -m "$(cat <<'COMMITEOF'
$COMMIT_MESSAGE
COMMITEOF
)"

if [[ $? -eq 0 ]]; then
    # Get commit hash
    COMMIT_HASH=$(git rev-parse --short HEAD)
    echo "✓ Commit created: $COMMIT_HASH"
else
    echo "❌ ERROR: git commit failed"

    # Check if it's because there's nothing to commit
    if git diff --cached --quiet; then
        echo "   Reason: No changes staged"
        echo "   This may be expected if only tracking files changed."
        echo "   Continuing anyway..."
    else
        exit 44
    fi
fi

echo ""
```

---

### 8. Verify Commit

**Confirm commit was created:**

```bash
echo "Verifying commit..."

# Show last commit
LAST_COMMIT=$(git log -1 --oneline)

if [[ -n "$LAST_COMMIT" ]]; then
    echo "✓ Last commit: $LAST_COMMIT"
else
    echo "⚠️  Could not verify commit"
fi

echo ""
```

---

### 9. Log Commit to Build Log

**Record commit in tracking:**

```bash
BUILD_LOG_FILE="{buildLogFile}"

cat >> "$BUILD_LOG_FILE" <<EOF

#### Git Commit

**Commit Hash:** $(git rev-parse --short HEAD 2>/dev/null || echo "N/A")
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

### 10. Display Commit Summary

```
─────────────────────────────────────────────────────
  COMMIT COMPLETE
─────────────────────────────────────────────────────

Feature: $SELECTED_FEATURE_ID
Status: $OVERALL_STATUS
Commit: $(git rev-parse --short HEAD 2>/dev/null || echo "N/A")

Changes Committed:
  - Implementation files/code
  - feature_list.json (status updated)
  - claude-progress.txt (metadata updated)
  - autonomous_build_log.md (actions logged)

$(if [[ "$OVERALL_STATUS" == "pass" ]]; then
    echo "✓ Feature implementation persisted"
else
    echo "⚠️  Failed attempt persisted (for retry analysis)"
fi)

Note: Changes committed locally only (not pushed to remote)

Next: Check completion status and determine next action
```

---

### 11. Proceed to Next Step

**Menu Handling Logic:**
- This step uses **Auto-proceed** (no menu)
- Changes committed to git
- Next step will determine loop/complete/circuit breaker

**Execution:**

```
Proceeding to completion check...

→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- In correct git repository
- Changes detected (or no changes acceptable)
- All changes staged (git add -A)
- Commit message built (standard format with Co-Authored-By)
- Commit created successfully
- Commit verified (last commit shown)
- Commit logged to build log
- Changes persisted to git history
- Ready for step-13 (completion check)

### ❌ FAILURE:
- Not a git repository (exit code 42)
- git add failed (exit code 43)
- git commit failed (exit code 44, unless no changes which is acceptable)

**Master Rule:** All feature work must be committed to git before proceeding.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
