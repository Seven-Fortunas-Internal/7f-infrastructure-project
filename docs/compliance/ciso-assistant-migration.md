# CISO Assistant Migration to Seven-Fortunas-Internal

**Version:** 1.0  
**Date:** 2026-02-23  
**Owner:** Jorge (VP AI-SecOps)

## Overview

This guide documents the migration of CISO Assistant to the Seven-Fortunas-Internal organization for SOC 2 compliance management.

## What is CISO Assistant?

CISO Assistant is an open-source governance, risk, and compliance (GRC) platform that:
- Maps security controls to compliance frameworks (SOC 2, ISO 27001, etc.)
- Collects and stores compliance evidence
- Provides compliance dashboards and reporting
- Tracks control implementation and effectiveness

**Repository:** https://github.com/intuitem/ciso-assistant-community

## Migration Steps

### 1. Fork CISO Assistant to Seven-Fortunas-Internal

```bash
# Navigate to CISO Assistant repository
# https://github.com/intuitem/ciso-assistant-community

# Click "Fork" button
# Select organization: Seven-Fortunas-Internal
# Repository name: ciso-assistant
# Description: SOC 2 compliance management platform
```

### 2. Deploy CISO Assistant Instance

**Option A: Docker Compose (Recommended for Phase 1.5)**

```bash
# Clone the forked repository
git clone https://github.com/Seven-Fortunas-Internal/ciso-assistant.git
cd ciso-assistant

# Configure environment
cp .env.example .env
# Edit .env with production settings

# Deploy
docker-compose up -d

# Access at: http://localhost:8000
```

**Option B: Cloud Deployment (Production)**

Deploy to Azure Container Instances or AWS ECS:
- Database: PostgreSQL (Azure Database or AWS RDS)
- Storage: Azure Blob Storage or AWS S3
- Authentication: Azure AD or AWS Cognito integration

### 3. Initial Configuration

#### Create Seven Fortunas Organization

```bash
# Login to CISO Assistant
# Create organization: "Seven Fortunas"
# Add users:
#   - Jorge (Admin)
#   - Team members (as needed)
```

#### Import SOC 2 Framework

```bash
# Navigate to: Frameworks > Import
# Select: SOC 2 Type II (2023)
# Import all Trust Service Criteria
```

#### Map GitHub Controls

1. Navigate to: Controls > Import
2. Import custom control library: `compliance/soc2/github-control-mapping.md`
3. Map each GitHub control to SOC 2 criteria
4. Set evidence collection frequency: Daily

### 4. Configure Evidence Collection Integration

#### GitHub API Authentication

```bash
# Create GitHub Personal Access Token (PAT) or GitHub App
# Scopes required:
#   - read:org
#   - read:repo
#   - read:user

# Store in CISO Assistant:
# Settings > Integrations > GitHub
# API Token: [paste token]
# Organization: Seven-Fortunas-Internal
```

#### Evidence Collection Schedule

```bash
# Configure evidence collection in CISO Assistant:
# Settings > Evidence > Automation

# Schedule:
#   - Frequency: Daily
#   - Time: 02:00 UTC
#   - Controls: All GitHub controls (GH-*)

# Notification:
#   - Email: jorge@sevenfortunas.com
#   - Slack: #security-compliance (Phase 1.5)
```

### 5. Set Up Compliance Dashboard

#### Dashboard Configuration

Navigate to: Dashboards > Create New Dashboard

**Dashboard Name:** GitHub Security Compliance

**Widgets:**
1. **Control Posture Summary**
   - Type: Pie chart
   - Data: Control status (implemented, partial, not implemented)
   - Filters: All GitHub controls

2. **Evidence Collection Status**
   - Type: Table
   - Data: Last evidence collection timestamp, status
   - Filters: Last 30 days

3. **Drift Detection Alerts**
   - Type: Alert list
   - Data: Controls that changed from compliant to non-compliant
   - Filters: Last 7 days

4. **SOC 2 Readiness Score**
   - Type: Gauge
   - Data: Percentage of controls with evidence collected
   - Target: >95%

5. **Open Findings**
   - Type: List
   - Data: Controls with failed evidence collection or non-compliance
   - Priority: P0/P1 first

### 6. Configure Drift Alerts

