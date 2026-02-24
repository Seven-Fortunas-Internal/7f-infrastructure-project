# GitHub Actions Workflows

**Version:** 1.0  
**Date:** 2026-02-23  
**Owner:** Jorge (VP AI-SecOps)  
**Category:** DevOps & Deployment

## Overview

Seven Fortunas uses GitHub Actions to automate recurring tasks including dashboard updates, security scans, compliance evidence collection, and deployments.

## MVP Workflows (Implemented)

### 1. update-ai-dashboard.yml

**Purpose:** Auto-update AI Advancements Dashboard

**Trigger:** Daily at 06:00 UTC, manual dispatch

**Actions:**
- Fetch AI news from multiple sources
- Update dashboard.json
- Commit changes

**Secrets Required:**
- GITHUB_TOKEN (automatic)

**File:** `.github/workflows/update-ai-dashboard.yml`

### 2. weekly-ai-summary.yml

**Purpose:** Generate weekly AI advancement summaries

**Trigger:** Weekly on Sundays at 20:00 UTC, manual dispatch

**Actions:**
- Aggregate AI news from past week
- Generate markdown summary
- Create GitHub Issue with summary

**Secrets Required:**
- GITHUB_TOKEN (automatic)

**File:** `.github/workflows/weekly-ai-summary.yml`

### 3. dependabot-auto-merge.yml

**Purpose:** Auto-merge Dependabot PRs for minor/patch updates

**Trigger:** On pull_request from Dependabot

**Actions:**
- Check if PR is from Dependabot
- Verify semantic version (minor/patch only)
- Wait for CI to pass
- Auto-approve and merge

**Secrets Required:**
- GITHUB_TOKEN (automatic)

**File:** `.github/workflows/dependabot-auto-merge.yml`

### 4. pre-commit-validation.yml

**Purpose:** Validate code before commits

**Trigger:** On push to any branch, on pull_request

**Actions:**
- Run linters (shellcheck for bash scripts)
- Validate JSON files (jq syntax check)
- Check for hardcoded secrets
- Validate markdown links

**Secrets Required:**
- GITHUB_TOKEN (automatic)

**File:** `.github/workflows/pre-commit-validation.yml`

### 5. test-suite.yml

**Purpose:** Run automated test suite

**Trigger:** On push to main, on pull_request

**Actions:**
- Run unit tests
- Run integration tests
- Generate test coverage report
- Upload artifacts

**Secrets Required:**
- GITHUB_TOKEN (automatic)

**File:** `.github/workflows/test-suite.yml`

### 6. deploy-website.yml

**Purpose:** Deploy documentation website to GitHub Pages

**Trigger:** On push to main branch

**Actions:**
- Build static site from markdown
- Deploy to GitHub Pages
- Verify deployment

**Secrets Required:**
- GITHUB_TOKEN (automatic)

**File:** `.github/workflows/deploy-website.yml`

## Bonus Workflows (Implemented)

### 7. compliance-evidence-collection.yml

**Purpose:** Daily SOC 2 compliance evidence collection

**Trigger:** Daily at 02:00 UTC, manual dispatch

**Actions:**
- Collect GitHub security settings
- Generate evidence JSON
- Upload artifacts (90-day retention)
- Check for compliance drift

**Secrets Required:**
- GITHUB_TOKEN (automatic)
- CISO_ASSISTANT_API_KEY (Phase 1.5)
- CISO_ASSISTANT_URL (Phase 1.5)

**File:** `.github/workflows/compliance-evidence-collection.yml`

### 8. test-coverage-validation.yml

**Purpose:** Validate test coverage for all pass features

**Trigger:** On pull_request (feature_list.json changes), on push to main/autonomous-implementation

**Actions:**
- Validate README presence
- Check test coverage (100% required)
- Generate coverage report
- Upload report artifact

**Secrets Required:**
- GITHUB_TOKEN (automatic)

**File:** `.github/workflows/test-coverage-validation.yml`

