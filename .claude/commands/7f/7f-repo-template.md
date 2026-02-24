# 7f-repo-template

**Seven Fortunas Custom Skill** - Generate repository templates with Seven Fortunas standards

---

## Metadata

```yaml
source_bmad_skill: N/A (original Seven Fortunas skill)
created_by: Seven Fortunas Infrastructure Team
version: 1.0.0
created: 2026-02-17
integration: GitHub repository creation
```

---

## Purpose

Generate complete repository templates following Seven Fortunas standards, including README, CLAUDE.md, directory structure, CI/CD configuration, and security policies.

---

## Usage

```bash
/7f-repo-template <repo-type> <repo-name> [options]
```

**Repository Types:**
- `application`: Application/service repository
- `library`: Shared library or package
- `infrastructure`: Infrastructure-as-code repository
- `documentation`: Documentation-only repository
- `dashboard`: Dashboard/UI repository

**Options:**
- `--language <lang>`: Primary language (python, typescript, go, etc.)
- `--framework <name>`: Framework (django, react, terraform, etc.)
- `--visibility <level>`: public, internal, private
- `--team <name>`: Owning team
- `--security-level <level>`: standard, high, critical

---

## Workflow

### 1. Initialize Repository Structure

**Base structure (all repos):**
```
<repo-name>/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml
│   │   ├── security-scan.yml
│   │   └── dependency-check.yml
│   ├── CODEOWNERS
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── ISSUE_TEMPLATE/
│       ├── bug_report.md
│       ├── feature_request.md
│       └── security_report.md
├── .claude/
│   ├── CLAUDE.md
│   └── commands/ (if applicable)
├── docs/
│   ├── README.md
│   ├── ARCHITECTURE.md
│   ├── CONTRIBUTING.md
│   └── SECURITY.md
├── scripts/
│   ├── setup.sh
│   ├── test.sh
│   └── deploy.sh
├── tests/
├── .gitignore
├── .gitattributes
├── LICENSE
├── README.md
└── CHANGELOG.md
```

### 2. Generate README.md

**Standard README template:**
```markdown
# [Repo Name]

> [One-line description]

[![CI](https://github.com/Seven-Fortunas/[repo-name]/workflows/CI/badge.svg)](https://github.com/Seven-Fortunas/[repo-name]/actions)
[![Security](https://github.com/Seven-Fortunas/[repo-name]/workflows/Security/badge.svg)](https://github.com/Seven-Fortunas/[repo-name]/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Overview

[2-3 paragraph description of what this repository contains]

## Quick Start

```bash
# Clone repository
git clone https://github.com/Seven-Fortunas/[repo-name].git
cd [repo-name]

# Setup
./scripts/setup.sh

# Run tests
./scripts/test.sh
```

## Documentation

- **[Architecture](docs/ARCHITECTURE.md)** - System design and architecture
- **[Contributing](docs/CONTRIBUTING.md)** - How to contribute
- **[Security](docs/SECURITY.md)** - Security policies and reporting

## Development

[Language/framework-specific setup instructions]

## Testing

[Test execution instructions]

## Deployment

[Deployment instructions or link to runbooks]

## Security

For security issues, see [SECURITY.md](docs/SECURITY.md).

## License

[License information]

## Ownership

- **Team:** [Owning Team]
- **Primary Contact:** [Name/Email]
- **Secondary Contact:** [Name/Email]
```

### 3. Generate CLAUDE.md

**Seven Fortunas CLAUDE.md template:**
```markdown
# [Repo Name] - Agent Instructions

**Repository:** `[org]/[repo-name]`
**Purpose:** [Purpose statement]
**Owner:** [Owner]

---

## Project Context

[Project description and context]

**Tech Stack:**
- [Language]: [Version]
- [Framework]: [Version]
- [Key Dependencies]

---

## Directory Structure

```
[Generated structure based on repo type]
```

---

## Development Rules

### Code Style
[Language-specific style guide reference]

### Testing Requirements
- Unit tests required for all new features
- Integration tests for API endpoints
- E2E tests for critical user flows
- Minimum 80% code coverage

### Security Requirements
- No hardcoded credentials
- All secrets in environment variables
- Dependency scanning on PR
- SAST on every push

### Git Workflow
- Feature branches from `main`
- PR required for all changes
- 1 approval required
- CI must pass before merge

---

## Agent Behavior

**What you should do:**
- Follow Seven Fortunas coding standards
- Write tests for new features
- Update documentation
- Use conventional commit messages

**What you should NOT do:**
- Commit directly to main
- Skip CI checks
- Disable security scanning
- Hardcode sensitive data

---

## BMAD Integration

[If BMAD library is integrated]

**Available Skills:**
[List of relevant BMAD skills]

---

## Resources

- [Link to internal docs]
- [Link to dashboards]
- [Link to runbooks]

---

**Document Version:** 1.0
**Last Updated:** [Date]
**Owner:** [Owner]
```

### 4. Generate Security Files

