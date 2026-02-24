# SOC 2 Control Mapping

## Overview

This document maps Seven Fortunas GitHub security controls to SOC 2 Trust Service Criteria (TSC).

**Status:** Phase 1.5 (Preparation)
**Owner:** Jorge (VP AI-SecOps)
**CISO Assistant:** To be migrated to Seven-Fortunas-Internal org

---

## Trust Service Criteria Coverage

### CC6.1: Logical and Physical Access Controls

**Control:** The entity implements logical access security software, infrastructure, and architectures over protected information assets to protect them from security events.

#### GitHub Controls

| Control ID | Description | Implementation | Evidence |
|------------|-------------|----------------|----------|
| GH-AC-001 | 2FA Required | Organization-wide 2FA enforcement | API: `/orgs/{org}/members` (2FA status) |
| GH-AC-002 | Default Repo Permission: None | Least privilege by default | API: `/orgs/{org}` (default_repository_permission) |
| GH-AC-003 | Team-Based Access | No individual grants | API: `/orgs/{org}/teams` |
| GH-AC-004 | Branch Protection | Main branch protection required | API: `/repos/{owner}/{repo}/branches/{branch}/protection` |

**Compliance Status:** ✅ Implemented (FR-5.3)

---

### CC6.6: Logical and Physical Access Controls - Removal

**Control:** The entity discontinues logical and physical protections over physical assets only after the ability to read or recover data and software from those assets has been diminished.

#### GitHub Controls

| Control ID | Description | Implementation | Evidence |
|------------|-------------|----------------|----------|
| GH-AC-005 | Access Revocation | Immediate removal via GitHub API | API: `/orgs/{org}/members/{user}` (DELETE) |
| GH-AC-006 | Token Expiration | GitHub App tokens expire automatically | App installation logs |
| GH-AC-007 | SSH Key Management | User SSH keys removed on offboarding | API: `/users/{user}/keys` |

**Compliance Status:** ⏸️ Planned (Phase 1.5)

---

### CC7.1: System Operations

**Control:** To meet its objectives, the entity uses detection and monitoring procedures to identify anomalies and events that could impact system operations.

#### GitHub Controls

| Control ID | Description | Implementation | Evidence |
|------------|-------------|----------------|----------|
| GH-MO-001 | Secret Detection | Push protection + scanning | API: `/repos/{owner}/{repo}/secret-scanning/alerts` |
| GH-MO-002 | Dependabot Alerts | Automated vulnerability scanning | API: `/repos/{owner}/{repo}/dependabot/alerts` |
| GH-MO-003 | Code Scanning | SARIF upload + CodeQL | API: `/repos/{owner}/{repo}/code-scanning/alerts` |
| GH-MO-004 | Audit Logging | Organization audit log | API: `/orgs/{org}/audit-log` |

**Compliance Status:** ✅ Implemented (FR-5.1, FR-5.2)

---

### CC7.2: System Operations - Monitoring

**Control:** The entity monitors system components and the operation of those components for anomalies that are indicative of malicious acts, natural disasters, and errors.

#### GitHub Controls

| Control ID | Description | Implementation | Evidence |
|------------|-------------|----------------|----------|
| GH-MO-005 | Failed Login Attempts | GitHub tracks failed auth attempts | Organization security log |
| GH-MO-006 | Unusual Activity | GitHub Advanced Security alerts | Security overview dashboard |
| GH-MO-007 | API Rate Limiting | Automatic protection against abuse | API rate limit headers |

**Compliance Status:** ⏸️ Planned (Phase 1.5)

---

### CC7.3: System Operations - Evaluation and Management

**Control:** The entity evaluates security events to determine whether they could or have resulted in a failure of the entity to meet its objectives and, if so, takes actions to prevent or address such failures.

#### GitHub Controls

| Control ID | Description | Implementation | Evidence |
|------------|-------------|----------------|----------|
| GH-IM-001 | Secret Leak Response | Auto-revoke + notify | Incident response playbook |
| GH-IM-002 | Vulnerability Patching | Dependabot auto-PR | Pull request history |
| GH-IM-003 | Security Advisory | Create advisory for found issues | API: `/repos/{owner}/{repo}/security-advisories` |

**Compliance Status:** ⏸️ Planned (Phase 1.5)

---

### CC8.1: Change Management

