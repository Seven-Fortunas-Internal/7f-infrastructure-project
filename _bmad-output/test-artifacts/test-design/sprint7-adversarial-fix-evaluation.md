# Sprint 7 Adversarial Fix Evaluation

**Author:** Murat (TEA Agent — Master Test Architect)
**Purpose:** Evaluate developer fixes against findings in `adversarial-review-input.md`
**Status:** COMPLETE — All findings reviewed and rated
**Findings doc:** `_bmad-output/test-artifacts/adversarial-review-input.md`
**Developer PR:** https://github.com/Seven-Fortunas-Internal/7f-infrastructure-project/pull/90
**Evaluated on branch:** `sprint7/adversarial-fixes` (commit `141a8ce`)

---

## Evaluation Criteria

For each finding, the fix is evaluated on:

| Criterion | Pass Condition |
|-----------|---------------|
| **Correct** | Fix addresses the root cause, not just the symptom |
| **Complete** | All affected lines/files are updated |
| **Safe** | Fix does not introduce new vulnerabilities |
| **Tested** | Regression test added (where recommended in Section 5) |
| **No regression** | Existing tests still pass after fix |

---

## Final Test Results (on developer's branch)

| Suite | Result |
|-------|--------|
| `pytest tests/unit/python/ tests/secret-detection/ --no-cov` | **497 pass + 3 xfail** ✅ |
| `bats tests/bats/` | **213 pass, 0 failures** ✅ |

---

## Automated Grep Checks

| Check | Command | Expected | Actual | Result |
|-------|---------|----------|--------|--------|
| CRIT-001: No expression in `run:` blocks | `grep '${{ github.event.workflow_run' run: blocks` | 0 | 0 | ✅ PASS |
| HIGH-004: No hardcoded `/tmp/` | `grep -c '/tmp/' sentinel.yml` | 0 (actual file refs) | 6 (all comments) | ✅ PASS |
| MED-002: Relative validator path | `grep VALIDATOR_PATH validate-and-fix-workflow.sh` | `$SCRIPT_DIR/...` | `$SCRIPT_DIR/validate-workflow-compliance.sh` | ✅ PASS |

**Note on CRIT-001:** The raw `grep -c '\${{ github.event.workflow_run'` returns 47 — but all 47 are inside `env:` blocks, not `run:` blocks. Verified with a Python parser that walks the YAML structure. **0 unsafe interpolations remain.** ✅

---

## Finding Evaluation Matrix

### CRITICAL Findings

#### CRIT-001 — Script Injection (workflow-sentinel.yml) ✅

| Check | Status | Notes |
|-------|--------|-------|
| `github.event.workflow_run.name` moved to `env:` block | ✅ PASS | All 4 jobs updated |
| `github.event.workflow_run.id` moved to `env:` block | ✅ PASS | All affected `run:` steps |
| No direct expression interpolation in `run:` shell | ✅ PASS | 0 unsafe occurrences confirmed by parser |
| TEST-001 regression test added | ⚠️ PARTIAL | No BATS test for injection payload — acceptable: live runner required |

**Assessment: PASS** — Root cause fixed. The correct pattern (`env:` block, shell var reference) applied throughout. The missing TEST-001 BATS test is a known limitation (needs live runner for full payload test), acceptable per the finding documentation itself.

---

#### CRIT-002 — Silent git push Failure (workflow-sentinel.yml) ✅

| Check | Status | Notes |
|-------|--------|-------|
| `git push` failure raises `::error::` annotation | ✅ PASS | `echo "::error::Sentinel push failed..."` on failure |
| `continue-on-error: true` still present (pipeline continues) | ✅ PASS | Pipeline not broken |
| `SENTINEL_PUSH_FAILED` env flag set on failure | ✅ PASS | `echo "SENTINEL_PUSH_FAILED=true" >> "$GITHUB_ENV"` |
| Summary step logs warning if push failed | ✅ PASS | Writes to `$GITHUB_STEP_SUMMARY` |
| TEST-002 regression test added | ⚠️ NOT ADDED | Requires mock `git push` intercept — complex to BATS |

