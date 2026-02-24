# Git Commit Standards

**Purpose:** Define git commit conventions for autonomous implementation workflow to ensure traceability and consistency.

---

## Commit Frequency

### When to Commit

**MUST commit after:**
- ✅ Each feature implementation (pass or fail)
- ✅ Tracking file updates (feature_list.json, claude-progress.txt)

**SHOULD commit before:**
- Circuit breaker about to trigger
- Context degradation/memory issues
- Long-running sessions

**DO NOT commit:**
- Before implementation starts (no changes yet)
- Multiple times per feature (atomic commits only)

---

## Commit Message Format

### Standard Structure

```
<type>(<scope>): <subject>

<body>

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

### Type

**feat:** Feature implementation succeeded
- Used when feature status = "pass"
- Indicates new functionality added

**fix:** Feature implementation failed (attempt N)
- Used when feature status = "fail"
- Indicates implementation attempted but not complete

### Scope

**Always:** Feature ID
- Example: `feat(F001): ...`
- Allows easy filtering by feature

### Subject

**Format:** Feature name (with context if needed)

**Examples:**
- `feat(F001): Create GitHub organization`
- `fix(F042): API authentication setup (attempt 2)`

**Guidelines:**
- Concise (< 70 characters)
- Imperative mood ("Create" not "Created")
- No period at end

---

## Commit Message Body

### Success (status=pass)

```
Implemented and verified feature.

Verification results:
- Functional: <result>
- Technical: <result>
- Integration: <result>

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Example:**
```
feat(F001): Create GitHub organization

Implemented and verified feature.

Verification results:
- Functional: pass
- Technical: pass
- Integration: pass

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

### Failure (status=fail)

```
Implementation attempt N failed.

Failure reasons:
- <category>: <error message>
- <category>: <error message>

Feature will retry in next session.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Example:**
```
fix(F002): Create GitHub repository (attempt 1)

Implementation attempt 1 failed.

Failure reasons:
- Functional: Repository creation returned 401 Unauthorized
- Technical: Could not verify repository settings

Feature will retry in next session.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

### Blocked (status=blocked, after 3rd failure)

```
Implementation attempt 3 failed.

Failure reasons:
- <category>: <error message>

Feature will be blocked (retry limit reached).

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Example:**
```
fix(F003): Configure API credentials (attempt 3)

Implementation attempt 3 failed.

Failure reasons:
- Integration: GitHub API authentication failed (401)

Feature will be blocked (retry limit reached).

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## Co-Authored-By Attribution

### Required Attribution

**Every commit MUST include:**
```
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Purpose:**
- Transparency (AI-assisted work)
- GitHub attribution
- Audit trail

**Format Rules:**
- Separate line at end of commit message body
- Exactly one Co-Authored-By line
- No extra whitespace

---

## What to Commit

### Files to Commit

**Always include:**
- Implementation files/code (if any created/modified)
- feature_list.json (updated status)
- claude-progress.txt (updated metadata)
- autonomous_build_log.md (session logs)

**Example git add:**
```bash
git add -A
```

**Why -A:** Captures all changes (new files, modifications, deletions)

### Files to Exclude

**Never commit:**
- Temporary files (*.tmp, *.backup)
- Build artifacts (node_modules/, dist/, target/)
- IDE configuration (.vscode/, .idea/)
- Credentials (.env, *.key, *.pem)
- OS files (.DS_Store, Thumbs.db)

**Use .gitignore:** Ensure project has proper .gitignore file

---

## Commit Execution

### Standard Commit Flow (step-12)

```bash
cd "$PROJECT_FOLDER"

# Check status
git status --short

# Stage all changes
git add -A

# Create commit with message
git commit -m "$(cat <<'COMMITEOF'
<type>(<scope>): <subject>

<body>

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
COMMITEOF
)"

# Verify commit created
git log -1 --oneline
```

### Handling Empty Commits

