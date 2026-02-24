#!/bin/bash
# FEATURE_036: Access Control Enforcement
# Enforces principle of least privilege with 2FA, team-based access, and monthly audits

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== FEATURE_036: Access Control Enforcement Setup ==="
echo ""

# Verify GitHub authentication
echo "1. Verifying GitHub authentication..."
if ! gh auth status &>/dev/null; then
    echo "ERROR: GitHub CLI not authenticated. Run: gh auth login"
    exit 1
fi
echo "✓ GitHub authenticated"
echo ""

# Create access control policy
echo "2. Creating access control policy..."
mkdir -p "$PROJECT_ROOT/compliance/access-control"

cat > "$PROJECT_ROOT/compliance/access-control/access-control-policy.yaml" << 'EOF'
# Access Control Enforcement Policy
# Seven Fortunas Internal Security Policy

policy:
  name: "Principle of Least Privilege"
  version: "1.0"
  effective_date: "2026-02-17"
  owner: "Jorge (VP AI-SecOps)"

two_factor_authentication:
  requirement: "mandatory"
  compliance_target: 100.0  # percent
  enforcement: "organization-level"
  exceptions: []
  audit_frequency: "monthly"

default_permissions:
  base_permission: "none"  # No default repository access
  rationale: "Principle of least privilege - grant access explicitly via teams"
  override_allowed: false

team_based_access:
  enabled: true
  permission_model: "team-centric"
  teams:
    - name: "founders"
      permission: "admin"
      repositories: "all"
      members_require_2fa: true

    - name: "infrastructure-team"
      permission: "maintain"
      repositories:
        - "7f-infrastructure-project"
        - "seven-fortunas-brain"
      members_require_2fa: true

    - name: "dashboard-team"
      permission: "write"
      repositories:
        - "dashboards"
      members_require_2fa: true

    - name: "read-only-team"
      permission: "read"
      repositories: "all"
      members_require_2fa: true

organization_settings:
  two_factor_requirement: true
  members_can_create_repositories: false
  members_can_create_teams: false
  members_can_change_repo_visibility: false
  members_can_delete_repositories: false
  members_can_delete_issues: false
  default_repository_permission: "none"

audit:
  frequency: "monthly"
  quarterly_manual_review: true
  owner: "Jorge"
  report_location: "compliance/access-control/audit-reports/"
  soc2_integration: true

alerts:
  policy_violations:
    enabled: true
    channels:
      - email
      - matrix
      - github_issue

  2fa_non_compliance:
    enabled: true
    action: "remove_from_organization"
    grace_period_days: 7

  unauthorized_permission_change:
    enabled: true
    action: "revert_and_alert"

metrics:
  - 2fa_compliance_rate
  - default_permission_compliance
  - team_based_access_coverage
  - policy_violations_count
  - access_reviews_completed
EOF

echo "✓ Access control policy created: compliance/access-control/access-control-policy.yaml"
echo ""

# Create enforcement script
echo "3. Creating access control enforcement script..."
cat > "$PROJECT_ROOT/scripts/enforce-access-control.sh" << 'EOF'
#!/bin/bash
# Access Control Enforcement
# Enforces organization-level security settings

set -euo pipefail

ORG_NAME="Seven-Fortunas-Internal"

echo "=== Access Control Enforcement ==="
echo "Organization: $ORG_NAME"
echo "Date: $(date)"
echo ""

# Verify GitHub authentication
if ! gh auth status &>/dev/null; then
    echo "ERROR: GitHub CLI not authenticated"
    exit 1
fi

echo "1. Enforcing 2FA requirement..."
# Enable 2FA requirement (requires admin:org scope)
if gh api -X PATCH "orgs/$ORG_NAME" -f two_factor_requirement_enabled=true &>/dev/null; then
    echo "  ✓ 2FA requirement enabled"
else
    echo "  ⚠ Could not enforce 2FA (requires admin:org scope)"
fi

