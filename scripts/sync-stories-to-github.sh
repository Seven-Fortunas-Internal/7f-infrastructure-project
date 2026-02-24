#!/bin/bash
# sync-stories-to-github.sh
# Syncs sprint-status.yaml to GitHub Projects for Kanban visualization

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
STATUS_FILE="${PROJECT_ROOT}/_bmad-output/implementation-artifacts/sprint-status.yaml"
REPO_OWNER="${GITHUB_ORG:-Seven-Fortunas-Internal}"
REPO_NAME="${GITHUB_REPO:-7f-infrastructure-project}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Flags
DRY_RUN=false
VERBOSE=false
EPIC_FILTER=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --epic)
            EPIC_FILTER="$2"
            shift 2
            ;;
        --status-file)
            STATUS_FILE="$2"
            shift 2
            ;;
        --repo)
            REPO_NAME="$2"
            shift 2
            ;;
        --owner)
            REPO_OWNER="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Syncs sprint status to GitHub Projects for Kanban visualization."
            echo ""
            echo "Options:"
            echo "  --dry-run          Preview changes without creating issues"
            echo "  --verbose          Enable verbose output"
            echo "  --epic N           Sync only epic N"
            echo "  --status-file      Path to sprint-status.yaml"
            echo "  --repo NAME        GitHub repository name"
            echo "  --owner NAME       GitHub organization/owner"
            echo "  -h, --help         Show this help message"
            echo ""
            echo "Environment:"
            echo "  GITHUB_ORG         Override default organization (default: Seven-Fortunas-Internal)"
            echo "  GITHUB_REPO        Override default repository (default: 7f-infrastructure-project)"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Functions
log() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${GREEN}[INFO]${NC} $*"
    fi
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

# Validate prerequisites
if ! command -v gh &> /dev/null; then
    error "GitHub CLI (gh) not installed"
    error "Install: https://cli.github.com/"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    error "GitHub CLI not authenticated"
    error "Run: gh auth login"
    exit 1
fi

if [[ ! -f "$STATUS_FILE" ]]; then
    error "Status file not found: $STATUS_FILE"
    error "Run /bmad-bmm-sprint-planning to generate it"
    exit 1
fi

log "Using status file: $STATUS_FILE"
log "Target repository: $REPO_OWNER/$REPO_NAME"

if [[ "$DRY_RUN" == "true" ]]; then
    warn "DRY RUN MODE - No changes will be made"
fi

# Extract project metadata
PROJECT_NAME=$(grep "^project:" "$STATUS_FILE" | awk '{print $2}' || echo "Unknown")
info "Project: $PROJECT_NAME"

# Map status to GitHub label
map_status_to_label() {
    local status=$1
    case $status in
        backlog) echo "Status: Backlog" ;;
        ready-for-dev) echo "Status: Ready" ;;
        in-progress) echo "Status: In Progress" ;;
        review) echo "Status: Review" ;;
        done) echo "Status: Done" ;;
        *) echo "Status: Unknown" ;;
    esac
}

# Parse sprint-status.yaml and sync stories
STORY_COUNT=0
EPIC_NUM=""

while IFS=: read -r key value; do
    # Remove leading whitespace
    key=$(echo "$key" | sed 's/^[[:space:]]*//')
    value=$(echo "$value" | sed 's/^[[:space:]]*//')

    # Skip comments and metadata
    [[ "$key" =~ ^# ]] && continue
    [[ -z "$key" ]] && continue

    # Detect epic
    if [[ "$key" =~ ^epic-([0-9]+)$ ]]; then
        EPIC_NUM="${BASH_REMATCH[1]}"
        log "Processing Epic $EPIC_NUM"

        # Skip if filtering and not matching
        if [[ -n "$EPIC_FILTER" && "$EPIC_NUM" != "$EPIC_FILTER" ]]; then
            log "Skipping Epic $EPIC_NUM (filter: $EPIC_FILTER)"
            EPIC_NUM=""
            continue
        fi
        continue
    fi

    # Detect story
    if [[ "$key" =~ ^([0-9]+)-([0-9]+)-(.+)$ ]]; then
        STORY_EPIC="${BASH_REMATCH[1]}"
        STORY_NUM="${BASH_REMATCH[2]}"
        STORY_SLUG="${BASH_REMATCH[3]}"
        STORY_STATUS="$value"

        # Skip if filtering and not matching current epic
        if [[ -n "$EPIC_FILTER" && "$STORY_EPIC" != "$EPIC_FILTER" ]]; then
            continue
        fi

        # Convert slug to title
        STORY_TITLE=$(echo "$STORY_SLUG" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')
        STORY_ID="$STORY_EPIC.$STORY_NUM"
        FULL_TITLE="Story $STORY_ID: $STORY_TITLE"

        # Map status to label
        STATUS_LABEL=$(map_status_to_label "$STORY_STATUS")

        log "Story: $FULL_TITLE [$STORY_STATUS]"

        # Check if issue already exists
        EXISTING_ISSUE=$(gh issue list \
            --repo "$REPO_OWNER/$REPO_NAME" \
            --search "in:title \"Story $STORY_ID\"" \
            --json number \
            --jq '.[0].number' 2>/dev/null || echo "")

        if [[ -n "$EXISTING_ISSUE" ]]; then
            log "  → Issue #$EXISTING_ISSUE already exists"

            # Update labels
            if [[ "$DRY_RUN" == "false" ]]; then
                gh issue edit "$EXISTING_ISSUE" \
                    --repo "$REPO_OWNER/$REPO_NAME" \
                    --add-label "$STATUS_LABEL" \
                    --add-label "Epic-$STORY_EPIC" \
                    &> /dev/null || warn "  → Failed to update labels"
                log "  → Updated labels: $STATUS_LABEL, Epic-$STORY_EPIC"
            else
                info "  → Would update labels: $STATUS_LABEL, Epic-$STORY_EPIC"
            fi
        else
            # Create new issue
            ISSUE_BODY="**Story ID:** $STORY_ID
**Epic:** $STORY_EPIC
**Status:** $STORY_STATUS
**Slug:** $STORY_SLUG

---

*Auto-generated from sprint-status.yaml*
*Synced at: $(date -u +%Y-%m-%dT%H:%M:%SZ)*"

            if [[ "$DRY_RUN" == "false" ]]; then
                NEW_ISSUE=$(gh issue create \
                    --repo "$REPO_OWNER/$REPO_NAME" \
                    --title "$FULL_TITLE" \
                    --body "$ISSUE_BODY" \
                    --label "$STATUS_LABEL" \
                    --label "Epic-$STORY_EPIC" \
                    --label "Type: Story" 2>/dev/null || echo "")

                if [[ -n "$NEW_ISSUE" ]]; then
                    log "  → Created issue: $NEW_ISSUE"
                else
                    warn "  → Failed to create issue"
                fi
            else
                info "  → Would create issue: $FULL_TITLE"
                info "     Labels: $STATUS_LABEL, Epic-$STORY_EPIC, Type: Story"
            fi
        fi

        ((STORY_COUNT++))
    fi
done < <(grep -E "^  [a-z0-9-]+:" "$STATUS_FILE")

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  GitHub Projects Sync Complete"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Repository: $REPO_OWNER/$REPO_NAME"
echo "Stories Processed: $STORY_COUNT"
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
    warn "DRY RUN - No changes were made"
    echo ""
    echo "Run without --dry-run to apply changes."
else
    echo "View issues: https://github.com/$REPO_OWNER/$REPO_NAME/issues"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""

exit 0
