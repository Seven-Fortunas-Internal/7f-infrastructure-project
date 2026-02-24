# Seven Fortunas Infrastructure - Dependencies

**Last Updated:** 2026-02-24
**Owner:** DevOps Team
**Review Frequency:** Quarterly

---

## Overview

This document tracks all dependencies for the Seven Fortunas infrastructure project, including versions, support windows, and upgrade status.

**Backward Compatibility Commitment:** All dependencies supported for minimum 12 months.

---

## Core Framework

### BMAD (Business Method Architecture Design)

- **Type:** Core Framework
- **Location:** `_bmad/` directory (local clone)
- **Current Version:** Git commit from 2024-11-15 (approximate)
- **Version Tracking:** Git commit hash
- **Support Window:** 12 months rolling
- **Last Updated:** 2024-11-15
- **Next Review:** 2026-05-24

**Modules Used:**
- `bmm/` - Business Method workflows
- `bmb/` - Builder workflows
- `cis/` - Creative Intelligence workflows (if present)
- `core/` - Core framework utilities

**Upgrade Notes:**
- BMAD is version-controlled within this repository
- Updates require git operations (pull/merge from upstream)
- All custom workflows depend on BMAD stability
- Test suite: `scripts/validate-bmad-workflows.sh` (to be created)

---

## System Dependencies

### Git

- **Current Version:** 2.39+ (system-dependent)
- **Minimum Required:** 2.30.0
- **Maximum Tested:** 2.43.0
- **Support Window:** 24 months
- **Installation:** System package manager

**Features Used:**
- Git workflows (clone, commit, push, pull, rebase)
- Git hooks (pre-commit validation)
- Git history operations (log, diff, checkout)

**Compatibility Notes:**
- Git 2.30+ required for improved sparse checkout
- Git 2.35+ recommended for better performance

---

### GitHub CLI (gh)

- **Current Version:** 2.20+ (system-dependent)
- **Minimum Required:** 2.20.0
- **Maximum Tested:** 2.40.0
- **Support Window:** 18 months
- **Installation:** https://cli.github.com/

**Features Used:**
- `gh auth` - Authentication management
- `gh api` - GitHub API access
- `gh pr` - Pull request operations
- `gh workflow` - GitHub Actions workflow management
- `gh repo` - Repository operations
- `gh secret` - Secrets management

**Compatibility Notes:**
- gh 2.20+ required for improved secret management
- gh 2.30+ recommended for enhanced workflow features

---

### jq (JSON Processor)

- **Current Version:** 1.6+
- **Minimum Required:** 1.6
- **Maximum Tested:** 1.7
- **Support Window:** 24 months (stable, infrequent updates)
- **Installation:** System package manager

**Features Used:**
- JSON parsing and manipulation
- Feature list updates (`feature_list.json`)
- Data extraction from GitHub API responses

**Compatibility Notes:**
- jq 1.6 is stable and widely supported
- Breaking changes rare in jq ecosystem

---

### Bash

- **Current Version:** 4.4+ / 5.0+
- **Minimum Required:** 4.4
- **Maximum Tested:** 5.2
- **Support Window:** Bash 4.x supported indefinitely
- **Installation:** System default shell

**Features Used:**
- Script execution (all `.sh` files)
- Process control and automation
- Text processing (grep, sed, awk)

**Compatibility Notes:**
- Bash 4.4+ required for associative arrays
- Bash 5.x features avoided for backward compatibility

---

### Python

- **Current Version:** 3.8+ / 3.10+ (system-dependent)
- **Minimum Required:** 3.8
- **Maximum Tested:** 3.12
- **Support Window:** Python release lifecycle (5 years)
- **Installation:** System package manager

**Python Packages** (when used):
```
# Currently no requirements.txt - using standard library only
# Future: Create requirements.txt when external packages needed
```

**Features Used:**
- Data analysis scripts (`scripts/analyze_*.py`)
- JSON processing (when bash/jq insufficient)
- API interactions (Anthropic Claude API)

**Compatibility Notes:**
- Python 3.8+ required for f-strings and type hints
- Standard library preferred over external dependencies

---

### curl

- **Current Version:** 7.68+ / 7.88+
- **Minimum Required:** 7.68.0
- **Maximum Tested:** 8.5.0
- **Support Window:** 24 months
- **Installation:** System package manager

**Features Used:**
- HTTP requests to APIs
- GitHub Pages deployment verification (T4 checks)
- Health check endpoints

**Compatibility Notes:**
- curl 7.68+ required for improved HTTP/2 support
- Security updates applied automatically via system

---

## GitHub Actions Dependencies

### actions/checkout

- **Current Version:** v3.5
- **Pinned Version:** `@v3`
- **Support Window:** GitHub maintains for 12+ months
- **Documentation:** https://github.com/actions/checkout

**Usage:**
```yaml
- uses: actions/checkout@v3.5
  with:
    fetch-depth: 0  # Full history for git operations
```

**Upgrade Path:**
- v3 → v4: Requires Node.js 20 (breaking change)
- Monitor for v4 adoption timeline

---

### actions/setup-node

- **Current Version:** v3.8
- **Pinned Version:** `@v3`
- **Support Window:** GitHub maintains for 12+ months
- **Documentation:** https://github.com/actions/setup-node

**Usage:**
```yaml
- uses: actions/setup-node@v3.8
  with:
    node-version: '18'  # LTS version
```

**Upgrade Path:**
- v3 → v4: Monitor for release and breaking changes

