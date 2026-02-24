# Dashboard Performance Monitoring (NFR-2.2)

**Version:** 1.0
**Status:** Implemented
**Target:** Dashboard aggregation SHALL complete in less than 10 minutes per cycle

---

## Overview

The Dashboard Performance Monitoring system ensures that all dashboard aggregation workflows meet the 10-minute performance target specified in NFR-2.2.

### Key Components

1. **Performance Monitoring Workflow** (`.github/workflows/monitor-dashboard-performance.yml`)
   - Automatically tracks dashboard workflow durations
   - Logs performance metrics to CSV file
   - Creates GitHub issues when performance target is exceeded

2. **Performance Optimizer** (`scripts/optimize_dashboard_performance.py`)
   - Optimizes dashboard workflows with parallel API calls
   - Uses asyncio for concurrent execution
   - Supports up to 15 concurrent requests

3. **Performance Analyzer** (`scripts/analyze_dashboard_performance.py`)
   - Analyzes historical performance metrics
   - Generates compliance reports
   - Provides optimization recommendations

4. **Performance Configuration** (`dashboards/performance/performance-config.yaml`)
   - Central configuration for performance targets
   - Dashboard-specific optimization settings
   - Alert and monitoring configuration

---

## How It Works

### 1. Automatic Performance Tracking

When any dashboard update workflow completes, the monitoring workflow automatically:

1. Fetches workflow execution details via GitHub API
2. Calculates workflow duration (created_at → updated_at)
3. Logs metrics to `dashboards/performance/metrics/dashboard-performance.csv`
4. Checks if duration exceeds 10-minute target
5. Creates/updates GitHub issue if target exceeded
6. Commits metrics file to repository

### 2. Performance Metrics

Metrics tracked for each workflow run:

```csv
timestamp,workflow_name,workflow_id,duration_minutes,conclusion
2026-02-23T20:00:00Z,Update AI Advancements Dashboard,12345,7.5,success
2026-02-23T20:00:00Z,Update Security Intelligence Dashboard,12346,9.2,success
```

### 3. Performance Alerts

When a workflow exceeds the 10-minute target:

- **GitHub Issue Created** with label `performance,dashboard,P1`
- Issue includes:
  - Workflow name and run ID
  - Actual duration vs. target
  - Link to workflow run
  - Recommended actions

If multiple violations occur, the existing issue is updated rather than creating duplicates.

---

## Usage

### Analyze Performance Metrics

```bash
# Generate performance report
python3 scripts/analyze_dashboard_performance.py

# Save report to file
python3 scripts/analyze_dashboard_performance.py \
  --output dashboards/performance/reports/performance-report-$(date +%Y-%m-%d).md

# Check compliance (exit 1 if not compliant)
python3 scripts/analyze_dashboard_performance.py --check-compliance
```

### Optimize Dashboard Workflow

```bash
# Test optimization with a dashboard config
python3 scripts/optimize_dashboard_performance.py \
  --config dashboards/ai/sources.yaml \
  --concurrent 12 \
  --output dashboards/performance/reports/ai-optimization-$(date +%Y-%m-%d).json

# Test with security dashboard
python3 scripts/optimize_dashboard_performance.py \
  --config dashboards/security/sources.yaml \
  --concurrent 12
```

### Manual Performance Check

```bash
# Get recent workflow runs
gh run list --workflow="Update AI Advancements Dashboard" --limit 10

# Get specific run details
gh run view <run-id>

# Get run duration
gh run view <run-id> --json createdAt,updatedAt
```

---

## Performance Targets

### NFR-2.2 Requirements

- **Target Duration:** < 10 minutes per cycle
- **Measurement:** GitHub Actions workflow execution logs
- **Scope:** Dashboard aggregation workflows only
- **Compliance:** >= 80% of runs must meet target

### Current Configuration

```yaml
performance_targets:
  aggregation_cycle_max_duration_minutes: 10
  warning_threshold_minutes: 8  # Alert at 80% of target
  max_concurrent_requests: 15   # Parallel optimization

dashboards:
  ai:
    max_concurrent_requests: 12
  security:
    max_concurrent_requests: 12
  fintech:
    max_concurrent_requests: 10
  edutech:
    max_concurrent_requests: 10
```

---

## Optimization Strategies

### 1. Parallel API Calls

**Implementation:** `scripts/optimize_dashboard_performance.py`

Uses Python asyncio to make concurrent API requests:
- Default: 15 concurrent requests
- Customizable per dashboard
- Semaphore-based rate limiting
- Automatic retry with exponential backoff

**Expected Improvement:** 3-5x faster than sequential execution

### 2. Connection Pooling

**Implementation:** `aiohttp.ClientSession` in optimizer

Reuses HTTP connections across requests:
- Reduces TCP handshake overhead
- Maintains connection pool (up to 20 connections)
- Automatic cleanup on completion

**Expected Improvement:** 10-20% reduction in latency

### 3. Request Batching

**Configuration:** `performance-config.yaml`

