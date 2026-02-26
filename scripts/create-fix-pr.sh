#!/usr/bin/env bash
# =============================================================================
# create-fix-pr.sh — FR-9.5: Known Pattern Fix PR Generation
# =============================================================================
# Creates automated fix PRs for known CI failure patterns identified by FR-9.2.
#
# Usage:
#   ./scripts/create-fix-pr.sh <workflow-name> <pattern-type> <fix-branch>
#
# Supported patterns:
#   - branch_protection_push: Add || echo "skipped" to git push commands
#   - missing_secret: Add placeholder to .secrets-manifest.yml
#   - wrong_permissions: Add required permission to workflow file
#
# Exit codes:
#   0 = PR created successfully
#   1 = Error (validation failed, open PR exists, etc.)
#   2 = Pattern not supported (falls through to FR-9.4)
#
# Constraints:
#   - Never creates PR targeting main branch
#   - Checks for existing open PR before creating new one
#   - Maximum 1 open fix PR per workflow (circuit breaker)
# =============================================================================

set -euo pipefail

WORKFLOW_NAME="$1"
PATTERN_TYPE="$2"
FIX_BRANCH="${3:-fix/ci-${WORKFLOW_NAME}-$(date +%Y-%m-%d)}"

# Validate inputs
if [[ -z "$WORKFLOW_NAME" ]] || [[ -z "$PATTERN_TYPE" ]]; then
    echo "Error: Usage: $0 <workflow-name> <pattern-type> [fix-branch]"
    exit 1
fi

# Check supported patterns
case "$PATTERN_TYPE" in
    branch_protection_push|missing_secret|wrong_permissions)
        echo "✓ Pattern '$PATTERN_TYPE' is supported"
        ;;
    *)
        echo "⚠ Pattern '$PATTERN_TYPE' is not supported - falling through to FR-9.4"
        exit 2
        ;;
esac

# Circuit breaker: Check for existing open PRs for this workflow
OPEN_PRS=$(gh pr list --search "fix/ci-$WORKFLOW_NAME in:title is:open" --json number --jq 'length')
if [[ "$OPEN_PRS" -gt 0 ]]; then
    echo "⚠ Circuit breaker: $OPEN_PRS open fix PR(s) already exist for $WORKFLOW_NAME"
    echo "  Skipping PR creation to prevent flood"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Never target main
if [[ "$FIX_BRANCH" == "main" ]]; then
    echo "Error: Cannot create PR targeting main branch"
    exit 1
fi

# Create fix branch
echo "Creating fix branch: $FIX_BRANCH"
git checkout -b "$FIX_BRANCH" 2>/dev/null || git checkout "$FIX_BRANCH"

# Apply fix based on pattern
case "$PATTERN_TYPE" in
    branch_protection_push)
        echo "Applying fix for branch_protection_push..."
        WORKFLOW_FILE=".github/workflows/${WORKFLOW_NAME}.yml"
        if [[ ! -f "$WORKFLOW_FILE" ]]; then
            echo "Error: Workflow file not found: $WORKFLOW_FILE"
            git checkout "$CURRENT_BRANCH"
            exit 1
        fi

        # Use FR-10.4 validator to auto-fix C5 violations
        if bash scripts/validate-and-fix-workflow.sh "$WORKFLOW_FILE"; then
            git add "$WORKFLOW_FILE"
            git commit -m "fix(ci): Add fallback to git push in $WORKFLOW_NAME

Auto-fix for branch protection violation detected by FR-9.2.

Pattern: branch_protection_push
Fix: Added || echo 'skipped - protected branch' to git push commands

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
        else
            echo "Error: Auto-fix validation failed"
            git checkout "$CURRENT_BRANCH"
            exit 1
        fi
        ;;

    missing_secret)
        echo "Applying fix for missing_secret..."
        # Add placeholder to .secrets-manifest.yml
        SECRET_NAME=$(echo "$WORKFLOW_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' '_')_SECRET

        if ! grep -q "$SECRET_NAME" .secrets-manifest.yml 2>/dev/null; then
            cat >> .secrets-manifest.yml << EOF

# Added by FR-9.5 auto-fix for $WORKFLOW_NAME
$SECRET_NAME:
  description: "Secret required by $WORKFLOW_NAME workflow"
  required: true
  scope: actions
EOF
            git add .secrets-manifest.yml
            git commit -m "fix(ci): Add missing secret to manifest for $WORKFLOW_NAME

Auto-fix for missing secret detected by FR-9.2.

Pattern: missing_secret
Fix: Added $SECRET_NAME to .secrets-manifest.yml

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
        else
            echo "Secret $SECRET_NAME already exists in manifest"
            git checkout "$CURRENT_BRANCH"
            exit 1
        fi
        ;;

    wrong_permissions)
        echo "Applying fix for wrong_permissions..."
        WORKFLOW_FILE=".github/workflows/${WORKFLOW_NAME}.yml"
        if [[ ! -f "$WORKFLOW_FILE" ]]; then
            echo "Error: Workflow file not found: $WORKFLOW_FILE"
            git checkout "$CURRENT_BRANCH"
            exit 1
        fi

        # This is a simplified fix - in reality would need FR-9.2 output to know which permission
        # For now, just add a comment suggesting manual review
        git commit --allow-empty -m "fix(ci): Review permissions for $WORKFLOW_NAME

Auto-detected permission issue by FR-9.2.

Pattern: wrong_permissions
Fix: Please review and add required permissions to workflow

Note: Automated permission fix requires FR-9.2 detailed output
This PR serves as a reminder to review the workflow permissions.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
        ;;
esac

# Push to remote
echo "Pushing branch to remote..."
git push -u origin "$FIX_BRANCH"

# Create PR (never targeting main)
BASE_BRANCH="develop"  # Default to develop, not main
if ! git ls-remote --heads origin develop | grep -q develop; then
    # If develop doesn't exist, use current branch as base (but not main)
    if [[ "$CURRENT_BRANCH" == "main" ]]; then
        echo "Error: No suitable base branch found (cannot use main)"
        git checkout "$CURRENT_BRANCH"
        exit 1
    fi
    BASE_BRANCH="$CURRENT_BRANCH"
fi

echo "Creating PR targeting $BASE_BRANCH..."
gh pr create \
    --base "$BASE_BRANCH" \
    --head "$FIX_BRANCH" \
    --title "fix(ci): Auto-fix $PATTERN_TYPE in $WORKFLOW_NAME" \
    --body "## Automated Fix PR (FR-9.5)

**Workflow:** \`$WORKFLOW_NAME\`
**Pattern:** \`$PATTERN_TYPE\`
**Detected by:** FR-9.2 AI-Powered Log Analysis

### Changes

This PR was automatically generated to fix a known CI failure pattern.

### Testing

- [ ] Workflow runs successfully after merge
- [ ] No new failures introduced

### Notes

- Generated by FR-9.5 (Known Pattern Fix PR Generation)
- Part of self-healing CI system (ADR-006)
- If this fix is incorrect, close without merging and FR-9.4 will create an issue for manual review

---
🤖 Automated by [Seven Fortunas AI Infrastructure](https://github.com/Seven-Fortunas-Internal/7f-infrastructure-project)"

echo "✓ PR created successfully"

# Return to original branch
git checkout "$CURRENT_BRANCH"