echo ""
echo "2. Setting default repository permission to 'none'..."
if gh api -X PATCH "orgs/$ORG_NAME" -f default_repository_permission=none &>/dev/null; then
    echo "  ✓ Default permission set to 'none'"
else
    echo "  ⚠ Could not set default permission (requires admin:org scope)"
fi

echo ""
echo "3. Restricting member capabilities..."

# Members cannot create repositories
if gh api -X PATCH "orgs/$ORG_NAME" -f members_can_create_repositories=false &>/dev/null; then
    echo "  ✓ Members cannot create repositories"
fi

# Members cannot create teams
if gh api -X PATCH "orgs/$ORG_NAME" -f members_can_create_teams=false &>/dev/null; then
    echo "  ✓ Members cannot create teams"
fi

# Members cannot change repository visibility
if gh api -X PATCH "orgs/$ORG_NAME" -f members_can_change_repo_visibility=false &>/dev/null; then
    echo "  ✓ Members cannot change repository visibility"
fi

echo ""
echo "✓ Access control enforcement complete"
EOF

chmod +x "$PROJECT_ROOT/scripts/enforce-access-control.sh"
echo "✓ Enforcement script created: scripts/enforce-access-control.sh"
echo ""

# Create monthly audit script
echo "4. Creating monthly access control audit script..."
mkdir -p "$PROJECT_ROOT/compliance/access-control/audit-reports"

cat > "$PROJECT_ROOT/scripts/monthly-access-control-audit.sh" << 'EOF'
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
EOF

chmod +x "$PROJECT_ROOT/scripts/monthly-access-control-audit.sh"
echo "✓ Monthly audit script created: scripts/monthly-access-control-audit.sh"
echo ""

# Create quarterly review checklist
echo "5. Creating quarterly manual review checklist..."
cat > "$PROJECT_ROOT/compliance/access-control/quarterly-review-checklist.md" << 'EOF'
# Quarterly Access Control Manual Review

**Frequency:** Quarterly (every 3 months)
**Owner:** Jorge (VP AI-SecOps)
**Purpose:** Manual validation of access control policy compliance

## Review Checklist

### 1. Member Access Review
- [ ] Review all organization members
- [ ] Verify each member still requires access
- [ ] Remove inactive members (no activity in 90 days)
- [ ] Verify 2FA enabled for all members
- [ ] Check member roles match current responsibilities

**Commands:**
```bash
# List all members
gh api orgs/Seven-Fortunas-Internal/members --jq '.[] | {login: .login, role: .role}'

# Check member activity
gh api users/USERNAME/events --jq '.[0].created_at'
```

### 2. Team Access Review
- [ ] Review all teams and their members
- [ ] Verify team permissions match principle of least privilege
- [ ] Remove members who no longer need team access
- [ ] Verify repository access for each team

**Commands:**
```bash
# List teams
gh api orgs/Seven-Fortunas-Internal/teams --jq '.[] | {name: .name, permission: .permission}'

# List team members
gh api teams/TEAM_ID/members --jq '.[] | .login'

# List team repositories
gh api teams/TEAM_ID/repos --jq '.[] | {name: .name, permission: .permissions}'
```

### 3. Repository Access Review
- [ ] Review repository collaborators
- [ ] Verify outside collaborators (if any) still need access
- [ ] Check repository visibility settings
- [ ] Verify branch protection rules

**Commands:**
```bash
# List repository collaborators
gh api repos/OWNER/REPO/collaborators --jq '.[] | {login: .login, permission: .permissions}'

# Check outside collaborators
gh api orgs/Seven-Fortunas-Internal/outside_collaborators --jq '.[] | .login'
```

### 4. Organization Settings Audit
- [ ] Verify 2FA requirement enabled
- [ ] Confirm default permission is 'none'
- [ ] Check member capabilities (create repos, teams, etc.)
- [ ] Review third-party application access
- [ ] Verify GitHub Apps permissions

