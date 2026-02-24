#!/bin/bash
# Test script for FEATURE_030: Sprint Dashboard
#
# Verifies:
# 1. 7f-sprint-dashboard skill created
# 2. Sprint dashboard script implemented
# 3. GitHub Projects setup documented
# 4. Integration with sprint management
# 5. API access documented

set -e

PROJECT_DIR="/home/ladmin/dev/GDF/7F_github"
cd "$PROJECT_DIR"

echo "============================================================"
echo "Testing FEATURE_030: Sprint Dashboard"
echo "============================================================"
echo

TESTS_PASSED=0
TESTS_FAILED=0

# Test 1: Skill file exists
echo "Test 1: 7f-sprint-dashboard skill"
echo "------------------------------------------------------------"

if [ -f ".claude/commands/7f-sprint-dashboard.md" ]; then
    echo "✓ 7f-sprint-dashboard skill file exists"
    TESTS_PASSED=$((TESTS_PASSED + 1))

    # Check for key sections
    if grep -q "## Usage" ".claude/commands/7f-sprint-dashboard.md"; then
        echo "✓ Usage section present"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ Usage section missing"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    if grep -q "## Examples" ".claude/commands/7f-sprint-dashboard.md"; then
        echo "✓ Examples section present"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ Examples section missing"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
else
    echo "✗ 7f-sprint-dashboard skill file missing"
    TESTS_FAILED=$((TESTS_FAILED + 3))
fi

echo

# Test 2: Sprint dashboard script
echo "Test 2: Sprint dashboard implementation"
echo "------------------------------------------------------------"

if [ -f "scripts/sprint-management/sprint_dashboard.py" ]; then
    echo "✓ sprint_dashboard.py exists"
    TESTS_PASSED=$((TESTS_PASSED + 1))

    if [ -x "scripts/sprint-management/sprint_dashboard.py" ]; then
        echo "✓ Script is executable"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ Script is not executable"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    # Test script runs without error (help output)
    if python3 scripts/sprint-management/sprint_dashboard.py --help >/dev/null 2>&1; then
        echo "✓ Script runs without error"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ Script has syntax errors"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    # Check for command handlers
    COMMANDS=("status" "update" "velocity" "burndown")
    for cmd in "${COMMANDS[@]}"; do
        if grep -q "def cmd_$cmd" "scripts/sprint-management/sprint_dashboard.py"; then
            echo "✓ Command handler: $cmd"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo "✗ Missing handler: $cmd"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    done
else
    echo "✗ sprint_dashboard.py missing"
    TESTS_FAILED=$((TESTS_FAILED + 7))
fi

echo

# Test 3: GitHub Projects setup documentation
echo "Test 3: GitHub Projects setup guide"
echo "------------------------------------------------------------"

if [ -f "docs/github-projects-setup.md" ]; then
    echo "✓ GitHub Projects setup guide exists"
    TESTS_PASSED=$((TESTS_PASSED + 1))

    # Check for key sections
    SECTIONS=("Setup Steps" "Configure Custom Fields" "Create Board Views" "API Access")

    for section in "${SECTIONS[@]}"; do
        if grep -q "$section" "docs/github-projects-setup.md"; then
            echo "✓ Section: $section"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo "✗ Missing section: $section"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    done
else
    echo "✗ GitHub Projects setup guide missing"
    TESTS_FAILED=$((TESTS_FAILED + 5))
fi

echo

# Test 4: Custom fields documented
echo "Test 4: GitHub Projects custom fields"
echo "------------------------------------------------------------"

REQUIRED_FIELDS=("Sprint" "Story Points" "Priority" "Status")

for field in "${REQUIRED_FIELDS[@]}"; do
    if grep -q "$field" "docs/github-projects-setup.md"; then
        echo "✓ Field documented: $field"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ Field missing: $field"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done

echo

# Test 5: API integration documented
echo "Test 5: GitHub Projects API integration"
echo "------------------------------------------------------------"

if grep -q "GraphQL" "docs/github-projects-setup.md"; then
    echo "✓ GraphQL API documented"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ GraphQL API not documented"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

if grep -q "Personal Access Token" "docs/github-projects-setup.md"; then
    echo "✓ Access token setup documented"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Access token setup missing"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

if grep -q "query {" "docs/github-projects-setup.md"; then
    echo "✓ GraphQL query examples included"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ GraphQL query examples missing"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo

# Test 6: Integration with sprint management
echo "Test 6: Sprint management integration"
echo "------------------------------------------------------------"

if grep -q "FR-8.1" ".claude/commands/7f-sprint-dashboard.md" || \
   grep -q "sprint-management-guide" ".claude/commands/7f-sprint-dashboard.md"; then
    echo "✓ References sprint management (FR-8.1)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Missing sprint management reference"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

if grep -q "Sprint Management" "docs/github-projects-setup.md"; then
    echo "✓ Sprint management integration documented"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Sprint management integration missing"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo

# Test 7: Board views documented
echo "Test 7: Board views configuration"
echo "------------------------------------------------------------"

VIEWS=("Current Sprint Board" "Sprint Backlog" "Burndown Chart" "Velocity Trends")

for view in "${VIEWS[@]}"; do
    if grep -q "$view" "docs/github-projects-setup.md"; then
        echo "✓ View documented: $view"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ View missing: $view"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done

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
    echo "✓ 7f-sprint-dashboard skill created and documented"
    echo "✓ Sprint dashboard script implemented (Phase 2 placeholder)"
    echo "✓ GitHub Projects setup guide comprehensive"
    echo "✓ Custom fields documented (Sprint, Story Points, Priority, Status)"
    echo "✓ GraphQL API integration documented with examples"
    echo "✓ Integration with sprint management (FR-8.1) established"
    echo "✓ Board views documented (Current Sprint, Backlog, Burndown, Velocity)"
    echo
    echo "Sprint dashboard ready for Phase 2 implementation."
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