## Phase 1.5 Workflows (Planned)

### 9. update-fintech-dashboard.yml

**Purpose:** Auto-update Fintech Trends Dashboard

**Trigger:** Daily at 06:30 UTC

**Actions:**
- Fetch fintech news from APIs
- Update dashboards/fintech/dashboard.json
- Commit changes

**Dependencies:** API keys for fintech news sources

### 10. update-edutech-dashboard.yml

**Purpose:** Auto-update EduTech Dashboard

**Trigger:** Daily at 07:00 UTC

**Actions:**
- Fetch education technology news
- Update dashboards/edutech/dashboard.json
- Commit changes

**Dependencies:** API keys for edutech news sources

### 11. update-security-dashboard.yml

**Purpose:** Auto-update Security Intelligence Dashboard

**Trigger:** Every 6 hours

**Actions:**
- Fetch CVE data from NVD
- Fetch security advisories
- Update dashboards/security/dashboard.json
- Commit changes

**Dependencies:** NVD API key

### 12. backup-compliance-evidence.yml

**Purpose:** Backup compliance evidence to long-term storage

**Trigger:** Daily at 03:00 UTC

**Actions:**
- Collect all evidence files
- Compress to tar.gz
- Upload to Azure Blob Storage
- Verify backup integrity

**Dependencies:**
- AZURE_STORAGE_ACCOUNT
- AZURE_STORAGE_KEY
- AZURE_STORAGE_CONTAINER

### 13. monthly-compliance-report.yml

**Purpose:** Generate monthly SOC 2 compliance report

**Trigger:** First day of each month at 08:00 UTC

**Actions:**
- Aggregate evidence from past month
- Calculate compliance score
- Generate PDF report
- Email to Jorge

**Dependencies:**
- EMAIL_SERVER
- EMAIL_CREDENTIALS

### 14. ciso-assistant-sync.yml

**Purpose:** Sync compliance evidence to CISO Assistant

**Trigger:** Daily at 03:30 UTC

**Actions:**
- Fetch latest evidence
- Upload to CISO Assistant API
- Verify sync status

**Dependencies:**
- CISO_ASSISTANT_API_KEY
- CISO_ASSISTANT_URL

## Phase 2 Workflows (Planned)

### 15. project-progress-dashboard-update.yml

**Purpose:** Update project progress dashboard (FR-8.3)

**Trigger:** On push to main

**Actions:**
- Parse feature_list.json
- Calculate metrics
- Update progress dashboard
- Generate velocity charts

### 16. slack-notifications.yml

**Purpose:** Send Slack notifications for key events

**Trigger:** On workflow_run completion

**Actions:**
- Detect workflow failures
- Send alert to #engineering channel
- Include error details and logs

**Dependencies:**
- SLACK_WEBHOOK_URL

### 17. performance-monitoring.yml

**Purpose:** Monitor dashboard performance

**Trigger:** Hourly

**Actions:**
- Ping all dashboards
- Measure load times
- Check API availability
- Alert if degraded

**Dependencies:**
- PINGDOM_API_KEY (or similar)

### 18. database-backup.yml

**Purpose:** Backup CISO Assistant database

**Trigger:** Daily at 04:00 UTC

**Actions:**
- Connect to database
- Export SQL dump
- Encrypt backup
- Upload to Azure Storage

**Dependencies:**
- DB_CONNECTION_STRING
- ENCRYPTION_KEY

### 19. security-scan.yml

**Purpose:** Run comprehensive security scans

**Trigger:** Weekly on Mondays at 01:00 UTC

**Actions:**
- Run Trivy container scan
- Run OWASP ZAP for web apps
- Run Snyk for dependencies
- Generate security report

**Dependencies:**
- SNYK_TOKEN

### 20. rotate-secrets.yml

**Purpose:** Rotate GitHub secrets quarterly

**Trigger:** Quarterly (manual)

**Actions:**
- Generate new API keys
- Update GitHub Secrets
- Test new keys
- Archive old keys securely

