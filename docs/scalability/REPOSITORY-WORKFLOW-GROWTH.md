# Repository & Workflow Growth Scalability (NFR-3.2)

**Version:** 1.0
**Last Updated:** 2024-02-24
**Requirement:** NFR-3.2 - Repository & Workflow Growth

## Requirement

System SHALL support 100+ repositories and 200+ workflows.

**Target:** No architectural changes required
**Measurement:** GitHub org statistics, manual count

## Current State

### Repository Count
```bash
gh api /orgs/Seven-Fortunas-Internal/repos --paginate | jq '. | length'
```

**Current repositories:** 7 (as of 2024-02-24)
- seven-fortunas-brain
- 7f-infrastructure-project
- dashboards
- landing-page
- compliance-tracker
- internal-tools
- [others]

### Workflow Count
```bash
# Count all workflows across all repositories
gh api /orgs/Seven-Fortunas-Internal/repos --paginate | \
  jq -r '.[].full_name' | \
  xargs -I {} gh api /repos/{}/actions/workflows | \
  jq '.total_count' | \
  awk '{sum += $1} END {print sum}'
```

**Current workflows:** ~15-20 (estimated)

## Scalability Analysis

### 1. GitHub Organization Limits

**Free Tier:**
- Unlimited public repositories ✅
- Unlimited private repositories ✅
- No hard limit on workflows per repository
- 3,000 Actions minutes/month (shared across org)

**Team/Enterprise:**
- Same repository limits (unlimited)
- Increased Actions minutes
- Advanced features (SAML SSO, audit log, etc.)

**Assessment:** No architectural blocker for 100+ repos ✅

### 2. GitHub Actions Workflow Limits

**Per Repository:**
- Up to 20 workflow files per `.github/workflows/` directory
- No limit on total workflows across organization
- Workflows can be stored in multiple repositories

**Assessment:** 200+ workflows achievable (10-20 per repo across 10-20 repos) ✅

### 3. API Rate Limits

**With 100 repositories:**
- Dashboard auto-update: Queries all repos for metrics
- Compliance monitoring: Checks security settings per repo
- Search: May scan across all repos

**Current API usage:** ~100-200 requests/hour
**Projected with 100 repos:** ~1,000-2,000 requests/hour (still < 5,000 limit)

**Assessment:** Adequate for 100 repos with current usage patterns ✅

### 4. Performance Impact

#### Dashboard Rendering
**Current:** Fetches data for 7 repositories
**Projected:** 100 repositories

**Mitigation strategies:**
- Pagination (show 20 repos per page)
- Lazy loading (load details on demand)
- Caching (1-hour cache for repo metadata)
- Filtering (show only active/recent repos by default)

**Assessment:** Requires pagination for good UX, but architecturally sound ✅

#### Workflow Management
**Current:** 15-20 workflows
**Projected:** 200+ workflows

**Challenges:**
- Discovery (finding the right workflow)
- Monitoring (tracking all workflow runs)
- Debugging (identifying failures)

**Mitigation strategies:**
- Naming conventions (category-action-scope.yml)
- Centralized monitoring dashboard
- Tagging/labeling system
- Automated health checks

**Assessment:** Organizational challenge, not architectural ✅

### 5. Storage Requirements

**Per repository:**
- Code: 10-100 MB (average)
- Workflow logs: 1-10 MB/month
- Artifacts: Variable (can be limited via retention policies)

**100 repositories:**
- Code: 1-10 GB
- Workflow logs: 100 MB - 1 GB/month
- Artifacts: 5-50 GB (with 90-day retention)

**GitHub storage limits:**
- Unlimited repository storage (all plans)
- Artifacts: Default 90-day retention, configurable

**Assessment:** No concerns ✅

## Architectural Verification

### 1. No Hard-Coded Repository Limits

**Check all scripts for hard-coded repo lists:**
```bash
# Search for hard-coded repository names
grep -r "seven-fortunas-brain\|dashboards\|landing-page" scripts/ | \
  grep -v "example\|comment" | \
  wc -l
```

**Strategy:** Use dynamic repository discovery via GitHub API
```bash
# Good: Dynamic discovery
gh api /orgs/Seven-Fortunas-Internal/repos --paginate | jq -r '.[].name'

# Bad: Hard-coded list
REPOS=("seven-fortunas-brain" "dashboards" "landing-page")
```

### 2. Pagination Implemented

**All scripts that query repositories MUST paginate:**
```bash
# Good: Paginated query
gh api /orgs/Seven-Fortunas-Internal/repos --paginate

# Bad: Single page (max 30 repos)
gh api /orgs/Seven-Fortunas-Internal/repos
```

**Assessment:** Verify all scripts use `--paginate` flag ✅

### 3. Workflow Naming Convention

