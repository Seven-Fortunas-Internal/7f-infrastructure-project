# Sprint 3 Pre-Start Dependency Assessment

**Purpose:** Gate review — identify blockers, schema mismatches, and scoping adjustments before Sprint 3 test implementation begins.
**Date:** 2026-03-03
**Author:** Murat (TEA Agent)
**Status:** READY WITH ADJUSTMENTS (see items below)

---

## Assessment Summary

| Category | Status | Count |
|----------|--------|-------|
| Hard blockers (cannot start Sprint 3) | ✅ NONE | 0 |
| Schema/spec mismatches (tests would be wrong without correction) | ⚠️ 2 | — |
| Scoping adjustments (spec differs from reality) | ⚠️ 3 | — |
| Dependencies confirmed clear | ✅ 9 | — |

**Verdict:** Sprint 3 can proceed. No hard blockers. Two tests need spec correction before writing (P2-001, P2-002). Three tests need scope adjustment (P2-001 field list, P2-002 path, P2-003 breadth).

---

## Sprint 0 Prerequisites — Final Check

All Sprint 0 dependencies are confirmed installed and functional.

| Tool | Required By | Version | Status |
|------|-------------|---------|--------|
| `pytest-cov` | P2-007, B-002 | 7.0.0 | ✅ OK |
| `responses` (mock HTTP) | P0-002, P1-003 | installed | ✅ OK (functional — `__version__` attr absent but library works) |
| `pytest-json-report` | All pytest | installed | ✅ OK |
| `anthropic` SDK | P1-003 | 0.84.0 | ✅ OK |
| `pyyaml` | P2-001 | 6.0.3 | ✅ OK |
| `bats` | P1-004, P2-002+ | 1.13.0 | ✅ OK |
| `gh` CLI (jorge-at-sf) | live infra | 2.87.0 | ✅ OK |
| `seven-fortunas-brain` clone | P2-001 | present | ✅ OK |

---

## Gap Carry-Forward from Previous Sprints

### G-001 (Sprint 1): detect-secrets logic bug in existing test_secret_patterns.py
**Status:** ✅ NON-BLOCKING — new test file uses corrected logic; old file not used in CI gate.
**Sprint 3 action:** None.

### G-002 (Sprint 1): App.js / App.jsx conflict in dashboard
**Status:** ✅ NON-BLOCKING — fixed by using explicit `import App from '../App.jsx'`.
**Sprint 3 action:** Cleanup task for Jorge/Buck (remove stale `src/App.js`). Not a test blocker.

### G-003 (Sprint 1): Adversarial secret pattern gaps (hex-encoded, reversed, URL-encoded)
**Status:** ✅ ACCEPTED — documented as known limitations (3 xfail). No detection tool covers these without custom rules.
**Sprint 3 action:** None.

### G-008 (Sprint 2): `circuit_breaker.py` uses deprecated `datetime.utcnow()`
**Status:** ✅ NON-BLOCKING — produces `DeprecationWarning` in Python 3.12+ but does not affect test results.
**Sprint 3 action:** Log as tech debt for Jorge. Suggested fix: `datetime.now(timezone.utc)`.

### G-009 (Sprint 2): P1-003 `test_classify_failure_logs.py` deferred
**Status:** ⏳ FIRST ITEM in Sprint 3. All prerequisites confirmed (script exists, anthropic SDK installed).
**Sprint 3 action:** Write and run immediately.

---

## Per-Test Dependency Analysis

### P1-003 — classify-failure-logs.py (DEFERRED FROM SPRINT 2)

**Prerequisites:**
- ✅ `scripts/classify-failure-logs.py` exists (confirmed)
- ✅ `anthropic` SDK 0.84.0 installed (for mocking)
- ✅ `responses` library functional
- ✅ `unittest.mock` available (stdlib)

**Status:** ✅ CLEAR — no blockers. Write first in Sprint 3.

---

### P2-001 — YAML Frontmatter Validator

