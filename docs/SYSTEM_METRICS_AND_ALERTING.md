# System Metrics & Alerting - Seven Fortunas Infrastructure

**Version:** 1.0
**Last Updated:** 2026-02-24
**Priority:** P1 (Critical)
**Status:** Active

---

## Overview

The Seven Fortunas infrastructure collects and monitors key operational metrics to ensure system reliability. Critical alerts fire immediately when thresholds are exceeded, enabling rapid incident response.

---

## Monitored Metrics

### 1. Workflow Success Rate

**Metric:** Percentage of successful GitHub Actions workflow runs
**Target:** ≥ 95% success rate
**Alert Threshold:** < 95% success rate
**Measurement Window:** Rolling 24 hours

**Data Source:** GitHub Actions API
**Collection Frequency:** Every 6 hours
**Alert Channel:** GitHub Issues

**Critical Indicators:**
- Dashboard update workflow failures
- Deployment workflow failures
- Test workflow failures

---

### 2. API Rate Limit Usage

**Metric:** GitHub API rate limit consumption percentage
**Target:** < 90% of rate limit
**Alert Threshold:** ≥ 90% of rate limit
**Measurement Window:** Real-time

**Data Source:** GitHub API `X-RateLimit-*` headers
**Collection Frequency:** After every API call
**Alert Channel:** Workflow warnings, GitHub Issues if critical

**Critical Indicators:**
- Approaching rate limit (>90%)
- Rate limit exceeded (100%)
- Frequent 403 responses

---

### 3. Security Incidents

**Metric:** Security events detected by scanning tools
**Target:** 0 critical security incidents
**Alert Threshold:** Any critical/high severity incident
**Measurement Window:** Real-time

**Data Source:**
- Dependabot alerts
- Secret scanning alerts
- Code scanning (CodeQL) alerts

**Collection Frequency:** Real-time (GitHub webhooks)
**Alert Channel:** GitHub Issues, Email notifications

**Critical Indicators:**
- Exposed secrets detected
- Critical vulnerabilities in dependencies
- Security policy violations

---

### 4. Dashboard Data Freshness

**Metric:** Time since last successful dashboard update
**Target:** < 24 hours
**Alert Threshold:** > 48 hours stale
**Measurement Window:** Continuous

**Data Source:** Dashboard metadata files
**Collection Frequency:** Every 6 hours
**Alert Channel:** GitHub Issues

**Critical Indicators:**
- Dashboard not updated in 48+ hours
- RSS feed fetch failures
- Data source unavailable

---

### 5. Autonomous Agent Success Rate

**Metric:** Percentage of features passing verification
**Target:** ≥ 60% success rate (current: 90%)
**Alert Threshold:** < 50% success rate
**Measurement Window:** Per session

**Data Source:** `feature_list.json`, `claude-progress.txt`
**Collection Frequency:** End of each agent session
**Alert Channel:** Console output, GitHub Issues if blocked

**Critical Indicators:**
- Circuit breaker triggered
- Multiple consecutive feature failures
- Blocked features increasing

---

## Alert Rules

### Critical Alerts (Immediate Response Required)

| Alert | Condition | Response Time | Action |
|-------|-----------|---------------|--------|
| **Workflow Failure Rate High** | Success rate < 95% | < 1 hour | Investigate logs, disable failing workflows if needed |
| **API Rate Limit Critical** | Usage ≥ 95% | < 15 minutes | Pause API-heavy operations, wait for reset |
| **Secret Exposed** | Secret scanning alert | < 30 minutes | Revoke compromised secret, rotate credentials |
| **Critical Vulnerability** | CVE severity: CRITICAL | < 4 hours | Update dependency, deploy patch |
| **Dashboard Offline** | No updates in 72+ hours | < 24 hours | Check workflow status, re-run manually |

### Warning Alerts (Monitor, Non-Urgent)

| Alert | Condition | Response Time | Action |
|-------|-----------|---------------|--------|
| **Workflow Failure Rate Degrading** | Success rate 95-98% | < 24 hours | Review error patterns |
| **API Rate Limit Warning** | Usage 90-94% | < 1 hour | Optimize API calls, add caching |
| **High/Medium Vulnerability** | CVE severity: HIGH/MEDIUM | < 1 week | Schedule dependency update |
| **Dashboard Stale** | No updates in 48-72 hours | < 48 hours | Check data sources, verify cron schedules |

---

## Alert Channels

### 1. GitHub Issues (Primary)

**When to Use:** Critical alerts, tracking required

**Implementation:**
```yaml
# .github/workflows/monitoring.yml
- name: Create Alert Issue
  if: failure()
  uses: actions/github-script@v7
  with:
    script: |
      await github.rest.issues.create({
        owner: context.repo.owner,
        repo: context.repo.repo,
        title: '[ALERT] Workflow Failure Rate Critical',
        body: 'Success rate dropped below 95%. Immediate investigation required.',
        labels: ['alert', 'critical', 'monitoring']
      });
```

