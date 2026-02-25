#!/bin/bash
# Continuous Autonomous Agent Launcher
# Runs multiple sessions until all features complete or circuit breaker triggers

set -euo pipefail

# Project configuration
PROJECT_ROOT="/home/ladmin/dev/GDF/7F_github"
cd "$PROJECT_ROOT"

# Circuit breaker configuration
MAX_SESSIONS=50
MAX_CONSECUTIVE_ERRORS=5
MAX_STALL_SESSIONS=5

# Color output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Seven Fortunas Autonomous Agent - Continuous Mode${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo ""

# Verify prerequisites
echo "Checking prerequisites..."

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
    echo -e "${RED}✗ ANTHROPIC_API_KEY not set${NC}"
    exit 1
fi
echo -e "${GREEN}✓ ANTHROPIC_API_KEY configured${NC}"

if [ ! -f "feature_list.json" ]; then
    echo -e "${RED}✗ feature_list.json not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ feature_list.json found${NC}"

# Validate GitHub CLI authentication (pre-flight check)
echo "Validating GitHub authentication..."
if bash "$PROJECT_ROOT/scripts/validate_github_auth.sh" 2>/dev/null; then
    echo -e "${GREEN}✓ GitHub CLI authenticated as jorge-at-sf${NC}"
else
    echo -e "${YELLOW}⚠ GitHub CLI authentication check failed${NC}"
    echo -e "${YELLOW}GitHub operations will be disabled, but non-GitHub operations will continue${NC}"
fi

# Initialize tracking
CONSECUTIVE_ERRORS=0
STALL_COUNT=0
LAST_PASS_COUNT=0
SESSION_NUM=0

echo ""
echo -e "${BLUE}Starting continuous agent sessions...${NC}"
echo ""

# Main loop
while [ $SESSION_NUM -lt $MAX_SESSIONS ]; do
    SESSION_NUM=$((SESSION_NUM + 1))

    echo -e "${YELLOW}─────────────────────────────────────────────────────${NC}"
    echo -e "${YELLOW}Session $SESSION_NUM${NC}"
    echo -e "${YELLOW}─────────────────────────────────────────────────────${NC}"

    # Get current status
    PENDING_COUNT=$(jq '[.features[] | select(.status == "pending")] | length' feature_list.json)
    PASS_COUNT=$(jq '[.features[] | select(.status == "pass")] | length' feature_list.json)
    TOTAL_COUNT=$(jq '.features | length' feature_list.json)

    echo "Status: $PASS_COUNT/$TOTAL_COUNT complete ($PENDING_COUNT pending)"

    # Check if all features complete
    if [ "$PENDING_COUNT" -eq 0 ]; then
        echo ""
        echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}🎉 All features completed successfully!${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
        exit 0
    fi

    # Run single session
    cd scripts
    if python3 agent.py coding 10; then
        CONSECUTIVE_ERRORS=0

        # Check for stall (no progress)
        NEW_PASS_COUNT=$(jq '[.features[] | select(.status == "pass")] | length' ../feature_list.json)
        if [ "$NEW_PASS_COUNT" -eq "$LAST_PASS_COUNT" ]; then
            STALL_COUNT=$((STALL_COUNT + 1))
            echo -e "${YELLOW}⚠ No progress this session (stall count: $STALL_COUNT/$MAX_STALL_SESSIONS)${NC}"

            if [ "$STALL_COUNT" -ge "$MAX_STALL_SESSIONS" ]; then
                echo -e "${RED}Circuit breaker: Max stall sessions reached${NC}"
                exit 1
            fi
        else
            STALL_COUNT=0
            LAST_PASS_COUNT=$NEW_PASS_COUNT
        fi

    else
        CONSECUTIVE_ERRORS=$((CONSECUTIVE_ERRORS + 1))
        echo -e "${RED}✗ Session failed (error count: $CONSECUTIVE_ERRORS/$MAX_CONSECUTIVE_ERRORS)${NC}"

        if [ "$CONSECUTIVE_ERRORS" -ge "$MAX_CONSECUTIVE_ERRORS" ]; then
            echo -e "${RED}Circuit breaker: Max consecutive errors reached${NC}"
            exit 1
        fi
    fi

    cd "$PROJECT_ROOT"

    # Brief pause between sessions
    sleep 5
done

echo ""
echo -e "${YELLOW}Max sessions ($MAX_SESSIONS) reached${NC}"
echo "Review progress and run again if needed"
