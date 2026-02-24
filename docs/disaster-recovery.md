# Disaster Recovery Plan - Seven Fortunas Infrastructure

**Last Updated:** 2026-02-24
**Owner:** DevOps Team
**Review Frequency:** Quarterly

---

## Overview

This document outlines the disaster recovery (DR) strategy for the Seven Fortunas infrastructure, designed to meet:

- **RTO (Recovery Time Objective):** 1 hour
- **RPO (Recovery Point Objective):** 6 hours maximum

The infrastructure is built on GitHub's cloud platform, providing inherent redundancy and disaster recovery capabilities.

---

## Architecture Resilience

### GitHub Platform Benefits

- **Multi-region redundancy:** GitHub maintains data centers across multiple regions
- **Automatic backups:** Git commits provide point-in-time recovery
- **High availability:** 99.9% uptime SLA
- **Geographic distribution:** Content delivery via CDN for GitHub Pages

### Critical Components

| Component | Backup Method | Recovery Time | RPO |
|-----------|---------------|---------------|-----|
| Git Repositories | Native Git replication | 5 minutes | Real-time |
| GitHub Actions Workflows | Version controlled in repos | 10 minutes | Real-time |
| GitHub Pages Sites | Rebuilt from source | 15 minutes | Last commit |
| Dashboard Data (JSON) | Committed to repos | 5 minutes | Last data aggregation (≤6h) |
| Secrets (GitHub Secrets) | Documented in runbook | 20 minutes | Manual restoration |
| Organization Settings | IaC scripts | 15 minutes | Last script run |

**Total Maximum Recovery Time:** 60 minutes (within RTO)
**Total Maximum Data Loss:** 6 hours (dashboard aggregation interval - within RPO)

---

## Disaster Scenarios

### Scenario 1: Repository Deletion

**Impact:** Loss of code, documentation, or configuration
**Likelihood:** Low (protected branches, access controls)
**Recovery Strategy:**

```bash
# 1. Check GitHub's repository restore feature (90-day retention)
gh api repos/{org}/{repo}/restore -X POST

# 2. If beyond retention, restore from local clone
git clone --mirror /path/to/local/backup/{repo}.git
cd {repo}.git
git push --mirror https://github.com/{org}/{repo}.git

# 3. Verify restoration
gh repo view {org}/{repo}
```

**Estimated Recovery Time:** 15 minutes

---

### Scenario 2: GitHub Pages Site Failure

**Impact:** Dashboard/documentation sites unavailable
**Likelihood:** Low (GitHub infrastructure redundancy)
**Recovery Strategy:**

```bash
# 1. Verify GitHub Pages status
curl -I https://{org}.github.io/{repo}/

# 2. Check GitHub Actions deployment workflow
gh run list --repo {org}/{repo} --workflow deploy.yml --limit 5

# 3. Trigger manual rebuild if needed
gh workflow run deploy.yml --repo {org}/{repo}

# 4. Monitor build progress
gh run watch

# 5. Verify site restoration
curl -sf https://{org}.github.io/{repo}/ | grep "<!DOCTYPE html"
```

**Estimated Recovery Time:** 20 minutes

---

### Scenario 3: Secrets Compromise

**Impact:** Authentication tokens, API keys exposed
**Likelihood:** Low (secret scanning, access controls)
**Recovery Strategy:**

```bash
# 1. Immediately rotate compromised secrets
gh secret set ANTHROPIC_API_KEY --repo {org}/{repo}
gh secret set GH_TOKEN --repo {org}/{repo}

# 2. Revoke old tokens at source
# - GitHub: https://github.com/settings/tokens
# - Anthropic: https://console.anthropic.com/settings/keys

# 3. Update documentation with new credentials
# 4. Re-run workflows to verify access
gh workflow run test-auth.yml --repo {org}/{repo}

# 5. Audit access logs
gh api /orgs/{org}/audit-log
```

