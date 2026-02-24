# API Rate Limit Compliance (NFR-6.1)

**Version:** 1.0
**Status:** Implemented
**Requirement:** System SHALL respect rate limits of all external APIs

---

## Overview

The API Rate Limit Compliance system ensures all external API calls respect rate limits to prevent service disruptions and maintain good API citizenship.

### Key Components

1. **Rate Limiter** (`scripts/rate_limiter.py`)
   - Per-API rate limiting (GitHub, Claude, Reddit, OpenAI, X)
   - Request throttling and queueing
   - Automatic header parsing
   - Violation logging

2. **Rate Limit Monitor** (`.github/workflows/monitor-rate-limits.yml`)
   - Hourly rate limit usage checks
   - GitHub API rate limit tracking
   - Violation detection and alerting
   - Usage metrics collection

3. **Usage Analyzer** (`scripts/analyze_rate_limits.py`)
   - Usage statistics per API
   - Compliance checking
   - Violation analysis
   - Trend reporting

4. **Configuration** (`compliance/rate-limits/rate-limit-config.yaml`)
   - Rate limit thresholds per API
   - Monitoring settings
   - Alert configuration

---

## Rate Limits

### Configured Limits

| API | Limit | Period | Status |
|-----|-------|--------|--------|
| **GitHub** | 5,000 requests | 1 hour (authenticated) | ✅ Active |
| **Claude** | 50 requests / 40,000 requests | 1 minute / 1 day | ✅ Active |
| **Reddit** | 60 requests | 1 minute (unauthenticated) | ✅ Active |
| **OpenAI Whisper** | ~50 requests | 1 minute (conservative) | ✅ Active |
| **X API** | 10,000 requests | 1 month ($100/mo tier) | 🔄 Phase 2 |

### Throttling Strategy

**GitHub API:**
- Start throttling at 80% usage (4,000/5,000 requests)
- Parse `x-ratelimit-remaining` header
- Auto-wait when limit reached

**Claude API:**
- Pre-request throttling based on time windows
- Track both per-minute and per-day limits
- Queue requests when limit reached

**Reddit API:**
- Enforce 60 req/min via request throttling
- Verify User-Agent compliance
- Auto-wait between requests

**OpenAI Whisper:**
- Conservative 50 req/min limit (no official limit documented)
- Pre-request throttling
- Respectful usage patterns

---

## Usage

### Using the Rate Limiter in Code

```python
from scripts.rate_limiter import get_rate_limiter, wait_for_rate_limit, record_api_request

# Option 1: Manual control
limiter = get_rate_limiter('github')

# Check if request can proceed
can_proceed, wait_seconds = limiter.check_limit()
if not can_proceed:
    print(f"Rate limit reached, waiting {wait_seconds}s")
    time.sleep(wait_seconds)

# Make API request
response = requests.get(url, headers=headers)

# Record request
limiter.record_request(response.headers)

# Option 2: Automatic waiting
wait_for_rate_limit('github')
response = requests.get(url, headers=headers)
record_api_request('github', response.headers)

# Option 3: Context manager (recommended)
with rate_limit_context('github') as limiter:
    response = requests.get(url, headers=headers)
    # Request automatically recorded
```

### Check Rate Limit Usage

```bash
# Analyze usage for last 7 days
python3 scripts/analyze_rate_limits.py

# Analyze usage for last 30 days
python3 scripts/analyze_rate_limits.py --days 30

# Save report to file
python3 scripts/analyze_rate_limits.py \
  --output compliance/rate-limits/reports/report-$(date +%Y-%m-%d).md
```

### Manual Rate Limit Check (GitHub)

```bash
# Check current GitHub API rate limit
gh api rate_limit

# Check rate limit with details
gh api rate_limit --jq '.resources.core'
```

---

## How It Works

### 1. Request Throttling

Before making an API request:

1. **Check Rate Limit:**
   - Query rate limiter for API
   - Check if within limit based on time window
   - Calculate wait time if limit reached

2. **Wait if Needed:**
   - Automatically sleep if limit reached
   - Log throttling event
   - Update throttle counter

3. **Make Request:**
   - Execute API call
   - Capture response headers

4. **Record Request:**
   - Log request timestamp
   - Parse rate limit headers (if available)
   - Update usage statistics
   - Save metrics to file

### 2. Usage Monitoring

Hourly monitoring workflow:

1. **Check GitHub Rate Limit:**
   - Query GitHub API `/rate_limit` endpoint
   - Extract usage and limit info
   - Calculate usage percentage
   - Log to metrics file

2. **Analyze Violations:**
   - Read violations log
   - Count recent violations (last 24 hours)
   - Group by API

3. **Create Alerts:**
   - Create GitHub issue if violations found
   - Create issue if usage > 80%
   - Update existing issues if already open

4. **Commit Metrics:**
   - Save all metrics to repository
   - Maintain historical record

### 3. Header Parsing

**GitHub API Headers:**
```
x-ratelimit-limit: 5000
x-ratelimit-remaining: 4523
x-ratelimit-reset: 1708761600
```

Parsed to:
- Detect approaching limits
- Calculate optimal wait times
- Log violations when remaining = 0

**Other APIs:**
- Most don't provide rate limit headers
- Rely on pre-request throttling
- Track usage client-side

---

## Metrics

### GitHub Rate Limit Metrics

File: `compliance/rate-limits/metrics/github-rate-limit.jsonl`

```json
{
  "timestamp": "2026-02-24T05:00:00Z",
  "api": "github",
  "core": {
    "limit": 5000,
    "remaining": 4523,
    "used": 477,
    "reset": 1708761600
  },
  "search": {
    "limit": 30,
    "remaining": 28,
    "used": 2,
    "reset": 1708761600
  }
}
```

