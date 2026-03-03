# Test Plan Session State — Seven Fortunas Phase 1

**Purpose:** Resumption guide. If this conversation is interrupted, load this file first to get back on track.

**Last Updated:** 2026-03-02 (Sprint 1 complete)
**Agent:** Murat (TEA Agent — Master Test Architect)
**User:** Jorge (VP AI-SecOps)

---

## Where We Are

### Completed ✅

| Step | Output | Location |
|------|--------|----------|
| Project reconnaissance | Full project understanding (53 features, 78 requirements, 36 workflows, existing tests) | Explored by Murat |
| TD Workflow — Steps 1-5 | Test Design complete (System-Level Mode) | This directory |
| Architecture doc | Testability concerns, 14 risks, blockers | `test-design-architecture.md` |
| QA doc | 39 test scenarios P0-P3, execution strategy, JSON output contract | `test-design-qa.md` |
| Sprint 0 setup | pytest-cov, responses, pytest-json-report, BATS 1.13, Vitest installed | Committed |
| Sprint 1 — P0 tests | 8 suites, 131 assertions, 3 xfail | `tests/` — see `test-results-sprint1.md` |

### In Progress / Next

| Step | Description | Owner |
|------|-------------|-------|
| Sprint 2 — P1 tests | validate-live-infrastructure.sh, bounded_retry, circuit_breaker, workflow_validator BATS, component tests | Murat |
| Run live infra script | Jorge runs `tests/validate-live-infrastructure.sh`, shares JSON | Jorge |
| Sprint 3 — P2 tests | YAML frontmatter validator, remaining bash assertions, coverage report | Murat |
| Manual P3 checks | Lighthouse, accessibility, 2FA | Jorge |

---

## Key Decisions Made

| Decision | Value |
|----------|-------|
| Scope | Phase 1 only (no Phase 1.5, no Phase 2) |
| Output format | Scripts output JSON for Murat to parse |
| Mode | System-Level test design |
| Total tests | 39 scenarios (P0:8, P1:17, P2:9, P3:5) |
| Automation ratio | ~70% Murat, ~22% Jorge-scripted, ~8% manual |

---

## Resumption Instructions

### If Murat (TEA Agent) is resuming:

1. Load `test-design-qa.md` — this is your execution blueprint
2. Load `test-design-architecture.md` — this is your risk register
3. Current phase: **Test Implementation**
4. Start with Sprint 0 blockers (install BATS, pytest-cov, responses library)
5. Then implement in priority order: P0 → P1 → P2 → P3

### If starting from scratch after context loss:

Tell the new agent:
> "I am Murat, TEA Agent. We completed the TD workflow for Seven Fortunas Phase 1 infrastructure. The test plan is documented in `_bmad-output/test-artifacts/test-design/`. We are now in the test implementation phase. Load `test-design-qa.md` for the test list and `test-design-architecture.md` for risk context."

---

## Test Implementation Order (Next Session)

### Sprint 0 — Setup (Before Writing Tests)

```bash
# Install test dependencies
pip install pytest-cov responses pytest-json-report
sudo apt-get install bats  # or: npm install -g bats
```

### Sprint 1 — P0 Tests (Critical Path)

In this order:

1. **P0-001** — Expand `tests/secret-detection/test_secret_patterns.py`
   - Add `detection_rate` calculation
   - Assert ≥99.5% in pytest

2. **P0-006** — Write `tests/validate-all-workflows.sh`
   - Loop over all `.github/workflows/*.yml`
   - Run `scripts/validate-and-fix-workflow.sh` on each
   - Output JSON

3. **P0-007** — Write `tests/bats/test_auth_guard.bats`
   - Happy path: jorge-at-sf → exit 0
   - Adversarial: wrong-user → exit 1 + error message

4. **P0-002** — Write `tests/integration/test_fr9_pipeline.py`
   - Mock `responses` library for GitHub API
   - Mock `anthropic` client for Claude API
   - Test 4 classification paths

5. **P0-004** — Write `tests/component/dashboard/App.test.jsx`
   - All 6 degradation scenarios
   - Mocked fetch responses

6. **P0-003 + P0-005** — Included in `validate-live-infrastructure.sh` (Jorge runs)

7. **P0-008** — Write `tests/config/test_config_assertions.sh`
   - Verify CI gate workflows exist and are structured correctly

### Sprint 2 — P1 Tests (High Priority)

1. Python unit tests: `test_bounded_retry.py`, `test_circuit_breaker.py`, `test_classify_failure_logs.py`
2. BATS tests: `test_workflow_validator.bats` (C1-C8 constraints)
3. Vitest component tests: `UpdateCard`, `SourceFilter`, `SearchBar`, `LastUpdated`
4. Bash unit tests: file structure, config assertions, BMAD paths
5. Live infra script: `tests/validate-live-infrastructure.sh`

### Sprint 3 — P2 Tests + Coverage Report

1. YAML frontmatter validator (Python)
2. All remaining bash assertions
3. Run pytest-cov and generate coverage report

### Jorge's Session (After Sprint 2)

1. Run `bash tests/validate-live-infrastructure.sh` (jorge-at-sf)
2. Share JSON output with Murat
3. Run P3 manual checks (Lighthouse, accessibility, 2FA)

---

## Risk Register Summary

| Risk ID | Category | Score | Status | Owner |
|---------|----------|-------|--------|-------|
| R-001 | SEC | 6 | Open → Tested by P0-003/P0-005 | Jorge |
| R-002 | SEC | 6 | Open → Tested by P0-001 | Murat |
| R-003 | TECH | 6 | Open → Tested by P0-002 | Murat |
| R-004 | DATA | 6 | Open → Tested by P0-004 | Murat |
| R-005 | TECH | 4 | Open → Tested by P1-001/P1-002 | Murat |
| R-006 | TECH | 4 | Open → Tested by P1-004, P0-006 | Murat |
| R-007 | TECH | 4 | Open → Tested by P1-003 | Murat |
| R-008 | PERF | 4 | Open → Tested by P3-001 | Jorge |
| R-009 | BUS | 4 | Open → Tested by P1-010 | Murat |
| R-010 | DATA | 4 | Open → Tested by P2-001 | Murat |
| R-011 | SEC | 3 | Open → Tested by P0-007 | Murat |
| R-012 | OPS | 1 | Document | Murat |
| R-013 | OPS | 3 | Monitor → P2-007 | Murat |
| R-014 | BUS | 1 | Document | — |

---

## Files in This Directory

```
_bmad-output/test-artifacts/test-design/
├── SESSION-STATE.md              ← You are here
├── test-design-architecture.md  ← Testability concerns, risk register, blockers
└── test-design-qa.md            ← 39 test scenarios, execution strategy, JSON contract
```

---

**Status:** Test Design ✅ COMPLETE — Test Implementation ⏳ NEXT