**Control:** The entity authorizes, designs, develops or acquires, implements, operates, approves, maintains, and monitors environmental protections, software, data backup processes, and recovery infrastructure to meet its objectives.

#### GitHub Controls

| Control ID | Description | Implementation | Evidence |
|------------|-------------|----------------|----------|
| GH-CM-001 | Branch Protection | Require PR reviews before merge | Branch protection rules |
| GH-CM-002 | CODEOWNERS | Mandatory code owner reviews | CODEOWNERS file |
| GH-CM-003 | Required Status Checks | CI/CD must pass before merge | Status check configuration |
| GH-CM-004 | Signed Commits | GPG signature verification | Commit signature verification |

**Compliance Status:** ✅ Implemented (FR-1.6)

---

## Evidence Collection Strategy

### Automated Evidence Collection

**Script:** `scripts/collect_soc2_evidence.py`
**Frequency:** Daily (GitHub Actions cron: 0 9 * * *)
**Storage:** `compliance/evidence/{YYYY-MM-DD}/`

#### Collected Evidence

1. **2FA Status Report**
   - API: `/orgs/{org}/members` (filter by 2FA)
   - Output: `2fa_status.json`

2. **Access Control Configuration**
   - API: `/orgs/{org}` (default permissions)
   - Output: `access_control_config.json`

3. **Secret Scanning Alerts**
   - API: `/repos/{owner}/{repo}/secret-scanning/alerts`
   - Output: `secret_scanning_alerts.json`

4. **Dependabot Alerts**
   - API: `/repos/{owner}/{repo}/dependabot/alerts`
   - Output: `dependabot_alerts.json`

5. **Branch Protection Status**
   - API: `/repos/{owner}/{repo}/branches/{branch}/protection`
   - Output: `branch_protection.json`

6. **Audit Log**
   - API: `/orgs/{org}/audit-log`
   - Output: `audit_log.json`

---

## CISO Assistant Integration

### Repository Setup

**Organization:** Seven-Fortunas-Internal
**Repository:** `ciso-assistant`
**Fork Source:** https://github.com/intuitem/ciso-assistant-community

### Migration Steps

1. **Fork CISO Assistant**
   ```bash
   gh repo fork intuitem/ciso-assistant-community \
     --org Seven-Fortunas-Internal \
     --fork-name ciso-assistant \
     --clone
   ```

2. **Configure for Seven Fortunas**
   - Update branding
   - Configure organization settings
   - Import control library

3. **Import Control Mappings**
   - Load GitHub control mappings (this document)
   - Map to SOC 2 TSC
   - Configure evidence collection

4. **Deploy**
   - Self-hosted (AWS/GCP/Azure)
   - OR: Cloud-hosted (ciso-assistant.com)

### Evidence Sync

**Script:** `scripts/sync_evidence_to_ciso_assistant.py`
**Frequency:** Daily (after evidence collection)
**Method:** CISO Assistant API

---

## Compliance Dashboard

### Real-Time Control Posture

**Location:** `dashboards/compliance/README.md`
**Data Source:** Daily evidence collection + CISO Assistant API

#### Dashboard Metrics

- **Overall Compliance Score** (% of controls passing)
- **Control Status by TSC** (CC6.1, CC6.6, CC7.1, etc.)
- **Open Findings** (non-compliant controls)
- **Evidence Collection Status** (last run, success rate)
- **Control Drift Alerts** (changes detected)

---

## Compliance Roadmap

### Phase 1.5 (Current)
- ✅ Map GitHub controls to SOC 2 TSC
- ⏸️ Migrate CISO Assistant to Seven-Fortunas-Internal
- ⏸️ Implement automated evidence collection
- ⏸️ Create compliance dashboard

### Phase 2
- Implement missing controls (GH-AC-005, GH-MO-005, GH-IM-001)
- Document incident response procedures
- Conduct internal compliance audit
- Address identified gaps

### Phase 3
- Engage SOC 2 auditor
- Complete Type I audit
- Implement continuous monitoring
- Prepare for Type II audit

---

## References

- **SOC 2 Trust Service Criteria:** https://www.aicpa.org/soc-for-service-organizations
- **GitHub Security Best Practices:** https://docs.github.com/en/organizations/keeping-your-organization-secure
- **CISO Assistant:** https://github.com/intuitem/ciso-assistant-community

---

**Document Version:** 1.0
**Last Updated:** 2026-02-18
**Next Review:** 2026-03-18
