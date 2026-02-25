# Access Control & Authentication (FR-5.3)

**Feature:** FEATURE_021 - FR-5.3: Access Control & Authentication
**Generated:** 2026-02-25
**Status:** Partially Implemented (2FA requires manual setup, GitHub App in Phase 1.5)

## Overview

This document describes the access control and authentication mechanisms implemented for the Seven Fortunas infrastructure project.

## Implementation Status

| Requirement | Status | Evidence |
|-------------|--------|----------|
| Default repository permission: none | ✅ Implemented | `default_repository_permission: "none"` |
| Team-based access control | ✅ Implemented | 5 teams configured |
| 2FA enforcement | ⚠️ Manual Setup Required | Documented in security-compliance-evidence.md |
| GitHub App for automation | 🔄 Phase 1.5 | Deferred to Phase 1.5 |

## Principle of Least Privilege

### Default Repository Permission

**Setting:** `none`
**Effect:** New members have no repository access by default. All access must be granted explicitly through team membership.

**Verification:**
```bash
gh api /orgs/Seven-Fortunas | jq '.default_repository_permission'
# Expected output: "none"
```

## Team-Based Access Control

All repository access is granted through team membership, not individual grants.

### Public Organization Teams

| Team | Permission | Purpose |
|------|------------|---------|
| Public BD | pull | Business Development and Partnerships |
| Public Community | pull | Community Management and Support |
| Public Engineering | pull | Public Open Source Engineering |
| Public Marketing | pull | Marketing, Communications, and Community Outreach |
| Public Operations | pull | Public Operations and Infrastructure |

**Verification:**
```bash
gh api /orgs/Seven-Fortunas/teams | jq '.[] | {name, permission, description}'
```

### Access Control Model

1. **New Members:** No repository access by default (default_repository_permission: none)
2. **Team Assignment:** Members added to appropriate teams based on role
3. **Repository Access:** Teams granted specific permissions on specific repositories
4. **Principle of Least Privilege:** Minimal permissions required for role

## Two-Factor Authentication (2FA)

### Current Status

**Organization-level 2FA enforcement:** ⚠️ Not yet enabled (requires manual setup by owner)

### Why 2FA Cannot Be Automated

The GitHub API does not allow automated enablement of 2FA requirements. This is intentional to prevent:
- Accidental lockouts
- Unauthorized policy changes
- Members being removed without warning

### Manual Setup Required

**Organization Owner Action Required:**

1. Navigate to: https://github.com/organizations/Seven-Fortunas/settings/security
2. Click "Require two-factor authentication for everyone"
3. Confirm the action

**Before enabling:**
- Notify all organization members 48 hours in advance
- Provide 2FA setup instructions
- Ensure all active members have 2FA configured
- Members without 2FA will be removed from the organization upon enforcement

### Member 2FA Status

**Current members:** 1 (jorge-at-sf)
**2FA verification:** Members can verify their own 2FA status at https://github.com/settings/security

**Note:** Individual member 2FA status is not visible via API for privacy reasons.

## GitHub App for Automation (Phase 1.5)

### Purpose

Replace personal access tokens with GitHub App authentication for automation workflows.

### Benefits

- **Fine-grained permissions:** App only has permissions it needs
- **Audit trail:** All API calls attributed to the app
- **No personal tokens:** Removes dependency on individual accounts
- **Revocable:** Can revoke app access without affecting personal accounts

### Scope

The GitHub App will be used for:
- Dashboard updates (RSS feed aggregation)
- Repository metrics collection
- Automated documentation updates
- GitHub Actions workflows

### Implementation Timeline

**Phase 1.5** (deferred from MVP Day 1)

**Reason for deferral:** GitHub App setup requires:
1. App registration on GitHub
2. Private key management
3. Installation and permissions configuration
4. Integration with existing workflows

This is a non-blocking enhancement that can be implemented after MVP launch.

### Current Authentication Method

**Temporary approach:** GitHub Actions workflows use `GITHUB_TOKEN` (built-in) and personal access tokens for external API calls.

**Migration plan:** Replace PATs with GitHub App tokens in Phase 1.5.

## Verification

### Automated Verification

Run the verification script:
```bash
bash scripts/verify-access-control.sh
```

**Expected output:**
- Default repository permission: none ✓
- Team-based access control: 5 teams configured ✓
- 2FA enforcement: Requires manual setup ⚠️

### Manual Verification

**Check organization settings:**
```bash
gh api /orgs/Seven-Fortunas | jq '{
  default_repository_permission,
  two_factor_requirement_enabled,
  members_can_create_repositories
}'
```

**Check team configuration:**
```bash
gh api /orgs/Seven-Fortunas/teams | jq '.[] | {name, permission, privacy}'
```

**Check member count:**
```bash
gh api /orgs/Seven-Fortunas/members | jq 'length'
```

## Compliance Evidence

**Default Repository Permission:** ✅ Set to "none"
**Team-Based Access:** ✅ 5 teams configured
**2FA Enforcement:** ⚠️ Requires manual setup (documented)
**GitHub App:** 🔄 Phase 1.5 (deferred)

## References

- [GitHub Organization Security Best Practices](https://docs.github.com/en/organizations/keeping-your-organization-secure)
- [Two-Factor Authentication for Organizations](https://docs.github.com/en/organizations/keeping-your-organization-secure/managing-two-factor-authentication-for-your-organization/requiring-two-factor-authentication-in-your-organization)
- [GitHub Apps Documentation](https://docs.github.com/en/apps/creating-github-apps/about-creating-github-apps/about-creating-github-apps)

---

**Last Updated:** 2026-02-25
**Next Review:** After 2FA manual enablement and Phase 1.5 GitHub App implementation
