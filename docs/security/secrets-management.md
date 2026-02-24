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