**Dependencies:**
- ORG_ADMIN_TOKEN

### 21. disaster-recovery-test.yml

**Purpose:** Test disaster recovery procedures

**Trigger:** Monthly (manual)

**Actions:**
- Restore from latest backup
- Verify data integrity
- Test failover procedures
- Generate DR report

### 22. cost-optimization-report.yml

**Purpose:** Generate cloud cost optimization report

**Trigger:** Weekly on Fridays

**Actions:**
- Analyze Azure usage
- Identify cost savings opportunities
- Generate recommendations
- Email report

**Dependencies:**
- AZURE_COST_MANAGEMENT_API_KEY

## Workflow Standards

### Naming Convention

- Use kebab-case: `update-ai-dashboard.yml`
- Be descriptive: `compliance-evidence-collection.yml` not `collect.yml`
- Include action: `deploy-website.yml` not `website.yml`

### Structure

```yaml
name: Descriptive Workflow Name

on:
  schedule:
    - cron: '0 6 * * *'  # Daily at 06:00 UTC
  workflow_dispatch:  # Manual trigger

permissions:
  contents: write  # Be explicit about permissions

jobs:
  job-name:
    runs-on: ubuntu-latest
    
    steps:
      - name: Descriptive step name
        uses: actions/checkout@v4
      
      - name: Another step
        run: |
          # Clear, commented commands
          echo "Doing something"
      
      - name: Error handling
        if: failure()
        run: |
          echo "Workflow failed, alerting team"
```

### Error Handling

**Always include:**
- `if: failure()` steps to handle errors
- `if: always()` for cleanup steps
- Email/Slack notifications on failure
- Artifact upload for debugging

**Example:**
```yaml
- name: Notify on failure
  if: failure()
  run: |
    curl -X POST ${{ secrets.SLACK_WEBHOOK_URL }} \
      -H 'Content-Type: application/json' \
      -d '{"text":"Workflow ${{ github.workflow }} failed!"}'
```

### Secrets Management

**Use GitHub Secrets for:**
- API keys
- Database credentials
- Encryption keys
- Webhook URLs

**Access in workflows:**
```yaml
env:
  API_KEY: ${{ secrets.MY_API_KEY }}
```

**Never hardcode:**
- Passwords
- API keys
- Connection strings
- Sensitive URLs

### Testing

**Before committing workflows:**
1. Validate syntax: `yamllint .github/workflows/*.yml`
2. Test locally: Use `act` (GitHub Actions locally)
3. Test in development branch
4. Verify workflow runs successfully
5. Check logs for errors

## Monitoring

### Workflow Status

**Check status:**
```bash
gh workflow list
gh workflow view update-ai-dashboard.yml
gh run list --workflow=update-ai-dashboard.yml
```

**View logs:**
```bash
gh run view <run-id>
gh run view <run-id> --log
```

### Alerts

**Current alerting:**
- Email on workflow failure (via GitHub notifications)
- Console output in workflow logs

**Future alerting (Phase 1.5):**
- Slack notifications (#engineering)
- PagerDuty for critical workflows
- Dashboard status indicators

## Maintenance

### Weekly
- Review workflow execution logs
- Check for failures
- Update dependencies (actions/checkout@v4, etc.)

### Monthly
- Review workflow efficiency
- Optimize slow workflows
- Archive unused workflows

### Quarterly
- Security audit of workflows
- Rotate secrets
- Update workflow permissions

## Resources

- **Workflows Directory:** `.github/workflows/`
- **Documentation:** `docs/github-actions-workflows.md` (this file)
- **GitHub Actions Docs:** https://docs.github.com/en/actions
- **Workflow Editor:** GitHub web UI (visual editor available)

---

**Next Actions:**
1. Review all workflows for errors
2. Test manual workflow dispatch
3. Set up Slack webhook (Phase 1.5)
4. Create Azure Storage for backups (Phase 1.5)
