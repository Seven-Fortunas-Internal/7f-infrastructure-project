#!/bin/bash
# Single-Session Autonomous Agent Launcher
# Runs one iteration of the autonomous coding agent

set -euo pipefail

# Project configuration
PROJECT_ROOT="/home/ladmin/dev/GDF/7F_github"
cd "$PROJECT_ROOT"

# Color output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Seven Fortunas Autonomous Agent - Single Session${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo ""

# Verify prerequisites
echo "Checking prerequisites..."

# Check for ANTHROPIC_API_KEY
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
    echo -e "${RED}✗ ANTHROPIC_API_KEY not set${NC}"
    echo "Set it with: export ANTHROPIC_API_KEY='your-key-here'"
    exit 1
fi
echo -e "${GREEN}✓ ANTHROPIC_API_KEY configured${NC}"

# Check for required files
if [ ! -f "app_spec.txt" ]; then
    echo -e "${RED}✗ app_spec.txt not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ app_spec.txt found${NC}"

if [ ! -f "feature_list.json" ]; then
    echo -e "${RED}✗ feature_list.json not found${NC}"
    echo "Run initializer agent first to generate feature_list.json"
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

# Count pending features
PENDING_COUNT=$(jq '[.features[] | select(.status == "pending")] | length' feature_list.json)
PASS_COUNT=$(jq '[.features[] | select(.status == "pass")] | length' feature_list.json)
TOTAL_COUNT=$(jq '.features | length' feature_list.json)

echo ""
echo "Feature Status:"
echo "  ✓ Completed: $PASS_COUNT"
echo "  ⏳ Pending: $PENDING_COUNT"
echo "  📊 Total: $TOTAL_COUNT"
echo ""

if [ "$PENDING_COUNT" -eq 0 ]; then
    echo -e "${GREEN}All features completed! 🎉${NC}"
    exit 0
fi

# Run coding agent
echo -e "${YELLOW}Starting coding agent session...${NC}"
echo ""

cd scripts
python3 agent.py coding 10

echo ""
echo -e "${GREEN}Session complete!${NC}"
echo ""
echo "View progress:"
echo "  tail -f ../autonomous_build_log.md"
echo ""
echo "View feature status:"
echo "  jq '[.features[] | .status] | group_by(.) | map({status: .[0], count: length})' ../feature_list.json"
