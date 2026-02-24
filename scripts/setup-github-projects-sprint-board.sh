#!/bin/bash
# setup-github-projects-sprint-board.sh
# Creates GitHub Projects board for sprint management

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
GITHUB_ORG="${GITHUB_ORG:-Seven-Fortunas-Internal}"
PROJECT_TITLE="${PROJECT_TITLE:-7F Sprint Board}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Flags
DRY_RUN=false
VERBOSE=false

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
        --org)
            GITHUB_ORG="$2"
            shift 2
            ;;
        --title)
            PROJECT_TITLE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Creates GitHub Projects board for sprint management."
            echo ""
            echo "Options:"
            echo "  --dry-run      Preview changes without creating board"
            echo "  --verbose      Enable verbose output"
            echo "  --org NAME     GitHub organization (default: Seven-Fortunas-Internal)"
            echo "  --title TITLE  Project board title (default: 7F Sprint Board)"
            echo "  -h, --help     Show this help message"
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

info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
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

log "Using organization: $GITHUB_ORG"
log "Project title: $PROJECT_TITLE"

if [[ "$DRY_RUN" == "true" ]]; then
    warn "DRY RUN MODE - No changes will be made"
fi

# Check if project already exists
info "Checking for existing projects..."
EXISTING_PROJECTS=$(gh project list --owner "$GITHUB_ORG" --format json 2>/dev/null | jq -r ".[].title" || echo "")

if echo "$EXISTING_PROJECTS" | grep -q "^$PROJECT_TITLE$"; then
    warn "Project '$PROJECT_TITLE' already exists"
    echo ""
    echo "Existing projects:"
    echo "$EXISTING_PROJECTS"
    echo ""
    echo "Use a different --title or delete the existing project first."
    exit 0
fi

# Create GitHub Project
info "Creating GitHub Projects board..."

if [[ "$DRY_RUN" == "false" ]]; then
    PROJECT_OUTPUT=$(gh project create \
        --owner "$GITHUB_ORG" \
        --title "$PROJECT_TITLE" \
        --format json 2>/dev/null || echo "")

    if [[ -z "$PROJECT_OUTPUT" ]]; then
        error "Failed to create project"
        error "Ensure you have admin permissions for organization: $GITHUB_ORG"
        error "GitHub Projects requires GitHub Team tier ($4/user/month)"
        exit 1
    fi

    PROJECT_NUMBER=$(echo "$PROJECT_OUTPUT" | jq -r '.number')
    PROJECT_URL=$(echo "$PROJECT_OUTPUT" | jq -r '.url')

    info "✓ Created project #$PROJECT_NUMBER"
    log "URL: $PROJECT_URL"
else
    info "Would create project: $PROJECT_TITLE"
    PROJECT_NUMBER="DRY_RUN"
    PROJECT_URL="https://github.com/orgs/$GITHUB_ORG/projects/DRY_RUN"
fi

# Add custom fields
info "Adding custom fields to project..."

FIELDS=(
    "Sprint:SINGLE_SELECT"
    "Story Points:NUMBER"
    "Priority:SINGLE_SELECT"
    "Epic:SINGLE_SELECT"
)

for field_spec in "${FIELDS[@]}"; do
    IFS=: read -r field_name field_type <<< "$field_spec"

    log "Adding field: $field_name ($field_type)"

    if [[ "$DRY_RUN" == "false" ]]; then
        # Note: GitHub CLI doesn't support creating custom fields directly
        # This requires GraphQL API
        log "  → Custom fields must be created manually via web UI"
        log "     Visit: $PROJECT_URL/settings/fields"
    else
        info "Would add field: $field_name ($field_type)"
    fi
done

# Configure views
info "Configuring project views..."

VIEWS=(
    "Current Sprint:Filter by current sprint"
    "Backlog:All items not in active sprint"
    "Burndown:Chart view for sprint progress"
    "Velocity:Historical velocity metrics"
)

log "Default views (configured via web UI):"
for view_spec in "${VIEWS[@]}"; do
    IFS=: read -r view_name view_desc <<< "$view_spec"
    log "  - $view_name: $view_desc"
done

# Save configuration
CONFIG_DIR="$PROJECT_ROOT/.7f"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/sprint-dashboard-config.yaml" <<EOF
# Seven Fortunas Sprint Dashboard Configuration
# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)

github:
  organization: $GITHUB_ORG
  project_number: $PROJECT_NUMBER
  project_title: "$PROJECT_TITLE"
  project_url: "$PROJECT_URL"
  token_env_var: GITHUB_TOKEN

sprint:
  default_duration_days: 14
  story_point_field: "Story Points"
  sprint_field: "Sprint"
  status_field: "Status"
  epic_field: "Epic"
  priority_field: "Priority"

metrics:
  velocity_window: 6  # Last N sprints for velocity calculation
  confidence_threshold: 0.8

# Status column mappings
status_columns:
  backlog: "Backlog"
  ready-for-dev: "Ready"
  in-progress: "In Progress"
  review: "Review"
  done: "Done"

# Priority values
priorities:
  - P0
  - P1
  - P2
  - P3
EOF

