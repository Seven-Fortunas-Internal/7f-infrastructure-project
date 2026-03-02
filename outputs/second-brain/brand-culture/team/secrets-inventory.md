# Secrets Inventory

Inventory of shared API keys and secrets stored in GitHub organization secrets.

## Active Secrets

### ANTHROPIC_API_KEY
- **Provider:** Anthropic (Claude API)
- **Purpose:** AI dashboard updates, weekly summaries, compliance reports
- **Created:** 2026-02-10
- **Last Rotated:** 2026-02-25
- **Owner:** Jorge (VP AI-SecOps)
- **Rotation Schedule:** Quarterly
- **Next Rotation:** 2026-05-25
- **Used by workflows:**
  - update-ai-dashboard.yml
  - weekly-ai-summary.yml
  - update-project-progress.yml

### GITHUB_TOKEN
- **Provider:** GitHub (automatically provided)
- **Purpose:** Workflow automation, API access
- **Created:** Automatic
- **Last Rotated:** N/A (auto-generated per workflow run)
- **Owner:** System
- **Rotation Schedule:** N/A
- **Used by workflows:** All workflows (default)

### GH_ADMIN_TOKEN (Placeholder)
- **Provider:** GitHub (Personal Access Token)
- **Purpose:** SOC2 evidence collection, admin operations
- **Created:** TBD
- **Last Rotated:** TBD
- **Owner:** Jorge
- **Rotation Schedule:** Annually
- **Next Rotation:** TBD
- **Used by workflows:**
  - soc2-evidence-collection.yml
  - sync-sprint-boards.yml

## Rotation Schedule

| Secret | Last Rotated | Next Rotation | Status |
|--------|-------------|---------------|---------|
| ANTHROPIC_API_KEY | 2026-02-25 | 2026-05-25 | ✅ Current |
| GH_ADMIN_TOKEN | TBD | TBD | ⚠️ Pending setup |
| GITHUB_TOKEN | Auto | Auto | ✅ Auto-managed |

## Pending Secrets (To Be Added)

### OPENAI_API_KEY
- **Purpose:** AI dashboard, content generation
- **Owner:** TBD
- **Priority:** Medium
- **Action:** Create once OpenAI account is set up

### SLACK_WEBHOOK_URL
- **Purpose:** Workflow notifications
- **Owner:** TBD
- **Priority:** Low
- **Action:** Create once Slack workspace is set up

## Access Control

**Organization Owners (full access):**
- Jorge (VP AI-SecOps)
- Henry (CEO)

**To grant access:**
```bash
# Invite as owner
gh api /orgs/Seven-Fortunas-Internal/memberships/USERNAME \
  -X PUT -f role="admin"
```

## Rotation Procedure

### Quarterly Rotation (AI API Keys)

1. **Generate new key** from provider dashboard
2. **Update GitHub secret:**
   ```bash
   gh secret set ANTHROPIC_API_KEY --org Seven-Fortunas-Internal
   ```
3. **Test workflows** to ensure new key works
4. **Revoke old key** from provider
5. **Document rotation** in this file
6. **Schedule next rotation** (add to calendar)

### Annual Rotation (GitHub Tokens)

1. **Create fine-grained token** at https://github.com/settings/tokens
2. **Set permissions:** org:read, repo:read, project:write
3. **Update secret** via `gh secret set`
4. **Verify workflows** still function
5. **Delete old token**

## Audit Log

**Recent Changes:**

- **2026-02-25:** ANTHROPIC_API_KEY rotated (quarterly schedule)
- **2026-02-10:** ANTHROPIC_API_KEY created
- **2026-02-01:** GitHub organization secrets enabled

## Security Incident Response

**If secret is compromised:**

1. **Immediately rotate** the secret
2. **Revoke old key** from provider
3. **Check audit logs** for unauthorized access
4. **Notify team** via #security channel
5. **Document incident** in this file
6. **Review access controls**

## References

- [7f-secrets-manager Skill](../../../../.claude/commands/7f-secrets-manager.md)
- [Secrets Management Guide](../../../../docs/security/secrets-management-guide.md)
- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

---

**Owner:** Jorge (VP AI-SecOps)
**Last Updated:** 2026-02-25
**Next Review:** 2026-03-25 (monthly)
