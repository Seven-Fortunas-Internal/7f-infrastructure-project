# Seven Fortunas: Access Control & Authentication

## Overview

This document describes the access control and authentication security measures for Seven Fortunas GitHub organizations.

## 2FA Enforcement

**Status:** ✅ Enabled at organization level

- **Policy:** All organization members MUST enable 2FA to maintain access
- **Enforcement:** Configured via GitHub organization settings API
- **Grace Period:** Members have 7 days to enable 2FA after joining
- **Consequence:** Automatic removal from organization if 2FA not enabled

### Verifying 2FA Status

```bash
# Check organization 2FA requirement
gh api /orgs/Seven-Fortunas --jq .two_factor_requirement_enabled

# List members without 2FA (org owners only)
gh api /orgs/Seven-Fortunas/members --jq '.[] | select(.two_factor_authentication == false) | .login'
```

## Default Repository Permissions

**Policy:** Least privilege by default

- **Default Permission:** `none` (no access unless explicitly granted)
- **Access Grants:** Via team membership only (not individual collaborators)
- **Repository Creation:** Restricted to organization owners

### Permission Levels

1. **None** (default) - No access
2. **Read** - Can view and clone
3. **Triage** - Can manage issues/PRs
4. **Write** - Can push code
5. **Maintain** - Can manage repo settings (no admin)
6. **Admin** - Full control

## Team-Based Access Control

**Principle:** Access granted via team membership, not individual collaborators

### Organizational Structure

```
Seven-Fortunas (Public Org)
├── founders (admin)
│   ├── Jorge (VP AI-SecOps)
│   └── Henry (CEO)
├── engineering (write)
│   └── [Future team members]
└── community (read)
    └── [Future contributors]

Seven-Fortunas-Internal (Private Org)
├── founders (admin)
│   ├── Jorge
│   └── Henry
└── ops (write)
    └── [Future ops team]
```

### Adding Members

```bash
# Add to team (grants repository access automatically)
gh api --method PUT /orgs/Seven-Fortunas/teams/engineering/memberships/USERNAME

# Do NOT use individual collaborators
# ❌ gh repo add-collaborator (violates team-based policy)
```

## GitHub App Authentication

**For Phase 1.5:** Automation workflows will use GitHub App authentication instead of personal access tokens.

### Why GitHub Apps?

- ✅ Fine-grained permissions
- ✅ Organization-level installation
- ✅ Audit trail for all actions
- ✅ No dependency on individual user accounts
- ✅ Automatic token rotation

### Creating GitHub App

```bash
# Phase 1.5: Create app for automation
gh api --method POST /orgs/Seven-Fortunas/apps \
  -f name="Seven Fortunas Automation" \
  -f description="Automation bot for CI/CD and dashboard updates" \
  -f permissions[contents]=write \
  -f permissions[workflows]=write \
  -f permissions[pull_requests]=write
```

## Security Checklist

### Organization Setup
- [x] 2FA requirement enabled
- [x] Default repository permission set to "none"
- [x] Repository creation restricted to owners
- [x] Team-based access control structure created
- [ ] GitHub App created (Phase 1.5)
- [ ] All founders have 2FA enabled (manual verification)

### Per-Repository Setup
- [x] Branch protection rules configured
- [x] Require pull request reviews
- [x] Require status checks before merging
- [x] Secret scanning enabled
- [x] Dependabot alerts enabled

## Compliance

### SOC 2 Requirements

- **Access Control:** Team-based, least privilege
- **Authentication:** 2FA required for all users
- **Audit Trail:** GitHub audit log tracks all access changes
- **Separation of Duties:** Owners approve security changes

### NIST Cybersecurity Framework

- **Identify:** Asset inventory via repository list
- **Protect:** 2FA + team-based access + branch protection
- **Detect:** Secret scanning + Dependabot alerts
- **Respond:** Incident response via Security tab
- **Recover:** Backups via git + GitHub archive

## References

- GitHub Security Best Practices: https://docs.github.com/security
- GitHub Organizations Settings API: https://docs.github.com/rest/orgs
- Team Management: https://docs.github.com/organizations/organizing-members-into-teams

---

**Last Updated:** 2026-02-25
**Maintained By:** Jorge (VP AI-SecOps)
