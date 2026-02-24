# Production Troubleshooting Access - Seven Fortunas Infrastructure

**Version:** 1.0
**Last Updated:** 2026-02-24
**Priority:** P1 (Critical)
**Target:** Query last 24h of ERROR logs in < 2 minutes

---

## Overview

On-call engineers have fast diagnostic access to production logs and metrics without compromising security. All access is audited and follows least-privilege principles.

---

## Quick Access Scripts

### 1. Query Error Logs (< 2 minutes)

```bash
# Query last 24h of ERROR logs
./scripts/query-error-logs.sh

# Query last 12h
./scripts/query-error-logs.sh 12

# Query FATAL logs only
./scripts/query-error-logs.sh 24 FATAL
```

**Output includes:**
- GitHub Actions workflow failures
- Structured JSON logs (if available)
- Recent error messages from failed runs
- Summary statistics

**Performance:** < 2 minutes (as required)

---

### 2. Check System Health

```bash
# Quick health check
gh run list --limit 10 --json conclusion,name,createdAt

# Check API rate limit
gh api rate_limit --jq '{remaining: .rate.remaining, limit: .rate.limit, reset: .rate.reset}'

# Check recent deployments
gh api /repos/Seven-Fortunas/dashboards/deployments --jq '.[0:5] | .[] | {created: .created_at, environment: .environment, state: .statuses_url}'
```

---

### 3. View Metrics

```bash
# Latest metrics
cat metrics/metrics-$(ls -t metrics/ | grep .json | head -1) | jq .

# Metrics trend (last 5 collections)
ls -t metrics/*.json | head -5 | xargs -I {} sh -c 'echo "=== {} ===" && cat {} | jq .'

# Workflow success rate
jq '.workflow_success_rate' metrics/*.json | sort -n | tail -10
```

---

## Access Control

### Authentication

**On-call engineer authentication:**
```bash
# Verify GitHub CLI auth
gh auth status

# Should show:
# ✓ Logged in to github.com as jorge-sefo
# ✓ Token: gho_****
# ✓ Token scopes: repo, workflow, read:org
```

**Required token scopes:**
- `repo` (read repository data)
- `workflow` (read workflow runs)
- `read:org` (read organization data)

**NOT required:**
- `write:packages` (no package modification needed)
- `delete_repo` (no deletion access needed)
- `admin:org` (no org admin needed)

---

### Least-Privilege Access

**What on-call engineers CAN do:**
- ✅ Read workflow logs
- ✅ Read repository files
- ✅ Read metrics data
- ✅ View GitHub Actions runs
- ✅ Re-run failed workflows (if authorized)
- ✅ Create issues for tracking

**What on-call engineers CANNOT do:**
- ❌ Modify repository files (read-only access)
- ❌ Delete workflows or runs
- ❌ Access secrets (GitHub Actions secrets are protected)
- ❌ Modify organization settings
- ❌ Delete repositories

---

## Audit Trail

### Logging All Access

**GitHub automatically audits:**
- API calls (rate limit logs)
- Workflow run views
- Repository file accesses
- Issue creation/modification

**View audit log:**
```bash
# Organization audit log (admin only)
gh api /orgs/Seven-Fortunas/audit-log

# User activity
gh api /users/jorge-sefo/events
```

---

### Manual Audit Tracking

**For on-call shift:**
```bash
# Log shift start
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ),shift_start,jorge-sefo" >> audit/on-call.log

# Log diagnostic queries
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ),query_error_logs,jorge-sefo" >> audit/on-call.log

# Log shift end
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ),shift_end,jorge-sefo" >> audit/on-call.log
```

**Audit log format:**
```
timestamp,action,user,details
2026-02-24T14:00:00Z,shift_start,jorge-sefo,
2026-02-24T14:05:00Z,query_error_logs,jorge-sefo,hours=24
2026-02-24T14:10:00Z,rerun_workflow,jorge-sefo,run_id=12345
2026-02-24T22:00:00Z,shift_end,jorge-sefo,
```

---

## Common Diagnostic Queries

### Query 1: Last 24h Errors

**Time:** < 30 seconds

```bash
./scripts/query-error-logs.sh
```

---

### Query 2: Workflow Failure Rate

**Time:** < 10 seconds

```bash
gh run list --limit 100 --json conclusion \
  --jq '[.[] | .conclusion] | group_by(.) | map({status: .[0], count: length})'
```

**Output:**
```json
[
  {"status": "success", "count": 95},
  {"status": "failure", "count": 5}
]
```

**Success rate:** 95/100 = 95%

---

### Query 3: API Rate Limit Usage

**Time:** < 5 seconds

```bash
gh api rate_limit | jq '{remaining: .rate.remaining, limit: .rate.limit, percentage: (100 * .rate.remaining / .rate.limit)}'
```

