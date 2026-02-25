# API Rate Limiting System

## Overview

The Seven Fortunas rate limiting system ensures all external API calls respect provider rate limits, preventing service disruptions and maintaining compliance with API terms of service.

## Supported APIs

### GitHub API
- **Limit:** 5,000 requests/hour (authenticated)
- **Wrapper:** `scripts/lib/github_api_wrapper.sh`
- **Usage:** Replace `gh api` with `gh_api_rate_limited`

### Claude API (Anthropic)
- **Limits:** 50 requests/minute, 40,000 requests/day
- **Wrapper:** `scripts/lib/claude_api_wrapper.sh`
- **Usage:** Use `claude_api_rate_limited` for all API calls

### Reddit JSON API
- **Limit:** 60 requests/minute (unauthenticated)
- **Wrapper:** `scripts/lib/reddit_api_wrapper.sh`
- **Usage:** Use `reddit_api_rate_limited` for subreddit fetches

### OpenAI Whisper API
- **Limit:** No documented limit (recommended: 20 requests/minute)
- **Wrapper:** `scripts/lib/whisper_api_wrapper.sh`
- **Usage:** Use `whisper_api_rate_limited` for transcriptions

### X API (Twitter)
- **Limit:** 10,000 requests/month (Basic tier, Phase 2)
- **Configuration:** `config/rate_limits.json`
- **Status:** Phase 2 implementation

## Usage

### Basic Example

```bash
#!/bin/bash
# Source the API wrapper
source scripts/lib/github_api_wrapper.sh

# Make rate-limited API call
gh_api_rate_limited /repos/Seven-Fortunas/dashboards
```

### Batch Operations

```bash
#!/bin/bash
source scripts/lib/github_api_wrapper.sh

# Process multiple repositories (automatically throttled)
for repo in repo1 repo2 repo3; do
    gh_api_rate_limited "/repos/Seven-Fortunas/$repo"
    # Rate limiter automatically throttles if limit reached
done
```

### Integration with Workflows

```yaml
# .github/workflows/dashboard-update.yml
- name: Fetch AI news (rate-limited)
  run: |
    source scripts/lib/reddit_api_wrapper.sh
    reddit_fetch_top_rate_limited "MachineLearning" "week" > ai_news.json
```

## Monitoring

### Real-Time Dashboard

```bash
# View current rate limit usage
bash scripts/monitor-rate-limits.sh
```

### Automated Monitoring

Rate limit monitoring runs automatically via GitHub Actions every 6 hours:
- Workflow: `.github/workflows/rate-limit-monitoring.yml`
- Alerts triggered if usage exceeds 90% threshold
- Violation logs uploaded as artifacts

### Violation Logs

All rate limit violations are logged to:
```
logs/rate_limit_violations.log
```

Format:
```
[2026-02-25T08:00:00Z] RATE_LIMIT_VIOLATION: github_api - 5000 req/hour exceeded
```

## Configuration

Rate limits are configured in `config/rate_limits.json`:

```json
{
  "apis": {
    "github": {
      "limits": {
        "requests_per_hour": 5000
      }
    }
  },
  "monitoring": {
    "log_violations": true,
    "alert_threshold": 0.9
  }
}
```

## Technical Details

### Rate Limiting Algorithm

The system uses a **sliding window** algorithm:
1. Tracks request timestamps per API
2. Resets count when window expires
3. Blocks requests exceeding limit
4. Auto-retries after cooldown period

### State Management

Rate limit state is stored in:
```
/tmp/7f_rate_limit_state.json
```

Format:
```json
{
  "github_api": {
    "last_reset": 1708848000,
    "request_count": 142
  }
}
```

### Throttling Behavior

When rate limit is reached:
1. Request is blocked
2. Wait time is calculated
3. System sleeps for 5 seconds
4. Retries until window resets
5. Logs warning message

## Integration with Cost Management

Rate limit metrics feed into **NFR-9.1: Cost Management**:
- API usage tracked per service
- Costs calculated based on tier limits
- Alerts triggered for high-cost operations
- Monthly usage reports generated

## Best Practices

1. **Always use wrappers** - Don't make direct API calls
2. **Monitor regularly** - Check `monitor-rate-limits.sh` output
3. **Set alerts** - Configure threshold alerts in workflows
4. **Batch wisely** - Group API calls to minimize requests
5. **Cache responses** - Store frequently-accessed data locally

## Troubleshooting

### Rate Limit Exceeded Errors

**Symptom:** Script exits with "RATE_LIMIT_EXCEEDED" error

**Solution:**
```bash
# Check current usage
bash scripts/monitor-rate-limits.sh

# Wait for window to reset, or
# Reduce request frequency
```

### State File Corruption

**Symptom:** Rate limiter fails to initialize

**Solution:**
```bash
# Reset state file
rm /tmp/7f_rate_limit_state.json
echo '{}' > /tmp/7f_rate_limit_state.json
```

### API Wrapper Not Found

**Symptom:** `source: file not found` error

**Solution:**
```bash
# Use absolute path
source /home/ladmin/dev/GDF/7F_github/scripts/lib/rate_limiter.sh
```

## Related Requirements

- **NFR-6.1:** API Rate Limit Compliance ✅
- **NFR-9.1:** Cost Management (integration)
- **FR-4.1:** AI Advancements Dashboard (uses rate-limited Reddit API)
- **FR-4.2:** AI-Generated Weekly Summaries (uses rate-limited Claude API)

## References

- [GitHub API Rate Limits](https://docs.github.com/en/rest/overview/resources-in-the-rest-api#rate-limiting)
- [Claude API Rate Limits](https://docs.anthropic.com/claude/reference/rate-limits)
- [Reddit API Guidelines](https://github.com/reddit-archive/reddit/wiki/API)
- [OpenAI Rate Limits](https://platform.openai.com/docs/guides/rate-limits)
