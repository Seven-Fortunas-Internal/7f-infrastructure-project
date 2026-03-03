# Sprint 5 Plan — Seven Fortunas Phase 1 Infrastructure

**Author:** Murat (TEA Agent — Master Test Architect)
**Date:** 2026-03-03
**Status:** PLANNED — Awaiting execution
**Supersedes:** WC backlog in `sprint4-plan.md`
**Related:** `test-design-qa.md` · `sprint4-plan.md` · `spec-corrections.md`

---

## Context: Where We Stand

### Automated Test Suite — Sprint 4 Complete Baseline

| Sprint | Suites | Assertions | Status |
|--------|--------|------------|--------|
| Sprint 1 — P0 (8 suites) | 8 | 131 pass + 3 xfail | ✅ Complete |
| Sprint 2 — P1 (9 suites) | 9 | 181 pass | ✅ Complete |
| Sprint 3 — P2 + P1-003 (7 suites) | 7 | 75 pass | ✅ Complete |
| BATS validator suite | 1 | 174 pass | ✅ Complete |
| Sprint 4 (P2-010, P4-001, P4-002) | 3 | 49 pass | ✅ Complete |
| **Running total** | **28** | **470 pass + 3 xfail** | ✅ Zero regressions |

### Live Infrastructure — Run 4

| Assertions | Pass | Fail | Skip | Status |
|-----------|------|------|------|--------|
| 32 | 25 | 1 | 6 | ⚠️ PARTIAL |

1 permanent fail (SC-006 — intentional Free-plan decision). 6 skips (4 Free-plan API limits, 2 deferrals).

### Workflows on disk: 40

---

## SDD Rules Inherited (Permanent)

All SDD-1 through SDD-8 rules from `sprint4-plan.md §Spec-Driven Development` apply.
Not repeated here — see source document.

**SDD-8 emphasis for Sprint 5:** Every deployed workflow or live feature must have a documented
live verification step executed before the scenario is marked PASS. CI pass alone is not sufficient.
See `sprint4-plan.md §Live Verification Protocol` for method per feature type.

---

## Sprint 5 Work Queue

### Priority Order (Risk × Value)

| # | ID | Description | Owner | Risk Closed |
|---|----|-------------|-------|-------------|
| 1 | **P5-001** | Sentinel E2E SLA assertion (WC-003) | Murat | SC-005 regression gap / FR-9.1 timing |
| 2 | **P5-002** | Brain repo CI — frontmatter gate (WC-005) | Murat | P2-001 data regression / FR-2.2 |
| 3 | **P5-003** | Lighthouse CI scheduled workflow (WC-001) | Murat | R-008 performance regression |
| 4 | **P5-004** | Coverage gate 60% → 75% (WC-006) | Murat | R-013 coverage progression |
| 5 | **P5-005** | Accessibility CI (WC-002) | Murat | NFR-7.1/7.2 manual check automation |
| 6 | **P5-006** | bot585 live approval verification (SDD-8 backfill) | Murat | SC-004 live behaviour gap |
| 7 | **P5-007** | GitHub API latency benchmark (P3-004) | Jorge | NFR-2.2 |
| 8 | **P5-008** | cleanup_raw_data.sh dry-run (P3-005) | Murat | Data retention safety |

Execute in order. Do not skip ahead.

---

## Detailed Work Items

### P5-001 — Sentinel E2E SLA Assertion (WC-003)

**Requirement:** FR-9.1 — Sentinel must detect and process workflow failures within 5 minutes
**Gap closed:** SC-005 has no regression test; E2E timing between failure and issue creation has
never been asserted. The entire FR-9.x chain (9.1→9.5) has only been manually verified once.
**Spec reference:** FR-9.1 (detect ≤5 min), FR-9.4 (create issue), FR-9.5 (create fix PR)

**Implementation plan:**

Extend `ci-canary-test.yml` with a post-canary SLA check:
1. Canary job records start timestamp and run ID
2. New `assert-sla` job waits for `ci-canary-test` job completion
3. Polls `gh issue list --label ci-failure --search "run {run_id}"` every 30s (max 10 polls = 5 min)
4. Asserts: issue found, correct labels (`ci-failure` + priority label), wall-clock < 5 minutes
5. Fails CI if SLA breached

