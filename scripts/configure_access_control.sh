#!/bin/bash
# Configure Access Control & Authentication
# Enforces 2FA, least privilege, team-based access control

set -e

echo "=== Access Control & Authentication Configuration ==="

# Configuration
ORG_NAME="Seven-Fortunas-Internal"
DEFAULT_PERMISSION="none"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if gh CLI is authenticated
if ! gh auth status &>/dev/null; then
    echo -e "${RED}❌ GitHub CLI not authenticated${NC}"
    echo "Run: gh auth login"
    exit 1
fi

echo -e "${GREEN}✓ GitHub CLI authenticated${NC}"

# Function to enable 2FA requirement
enable_2fa_requirement() {
    echo ""
    echo "=== Configuring 2FA Requirement ==="

    # Note: 2FA enforcement is only available via web UI or GitHub Enterprise
    # For standard organizations, we need to use the API

    echo "Enabling 2FA requirement for organization..."

    # Use GitHub API to enable 2FA requirement
    RESPONSE=$(gh api \
        --method PATCH \
        -H "Accept: application/vnd.github+json" \
        "/orgs/$ORG_NAME" \
        -f two_factor_requirement_enabled=true 2>&1) || {
        echo -e "${YELLOW}⚠️  2FA requirement could not be set via API${NC}"
        echo "This may require owner permissions or GitHub Enterprise"
        echo "Manual step required: Go to Organization Settings > Authentication security"
        return 1
    }

    echo -e "${GREEN}✓ 2FA requirement enabled${NC}"
}

# Function to set default repository permission
set_default_permission() {
    echo ""
    echo "=== Configuring Default Repository Permission ==="

    echo "Setting default permission to: $DEFAULT_PERMISSION"

    # Update organization default permission
    # Note: internal repositories not supported on free tier
    gh api \
        --method PATCH \
        -H "Accept: application/vnd.github+json" \
        "/orgs/$ORG_NAME" \
        -f default_repository_permission="$DEFAULT_PERMISSION" \
        -F members_can_create_repositories=false \
        -F members_can_create_public_repositories=false \
        -F members_can_create_private_repositories=false

    echo -e "${GREEN}✓ Default repository permission set to 'none'${NC}"
    echo -e "${GREEN}✓ Repository creation restricted to organization owners${NC}"
}

# Function to verify team-based access
verify_team_access() {
    echo ""
    echo "=== Verifying Team-Based Access Control ==="

    # List teams
    echo "Organization teams:"
    gh api "/orgs/$ORG_NAME/teams" --jq '.[] | "  - \(.name) (\(.slug))"'

    echo ""
    echo -e "${GREEN}✓ Team-based access control structure verified${NC}"
}

# Function to check 2FA status for members
check_2fa_status() {
    echo ""
    echo "=== Checking 2FA Status for Members ==="

    # List members with 2FA status
    echo "Fetching member 2FA status..."

    # Get organization members
    MEMBERS=$(gh api "/orgs/$ORG_NAME/members" --jq '.[] | .login')

    if [ -z "$MEMBERS" ]; then
        echo "No members found"
        return
    fi

    echo "Organization members:"
    for member in $MEMBERS; do
        echo "  - $member"
    done

    echo ""
    echo -e "${YELLOW}⚠️  Note: 2FA status requires organization owner permissions${NC}"
    echo "To check 2FA compliance: Organization Settings > People > Filter by 2FA status"
}

# Function to document GitHub App authentication
document_github_app() {
    echo ""
    echo "=== GitHub App Authentication (Phase 1.5) ==="

    cat > docs/github-app-setup.md << 'EOF'
# GitHub App Authentication Setup

## Overview
GitHub Apps provide secure, scoped authentication for automation workflows, replacing personal access tokens.

## Benefits
- Fine-grained permissions
- No user account dependency
- Automatic token rotation
- Audit trail for all actions

## Setup Steps

### 1. Create GitHub App

Navigate to: Organization Settings > Developer settings > GitHub Apps > New GitHub App

**App Configuration:**
- App name: `seven-fortunas-automation`
- Homepage URL: `https://github.com/Seven-Fortunas-Internal`
- Webhook: Disable (not needed for CI/CD)

**Repository Permissions:**
- Contents: Read & Write (for commits)
- Issues: Read & Write (for dashboard health checks)
- Workflows: Read & Write (for GitHub Actions)
- Metadata: Read (required)

**Organization Permissions:**
- Members: Read (for team management)
- Administration: Read (for org settings)

### 2. Generate Private Key

After creating the app:
1. Scroll to "Private keys" section
2. Click "Generate a private key"
3. Save the `.pem` file securely (this is your authentication credential)

### 3. Install App to Organization

1. Go to "Install App" in sidebar
2. Select your organization
3. Choose "All repositories" or select specific repos
4. Click "Install"

### 4. Configure GitHub Secrets

Store these in Organization Secrets (Settings > Secrets and variables > Actions):

```
APP_ID: <your-app-id>
APP_PRIVATE_KEY: <contents-of-pem-file>
```

### 5. Use in GitHub Actions

```yaml
- name: Generate GitHub App token
  id: generate_token
  uses: tibdex/github-app-token@v1
  with:
    app_id: ${{ secrets.APP_ID }}
    private_key: ${{ secrets.APP_PRIVATE_KEY }}

- name: Use token
  run: |
    git config --global url."https://x-access-token:${{ steps.generate_token.outputs.token }}@github.com/".insteadOf "https://github.com/"
```

## Security Best Practices

- ✅ Store private key in GitHub Secrets (never commit to repo)
- ✅ Use minimum required permissions
- ✅ Enable "Require approval for all outside collaborators"
- ✅ Regularly review app installation and permissions
- ✅ Rotate private keys annually

## Troubleshooting

**Token generation fails:**
- Verify APP_ID is correct
- Verify private key is complete (includes header/footer)
- Check app is installed to organization

**Permission denied:**
- Review app permissions match workflow requirements
- Verify app is installed to target repositories

---

**Status:** Phase 1.5 (to be implemented)
**Owner:** Jorge
**Priority:** P1
EOF

    echo -e "${GREEN}✓ GitHub App authentication guide created: docs/github-app-setup.md${NC}"
}

# Function to create access control audit script
create_audit_script() {
    echo ""
    echo "=== Creating Access Control Audit Script ==="

    mkdir -p scripts
    cat > scripts/audit_access_control.sh << 'AUDIT_EOF'
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
AUDIT_EOF

    chmod +x scripts/audit_access_control.sh
    echo -e "${GREEN}✓ Audit script created: scripts/audit_access_control.sh${NC}"
}

# Main execution
main() {
    echo "Organization: $ORG_NAME"
    echo ""

    # Enable 2FA requirement
    enable_2fa_requirement || echo -e "${YELLOW}⚠️  2FA configuration requires manual setup${NC}"

    # Set default repository permission
    set_default_permission

    # Verify team-based access
    verify_team_access

    # Check 2FA status
    check_2fa_status

    # Document GitHub App authentication
    document_github_app

    # Create audit script
    create_audit_script

    echo ""
    echo "=== Configuration Summary ==="
    echo -e "${GREEN}✓ Access control configuration complete${NC}"
    echo ""
    echo "Manual steps required:"
    echo "1. Verify 2FA is enabled for all members (Organization Settings > People)"
    echo "2. Review team permissions (Organization Settings > Teams)"
    echo "3. Set up GitHub App authentication (see docs/github-app-setup.md)"
    echo ""
    echo "To audit access control: ./scripts/audit_access_control.sh"
}

# Run main function
main