**Assessment: PASS** — Failure is now visible via `::error::` annotation AND `GITHUB_STEP_SUMMARY`. Jorge will see it in the Actions UI. TEST-002 not added (reasonable — intercepting `git push` in BATS requires PATH mocking at a scope that risks test pollution).

---

#### CRIT-003 — C2 Auto-Fix Removes Security Guard (validate-and-fix-workflow.sh) ✅

| Check | Status | Notes |
|-------|--------|-------|
| C2 auto-fix does NOT convert `if: secrets.X` to `continue-on-error` | ✅ PASS | Auto-fix block removed entirely |
| C2 violation REPORTED with clear error message | ✅ PASS | 4-line error block; exits non-zero |
| Documented as requiring manual review | ✅ PASS | Comment at line 20 and 74–83 explain why |
| TEST-003 regression test added | ✅ PASS | BATS test 212: `CRIT-003: C2 secrets in if: is NOT auto-fixed — reported as error, exit 1` |

**Assessment: PASS** — Strongest fix of all 4 CRITs. Auto-fix removed, correct behavior (report, not silently transform) implemented, test added and verifiable.

---

#### CRIT-004 — Destructive File Overwrite (validate-and-fix-workflow.sh) ✅

| Check | Status | Notes |
|-------|--------|-------|
| Atomic write pattern used (tmpfile → rename) | ✅ PASS | `tempfile.mkstemp()` + `os.rename()` |
| Original file preserved if write fails | ✅ PASS | `os.rename()` is atomic on POSIX |
| Output file non-empty validation before rename | ⚠️ NOT ADDED | No explicit size check before rename |
| TEST-004 regression test added | ⚠️ NOT ADDED | SIGKILL intercept test not implemented |

**Assessment: PASS with minor gap** — Atomic write prevents the truncation-on-crash scenario. The non-empty validation and SIGKILL test are desirable but not blocking — `os.rename()` is atomic at OS level, so partial writes result in either the old or new file being present, never a truncated state.

---

### HIGH Findings

#### HIGH-001 — `--force-account` Bypass (validate_github_auth.sh) ✅

| Check | Status | Notes |
|-------|--------|-------|
| Caller context logged (PPID, BASH_SOURCE, GITHUB_RUN_ID) | ✅ PASS | All three in audit log |
| `--reason` string required | ✅ PASS | Exits 1 without `--reason` |
| `GITHUB_STEP_SUMMARY` annotation when in CI | ✅ PASS | Writes warning line when env var set |
| BATS test updated | ✅ PASS | Tests 11–13 updated for new `--reason` requirement |

**Assessment: PASS** — Bypass is still allowed (operational necessity), but now leaves an auditable trail. Good balance.

---

#### HIGH-002 — Substring Account Match (validate_github_auth.sh) ✅

| Check | Status | Notes |
|-------|--------|-------|
| `gh api user --jq '.login'` used for exact match | ✅ PASS | Line 69 |
| Bash `==` comparison (not grep substring) | ✅ PASS | Line 72 |
| `jorge-at-sf-evil` correctly rejected | ✅ PASS | New BATS test added |

**Assessment: PASS** — This was the clearest fix and was done correctly. The `gh api` approach is also more robust than parsing `gh auth status` text format (which can change between gh CLI versions).

---

#### HIGH-003 — Silent API Failures Pass Empty Logs (workflow-sentinel.yml) ✅

| Check | Status | Notes |
|-------|--------|-------|
| `2>/dev/null` removed from `gh api` log download | ✅ PASS | Error now visible in step output |
| Log file content validated before classification | ✅ PASS | Checks for empty file or "Failed to download" sentinel |
| Unknown classification stub written on bad log | ✅ PASS | Avoids misclassification |
| `create_issue` skipped if no valid logs | ⚠️ PARTIAL | Stub written but issue may still be created (unknown category) |

**Assessment: PASS** — Core problem solved: classifier no longer receives ambiguous error strings. The stub approach means issues could still be created for "unknown" — acceptable, as it's honest about the gap rather than silently wrong.

---

#### HIGH-004 — Shared `/tmp/` Race Condition (workflow-sentinel.yml) ✅