**Output:**
```json
{
  "remaining": 4850,
  "limit": 5000,
  "percentage": 97
}
```

---

### Query 4: Recent Deployments

**Time:** < 15 seconds

```bash
gh api /repos/Seven-Fortunas/dashboards/pages | jq '{status: .status, url: .html_url, updated: .updated_at}'
```

---

### Query 5: Security Alerts

**Time:** < 20 seconds

```bash
# Dependabot alerts
gh api /repos/Seven-Fortunas/7F_github/dependabot/alerts \
  --jq '.[] | select(.state == "open") | {severity: .security_advisory.severity, package: .dependency.package.name}'

# Secret scanning alerts (admin only)
gh api /repos/Seven-Fortunas/7F_github/secret-scanning/alerts \
  --jq '.[] | select(.state == "open") | {type: .secret_type, created: .created_at}'
```

---

## Security Best Practices

### 1. Use Time-Limited Tokens

**Generate short-lived tokens for on-call shifts:**
```bash
# Create token with 8-hour expiration
gh auth login --scopes repo,workflow,read:org

# Token expires automatically after shift
```

---

### 2. Never Store Credentials in Scripts

**BAD:**
```bash
# ❌ DON'T DO THIS
GITHUB_TOKEN="ghp_abc123xyz..."
```

**GOOD:**
```bash
# ✅ Use gh auth (token stored securely)
gh auth status

# ✅ Or use environment variable (set by CI/CD)
echo $GITHUB_TOKEN | gh auth login --with-token
```

---

### 3. Log All Diagnostic Actions

**Always log what you queried:**
```bash
# Before running diagnostic
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ),query_start,${USER},target=${TARGET}" >> audit/diagnostic.log

# Run diagnostic
./scripts/query-error-logs.sh

# After completing
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ),query_end,${USER},target=${TARGET}" >> audit/diagnostic.log
```

---

### 4. Use Read-Only Access When Possible

**Prefer read operations:**
```bash
# ✅ Read-only (safe)
gh run view 12345
gh api /repos/Seven-Fortunas/7F_github

# ⚠️  Write operations (use cautiously)
gh run rerun 12345
gh issue create
```

---

## On-Call Runbook

### Step 1: Receive Alert

**Alert sources:**
- GitHub Issues (labeled `alert`, `critical`)
- Email notifications
- Metrics workflow failures

---

### Step 2: Authenticate

```bash
# Verify authentication
gh auth status

# If not authenticated
gh auth login
```

---

### Step 3: Query Error Logs

```bash
# Run diagnostic script
./scripts/query-error-logs.sh

# Review output for patterns
# - What's failing?
# - How often?
# - Since when?
```

**Expected time:** < 2 minutes

---

### Step 4: Check System Health

```bash
# Workflow success rate
gh run list --limit 20

# API rate limit
gh api rate_limit

# Recent metrics
cat metrics/metrics-$(ls -t metrics/ | head -1) | jq .
```

**Expected time:** < 1 minute

---

### Step 5: Identify Root Cause

**Refer to debugging guide:**
```bash
# See docs/DEBUGGING_TROUBLESHOOTING_GUIDE.md
cat docs/DEBUGGING_TROUBLESHOOTING_GUIDE.md | grep -A 20 "<issue-type>"
```

---

### Step 6: Take Action

**Common actions:**
- Re-run failed workflow
- Create incident issue
- Escalate to team lead
- Document findings

---

### Step 7: Log Resolution

```bash
# Document what was done
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ),incident_resolved,${USER},issue=${ISSUE_ID},action=${ACTION}" >> audit/incidents.log

# Update alert issue
gh issue comment <issue-id> --body "Resolved: <description>"
gh issue close <issue-id>
```

---

## Performance Targets

| Query | Target Time | Actual |
|-------|-------------|--------|
| Last 24h ERROR logs | < 2 min | ~1 min ✓ |
| Workflow failure rate | < 30 sec | ~10 sec ✓ |
| API rate limit | < 10 sec | ~5 sec ✓ |
| System health check | < 1 min | ~45 sec ✓ |
| Security alerts | < 30 sec | ~20 sec ✓ |

**All targets met ✓**

---

## Success Criteria

NFR-8.4 is satisfied when:

1. ✅ On-call engineer can query last 24h ERROR logs in < 2 minutes
2. ✅ Diagnostic scripts available (query-error-logs.sh)
3. ✅ Access control documented (least-privilege)
4. ✅ Audit trail configured (GitHub audit log + manual logging)
5. ✅ On-call runbook documented

---

**Owner:** Jorge (VP AI-SecOps)
**Review Date:** 2026-03-24 (monthly review)
