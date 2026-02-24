# 7f-secrets-manager

**Purpose:** Manage organization-level GitHub Secrets for secure API key sharing

**Category:** Security & Secrets Management
**Owner:** Jorge
**Phase:** Phase 2

---

## Description

The 7f-secrets-manager skill provides a conversational interface for managing organization-level GitHub Secrets used by Seven Fortunas founders to securely share API keys, credentials, and sensitive configuration.

**Implementation:** Uses GitHub CLI (`gh secret`) to interact with GitHub Secrets API.

---

## Usage

```
/7f-secrets-manager <action> [options]
```

**Actions:**
- `list` - List all organization secrets
- `add` - Add a new secret
- `update` - Update existing secret value
- `delete` - Delete a secret
- `rotate` - Rotate a secret (guided process)

---

## Examples

### List Secrets

```
/7f-secrets-manager list
```

**Output:**
```
Organization Secrets (Seven-Fortunas-Internal):
  ✓ ANTHROPIC_API_KEY (Updated: 2026-02-23)
  ✓ GITHUB_TOKEN (Updated: 2026-02-20)
  ✓ OPENAI_API_KEY (Updated: 2026-02-22)
  ✓ AWS_ACCESS_KEY_ID (Updated: 2026-02-15)

Total: 4 secrets
```

---

### Add Secret

```
/7f-secrets-manager add --name SLACK_WEBHOOK_URL
```

**Interactive Prompt:**
```
Enter value for SLACK_WEBHOOK_URL:
[User enters value]

Set repository visibility:
  1. All repositories (default)
  2. Private (selected repositories only)
  3. Specific repositories

Choice [1]: 1

✓ Secret SLACK_WEBHOOK_URL added successfully
  Organization: Seven-Fortunas-Internal
  Visibility: All repositories
  Encrypted: Yes (AES-256-GCM)
```

---

### Update Secret

```
/7f-secrets-manager update --name ANTHROPIC_API_KEY
```

**Interactive Prompt:**
```
Current secret: ANTHROPIC_API_KEY
Last updated: 2026-02-23T10:15:00Z

Enter new value:
[User enters value]

✓ Secret ANTHROPIC_API_KEY updated successfully
  Last Updated: 2026-02-24T04:35:00Z

Reminder: Test the new key in a workflow before revoking the old one.
```

---

### Delete Secret

```
/7f-secrets-manager delete --name OLD_API_KEY
```

**Confirmation:**
```
⚠️  WARNING: This will permanently delete OLD_API_KEY

Secret details:
  Name: OLD_API_KEY
  Last Updated: 2026-01-15T08:00:00Z
  Used by: 3 workflows

Are you sure you want to delete this secret? (y/N): y

✓ Secret OLD_API_KEY deleted successfully
```

---

### Rotate Secret

```
/7f-secrets-manager rotate --name ANTHROPIC_API_KEY
```

**Guided Process:**
```
Secret Rotation Guide for ANTHROPIC_API_KEY

Step 1: Generate new API key
  - Visit: https://console.anthropic.com/settings/keys
  - Click "Create Key"
  - Copy new key value

Step 2: Update GitHub Secret
  Run: gh secret set ANTHROPIC_API_KEY --org Seven-Fortunas-Internal

Step 3: Test new key
  - Trigger test workflow
  - Monitor for errors: https://github.com/Seven-Fortunas-Internal/7f-infrastructure-project/actions

Step 4: Revoke old key
  - Return to Anthropic console
  - Find previous key
  - Click "Revoke"

Would you like to update the secret now? (y/N): y

[If yes, proceeds to interactive update]

✓ Rotation process initiated
  Next rotation due: 2026-05-24 (90 days)
```

---

## Implementation

**Script:** `scripts/7f-secrets-manager.sh`

```bash
#!/bin/bash
# 7f-secrets-manager.sh - Manage GitHub organization secrets

ACTION="${1:-list}"

case $ACTION in
    list)
        gh secret list --org Seven-Fortunas-Internal
        ;;
    add)
        gh secret set "$2" --org Seven-Fortunas-Internal --visibility all
        ;;
    update)
        gh secret set "$2" --org Seven-Fortunas-Internal
        ;;
    delete)
        gh secret delete "$2" --org Seven-Fortunas-Internal
        ;;
    rotate)
        echo "Rotation guide for $2"
        # Display rotation steps
        ;;
esac
```

---

## Security Features

### Encryption

- **At Rest:** AES-256-GCM
- **In Transit:** TLS 1.3
- **Libsodium Sealed Boxes:** Encrypted before reaching GitHub

### Access Control

- **Organization Owners:** Full access
- **GitHub Actions:** Read-only access during workflow execution
- **API/CLI:** Cannot retrieve secret values (metadata only)

### Audit Logging

- All secret operations logged in GitHub Audit Log
- Accessible at: https://github.com/organizations/Seven-Fortunas-Internal/settings/audit-log

---

## Best Practices

### Secret Naming

```
# Good
ANTHROPIC_API_KEY
AWS_SECRET_ACCESS_KEY
SLACK_WEBHOOK_URL

# Bad
api_key              # Too generic
AnthropicKey         # Inconsistent casing
ANTHROPIC-API-KEY    # Hyphens not recommended
```

### Rotation Schedule

- **API Keys:** Every 90 days
- **Service Credentials:** Every 180 days
- **Infrastructure Keys:** Annually

### Documentation

For each secret, document in Second Brain:
- Purpose and which services use it
- Rotation procedure
- Point of contact for issues

---

## Integration

### GitHub Actions

Secrets are automatically available in workflows:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Use secret
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: ./build.sh
```

### Related Features

- FR-7.2: Secret Detection & Prevention
- FR-7.5: GitHub Actions Security
- FR-3.3: Second Brain Documentation

---

## Troubleshooting

### Common Issues

**1. Permission Denied**
```
Solution: Ensure you're an organization owner
Check: gh auth status
Fix: gh auth login --scopes admin:org
```

**2. Secret Not Available in Workflow**
```
Solution: Check repository visibility setting
Fix: gh secret set NAME --org ORG --visibility all
```

**3. Cannot View Secret Value**
```
This is expected behavior. Secret values are never displayed.
Workaround: Store backup in password manager
```

---

## See Also

- [Secrets Management Guide](../docs/secrets-management/README.md)
- [GitHub Secrets Docs](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- FR-8.4: Shared Secrets Management

---

**Status:** Operational
**Dependencies:** GitHub CLI (gh), Organization owner permissions