#### Alert Rules

Create alert rules for each control:

```yaml
# Example: 2FA Enforcement Drift Alert
alert_name: "2FA Enforcement Disabled"
control_id: "GH-ACCESS-001"
trigger_condition: "two_factor_requirement_enabled == false"
severity: "Critical"
notification_channel: "email, slack"
recipients:
  - jorge@sevenfortunas.com
escalation_time: 1 hour
```

#### Alert Channels

- **Email:** jorge@sevenfortunas.com
- **Slack:** #security-compliance (Phase 1.5)
- **PagerDuty:** (Production only)

### 7. Backup and Disaster Recovery

#### Database Backup

```bash
# Daily database backup
# Retention: 30 days (operational), 7 years (compliance archives)

# Backup script (crontab)
0 3 * * * docker exec ciso-assistant-db pg_dump -U postgres ciso_assistant > /backup/ciso-assistant-$(date +\%Y\%m\%d).sql
```

#### Evidence Retention

- **Primary:** CISO Assistant database (7 years)
- **Secondary:** GitHub Actions artifacts (90 days)
- **Archive:** Azure Blob Storage (7 years, immutable)

## Integration with GitHub Actions

### Daily Evidence Collection Workflow

Create `.github/workflows/compliance-evidence-collection.yml`:

```yaml
name: SOC 2 Evidence Collection

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 02:00 UTC
  workflow_dispatch:  # Manual trigger

jobs:
  collect-evidence:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Collect GitHub evidence
        run: |
          bash scripts/compliance/collect-github-evidence.sh

      - name: Upload evidence to CISO Assistant
        env:
          CISO_ASSISTANT_API_KEY: ${{ secrets.CISO_ASSISTANT_API_KEY }}
          CISO_ASSISTANT_URL: ${{ secrets.CISO_ASSISTANT_URL }}
        run: |
          # Upload evidence JSON to CISO Assistant
          curl -X POST "${CISO_ASSISTANT_URL}/api/v1/evidence" \
            -H "Authorization: Bearer ${CISO_ASSISTANT_API_KEY}" \
            -H "Content-Type: application/json" \
            -d @/tmp/compliance-evidence/latest.json

      - name: Archive evidence
        uses: actions/upload-artifact@v4
        with:
          name: compliance-evidence-${{ github.run_id }}
          path: /tmp/compliance-evidence/*.json
          retention-days: 90
```

## Verification Checklist

### Functional Verification
- [ ] CISO Assistant forked to Seven-Fortunas-Internal
- [ ] CISO Assistant instance deployed and accessible
- [ ] SOC 2 framework imported
- [ ] GitHub controls mapped to SOC 2 criteria
- [ ] Evidence collection configured (daily sync)

### Technical Verification
- [ ] GitHub API authentication configured
- [ ] Evidence collection script runs successfully
- [ ] Compliance dashboard displays real-time data
- [ ] Database backup configured (daily)
- [ ] Evidence retention policy configured (7 years)

### Integration Verification
- [ ] GitHub Actions workflow deployed
- [ ] Evidence uploaded to CISO Assistant successfully
- [ ] Drift alerts configured and tested
- [ ] Email/Slack notifications working
- [ ] Audit trail captured for all activities

## Timeline

- **Week 1 (Current):** Documentation and planning (FEATURE_022)
- **Week 2-3 (Phase 1.5):** 
  - Fork and deploy CISO Assistant
  - Configure controls and evidence collection
  - Create compliance dashboard
- **Week 4 (Phase 1.5):**
  - Test drift alerts
  - Validate evidence collection automation
  - Conduct mock SOC 2 audit

## Resources

- **CISO Assistant Docs:** https://docs.ciso-assistant.com/
- **SOC 2 Trust Service Criteria:** https://www.aicpa.org/soc2
- **GitHub Control Mapping:** `compliance/soc2/github-control-mapping.md`
- **Evidence Collection Script:** `scripts/compliance/collect-github-evidence.sh`

---

**Next Actions:**
1. Fork CISO Assistant repository (Jorge)
2. Deploy CISO Assistant instance (Phase 1.5)
3. Configure GitHub integration (Phase 1.5)
4. Test evidence collection automation (Phase 1.5)
