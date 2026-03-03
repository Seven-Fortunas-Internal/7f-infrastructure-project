# Test Design for Architecture: Seven Fortunas Phase 1 Infrastructure

**Purpose:** Architectural concerns, testability gaps, and NFR requirements. Serves as a contract between QA and Engineering on what must be addressed before test development begins.

**Date:** 2026-03-02
**Author:** Murat (TEA Agent)
**Status:** Ready for Review
**Project:** 7f-infrastructure-project (Phase 1)
**PRD Reference:** `_bmad-output/planning-artifacts/master-requirements.md` v1.14.0
**ADR Reference:** `_bmad-output/planning-artifacts/master-architecture.md` v1.9.0 (ADR-001 through ADR-007)

---

## Executive Summary

**Scope:** Full system-level test design for the Seven Fortunas Phase 1 infrastructure — two GitHub organizations, BMAD Skills Platform (26 skills), Second Brain (seven-fortunas-brain), 7F Lens AI Dashboard, CI/CD self-healing pipeline (FR-9), and CI quality gates (FR-10). Phase 1.5 (CISO Assistant, GitHub App), Phase 2 (Sprint boards, Matrix), and Phase 3 are explicitly excluded.

**Business Context:**
- **Problem:** Seven Fortunas (4-person founding team) needed a GitHub-hosted AI-native infrastructure — two orgs, knowledge management, intelligence dashboards, automated CI/CD quality gates — built autonomously to allow founders to focus on product.
- **Implementation complete:** 52/53 features pass per feature_list.json. Readiness assessment: 91/100 GO.
- **Testing gap:** Implementation was verified feature-by-feature at point-of-creation. No systematic, repeatable, regression-capable test suite exists.

**Architecture (from ADRs):**
- **ADR-001:** Two-org model (Seven-Fortunas public + Seven-Fortunas-Internal private) with team-based access control
- **ADR-003:** GitHub Actions for all automation (not Lambda, not Zapier) — free on public repos, co-located with code
- **ADR-006:** CI self-healing via workflow_run sentinel + Claude API log analysis
- **ADR-007:** CI quality gate stack (actionlint + custom NFR-5.6 validator + mypy/pylint) as prevention layer

**Expected Scale (from requirements):**
- 4 founding team members, expanding to 50+ (NFR-3.1)
- 10 repos currently, 200+ eventually (NFR-3.2)
- GitHub Actions rate: 5,000 API req/hour, 2,000 min/month (private repo limit)

**Risk Summary:**
- **Total risks identified:** 14
- **High-priority (≥6):** 4 risks requiring immediate mitigation
- **Medium (3-5):** 7 risks to monitor
- **Low (1-2):** 3 risks to document

---

## Quick Guide

### 🚨 BLOCKERS — Must Resolve Before Test Suite Can Run

**These items block reliable, repeatable test execution:**

1. **B-001: No structured JSON output from verification scripts** — Current verify-feature-*.sh scripts use ad-hoc exit codes and unstructured stdout. Tests cannot be parsed, aggregated, or reported to the QA agent. **Required:** All test scripts must output JSON to stdout in the standard format defined in the QA doc. (Owner: Murat → Jorge review)

2. **B-002: No pytest-cov instrumentation for Python scripts** — NFR-5.5 requires ≥80% code coverage. Currently no coverage baseline exists. **Required:** pytest-cov installed and configured in requirements.txt + mypy.ini before coverage gate can be enforced. (Owner: Murat)

3. **B-003: Live infrastructure tests require jorge-at-sf authentication** — All FR-1.x validation requires GitHub API access as jorge-at-sf. CI cannot run these. **Required:** A dedicated `validate-live-infrastructure.sh` script that Jorge runs manually, with JSON output fed back to QA for analysis. (Owner: Jorge)

---

### ⚠️ HIGH PRIORITY — Team Should Validate

1. **R-001: Org security settings — drift undetected** — Verify current state matches spec (2FA, push protection, secret scanning, branch protection). Last verified at implementation time. Risk of silent drift. (Jorge validates via generated live script)

2. **R-002: Secret detection rate** — Adversarial test suite exists but full 20+ scenario pass/fail never aggregated into a detection-rate metric. Need formal measurement against NFR-1.1 ≥99.5% target.

