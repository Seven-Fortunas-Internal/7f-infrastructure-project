#!/bin/bash
# FEATURE_003: FR-1.2 - Configure Team Structure
# Creates 10 teams (5 per org) representing functional areas

set -euo pipefail

# Color output for readability
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== FEATURE_003: Configuring Team Structure ==="
echo

# Function to create a team
create_team() {
    local org=$1
    local team_name=$2
    local description=$3
    local privacy=$4  # secret or closed
    local permission=$5  # pull, push, admin

    echo -n "Creating team '$team_name' in $org... "

    # Check if team already exists
    if gh api "orgs/$org/teams/$team_name" &>/dev/null; then
        echo -e "${YELLOW}ALREADY EXISTS${NC}"
        return 0
    fi

    # Create team
    if gh api --method POST "orgs/$org/teams" \
        -f name="$team_name" \
        -f description="$description" \
        -f privacy="$privacy" \
        -f permission="$permission" &>/dev/null; then
        echo -e "${GREEN}CREATED${NC}"
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        return 1
    fi
}

# Function to add member to team
add_team_member() {
    local org=$1
    local team_slug=$2
    local username=$3

    echo -n "  Adding $username to $team_slug... "

    # Check if member already in team
    if gh api "orgs/$org/teams/$team_slug/memberships/$username" &>/dev/null; then
        echo -e "${YELLOW}ALREADY MEMBER${NC}"
        return 0
    fi

    # Add member (role: member or maintainer)
    if gh api --method PUT "orgs/$org/teams/$team_slug/memberships/$username" \
        -f role="member" &>/dev/null; then
        echo -e "${GREEN}ADDED${NC}"
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        return 1
    fi
}

# ================================================
# PUBLIC ORGANIZATION: Seven-Fortunas
# ================================================
echo "--- Public Organization: Seven-Fortunas ---"
echo

create_team "Seven-Fortunas" "public-bd" \
    "Business Development team for public-facing initiatives" \
    "closed" "push"

create_team "Seven-Fortunas" "public-marketing" \
    "Marketing and outreach for Seven Fortunas brand" \
    "closed" "push"

create_team "Seven-Fortunas" "public-engineering" \
    "Engineering team for open-source projects" \
    "closed" "push"

create_team "Seven-Fortunas" "public-operations" \
    "Operations and infrastructure for public services" \
    "closed" "push"

create_team "Seven-Fortunas" "public-community" \
    "Community management and engagement" \
    "closed" "pull"

echo

# ================================================
# PRIVATE ORGANIZATION: Seven-Fortunas-Internal
# ================================================
echo "--- Private Organization: Seven-Fortunas-Internal ---"
echo

create_team "Seven-Fortunas-Internal" "bd" \
    "Business Development - internal strategy and partnerships" \
    "secret" "push"

create_team "Seven-Fortunas-Internal" "marketing" \
    "Marketing - internal campaigns and brand strategy" \
    "secret" "push"

create_team "Seven-Fortunas-Internal" "engineering" \
    "Engineering - core development and infrastructure" \
    "secret" "push"

create_team "Seven-Fortunas-Internal" "finance" \
    "Finance - budget, accounting, and financial operations" \
    "secret" "push"

create_team "Seven-Fortunas-Internal" "operations" \
    "Operations - internal processes and systems" \
    "secret" "push"

echo

# ================================================
# ASSIGN FOUNDING MEMBERS
# ================================================
echo "--- Assigning Founding Members ---"
echo

# Jorge (jorge-at-sf) - VP AI-SecOps
echo "Jorge (jorge-at-sf):"
add_team_member "Seven-Fortunas-Internal" "engineering" "jorge-at-sf"
add_team_member "Seven-Fortunas-Internal" "operations" "jorge-at-sf"
add_team_member "Seven-Fortunas" "public-engineering" "jorge-at-sf"

# TODO: Add Buck, Patrick, Henry when GitHub usernames are confirmed
# Buck - COO
# add_team_member "Seven-Fortunas-Internal" "operations" "buck-username"
# add_team_member "Seven-Fortunas-Internal" "bd" "buck-username"

# Patrick - CTO
# add_team_member "Seven-Fortunas-Internal" "engineering" "patrick-username"
# add_team_member "Seven-Fortunas" "public-engineering" "patrick-username"

# Henry - CPO
# add_team_member "Seven-Fortunas-Internal" "marketing" "henry-username"
# add_team_member "Seven-Fortunas" "public-marketing" "henry-username"

echo
echo -e "${GREEN}=== Team Structure Configuration Complete ===${NC}"
echo

# Verification
echo "--- Verification ---"
echo "Public org teams:"
gh api "orgs/Seven-Fortunas/teams" --jq '.[].name' | sort

echo
echo "Private org teams:"
gh api "orgs/Seven-Fortunas-Internal/teams" --jq '.[].name' | sort

echo
echo "Done."