Groups similar API requests together:
- Batch size: 10 requests
- Reduces API rate limit issues
- Improves throughput

### 4. Response Caching

**Configuration:** `performance-config.yaml`

Caches API responses to avoid redundant calls:
- Cache TTL: 30 minutes
- Per-source cache invalidation
- Memory-based cache (no persistence)

**Expected Improvement:** 20-40% reduction for repeated queries

### 5. Incremental Updates

**Configuration:** `performance-config.yaml`

Only fetches data that changed since last update:
- Timestamp-based filtering
- Reduces data transfer
- Lowers API call count

**Expected Improvement:** 30-50% reduction for stable sources

---

## Monitoring Dashboard

### Metrics Collected

1. **Workflow Duration** - Total time from start to completion
2. **API Call Count** - Number of API requests made
3. **API Call Latency** - P50 and P95 latency percentiles
4. **Failure Rate** - Percentage of failed API calls
5. **Success Rate** - Percentage of successful workflow runs
6. **Cache Hit Rate** - Percentage of requests served from cache

### Performance Trends

View historical performance trends:

```bash
# Last 30 days of metrics
tail -n 1000 dashboards/performance/metrics/dashboard-performance.csv

# Average duration per workflow
awk -F',' 'NR>4 {sum[$2]+=$4; count[$2]++} END {
  for (workflow in sum) {
    print workflow ": " sum[workflow]/count[workflow] " minutes"
  }
}' dashboards/performance/metrics/dashboard-performance.csv
```

---

## Troubleshooting

### Performance Exceeds 10 Minutes

**Symptoms:**
- GitHub issue created with "Performance Alert" label
- Workflow duration > 10 minutes in logs
- Low compliance rate in analytics

**Diagnosis:**
1. Run performance analyzer: `python3 scripts/analyze_dashboard_performance.py`
2. Check which workflows are slow
3. Review API call patterns
4. Check for network issues or API rate limits

**Solutions:**
1. **Increase concurrent requests:**
   ```yaml
   # In performance-config.yaml
   dashboards:
     ai:
       max_concurrent_requests: 15  # Increase from 12
   ```

2. **Enable caching:**
   ```yaml
   optimization_strategies:
     response_caching: true
   ```

3. **Reduce API timeouts:**
   ```yaml
   performance_targets:
     api_call_timeout_seconds: 20  # Reduce from 30
   ```

4. **Split large dashboards:**
   - Divide dashboard into smaller units
   - Run updates in parallel workflows
   - Aggregate results at the end

### Metrics Not Collecting

**Symptoms:**
- Empty or outdated metrics file
- No GitHub issues created for violations
- Monitoring workflow not running

**Diagnosis:**
1. Check workflow run history:
   ```bash
   gh run list --workflow="Monitor Dashboard Performance"
   ```

2. Check for workflow errors:
   ```bash
   gh run view <run-id> --log
   ```

**Solutions:**
1. Ensure monitoring workflow is enabled
2. Verify GitHub API token has correct permissions
3. Check that dashboard workflows are running
4. Verify metrics directory exists and is writable

### False Performance Alerts

**Symptoms:**
- Alerts created when performance is actually good
- Inconsistent duration measurements
- Alerts for workflows that don't exist

**Diagnosis:**
1. Check metrics file for data integrity
2. Verify workflow names in configuration
3. Review GitHub Actions run logs

**Solutions:**
1. Update workflow names in `performance-config.yaml`
2. Clean up invalid metrics entries
3. Adjust alert threshold if needed

---

## Integration with Other Systems

### NFR-4.1: Workflow Reliability

Performance metrics feed into workflow reliability tracking:
- Duration is a reliability indicator
- Persistent slow performance triggers investigations
- Compliance rate affects overall reliability score

### Dashboard Health Checks

Performance monitoring integrates with dashboard health checks:
- `scripts/check_dashboard_health.py` uses performance data
- Health status considers both correctness and performance
- Degraded performance affects health score

---

## Maintenance

### Regular Tasks

**Weekly:**
- Review performance reports
- Check compliance rates
- Investigate any alerts

**Monthly:**
- Analyze performance trends
- Optimize slow workflows
- Update configuration based on patterns

**Quarterly:**
- Review and adjust performance targets
- Evaluate optimization strategies
- Update monitoring workflows

### Metrics Retention

- **CSV file:** Rolling 1000 entries (auto-trimmed)
- **Reports:** Keep last 90 days
- **GitHub issues:** Close resolved performance issues after 30 days

---

## References

- **NFR-2.2:** Dashboard Auto-Update Performance
- **NFR-4.1:** Workflow Reliability
- **FR-4.1:** AI Advancements Dashboard (MVP)
- **FR-7.5:** GitHub Actions Workflows

---

## Change Log

| Date | Version | Changes |
|------|---------|---------|
| 2026-02-23 | 1.0 | Initial implementation |

---

**Owner:** Jorge (VP AI-SecOps)
**Maintained by:** Autonomous Implementation Agent
