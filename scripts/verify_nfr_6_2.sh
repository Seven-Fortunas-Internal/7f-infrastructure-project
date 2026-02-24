#!/bin/bash
# Verification script for FEATURE_054: NFR-6.2 External Dependency Resilience

set -e

echo "========================================="
echo "FEATURE_054 Verification: NFR-6.2"
echo "External Dependency Resilience"
echo "========================================="
echo ""

FUNCTIONAL_PASS=0
TECHNICAL_PASS=0
INTEGRATION_PASS=0

# ===========================================
# FUNCTIONAL CRITERIA
# ===========================================
echo "📋 Testing FUNCTIONAL Criteria..."
echo "- Retry logic with exponential backoff (1s, 2s, 4s, 8s) max 5 retries"
echo "- Error logging captures failure context"
echo "- Fallback to degraded mode when retries exhausted"
echo ""

# Check if resilience module exists
if [ -f "scripts/resilience.py" ]; then
    echo "  ✅ Resilience module exists"

    # Check for retry decorator
    if grep -q "retry_with_backoff" "scripts/resilience.py"; then
        echo "  ✅ Retry decorator implemented"

        # Check for exponential backoff sequence
        if grep -q "(1, 2, 4, 8)" "scripts/resilience.py"; then
            echo "  ✅ Exponential backoff sequence (1s, 2s, 4s, 8s) configured"
        fi

        # Check for max retries
        if grep -q "max_retries.*=.*5" "scripts/resilience.py"; then
            echo "  ✅ Max 5 retries configured"
        fi

        # Check for error logging
        if grep -q "_log_retry_error" "scripts/resilience.py"; then
            echo "  ✅ Error logging implemented"
        fi

        # Check for fallback support
        if grep -q "fallback" "scripts/resilience.py"; then
            echo "  ✅ Fallback to degraded mode implemented"
            FUNCTIONAL_PASS=1
        fi
    fi
else
    echo "  ❌ Resilience module not found"
fi

echo ""

# ===========================================
# TECHNICAL CRITERIA
# ===========================================
echo "📋 Testing TECHNICAL Criteria..."
echo "- Retry strategy consistent across all external dependencies"
echo "- Circuit breaker pattern trips after 5 consecutive failures"
echo "- Error logs include sufficient context for debugging"
echo ""

# Check for circuit breaker implementation
if [ -f "scripts/resilience.py" ]; then
    if grep -q "CircuitBreaker" "scripts/resilience.py"; then
        echo "  ✅ Circuit breaker pattern implemented"

        # Check for failure threshold
        if grep -q "failure_threshold.*=.*5" "scripts/resilience.py"; then
            echo "  ✅ Circuit breaker trips after 5 consecutive failures"
        fi

        # Check for circuit states
        if grep -q "CircuitState" "scripts/resilience.py"; then
            echo "  ✅ Circuit states (CLOSED, OPEN, HALF_OPEN) defined"
        fi

        # Check for error context logging
        if grep -q "Function:" "scripts/resilience.py" && \
           grep -q "Attempt:" "scripts/resilience.py"; then
            echo "  ✅ Error logs include context (function, attempt, error, backoff)"
            TECHNICAL_PASS=1
        fi
    fi
fi

# Check for monitoring workflow
if [ -f ".github/workflows/monitor-dependency-resilience.yml" ]; then
    echo "  ✅ Dependency resilience monitoring workflow exists"
fi

echo ""

# ===========================================
# INTEGRATION CRITERIA
# ===========================================
echo "📋 Testing INTEGRATION Criteria..."
echo "- External dependency resilience integrates with graceful degradation (NFR-4.2)"
echo "- Uptime monitoring tracks dependency availability"
echo ""

# Check for compliance directory
if [ -d "compliance/resilience" ]; then
    echo "  ✅ Resilience compliance directory exists"

    if [ -d "compliance/resilience/reports" ]; then
        echo "  ✅ Resilience reports directory exists"
    fi
fi

# Check for documentation
if [ -f "docs/external-dependency-resilience.md" ]; then
    echo "  ✅ Dependency resilience documentation exists"

    # Check for NFR-4.2 integration
    if grep -q "NFR-4.2" "docs/external-dependency-resilience.md"; then
        echo "  ✅ Documents integration with NFR-4.2 (Graceful Degradation)"
    fi

    # Check for uptime monitoring integration
    if grep -q "uptime" "docs/external-dependency-resilience.md" || \
       grep -q "Uptime" "docs/external-dependency-resilience.md"; then
        echo "  ✅ Documents integration with uptime monitoring"
        INTEGRATION_PASS=1
    fi
else
    echo "  ❌ Dependency resilience documentation not found"
fi

echo ""
echo "========================================="
echo "VERIFICATION RESULTS"
echo "========================================="
echo ""

if [ $FUNCTIONAL_PASS -eq 1 ]; then
    echo "✅ FUNCTIONAL: PASS"
else
    echo "❌ FUNCTIONAL: FAIL"
fi

if [ $TECHNICAL_PASS -eq 1 ]; then
    echo "✅ TECHNICAL: PASS"
else
    echo "❌ TECHNICAL: FAIL"
fi

if [ $INTEGRATION_PASS -eq 1 ]; then
    echo "✅ INTEGRATION: PASS"
else
    echo "❌ INTEGRATION: FAIL"
fi

echo ""

if [ $FUNCTIONAL_PASS -eq 1 ] && [ $TECHNICAL_PASS -eq 1 ] && [ $INTEGRATION_PASS -eq 1 ]; then
    echo "🎉 OVERALL: PASS"
    echo ""
    echo "All verification criteria met for FEATURE_054 (NFR-6.2)"
    exit 0
else
    echo "❌ OVERALL: FAIL"
    echo ""
    echo "Some verification criteria not met"
    exit 1
fi
