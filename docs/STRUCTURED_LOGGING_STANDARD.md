# Structured Logging Standard - Seven Fortunas Infrastructure

**Version:** 1.0
**Last Updated:** 2026-02-24
**Priority:** P1 (Critical)
**Status:** Active

---

## Overview

All Seven Fortunas systems SHALL emit structured logs in JSON format with consistent fields and severity levels. This standard ensures:

1. **Searchability** - Easy filtering and querying in log aggregation systems
2. **Consistency** - Uniform format across all components
3. **Debuggability** - Rich context for troubleshooting
4. **Compliance** - Audit trail for security and regulatory requirements

---

## Log Format Specification

### Required Fields

Every log entry MUST include these fields:

```json
{
  "timestamp": "2026-02-24T14:30:45.123Z",
  "severity": "INFO",
  "component": "dashboard-updater",
  "message": "AI dashboard updated successfully",
  "context": {
    "dashboard_id": "ai-advancements",
    "items_fetched": 15,
    "duration_ms": 342
  }
}
```

**Field Definitions:**

| Field | Type | Required | Description | Example |
|-------|------|----------|-------------|---------|
| `timestamp` | ISO 8601 string | Yes | UTC timestamp with millisecond precision | `2026-02-24T14:30:45.123Z` |
| `severity` | Enum | Yes | Log level (see severity levels below) | `INFO`, `ERROR`, `DEBUG` |
| `component` | String | Yes | System/service name | `dashboard-updater`, `gh-auth-check` |
| `message` | String | Yes | Human-readable description | `AI dashboard updated successfully` |
| `context` | Object | Yes | Structured metadata (varies by event) | `{"user_id": "123", "duration_ms": 342}` |

### Optional Fields

Include when applicable:

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `user_id` | String | GitHub username (for user-triggered actions) | `jorge-sefo` |
| `request_id` | String | Unique identifier for request tracing | `req_abc123xyz` |
| `error` | Object | Error details (for ERROR/FATAL logs) | `{"type": "APIError", "code": 429}` |
| `session_id` | String | Autonomous agent session ID | `session_2026-02-24_001` |
| `feature_id` | String | Feature being implemented (agent logs) | `FEATURE_015` |

---

## Severity Levels

Use these severity levels (in ascending order of importance):

| Level | When to Use | Examples | Action Required |
|-------|-------------|----------|-----------------|
| `DEBUG` | Detailed diagnostic information | Variable values, function entry/exit | None (disabled in production) |
| `INFO` | Normal operational events | Dashboard updated, skill invoked | None |
| `WARN` | Potentially harmful situations | API rate limit at 85%, retry attempt 2/3 | Monitor, may need investigation |
| `ERROR` | Error events that might still allow continued operation | API call failed (will retry), dashboard update partial | Investigate within 24h |
| `FATAL` | Severe errors causing termination | Circuit breaker triggered, unrecoverable auth failure | Immediate investigation required |

---

## Implementation Examples

### Bash Scripts

```bash
#!/bin/bash

# Function to emit structured log
log_json() {
  local severity="$1"
  local component="$2"
  local message="$3"
  local context="$4"  # JSON string

  cat <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)",
  "severity": "$severity",
  "component": "$component",
  "message": "$message",
  "context": $context
}
EOF
}

# Usage examples
log_json "INFO" "gh-auth-check" "GitHub authentication verified" '{"username": "jorge-sefo"}'
log_json "ERROR" "dashboard-updater" "Failed to fetch RSS feed" '{"url": "https://example.com/feed.xml", "error": "HTTP 404"}'
log_json "WARN" "api-client" "Rate limit approaching" '{"current": 4500, "limit": 5000, "percentage": 90}'
```

### Python Scripts

