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
