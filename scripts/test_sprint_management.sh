#!/bin/bash
# Test script for FEATURE_029: Sprint Management
#
# Verifies:
# 1. Sprint management guide documented
# 2. BMAD sprint workflows accessible
# 3. Sprint management scripts created
# 4. Flexible terminology supported (technical and business)
# 5. Integration points defined

set -e

PROJECT_DIR="/home/ladmin/dev/GDF/7F_github"
cd "$PROJECT_DIR"

echo "============================================================"
echo "Testing FEATURE_029: Sprint Management"
echo "============================================================"
echo

TESTS_PASSED=0
TESTS_FAILED=0

# Test 1: Sprint management guide exists
echo "Test 1: Sprint management documentation"
echo "------------------------------------------------------------"

if [ -f "docs/sprint-management-guide.md" ]; then
    echo "✓ Sprint management guide exists"
    TESTS_PASSED=$((TESTS_PASSED + 1))

    # Check for key sections
    SECTIONS=("Sprint Structure" "BMAD Sprint Workflows" "Flexible Terminology" "Sprint Metrics" "GitHub Projects Integration")

    for section in "${SECTIONS[@]}"; do
        if grep -q "$section" "docs/sprint-management-guide.md"; then
            echo "✓ Section present: $section"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo "✗ Section missing: $section"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    done
else
    echo "✗ Sprint management guide missing"
    TESTS_FAILED=$((TESTS_FAILED + 6))
fi

echo

# Test 2: BMAD sprint workflows accessible
echo "Test 2: BMAD sprint workflows"
echo "------------------------------------------------------------"

if [ -f "_bmad/bmm/workflows/4-implementation/sprint-planning/sprint-status-template.yaml" ]; then
    echo "✓ BMAD sprint template exists"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ BMAD sprint template missing"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Check for BMAD sprint skills in .claude/commands/
if ls .claude/commands/bmad-*sprint* 2>/dev/null | grep -q .; then
    echo "✓ BMAD sprint skills available"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "⚠ No BMAD sprint skills found (may need to be created)"
fi

echo

# Test 3: Sprint management scripts created
echo "Test 3: Sprint management scripts"
echo "------------------------------------------------------------"

SCRIPTS=(
    "sync_sprint_to_github.py"
    "generate_burndown.py"
    "calculate_velocity.py"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "scripts/sprint-management/$script" ]; then
        echo "✓ $script exists"
        TESTS_PASSED=$((TESTS_PASSED + 1))

        if [ -x "scripts/sprint-management/$script" ]; then
            echo "  Executable: yes"
        else
            echo "  ⚠ Not executable"
        fi
    else
        echo "✗ $script missing"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done

echo

# Test 4: Flexible terminology support
echo "Test 4: Flexible terminology (Technical vs Business)"
echo "------------------------------------------------------------"

if grep -q "Engineering Projects" "docs/sprint-management-guide.md" && \
   grep -q "Business Projects" "docs/sprint-management-guide.md"; then
    echo "✓ Both engineering and business terminology documented"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Missing terminology definitions"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

if grep -q "PRD → Epic → Story → Sprint" "docs/sprint-management-guide.md"; then
    echo "✓ Engineering hierarchy documented"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Engineering hierarchy missing"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

if grep -q "Initiative → Objective → Task → Sprint" "docs/sprint-management-guide.md"; then
    echo "✓ Business hierarchy documented"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Business hierarchy missing"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo

# Test 5: Sprint metrics defined
echo "Test 5: Sprint metrics and tracking"
echo "------------------------------------------------------------"

METRICS=("Velocity Tracking" "Completion Rate" "Burndown Chart")

for metric in "${METRICS[@]}"; do
    if grep -q "$metric" "docs/sprint-management-guide.md"; then
        echo "✓ $metric defined"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ $metric not defined"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done

echo

# Test 6: GitHub Projects integration
echo "Test 6: GitHub Projects integration"
echo "------------------------------------------------------------"

if grep -q "GitHub Projects Integration" "docs/sprint-management-guide.md"; then
    echo "✓ GitHub Projects integration documented"
    TESTS_PASSED=$((TESTS_PASSED + 1))

    if grep -q "Board Setup" "docs/sprint-management-guide.md"; then
        echo "✓ Board setup described"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ Board setup missing"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    if grep -q "Sprint Board Views" "docs/sprint-management-guide.md"; then
        echo "✓ Board views described"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ Board views missing"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
else
    echo "✗ GitHub Projects integration not documented"
    TESTS_FAILED=$((TESTS_FAILED + 3))
fi

echo

# Test 7: Integration with dashboards
echo "Test 7: Dashboard integration points"
echo "------------------------------------------------------------"

if grep -q "Sprint Dashboard (FR-8.2)" "docs/sprint-management-guide.md"; then
    echo "✓ Sprint Dashboard integration defined"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Sprint Dashboard integration missing"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

if grep -q "Project Progress Dashboard (FR-8.3)" "docs/sprint-management-guide.md"; then
    echo "✓ Project Progress Dashboard integration defined"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Project Progress Dashboard integration missing"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo

# Test 8: Phase 2 pilot planning
echo "Test 8: Phase 2 pilot (Business project fit)"
echo "------------------------------------------------------------"

if grep -q "Phase 2 Pilot" "docs/sprint-management-guide.md"; then
    echo "✓ Phase 2 pilot documented"
    TESTS_PASSED=$((TESTS_PASSED + 1))

    if grep -q "Test Scenarios" "docs/sprint-management-guide.md"; then
        echo "✓ Test scenarios defined"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ Test scenarios missing"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    if grep -q "Success Criteria" "docs/sprint-management-guide.md"; then
        echo "✓ Success criteria defined"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ Success criteria missing"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
else
    echo "✗ Phase 2 pilot not documented"
    TESTS_FAILED=$((TESTS_FAILED + 3))
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
    echo "✓ Sprint management guide comprehensive and complete"
    echo "✓ BMAD sprint workflows accessible"
    echo "✓ Sprint management scripts created (Phase 2 placeholders)"
    echo "✓ Flexible terminology for engineering and business projects"
    echo "✓ Sprint metrics (velocity, burndown, completion rate) defined"
    echo "✓ GitHub Projects integration documented"
    echo "✓ Dashboard integration points defined"
    echo "✓ Phase 2 pilot planned for business project validation"
    echo
    echo "Sprint management system ready for Phase 2 implementation."
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
