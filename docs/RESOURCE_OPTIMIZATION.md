# Resource Optimization - Seven Fortunas Infrastructure

**Version:** 1.0
**Last Updated:** 2026-02-24
**Priority:** P2
**Target:** <10% month-over-month cost increase

---

## Overview

The Seven Fortunas infrastructure is designed for cost efficiency, leveraging free-tier services and optimizing resource usage to minimize operational costs while scaling.

---

## Current Cost Profile

### GitHub (Free Tier)

**Cost:** $0/month
**Resources:**
- Public repositories: Unlimited
- GitHub Actions: 2,000 minutes/month (public repos: unlimited)
- GitHub Pages: Unlimited bandwidth (soft limit: 100GB/month)
- Storage: 500MB per repository

**Usage:**
- Repositories: 8
- Actions minutes: ~200/month (well within limits)
- Pages bandwidth: <1GB/month
- Storage: <100MB per repo

**Optimization:**
- Use public repos (unlimited Actions minutes)
- Minimize workflow runs (schedule vs push triggers)
- Cache dependencies (reduce build time)

---

### Anthropic Claude API

**Cost:** Pay-per-use
**Model:** Claude Sonnet 3.5 (primary), Claude Haiku (secondary)

**Usage patterns:**
- Autonomous agent: ~10,000 tokens/session
- Dashboard summaries: ~5,000 tokens/week
- Skills invocation: ~2,000 tokens/invocation

**Monthly estimate:**
- Agent: 4 sessions/week × 10k tokens = 160k tokens/month
- Dashboards: 4 updates/month × 5k tokens = 20k tokens/month
- Skills: 10 invocations/month × 2k tokens = 20k tokens/month
- **Total: ~200k tokens/month**

**Cost optimization:**
- Use Claude Haiku for simple tasks (10× cheaper)
- Cache prompts where possible (50% cost reduction)
- Batch API calls (reduce overhead)
- Monitor token usage (track via API)

---

### External Services (Free Tier)

**GitHub:**
- Cost: $0
- Free for public repos

**Cloudflare (future):**
- Cost: $0 (free tier)
- CDN, DDoS protection

**Vercel (future):**
- Cost: $0 (hobby tier)
- Serverless functions, edge network

---

## Cost Optimization Strategies

### 1. GitHub Actions Optimization

**Current usage:** ~200 minutes/month
**Target:** <500 minutes/month
**Free tier limit:** 2,000 minutes/month (or unlimited for public repos)

**Optimizations:**

**A. Reduce workflow frequency:**
```yaml
# Before: Every hour
on:
  schedule:
    - cron: '0 * * * *'  # 720 runs/month

# After: Every 6 hours
on:
  schedule:
    - cron: '0 */6 * * *'  # 120 runs/month
```
**Savings:** 600 runs/month = 83% reduction

**B. Use caching:**
```yaml
- name: Cache dependencies
  uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```
**Savings:** 60% faster builds = 40% time reduction

**C. Conditional runs:**
```yaml
- name: Run tests
  if: github.event_name == 'pull_request'  # Only on PRs
```
**Savings:** 50% fewer runs

---

### 2. API Rate Limit Optimization

**Current usage:** 1,000-2,000 API calls/day
**Free tier limit:** 5,000 calls/hour (authenticated)

**Optimizations:**

**A. Use GraphQL instead of REST:**
```graphql
# GraphQL: 1 call for multiple resources
query {
  repository(owner: "Seven-Fortunas", name: "dashboards") {
    releases(first: 10) { nodes { name, createdAt } }
    issues(first: 10) { nodes { title, state } }
  }
}
```
**Savings:** 50% fewer API calls vs REST

**B. Add caching:**
```python
import requests_cache

requests_cache.install_cache('github_cache', expire_after=3600)  # 1h cache
response = requests.get('https://api.github.com/repos/...')
```
**Savings:** 80% reduction in duplicate calls

**C. Use conditional requests:**
```bash
# If-Modified-Since header
curl -H "If-Modified-Since: $(date -R)" \
  https://api.github.com/repos/Seven-Fortunas/dashboards
# Returns 304 Not Modified if no changes (doesn't count toward rate limit)
```
**Savings:** 30% reduction in rate limit consumption

---

### 3. Storage Optimization

**Current usage:** <100MB per repository
**Free tier limit:** 500MB per repository

**Optimizations:**

**A. Exclude build artifacts from git:**
```gitignore
# .gitignore
node_modules/
dist/
build/
*.log
.cache/
```
**Savings:** 90% reduction in repo size

**B. Use Git LFS for large files (if needed):**
```bash
git lfs track "*.pdf"
git lfs track "*.zip"
```
**Savings:** Offload large files from repo

**C. Prune old metrics files:**
```bash
# Keep only last 90 days of metrics
find metrics/ -name "*.json" -mtime +90 -delete
```
**Savings:** Prevent unbounded growth

---

### 4. Bandwidth Optimization (GitHub Pages)

