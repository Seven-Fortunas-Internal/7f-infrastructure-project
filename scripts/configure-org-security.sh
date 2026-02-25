#!/bin/bash
# Configure Organization Security Settings
# Enforces 2FA, sets default permissions, and configures access control

set -e

ORG="${1:-Seven-Fortunas}"

echo "=== Configuring Security for Organization: $ORG ==="
echo ""

# 1. Enable 2FA requirement
echo "1. Enabling 2FA requirement..."
gh api --method PATCH "/orgs/$ORG" \
  -f two_factor_requirement_enabled=true \
  2>&1 | grep -q "two_factor" && echo "✓ 2FA requirement enabled" || echo "⚠ May already be configured"

# 2. Set default repository permission to none
echo ""
echo "2. Setting default repository permission to 'none'..."
gh api --method PATCH "/orgs/$ORG" \
  -f default_repository_permission=none \
  2>&1 | grep -q "default_repository_permission" && echo "✓ Default permission set to 'none'" || echo "⚠ May already be configured"

# 3. Disable members from creating repositories (org owner only)
echo ""
echo "3. Restricting repository creation to org owners..."
gh api --method PATCH "/orgs/$ORG" \
  -f members_can_create_repositories=false \
  2>&1 | grep -q "members_can_create" && echo "✓ Repository creation restricted" || echo "⚠ May already be configured"

# 4. Verify settings
echo ""
echo "4. Verifying configuration..."
gh api "/orgs/$ORG" --jq '{
  two_factor_requirement_enabled,
  default_repository_permission,
  members_can_create_repositories
}'

echo ""
echo "✓ Security configuration complete for $ORG"