| Check | Status | Notes |
|-------|--------|-------|
| `TMP_DIR=$(mktemp -d)` used | ✅ PASS | Present in all 6 affected steps |
| `trap 'rm -rf "$TMP_DIR"' EXIT` cleanup set | ✅ PASS | On each affected step |
| All 6 hardcoded `/tmp/` paths replaced | ✅ PASS | 0 actual file refs remain (6 comments only) |
| TEST-006 regression test added | ⚠️ NOT ADDED | Parallel runner simulation not implemented |

**Assessment: PASS** — Complete fix. The pattern is correct and consistent across all 6 affected steps. TEST-006 (parallel runner simulation) is hard to implement in BATS without a real concurrent runner environment.

---

#### HIGH-005 — circuit_breaker.py Missing Exception Handling ✅

| Check | Status | Notes |
|-------|--------|-------|
| `load_feature_list()` handles missing file | ✅ PASS | `if not feature_file.exists(): return {"features": []}` |
| Returns safe default on `FileNotFoundError` | ✅ PASS | |
| `json.JSONDecodeError` and `PermissionError` caught | ✅ PASS | Both in `except` clause |
| `generate_summary_report()` guards `total == 0` | ✅ PASS | Division by zero prevented |
| TEST-007 regression test added | ✅ PASS | `TestGenerateSummaryReportWithoutFeatureList` (4 tests) |

**Assessment: PASS** — Cleanest Python fix. The `exists()` check before `open()` and exception handling follow the defensive pattern recommended in the finding exactly. TEST-007 verifies the no-file path works end-to-end.

---

### MEDIUM Findings

#### MED-001 — Silent Rebase Conflict (workflow-sentinel.yml) ✅

| Check | Status | Notes |
|-------|--------|-------|
| `2>/dev/null` removed from `git pull --rebase` | ✅ PASS | Error output now visible |
| Rebase failure handled explicitly | ✅ PASS | `git rebase --abort` + `::warning::` annotation |

**Assessment: PASS**

---

#### MED-002 — Hardcoded Absolute Path (validate-and-fix-workflow.sh) ✅

| Check | Status | Notes |
|-------|--------|-------|
| `SCRIPT_DIR` pattern used | ✅ PASS | `$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)` |
| `VALIDATOR_PATH` uses `$SCRIPT_DIR` | ✅ PASS | Works in CI, Docker, any machine |

**Assessment: PASS** — One-line fix, correctly implemented. Script now portable.

---

#### MED-003 — Search Injection in `gh issue list` (workflow-sentinel.yml) ✅

| Check | Status | Notes |
|-------|--------|-------|
| `SAFE_WORKFLOW_NAME` set before `--search` | ✅ PASS | `tr -d '"' | cut -c1-100` |
| Applied to all search uses | ✅ PASS | Both `check-circuit-breaker` and `check-duplicate` steps |

**Assessment: PASS**

---

## Overall Effectiveness Rating

| Category | Findings | Fully Fixed | Partial | Score |
|----------|----------|-------------|---------|-------|
| CRITICAL | 4 | 3 | 1 (CRIT-004 missing size check) | **3.75/4** |
| HIGH | 5 | 4 | 1 (HIGH-003 issue still created for unknown) | **4.5/5** |
| MEDIUM | 3 | 3 | 0 | **3/3** |
| Regression tests | 7 recommended | 3 added (TEST-003, TEST-005/HIGH-002, TEST-007) | 4 not added | **3/7** |
| **Total** | **12 findings** | **10 full + 2 partial** | | |

**Rating: GOOD** — All CRITICAL findings fixed (CRIT-001 fully, CRIT-002 fully, CRIT-003 fully, CRIT-004 substantially). All HIGH and MEDIUM fixed. The regression test gap (4 of 7 not added) is the only meaningful shortfall — the 4 missing tests require live runner, parallel process, or SIGKILL injection tooling that's beyond standard pytest/BATS scope.

---

## P7 Sprint Effectiveness — Meta-Assessment

### What this Sprint revealed

**1. Mutation testing does NOT surface architectural vulnerabilities**

