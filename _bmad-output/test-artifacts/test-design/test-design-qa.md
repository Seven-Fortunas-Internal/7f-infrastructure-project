# Test Design for QA: Seven Fortunas Phase 1 Infrastructure

**Purpose:** Test execution recipe — defines what to test, how to test it, who owns each test, and the output format that enables automated pass/fail reporting back to Murat.

**Date:** 2026-03-02
**Author:** Murat (TEA Agent)
**Status:** Approved — Ready for Implementation
**Project:** 7f-infrastructure-project (Phase 1)
**Related:** See `test-design-architecture.md` for testability concerns and architectural blockers.

---

## Executive Summary

**Scope:** Phase 1 system validation — GitHub organizations, BMAD Skills Platform, Second Brain, 7F Lens AI Dashboard, CI self-healing (FR-9), CI quality gates (FR-10), and all Phase 1 NFRs. Phase 1.5, Phase 2, Phase 3, and FR-2.3 (Voice Input) excluded.

**Risk Summary:**
- Total Risks: 14 (4 high-priority ≥6, 7 medium 3-5, 3 low 1-2)
- Critical Categories: SEC (org drift, secret detection), TECH (FR-9 edge cases, core scripts untested), DATA (dashboard degradation)

**Coverage Summary:**
- P0 tests: ~8 (critical paths, security — blocks release)
- P1 tests: ~17 (important features, infra state — should fix before release)
- P2 tests: ~9 (secondary, edge cases — fix if time permits)
- P3 tests: ~5 (exploratory, performance — defer if time-constrained)
- **Total: ~39 test scenarios (~2–3 weeks, 1 QA/dev)**

**Automation ratio:**
- ~70% fully automated (Murat writes and runs — pytest, BATS, Vitest, bash)
- ~22% scripted-for-Jorge (live GitHub infra — Jorge runs `validate-live-infrastructure.sh`, shares JSON output)
- ~8% manual spot checks (Jorge — 3 items, browser-based)

---

## Not in Scope

