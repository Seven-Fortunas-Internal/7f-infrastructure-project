# Team Growth Scalability (NFR-3.1)

**Version:** 1.0
**Last Updated:** 2024-02-24
**Requirement:** NFR-3.1 - Team Growth Scalability

## Requirement

System SHALL scale from 4 to 50 users with less than 10% performance degradation.

**Target:** Less than 10% slowdown from baseline
**Measurement:** Response times, workflow durations at different team sizes

## Current State (4 Users)

### Team Composition
- Jorge (VP AI-SecOps)
- 3 AI agents (Mary, Dev agents)
- Total: ~4 active users

### Baseline Performance Metrics

#### 1. GitHub Web UI Response Times
- **Dashboard Load:** ~1.2s
- **Repository View:** ~0.8s
- **Issues Page:** ~1.0s
- **Pull Requests:** ~0.9s

#### 2. Claude Code Skills
- **Search Second Brain:** ~2-5s
- **Dashboard Configurator:** ~3-8s
- **BMAD Workflow Execution:** ~10-30s (varies by workflow)

#### 3. GitHub Actions Workflows
- **SOC 2 Control Monitoring:** ~15-30s
- **Dashboard Auto-Update:** ~2-5 min
- **Test Workflows:** ~30s-2min

#### 4. API Rate Limits (Current Usage)
- **GitHub API:** ~100-200 requests/hour (limit: 5,000/hour)
- **Claude API:** ~10-20 requests/hour (no hard limit with current tier)
- **Anthropic:** Varies by model usage

## Scalability Analysis

### 1. GitHub Organization Capacity

✅ **GitHub Team Plan** supports:
- Unlimited users
- Unlimited public/private repositories
- 3,000 Actions minutes/month
- Advanced security features

**Scalability Assessment:** No technical limitation for 50 users

### 2. API Rate Limits

#### GitHub API (Per User)
- **Authenticated:** 5,000 requests/hour/user
- **Search:** 30 requests/minute (org-wide)
- **GraphQL:** 5,000 points/hour

**Current Usage:** 100-200 req/hour with 4 users = 25-50 req/hour/user
**Projected at 50 users:** 1,250-2,500 req/hour (well within limits)

**Scalability Assessment:** 5x safety margin at 50 users ✅

#### Claude API
- **Rate limits:** Model-dependent
- **Current usage:** Low (~10-20 req/hour)
- **Projected at 50 users:** ~125-250 req/hour (Claude primarily used by AI agents, not all human users)

**Scalability Assessment:** Adequate for projected growth ✅

### 3. GitHub Actions Compute

**Current allocation:** 3,000 minutes/month (Team plan)
**Current usage:** ~500-1,000 minutes/month
**Projected at 50 users:** ~2,500-5,000 minutes/month

**Risk:** May exceed free tier at scale
**Mitigation:** Upgrade to Enterprise or optimize workflow efficiency

**Scalability Assessment:** Requires monitoring and potential upgrade ⚠️

### 4. Storage & Data Growth

**GitHub Storage:**
- Unlimited repository storage (Team plan)
- Large File Storage (LFS): 50 GB included, $5/50GB after

**Current usage:** ~500 MB across all repos
**Projected at 50 users:** ~2-5 GB (assuming linear growth)

**Scalability Assessment:** No concerns ✅

### 5. Second Brain Search Performance

**Current performance:** 2-5s for keyword search
**Data size:** ~100 documents, ~2 MB markdown
**Projected at 50 users:** ~500-1,000 documents, ~10-20 MB

**Search method:** `grep -r` (linear time complexity)
**Projected degradation:** 5x data = ~10-25s search time (5-10x slower)

**Risk:** Exceeds 10% degradation threshold
**Mitigation:** Implement indexed search (ripgrep, FTS database)

**Scalability Assessment:** Requires optimization ⚠️

### 6. Dashboard Performance

**Current rendering:** Client-side (React)
**Data source:** GitHub API (cached)
**Current load time:** ~2-3s (Lighthouse score: 85+)

**Projected at 50 users:**
- More repositories to display
- More team members in visualizations
- Increased API calls for aggregations

**Estimated degradation:** ~5-8% (caching mitigates most growth)

**Scalability Assessment:** Acceptable within 10% threshold ✅

## Scalability Strategy

### Immediate (Phase 1)

1. **Establish Performance Baselines**
   - Measure all critical paths with current team
   - Document in this file
   - Set up automated performance monitoring