### API Usage Metrics

File: `compliance/rate-limits/metrics/api-usage.jsonl`

```json
{
  "timestamp": "2026-02-24T05:00:00Z",
  "api": "claude",
  "total_requests": 1250,
  "throttled_requests": 15,
  "violations": 0,
  "current_window_requests": 8,
  "daily_requests": 1250
}
```

### Violations Log

File: `compliance/rate-limits/metrics/violations.jsonl`

```json
{
  "timestamp": "2026-02-24T05:00:00Z",
  "api": "github",
  "violation_type": "rate_limit_exceeded",
  "headers": {
    "x-ratelimit-remaining": "0",
    "x-ratelimit-reset": "1708761600"
  }
}
```

---

## Alerts

### Violation Alert

Created when rate limit violations detected:

**Title:** ⚠️ API Rate Limit Violations Detected

**Labels:** rate-limit, NFR-6.1, P0

**Content:**
- Violation count (last 24 hours)
- Detection time
- Affected APIs
- Action items

### High Usage Alert

Created when usage > 80% of limit:

**Title:** ⚠️ API Rate Limit Usage Warning

**Labels:** rate-limit, NFR-6.1, monitoring

**Content:**
- Current usage percentage
- API details
- Recommendations

---

## Compliance Report Example

```markdown
# API Rate Limit Compliance Report (NFR-6.1)

**Period:** Last 7 days
**Generated:** 2026-02-24 05:00:00 UTC

## Compliance Status

### ✅ COMPLIANT

All API usage is within rate limits.

## GitHub API

✅ **Current Usage:** 9.5%
- Limit: 5,000 requests/hour
- Used: 477
- Remaining: 4,523

**Average Usage:** 12.3%
- Samples: 168

## Other API Usage

### CLAUDE
- Total Requests: 1,250
- Throttled: 15
- Violations: 0

### REDDIT
- Total Requests: 850
- Throttled: 8
- Violations: 0

## Violations

✅ No rate limit violations detected.

## Recommendations

Current API usage is compliant. Continue monitoring.
```

---

## Troubleshooting

### Rate Limit Exceeded

**Symptoms:**
- API requests failing with 429 status
- "rate limit exceeded" errors
- Workflows slowing down or failing

**Diagnosis:**
1. Check current usage:
   ```bash
   python3 scripts/analyze_rate_limits.py
   ```

2. Review violations:
   ```bash
   cat compliance/rate-limits/metrics/violations.jsonl | tail -20
   ```

3. Check GitHub rate limit:
   ```bash
   gh api rate_limit --jq '.resources.core'
   ```

**Solutions:**

1. **Increase Throttling:**
   ```python
   # Reduce concurrent requests
   limiter = RateLimiter('github')
   # Wait longer between requests
   ```

2. **Implement Caching:**
   - Cache API responses to reduce calls
   - Use ETags for conditional requests
   - Store results locally when possible

3. **Optimize Scheduling:**
   - Spread workflow runs across hours
   - Avoid peak usage times
   - Reduce update frequency

4. **Request Limit Increase:**
   - Contact API provider for higher limits
   - Consider paid tiers (e.g., GitHub Enterprise)

### Metrics Not Recording

**Symptoms:**
- Empty metrics files
- No usage data in reports
- Monitoring workflow not running

**Diagnosis:**
1. Check workflow runs:
   ```bash
   gh run list --workflow="Monitor API Rate Limits"
   ```

2. Check for errors:
   ```bash
   gh run view <run-id> --log
   ```

**Solutions:**
1. Verify monitoring workflow is enabled
2. Check GitHub API token permissions
3. Ensure metrics directory exists and is writable
4. Manually trigger workflow:
   ```bash
   gh workflow run monitor-rate-limits.yml
   ```

### False Violations

**Symptoms:**
- Violations logged but API working fine
- High violation count with no actual errors
- Inconsistent violation detection

**Diagnosis:**
1. Review violation details:
   ```bash
   cat compliance/rate-limits/metrics/violations.jsonl | jq .
   ```

2. Check API response headers
3. Verify rate limiter configuration

**Solutions:**
1. Update rate limiter thresholds
2. Fix header parsing logic
3. Clear false positive violations
4. Adjust violation detection logic

---

## Integration

### With NFR-9.1: Cost Management

Rate limit metrics feed into cost management:
- API usage affects costs (especially paid tiers)
- High usage may indicate need for optimization
- Trend analysis for capacity planning

### With Dashboard Features

Rate limiting integrated into dashboard updates:
- All dashboard workflows use rate limiter
- Automatic throttling prevents violations
- Parallel requests respect limits

---

## Maintenance

### Regular Tasks

**Daily:**
- Review monitoring workflow runs
- Check for violations

**Weekly:**
- Generate compliance report
- Analyze usage trends
- Optimize if approaching limits

**Monthly:**
- Review and adjust rate limits
- Evaluate API tier needs
- Update documentation

### Data Retention

- **Metrics:** 90 days (configurable)
- **Violations:** Keep all (audit trail)
- **Reports:** Keep all (historical record)

---

## References

- **NFR-6.1:** API Rate Limit Compliance
- **NFR-9.1:** Cost Management
- **FR-4.1:** AI Advancements Dashboard (MVP)
- **FR-4.2:** AI-Generated Weekly Summaries

---

## Change Log

| Date | Version | Changes |
|------|---------|---------|
| 2026-02-24 | 1.0 | Initial implementation |

---

**Owner:** Jorge (VP AI-SecOps)
**Maintained by:** Autonomous Implementation Agent
