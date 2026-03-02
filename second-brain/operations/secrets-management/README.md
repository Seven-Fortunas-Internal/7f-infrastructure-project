---
title: Secrets Management
description: Credentials, keys, and secure credential handling
---

# Secrets Management

## Core Principles

### Golden Rules
1. **Never commit secrets to git** — Even in private repos
2. **Rotate regularly** — Keys and credentials
3. **Least privilege** — Only necessary access
4. **Audit everything** — Log all secret access
5. **Encrypt always** — In transit and at rest
6. **Automate rotation** — Don't manually manage

## Secret Types

### API Keys and Tokens
- **OAuth Tokens**: Third-party service authentication
- **API Keys**: Service-to-service communication
- **Bearer Tokens**: Authentication tokens
- **JWT Tokens**: Stateless authentication
- **Refresh Tokens**: Extended session management

### Database Credentials
- **Connection Strings**: Database URLs with credentials
- **Usernames**: Database user accounts
- **Passwords**: Database access passwords
- **Connection Certificates**: TLS certs for databases

### Cryptographic Keys
- **Private Keys**: SSH, TLS, encryption keys
- **Symmetric Keys**: AES, shared secrets
- **Key Pair Passphrases**: Passwords protecting keys
- **Master Keys**: Root encryption keys

### Service Credentials
- **AWS Access Keys**: AWS API credentials
- **GCP Service Accounts**: Google Cloud credentials
- **Azure Secrets**: Microsoft Azure credentials
- **Cloud Vendor Keys**: Keys for other cloud providers

### Application Secrets
- **Session Keys**: HTTP session encryption
- **CSRF Tokens**: Cross-site request forgery prevention
- **Signing Keys**: Code signing certificates
- **Webhook Secrets**: Webhook validation tokens

## Secret Storage Solutions

### Development Environment
- **Option 1**: .env files (gitignored)
  ```bash
  # .env
  API_KEY=dev-key-xyz
  DATABASE_URL=postgres://dev:password@localhost/db
  # Add to .gitignore: .env
  ```

- **Option 2**: .env.local (local overrides)
  ```bash
  # .env.local (gitignored)
  DATABASE_PASSWORD=local-password
  ```

- **Option 3**: Local Secret Manager
  ```bash
  # macOS keychain
  security add-generic-password -a $USER -s api-key -w "secret-value"
  security find-generic-password -a $USER -s api-key -w
  ```

### Staging/Production Environment
- **AWS Secrets Manager**: Managed secret storage
- **HashiCorp Vault**: Open-source secret management
- **Google Secret Manager**: GCP native solution
- **Azure Key Vault**: Microsoft Azure solution
- **1Password Business**: Team-focused secret management

### GitHub Actions
```yaml
# Use GitHub Secrets for CI/CD
env:
  API_KEY: ${{ secrets.API_KEY }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Run tests
        env:
          DATABASE_URL: ${{ secrets.STAGING_DATABASE_URL }}
        run: npm test
```

## Rotation Schedules

### High-Risk Secrets (Rotate Monthly)
- Root/admin credentials
- Master encryption keys
- Frequently-used API keys
- Database credentials

### Medium-Risk Secrets (Rotate Quarterly)
- Service account credentials
- OAuth refresh tokens
- Backup access credentials
- Internal API keys

### Low-Risk Secrets (Rotate Annually)
- Third-party read-only tokens
- Non-critical API keys
- Development environment keys
- Static configuration values

### Immediate Rotation Required
- Suspected compromise
- Employee departure
- Security incident
- Vendor compromise

## Credential Rotation Procedures

### API Key Rotation
1. Generate new API key in service
2. Update configuration with new key
3. Deploy updated configuration
4. Monitor for errors
5. Revoke old key after verification
6. Document rotation date and approver

### Database Password Rotation
1. Generate strong new password (20+ chars)
2. Update password in secret store
3. Update database user password
4. Test connection with new password
5. Update all applications
6. Monitor for connection errors
7. Remove old password from any backups

### SSH Key Rotation
1. Generate new key pair
2. Add public key to target servers
3. Update deployment configs
4. Deploy changes
5. Verify new key works
6. Remove old public key
7. Securely destroy old private key

### OAuth Token Refresh
1. Request new refresh token
2. Update stored refresh token
3. Revoke old token
4. Monitor for failures
5. Document changes

