# GitHub Controls to SOC 2 Trust Service Criteria Mapping

**Version:** 1.0  
**Last Updated:** 2026-02-23  
**Owner:** Jorge (VP AI-SecOps)

## Overview

This document maps GitHub organization security controls to SOC 2 Trust Service Criteria (TSC), enabling compliance evidence collection and audit readiness.

## Trust Service Criteria Categories

1. **CC (Common Criteria)** - Applies to all trust services
2. **A (Availability)** - System availability for operation and use
3. **C (Confidentiality)** - Confidential information protected
4. **P (Processing Integrity)** - System processing complete, valid, accurate
5. **PI (Privacy)** - Personal information collected, used, retained, disclosed

## GitHub Control Mappings

### CC6.1: Logical and Physical Access Controls

#### CC6.1.1: Two-Factor Authentication (2FA)
- **Control ID:** GH-ACCESS-001
- **GitHub Setting:** Organization 2FA requirement
- **Implementation:** `two_factor_requirement_enabled = true`
- **Evidence Source:** `GET /orgs/{org}`
- **Collection Frequency:** Daily
- **Compliance Status:** Implemented (FEATURE_021)

#### CC6.1.2: Default Repository Permission
- **Control ID:** GH-ACCESS-002
- **GitHub Setting:** Default repository permission = none
- **Implementation:** `default_repository_permission = "none"`
- **Evidence Source:** `GET /orgs/{org}`
- **Collection Frequency:** Daily
- **Compliance Status:** Implemented (FEATURE_021)

#### CC6.1.3: Team-Based Access Control
- **Control ID:** GH-ACCESS-003
- **GitHub Setting:** Team-based repository access (no individual grants)
- **Implementation:** Teams configured with least privilege
- **Evidence Source:** `GET /orgs/{org}/teams`, `GET /repos/{owner}/{repo}/teams`
- **Collection Frequency:** Daily
- **Compliance Status:** Implemented (FEATURE_003)

### CC6.6: Logical Access - Authentication and Authorization

#### CC6.6.1: GitHub App Authentication
- **Control ID:** GH-AUTH-001
- **GitHub Setting:** GitHub Apps for automation (not personal tokens)
- **Implementation:** GitHub App with scoped permissions
- **Evidence Source:** `GET /orgs/{org}/installations`
- **Collection Frequency:** Daily
- **Compliance Status:** Planned (Phase 1.5)

### CC7.2: System Monitoring

#### CC7.2.1: Secret Detection
- **Control ID:** GH-SEC-001
- **GitHub Setting:** Secret scanning enabled with push protection
- **Implementation:** 
  - `secret_scanning_enabled_for_new_repositories = true`
  - `secret_scanning_push_protection_enabled_for_new_repositories = true`
- **Evidence Source:** `GET /orgs/{org}`, `GET /repos/{owner}/{repo}`
- **Collection Frequency:** Daily
- **Compliance Status:** Implemented (FEATURE_019)

#### CC7.2.2: Dependency Vulnerability Management
- **Control ID:** GH-SEC-002
- **GitHub Setting:** Dependabot alerts and security updates
- **Implementation:**
  - `dependabot_alerts_enabled_for_new_repositories = true`
  - `dependabot_security_updates_enabled_for_new_repositories = true`
- **Evidence Source:** `GET /orgs/{org}`, `GET /repos/{owner}/{repo}/dependabot/alerts`
- **Collection Frequency:** Daily
- **Compliance Status:** Implemented (FEATURE_020)

#### CC7.2.3: Branch Protection
- **Control ID:** GH-SEC-003
- **GitHub Setting:** Branch protection on main branches
- **Implementation:** 
  - Require pull request reviews
  - Require status checks to pass
  - Enforce for administrators
- **Evidence Source:** `GET /repos/{owner}/{repo}/branches/{branch}/protection`
- **Collection Frequency:** Daily
- **Compliance Status:** Implemented (FEATURE_006)

