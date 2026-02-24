#!/usr/bin/env bash
# progress-report.sh
# Generate real-time progress report for Seven Fortunas implementation

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
FEATURE_LIST="${FEATURE_LIST:-feature_list.json}"
PROGRESS_FILE="${PROGRESS_FILE:-claude-progress.txt}"
BUILD_LOG="${BUILD_LOG:-autonomous_build_log.md}"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${CYAN}Seven Fortunas - Autonomous Implementation Progress${NC}     ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Parse feature_list.json
if [ ! -f "$FEATURE_LIST" ]; then
    echo -e "${RED}✗ feature_list.json not found${NC}"
    exit 1
fi

TOTAL=$(jq '.features | length' "$FEATURE_LIST")
PASS=$(jq '[.features[] | select(.status == "pass")] | length' "$FEATURE_LIST")
PENDING=$(jq '[.features[] | select(.status == "pending")] | length' "$FEATURE_LIST")
FAIL=$(jq '[.features[] | select(.status == "fail")] | length' "$FEATURE_LIST")
BLOCKED=$(jq '[.features[] | select(.status == "blocked")] | length' "$FEATURE_LIST")

# Calculate percentages
PROGRESS_PCT=$((PASS * 100 / TOTAL))
PENDING_PCT=$((PENDING * 100 / TOTAL))
BLOCKED_PCT=$((BLOCKED * 100 / TOTAL))

# Status colors
PASS_COLOR=$GREEN
PENDING_COLOR=$YELLOW
FAIL_COLOR=$RED
BLOCKED_COLOR=$RED

echo -e "${BLUE}Feature Status:${NC}"
echo -e "  Total Features:    ${TOTAL}"
echo -e "  ${PASS_COLOR}✓ Pass:${NC}            ${PASS} (${PROGRESS_PCT}%)"
echo -e "  ${PENDING_COLOR}⊙ Pending:${NC}         ${PENDING} (${PENDING_PCT}%)"
echo -e "  ${FAIL_COLOR}✗ Fail:${NC}            ${FAIL}"
echo -e "  ${BLOCKED_COLOR}⊗ Blocked:${NC}         ${BLOCKED} (${BLOCKED_PCT}%)"
echo ""

# Progress bar
BAR_WIDTH=50
FILLED=$((PASS * BAR_WIDTH / TOTAL))
EMPTY=$((BAR_WIDTH - FILLED))

printf "Progress: ["
printf "${GREEN}%${FILLED}s${NC}" | tr ' ' '█'
printf "${YELLOW}%${EMPTY}s${NC}" | tr ' ' '░'
printf "] ${PROGRESS_PCT}%%\n"
echo ""

# Parse claude-progress.txt
if [ -f "$PROGRESS_FILE" ]; then
    LAST_UPDATED=$(grep "^last_updated=" "$PROGRESS_FILE" | cut -d= -f2)
    SESSION_COUNT=$(grep "^session_count=" "$PROGRESS_FILE" | cut -d= -f2)
    CIRCUIT_STATUS=$(grep "^circuit_breaker_status=" "$PROGRESS_FILE" | cut -d= -f2)
    
    echo -e "${BLUE}Session Info:${NC}"
    echo -e "  Session Count:     ${SESSION_COUNT}"
    echo -e "  Circuit Breaker:   ${CIRCUIT_STATUS}"
    echo -e "  Last Updated:      ${LAST_UPDATED}"
    echo ""
fi

# Category breakdown
echo -e "${BLUE}Progress by Category:${NC}"

CATEGORIES=$(jq -r '[.features[].category] | unique[]' "$FEATURE_LIST")

while IFS= read -r category; do
    CAT_TOTAL=$(jq "[.features[] | select(.category == \"$category\")] | length" "$FEATURE_LIST")
    CAT_PASS=$(jq "[.features[] | select(.category == \"$category\" and .status == \"pass\")] | length" "$FEATURE_LIST")
    CAT_PCT=$((CAT_PASS * 100 / CAT_TOTAL))
    
    # Color based on completion
    if [ $CAT_PCT -eq 100 ]; then
        COLOR=$GREEN
    elif [ $CAT_PCT -ge 50 ]; then
        COLOR=$YELLOW
    else
        COLOR=$RED
    fi
    
    printf "  %-35s ${COLOR}%3d%%${NC} (%2d/%2d)\n" "$category" "$CAT_PCT" "$CAT_PASS" "$CAT_TOTAL"
done <<< "$CATEGORIES"

echo ""

# Blocked features (if any)
if [ $BLOCKED -gt 0 ]; then
    echo -e "${RED}⚠️  Blocked Features:${NC}"
    jq -r '.features[] | select(.status == "blocked") | "  - \(.id): \(.name)"' "$FEATURE_LIST"
    echo ""
fi

# Recent completions (last 5)
echo -e "${BLUE}Recent Completions:${NC}"
if [ -f "$BUILD_LOG" ]; then
    grep "^### FEATURE_" "$BUILD_LOG" | tail -5 | sed 's/^### /  - /'
else
    echo "  (Build log not found)"
fi

echo ""

# Estimate completion
if [ $PENDING -gt 0 ]; then
    # Estimate based on average time per feature (rough)
    AVG_TIME_MIN=5
    REMAINING_TIME=$((PENDING * AVG_TIME_MIN))
    HOURS=$((REMAINING_TIME / 60))
    MINUTES=$((REMAINING_TIME % 60))
    
    echo -e "${BLUE}Estimated Completion:${NC}"
    echo -e "  Remaining Features: ${PENDING}"
    echo -e "  Est. Time:          ~${HOURS}h ${MINUTES}m (at ${AVG_TIME_MIN} min/feature)"
    echo ""
fi

# Watch mode (if requested)
if [ "${1:-}" = "--watch" ] || [ "${1:-}" = "-w" ]; then
    echo -e "${YELLOW}Watching for updates... (Press Ctrl+C to stop)${NC}"
    echo ""
    
    while true; do
        sleep 5
        clear
        bash "$0"  # Re-run this script
    done
fi
