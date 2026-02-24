#!/bin/bash
# calculate-sprint-velocity.sh
# Calculates sprint velocity metrics from sprint-status.yaml

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
STATUS_FILE="${PROJECT_ROOT}/_bmad-output/implementation-artifacts/sprint-status.yaml"
OUTPUT_FILE="${PROJECT_ROOT}/docs/sprint-management/velocity-metrics.yaml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Flags
DEBUG=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            DEBUG=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --status-file)
            STATUS_FILE="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --debug          Enable debug output"
            echo "  --verbose        Enable verbose output"
            echo "  --status-file    Path to sprint-status.yaml (default: _bmad-output/implementation-artifacts/sprint-status.yaml)"
            echo "  --output         Path to output file (default: docs/sprint-management/velocity-metrics.yaml)"
            echo "  -h, --help       Show this help message"
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

debug() {
    if [[ "$DEBUG" == "true" ]]; then
        echo -e "${YELLOW}[DEBUG]${NC} $*"
    fi
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Validate status file exists
if [[ ! -f "$STATUS_FILE" ]]; then
    error "Status file not found: $STATUS_FILE"
    error "Run /bmad-bmm-sprint-planning to generate it"
    exit 1
fi

log "Calculating sprint velocity from: $STATUS_FILE"

# Extract project metadata
PROJECT_NAME=$(grep "^project:" "$STATUS_FILE" | awk '{print $2}' || echo "Unknown")
GENERATED_DATE=$(grep "^generated:" "$STATUS_FILE" | cut -d' ' -f2- || date -u +%Y-%m-%dT%H:%M:%SZ)

debug "Project: $PROJECT_NAME"
debug "Generated: $GENERATED_DATE"

# Count total epics and stories
TOTAL_EPICS=$(grep -E "^  epic-[0-9]+:" "$STATUS_FILE" | wc -l)
TOTAL_STORIES=$(grep -E "^  [0-9]+-[0-9]+-" "$STATUS_FILE" | wc -l)

debug "Total epics: $TOTAL_EPICS"
debug "Total stories: $TOTAL_STORIES"

# Count by status - epics
EPICS_BACKLOG=$(grep -E "^  epic-[0-9]+: backlog" "$STATUS_FILE" | wc -l)
EPICS_IN_PROGRESS=$(grep -E "^  epic-[0-9]+: in-progress" "$STATUS_FILE" | wc -l)
EPICS_DONE=$(grep -E "^  epic-[0-9]+: done" "$STATUS_FILE" | wc -l)

debug "Epic status - backlog: $EPICS_BACKLOG, in-progress: $EPICS_IN_PROGRESS, done: $EPICS_DONE"

# Count by status - stories
STORIES_BACKLOG=$(grep -E "^  [0-9]+-[0-9]+-.*: backlog" "$STATUS_FILE" | wc -l)
STORIES_READY=$(grep -E "^  [0-9]+-[0-9]+-.*: ready-for-dev" "$STATUS_FILE" | wc -l)
STORIES_IN_PROGRESS=$(grep -E "^  [0-9]+-[0-9]+-.*: in-progress" "$STATUS_FILE" | wc -l)
STORIES_REVIEW=$(grep -E "^  [0-9]+-[0-9]+-.*: review" "$STATUS_FILE" | wc -l)
STORIES_DONE=$(grep -E "^  [0-9]+-[0-9]+-.*: done" "$STATUS_FILE" | wc -l)

debug "Story status - backlog: $STORIES_BACKLOG, ready: $STORIES_READY, in-progress: $STORIES_IN_PROGRESS, review: $STORIES_REVIEW, done: $STORIES_DONE"

# Calculate sprint metrics
STORIES_COMPLETED=$STORIES_DONE
STORIES_IN_FLIGHT=$((STORIES_READY + STORIES_IN_PROGRESS + STORIES_REVIEW))

# Calculate completion rate
if [[ $TOTAL_STORIES -gt 0 ]]; then
    COMPLETION_RATE=$(awk "BEGIN {printf \"%.1f\", ($STORIES_COMPLETED / $TOTAL_STORIES) * 100}")
else
    COMPLETION_RATE="0.0"
fi

# Calculate velocity (assume 2-week sprints)
SPRINT_DURATION_WEEKS=2
VELOCITY=$(awk "BEGIN {printf \"%.2f\", $STORIES_COMPLETED / $SPRINT_DURATION_WEEKS}")

# Calculate estimated completion
if [[ $(echo "$VELOCITY > 0" | bc) -eq 1 ]]; then
    STORIES_REMAINING=$((TOTAL_STORIES - STORIES_COMPLETED))
    SPRINTS_REMAINING=$(awk "BEGIN {printf \"%.1f\", $STORIES_REMAINING / ($VELOCITY * $SPRINT_DURATION_WEEKS)}")
else
    SPRINTS_REMAINING="N/A"
fi

log "Metrics calculated successfully"

# Generate output YAML
mkdir -p "$(dirname "$OUTPUT_FILE")"

cat > "$OUTPUT_FILE" <<EOF
# Seven Fortunas Sprint Velocity Metrics
# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
# Source: $STATUS_FILE

project: $PROJECT_NAME
sprint_duration_weeks: $SPRINT_DURATION_WEEKS
calculated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)

