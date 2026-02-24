# SOC 2 Compliance Dashboard

**Version:** 1.0  
**Date:** 2026-02-23  
**Owner:** Jorge (VP AI-SecOps)

## Overview

The SOC 2 Compliance Dashboard provides real-time visibility into the security control posture for Seven Fortunas infrastructure, mapped to SOC 2 Trust Service Criteria.

## Dashboard Location

**Platform:** CISO Assistant (Phase 1.5)  
**URL:** TBD (after CISO Assistant deployment)  
**Access:** Organization Admins only

## Dashboard Widgets

### 1. Control Posture Summary

**Type:** Pie Chart  
**Description:** Overall status of all GitHub security controls

**Metrics:**
- **Implemented (Green):** Controls with evidence collected and passing
- **Partial (Yellow):** Controls implemented but evidence collection failing
- **Not Implemented (Red):** Controls not yet configured
- **Not Applicable (Gray):** Controls not applicable to current phase

**Target:** >95% Implemented

### 2. SOC 2 Readiness Score

**Type:** Gauge  
**Description:** Percentage of SOC 2 controls with valid evidence

**Calculation:**
```
Readiness Score = (Controls with Valid Evidence) / (Total Applicable Controls) × 100
```

**Thresholds:**
- **Green (>95%):** Audit ready
- **Yellow (85-95%):** Minor gaps, action required
- **Red (<85%):** Major gaps, audit not recommended

**Current Target:** >95% for SOC 2 Type I readiness

### 3. Evidence Collection Status

**Type:** Table  
**Description:** Status of daily evidence collection runs

**Columns:**
- **Control ID:** GitHub control identifier (e.g., GH-ACCESS-001)
- **Description:** Control description
- **Last Collection:** Timestamp of last successful collection
- **Status:** Success/Failed/Pending
- **Evidence:** Link to evidence artifact

**Filters:**
- Last 7 days (default)
- Last 30 days
- Last 90 days
- All time

**Sort:** Most recent first

### 4. Compliance Drift Alerts

**Type:** Alert List  
**Description:** Controls that changed from compliant to non-compliant

**Alert Severity:**
- **Critical (Red):** 2FA disabled, secret scanning disabled
- **High (Orange):** Default permission changed, branch protection removed
- **Medium (Yellow):** Dependabot disabled, team access changed
- **Low (Blue):** Documentation updated, minor config changes

**Alert Details:**
- **Control ID:** GH-ACCESS-001
- **Change Detected:** 2026-02-23 14:32:00 UTC
- **Previous State:** two_factor_requirement_enabled = true
- **Current State:** two_factor_requirement_enabled = false
- **Action Required:** Re-enable 2FA enforcement immediately

**Auto-Resolution:** Alert clears when control returns to compliant state

### 5. Open Findings

**Type:** List  
**Description:** Controls with failed evidence collection or non-compliance

**Priority Order:**
1. **P0 (Critical):** Access controls, authentication
2. **P1 (High):** Secret detection, vulnerability management
3. **P2 (Medium):** Branch protection, change management
4. **P3 (Low):** Documentation, audit logs

**Columns:**
- **Finding ID:** Auto-generated (e.g., FIND-2026-001)
- **Control ID:** GitHub control affected
- **Severity:** P0/P1/P2/P3
- **Description:** What is not compliant
- **Opened:** Timestamp of detection
- **Owner:** Assigned team member
- **Status:** Open/In Progress/Resolved
- **SLA:** Time remaining to resolve

**SLA Targets:**
- P0: 4 hours
- P1: 24 hours
- P2: 7 days
- P3: 30 days

### 6. GitHub Organization Health

**Type:** Multi-metric Card  
**Description:** Key GitHub security metrics

**Metrics:**
- **2FA Enabled:** Yes/No (Organization-wide)
- **Default Permission:** none/read/write
- **Total Repositories:** Count
- **Protected Repositories:** Count with branch protection
- **Secret Scanning:** Enabled/Disabled
- **Dependabot Alerts:** Count of open alerts (Critical/High/Medium/Low)
- **Team-Based Access:** Percentage of repos with team access (not individual)

**Target:**
- 2FA: Yes
- Default Permission: none
- Protected Repositories: 100%
- Secret Scanning: Enabled
- Dependabot Alerts: 0 Critical/High
- Team-Based Access: 100%

### 7. Evidence Collection Trends

**Type:** Line Chart  
**Description:** Historical evidence collection success rate

**X-Axis:** Date (last 90 days)  
**Y-Axis:** Success Rate (%)

**Data Series:**
- **Overall Success Rate:** All controls
- **Critical Controls:** P0/P1 only
- **Target:** 100% baseline

**Use Case:** Identify patterns in evidence collection failures (e.g., API rate limits, token expiration)

### 8. SOC 2 Trust Service Criteria Coverage

**Type:** Heatmap  
**Description:** Evidence coverage by TSC category

