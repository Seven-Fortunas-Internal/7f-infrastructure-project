#!/bin/bash
# FEATURE_032: Shared Secrets Management
# Sets up GitHub org-level secrets for API key sharing between founders

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== FEATURE_032: Shared Secrets Management Setup ==="
echo ""

# Configuration
ORG_NAME="Seven-Fortunas-Internal"

# Verify GitHub authentication
echo "1. Verifying GitHub authentication..."
if ! gh auth status &>/dev/null; then
    echo "ERROR: GitHub CLI not authenticated. Run: gh auth login"
    exit 1
fi
echo "✓ GitHub authenticated"
echo ""

# Check organization access
echo "2. Verifying organization access..."
if ! gh api "orgs/$ORG_NAME" &>/dev/null; then
    echo "ERROR: Cannot access organization: $ORG_NAME"
    echo "Please ensure you have admin access to the organization."
    exit 1
fi
echo "✓ Organization access verified: $ORG_NAME"
echo ""

# Create documentation for secrets management
echo "3. Creating secrets management documentation..."
mkdir -p "$PROJECT_ROOT/docs/security"

cat > "$PROJECT_ROOT/docs/security/secrets-management.md" << 'EOF'
# Shared Secrets Management

## Overview
Seven Fortunas uses GitHub organization-level secrets for secure API key sharing between founders.

## For Founders: Storing Secrets

### Using GitHub CLI
```bash
# Store a new secret
gh secret set API_KEY_NAME --org Seven-Fortunas-Internal --body "your-secret-value"

# Store from file
gh secret set API_KEY_NAME --org Seven-Fortunas-Internal < secret-file.txt

# Interactive entry (prompts for value)
gh secret set API_KEY_NAME --org Seven-Fortunas-Internal
```

### Using GitHub Web UI
1. Navigate to: https://github.com/organizations/Seven-Fortunas-Internal/settings/secrets/actions
2. Click "New organization secret"
3. Enter secret name and value
4. Select repository access (all repos or specific repos)
5. Click "Add secret"

## For Founders: Retrieving Secrets

### Using GitHub Web UI
1. Navigate to: https://github.com/organizations/Seven-Fortunas-Internal/settings/secrets/actions
2. View list of available secrets (values are masked)
3. Use "Update" to change or "Remove" to delete

### Using GitHub API
```bash
# List all organization secrets
gh api orgs/Seven-Fortunas-Internal/actions/secrets

# Get specific secret metadata (value is not returned for security)
gh api orgs/Seven-Fortunas-Internal/actions/secrets/API_KEY_NAME
```

**Note:** Secret values cannot be retrieved via API for security reasons. Secrets can only be used in GitHub Actions workflows or updated/deleted.

## Using Secrets in GitHub Actions

### Workflow Configuration
```yaml
name: Example Workflow
on: [push]
jobs:
  example:
    runs-on: ubuntu-latest
    steps:
      - name: Use secret
        env:
          API_KEY: ${{ secrets.API_KEY_NAME }}
        run: |
          echo "Secret is available (masked in logs)"
          # Use $API_KEY in your commands
```

## 7f-secrets-manager Skill

Use the custom Claude skill for conversational secrets management:

```
/7f-secrets-manager
```

**Capabilities:**
- List available secrets
- Guide secret rotation procedures
- Document secret usage across repositories
- Audit secret access patterns (Phase 3)

## Security Best Practices

### Secret Naming
- Use descriptive names: `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`
- Prefix with service: `AWS_ACCESS_KEY_ID`, `GCP_SERVICE_ACCOUNT`
- Avoid generic names: `SECRET`, `KEY`, `PASSWORD`

### Secret Rotation
1. Create new secret value with provider
2. Update GitHub secret: `gh secret set KEY_NAME --org Seven-Fortunas-Internal`
3. Test in non-production workflows
4. Monitor for failures
5. Deactivate old secret value

### Access Control
- Organization secrets are accessible to all org members with appropriate permissions
- Repository-level secrets for sensitive keys (limit to specific repos)
- Use environment protection rules for production secrets (Phase 2)

## Encryption

- **At Rest:** GitHub encrypts secrets using libsodium sealed boxes before storage
- **In Transit:** All API calls use HTTPS/TLS 1.2+
- **In Use:** Secrets are masked in workflow logs

## Audit Logging (Phase 3)

Track secret access via:
- GitHub audit log API
- Organization security events
- Workflow run logs (access times only, not values)

## Troubleshooting

### "Secret not found" in workflow
- Verify secret name matches exactly (case-sensitive)
- Check repository has access to org-level secret
- Confirm secret is set at organization level, not repository level

### Cannot update secret via CLI
- Ensure you have admin access to organization
- Re-authenticate: `gh auth login --scopes admin:org`
- Check GitHub CLI version: `gh --version` (use v2.0.0+)

### Secret not working in forked repository
- Organization secrets are not available to forked repositories for security
- Use repository-specific secrets for fork testing

## Migration from Other Secret Managers

If migrating from 1Password, AWS Secrets Manager, or similar:

1. **Export secrets** (follow provider's export procedures)
2. **Import to GitHub:**
   ```bash
   # Example batch import script
   while IFS=, read -r name value; do
       gh secret set "$name" --org Seven-Fortunas-Internal --body "$value"
   done < secrets.csv
   ```
3. **Update workflows** to use `${{ secrets.NAME }}`
4. **Verify functionality** before deactivating old secrets
5. **Deactivate old secrets** after migration complete

## References

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub CLI Secrets Reference](https://cli.github.com/manual/gh_secret)
- Seven Fortunas Security Policy (in Second Brain)

---

**Last Updated:** 2026-02-17
**Owner:** Jorge (VP AI-SecOps)
**Phase:** Phase 2 - Production
EOF

echo "✓ Documentation created: $PROJECT_ROOT/docs/security/secrets-management.md"
echo ""

# Create 7f-secrets-manager skill
echo "4. Creating 7f-secrets-manager skill..."
mkdir -p "$PROJECT_ROOT/.claude/commands"

cat > "$PROJECT_ROOT/.claude/commands/7f-secrets-manager.md" << 'EOF'
---
description: Manage shared secrets in Seven Fortunas GitHub organization
---

# 7f-secrets-manager Skill

**Purpose:** Conversational interface for managing GitHub organization-level secrets

## What This Skill Does

This skill provides guidance and automation for:
- Listing available organization secrets
- Rotating secrets safely
- Documenting secret usage across repositories
- Auditing secret access patterns

## Usage

When invoked, I will help you with secrets management tasks.

## Common Tasks

### List Available Secrets
```bash
gh api orgs/Seven-Fortunas-Internal/actions/secrets --jq '.secrets[] | {name: .name, created_at: .created_at, updated_at: .updated_at}'
```

### Add New Secret
```bash
# Interactive (prompts for value)
gh secret set SECRET_NAME --org Seven-Fortunas-Internal

# From value
gh secret set SECRET_NAME --org Seven-Fortunas-Internal --body "secret-value"

# From file
gh secret set SECRET_NAME --org Seven-Fortunas-Internal < secret-file.txt
```

### Rotate Secret
1. Generate new secret value with provider (OpenAI, Anthropic, AWS, etc.)
2. Update GitHub secret:
   ```bash
   gh secret set SECRET_NAME --org Seven-Fortunas-Internal --body "new-value"
   ```
3. Verify in test workflow
4. Deactivate old secret value with provider

### Remove Secret
```bash
gh secret remove SECRET_NAME --org Seven-Fortunas-Internal
```

### Check Secret Visibility
```bash
# Get secret metadata (value not shown)
gh api orgs/Seven-Fortunas-Internal/actions/secrets/SECRET_NAME
```

## Security Notes

- **Values cannot be retrieved:** GitHub API masks secret values for security
- **Secrets persist in workflow runs:** Old secret values remain in completed workflow runs for 90 days
- **Rotation frequency:** Rotate sensitive secrets quarterly (or after suspected exposure)
- **Access control:** All org admins can manage secrets; limit admin access appropriately

## Documentation

See full documentation: `docs/security/secrets-management.md`

---

**Commands I can help with:**
- "List all secrets"
- "Help me rotate the OpenAI API key"
- "Show me how to add a new AWS access key"
- "Which repositories use this secret?"
- "Audit secret access for the last 30 days" (Phase 3)

**Owner:** Jorge (VP AI-SecOps)
EOF

echo "✓ Skill created: $PROJECT_ROOT/.claude/commands/7f-secrets-manager.md"
echo ""

# Test GitHub secrets access
echo "5. Testing GitHub Secrets API access..."
if gh api "orgs/$ORG_NAME/actions/secrets" &>/dev/null; then
    echo "✓ Can access organization secrets API"

    # List existing secrets (names only, values are never returned)
    echo ""
    echo "Current organization secrets:"
    gh api "orgs/$ORG_NAME/actions/secrets" --jq '.secrets[] | "  - \(.name) (updated: \(.updated_at))"' || echo "  (no secrets configured yet)"
else
    echo "WARNING: Cannot access secrets API. You may need to:"
    echo "  1. Grant 'admin:org' scope: gh auth login --scopes admin:org"
    echo "  2. Verify organization admin access"
    echo ""
    echo "Secrets management will work when permissions are granted."
fi
echo ""

# Create example secret (optional, commented out)
cat > "$PROJECT_ROOT/docs/security/example-secret-setup.sh" << 'EOF'
#!/bin/bash
# Example: Setting up a secret for testing
# DO NOT run this directly - it's a template

# Replace with actual values:
ORG_NAME="Seven-Fortunas-Internal"
SECRET_NAME="EXAMPLE_API_KEY"
SECRET_VALUE="your-actual-secret-value-here"

# Set secret
gh secret set "$SECRET_NAME" --org "$ORG_NAME" --body "$SECRET_VALUE"

# Verify it was created
gh api "orgs/$ORG_NAME/actions/secrets/$SECRET_NAME"
EOF
chmod +x "$PROJECT_ROOT/docs/security/example-secret-setup.sh"
echo "✓ Example script created: $PROJECT_ROOT/docs/security/example-secret-setup.sh"
echo ""

echo "=== Setup Complete ==="
echo ""
echo "Next Steps for Founders:"
echo "1. Store secrets via: gh secret set SECRET_NAME --org Seven-Fortunas-Internal"
echo "2. View secrets in GitHub UI: https://github.com/organizations/Seven-Fortunas-Internal/settings/secrets/actions"
echo "3. Use in workflows: \${{ secrets.SECRET_NAME }}"
echo "4. Invoke skill: /7f-secrets-manager (in Claude Code)"
echo ""
echo "Documentation: $PROJECT_ROOT/docs/security/secrets-management.md"
echo ""