3. **R-003: FR-9 self-healing pipeline verified once** — One canary test is not a test suite. Multiple failure modes (transient, known pattern, unknown, rate-limited Claude API) untested.

4. **R-004: Dashboard error handling** — FR-4.1 specifies 6 degradation scenarios. None have been tested since deployment (all-sources-fail → ErrorBanner, stale >7 days → error page, etc.).

---

### 📋 INFO ONLY — Solutions Provided

1. **Test split:** Unit (pytest + BATS) for local scripts — 60% of tests. Live infra (bash + gh api) for GitHub state — 30%. Component (Vitest + RTL) for React dashboard — 10%.
2. **Tooling:** pytest + pytest-cov (Python), BATS (Bash), Vitest + React Testing Library (React), BATS + shellcheck (workflow YAML indirect).
3. **Tiered execution:** Automated tests (Murat runs), live infra script (Jorge runs once), manual spot checks (Jorge, 2-3 items).
4. **Coverage target:** ~65 test scenarios across P0–P3.
5. **Quality gates:** P0 = 100% pass, P1 = 95% pass, P2 = 90% pass.
6. **Live verification layer (SDD-8 — added 2026-03-03):** CI pass is necessary but not sufficient. Every PR that deploys a workflow, script, or live feature requires post-merge end-to-end verification in the production GitHub environment. See `sprint4-plan.md §Live Verification Protocol` for the method per feature type. A scenario is not PASS until live verification is logged.

---

## For Architects and Devs — Open Topics

### Risk Assessment

**Total risks identified:** 14 (4 high-priority ≥6, 7 medium 3-5, 3 low 1-2)

#### High-Priority Risks (Score ≥6) — IMMEDIATE ATTENTION

