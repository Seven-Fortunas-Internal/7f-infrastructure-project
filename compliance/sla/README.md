# Vulnerability Patch SLAs

**Purpose:** Define and enforce Service Level Agreements for patching security vulnerabilities

## Overview

Seven Fortunas maintains strict SLAs for patching security vulnerabilities to ensure rapid response to security threats and maintain SOC 2 compliance.

## SLA Policy

### Patch Windows by Severity

| Severity | Patch Window | Auto-Merge | Manual Review |
|----------|--------------|------------|---------------|
| **Critical** | 24 hours (1 day) | ❌ No | ✅ Required |
| **High** | 7 days | ✅ Yes | ⚫ Optional |
| **Medium** | 30 days | ✅ Yes | ⚫ Optional |
| **Low** | 90 days | ✅ Yes | ⚫ Optional |

**Policy Document:** `vulnerability-patch-slas.yaml`

---

## Automated Patching Workflow

### Dependabot Integration

**Configuration:** `.github/dependabot.yml`
**Auto-merge Workflow:** `.github/workflows/dependabot-auto-merge.yml`

### How It Works

1. **Dependabot** scans dependencies and creates PRs for vulnerabilities
2. **Auto-merge workflow** evaluates severity and SLA compliance
3. **High/Medium/Low** vulnerabilities auto-merge after CI passes
4. **Critical** vulnerabilities require manual review within 24 hours
5. **SLA breach warnings** sent at 80% of patch window

### Alert Channels

- **Critical:** Email + Matrix + GitHub Issue
- **High:** Email + Matrix
- **Medium:** GitHub Issue
- **Low:** No alerts (auto-patched)

---

## Monthly SLA Audit

### Audit Process

**Script:** `scripts/monthly-vulnerability-sla-audit.sh`
**Frequency:** Monthly (1st of each month)
**Owner:** Jorge (VP AI-SecOps)

### Audit Checks

1. **SLA Compliance Rate** - % of vulnerabilities patched within SLA
2. **Average Patch Time** - By severity level
3. **SLA Breaches** - Count and root cause analysis
4. **Auto-merge Success Rate** - Automation effectiveness
5. **Manual Intervention Rate** - Critical patches requiring review

### Audit Reports

**Location:** `compliance/sla/audit-reports/`
**Format:** JSON + Markdown summary
**Integration:** Fed into SOC 2 compliance tracking

---

## SLA Breach Alerts

### Warning Threshold: 80%

When a vulnerability PR reaches 80% of its SLA window, automated warnings are sent:

**For Critical (19.2 hours):**
```
🚨 CRITICAL Vulnerability - Manual review required within 24 hours (SLA compliance)

Severity: critical
SLA Window: 24 hours
Elapsed: 19.2 hours (80%)
Action Required: Review and merge this PR within 4.8 hours
```

**For Other Severities:**
```
⚠️ SLA Breach Warning - This vulnerability PR is approaching the SLA window (80% elapsed)

Severity: high
SLA Window: 168 hours (7 days)
Elapsed: 134.4 hours (80%)
Action: Merge this PR to maintain SLA compliance
```

---

## Integration with Other Systems

### Dependency Management (FR-5.2)

Vulnerability patch SLAs are part of the broader dependency vulnerability management system:
- Dependabot monitors all dependencies
- Security advisories tracked via GitHub API
- Patch automation reduces manual burden

### SOC 2 Compliance (FR-5.4)

SLA metrics feed into SOC 2 compliance tracking:
- Monthly audit reports demonstrate patch discipline
- SLA compliance rate tracked as SOC 2 metric
- Breach incidents logged and reviewed

---

## Metrics Tracked

1. **sla_compliance_rate** - % of vulnerabilities patched within SLA
2. **average_patch_time_by_severity** - Mean time to patch by severity
3. **sla_breaches_count** - Number of SLA breaches per month
4. **auto_merge_success_rate** - % of auto-merges successful
5. **manual_intervention_rate** - % requiring manual review

**Dashboard:** Security metrics dashboard integrates these metrics

---

## Manual Audit Procedure

### Monthly Audit (1st of each month)

```bash
# Run automated audit script
cd /home/ladmin/dev/GDF/7F_github
bash scripts/monthly-vulnerability-sla-audit.sh

# Review audit report
cat compliance/sla/audit-reports/vulnerability-sla-audit-YYYYMMDD-HHMMSS.json

# Update SOC 2 evidence
# (report is automatically saved to audit-reports/ for SOC 2)
```

### Ad-hoc Compliance Check

```bash
# Check current vulnerability status
bash scripts/check-vulnerability-sla-compliance.sh

# View Dependabot dashboard
gh browse /security/dependabot
```

---

## Usage Examples

### Check SLA Compliance Status

```bash
# Run SLA compliance check
scripts/check-vulnerability-sla-compliance.sh
```

### Manual Vulnerability Review (Critical)

1. Receive alert: "🚨 CRITICAL Vulnerability - Manual review required"
2. Navigate to PR: `gh pr view <PR_NUMBER>`
3. Review changes: `gh pr diff <PR_NUMBER>`
4. Check CI status: `gh pr checks <PR_NUMBER>`
5. Merge (if safe): `gh pr merge <PR_NUMBER> --squash`

### Monthly Audit Report Generation

```bash
# Generate monthly audit report
bash scripts/monthly-vulnerability-sla-audit.sh

# View latest report
ls -lt compliance/sla/audit-reports/ | head -2
cat compliance/sla/audit-reports/vulnerability-sla-audit-*.json
```

---

## Related Documentation

- [Parent Compliance README](../README.md)
- [Dependency Management](../../docs/security/dependency-management.md)
- [SOC 2 Compliance](../soc2/README.md)
- NFR-1.2: Vulnerability Patch SLAs (feature specification)

---

**Last Updated:** 2026-02-24
**Owner:** Jorge (VP AI-SecOps)
**Compliance:** SOC 2, Internal Security Policy
