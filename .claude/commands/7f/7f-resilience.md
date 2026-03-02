---
description: "External dependency resilience with retry logic, circuit breaker, and error handling"
tags: ["resilience", "retry", "circuit-breaker", "error-handling", "external-dependencies"]
---

# External Dependency Resilience (NFR-6.2)

Comprehensive retry logic, circuit breaker pattern, and error handling for external dependencies.

## Overview

The resilience module (`scripts/resilience.py`) provides:

- **Exponential Backoff:** 1s, 2s, 4s, 8s retry delays
- **Max Retries:** Up to 5 attempts per operation
- **Circuit Breaker Pattern:** Trips after 5 consecutive failures
- **Error Logging:** Full context capture for debugging
- **Degraded Mode:** Fallback values when all retries exhausted

## Usage

### Basic Retry with Exponential Backoff

```python
from scripts.resilience import retry_with_exponential_backoff

@retry_with_exponential_backoff(
    max_retries=5,
    backoff_sequence=[1, 2, 4, 8, 16]
)
def fetch_external_data():
    # API call that might fail
    response = requests.get("https://api.example.com/data")
    return response.json()
```

### Retry with Fallback (Degraded Mode)

```python
@retry_with_exponential_backoff(
    max_retries=5,
    fallback_value={"cached": True, "data": []}
)
def fetch_github_repos():
    # If all retries fail, return fallback value
    response = requests.get("https://api.github.com/repos")
    return response.json()
```

### Circuit Breaker Pattern

```python
from scripts.resilience import CircuitBreaker

# Create circuit breaker for a service
github_breaker = CircuitBreaker(
    name="github_api",
    failure_threshold=5,
    recovery_timeout=60
)

def call_github_api():
    return github_breaker.call(
        lambda: requests.get("https://api.github.com/repos")
    )
```

### Combined: Retry + Circuit Breaker

```python
@retry_with_exponential_backoff(
    max_retries=5,
    service_name="github_api"  # Uses circuit breaker
)
def fetch_github_data():
    response = requests.get("https://api.github.com/repos")
    return response.json()
```

### Error Logging with Context

```python
from scripts.resilience import log_dependency_error

try:
    data = fetch_external_api()
except Exception as e:
    log_dependency_error(
        service_name="github_api",
        operation="fetch_repos",
        error=e,
        context={"user": "jorge", "repo": "seven-fortunas"}
    )
```

## Features

### Exponential Backoff

Retry delays follow exponential backoff sequence:
- Attempt 1: Immediate
- Attempt 2: Wait 1s
- Attempt 3: Wait 2s
- Attempt 4: Wait 4s
- Attempt 5: Wait 8s
- Attempt 6: Wait 16s (if max_retries > 5)

**Why exponential backoff?**
- Gives transient failures time to resolve
- Reduces load on struggling services
- Industry standard for API rate limiting

### Circuit Breaker Pattern

**States:**
- **CLOSED** (normal): Requests pass through
- **OPEN** (failing): Requests fail immediately, no retry
- **HALF_OPEN** (testing): Limited requests to test recovery

**State Transitions:**
- CLOSED → OPEN: After 5 consecutive failures
- OPEN → HALF_OPEN: After 60 seconds recovery timeout
- HALF_OPEN → CLOSED: After 3 successful test requests
- HALF_OPEN → OPEN: If test request fails

**Benefits:**
- Prevents cascading failures
- Gives failing services time to recover
- Reduces unnecessary retry load
- Fails fast when service is down

### Error Logging

All failures logged with:
- Timestamp (ISO 8601)
- Service name
- Operation name
- Error type and message
- Attempt number
- Context (custom key-value pairs)

**Example log entry:**
```
2026-02-24T21:50:00Z [ERROR] resilience.github_api: Attempt 3/5 failed for fetch_repos: ConnectionError: Connection timeout | Context: user=jorge, repo=seven-fortunas
```

### Degraded Mode (Fallback)

When all retries exhausted, system can fall back to:
- **Cached data:** Return stale but valid data
- **Default values:** Empty list, null, or placeholder
- **Partial results:** Best-effort response
- **User notification:** Display "using cached data" message

## Integration

### AI Dashboard (FR-4.1)

Resilience integrated into dashboard update scripts:

```python
# dashboards/ai/scripts/update_ai_dashboard.py
from scripts.resilience import retry_with_exponential_backoff

@retry_with_exponential_backoff(
    max_retries=5,
    service_name="rss_feed",
    fallback_value=[]
)
def fetch_rss_feed(url):
    return feedparser.parse(url).entries
```

### Graceful Degradation (NFR-4.2)

Resilience module integrates with graceful degradation:
- Fallback values enable degraded mode
- Circuit breaker prevents cascading failures
- Error logs help diagnose systemic issues

### Uptime Monitoring

Error logs feed into uptime monitoring:
- Track dependency availability per service
- Alert on circuit breaker opens
- Identify patterns of transient vs permanent failures

## Configuration

### Default Settings

