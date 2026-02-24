#!/bin/bash
#
# Seven Fortunas - Autonomous Implementation Launcher
#
# Usage:
#   ./scripts/run-autonomous.sh                      # Continuous (max 10 iterations)
#   ./scripts/run-autonomous.sh --single             # Single iteration (debug)
#   ./scripts/run-autonomous.sh --model opus         # Use different model
#   ./scripts/run-autonomous.sh --max-iterations 5   # Custom iteration limit
#   ./scripts/run-autonomous.sh --log-file session.log  # Save output to file
#
# Features:
#   - Pre-flight checks (git, app_spec.txt, venv, dependencies)
#   - Automatic venv setup and dependency installation
#   - Progress display before launch
#   - Circuit breaker detection (exit code 42)
#   - Pass-through arguments to agent.py
#   - Output logging to file (optional)

set -euo pipefail

# Parse --log-file argument (extract it before passing to agent.py)
LOG_FILE=""
AGENT_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --log-file)
            LOG_FILE="$2"
            shift 2
            ;;
        *)
            AGENT_ARGS+=("$1")
            shift
            ;;
    esac
done

# Determine paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTONOMOUS_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$(dirname "$AUTONOMOUS_DIR")"
VENV_PYTHON="$PROJECT_DIR/venv/bin/python"
AGENT_SCRIPT="$AUTONOMOUS_DIR/agent.py"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Change to project directory
cd "$PROJECT_DIR"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE} Seven Fortunas - Autonomous Implementation${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# ═══════════════════════════════════════════════════════
# Pre-Flight Checks
# ═══════════════════════════════════════════════════════

echo -e "${BLUE}=== Pre-Flight Checks ===${NC}"
echo ""

# 1. Git repository
echo -n "Checking git repository... "
if [ ! -d ".git" ]; then
    echo -e "${RED}FAILED${NC}"
    echo -e "${RED}ERROR: Not a git repository${NC}"
    echo "Expected: $PROJECT_DIR/.git"
    exit 1
fi
echo -e "${GREEN}OK${NC}"

# 2. app_spec.txt
echo -n "Checking app_spec.txt... "
if [ ! -f "app_spec.txt" ]; then
    echo -e "${RED}FAILED${NC}"
    echo -e "${RED}ERROR: app_spec.txt not found${NC}"
    echo "Expected: $PROJECT_DIR/app_spec.txt"
    echo ""
    echo "Create app_spec.txt using:"
    echo "  /bmad-bmm-create-app-spec"
    exit 1
fi
echo -e "${GREEN}OK${NC}"

# 3. Python 3
echo -n "Checking Python 3... "
if ! command -v python3 &>/dev/null; then
    echo -e "${RED}FAILED${NC}"
    echo -e "${RED}ERROR: Python 3 not found${NC}"
    echo "Install Python 3.8+ from: https://www.python.org/"
    exit 1
fi
PYTHON_VERSION=$(python3 --version)
echo -e "${GREEN}OK${NC} ($PYTHON_VERSION)"

# 4. Python venv
echo -n "Checking Python venv... "
if [ ! -f "$VENV_PYTHON" ]; then
    echo -e "${YELLOW}NOT FOUND${NC}"
    echo "Creating Python virtual environment..."
    python3 -m venv venv
    ./venv/bin/pip install --upgrade pip --quiet
    echo -e "${GREEN}CREATED${NC}"
else
    echo -e "${GREEN}OK${NC}"
fi

# 5. claude-agent-sdk
echo -n "Checking claude-agent-sdk... "
if ! ./venv/bin/python -c "import claude_agent_sdk" 2>/dev/null; then
    echo -e "${YELLOW}NOT INSTALLED${NC}"
    echo "Installing claude-agent-sdk..."
    ./venv/bin/pip install claude-agent-sdk --quiet
    echo -e "${GREEN}INSTALLED${NC}"
else
    echo -e "${GREEN}OK${NC}"
fi

# 6. jq (JSON processor)
echo -n "Checking jq... "
if ! command -v jq &>/dev/null; then
    echo -e "${YELLOW}NOT FOUND${NC}"
    echo -e "${YELLOW}WARNING: jq not installed (optional but recommended)${NC}"
    echo "Install: sudo apt-get install jq"
else
    echo -e "${GREEN}OK${NC}"
fi

echo ""
echo -e "${GREEN}✓ All pre-flight checks passed${NC}"
echo ""

# ═══════════════════════════════════════════════════════
# Display Progress (if continuing)
# ═══════════════════════════════════════════════════════

if [ -f "feature_list.json" ]; then
    echo -e "${BLUE}=== Current Progress ===${NC}"
    echo ""

    if command -v jq &>/dev/null; then
        # Use jq for accurate counts
        TOTAL=$(jq '.metadata.total_features' feature_list.json 2>/dev/null || echo "?")
        PASS=$(jq '[.features[] | select(.status == "pass")] | length' feature_list.json 2>/dev/null || echo "0")
        PENDING=$(jq '[.features[] | select(.status == "pending")] | length' feature_list.json 2>/dev/null || echo "0")
        FAIL=$(jq '[.features[] | select(.status == "fail")] | length' feature_list.json 2>/dev/null || echo "0")
        BLOCKED=$(jq '[.features[] | select(.status == "blocked")] | length' feature_list.json 2>/dev/null || echo "0")

        if [ "$TOTAL" != "?" ]; then
            PERCENTAGE=$((PASS * 100 / TOTAL))
            echo "Total Features: $TOTAL"
            echo "Progress: $PASS/$TOTAL ($PERCENTAGE%)"
            echo ""
            echo "By Status:"
            echo "  ${GREEN}✓ Pass:${NC} $PASS"
            echo "  ${YELLOW}⏳ Pending:${NC} $PENDING"
            echo "  ${RED}❌ Fail:${NC} $FAIL"
            echo "  ${RED}🚫 Blocked:${NC} $BLOCKED"
        fi
    else
        # Fallback to grep (less accurate)
        PASS=$(grep -o '"status": "pass"' feature_list.json 2>/dev/null | wc -l)
        PENDING=$(grep -o '"status": "pending"' feature_list.json 2>/dev/null | wc -l)
        FAIL=$(grep -o '"status": "fail"' feature_list.json 2>/dev/null | wc -l)
        BLOCKED=$(grep -o '"status": "blocked"' feature_list.json 2>/dev/null | wc -l)

        echo "Progress: $PASS passing, $PENDING pending, $FAIL failed, $BLOCKED blocked"
    fi

    echo ""
else
    echo -e "${BLUE}=== Fresh Start ===${NC}"
    echo ""
    echo "No existing feature_list.json found."
    echo "Agent will run Session 1 (Initializer) to parse app_spec.txt."
    echo ""
fi

# ═══════════════════════════════════════════════════════
# Launch Agent
# ═══════════════════════════════════════════════════════

echo -e "${BLUE}=== Starting Autonomous Agent ===${NC}"
echo ""
echo "Agent: $AGENT_SCRIPT"
echo "Arguments: $*"
echo ""
echo "Press Ctrl+C to stop at any time."
echo ""
echo "-" * 60
echo ""

# Run agent with all passed arguments
set +e  # Don't exit on agent error (we want to handle exit codes)

if [[ -n "$LOG_FILE" ]]; then
    echo "Output will be logged to: $LOG_FILE"
    echo ""
    "$VENV_PYTHON" "$AGENT_SCRIPT" "${AGENT_ARGS[@]}" 2>&1 | tee "$LOG_FILE"
    EXIT_CODE=${PIPESTATUS[0]}
else
    "$VENV_PYTHON" "$AGENT_SCRIPT" "${AGENT_ARGS[@]}"
    EXIT_CODE=$?
fi

set -e

echo ""
echo "-" * 60
echo ""

# ═══════════════════════════════════════════════════════
# Handle Exit Codes
# ═══════════════════════════════════════════════════════

if [ $EXIT_CODE -eq 0 ]; then
    # Success
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN} Agent Completed Successfully${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo ""

    if [ -f "feature_list.json" ] && command -v jq &>/dev/null; then
        PASS=$(jq '[.features[] | select(.status == "pass")] | length' feature_list.json 2>/dev/null || echo "0")
        REMAINING=$(jq '[.features[] | select(.status == "pending" or (.status == "fail" and .attempts < 3))] | length' feature_list.json 2>/dev/null || echo "?")

        if [ "$REMAINING" = "0" ] && [ "$PASS" -gt 0 ]; then
            echo -e "${GREEN}🎉 ALL FEATURES COMPLETE!${NC}"
            echo ""
            echo "Total features implemented: $PASS"
            echo ""
            echo "Next steps:"
            echo "  1. Review autonomous_build_log.md for implementation details"
            echo "  2. Run validation: /bmad-bmm-run-autonomous-implementation --mode=validate"
            echo "  3. Deploy to production (if ready)"
        else
            echo "Progress: $PASS features complete, $REMAINING remaining"
            echo ""
            echo "To continue:"
            echo "  ./autonomous-implementation/scripts/run-autonomous.sh"
        fi
    fi

elif [ $EXIT_CODE -eq 42 ]; then
    # Circuit breaker triggered
    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW} CIRCUIT BREAKER TRIGGERED${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}The autonomous agent stopped after detecting repeated failures.${NC}"
    echo ""
    echo "Review logs:"
    echo "  - autonomous_build_log.md (detailed implementation log)"
    echo "  - issues.log (error tracking)"
    echo "  - claude-progress.txt (session history)"
    echo ""
    echo "To investigate and resume:"
    echo "  1. Check blocked/failed features: jq '.features[] | select(.status == \"fail\" or .status == \"blocked\")' feature_list.json"
    echo "  2. Fix external blockers (API auth, dependencies, etc.)"
    echo "  3. Reset features: /bmad-bmm-run-autonomous-implementation --mode=edit"
    echo "  4. Restart: ./autonomous-implementation/scripts/run-autonomous.sh"
    echo ""

else
    # Other error
    echo -e "${RED}═══════════════════════════════════════════════════════${NC}"
    echo -e "${RED} Agent Exited With Error (Code: $EXIT_CODE)${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Check logs for details:"
    echo "  - issues.log (error tracking)"
    echo "  - autonomous_build_log.md (session log)"
    echo ""

    if [ -f "issues.log" ]; then
        echo "Recent errors:"
        tail -10 issues.log | sed 's/^/  /'
        echo ""
    fi
fi

exit $EXIT_CODE
