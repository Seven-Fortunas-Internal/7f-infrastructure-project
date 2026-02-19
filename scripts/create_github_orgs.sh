#!/usr/bin/env bash
# create_github_orgs.sh
# Creates GitHub organizations for Seven Fortunas project
# NOTE: Organization creation requires manual steps via GitHub web interface
# This script documents the process and validates org creation

set -euo pipefail

# Constants
PUBLIC_ORG="Seven-Fortunas"
PRIVATE_ORG="Seven-Fortunas-Internal"
LOG_FILE="${LOG_FILE:-/tmp/github_org_creation.log}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to log actions
log_action() {
    local message="$1"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[${timestamp}] ${message}" | tee -a "${LOG_FILE}"
}

# Function to check if org exists
check_org_exists() {
    local org_name="$1"
    if gh api "orgs/${org_name}" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Validate GitHub authentication first
echo -e "${YELLOW}Validating GitHub authentication...${NC}"
if ! ./scripts/validate_github_auth.sh; then
    echo -e "${RED}ERROR: GitHub authentication validation failed${NC}"
    log_action "ORG_CREATION_FAILED: Authentication validation failed"
    exit 1
fi
echo -e "${GREEN}✓ GitHub authentication validated${NC}"
log_action "ORG_CREATION_START: Authentication validated"

# Check if organizations already exist
echo ""
echo "Checking for existing organizations..."

PUBLIC_EXISTS=false
PRIVATE_EXISTS=false

if check_org_exists "${PUBLIC_ORG}"; then
    echo -e "${GREEN}✓ ${PUBLIC_ORG} organization exists${NC}"
    PUBLIC_EXISTS=true
else
    echo -e "${YELLOW}⚠ ${PUBLIC_ORG} organization does not exist${NC}"
fi

if check_org_exists "${PRIVATE_ORG}"; then
    echo -e "${GREEN}✓ ${PRIVATE_ORG} organization exists${NC}"
    PRIVATE_EXISTS=true
else
    echo -e "${YELLOW}⚠ ${PRIVATE_ORG} organization does not exist${NC}"
fi

# If both exist, we're done
if [[ "${PUBLIC_EXISTS}" == "true" && "${PRIVATE_EXISTS}" == "true" ]]; then
    echo ""
    echo -e "${GREEN}✓ Both organizations exist. Validating configuration...${NC}"
    log_action "ORG_VALIDATION: Both organizations exist"

    # Validate org profiles
    echo "Validating organization profiles..."

    # Check public org
    public_profile=$(gh api "orgs/${PUBLIC_ORG}" 2>/dev/null || echo "{}")
    public_name=$(echo "${public_profile}" | jq -r '.name // "N/A"')
    public_desc=$(echo "${public_profile}" | jq -r '.description // "N/A"')

    echo "  ${PUBLIC_ORG}:"
    echo "    Name: ${public_name}"
    echo "    Description: ${public_desc}"

    # Check private org
    private_profile=$(gh api "orgs/${PRIVATE_ORG}" 2>/dev/null || echo "{}")
    private_name=$(echo "${private_profile}" | jq -r '.name // "N/A"')
    private_desc=$(echo "${private_profile}" | jq -r '.description // "N/A"')

    echo "  ${PRIVATE_ORG}:"
    echo "    Name: ${private_name}"
    echo "    Description: ${private_desc}"

    log_action "ORG_VALIDATION_SUCCESS: Both organizations configured"
    exit 0
fi

# Organizations need to be created
echo ""
echo -e "${YELLOW}=== GitHub Organization Creation Required ===${NC}"
echo ""
echo "GitHub organizations cannot be created via API in free/team plans."
echo "Organizations must be created manually through the GitHub web interface."
echo ""
echo "Steps to create organizations:"
echo ""

if [[ "${PUBLIC_EXISTS}" == "false" ]]; then
    echo "1. Create PUBLIC organization: ${PUBLIC_ORG}"
    echo "   a. Go to https://github.com/organizations/new"
    echo "   b. Organization name: ${PUBLIC_ORG}"
    echo "   c. Contact email: (your email)"
    echo "   d. Organization type: Free"
    echo "   e. Click 'Create organization'"
    echo ""
    echo "   After creation, configure profile:"
    echo "   - Go to https://github.com/orgs/${PUBLIC_ORG}/settings/profile"
    echo "   - Display name: Seven Fortunas"
    echo "   - Description: AI-Native Enterprise Infrastructure for Modern SecOps"
    echo "   - Website: https://seven-fortunas.com (or your domain)"
    echo "   - Email: contact@seven-fortunas.com (or your email)"
    echo "   - Location: (optional)"
    echo "   - Upload logo (optional)"
    echo ""
fi

if [[ "${PRIVATE_EXISTS}" == "false" ]]; then
    echo "2. Create PRIVATE organization: ${PRIVATE_ORG}"
    echo "   a. Go to https://github.com/organizations/new"
    echo "   b. Organization name: ${PRIVATE_ORG}"
    echo "   c. Contact email: (your email)"
    echo "   d. Organization type: Free"
    echo "   e. Click 'Create organization'"
    echo ""
    echo "   After creation, configure profile:"
    echo "   - Go to https://github.com/orgs/${PRIVATE_ORG}/settings/profile"
    echo "   - Display name: Seven Fortunas Internal"
    echo "   - Description: Private infrastructure and internal tools"
    echo "   - Set organization visibility to private if available"
    echo ""
fi

echo "After creating organizations, run this script again to validate."
echo ""

log_action "ORG_CREATION_PENDING: Manual creation required"
exit 1