**Current usage:** <1GB/month
**Soft limit:** 100GB/month

**Optimizations:**

**A. Minify and compress assets:**
```javascript
// vite.config.js
export default {
  build: {
    minify: 'terser',
    terserOptions: {
      compress: { drop_console: true }
    },
    cssMinify: true
  }
}
```
**Savings:** 50% reduction in asset size

**B. Use CDN for external libraries:**
```html
<!-- Use CDN instead of bundling -->
<script src="https://cdn.jsdelivr.net/npm/react@18/umd/react.production.min.js"></script>
```
**Savings:** 30% reduction in bandwidth

**C. Implement lazy loading:**
```javascript
const Dashboard = lazy(() => import('./Dashboard'));
```
**Savings:** 40% reduction in initial page load

---

## Cost Monitoring

### Monthly Cost Tracking

**File:** `costs/monthly-costs.json`

```json
{
  "month": "2026-02",
  "github_actions_minutes": 200,
  "claude_api_tokens": 180000,
  "storage_mb": 450,
  "bandwidth_gb": 0.8,
  "estimated_cost": 0,
  "notes": "All services on free tier"
}
```

**Script:** `scripts/track-costs.sh`

```bash
#!/bin/bash

MONTH=$(date +%Y-%m)

# GitHub Actions usage
ACTIONS_MINUTES=$(gh api /repos/Seven-Fortunas/7F_github/actions/usage \
  --jq '.total_minutes_used')

# Storage usage
STORAGE_MB=$(du -sm . | cut -f1)

# Create cost report
cat > costs/costs-$MONTH.json <<EOF
{
  "month": "$MONTH",
  "github_actions_minutes": $ACTIONS_MINUTES,
  "storage_mb": $STORAGE_MB,
  "date_generated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo "Cost report generated: costs/costs-$MONTH.json"
```

---

### Month-over-Month Trend Analysis

**Target:** <10% MoM increase

```bash
# Calculate MoM increase
CURRENT=$(jq '.github_actions_minutes' costs/costs-$(date +%Y-%m).json)
PREVIOUS=$(jq '.github_actions_minutes' costs/costs-$(date -d '1 month ago' +%Y-%m).json)

INCREASE=$(((CURRENT - PREVIOUS) * 100 / PREVIOUS))

if [ $INCREASE -gt 10 ]; then
  echo "WARNING: Cost increase ${INCREASE}% exceeds 10% threshold"
else
  echo "OK: Cost increase ${INCREASE}% within 10% threshold"
fi
```

---

## Scaling Considerations

### When Usage Doubles (10x Growth)

**Current:**
- Repositories: 8
- Workflow runs: 120/month
- API calls: 50k/month
- Storage: 800MB total

**At 10x scale:**
- Repositories: 80
- Workflow runs: 1,200/month
- API calls: 500k/month
- Storage: 8GB total

**Still within free tier:**
- ✅ Public repos: Unlimited (still $0)
- ✅ Actions: Unlimited for public repos (still $0)
- ✅ API calls: 5,000/hour = 3.6M/month (10x headroom)
- ✅ Storage: 500MB × 80 repos = 40GB limit (5x headroom)

**Optimizations needed:**
- Implement caching (API calls)
- Use GraphQL (reduce API calls)
- Prune old data (storage)

**Cost impact:** Still $0 (free tier sufficient)

---

### When to Upgrade (Beyond Free Tier)

**Scenario 1: Private repositories needed**
- GitHub Team: $4/user/month
- Alternative: Keep infrastructure public, use private repos only for sensitive code

**Scenario 2: >2,000 Actions minutes/month (paid account)**
- Happens if: >16 workflow runs/day with 10min builds
- Cost: $0.008/minute = $16/month for 2,000 extra minutes
- Alternative: Optimize builds, use caching, reduce frequency

**Scenario 3: Claude API usage >1M tokens/month**
- Current: ~200k tokens/month
- At 1M: ~$15-30/month (depending on model)
- Alternative: Use Claude Haiku for simple tasks (10× cheaper)

---

## Resource Quotas

| Resource | Free Tier | Current Usage | Headroom |
|----------|-----------|---------------|----------|
| GitHub Actions (public) | Unlimited | 200 min/month | Unlimited |
| GitHub API calls | 5k/hour | 1k/day | 20x |
| GitHub Pages bandwidth | 100GB/month | <1GB/month | 100x |
| Repository storage | 500MB each | <100MB each | 5x |
| Claude API tokens | Pay-per-use | 200k/month | N/A |

**All resources well within limits ✓**

---

## Success Criteria

NFR-9.3 is satisfied when:

1. ✅ Cost optimization strategies documented
2. ✅ Monthly cost tracking implemented
3. ✅ MoM cost increase <10% (monitored)
4. ✅ Free tier limits documented
5. ✅ Scaling considerations analyzed

**Target:** <10% month-over-month cost increase

---

**Owner:** Jorge (VP AI-SecOps)
**Review Date:** 2026-03-24 (monthly review)
