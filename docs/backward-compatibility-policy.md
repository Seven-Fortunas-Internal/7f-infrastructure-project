# Backward Compatibility Policy - Seven Fortunas Infrastructure

**Version:** 1.0
**Last Updated:** 2026-02-24
**Owner:** DevOps Team
**Review Frequency:** Quarterly

---

## Overview

This document defines the backward compatibility policy for the Seven Fortunas infrastructure project, ensuring stable dependencies and smooth upgrades.

**Commitment:** Maintain backward compatibility for all dependencies for a minimum of 1 year.

---

## Dependency Categories

### Category 1: Core Framework (BMAD)

**Current:** BMAD library (Business Method Architecture Design)
**Source:** Local clone in `_bmad/` directory
**Version Tracking:** Git commit hash
**Compatibility Window:** 1 year minimum

**Policy:**
- Pin BMAD to specific git commit/tag
- Test all workflows before upgrading BMAD version
- Maintain compatibility with BMAD versions from past 12 months
- Document breaking changes in upgrade notes

### Category 2: System Dependencies

**Dependencies:**
- Git
- GitHub CLI (gh)
- jq (JSON processor)
- bash (shell)
- Python 3.x
- curl

**Policy:**
- Document minimum required versions
- Test against multiple versions where possible
- Provide fallback implementations for version-specific features
- Pin Python package versions in requirements.txt (when used)

### Category 3: GitHub Actions

**Dependencies:**
- GitHub Actions runner environments
- actions/checkout@v3
- actions/setup-node@v3 (for dashboard builds)
- Custom workflow actions

**Policy:**
- Pin action versions to major.minor (e.g., v3.2, not @main)
- Test workflow changes in feature branches before merging
- Document required runner environment (ubuntu-latest specifications)
- Provide 30-day notice before deprecating old workflow versions

### Category 4: External APIs

**Dependencies:**
- GitHub API (via gh CLI)
- Anthropic Claude API (for AI features)

**Policy:**
- Use stable API versions (not beta/preview)
- Handle API deprecation notices proactively (90+ days before sunset)
- Implement graceful degradation for API changes
- Test against API version changes in staging

---

## Version Pinning Strategy

### BMAD Version Pinning

**Current Approach:**
- BMAD library checked into repository (`_bmad/` directory)
- Version tracked via git commit hash
- Updates require explicit git operations (pull/merge)

**Upgrade Process:**
1. Test BMAD update in feature branch
2. Run full workflow validation suite
3. Document breaking changes (if any)
4. Update `DEPENDENCIES.md` with new version
5. Merge to main after validation passes

**Rollback Strategy:**
- Git history allows instant rollback to previous BMAD version
- Documented in `docs/rollback-procedures.md`

### System Dependency Versions

**Minimum Versions (as of 2026-02-24):**
```yaml
dependencies:
  git: ">=2.30.0"
  gh: ">=2.20.0"
  jq: ">=1.6"
  bash: ">=4.4"
  python: ">=3.8"
  curl: ">=7.68.0"
```

**Tracking:**
- Documented in `DEPENDENCIES.md`
- Validated by `scripts/check-dependencies.sh`
- Updated quarterly during dependency audits

### GitHub Actions Pinning

**Pattern:** Use `@vMAJOR.MINOR` tags, not `@main` or `@latest`

**Example:**
```yaml
# ✓ Good - pinned to minor version
- uses: actions/checkout@v3.5

# ✗ Bad - unpinned, may break unexpectedly
- uses: actions/checkout@main
```

**Automated Monitoring:**
- Dependabot monitors action versions
- Pull requests auto-created for security updates
- Manual review required for major version bumps

---

## Testing Before Upgrades

### Pre-Upgrade Checklist

Before upgrading any major dependency:

- [ ] **Review changelog** - Identify breaking changes
- [ ] **Create feature branch** - Isolate upgrade testing
- [ ] **Update dependency version** - In appropriate manifest file
- [ ] **Run validation suite** - Execute all tests
- [ ] **Test core workflows** - Verify critical paths work
- [ ] **Document changes** - Update DEPENDENCIES.md
- [ ] **Create upgrade guide** - If breaking changes exist
- [ ] **Seek peer review** - Before merging to main

### Validation Suite

**For BMAD Upgrades:**
```bash
# Test all BMAD workflows
cd _bmad/
./scripts/validate-all-workflows.sh

# Test custom Seven Fortunas workflows
cd /home/ladmin/dev/GDF/7F_github
for workflow in _bmad-output/bmb-creations/workflows/*/; do
    echo "Testing: $workflow"
    # Execute workflow validation
done
```

**For System Dependency Upgrades:**
```bash
# Check dependency versions
./scripts/check-dependencies.sh

# Run integration tests
./scripts/test-integration.sh

# Verify GitHub CLI functionality
gh auth status
gh api user
```

**For GitHub Actions Upgrades:**
- Create pull request with updated action versions
- Trigger CI/CD pipeline
- Monitor workflow execution
- Verify dashboard builds and deployments

### Compatibility Matrix

| Dependency | Current Version | Min Supported | Max Tested | Compatibility Period |
|------------|----------------|---------------|-----------|---------------------|
| BMAD | 2024-11-15 commit | 2023-11-15 commit | Latest | 12 months rolling |
| Git | 2.30+ | 2.30.0 | 2.43.0 | 24 months |
| GitHub CLI | 2.20+ | 2.20.0 | 2.40.0 | 18 months |
| jq | 1.6+ | 1.6 | 1.7 | 24 months |
| Python | 3.8+ | 3.8 | 3.12 | Python lifecycle |
| Node.js | 18+ | 18.0.0 | 20.0.0 | Node LTS schedule |

---

## Deprecation Process

### Announcing Deprecations

When deprecating a dependency version:

1. **90-day notice** - Announce in team communication channels
2. **Update documentation** - Mark as deprecated in DEPENDENCIES.md
3. **Create migration guide** - Document upgrade path
4. **Monitor usage** - Track systems still using deprecated version
5. **Provide support** - Help teams migrate before sunset
6. **Remove support** - After 12 months minimum

### Deprecation Notice Template

```markdown
## Deprecation Notice: [Dependency Name] [Old Version]

**Deprecated:** 2026-02-24
**End of Life:** 2027-02-24 (12 months from deprecation)
**Reason:** [Security vulnerability / End of upstream support / Breaking bug]
**Migration Path:** Upgrade to [New Version]
**Migration Guide:** docs/migrations/[dependency]-[old]-to-[new].md
**Support:** Contact DevOps team for assistance
```

---

## Dependency Audit Process

### Quarterly Dependency Audit

**Schedule:** Every 90 days (Month 1, 4, 7, 10)
**Owner:** DevOps Team

**Audit Steps:**
1. **Inventory dependencies** - Run `scripts/audit-dependencies.sh`
2. **Check for updates** - Review upstream release notes
3. **Identify vulnerabilities** - Security scanning via Dependabot
4. **Test compatibility** - Verify current versions still supported
5. **Plan upgrades** - Schedule necessary version bumps
6. **Update documentation** - Refresh DEPENDENCIES.md

**Audit Script:**
```bash
./scripts/audit-dependencies.sh --output reports/dependency-audit-$(date +%Y-Q%q).md
```

### Continuous Monitoring

**Automated Alerts:**
- Dependabot security advisories (immediate notification)
- Major version releases of pinned dependencies (weekly digest)
- Deprecation announcements from upstream (monitored via RSS/webhooks)

**Manual Checks:**
- Monthly review of GitHub Actions usage
- Monthly BMAD library sync check
- Quarterly system dependency version audit

---

## Rollback Procedures

### BMAD Rollback