**Example Issue Template:**
```markdown
## 🚨 Alert: Workflow Failure Rate Critical

**Metric:** Workflow Success Rate
**Threshold:** 95%
**Current Value:** 89%
**Severity:** Critical
**Detected:** 2026-02-24 14:30 UTC

### Details
- Failed workflows: 11/100 in last 24 hours
- Most common failure: Dashboard update (5 failures)
- Error message: "HTTP 429: Rate limit exceeded"

### Recommended Actions
1. Check API rate limit usage
2. Review dashboard update logs
3. Implement retry with exponential backoff

### Related Logs
- Workflow run: https://github.com/Seven-Fortunas/7F_github/actions/runs/12345
- Error logs: [See run details]

---
*Auto-generated by monitoring workflow*
```

---

### 2. Workflow Warnings (Secondary)

**When to Use:** Non-critical warnings, informational

**Implementation:**
```yaml
- name: Warn if Rate Limit High
  run: |
    REMAINING=$(curl -s -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
      https://api.github.com/rate_limit | jq '.rate.remaining')
    LIMIT=$(curl -s -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
      https://api.github.com/rate_limit | jq '.rate.limit')
    PERCENTAGE=$((100 * REMAINING / LIMIT))

    if [ $PERCENTAGE -lt 10 ]; then
      echo "::warning::API rate limit at ${PERCENTAGE}% (${REMAINING}/${LIMIT} remaining)"
    fi
```

---

### 3. Slack/Discord (Future)

**When to Use:** Real-time team notifications

**Implementation:** Use GitHub Actions + webhook
```yaml
- name: Send Slack Alert
  if: failure()
  run: |
    curl -X POST ${{ secrets.SLACK_WEBHOOK_URL }} \
      -H 'Content-Type: application/json' \
      -d '{"text":"🚨 Workflow failure detected in Seven Fortunas infrastructure"}'
```

---

## Monitoring Workflows

### Workflow 1: Metrics Collection

**File:** `.github/workflows/collect-metrics.yml`
**Schedule:** Every 6 hours
**Purpose:** Collect and store system metrics

```yaml
name: Collect System Metrics

on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:

jobs:
  collect-metrics:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Collect Workflow Success Rate
        id: workflow_success
        run: |
          # Get last 100 workflow runs
          SUCCESS=$(gh run list --limit 100 --json conclusion \
            --jq '[.[] | select(.conclusion == "success")] | length')
          TOTAL=$(gh run list --limit 100 --json conclusion --jq 'length')
          RATE=$((100 * SUCCESS / TOTAL))

          echo "success_count=$SUCCESS" >> $GITHUB_OUTPUT
          echo "total_count=$TOTAL" >> $GITHUB_OUTPUT
          echo "success_rate=$RATE" >> $GITHUB_OUTPUT

          if [ $RATE -lt 95 ]; then
            echo "::error::Workflow success rate is ${RATE}% (threshold: 95%)"
            exit 1
          fi
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Collect API Rate Limit
        id: rate_limit
        run: |
          RESPONSE=$(curl -s -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
            https://api.github.com/rate_limit)

          REMAINING=$(echo $RESPONSE | jq '.rate.remaining')
          LIMIT=$(echo $RESPONSE | jq '.rate.limit')
          PERCENTAGE=$((100 * REMAINING / LIMIT))

          echo "remaining=$REMAINING" >> $GITHUB_OUTPUT
          echo "limit=$LIMIT" >> $GITHUB_OUTPUT
          echo "percentage=$PERCENTAGE" >> $GITHUB_OUTPUT

          if [ $PERCENTAGE -lt 10 ]; then
            echo "::warning::API rate limit at ${PERCENTAGE}% (${REMAINING}/${LIMIT})"
          fi

      - name: Store Metrics
        run: |
          mkdir -p metrics
          cat > metrics/metrics-$(date +%Y-%m-%d-%H-%M).json <<EOF
          {
            "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
            "workflow_success_rate": ${{ steps.workflow_success.outputs.success_rate }},
            "api_rate_limit_remaining": ${{ steps.rate_limit.outputs.remaining }},
            "api_rate_limit_percentage": ${{ steps.rate_limit.outputs.percentage }}
          }
          EOF

          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add metrics/
          git commit -m "chore: collect system metrics $(date +%Y-%m-%d-%H-%M)" || true
          git push || true

      - name: Create Alert Issue if Critical
        if: failure()
        uses: actions/github-script@v7
        with:
          script: |
            await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: '[ALERT] System Metrics Critical',
              body: `## 🚨 Critical Alert

              **Timestamp:** ${new Date().toISOString()}
              **Workflow:** ${context.workflow}
              **Run:** ${context.runId}

              One or more metrics exceeded critical thresholds. See workflow logs for details.

              ### Actions Required
              1. Review workflow logs
              2. Investigate root cause
              3. Take corrective action

              [View Workflow Run](${context.payload.repository.html_url}/actions/runs/${context.runId})`,
              labels: ['alert', 'critical', 'monitoring']
            });
```