| Risk ID | Category | Description | Probability | Impact | Score | Mitigation | Owner | Timeline |
|---------|----------|-------------|-------------|--------|-------|------------|-------|----------|
| **R-001** | **SEC** | Org security settings (2FA, push protection, secret scanning, branch protection) were configured at implementation time. Silent drift is possible — no automated monitoring exists. | 2 | 3 | **6** | Run `validate-live-infrastructure.sh` to assert current state against spec. Add to quarterly review calendar. | Jorge | Before test execution |
| **R-002** | **SEC** | Secret detection rate measured informally. NFR-1.1 requires ≥99.5% against adversarial suite. No aggregate pass/fail report generated. | 2 | 3 | **6** | Expand `test_secret_patterns.py` to compute detection-rate metric. Run full 100+ baseline + 20+ adversarial scenarios. Report rate in CI. | Murat | Test implementation |
| **R-003** | **TECH** | FR-9 self-healing pipeline (detect → classify → retry → issue) verified exactly once (canary #5, Issue #42). Edge cases: multiple concurrent failures, transient classification, Claude API unavailable, rate limit hit. | 2 | 3 | **6** | Build FR-9 integration test harness with synthetic failure injection. Test all classification paths. | Murat | Test implementation |
| **R-004** | **DATA** | FR-4.1 dashboard specifies 6 degradation scenarios (all-sources-fail, stale 0-7 days, stale >7 days, ErrorBanner on fetch reject, multiple sources fail ≥50%, Claude API fail). None tested since deployment. | 2 | 3 | **6** | React component tests with mocked `fetch` and mocked data sources for each degradation scenario. | Murat | Test implementation |

#### Medium-Priority Risks (Score 3-5)

| Risk ID | Category | Description | Probability | Impact | Score | Mitigation | Owner |
|---------|----------|-------------|-------------|--------|-------|------------|-------|
| R-005 | TECH | `bounded_retry.py` and `circuit_breaker.py` — complex branching logic (retry limits, session circuit breaker, exit code 42) — zero unit tests. An agent stuck in infinite loop is a production problem. | 2 | 2 | 4 | pytest unit tests covering all retry/breaker branches | Murat |
| R-006 | TECH | `validate-and-fix-workflow.sh` (NFR-5.6 validator) is a critical shared artifact. Changes must not break NFR-5.6 enforcement. Zero unit tests. | 2 | 2 | 4 | BATS tests covering all 8 NFR-5.6 constraints (C1-C8) | Murat |
| R-007 | TECH | `classify-failure-logs.py` (FR-9.2 Claude API classification) — no unit tests for parsing, pattern matching, or fallback when Claude API is unavailable. | 2 | 2 | 4 | pytest with mocked anthropic client | Murat |
| R-008 | PERF | NFR-2.1: Dashboard FCP <2s, TTI <5s. Never measured. React 18 SPA fetches external JSON on load — cold start with network latency could exceed target. | 2 | 2 | 4 | Lighthouse CLI against live dashboard; baseline captured | Jorge |
| R-009 | BUS | BMAD skill stubs (.claude/commands/*.md) reference paths in _bmad/. If paths are wrong, skills silently fail. 26 stubs never path-validated programmatically. | 2 | 2 | 4 | Bash script validating each stub's `@{project-root}/...` path resolves to a real file | Murat |
| R-010 | DATA | Second Brain YAML frontmatter schema (context-level, relevant-for, last-updated, author, status) — no validation. Authors may omit required fields, silently breaking AI agent context loading. | 2 | 2 | 4 | Python script validating all .md files in seven-fortunas-brain have valid frontmatter | Murat |
| R-011 | SEC | FR-1.4 AC specifies adversarial test: "Script independently verified to reject wrong accounts." No evidence this was run post-implementation. | 1 | 3 | 3 | Add adversarial unit test for `validate_github_auth.sh` (mock wrong-account env) | Murat |

#### Low-Priority Risks (Score 1-2)

| Risk ID | Category | Description | Probability | Impact | Score | Action |
|---------|----------|-------------|-------------|--------|-------|--------|
| R-012 | OPS | Data retention scripts (cleanup_raw_data.sh, cleanup_archives.sh, cleanup_scan_reports.sh) exist but have never been executed. Risk: they fail silently or delete the wrong files. | 1 | 1 | 1 | Document only; dry-run test P3 |
| R-013 | OPS | NFR-5.5 code coverage ≥80% for Python scripts — no coverage baseline ever established. | 3 | 1 | 3 | Monitor; add pytest-cov to CI |
| R-014 | BUS | FR-3.3/3.4 Skill governance (skill-creator searches before creating, <5 duplicates) — governance logic not testable in Phase 1 without Phase 2 skill proliferation data. | 1 | 1 | 1 | Document; revisit in Phase 2 |

---

### Testability Concerns and Architectural Gaps

#### 🚨 ACTIONABLE CONCERNS — Architecture Team Must Address

**Critical Testability Challenge: This is infrastructure, not software. The primary system under test is GitHub-hosted state.**

The standard test pyramid (unit → integration → E2E) applies differently here:

| Layer | What Is Tested | Testable Locally? | Notes |
|-------|----------------|-------------------|-------|
| Unit | Python scripts, Bash scripts, React components | Yes — fully automated | pytest, BATS, Vitest |
| Integration | FR-9 pipeline, GitHub API mock interactions, Claude API mock | Yes — with mocks | responses library, mock anthropic |
| System/E2E | GitHub org/repo/team state, GitHub Pages deployment, live workflows | No — requires jorge-at-sf auth | Live infra script (Jorge runs) |

**Blockers to Fast Feedback:**

| Concern | Impact on Testing | What Architecture Must Provide | Owner | Timeline |
|---------|------------------|-------------------------------|-------|----------|
| **No structured test output format** | Can't aggregate pass/fail from verify-feature-*.sh scripts. Murat can't parse results. | JSON output format for all test scripts (see QA doc Appendix) | Murat | Sprint 0 |
| **Live GitHub state requires human auth** | 30% of tests (all FR-1.x infra validation) can't run in CI without jorge-at-sf credentials | Dedicated `validate-live-infrastructure.sh` with JSON output Jorge runs once per environment change | Jorge | Before test execution |
| **No pytest-cov config** | NFR-5.5 coverage target unmeasurable | Add `pytest-cov` to requirements.txt + coverage config | Murat | Sprint 0 |

**Architectural Improvements Needed:**

1. **JSON output contract for test scripts**
   - **Current problem:** verify-feature-*.sh scripts mix prose and exit codes. No machine-readable output.
   - **Required change:** All test scripts output `{"test_id": "...", "status": "PASS|FAIL", "message": "...", "duration_ms": N}` to stdout.
   - **Impact if not fixed:** Pass/fail cannot be aggregated, reported, or fed back to QA agent.
   - **Owner:** Murat (implement in new test scripts; old verify-feature-*.sh are deprecated)
   - **Timeline:** Test implementation sprint

2. **Centralised live infrastructure validation**
   - **Current problem:** 50+ verification `gh api` commands scattered across verify-feature-*.sh scripts. No single comprehensive check.
   - **Required change:** Consolidate into `tests/validate-live-infrastructure.sh` — runs all GitHub state assertions, outputs JSON report, Jorge runs once.
   - **Impact if not fixed:** Live state verification requires running 8+ separate scripts.
   - **Owner:** Murat (creates script), Jorge (runs it)
   - **Timeline:** Test implementation sprint

---

### Testability Assessment Summary

#### What Works Well

- ✅ **Git-as-database pattern** is highly testable — all data is in files, version controlled, inspectable without external services
- ✅ **Python scripts have clear interfaces** (stdin/stdout, environment variables) — mocking is straightforward
- ✅ **React dashboard is a standard React 18 SPA** — Vitest + React Testing Library cover component testing well
- ✅ **GitHub Actions YAML is structurally validatable** — actionlint + NFR-5.6 validator already exist
- ✅ **FR-9 pipeline uses artifact-based state sharing** (after PR #40 fix) — makes inter-job state testable
- ✅ **ADR-007 (CI quality gate)** and **ADR-006 (self-healing)** are complementary layers — prevention + detection
- ✅ **ANTHROPIC_API_KEY confirmed set** in 7f-infrastructure-project GitHub Secrets — Claude API calls in tests will work in CI

#### Accepted Trade-offs (No Action Required)

- **GitHub Actions workflows cannot be unit tested in isolation** — They require the GitHub runner environment. Accepted: we validate structural compliance (NFR-5.6) and trigger live runs via `workflow_dispatch`. This is standard practice for GitHub Actions testing.
- **GitHub org/team state requires live auth** — There is no way to mock the actual GitHub organization state. Accepted: Jorge runs the live validation script; this is a one-time check per environment change, not per commit.
- **Rate limit risk for live tests** — Running 50+ `gh api` calls in sequence could approach rate limits. Accepted: live script adds 100ms sleep between calls; rate limit monitoring workflow is already deployed.

---

### Risk Mitigation Plans (High-Priority Risks ≥6)

#### R-001: Org Security Settings Drift (Score: 6) — HIGH

**Mitigation Strategy:**
1. `validate-live-infrastructure.sh` includes assertions for every security setting in FR-1.3 and FR-1.6 for both orgs and all 10 repos
2. Each assertion uses `gh api` commands from the spec acceptance criteria (already documented in master-requirements.md)
3. Script outputs JSON with PASS/FAIL per setting
4. Jorge runs script; output fed to Murat for analysis
5. Quarterly re-run added to calendar

**Owner:** Murat (script), Jorge (execution)
**Timeline:** Before test execution begins
**Status:** Planned
**Verification:** Script exits 0 with all assertions PASS

---

#### R-002: Secret Detection Rate Not Formally Measured (Score: 6) — HIGH

**Mitigation Strategy:**
1. Expand `tests/secret-detection/test_secret_patterns.py` with a detection-rate calculator
2. Run all 100+ baseline + 20+ adversarial patterns
3. Compute: `detection_rate = detected / total * 100`
4. Assert `detection_rate >= 99.5` in CI (pytest assertion)
5. Report rate in test output JSON

**Owner:** Murat
**Timeline:** Test implementation sprint
**Status:** Planned
**Verification:** pytest passes with detection_rate ≥ 99.5% printed in output

---

#### R-003: FR-9 Pipeline Edge Cases Not Tested (Score: 6) — HIGH

**Mitigation Strategy:**
1. Build integration test harness that:
   - Mocks GitHub API responses (use `responses` library)
   - Mocks Claude API responses (mock anthropic client)
   - Injects synthetic workflow_run payloads
2. Test failure classification paths:
   - Transient failure → auto-retry triggered, no issue
   - Known pattern → fix PR branch created
   - Unknown pattern → issue created with ci-failure label
   - Claude API unavailable → fallback to unknown classification
3. Verify issue creation path end-to-end with mocked `gh issue create`

**Owner:** Murat
**Timeline:** Test implementation sprint
**Status:** Planned
**Verification:** All 4 classification paths return expected outcomes in test

---

#### R-004: Dashboard Degradation Scenarios Not Tested (Score: 6) — HIGH

**Mitigation Strategy:**
1. Vitest + React Testing Library component tests for `App.jsx`:
   - Mock `fetch('./data/cached_updates.json')` to reject → assert `ErrorBanner` renders
   - Mock response with `last_updated` > 7 days old → assert error page renders, not dashboard
   - Mock response with `last_updated` 0-7 days old → assert staleness warning banner renders
   - Mock all sources returning empty → assert `⚠️ Limited data` banner renders
2. Component test for `LastUpdated` — assert next update = last_updated + 6h displays
3. Component test for `ErrorBanner` — assert message content matches spec

**Owner:** Murat
**Timeline:** Test implementation sprint
**Status:** Planned
**Verification:** All 6 degradation scenarios pass in Vitest

---

### Assumptions and Dependencies

#### Assumptions

1. Phase 1.5 features (CISO Assistant, GitHub App, FR-5.4) are excluded from this test plan per Jorge's direction.
2. Phase 2 features (FR-8.x Sprint boards, Matrix) are excluded — not implemented.
3. FR-2.3 (Voice Input / OpenAI Whisper) — excluded. Henry's device-specific; not infrastructure that can be automated.
4. The live GitHub orgs (Seven-Fortunas, Seven-Fortunas-Internal) are currently in the state they were configured to be in. Test plan verifies this assumption.
5. jorge-at-sf account has `owner` rights on both GitHub orgs — required for security settings verification.
6. `ANTHROPIC_API_KEY` is set in 7f-infrastructure-project GitHub Secrets (confirmed 2026-02-25).

#### Dependencies

1. **jorge-at-sf GitHub account available** — Required for all live infra tests. Not optional.
2. **Python 3.11 + pytest + pytest-cov** — Must be installed in test environment. Currently: pytest installed, pytest-cov not confirmed.
3. **BATS (Bash Automated Testing System)** — Required for bash script unit tests. Not currently installed. Install: `sudo apt-get install bats`.
4. **Node.js 18 LTS + npm** — Required for Vitest/React component tests. Available in GitHub Actions; may need local install.
5. **seven-fortunas-brain repo access** — Second Brain tests require read access to `Seven-Fortunas-Internal/seven-fortunas-brain` via jorge-at-sf.

#### Risks to Plan

- **Risk:** jorge-at-sf account unavailable (e.g., 2FA issue, rate limit)
  - **Impact:** Live infra tests cannot run (30% of test suite)
  - **Contingency:** Defer live infra tests; all automated tests still run

- **Risk:** GitHub Pages propagation delay at test time
  - **Impact:** Live URL tests may fail on fresh deployment
  - **Contingency:** Add 30s sleep or retry loop to live URL checks

- **Risk:** External RSS/Reddit feeds return 4xx/5xx during integration tests
  - **Impact:** FR-4.1 integration tests may flap
  - **Contingency:** All integration tests use mocked feeds (no live feed calls in CI)

---

**End of Architecture Document**

**Next Steps for Architecture Team:**
1. Review Quick Guide 🚨 items — B-001, B-002, B-003 must be addressed in Sprint 0
2. Confirm jorge-at-sf has owner access on both orgs for live validation
3. Install BATS: `sudo apt-get install bats`
4. Review risk mitigation plans for R-001 through R-004

**Next Steps for QA (Murat):**
1. Implement automated test suites per QA doc (test-design-qa.md)
2. Create `tests/validate-live-infrastructure.sh` script
3. Jorge runs live infra script and shares JSON output

**Generated by:** Murat (TEA Agent — Master Test Architect)
**Workflow:** `_bmad/tea/testarch/test-design` (System-Level Mode)
**Date:** 2026-03-02
