# SOC 2 Control Tracking System

**Version:** 1.0
**Last Updated:** 2024-02-24
**Requirement:** NFR-1.5 - SOC 2 Control Tracking (Phase 1.5)

## Overview

Real-time monitoring system for SOC 2 Trust Service Criteria compliance across GitHub organizations.

## Features

### 1. Real-Time Control Monitoring

- **Frequency:** Every 15 minutes (automated via GitHub Actions)
- **Coverage:** 6 key SOC 2 controls mapped to GitHub settings
- **Alert Threshold:** Any control drift triggers immediate alert

### 2. Automated Evidence Collection

- **Format:** JSON reports with timestamp, control status, expected vs actual values
- **Storage:** `compliance/soc2/reports/` (versioned by timestamp)
- **Latest Report:** Symlinked to `reports/latest.json`

### 3. Control Drift Alerts

- **Trigger:** Any control fails compliance check
- **Notification:** GitHub Issue created with details
- **SLA:** Alert within 15 minutes of drift (meets NFR-1.5 target)

### 4. Compliance Dashboard

- **Location:** `compliance/soc2/control-status-dashboard.md`
- **Content:** Current compliance %, control details, historical reports
- **Updates:** Automatically updated every 15 minutes

## Monitored Controls

| Control ID | Control Name | TSC Mapping | GitHub Setting |
|------------|--------------|-------------|----------------|
| GH-ACCESS-001 | Two-Factor Authentication | CC6.1.1 | `two_factor_requirement_enabled` |
| GH-ACCESS-002 | Default Repository Permission | CC6.1.2 | `default_repository_permission` |
| GH-ACCESS-003 | Public Repository Creation | CC6.6.1 | `members_can_create_public_repositories` |
| GH-SEC-001 | Branch Protection | CC7.2.1 | Branch protection rules |
| GH-SEC-002 | Secret Scanning | CC8.1.1 | `advanced_security_enabled_for_new_repositories` |
| GH-SEC-003 | Dependabot Alerts | CC8.1.2 | `dependabot_alerts_enabled_for_new_repositories` |

## Usage

### Manual Check

Run the control posture check manually:

```bash
./compliance/soc2/check-control-posture.sh Seven-Fortunas-Internal
```

**Output:**
- Console report with color-coded pass/fail indicators
- JSON report in `compliance/soc2/reports/`
- Exit code 0 (all pass) or 1 (drift detected)

### View Current Status

Check the latest compliance status:

```bash
# View JSON report
cat compliance/soc2/reports/latest.json | jq '.'

# View dashboard
cat compliance/soc2/control-status-dashboard.md

# Get compliance percentage
cat compliance/soc2/reports/latest.json | jq '.summary.compliance_percentage'
```

### Historical Analysis

Review historical compliance trends:

```bash
# List all reports
ls -lt compliance/soc2/reports/*.json | head -10

# Compare two reports
diff \
  <(jq '.controls | sort_by(.control_id)' compliance/soc2/reports/2024-02-24T10:00:00Z.json) \
  <(jq '.controls | sort_by(.control_id)' compliance/soc2/reports/latest.json)
```

### Automated Monitoring

GitHub Actions workflow runs automatically:

- **Schedule:** Every 15 minutes (`*/15 * * * *`)
- **Workflow:** `.github/workflows/soc2-control-monitoring.yml`
- **Actions:**
  1. Run control check
  2. Commit report to repository
  3. Create alert issue if drift detected
  4. Update compliance dashboard

**Trigger manual run:**

```bash
gh workflow run soc2-control-monitoring.yml --repo Seven-Fortunas-Internal/7f-infrastructure-project
```

## Control Drift Response

When control drift is detected:

1. **Alert Issue Created**
   - Title: "🚨 SOC 2 Control Drift Detected - XX% Compliant"
   - Labels: `security`, `soc2`, `control-drift`
   - Details: Failed controls with expected vs actual values