info "✓ Saved configuration to: $CONFIG_DIR/sprint-dashboard-config.yaml"

# Create setup guide
GUIDE_FILE="$PROJECT_ROOT/docs/sprint-management/github-projects-setup-guide.md"

cat > "$GUIDE_FILE" <<EOF
# GitHub Projects Sprint Board Setup Guide

## Board Created

- **Organization:** $GITHUB_ORG
- **Project:** $PROJECT_TITLE
- **Number:** $PROJECT_NUMBER
- **URL:** $PROJECT_URL

## Manual Configuration Steps

### 1. Add Custom Fields

Visit: $PROJECT_URL/settings/fields

Add the following custom fields:

1. **Sprint** (Single Select)
   - Add options: Sprint-2026-W08, Sprint-2026-W09, etc.

2. **Story Points** (Number)
   - Use for velocity tracking

3. **Priority** (Single Select)
   - Options: P0, P1, P2, P3

4. **Epic** (Single Select)
   - Add options: Epic-1, Epic-2, Epic-3, etc.

### 2. Configure Status Column

Default status column should have:
- Backlog
- Ready
- In Progress
- Review
- Done

### 3. Create Views

#### Current Sprint View
- **Type:** Board
- **Filter:** Sprint = current sprint (e.g., "Sprint-2026-W08")
- **Group by:** Status
- **Sort by:** Priority

#### Backlog View
- **Type:** Table
- **Filter:** Sprint is empty
- **Sort by:** Priority, Story Points

#### Burndown View
- **Type:** Chart
- **X-axis:** Date
- **Y-axis:** Story Points Remaining
- **Filter:** Sprint = current sprint

#### Velocity View
- **Type:** Insights
- **Metric:** Story Points completed per sprint
- **Time range:** Last 6 sprints

### 4. Configure Automation

Visit: $PROJECT_URL/settings/workflows

Enable these automations:
1. **Auto-add items:** When issues/PRs are added to organization
2. **Auto-close:** When issue is closed, move to Done column
3. **Auto-archive:** Archive items in Done after 30 days

### 5. Set Permissions

Visit: $PROJECT_URL/settings/access

Grant access to:
- Organization members: Write
- Team leads: Admin

## Integration with Sprint Management

### Sync Stories to Board

Use the sync script to populate board with stories:

\`\`\`bash
./scripts/sync-stories-to-github.sh
\`\`\`

This will:
1. Create GitHub issues for each story in sprint-status.yaml
2. Add issues to the project board
3. Set custom fields (Sprint, Epic, Story Points)
4. Move to correct status column

### Query Sprint Status

Use the 7f-sprint-dashboard skill:

\`\`\`
/7f-sprint-dashboard status --sprint Sprint-2026-W08
\`\`\`

### Update Item Status

\`\`\`
/7f-sprint-dashboard update --item STORY-001 --status "In Progress"
\`\`\`

## API Access

### GraphQL API

Query project data:

\`\`\`bash
gh api graphql -f query='
  query {
    organization(login: "$GITHUB_ORG") {
      projectV2(number: $PROJECT_NUMBER) {
        title
        items(first: 100) {
          nodes {
            id
            content {
              ... on Issue {
                number
                title
              }
            }
          }
        }
      }
    }
  }'
\`\`\`

### Update Field Value

\`\`\`bash
gh project item-edit --id ITEM_ID --field "Status" --project-id PROJECT_ID --value "In Progress"
\`\`\`

## Troubleshooting

### Cannot Create Project

**Error:** "Resource not accessible by personal access token"

**Solution:**
1. Ensure you have admin permissions for the organization
2. GitHub Projects requires GitHub Team tier ($4/user/month)
3. Verify your token has \`project\` scope

### Cannot Add Custom Fields

**Solution:** Custom fields must be added via web UI at:
$PROJECT_URL/settings/fields

### Sync Script Fails

**Solution:**
1. Verify GitHub CLI is authenticated: \`gh auth status\`
2. Check organization name matches: \`$GITHUB_ORG\`
3. Ensure project exists: \`gh project list --owner $GITHUB_ORG\`

## References

- **GitHub Projects API:** https://docs.github.com/en/graphql/reference/objects#projectv2
- **Sprint Management:** docs/sprint-management/README.md
- **BMAD Workflows:** _bmad/bmm/workflows/4-implementation/sprint-planning/

---

**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)
**Status:** Manual steps required (custom fields, views, automation)
EOF

info "✓ Created setup guide: $GUIDE_FILE"

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  GitHub Projects Sprint Board Setup"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Organization: $GITHUB_ORG"
echo "Project: $PROJECT_TITLE"
echo "Number: $PROJECT_NUMBER"
echo "URL: $PROJECT_URL"
echo ""
echo "NEXT STEPS:"
echo "  1. Complete manual setup steps (custom fields, views)"
echo "     Guide: $GUIDE_FILE"
echo ""
echo "  2. Sync stories to board:"
echo "     ./scripts/sync-stories-to-github.sh"
echo ""
echo "  3. Use sprint dashboard skill:"
echo "     /7f-sprint-dashboard status"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""

exit 0
