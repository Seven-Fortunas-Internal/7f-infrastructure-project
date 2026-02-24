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