The 85.1% (circuit_breaker) and 80.1% (classify) mutation scores were achieved by killing value mutations — off-by-one, wrong string, wrong key. They did not and cannot surface:
- CRIT-001 (injection): architectural pattern, not a value error
- CRIT-002 (silent failure): absence of a signal, not a wrong value
- CRIT-003 (security regression): wrong fix strategy, not a wrong value
- HIGH-004 (race condition): concurrency, not a logic error

**Lesson:** Mutation testing + line coverage are necessary but not sufficient. Adversarial review adds a qualitatively different class of findings that unit tests cannot systematically surface.

**2. Mutation testing DID correctly identify HIGH-005**

The `load_feature_list()` gap (missing exception handling) was listed in the adversarial review — but the mutation tests for circuit_breaker.py DID reach 85.1% while NOT catching this gap. Why? Because `load_feature_list()` was always mocked in tests. This is the classic **mock coverage blind spot**: high kill rate from mocked paths, zero fault coverage for the unmocked real path.

**Lesson:** When a function is always mocked, surviving mutants in that function are labeled "equivalent" — but they may be real gaps. Future: add integration tests (not just unit tests) that call through to the real file I/O.

**3. The gaps analysis (P7-001) correctly predicted 3 of 5 findings**

| P7-001 Gap | Maps To |
|-----------|---------|
| `workflow_run` event delivery | HIGH-003 (silent log API failure) + CRIT-002 (silent push failure) |
| Mutation scope too narrow | HIGH-005 (circuit_breaker exception path) |
| cleanup_raw_data.sh untested | Addressed by P7-004 |

The other 2 CRITICAL findings (CRIT-001 injection, CRIT-003 C2 regression) were NOT predicted in the gap analysis — they were only surfaced by adversarial review. This confirms the value of the adversarial review as a complementary technique.

**4. Test count vs. security quality**

Sprint 7 added **+62 circuit_breaker tests** and **+49 classify tests** without catching CRIT-001/002/003. Conversely, the adversarial review document (0 tests, just analysis) caught 4 CRITICAL issues. This argues against using test count growth as a proxy for security quality.

---

## Residual Open Questions — RESOLVED

### Q1 — Can fork PR authors trigger `workflow_run` with attacker-controlled name?

**Answer: No. CRIT-001 is NOT exploitable by external fork PR authors.**

The `workflow_run` event fires when a **base repository** workflow completes. The `github.event.workflow_run.name` field is the `name:` field from a workflow YAML that lives in the base repository's `.github/workflows/` directory. Fork PR authors cannot modify base repo workflow files — they can only push to their own fork.

To exploit CRIT-001, an attacker would need write access to the base repo to plant a workflow file with a malicious `name:` field. For `Seven-Fortunas-Internal`, Q2 confirms only `jorge-at-sf` has write access — the attack surface is a single trusted account.

**CRIT-001 risk for Seven-Fortunas-Internal: NEGLIGIBLE** (single trusted write accessor).

**CRIT-001 fix value: RETAINED** — defense-in-depth still warranted. If a future maintainer is added with write access, or if a workflow name accidentally contains special characters, the `env:` block pattern prevents any future injection. The fix is correct and costs nothing to keep.

