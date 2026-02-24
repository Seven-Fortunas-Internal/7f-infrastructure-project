# Seven Fortunas Naming Conventions

**Version:** 1.0
**Last Updated:** 2026-02-24
**Status:** Active

---

## Overview

This document defines the naming, structure, and workflow patterns for the Seven Fortunas infrastructure project. Consistent patterns improve maintainability, reduce cognitive load, and enable automation.

---

## 1. Repository Naming

### Pattern: `kebab-case` with descriptive names

**Format:** `{project-name}-{component}`

**Examples:**
- ✅ `seven-fortunas-brain` - Knowledge management repository
- ✅ `7f-infrastructure-project` - Infrastructure project planning
- ✅ `dashboards` - Dashboard applications
- ❌ `sevenFortunas_brain` - Mixed case, underscores
- ❌ `SFBrain` - Abbreviations, PascalCase

**Rules:**
1. Use lowercase letters, numbers, and hyphens only
2. Start with project prefix (`seven-fortunas-` or `7f-`)
3. End with component purpose (`-brain`, `-dashboards`, `-api`)
4. Keep names descriptive but concise (max 40 characters)

---

## 2. Branch Naming

### Pattern: `{type}/{description}` or `{type}/{ticket-id}-{description}`

**Types:**
- `main` - Primary branch (protected)
- `develop` - Development integration branch
- `feature/{description}` - New features
- `fix/{description}` - Bug fixes
- `docs/{description}` - Documentation updates
- `refactor/{description}` - Code refactoring
- `test/{description}` - Test additions/fixes
- `release/{version}` - Release branches

**Examples:**
- ✅ `main`
- ✅ `feature/dashboard-auto-update`
- ✅ `fix/secret-detection-rate`
- ✅ `docs/api-documentation`
- ✅ `feature/FEATURE_001-gh-auth`
- ❌ `newFeature` - No type prefix
- ❌ `fix_bug` - Underscores instead of hyphens
- ❌ `FEATURE-001` - Missing type

**Rules:**
1. Always use type prefix
2. Use kebab-case for descriptions
3. Include ticket/feature ID when available
4. Keep descriptions concise (max 50 characters)

---

## 3. Commit Messages

### Pattern: Conventional Commits

**Format:** `{type}({scope}): {description}`

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style/formatting (no functional change)
- `refactor` - Code refactoring
- `test` - Test additions or corrections
- `chore` - Build process, dependencies, tooling

**Scopes:**
- Feature IDs: `FEATURE_001`, `NFR-4.3`
- Components: `dashboard`, `api`, `workflows`
- Areas: `security`, `compliance`, `devops`

**Examples:**
- ✅ `feat(FEATURE_001): GitHub CLI Authentication Verification`
- ✅ `fix(NFR-4.3): Correct RTO calculation in DR script`
- ✅ `docs(compliance): Add SOC 2 evidence collection guide`
- ✅ `refactor(dashboard): Simplify data aggregation logic`
- ❌ `Added new feature` - No type or scope
- ❌ `fix: bug` - Too vague
- ❌ `FEAT(feature): new thing` - Wrong case

