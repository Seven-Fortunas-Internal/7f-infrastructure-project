# Seven Fortunas Shared Secrets Management

## Overview

The Seven Fortunas organization uses GitHub's native secrets management solution for secure storage and sharing of API keys, credentials, and sensitive configuration.

**Key Features:**
- Organization-level secrets accessible to all founders
- Encryption at rest (AES-256-GCM)
- Audit logging of secret access
- GitHub CLI and web UI interfaces
- Integration with GitHub Actions workflows

---

## Architecture

### Storage Model

**Location:** GitHub Organization Secrets (org-level)
**Organization:** `Seven-Fortunas-Internal`
**Access:** Organization owners and admins
**Encryption:** AES-256-GCM at rest, TLS 1.3 in transit

### Secret Types

1. **API Keys**
   - `ANTHROPIC_API_KEY` - Claude API access
   - `OPENAI_API_KEY` - OpenAI API access
   - `GITHUB_TOKEN` - GitHub Personal Access Token (PAT)

2. **Service Credentials**
   - `AWS_ACCESS_KEY_ID` - AWS access
   - `AWS_SECRET_ACCESS_KEY` - AWS secret
   - `SLACK_WEBHOOK_URL` - Slack notifications

3. **Infrastructure**
   - `SSH_PRIVATE_KEY` - Deployment keys
   - `GPG_PRIVATE_KEY` - Code signing
   - `SIGNING_KEY` - Release signing

---

## Usage

### Storing Secrets

#### Via GitHub CLI (Recommended)

```bash
# Set organization-level secret
gh secret set ANTHROPIC_API_KEY \
  --org Seven-Fortunas-Internal \
  --visibility all

# Set secret with value from file
gh secret set AWS_CREDENTIALS \
  --org Seven-Fortunas-Internal \
  --body < ~/.aws/credentials

# Set secret interactively (will prompt)
gh secret set API_KEY --org Seven-Fortunas-Internal
```

#### Via GitHub Web UI

1. Navigate to: https://github.com/organizations/Seven-Fortunas-Internal/settings/secrets/actions
2. Click "New organization secret"
3. Enter secret name and value
4. Set repository access (all repositories or specific)
5. Click "Add secret"

---

### Retrieving Secrets

#### Via GitHub Actions Workflows

```yaml
name: Example Workflow
on: push

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Use secret
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          # Secret is available as environment variable
          echo "API key loaded"
```

#### Via GitHub CLI (List Only)

```bash
# List all organization secrets
gh secret list --org Seven-Fortunas-Internal

# Output:
# ANTHROPIC_API_KEY  Updated 2026-02-23
# GITHUB_TOKEN       Updated 2026-02-20
# OPENAI_API_KEY     Updated 2026-02-22
```

**Note:** GitHub CLI and API **cannot retrieve secret values** for security reasons. Secrets can only be accessed within GitHub Actions workflows.

#### Via GitHub Web UI (View Metadata Only)

1. Navigate to: https://github.com/organizations/Seven-Fortunas-Internal/settings/secrets/actions
2. View secret names and last updated timestamps
3. Secret values are **not visible** (security policy)

---

## 7f-secrets-manager Skill

Conversational interface for secrets management.

### Usage

```
/7f-secrets-manager <action> [options]
```

### Actions

#### List Secrets

```
/7f-secrets-manager list

Output:
Organization Secrets (Seven-Fortunas-Internal):
  ✓ ANTHROPIC_API_KEY (Updated: 2026-02-23)
  ✓ GITHUB_TOKEN (Updated: 2026-02-20)
  ✓ OPENAI_API_KEY (Updated: 2026-02-22)
  ✓ AWS_ACCESS_KEY_ID (Updated: 2026-02-15)
```

#### Add Secret

```
/7f-secrets-manager add --name SLACK_WEBHOOK_URL --value https://hooks.slack.com/...

Output:
✓ Secret SLACK_WEBHOOK_URL added successfully
  Organization: Seven-Fortunas-Internal
  Visibility: All repositories
  Encrypted: Yes (AES-256-GCM)
```

#### Update Secret

```
/7f-secrets-manager update --name ANTHROPIC_API_KEY

Prompt: Enter new value for ANTHROPIC_API_KEY:
[User enters value]

Output:
✓ Secret ANTHROPIC_API_KEY updated successfully
  Last Updated: 2026-02-24T04:30:00Z
```

#### Delete Secret

```
/7f-secrets-manager delete --name OLD_API_KEY

Confirmation: Delete OLD_API_KEY? This cannot be undone. (y/N)
y

Output:
✓ Secret OLD_API_KEY deleted successfully
```

#### Rotate Secret

```
/7f-secrets-manager rotate --name ANTHROPIC_API_KEY

Output:
Secret Rotation Guide for ANTHROPIC_API_KEY:

1. Generate new API key:
   - Visit: https://console.anthropic.com/settings/keys
   - Click "Create Key"
   - Copy new key

2. Update secret:
   gh secret set ANTHROPIC_API_KEY --org Seven-Fortunas-Internal

3. Test new key:
   - Run test workflow to verify
   - Monitor for errors

4. Revoke old key:
   - Return to Anthropic console
   - Revoke previous key

✓ Rotation reminder created
```

---

## Security Best Practices

### Secret Creation

1. **Use Strong Values**
   - Minimum 32 characters for API keys
   - Use cryptographically random generation
   - Avoid predictable patterns

