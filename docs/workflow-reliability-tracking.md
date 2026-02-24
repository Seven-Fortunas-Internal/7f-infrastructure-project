# Workflow Reliability Tracking (NFR-4.1)

**Version:** 1.0
**Status:** Implemented
**Requirement:** GitHub Actions workflows SHALL succeed 99% of the time (excluding confirmed external service outages)

---

## Overview

The Workflow Reliability Tracking system ensures that GitHub Actions workflows meet the 99% success rate target specified in NFR-4.1.

### Key Components

1. **Reliability Tracking Workflow** (`.github/workflows/track-workflow-reliability.yml`)
   - Automatically records all workflow run results
   - Classifies failures as internal or external
   - Generates monthly reliability reports
   - Creates alerts when reliability falls below target

2. **Reliability Checker** (`scripts/check_workflow_reliability.py`)
   - Calculates success rates over specified periods
   - Checks against 99% threshold
   - Provides per-workflow statistics
   - Alerts when below target

3. **Report Generator** (`scripts/generate_reliability_report.py`)
   - Generates monthly reliability reports
   - Analyzes failure patterns
   - Provides recommendations for improvement
   - Classifies failures by type (internal vs. external)

---

## How It Works

### 1. Automatic Result Recording

When any tracked workflow completes, the reliability workflow automatically:

1. Records workflow result (success/failure) to CSV file
2. Classifies failures as internal or external
3. Checks if reliability is below threshold
4. Commits metrics to repository

### 2. Failure Classification

**Internal Failures** (count against 99% target):
- Configuration errors
- Code bugs and syntax errors
- Test failures
- Rate limits (GitHub API, npm, etc.)
- Permission errors
- Missing dependencies

**External Failures** (excluded from 99% target):
- GitHub service outages (confirmed via GitHub Status Page)
- Third-party API outages (npm registry, PyPI, Docker Hub, etc.)
- Network connectivity issues
- Infrastructure outages

**Classification Process:**
1. Workflow fails
2. Logs are analyzed for failure patterns
3. Failure is classified based on error messages
4. Classification is recorded in CSV file
5. Jorge/Buck can manually reclassify if needed

### 3. Monthly Reporting

On the 1st of each month, the system:

1. Generates comprehensive reliability report
2. Calculates overall and per-workflow statistics
3. Identifies problematic workflows
4. Provides recommendations for improvement
5. Creates GitHub issue if below 99% target
6. Commits report to repository

---

## Metrics Tracked

### Workflow Results

File: `compliance/reliability/metrics/workflow-results.csv`

```csv
timestamp,workflow_name,workflow_id,status,conclusion,created_at,updated_at,run_url
2026-02-23T20:00:00Z,Update AI Dashboard,12345,completed,success,...
2026-02-23T20:15:00Z,Update Security Dashboard,12346,completed,success,...
2026-02-23T20:30:00Z,Deploy Skills,12347,completed,failure,...
```

**Fields:**
- `timestamp`: When result was recorded
- `workflow_name`: Name of workflow
- `workflow_id`: GitHub workflow run ID
- `status`: Workflow status (completed, in_progress, etc.)
- `conclusion`: Workflow conclusion (success, failure, cancelled, etc.)
- `created_at`: When workflow started
- `updated_at`: When workflow finished
- `run_url`: Link to workflow run

### Failure Classifications

File: `compliance/reliability/metrics/failure-classifications.csv`

```csv
timestamp,workflow_name,workflow_id,failure_type,failure_reason
2026-02-23T20:30:00Z,Deploy Skills,12347,internal,Configuration error: invalid YAML
2026-02-23T21:00:00Z,Update AI Dashboard,12348,external,GitHub API rate limit exceeded
```

**Fields:**
- `timestamp`: When failure was classified
- `workflow_name`: Name of failed workflow
- `workflow_id`: GitHub workflow run ID
- `failure_type`: `internal` or `external`
- `failure_reason`: Human-readable failure reason

---

## Usage

### Check Current Reliability

```bash
# Check last 30 days
python3 scripts/check_workflow_reliability.py

# Check last 7 days
python3 scripts/check_workflow_reliability.py --period 7

# Check with detailed per-workflow stats
python3 scripts/check_workflow_reliability.py --detailed

# Check against custom threshold (e.g., 95%)
python3 scripts/check_workflow_reliability.py --threshold 0.95
```

**Output:**
```
📊 Workflow Reliability Check (Last 30 Days)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total runs: 120
Successful runs: 119
Failed runs: 1
Success rate: 99.17%
Target: 99%
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Reliability MEETS target (NFR-4.1)
```

### Generate Monthly Report

```bash
# Generate report for current month
python3 scripts/generate_reliability_report.py \
  --output compliance/reliability/reports/reliability-report-$(date +%Y-%m).md

# Generate report for specific month
python3 scripts/generate_reliability_report.py \
  --output compliance/reliability/reports/reliability-report-2026-02.md \
  --month 2026-02

# Generate with custom threshold
python3 scripts/generate_reliability_report.py \
  --output report.md \
  --threshold 0.95
```

### Manual Trigger

```bash
# Trigger monthly report via GitHub Actions
gh workflow run track-workflow-reliability.yml \
  -f generate_report=true
```

---

## Reliability Targets

### NFR-4.1 Requirements

- **Success Rate:** >= 99%
- **Measurement Period:** Monthly
- **Exclusions:** Confirmed external service outages
- **Classification Authority:** Jorge/Buck
- **Reporting:** Monthly automated report
- **Alerting:** GitHub issue when below target

### Current Configuration

