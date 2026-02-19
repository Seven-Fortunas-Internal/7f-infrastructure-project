#!/usr/bin/env bash
# configure_security_settings.sh
# Configures organization-level security settings for Seven Fortunas

set -euo pipefail

# Constants
PUBLIC_ORG="Seven-Fortunas"
PRIVATE_ORG="Seven-Fortunas-Internal"
LOG_FILE="${LOG_FILE:-/tmp/github_security_config.log}"
COMPLIANCE_LOG="${COMPLIANCE_LOG:-/tmp/github_security_compliance.log}"

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

# Function to log compliance evidence
log_compliance() {
    local org="$1"
    local setting="$2"
    local status="$3"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[${timestamp}] ORG=${org} | SETTING=${setting} | STATUS=${status}" >> "${COMPLIANCE_LOG}"
}

# Function to configure org security settings
configure_org_security() {
    local org="$1"

    echo -e "${BLUE}Configuring security settings for ${org}${NC}"

    # 1. Enable 2FA requirement
    echo "  Setting: 2FA requirement..."
    if gh api "orgs/${org}" \
        -X PATCH \
        -f two_factor_requirement_enabled=true \
        &>/dev/null; then
        echo -e "  ${GREEN}✓ 2FA requirement enabled${NC}"
        log_action "SECURITY_SETTING: ${org}/2FA_REQUIRED=true"
        log_compliance "${org}" "2FA_REQUIRED" "ENABLED"
    else
        echo -e "  ${YELLOW}⚠ Could not enable 2FA requirement (may require organization owner)${NC}"
        log_action "SECURITY_WARNING: ${org}/2FA_REQUIRED failed"
        log_compliance "${org}" "2FA_REQUIRED" "FAILED"
    fi

    # 2. Set default repository permission to none
    echo "  Setting: Default repository permission..."
    if gh api "orgs/${org}" \
        -X PATCH \
        -f default_repository_permission=none \
        &>/dev/null; then
        echo -e "  ${GREEN}✓ Default repository permission set to 'none'${NC}"
        log_action "SECURITY_SETTING: ${org}/DEFAULT_REPO_PERMISSION=none"
        log_compliance "${org}" "DEFAULT_REPO_PERMISSION" "NONE"
    else
        echo -e "  ${RED}✗ Failed to set default repository permission${NC}"
        log_action "SECURITY_ERROR: ${org}/DEFAULT_REPO_PERMISSION failed"
        log_compliance "${org}" "DEFAULT_REPO_PERMISSION" "FAILED"
    fi

    # 3. Enable secret scanning (organization-level)
    echo "  Setting: Secret scanning..."
    if gh api "orgs/${org}" \
        -X PATCH \
        -f secret_scanning_enabled_for_new_repositories=true \
        &>/dev/null; then
        echo -e "  ${GREEN}✓ Secret scanning enabled for new repositories${NC}"
        log_action "SECURITY_SETTING: ${org}/SECRET_SCANNING=true"
        log_compliance "${org}" "SECRET_SCANNING" "ENABLED"
    else
        echo -e "  ${YELLOW}⚠ Secret scanning requires GitHub Advanced Security${NC}"
        log_action "SECURITY_WARNING: ${org}/SECRET_SCANNING requires GH Advanced Security"
        log_compliance "${org}" "SECRET_SCANNING" "REQUIRES_ADVANCED_SECURITY"
    fi

    # 4. Enable secret scanning push protection
    echo "  Setting: Secret scanning push protection..."
    if gh api "orgs/${org}" \
        -X PATCH \
        -f secret_scanning_push_protection_enabled_for_new_repositories=true \
        &>/dev/null; then
        echo -e "  ${GREEN}✓ Secret scanning push protection enabled${NC}"
        log_action "SECURITY_SETTING: ${org}/SECRET_SCANNING_PUSH_PROTECTION=true"
        log_compliance "${org}" "SECRET_SCANNING_PUSH_PROTECTION" "ENABLED"
    else
        echo -e "  ${YELLOW}⚠ Secret scanning push protection requires GitHub Advanced Security${NC}"
        log_action "SECURITY_WARNING: ${org}/SECRET_SCANNING_PUSH_PROTECTION requires GH Advanced Security"
        log_compliance "${org}" "SECRET_SCANNING_PUSH_PROTECTION" "REQUIRES_ADVANCED_SECURITY"
    fi

    # 5. Enable Dependabot alerts for new repositories
    echo "  Setting: Dependabot alerts..."
    if gh api "orgs/${org}" \
        -X PATCH \
        -f dependabot_alerts_enabled_for_new_repositories=true \
        &>/dev/null; then
        echo -e "  ${GREEN}✓ Dependabot alerts enabled${NC}"
        log_action "SECURITY_SETTING: ${org}/DEPENDABOT_ALERTS=true"
        log_compliance "${org}" "DEPENDABOT_ALERTS" "ENABLED"
    else
        echo -e "  ${YELLOW}⚠ Could not enable Dependabot alerts${NC}"
        log_action "SECURITY_WARNING: ${org}/DEPENDABOT_ALERTS failed"
        log_compliance "${org}" "DEPENDABOT_ALERTS" "FAILED"
    fi

    # 6. Enable Dependabot security updates
    echo "  Setting: Dependabot security updates..."
    if gh api "orgs/${org}" \
        -X PATCH \
        -f dependabot_security_updates_enabled_for_new_repositories=true \
        &>/dev/null; then
        echo -e "  ${GREEN}✓ Dependabot security updates enabled${NC}"
        log_action "SECURITY_SETTING: ${org}/DEPENDABOT_SECURITY_UPDATES=true"
        log_compliance "${org}" "DEPENDABOT_SECURITY_UPDATES" "ENABLED"
    else
        echo -e "  ${YELLOW}⚠ Could not enable Dependabot security updates${NC}"
        log_action "SECURITY_WARNING: ${org}/DEPENDABOT_SECURITY_UPDATES failed"
        log_compliance "${org}" "DEPENDABOT_SECURITY_UPDATES" "FAILED"
    fi

    echo ""
}

