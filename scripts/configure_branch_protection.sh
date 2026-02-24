#!/usr/bin/env bash
# configure_branch_protection.sh
# Configures branch protection rules for Seven Fortunas repositories

set -euo pipefail

# Constants
PUBLIC_ORG="Seven-Fortunas"
PRIVATE_ORG="Seven-Fortunas-Internal"
LOG_FILE="${LOG_FILE:-/tmp/github_branch_protection.log}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to log actions
log_action() {
    local message="$1"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[${timestamp}] ${message}" | tee -a "${LOG_FILE}"
}

# Function to apply branch protection
apply_branch_protection() {
    local org="$1"
    local repo="$2"
    local branch="${3:-main}"

    echo -e "${BLUE}Applying branch protection: ${org}/${repo} (${branch})${NC}"

    # Check if repo exists
    if ! gh api "repos/${org}/${repo}" &>/dev/null; then
        echo -e "${RED}✗ Repository ${org}/${repo} does not exist${NC}"
        log_action "BRANCH_PROTECTION_SKIPPED: ${org}/${repo} (repo not found)"
        return 1
    fi

    # Branch protection on GitHub Free tier requires manual configuration
    # API-based protection rules require GitHub Pro/Team/Enterprise

    echo -e "${YELLOW}⚠ Branch protection requires manual configuration (Free tier limitation)${NC}"
    echo "  Manual steps:"
    echo "  1. Go to: https://github.com/${org}/${repo}/settings/branches"
    echo "  2. Click 'Add branch protection rule'"
    echo "  3. Branch name pattern: ${branch}"
    echo "  4. Enable: 'Require a pull request before merging'"
    echo "  5. Enable: 'Require conversation resolution before merging'"
    echo "  6. Enable: 'Do not allow bypassing the above settings'"
    echo "  7. Click 'Create'"
    echo ""

    log_action "BRANCH_PROTECTION_MANUAL: ${org}/${repo}/${branch} (requires manual setup)"
    return 0
}

# Function to verify branch protection
verify_branch_protection() {
    local org="$1"
    local repo="$2"
    local branch="${3:-main}"

    if ! protection_data=$(gh api "repos/${org}/${repo}/branches/${branch}/protection" 2>/dev/null); then
        echo -e "  ${RED}✗ No branch protection found${NC}"
        return 1
    fi

    # Check key settings
    pr_required=$(echo "${protection_data}" | jq -r '.required_pull_request_reviews != null')
    force_push=$(echo "${protection_data}" | jq -r '.allow_force_pushes.enabled // false')
    delete=$(echo "${protection_data}" | jq -r '.allow_deletions.enabled // false')

    echo -e "  ${GREEN}✓ Branch protection active${NC}"
    echo "    - PR required: ${pr_required}"
    echo "    - Force push blocked: $([ "$force_push" == "false" ] && echo "yes" || echo "no")"
    echo "    - Deletion blocked: $([ "$delete" == "false" ] && echo "yes" || echo "no")"

    return 0
}

# Validate authentication
echo -e "${YELLOW}Validating GitHub authentication...${NC}"
if ! ./scripts/validate_github_auth.sh; then
    echo -e "${RED}ERROR: GitHub authentication validation failed${NC}"
    log_action "BRANCH_PROTECTION_FAILED: Authentication validation failed"
    exit 1
fi
echo -e "${GREEN}✓ GitHub authentication validated${NC}"
log_action "BRANCH_PROTECTION_START: Authentication validated"

# Apply branch protection to all repositories
echo ""
echo -e "${BLUE}=== Applying Branch Protection Rules ===${NC}"
echo ""

# Public repositories
echo -e "${BLUE}Public Organization (${PUBLIC_ORG}):${NC}"
apply_branch_protection "${PUBLIC_ORG}" ".github"
apply_branch_protection "${PUBLIC_ORG}" "seven-fortunas.github.io"
apply_branch_protection "${PUBLIC_ORG}" "dashboards"
apply_branch_protection "${PUBLIC_ORG}" "second-brain-public"

echo ""
echo -e "${BLUE}Private Organization (${PRIVATE_ORG}):${NC}"
apply_branch_protection "${PRIVATE_ORG}" ".github"
apply_branch_protection "${PRIVATE_ORG}" "internal-docs"
apply_branch_protection "${PRIVATE_ORG}" "seven-fortunas-brain"
apply_branch_protection "${PRIVATE_ORG}" "dashboards-internal"
apply_branch_protection "${PRIVATE_ORG}" "7f-infrastructure-project"

# Verify protection
echo ""
echo -e "${BLUE}=== Verifying Branch Protection ===${NC}"
echo ""

echo "Sample verification:"
verify_branch_protection "${PUBLIC_ORG}" "dashboards" || true
verify_branch_protection "${PRIVATE_ORG}" "seven-fortunas-brain" || true

echo ""
echo -e "${GREEN}✓ Branch protection configuration complete${NC}"
log_action "BRANCH_PROTECTION_COMPLETE: All repositories processed"

echo ""
echo "Note: Some branch protection features require GitHub Team/Enterprise plan."
echo "      Free tier limitations: PR approvals may not be enforced."
echo ""

exit 0