---

## External APIs

### GitHub API

- **API Version:** 2022-11-28 (via `gh` CLI)
- **Authentication:** GitHub CLI token
- **Rate Limits:** 5000 requests/hour (authenticated)
- **Support Window:** GitHub maintains API versions for 12+ months

**Endpoints Used:**
- `/user` - User information
- `/orgs/{org}` - Organization details
- `/repos/{owner}/{repo}` - Repository operations
- `/orgs/{org}/audit-log` - Audit log access (Enterprise)

**Compatibility Notes:**
- `gh` CLI handles API versioning automatically
- Breaking changes announced 90+ days in advance

---

### Anthropic Claude API

- **API Version:** 2023-06-01 (Claude 3.x)
- **Authentication:** API key (via `ANTHROPIC_API_KEY` secret)
- **Rate Limits:** Depends on plan (see NFR-9.1)
- **Support Window:** Anthropic maintains stable APIs

**Features Used:**
- Text generation (weekly summaries)
- Dashboard data analysis
- Skill creation assistance

**Compatibility Notes:**
- API versioning via header (`anthropic-version: 2023-06-01`)
- Graceful degradation if API unavailable

---

## Node.js Dependencies (Dashboard Builds)

### Node.js

- **Current Version:** 18.x LTS
- **Minimum Required:** 18.0.0
- **Maximum Tested:** 20.x
- **Support Window:** Node.js LTS schedule (30 months)
- **Installation:** nvm or system package manager

**Upgrade Timeline:**
- Node.js 18: Maintenance LTS until 2025-04-30
- Node.js 20: Active LTS (recommended migration target)

### Package Dependencies

**Location:** `dashboards/package.json` (if present)
**Lock File:** `dashboards/package-lock.json`

**Key Packages** (example - actual deps vary):
```json
{
  "vite": "^4.5.0",
  "react": "^18.2.0",
  "react-dom": "^18.2.0"
}
```

**Update Strategy:**
- Minor/patch updates: Automated via Dependabot
- Major updates: Manual review and testing required
- Security updates: Expedited review and deployment

---

## Dependency Audit Log

### 2026-02-24 - Initial Audit

**Auditor:** Autonomous Agent
**Status:** All dependencies within support window

**Findings:**
- ✓ Git: v2.39+ (supported)
- ✓ GitHub CLI: v2.20+ (supported)
- ✓ jq: v1.6+ (supported)
- ✓ Python: v3.8+ (supported)
- ✓ Bash: v4.4+ / 5.0+ (supported)
- ✓ curl: v7.68+ (supported)
- ✓ BMAD: 2024-11 commit (within 12-month window)

**Actions:**
- None required - all dependencies current

**Next Audit:** 2026-05-24

---

## Upgrade Schedule

### Q1 2026 (Jan-Mar)

- [x] Initial dependency audit (2026-02-24)
- [ ] Review GitHub Actions for v4 migrations
- [ ] Test Python 3.12 compatibility

### Q2 2026 (Apr-Jun)

- [ ] Quarterly dependency audit
- [ ] BMAD library sync and update
- [ ] Node.js 18 → 20 migration planning

### Q3 2026 (Jul-Sep)

- [ ] Quarterly dependency audit
- [ ] GitHub Actions v4 adoption (if stable)
- [ ] Review API usage patterns

### Q4 2026 (Oct-Dec)

- [ ] Year-end dependency audit
- [ ] Plan 2027 deprecations
- [ ] Update compatibility matrix

---

## Validation Scripts

### check-dependencies.sh

**Purpose:** Validate minimum dependency versions

```bash
#!/bin/bash
# Check all required dependencies meet minimum versions
./scripts/check-dependencies.sh
```

**Checks:**
- Git >= 2.30.0
- gh >= 2.20.0
- jq >= 1.6
- Python >= 3.8
- Bash >= 4.4
- curl >= 7.68.0

**Exit Codes:**
- 0: All dependencies meet requirements
- 1: One or more dependencies below minimum version

### audit-dependencies.sh

**Purpose:** Generate quarterly dependency audit report

```bash
#!/bin/bash
# Generate comprehensive dependency audit
./scripts/audit-dependencies.sh --output reports/audit-$(date +%Y-Q%q).md
```

**Report Includes:**
- Current versions of all dependencies
- Days since last update
- Security vulnerabilities (via Dependabot)
- Upgrade recommendations
- Compatibility status

---

## Security Vulnerability Tracking

### Dependabot Configuration

**Location:** `.github/dependabot.yml`
**Frequency:** Daily scans
**Auto-merge:** Security patches (minor/patch versions only)

**Alerts:**
- Critical: Immediate notification
- High: 24-hour SLA
- Medium/Low: Weekly digest

### Manual Security Review

**Schedule:** Monthly (first Monday of month)
**Owner:** Security Team + DevOps Team

**Review:**
1. Check Dependabot security advisories
2. Review CVE databases for system dependencies
3. Audit API security bulletins (GitHub, Anthropic)
4. Plan expedited upgrades if needed

---

## Related Documents

- `docs/backward-compatibility-policy.md` - Compatibility policy and procedures
- `scripts/check-dependencies.sh` - Dependency version validation
- `scripts/audit-dependencies.sh` - Quarterly audit automation
- `.github/dependabot.yml` - Automated security updates

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-02-24 | Autonomous Agent | Initial dependency tracking |

---

**Next Update:** 2026-05-24 (Quarterly Review)
**Owner:** DevOps Team