**Estimated Recovery Time:** 30 minutes

---

### Scenario 4: Organization Account Compromise

**Impact:** Complete access loss to all repositories
**Likelihood:** Very Low (2FA required, SSO, audit logging)
**Recovery Strategy:**

```bash
# 1. Contact GitHub Support immediately
# Support ticket: https://support.github.com/

# 2. Restore from local mirrors while GitHub investigates
for repo in $(cat critical-repos.txt); do
  git clone --mirror /backups/$repo.git
  # Hold for re-push after account recovery
done

# 3. Once access restored, verify organization settings
gh api /orgs/{org} | jq '.two_factor_requirement_enabled'
gh api /orgs/{org}/members --paginate | jq -r '.[].login'

# 4. Re-apply organization security settings
./scripts/configure-org-security.sh

# 5. Audit all access and recent activity
gh api /orgs/{org}/audit-log --paginate | jq '.[] | select(.created_at > "2026-02-24")'
```

**Estimated Recovery Time:** 60 minutes (assumes GitHub Support response within SLA)

---

### Scenario 5: Dashboard Data Corruption

**Impact:** Incorrect metrics, broken visualizations
**Likelihood:** Medium (automation errors, API changes)
**Recovery Strategy:**

```bash
# 1. Identify last known good commit
cd dashboards/
git log --oneline data/*.json | head -20

# 2. Restore from git history
git checkout HEAD~1 -- data/sprint-metrics.json
git checkout HEAD~1 -- data/velocity-data.json

# 3. Verify data integrity
jq empty data/*.json && echo "JSON valid"

# 4. Re-run data aggregation for missing period
./scripts/aggregate-dashboard-data.sh --start "2026-02-24" --end "2026-02-24"

# 5. Commit corrected data
git add data/*.json
git commit -m "fix: restore dashboard data from corruption"
git push
```

**Estimated Recovery Time:** 20 minutes
**Data Loss:** Maximum 6 hours (last aggregation interval)

---

## Backup Procedures

### Automated Backups

**Daily (Midnight UTC):**
```bash
# Automated via GitHub Actions: .github/workflows/backup.yml
# - Creates snapshots of all organization repos
# - Stores metadata for quick recovery
# - Validates backup integrity
```

**Continuous (Real-time):**
- Git commits (automatic via version control)
- GitHub Actions workflow runs (retained for 90 days)
- Audit logs (retained for 90 days in GitHub Enterprise)

### Manual Backup (Quarterly DR Drills)

```bash
# Run quarterly: Month 2, 5, 8, 11
./scripts/dr-test.sh --mode backup --verify
```

---

## Recovery Procedures

### Pre-Recovery Checklist

- [ ] Incident logged and stakeholders notified
- [ ] Root cause identified (if possible)
- [ ] Recovery strategy selected based on scenario
- [ ] Backup validation completed
- [ ] Recovery timeline communicated (target: 1 hour RTO)

### Recovery Execution

1. **Isolate the Problem** (5 minutes)
   - Determine scope of failure
   - Prevent further damage
   - Document incident timeline

2. **Select Recovery Method** (5 minutes)
   - Match scenario to recovery procedure
   - Verify backup availability
   - Calculate expected RTO/RPO

3. **Execute Recovery** (30 minutes)
   - Follow scenario-specific procedure
   - Monitor progress continuously
   - Document actions taken

4. **Verify Recovery** (15 minutes)
   - Test all critical functions
   - Verify data integrity
   - Confirm user access

5. **Post-Recovery Review** (5 minutes within incident, full review later)
   - Update incident log
   - Notify stakeholders of completion
   - Schedule post-mortem

---

## Testing Schedule

### Quarterly DR Drills

**Schedule:** Month 2, 5, 8, 11 (February, May, August, November)

**Test Scenarios (Rotate):**

