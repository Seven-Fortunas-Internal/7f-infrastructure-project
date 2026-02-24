#!/usr/bin/env bash
# configure_teams.sh
# Creates and configures GitHub teams for Seven Fortunas organizations

set -euo pipefail

# Constants
PUBLIC_ORG="Seven-Fortunas"
PRIVATE_ORG="Seven-Fortunas-Internal"
LOG_FILE="${LOG_FILE:-/tmp/github_team_setup.log}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log actions
log_action() {
    local message="$1"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[${timestamp}] ${message}" | tee -a "${LOG_FILE}"
}

# Function to check if team exists
check_team_exists() {
    local org="$1"
    local team_slug="$2"
    if gh api "orgs/${org}/teams/${team_slug}" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to create team
create_team() {
    local org="$1"
    local team_name="$2"
    local description="$3"
    local privacy="${4:-closed}"  # closed or secret

    echo -e "${BLUE}Creating team: ${team_name} in ${org}${NC}"

    # Convert team name to slug
    local team_slug
    team_slug=$(echo "${team_name}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

    if check_team_exists "${org}" "${team_slug}"; then
        echo -e "${GREEN}✓ Team ${team_name} already exists${NC}"
        log_action "TEAM_EXISTS: ${org}/${team_slug}"
        return 0
    fi

    # Create team using GitHub API
    if gh api "orgs/${org}/teams" \
        -X POST \
        -f name="${team_name}" \
        -f description="${description}" \
        -f privacy="${privacy}" \
        &>/dev/null; then
        echo -e "${GREEN}✓ Created team: ${team_name}${NC}"
        log_action "TEAM_CREATED: ${org}/${team_slug}"
        return 0
    else
        echo -e "${RED}✗ Failed to create team: ${team_name}${NC}"
        log_action "TEAM_CREATION_FAILED: ${org}/${team_slug}"
        return 1
    fi
}

# Function to add member to team
add_team_member() {
    local org="$1"
    local team_slug="$2"
    local username="$3"
    local role="${4:-member}"  # member or maintainer

    # Check if user exists first
    if ! gh api "users/${username}" &>/dev/null; then
        echo -e "${YELLOW}⚠ User ${username} does not exist on GitHub${NC}"
        log_action "USER_NOT_FOUND: ${username}"
        return 1
    fi

    # Add member to team
    if gh api "orgs/${org}/teams/${team_slug}/memberships/${username}" \
        -X PUT \
        -f role="${role}" \
        &>/dev/null; then
        echo -e "${GREEN}✓ Added ${username} to ${team_slug} as ${role}${NC}"
        log_action "MEMBER_ADDED: ${org}/${team_slug}/${username} (${role})"
        return 0
    else
        echo -e "${RED}✗ Failed to add ${username} to ${team_slug}${NC}"
        log_action "MEMBER_ADD_FAILED: ${org}/${team_slug}/${username}"
        return 1
    fi
}

# Validate GitHub authentication
echo -e "${YELLOW}Validating GitHub authentication...${NC}"
if ! ./scripts/validate_github_auth.sh; then
    echo -e "${RED}ERROR: GitHub authentication validation failed${NC}"
    log_action "TEAM_SETUP_FAILED: Authentication validation failed"
    exit 1
fi
echo -e "${GREEN}✓ GitHub authentication validated${NC}"
log_action "TEAM_SETUP_START: Authentication validated"

# Validate organizations exist
echo ""
echo -e "${YELLOW}Validating organizations...${NC}"
if ! gh api "orgs/${PUBLIC_ORG}" &>/dev/null; then
    echo -e "${RED}ERROR: ${PUBLIC_ORG} organization does not exist${NC}"
    echo "Run ./scripts/create_github_orgs.sh first"
    log_action "TEAM_SETUP_FAILED: ${PUBLIC_ORG} not found"
    exit 1
fi

if ! gh api "orgs/${PRIVATE_ORG}" &>/dev/null; then
    echo -e "${RED}ERROR: ${PRIVATE_ORG} organization does not exist${NC}"
    echo "Run ./scripts/create_github_orgs.sh first"
    log_action "TEAM_SETUP_FAILED: ${PRIVATE_ORG} not found"
    exit 1
fi
echo -e "${GREEN}✓ Both organizations validated${NC}"

# Create teams for PUBLIC organization
echo ""
echo -e "${BLUE}=== Creating teams for ${PUBLIC_ORG} ===${NC}"

create_team "${PUBLIC_ORG}" "Public BD" "Business Development and Partnerships" "closed"
create_team "${PUBLIC_ORG}" "Public Marketing" "Marketing, Communications, and Community Outreach" "closed"
create_team "${PUBLIC_ORG}" "Public Engineering" "Public Open Source Engineering" "closed"
create_team "${PUBLIC_ORG}" "Public Operations" "Public Operations and Infrastructure" "closed"
create_team "${PUBLIC_ORG}" "Public Community" "Community Management and Support" "closed"

# Create teams for PRIVATE organization
echo ""
echo -e "${BLUE}=== Creating teams for ${PRIVATE_ORG} ===${NC}"

create_team "${PRIVATE_ORG}" "BD" "Business Development Team" "closed"
create_team "${PRIVATE_ORG}" "Marketing" "Marketing and Growth Team" "closed"
create_team "${PRIVATE_ORG}" "Engineering" "Engineering and Product Development" "closed"
create_team "${PRIVATE_ORG}" "Finance" "Finance and Administration" "closed"
create_team "${PRIVATE_ORG}" "Operations" "Operations and Infrastructure" "closed"

# Add founding team members (example - adjust based on actual GitHub usernames)
echo ""
echo -e "${BLUE}=== Adding founding team members ===${NC}"
echo "Note: Team member assignment requires valid GitHub usernames"
echo "Edit this script to add actual founding member usernames"

# Example (commented out - uncomment and adjust usernames as needed):
# add_team_member "${PRIVATE_ORG}" "engineering" "jorge-at-sf" "maintainer"
# add_team_member "${PRIVATE_ORG}" "operations" "jorge-at-sf" "maintainer"
# add_team_member "${PRIVATE_ORG}" "bd" "buck-github" "member"
# add_team_member "${PRIVATE_ORG}" "marketing" "patrick-github" "member"
# add_team_member "${PRIVATE_ORG}" "finance" "henry-github" "member"

echo ""
echo -e "${GREEN}✓ Team structure setup complete${NC}"
log_action "TEAM_SETUP_SUCCESS: All teams created"

echo ""
echo "To add team members, use:"
echo "  gh api orgs/ORG/teams/TEAM_SLUG/memberships/USERNAME -X PUT -f role=member"
echo ""

exit 0