2. **Remove Hard-Coded Limits**
   - Audit scripts for user/team count assumptions
   - Use dynamic team member queries
   - Avoid pagination limits (fetch all pages)

3. **Optimize High-Impact Areas**
   - Second Brain search: Switch to ripgrep with indexing
   - Dashboard: Implement aggressive caching
   - Workflows: Optimize for parallel execution

### Near-Term (Phase 1.5)

4. **Monitor GitHub Actions Usage**
   - Track monthly compute minutes
   - Alert at 80% threshold
   - Plan for Enterprise upgrade if needed

5. **API Rate Limit Monitoring**
   - Add rate limit tracking to workflows
   - Alert at 70% utilization
   - Implement exponential backoff

6. **Load Testing**
   - Simulate 10, 20, 50 user scenarios
   - Measure response times under load
   - Identify bottlenecks

### Long-Term (Phase 2+)

7. **Search Infrastructure**
   - Replace grep with Algolia, Meilisearch, or similar
   - Full-text indexed search
   - Sub-second response times regardless of data size

8. **Caching Layer**
   - Redis or similar for GitHub API responses
   - Cache invalidation on webhook events
   - Reduce API calls by 70-80%

9. **Horizontal Scaling**
   - Stateless architecture (already achieved)
   - CDN for static assets (GitHub Pages supports this)
   - Distributed workflow execution

## Verification Criteria

### Functional
- [ ] System supports adding 10+ users without errors
- [ ] All features work identically for new users
- [ ] No hard-coded user limits in codebase

### Technical
- [ ] Performance baselines documented
- [ ] API usage < 50% of limits at 50 users (projected)
- [ ] Search performance degradation < 10% with 5x data

### Integration
- [ ] GitHub organization configured for unlimited users
- [ ] Monitoring in place for rate limits and compute
- [ ] Scalability strategy documented and approved

## Performance Monitoring

### Automated Checks (GitHub Actions)

```yaml
name: Performance Baseline
on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly
  workflow_dispatch:

jobs:
  measure-performance:
    runs-on: ubuntu-latest
    steps:
      - name: Measure GitHub UI Response
        run: |
          curl -w "time_total:%{time_total}\n" -o /dev/null -s \
            https://github.com/Seven-Fortunas-Internal

      - name: Measure Dashboard Load Time
        run: |
          npx lighthouse https://seven-fortunas.github.io/dashboards \
            --output json --chrome-flags="--headless" \
            | jq '.categories.performance.score'

      - name: Test Second Brain Search
        run: |
          time ./scripts/search-second-brain.sh "BMAD"

      - name: Check API Rate Limit Usage
        run: |
          gh api /rate_limit | jq '.resources.core |
            {limit, used, remaining, reset}'
```

### Manual Testing Checklist

- [ ] Add 5 new team members (test environment)
- [ ] Measure dashboard load time (before/after)
- [ ] Measure search performance (before/after)
- [ ] Check GitHub Actions workflow duration (before/after)
- [ ] Verify < 10% degradation across all metrics

## Known Limitations

1. **Second Brain Search:** Linear time complexity, will slow with data growth
   - **Impact:** High for 50 users
   - **Priority:** P1 (must fix before Phase 2)

2. **GitHub Actions Compute:** Fixed monthly allocation
   - **Impact:** Medium (can upgrade)
   - **Priority:** P2 (monitor and upgrade as needed)

3. **Client-Side Rendering:** Dashboard renders all data in browser
   - **Impact:** Low (React is efficient, data cached)
   - **Priority:** P3 (optimize if needed)

## Acceptance Criteria

✅ **PASS** if:
- No hard-coded user limits exist
- API usage projections show < 50% of limits at 50 users
- Critical paths measured and documented
- Monitoring infrastructure in place
- Scalability risks identified with mitigation plans

❌ **FAIL** if:
- Hard limits prevent adding users
- Projected API usage exceeds 80% of limits
- No performance baselines documented
- No monitoring or alerting configured

## References

- **GitHub Rate Limits:** https://docs.github.com/en/rest/overview/rate-limits-for-the-rest-api
- **GitHub Actions Pricing:** https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions
- **Performance Testing:** Lighthouse, WebPageTest, curl timing
- **Related Requirements:** NFR-3.2 (Repository Growth), NFR-2.1 (Response Time)

---

**Owner:** Jorge (VP AI-SecOps)
**Status:** Baseline documented, monitoring pending
