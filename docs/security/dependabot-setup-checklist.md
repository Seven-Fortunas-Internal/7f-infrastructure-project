# Dependabot Setup Checklist

**Feature:** FR-5.2 Dependency Vulnerability Management
**Status:** Infrastructure operational, requires admin configuration
**Last Updated:** 2026-03-02

---

## Infrastructure Files (✓ Committed)

- [x] `.github/dependabot.yml` - Dependabot configuration
- [x] `.github/workflows/dependabot-auto-merge.yml` - Auto-merge with SLA enforcement
- [x] `compliance/sla/vulnerability-patch-slas.yaml` - SLA policy
- [x] `docs/security/vulnerability-patch-slas.md` - SLA documentation

---

## Manual Configuration Required

### 1. Enable Dependabot Security Updates (GitHub Admin)

**Location:** Repository Settings > Security > Dependabot

**Steps:**
1. Go to https://github.com/Seven-Fortunas-Internal/7f-infrastructure-project/settings/security_analysis
2. Enable "Dependabot security updates"
3. Enable "Dependabot alerts"

**Current Status:** DISABLED (requires manual enabling)

**Command to verify:**
```bash
gh api repos/Seven-Fortunas-Internal/7f-infrastructure-project --jq '.security_and_analysis.dependabot_security_updates.status'
# Should return: "enabled"
```

---

### 2. Configure Slack Webhook (GitHub Secrets)

**Secret Name:** `SLACK_WEBHOOK_URL`

**Steps:**
1. Create Slack incoming webhook at: https://api.slack.com/messaging/webhooks
2. Add webhook URL to GitHub Secrets:
   ```bash
   gh secret set SLACK_WEBHOOK_URL --repo Seven-Fortunas-Internal/7f-infrastructure-project
   ```
3. Paste webhook URL when prompted

**Current Status:** NOT CONFIGURED (optional but recommended)

**Notification Format:**
```
🔒 Dependabot Vulnerability Alert
Severity: critical
PR: Bump lodash from 4.17.19 to 4.17.21
URL: https://github.com/.../pull/123
SLA: 24h
```

---

### 3. Enable on All Repos

**For each repository:**

1. Copy `.github/dependabot.yml` from 7f-infrastructure-project
2. Copy `.github/workflows/dependabot-auto-merge.yml` from 7f-infrastructure-project
3. Enable Dependabot security updates in repo settings
4. Verify workflow runs on next Dependabot PR

**Automation script:**
```bash
# Run from 7f-infrastructure-project root
./scripts/setup_dependabot.sh --enable-all-repos
```

---

## SLA Compliance

| Severity | SLA Window | Auto-Merge | Manual Review |
|----------|------------|------------|---------------|
| Critical | 24 hours | No | Yes (required) |
| High | 7 days | Yes | Optional |
| Medium | 30 days | Yes | Optional |
| Low | 90 days | Yes | Optional |

**Auto-merge conditions:**
- All CI checks pass
- Not critical severity
- Within SLA window

---

## Verification Tests

### Test 1: Dependabot Enabled
```bash
gh api repos/Seven-Fortunas-Internal/7f-infrastructure-project \
  --jq '.security_and_analysis.dependabot_security_updates.status'
# Expected: "enabled"
```

### Test 2: Config File Valid
```bash
# Dependabot will validate on next run
test -f .github/dependabot.yml && echo "PASS" || echo "FAIL"
```

### Test 3: Workflow Exists
```bash
test -f .github/workflows/dependabot-auto-merge.yml && echo "PASS" || echo "FAIL"
```

### Test 4: Slack Notification (after PR created)
```bash
# Wait for next Dependabot PR, verify Slack message received within 15 minutes
```

---

## See Also

- [Vulnerability Patch SLAs](./vulnerability-patch-slas.md)
- [Dependabot Documentation](https://docs.github.com/en/code-security/dependabot)
- [SLA Compliance Monitoring](../../compliance/sla/vulnerability-patch-slas.yaml)

---

**Owner:** Jorge (VP AI-SecOps)
**Next Action:** Enable Dependabot security updates in repo settings
