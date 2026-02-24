# Access Control Enforcement

## Overview

Seven Fortunas enforces the principle of least privilege through GitHub organization settings, 2FA requirements, and team-based access control.

**Framework:** NFR-1.3
**Implementation:** FR-5.3 (2FA + Team-based access)

---

## Policy Enforcement

### 1. Two-Factor Authentication (2FA)

**Requirement:** 100% compliance

**Configuration:**
```bash
# Enforce 2FA at organization level
gh api -X PATCH /orgs/Seven-Fortunas-Internal \
  -f two_factor_requirement_enabled=true
```

**Verification:**
```bash
# Check 2FA compliance
gh api /orgs/Seven-Fortunas-Internal/members \
  --jq '.[] | select(.two_factor_authentication == false) | .login'
```

**Expected Output:** (empty - all members have 2FA enabled)

### 2. Default Repository Permission

**Requirement:** None (explicit grant required)

**Configuration:**
```bash
# Set default to 'none'
gh api -X PATCH /orgs/Seven-Fortunas-Internal \
  -f default_repository_permission=none \
  -f members_can_create_repositories=false
```

**Rationale:** Force explicit, team-based access grants

### 3. Team-Based Access

**Requirement:** All repository access via teams (not individual grants)

**Teams:**
- `@Seven-Fortunas-Internal/founders` - Admin access to all repos
- `@Seven-Fortunas-Internal/developers` - Write access to specific repos
- `@Seven-Fortunas-Internal/readonly` - Read access for auditors

**Grant Access:**
```bash
# Add repository to team (not individual)
gh api -X PUT /orgs/Seven-Fortunas-Internal/teams/founders/repos/Seven-Fortunas-Internal/7f-infrastructure-project \
  -f permission=admin
```

---

## Monthly Audit

**Schedule:** First Monday of each month

**Audit Script:** `scripts/audit-access-control.sh`

### Audit Checklist

- [ ] 2FA compliance: 100%
- [ ] No individual repository grants (team-based only)
- [ ] Default permission: none
- [ ] Outside collaborators reviewed and justified
- [ ] Team membership reviewed
- [ ] Pending invitations reviewed
- [ ] Removed members have access revoked

**Run Audit:**
```bash
./scripts/audit-access-control.sh

# Output:
# ✓ 2FA Compliance: 100% (3/3 members)
# ✓ Default Permission: none
# ✓ Team-based Access: 100% (0 individual grants)
# ⚠ Outside Collaborators: 1 (review required)
# ✓ Pending Invitations: 0
```

---

## Quarterly Manual Review

**Schedule:** End of each quarter

### Review Scope

1. **Access Logs**
   - Review audit log for unauthorized access attempts
   - Identify anomalous patterns
   - Document findings

2. **Team Membership**
   - Verify all team members still require access
   - Remove ex-employees/contractors
   - Update team permissions based on role changes

3. **Repository Permissions**
   - Review team-to-repository mappings
   - Verify least privilege principle
   - Remove unnecessary access

4. **Policy Violations**
   - Review policy violation logs
   - Investigate root causes
   - Implement preventive measures

**Review Process:**
```bash
# Export audit log for quarter
gh api /orgs/Seven-Fortunas-Internal/audit-log \
  --jq '.[] | select(.created_at >= "2026-01-01" and .created_at < "2026-04-01")' \
  > audit-log-Q1-2026.json

# Analyze access patterns
./scripts/analyze-access-patterns.sh audit-log-Q1-2026.json

# Generate review report
./scripts/generate-access-review-report.sh --quarter Q1-2026
```

---

## Policy Violations

### Detection

**Monitored Violations:**
1. Member without 2FA (auto-detected, immediate alert)
2. Individual repository grant (monthly audit detection)
3. Default permission changed from 'none' (webhook alert)
4. Unauthorized team membership changes (webhook alert)

**Alert Channels:**
- Slack: #security (immediate)
- Email: security@sevenfortunas.dev (daily digest)
- Audit log: Permanent record

### Response

**Violation:** Member without 2FA

**Action:**
1. Automatic suspension from organization
2. Email notification with 2FA setup instructions
3. Re-invitation after 2FA enabled

**Violation:** Individual repository grant

**Action:**
1. Log violation with timestamp and granter
2. Notify granter to use team-based access instead
3. Quarterly review flags for removal

**Violation:** Unauthorized configuration change

**Action:**
1. Immediate Slack alert
2. Revert change (if automated)
3. Incident investigation required

---

## Integration with SOC 2

### Controls Mapping

**Control:** CC6.1 - Logical and Physical Access

**Evidence:**
- Monthly audit reports
- 2FA compliance metrics
- Team-based access policy
- Quarterly manual reviews
- Policy violation logs

**Audit Trail:**
```bash
# Export access control evidence for auditors
./scripts/export-access-control-evidence.sh --year 2026 --format pdf

# Output: access-control-evidence-2026.pdf
# - 2FA compliance: 12 months × 100%
# - Monthly audit reports
# - Quarterly review summaries
# - Policy violation incidents (if any)
```

---

## See Also

- [FR-5.3: Access Control & Authentication](../scripts/configure-security-settings.sh)
- [GitHub Organization Security](https://docs.github.com/en/organizations/keeping-your-organization-secure)
- [SOC 2 Compliance Tracking](./soc2-compliance.md)

---

**Version:** 1.0
**Last Updated:** 2026-02-24
**Owner:** Jorge (VP AI-SecOps)
**Next Audit:** First Monday of next month
