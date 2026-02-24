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