```yaml
# Tracked workflows
workflows:
  - "Update AI Advancements Dashboard"
  - "Update Security Intelligence Dashboard"
  - "Update FinTech Dashboard"
  - "Update EduTech Dashboard"
  - "Monitor Dashboard Performance"
  - "Deploy Skills"
  - "Validate Configuration"
  - "Run Tests"
  - "Build Documentation"

# Thresholds
success_rate_target: 0.99  # 99%
warning_threshold: 0.95     # 95%
critical_threshold: 0.90    # 90%

# Reporting
report_frequency: monthly
report_day: 1  # 1st of each month
alert_on_below_target: true
```

---

## Monthly Report Example

```markdown
# Monthly Workflow Reliability Report

**Month:** 2026-02
**Generated:** 2026-03-01 00:00:00 UTC
**Requirement:** NFR-4.1 - GitHub Actions workflows SHALL succeed 99% of the time

---

## Executive Summary

### ✅ Compliance Status: COMPLIANT

Workflow reliability meets the 99% success rate target.

## Overall Statistics

- **Total Runs:** 450
- **Successful Runs:** 447
- **Failed Runs:** 3
- **Overall Success Rate:** 99.33%

### Failure Classification

- **Internal Failures:** 1 (configuration errors, code bugs, rate limits)
- **External Failures:** 2 (confirmed external service outages)
- **Internal Success Rate:** 99.78% (excluding external outages)

**Target:** >= 99.0%
**Status:** ✅ MEETS target

---

## Per-Workflow Statistics

### ✅ Update AI Advancements Dashboard

- Total Runs: 120
- Successful: 120
- Failed: 0
- Success Rate: 100.00%

### ✅ Update Security Intelligence Dashboard

- Total Runs: 120
- Successful: 119
- Failed: 1
- Success Rate: 99.17%

[... additional workflows ...]

---

## Recommendations

Workflow reliability is meeting targets. Continue monitoring.

**Suggested Actions:**
- Monitor trends for early warning signs
- Review failure patterns monthly
- Document external outage classifications
```

---

## Troubleshooting

### Reliability Below Target

**Symptoms:**
- Monthly report shows < 99% success rate
- GitHub issue created with "NFR-4.1" label
- Reliability check fails

**Diagnosis:**
1. Run reliability checker: `python3 scripts/check_workflow_reliability.py --detailed`
2. Review per-workflow statistics
3. Analyze failure classifications
4. Check recent workflow runs: `gh run list --limit 50`

**Solutions:**

**For Internal Failures:**
1. **Configuration Errors:**
   - Review workflow YAML syntax
   - Validate environment variables
   - Check secrets configuration

2. **Code Bugs:**
   - Review recent code changes
   - Run tests locally
   - Fix failing tests

3. **Rate Limits:**
   - Implement rate limit handling
   - Add delays between API calls
   - Use caching where possible

4. **Permission Errors:**
   - Review GitHub Actions permissions
   - Check token scopes
   - Verify repository settings

**For External Failures:**
1. Verify outage via status pages:
   - [GitHub Status](https://www.githubstatus.com/)
   - [NPM Status](https://status.npmjs.org/)
   - [PyPI Status](https://status.python.org/)

2. Document outage classification
3. Update failure classification if misclassified
4. Consider fallback strategies

### Metrics Not Recording

**Symptoms:**
- Empty or outdated metrics files
- No monthly reports generated
- Reliability workflow not running

**Diagnosis:**
1. Check workflow run history:
   ```bash
   gh run list --workflow="Track Workflow Reliability"
   ```

2. Check for workflow errors:
   ```bash
   gh run view <run-id> --log
   ```

**Solutions:**
1. Ensure tracking workflow is enabled
2. Verify workflow triggers are correct
3. Check GitHub API token permissions
4. Verify metrics directory exists and is writable

### Manual Classification Needed

**Symptoms:**
- Failure classified as internal but should be external
- External outage not detected automatically
- Incorrect failure classification

**Process:**
1. Review failure details in GitHub Actions logs
2. Verify external outage via status pages
3. Update classification in CSV file:
   ```bash
   # Edit failure-classifications.csv
   # Change failure_type from 'internal' to 'external'
   ```
4. Document justification in commit message
5. Regenerate monthly report

---

## Integration

### With NFR-8.2: System Monitoring

Workflow reliability metrics feed into overall system monitoring:
- Reliability is a key health indicator
- Persistent low reliability triggers system-wide alerts
- Trends analyzed for capacity planning

### With Dashboard Performance (NFR-2.2)

Performance and reliability are correlated:
- Slow workflows may be less reliable
- Performance degradation often precedes failures
- Combined monitoring provides holistic view

---

## Maintenance

### Regular Tasks

**Weekly:**
- Review current reliability status
- Check for new failures
- Classify any unclassified failures

**Monthly:**
- Review and approve monthly report
- Investigate any reliability drops
- Update failure classifications if needed
- Implement fixes for internal failures

**Quarterly:**
- Analyze reliability trends
- Review and adjust thresholds if needed
- Update tracked workflows list
- Optimize problematic workflows

### Data Retention

- **Metrics CSV:** Rolling 10,000 entries (~6 months)
- **Monthly Reports:** Keep all (historical record)
- **GitHub Issues:** Close after resolution, keep for audit trail

---

## References

- **NFR-4.1:** Workflow Reliability
- **NFR-2.2:** Dashboard Auto-Update Performance
- **NFR-8.2:** System Monitoring
- **FR-7.5:** GitHub Actions Workflows

---

## Change Log

| Date | Version | Changes |
|------|---------|---------|
| 2026-02-24 | 1.0 | Initial implementation |

---

**Owner:** Jorge (VP AI-SecOps)
**Maintained by:** Autonomous Implementation Agent