```python
import json
import logging
from datetime import datetime

class StructuredLogger:
    """Structured JSON logger for Seven Fortunas systems"""

    def __init__(self, component):
        self.component = component

    def _log(self, severity, message, context=None):
        log_entry = {
            "timestamp": datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%S.%f')[:-3] + 'Z',
            "severity": severity,
            "component": self.component,
            "message": message,
            "context": context or {}
        }
        print(json.dumps(log_entry))

    def debug(self, message, **context):
        self._log("DEBUG", message, context)

    def info(self, message, **context):
        self._log("INFO", message, context)

    def warn(self, message, **context):
        self._log("WARN", message, context)

    def error(self, message, **context):
        self._log("ERROR", message, context)

    def fatal(self, message, **context):
        self._log("FATAL", message, context)

# Usage example
logger = StructuredLogger("feature-implementer")

logger.info("Starting feature implementation",
            feature_id="FEATURE_015",
            approach="STANDARD")

logger.error("Feature test failed",
             feature_id="FEATURE_015",
             test="functional",
             error="HTTP 429: Rate limit exceeded")

logger.warn("Retrying with SIMPLIFIED approach",
            feature_id="FEATURE_015",
            attempt=2,
            max_attempts=3)
```

### JavaScript (Node.js)

```javascript
class StructuredLogger {
  constructor(component) {
    this.component = component;
  }

  _log(severity, message, context = {}) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      severity,
      component: this.component,
      message,
      context
    };
    console.log(JSON.stringify(logEntry));
  }

  info(message, context) { this._log('INFO', message, context); }
  warn(message, context) { this._log('WARN', message, context); }
  error(message, context) { this._log('ERROR', message, context); }
  debug(message, context) { this._log('DEBUG', message, context); }
  fatal(message, context) { this._log('FATAL', message, context); }
}

// Usage
const logger = new StructuredLogger('dashboard-server');

logger.info('Dashboard server started', {
  port: 3000,
  env: 'production'
});

logger.error('Failed to load dashboard data', {
  dashboard_id: 'ai-advancements',
  error: 'ECONNREFUSED'
});
```

---

## Context Field Guidelines

### Good Context Examples

**Dashboard Updates:**
```json
{
  "dashboard_id": "ai-advancements",
  "items_fetched": 15,
  "items_new": 3,
  "duration_ms": 342,
  "data_sources": ["github_releases", "rss_feeds", "claude_api"]
}
```

**Feature Implementation:**
```json
{
  "feature_id": "FEATURE_015",
  "approach": "STANDARD",
  "attempt": 1,
  "verification_status": "pass",
  "duration_seconds": 45
}
```

**API Calls:**
```json
{
  "method": "GET",
  "url": "/api/repos/Seven-Fortunas/dashboards",
  "status_code": 200,
  "response_time_ms": 123,
  "rate_limit_remaining": 4850
}
```

**Error Events:**
```json
{
  "error_type": "RateLimitError",
  "error_code": 429,
  "retry_after_seconds": 3600,
  "request_id": "req_xyz789",
  "stack_trace": "..."
}
```

### What NOT to Include in Context

❌ **Secrets:** API keys, tokens, passwords
❌ **PII:** Email addresses (use user_id instead), phone numbers
❌ **Large payloads:** Full API responses (summarize instead)
❌ **Binary data:** Images, files (log metadata only)

---

## Validation

### Log Format Validator (Python)

```python
import json
import sys

def validate_log_entry(log_line):
    """Validate a single log entry against the standard"""
    try:
        entry = json.loads(log_line)
    except json.JSONDecodeError:
        return False, "Invalid JSON"

    # Check required fields
    required = ['timestamp', 'severity', 'component', 'message', 'context']
    for field in required:
        if field not in entry:
            return False, f"Missing required field: {field}"

    # Check severity level
    valid_severities = ['DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL']
    if entry['severity'] not in valid_severities:
        return False, f"Invalid severity: {entry['severity']}"

    # Check timestamp format (basic check)
    if not entry['timestamp'].endswith('Z'):
        return False, "Timestamp must be in UTC (end with Z)"

    # Check context is an object
    if not isinstance(entry['context'], dict):
        return False, "Context must be a JSON object"

    return True, "Valid"

# Usage
if __name__ == '__main__':
    for line in sys.stdin:
        valid, message = validate_log_entry(line.strip())
        if not valid:
            print(f"INVALID: {message}", file=sys.stderr)
            print(f"  Line: {line.strip()}", file=sys.stderr)
```

