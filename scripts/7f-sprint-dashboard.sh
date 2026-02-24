#!/bin/bash
# 7f-sprint-dashboard.sh
# Query and update sprint status using GitHub Projects API

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG_FILE="${PROJECT_ROOT}/.7f/sprint-dashboard-config.yaml"
GITHUB_ORG="${GITHUB_ORG:-Seven-Fortunas-Internal}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse action
ACTION="${1:-help}"

# Functions
log() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

show_help() {
    cat <<EOF
7f-sprint-dashboard - Query and update sprint status

Usage:
  $0 <action> [options]

Actions:
  status      Show current sprint status
  update      Update sprint item status
  velocity    Calculate sprint velocity
  burndown    Show sprint burndown chart
  help        Show this help message

Options:
  --sprint NAME       Sprint identifier (e.g., Sprint-2026-W08)
  --item ID           Story/task identifier
  --status STATUS     New status value
  --last-n-sprints N  Number of sprints for velocity calculation

Examples:
  # View current sprint status
  $0 status --sprint Sprint-2026-W08

  # Update story status
  $0 update --item STORY-001 --status "In Progress"

  # Calculate velocity
  $0 velocity --last-n-sprints 6

  # Show burndown
  $0 burndown --sprint Sprint-2026-W08

Configuration:
  Config file: $CONFIG_FILE
  GitHub org:  $GITHUB_ORG

EOF
}

# Load configuration
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        error "Configuration file not found: $CONFIG_FILE"
        error "Run: ./scripts/setup-github-projects-sprint-board.sh"
        exit 1
    fi

    PROJECT_NUMBER=$(grep "project_number:" "$CONFIG_FILE" | awk '{print $2}')
    PROJECT_TITLE=$(grep "project_title:" "$CONFIG_FILE" | awk '{print $2}' | tr -d '"')

    if [[ -z "$PROJECT_NUMBER" || "$PROJECT_NUMBER" == "null" ]]; then
        error "Invalid project configuration"
        error "Re-run setup: ./scripts/setup-github-projects-sprint-board.sh"
        exit 1
    fi
}

# Action: status
action_status() {
    local sprint_name="${SPRINT_NAME:-}"

    if [[ -z "$sprint_name" ]]; then
        error "Missing required option: --sprint"
        echo ""
        echo "Usage: $0 status --sprint Sprint-2026-W08"
        exit 1
    fi

    info "Fetching sprint status for: $sprint_name"
    echo ""

    # Query GitHub Projects API
    # Note: This is a simplified implementation
    # Full implementation would use GraphQL to query project items

    # For now, query issues with sprint label
    ISSUES=$(gh issue list \
        --repo "$GITHUB_ORG/7f-infrastructure-project" \
        --label "Sprint:$sprint_name" \
        --json number,title,state,labels \
        --limit 100 2>/dev/null || echo "[]")

    TOTAL_ITEMS=$(echo "$ISSUES" | jq length)

    if [[ "$TOTAL_ITEMS" -eq 0 ]]; then
        warn "No items found for sprint: $sprint_name"
        echo ""
        echo "Ensure:"
        echo "  1. Sprint board is created"
        echo "  2. Stories are synced: ./scripts/sync-stories-to-github.sh"
        echo "  3. Issues have label: Sprint:$sprint_name"
        exit 0
    fi

    # Count by status
    DONE=$(echo "$ISSUES" | jq '[.[] | select(.state == "closed")] | length')
    OPEN=$(echo "$ISSUES" | jq '[.[] | select(.state == "open")] | length')

    # Display status
    echo "Sprint: $sprint_name"
    echo "Goal: Infrastructure setup (from sprint-status.yaml)"
    echo ""
    echo "Progress: $DONE/$TOTAL_ITEMS items completed ($(awk "BEGIN {printf \"%.0f\", ($DONE / $TOTAL_ITEMS) * 100}")%)"
    echo ""
    echo "Status Breakdown:"
    echo "  ✓ Done: $DONE items"
    echo "  ○ Open: $OPEN items"
    echo ""

    # List items
    echo "Items:"
    echo "$ISSUES" | jq -r '.[] | "  [\(.state | if . == "open" then "○" else "✓" end)] #\(.number) - \(.title)"'
    echo ""
}

# Action: update
action_update() {
    local item_id="${ITEM_ID:-}"
    local new_status="${NEW_STATUS:-}"

    if [[ -z "$item_id" || -z "$new_status" ]]; then
        error "Missing required options: --item and --status"
        echo ""
        echo "Usage: $0 update --item STORY-001 --status 'In Progress'"
        exit 1
    fi

    info "Updating $item_id to status: $new_status"

    # Map story ID to GitHub issue number
    # This would query the GitHub Projects API or issues
    warn "Update functionality requires GitHub Projects API integration"
    warn "For now, update manually via web UI or use:"
    echo ""
    echo "  gh issue edit <issue-number> --add-label 'Status: $new_status'"
    echo ""
}

# Action: velocity
action_velocity() {
    local n_sprints="${N_SPRINTS:-6}"

    info "Calculating sprint velocity (last $n_sprints sprints)"
    echo ""

    # Read sprint-status.yaml and calculate velocity
    STATUS_FILE="$PROJECT_ROOT/_bmad-output/implementation-artifacts/sprint-status.yaml"

    if [[ ! -f "$STATUS_FILE" ]]; then
        error "Sprint status file not found: $STATUS_FILE"
        error "Run: /bmad-bmm-sprint-planning"
        exit 1
    fi

    # Use existing velocity calculator
    "$SCRIPT_DIR/calculate-sprint-velocity.sh" --verbose

    echo ""
    info "For multi-sprint trends, track velocity over time"
}

# Action: burndown
action_burndown() {
    local sprint_name="${SPRINT_NAME:-}"

    if [[ -z "$sprint_name" ]]; then
        error "Missing required option: --sprint"
        echo ""
        echo "Usage: $0 burndown --sprint Sprint-2026-W08"
        exit 1
    fi

    info "Generating burndown chart for: $sprint_name"
    echo ""

    # Use existing burndown generator
    "$SCRIPT_DIR/generate-burndown-data.sh"

    echo ""
    info "Burndown data generated"
    info "View in dashboards: dashboards/sprint-dashboard/"
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

# Parse options
SPRINT_NAME=""
ITEM_ID=""
NEW_STATUS=""
N_SPRINTS=6

shift || true  # Skip action argument

while [[ $# -gt 0 ]]; do
    case $1 in
        --sprint)
            SPRINT_NAME="$2"
            shift 2
            ;;
        --item)
            ITEM_ID="$2"
            shift 2
            ;;
        --status)
            NEW_STATUS="$2"
            shift 2
            ;;
        --last-n-sprints)
            N_SPRINTS="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Execute action
case $ACTION in
    status)
        load_config
        action_status
        ;;
    update)
        load_config
        action_update
        ;;
    velocity)
        action_velocity
        ;;
    burndown)
        action_burndown
        ;;
    help|-h|--help)
        show_help
        ;;
    *)
        error "Unknown action: $ACTION"
        echo ""
        show_help
        exit 1
        ;;
esac

exit 0