**Commands:**
```bash
# Get organization settings
gh api orgs/Seven-Fortunas-Internal | jq '{
  two_factor_requirement_enabled,
  default_repository_permission,
  members_can_create_repositories
}'

# List installed GitHub Apps
gh api orgs/Seven-Fortunas-Internal/installations --jq '.installations[] | {app: .app_slug, permissions}'
```

### 5. Access Log Review
- [ ] Review audit log for access-related events
- [ ] Check for unauthorized permission changes
- [ ] Verify no policy violations occurred
- [ ] Document any anomalies

**Commands:**
```bash
# Get recent audit log events (requires audit log API access)
gh api orgs/Seven-Fortunas-Internal/audit-log?phrase=action:org.update_member --jq '.'
```

### 6. SOC 2 Documentation
- [ ] Save quarterly review results to compliance folder
- [ ] Update SOC 2 evidence tracker
- [ ] Document any exceptions or violations
- [ ] Generate summary report for auditors

**Location:** `compliance/access-control/quarterly-reviews/`

## Review Template

```markdown
# Quarterly Access Control Review - Q[X] 20XX

**Date:** YYYY-MM-DD
**Reviewer:** Jorge (VP AI-SecOps)
**Quarter:** QX 20XX

## Summary
- Total members reviewed: [N]
- Members removed: [N]
- Teams reviewed: [N]
- Policy violations: [N]
- Compliance status: [COMPLIANT/NON-COMPLIANT]

## Findings
1. [Finding description]
   - Action taken: [Action]
   - Status: [Resolved/In Progress/Pending]

## Recommendations
1. [Recommendation]

## Sign-off
**Reviewed by:** Jorge (VP AI-SecOps)
**Date:** YYYY-MM-DD
**Next review:** [Q+1] 20XX
```

## Completion

After completing the quarterly review:

1. Save review document: `compliance/access-control/quarterly-reviews/review-YYYY-QX.md`
2. Update SOC 2 evidence tracker
3. Address any findings within 30 days
4. Schedule next quarterly review

---

**Last Updated:** 2026-02-17
**Owner:** Jorge (VP AI-SecOps)
EOF

echo "✓ Quarterly review checklist created: compliance/access-control/quarterly-review-checklist.md"
echo ""

# Create documentation
echo "6. Creating access control enforcement documentation..."
mkdir -p "$PROJECT_ROOT/docs/security"

cat > "$PROJECT_ROOT/docs/security/access-control-enforcement.md" << 'EOF'
# Access Control Enforcement

## Overview
Seven Fortunas enforces the principle of least privilege through organization-level access controls, 2FA requirements, and team-based permissions.

## Policy

### Two-Factor Authentication (2FA)
**Requirement:** Mandatory for all organization members
**Compliance Target:** 100%
**Grace Period:** 7 days after joining
**Enforcement:** Automatic removal after grace period

### Default Permissions
**Base Permission:** None (no default repository access)
**Rationale:** Principle of least privilege - access granted explicitly via teams
**Override:** Not allowed

### Team-Based Access
**Model:** All repository access granted through team membership
**Permission Levels:**
- **Admin:** Founders only (full repository access)
- **Maintain:** Infrastructure team (7f-infrastructure-project, seven-fortunas-brain)
- **Write:** Dashboard team (dashboards)
- **Read:** Read-only team (all repositories)

## Enforcement

### Automated Enforcement
Run enforcement script to apply policy:
```bash
./scripts/enforce-access-control.sh
```

**Script Actions:**
1. Enable 2FA requirement
2. Set default permission to 'none'
3. Restrict member capabilities
4. Enforce organization settings

### Monthly Audits
Automated monthly compliance validation:
```bash
./scripts/monthly-access-control-audit.sh
```

**Audit Checks:**
- 2FA compliance rate
- Organization settings compliance
- Team-based access coverage
- Policy violations

**Report Location:** `compliance/access-control/audit-reports/`

### Quarterly Manual Reviews
Manual access review every quarter using checklist:
`compliance/access-control/quarterly-review-checklist.md`

**Review Scope:**
- Member access justification
- Team membership validation
- Repository collaborator review
- Organization settings audit
- Access log analysis