**Test file:** `.github/workflows/ci-canary-test.yml` (new `assert-sla` job)
**Live verification (SDD-8):** The canary workflow IS the live verification — runs against real GitHub Actions.
Trigger via `workflow_dispatch` after merge and confirm `assert-sla` job passes.
**SDD registration:** P5-001 added to `test-design-qa.md`

---

### P5-002 — Brain Repo CI: Frontmatter Gate (WC-005)

**Requirement:** FR-2.2 — YAML frontmatter required on all Second Brain documents
**Gap closed:** P2-001 found 30 files missing `version` field in the brain repo. Currently no CI
gate exists in `seven-fortunas-brain` — new files can be committed without frontmatter and only
caught during quarterly test runs in this repo.
**Spec reference:** FR-2.2, NFR-5.5

**Implementation plan:**
1. Create `.github/workflows/validate-frontmatter.yml` in `seven-fortunas-brain` repo
2. Trigger: `push` to main + `pull_request` targeting main, path filter: `second-brain-core/**/*.md`
3. Copy `scripts/validate_yaml_frontmatter.py` (or equivalent) to brain repo `scripts/`
4. CI fails if any `.md` file is missing required frontmatter fields
5. Open PR to brain repo, deploy, verify

**Test file:** `seven-fortunas-brain/.github/workflows/validate-frontmatter.yml`
**Live verification (SDD-8):** After deploying, open a test PR in the brain repo with a file missing
`version:`. Confirm CI fails. Remove the bad file, confirm CI passes.
**SDD registration:** P5-002 added to `test-design-qa.md`

---

### P5-003 — Lighthouse CI Scheduled Workflow (WC-001)

**Requirement:** NFR-2.1 — Dashboard performance ≥90/100, FCP <2s, TTI <5s
**Gap closed:** P3-001 is a one-time spot check (98/100 achieved). Without a scheduled gate,
performance could degrade silently as the dashboard evolves.
**Spec reference:** NFR-2.1

**Implementation plan:**
1. Create `.github/workflows/lighthouse-ci.yml`
2. Triggers: weekly cron (Sunday 09:00 UTC) + `workflow_dispatch`
3. Use `ubuntu-latest` runner — `google-chrome-stable` is pre-installed
4. Install `lighthouse` CLI: `npm install -g lighthouse`
5. Run: `lighthouse <URL> --output json --chrome-flags="--headless --no-sandbox --disable-gpu"`
6. Parse performance score via `jq .categories.performance.score`; assert `>= 0.9`
7. Upload JSON report as artifact (artifact name: `lighthouse-report-${{ github.run_number }}`)

**Test file:** `.github/workflows/lighthouse-ci.yml`
**Live verification (SDD-8):** After merge, trigger via `workflow_dispatch`. Confirm: workflow runs,
score ≥90 appears in logs, artifact uploaded to Actions run page.
**SDD registration:** P5-003 added to `test-design-qa.md`

---

### P5-004 — Coverage Gate 60% → 75% (WC-006)

**Requirement:** NFR-5.5 — Coverage target progression toward 80%
**Gap closed:** R-013 floor established at 60% in Sprint 4. `classify-failure-logs.py` is at 69%
— 6% below the new 75% target. `bounded_retry` (75%) and `circuit_breaker` (76%) already meet it.
**Spec reference:** NFR-5.5

**Current vs target:**

| Script | Sprint 4 | Sprint 5 Target |
|--------|----------|-----------------|
| `bounded_retry.py` | 75% | ≥75% (maintain) |
| `circuit_breaker.py` | 76% | ≥75% (maintain) |
| `classify-failure-logs.py` | 69% | ≥75% (+6% needed) |

**Implementation plan:**
1. Run `pytest --cov=scripts/classify-failure-logs.py --cov-report=term-missing` to find uncovered lines
2. Add targeted tests in `test_classify_failure_logs.py` to cover the identified gaps
3. Once all 3 scripts reach ≥75%, update `COVERAGE_THRESHOLD = 75` in `test_coverage_enforcement.py`
4. Update the threshold guard assertion: `assert COVERAGE_THRESHOLD == 75`

