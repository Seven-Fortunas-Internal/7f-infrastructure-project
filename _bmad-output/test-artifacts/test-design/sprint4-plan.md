# Sprint 4 Plan — Seven Fortunas Phase 1 Infrastructure

**Author:** Murat (TEA Agent — Master Test Architect)
**Date:** 2026-03-03
**Status:** ACTIVE — In Execution
**Supersedes:** Sprint 3 work queue in `SESSION-STATE.md`
**Related:** `test-design-qa.md` · `test-design-architecture.md` · `spec-corrections.md`

---

## Context: Where We Stand

### Automated Test Suite — Clean Baseline (2026-03-03)

| Sprint | Suites | Assertions | Status |
|--------|--------|------------|--------|
| Sprint 1 — P0 (8 suites) | 8 | 131 pass + 3 xfail | ✅ Complete |
| Sprint 2 — P1 (9 suites) | 9 | 181 pass | ✅ Complete |
| Sprint 3 — P2 + P1-003 (7 suites) | 7 | 75 pass (P2-001 fix confirmed) | ✅ Complete |
| BATS validator suite | 1 | 174 pass | ✅ Complete |
| **Running total** | **25** | **421 pass + 3 xfail** | ✅ Zero regressions |

Sprint 3 had 30 findings (P2-001: `version` field missing in 10 brain files). All 30 now pass
after the fix was applied and confirmed with a full regression run on 2026-03-03.

### Live Infrastructure — Partial Pass

| Run | Pass | Fail | Skip | Status |
|-----|------|------|------|--------|
| Run 3 (current) | 22 | 2 | 4 | ⚠️ Partial |
| Target | 28 | 0 | ≤4 | Goal |

2 remaining failures: `P1-008-d` (founders not invited) and `P1-016-b` (`cached_updates.json`
not deployed) — both deferred by Jorge pending org readiness.

---

## Spec-Driven Development (SDD) Enforcement Rules

These rules are permanent. They govern all future work on this project, not just Sprint 4.

| # | Rule | Trigger | Action |
|---|------|---------|--------|
| SDD-1 | **Spec-first** | Any new workflow, script, or feature | Add to test register *before* implementation, or log as retroactive entry immediately after |
| SDD-2 | **Test registration** | Any PR touching `.github/workflows/` | Add or update scenario in `test-design-qa.md` for the changed behaviour |
| SDD-3 | **Corrections log** | Any spec discrepancy found during testing | Record in `spec-corrections.md` within the same session — never leave corrections undocumented |
| SDD-4 | **Coverage gate** | Before next autonomous implementation run | P0-risk scripts must reach 60% unit test coverage |
| SDD-5 | **Contract enforcement** | Any change to `classify-failure-logs.py` output | JSON schema contract test must pass before merge |
| SDD-6 | **Session close** | End of every test session | `SESSION-STATE.md` updated with new counts and open items |
| SDD-7 | **No silent debt** | Any manual test bypassed due to time | Log in `SESSION-STATE.md` as deferred with owner and condition for resolution |

---

## Sprint 4 Work Queue

### Murat's Items (Automated)

Priority is risk × value. Complete in order — do not jump ahead.

| # | ID | File | Description | Risk Closed | Priority |
|---|----|------|-------------|------------|---------|
| 1 | **P2-010** | `tests/bats/test_bot_approval.bats` | `auto-approve-pr.yml` deployed to all 14 repos; workflow structure validates against spec | R-new (bot approval coverage gap) | 🔴 High |
| 2 | **P4-001** | `tests/unit/python/test_classify_output_contract.py` | JSON output schema validation for `classify-failure-logs.py` — `REQUIRED_FIELDS`, `VALID_CATEGORIES`, output shape, downstream-safe field types | R-007 (runtime silent breakage) | 🔴 High |
| 3 | **P4-002** | `tests/unit/python/test_coverage_enforcement.py` | Verify P0-risk scripts reach 60% coverage threshold; fail CI if below | R-013 (coverage blind spot) | 🟡 Medium |
| 4 | **P4-003** | `tests/bats/test_bot_approval.bats` (live section) | `APPROVER_PAT` secret exists at org level in both orgs (requires `jorge-at-sf`) — add to `validate-live-infrastructure.sh` | R-new (secret coverage gap) | 🟡 Medium |

### Jorge's Items (Manual / Live Infra)

| # | ID | Description | Condition to close | Priority |
|---|----|-------------|-------------------|---------|
| 1 | **P3-001** | Lighthouse CLI performance benchmark — run against deployed AI dashboard; record score | Install: `npm install -g @lhci/cli` · run: `lhci autorun` | 🟡 Medium |
| 2 | **P3-002** | Accessibility keyboard navigation — tab through AI dashboard; verify no keyboard traps | Browser: open dashboard, Tab key through all interactive elements | 🟡 Medium |
| 3 | **P3-003** | Verify all 4 founders have 2FA individually — check org audit log or member settings | `gh api orgs/Seven-Fortunas/members` — confirm 2FA for Jorge, Henry, Buck, Patrick | 🟡 Medium |
| 4 | **P1-008-d** | Invite Henry, Buck, Patrick to Seven-Fortunas org | Pending org readiness — Jorge to initiate | 🟢 Low (deferred) |
| 5 | **P1-016-b** | Deploy `cached_updates.json` via dashboard-curator to GitHub Pages | Pending content pipeline — Jorge to initiate | 🟢 Low (deferred) |

