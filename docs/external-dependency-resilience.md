# External Dependency Resilience (NFR-6.2)

**Version:** 1.0
**Status:** Implemented
**Requirement:** System SHALL implement retry logic and error logging for external dependencies

---

## Overview

The External Dependency Resilience system ensures robust handling of external service failures through retry logic, circuit breakers, and graceful degradation.

### Key Components

1. **Resilience Module** (`scripts/resilience.py`)
   - Retry decorator with exponential backoff
   - Circuit breaker pattern implementation
   - Error logging with context
   - Fallback to degraded mode

2. **Resilience Monitor** (`.github/workflows/monitor-dependency-resilience.yml`)
   - Track circuit breaker trips
   - Analyze retry errors
   - Generate resilience reports
   - Alert on resilience issues

---

## Retry Strategy

### Exponential Backoff

**Sequence:** 1s, 2s, 4s, 8s

**Max Retries:** 5

**Example:**
```
Attempt 1: Immediate
Attempt 2: Wait 1s
Attempt 3: Wait 2s
Attempt 4: Wait 4s
Attempt 5: Wait 8s
Attempt 6: FAIL (retries exhausted)
```

**Total maximum delay:** 15 seconds (1+2+4+8)

### Usage

```python
from scripts.resilience import retry_with_backoff

@retry_with_backoff(
    max_retries=5,
    backoff_sequence=(1, 2, 4, 8)
)
def fetch_data_from_api():
    response = requests.get(api_url)
    response.raise_for_status()
    return response.json()

# Call function - retries automatically on failure
try:
    data = fetch_data_from_api()
except RetryError:
    # All retries exhausted
    handle_permanent_failure()
```

---

## Circuit Breaker Pattern

### States

1. **CLOSED** (Normal Operation)
   - All requests pass through
   - Failures are counted
   - Trips to OPEN after threshold

2. **OPEN** (Failing)
   - Requests are rejected immediately
   - Prevents cascading failures
   - Transitions to HALF_OPEN after timeout

3. **HALF_OPEN** (Testing Recovery)
   - Limited requests allowed
   - Tests if service recovered
   - Resets to CLOSED on success
   - Trips back to OPEN on failure

### Configuration

| Parameter | Value | Description |
|-----------|-------|-------------|
| Failure Threshold | 5 | Consecutive failures before trip |
| Recovery Timeout | 60s | Wait time before testing recovery |
| Half-Open Max Calls | 3 | Test calls in HALF_OPEN state |

### Usage

```python
from scripts.resilience import get_circuit_breaker, retry_with_backoff

# Get circuit breaker for dependency
github_cb = get_circuit_breaker('github_api')

@retry_with_backoff(
    max_retries=5,
    backoff_sequence=(1, 2, 4, 8),
    circuit_breaker=github_cb
)
def call_github_api():
    return requests.get(github_url)

# Circuit breaker automatically manages state
try:
    data = call_github_api()
except CircuitBreakerOpenError:
    # Circuit is open, use fallback
    data = use_cached_data()
```

---

## Fallback to Degraded Mode

When retries are exhausted, the system can fall back to degraded mode.

### Example: Dashboard with Fallback

```python
from scripts.resilience import retry_with_backoff

def fallback_dashboard_data():
    """Return cached/partial data when API unavailable."""
    return {
        'status': 'degraded',
        'data': load_cached_data(),
        'message': 'Using cached data due to API unavailability'
    }

@retry_with_backoff(
    max_retries=5,
    backoff_sequence=(1, 2, 4, 8),
    fallback=fallback_dashboard_data
)
def fetch_dashboard_data():
    response = requests.get(api_url)
    response.raise_for_status()
    return response.json()

# Always returns data (fresh or degraded)
data = fetch_dashboard_data()
print(f"Status: {data.get('status', 'ok')}")
```

---

## Error Logging

### Retry Errors

File: `compliance/resilience/retry-errors.log`

```
2026-02-24T05:30:00Z - Function: fetch_dashboard_data | Attempt: 1 | Error: ConnectionError: Connection timeout | Backoff: 1s
2026-02-24T05:30:01Z - Function: fetch_dashboard_data | Attempt: 2 | Error: ConnectionError: Connection timeout | Backoff: 2s
2026-02-24T05:30:03Z - Function: fetch_dashboard_data | Attempt: 3 | Error: ConnectionError: Connection timeout | Backoff: 4s
```

**Includes:**
- Timestamp (UTC)
- Function name
- Attempt number
- Error type and message
- Backoff delay

### Circuit Breaker Trips

File: `compliance/resilience/circuit-breaker-trips.log`

```
2026-02-24T05:35:00Z - Circuit breaker 'github_api' TRIPPED (failures: 5)
2026-02-24T05:36:15Z - Circuit breaker 'reddit_api' TRIPPED (failures: 5)
```

**Includes:**
- Timestamp (UTC)
- Circuit breaker name
- Failure count

---

## Monitoring

### Automatic Checks

**Frequency:** Every 6 hours