**If no changes to commit:**
- Check if git diff --cached is empty
- Log warning (unusual but acceptable)
- Continue workflow (don't fail)

**Example:**
```bash
if git diff --cached --quiet; then
    echo "⚠️  No changes to commit"
    echo "   This may be expected if only tracking files changed"
fi
```

---

## Git Safety Rules

### DO NOT Use

**Forbidden commands (unless user explicitly requests):**
- ❌ `git push --force`
- ❌ `git reset --hard`
- ❌ `git clean -f`
- ❌ `git commit --amend`
- ❌ `git rebase -i`
- ❌ `--no-verify` (skip hooks)

**Why:** These can destroy work or bypass safety checks

### Safe Commands Only

**Allowed:**
- ✅ `git add`
- ✅ `git commit`
- ✅ `git status`
- ✅ `git log`
- ✅ `git diff`
- ✅ `git rev-parse`

---

## Commit Message Validation

### Validation Checks

**Before committing, verify:**
1. Message has type and scope
2. Subject line < 70 characters
3. Body describes change
4. Co-Authored-By line present
5. No typos in attribution

**Example validation:**
```bash
# Check Co-Authored-By present
if ! echo "$COMMIT_MESSAGE" | grep -q "Co-Authored-By: Claude"; then
    echo "⚠️  WARNING: Missing Co-Authored-By line"
fi

# Check subject length
SUBJECT_LENGTH=$(echo "$COMMIT_MESSAGE" | head -1 | wc -c)
if [[ $SUBJECT_LENGTH -gt 70 ]]; then
    echo "⚠️  WARNING: Subject line > 70 characters"
fi
```

---

## Git History Analysis

### Useful Commands

**View all autonomous implementation commits:**
```bash
git log --oneline --grep="Co-Authored-By: Claude"
```

**View commits for specific feature:**
```bash
git log --oneline --grep="F001"
```

**View recent implementation activity:**
```bash
git log --oneline --since="24 hours ago" --author="Claude"
```

**Count features implemented:**
```bash
git log --oneline --grep="feat(" | wc -l
```

**Count failed attempts:**
```bash
git log --oneline --grep="fix(" | wc -l
```

---

## Commit Metadata

### Stored in Build Log

After each commit, log to autonomous_build_log.md:

```markdown
#### Git Commit

**Commit Hash:** abc123
**Type:** feat
**Feature:** F001
**Status:** pass
**Message:**
\`\`\`
feat(F001): Create GitHub organization

Implemented and verified feature.

Verification results:
- Functional: pass
- Technical: pass
- Integration: pass

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
\`\`\`
```

---

## Push Strategy

### Local Commits Only

**By default:**
- Commits stay local
- No automatic push to remote

**Rationale:**
- User control over remote state
- Review before pushing
- Network independence

### Manual Push

**User can push after implementation:**
```bash
cd {project_folder}
git log --oneline  # Review commits
git push origin main  # Push to remote
```

---

## Troubleshooting

### Q: Commit fails with "nothing to commit"

**A:** No changes staged. This is acceptable (tracking files may not have changed). Workflow continues.

### Q: Commit fails with "Author identity unknown"

**A:** Git user.name or user.email not configured.

**Fix:**
```bash
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### Q: Pre-commit hook fails

**A:** Project has pre-commit hooks (linting, formatting, etc.)

**Options:**
1. Fix the issues the hook identifies (preferred)
2. Skip hooks with `--no-verify` (NOT RECOMMENDED)

### Q: Commit message too long

**A:** Keep subject < 70 chars, use body for details.

---

## Examples by Scenario

### Scenario 1: First Feature Success

```
feat(F001): Create GitHub organization

Implemented and verified feature.

Verification results:
- Functional: pass
- Technical: pass
- Integration: pass

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

### Scenario 2: Feature Fails, Will Retry

```
fix(F002): Create GitHub repository (attempt 1)

Implementation attempt 1 failed.

Failure reasons:
- Functional: Repository creation returned 404 (org not found)
- Technical: Could not verify repository settings

Feature will retry in next session.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

### Scenario 3: Feature Blocked After 3 Attempts

```
fix(F003): Configure API credentials (attempt 3)

Implementation attempt 3 failed.

Failure reasons:
- Integration: GitHub API authentication failed (401 Unauthorized)

Feature will be blocked (retry limit reached).

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

### Scenario 4: Feature Success After Retry

```
feat(F002): Create GitHub repository (attempt 2)

Implemented and verified feature after retry.

Verification results:
- Functional: pass
- Technical: pass
- Integration: pass

Note: First attempt failed due to org not found (now fixed).

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## Metrics from Git History

### Implementation Success Rate

```bash
TOTAL_COMMITS=$(git log --oneline --grep="Co-Authored-By: Claude" | wc -l)
SUCCESS_COMMITS=$(git log --oneline --grep="feat(" --grep="Co-Authored-By: Claude" | wc -l)

echo "Success Rate: $((SUCCESS_COMMITS * 100 / TOTAL_COMMITS))%"
```

### Average Attempts per Feature

```bash
FEATURES=$(git log --oneline --grep="feat(" | wc -l)
ATTEMPTS=$(git log --oneline --grep="fix(" | wc -l)

echo "Average Attempts: $(( (FEATURES + ATTEMPTS) / FEATURES ))"
```

---

**Version:** 1.0.0
**Created:** 2026-02-17
**Applies To:** run-autonomous-implementation workflow