---

### Workflow 2: Security Incident Response

**File:** `.github/workflows/security-incident.yml`
**Trigger:** On Dependabot/Secret Scanning alert
**Purpose:** Auto-create incident tracking issue

```yaml
name: Security Incident Response

on:
  security_and_analysis:
  repository_vulnerability_alert:
    types: [create]

jobs:
  create-incident:
    runs-on: ubuntu-latest
    steps:
      - name: Create Security Incident Issue
        uses: actions/github-script@v7
        with:
          script: |
            const severity = context.payload.alert.severity || 'unknown';
            const packageName = context.payload.alert.package?.name || 'unknown';

            await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `[SECURITY] ${severity.toUpperCase()}: ${packageName}`,
              body: `## 🔒 Security Incident Detected

              **Severity:** ${severity.toUpperCase()}
              **Package:** ${packageName}
              **Detected:** ${new Date().toISOString()}

              ### Details
              See Dependabot alert for full details.

              ### Response Actions
              - [ ] Assess impact
              - [ ] Update dependency
              - [ ] Test changes
              - [ ] Deploy patch
              - [ ] Verify fix

              **Target Resolution Time:**
              - CRITICAL: 4 hours
              - HIGH: 1 week
              - MEDIUM: 1 month`,
              labels: ['security', 'alert', severity]
            });
```

---

## Metrics Storage

### Storage Strategy

**Format:** JSON files in `metrics/` directory
**Retention:** 90 days (automated cleanup)
**Backup:** Git repository (automatic via commit)

**File Structure:**
```
metrics/
├── metrics-2026-02-24-14-00.json
├── metrics-2026-02-24-20-00.json
├── metrics-2026-02-25-02-00.json
└── README.md
```

**Example Metrics File:**
```json
{
  "timestamp": "2026-02-24T14:00:00Z",
  "workflow_success_rate": 98,
  "workflow_success_count": 98,
  "workflow_total_count": 100,
  "api_rate_limit_remaining": 4850,
  "api_rate_limit_limit": 5000,
  "api_rate_limit_percentage": 97,
  "dashboard_last_updated": "2026-02-24T08:30:00Z",
  "security_alerts_critical": 0,
  "security_alerts_high": 2,
  "security_alerts_medium": 5
}
```

---

## Alert Response Procedures

### 1. Workflow Failure Rate Critical

**Detection:** Success rate < 95%

**Response Steps:**
1. Check recent workflow runs: `gh run list --limit 20`
2. Identify most common failure pattern
3. Review error logs for failed runs
4. If API rate limit issue: Wait for reset or optimize calls
5. If infrastructure issue: Check GitHub Status page
6. If code issue: Fix bug, create PR, deploy
7. Update alert issue with resolution

**Escalation:** If unresolved after 4 hours, notify team lead

---

### 2. API Rate Limit Critical

**Detection:** Usage ≥ 95%

**Response Steps:**
1. Check current limit: `curl -H "Authorization: token $TOKEN" https://api.github.com/rate_limit`
2. Identify high-usage workflows (check recent runs)
3. Pause non-critical workflows temporarily
4. Wait for rate limit reset (hourly)
5. Implement caching or reduce API calls
6. Monitor usage for next 24 hours

**Prevention:**
- Add rate limit checks before API calls
- Implement exponential backoff
- Cache responses where possible
- Use GraphQL instead of REST (fewer calls)

---

### 3. Secret Exposed

**Detection:** Secret scanning alert

**Response Steps:**
1. **IMMEDIATE:** Revoke exposed secret (< 30 minutes)
2. Rotate all related credentials
3. Audit recent activity for misuse
4. Update secrets in GitHub Actions
5. Verify new secrets work
6. Document incident
7. Review commit history to find exposure source
8. Update `.gitignore` to prevent recurrence

**Critical:** Do NOT commit new secrets to fix old secrets!

---

## Success Criteria

NFR-8.2 is satisfied when:

1. ✅ Metrics collection workflow deployed and running every 6 hours
2. ✅ Alert rules configured for all critical metrics
3. ✅ GitHub Issues auto-created for critical alerts
4. ✅ Metrics stored in `metrics/` directory
5. ✅ Documentation exists for alert response procedures

---

## Future Enhancements (Phase 2)

- **Grafana Dashboard:** Visual metrics dashboard
- **Slack/Discord Integration:** Real-time team notifications
- **PagerDuty Integration:** On-call rotation and escalation
- **Metrics Aggregation:** Centralized metrics across all Seven Fortunas projects
- **Anomaly Detection:** ML-based anomaly detection for metrics
- **SLA Tracking:** Track and report on SLA compliance

---

**Owner:** Jorge (VP AI-SecOps)
**Review Date:** 2026-03-24 (monthly review)
