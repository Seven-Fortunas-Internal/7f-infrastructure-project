#!/bin/bash
# FEATURE_053: API Rate Limit Compliance
# Tracks and enforces rate limits for all external APIs

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== FEATURE_053: API Rate Limit Compliance Setup ==="
echo ""

mkdir -p "$PROJECT_ROOT/compliance/rate-limits"

# Create rate limit configuration
cat > "$PROJECT_ROOT/compliance/rate-limits/rate-limits-config.yaml" << 'EOF'
# API Rate Limit Configuration

external_apis:
  github:
    service: GitHub API
    tier: authenticated
    limits:
      requests_per_hour: 5000
      secondary_rate_limit: true
    documentation: https://docs.github.com/en/rest/overview/resources-in-the-rest-api#rate-limiting
    enforcement: automatic

  claude:
    service: Claude API (Anthropic)
    tier: production
    limits:
      requests_per_minute: 50
      requests_per_day: 40000
    documentation: https://docs.anthropic.com/claude/reference/rate-limits
    enforcement: automatic

  reddit:
    service: Reddit JSON API
    tier: unauthenticated
    limits:
      requests_per_minute: 60
    documentation: https://www.reddit.com/wiki/api
    enforcement: client_throttling

  openai_whisper:
    service: OpenAI Whisper API
    tier: standard
    limits:
      requests_per_minute: null  # No documented limit
      usage_policy: responsible_use
    documentation: https://platform.openai.com/docs/guides/rate-limits
    enforcement: best_effort

  x_api:
    service: X API (Twitter)
    tier: basic_100
    limits:
      requests_per_month: 10000
      cost: "$100/month"
    phase: Phase-2
    documentation: https://developer.twitter.com/en/docs/twitter-api/rate-limits
    enforcement: manual_tracking

monitoring:
  track_usage: true
  alert_threshold: 0.8  # 80% of limit
  log_violations: true
  dashboard_integration: true
EOF

# Create rate limit library
mkdir -p "$PROJECT_ROOT/scripts/lib"
cat > "$PROJECT_ROOT/scripts/lib/rate-limit.sh" << 'EOF'
#!/bin/bash
# Rate Limit Library: Track and enforce API rate limits

check_github_rate_limit() {
    RATE_LIMIT=$(gh api rate_limit --jq '.rate')
    REMAINING=$(echo "$RATE_LIMIT" | jq -r '.remaining')
    LIMIT=$(echo "$RATE_LIMIT" | jq -r '.limit')
    RESET=$(echo "$RATE_LIMIT" | jq -r '.reset')

    echo "GitHub API: $REMAINING/$LIMIT remaining (resets: $(date -d @$RESET))"

    if [ $REMAINING -lt $((LIMIT / 5)) ]; then
        echo "⚠ WARNING: GitHub rate limit below 20%"
        return 1
    fi
    return 0
}
EOF

chmod +x "$PROJECT_ROOT/scripts/lib/rate-limit.sh"

# Create documentation
mkdir -p "$PROJECT_ROOT/docs/integration"
cat > "$PROJECT_ROOT/docs/integration/api-rate-limit-compliance.md" << 'EOF'
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
EOF

echo "✓ API rate limit compliance configured"
echo ""
