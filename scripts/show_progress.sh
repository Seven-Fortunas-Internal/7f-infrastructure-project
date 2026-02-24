#!/bin/bash
# Progress Tracking Script for Seven Fortunas Autonomous Implementation
#
# Provides real-time visibility into:
# - Feature completion status
# - Current session progress
# - Elapsed time
# - Blocked features
# - Recent activity

PROJECT_DIR="/home/ladmin/dev/GDF/7F_github"
cd "$PROJECT_DIR"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

clear

echo "============================================================"
echo "  Seven Fortunas - Autonomous Implementation Progress"
echo "============================================================"
echo

# Parse claude-progress.txt
if [ -f "claude-progress.txt" ]; then
    SESSION_COUNT=$(grep "^session_count=" claude-progress.txt | cut -d= -f2)
    FEATURES_COMPLETED=$(grep "^features_completed=" claude-progress.txt | cut -d= -f2)
    FEATURES_PENDING=$(grep "^features_pending=" claude-progress.txt | cut -d= -f2)
    FEATURES_FAIL=$(grep "^features_fail=" claude-progress.txt | cut -d= -f2)
    FEATURES_BLOCKED=$(grep "^features_blocked=" claude-progress.txt | cut -d= -f2)
    CIRCUIT_BREAKER=$(grep "^circuit_breaker_status=" claude-progress.txt | cut -d= -f2)
    CONSECUTIVE_FAILURES=$(grep "^consecutive_failures=" claude-progress.txt | cut -d= -f2)
    LAST_UPDATED=$(grep "^last_updated=" claude-progress.txt | cut -d= -f2)
else
    echo "Error: claude-progress.txt not found"
    exit 1
fi

# Calculate totals and percentages
TOTAL_FEATURES=$((FEATURES_COMPLETED + FEATURES_PENDING + FEATURES_FAIL + FEATURES_BLOCKED))
if [ $TOTAL_FEATURES -gt 0 ]; then
    COMPLETION_PCT=$((FEATURES_COMPLETED * 100 / TOTAL_FEATURES))
else
    COMPLETION_PCT=0
fi

# Display summary
echo "📊 Overall Progress"
echo "------------------------------------------------------------"
printf "Completion: ${GREEN}%d%%${NC} (%d of %d features)\n" "$COMPLETION_PCT" "$FEATURES_COMPLETED" "$TOTAL_FEATURES"
echo
printf "  ${GREEN}✓${NC} Passing:    %d\n" "$FEATURES_COMPLETED"
printf "  ${BLUE}○${NC} Pending:    %d\n" "$FEATURES_PENDING"
printf "  ${YELLOW}△${NC} Failed:     %d\n" "$FEATURES_FAIL"
printf "  ${RED}✗${NC} Blocked:    %d\n" "$FEATURES_BLOCKED"
echo
echo "Session Count: $SESSION_COUNT"
echo "Last Updated: $LAST_UPDATED"
echo

# Circuit breaker status
echo "⚡ Circuit Breaker"
echo "------------------------------------------------------------"
if [ "$CIRCUIT_BREAKER" == "HEALTHY" ]; then
    printf "Status: ${GREEN}HEALTHY${NC}\n"
else
    printf "Status: ${RED}%s${NC}\n" "$CIRCUIT_BREAKER"
fi
printf "Consecutive Failures: %d/5\n" "$CONSECUTIVE_FAILURES"
echo

# Show blocked features (if any)
if [ "$FEATURES_BLOCKED" -gt 0 ]; then
    echo "🚫 Blocked Features"
    echo "------------------------------------------------------------"
    jq -r '.features[] | select(.status == "blocked") | "  - \(.id): \(.name)"' feature_list.json
    echo
fi

# Show recently completed features (last 5)
echo "✅ Recently Completed (last 5)"
echo "------------------------------------------------------------"
tail -n 5 claude-progress.txt | grep "FEATURE_" | tail -5 || echo "  No recent completions"
echo

# Show next pending features (next 5)
NEXT_FEATURES=$(jq -r '.features[] | select(.status == "pending") | .id' feature_list.json | head -5)
if [ -n "$NEXT_FEATURES" ]; then
    echo "⏭️  Next Pending Features"
    echo "------------------------------------------------------------"
    echo "$NEXT_FEATURES" | while read -r fid; do
        FNAME=$(jq -r ".features[] | select(.id == \"$fid\") | .name" feature_list.json)
        echo "  - $fid: $FNAME"
    done
    echo
fi

# Progress bar visualization
echo "📈 Visual Progress"
echo "------------------------------------------------------------"
BAR_WIDTH=50
COMPLETED_WIDTH=$((COMPLETION_PCT * BAR_WIDTH / 100))
PENDING_WIDTH=$((BAR_WIDTH - COMPLETED_WIDTH))

printf "["
printf "${GREEN}%${COMPLETED_WIDTH}s${NC}" | tr ' ' '='
printf "%${PENDING_WIDTH}s" | tr ' ' '-'
printf "] %d%%\n" "$COMPLETION_PCT"
echo

# Session statistics (from session_progress.json)
if [ -f "session_progress.json" ]; then
    echo "📊 Session Statistics"
    echo "------------------------------------------------------------"
    jq -r '"Total Sessions: \(.session_count)"' session_progress.json
    jq -r '"Last Session Success: \(.last_session_success)"' session_progress.json
    jq -r '"Consecutive Failed: \(.consecutive_failed_sessions)/5"' session_progress.json
    echo
fi

# Recent activity (last 10 lines of build log)
echo "📝 Recent Activity (last 10 entries)"
echo "------------------------------------------------------------"
grep -E "^### FEATURE_|^\*\*Started:" autonomous_build_log.md | tail -10 || echo "  No recent activity"
echo

echo "============================================================"
echo "💡 Commands:"
echo "  tail -f autonomous_build_log.md  # Watch real-time progress"
echo "  jq . feature_list.json            # View all feature details"
echo "  watch -n 5 scripts/show_progress.sh  # Auto-refresh every 5s"
echo "============================================================"
