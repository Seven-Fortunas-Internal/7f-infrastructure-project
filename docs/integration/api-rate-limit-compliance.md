# API Rate Limit Compliance

## Rate Limits

| API | Tier | Limit | Enforcement |
|-----|------|-------|-------------|
| GitHub | Authenticated | 5,000 req/hour | Automatic |
| Claude | Production | 50 req/min, 40K req/day | Automatic |
| Reddit | Unauthenticated | 60 req/min | Client throttling |
| OpenAI Whisper | Standard | Responsible use | Best effort |
| X API | Basic ($100/mo) | 10K req/month | Manual (Phase 2) |

## Usage

```bash
source scripts/lib/rate-limit.sh
check_github_rate_limit
```

## Monitoring
- Rate limit usage tracked in dashboards
- Alerts at 80% threshold
- Violations logged for review

---
**Owner:** Jorge | **Priority:** P0
