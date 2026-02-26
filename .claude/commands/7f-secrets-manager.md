# 7F Secrets Manager

**Skill:** 7f-secrets-manager
**Purpose:** Manage shared API keys and secrets using GitHub org-level secrets

## Usage

```bash
# List available secrets
/7f-secrets-manager --action list

# Set a new secret
/7f-secrets-manager --action set --name OPENAI_API_KEY --value "sk-..."

# Rotate a secret
/7f-secrets-manager --action rotate --name ANTHROPIC_API_KEY

# Get secret metadata (not value)
/7f-secrets-manager --action info --name GITHUB_TOKEN

# Delete a secret
/7f-secrets-manager --action delete --name OLD_API_KEY
```

## Parameters

- `--action`: Operation (list | set | rotate | info | delete)
- `--name`: Secret name (uppercase with underscores)
- `--value`: Secret value (for set action)
- `--org`: Organization (defaults to Seven-Fortunas-Internal)

## GitHub Organization Secrets

### What are org-level secrets?

GitHub organization secrets are:
- **Encrypted at rest:** AES-256 encryption
- **Shared across repos:** Available to all repos in the org
- **Access controlled:** Only org admins can manage
- **Used in workflows:** Available as `${{ secrets.SECRET_NAME }}`

### Why use them?

✅ **Centralized:** One place for all API keys
✅ **Secure:** Encrypted and never exposed in logs
✅ **Auditable:** GitHub tracks all access (enterprise tier)
✅ **Team-friendly:** Founders share access without exposing keys

❌ **Don't use for:** Database passwords, private keys (use vault instead)

## Actions

### 1. List Available Secrets

**Command:**
```bash
/7f-secrets-manager --action list --org Seven-Fortunas-Internal
```

**Process:**
```bash
gh api /orgs/Seven-Fortunas-Internal/actions/secrets \
  --jq '.secrets[] | {name, created_at, updated_at}'
```

**Output:**
```
Organization Secrets (Seven-Fortunas-Internal)
===============================================

1. ANTHROPIC_API_KEY
   Created: 2026-02-10
   Updated: 2026-02-25
   Used by: 5 workflows

2. OPENAI_API_KEY
   Created: 2026-02-15
   Updated: 2026-02-20
   Used by: 3 workflows

3. GH_ADMIN_TOKEN
   Created: 2026-01-05
   Updated: 2026-01-05
   Used by: 12 workflows

Total: 3 secrets
```

### 2. Set a New Secret

**Command:**
```bash
/7f-secrets-manager --action set \
  --name ANTHROPIC_API_KEY \
  --value "sk-ant-..."
```

**Process:**
```bash
# Using GitHub CLI
gh secret set ANTHROPIC_API_KEY \
  --org Seven-Fortunas-Internal \
  --visibility all \
  --body "sk-ant-..."

# Or using API
gh api /orgs/Seven-Fortunas-Internal/actions/secrets/ANTHROPIC_API_KEY \
  -X PUT \
  -f encrypted_value="..." \
  -f visibility="all"
```

**Output:**
```
✓ Secret ANTHROPIC_API_KEY created
  Organization: Seven-Fortunas-Internal
  Visibility: All repositories
  Created: 2026-02-25 11:30 UTC

Next steps:
1. Use in workflows: ${{ secrets.ANTHROPIC_API_KEY }}
2. Document in Second Brain: docs/security/secrets-inventory.md
3. Share with team: Notify founders in #security channel
```

### 3. Rotate a Secret

**Command:**
```bash
/7f-secrets-manager --action rotate --name OPENAI_API_KEY
```

**Process:**
1. Generate new API key from provider (OpenAI, Anthropic, etc.)
2. Update secret value
3. Test new key in workflows
4. Revoke old key from provider
5. Document rotation in audit log

**Output:**
```
Secret Rotation: OPENAI_API_KEY
================================

Step 1: Generate new key
  → Go to https://platform.openai.com/api-keys
  → Create new key: "seven-fortunas-2026-02-25"
  → Copy key value

Step 2: Update GitHub secret
  → gh secret set OPENAI_API_KEY --org Seven-Fortunas-Internal

Step 3: Test workflows
  → Trigger workflow: update-ai-dashboard.yml
  → Verify: Check workflow run for errors

Step 4: Revoke old key
  → Go to provider dashboard
  → Revoke previous key

Step 5: Document rotation
  → Update docs/security/secrets-inventory.md
  → Add entry: "Rotated OPENAI_API_KEY on 2026-02-25"

✓ Rotation complete
```

### 4. Get Secret Metadata

**Command:**
```bash
/7f-secrets-manager --action info --name GITHUB_TOKEN
```

**Output:**
```
Secret: GITHUB_TOKEN
====================

Organization: Seven-Fortunas-Internal
Created: 2026-01-05
Last Updated: 2026-01-05
Visibility: All repositories

Used by workflows:
- sync-sprint-boards.yml
- update-project-progress.yml
- soc2-evidence-collection.yml
- (9 more...)

Repositories with access: 12
Last accessed: 2026-02-25 (estimated)

Note: Secret value cannot be retrieved via API for security reasons.
To view value, regenerate from provider.
```

