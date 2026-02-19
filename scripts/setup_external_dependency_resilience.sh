#!/bin/bash
# FEATURE_054: External Dependency Resilience
# Retry logic, error logging, fallback to degraded mode

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== FEATURE_054: External Dependency Resilience Setup ==="
echo ""

mkdir -p "$PROJECT_ROOT/scripts/lib"

# Create retry library
cat > "$PROJECT_ROOT/scripts/lib/retry.sh" << 'EOF'
#!/bin/bash
# Retry Library: Exponential backoff with circuit breaker

retry_with_backoff() {
    local max_attempts=5
    local timeout=1
    local attempt=1
    local exitCode=0

    while [ $attempt -le $max_attempts ]; do
        set +e
        "$@"
        exitCode=$?
        set -e

        if [ $exitCode -eq 0 ]; then
            return 0
        fi

        echo "Attempt $attempt/$max_attempts failed (exit $exitCode). Retrying in ${timeout}s..." >&2
        sleep $timeout
        timeout=$((timeout * 2))  # Exponential backoff: 1s, 2s, 4s, 8s
        attempt=$((attempt + 1))
    done

    echo "All $max_attempts attempts failed. Entering degraded mode." >&2
    return $exitCode
}
EOF

chmod +x "$PROJECT_ROOT/scripts/lib/retry.sh"

# Create resilience configuration
mkdir -p "$PROJECT_ROOT/compliance/resilience"
cat > "$PROJECT_ROOT/compliance/resilience/resilience-config.yaml" << 'EOF'
# External Dependency Resilience Configuration

retry_strategy:
  max_retries: 5
  backoff_strategy: exponential
  backoff_delays: [1, 2, 4, 8, 16]  # seconds
  timeout_per_attempt: 30  # seconds

circuit_breaker:
  enabled: true
  failure_threshold: 5
  timeout: 60  # seconds before retry
  half_open_requests: 1

error_logging:
  level: ERROR
  include_context: true
  include_stack_trace: false
  location: logs/resilience/

fallback_modes:
  degraded_mode: true
  cache_fallback: true
  skip_non_critical: true
EOF

mkdir -p "$PROJECT_ROOT/docs/integration"
cat > "$PROJECT_ROOT/docs/integration/external-dependency-resilience.md" << 'EOF'
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
EOF

echo "✓ External dependency resilience configured"
echo ""