**Rows:** Trust Service Criteria (CC, A, C, P, PI)  
**Columns:** Control domains (Access, Monitoring, Change, Availability)

**Cell Color:**
- **Green:** Evidence collected for all controls
- **Yellow:** Evidence collected for some controls
- **Red:** No evidence collected

**Drill-Down:** Click cell to view controls in that category

## Real-Time Monitoring

### Data Refresh

- **Dashboard:** Auto-refresh every 5 minutes
- **Evidence Collection:** Daily at 02:00 UTC
- **Drift Detection:** Real-time (on evidence collection)
- **Alerts:** Immediate (email/Slack)

### Data Sources

1. **GitHub API:** Organization and repository settings
2. **GitHub Actions:** Workflow execution logs
3. **CISO Assistant:** Evidence database
4. **Compliance Evidence Files:** JSON artifacts (90-day retention)

## Alerting Configuration

### Alert Channels

- **Email:** jorge@sevenfortunas.com
- **Slack:** #security-compliance (Phase 1.5)
- **Dashboard:** In-app notifications
- **PagerDuty:** Production only (Phase 2)

### Alert Rules

#### Critical: 2FA Enforcement Disabled
```yaml
alert: "2FA Enforcement Disabled"
control: GH-ACCESS-001
condition: two_factor_requirement_enabled == false
severity: Critical
notification: Email + Slack (immediate)
escalation: Page Jorge after 1 hour
```

#### High: Secret Scanning Disabled
```yaml
alert: "Secret Scanning Disabled"
control: GH-SEC-001
condition: secret_scanning_enabled_for_new_repositories == false
severity: High
notification: Email + Slack (immediate)
escalation: Email reminder after 4 hours
```

#### Medium: Branch Protection Removed
```yaml
alert: "Branch Protection Removed"
control: GH-SEC-003
condition: branch_protection == null
severity: Medium
notification: Email (daily digest)
escalation: None
```

## Access Control

### Dashboard Permissions

- **View Only:** All organization members
- **Edit:** Security team members
- **Admin:** Jorge (VP AI-SecOps)

### Audit Trail

All dashboard access and changes are logged:
- User: jorge@sevenfortunas.com
- Action: Viewed dashboard
- Timestamp: 2026-02-23 14:45:00 UTC
- IP Address: 192.168.1.100

**Retention:** 7 years (SOC 2 requirement)

## Compliance Reporting

### Monthly Report

**Generated:** First day of each month  
**Distribution:** Security team, leadership

**Sections:**
1. Executive Summary
2. Control Posture Summary (pass/fail by category)
3. Evidence Collection Metrics (success rate)
4. Compliance Drift Incidents (count, resolution time)
5. Open Findings (by priority)
6. Recommendations for improvement

### Quarterly Report

**Generated:** End of each quarter  
**Distribution:** Security team, leadership, board

**Sections:**
- All monthly report sections
- Trend analysis (quarter-over-quarter)
- SOC 2 readiness assessment
- Audit preparation checklist
- Risk register updates

### Annual Report

**Generated:** End of fiscal year  
**Distribution:** Security team, leadership, board, auditors

**Sections:**
- All quarterly report sections
- Annual compliance summary
- SOC 2 audit results (if conducted)
- Continuous improvement roadmap
- Budget recommendations

## Implementation Timeline

### Phase 1 (Current - FEATURE_022)
- [x] Document dashboard requirements
- [x] Define metrics and widgets
- [x] Create alerting rules
- [x] Document access control

### Phase 1.5 (Weeks 2-4)
- [ ] Deploy CISO Assistant
- [ ] Configure dashboard in CISO Assistant
- [ ] Test evidence collection integration
- [ ] Validate drift alerts
- [ ] Conduct user acceptance testing

### Phase 2 (Production)
- [ ] Enable Slack notifications
- [ ] Enable PagerDuty integration
- [ ] Set up automated monthly reports
- [ ] Conduct first SOC 2 audit

## Maintenance

### Daily
- Review evidence collection logs
- Check for compliance drift alerts
- Acknowledge and triage open findings

### Weekly
- Review open findings progress
- Update control documentation if needed
- Test alert notifications

### Monthly
- Generate compliance report
- Review SOC 2 readiness score
- Conduct control effectiveness reviews
- Update dashboard configuration if needed

### Quarterly
- Review and update control mappings
- Conduct mock SOC 2 audit
- Update alerting thresholds
- Train new team members on dashboard

## Resources

- **CISO Assistant Docs:** https://docs.ciso-assistant.com/
- **GitHub Control Mapping:** `compliance/soc2/github-control-mapping.md`
- **Evidence Collection Script:** `scripts/compliance/collect-github-evidence.sh`
- **GitHub Actions Workflow:** `.github/workflows/compliance-evidence-collection.yml`

---

**Next Actions:**
1. Deploy CISO Assistant (Phase 1.5)
2. Configure dashboard widgets (Phase 1.5)
3. Test evidence collection automation (Phase 1.5)
4. Validate alerting (Phase 1.5)
