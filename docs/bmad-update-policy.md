# BMAD Update Policy

**Version:** 1.0
**Last Updated:** 2026-02-24
**Owner:** Jorge (VP AI-SecOps)

---

## Overview

The `_bmad/` directory contains the BMAD Method library (v6.0.0-Beta.8), installed via the BMAD npm installer. This policy defines how and when BMAD updates are applied to this project.

## Current Version

| Field | Value |
|-------|-------|
| Package | `bmad-method` |
| Installed Version | `6.0.0-Beta.8` |
| Upstream Tag | `v6.0.0` |
| Upstream Commit | `aa573bdbb8f1aa95bb6f4f5a8516e507e0d72a07` |
| Upstream Repo | https://github.com/bmad-code-org/BMAD-METHOD |
| Lock File | `.bmad-version` |

## Why Not a Git Submodule?

The `npx bmad-method install` command applies project-specific configuration (user name, output folders, module selection) during installation. The upstream GitHub repo (`bmad-code-org/BMAD-METHOD`) uses a `src/` build structure that differs from the installed `_bmad/` output; a direct git submodule would not be compatible without a separate build step.

The `.bmad-version` lockfile serves the same pinning purpose as a submodule SHA.

## Update Cadence

- **Quarterly reviews** — check for BMAD updates every 3 months
- **Security patches** — apply immediately if upstream reports a security issue
- **Major versions** — require explicit approval before upgrade (breaking changes possible)

## Update Procedure

1. **Review changelog** at https://github.com/bmad-code-org/BMAD-METHOD/releases
2. **Test in branch** — never update directly on `main`
3. **Run installer** in a feature branch:
   ```bash
   git checkout -b update/bmad-vX.Y.Z
   npx bmad-method@X.Y.Z install
   ```
4. **Verify skill stubs** — check that all 18 stubs in `.claude/commands/bmad-*.md` still resolve to valid workflow paths
5. **Run tests** — ensure CI passes on the update branch
6. **Update lockfile** — update `.bmad-version` with new version details
7. **PR and review** — merge via pull request with at least 1 approval
8. **Update this document** — record the new version and date

## Rollback

If an update causes issues:

```bash
git revert <merge-commit>
# OR restore from the previous committed state of _bmad/
git checkout main -- _bmad/
git checkout main -- .bmad-version
```

## Skill Stub Maintenance

All 18 BMAD skill stubs live in `.claude/commands/bmad-*.md`. After any BMAD update:

- Verify each stub's referenced workflow path still exists in `_bmad/`
- Update paths in stub files if workflows were renamed or moved
- Add new stubs for newly adopted workflows

Current stubs: `ls .claude/commands/bmad-*.md`