### CC8.1: Change Management

#### CC8.1.1: Pull Request Reviews
- **Control ID:** GH-CHANGE-001
- **GitHub Setting:** Required reviews before merge
- **Implementation:** Branch protection requires PR reviews
- **Evidence Source:** `GET /repos/{owner}/{repo}/branches/{branch}/protection`
- **Collection Frequency:** Daily
- **Compliance Status:** Implemented (FEATURE_006)

#### CC8.1.2: Status Checks
- **Control ID:** GH-CHANGE-002
- **GitHub Setting:** Required status checks before merge
- **Implementation:** Branch protection requires passing CI/CD
- **Evidence Source:** `GET /repos/{owner}/{repo}/branches/{branch}/protection`
- **Collection Frequency:** Daily
- **Compliance Status:** Implemented (FEATURE_006)

### A1.2: System Availability Monitoring

#### A1.2.1: Dependabot Auto-Merge
- **Control ID:** GH-AVAIL-001
- **GitHub Setting:** Automated dependency updates
- **Implementation:** Dependabot auto-merge for security patches
- **Evidence Source:** `GET /repos/{owner}/{repo}/actions/workflows`
- **Collection Frequency:** Daily
- **Compliance Status:** Implemented (FEATURE_020)

## Evidence Collection Requirements

### Daily Evidence Collection
The following GitHub API endpoints should be queried daily to collect compliance evidence:

1. **Organization Settings**
   - `GET /orgs/Seven-Fortunas-Internal`
   - Fields: `two_factor_requirement_enabled`, `default_repository_permission`, security settings

2. **Team Structure**
   - `GET /orgs/Seven-Fortunas-Internal/teams`
   - Verify team-based access control

3. **Repository Settings** (for each repository)
   - `GET /repos/{owner}/{repo}`
   - Fields: security settings, branch protection

4. **Branch Protection** (for each repository)
   - `GET /repos/{owner}/{repo}/branches/main/protection`
   - Verify required reviews, status checks

5. **Dependabot Alerts** (for each repository)
   - `GET /repos/{owner}/{repo}/dependabot/alerts`
   - Track vulnerability remediation

6. **GitHub App Installations**
   - `GET /orgs/Seven-Fortunas-Internal/installations`
   - Verify GitHub App authentication

## Compliance Dashboard Metrics

### Real-Time Control Posture
- **2FA Enforcement:** Enabled/Disabled
- **Default Permission:** none/read/write
- **Secret Scanning:** Enabled/Disabled
- **Push Protection:** Enabled/Disabled
- **Dependabot Alerts:** Count of open alerts
- **Branch Protection:** Protected/Unprotected branches
- **Team-Based Access:** Percentage of repositories with team access

### Drift Detection
- Alert when control settings change from compliant to non-compliant
- Alert when new repositories are created without security settings
- Alert when team access is bypassed with individual grants

## Evidence Retention

- **Collection Frequency:** Daily
- **Retention Period:** 7 years (SOC 2 requirement)
- **Storage Location:** CISO Assistant database
- **Backup:** GitHub Actions artifacts (90 days)

## Audit Trail

All evidence collection activities are logged with:
- Timestamp (UTC)
- Control ID
- Evidence source (API endpoint)
- Collected value
- Compliance status (pass/fail)

## Next Steps (Phase 1.5)

1. **Migrate CISO Assistant** to Seven-Fortunas-Internal organization
2. **Implement Evidence Sync Script** using GitHub Actions
3. **Create Compliance Dashboard** for real-time monitoring
4. **Configure Drift Alerts** for control changes
5. **Document Audit Procedures** for SOC 2 readiness

---

**Document Control:**
- **Created:** 2026-02-23
- **Author:** Jorge (with Claude Sonnet 4.5)
- **Review Frequency:** Quarterly
- **Next Review:** 2026-05-23