```python
# Max retries (NFR-6.2 requirement)
MAX_RETRIES = 5

# Backoff sequence (NFR-6.2 requirement: 1s, 2s, 4s, 8s)
BACKOFF_SEQUENCE = [1, 2, 4, 8, 16]

# Circuit breaker settings
FAILURE_THRESHOLD = 5  # Open after N failures
RECOVERY_TIMEOUT = 60  # Seconds before testing recovery
HALF_OPEN_MAX_CALLS = 3  # Test calls in half-open state
```

### Per-Service Customization

Override defaults for specific services:

```python
@retry_with_exponential_backoff(
    max_retries=3,  # Reddit API has strict rate limits
    backoff_sequence=[2, 4, 8],  # Slower backoff
    service_name="reddit_api"
)
def fetch_reddit_posts(subreddit):
    # ...
```

## Examples

### Example 1: RSS Feed Fetching

```python
from scripts.resilience import retry_with_exponential_backoff
import feedparser

@retry_with_exponential_backoff(
    max_retries=5,
    service_name="rss_feed",
    fallback_value={"entries": [], "cached": True}
)
def fetch_rss_feed(url):
    """Fetch RSS feed with retry and fallback"""
    feed = feedparser.parse(url)

    if feed.bozo:  # Feed parsing error
        raise Exception(f"Invalid RSS feed: {feed.bozo_exception}")

    return {
        "entries": feed.entries,
        "cached": False
    }

# Usage
feed_data = fetch_rss_feed("https://example.com/feed.xml")
if feed_data["cached"]:
    print("⚠ Using cached data (service unavailable)")
```

### Example 2: GitHub API with Circuit Breaker

```python
from scripts.resilience import retry_with_exponential_backoff
import requests

@retry_with_exponential_backoff(
    max_retries=5,
    service_name="github_api",
    fallback_value={"releases": [], "rate_limited": True}
)
def fetch_github_releases(repo):
    """Fetch GitHub releases with circuit breaker"""
    url = f"https://api.github.com/repos/{repo}/releases"
    response = requests.get(url, timeout=10)

    if response.status_code == 403:  # Rate limited
        raise Exception("GitHub API rate limit exceeded")
    elif response.status_code != 200:
        raise Exception(f"GitHub API error: {response.status_code}")

    return {
        "releases": response.json(),
        "rate_limited": False
    }
```

### Example 3: Reddit API with Logging

```python
from scripts.resilience import (
    retry_with_exponential_backoff,
    log_dependency_error
)
import requests

@retry_with_exponential_backoff(
    max_retries=3,  # Reddit is stricter
    backoff_sequence=[2, 4, 8],
    service_name="reddit_api"
)
def fetch_reddit_posts(subreddit):
    """Fetch Reddit posts with retry and logging"""
    url = f"https://www.reddit.com/r/{subreddit}/hot.json"
    headers = {"User-Agent": "7F Dashboard/1.0"}

    try:
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        return response.json()["data"]["children"]

    except Exception as e:
        # Log with context for debugging
        log_dependency_error(
            service_name="reddit_api",
            operation="fetch_posts",
            error=e,
            context={"subreddit": subreddit}
        )
        raise
```

## Testing

Run resilience module tests:

```bash
python3 scripts/resilience.py
```

This runs built-in examples demonstrating:
- Basic retry with exponential backoff
- Retry with fallback value
- Circuit breaker state transitions

## Troubleshooting

### Issue: All retries exhausted

**Symptoms:** Function returns fallback value or None

**Diagnosis:**
1. Check error logs for failure patterns
2. Verify external service is accessible
3. Check network connectivity and firewall rules
4. Verify API keys/credentials

**Solutions:**
- Fix external service issues
- Increase retry count (if transient failures)
- Adjust backoff sequence (if rate limited)
- Update fallback value to better degraded mode

### Issue: Circuit breaker stuck OPEN

**Symptoms:** Requests fail immediately without retry

**Diagnosis:**
1. Check circuit breaker logs
2. Verify when circuit opened (last_failure_time)
3. Check if recovery timeout elapsed

**Solutions:**
- Wait for recovery timeout (60s default)
- Fix underlying service issue
- Manually reset circuit breaker (development only)

### Issue: Too many retries causing slowness

**Symptoms:** Operations take too long to fail

**Diagnosis:**
1. Calculate total retry time: sum(backoff_sequence)
2. Check if services are consistently down

**Solutions:**
- Reduce max_retries for specific services
- Shorten backoff sequence
- Implement health checks before retries
- Use circuit breaker to fail fast

## Monitoring

### Circuit Breaker States

Monitor circuit breaker states across all services:

```bash
# Check circuit breaker status in logs
grep "Circuit breaker" logs/application.log | tail -20
```

### Retry Statistics

Track retry success rates:

```bash
# Count retry attempts per service
grep "Attempt" logs/application.log | cut -d' ' -f4 | sort | uniq -c
```

### Service Availability

Calculate service availability from logs:

```bash
# Success rate for specific service
grep "github_api" logs/application.log | \
  awk '/success/ {s++} /failure/ {f++} END {print s/(s+f)*100 "%"}'
```

---

**Implementation:** `scripts/resilience.py`
**Status:** Active (NFR-6.2)
**Maintained By:** Seven Fortunas Team