## Access Request Process

### New Member Onboarding
1. Create GitHub invitation
2. Member enables 2FA within 7 days
3. Assign to appropriate team(s)
4. Grant minimum necessary permissions
5. Document access justification

### Team Access Request
1. Submit request to Jorge (VP AI-SecOps)
2. Justify business need
3. Approval required from team lead
4. Add to team with minimum permission level
5. Review access after 90 days

### Permission Escalation
1. Submit escalation request with justification
2. Approval required from organization admin
3. Time-limited escalation (default: 30 days)
4. Automatic review at escalation expiry
5. Revert to base permission unless renewed

## Metrics

### Tracked Metrics
1. **2FA Compliance Rate:** % of members with 2FA enabled
2. **Default Permission Compliance:** Verify 'none' setting maintained
3. **Team-Based Access Coverage:** % of users accessing repos via teams
4. **Policy Violations Count:** Number of policy violations detected
5. **Access Reviews Completed:** Monthly/quarterly reviews on schedule

### Dashboard Integration
Access control metrics feed into:
- Security Dashboard (real-time monitoring)
- SOC 2 Compliance Dashboard (audit evidence)
- Project Progress Dashboard (team visibility)

## SOC 2 Integration

### Control: CC6.1 - Logical and Physical Access Controls
**Requirement:** Organization restricts logical access to information assets through appropriate access control mechanisms.

**Evidence:**
- Access control policy document
- Monthly audit reports
- Quarterly review records
- 2FA compliance reports
- Organization settings snapshots

### Audit Preparation
```bash
# Generate evidence for SOC 2 audit
./scripts/monthly-access-control-audit.sh

# Verify quarterly reviews completed
ls compliance/access-control/quarterly-reviews/

# Export 2FA compliance history
gh api orgs/Seven-Fortunas-Internal/members | jq '[.[] | {login: .login, two_factor: .two_factor_enabled}]'
```

## Troubleshooting

### Member Without 2FA After Grace Period
1. Contact member via email
2. Provide 2FA setup instructions
3. If not enabled within grace period: remove from organization
4. Document exception if business-critical

### Policy Violation Detected
1. Automated alert sent to Jorge
2. Investigate root cause
3. Revert unauthorized change
4. Document incident
5. Implement preventive measure

### Audit Script Fails
1. Verify GitHub CLI authenticated: `gh auth status`
2. Check admin:org scope: `gh auth status --show-scopes`
3. Verify organization access: `gh api orgs/Seven-Fortunas-Internal`
4. Review script logs for specific errors

## References

- [GitHub Organization Security Best Practices](https://docs.github.com/en/organizations/keeping-your-organization-secure)
- [Two-Factor Authentication](https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa)
- [Managing Team Access](https://docs.github.com/en/organizations/organizing-members-into-teams)
- Seven Fortunas Access Control & Authentication (FEATURE_021/FR-5.3)

---

**Last Updated:** 2026-02-17
**Owner:** Jorge (VP AI-SecOps)
**Review Cycle:** Monthly (automated), Quarterly (manual)
EOF

echo "✓ Documentation created: docs/security/access-control-enforcement.md"
echo ""

echo "=== Setup Complete ==="
echo ""
echo "Access Control Policy:"
echo "- 2FA: 100% compliance (mandatory)"
echo "- Default permission: none (least privilege)"
echo "- Access model: Team-based"
echo ""
echo "Automation:"
echo "- Enforcement script: scripts/enforce-access-control.sh"
echo "- Monthly audit: scripts/monthly-access-control-audit.sh"
echo "- Quarterly review: compliance/access-control/quarterly-review-checklist.md"
echo ""
echo "Next Steps:"
echo "1. Run enforcement script: ./scripts/enforce-access-control.sh"
echo "2. Run initial audit: ./scripts/monthly-access-control-audit.sh"
echo "3. Schedule monthly audits (cron or GitHub Actions)"
echo "4. Schedule quarterly manual reviews (calendar)"
echo ""