2. **Principle of Least Privilege**
   - Grant repository access only as needed
   - Use repository-specific secrets when possible
   - Limit organization-wide secrets to truly shared resources

3. **Documentation**
   - Document secret purpose in Second Brain
   - Track which services use which secrets
   - Maintain secret rotation schedule

### Secret Usage

1. **Never Log Secrets**
   ```bash
   # BAD: Logs secret value
   echo "API_KEY=$ANTHROPIC_API_KEY"

   # GOOD: Logs status only
   echo "API_KEY loaded successfully"
   ```

2. **Never Commit Secrets**
   - Use `.gitignore` for local credential files
   - Enable secret scanning (FR-7.2)
   - Use pre-commit hooks to detect secrets

3. **Rotate Regularly**
   - API keys: Every 90 days
   - Service credentials: Every 6 months
   - Infrastructure keys: Annually or on personnel change

### Secret Rotation

**Schedule:**
- **Critical Secrets** (API keys): 90 days
- **Service Credentials**: 180 days
- **Infrastructure Keys**: 365 days or on team change

**Process:**
1. Generate new secret value
2. Update GitHub Secret (gh secret set)
3. Test with new value
4. Revoke old value
5. Document rotation in audit log

---

## Access Control

### Who Can Access Secrets?

**Organization-Level Secrets:**
- Organization owners: Full access (read metadata, update, delete)
- Organization members: No access (unless explicitly granted)
- GitHub Actions: Full access (can use secret values in workflows)

**Repository-Level Secrets:**
- Repository admins: Full access
- Repository collaborators: No access
- GitHub Actions in that repo: Full access

### Granting Access

```bash
# Make secret available to all repositories
gh secret set API_KEY --org Seven-Fortunas-Internal --visibility all

# Make secret available to specific repositories
gh secret set API_KEY \
  --org Seven-Fortunas-Internal \
  --repos "repo1,repo2,repo3"

# Make secret private (selected repositories only)
gh secret set API_KEY \
  --org Seven-Fortunas-Internal \
  --visibility private
```

---

## Integration with GitHub Actions

### Workflow Access

Secrets are automatically available to GitHub Actions workflows:

```yaml
name: Deploy
on: push

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to AWS
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          aws s3 sync ./dist s3://my-bucket
```

### Environment-Specific Secrets

For multi-environment deployments:

```yaml
jobs:
  deploy-prod:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy
        env:
          API_KEY: ${{ secrets.PROD_API_KEY }}
        run: ./deploy.sh
```

---

## Audit and Monitoring

### Audit Log

**Location:** GitHub Organization Audit Log
**Access:** https://github.com/organizations/Seven-Fortunas-Internal/settings/audit-log

**Events Tracked:**
- `org.update_actions_secret` - Secret created/updated
- `org.remove_actions_secret` - Secret deleted
- `repo_secret.create` - Repository secret created
- `repo_secret.remove` - Repository secret deleted

**Query Example:**
```
action:org.update_actions_secret created:>=2026-02-01
```

### Monitoring (Phase 3)

In Phase 3, implement:
- Secret access alerts (Slack notifications)
- Rotation reminders (automated)
- Unused secret detection
- Compliance reporting

---

## Troubleshooting

### "Permission denied" when setting secret

**Symptom:**
```
Error: HTTP 403: Resource not accessible by personal access token
```

**Solution:**
1. Verify you're an organization owner
2. Check GitHub CLI authentication:
   ```bash
   gh auth status
   ```
3. Re-authenticate with correct scopes:
   ```bash
   gh auth login --scopes admin:org
   ```

### Secret not available in workflow

**Symptom:**
```
Error: Required secret not found
```

**Solution:**
1. Verify secret exists:
   ```bash
   gh secret list --org Seven-Fortunas-Internal
   ```
2. Check repository access (visibility setting)
3. Ensure secret name matches exactly (case-sensitive)

### Cannot view secret value

**Expected Behavior:** Secret values are **never** displayed in UI or API.

**Workaround:**
- Store secrets in password manager as backup
- Document secret rotation procedures
- Test secrets in GitHub Actions to verify correctness

---

## Migration from Other Solutions

### From .env Files

```bash
# Read secrets from .env file
while IFS='=' read -r key value; do
  # Skip comments and empty lines
  [[ "$key" =~ ^#.*$ ]] && continue
  [[ -z "$key" ]] && continue

  # Set secret in GitHub
  echo "Setting $key..."
  echo "$value" | gh secret set "$key" --org Seven-Fortunas-Internal
done < .env

echo "✓ Migration complete"
```

### From AWS Secrets Manager

```bash
# Example: Migrate from AWS Secrets Manager
aws secretsmanager list-secrets --query 'SecretList[*].Name' --output text | while read -r name; do
  value=$(aws secretsmanager get-secret-value --secret-id "$name" --query SecretString --output text)
  echo "$value" | gh secret set "$name" --org Seven-Fortunas-Internal
  echo "✓ Migrated $name"
done
```

---

## See Also

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [7f-secrets-manager Skill](.claude/commands/7f-secrets-manager.md)
- FR-7.2: Secret Detection & Prevention
- FR-7.5: GitHub Actions Security

---

**Version:** 1.0
**Last Updated:** 2026-02-24
**Owner:** Jorge (VP AI-SecOps)
**Status:** Operational