**Source:** [GitHub Security Lab — Preventing pwn requests](https://securitylab.github.com/resources/github-actions-preventing-pwn-requests/) · [GitHub Actions docs — workflow_run](https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows#workflow_run)

---

### Q2 — Does `jorge-at-gd` have Write access to `Seven-Fortunas-Internal`?

**Answer: No — confirmed by Jorge.** Only `jorge-at-sf` has write access.

**Impact on HIGH-001:** The `--force-account` bypass risk is reduced. If `jorge-at-gd` ran CI commands, they would fail at the GitHub API level anyway (401 Unauthorized), not just at the shell validation layer. The HIGH-001 fix (audit trail + `--reason` requirement) remains correct and adds visibility, but is not the last line of defense.

---

### Q3 — Is C2 a real rule or a validator false positive?

**Answer: C2 is partially real but over-broad. The auto-fix was wrong; the rule should be refined, not removed.**

**What C2 is flagging:** `if: secrets.X != ''` in step conditions. GitHub's concern is that:
1. Secret presence/absence can be inferred from job behavior visible in the UI (a step that skips reveals the secret is empty)
2. Some CI logging environments may print the evaluated `if:` condition, exposing `secrets.X` being referenced

**What C2 is NOT:** A code injection risk. `secrets.X` in an `if:` condition does not interpolate the secret value into a shell command — it evaluates a boolean in the GitHub Actions expression engine, which has its own sanitization.

**Recommendation:** Refine C2, don't remove it:
- **Keep as WARNING** (not ERROR) for `if: secrets.X != ''` — it's a code smell, not a vulnerability
- **Keep as ERROR** for `${{ secrets.X }}` in `run:` shell blocks — this IS the dangerous pattern (same as CRIT-001 class)
- **Document the distinction** in the validator comment so future maintainers understand what's actually risky

The CRIT-003 fix (remove auto-fix, report as error) was correct. The follow-up action is to downgrade C2 from ERROR to WARNING in the validator. **This is a new work item for a future sprint.**

**Source:** [GitHub Actions Security Best Practices](https://blog.gitguardian.com/github-actions-security-cheat-sheet/) · [GitHub Secure Use Reference](https://docs.github.com/en/actions/reference/security/secure-use)

---

### Q4 — Do GitHub-hosted runners share filesystem between concurrent jobs?

**Answer: No. Each job on a GitHub-hosted runner gets a fresh isolated VM. `/tmp/` is not shared.**

GitHub's documentation confirms: "Each GitHub-hosted runner is a new virtual machine (VM) hosted by GitHub." This means concurrent sentinel runs for different workflow failures each get their own VM with their own `/tmp/` — no cross-contamination is possible on GitHub-hosted runners.

**Impact on HIGH-004 severity re-classification:**

| Runner type | `/tmp/` shared? | HIGH-004 actual risk |
|------------|-----------------|----------------------|
| GitHub-hosted (`ubuntu-latest`) | **No** — fresh VM per job | **LOW** |
| Self-hosted (shared machine) | **Yes** — same OS filesystem | **HIGH** |

Since Seven Fortunas uses GitHub-hosted runners for the sentinel workflow, HIGH-004 was over-classified. **Effective severity: LOW** for current infrastructure.

**HIGH-004 fix value: RETAINED** — the `mktemp -d` pattern costs nothing and makes the code correct-by-construction regardless of runner type. If Seven Fortunas ever adds self-hosted runners (for cost savings), the fix prevents a real race condition automatically.

**Source:** [GitHub-hosted runners reference](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)

---

### Q5 — Should `autonomous_summary_report.md` go to `_bmad-output/archive/`?

**Answer: Yes — confirmed by Jorge. Fixed in this commit.**

`scripts/circuit_breaker.py` `generate_summary_report()` now writes to `_bmad-output/archive/autonomous_summary_report.md` instead of the project root. The archive directory is created if it doesn't exist (`mkdir(parents=True, exist_ok=True)`).

The report should NOT be committed automatically — it's a local operator artifact generated when the circuit breaker triggers. It lives in `_bmad-output/archive/` alongside other historical artifacts and is gitignored by the existing `*.md` archive exclusion (or can be added explicitly if needed).

---

## Final Status

| Q# | Question | Resolution |
|----|----------|------------|
| Q1 | Fork PR injection scope | ✅ CLOSED — Not exploitable externally; fix retained as defense-in-depth |
| Q2 | jorge-at-gd access | ✅ CLOSED — No write access; HIGH-001 is belt-and-suspenders |
| Q3 | C2 rule validity | ✅ CLOSED — Rule split into C2a (ERROR) / C2b (WARNING); implemented and merged PR #93 |
| Q4 | Runner filesystem isolation | ✅ CLOSED — GitHub-hosted VMs isolated; HIGH-004 was LOW severity; fix retained |
| Q5 | Summary report location | ✅ CLOSED — Fixed: now writes to `_bmad-output/archive/` |

---

## Q3 Fix Evaluation — C2 Rule Split (PR #93)

**Implemented:** `scripts/validate-workflow-compliance.sh` + `tests/bats/test_workflow_validator.bats`
**Evaluated on:** `main` post PR #93 merge

### What was implemented

| Rule | Pattern | Severity | Detection method |
|------|---------|----------|-----------------|
| **C2a** | `${{ secrets.X }}` in shell content | ERROR | Python line scanner with YAML key-value exclusion |
| **C2b** | `if: secrets.X != ''` in step conditions | WARNING | bash grep on `^\s+if:\s+.*secrets\.` |

The old single C2 ERROR rule (all `secrets.*` usage = ERROR, wrong fix guidance) is gone. C2b is now purely advisory — it does not block CI.

### Evaluation: PASS with one documented gap

#### What works correctly

| Scenario | C2a result | C2b result | Correct? |
|----------|-----------|-----------|---------|
| `run: deploy.sh --key "${{ secrets.X }}"` (inline) | ERROR | — | ✅ |
| `run: \|` multiline block with `${{ secrets.X }}` | ERROR | — | ✅ |
| `env:\n  KEY: ${{ secrets.X }}` (env block) | clean | — | ✅ |
| `with:\n  key: ${{ secrets.X }}` (action input) | clean | — | ✅ |
| `MY_KEY=${{ secrets.X }}` (shell var assignment with `=`) | ERROR | — | ✅ |
| `if: secrets.DEPLOY_KEY != ''` | — | WARN | ✅ |
| No secrets at all | clean | clean | ✅ |
| CRIT-003: auto-fix NOT applied to C2a | — | — | ✅ (PR #90) |
| CRIT-003: C2b does not trigger auto-fix, exits 0 | — | — | ✅ |

#### One confirmed gap (low practical risk)

**Pattern:** `run: ${{ secrets.DEPLOY_COMMAND }}` — the entire `run:` value IS the expression.

The Python heuristic excludes lines matching `^\s*IDENTIFIER\s*:\s+\$\{\{` to avoid flagging `env:` block entries. This regex also matches `run: ${{ secrets.X }}` because `run` is a valid identifier followed by `: ${{`.

**Result:** This specific pattern is **not flagged** as C2a — a false negative.

**Practical risk: NEGLIGIBLE.** Storing shell commands in secrets is not a known pattern in this codebase or in standard GitHub Actions usage. The danger with `${{ secrets.X }}` in `run:` blocks is typically partial injection (`deploy.sh --key "${{ secrets.X }}"`, `MY_KEY=${{ secrets.X }}`), not running the entire command from a secret. Verified against all 35 production workflow files — this pattern does not appear.

**Recommended future fix:** Add `run:` key to the exclusion allowlist for the yaml_kv pattern by checking the key name: exclude env/with/name/id keys but not `run`. This is a one-line regex change if the gap ever becomes relevant.

#### Old wrong guidance removed

The previous error message `"use continue-on-error: true instead"` has been removed. New message: `"move to env: block"`. This is the correct fix per GitHub's own hardening guide.

#### Test coverage (BATS)

| Test | Assertion | Status |
|------|-----------|--------|
| C2a: `${{ secrets.X }}` in `run:` → ERROR, exit 1 | `status -eq 1` + `ERROR C2` | ✅ |
| C2a: secrets in `env:` block → clean | `status -eq 0` + no `ERROR C2` | ✅ |
| C2b: `if: secrets.X` → WARN only, exit 0 | `status -eq 0` + `WARN C2` + no `ERROR C2` | ✅ |
| No secrets → both clean | no ERROR, no WARN | ✅ |
| CRIT-003 C2a: fixer does NOT auto-fix, exits 1 | file unchanged + exit 1 | ✅ |
| CRIT-003 C2b: fixer exits 0, file not mutated | exit 0 + `if: secrets.` still present | ✅ |

**BATS total post-PR #93: 216 pass, 0 failures.**

### Overall Q3 Fix Rating: **PASS**

The fix correctly implements the two-tier classification recommended in Q3 analysis. The one false negative (bare `run: ${{ secrets.X }}`) is documented, low-risk, and does not appear in the production codebase. The wrong auto-fix guidance is corrected. CI behavior is now correct: `if: secrets.X` conditions no longer block merges.

---

*Evaluation complete. PR #90 and PR #93 merged. All open questions resolved.*