**Checks:**
1. Circuit breaker trips (last 24 hours)
2. Retry errors (last 24 hours)
3. Affected dependencies
4. Error patterns

### Alerts

**Circuit Breaker Trip Alert:**
- Title: ⚠️ Dependency Resilience Alert: Circuit Breaker Trips
- Labels: resilience, NFR-6.2, P1
- Triggered: When trips detected in last 24 hours
- Contains: Trip count, affected circuit breakers, investigation steps

**Report Generation:**
- Frequency: Every 6 hours
- Location: `compliance/resilience/reports/`
- Format: Markdown
- Contains: Summary statistics, configuration, trends

---

## Integration

### With NFR-4.2: Graceful Degradation

Resilience system provides foundation for graceful degradation:
- Circuit breaker prevents cascading failures
- Fallback functions provide degraded service
- Error logging tracks degradation events

### With Uptime Monitoring

Resilience metrics feed into uptime tracking:
- Circuit breaker state indicates service health
- Retry errors indicate transient issues
- Trip frequency tracks dependency reliability

---

## Troubleshooting

### High Retry Rate

**Symptoms:**
- Many retry errors in logs
- Workflows taking longer than usual
- Increased API latency

**Diagnosis:**
```bash
# Count retry errors by function
grep "Function:" compliance/resilience/retry-errors.log | \
  cut -d'|' -f2 | sort | uniq -c | sort -rn
```

**Solutions:**
1. Check external service status
2. Increase backoff delays
3. Implement caching
4. Add circuit breaker if not present

### Circuit Breaker Tripping Frequently

**Symptoms:**
- Circuit breaker trips in logs
- CircuitBreakerOpenError exceptions
- Services unavailable

**Diagnosis:**
```bash
# View recent trips
tail -20 compliance/resilience/circuit-breaker-trips.log

# Count trips by circuit
grep "Circuit breaker" compliance/resilience/circuit-breaker-trips.log | \
  grep -oP "Circuit breaker '\K[^']*" | sort | uniq -c | sort -rn
```

**Solutions:**
1. Verify external service health
2. Increase failure threshold if appropriate
3. Implement better error handling
4. Add fallback mechanisms

### Degraded Mode Not Working

**Symptoms:**
- Errors despite fallback function
- No degraded data returned
- Fallback errors in logs

**Diagnosis:**
```bash
# Check for fallback errors
grep -i "fallback" compliance/resilience/retry-errors.log
```

**Solutions:**
1. Verify fallback function logic
2. Ensure cached data is available
3. Test fallback independently
4. Add logging to fallback function

---

## Examples

### GitHub API with Resilience

```python
from scripts.resilience import retry_with_backoff, get_circuit_breaker
import requests

github_cb = get_circuit_breaker('github_api', failure_threshold=5)

def fallback_github_data():
    """Use cached GitHub data when API unavailable."""
    return load_cached_github_data()

@retry_with_backoff(
    max_retries=5,
    backoff_sequence=(1, 2, 4, 8),
    circuit_breaker=github_cb,
    fallback=fallback_github_data
)
def fetch_github_repos():
    response = requests.get(
        'https://api.github.com/orgs/Seven-Fortunas/repos',
        headers={'Authorization': f'token {GITHUB_TOKEN}'}
    )
    response.raise_for_status()
    return response.json()

# Usage
repos = fetch_github_repos()
```

### Reddit API with Resilience

```python
from scripts.resilience import retry_with_backoff
import requests

@retry_with_backoff(
    max_retries=5,
    backoff_sequence=(1, 2, 4, 8)
)
def fetch_reddit_posts(subreddit):
    response = requests.get(
        f'https://www.reddit.com/r/{subreddit}/.json',
        headers={'User-Agent': 'SevenFortunas/1.0'}
    )
    response.raise_for_status()
    return response.json()

# Usage
try:
    posts = fetch_reddit_posts('MachineLearning')
except RetryError:
    # All retries exhausted, handle error
    posts = []
```

---

## Best Practices

1. **Always Use Retry Logic for External Calls**
   - Apply `@retry_with_backoff` to all external API calls
   - Use circuit breakers for frequently-called dependencies

2. **Implement Meaningful Fallbacks**
   - Provide cached/partial data instead of failures
   - Ensure fallback functions are simple and fast

3. **Log with Context**
   - Include function name, attempt number, error details
   - Use structured logging for analysis

4. **Monitor Circuit Breaker State**
   - Track trips and recovery patterns
   - Alert on persistent OPEN states

5. **Test Resilience Mechanisms**
   - Simulate failures to verify retry logic
   - Test fallback functions independently

---

## References

- **NFR-6.2:** External Dependency Resilience
- **NFR-4.2:** Graceful Degradation
- **NFR-6.1:** API Rate Limit Compliance

---

## Change Log

| Date | Version | Changes |
|------|---------|---------|
| 2026-02-24 | 1.0 | Initial implementation |

---

**Owner:** Jorge (VP AI-SecOps)
**Maintained by:** Autonomous Implementation Agent
