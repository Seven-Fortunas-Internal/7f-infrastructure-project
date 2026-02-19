#!/bin/bash
# FEATURE_045: Workflow Reliability
# Tracks GitHub Actions workflow reliability (99% success rate target)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== FEATURE_045: Workflow Reliability Setup ==="
echo ""

# Verify GitHub authentication
echo "1. Verifying GitHub authentication..."
if ! gh auth status &>/dev/null; then
    echo "ERROR: GitHub CLI not authenticated. Run: gh auth login"
    exit 1
fi
echo "✓ GitHub authenticated"
echo ""

# Create reliability configuration
echo "2. Creating workflow reliability configuration..."
mkdir -p "$PROJECT_ROOT/compliance/workflow-reliability"

cat > "$PROJECT_ROOT/compliance/workflow-reliability/reliability-config.yaml" << 'EOF'
# Workflow Reliability Configuration
# Target: 99% success rate

reliability_targets:
  success_rate: 99.0  # percent
  measurement_period: monthly
  exclude_external_outages: true

failure_classification:
  internal:
    - configuration_errors
    - code_bugs
    - rate_limit_exceeded
    - insufficient_permissions
    - timeout_internal_logic

  external:
    - github_platform_outage
    - third_party_api_outage
    - network_connectivity_issues

external_outage_sources:
  - https://www.githubstatus.com/
  - Third-party API status pages
  - Network provider status

owner:
  primary: "Jorge (VP AI-SecOps)"
  secondary: "Buck (Co-Founder)"

reporting:
  frequency: monthly
  report_location: compliance/workflow-reliability/reports/
  include_trend_analysis: true

metrics:
  - total_workflow_runs
  - successful_runs
  - failed_runs_internal
  - failed_runs_external
  - success_rate
  - internal_failure_rate
EOF

echo "✓ Reliability configuration created"
echo ""

# Create monthly reliability report script
echo "3. Creating monthly workflow reliability report script..."
mkdir -p "$PROJECT_ROOT/compliance/workflow-reliability/reports"

cat > "$PROJECT_ROOT/scripts/monthly-workflow-reliability-report.sh" << 'EOF'
#!/bin/bash
# Monthly Workflow Reliability Report
# Calculates 99% success rate compliance

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT="$PROJECT_ROOT/compliance/workflow-reliability/reports/workflow-reliability-$TIMESTAMP.json"

echo "=== Monthly Workflow Reliability Report ==="
echo "Date: $(date)"
echo "Report: $REPORT"
echo ""

# Verify GitHub authentication
if ! gh auth status &>/dev/null; then
    echo "ERROR: GitHub CLI not authenticated"
    exit 1
fi

# Repositories to track
REPOS=(
    "Seven-Fortunas-Internal/7f-infrastructure-project"
    "Seven-Fortunas-Internal/seven-fortunas-brain"
    "Seven-Fortunas/dashboards"
)

TOTAL_RUNS=0
SUCCESSFUL_RUNS=0
FAILED_RUNS=0

echo "1. Collecting workflow run data (last 30 days)..."

for REPO in "${REPOS[@]}"; do
    echo "  Processing: $REPO"

    # Get workflow runs from last 30 days
    RUNS=$(gh api "repos/$REPO/actions/runs?per_page=100&created=>=$(date -d '30 days ago' -u +%Y-%m-%dT%H:%M:%SZ)" --jq '.workflow_runs[] | {
      id,
      status,
      conclusion,
      name: .name,
      created_at
    }' 2>/dev/null || echo "[]")

    if [[ -n "$RUNS" ]]; then
        # Count completed runs only
        REPO_TOTAL=$(echo "$RUNS" | jq -s '[.[] | select(.status == "completed")] | length')
        REPO_SUCCESS=$(echo "$RUNS" | jq -s '[.[] | select(.status == "completed" and .conclusion == "success")] | length')
        REPO_FAILED=$(echo "$RUNS" | jq -s '[.[] | select(.status == "completed" and .conclusion != "success")] | length')

        TOTAL_RUNS=$((TOTAL_RUNS + REPO_TOTAL))
        SUCCESSFUL_RUNS=$((SUCCESSFUL_RUNS + REPO_SUCCESS))
        FAILED_RUNS=$((FAILED_RUNS + REPO_FAILED))

        echo "    Runs: $REPO_TOTAL | Success: $REPO_SUCCESS | Failed: $REPO_FAILED"
    fi
