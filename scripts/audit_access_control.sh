#!/bin/bash
# Audit Access Control Configuration

set -e

ORG_NAME="Seven-Fortunas-Internal"

echo "=== Access Control Audit Report ==="
echo "Organization: $ORG_NAME"
echo "Date: $(date -u +%Y-%m-%d)"
echo ""

# Check 2FA requirement
echo "## 2FA Requirement"
gh api "/orgs/$ORG_NAME" --jq '.two_factor_requirement_enabled' | \
    awk '{print ($1 == "true" ? "✓ Enabled" : "✗ Disabled")}'

# Check default repository permission
echo ""
echo "## Default Repository Permission"
gh api "/orgs/$ORG_NAME" --jq '.default_repository_permission' | \
    awk '{print "Default permission: " $1}'

# Check repository creation permissions
echo ""
echo "## Repository Creation Permissions"
gh api "/orgs/$ORG_NAME" --jq '{
    members_can_create_repositories,
    members_can_create_public_repositories,
    members_can_create_private_repositories
}' | grep -E "true|false" | \
    awk '{print "  " $1 " " $2}'

# List teams
echo ""
echo "## Teams"
gh api "/orgs/$ORG_NAME/teams" --jq '.[] | "  - \(.name) (\(.members_count) members)"'

# List members
echo ""
echo "## Members"
MEMBER_COUNT=$(gh api "/orgs/$ORG_NAME/members" --jq '. | length')
echo "Total members: $MEMBER_COUNT"

echo ""
echo "=== Audit Complete ==="