| Item | Reasoning | Mitigation |
|------|-----------|------------|
| **Phase 1.5 features** (FR-5.4 CISO Assistant, FR-5.3 GitHub App) | Not implemented in Phase 1 per Jorge's direction | Addressed in future test plan |
| **Phase 2 features** (FR-8.x Sprint boards, Matrix communication) | Not implemented | Not applicable |
| **FR-2.3 Voice Input (OpenAI Whisper)** | Device-specific (Henry's MacBook); not infrastructure automation | Henry validates manually on their device |
| **FR-4.4 Additional Dashboards** (Fintech, EduTech) | Phase 2 scope | Not applicable |
| **FR-3.4 Skill Governance metrics** (<5 duplicates) | Requires Phase 2 proliferation data | Monitor in Phase 2 |
| **SOC 2 audit quality** (FR-5.4) | Phase 1.5 — excluded | Future test plan |
| **Matrix homeserver** | Phase 2 — not implemented | Not applicable |
| **GitHub Actions runner environment tests** | Requires live GitHub Actions execution; covered by sentinel + compliance gate | ADR-006 + ADR-007 |

---

## Dependencies & Test Blockers

### Sprint 0 Prerequisites (Before Test Implementation Can Begin)

1. **BATS (Bash Automated Testing System)** — Murat
   - Install: `sudo apt-get install bats` or `npm install -g bats`
   - Required for: P1-004 (validate-and-fix-workflow.sh tests)
   - Status: Pending installation

2. **pytest-cov** — Murat
   - Install: `pip install pytest-cov`
   - Required for: P2-007 (NFR-5.5 coverage gate)
   - Status: Pending

3. **Node.js 18 LTS + Vitest** — Murat
   - Already in `ai/package.json` for the dashboard — reuse
   - Required for: P0-004, P1-005 (React component tests)
   - Status: Available (GitHub Actions runner)

4. **jorge-at-sf GitHub account** — Jorge
   - Required for: All P1-007 through P1-015 live infra tests
   - Status: Available (confirmed active)

5. **Cloned seven-fortunas-brain repo** — Jorge (or provide Murat read access)
   - Required for: P1-012 (Second Brain structure validation), P2-001 (YAML frontmatter)
   - Option A: Clone to `/tmp/seven-fortunas-brain` before running script
   - Option B: Script uses `gh api repos/Seven-Fortunas-Internal/seven-fortunas-brain/contents/...` (slower)

---

## JSON Output Contract (CRITICAL)

**All test scripts must output this JSON to stdout. This enables Murat to parse results and report to Jorge.**

```json
{
  "test_suite": "string",
  "timestamp": "ISO8601",
  "total": N,
  "passed": N,
  "failed": N,
  "skipped": N,
  "results": [
    {
      "test_id": "P0-001",
      "requirement": "FR-5.1",
      "description": "Secret detection rate ≥99.5%",
      "status": "PASS",
      "message": "Detection rate: 99.7% (100/100 baseline, 21/21 adversarial)",
      "duration_ms": 450
    }
  ]
}
```

**Exit codes:**
- `0` = All tests passed
- `1` = One or more test failures
- `2` = Test infrastructure error (blocker B-001/B-002/B-003 not met)

**How Jorge shares results with Murat:** Run the script, pipe output to a `.json` file, paste the file content in the conversation.

---

## Risk Assessment (QA View)

### High-Priority Risks (Score ≥6) — Test Coverage

| Risk ID | Category | Description | Score | QA Test Coverage |
|---------|----------|-------------|-------|-----------------|
| **R-001** | SEC | Org security settings drift | **6** | Live infra script validates all FR-1.3 + FR-1.6 settings via `gh api` — P0-003, P0-005 |
| **R-002** | SEC | Secret detection rate unmeasured | **6** | Expanded `test_secret_patterns.py` with rate calculator — P0-001 |
| **R-003** | TECH | FR-9 pipeline edge cases | **6** | Integration test harness with mocked APIs and all 4 classification paths — P0-002 |
| **R-004** | DATA | Dashboard degradation untested | **6** | React component tests for all 6 degradation scenarios — P0-004 |

### Medium/Low-Priority Risks — Test Coverage

| Risk ID | Category | Description | Score | QA Test Coverage |
|---------|----------|-------------|-------|-----------------|
| R-005 | TECH | bounded_retry.py / circuit_breaker.py untested | 4 | pytest unit tests P1-001, P1-002 |
| R-006 | TECH | validate-and-fix-workflow.sh untested | 4 | BATS tests P1-004 |
| R-007 | TECH | classify-failure-logs.py untested | 4 | pytest with mock anthropic P1-003 |
| R-008 | PERF | Dashboard FCP/TTI unmeasured | 4 | Lighthouse CLI P3-001 |
| R-009 | BUS | BMAD skill stubs path validation | 4 | Bash path validator P1-010 |
| R-010 | DATA | Second Brain YAML frontmatter | 4 | Python validator P2-001 |
| R-011 | SEC | FR-1.4 adversarial auth test missing | 3 | Unit test P0-007 |
| R-012 | OPS | Data retention scripts never run | 1 | Dry-run P3-005 |
| R-013 | OPS | Coverage baseline never established | 3 | pytest-cov P2-007 |

---

## Entry Criteria

**Test implementation cannot begin until ALL of the following are met:**

- [ ] BATS installed locally (`bats --version` succeeds)
- [ ] `pytest-cov` in requirements.txt and importable
- [ ] `seven-fortunas-brain` repo accessible (clone or gh api read access confirmed)
- [ ] `jorge-at-sf` account active (`gh api user --jq '.login'` returns `jorge-at-sf`)
- [ ] `_bmad-output/test-artifacts/test-design/` directory exists (created by this workflow)

## Exit Criteria

**Testing phase complete when ALL of the following are met:**

- [ ] All P0 tests passing (100% — no exceptions)
- [ ] All P1 tests passing or failures triaged and formally waived
- [ ] No unmitigated high-risk (≥6) items
- [ ] Live infra script (`validate-live-infrastructure.sh`) exits 0 as run by Jorge
- [ ] Detection rate ≥99.5% confirmed by test output
- [ ] Coverage report generated (even if below 80% — baseline established)

---

## Project Team

| Name | Role | Testing Responsibilities |
|------|------|--------------------------|
| Murat (TEA Agent) | QA Lead | Write + run all automated tests; create live infra script; report results |
| Jorge | Infrastructure Owner + Test Executor | Run `validate-live-infrastructure.sh`; run manual spot checks; review findings |

---

## Test Coverage Plan

**Priority key:** P0 = blocks release, P1 = should fix before release, P2 = fix if time permits, P3 = exploratory/benchmark

---

### P0 (Critical) — Blocks Release

**Criteria:** High risk (≥6) + security/data integrity + no acceptable workaround

| Test ID | Requirement | Description | Test Level | Owner | Risk Link |
|---------|-------------|-------------|------------|-------|-----------|
| **P0-001** | FR-5.1 / NFR-1.1 | Secret detection rate ≥99.5% — run all baseline + adversarial patterns, assert rate | Unit (pytest) | Murat | R-002 |
| **P0-002** | FR-9.1–9.4 | Sentinel pipeline integration — inject synthetic failure, assert all 4 classification paths (transient, known, unknown, Claude-unavailable) | Integration | Murat | R-003 |
| **P0-003** | FR-1.3 / FR-1.6 | Both orgs: 2FA enforced, secret scanning + push protection enabled, branch protection on all main branches | Live Infra | Jorge | R-001 |
| **P0-004** | FR-4.1 | Dashboard degradation: all 6 scenarios (ErrorBanner on fetch fail, stale >7 days → error page, stale 0-7 days → warning, ≥50% sources fail → banner, Claude API fail → raw data, single source fail → skip+continue) | Component (Vitest) | Murat | R-004 |
| **P0-005** | FR-1.6 | Branch protection on all 10 MVP repos — PR required, no force push, conversation resolution required | Live Infra | Jorge | R-001 |
| **P0-006** | NFR-5.6 | All 36 `.github/workflows/*.yml` files pass `validate-and-fix-workflow.sh` (all 8 constraints: C1-C8) | Integration | Murat | R-006 |
| **P0-007** | FR-1.4 | Auth guard adversarial — `validate_github_auth.sh` exits 1 + error message when wrong account; exits 0 for jorge-at-sf | Unit (BATS) | Murat | R-011 |
| **P0-008** | FR-10.1–10.4 | CI quality gate workflows exist and are correctly structured — workflow-compliance-gate.yml, python-static-analysis.yml, secret-reference-audit.yml, pre-commit-validation.yml | Unit | Murat | R-006 |

**Total P0:** 8 tests

---

### P1 (High) — Should Fix Before Release

**Criteria:** Important features + medium risk (3-4) + common workflows

| Test ID | Requirement | Description | Test Level | Owner | Risk Link |
|---------|-------------|-------------|------------|-------|-----------|
| **P1-001** | FR-7.2 | `bounded_retry.py`: attempt 1/2/3 triggers, max 3 enforced, blocked status set, 30-min timeout respected | Unit (pytest) | Murat | R-005 |
| **P1-002** | FR-7.2 | `circuit_breaker.py`: 5-consecutive-failures trigger, exit code 42, summary report generated, reset on success | Unit (pytest) | Murat | R-005 |
| **P1-003** | FR-9.2 | `classify-failure-logs.py`: transient classification, known-pattern classification, unknown classification, Claude API error fallback | Unit (pytest + mock anthropic) | Murat | R-007 |
| **P1-004** | NFR-5.6 | `validate-and-fix-workflow.sh`: each of 8 constraints (C1-C8) — valid YAML, no secrets in if-conditions, gh error handling, API retries, no bare git push, no hardcoded creds, artifact name sanitization, documentation | Unit (BATS) | Murat | R-006 |
| **P1-005** | FR-4.1 | React components — `UpdateCard` renders source/title/link, `SourceFilter` toggles sources, `SearchBar` filters results, `LastUpdated` shows timestamp + next update time | Component (Vitest + RTL) | Murat | R-004 |
| **P1-006** | FR-4.1 | Dashboard config: `ai/config/sources.yaml` exists, `cache_max_age_hours: 168`, `LocalLLaMA` present, `base: '/dashboards/ai/'` in vite.config.js | Unit (bash/grep) | Murat | R-004 |
| **P1-007** | FR-1.1 | Both orgs exist: `Seven-Fortunas` (public) and `Seven-Fortunas-Internal` (private), with correct display names and descriptions | Live Infra | Jorge | R-001 |
| **P1-008** | FR-1.2 | All 10 teams exist (5 per org), correct member mapping (Jorge→Engineering/Operations, Henry→Marketing/Community, Buck→Engineering, Patrick→BD/Operations) | Live Infra | Jorge | R-001 |
| **P1-009** | FR-1.5 | All 8 MVP repos exist with README.md present; GitHub Pages built on `dashboards` and `seven-fortunas.github.io` | Live Infra | Jorge | R-001 |
| **P1-010** | FR-3.1 | BMAD submodule locked to SHA (not branch); 18+ skill stubs in `.claude/commands/`; each stub's `@{project-root}/...` path resolves to a real file | Unit (bash) | Murat | R-009 |
| **P1-011** | FR-3.2 | 7 custom skills accessible in brain repo: `gh api repos/Seven-Fortunas-Internal/seven-fortunas-brain/contents/.claude/commands/` returns 7 7f-* files | Live Infra | Jorge | R-009 |
| **P1-012** | FR-2.1 | Second Brain directory structure: `index.md` exists at root, each directory has README.md, no path exceeds 3 levels deep | Unit (bash on clone) | Murat | R-010 |
| **P1-013** | FR-2.4 | `search-second-brain.sh` deployed: `gh api repos/Seven-Fortunas-Internal/seven-fortunas-brain/contents/.claude/commands/search-second-brain.sh` returns name field | Live Infra | Jorge | — |
| **P1-014** | FR-6.1 | README.md exists at root of every directory in 7f-infrastructure-project (recursive check) | Unit (bash) | Murat | — |
| **P1-015** | FR-5.2 | Dependabot enabled on all 8 MVP repos (security updates + version updates) | Live Infra | Jorge | — |
| **P1-016** | FR-4.1 | Live dashboard: HTML returns 200, JS bundle returns 200, CSS bundle returns 200, `cached_updates.json` returns ≥1 update | Live Infra | Jorge | R-004 |
| **P1-017** | FR-4.2 | `weekly-ai-summary.yml` exists with Sunday 09:00 UTC cron, `ANTHROPIC_API_KEY` referenced (not hardcoded), `ai/summaries/` directory exists | Unit (bash/yaml) | Murat | — |

**Total P1:** 17 tests

---

### P2 (Medium) — Fix If Time Permits

**Criteria:** Secondary features + low risk (1-2) + regression prevention

| Test ID | Requirement | Description | Test Level | Owner | Risk Link |
|---------|-------------|-------------|------------|-------|-----------|
| **P2-001** | FR-2.2 | YAML frontmatter validation: all `.md` files in `seven-fortunas-brain` have required fields (context-level, relevant-for, last-updated, author, status) with valid values | Unit (Python script) | Murat | R-010 |
| **P2-002** | FR-7.1 | Autonomous agent scripts exist and are executable: `autonomous-implementation/agent.py`, `client.py`, `prompts.py`, `run-autonomous.sh` | Unit (bash) | Murat | — |
| **P2-003** | FR-7.3 | Verify existing verify-feature-*.sh scripts have at least 1 non-trivial assertion per AC (no `assert True` equivalents) | Unit (code inspection) | Murat | — |
| **P2-004** | NFR-8.5 | `ci-health-weekly-report.yml` exists with Monday 09:00 UTC cron schedule | Unit (bash/grep) | Murat | — |
| **P2-005** | NFR-4.6 | `collect-metrics.yml` includes 24-hour grace period logic for new workflows | Unit (bash/grep) | Murat | — |
| **P2-006** | FR-3.3 | Skills in `.claude/commands/` follow category naming (bmad-, bmm-, cis-, 7f-); README documents categories | Unit (bash) | Murat | — |
| **P2-007** | NFR-5.5 | Python code coverage report — run pytest-cov on `scripts/*.py`, report coverage percentage (baseline; 80% target) | Coverage | Murat | R-013 |
| **P2-008** | FR-4.3 | `7f-dashboard-curator` skill deployed in brain repo | Live Infra | Jorge | — |
| **P2-009** | NFR-4.4 | `deploy-ai-dashboard.yml` has `destination_dir: ai`, `keep_files: true`, and `workflow_run` trigger | Unit (yaml/grep) | Murat | — |

**Total P2:** 9 tests

---

### P3 (Low) — Exploratory / Benchmark

**Criteria:** Nice-to-have, performance benchmarks, manual spot checks

| Test ID | Requirement | Description | Test Level | Owner | Notes |
|---------|-------------|-------------|------------|-------|-------|
| **P3-001** | NFR-2.1 | Dashboard performance: Lighthouse CLI against live URL — FCP <2s, TTI <5s | Performance | Jorge | `lighthouse https://seven-fortunas.github.io/dashboards/ai/ --output json` |
| **P3-002** | NFR-7.1/7.2 | Accessibility spot check: keyboard navigation on dashboard, alt text on AI dashboard images | Manual | Jorge | Browser tab-navigation test; Chrome DevTools accessibility audit |
| **P3-003** | FR-5.3 | All 4 founders have 2FA enabled individually | Manual | Jorge | GitHub org Settings → People → verify 2FA badges |
| **P3-004** | NFR-2.2 | GitHub API call latency: `time gh api repos/Seven-Fortunas/dashboards` < 500ms | Performance | Jorge | Run 3x, take median |
| **P3-005** | Data retention | `cleanup_raw_data.sh` dry-run exits 0 without deleting production files | Unit (bash dry-run) | Murat | Confirm safe before any cron schedule |

**Total P3:** 5 tests

---

## Execution Strategy

### Automated Tests (Murat runs — no Jorge involvement needed)

**Trigger: Any time, fully local, no external dependencies**

```bash
# Run all automated tests
cd /home/ladmin/dev/GDF/7F_github

# Python unit tests
pytest tests/ -v --tb=short --json-report --json-report-file=_bmad-output/test-artifacts/results/pytest-results.json

# BATS bash tests
bats tests/bats/ --formatter tap > _bmad-output/test-artifacts/results/bats-results.tap

# React component tests (from dashboards repo or local ai/ dir)
cd <path-to-dashboards-repo>/ai && npm test -- --reporter=json > _bmad-output/test-artifacts/results/vitest-results.json

# Workflow compliance validation (all 36 workflows)
bash tests/validate-all-workflows.sh > _bmad-output/test-artifacts/results/workflow-compliance.json
```

**Expected runtime:** ~5–10 minutes total

---

### Live Infrastructure Tests (Jorge runs — one-time per environment change)

**Trigger: Jorge runs manually after any org/repo/settings change**

```bash
# Single command — runs all live infrastructure assertions
cd /home/ladmin/dev/GDF/7F_github
bash tests/validate-live-infrastructure.sh 2>&1 | tee _bmad-output/test-artifacts/results/live-infra-results.json

# Share the JSON output with Murat for analysis
cat _bmad-output/test-artifacts/results/live-infra-results.json
```

**Expected runtime:** ~3–5 minutes (includes GitHub API calls with rate-limit sleeps)
**Exit code:** 0 = all pass, 1 = failures (see JSON for details)

---

### Manual Spot Checks (Jorge runs — on-demand)

| Test ID | Command / Action | Expected Result |
|---------|-----------------|-----------------|
| P3-001 | `lighthouse https://seven-fortunas.github.io/dashboards/ai/ --output json --output-path /tmp/lh-report.json && cat /tmp/lh-report.json \| jq '.categories.performance.score'` | ≥ 0.9 (= FCP <2s, TTI <5s) |
| P3-002 | Browser: navigate to dashboard URL, Tab through all interactive elements | All elements reachable, no focus traps |
| P3-003 | GitHub org Settings → People → Members → verify each founder shows 2FA badge | All 4 founders: 2FA enabled |

---

## QA Effort Estimate

| Priority | Count | Effort Range | Owner | Notes |
|----------|-------|--------------|-------|-------|
| P0 | 8 | ~3–5 days | Murat (6) + Jorge (2) | Integration test harness is heaviest |
| P1 | 17 | ~4–6 days | Murat (10) + Jorge (7) | Live infra script is bulk of Jorge's time |
| P2 | 9 | ~1–2 days | Murat (8) + Jorge (1) | Mostly quick bash assertions |
| P3 | 5 | ~2–4 hours | Jorge (3) + Murat (2) | Exploratory; low investment |
| **Total** | **39** | **~8–14 days** | **Split** | **~2 weeks with 1 person** |

**Assumptions:**
- Murat runs automated tests iteratively during implementation (write → run → fix)
- Jorge runs live infra script once at the end (one 30-minute session)
- Manual P3 checks done in one sitting (~1 hour)
- Estimates include test writing, debugging, and CI integration

---

## Tooling & Access

| Tool | Purpose | Access Required | Status |
|------|---------|-----------------|--------|
| pytest + pytest-cov | Python unit tests + coverage | Local install | pytest installed; pytest-cov needed |
| BATS | Bash unit tests | Local install (`sudo apt-get install bats`) | Pending |
| Vitest + React Testing Library | React component tests | `npm install` in ai/ dir | Available |
| `responses` (Python library) | Mock GitHub API in integration tests | `pip install responses` | Pending |
| `unittest.mock` / `anthropic` mock | Mock Claude API in tests | stdlib + anthropic SDK | Available |
| `gh` CLI (jorge-at-sf) | Live infra assertions | jorge-at-sf account | Active |
| Lighthouse CLI | Performance benchmarks | `npm install -g lighthouse` | Pending |

---

## Interworking & Regression

| Component | Impact | Regression Scope | Validation |
|-----------|--------|-----------------|------------|
| **workflow-sentinel.yml** | Watches 35 workflows; watch list must stay current | Re-run P0-006 (compliance gate) after any new workflow added | Sentinel canary test (existing CI Canary workflow) |
| **validate-and-fix-workflow.sh** | Critical shared artifact — used in agent loop AND in CI | Run P1-004 (BATS tests) before and after any change to validator | BATS test suite |
| **_bmad submodule** | All 26 skills depend on correct SHA pin | Run P1-010 (stub path validation) after any BMAD update | Bash path resolver |
| **ai/config/sources.yaml** | Dashboard data pipeline config | Run P1-006 (config validation) after any config change | Unit grep test |
| **GitHub org security settings** | 2FA, push protection, secret scanning — security foundation | Run P0-003 + P0-005 (live infra) after any org settings change | Live infra script |

**Regression test strategy:**
- Automated tests (P0-001 through P2-009 where applicable) run on every PR to `main`
- Live infra script (`validate-live-infrastructure.sh`) run manually by Jorge after any infrastructure change
- Sentinel CI canary (existing) provides continuous regression for workflow failures

---

## Sprint Planning Handoff

| Work Item | Owner | Notes |
|-----------|-------|-------|
| Install BATS + pytest-cov + responses library | Murat | Sprint 0 blocker |
| Write `tests/validate-live-infrastructure.sh` | Murat | P0-003, P0-005, P1-007 through P1-016 |
| Write pytest unit tests (P0-001, P1-001–P1-003) | Murat | Python script coverage |
| Write BATS tests (P0-007, P1-004) | Murat | Bash script coverage |
| Write Vitest component tests (P0-004, P1-005) | Murat | React dashboard coverage |
| Write bash unit tests (P1-006, P1-010, P1-012, P1-014, P1-017, P2-002–P2-006) | Murat | Quick file-existence + grep assertions |
| Write Python YAML frontmatter validator (P2-001) | Murat | Second Brain validation |
| Run live infra script + share JSON output | Jorge | One session; provides validation data |
| Run P3 manual checks | Jorge | One 1-hour session after automated tests pass |

---

## Appendix A: Test File Structure

Tests will be organized as:

```
tests/
├── unit/
│   ├── python/
│   │   ├── test_bounded_retry.py          (P1-001)
│   │   ├── test_circuit_breaker.py        (P1-002)
│   │   ├── test_classify_failure_logs.py  (P1-003)
│   │   ├── test_secret_detection.py       (P0-001, expand existing)
│   │   └── test_yaml_frontmatter.py       (P2-001)
│   └── bash/
│       ├── test_auth_guard.bats           (P0-007)
│       ├── test_workflow_validator.bats   (P1-004)
│       └── test_file_structure.sh         (P1-012, P1-014, P1-010, P2-002–P2-006)
├── component/
│   └── dashboard/
│       ├── App.test.jsx                   (P0-004 — degradation scenarios)
│       └── components.test.jsx            (P1-005 — UpdateCard, SourceFilter, etc.)
├── integration/
│   └── test_fr9_pipeline.py              (P0-002 — FR-9 self-healing)
├── config/
│   └── test_config_assertions.sh         (P1-006, P1-017, P2-004, P2-005, P2-009)
├── validate-live-infrastructure.sh        (P0-003, P0-005, P1-007–P1-016, P2-008)
└── validate-all-workflows.sh              (P0-006)
```

---

## Appendix B: Live Infrastructure Script — Output Format

`tests/validate-live-infrastructure.sh` outputs:

```json
{
  "test_suite": "live-infrastructure-validation",
  "timestamp": "2026-03-02T10:00:00Z",
  "account": "jorge-at-sf",
  "total": 25,
  "passed": 24,
  "failed": 1,
  "skipped": 0,
  "results": [
    {
      "test_id": "P0-003-a",
      "requirement": "FR-1.3",
      "description": "Seven-Fortunas org: 2FA required for members",
      "status": "PASS",
      "message": "two_factor_requirement_enabled: true",
      "duration_ms": 312
    },
    {
      "test_id": "P0-003-b",
      "requirement": "FR-1.3",
      "description": "Seven-Fortunas org: secret scanning enabled",
      "status": "FAIL",
      "message": "Expected: true, Got: false",
      "duration_ms": 289
    }
  ]
}
```

**How Murat interprets the output:**
- `failed > 0` → investigate specific test_ids in `results[]`
- `status: FAIL` + `requirement` → maps to specific FR/NFR for root cause
- Share full JSON in conversation; Murat will parse and report

---

## Appendix C: Knowledge Base References

- `risk-governance.md` — Risk scoring methodology (P×I = score, ≥6 = MITIGATE, 9 = BLOCK)
- `test-priorities-matrix.md` — P0-P3 criteria
- `test-levels-framework.md` — E2E vs API vs Unit selection rules
- `probability-impact.md` — Probability/Impact scale (1-3 each, max score 9)

---

**Generated by:** Murat (TEA Agent — Master Test Architect)
**Workflow:** `_bmad/tea/testarch/test-design` (System-Level Mode)
**Date:** 2026-03-02
