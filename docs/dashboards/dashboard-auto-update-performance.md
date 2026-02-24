# Dashboard Auto-Update Performance

## Overview
Seven Fortunas dashboards aggregate data from multiple sources on a scheduled cycle. Performance target: **<10 minutes per cycle**.

## Performance Targets

| Metric | Target | Warning Threshold |
|--------|--------|-------------------|
| **Aggregation Cycle Duration** | <10 minutes | 8 minutes (80%) |
| **API Call Timeout** | 30 seconds | N/A |
| **Failure Rate** | <5% | 3% |

## Optimization Strategies

### 1. Parallel API Calls
GitHub Actions jobs run aggregation steps in parallel:
- Progress dashboard
- Sprint dashboard
- Project dashboard

**Benefit:** 3x faster than sequential execution

### 2. API Call Optimization
- Use GraphQL for complex queries (fewer API calls)
- Batch requests when possible
- Implement exponential backoff for retries
- Cache intermediate results

### 3. Workflow Timeout
Hard timeout: **15 minutes** (50% buffer above target)
- Prevents runaway workflows
- Forces optimization of slow steps

### 4. Early Termination
Workflows continue on non-critical errors:
- Missing data: use cached value
- API rate limit: retry with backoff
- Partial aggregation better than total failure

## Performance Monitoring

### Workflow Duration Tracking
Every workflow run logs performance metrics:
- Duration (seconds and minutes)
- Performance status (pass/fail)
- Trigger (schedule/manual)

**Log Location:** `dashboards/performance/logs/workflow-TIMESTAMP.json`

### Performance Analysis
```bash
# Analyze recent workflow performance
./scripts/analyze-dashboard-performance.sh
```

**Metrics:**
- Average duration
- Min/max duration
- Compliance rate (% runs within target)
- Recent runs (last 10)

### GitHub Actions Logs
View workflow execution times:
```bash
# List recent workflow runs
gh run list --workflow=dashboard-auto-update.yml --limit 20

# View specific run
gh run view RUN_ID --log
```

## Performance Degradation Alerts

### Automatic Alerts
Workflow automatically creates GitHub issue if:
- Duration exceeds 10 minutes
- Failure rate exceeds 5%

**Issue Labels:** `performance`, `dashboard`, `P1`

### Alert Response
1. **Immediate:** Review workflow logs for bottlenecks
2. **Check:** GitHub API rate limits: `gh api rate_limit`
3. **Optimize:** Slow aggregation steps
4. **Consider:** Caching strategies or reducing data scope

## Troubleshooting

### Workflow Exceeding 10 Minutes

**Common Causes:**
1. **GitHub API rate limit:** Hitting secondary rate limits
2. **Large dataset:** Too much data to aggregate
3. **Slow API responses:** GitHub API latency
4. **Network issues:** Connectivity problems

**Solutions:**
1. **Rate limit:** Implement caching, reduce API call frequency
2. **Large dataset:** Paginate results, filter data
3. **Slow API:** Add timeouts, implement retries
4. **Network:** Add retry logic with exponential backoff

### Workflow Timeout (15 minutes)

**Action:**
1. Review workflow logs: `gh run view RUN_ID --log`
2. Identify bottleneck step
3. Optimize or split into multiple workflows
4. Consider increasing timeout (last resort)

### High Failure Rate

**Action:**
1. Check error patterns in logs
2. Improve error handling
3. Add retries for transient failures
4. Alert team if systemic issue

## Integration

### Dashboard Features (FR-4.1)
Auto-update performance integrates with:
- Progress Dashboard (FEATURE_015)
- Sprint Dashboard (FEATURE_016)
- Project Dashboard (FEATURE_017)

### Workflow Reliability (NFR-4.1)
Performance metrics feed into:
- Workflow reliability tracking (FEATURE_045)
- SOC 2 operational monitoring
- Team visibility via dashboards

## Optimization Tips

### Reduce API Calls
```bash
# Use GraphQL instead of REST for complex queries
# Example: Get multiple data points in single query
gh api graphql -f query='
{
  repository(owner: "Seven-Fortunas-Internal", name: "7f-infrastructure-project") {
    issues(states: OPEN, first: 100) {
      totalCount
      nodes {
        title
        labels(first: 10) { nodes { name } }
      }
    }
    pullRequests(states: OPEN, first: 100) {
      totalCount
    }
  }
}'
```

### Cache Intermediate Results
Store frequently accessed data:
- Repository metadata
- Team structure
- Label mappings

### Batch Processing
Process items in batches:
```bash
# Instead of: for each repo, fetch issues
# Do: fetch all repos, then all issues in batches
```

## Performance Benchmarks

**Target:** <10 minutes per cycle

**Typical Breakdown:**
- GitHub API calls: 2-3 minutes
- Data aggregation: 1-2 minutes
- Dashboard rendering: 1-2 minutes
- Git commit/push: 1 minute
- **Total:** 5-8 minutes (within target)

**Buffer:** 2-5 minutes for:
- API latency variance
- Network delays
- Occasional retries

## References

- [GitHub Actions Performance Best Practices](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub API Rate Limits](https://docs.github.com/en/rest/overview/resources-in-the-rest-api#rate-limiting)
- Seven Fortunas Progress Dashboard (FEATURE_015)
- Seven Fortunas Workflow Reliability (FEATURE_045/NFR-4.1)

---

**Last Updated:** 2026-02-17
**Owner:** Jorge (VP AI-SecOps)
**Target:** <10 minutes per cycle
