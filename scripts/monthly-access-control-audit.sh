#!/bin/bash
# Monthly Access Control Audit
# Validates access control policy compliance

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
AUDIT_REPORT="$PROJECT_ROOT/compliance/access-control/audit-reports/access-control-audit-$TIMESTAMP.json"
ORG_NAME="Seven-Fortunas-Internal"

echo "=== Monthly Access Control Audit ==="
echo "Organization: $ORG_NAME"
echo "Date: $(date)"
echo "Report: $AUDIT_REPORT"
echo ""

# Verify GitHub authentication
if ! gh auth status &>/dev/null; then
    echo "ERROR: GitHub CLI not authenticated"
    exit 1
fi

echo "1. Auditing 2FA compliance..."
TOTAL_MEMBERS=$(gh api "orgs/$ORG_NAME/members" --jq 'length')
MEMBERS_2FA=$(gh api "orgs/$ORG_NAME/members?filter=2fa_disabled" --jq 'length')
MEMBERS_WITHOUT_2FA=$MEMBERS_2FA

if [[ $TOTAL_MEMBERS -gt 0 ]]; then
    MEMBERS_WITH_2FA=$((TOTAL_MEMBERS - MEMBERS_WITHOUT_2FA))
    TWO_FA_COMPLIANCE=$(awk "BEGIN {printf \"%.2f\", ($MEMBERS_WITH_2FA / $TOTAL_MEMBERS) * 100}")
else
    TWO_FA_COMPLIANCE="100.00"
    MEMBERS_WITH_2FA=0
fi

echo "  Total members: $TOTAL_MEMBERS"
echo "  With 2FA: $MEMBERS_WITH_2FA"
echo "  Without 2FA: $MEMBERS_WITHOUT_2FA"
echo "  Compliance rate: $TWO_FA_COMPLIANCE%"

if [[ $MEMBERS_WITHOUT_2FA -gt 0 ]]; then
    echo "  ⚠ WARNING: $MEMBERS_WITHOUT_2FA members without 2FA"
    echo "  Members without 2FA:"
    gh api "orgs/$ORG_NAME/members?filter=2fa_disabled" --jq '.[].login' | while read -r login; do
        echo "    - $login"
    done
fi
echo ""

echo "2. Auditing organization settings..."
ORG_SETTINGS=$(gh api "orgs/$ORG_NAME")

DEFAULT_PERMISSION=$(echo "$ORG_SETTINGS" | jq -r '.default_repository_permission')
TWO_FA_REQUIRED=$(echo "$ORG_SETTINGS" | jq -r '.two_factor_requirement_enabled')
MEMBERS_CAN_CREATE_REPOS=$(echo "$ORG_SETTINGS" | jq -r '.members_can_create_repositories')

echo "  Default permission: $DEFAULT_PERMISSION"
echo "  2FA required: $TWO_FA_REQUIRED"
echo "  Members can create repos: $MEMBERS_CAN_CREATE_REPOS"
echo ""

# Check compliance
SETTINGS_COMPLIANT=true

if [[ "$DEFAULT_PERMISSION" != "none" ]]; then
    echo "  ✗ VIOLATION: Default permission should be 'none' (found: $DEFAULT_PERMISSION)"
    SETTINGS_COMPLIANT=false
else
    echo "  ✓ Default permission compliant"
fi

if [[ "$TWO_FA_REQUIRED" != "true" ]]; then
    echo "  ✗ VIOLATION: 2FA should be required"
    SETTINGS_COMPLIANT=false
else
    echo "  ✓ 2FA requirement compliant"
fi

echo ""

echo "3. Auditing team-based access..."
TEAMS=$(gh api "orgs/$ORG_NAME/teams" --jq '.')
TEAMS_COUNT=$(echo "$TEAMS" | jq 'length')

echo "  Total teams: $TEAMS_COUNT"

