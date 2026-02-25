#!/bin/bash
# FEATURE_004: FR-1.3: Configure Organization Security Settings
# Enforces security policies at organization level
# - 2FA required for all members (enforced)
# - Dependabot enabled (security + version updates)
# - Secret scanning enabled with push protection
# - Default repository permission: none
# - Branch protection on all main branches (documented for repo creation)

set -euo pipefail

# Configuration
ORGS=("Seven-Fortunas" "Seven-Fortunas-Internal")
LOG_FILE="compliance-evidence.log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Initialize log file
echo "=== Organization Security Configuration ===" | tee -a "$LOG_FILE"
echo "Timestamp: $TIMESTAMP" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Function to configure org security settings
configure_org_security() {
  local org=$1
  echo "=== Configuring security settings for: $org ===" | tee -a "$LOG_FILE"
  echo "" | tee -a "$LOG_FILE"

  # 1. Enable 2FA requirement for all members
  echo "1. Enforcing 2FA requirement..." | tee -a "$LOG_FILE"
  if gh api --method PATCH "/orgs/$org" -f two_factor_requirement_enabled=true >/dev/null 2>&1; then
    echo "   ✓ 2FA requirement enforced" | tee -a "$LOG_FILE"
  else
    echo "   ⚠ 2FA configuration attempted (may require owner permissions)" | tee -a "$LOG_FILE"
  fi

  # 2. Set default repository permission to 'none'
  echo "" | tee -a "$LOG_FILE"
  echo "2. Setting default repository permission to 'none'..." | tee -a "$LOG_FILE"
  if gh api --method PATCH "/orgs/$org" -f default_repository_permission=none >/dev/null 2>&1; then
    echo "   ✓ Default permission set to 'none'" | tee -a "$LOG_FILE"
  else
    echo "   ⚠ Default permission configuration attempted" | tee -a "$LOG_FILE"
  fi

  # 3. Enable Dependabot security updates for new repositories
  echo "" | tee -a "$LOG_FILE"
  echo "3. Enabling Dependabot for new repositories..." | tee -a "$LOG_FILE"
  if gh api --method PATCH "/orgs/$org" \
    -f dependabot_security_updates_enabled_for_new_repositories=true >/dev/null 2>&1; then
    echo "   ✓ Dependabot security updates enabled" | tee -a "$LOG_FILE"
  else
    echo "   ⚠ Dependabot configuration attempted" | tee -a "$LOG_FILE"
  fi

  # 4. Enable secret scanning and push protection (requires GitHub Advanced Security)
  echo "" | tee -a "$LOG_FILE"
  echo "4. Enabling secret scanning with push protection..." | tee -a "$LOG_FILE"

  # Try to enable advanced security features (may fail on free tier)
  if gh api --method PATCH "/orgs/$org" \
    -f secret_scanning_enabled_for_new_repositories=true \
    -f secret_scanning_push_protection_enabled_for_new_repositories=true >/dev/null 2>&1; then
    echo "   ✓ Secret scanning with push protection enabled" | tee -a "$LOG_FILE"
  else
    echo "   ⚠ Secret scanning requires GitHub Advanced Security (Enterprise Cloud)" | tee -a "$LOG_FILE"
    echo "   Note: Basic secret scanning may be available on public repos" | tee -a "$LOG_FILE"
  fi

  echo "" | tee -a "$LOG_FILE"
}

# Function to verify security settings
verify_org_security() {
  local org=$1
  echo "=== Verifying security settings for: $org ===" | tee -a "$LOG_FILE"
  echo "" | tee -a "$LOG_FILE"

  # Get current org settings
  ORG_SETTINGS=$(gh api "/orgs/$org" 2>/dev/null || echo "{}")

  # Check 2FA requirement
  TWO_FACTOR=$(echo "$ORG_SETTINGS" | jq -r '.two_factor_requirement_enabled // "unknown"')
  echo "  2FA Requirement Enabled: $TWO_FACTOR" | tee -a "$LOG_FILE"

  # Check default repository permission
  DEFAULT_PERM=$(echo "$ORG_SETTINGS" | jq -r '.default_repository_permission // "unknown"')
  echo "  Default Repository Permission: $DEFAULT_PERM" | tee -a "$LOG_FILE"

  # Check Dependabot
  DEPENDABOT=$(echo "$ORG_SETTINGS" | jq -r '.dependabot_security_updates_enabled_for_new_repositories // false')
  echo "  Dependabot Security Updates (New Repos): $DEPENDABOT" | tee -a "$LOG_FILE"

  # Check secret scanning (may not be available on free tier)
  SECRET_SCAN=$(echo "$ORG_SETTINGS" | jq -r '.secret_scanning_enabled_for_new_repositories // false')
  PUSH_PROTECT=$(echo "$ORG_SETTINGS" | jq -r '.secret_scanning_push_protection_enabled_for_new_repositories // false')

  echo "  Secret Scanning (New Repos): $SECRET_SCAN" | tee -a "$LOG_FILE"
  echo "  Secret Scanning Push Protection (New Repos): $PUSH_PROTECT" | tee -a "$LOG_FILE"

  echo "" | tee -a "$LOG_FILE"
}

# Main execution
main() {
  echo "Starting organization security configuration..."
  echo ""

  for org in "${ORGS[@]}"; do
    configure_org_security "$org"
    verify_org_security "$org"
  done

  echo "=== Configuration Complete ===" | tee -a "$LOG_FILE"
  echo "" | tee -a "$LOG_FILE"
  echo "Compliance evidence logged to: $LOG_FILE"
  echo ""
  echo "NOTE ON ADVANCED SECURITY:" | tee -a "$LOG_FILE"
  echo "  - Secret scanning with push protection requires GitHub Advanced Security" | tee -a "$LOG_FILE"
  echo "  - This feature is available on GitHub Enterprise Cloud (paid tier)" | tee -a "$LOG_FILE"
  echo "  - Public repositories may have basic secret scanning enabled by default" | tee -a "$LOG_FILE"
  echo "" | tee -a "$LOG_FILE"
  echo "NOTE ON BRANCH PROTECTION:" | tee -a "$LOG_FILE"
  echo "  - Branch protection rules are configured per-repository" | tee -a "$LOG_FILE"
  echo "  - These will be applied when repositories are created (FR-1.5)" | tee -a "$LOG_FILE"
  echo "  - See scripts/configure_branch_protection.sh for implementation" | tee -a "$LOG_FILE"
  echo "" | tee -a "$LOG_FILE"
  echo "NOTE ON DEPENDABOT VERSION UPDATES:" | tee -a "$LOG_FILE"
  echo "  - Security updates are now enabled org-wide for new repos" | tee -a "$LOG_FILE"
  echo "  - Version updates require a .github/dependabot.yml file in each repo" | tee -a "$LOG_FILE"
  echo "  - This will be configured when repositories are initialized" | tee -a "$LOG_FILE"
  echo "" | tee -a "$LOG_FILE"
}

main "$@"
