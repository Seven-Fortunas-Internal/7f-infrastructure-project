#!/bin/bash
# Verify Access Control & Authentication (FR-5.3)
# Part of FEATURE_021 implementation

set -euo pipefail

echo "=== Access Control & Authentication Verification ==="
echo ""

# Check Seven-Fortunas organization
echo "1. Checking Seven-Fortunas organization settings..."
ORG_SETTINGS=$(gh api /orgs/Seven-Fortunas)

TWO_FA=$(echo "$ORG_SETTINGS" | jq -r '.two_factor_requirement_enabled')
DEFAULT_PERM=$(echo "$ORG_SETTINGS" | jq -r '.default_repository_permission')

echo "   - 2FA Enforcement: $TWO_FA"
echo "   - Default Repository Permission: $DEFAULT_PERM"

# Check members
echo ""
echo "2. Checking organization members..."
MEMBERS=$(gh api /orgs/Seven-Fortunas/members)
MEMBER_COUNT=$(echo "$MEMBERS" | jq 'length')
echo "   - Total members: $MEMBER_COUNT"
echo "$MEMBERS" | jq -r '.[] | "     - \(.login)"'

# Check teams
echo ""
echo "3. Checking team-based access control..."
TEAMS=$(gh api /orgs/Seven-Fortunas/teams)
TEAM_COUNT=$(echo "$TEAMS" | jq 'length')
echo "   - Total teams: $TEAM_COUNT"
echo "$TEAMS" | jq -r '.[] | "     - \(.name) (\(.permission))"'

# Verify principle of least privilege
echo ""
echo "4. Principle of Least Privilege Verification..."
if test "$DEFAULT_PERM" = "none"; then
    echo "   ✓ Default repository permission is 'none' (correct)"
else
    echo "   ✗ Default repository permission is '$DEFAULT_PERM' (should be 'none')"
fi

# Summary
echo ""
echo "=== Summary ==="
echo "Default Repository Permission: $DEFAULT_PERM"
echo "2FA Enforcement: $TWO_FA"
echo "Members: $MEMBER_COUNT"
echo "Teams: $TEAM_COUNT"
echo ""

if test "$TWO_FA" = "true" && test "$DEFAULT_PERM" = "none" && test "$TEAM_COUNT" -gt 0; then
    echo "✓ Access control fully configured"
    exit 0
elif test "$DEFAULT_PERM" = "none" && test "$TEAM_COUNT" -gt 0; then
    echo "⚠️  Access control partially configured (2FA enforcement requires manual setup)"
    exit 0
else
    echo "✗ Access control configuration incomplete"
    exit 1
fi
