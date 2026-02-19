# Scripts

## Purpose

Automation scripts for Seven Fortunas infrastructure setup, maintenance, and compliance.

## Contents

### Organization Setup
- `create_github_orgs.sh` - Create GitHub organizations (Internal/Public)
- `configure_teams.sh` - Set up team structure
- `configure_security_settings.sh` - Organization security configuration
- `configure_access_control.sh` - 2FA enforcement and access control
- `audit_access_control.sh` - Access control compliance audit

### Repository Management
- `create_repositories.sh` - Create and configure repositories
- `configure_branch_protection.sh` - Branch protection rules

### Security & Compliance
- `setup_secret_detection.sh` - Secret detection configuration
- `setup_dependabot.sh` - Dependabot vulnerability management
- `collect_soc2_evidence.py` - Daily SOC 2 evidence collection

### Dashboard Management
- `update_ai_dashboard.py` - AI Advancements Dashboard updater
- `update_dashboard.py` - Universal dashboard updater (all dashboards)
- `generate_weekly_summary.py` - AI-generated weekly summaries
- `check_dashboard_health.py` - Dashboard health checker
- `dashboard_curator.py` - Interactive dashboard configuration tool

### BMAD Integration
- `setup_bmad_integration.sh` - BMAD library integration

### Validation
- `validate_github_auth.sh` - GitHub CLI authentication check
- `validate_readme_coverage.sh` - README coverage validator

## Usage

### Prerequisites

All scripts require:
- GitHub CLI (`gh`) installed and authenticated
- Appropriate permissions (organization owner for most operations)
- Python 3.11+ (for Python scripts)

### Running Scripts

```bash
# Make script executable (if needed)
chmod +x scripts/script_name.sh

# Run script
./scripts/script_name.sh

# Or with arguments
./scripts/script_name.sh --option value
```

### Python Scripts

```bash
# Install dependencies
pip install -r requirements.txt

# Run script
python3 scripts/script_name.py

# With arguments
python3 scripts/script_name.py --config path/to/config.yaml
```

## Script Categories

### Daily Automation
- SOC 2 evidence collection (9am UTC)
- Dashboard updates (every 6 hours)
- Weekly summaries (Sunday 9am UTC)

### One-Time Setup
- Organization creation
- Team configuration
- Security settings
- Repository creation

### Maintenance
- Audit access control
- Validate README coverage
- Check dashboard health

## Dependencies

Python scripts require:
- `feedparser` - RSS feed parsing
- `requests` - HTTP requests
- `pyyaml` - YAML parsing
- `anthropic` - Claude API integration
- `praw` (optional) - Reddit API

Install all:
```bash
pip install feedparser requests pyyaml anthropic praw beautifulsoup4
```

---

**Owner:** Seven Fortunas Infrastructure Team
**Related:** [docs/](../docs/README.md) | [dashboards/](../dashboards/README.md)