**SECURITY.md:**
```markdown
# Security Policy

## Reporting a Vulnerability

**DO NOT** create public GitHub issues for security vulnerabilities.

**Instead:**
1. Email security@sevenfortunas.com with:
   - Description of vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

2. Use GitHub Security Advisory (private)

**Response SLA:**
- Initial response: 24 hours
- Severity assessment: 48 hours
- Fix timeline: Based on severity
  - Critical: 7 days
  - High: 14 days
  - Medium: 30 days
  - Low: 90 days

## Supported Versions

[Version support matrix]

## Security Measures

- Dependency scanning (Dependabot)
- Secret scanning
- Code scanning (SAST)
- Container scanning (if applicable)
- Regular security audits
```

**CODEOWNERS:**
```
# Seven Fortunas Code Owners
# https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners

* @[owning-team]

# Security-sensitive files
SECURITY.md @seven-fortunas-security-team
.github/workflows/* @seven-fortunas-devops-team
```

### 5. Generate CI/CD Configuration

**GitHub Actions: ci.yml**
```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup [Language]
        uses: [language-setup-action]
      - name: Install dependencies
        run: [install command]
      - name: Run tests
        run: [test command]
      - name: Coverage report
        run: [coverage command]

  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run linter
        run: [lint command]

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Security scan
        run: [security scan command]
```

### 6. Create Repository

**Execute git initialization:**
```bash
cd /tmp
mkdir [repo-name]
cd [repo-name]
git init
[Create all files]
git add -A
git commit -m "feat: Initial repository setup with Seven Fortunas standards

- Add README, CLAUDE.md, and documentation
- Configure CI/CD pipelines
- Set up security scanning
- Add issue/PR templates

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# Create GitHub repository
gh repo create Seven-Fortunas/[repo-name] \
  --[visibility] \
  --description "[description]" \
  --source . \
  --remote origin \
  --push

# Configure branch protection
gh api repos/Seven-Fortunas/[repo-name]/branches/main/protection \
  -X PUT \
  -f required_status_checks[strict]=true \
  -f required_status_checks[contexts][]=CI \
  -f required_pull_request_reviews[required_approving_review_count]=1 \
  -f enforce_admins=true

# Enable security features
gh api repos/Seven-Fortunas/[repo-name] \
  -X PATCH \
  -f security_and_analysis[secret_scanning][status]=enabled \
  -f security_and_analysis[secret_scanning_push_protection][status]=enabled
```

### 7. Verification

**Checklist:**
- [x] Repository created on GitHub
- [x] All files present and valid
- [x] CI/CD workflows configured
- [x] Branch protection enabled
- [x] Security scanning enabled
- [x] CODEOWNERS file valid
- [x] README renders correctly
- [x] CLAUDE.md follows standards
- [x] License file present

---

## Repository Type Templates

### Application Repository

**Additional files:**
- `Dockerfile`
- `docker-compose.yml`
- `k8s/` (Kubernetes manifests)
- `.env.example`

### Library Repository

**Additional files:**
- `setup.py` or `package.json`
- `PUBLISHING.md`
- `examples/`

### Infrastructure Repository

**Additional files:**
- `terraform/`
- `ansible/`
- `RUNBOOK.md`

### Documentation Repository

**Additional files:**
- `mkdocs.yml` or `docusaurus.config.js`
- `static/`
- `blog/`

### Dashboard Repository

**Additional files:**
- `public/`
- `src/`
- `package.json`
- `vite.config.ts`

---

## Error Handling

**Validation Errors:**
- Invalid repo type: Show available types
- Missing required options: Prompt for input
- Invalid repo name: Suggest valid name (lowercase, hyphens)

**GitHub Errors:**
- Repository already exists: Prompt to overwrite or rename
- Authentication failed: Check `gh auth status`
- API rate limit: Display wait time

**File System Errors:**
- Directory already exists: Prompt to overwrite or rename
- Write permissions denied: Display error
- Disk space low: Warn before creation

---

## Integration Points

- **GitHub:** Creates repositories via GitHub API
- **BMAD Library:** Can integrate BMAD workflows
- **Second Brain:** Documents saved to Brain
- **CI/CD:** Configures GitHub Actions

---

## Example Usage

```bash
# Create Python application repository
/7f-repo-template application my-api --language python --framework django --security-level high

# Create TypeScript library
/7f-repo-template library ui-components --language typescript --framework react --visibility public

# Create infrastructure repository
/7f-repo-template infrastructure aws-infra --framework terraform --security-level critical

# Create documentation site
/7f-repo-template documentation product-docs --framework mkdocs --visibility public

# Create dashboard repository
/7f-repo-template dashboard admin-panel --language typescript --framework react --team platform
```

---

## Dependencies

- GitHub CLI (gh) ✅
- Git ✅
- jq (JSON processing) ✅
- Second Brain Structure (FR-2.1) ✅

---

## Notes

This skill automates repository creation with all Seven Fortunas standards baked in. Every repository starts with proper documentation, security configuration, and CI/CD pipelines.

**Key Benefits:**
- Consistency across all repositories
- Security best practices by default
- Ready-to-use CI/CD workflows
- Complete documentation structure
- Proper CLAUDE.md for AI agents

**Pro Tip:** Use this skill for all new repositories, then customize the generated files as needed. Starting with a complete, standards-compliant template is much faster than building from scratch.