**Prerequisites:**
- ✅ `seven-fortunas-brain` clone at `/home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/`
- ✅ 19 content `.md` files in `second-brain-core/` — ALL 19 have frontmatter blocks
- ✅ Schema definition found at `standards/yaml-frontmatter-schema.md`
- ✅ `pyyaml` 6.0.3 installed

**⚠️ SCHEMA MISMATCH — Must Correct Before Writing Test:**

The test-design-qa.md (written at design time) listed these required fields:
```
context-level, relevant-for, last-updated, author, status
```

The **actual schema** in `standards/yaml-frontmatter-schema.md` (the authoritative source) defines required fields as:
```
title, type, description, version, last_updated, status
```

Key differences:
- `context-level` → not required (appears as `context_level` in some files, optional)
- `relevant-for` → not required (appears as `relevant_for`, optional)
- `author` → **not in schema at all** (never required)
- `title`, `type`, `description`, `version` → required per schema but NOT in QA doc

**Resolution:** Test must validate against `standards/yaml-frontmatter-schema.md` (the source of truth), not the QA doc's outdated field list. Tests will assert: `title`, `type`, `description`, `version`, `last_updated`, `status` are present.

**Also note:** Not all `.md` files in the repo need frontmatter — only content files in `second-brain-core/`. The `docs/`, `standards/`, and `README.md` files use different conventions. Test scope = `second-brain-core/**/*.md` (excluding README.md).

---

### P2-002 — Autonomous Agent Scripts Exist + Executable

**Prerequisites:**
- ✅ `autonomous-implementation/agent.py` exists
- ✅ `autonomous-implementation/client.py` exists
- ✅ `autonomous-implementation/prompts.py` exists
- ✅ `autonomous-implementation/security.py` exists (additional — not in spec)

**⚠️ PATH MISMATCH — run-autonomous.sh location:**

The test-design-qa.md spec says: `autonomous-implementation/run-autonomous.sh`

Actual location: `autonomous-implementation/scripts/run-autonomous.sh` (confirmed executable: `-rwxrwxr-x`)

**Resolution:** Test will use the actual path (`autonomous-implementation/scripts/run-autonomous.sh`). The QA doc path was a prediction; this is the reality.

**Additional script found:** `autonomous-implementation/security.py` — not in the spec but exists and should be included in the test for completeness (script exists + is Python).

---

### P2-003 — verify-feature-*.sh Non-Trivial Assertions

**Prerequisites:**
- ✅ `scripts/verify-feature-003.sh` found and readable

**⚠️ SCOPE REDUCTION — only 1 script exists:**

The test-design-qa.md spec assumed multiple `verify-feature-*.sh` scripts. Only one exists: `verify-feature-003.sh`.

**Content inspection (verify-feature-003.sh):** Uses real `gh api` calls to check team counts and membership. These are non-trivial assertions (not `assert True` equivalents). The script has genuine validation logic. ✅ Passes the spirit of the test.

**Resolution:** Test will:
1. Assert at least 1 `verify-feature-*.sh` script exists
2. Assert each found script has at least one non-trivial assertion (grep for `gh api`, `curl`, `test -`, `[ -`, `==`, `!=` patterns — not just `echo` or exit codes)
3. Assert the script is executable

This is less coverage than hoped (only 1 script), but the test correctly validates what exists.

---

### P2-004 — ci-health-weekly-report.yml Cron

**Prerequisites:**
- ✅ `.github/workflows/ci-health-weekly-report.yml` exists

**Status:** ✅ CLEAR. Read file content during Sprint 3 to extract exact cron assertion.
**Spec assertion:** Monday 09:00 UTC → cron `'0 9 * * 1'`

---

### P2-005 — collect-metrics.yml Grace Period

**Prerequisites:**
- ✅ `.github/workflows/collect-metrics.yml` exists

**Status:** ✅ CLEAR. Will read file and verify 24-hour grace period logic is present.
**Note:** "Grace period logic" likely means a time comparison like `age_hours < 24` or similar conditional. Will validate by grep pattern.

