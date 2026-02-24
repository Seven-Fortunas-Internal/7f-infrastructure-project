#!/bin/bash
# Sync Sprint Data to GitHub Projects
# Usage: ./scripts/sync-sprint-to-github.sh <sprint_id> [project_id]

set -e

SPRINT_ID=$1
PROJECT_ID=${2:-""}  # Optional: specify project ID, otherwise auto-detect

if [ -z "$SPRINT_ID" ]; then
    echo "Usage: $0 <sprint_id> [project_id]"
    echo "Example: $0 2 PVT_kwDOBKz..."
    exit 1
fi

SPRINT_DIR="docs/sprints/sprint-$SPRINT_ID"
BACKLOG_FILE="$SPRINT_DIR/backlog.yaml"

if [ ! -f "$BACKLOG_FILE" ]; then
    echo "Error: $BACKLOG_FILE not found"
    echo "Run /bmad-bmm-sprint-planning first to create sprint plan"
    exit 1
fi

echo "Syncing Sprint $SPRINT_ID to GitHub Projects..."
echo "================================================"
echo

# Check if yq is available
if ! command -v yq &> /dev/null; then
    echo "Error: yq not installed. Install with: brew install yq"
    exit 1
fi

# Check GitHub CLI authentication
if ! gh auth status &> /dev/null; then
    echo "Error: GitHub CLI not authenticated"
    echo "Run: gh auth login"
    exit 1
fi

# Check for read:project scope
if ! gh auth status 2>&1 | grep -q "read:project"; then
    echo "Warning: Missing read:project scope"
    echo "Run: gh auth refresh -s project"
    echo
fi

# Parse backlog.yaml
STORIES=$(yq eval '.stories[] | .title' "$BACKLOG_FILE" 2>/dev/null || echo "")

if [ -z "$STORIES" ]; then
    echo "Error: No stories found in $BACKLOG_FILE"
    exit 1
fi

# Count stories
STORY_COUNT=$(echo "$STORIES" | wc -l | tr -d ' ')
echo "Found $STORY_COUNT stories in sprint backlog"
echo

# Create GitHub issues for each story
ISSUE_COUNT=0
while IFS= read -r story; do
    if [ -z "$story" ]; then
        continue
    fi

    echo "Creating issue: $story"

    # Extract story details from YAML
    STORY_POINTS=$(yq eval ".stories[] | select(.title == \"$story\") | .story_points" "$BACKLOG_FILE" 2>/dev/null || echo "3")
    ASSIGNEE=$(yq eval ".stories[] | select(.title == \"$story\") | .assignee" "$BACKLOG_FILE" 2>/dev/null || echo "")

    # Create issue
    ISSUE_CMD="gh issue create --title \"$story\" --label \"sprint-$SPRINT_ID,story\" --body \"**Story Points:** $STORY_POINTS\n\nPart of Sprint $SPRINT_ID\""

    if [ -n "$ASSIGNEE" ] && [ "$ASSIGNEE" != "null" ]; then
        ISSUE_CMD="$ISSUE_CMD --assignee \"$ASSIGNEE\""
    fi

    if [ -n "$PROJECT_ID" ]; then
        ISSUE_CMD="$ISSUE_CMD --project \"$PROJECT_ID\""
    fi

    eval $ISSUE_CMD || echo "  ⚠️  Failed to create issue (may already exist)"
    ISSUE_COUNT=$((ISSUE_COUNT + 1))

done <<< "$STORIES"

echo
echo "================================================"
echo "✅ Sprint sync complete"
echo "   Created/updated $ISSUE_COUNT issues"
echo "   Sprint $SPRINT_ID backlog synced to GitHub"
echo
echo "View issues: gh issue list --label sprint-$SPRINT_ID"
