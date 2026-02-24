---
description: "Generate repository from Seven Fortunas templates with pre-configured structure"
tags: ["repository", "template", "initialization", "project-setup"]
source: "Custom Seven Fortunas skill"
---

# Repository Template Skill

Generate new repositories from Seven Fortunas templates with pre-configured:
- **Directory Structure:** Standard Seven Fortunas project layout
- **Configuration Files:** .gitignore, .github/workflows/, .claude/
- **Documentation:** README, CONTRIBUTING, CODE_OF_CONDUCT
- **Security:** Branch protection, secret scanning, Dependabot

## Usage

**Create Repository:**
```bash
# Interactive mode
/7f-repo-template

# Specific template
/7f-repo-template --template="python-service" --name="my-new-service"

# With GitHub creation
/7f-repo-template --template="dashboard" --name="my-dashboard" --create-github
```

## Available Templates

**Python Service:**
- FastAPI boilerplate
- pytest configuration
- Docker support
- CI/CD workflows

**Dashboard:**
- React + Vite setup
- Tailwind CSS
- Chart.js integration
- GitHub Pages deployment

**Documentation Site:**
- MkDocs setup
- Material theme
- Search enabled
- GitHub Pages deployment

**BMAD Project:**
- BMAD library integration
- Skill stubs
- Workflow templates
- Seven Fortunas conventions

## Features

- ✅ **Template Library:** Pre-configured project templates
- ✅ **GitHub Integration:** Creates repository and configures settings
- ✅ **Security Defaults:** Branch protection, secret scanning enabled
- ✅ **Seven Fortunas Standards:** Follows organizational conventions

## Output

Creates local repository:
```
{repo-name}/
├── .github/
│   └── workflows/
├── .claude/
│   └── commands/
├── src/
├── tests/
├── README.md
├── .gitignore
└── pyproject.toml (or package.json, etc.)
```

Optionally creates GitHub repository with:
- Branch protection on main
- Dependabot enabled
- Secret scanning enabled
- Repository settings configured

## Integration

- **GitHub CLI:** Uses `gh repo create` for GitHub operations
- **Template Repository:** Can use GitHub template repositories
- **Based on:** Seven Fortunas organizational standards

---

**Status:** MVP (Placeholder - Full implementation pending)
**Source:** Custom Seven Fortunas skill (new)
