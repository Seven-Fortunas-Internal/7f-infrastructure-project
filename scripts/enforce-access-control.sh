#!/bin/bash
# Access Control Enforcement
# Enforces organization-level security settings

set -euo pipefail

ORG_NAME="Seven-Fortunas-Internal"

echo "=== Access Control Enforcement ==="
echo "Organization: $ORG_NAME"
echo "Date: $(date)"
echo ""

# Verify GitHub authentication
if ! gh auth status &>/dev/null; then
    echo "ERROR: GitHub CLI not authenticated"
    exit 1
fi

echo "1. Enforcing 2FA requirement..."
# Enable 2FA requirement (requires admin:org scope)
if gh api -X PATCH "orgs/$ORG_NAME" -f two_factor_requirement_enabled=true &>/dev/null; then
    echo "  ✓ 2FA requirement enabled"
else
    echo "  ⚠ Could not enforce 2FA (requires admin:org scope)"
fi

echo ""
echo "2. Setting default repository permission to 'none'..."
if gh api -X PATCH "orgs/$ORG_NAME" -f default_repository_permission=none &>/dev/null; then
    echo "  ✓ Default permission set to 'none'"
else
    echo "  ⚠ Could not set default permission (requires admin:org scope)"
fi

echo ""
echo "3. Restricting member capabilities..."

# Members cannot create repositories
if gh api -X PATCH "orgs/$ORG_NAME" -f members_can_create_repositories=false &>/dev/null; then
    echo "  ✓ Members cannot create repositories"
fi

# Members cannot create teams
if gh api -X PATCH "orgs/$ORG_NAME" -f members_can_create_teams=false &>/dev/null; then
    echo "  ✓ Members cannot create teams"
fi

# Members cannot change repository visibility
if gh api -X PATCH "orgs/$ORG_NAME" -f members_can_change_repo_visibility=false &>/dev/null; then
    echo "  ✓ Members cannot change repository visibility"
fi

echo ""
echo "✓ Access control enforcement complete"
