---
name: 'repo-template'
description: 'Initialize new GitHub repositories with Seven Fortunas standards and templates'
---

# Repository Template

**Skill ID:** 7f-repo-template
**Purpose:** Create standardized GitHub repositories for Seven Fortunas projects
**Owner:** Seven Fortunas Team
**Type:** New Custom Skill

---

## Overview

This skill initializes new GitHub repositories with:
- Standard directory structure
- README.md with Seven Fortunas branding
- LICENSE file (MIT/Apache 2.0)
- .gitignore for common languages
- GitHub Actions CI/CD workflows
- Security policies (SECURITY.md, CODE_OF_CONDUCT.md)
- Issue and PR templates
- Branch protection rules

---

## Usage

Invoke this skill from Claude Code:
```
/7f-repo-template <repo-name> <repo-type>
```

**Repo Types:**
- `service` - Microservice/backend service
- `frontend` - React/web application
- `library` - Shared library/package
- `infrastructure` - IaC/deployment configs
- `docs` - Documentation site

---

## Implementation

When invoked, this skill:

1. **Creates local repo** - Initializes git repository
2. **Applies template** - Copies structure based on repo type
3. **Configures GitHub** - Creates remote repo via gh CLI
4. **Sets up branch protection** - Enforces PR reviews, CI checks
5. **Initializes CI/CD** - Adds GitHub Actions workflows
6. **Pushes initial commit** - Commits and pushes template

---

## Repository Structure

```
<repo-name>/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml
│   │   ├── security.yml
│   │   └── deploy.yml
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   └── PULL_REQUEST_TEMPLATE.md
├── src/                    # Source code
├── tests/                  # Test files
├── docs/                   # Documentation
├── scripts/                # Utility scripts
├── .gitignore
├── .dockerignore          # if service/frontend
├── Dockerfile             # if service/frontend
├── README.md
├── LICENSE
├── SECURITY.md
├── CODE_OF_CONDUCT.md
└── CONTRIBUTING.md
```

---

## Templates by Type

### Service Template
- Python/Node.js starter code
- Docker containerization
- Health check endpoints
- Prometheus metrics
- OpenAPI/Swagger docs

### Frontend Template
- React + Vite setup
- TypeScript configuration
- ESLint + Prettier
- Component library structure
- GitHub Pages deployment

### Library Template
- Package configuration (npm/pip)
- API documentation
- Testing framework
- Semantic versioning
- Release automation

### Infrastructure Template
- Terraform/Pulumi configs
- Environment templates
- Deployment scripts
- Architecture diagrams

### Docs Template
- MkDocs/Docusaurus setup
- Auto-generated API docs
- GitHub Pages deployment
- Search integration

---

## GitHub Configuration

Automatically configures:
- **Branch protection** - Require PR reviews, CI pass
- **Secret scanning** - Enable Dependabot alerts
- **Vulnerability alerts** - Enable security advisories
- **Labels** - Standard issue labels (bug, enhancement, docs, etc.)
- **Team access** - Assign default team permissions

---

## Security Defaults

All repositories include:
- Dependabot configuration
- CodeQL scanning workflow
- Secret scanning enabled
- SECURITY.md with reporting process
- CODE_OF_CONDUCT.md
- MIT or Apache 2.0 LICENSE

---

## Outputs

- Local git repository initialized
- Remote GitHub repository created
- Initial commit pushed to main
- Branch protection rules configured
- GitHub Actions workflows active

---

## Integration

- Uses: gh CLI for GitHub operations
- Creates: Local and remote repositories
- Configures: Branch protection, CI/CD, security
- Follows: Seven Fortunas repository standards

---

## Example

```bash
# Create new service repository
/7f-repo-template "7f-auth-service" "service"

# Output:
# ✓ Created local repo: 7f-auth-service/
# ✓ Applied service template
# ✓ Created GitHub repo: Seven-Fortunas/7f-auth-service
# ✓ Configured branch protection
# ✓ Enabled security scanning
# ✓ Pushed initial commit
#
# Repository ready: https://github.com/Seven-Fortunas/7f-auth-service
```

---

**Note:** This is a custom Seven Fortunas skill for standardized repository creation.
Invoke with `/7f-repo-template` from the Claude Code interface.