```bash
# Rollback to previous BMAD version
cd /home/ladmin/dev/GDF/7F_github
git log --oneline _bmad/ | head -10
git checkout <commit-hash> -- _bmad/
git commit -m "rollback: Revert BMAD to <commit-hash> due to <reason>"
```

### GitHub Actions Rollback

```bash
# Revert to previous workflow version
cd .github/workflows/
git diff HEAD~1 <workflow-file>.yml
git checkout HEAD~1 -- <workflow-file>.yml
git commit -m "rollback: Revert <workflow> to previous version"
```

### System Dependency Rollback

- Docker/container environments: Revert to previous image tag
- System packages: Use package manager downgrade (apt, yum, brew)
- Python packages: `pip install <package>==<old-version>`

---

## Version Upgrade Examples

### Example 1: BMAD Minor Update

**Scenario:** BMAD library has new workflows, no breaking changes

**Process:**
1. Review BMAD changelog: `cd /path/to/bmad && git log --oneline`
2. Create feature branch: `git checkout -b feature/bmad-update-2026-02`
3. Update BMAD: `cd _bmad && git pull origin main`
4. Test workflows: `./scripts/validate-all-workflows.sh`
5. Update docs: Edit `DEPENDENCIES.md` with new commit hash
6. Create PR: `gh pr create --title "Update BMAD to 2026-02-24"`
7. Merge after approval and CI pass

**Rollback:** `git revert <merge-commit>` if issues found

### Example 2: GitHub Actions Major Update

**Scenario:** actions/checkout v3 → v4 (major version bump)

**Process:**
1. Review v4 changelog: https://github.com/actions/checkout/releases
2. Identify breaking changes: Node.js 16 → Node.js 20 requirement
3. Create feature branch: `git checkout -b update/actions-checkout-v4`
4. Update all workflows: `sed -i 's/actions\/checkout@v3/actions\/checkout@v4/g' .github/workflows/*.yml`
5. Test in CI: Push branch, monitor workflow runs
6. Update documentation: Note Node.js 20 requirement
7. Merge after validation

**Rollback:** Keep v3 in parallel for 30 days, deprecate after validation

### Example 3: System Dependency Security Update

**Scenario:** Critical security patch for curl

**Process:**
1. Review security advisory (CVE details)
2. Check minimum version requirements
3. Update system packages: `sudo apt update && sudo apt upgrade curl`
4. Verify functionality: `curl --version && ./scripts/test-api-calls.sh`
5. Document in audit log: `echo "2026-02-24: curl updated to 7.88.1 (CVE-2026-XXXX)" >> logs/security-updates.log`
6. Communicate to team via security channel

**Rollback:** Revert package version if breaking changes detected

---

## Monitoring and Metrics

### Tracked Metrics

- **Dependency age:** Days since last update
- **Security vulnerabilities:** Count of open CVEs
- **Compatibility coverage:** % of dependencies within support window
- **Upgrade frequency:** Updates per quarter
- **Rollback rate:** % of upgrades requiring rollback

### Compliance Targets

- **No critical vulnerabilities:** 0 CVEs rated 9.0+ CVSS score
- **Dependency freshness:** <90 days average age for security updates
- **Compatibility window:** 100% of dependencies supported for 12+ months
- **Upgrade success rate:** >95% of upgrades succeed without rollback

---

## Related Documents

- `DEPENDENCIES.md` - Current dependency versions and requirements
- `scripts/check-dependencies.sh` - Dependency version validation script
- `scripts/audit-dependencies.sh` - Quarterly audit automation
- `docs/rollback-procedures.md` - Detailed rollback instructions
- `.github/dependabot.yml` - Automated dependency update configuration

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-02-24 | Autonomous Agent | Initial backward compatibility policy |

---

**Next Review:** 2026-05-24 (Quarterly)
**Owner:** DevOps Team
**Approvers:** Security Team, Architecture Team
