# Compliance

## Purpose

SOC 2 compliance artifacts, evidence collection, and audit trails.

## Contents

### CISO Assistant (`ciso-assistant/`)
Open-source GRC platform for managing SOC 2 compliance.

- **deployment-guide.md**: Step-by-step deployment instructions
- **Integration**: GitHub OAuth for authentication, GitHub API for evidence collection

### SOC 2 Mapping (`soc2-mapping/`)
Maps GitHub security controls to SOC 2 Trust Service Criteria.

- **github-controls-to-soc2.yaml**: Control mapping specification
- **Coverage**: CC6.1 (Access Controls), CC6.6 (Access Removal), CC7.2 (Monitoring), CC7.3 (Monitoring Evaluation), CC8.1 (Change Management)

### Evidence Collection

Evidence is collected daily at 2:00 AM UTC via GitHub Actions.

**Script:** `evidence-collection/collect-github-evidence.py`
**Workflow:** `.github/workflows/soc2-evidence-collection.yml`
**Retention:** 365 days (SOC 2 requirement)

#### Directory Structure

```
compliance/
├── ciso-assistant/          # CISO Assistant deployment guide
├── soc2-mapping/            # GitHub → SOC 2 control mapping
├── evidence-collection/     # Automated evidence scripts
├── evidence/                # Collected evidence (date-stamped)
│   ├── 2026-02-18/
│   │   ├── 2fa_status.json
│   │   ├── access_control_config.json
│   │   ├── secret_scanning_alerts.json
│   │   ├── dependabot_alerts.json
│   │   ├── branch_protection.json
│   │   ├── audit_log.json
│   │   └── summary.json
│   └── 2026-02-19/
│       └── ...
└── README.md
```

## Evidence Types

### 1. 2FA Status Report
**File:** `2fa_status.json`
**Control:** GH-AC-001 (CC6.1)
**Content:** 2FA status for all organization members

### 2. Access Control Configuration
**File:** `access_control_config.json`
**Control:** GH-AC-002, GH-AC-003 (CC6.1)
**Content:** Organization access control settings

### 3. Secret Scanning Alerts
**File:** `secret_scanning_alerts.json`
**Control:** GH-MO-001 (CC7.1)
**Content:** Secret detection alerts across all repositories

### 4. Dependabot Alerts
**File:** `dependabot_alerts.json`
**Control:** GH-MO-002 (CC7.1)
**Content:** Vulnerability alerts across all repositories

### 5. Branch Protection Status
**File:** `branch_protection.json`
**Control:** GH-CM-001 (CC8.1)
**Content:** Branch protection configuration for all repositories

### 6. Audit Log
**File:** `audit_log.json`
**Control:** GH-MO-004 (CC7.1)
**Content:** Organization audit log (last 7 days)

## Automation

**Script:** `scripts/collect_soc2_evidence.py`
**Frequency:** Daily (9am UTC)
**Workflow:** `.github/workflows/collect-soc2-evidence.yml`

## Usage

### Manual Evidence Collection

```bash
python3 scripts/collect_soc2_evidence.py
```

### View Latest Evidence

```bash
# Find latest evidence directory
ls -t compliance/evidence/ | head -1

# View summary
cat compliance/evidence/$(ls -t compliance/evidence/ | head -1)/summary.json
```

## Compliance Dashboard

Real-time compliance posture: [dashboards/compliance/](../dashboards/compliance/README.md)

## Documentation

- [SOC 2 Control Mapping](../docs/soc2-control-mapping.md)
- [Evidence Collection Script](../scripts/collect_soc2_evidence.py)

---

**Owner:** Jorge (VP AI-SecOps)
**Status:** Phase 1.5 (Preparation)
**Related:** [dashboards/compliance/](../dashboards/compliance/README.md) | [docs/](../docs/README.md)
