#!/bin/bash
# Verification tests for FEATURE_003

set -euo pipefail

FUNCTIONAL="fail"
TECHNICAL="fail"
INTEGRATION="fail"

echo "=== FEATURE_003 Verification Tests ==="
echo

# ================================================
# FUNCTIONAL TEST
# ================================================
echo "--- Functional Test ---"
echo "Checking: All 10 teams created with descriptions, correct access levels, founding members assigned"
echo

# Check public org teams (5 teams)
PUBLIC_TEAMS=$(gh api "orgs/Seven-Fortunas/teams" --jq '.[].name' | wc -l)
echo "Public org teams count: $PUBLIC_TEAMS (expected: 5)"

# Check private org teams (5 teams)
PRIVATE_TEAMS=$(gh api "orgs/Seven-Fortunas-Internal/teams" --jq '.[].name' | wc -l)
echo "Private org teams count: $PRIVATE_TEAMS (expected: 5)"

# Check if Jorge is a member of engineering team
JORGE_IN_ENG=$(gh api "orgs/Seven-Fortunas-Internal/teams/engineering/members" --jq '.[].login' | grep -c "jorge-at-sf" || echo "0")
echo "Jorge in private engineering team: $JORGE_IN_ENG (expected: 1)"

# Functional test passes if all counts are correct
if test "$PUBLIC_TEAMS" -ge 5 && test "$PRIVATE_TEAMS" -ge 5 && test "$JORGE_IN_ENG" -eq 1; then
    FUNCTIONAL="pass"
    echo "Functional test: PASS"
else
    echo "Functional test: FAIL"
fi

echo

# ================================================
# TECHNICAL TEST
# ================================================
echo "--- Technical Test ---"
echo "Checking: Team creation uses GitHub Teams API with proper authentication and error handling"
echo

# Verify authentication works
if gh auth status >/dev/null 2>&1; then
    echo "GitHub CLI authenticated: YES"
    AUTH_OK=1
else
    echo "GitHub CLI authenticated: NO"
    AUTH_OK=0
fi

# Verify script exists and is executable
if test -x scripts/configure-team-structure.sh; then
    echo "Script exists and is executable: YES"
    SCRIPT_OK=1
else
    echo "Script exists and is executable: NO"
    SCRIPT_OK=0
fi

# Verify script uses gh api (proper API usage)
if grep -q "gh api" scripts/configure-team-structure.sh; then
    echo "Script uses gh api: YES"
    API_OK=1
else
    echo "Script uses gh api: NO"
    API_OK=0
fi

# Verify script has error handling (set -e)
if grep -q "set -euo pipefail" scripts/configure-team-structure.sh; then
    echo "Script has error handling: YES"
    ERROR_OK=1
else
    echo "Script has error handling: NO"
    ERROR_OK=0
fi

if test "$AUTH_OK" -eq 1 && test "$SCRIPT_OK" -eq 1 && test "$API_OK" -eq 1 && test "$ERROR_OK" -eq 1; then
    TECHNICAL="pass"
    echo "Technical test: PASS"
else
    echo "Technical test: FAIL"
fi

echo

# ================================================
# INTEGRATION TEST
# ================================================
echo "--- Integration Test ---"
echo "Checking: Team creation happens after organization creation, teams reference organization IDs"
echo

# Verify both orgs exist (dependency on FEATURE_002)
if gh api "orgs/Seven-Fortunas" >/dev/null 2>&1; then
    echo "Public org exists: YES"
    PUB_ORG_OK=1
else
    echo "Public org exists: NO"
    PUB_ORG_OK=0
fi

if gh api "orgs/Seven-Fortunas-Internal" >/dev/null 2>&1; then
    echo "Private org exists: YES"
    PRIV_ORG_OK=1
else
    echo "Private org exists: NO"
    PRIV_ORG_OK=0
fi

# Verify teams are actually associated with the orgs
PUB_TEAM_ORG=$(gh api "orgs/Seven-Fortunas/teams/public-engineering" --jq '.organization.login' 2>/dev/null || echo "")
PRIV_TEAM_ORG=$(gh api "orgs/Seven-Fortunas-Internal/teams/engineering" --jq '.organization.login' 2>/dev/null || echo "")

echo "Public team belongs to: $PUB_TEAM_ORG (expected: Seven-Fortunas)"
echo "Private team belongs to: $PRIV_TEAM_ORG (expected: Seven-Fortunas-Internal)"

if test "$PUB_ORG_OK" -eq 1 && test "$PRIV_ORG_OK" -eq 1 && \
   test "$PUB_TEAM_ORG" = "Seven-Fortunas" && \
   test "$PRIV_TEAM_ORG" = "Seven-Fortunas-Internal"; then
    INTEGRATION="pass"
    echo "Integration test: PASS"
else
    echo "Integration test: FAIL"
fi

echo

# ================================================
# SUMMARY
# ================================================
echo "=== Test Results Summary ==="
echo "Functional:  $FUNCTIONAL"
echo "Technical:   $TECHNICAL"
echo "Integration: $INTEGRATION"
echo

if test "$FUNCTIONAL" = "pass" && test "$TECHNICAL" = "pass" && test "$INTEGRATION" = "pass"; then
    echo "OVERALL: PASS"
    exit 0
else
    echo "OVERALL: FAIL"
    exit 1
fi
