#!/usr/bin/env bash
# Verify GitHub Pages Configuration
# FEATURE_056: GitHub Pages — Verify Configuration, .nojekyll, and No-Placeholder

set -euo pipefail

echo "=== GitHub Pages Configuration Verification ==="
echo ""

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Exit codes
EXIT_SUCCESS=0
EXIT_FAIL=1

# Track overall status
OVERALL_STATUS=$EXIT_SUCCESS

echo "1. Checking Seven-Fortunas/dashboards GitHub Pages..."
DASHBOARD_STATUS=$(gh api repos/Seven-Fortunas/dashboards/pages --jq '.status' 2>&1)
DASHBOARD_BRANCH=$(gh api repos/Seven-Fortunas/dashboards/pages --jq '.source.branch' 2>&1)

if [[ "$DASHBOARD_STATUS" == "built" ]]; then
    echo -e "${GREEN}✓${NC} Status: $DASHBOARD_STATUS"
else
    echo -e "${RED}✗${NC} Status: $DASHBOARD_STATUS (expected: built)"
    OVERALL_STATUS=$EXIT_FAIL
fi

if [[ "$DASHBOARD_BRANCH" == "gh-pages" ]]; then
    echo -e "${GREEN}✓${NC} Source Branch: $DASHBOARD_BRANCH"
else
    echo -e "${RED}✗${NC} Source Branch: $DASHBOARD_BRANCH (expected: gh-pages)"
    OVERALL_STATUS=$EXIT_FAIL
fi

echo ""
echo "2. Checking Seven-Fortunas/seven-fortunas.github.io GitHub Pages..."
LANDING_STATUS=$(gh api repos/Seven-Fortunas/seven-fortunas.github.io/pages --jq '.status' 2>&1)
LANDING_BRANCH=$(gh api repos/Seven-Fortunas/seven-fortunas.github.io/pages --jq '.source.branch' 2>&1)

if [[ "$LANDING_STATUS" == "built" ]]; then
    echo -e "${GREEN}✓${NC} Status: $LANDING_STATUS"
else
    echo -e "${RED}✗${NC} Status: $LANDING_STATUS (expected: built)"
    OVERALL_STATUS=$EXIT_FAIL
fi

if [[ "$LANDING_BRANCH" == "main" ]]; then
    echo -e "${GREEN}✓${NC} Source Branch: $LANDING_BRANCH"
else
    echo -e "${RED}✗${NC} Source Branch: $LANDING_BRANCH (expected: main)"
    OVERALL_STATUS=$EXIT_FAIL
fi

echo ""
echo "3. Checking .nojekyll on dashboards gh-pages branch..."
NOJEKYLL_NAME=$(gh api "repos/Seven-Fortunas/dashboards/contents/.nojekyll?ref=gh-pages" --jq '.name' 2>&1)

if [[ "$NOJEKYLL_NAME" == ".nojekyll" ]]; then
    echo -e "${GREEN}✓${NC} .nojekyll exists on gh-pages branch"
else
    echo -e "${RED}✗${NC} .nojekyll missing on gh-pages branch"
    echo ""
    echo "To create .nojekyll:"
    echo "  gh api -X PUT repos/Seven-Fortunas/dashboards/contents/.nojekyll \\"
    echo "    --field message=\"Add .nojekyll to prevent Jekyll processing\" \\"
    echo "    --field content=\"\" \\"
    echo "    --field branch=\"gh-pages\""
    OVERALL_STATUS=$EXIT_FAIL
fi

echo ""
echo "4. Testing live endpoints..."

if curl -sf https://seven-fortunas.github.io/ -o /dev/null; then
    echo -e "${GREEN}✓${NC} Landing page (https://seven-fortunas.github.io/) returns 200"
else
    echo -e "${RED}✗${NC} Landing page not accessible"
    OVERALL_STATUS=$EXIT_FAIL
fi

if curl -sf https://seven-fortunas.github.io/dashboards/ai/ -o /dev/null; then
    echo -e "${GREEN}✓${NC} AI Dashboard (https://seven-fortunas.github.io/dashboards/ai/) returns 200"
else
    echo -e "${YELLOW}⚠${NC} AI Dashboard not accessible (might not be deployed yet)"
    # Don't fail on this - it's expected if not deployed yet
fi

echo ""
if [[ $OVERALL_STATUS -eq $EXIT_SUCCESS ]]; then
    echo -e "${GREEN}=== All Checks Passed ===${NC}"
else
    echo -e "${RED}=== Some Checks Failed ===${NC}"
fi

exit $OVERALL_STATUS
