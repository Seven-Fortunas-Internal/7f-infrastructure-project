# Workflow Reliability

## Overview
Seven Fortunas maintains 99% success rate for GitHub Actions workflows (excluding external outages).

## Reliability Target

**Success Rate:** ≥99%
**Measurement:** Monthly
**Exclusions:** Confirmed external service outages

## Failure Classification

### Internal Failures (counted against target)
- Configuration errors
- Code bugs
- API rate limits exceeded
- Insufficient permissions
- Logic timeout/errors

### External Failures (excluded from target)
- GitHub platform outages
- Third-party API outages
- Network connectivity issues

**External Outage Sources:**
- https://www.githubstatus.com/
- Third-party API status pages
- Network provider status

**Classification Owner:** Jorge (VP AI-SecOps) or Buck (Co-Founder)

## Monthly Reporting

```bash
# Generate monthly reliability report
./scripts/monthly-workflow-reliability-report.sh
```

**Report Location:** `compliance/workflow-reliability/reports/workflow-reliability-TIMESTAMP.json`

**Report Contents:**
- Total workflow runs
- Success/failure counts
- Success rate percentage
- Compliance status
- Recommendations

## Integration

### GitHub Actions Workflows (FR-7.5)
All workflows tracked:
- Dashboard auto-update
- Dependabot auto-merge
- Secret detection
- Custom workflows

### System Monitoring (NFR-8.2)
Reliability metrics feed into:
- Operational dashboards
- SOC 2 compliance tracking
- Team visibility

## Troubleshooting

### Below 99% Success Rate
1. Run monthly report: `./scripts/monthly-workflow-reliability-report.sh`
2. Review failed workflow runs: `gh run list --status failure --limit 50`
3. Classify failures (internal vs external)
4. Fix internal failures
5. Document external outages

## References

- GitHub Actions Workflows (FEATURE_028/FR-7.5)
- GitHub Status Page: https://www.githubstatus.com/

---

**Last Updated:** 2026-02-17
**Owner:** Jorge (VP AI-SecOps)
**Target:** 99% success rate
