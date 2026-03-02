# 7f-secrets-manager

Manage organization-level GitHub Secrets for Seven Fortunas.

## Usage

```bash
# List all org-level secrets
/7f-secrets-manager list

# Add or update a secret
/7f-secrets-manager set <SECRET_NAME>

# Delete a secret
/7f-secrets-manager delete <SECRET_NAME>

# Get help
/7f-secrets-manager help
```

## What This Skill Does

This skill provides a conversational interface for managing GitHub Secrets at the organization level. It simplifies common secrets management tasks:

1. **List Secrets:** View all available org-level secret names (values are never displayed)
2. **Set Secrets:** Add or update secrets with interactive prompts
3. **Delete Secrets:** Remove secrets that are no longer needed
4. **Documentation:** View secrets management best practices

## Implementation

When invoked, this skill will:

1. Verify GitHub CLI authentication
2. Check org admin permissions
3. Execute the requested operation using `gh secret` commands
4. Provide clear feedback and error messages

## Commands

### list

Lists all organization-level secrets (names only).

```bash
/7f-secrets-manager list
```

**Example output:**
```
Organization Secrets (Seven-Fortunas-Internal):
- ANTHROPIC_API_KEY
- GITHUB_TOKEN (auto-managed)
- SLACK_WEBHOOK_URL

Total: 3 secrets
```

### set

Adds or updates a secret. You'll be prompted to enter the secret value securely.

```bash
/7f-secrets-manager set ANTHROPIC_API_KEY
```

**Process:**
1. Prompts for secret value (hidden input)
2. Confirms the secret name
3. Uploads to GitHub org secrets
4. Confirms success

### delete

Removes a secret from the organization.

```bash
/7f-secrets-manager delete OLD_API_KEY
```

**Warning:** This operation cannot be undone. The secret will be immediately removed from all workflows.

### help

Displays usage information and links to documentation.

```bash
/7f-secrets-manager help
```

## Security Notes

- Secret values are **never displayed** after being set
- All operations require org admin permissions
- Secret names are visible to all org members
- Secret values are only accessible in GitHub Actions workflows
- All operations are logged in the org audit trail

## Prerequisites

- GitHub CLI authenticated as `jorge-at-sf`
- Org admin role in `Seven-Fortunas-Internal`
- Network access to GitHub API

## Related Documentation

- Secrets Management Guide: `/home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/docs/secrets-management.md`
- GitHub Secrets Docs: https://docs.github.com/en/actions/security-guides/encrypted-secrets

---

**Skill Type:** Utility
**Category:** Security & Compliance
**Maintainer:** Jorge (VP AI-SecOps)