# Epic Metrics
epics:
  total: $TOTAL_EPICS
  backlog: $EPICS_BACKLOG
  in_progress: $EPICS_IN_PROGRESS
  done: $EPICS_DONE
  completion_rate: $(awk "BEGIN {printf \"%.1f\", ($EPICS_DONE / $TOTAL_EPICS) * 100}")%

# Story Metrics
stories:
  total: $TOTAL_STORIES
  backlog: $STORIES_BACKLOG
  ready_for_dev: $STORIES_READY
  in_progress: $STORIES_IN_PROGRESS
  review: $STORIES_REVIEW
  done: $STORIES_DONE
  completion_rate: ${COMPLETION_RATE}%

# Velocity Metrics
velocity:
  stories_per_sprint: $VELOCITY
  stories_completed: $STORIES_COMPLETED
  stories_in_flight: $STORIES_IN_FLIGHT
  stories_remaining: $((TOTAL_STORIES - STORIES_COMPLETED))
  estimated_sprints_remaining: $SPRINTS_REMAINING

# Progress Indicators
progress:
  total_work_items: $((TOTAL_EPICS + TOTAL_STORIES))
  completed_work_items: $((EPICS_DONE + STORIES_DONE))
  overall_completion: $(awk "BEGIN {printf \"%.1f\", (($EPICS_DONE + $STORIES_DONE) / ($TOTAL_EPICS + $TOTAL_STORIES)) * 100}")%

# Burndown Data Points (for charting)
burndown:
  sprint_start_stories: $TOTAL_STORIES
  current_remaining_stories: $((TOTAL_STORIES - STORIES_COMPLETED))
  target_completion_day: $((SPRINT_DURATION_WEEKS * 7))
  daily_target_rate: $(awk "BEGIN {printf \"%.2f\", $TOTAL_STORIES / ($SPRINT_DURATION_WEEKS * 7)}")
EOF

log "Velocity metrics saved to: $OUTPUT_FILE"

# Display summary
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Seven Fortunas Sprint Velocity Summary"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Project: $PROJECT_NAME"
echo "Sprint Duration: $SPRINT_DURATION_WEEKS weeks"
echo ""
echo "EPIC PROGRESS:"
echo "  Total: $TOTAL_EPICS"
echo "  Done: $EPICS_DONE ($(awk "BEGIN {printf \"%.1f\", ($EPICS_DONE / $TOTAL_EPICS) * 100}")%)"
echo "  In Progress: $EPICS_IN_PROGRESS"
echo "  Backlog: $EPICS_BACKLOG"
echo ""
echo "STORY PROGRESS:"
echo "  Total: $TOTAL_STORIES"
echo "  Done: $STORIES_DONE (${COMPLETION_RATE}%)"
echo "  In Flight: $STORIES_IN_FLIGHT (ready + in-progress + review)"
echo "  Backlog: $STORIES_BACKLOG"
echo ""
echo "VELOCITY:"
echo "  Stories per Sprint: $VELOCITY"
echo "  Estimated Sprints Remaining: $SPRINTS_REMAINING"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Detailed metrics: $OUTPUT_FILE"
echo ""

exit 0