2. **Investigate Drift**
   ```bash
   # View failed controls
   cat compliance/soc2/reports/latest.json | jq '.controls[] | select(.status == "fail")'
   ```

3. **Remediate**
   - Review GitHub organization settings
   - Correct any deviations from required state
   - Re-run check to verify compliance

4. **Document**
   - Update control mapping if expected values changed
   - Note any exceptions in evidence collection

## Integration with CISO Assistant

The control posture reports are designed to integrate with CISO Assistant:

- **Evidence Format:** JSON with timestamp, control ID, status, values
- **Upload Frequency:** Daily (can be increased to hourly if needed)
- **API Integration:** Use CISO Assistant API to push evidence automatically

**Example integration:**

```bash
# Push latest report to CISO Assistant
curl -X POST https://ciso-assistant.seven-fortunas.com/api/evidence \
  -H "Authorization: Bearer $CISO_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d @compliance/soc2/reports/latest.json
```

## Compliance Verification

### NFR-1.5 Requirements

✅ **Real-time tracking:** Automated checks every 15 minutes
✅ **Control drift alerts:** GitHub Issues created within 15 minutes
✅ **CISO Assistant integration:** JSON format compatible with evidence upload
✅ **Automated evidence collection:** Reports stored with timestamps

### Verification Commands

```bash
# 1. Verify script exists and is executable
test -x compliance/soc2/check-control-posture.sh && echo "PASS: Script executable"

# 2. Run manual check
./compliance/soc2/check-control-posture.sh Seven-Fortunas-Internal

# 3. Verify workflow exists
test -f .github/workflows/soc2-control-monitoring.yml && echo "PASS: Workflow exists"

# 4. Verify monitoring frequency (15 minutes)
grep "cron: '\*/15" .github/workflows/soc2-control-monitoring.yml && echo "PASS: 15-min schedule"

# 5. Verify alert creation on drift
grep "Create Control Drift Alert" .github/workflows/soc2-control-monitoring.yml && echo "PASS: Alert step exists"
```

## Adding New Controls

To add a new SOC 2 control to monitoring:

1. **Update control mapping:**
   - Add control to `github-control-mapping.md`
   - Document TSC mapping, GitHub setting, evidence source

2. **Add check to script:**
   ```bash
   # In check-control-posture.sh
   check_control \
       "GH-XXX-XXX" \
       "Control Name" \
       "gh api /orgs/\$ORG --jq '.setting_name'" \
       "expected_value"
   ```

3. **Test:**
   ```bash
   ./compliance/soc2/check-control-posture.sh Seven-Fortunas-Internal
   ```

4. **Commit:**
   ```bash
   git add compliance/soc2/
   git commit -m "feat: Add SOC 2 control GH-XXX-XXX monitoring"
   ```

## Troubleshooting

### Check fails with "gh: command not found"

Ensure GitHub CLI is installed and authenticated:

```bash
gh --version
gh auth status
```

### Reports directory not created

Script creates it automatically, but you can create manually:

```bash
mkdir -p compliance/soc2/reports
```

### Workflow not running

Check workflow status:

```bash
gh workflow view soc2-control-monitoring.yml --repo Seven-Fortunas-Internal/7f-infrastructure-project
gh run list --workflow=soc2-control-monitoring.yml --limit 5
```

### False alerts

Review control mapping to ensure expected values are correct:

```bash
cat compliance/soc2/github-control-mapping.md
```

## References

- **Requirement:** NFR-1.5 (SOC 2 Control Tracking)
- **Related Features:** FEATURE_022 (SOC 2 Preparation)
- **Control Mapping:** `github-control-mapping.md`
- **Workflow:** `.github/workflows/soc2-control-monitoring.yml`
- **Script:** `check-control-posture.sh`

---

**Owner:** Jorge (VP AI-SecOps)
**Maintained by:** SOC 2 Control Bot (automated)
