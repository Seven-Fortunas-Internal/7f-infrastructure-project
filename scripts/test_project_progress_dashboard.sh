#!/bin/bash
# Test script for FEATURE_031: Project Progress Dashboard

set -e

PROJECT_DIR="/home/ladmin/dev/GDF/7F_github"
cd "$PROJECT_DIR"

echo "============================================================"
echo "Testing FEATURE_031: Project Progress Dashboard"
echo "============================================================"
echo

TESTS_PASSED=0
TESTS_FAILED=0

# Test 1: Dashboard structure
echo "Test 1: Dashboard structure exists"
echo "------------------------------------------------------------"

if [ -d "dashboards/project-progress" ]; then
    echo "✓ Dashboard directory exists"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Dashboard directory missing"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

REQUIRED_DIRS=("scripts" "data" "templates")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "dashboards/project-progress/$dir" ]; then
        echo "✓ Subdirectory: $dir"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ Missing subdirectory: $dir"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done

echo

# Test 2: README documentation
echo "Test 2: README documentation"
echo "------------------------------------------------------------"

if [ -f "dashboards/project-progress/README.md" ]; then
    echo "✓ README.md exists"
    TESTS_PASSED=$((TESTS_PASSED + 1))

    SECTIONS=("Metrics Collected" "Data Collection" "Integration with 7F Lens" "Phase 2 Implementation Plan")
    for section in "${SECTIONS[@]}"; do
        if grep -q "$section" "dashboards/project-progress/README.md"; then
            echo "✓ Section: $section"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo "✗ Missing section: $section"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    done
else
    echo "✗ README.md missing"
    TESTS_FAILED=$((TESTS_FAILED + 5))
fi

echo

# Test 3: Scripts created
echo "Test 3: Dashboard scripts"
echo "------------------------------------------------------------"

SCRIPTS=("update_dashboard.py" "generate_ai_summary.py")
for script in "${SCRIPTS[@]}"; do
    if [ -f "dashboards/project-progress/scripts/$script" ]; then
        echo "✓ Script: $script"
        TESTS_PASSED=$((TESTS_PASSED + 1))

        if [ -x "dashboards/project-progress/scripts/$script" ]; then
            echo "  Executable: yes"
        else
            echo "  ⚠ Not executable"
        fi
    else
        echo "✗ Missing script: $script"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done

echo

# Test 4: Metrics documented
echo "Test 4: Metrics documentation"
echo "------------------------------------------------------------"

METRICS=("Sprint Velocity" "Feature Completion Rate" "Burndown Chart" "Active Blockers" "Team Utilization")
for metric in "${METRICS[@]}"; do
    if grep -q "$metric" "dashboards/project-progress/README.md"; then
        echo "✓ Metric: $metric"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ Missing metric: $metric"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done

echo

# Test 5: Data format defined
echo "Test 5: Data format (project-progress-latest.json)"
echo "------------------------------------------------------------"

if [ -f "dashboards/project-progress/data/project-progress-latest.json" ]; then
    echo "✓ Sample data file exists"
    TESTS_PASSED=$((TESTS_PASSED + 1))

    # Validate JSON
    if jq empty "dashboards/project-progress/data/project-progress-latest.json" 2>/dev/null; then
        echo "✓ Valid JSON format"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ Invalid JSON"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    # Check required fields
    FIELDS=("sprint_velocity" "feature_completion" "burndown" "blockers" "team_utilization")
    for field in "${FIELDS[@]}"; do
        if jq -e ".$field" "dashboards/project-progress/data/project-progress-latest.json" >/dev/null 2>&1; then
            echo "✓ Field: $field"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo "✗ Missing field: $field"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    done
else
    echo "✗ Sample data file missing"
    TESTS_FAILED=$((TESTS_FAILED + 7))
fi

echo

# Test 6: Integration with 7F Lens
echo "Test 6: 7F Lens integration"
echo "------------------------------------------------------------"

if grep -q "7F Lens" "dashboards/project-progress/README.md"; then
    echo "✓ 7F Lens integration documented"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ 7F Lens integration not documented"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

if grep -q "Dashboard #2" "dashboards/project-progress/README.md"; then
    echo "✓ Dashboard positioned as #2 in 7F Lens"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Dashboard position not documented"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo

# Test 7: Dependencies documented
echo "Test 7: Dependencies and integrations"
echo "------------------------------------------------------------"

if grep -q "FR-8.1" "dashboards/project-progress/README.md" || \
   grep -q "Sprint Management" "dashboards/project-progress/README.md"; then
    echo "✓ References FR-8.1 (Sprint Management)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Missing FR-8.1 reference"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

if grep -q "FR-4.1" "dashboards/project-progress/README.md" || \
   grep -q "AI Advancements Dashboard" "dashboards/project-progress/README.md"; then
    echo "✓ References FR-4.1 (AI Dashboard)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Missing FR-4.1 reference"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo

# Summary
echo "============================================================"
TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
echo "Test Results: $TESTS_PASSED/$TOTAL_TESTS passed"

if [ "$TESTS_FAILED" -eq 0 ]; then
    echo "============================================================"
    echo "VALIDATION: PASS"
    echo "============================================================"
    echo
    echo "✓ Dashboard structure created (scripts, data, templates)"
    echo "✓ README with comprehensive documentation"
    echo "✓ All 5 metrics documented (velocity, completion, burndown, blockers, utilization)"
    echo "✓ Data format defined (project-progress-latest.json)"
    echo "✓ Scripts created (update_dashboard.py, generate_ai_summary.py)"
    echo "✓ 7F Lens integration documented (Dashboard #2)"
    echo "✓ Dependencies referenced (FR-8.1, FR-4.1)"
    echo
    echo "Project Progress Dashboard ready for Phase 2 implementation."
    echo "============================================================"
    exit 0
else
    echo "============================================================"
    echo "VALIDATION: FAIL"
    echo "============================================================"
    echo
    echo "✗ $TESTS_FAILED tests failed"
    echo "  Review failures above and address missing components"
    echo "============================================================"
    exit 1
fi