**Usage:**
```bash
cat logfile.jsonl | python3 validate_logs.py
```

---

## Integration with Existing Systems

### GitHub Actions Workflows

```yaml
name: Dashboard Update

on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - name: Update AI Dashboard
        run: |
          # Emit structured log on start
          echo '{"timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","severity":"INFO","component":"gh-actions-dashboard-update","message":"Starting dashboard update","context":{"workflow":"dashboard-update","dashboard":"ai-advancements"}}' >> logs/workflow.jsonl

          # Run update script (should emit structured logs)
          ./scripts/update_ai_dashboard.sh

          # Emit structured log on completion
          echo '{"timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","severity":"INFO","component":"gh-actions-dashboard-update","message":"Dashboard update completed","context":{"workflow":"dashboard-update","status":"success"}}' >> logs/workflow.jsonl
```

### Autonomous Agent Logs

The autonomous agent (`agent.py`) SHOULD emit structured logs for:

- Session start/end
- Feature selection
- Implementation attempts
- Test results
- Circuit breaker events

Example:
```json
{
  "timestamp": "2026-02-24T14:30:45Z",
  "severity": "INFO",
  "component": "autonomous-agent",
  "message": "Feature implementation started",
  "context": {
    "session_id": "session_2026-02-24_001",
    "feature_id": "FEATURE_015",
    "approach": "STANDARD",
    "attempt": 1
  }
}
```

---

## Monitoring & Alerting

### Log Aggregation

**Recommended tools:**
- GitHub Actions logs (built-in)
- CloudWatch Logs (AWS)
- Datadog (SaaS)
- ELK Stack (self-hosted)

**Query examples (conceptual):**

```
# Find all errors in last 24 hours
severity:ERROR AND timestamp:[now-24h TO now]

# Find dashboard update failures
component:"dashboard-updater" AND severity:ERROR

# Find high API usage
context.rate_limit_remaining:<100

# Find circuit breaker triggers
message:"Circuit breaker triggered"
```

### Alert Rules

Create alerts for:

1. **High error rate:** >5 ERROR logs per hour
2. **Fatal errors:** Any FATAL log
3. **Circuit breaker:** Any "Circuit breaker triggered" message
4. **Rate limits:** context.rate_limit_percentage > 90

---

## Compliance

### SOC 2 Requirements

Structured logging supports SOC 2 compliance by providing:

- **Audit trail:** All system events logged with timestamp
- **Incident response:** Error logs for security events
- **Change management:** Logs of configuration changes
- **Access control:** Logs of authentication/authorization events

### Retention Policy

- **INFO/DEBUG logs:** Retain 30 days
- **WARN/ERROR logs:** Retain 90 days
- **FATAL logs:** Retain 1 year
- **Security events:** Retain 7 years (compliance requirement)

---

## Migration Plan

### Phase 1: Immediate (Week 1)
- [ ] Deploy logging utilities (bash, python, js)
- [ ] Update autonomous agent to emit structured logs
- [ ] Update dashboard update scripts

### Phase 2: Short-term (Week 2-4)
- [ ] Add structured logging to all GitHub Actions workflows
- [ ] Create log validation script
- [ ] Configure log aggregation (GitHub Actions artifacts)

### Phase 3: Long-term (Month 2+)
- [ ] Integrate with external log aggregation service
- [ ] Create alerting rules
- [ ] Build log analysis dashboard

---

## Success Criteria

NFR-8.1 is satisfied when:

1. ✅ All system components emit JSON-formatted logs
2. ✅ Logs include all required fields (timestamp, severity, component, message, context)
3. ✅ 100% of logs pass validation script
4. ✅ Spot-check confirms consistent format across systems
5. ✅ Documentation exists for developers (this document)

---

**Owner:** Jorge (VP AI-SecOps)
**Review Date:** 2026-03-24 (monthly review)