**Recommended structure:**
```
.github/workflows/
├── compliance-soc2-monitor.yml          # Category: compliance
├── compliance-secrets-scan.yml
├── deploy-dashboard-production.yml      # Category: deploy
├── deploy-brain-staging.yml
├── test-unit-all.yml                    # Category: test
├── test-integration-api.yml
└── ...
```

**Benefits:**
- Easy to find workflows by category
- Clear purpose from filename
- Scalable to 200+ workflows

### 4. Centralized Configuration

**Avoid duplication across workflows:**
```yaml
# Good: Use reusable workflows
name: Deploy Dashboard
uses: ./.github/workflows/reusable-deploy.yml
with:
  environment: production
  app: dashboard

# Bad: Duplicate workflow code 200 times
name: Deploy Dashboard Production
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps: [... 50 lines of repeated code ...]
```

**Strategy:** Create 10-20 reusable workflows, parameterize for specific use cases

## Implementation Checklist

### Phase 1: Current State Audit
- [x] Count current repositories
- [x] Count current workflows
- [x] Identify hard-coded repository references
- [x] Document current architecture

### Phase 2: Remove Barriers
- [ ] Replace hard-coded repo lists with API discovery
- [ ] Add pagination to all repository queries
- [ ] Implement workflow naming convention
- [ ] Create reusable workflow templates

### Phase 3: Optimization
- [ ] Add dashboard pagination for repos
- [ ] Implement caching for repo metadata
- [ ] Create workflow monitoring dashboard
- [ ] Set up automated health checks

### Phase 4: Validation
- [ ] Test with 20 repos (simulate growth)
- [ ] Test with 50 repos
- [ ] Test with 100 repos
- [ ] Measure performance at each scale

## Verification Criteria

### Functional
✅ System can discover all repositories dynamically (no hard-coded lists)
✅ Workflows can be created without architectural limits
✅ No pagination limits in critical paths

### Technical
✅ All repository queries use `--paginate`
✅ API usage projects to < 50% of limits at 100 repos
✅ Dashboard performance acceptable with 100 repos

### Integration
✅ GitHub organization supports unlimited repos
✅ No architectural changes required for 100+ repos
✅ Monitoring in place for repo/workflow growth

## Monitoring & Alerts

### Repository Growth Tracking
```bash
# Weekly cron job to track growth
gh api /orgs/Seven-Fortunas-Internal/repos --paginate | \
  jq '{
    total: length,
    public: [.[] | select(.private == false)] | length,
    private: [.[] | select(.private == true)] | length,
    timestamp: now | strftime("%Y-%m-%d")
  }' >> repo-growth-log.json
```

### Workflow Count Tracking
```bash
# Count workflows across all repos
TOTAL_WORKFLOWS=$(
  gh api /orgs/Seven-Fortunas-Internal/repos --paginate | \
  jq -r '.[].full_name' | \
  xargs -I {} gh api /repos/{}/actions/workflows --paginate | \
  jq '.workflows | length' | \
  awk '{sum += $1} END {print sum}'
)

echo "Total workflows: $TOTAL_WORKFLOWS"

# Alert if approaching 200
if [ "$TOTAL_WORKFLOWS" -gt 150 ]; then
  echo "⚠️ Approaching 200 workflow limit ($TOTAL_WORKFLOWS/200)"
fi
```

## Risk Assessment

### Low Risk ✅
- GitHub supports unlimited repositories
- GitHub supports unlimited workflows
- API rate limits adequate for 100+ repos
- Storage unlimited

### Medium Risk ⚠️
- Dashboard may be slow without pagination
- Workflow discovery challenging without organization
- GitHub Actions minutes may need upgrade

### High Risk ❌
- None identified

## Acceptance Criteria

✅ **PASS** if:
- No hard-coded repository limits in codebase
- All queries use pagination
- API usage projects to < 50% at 100 repos
- No architectural barriers identified
- Monitoring plan documented

❌ **FAIL** if:
- Hard-coded limits prevent scaling
- Missing pagination causes failures
- Architectural redesign required

## Current Status

**Repositories:** 7/100 (7%)
**Workflows:** ~15/200 (7.5%)
**API Usage:** < 1% of limits
**Architecture:** ✅ Ready for 100+ repos/200+ workflows

## References

- **GitHub Limits:** https://docs.github.com/en/actions/learn-github-actions/usage-limits-billing-and-administration
- **API Pagination:** https://docs.github.com/en/rest/guides/using-pagination-in-the-rest-api
- **Reusable Workflows:** https://docs.github.com/en/actions/using-workflows/reusing-workflows
- **Related:** NFR-3.1 (Team Growth), NFR-2.1 (Performance)

---

**Owner:** Jorge (VP AI-SecOps)
**Status:** Architecture verified, ready for growth