## Access Control

### Role-Based Access
- **Admin**: All secrets
- **Engineer**: Development and staging secrets
- **DevOps**: Infrastructure secrets only
- **Application**: Only required secrets (via service accounts)
- **CI/CD**: Deployment secrets only

### Principle of Least Privilege
- Grant minimum required permissions
- Scope access to environments
- Limit secret access per role
- Regular access reviews
- Immediate revocation on departure

### Secret Access Logging
```
2024-01-15 14:32:01 - engineer@example.com - accessed API_KEY - success
2024-01-15 14:32:45 - lambda-service - accessed DB_PASSWORD - success
2024-01-15 14:33:12 - developer@example.com - failed access MASTER_KEY - denied
```

## Handling Leaked Secrets

### Discovery
- Automated scanning (git pre-commit hooks)
- Accidental commit notifications
- Security report from third party
- Internal audit or investigation

### Immediate Actions
1. **Disable Access**: Revoke/rotate compromised secret
2. **Assess**: Determine what was exposed
3. **Notify**: Alert security team and management
4. **Document**: Record incident details

### Investigation
1. Determine exposure scope (who/when/what)
2. Identify if secret was actually used
3. Check logs for unauthorized access
4. Assess damage and impact
5. Determine root cause

### Remediation
1. Rotate compromised secret
2. Update all dependent systems
3. Monitor for misuse
4. Implement preventive measures
5. Communicate with affected parties if needed

### Prevention
- Pre-commit hooks: Scan for patterns
- Regular audits: Check for leaked secrets
- Education: Train team on secret handling
- Process: Code review checks
- Tools: Secret scanning in GitHub/GitLab

## Secret Scanning Tools

### Local Development
```bash
# Pre-commit hook
pip install detect-secrets
detect-secrets scan --baseline .secrets.baseline

# Manual scanning
git diff HEAD~1 | detect-secrets scan -
```

### GitHub
```yaml
# Enable secret scanning in repository settings
# Settings → Security → Secret scanning
```

### CI/CD Integration
```yaml
# GitLab CI
include:
  - template: Secret-Detection.gitlab-ci.yml

# GitHub Actions
- name: Detect secrets
  uses: gitleaks/gitleaks-action@v2
```

## Secret Injection in Deployment

### Environment Variables
```bash
# Docker
docker run \
  -e API_KEY=$API_KEY \
  -e DATABASE_URL=$DATABASE_URL \
  my-app:latest
```

### Kubernetes Secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  api-key: <base64-encoded>
  db-password: <base64-encoded>
---
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
  - name: app
    env:
    - name: API_KEY
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: api-key
```

### Vault Integration
```python
# Retrieve secret at runtime
from hvac import Client

client = Client(url='https://vault.example.com')
secret = client.secrets.kv.read_secret_version(path='app/api-key')
api_key = secret['data']['data']['key']
```

## Secret Management Checklist

### New Secret
- [ ] Generated with sufficient entropy
- [ ] Stored in secret manager (not code)
- [ ] Access restricted to principals
- [ ] Logged in audit trail
- [ ] Rotation schedule defined
- [ ] Expiration date set (if applicable)

### Quarterly Review
- [ ] All secrets accounted for
- [ ] Unused secrets removed
- [ ] Rotation completed on schedule
- [ ] Access levels appropriate
- [ ] Audit logs reviewed for anomalies

### Incident or Suspected Compromise
- [ ] Secret immediately revoked
- [ ] New secret generated
- [ ] All systems updated
- [ ] Logs searched for misuse
- [ ] Post-incident review scheduled

## Tools and Resources

### Recommended Tools
- **HashiCorp Vault**: Comprehensive secret management
- **AWS Secrets Manager**: Cloud-native AWS solution
- **1Password**: Team and enterprise focused
- **Bitwarden**: Open-source password manager

### Scanning Tools
- **detect-secrets**: Python-based detection
- **gitleaks**: Git secret scanner
- **TruffleHog**: Searches for credentials in git history
- **git-secrets**: AWS secret pattern detection

### Documentation
- [OWASP: Secret Management Cheat Sheet](https://cheatsheetseries.owasp.org/)
- [HashiCorp: Secret Management Best Practices](https://www.hashicorp.com/)
- [AWS: Security Best Practices](https://aws.amazon.com/security/)
