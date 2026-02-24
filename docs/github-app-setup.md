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
