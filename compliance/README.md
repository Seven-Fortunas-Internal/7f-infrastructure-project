# Compliance

## Purpose

SOC 2 compliance artifacts, evidence collection, and audit trails.

## Contents

### Evidence Collection

Evidence is collected daily at 9am UTC via GitHub Actions and stored in date-stamped directories.

#### Directory Structure

```
compliance/
├── evidence/
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
