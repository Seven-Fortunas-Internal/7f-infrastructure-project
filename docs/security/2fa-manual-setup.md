# 2FA Manual Setup Guide

**Feature:** FR-5.3 Access Control & Authentication
**Requirement:** 2FA enforcement for all organization members
**Status:** Requires manual setup (GitHub API limitation)
**Last Updated:** 2026-03-02

---

## Why Manual Setup?

The GitHub API does not allow automated 2FA enforcement. This is intentional to prevent:
- Accidental member lockouts
- Unauthorized policy changes
- Members being removed without warning

**Reference:** https://docs.github.com/en/rest/orgs/orgs#update-an-organization

---

## Prerequisites

Before enabling 2FA enforcement:

1. **Notify members 48 hours in advance**
   ```
   Subject: 2FA Requirement - Action Required

   In 48 hours, two-factor authentication (2FA) will be required for all
   members of Seven-Fortunas and Seven-Fortunas-Internal organizations.

   If you don't have 2FA enabled, you will be removed from the organization.

   Setup instructions: https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa
   ```

2. **Verify critical members have 2FA**
   - Members can check at: https://github.com/settings/security
   - Look for "Two-factor authentication" section with green checkmark

3. **Backup recovery codes**
   - All members should save recovery codes before enforcement

---

## Setup Steps

### For Seven-Fortunas (Public)

1. **Navigate to org security settings:**
   ```
   https://github.com/organizations/Seven-Fortunas/settings/security
   ```

2. **Enable 2FA requirement:**
   - Scroll to "Two-factor authentication"
   - Click "Require two-factor authentication for everyone in the Seven-Fortunas organization"
   - Review warning
   - Click "Require two-factor authentication"

3. **Verify enforcement:**
   ```bash
   gh api orgs/Seven-Fortunas --jq '.two_factor_requirement_enabled'
   # Should return: true
   ```

### For Seven-Fortunas-Internal (Private)

1. **Navigate to org security settings:**
   ```
   https://github.com/organizations/Seven-Fortunas-Internal/settings/security
   ```

2. **Enable 2FA requirement:**
   - Scroll to "Two-factor authentication"
   - Click "Require two-factor authentication for everyone in the Seven-Fortunas-Internal organization"
   - Review warning
   - Click "Require two-factor authentication"

3. **Verify enforcement:**
   ```bash
   gh api orgs/Seven-Fortunas-Internal --jq '.two_factor_requirement_enabled'
   # Should return: true
   ```

---

## What Happens When Enabled?

### Immediate Effects

- Members **without** 2FA are removed from the organization
- Members **with** 2FA retain access
- New invitations require 2FA before acceptance

### Member Experience

**Members with 2FA already enabled:**
- No disruption
- Continue working normally

**Members without 2FA:**
- Removed from organization immediately
- Receive email notification
- Can re-join after enabling 2FA

---

## Verification

### Check 2FA Status

**Organization-level:**
```bash
gh api orgs/Seven-Fortunas --jq '.two_factor_requirement_enabled'
gh api orgs/Seven-Fortunas-Internal --jq '.two_factor_requirement_enabled'
```

**Current members (count):**
```bash
gh api orgs/Seven-Fortunas/members | jq 'length'
gh api orgs/Seven-Fortunas-Internal/members | jq 'length'
```

**Expected after enforcement:**
- `two_factor_requirement_enabled: true`
- Member count unchanged (if all had 2FA)

---

## Rollback

If 2FA enforcement causes issues:

1. **Navigate to security settings** (same URLs as above)
2. **Disable 2FA requirement:**
   - Scroll to "Two-factor authentication"
   - Click "Disable two-factor authentication requirement"
3. **Re-invite removed members**
4. **Communicate new timeline for 2FA enablement**

---

## Current Status

| Organization | 2FA Enforced | Members | Teams |
|--------------|--------------|---------|-------|
| Seven-Fortunas | ❌ Not yet | 1 | 5 |
| Seven-Fortunas-Internal | ❌ Not yet | 1 | 0 |

**Next Action:** Enable 2FA enforcement via web UI (owner action required)

---

## See Also

- [GitHub 2FA Documentation](https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa)
- [Requiring 2FA in Organizations](https://docs.github.com/en/organizations/keeping-your-organization-secure/managing-two-factor-authentication-for-your-organization/requiring-two-factor-authentication-in-your-organization)
- [Access Control Verification](./access-control-enforcement-verification.md)

---

**Owner:** Jorge (VP AI-SecOps)
**Action:** Enable 2FA via web UI after member notification
