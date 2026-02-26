# Secrets Management Guide

Guide for managing shared API keys and secrets in Seven Fortunas using GitHub organization secrets.

## Overview

Seven Fortunas uses GitHub organization-level secrets for secure API key sharing between founders.

**Key principles:**
- Centralized storage in GitHub Secrets
- Encrypted at rest (AES-256)
- Access controlled (org owners only)
- Auditable (enterprise tier)
- Team-friendly sharing

## Quick Start

### Store a Secret

```bash
# Using GitHub CLI
gh secret set ANTHROPIC_API_KEY \
  --org Seven-Fortunas-Internal \
  --visibility all
# Paste secret value when prompted
```

### List Secrets

```bash
# Using 7f-secrets-manager skill
/7f-secrets-manager --action list

# Or GitHub CLI
gh secret list --org Seven-Fortunas-Internal
```

### Use in Workflow

```yaml
env:
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

## Secret Types

### API Keys (Recommended for org secrets)
- Anthropic Claude API
- OpenAI GPT-4 API
- GitHub PATs (admin operations)
- Slack webhooks
- Email SMTP passwords

### NOT Recommended
- Database passwords (use environment-specific)
- SSH private keys (use deploy keys)
- Encryption keys (use dedicated vault)
- User passwords (use SSO)

## Rotation Schedule

| Secret Type | Frequency | Responsibility |
|-------------|-----------|----------------|
| AI API Keys | Quarterly | Jorge |
| GitHub Tokens | Annually | Jorge |
| Slack Webhooks | As needed | Henry |
| Email Passwords | Semi-annually | Jorge |

## Access Control

**Organization Owners (can manage secrets):**
- Jorge (VP AI-SecOps)
- Henry (CEO)

**Organization Members (can use secrets in workflows):**
- All future team members

**To grant owner access:**
1. Go to https://github.com/orgs/Seven-Fortunas-Internal/people
2. Click "Invite member"
3. Select role: "Owner"
4. Send invitation

## Security Best Practices

### DO ✅
- Store all API keys in GitHub Secrets
- Rotate secrets on schedule
- Document secrets in inventory
- Use fine-grained GitHub tokens
- Set secret visibility appropriately
- Monitor secret usage

### DON'T ❌
- Hardcode secrets in code
- Commit secrets to git
- Share secrets via email/Slack
- Use classic GitHub PATs
- Print secret values in logs
- Skip rotation schedule

## Troubleshooting

### Common Issues

**"Secret not found in workflow"**
```bash
# Check secret visibility
gh secret list --org Seven-Fortunas-Internal

# Ensure visibility is "all" or includes your repo
gh api /orgs/Seven-Fortunas-Internal/actions/secrets/SECRET_NAME \
  | jq '.visibility'
```

**"Permission denied"**
- Only org owners can manage secrets
- Request owner role from Jorge or Henry
- Verify you're in the correct org

**"Secret value masked in logs"**
- This is expected behavior (security feature)
- GitHub automatically masks secret values
- Use `echo "::add-mask::$SECRET"` for additional masking

## Integration

### With GitHub Actions

All workflows can access org secrets:

```yaml
jobs:
  example:
    runs-on: ubuntu-latest
    steps:
      - name: Use secret
        env:
          API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          curl -H "X-API-Key: $API_KEY" https://api.anthropic.com/
```

### With 7f-secrets-manager

Use conversational interface:

```bash
# List all secrets
/7f-secrets-manager --action list

# Get secret info
/7f-secrets-manager --action info --name ANTHROPIC_API_KEY

# Rotate secret
/7f-secrets-manager --action rotate --name OPENAI_API_KEY
```

## References

- [7f-secrets-manager Skill](../../.claude/commands/7f-secrets-manager.md)
- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Secrets Inventory](../../outputs/second-brain/brand-culture/team/secrets-inventory.md)

---

**Owner:** Jorge (VP AI-SecOps)
**Last Updated:** 2026-02-25