---

## World-Class Improvements — Backlog

These are not Sprint 4 blockers but are the gap between "good" and "world-class." Capture here so they are not forgotten.

| ID | Improvement | Rationale | Target Sprint |
|----|------------|-----------|---------------|
| WC-001 | Lighthouse CI as a scheduled workflow (not manual) | `lhci` runs headlessly; P3-001 becomes a regression gate, not a spot check | Sprint 5 |
| WC-002 | axe-core accessibility CI workflow | Keyboard nav is automatable; removes human error from P3-002 | Sprint 5 |
| WC-003 | Sentinel E2E SLA assertion | FR-9.1 says "detect within 5 minutes" — no test currently asserts this end-to-end timing | Sprint 5 |
| WC-004 | Mutation testing on bounded_retry + circuit_breaker | Verify tests actually detect regressions, not just pass | Sprint 5 |
| WC-005 | Brain repo CI: run P2-001 frontmatter tests in brain repo pipeline | Prevents new files without `version` field from ever reaching main | Sprint 5 |
| WC-006 | Coverage target progression: 60% → 75% → 80% (NFR-5.5 target) | Incremental — enforce 60% in Sprint 4, raise threshold as coverage improves | Sprint 5-6 |

---

## New Test Scenarios Added to QA Register

The following scenarios were added retroactively to `test-design-qa.md` during Sprint 4
documentation to close the SDD-1 gap (new behaviour with no test registration).

| ID | Scenario | Spec Reference | Owner |
|----|---------|----------------|-------|
| P2-010 | `auto-approve-pr.yml` deployed to all repos in both orgs | FR-new (bot585 integration — 2026-03-03) | Murat |
| P4-001 | JSON output schema contract for `classify-failure-logs.py` | FR-9.2 output contract | Murat |
| P4-002 | P0-risk script coverage ≥60% enforcement | NFR-5.5 (coverage gate) | Murat |
| P4-003 | `APPROVER_PAT` org-level secret in both orgs | FR-new (bot585 integration — 2026-03-03) | Jorge (live infra) |

---

## Success Criteria — Sprint 4 Complete When:

- [ ] `test_bot_approval.bats` runs clean — all 14 repos confirmed, workflow structure verified
- [ ] `test_classify_output_contract.py` passes — JSON contract enforced on current and future outputs
- [ ] `test_coverage_enforcement.py` passes — P0 scripts at ≥60%
- [ ] `validate-live-infrastructure.sh` updated — P4-003 (`APPROVER_PAT`) added
- [ ] P3-001, P3-002, P3-003 completed by Jorge and results recorded
- [ ] `SESSION-STATE.md` updated with final counts
- [ ] `spec-corrections.md` up to date with all known corrections
- [ ] Zero regressions on full regression run (python + bats)

---

## Known Risks Going Into Sprint 4

| Risk | Impact | Mitigation |
|------|--------|-----------|
| P0 script coverage at 7% — silent regressions possible in 25 untested scripts | High — CI backbone has no safety net | P4-002 sets the 60% floor; WC-006 tracks path to 80% |
| `classify-failure-logs.py` output consumed by sentinel with no schema guard | Medium — silent downstream breakage on schema change | P4-001 adds contract test as merge gate |
| New behaviour (bot585, sentinel fix, dashboards protection) added without spec entry | Low — documented retroactively in `spec-corrections.md`; test registration closed by P2-010/P4-003 | SDD-1/SDD-2 rules prevent recurrence |
| P3 manual items have no automated equivalent | Low — acceptable for Phase 1; WC-001 through WC-003 close this in Sprint 5 | Deferred by design |

---

## Files in This Test Plan

```
_bmad-output/test-artifacts/test-design/
├── SESSION-STATE.md              ← Resumption guide + current counts (updated each session)
├── sprint4-plan.md               ← THIS FILE — Sprint 4 master plan
├── spec-corrections.md           ← Formal log of spec corrections
├── test-design-architecture.md   ← Testability concerns, risk register
├── test-design-qa.md             ← Full test scenario register (39 original + new P2-010, P4-001-003)
├── test-results-sprint1.md       ← Sprint 1 (P0): 131 pass + 3 xfail
├── test-results-sprint2.md       ← Sprint 2 (P1): 181 pass
├── test-results-sprint3.md       ← Sprint 3 (P2 + P1-003): 75 pass + 30 findings (now resolved)
└── test-results-sprint4.md       ← Sprint 4: in progress
```

---

*Sprint 4 is active. Execute in order. Do not deviate without updating this plan.*
