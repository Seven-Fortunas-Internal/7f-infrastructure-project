# Self-Documenting Architecture Integration

**Version:** 1.0  
**Date:** 2026-02-23  
**Owner:** Jorge (VP AI-SecOps)

## Overview

This document describes how the self-documenting architecture (README.md at every directory level) integrates with the Second Brain (FR-2.4) and autonomous agent (FR-1.5) to provide comprehensive, always-up-to-date project documentation.

## Architecture Components

### 1. README Templates

**Location:** `docs/templates/`

- `README-root.md` - Repository root documentation
- `README-directory.md` - Directory-level documentation
- `README-code.md` - Code component documentation
- `README-architecture.md` - Architecture decision documentation

**Purpose:** Standardized structure for all README files ensures consistency and completeness.

### 2. README Generator

**Location:** `scripts/documentation/generate-readmes.sh`

**Features:**
- Auto-detects directory type (root, directory, code, architecture)
- Generates README from appropriate template
- Fills in basic metadata (directory name, date)
- Dry-run mode for testing

**Usage:**
```bash
# Generate READMEs for all directories
bash scripts/documentation/generate-readmes.sh

# Dry run (preview only)
DRY_RUN=true bash scripts/documentation/generate-readmes.sh
```

### 3. README Validator

**Location:** `scripts/documentation/validate-readmes.sh`

**Features:**
- Checks for README presence at root and all directories
- Validates template structure (required sections)
- Link validation (requires markdown-link-check)
- Verbose mode for detailed output

**Usage:**
```bash
# Validate all READMEs
bash scripts/documentation/validate-readmes.sh

# Verbose mode
VERBOSE=true bash scripts/documentation/validate-readmes.sh
```

## Integration with Second Brain (FR-2.4)

### Knowledge Hierarchy

```
Seven Fortunas Second Brain (GitHub Wiki)
    ↓
Repository README.md (Self-Documenting Architecture)
    ↓
Directory README.md (Local Context)
    ↓
Code README.md (Implementation Details)
```

### Knowledge Flow

1. **Strategic Level (Second Brain)**
   - High-level architecture decisions
   - Cross-repository patterns
   - Organizational standards
   - Compliance requirements

2. **Repository Level (Root README.md)**
   - Project overview and quick start
   - Repository structure
   - Key features and requirements
   - Links to Second Brain articles

3. **Directory Level (Directory README.md)**
   - Purpose of directory
   - Contents and organization
   - Usage examples
   - Links to parent README and related docs

4. **Component Level (Code README.md)**
   - Setup and dependencies
   - API reference
   - Examples and testing
   - Links to architecture docs

### Bi-Directional Links

**Second Brain → README.md:**
- Second Brain articles link to specific repository READMEs
- Example: "SOC 2 Compliance" article links to `compliance/soc2/github-control-mapping.md`

**README.md → Second Brain:**
- Repository READMEs link to relevant Second Brain articles
- Example: Root README links to "BMAD Methodology" article

### Update Workflow

1. **Strategic Change (Architecture Decision):**
   - Update Second Brain article
   - Update affected repository root README.md
   - Update affected directory README.md (if applicable)
   - Autonomous agent applies changes to code

2. **Tactical Change (Implementation Detail):**
   - Update code README.md
   - Update parent directory README.md (if structure changes)
   - Summarize in repository root README.md (if significant)
   - Extract patterns to Second Brain (if reusable)

## Integration with Autonomous Agent (FR-1.5)

### Autonomous README Generation

**During Repository Creation:**

```python
# Autonomous agent workflow
def create_repository(repo_name, description):
    # 1. Create repository via GitHub API
    repo = gh.create_repo(repo_name, description)
    
    # 2. Generate root README from template
    readme_content = generate_root_readme(
        project_name=repo_name,
        description=description,
        structure=analyze_directory_structure(repo)
    )
    
    # 3. Create root README
    repo.create_file("README.md", "Initial README", readme_content)
    
    # 4. Generate directory READMEs
    for directory in repo.directories:
        dir_readme = generate_directory_readme(directory)
        repo.create_file(f"{directory}/README.md", "Add directory README", dir_readme)
    
    return repo
```

### Autonomous README Updates

**During Feature Implementation:**

```python
# Autonomous agent workflow
def implement_feature(feature_id):
    # 1. Read feature specification
    feature = load_feature(feature_id)
    
    # 2. Implement feature code
    code_files = implement_code(feature)
    
    # 3. Update code README.md
    for code_file in code_files:
        update_code_readme(code_file, feature)
    
    # 4. Update directory README.md
    update_directory_readme(code_file.directory, feature)
    
    # 5. Update root README.md (if significant)
    if feature.is_significant():
        update_root_readme(feature)
    
    # 6. Extract to Second Brain (if pattern)
    if feature.is_pattern():
        create_second_brain_article(feature)
```

### README Validation in CI/CD

**GitHub Actions Workflow:**