# List teams and their access
echo "$TEAMS" | jq -r '.[] | "  - \(.name): \(.permission) (\(.members_count) members)"'
echo ""

echo "4. Generating audit report..."

# Calculate compliance score
VIOLATION_COUNT=0
[[ "$DEFAULT_PERMISSION" != "none" ]] && VIOLATION_COUNT=$((VIOLATION_COUNT + 1))
[[ "$TWO_FA_REQUIRED" != "true" ]] && VIOLATION_COUNT=$((VIOLATION_COUNT + 1))
[[ $MEMBERS_WITHOUT_2FA -gt 0 ]] && VIOLATION_COUNT=$((VIOLATION_COUNT + MEMBERS_WITHOUT_2FA))

if [[ $VIOLATION_COUNT -eq 0 ]]; then
    COMPLIANCE_STATUS="COMPLIANT"
    COMPLIANCE_SCORE="100.00"
else
    COMPLIANCE_STATUS="NON_COMPLIANT"
    TOTAL_CHECKS=$((3 + TOTAL_MEMBERS))  # 3 settings + 1 per member
    PASSED_CHECKS=$((TOTAL_CHECKS - VIOLATION_COUNT))
    COMPLIANCE_SCORE=$(awk "BEGIN {printf \"%.2f\", ($PASSED_CHECKS / $TOTAL_CHECKS) * 100}")
fi

# Generate JSON report
cat > "$AUDIT_REPORT" << JSON
{
  "audit_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "auditor": "Jorge (VP AI-SecOps)",
  "organization": "$ORG_NAME",
  "two_factor_authentication": {
    "total_members": $TOTAL_MEMBERS,
    "members_with_2fa": $MEMBERS_WITH_2FA,
    "members_without_2fa": $MEMBERS_WITHOUT_2FA,
    "compliance_rate": $TWO_FA_COMPLIANCE,
    "target_rate": 100.0,
    "compliant": $([ $MEMBERS_WITHOUT_2FA -eq 0 ] && echo "true" || echo "false")
  },
  "organization_settings": {
    "default_repository_permission": "$DEFAULT_PERMISSION",
    "two_factor_requirement_enabled": $TWO_FA_REQUIRED,
    "members_can_create_repositories": $MEMBERS_CAN_CREATE_REPOS,
    "settings_compliant": $SETTINGS_COMPLIANT
  },
  "team_based_access": {
    "total_teams": $TEAMS_COUNT,
    "team_coverage": "$(echo "$TEAMS" | jq -r '[.[] | .name] | join(", ")')"
  },
  "policy_compliance": {
    "violation_count": $VIOLATION_COUNT,
    "compliance_score": $COMPLIANCE_SCORE,
    "status": "$COMPLIANCE_STATUS"
  },
  "soc2_integration": true,
  "recommendations": [
    $(if [[ $MEMBERS_WITHOUT_2FA -gt 0 ]]; then echo '"Enable 2FA for all members immediately"'; else echo '"Maintain current 2FA compliance"'; fi),
    $(if [[ "$DEFAULT_PERMISSION" != "none" ]]; then echo '"Set default repository permission to none"'; else echo '"Default permission compliant - no action needed"'; fi),
    "Continue monthly audits for SOC 2 compliance",
    "Perform quarterly manual access review"
  ]
}
JSON

echo "  ✓ Audit report saved: $AUDIT_REPORT"
echo ""

# Summary
echo "=== Audit Summary ==="
echo "2FA Compliance: $TWO_FA_COMPLIANCE% (target: 100%)"
echo "Settings Compliance: $SETTINGS_COMPLIANT"
echo "Violation Count: $VIOLATION_COUNT"
echo "Overall Status: $COMPLIANCE_STATUS ($COMPLIANCE_SCORE%)"
echo ""

if [[ "$COMPLIANCE_STATUS" == "COMPLIANT" ]]; then
    echo "✓ Access control policy fully compliant"
else
    echo "✗ Access control violations detected - review required"
fi
