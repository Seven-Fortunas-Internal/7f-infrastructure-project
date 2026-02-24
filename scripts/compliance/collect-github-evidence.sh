#!/usr/bin/env bash
# collect-github-evidence.sh
# Collects compliance evidence from GitHub for SOC 2 audit readiness

set -euo pipefail

# Configuration
ORG_NAME="${ORG_NAME:-Seven-Fortunas-Internal}"
EVIDENCE_DIR="${EVIDENCE_DIR:-/tmp/compliance-evidence}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EVIDENCE_FILE="${EVIDENCE_DIR}/github-evidence-${TIMESTAMP}.json"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Ensure evidence directory exists
mkdir -p "${EVIDENCE_DIR}"

echo -e "${BLUE}=== GitHub Compliance Evidence Collection ===${NC}"
echo "Organization: ${ORG_NAME}"
echo "Timestamp: ${TIMESTAMP}"
echo ""

# Initialize evidence file
cat > "${EVIDENCE_FILE}" << EOFJ
{
  "collection_timestamp": "${TIMESTAMP}",
  "organization": "${ORG_NAME}",
  "controls": {}
}
EOFJ

# Function to collect evidence and update JSON
collect_evidence() {
    local control_id="$1"
    local description="$2"
    local api_call="$3"
    
    echo -e "${BLUE}Collecting: ${control_id}${NC} - ${description}"
    
    if EVIDENCE=$(eval "$api_call" 2>&1); then
        # Add evidence to JSON
        jq --arg id "$control_id" \
           --arg desc "$description" \
           --arg ev "$EVIDENCE" \
           --arg status "collected" \
           '.controls[$id] = {
               "description": $desc,
               "evidence": $ev,
               "status": $status,
               "timestamp": "'${TIMESTAMP}'"
           }' "${EVIDENCE_FILE}" > "${EVIDENCE_FILE}.tmp" && \
           mv "${EVIDENCE_FILE}.tmp" "${EVIDENCE_FILE}"
        
        echo -e "  ${GREEN}✓ Evidence collected${NC}"
    else
        echo -e "  ${RED}✗ Failed to collect evidence${NC}"
        
        # Log failure
        jq --arg id "$control_id" \
           --arg desc "$description" \
           --arg err "$EVIDENCE" \
           --arg status "failed" \
           '.controls[$id] = {
               "description": $desc,
               "error": $err,
               "status": $status,
               "timestamp": "'${TIMESTAMP}'"
           }' "${EVIDENCE_FILE}" > "${EVIDENCE_FILE}.tmp" && \
           mv "${EVIDENCE_FILE}.tmp" "${EVIDENCE_FILE}"
    fi
    
    echo ""
}

# Collect CC6.1: Logical and Physical Access Controls
echo -e "${YELLOW}=== CC6.1: Access Controls ===${NC}"

collect_evidence \
    "GH-ACCESS-001" \
    "Two-Factor Authentication (2FA)" \
    "gh api /orgs/${ORG_NAME} --jq '{two_factor_requirement_enabled}'"

collect_evidence \
    "GH-ACCESS-002" \
    "Default Repository Permission" \
    "gh api /orgs/${ORG_NAME} --jq '{default_repository_permission, members_can_create_repositories}'"

collect_evidence \
    "GH-ACCESS-003" \
    "Team-Based Access Control" \
    "gh api /orgs/${ORG_NAME}/teams --jq '[.[] | {name, slug, privacy, permission}]'"

# Collect CC7.2: System Monitoring
echo -e "${YELLOW}=== CC7.2: System Monitoring ===${NC}"

collect_evidence \
    "GH-SEC-001" \
    "Secret Detection" \
    "gh api /orgs/${ORG_NAME} --jq '{secret_scanning_enabled_for_new_repositories, secret_scanning_push_protection_enabled_for_new_repositories}'"

collect_evidence \
    "GH-SEC-002" \
    "Dependency Vulnerability Management" \
    "gh api /orgs/${ORG_NAME} --jq '{dependabot_alerts_enabled_for_new_repositories, dependabot_security_updates_enabled_for_new_repositories, dependency_graph_enabled_for_new_repositories}'"

# Collect repository-specific evidence
echo -e "${YELLOW}=== Repository-Specific Controls ===${NC}"

# Get list of repositories
REPOS=$(gh api "/orgs/${ORG_NAME}/repos?per_page=100" --jq '.[].name' 2>/dev/null || echo "")

if [[ -n "$REPOS" ]]; then
    REPO_COUNT=$(echo "$REPOS" | wc -l)
    echo "Found ${REPO_COUNT} repositories"
    echo ""
    
    for REPO in $REPOS; do
        echo -e "${BLUE}Repository: ${REPO}${NC}"
        
        # Branch protection evidence
        collect_evidence \
            "GH-SEC-003-${REPO}" \
            "Branch Protection (${REPO})" \
            "gh api /repos/${ORG_NAME}/${REPO}/branches/main/protection 2>&1 || echo 'No protection configured'"
        
        # Repository security settings
        collect_evidence \
            "GH-REPO-SEC-${REPO}" \
            "Repository Security Settings (${REPO})" \
            "gh api /repos/${ORG_NAME}/${REPO} --jq '{
                security_and_analysis,
                visibility,
                archived,
                disabled
            }'"
    done
else
    echo -e "${YELLOW}No repositories found${NC}"
    echo ""
fi

# Collect CC6.6: Authentication and Authorization
echo -e "${YELLOW}=== CC6.6: Authentication ===${NC}"

collect_evidence \
    "GH-AUTH-001" \
    "GitHub App Authentication" \
    "gh api /orgs/${ORG_NAME}/installations --jq '[.installations[] | {app_name: .app_slug, created_at, permissions}]' 2>&1 || echo '[]'"

# Summary
echo -e "${GREEN}=== Evidence Collection Complete ===${NC}"
echo "Evidence file: ${EVIDENCE_FILE}"
echo ""

# Count collected vs failed
COLLECTED_COUNT=$(jq '[.controls[] | select(.status == "collected")] | length' "${EVIDENCE_FILE}")
FAILED_COUNT=$(jq '[.controls[] | select(.status == "failed")] | length' "${EVIDENCE_FILE}")
TOTAL_COUNT=$((COLLECTED_COUNT + FAILED_COUNT))

echo "Results:"
echo "  Total controls: ${TOTAL_COUNT}"
echo "  Collected: ${COLLECTED_COUNT}"
echo "  Failed: ${FAILED_COUNT}"

if [[ $FAILED_COUNT -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}⚠️  Some evidence collection failed${NC}"
    echo "Review ${EVIDENCE_FILE} for details"
fi

# Create symlink to latest evidence
ln -sf "$(basename "${EVIDENCE_FILE}")" "${EVIDENCE_DIR}/latest.json"

echo ""
echo "✅ Evidence collection complete"