```yaml
name: Documentation Validation

on:
  pull_request:
    paths:
      - '**/*.md'
      - '**/README.md'
  push:
    branches:
      - main

jobs:
  validate-readmes:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Validate README presence
        run: |
          bash scripts/documentation/validate-readmes.sh
      
      - name: Validate links
        run: |
          npm install -g markdown-link-check
          VERBOSE=true bash scripts/documentation/validate-readmes.sh
      
      - name: Check for TODO placeholders
        run: |
          # Fail if production READMEs have unfilled placeholders
          if grep -r "\[Description\]" */README.md; then
            echo "Error: README files have unfilled placeholders"
            exit 1
          fi
```

## Patrick's 2-Hour Architecture Understanding

**Requirement:** Patrick (new team member) can understand the architecture in 2 hours.

### Navigation Path

**Hour 1: High-Level Understanding (30 min per topic)**

1. **Start: Root README.md (30 min)**
   - Read "Overview" section (5 min)
   - Read "Quick Start" section (10 min)
   - Read "Project Structure" section (10 min)
   - Skim "Documentation" links (5 min)

2. **Second Brain Articles (30 min)**
   - Read "Seven Fortunas Architecture" article (15 min)
   - Read "BMAD Methodology" article (10 min)
   - Read "SOC 2 Compliance Overview" article (5 min)

**Hour 2: Deep Dive (choose one domain)**

3. **Option A: Dashboards (60 min)**
   - `dashboards/README.md` (10 min)
   - `dashboards/ai/README.md` (15 min)
   - `dashboards/ai/dashboard.json` + README (20 min)
   - `scripts/dashboards/README.md` (15 min)

4. **Option B: Compliance (60 min)**
   - `compliance/README.md` (10 min)
   - `compliance/soc2/github-control-mapping.md` (20 min)
   - `docs/compliance/ciso-assistant-migration.md` (15 min)
   - `scripts/compliance/collect-github-evidence.sh` + README (15 min)

5. **Option C: Automation (60 min)**
   - `scripts/README.md` (10 min)
   - `autonomous-implementation/README.md` (15 min)
   - `autonomous-implementation/agent.py` + README (20 min)
   - `.github/workflows/` + READMEs (15 min)

### Validation Criteria

**After 2 hours, Patrick can answer:**
- What is Seven Fortunas? (High-level purpose)
- What are the key components? (Dashboards, compliance, automation)
- Where do I find X? (Navigate to specific functionality)
- How do I run Y? (Quick start guide for common tasks)
- Who do I ask about Z? (Team ownership and contacts)

## Maintenance

### Daily (Automated)
- README validation in CI/CD (every PR)
- Link checking (every PR)
- Placeholder detection (every PR)

### Weekly (Manual)
- Review new READMEs from autonomous agent
- Update root README with significant changes
- Sync patterns to Second Brain

### Monthly (Manual)
- Audit README coverage (all directories)
- Update templates if patterns emerge
- Review Patrick's test results (new team members)

### Quarterly (Manual)
- Comprehensive README quality review
- Update templates based on feedback
- Refactor structure if needed

## Metrics

### Coverage Metrics
- **Target:** 100% directories have README.md
- **Current:** 259/259 (100%)

### Quality Metrics
- **Template Compliance:** >95% READMEs follow template structure
- **Link Validity:** 100% internal links valid
- **Placeholder Rate:** 0% production READMEs with placeholders

### Usage Metrics
- **Patrick's Time:** <2 hours to understand architecture
- **New Developer Onboarding:** <1 day to productivity
- **Documentation Questions:** <5 per week (Slack #engineering)

## Troubleshooting

### Issue: READMEs out of date

**Symptom:** Code changes not reflected in README

**Solution:**
1. Run `bash scripts/documentation/validate-readmes.sh`
2. Identify outdated READMEs
3. Update manually or regenerate: `bash scripts/documentation/generate-readmes.sh`

### Issue: Broken links

**Symptom:** README links return 404

**Solution:**
1. Install: `npm install -g markdown-link-check`
2. Run: `VERBOSE=true bash scripts/documentation/validate-readmes.sh`
3. Fix broken links
4. Re-validate

### Issue: Missing sections

**Symptom:** README doesn't follow template

**Solution:**
1. Identify template type (root, directory, code, architecture)
2. Copy appropriate template from `docs/templates/`
3. Fill in existing content
4. Add missing sections

## Resources

- **Templates:** `docs/templates/`
- **Generator:** `scripts/documentation/generate-readmes.sh`
- **Validator:** `scripts/documentation/validate-readmes.sh`
- **Second Brain:** https://github.com/Seven-Fortunas-Internal/seven-fortunas-brain/wiki

---

**Next Actions:**
1. Run validation: `bash scripts/documentation/validate-readmes.sh`
2. Fix placeholders in generated READMEs
3. Add CI/CD workflow for README validation
4. Test Patrick's 2-hour understanding (next new hire)
