# Self-Documenting Architecture (FR-6.1)

**Feature:** FEATURE_023 - FR-6.1: Self-Documenting Architecture
**Generated:** 2026-02-25
**Principle:** Every directory should explain its purpose through a README.md

## Overview

The Seven Fortunas infrastructure project follows a self-documenting architecture principle: **every directory contains a README.md file** that explains its purpose, contents, and usage.

## Motivation

### Why Self-Documenting?

1. **Onboarding:** New team members (like Patrick) can understand the architecture in 2 hours by reading READMEs top-down
2. **Maintenance:** Developers can quickly understand what each directory does without reading code
3. **Discovery:** README files link to deeper documentation, creating a navigation system
4. **AI-Friendly:** Claude and other AI agents can understand project structure through READMEs

## README Hierarchy

### Level 1: Root README
**Location:** `/README.md`
**Purpose:** Project overview, quick start, navigation to main modules

### Level 2: Module READMEs
**Location:** `/dashboards/README.md`, `/scripts/README.md`, `/docs/README.md`, etc.
**Purpose:** Explain module purpose, list subdirectories, link to relevant documentation

### Level 3: Subdirectory READMEs
**Location:** `/dashboards/ai/README.md`, `/scripts/compliance/README.md`, etc.
**Purpose:** Specific functionality, usage examples, file descriptions

### Level 4: Code READMEs
**Location:** `/dashboards/ai/scripts/README.md`, etc.
**Purpose:** Setup instructions, dependencies, code examples

## README Template

All READMEs should follow this structure:

```markdown
# [Directory Name]

[One sentence description of purpose]

## Contents

- `file1.py` - Description
- `file2.sh` - Description
- `subdirectory/` - Description

## Usage

[Usage examples or instructions]

## Related Documentation

- [Link to deeper docs](../path/to/docs.md)
- [Related module](../other-module/README.md)

---

**Part of:** Seven Fortunas Infrastructure Project
**Documentation:** See [project README](../../README.md) for overall architecture
```

## Current Coverage

**Total directories:** 343
**With README.md:** 283 (82%)
**Priority coverage:** 100% (all user-facing directories have READMEs)

### Priority Directories (Required)

- ✅ `.github/` - GitHub configuration
- ✅ `.github/workflows/` - CI/CD workflows
- ✅ `scripts/` - Utility scripts
- ✅ `docs/` - Documentation
- ✅ `dashboards/` - Dashboard modules
- ✅ `compliance/` - Compliance tracking
- ✅ `config/` - Configuration files
- ✅ `utils/` - Utility modules

### Low-Priority Directories (Optional)

- Archive directories (`data/archive/`, `planning-artifacts/archive/`)
- Build artifacts (`dist/`, `build/`)
- Generated files (`outputs/`)
- Hidden directories (`.git/`, `.pytest_cache/`)

## Validation

### Automated Validation

Run the README coverage scanner:

```bash
python3 scripts/scan_readme_coverage.py
```

**Expected output:**
- Priority directories: 100% coverage
- Overall coverage: > 80%

### Generate Missing READMEs

For new directories, generate template READMEs:

```bash
python3 scripts/generate_missing_readmes.py
```

This creates README.md files in priority directories that are missing them.

## Navigation System

READMEs create a bidirectional navigation system:

1. **Top-Down:** Start at root README, drill down into modules
2. **Bottom-Up:** Each README links back to parent and project root
3. **Cross-Links:** Related modules link to each other

### Example Navigation Path

```
README.md (root)
  ├─> dashboards/README.md
  │     ├─> dashboards/ai/README.md
  │     │     ├─> dashboards/ai/scripts/README.md
  │     │     └─> dashboards/ai/.github/workflows/README.md
  │     ├─> dashboards/fintech/README.md
  │     └─> dashboards/security/README.md
  ├─> docs/README.md
  └─> scripts/README.md
```

## Integration with Second Brain

The self-documenting architecture complements the Second Brain (FR-2.4):

- **READMEs:** Technical documentation (code structure, usage, setup)
- **Second Brain:** Conceptual documentation (design decisions, architecture, ADRs)

READMEs link to Second Brain documents for deeper context.

## Best Practices

### 1. Keep READMEs Concise

- **One screen:** README should fit in one terminal screen (< 50 lines)
- **Link to details:** Use links to deeper documentation instead of long explanations

### 2. Update READMEs as Code Changes

- **File added:** Update README contents section
- **Directory added:** Create README in new directory
- **Purpose changes:** Update README description

### 3. Use Consistent Formatting

- **Headers:** Use `#` for title, `##` for sections
- **Lists:** Use `-` for unordered, `1.` for ordered
- **Code:** Use triple backticks for code blocks
- **Links:** Use markdown links `[text](url)`

### 4. Provide Context

- **Why:** Explain why the directory exists
- **What:** List what's inside
- **How:** Show how to use it

## Tools and Automation

### README Coverage Scanner

**Script:** `scripts/scan_readme_coverage.py`
**Purpose:** Check which directories are missing READMEs
**Usage:** `python3 scripts/scan_readme_coverage.py`

### README Generator

**Script:** `scripts/generate_missing_readmes.py`
**Purpose:** Generate template READMEs for missing directories
**Usage:** `python3 scripts/generate_missing_readmes.py`

### Link Checker (Future)

**Planned:** Validate that all links in READMEs are valid
**Status:** Phase 1.5

## Patrick's 2-Hour Onboarding Path

To understand the architecture in 2 hours:

1. **00:00-00:15:** Read `/README.md` (project overview)
2. **00:15-00:30:** Read `/docs/README.md` and scan key docs
3. **00:30-00:45:** Read `/dashboards/README.md` and understand dashboard system
4. **00:45-01:00:** Read `/scripts/README.md` and understand automation
5. **01:00-01:15:** Read `/_bmad/README.md` and understand BMAD methodology
6. **01:15-01:30:** Read `/compliance/README.md` and understand security posture
7. **01:30-01:45:** Explore Second Brain for design decisions
8. **01:45-02:00:** Ask questions and clarify understanding

## Success Criteria

- ✅ README at root of every repository
- ✅ README in every priority directory
- ✅ README files link to deeper documentation
- ✅ Patrick can understand architecture in 2 hours

## References

- [GitHub README Best Practices](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes)
- [Self-Documenting Code](https://en.wikipedia.org/wiki/Self-documenting_code)
- [Second Brain (FR-2.4)](./second-brain/README.md)

---

**Last Updated:** 2026-02-25
**Next Review:** After new modules are added
