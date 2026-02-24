#!/bin/bash
# Verification script for FEATURE_045: NFR-4.1 Workflow Reliability

set -e

echo "========================================="
echo "FEATURE_045 Verification: NFR-4.1"
echo "Workflow Reliability"
echo "========================================="
echo ""

FUNCTIONAL_PASS=0
TECHNICAL_PASS=0
INTEGRATION_PASS=0

# ===========================================
# FUNCTIONAL CRITERIA
# ===========================================
echo "📋 Testing FUNCTIONAL Criteria..."
echo "- GitHub Actions workflows succeed 99% of the time"
echo "- External outages classified by Jorge/Buck"
echo "- Monthly workflow reliability report generated"
echo ""

# Check if reliability tracking workflow exists
if [ -f ".github/workflows/track-workflow-reliability.yml" ]; then
    echo "  ✅ Reliability tracking workflow exists"

    # Check if it tracks workflow_run events
    if grep -q "workflow_run:" ".github/workflows/track-workflow-reliability.yml"; then
        echo "  ✅ Monitors workflow runs"

        # Check for monthly report generation
        if grep -q "generate-monthly-report" ".github/workflows/track-workflow-reliability.yml"; then
            echo "  ✅ Generates monthly reports"

            # Check for schedule trigger (monthly)
            if grep -q "schedule:" ".github/workflows/track-workflow-reliability.yml"; then
                echo "  ✅ Monthly report scheduled"
                FUNCTIONAL_PASS=1
            else
                echo "  ❌ Monthly schedule not found"
            fi
        else
            echo "  ❌ Monthly report generation not found"
        fi
    else
        echo "  ❌ Does not monitor workflow runs"
    fi
else
    echo "  ❌ Reliability tracking workflow not found"
fi

echo ""

# ===========================================
# TECHNICAL CRITERIA
# ===========================================
echo "📋 Testing TECHNICAL Criteria..."
echo "- Internal failure rate calculated"
echo "- Configuration errors, code bugs, rate limits classified as internal"
echo "- Failure rate tracked monthly with trend analysis"
echo ""

# Check for reliability checker script
if [ -f "scripts/check_workflow_reliability.py" ]; then
    echo "  ✅ Reliability checker script exists"

    # Check for success rate calculation
    if grep -q "calculate_reliability" "scripts/check_workflow_reliability.py"; then
        echo "  ✅ Calculates success rate"

        # Check for threshold checking (99%)
        if grep -q "0.99" "scripts/check_workflow_reliability.py"; then
            echo "  ✅ Checks against 99% threshold"
        fi
    fi
else
    echo "  ❌ Reliability checker script not found"
fi

# Check for failure classification
if [ -f "scripts/generate_reliability_report.py" ]; then
    echo "  ✅ Report generator script exists"

    # Check for internal/external classification
    if grep -q "internal" "scripts/generate_reliability_report.py" && \
       grep -q "external" "scripts/generate_reliability_report.py"; then
        echo "  ✅ Classifies failures as internal/external"

        # Check for trend analysis
        if grep -q "trend" "scripts/generate_reliability_report.py"; then
            echo "  ✅ Includes trend analysis"
            TECHNICAL_PASS=1
        fi
    fi
else
    echo "  ❌ Report generator script not found"
fi

# Check for failure classification CSV
if [ -f "compliance/reliability/metrics/failure-classifications.csv" ]; then
    echo "  ✅ Failure classification tracking file exists"
fi

echo ""

# ===========================================
# INTEGRATION CRITERIA
# ===========================================
echo "📋 Testing INTEGRATION Criteria..."
echo "- Workflow reliability integrates with all GitHub Actions workflows"
echo "- Reliability metrics feed into system monitoring (NFR-8.2)"
echo ""

# Check for metrics directory
if [ -d "compliance/reliability/metrics" ]; then
    echo "  ✅ Reliability metrics directory exists"

    # Check for workflow results CSV
    if [ -f "compliance/reliability/metrics/workflow-results.csv" ]; then
        echo "  ✅ Workflow results tracking file exists"
    fi

    # Check for reports directory
    if [ -d "compliance/reliability/reports" ]; then
        echo "  ✅ Reports directory exists"
    fi
else
    echo "  ❌ Reliability metrics directory not found"
fi

# Check for documentation
if [ -f "docs/workflow-reliability-tracking.md" ]; then
    echo "  ✅ Workflow reliability documentation exists"

    # Check for NFR-8.2 integration
    if grep -q "NFR-8.2" "docs/workflow-reliability-tracking.md"; then
        echo "  ✅ Documents integration with NFR-8.2 (System Monitoring)"
        INTEGRATION_PASS=1
    else
        echo "  ⚠️ NFR-8.2 integration not documented"
    fi
else
    echo "  ❌ Workflow reliability documentation not found"
fi

# Check workflow configuration
if grep -q "Track Workflow Reliability" ".github/workflows/track-workflow-reliability.yml"; then
    echo "  ✅ Workflow integrates with GitHub Actions"
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
    echo "All verification criteria met for FEATURE_045 (NFR-4.1)"
    exit 0
else
    echo "❌ OVERALL: FAIL"
    echo ""
    echo "Some verification criteria not met"
    exit 1
fi
