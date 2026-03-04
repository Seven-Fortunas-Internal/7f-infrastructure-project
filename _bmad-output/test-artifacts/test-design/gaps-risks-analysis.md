# Gaps & Risks Use-Case Analysis — Sprint 7

**Document:** Post-Sprint-6 gap analysis driving Sprint 7 implementation
**Date:** 2026-03-03
**Status:** ACTIVE — each gap drives a Sprint 7 work item

---

## Gap 1 — `workflow_run` Event Delivery (Sentinel)

### Use Case Broken
A workflow fails in the Seven-Fortunas-Internal org. GitHub queues a `workflow_run`
event to trigger the sentinel's `detect-failure` job. If GitHub drops or delays the
event (known platform behaviour under high load), the sentinel never fires and the
CI failure goes undetected. No issue is created, no retry is attempted, and the
engineering team is not notified.

### Who Is Affected
- On-call engineer: misses SLA for P1 failures
- Jorge: silent dashboard — sprint health appears green when it is not
- BMAD Agent (next run): starts from an uncorrected broken state

### Observed Evidence
P6-002 exposed this: the sentinel fires correctly when event delivery works, but
the BATS integration test for SLA cannot reliably trigger a real `workflow_run` in
CI because event delivery latency is non-deterministic (runner-to-runner).

### Alternatives

| Option | Pros | Cons |
|--------|------|------|
| **Scheduled polling job (15-min cron)** | Deterministic, no event dependency | 15-min worst-case detection gap; slightly more API calls |
| **Redundant push-based + polling hybrid** | Best coverage, belt-and-suspenders | More complex to maintain; two paths to keep in sync |
| **GitHub Status Checks API (blocking)** | Prevents merges on failure | Requires Pro/Enterprise protected-branch PRs; not Free-tier friendly |
| **Keep event-only (status quo)** | Zero added complexity | Failure goes undetected when event dropped |

### Recommended Compromise
Implement a scheduled `sentinel-health-poll.yml` workflow that runs every 15 minutes.
It queries the GitHub Runs API for any workflow run that completed with `failure` in
the last 20 minutes and has NOT already generated a `ci-failure` issue. This provides
a deterministic backstop without replacing the event-driven path.

**Sprint 7 coverage:** Documented here. Implementation deferred to Sprint 8
(requires new workflow + issue-dedup logic). P6-002 CONDITIONAL stays open.

---

## Gap 2 — `dashboards` Branch Protection (SC-006)

### Use Case Broken
The `Collect Metrics` workflow requires a direct push to the `dashboards` branch in
the Seven-Fortunas/dashboards repo. The current branch protection rule for
`dashboards/main` requires at least one reviewer. This forces the workflow to either
bypass review (weakening the policy) or fail silently when it cannot push.

### Who Is Affected
- Sprint dashboard: metrics data staleness if push fails silently
- SOC 2 auditor: branch protection exception creates a control gap (SC-006 waiver
  recorded in spec-corrections.md)
- Security posture: any CI bot with Write access bypassing review is a risk surface

### Observed Evidence
SC-006 waiver was accepted in Sprint 6. The workflow uses a dedicated bot account
(`bot585`) with Write collaborator access. This satisfies the process gate but not
the spirit of the branch protection policy.

### Alternatives

| Option | Pros | Cons |
|--------|------|------|
| **Actor bypass in ruleset** (Free plan) | Policy-compliant bypass for known actor | Free plan rulesets have limited actor-bypass support; needs verification |
| **Separate `data` branch for metrics** | Main stays protected; data flows to data branch | Adds branch management complexity; dashboard reads from data branch |
| **Artifact-only approach** (no push) | No branch protection conflict | Dashboard must read from artifacts API, not git; bigger refactor |
| **Accept waiver (status quo)** | Zero implementation effort | Control gap persists; SC-006 cannot be fully closed |

### Recommended Compromise
Move metrics output to a `data/` branch (orphan branch, separate from `main`
history). Dashboard reads from `data/` branch. Main branch protection remains
strict. This separates concerns cleanly and closes SC-006 without policy exceptions.

**Sprint 7 coverage:** Waiver documented in spec-corrections.md. Full resolution
deferred to Sprint 8.

---

## Gap 3 — Mutation Scope (Only `bounded_retry.py` Tested)

### Use Case Broken
A developer modifies `circuit_breaker.py` — e.g., changes `>= MAX_CONSECUTIVE_FAILED_SESSIONS`
to `> MAX_CONSECUTIVE_FAILED_SESSIONS` (off-by-one). The change silently ships
because no mutation tests exist for this module. The circuit breaker now requires
6 consecutive failures instead of 5 before terminating, allowing an extra failing
session to run and consume API budget unnecessarily.

Similarly, a change to `classify-failure-logs.py` fallback pattern matching — e.g.,
swapping `is_retriable: True` to `False` for `timeout` — causes the sentinel to
stop retrying transient failures, leading to false-positive permanent issue tickets.

### Who Is Affected
- Dev Agent: behaviour changes silently without test failures
- Jorge: autonomous agent may over-run or under-run sessions
- CI reliability: false-positive issue tickets for retriable failures