---

### P2-006 — Skill Naming Conventions

**Prerequisites:**
- ✅ `.claude/commands/` exists with 100+ stubs
- ✅ `7f/`, `bmb/`, `bmm/`, `cis/` subdirectories present
- ✅ README exists at `.claude/commands/README.md`

**Status:** ✅ CLEAR. Test will assert:
- Files in `7f/` all match `7f-*.md` prefix
- Files in `bmb/` all match `bmad-bmb-*.md` prefix
- Files in `bmm/` all match `bmad-bmm-*.md` or `bmad-agent-bmm-*.md` prefix
- Files in `cis/` all match `bmad-cis-*.md` or `bmad-agent-cis-*.md` prefix
- `README.md` documents the categories

---

### P2-007 — pytest-cov Coverage Baseline

**Prerequisites:**
- ✅ `pytest-cov` 7.0.0 installed
- ✅ Python scripts in `scripts/*.py` to measure

**Status:** ✅ CLEAR. This is a run-time-only step (no test file to write). Will run:
```bash
cd /home/ladmin/dev/GDF/7F_github
source venv/bin/activate
pytest tests/unit/python/ --cov=scripts --cov-report=term-missing --cov-report=html:_bmad-output/test-artifacts/results/coverage-html 2>&1 | tee _bmad-output/test-artifacts/results/coverage-report.txt
```
Coverage is expected below 80% target (baseline only — establishing the floor, not enforcing yet per test-design-qa.md).

---

### P2-009 — deploy-ai-dashboard.yml Structure

**Prerequisites:**
- ✅ `.github/workflows/deploy-ai-dashboard.yml` exists

**Status:** ✅ CLEAR. Will read file and assert:
- `destination_dir: ai`
- `keep_files: true`
- `workflow_run` trigger present

---

## Sprint 3 Execution Order (Revised)

Based on this assessment, the revised execution order:

| # | Test ID | Action | Blocker cleared? |
|---|---------|--------|-----------------|
| 1 | P1-003 | Write `test_classify_failure_logs.py` | ✅ Clear |
| 2 | P2-001 | Write `test_yaml_frontmatter.py` using **actual schema** (title, type, description, version, last_updated, status) against `second-brain-core/**/*.md` | ⚠️ Schema corrected |
| 3 | P2-002 | Write `test_autonomous_agent.bats` using **actual path** for run-autonomous.sh | ⚠️ Path corrected |
| 4 | P2-003 | Write verify-feature script inspection (scoped to 1 script found) | ⚠️ Scope adjusted |
| 5 | P2-004/005/009 | Write `test_ci_workflows.bats` (ci-health cron, collect-metrics grace, deploy config) | ✅ Clear |
| 6 | P2-006 | Add skill naming convention assertions (in same BATS file or new) | ✅ Clear |
| 7 | P2-007 | Run `pytest --cov` — capture baseline, no pass/fail threshold yet | ✅ Clear |

---

## Items Requiring Jorge's Awareness

| Item | Severity | Description |
|------|----------|-------------|
| `src/App.js` stale file | Low | Dashboard has legacy `App.js` alongside `App.jsx`. Causes import confusion. Remove `dashboards/ai/src/App.js`. |
| `datetime.utcnow()` in circuit_breaker.py | Low | Deprecated in Python 3.12+. Replace with `datetime.now(timezone.utc)`. |
| Only 1 verify-feature-*.sh script | Info | Significantly fewer scripts than originally expected. Not blocking but means less regression coverage for the feature verification layer. |
| P2-001 frontmatter schema | Info | The frontmatter required fields differ from what the test plan originally specified. The actual schema is the source of truth — tests will validate against it. |
| Live infra re-run | Info | P1-008-d (founders) and P1-016-b (cached_updates.json) remain open. Re-run `validate-live-infrastructure.sh` after those are addressed. |

---

**Assessment complete. Sprint 3 is cleared to start.**
**Document version:** 1.0
