# External Dependency Resilience

## Retry Strategy
- Max retries: 5
- Backoff: Exponential (1s, 2s, 4s, 8s, 16s)
- Circuit breaker: 5 consecutive failures

## Usage
```bash
source scripts/lib/retry.sh
retry_with_backoff gh api /user
```

## Fallback
When retries exhausted, system enters degraded mode.

---
**Owner:** Jorge | **Target:** 99% uptime