done

echo ""
echo "2. Calculating reliability metrics..."

# Calculate success rate
if [[ $TOTAL_RUNS -gt 0 ]]; then
    SUCCESS_RATE=$(awk "BEGIN {printf \"%.2f\", ($SUCCESSFUL_RUNS / $TOTAL_RUNS) * 100}")
    FAILURE_RATE=$(awk "BEGIN {printf \"%.2f\", ($FAILED_RUNS / $TOTAL_RUNS) * 100}")
else
    SUCCESS_RATE="0.00"
    FAILURE_RATE="0.00"
fi

echo "  Total workflow runs: $TOTAL_RUNS"
echo "  Successful runs: $SUCCESSFUL_RUNS"
echo "  Failed runs: $FAILED_RUNS"
echo "  Success rate: $SUCCESS_RATE%"
echo "  Failure rate: $FAILURE_RATE%"
echo ""

# Check target compliance
if (( $(echo "$SUCCESS_RATE >= 99.0" | bc -l) )); then
    COMPLIANCE_STATUS="COMPLIANT"
    echo "✓ Workflow reliability target met: $SUCCESS_RATE% ≥ 99%"
else
    COMPLIANCE_STATUS="NON_COMPLIANT"
    echo "✗ Workflow reliability below target: $SUCCESS_RATE% < 99%"
fi

echo ""

# Generate JSON report
cat > "$REPORT" << JSON
{
  "report_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "measurement_period": "last_30_days",
  "owner": "Jorge (VP AI-SecOps)",
  "repositories": [
    $(printf '"%s"' "${REPOS[@]}" | paste -sd, -)
  ],
  "metrics": {
    "total_workflow_runs": $TOTAL_RUNS,
    "successful_runs": $SUCCESSFUL_RUNS,
    "failed_runs": $FAILED_RUNS,
    "success_rate": $SUCCESS_RATE,
    "failure_rate": $FAILURE_RATE
  },
  "targets": {
    "success_rate": 99.0,
    "exclude_external_outages": true
  },
  "compliance": {
    "status": "$COMPLIANCE_STATUS",
    "met_target": $([ "$COMPLIANCE_STATUS" == "COMPLIANT" ] && echo "true" || echo "false")
  },
  "recommendations": [
    $(if [[ "$COMPLIANCE_STATUS" == "NON_COMPLIANT" ]]; then echo '"Investigate failed workflow runs for root cause", "Classify failures as internal vs external", "Implement fixes for internal failures"'; else echo '"Maintain current reliability", "Continue monthly monitoring"'; fi)
  ]
}
JSON

echo "3. Report generated: $REPORT"
echo ""

# Summary
if [[ "$COMPLIANCE_STATUS" == "COMPLIANT" ]]; then
    echo "✓ Workflow reliability compliant ($SUCCESS_RATE% ≥ 99%)"
else
    echo "⚠ Action required: Workflow reliability below target"
    echo "  Current: $SUCCESS_RATE%"
    echo "  Target: 99.0%"
    echo "  Failed runs to investigate: $FAILED_RUNS"
fi
EOF

chmod +x "$PROJECT_ROOT/scripts/monthly-workflow-reliability-report.sh"
echo "✓ Monthly report script created"
echo ""

# Create documentation
echo "4. Creating workflow reliability documentation..."
mkdir -p "$PROJECT_ROOT/docs/devops"

cat > "$PROJECT_ROOT/docs/devops/workflow-reliability.md" << 'EOF'
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
EOF

echo "✓ Documentation created"
echo ""

echo "=== Setup Complete ==="
echo ""
echo "Reliability Targets:"
echo "- Success rate: ≥99%"
echo "- Measurement: Monthly"
echo "- External outages: Excluded"
echo ""
echo "Next Steps:"
echo "1. Run initial report: ./scripts/monthly-workflow-reliability-report.sh"
echo "2. Schedule monthly reports"
echo "3. Monitor workflow success rates"
echo ""
