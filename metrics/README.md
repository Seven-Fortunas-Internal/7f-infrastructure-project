# System Metrics

This directory contains automated system metrics collected every 6 hours by the `collect-metrics` GitHub Actions workflow.

## Metrics Collected

- **Workflow Success Rate:** Percentage of successful workflow runs (last 100 runs)
- **API Rate Limit Usage:** GitHub API rate limit remaining vs total
- **Timestamp:** UTC timestamp of collection

## File Format

```json
{
  "timestamp": "2026-02-24T14:00:00Z",
  "workflow_success_rate": 98,
  "workflow_success_count": 98,
  "workflow_total_count": 100,
  "api_rate_limit_remaining": 4850,
  "api_rate_limit_limit": 5000,
  "api_rate_limit_percentage": 97
}
```

## Alert Thresholds

| Metric | Warning | Critical |
|--------|---------|----------|
| Workflow Success Rate | < 98% | < 95% |
| API Rate Limit | < 20% remaining | < 10% remaining |

## Retention Policy

- Metrics files retained for 90 days
- Automatic cleanup via scheduled workflow
- All metrics committed to git for backup

## Usage

View latest metrics:
```bash
ls -lt metrics/ | head -5
cat metrics/metrics-$(date +%Y-%m-%d)*.json | jq .
```

Analyze trends:
```bash
jq '.workflow_success_rate' metrics/*.json | sort -n
```

## See Also

- [System Metrics & Alerting Documentation](../docs/SYSTEM_METRICS_AND_ALERTING.md)
- [Collect Metrics Workflow](../.github/workflows/collect-metrics.yml)
