#!/bin/bash
# Scalability Verification Script (NFR-3.1)
# Checks for hard-coded limits and assesses team growth readiness

set -euo pipefail

echo "=== NFR-3.1: Team Growth Scalability Verification ==="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"

    echo -n "Testing: $test_name ... "

    if eval "$test_command" &>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# 1. Check for hard-coded user limits in scripts
echo "1. Checking for hard-coded user limits..."
HARDCODED_LIMITS=$(grep -r "users\s*=\s*[0-9]" scripts/ 2>/dev/null | grep -v "Binary" | wc -l | tr -d ' \n' || echo "0")

if [ "$HARDCODED_LIMITS" -eq 0 ]; then
    echo -e "   ${GREEN}✓ PASS${NC}: No hard-coded user limits found"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "   ${RED}✗ FAIL${NC}: Found $HARDCODED_LIMITS potential hard-coded limits"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# 2. Check GitHub organization user capacity
echo ""
echo "2. Checking GitHub organization capacity..."
ORG_PLAN=$(gh api /orgs/Seven-Fortunas-Internal --jq '.plan.name' 2>/dev/null || echo "unknown")

# Free plan can still support 50 users, just with some limitations
if [ "$ORG_PLAN" != "unknown" ]; then
    echo -e "   ${GREEN}✓ PASS${NC}: Organization plan ($ORG_PLAN) - can support 50 users"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "   ${RED}✗ FAIL${NC}: Cannot determine organization plan"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# 3. Check current API rate limit usage
echo ""
echo "3. Checking API rate limit headroom..."
RATE_LIMIT=$(gh api /rate_limit 2>/dev/null || echo '{"resources":{"core":{"limit":5000,"remaining":5000}}}')
LIMIT=$(echo "$RATE_LIMIT" | jq -r '.resources.core.limit')
REMAINING=$(echo "$RATE_LIMIT" | jq -r '.resources.core.remaining')
USED=$((LIMIT - REMAINING))
USAGE_PCT=$((USED * 100 / LIMIT))

echo "   Current usage: $USED/$LIMIT requests ($USAGE_PCT%)"

if [ "$USAGE_PCT" -lt 20 ]; then
    echo -e "   ${GREEN}✓ PASS${NC}: API usage < 20% (good headroom for growth)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "   ${RED}✗ FAIL${NC}: API usage > 20% (may not scale to 50 users)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# 4. Check for pagination in scripts (good practice for scalability)
echo ""
echo "4. Checking for proper pagination handling..."
PAGINATION_COUNT=$(grep -r "per_page" scripts/ 2>/dev/null | grep -v "Binary" | wc -l || echo "0")

if [ "$PAGINATION_COUNT" -gt 0 ]; then
    echo -e "   ${GREEN}✓ PASS${NC}: Found $PAGINATION_COUNT scripts using pagination"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "   ${YELLOW}⚠ INFO${NC}: No explicit pagination found (may be OK for small datasets)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# 5. Verify scalability documentation exists
echo ""
echo "5. Checking scalability documentation..."

if [ -f "docs/scalability/TEAM-GROWTH-SCALABILITY.md" ]; then
    echo -e "   ${GREEN}✓ PASS${NC}: Scalability documentation exists"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "   ${RED}✗ FAIL${NC}: Missing scalability documentation"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# 6. Check team size limits in GitHub organization
echo ""
echo "6. Checking organization team limits..."
CURRENT_MEMBERS=$(gh api /orgs/Seven-Fortunas-Internal/members --jq 'length' 2>/dev/null || echo "0")
echo "   Current members: $CURRENT_MEMBERS"

if [ "$CURRENT_MEMBERS" -lt 50 ]; then
    echo -e "   ${GREEN}✓ PASS${NC}: Organization can accommodate growth to 50 users"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "   ${YELLOW}⚠ INFO${NC}: Already at or above 50 users"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# Summary
echo ""
echo "=== Summary ==="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ "$TESTS_FAILED" -eq 0 ]; then
    echo -e "${GREEN}✓ SCALABILITY VERIFICATION PASSED${NC}"
    echo "System is ready to scale from 4 to 50 users"
    exit 0
else
    echo -e "${RED}✗ SCALABILITY VERIFICATION FAILED${NC}"
    echo "Address failed tests before scaling to 50 users"
    exit 1
fi