### Observed Evidence
Sprint 6 mutation testing covered only `bounded_retry.py` (78.1% score). The
`circuit_breaker.py` and `classify-failure-logs.py` modules had zero mutation
coverage — confirmed gap.

### Alternatives

| Option | Pros | Cons |
|--------|------|------|
| **Add mutation tests (P7-002, P7-003)** | Directly closes the gap | Takes implementation time this sprint |
| **Contract tests (input/output pairs)** | Simpler than mutation testing | Less rigorous; misses operator-flip mutants |
| **Static analysis only (mypy, ruff)** | Zero effort | Does not catch logic mutations at all |

### Recommended Compromise
Implement P7-002 and P7-003 this sprint. Target ≥85% for `circuit_breaker.py` and
≥80% for `classify-failure-logs.py` (lower target for classify because network and
subprocess paths are not testable under unit test isolation).

**Sprint 7 coverage:** P7-002 and P7-003 — implemented this sprint.

---

## Gap 4 — `cleanup_raw_data.sh` Live Deletion Untested

### Use Case Broken
`cleanup_raw_data.sh` runs in production (scheduled via `ci-canary-test.yml` or
manually by Jorge) and deletes files in `outputs/raw/`. All existing tests ran with
`--dry-run` only — the actual `rm -f` path was never exercised. A bug in the
deletion loop (e.g., wrong `find -mtime` argument, incorrect DELETED counter, or
shell word-splitting on special characters) would silently cause the script to:
- Not delete files it should (data retention policy violated)
- Delete wrong files (data loss)
- Fail with a misleading exit code

### Who Is Affected
- Data retention compliance: NFR-4.2 requires old staging data be deleted
- R-014 compliance: if script silently fails, staging data accumulates
- Jorge: false confidence from exit 0 on dry-run

### Observed Evidence
Test coverage report from Sprint 6: 7 tests, all with `--dry-run`. The live
deletion branch (`rm -f` loop) had zero test coverage.

### Alternatives

| Option | Pros | Cons |
|--------|------|------|
| **Live BATS tests with real temp files (P7-004)** | Directly exercises rm path | Slightly slower tests; real filesystem ops |
| **Mock rm via PATH override** | Isolates test from filesystem | Doesn't test actual deletion occurs |
| **Integration test against real outputs/raw/** | Most realistic | Risk of deleting real data; not safe in CI |

### Recommended Compromise
Use BATS with `mktemp -d` isolated directories and real `touch -d "N days ago"` files.
Run without `--dry-run` and assert `[ ! -f "$file" ]` afterwards. Use `PATH` override
for the permission-error test to keep it hermetic.

**Sprint 7 coverage:** P7-004 — implemented this sprint.

---

## Gap 5 — P0-001 Silent for 6 Sprints

### Use Case Broken
The `test_detection.py` test file had a collection-time error for 6 consecutive
sprints: the function under test was renamed from `detect_secret` to `_detect_secret`
but the test still called the old name. pytest collected the test, ran it, and it
silently failed at import time in some CI configurations — or the CI ran but nobody
reviewed the collection warnings. The security-critical P0-001 test was broken and
providing false confidence.

### Who Is Affected
- Security assurance: R-002 (secret detection) was never tested — 100% detection
  claim was unverified for 6 sprints
- CI gate: should fail if any test errors at collection time
- Jorge: sprint sign-offs were based on incomplete test results

### Observed Evidence
Fixed in Sprint 6 (P6-001): renamed to `_detect_secret`, added `@pytest.mark.parametrize`
for 30 cases. Now 100% detection rate verified.

### Alternatives

| Option | Pros | Cons |
|--------|------|------|
| **`pytest --error-for-unknown-mark` + collection check in CI** | Catches future collection errors | More CI config; doesn't catch logic errors |
| **`pytest --strict-markers` + explicit conftest** | Best practice | Requires conftest changes |
| **`pytest --co -q` as a CI pre-check step** | Zero code change; just add a step | Still runs all collection; slower |
| **Accept as one-time fix (status quo)** | Already fixed | Could recur in other test files |

### Recommended Compromise
Add a `pytest --co -q` (collection-only) step to the CI workflow before the main
test run. If collection fails (exit non-zero), the workflow fails fast before running
any tests. This catches any future collection-time import errors across all test files.

**Sprint 7 coverage:** Documented. CI gate change deferred to Sprint 8 (workflow edit
requires `Auto-Approve PR` flag for Jorge review per Section 6 of CLAUDE.md).

---

## Summary Table

| Gap | Risk Level | Sprint 7 Action | Owner |
|-----|-----------|-----------------|-------|
| Sentinel event delivery | HIGH | Document; schedule Sprint 8 polling job | Sprint 8 |
| dashboards branch protection | MEDIUM | Waiver maintained; Sprint 8 data-branch | Sprint 8 |
| Mutation scope (circuit_breaker, classify) | HIGH | **P7-002, P7-003 — implement now** | Sprint 7 |
| cleanup_raw_data live deletion | HIGH | **P7-004 — implement now** | Sprint 7 |
| P0-001 silent collection error | CRITICAL | Fixed in Sprint 6; CI gate in Sprint 8 | Sprint 8 |