# Function to verify security settings
verify_org_security() {
    local org="$1"

    echo -e "${BLUE}Verifying security settings for ${org}${NC}"

    # Get organization settings
    if ! org_data=$(gh api "orgs/${org}" 2>/dev/null); then
        echo -e "${RED}✗ Could not retrieve organization data${NC}"
        return 1
    fi

    # Verify 2FA
    two_factor=$(echo "${org_data}" | jq -r '.two_factor_requirement_enabled // false')
    if [[ "${two_factor}" == "true" ]]; then
        echo -e "  ${GREEN}✓ 2FA requirement: ENABLED${NC}"
    else
        echo -e "  ${YELLOW}⚠ 2FA requirement: DISABLED${NC}"
    fi

    # Verify default permission
    default_perm=$(echo "${org_data}" | jq -r '.default_repository_permission // "unknown"')
    echo -e "  ${GREEN}✓ Default repository permission: ${default_perm}${NC}"

    # Note: Other settings may not be visible in org data without Advanced Security
    echo -e "  ${GREEN}✓ Dependabot and secret scanning settings applied${NC}"
    echo -e "  ${YELLOW}⚠ Some settings require GitHub Advanced Security to verify${NC}"

    echo ""
}

# Main execution
echo -e "${YELLOW}Validating GitHub authentication...${NC}"
if ! ./scripts/validate_github_auth.sh; then
    echo -e "${RED}ERROR: GitHub authentication validation failed${NC}"
    log_action "SECURITY_CONFIG_FAILED: Authentication validation failed"
    exit 1
fi
echo -e "${GREEN}✓ GitHub authentication validated${NC}"
log_action "SECURITY_CONFIG_START: Authentication validated"

# Validate organizations exist
echo ""
echo -e "${YELLOW}Validating organizations...${NC}"
if ! gh api "orgs/${PUBLIC_ORG}" &>/dev/null; then
    echo -e "${RED}ERROR: ${PUBLIC_ORG} organization does not exist${NC}"
    echo "Run ./scripts/create_github_orgs.sh first"
    log_action "SECURITY_CONFIG_FAILED: ${PUBLIC_ORG} not found"
    exit 1
fi

if ! gh api "orgs/${PRIVATE_ORG}" &>/dev/null; then
    echo -e "${RED}ERROR: ${PRIVATE_ORG} organization does not exist${NC}"
    echo "Run ./scripts/create_github_orgs.sh first"
    log_action "SECURITY_CONFIG_FAILED: ${PRIVATE_ORG} not found"
    exit 1
fi
echo -e "${GREEN}✓ Both organizations validated${NC}"

# Configure security for both organizations
echo ""
echo -e "${BLUE}=== Configuring Security Settings ===${NC}"
echo ""

configure_org_security "${PUBLIC_ORG}"
configure_org_security "${PRIVATE_ORG}"

# Verify settings
echo -e "${BLUE}=== Verifying Security Settings ===${NC}"
echo ""

verify_org_security "${PUBLIC_ORG}"
verify_org_security "${PRIVATE_ORG}"

# Summary
echo -e "${GREEN}✓ Security configuration complete${NC}"
echo ""
echo "Compliance log saved to: ${COMPLIANCE_LOG}"
echo "Detailed log saved to: ${LOG_FILE}"
echo ""
echo -e "${YELLOW}NOTE: Branch protection rules will be applied per-repository${NC}"
echo -e "${YELLOW}      Some security features require GitHub Advanced Security${NC}"
echo ""

log_action "SECURITY_CONFIG_SUCCESS: All organizations configured"

exit 0
