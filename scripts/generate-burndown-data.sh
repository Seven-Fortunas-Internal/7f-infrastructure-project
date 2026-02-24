#!/bin/bash
# generate-burndown-data.sh
# Generates burndown chart data from sprint-status.yaml

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
STATUS_FILE="${PROJECT_ROOT}/_bmad-output/implementation-artifacts/sprint-status.yaml"
OUTPUT_FILE="${PROJECT_ROOT}/docs/sprint-management/burndown-data.json"
SPRINT_DURATION_DAYS=14  # 2 weeks default

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --status-file)
            STATUS_FILE="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --sprint-duration)
            SPRINT_DURATION_DAYS="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --status-file      Path to sprint-status.yaml"
            echo "  --output           Path to output JSON file"
            echo "  --sprint-duration  Sprint duration in days (default: 14)"
            echo "  -h, --help         Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate status file
if [[ ! -f "$STATUS_FILE" ]]; then
    echo -e "${RED}[ERROR]${NC} Status file not found: $STATUS_FILE"
    exit 1
fi

# Count total and completed stories
TOTAL_STORIES=$(grep -E "^  [0-9]+-[0-9]+-" "$STATUS_FILE" | wc -l)
COMPLETED_STORIES=$(grep -E "^  [0-9]+-[0-9]+-.*: done" "$STATUS_FILE" | wc -l)
REMAINING_STORIES=$((TOTAL_STORIES - COMPLETED_STORIES))

# Calculate ideal burndown rate
IDEAL_RATE=$(awk "BEGIN {printf \"%.2f\", $TOTAL_STORIES / $SPRINT_DURATION_DAYS}")

# Generate burndown data points
BURNDOWN_DATA="["

for day in $(seq 0 $SPRINT_DURATION_DAYS); do
    IDEAL_REMAINING=$(awk "BEGIN {printf \"%.0f\", $TOTAL_STORIES - ($IDEAL_RATE * $day)}")

    # For actual data, we only have current day data
    # In a real implementation, this would read from historical data
    if [[ $day -eq 0 ]]; then
        ACTUAL_REMAINING=$TOTAL_STORIES
    elif [[ $day -eq $SPRINT_DURATION_DAYS ]]; then
        ACTUAL_REMAINING=$REMAINING_STORIES
    else
        # Interpolate (in real use, load from daily snapshots)
        PROGRESS_RATIO=$(awk "BEGIN {printf \"%.4f\", $day / $SPRINT_DURATION_DAYS}")
        ACTUAL_REMAINING=$(awk "BEGIN {printf \"%.0f\", $TOTAL_STORIES - (($TOTAL_STORIES - $REMAINING_STORIES) * $PROGRESS_RATIO)}")
    fi

    if [[ $day -gt 0 ]]; then
        BURNDOWN_DATA+=","
    fi

    BURNDOWN_DATA+="
    {
      \"day\": $day,
      \"ideal_remaining\": $IDEAL_REMAINING,
      \"actual_remaining\": $ACTUAL_REMAINING
    }"
done

BURNDOWN_DATA+="
]"

# Create output directory
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Write JSON output
cat > "$OUTPUT_FILE" <<EOF
{
  "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "sprint_duration_days": $SPRINT_DURATION_DAYS,
  "total_stories": $TOTAL_STORIES,
  "completed_stories": $COMPLETED_STORIES,
  "remaining_stories": $REMAINING_STORIES,
  "ideal_rate_per_day": $IDEAL_RATE,
  "burndown_data": $BURNDOWN_DATA
}
EOF

echo -e "${GREEN}[SUCCESS]${NC} Burndown data generated: $OUTPUT_FILE"
echo ""
echo "Sprint Stats:"
echo "  Total Stories: $TOTAL_STORIES"
echo "  Completed: $COMPLETED_STORIES"
echo "  Remaining: $REMAINING_STORIES"
echo "  Ideal Rate: $IDEAL_RATE stories/day"
echo ""
echo "Use this data to visualize burndown charts in dashboards."
echo ""

exit 0