**Full Format:**
```
{type}({scope}): {summary}

{body - optional}

{footer - optional}
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Rules:**
1. Type and scope in lowercase
2. Summary in sentence case, no period
3. Summary under 72 characters
4. Body wraps at 72 characters
5. Include Co-Authored-By for autonomous work
6. Reference issues/features in footer

---

## 4. File and Directory Naming

### Scripts: `kebab-case.{ext}`

**Format:** `{action}-{target}.{ext}`

**Examples:**
- ✅ `configure-branch-protection.sh`
- ✅ `analyze-dashboard-performance.py`
- ✅ `validate-naming-conventions.sh`
- ❌ `configure_branch_protection.sh` - Underscores (legacy)
- ❌ `analyzeDashboard.py` - camelCase
- ❌ `cfg_br_prot.sh` - Abbreviations

**Legacy Note:** Some existing scripts use `snake_case` (e.g., `audit_access_control.sh`). New scripts MUST use `kebab-case`. Legacy scripts will be renamed in Phase 2.

### Directories: `kebab-case`

**Examples:**
- ✅ `scripts/`
- ✅ `docs/`
- ✅ `.github/workflows/`
- ✅ `autonomous-implementation/`
- ❌ `Scripts/` - Capital letters
- ❌ `_bmad_output/` - Underscores (special case exception)

**Exception:** BMAD directories use underscores (`_bmad/`, `_bmad-output/`) for historical compatibility.

### Documentation: `kebab-case.md`

**Format:** `{topic}-{subtopic}.md` or `{COMPONENT}.md`

**Examples:**
- ✅ `disaster-recovery.md`
- ✅ `naming-conventions.md`
- ✅ `api-rate-limit-compliance.md`
- ✅ `README.md` - Standard filename
- ✅ `CLAUDE.md` - Project-specific convention
- ❌ `Disaster_Recovery.md` - Mixed case, underscores
- ❌ `dr.md` - Abbreviations

### Configuration Files: `{tool}.{format}` or `.{tool}rc`

**Examples:**
- ✅ `package.json`
- ✅ `vite.config.js`
- ✅ `.prettierrc`
- ✅ `.github/workflows/deploy.yml`

---

## 5. GitHub Actions Workflows

### Pattern: `kebab-case.yml`

**Format:** `{purpose}-{action}.yml` or `{component}-{action}.yml`

**Examples:**
- ✅ `dashboard-auto-update.yml`
- ✅ `deploy-ai-dashboard.yml`
- ✅ `collect-soc2-evidence.yml`
- ✅ `dependabot-auto-merge.yml`
- ❌ `DashboardUpdate.yml` - PascalCase
- ❌ `deploy_dashboard.yml` - Underscores
- ❌ `ci.yml` - Too vague

**Workflow Job Names:** `sentence case` or `Title Case`

**Examples:**
- ✅ `Build and Deploy Dashboard`
- ✅ `Run Security Scan`
- ✅ `Collect SOC 2 Evidence`

---

## 6. GitHub Secrets

### Pattern: `SCREAMING_SNAKE_CASE`

**Format:** `{SERVICE}_{PURPOSE}` or `{COMPONENT}_{SECRET_TYPE}`

**Examples:**
- ✅ `ANTHROPIC_API_KEY`
- ✅ `GH_TOKEN`
- ✅ `DASHBOARD_DEPLOY_KEY`
- ✅ `SOC2_EVIDENCE_BUCKET`
- ❌ `anthropic-api-key` - Lowercase
- ❌ `apiKey` - camelCase
- ❌ `key` - Too vague

**Rules:**
1. All uppercase
2. Underscores only
3. Service/component first
4. Purpose/type last
5. No abbreviations unless standard (API, SOC2, etc.)

---

## 7. Code Patterns

### Variables: Language-specific conventions

**JavaScript/TypeScript:**
- camelCase for variables and functions: `dashboardData`, `updateMetrics()`
- PascalCase for classes/components: `DashboardComponent`, `DataAggregator`
- SCREAMING_SNAKE_CASE for constants: `MAX_RETRIES`, `API_TIMEOUT`

**Python:**
- snake_case for variables and functions: `dashboard_data`, `update_metrics()`
- PascalCase for classes: `DashboardComponent`, `DataAggregator`
- SCREAMING_SNAKE_CASE for constants: `MAX_RETRIES`, `API_TIMEOUT`

**Bash:**
- snake_case for local variables: `feature_id`, `test_result`
- SCREAMING_SNAKE_CASE for environment/global variables: `FEATURE_ID`, `TEST_RESULT`
- lowercase for functions: `run_test()`, `validate_input()`

### Functions: Verb-noun pattern

**Examples:**
- ✅ `getUserData()`, `updateDashboard()`, `validateInput()`
- ✅ `get_user_data()`, `update_dashboard()`, `validate_input()`
- ❌ `data()`, `dashboard()` - Missing verb
- ❌ `doStuff()` - Too vague

---

## 8. Data Files

### JSON: `kebab-case.json`

**Examples:**
- ✅ `feature-list.json`
- ✅ `sprint-metrics.json`
- ✅ `package.json` - Standard
- ❌ `featureList.json` - camelCase
- ❌ `data.json` - Too vague

### YAML: `kebab-case.yaml` or `kebab-case.yml`

**Examples:**
- ✅ `resilience-config.yaml`
- ✅ `dashboard-settings.yml`
- ❌ `config.yaml` - Too vague

### CSV/TSV: `kebab-case-{date}.csv`

**Examples:**
- ✅ `velocity-data-2026-02.csv`
- ✅ `soc2-evidence-2026-Q1.csv`

---

## 9. Feature and Requirement IDs

### Pattern: `{PREFIX}_{NUMBER}` or `{PREFIX}-{NUMBER}.{NUMBER}`

**Feature IDs:**
- Format: `FEATURE_{NNN}` (zero-padded to 3 digits)
- Examples: `FEATURE_001`, `FEATURE_042`, `FEATURE_123`

**NFR IDs:**
- Format: `NFR-{N}.{N}` (category.number)
- Examples: `NFR-1.4`, `NFR-4.3`, `NFR-5.2`

**Epic/Story IDs (if used):**
- Format: `EPIC-{NN}`, `STORY-{NNN}`
- Examples: `EPIC-01`, `STORY-042`

---

## 10. Enforcement

### Automated Linting

**Script:** `scripts/validate-naming-conventions.sh`

**Run:**
```bash
./scripts/validate-naming-conventions.sh
```

**CI Integration:**
- Pre-commit hooks validate commit messages
- GitHub Actions workflow validates file naming
- Pull request checks enforce branch naming

### Manual Review

**Checklist:**
- [ ] Repository names follow `kebab-case` pattern
- [ ] Branch names include type prefix
- [ ] Commit messages use Conventional Commits format
- [ ] File names use appropriate case (kebab-case for scripts/docs)
- [ ] Workflow files use kebab-case.yml pattern
- [ ] Secrets use SCREAMING_SNAKE_CASE
- [ ] Code follows language-specific conventions
- [ ] Feature IDs follow FEATURE_NNN or NFR-N.N format

---

## 11. Migration Strategy

### Phase 1: Documentation (Complete)
- ✅ Document current patterns
- ✅ Define standards going forward
- ✅ Create validation tooling

### Phase 2: New Code (Active)
- ✅ All new files follow conventions
- ✅ All new commits follow conventions
- ⏳ Automated validation in CI/CD

### Phase 3: Legacy Code (Future)
- ⏳ Rename legacy scripts (snake_case → kebab-case)
- ⏳ Update old commit references
- ⏳ Refactor inconsistent patterns

---

## 12. Exceptions

### Allowed Exceptions

1. **Standard filenames:** `README.md`, `LICENSE`, `package.json`, `.gitignore`
2. **BMAD directories:** `_bmad/`, `_bmad-output/` (historical compatibility)
3. **Hidden files:** `.claude/`, `.github/` (Unix convention)
4. **Language-specific:** `__init__.py`, `__main__.py` (Python convention)
5. **Third-party tools:** `.prettierrc`, `.eslintrc.js` (tool-specific)

### Requesting Exception

To request a naming exception:
1. Document reason in pull request description
2. Get approval from team lead
3. Add to "Exceptions" section above

---

## 13. Quick Reference

| Item | Pattern | Example |
|------|---------|---------|
| Repository | kebab-case | `seven-fortunas-brain` |
| Branch | type/description | `feature/dashboard-update` |
| Commit | type(scope): message | `feat(NFR-4.3): Add DR plan` |
| Script | kebab-case.ext | `validate-naming.sh` |
| Directory | kebab-case | `autonomous-implementation/` |
| Documentation | kebab-case.md | `naming-conventions.md` |
| Workflow | kebab-case.yml | `deploy-dashboard.yml` |
| Secret | SCREAMING_SNAKE | `ANTHROPIC_API_KEY` |
| JS Variable | camelCase | `dashboardData` |
| Python Variable | snake_case | `dashboard_data` |
| Constant | SCREAMING_SNAKE | `MAX_RETRIES` |
| Feature ID | FEATURE_NNN | `FEATURE_001` |
| NFR ID | NFR-N.N | `NFR-4.3` |

---

## 14. Resources

- **Conventional Commits:** https://www.conventionalcommits.org/
- **Git Branch Naming:** https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows
- **GitHub Secrets:** https://docs.github.com/en/actions/security-guides/encrypted-secrets

---

**Document Owner:** DevOps Team
**Review Frequency:** Quarterly
**Next Review:** 2026-05-24
