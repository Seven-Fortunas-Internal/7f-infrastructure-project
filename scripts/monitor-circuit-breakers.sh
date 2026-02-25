#!/bin/bash
# Circuit Breaker Monitoring Dashboard
# Displays circuit breaker status across all external dependencies

source "$(dirname "$0")/lib/retry_with_backoff.sh"

echo "═══════════════════════════════════════════════════════"
echo "  Seven Fortunas Circuit Breaker Status Dashboard"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# Display circuit breaker state
echo "Circuit Breaker Status:"
echo "─────────────────────────────────────────────────────"
if [[ -f "$CIRCUIT_BREAKER_STATE" ]]; then
    get_circuit_breaker_stats | jq -r 'to_entries[] | "  \(.key): \(if .value.is_open then "🔴 OPEN (tripped at \(.value.tripped_at))" else "🟢 CLOSED (\(.value.consecutive_failures) consecutive failures)" end)"'
else
    echo "  No circuit breakers registered (all systems operational)"
fi
echo ""

# Display recent dependency errors
ERROR_LOG="/home/ladmin/dev/GDF/7F_github/logs/dependency_errors.log"
if [[ -f "$ERROR_LOG" ]]; then
    echo "Recent Dependency Errors (last 10):"
    echo "─────────────────────────────────────────────────────"
    tail -10 "$ERROR_LOG" 2>/dev/null || echo "  No errors recorded"
else
    echo "Recent Dependency Errors:"
    echo "─────────────────────────────────────────────────────"
    echo "  No errors recorded (log file not found)"
fi
echo ""

# Health summary
echo "Health Summary:"
echo "─────────────────────────────────────────────────────"
if [[ -f "$CIRCUIT_BREAKER_STATE" ]]; then
    OPEN_CIRCUITS=$(jq '[.[] | select(.is_open == true)] | length' "$CIRCUIT_BREAKER_STATE" 2>/dev/null || echo "0")
    TOTAL_CIRCUITS=$(jq 'length' "$CIRCUIT_BREAKER_STATE" 2>/dev/null || echo "0")

    if [[ "$OPEN_CIRCUITS" -eq 0 ]]; then
        echo "  ✓ All services operational ($TOTAL_CIRCUITS registered)"
    else
        echo "  ⚠️  $OPEN_CIRCUITS/$TOTAL_CIRCUITS services unavailable (circuit breakers open)"
        echo "  Action required: Investigate failing services"
    fi
else
    echo "  ✓ All services operational (no circuit breakers tripped)"
fi
echo ""

echo "═══════════════════════════════════════════════════════"
echo "Tip: Use scripts/lib/retry_with_backoff.sh to reset breakers"
echo "Integration: Integrates with NFR-4.2 (Graceful Degradation)"
echo "═══════════════════════════════════════════════════════"