### 5. Delete a Secret

**Command:**
```bash
/7f-secrets-manager --action delete --name OLD_API_KEY
```

**Process:**
```bash
# Confirm deletion
echo "Are you sure you want to delete OLD_API_KEY? (yes/no)"

# Delete
gh api /orgs/Seven-Fortunas-Internal/actions/secrets/OLD_API_KEY \
  -X DELETE
```

**Output:**
```
⚠️ Warning: This action cannot be undone

Secret: OLD_API_KEY
Organization: Seven-Fortunas-Internal
Used by: 2 workflows

Confirm deletion? (yes/no): yes

✓ Secret OLD_API_KEY deleted
  Deleted at: 2026-02-25 11:35 UTC

Action required:
1. Update workflows to use new secret name
2. Remove references in documentation
3. Notify team of deletion
```

## Secrets Inventory

Maintain an inventory in Second Brain:

**File:** `outputs/second-brain/brand-culture/team/secrets-inventory.md`

```markdown
# Secrets Inventory

## Active Secrets

### ANTHROPIC_API_KEY
- **Provider:** Anthropic (Claude API)
- **Created:** 2026-02-10
- **Rotated:** 2026-02-25
- **Owner:** Jorge
- **Used by:** AI dashboard, weekly summaries, compliance reports
- **Rotation schedule:** Quarterly

### OPENAI_API_KEY
- **Provider:** OpenAI (GPT-4 API)
- **Created:** 2026-02-15
- **Rotated:** 2026-02-20
- **Owner:** Henry
- **Used by:** AI dashboard, content generation
- **Rotation schedule:** Monthly

### GH_ADMIN_TOKEN
- **Provider:** GitHub (Personal Access Token)
- **Created:** 2026-01-05
- **Rotated:** Never (fine-grained token)
- **Owner:** Jorge
- **Used by:** SOC2 evidence, compliance monitoring, workflow automation
- **Rotation schedule:** Annually

## Rotation Schedule

| Secret | Last Rotated | Next Rotation | Frequency |
|--------|-------------|---------------|-----------|
| ANTHROPIC_API_KEY | 2026-02-25 | 2026-05-25 | Quarterly |
| OPENAI_API_KEY | 2026-02-20 | 2026-03-20 | Monthly |
| GH_ADMIN_TOKEN | Never | 2027-01-05 | Annually |
```

## Access Control

### Who can access?

**GitHub Organization Owners:**
- Jorge (VP AI-SecOps)
- Henry (CEO)
- Future founders

**Permissions:**
- List secrets: All org members
- Create/update secrets: Org owners only
- Delete secrets: Org owners only
- Use in workflows: All repos (when visibility="all")

### How to grant access?

```bash
# Add user to org as owner
gh api /orgs/Seven-Fortunas-Internal/memberships/USERNAME \
  -X PUT \
  -f role="admin"

# Or via web UI:
# Settings > Members > Invite member > Role: Owner
```

## Integration with Workflows

**Usage in GitHub Actions:**

```yaml
name: Example Workflow

on: workflow_dispatch

jobs:
  example:
    runs-on: ubuntu-latest
    steps:
      - name: Use org secret
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          # Secret is available as environment variable
          echo "API key loaded"
          # Value is masked in logs
```

**Best practices:**
- ✅ Use secrets for all API keys
- ✅ Rotate secrets regularly
- ✅ Document secret purpose
- ❌ Don't hardcode secrets
- ❌ Don't print secret values
- ❌ Don't commit secrets to repo

## Audit Logging

**GitHub Enterprise required for audit logs**

With Enterprise tier, track:
- Secret created/updated/deleted
- Secret accessed by workflow
- User who made changes
- Timestamp of all events

**Export audit log:**
```bash
gh api /orgs/Seven-Fortunas-Internal/audit-log \
  --jq '.[] | select(.action | contains("secret"))'
```

## Troubleshooting

### "Secret not found"
- Verify secret name (case-sensitive)
- Check organization (Seven-Fortunas vs Seven-Fortunas-Internal)
- Confirm you have owner permissions

### "Permission denied"
- Only org owners can manage secrets
- Request owner role from Jorge or Henry

### "Workflow not using secret"
- Check visibility is set to "all" or specific repos
- Verify workflow has `secrets` permission
- Ensure secret name matches exactly

## Security Best Practices

1. **Rotate regularly:** Follow rotation schedule
2. **Least privilege:** Use repo-specific secrets when possible
3. **Fine-grained tokens:** Use GitHub fine-grained PATs instead of classic
4. **Monitor usage:** Review which workflows use each secret
5. **Document everything:** Maintain secrets inventory in Second Brain

## References

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Secrets Inventory](../../outputs/second-brain/brand-culture/team/secrets-inventory.md)
- [Security Guide](../../docs/security/secrets-management-guide.md)

---

**Owner:** Jorge (VP AI-SecOps)
**Phase:** Phase 2
**Status:** Implemented