| Quarter | Primary Test Scenario | Secondary Validation |
|---------|----------------------|---------------------|
| Q1 (Feb) | Repository deletion recovery | Secrets rotation |
| Q2 (May) | GitHub Pages rebuild | Dashboard data restore |
| Q3 (Aug) | Full organization backup | Access control verification |
| Q4 (Nov) | Multi-component failure | End-to-end recovery |

**Execution:**
```bash
# Automated DR drill
./scripts/dr-test.sh --mode drill --scenario repo-deletion

# Manual verification
# Follow test plan in docs/dr-test-plans/
```

**Success Criteria:**
- RTO met: Recovery within 60 minutes
- RPO met: Data loss ≤ 6 hours
- All critical components operational
- No data corruption detected

---

## Monitoring and Alerts

### Health Checks (Every 5 minutes)

```bash
# Automated via GitHub Actions: .github/workflows/health-check.yml
# Monitors:
# - GitHub API availability
# - GitHub Pages site status
# - Dashboard data freshness
# - Workflow execution success rate
```

### Alert Thresholds

| Metric | Warning | Critical | Action |
|--------|---------|----------|--------|
| GitHub API error rate | >5% | >15% | Initiate DR procedure |
| Pages site downtime | >5 min | >15 min | Rebuild site |
| Dashboard data age | >4 hours | >6 hours | Trigger aggregation |
| Workflow failure rate | >10% | >25% | Investigate + restore |

---

## Roles and Responsibilities

### Incident Commander
- **Primary:** DevOps Lead
- **Backup:** Security Lead
- **Responsibilities:** Declare disaster, coordinate recovery, communicate status

### Technical Recovery Team
- **Members:** DevOps engineers, Security engineers
- **Responsibilities:** Execute recovery procedures, verify restoration

### Communication Lead
- **Primary:** Product Owner
- **Responsibilities:** Notify stakeholders, provide status updates

### Post-Mortem Facilitator
- **Primary:** Engineering Manager
- **Responsibilities:** Document lessons learned, update DR plan

---

## Contact Information

### Emergency Contacts

- **GitHub Support:** https://support.github.com/ (Enterprise SLA: 1-hour response)
- **DevOps On-Call:** Slack #devops-oncall
- **Security Team:** Slack #security-incidents

### Escalation Path

1. DevOps Engineer (0-15 minutes)
2. DevOps Lead (15-30 minutes)
3. Engineering Manager (30-45 minutes)
4. VP Engineering (45-60 minutes)

---

## Post-Disaster Review

### Within 24 Hours

- [ ] Incident timeline documented
- [ ] Root cause identified
- [ ] Recovery actions logged
- [ ] RTO/RPO metrics calculated
- [ ] Stakeholder communication sent

### Within 1 Week

- [ ] Post-mortem meeting held
- [ ] Action items identified
- [ ] DR plan updated
- [ ] Related documentation updated
- [ ] Team training needs identified

---

## Appendices

### A. Critical Repositories

```
Seven-Fortunas-Internal/seven-fortunas-brain
Seven-Fortunas-Internal/7f-infrastructure-project
Seven-Fortunas/dashboards
```

### B. Backup Validation Script

See: `scripts/dr-test.sh --mode validate`

### C. Recovery Runbook Quick Reference

| Scenario | Script | Max Time |
|----------|--------|----------|
| Repo deletion | `gh api repos/{org}/{repo}/restore -X POST` | 15 min |
| Pages rebuild | `gh workflow run deploy.yml` | 20 min |
| Secrets rotation | `gh secret set {SECRET}` | 30 min |
| Data restore | `git checkout HEAD~1 -- data/` | 20 min |
| Org recovery | Contact GitHub Support + local mirrors | 60 min |

### D. Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-02-24 | Autonomous Agent | Initial DR plan creation |

---

**Next Review Date:** 2026-05-24 (Q2 DR Drill)
**Document Owner:** DevOps Team
**Approval:** Pending
