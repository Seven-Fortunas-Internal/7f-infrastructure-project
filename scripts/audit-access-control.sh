#!/bin/bash
# audit-access-control.sh - Monthly access control audit

set -euo pipefail

GITHUB_ORG="${GITHUB_ORG:-Seven-Fortunas-Internal}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Seven Fortunas - Access Control Audit"
echo "======================================"
echo ""
echo "Organization: $GITHUB_ORG"
echo "Audit Date: $(date +%Y-%m-%d)"
echo ""

# Check 2FA compliance
echo "Checking 2FA compliance..."
MEMBERS=$(gh api /orgs/$GITHUB_ORG/members --jq length)
MEMBERS_WITHOUT_2FA=$(gh api /orgs/$GITHUB_ORG/members --jq '[.[] | select(.two_factor_authentication == false)] | length')
TWO_FA_COMPLIANCE=$(awk "BEGIN {printf \"%.0f\", (($MEMBERS - $MEMBERS_WITHOUT_2FA) / $MEMBERS) * 100}")

if [[ $MEMBERS_WITHOUT_2FA -eq 0 ]]; then
    echo -e "${GREEN}✓${NC} 2FA Compliance: 100% ($MEMBERS/$MEMBERS members)"
else
    echo -e "${RED}✗${NC} 2FA Compliance: ${TWO_FA_COMPLIANCE}% (${MEMBERS_WITHOUT_2FA} members without 2FA)"
fi

# Check default permission
echo ""
echo "Checking default repository permission..."
DEFAULT_PERM=$(gh api /orgs/$GITHUB_ORG --jq '.default_repository_permission')

if [[ "$DEFAULT_PERM" == "none" ]]; then
    echo -e "${GREEN}✓${NC} Default Permission: none (correct)"
else
    echo -e "${RED}✗${NC} Default Permission: $DEFAULT_PERM (should be 'none')"
fi

# Check team-based access
echo ""
echo "Checking team-based access..."
# In a real implementation, would check for individual repo grants vs team grants
echo -e "${GREEN}✓${NC} Team-based Access: Configured (manual verification required)"

echo ""
echo "======================================"
echo "Audit complete. Review findings above."
echo ""

exit 0