**Fallback:** If `classify-failure-logs.py` cannot reach 75% without large test additions,
raise to 72% as intermediate step, document in `spec-corrections.md` as SC-007.

**Test file:** `tests/unit/python/test_coverage_enforcement.py` + `tests/unit/python/test_classify_failure_logs.py`
**Live verification (SDD-8):** Coverage gate runs in CI on every PR — CI pass IS the live verification.
**SDD registration:** Update P4-002 entry in `test-design-qa.md` to reflect new threshold.

---

### P5-005 — Accessibility CI Workflow (WC-002)

**Requirement:** NFR-7.1/7.2 — Accessibility, keyboard navigation, WCAG compliance
**Gap closed:** P3-002 scored 93/100 with 10 manual checks unautomated. axe-cli was blocked by
ChromeDriver version mismatch (Chrome 145 vs bundled ChromeDriver 146).
**Spec reference:** NFR-7.1, NFR-7.2

**Implementation plan (preferred — extend P5-003):**
Extend `lighthouse-ci.yml` to also assert accessibility score:
- Add `--only-categories=performance,accessibility` or parse `categories.accessibility.score`
- Assert accessibility ≥ 0.90
- This avoids the axe-cli ChromeDriver issue entirely (Lighthouse uses its own bundled Chrome)

**Alternative (standalone):** `@axe-core/playwright` in a Node.js workflow — more comprehensive
but adds complexity. Defer to Sprint 6 if P5-003 extension is sufficient for Phase 1.

**Test file:** `.github/workflows/lighthouse-ci.yml` (extension)
**Live verification (SDD-8):** Piggybacks on P5-003 `workflow_dispatch` trigger.
**SDD registration:** P5-005 added to `test-design-qa.md`

---

### P5-006 — bot585 Live Approval Verification (SDD-8 Backfill)

**Requirement:** SC-004 — bot585 must actually approve PRs, not just have the workflow deployed
**Gap closed:** P2-010 BATS tests verify workflow YAML structure. SDD-8 requires live verification
that the deployed feature works in production — a real PR must be approved by bot585.
**Spec reference:** SC-004

**Implementation plan:**
1. Create branch `test/bot585-live-verify` with a trivial change (e.g., add a blank line to a docs file)
2. Open a real PR: `gh pr create --title "test: SDD-8 bot585 live verification" --body "..."`
3. Wait 90 seconds for `auto-approve-pr.yml` to trigger
4. Check: `gh pr reviews <PR_NUM> --jq '.[] | select(.state == "APPROVED") | .author.login'`
5. Assert: bot585 username appears as approver
6. Merge or close the test PR; document result in `test-results-sprint5.md`

**Live verification (SDD-8):** This step IS the live verification.
**Test file:** No new test file — scripted via `gh` CLI; result logged in sprint results doc.
**SDD registration:** Update P2-010 entry in `test-design-qa.md` to add live verification status.

---

### P5-007 — GitHub API Latency Benchmark (P3-004)

**Requirement:** NFR-2.2 — GitHub API call latency < 500ms
**Owner:** Jorge (requires `jorge-at-sf` active)

```bash
for i in 1 2 3; do
  time gh api repos/Seven-Fortunas/dashboards --silent
done
```

Record the 3 wall-clock times, take the median. Assert < 500ms.
**Expected:** Well under 500ms (typically 150–250ms from US-based runner).

---

### P5-008 — cleanup_raw_data.sh Dry-Run (P3-005)

**Requirement:** Data retention — script must not delete production files
**Owner:** Murat (local, no auth needed)

```bash
bash scripts/cleanup_raw_data.sh --dry-run
```

Assert: exits 0, output contains no production file paths, no `rm -rf` against non-temp directories.
If `--dry-run` flag doesn't exist, check if the script has a safe default mode.

---

## New Test Scenarios for QA Register

The following will be added to `test-design-qa.md` as a new Sprint 5 section:

| ID | Description | Spec Ref | Owner |
|----|-------------|---------|-------|
| P5-001 | Sentinel E2E SLA: canary failure → issue created within 5 minutes | FR-9.1 | Murat |
| P5-002 | Brain repo CI: `validate-frontmatter.yml` fails on missing frontmatter; passes on clean | FR-2.2 | Murat |
| P5-003 | Lighthouse CI: scheduled workflow runs weekly; performance ≥90; artifact uploaded | NFR-2.1 | Murat |
| P5-004 | Coverage gate at 75%: all 3 P0-risk scripts meet raised threshold | NFR-5.5 | Murat |
| P5-005 | Accessibility CI: Lighthouse accessibility ≥90 asserted in CI workflow | NFR-7.1/7.2 | Murat |
| P5-006 | bot585 live approval: real PR approved by bot585 within 90 seconds of open | SC-004 | Murat |

---

## Live Verification Summary (SDD-8 Compliance)

| ID | Method | When |
|----|--------|------|
| P5-001 | Real canary run → real sentinel issue creation | During implementation |
| P5-002 | Test PR to brain repo with bad frontmatter → CI fails | After workflow deployed |
| P5-003 | `workflow_dispatch` → Lighthouse score in logs + artifact | After workflow deployed |
| P5-004 | CI pass on PR with `COVERAGE_THRESHOLD = 75` | During implementation |
| P5-005 | Accessibility score in P5-003 `workflow_dispatch` run | Piggybacks on P5-003 |
| P5-006 | Real test PR → bot585 approves within 90 seconds | During implementation |
| P5-007 | Live `gh api` timing (Jorge) | Session |
| P5-008 | Local `--dry-run` execution | During implementation |

---

## Success Criteria — Sprint 5 Complete When:

- [ ] P5-001: Sentinel E2E SLA job runs live; `assert-sla` job passes; issue created < 5 min
- [ ] P5-002: Brain repo CI deployed; test PR with bad frontmatter fails; clean file passes
- [ ] P5-003: Lighthouse CI workflow deployed; `workflow_dispatch` run produces score ≥90 + artifact
- [ ] P5-004: Coverage gate raised to 75%; all 3 P0 scripts at ≥75%; CI passes
- [ ] P5-005: Accessibility ≥90 asserted in CI; visible in Lighthouse workflow run
- [ ] P5-006: Real test PR confirmed approved by bot585 within 90 seconds
- [ ] P5-007: Jorge records API latency (3 runs, median < 500ms)
- [ ] P5-008: `cleanup_raw_data.sh --dry-run` exits 0
- [ ] `test-design-qa.md` updated with P5-001 through P5-006 scenarios
- [ ] `test-results-sprint5.md` created with all results
- [ ] `SESSION-STATE.md` updated with new counts
- [ ] Zero regressions on full regression run (470 pass + 3 xfail as baseline)

---

## Deferred to Sprint 6

| ID | Improvement | Reason for Deferral |
|----|-------------|---------------------|
| WC-004 | Mutation testing on `bounded_retry` + `circuit_breaker` | Highest implementation complexity (`mutmut` setup + baseline); P5-001 through P5-006 close more risk per unit of effort |
| Coverage to 80% | NFR-5.5 final target | Incremental: 60% (Sprint 4) → 75% (Sprint 5) → 80% (Sprint 6) |

---

## Files in This Test Plan

```
_bmad-output/test-artifacts/test-design/
├── SESSION-STATE.md              ← Resumption guide + current counts
├── sprint4-plan.md               ← SDD rules (source of Sprint 5 items) — permanent reference
├── sprint5-plan.md               ← THIS FILE
├── spec-corrections.md           ← SC-001–SC-006 formal corrections log
├── test-design-architecture.md   ← Testability concerns, risk register
├── test-design-qa.md             ← Full test scenario register
├── test-results-sprint1.md through sprint4.md
└── test-results-sprint5.md       ← Created when Sprint 5 executes
```

---

*Execute in order P5-001 → P5-008. Apply SDD-8 live verification to every item before marking PASS.*
