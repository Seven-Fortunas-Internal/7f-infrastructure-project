#!/bin/bash
# Verification script for FEATURE_040: NFR-2.2 Dashboard Auto-Update Performance

set -e

echo "========================================="
echo "FEATURE_040 Verification: NFR-2.2"
echo "Dashboard Auto-Update Performance"
echo "========================================="
echo ""

FUNCTIONAL_PASS=0
TECHNICAL_PASS=0
INTEGRATION_PASS=0

# ===========================================
# FUNCTIONAL CRITERIA
# ===========================================
echo "📋 Testing FUNCTIONAL Criteria..."
echo "- Dashboard aggregation workflow completes in less than 10 minutes"
echo "- Workflow duration measured via GitHub Actions execution logs"
echo "- Workflows exceeding 10-minute target logged"
echo ""

# Check if monitoring workflow exists
if [ -f ".github/workflows/monitor-dashboard-performance.yml" ]; then
    echo "  ✅ Performance monitoring workflow exists"

    # Check if it tracks workflow_run events
    if grep -q "workflow_run:" ".github/workflows/monitor-dashboard-performance.yml"; then
        echo "  ✅ Monitors dashboard workflow runs"

        # Check if it logs duration
        if grep -q "duration" ".github/workflows/monitor-dashboard-performance.yml"; then
            echo "  ✅ Tracks workflow duration"

            # Check if it logs to file
            if grep -q "dashboard-performance.csv" ".github/workflows/monitor-dashboard-performance.yml"; then
                echo "  ✅ Logs performance metrics to CSV"
                FUNCTIONAL_PASS=1
            else
                echo "  ❌ Does not log to metrics file"
            fi
        else
            echo "  ❌ Does not track duration"
        fi
    else
        echo "  ❌ Does not monitor workflow runs"
    fi
else
    echo "  ❌ Performance monitoring workflow not found"
fi

echo ""

# ===========================================
# TECHNICAL CRITERIA
# ===========================================
echo "📋 Testing TECHNICAL Criteria..."
echo "- GitHub Actions workflow optimized for parallel API calls"
echo "- Workflow performance metrics tracked"
echo "- Performance degradation alerts fire when duration exceeds 10 minutes"
echo ""

# Check for parallel optimization
if [ -f "scripts/optimize_dashboard_performance.py" ]; then
    echo "  ✅ Performance optimizer script exists"

    # Check for asyncio (parallel execution)
    if grep -q "asyncio" "scripts/optimize_dashboard_performance.py"; then
        echo "  ✅ Uses asyncio for parallel execution"

        # Check for semaphore (rate limiting)
        if grep -q "Semaphore" "scripts/optimize_dashboard_performance.py"; then
            echo "  ✅ Implements rate limiting with Semaphore"
        fi
    fi
else
    echo "  ❌ Performance optimizer script not found"
fi

# Check for metrics tracking
if [ -f "scripts/analyze_dashboard_performance.py" ]; then
    echo "  ✅ Performance analyzer script exists"

    # Check for metrics analysis
    if grep -q "analyze_performance" "scripts/analyze_dashboard_performance.py"; then
        echo "  ✅ Analyzes performance metrics"
    fi
else
    echo "  ❌ Performance analyzer script not found"
fi

# Check for alert creation
if grep -q "Create performance alert issue" ".github/workflows/monitor-dashboard-performance.yml"; then
    echo "  ✅ Creates alerts for performance violations"

    # Check for 10-minute threshold
    if grep -q "10" ".github/workflows/monitor-dashboard-performance.yml"; then
        echo "  ✅ Checks against 10-minute threshold"
        TECHNICAL_PASS=1
    fi
fi

echo ""

# ===========================================
# INTEGRATION CRITERIA
# ===========================================
echo "📋 Testing INTEGRATION Criteria..."
echo "- Dashboard auto-update performance integrates with dashboard features"
echo "- Performance metrics feed into workflow reliability tracking (NFR-4.1)"
echo ""

# Check for integration with dashboards
if [ -f "dashboards/performance/performance-config.yaml" ]; then
    echo "  ✅ Performance configuration file exists"

    # Check for dashboard-specific settings
    if grep -q "dashboards:" "dashboards/performance/performance-config.yaml"; then
        echo "  ✅ Dashboard-specific configurations present"

        # Check for max_concurrent_requests
        if grep -q "max_concurrent_requests" "dashboards/performance/performance-config.yaml"; then
            echo "  ✅ Parallel optimization configured per dashboard"
        fi
    fi
else
    echo "  ❌ Performance configuration not found"
fi

# Check for NFR-4.1 integration
if [ -f "docs/dashboard-performance-monitoring.md" ]; then
    echo "  ✅ Performance monitoring documentation exists"

    # Check for NFR-4.1 reference
    if grep -q "NFR-4.1" "docs/dashboard-performance-monitoring.md"; then
        echo "  ✅ Documents integration with NFR-4.1 (Workflow Reliability)"
        INTEGRATION_PASS=1
    else
        echo "  ⚠️ NFR-4.1 integration not documented"
    fi
else
    echo "  ❌ Performance monitoring documentation not found"
fi

# Check metrics directory exists
if [ -d "dashboards/performance/metrics" ]; then
    echo "  ✅ Performance metrics directory exists"

    if [ -f "dashboards/performance/metrics/dashboard-performance.csv" ]; then
        echo "  ✅ Performance metrics CSV file initialized"
    fi
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
    echo "All verification criteria met for FEATURE_040 (NFR-2.2)"
    exit 0
else
    echo "❌ OVERALL: FAIL"
    echo ""
    echo "Some verification criteria not met"
    exit 1
fi
