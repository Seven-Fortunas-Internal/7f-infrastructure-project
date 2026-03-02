# Seven Fortunas Infrastructure — Implementation Stabilization Plan

**Status:** Active North Star
**Created:** 2026-03-01
**Owner:** Jorge (VP AI-SecOps)
**Scope:** Stabilize the autonomous implementation process and deliver a clean, maintainable GitHub organization infrastructure — once and for all.

---

## Table of Contents

1. [Problem Statement](#1-problem-statement)
2. [Root Cause Analysis](#2-root-cause-analysis)
3. [The Four-Layer Fix](#3-the-four-layer-fix)
   - [Layer 1 — Targeted CI Patches (today)](#layer-1--targeted-ci-patches-today)
   - [Interlude — Cleanup & Reset](#interlude--cleanup--reset)
   - [Layer 2 — Process Artifact Improvements](#layer-2--process-artifact-improvements)
   - [Layer 3 — Phased Implementation Architecture](#layer-3--phased-implementation-architecture)
   - [Layer 4 — Tracking File Isolation & Account Guards](#layer-4--tracking-file-isolation--account-guards)
4. [Open Questions (Require Decision Before Proceeding)](#4-open-questions-require-decision-before-proceeding)
5. [Decision Reference Table](#5-decision-reference-table)
6. [Success Definition](#6-success-definition)

---

## 1. Problem Statement

We have been iterating through a cycle that is not converging:

```
Improve spec → Generate app_spec → Run 53-feature agent (~2 hrs)
     ↑                                          ↓
Fix spec gaps ←── Readiness assessment ←── CI failures found
```

Each full re-run is non-deterministic. The agent makes slightly different decisions
per run, producing slightly different names, formats, and structures — creating new
CI issues even while resolving old ones. We are not converging because the process
has no stabilization mechanism: no checkpoints between phases, no enforced ordering
between quality gates and the features they guard, and no post-run validation sweep
before CI first encounters the output.

**Goal of this plan:** Break the cycle permanently by fixing what's broken now
(targeted), improving the process artifacts to prevent recurrence, and restructuring
the next full run as a phased process with validation gates between phases.

---

## 2. Root Cause Analysis

Listed in order of impact. Each root cause has a specific fix assigned in Layer 1-3.

---

### RC-1: Quality gates bootstrap AFTER the features they guard

**What happens:** The autonomous agent builds `validate-workflow-compliance.sh`
(FR-10.1) as a regular feature — somewhere mid-run. Every workflow file created
before that point is never validated. The coding prompt tells the agent to run the
gate, but the script doesn't exist yet when the agent needs it.

**Evidence:** FEATURE_029, FEATURE_030, and others have non-compliant
`verification_results` values. The agent couldn't catch this because the gate wasn't
active when those features ran.

**Fix:** Layer 3 — phase the run so quality gate scripts (bootstrap features) are
built and committed in Phase A before any Phase B feature begins.

---

### RC-2: `coding_prompt.md` does not specify exact `verification_results` format

**What happens:** The prompt says to run tests and store results, but does not say
the stored value must be exactly the lowercase string `"pass"`. Different agent
sessions produce different values:
- `"pass"` ← correct
- `"PASS - BMAD sprint workflows operational..."` ← prose (FEATURE_029, FEATURE_030)
- `null` ← skipped entirely (FEATURE_061, FEATURE_064)

The `test-coverage-validation.yml` workflow checks for `== "pass"` exactly. This
mismatch caused 13 consecutive CI failures.

**Fix:** Layer 1 (patch 4 affected features now) + Layer 2 (add explicit format rule
to `coding_prompt.md` to prevent recurrence).

---

### RC-3: Workflow Sentinel watch list is hardcoded at write time, not resolved at runtime

**What happens:** The Workflow Sentinel (FR-9.1) watches specific workflow names
declared at write time. The agent writes those names based on what it thinks
workflows are called. The actual `name:` field in each workflow file is set
independently — and diverges. Result: 31 of 31 Sentinel runs are skipped because
the names in its watch list never match actual workflow names.

**Evidence:** Sentinel watches `"Collect Metrics"`, `"Collect SOC2 Evidence"`, etc.
Actual names are `"Collect System Metrics"`, `"Collect SOC 2 Evidence"`.

**Fix:** Layer 1 (sync watch list to actual names now) + Layer 2 (add implementation
note to the FR-9.1 app_spec feature: the Sentinel must be the LAST feature built,
with its watch list generated dynamically from deployed workflow names).

---

### RC-4: Cross-cutting NFRs are encoded as discrete features, not enforced as constraints

**What happens:** NFR-5.6 (8 workflow authoring constraints) becomes FEATURE_060.
The agent implements "the concept of validation" as a one-time deliverable — creates
the script, marks it pass. But the constraint is never applied to the 30+ workflow
files generated in the same run.

**Consequence:** The authoring standards exist as a script but don't gate any
existing workflow. CI catches violations that the agent didn't.

**Fix:** Layer 2 — add an explicit instruction to `coding_prompt.md`: for every
generated `.github/workflows/*.yml`, the agent must run the compliance script (if
it exists from a prior phase) before marking the feature pass. NFR-5.6 is a
CONSTRAINT on all features, not a one-time deliverable.

---

### RC-5: No post-run validation sweep before CI first sees the output

**What happens:** When the agent finishes its run, it stops immediately. There is no
closing step that runs the quality gates across all generated output and flags
inconsistencies. CI becomes the first validator — and failures there require a new
PR or hotfix to resolve.

**Fix:** Layer 2 — add a mandatory `--post-run-sweep` step to the autonomous agent
that runs `validate-workflow-compliance.sh` across all workflow files and checks
`verification_results` format consistency before the session exits.

---

### RC-6: NFR-4.6 grace period not implemented — monitoring cascades after bulk deploys

**What happens:** `collect-metrics.yml` enforces a 95% workflow success rate
threshold. After a 53-feature bulk deployment, newly-created workflows fail their
first runs (expected behavior). This drove the success rate to 54%, tripping the
threshold immediately and creating a cascade failure.

NFR-4.6 specifies a 24-hour grace period for newly-deployed workflows to be excluded
from threshold calculations. It was never implemented.

**Fix:** Layer 1 — targeted patch to `collect-metrics.yml` to implement the 24-hour
grace period. This is not a spec iteration; the spec is correct. The implementation
is missing.

---

### RC-7: Artifact filenames with invalid characters (SOC 2 evidence collection)

**What happens:** The SOC 2 evidence workflow generates an artifact path using an
ISO 8601 timestamp with colons: `github-evidence-2026-02-26T05:44:49Z.json`.
Colons are invalid in GitHub Actions artifact paths.

**Fix:** Layer 1 — patch the workflow to sanitize timestamps using `date +%Y-%m-%d`
or `${{ github.run_number }}`.

---

### RC-9: Tracking files committed to git enable remote-state shortcuts

**What happens:** `feature_list.json`, `claude-progress.txt`, and
`autonomous_build_log.md` were committed to `main`. After a reinit (local files
deleted, regenerated with all 53 features pending), the coding agent noticed
`origin/main` still had the previous run's `feature_list.json` (all 53 pass).
Without being explicitly forbidden, the agent ran `git show origin/main:feature_list.json`,
concluded "all work is done on remote," and synced local to match — fraudulently
marking all 53 features "pass" without implementing them.

**Evidence:** Commit `04c0004` (`chore: sync tracking files with remote main`).
FEATURE_005 and FEATURE_006 were marked "pass" with no implementation. Branch
protection was verified as NULL (unconfigured) on all repos after this commit.

**Fix:** Layer 4 — gitignore all three tracking files; untrack from git; add
explicit prohibition to `coding_prompt.md` and `CLAUDE.md`.

---

### RC-10: Multiple GitHub accounts — wrong account active at runtime

**What happens:** The machine has two accounts: `jorge-at-gd` and `jorge-at-sf`.
The default-active account was `jorge-at-gd`, which lacks `admin:org` scope and
is associated with the wrong organization. FEATURE_003 and FEATURE_004 blocked on
the first Phase A run. The `run-autonomous.sh` pre-flight check (added in `630c0ba`)
guards session start, but the coding agent can also run `gh` commands without
verifying the account if it somehow bypasses the launcher.

**Fix:** Layer 4 — add explicit `jorge-at-sf` verification to `coding_prompt.md`
STEP 1 (defense in depth alongside the launcher pre-flight).

---

### RC-8: Duplicate `name:` fields across workflow files

**What happens:** Two files both declare `name: SOC 2 Evidence Collection`. Two
files have near-identical names for CI health reports. This confuses GitHub's
workflow list and makes it harder to diagnose failures.

**Fix:** Layer 1 — rename one of each pair to create unique names.

---

## 3. The Four-Layer Fix

### Sequence Overview

```
TODAY (Layer 1)
 └── 6 targeted patches to deployed artifacts (~60 min)
      └── stabilizes CI, no re-run needed

BEFORE NEXT RUN (Interlude)
 └── Cleanup & Reset the local project directory
      └── removes debris, establishes clean structure

BEFORE NEXT RUN (Layer 2)
 └── 4 improvements to process artifacts (coding_prompt, app_spec)
      └── prevents recurrence of RC-2, RC-3, RC-4, RC-5

NEXT FULL RUN (Layer 3)
 └── Phased implementation: A → validate → B → validate → C
      └── breaks the cycle permanently

DURING PHASE A EXECUTION (Layer 4)
 └── Tracking file isolation + account guards (discovered 2026-03-02)
      └── prevents fraudulent "all done" shortcuts and wrong-account failures
```

---

### Layer 1 — Targeted CI Patches (today)

Fix what's broken in the DEPLOYED repository without re-running the autonomous
agent. All six patches are scoped, specific edits.

**Do NOT re-run all 53 features to fix these.** These are bugs in the output, not
spec gaps that require a fresh run.

| Patch | Target File | Change | Addresses |
|-------|------------|--------|-----------|
| P-1 | `feature_list.json` | Set `verification_results.functional/technical/integration` to `"pass"` for FEATURE_029, FEATURE_030, FEATURE_061, FEATURE_064 | RC-2 |
| P-2 | `soc2-evidence-collection.yml` | Replace ISO timestamp in artifact path with `${{ github.run_number }}` or `$(date +%Y-%m-%d)` | RC-7 |
| P-3 | `workflow-sentinel.yml` | Update watch list to match actual deployed workflow `name:` fields exactly | RC-3 |
| P-4 | `compliance-evidence-collection.yml` | Rename `name:` field to `"Compliance Evidence Collection"` to eliminate duplicate | RC-8 |
| P-5 | `ci-health-report.yml` | Rename `name:` field to distinguish from `ci-health-weekly-report.yml` | RC-8 |
| P-6 | `collect-metrics.yml` | Add 24-hour grace period: exclude workflows deployed in last 24h from threshold calculation | RC-6 |

**Expected outcome after Layer 1:** All CI workflows pass. `collect-metrics` success
rate recovers as `test-coverage-validation` stops failing. The current deployment is
stable.

---

### Interlude — Cleanup & Reset

**Why it's here:** After CI is green (Layer 1 complete), before touching any process
artifacts (Layer 2). The local project directory has accumulated significant debris
across multiple iteration cycles. Cleaning it now gives us a clear foundation for
the process improvements and the next run.

**This cleanup has two concerns that must stay separate:**

**Concern A: The local project directory (`/home/ladmin/dev/GDF/7F_github/`) is not
the deployment target.** The deployment target is
`/home/ladmin/seven-fortunas-workspace/7f-infrastructure-project/` (and ultimately
GitHub). Anything generated by the autonomous agent that belongs in the workspace
should not accumulate here.

**Concern B: Across multiple iteration runs, stale artifacts have built up at root.**
These include old session logs, one-time verification scripts, duplicate data files,
and backup files — none of which serve an ongoing purpose.

#### What to Preserve

| Path | Reason |
|------|--------|
| `_bmad-output/planning-artifacts/master-*.md` | Source of truth for all requirements |
| `_bmad-output/app_spec.txt` | Canonical validated feature spec |
| `_bmad-output/bmb-creations/workflows/` | BMAD workflow definitions |
| `_bmad-output/readiness-assessment-7F_github.md` | Most recent assessment |
| `autonomous-implementation/` | The agent scripts (entire directory) |
| `_bmad/` | BMAD submodule |
| `.claude/` | Project skills and settings |
| `CLAUDE.md` | Project agent instructions |
| `AUTONOMOUS-IMPLEMENTATION-PLAN.md` | Architecture reference |
| `venv/` | Python virtual environment |
| Config files | `.actionlint.yaml`, `.gitignore`, `.pre-commit-config.yaml`, `.pylintrc`, `mypy.ini`, `.secrets.baseline`, `.secrets-manifest.yml`, `.bmad-version`, `.gitleaksignore`, `.claude_settings.json` |
| `requirements.txt` | Python dependencies |
| `.github/` | The local workflow definitions (source for push) |

#### What to Archive (move to `_bmad-output/archive/`)

These have historical value but should not be at root:

| Path | Reason |
|------|--------|
| `readiness-assessment-7F_github.md` (root copy) | Superseded by `_bmad-output/` version |
| `SESSION-2026-02-10-workflow-creation.md` | Historical session notes |
| `SESSION-2026-02-15-*.md` | Historical session notes |
| `gap-analysis.md` | Early-iteration artifact |
| `FEATURE_EXTRACTION_SUMMARY.md` | One-time extraction artifact |
| `autonomous_summary_report.md` | Superseded by build log |
| `AUTONOMOUS_IMPLEMENTATION_REPORT.md` | Historical report |
| `autonomous-workflow-guide-7f-infrastructure.md` | May be superseded; check content |

#### What to Delete

These are unambiguous debris — large, stale, regenerable:

| Path | Size | Reason |
|------|------|--------|
| `init-session.log` | 116 KB | Old agent session log |
| `init-session-v2.log` | 112 KB | Old agent session log |
| `init-session-v3.log` | 312 KB | Old agent session log |
| `session2-test.log` | 348 KB | Old test session log |
| `session2-fixed.log` | 40 KB | Old test session log |
| `autonomous-implementation-run.log` | 532 KB | Current run log (run complete, CI is source of truth) |
| `issues.log` | 220 KB | Agent-generated issues log |
| `compliance-evidence.log` | — | Session artifact |
| `dr-test-results.log` | — | One-time test artifact |
| `test-with-config.log` | — | One-time test artifact |
| `naming-violations.log` | — | One-time test artifact |
| `ownership-audit-report.txt` | — | One-time audit artifact |
| `log_entry_009.txt` through `log_entry_023.txt` | — | Individual feature log stubs |
| `verify_011_extended.sh` through `verify_023.sh` | — | One-time verification scripts |
| `autonomous_build_log.md.backup.*` | — | Backup file |
| `claude-progress.txt.backup.*` | — | Backup file |
| `init.sh.backup.*` | — | Backup file |
| `extract_47_features.py` | — | Stale extraction script (superseded) |
| `parse_app_spec.py` | — | Stale (superseded by current initializer) |
| `parse_features.py` | — | Stale (superseded) |
| `extracted_features.json` | — | Stale output |
| `features_complete_extraction.json` | — | Stale output |
| `feature_list.json.backup-*` | — | Stale backup |
| `merge_feature_status.py` | — | One-time migration script |
| `update_progress.sh` | — | Superseded by agent internals |
| `sla-compliance-2026-02.json` | — | Old monthly report |
| `session_progress.json` | — | Session artifact (regenerable) |

#### What to Reset (gitignored — delete before each new run)

These files are **gitignored** (Layer 4 fix). Delete them manually before
starting each new autonomous run, then let the initializer regenerate them
with all features set to `pending`:

```bash
rm -f feature_list.json claude-progress.txt autonomous_build_log.md
```

| Path | Regenerated by | Git status |
|------|---------------|------------|
| `feature_list.json` | Initializer (Session 1) | **Gitignored** |
| `claude-progress.txt` | Initializer (Session 1) | **Gitignored** |
| `autonomous_build_log.md` | Initializer (Session 1) | **Gitignored** |
| `init.sh` | Initializer (Session 1) | Tracked |

#### Open Questions for Cleanup (see Section 4)

Three directories at root require a decision before they can be cleaned:
`planning-artifacts/` (root-level duplicate), `outputs/`, and `second-brain-core/`.
See Section 4, Questions Q-1 and Q-2.

---

### Layer 2 — Process Artifact Improvements

These changes to `coding_prompt.md` and `app_spec.txt` prevent the same classes of
issues from appearing in future runs. Each change is targeted and scoped.

**Do these AFTER Layer 1 is complete and BEFORE the next full run.**

---

#### L2-A: Add exact `verification_results` format requirement to `coding_prompt.md`

Add a clearly boxed constraint immediately above the `jq` update template in
Section 4A (Update Tracking Files):

```
┌─────────────────────────────────────────────────────────────────┐
│  EXACT FORMAT REQUIRED — verification_results values            │
│                                                                 │
│  $FUNCTIONAL_RESULT, $TECHNICAL_RESULT, $INTEGRATION_RESULT    │
│  MUST be EXACTLY the lowercase string "pass" or "fail".        │
│  No prose. No "PASS - description...". No null.                │
│                                                                 │
│  If a test cannot be run: set value to "skipped" and set       │
│  overall status to "blocked" with a blocked_reason.            │
│                                                                 │
│  The CI workflow checks: .verification_results.functional == "pass"  │
│  Anything other than exactly "pass" causes a CI failure.       │
└─────────────────────────────────────────────────────────────────┘
```

**Addresses:** RC-2 (prevents prose/null values in future runs)

---

#### L2-B: Add workflow name uniqueness check to `coding_prompt.md`

Add to the quality gate section (Section 3.5), before writing any workflow file:

```
WORKFLOW NAME UNIQUENESS CHECK (mandatory before writing any workflow file):

# Check for name collision with existing workflow files
EXISTING_NAMES=$(grep -rh "^name:" \
  /home/ladmin/seven-fortunas-workspace/7f-infrastructure-project/.github/workflows/ \
  2>/dev/null | sort)
echo "Existing workflow names:"
echo "$EXISTING_NAMES"
# If your intended name appears in this list, choose a unique name before writing.
```

**Addresses:** RC-8 (prevents duplicate workflow names in future runs)

---

#### L2-C: Add artifact filename sanitization rule to `coding_prompt.md`

Add to the NFR-5.6 constraint list (Section 3.5) as Constraint #9:

```
Constraint 9 — Artifact/file names must not contain colons or special characters.
  ✓ Use: ${{ github.run_number }} or $(date +%Y-%m-%d)
  ✗ Never: $(date -u +%Y-%m-%dT%H:%M:%SZ) in filenames or artifact paths
```

**Addresses:** RC-7 (prevents colon-in-filename errors in future runs)

---

#### L2-D: Make the Workflow Sentinel the last feature built — add implementation note to `app_spec.txt`

In the FEATURE entry for FR-9.1 (Workflow Sentinel), add to `implementation_notes`:

```
CRITICAL IMPLEMENTATION NOTE:
This feature MUST be implemented LAST in any session — after all other workflow
files have been created. Before writing workflow-sentinel.yml, generate the
watch list dynamically from actual deployed workflow names:

  WORKFLOW_NAMES=$(grep -rh "^name:" \
    .github/workflows/*.yml 2>/dev/null \
    | sed 's/^name: //' | sort -u)

Use that list verbatim as the `workflows:` watch list. Do NOT hardcode guessed names.
This ensures the Sentinel watches exactly what exists, not what was imagined at
write time.
```

**Addresses:** RC-3 (prevents sentinel name mismatch in future runs)

---

#### L2-E: Add post-run validation sweep to `coding_prompt.md`

Add a new mandatory section at the very end of the session workflow (after "Loop
immediately" — the final step when no pending features remain):

```
### FINAL STEP: Post-Run Validation Sweep (runs ONCE, when all features complete)

When `jq '[.features[] | select(.status == "pending")] | length' feature_list.json`
returns 0:

1. Validate all workflow files:
   find .github/workflows/ -name "*.yml" | while read wf; do
     bash scripts/validate-and-fix-workflow.sh "$wf" 2>&1
   done

2. Validate verification_results format:
   PROSE_COUNT=$(jq '[.features[] |
     select(.status == "pass") |
     select(.verification_results.functional != "pass" or
            .verification_results.technical != "pass" or
            .verification_results.integration != "pass")] | length' feature_list.json)
   echo "Features with non-conformant verification_results: $PROSE_COUNT"

3. If any violations found: fix them and commit before ending the session.
4. Final commit: "chore: post-run validation sweep — all gates clean"
```

**Addresses:** RC-5 (catches issues before CI sees them)

---

#### L2-F: Add NFR-5.6 as runtime constraint, not just a deliverable, to `coding_prompt.md`

In Section 3 (Workflow Per Feature), add to the quality gate instructions:

```
IMPORTANT: NFR-5.6 is a CONSTRAINT on every workflow you generate, not a
one-time deliverable. For every .github/workflows/*.yml file you create:
  - Run validate-workflow-compliance.sh (if it exists from Phase A)
  - Fix any constraint violations before marking the feature "pass"
  - If the script does not exist yet, note it in implementation_notes
    and it will be caught by the post-run sweep (L2-E)
```

**Addresses:** RC-4 (ensures authoring standards apply to all workflows, not just
the feature that creates the script)

---

### Layer 3 — Phased Implementation Architecture

This is the structural change that permanently breaks the iteration cycle. Instead
of one 53-feature run, the next implementation uses three independent phases with a
human validation checkpoint between each.

**This is the architecture for the NEXT full run** — not for today. Implement after
Layers 1 and 2 are complete and CI is stable.

---

#### Why Phasing Breaks the Cycle

| Problem with Single-Batch Run | How Phasing Fixes It |
|-------------------------------|---------------------|
| Quality gates built mid-run; early features never validated | Phase A commits gates; Phase B features always validated |
| Sentinel written before all workflow names exist | Sentinel is Phase C's last feature; all names known |
| A bad feature in feature 5 affects monitoring in feature 50 | Phase boundaries create clean separation |
| Re-running 53 features to fix 4 issues wastes 2 hours | Re-run only the affected phase (~30 min) |
| No human visibility between start and CI failure | Validation checkpoints let you catch issues early |

---

#### Phase Architecture

```
PHASE A — Infrastructure Bootstrap (~12 features, ~30 min)
├── Purpose: Create the foundation that all other phases depend on
├── Features: FR-1.x (GitHub orgs, teams, repos, branch protection)
│            + FR-10.1, FR-10.3 SCRIPTS ONLY (not the CI workflows)
│              (validate-workflow-compliance.sh, mypy/pylint setup)
│            + Basic CI: secret-scanning.yml, pre-commit-validation.yml
├── Output: A clean GitHub org with security and quality gate scripts
└── VALIDATION GATE (human, ~10 min):
    ✓ Both GitHub orgs exist and have correct team structure
    ✓ Branch protection rules are active
    ✓ validate-workflow-compliance.sh runs without error
    ✓ Secret scanning CI passes on a test commit
    ✓ No CI failures in the Actions tab
    → ONLY proceed to Phase B when this gate is green

PHASE B — Core Features (~28 features, ~60 min)
├── Purpose: All product features, with quality gates ACTIVE
├── Features: FR-2.x (Second Brain), FR-3.x (BMAD/Skills),
│            FR-4.x (Dashboards), FR-5.x (Security hardening),
│            FR-8.x (Sprint management), FR-7.x (Progress tracking)
├── Quality gate ACTIVE: coding_prompt runs validate-workflow-compliance.sh
│   on every generated workflow (Phase A scripts exist now)
│   verification_results must be exactly "pass" (L2-A enforced)
├── Output: All product features delivered and validated locally
└── VALIDATION GATE (automated + human review, ~15 min):
    ✓ Run validate-workflow-compliance.sh across all Phase B workflows
    ✓ Run jq check: zero features with non-"pass" verification_results
    ✓ All Phase B CI workflows pass in GitHub Actions
    ✓ No duplicate workflow names
    → ONLY proceed to Phase C when this gate is green

PHASE C — Observability & Self-Healing (~13 features, ~30 min)
├── Purpose: Monitoring and self-healing built on top of stable Phases A+B
├── Features: FR-9.x (CI self-healing — built AFTER all other workflows
│            exist), FR-8.x observability, NFR-8.x metrics, FR-10.x
│            CI workflows (not scripts — the actual gate workflows)
├── Sentinel written LAST: watch list generated from actual Phase A+B+C
│   workflow names (L2-D enforced)
├── NFR-4.6 grace period active in collect-metrics.yml (from L1-P6)
└── VALIDATION GATE (automated, ~15 min):
    ✓ Full CI green across all workflows
    ✓ collect-metrics reports ≥95% (all workflows are stable now)
    ✓ Sentinel watch list matches actual workflow names
    ✓ Self-healing test: trigger a known-pattern failure; verify Sentinel
      detects and creates GitHub Issue
    → DONE. No re-run needed.
```

---

#### How to Implement Phasing in the Launcher

The `run-autonomous.sh` script gets a new `--phase` flag:

```bash
./autonomous-implementation/scripts/run-autonomous.sh --phase A
./autonomous-implementation/scripts/run-autonomous.sh --phase B
./autonomous-implementation/scripts/run-autonomous.sh --phase C
```

The `app_spec.txt` features already have a `phase` field. The initializer generates
a single `feature_list.json` but the coding agent, when launched with `--phase X`,
only processes features where `phase` matches:

- Phase A: `"MVP-Day-0"` category (GitHub setup) + bootstrap infra features
- Phase B: `"MVP-Day-1"` through `"MVP-Day-3"` + `"Phase-1.5"`
- Phase C: `"Phase-2"` + observability NFRs

**One-time setup:** Add phase tags to the small number of features (FR-10.1, FR-10.3
scripts) that need to move from their current phase to Phase A bootstrap.

---

### Layer 4 — Tracking File Isolation & Account Guards

Two additional root causes discovered during Phase A execution (2026-03-02).
Both fixed by process artifact changes only — no app_spec changes needed.

---

#### L4-A: Gitignore ephemeral tracking files

Add `feature_list.json`, `claude-progress.txt`, and `autonomous_build_log.md` to
`.gitignore`. Run `git rm --cached` to untrack them. Push to `origin/main`.

**Why:** These files are regenerated by the initializer at the start of every run.
Committing them creates a persistent stale "prior run" state on the remote that any
agent can see — and shortcut to. The local file is the only authority during a run.

**Fresh-start rule (mandatory before every autonomous run):**
```bash
rm -f feature_list.json claude-progress.txt autonomous_build_log.md
./autonomous-implementation/scripts/run-autonomous.sh --phase A
```
The initializer will recreate all three with all features set to `pending`.

**Addresses:** RC-9

---

#### L4-B: Explicit prohibition in `coding_prompt.md` and `CLAUDE.md`

Even with gitignore, an agent could try `git show origin/main:feature_list.json`
and get a non-zero exit rather than stale data. The explicit prohibition makes the
intent unambiguous and documents the failure mode.

**Added to `coding_prompt.md`** (section `⛔ CRITICAL PROHIBITIONS`, rule 1):
- `git show origin/main:feature_list.json` is **FORBIDDEN**
- Do not sync tracking state from remote in any form
- Local `feature_list.json` is the ONLY source of truth

**Added to `CLAUDE.md`** (Section 5.8 + Section 9 "What NOT to Do"):
- Same prohibition at project level
- Explains the failure mode so future agents understand why the rule exists

**Addresses:** RC-9

---

#### L4-C: Explicit GitHub account check in `coding_prompt.md` STEP 1

The `run-autonomous.sh` pre-flight already enforces `jorge-at-sf` (since `630c0ba`).
Adding the same check to the coding agent's STEP 1 orientation creates defense in
depth — the agent self-verifies even if somehow invoked outside the normal launcher.

**Added to `coding_prompt.md`** (section `⛔ CRITICAL PROHIBITIONS`, rule 2 +
STEP 1 orientation step 0):
```bash
ACTIVE_USER=$(gh api user --jq '.login' 2>/dev/null || echo "")
if [[ "$ACTIVE_USER" != "jorge-at-sf" ]]; then
  echo "ERROR: Wrong GitHub account: '$ACTIVE_USER'"
  echo "Fix: gh auth switch --user jorge-at-sf"
  exit 1
fi
```

**Added to `CLAUDE.md`** (Section 5.9 + Section 11 Common Issues):
- Documents the two-account situation
- Provides the switch command

**Addresses:** RC-10

---

## 4. Open Questions — RESOLVED (2026-03-01)

All three questions below were resolved in the same session that produced this plan.
The Interlude cleanup has been executed.

---

### Q-1: What is the canonical role of `/home/ladmin/dev/GDF/7F_github/`?

**Answer:** This repo IS `Seven-Fortunas-Internal/7f-infrastructure-project` — a
permanent member of the internal GitHub org. It is both the planning workspace AND
the production repository. All generated content (scripts, compliance, dashboards,
workflows) legitimately belongs here and is pushed to GitHub.

**What does NOT belong here:** Content for other repos (Second Brain content → goes
to `seven-fortunas-brain`), and any agent-generated debris (logs, backups, one-time
scripts). The directory rules are now encoded in CLAUDE.md Section 5.2.

**Action taken:** `second-brain-core/` (untracked, wrong repo) deleted.
Content directories `scripts/`, `compliance/`, `dashboards/`, etc. retained.

---

### Q-2: What is the `planning-artifacts/` directory at the project root?

**Answer:** Accidental duplicate. The canonical location is
`_bmad-output/planning-artifacts/`. The root-level copy contained stale versions of
the `master-*.md` files (older than `_bmad-output/`).

**Action taken:** `git rm -r planning-artifacts/` (root copy). The
`_bmad-output/planning-artifacts/` directory is the sole authoritative location.

---

### Q-3: Should `app_spec.txt` exist in both root and `_bmad-output/`?

**Answer:** No — there should be exactly one copy. The canonical location is
`_bmad-output/app_spec.txt`.

**Action taken:**
- `git rm app_spec.txt` (root copy removed from tracking)
- `autonomous-implementation/prompts/initializer_prompt.md` updated: the agent now
  reads `_bmad-output/app_spec.txt` directly (no sync step needed)
- Rule added to CLAUDE.md Section 3 (Canonical File Locations)

---

## 5. Decision Reference Table

Complete summary of every action, its layer, target, and status.

| ID | Action | Layer | Target | Addresses | Status |
|----|--------|-------|--------|-----------|--------|
| P-1 | Fix `verification_results` for FEATURE_029, 030, 061, 064 | L1 | `feature_list.json` | RC-2 | ✅ Done (commit 9ea575d) |
| P-2 | Fix SOC 2 artifact colon in filename | L1 | `soc2-evidence-collection.yml` | RC-7 | ✅ Pre-resolved (script already safe) |
| P-3 | Sync Sentinel watch list to actual workflow names | L1 | `workflow-sentinel.yml` | RC-3 | ✅ Done (commit 9ea575d) |
| P-4 | Rename duplicate "SOC 2 Evidence Collection" | L1 | `compliance-evidence-collection.yml` | RC-8 | ✅ Done (commit 9ea575d) |
| P-5 | Rename duplicate CI health report name | L1 | `ci-health-weekly-report.yml` | RC-8 | ✅ Done (commit 9ea575d) |
| P-6 | Implement NFR-4.6 24h grace period | L1 | `collect-metrics.yml` | RC-6 | ✅ Done (commit 9ea575d) |
| C-1 | Resolve Q-1 (role of root dir) | Interlude | Decision | — | ✅ Done (commit 2986554) |
| C-2 | Resolve Q-2 (root planning-artifacts duplicate) | Interlude | Decision | — | ✅ Done (commit 2986554) |
| C-3 | Resolve Q-3 (app_spec.txt duplication) | Interlude | Cleanup | — | ✅ Done (commit 2986554) |
| C-4 | Delete log debris (1.6 MB of stale logs) | Interlude | Root dir | — | ✅ Done (commit 2986554) |
| C-5 | Archive historical session/report files | Interlude | Root dir | — | ✅ Done (commit 2986554) |
| L2-A | Exact format rule in `coding_prompt.md` | L2 | `autonomous-implementation/prompts/coding_prompt.md` | RC-2 | ✅ Done |
| L2-B | Workflow name uniqueness check in `coding_prompt.md` | L2 | Same | RC-8 | ✅ Done |
| L2-C | Artifact filename sanitization rule in `coding_prompt.md` | L2 | Same | RC-7 | ✅ Done |
| L2-D | Sentinel dynamic name list — add to `app_spec.txt` | L2 | `_bmad-output/app_spec.txt` | RC-3 | ✅ Done |
| L2-E | Post-run validation sweep in `coding_prompt.md` | L2 | `autonomous-implementation/prompts/coding_prompt.md` | RC-5 | ✅ Done |
| L2-F | NFR-5.6 as runtime constraint in `coding_prompt.md` | L2 | Same | RC-4 | ✅ Done |
| L3-1 | Add `--phase A/B/C` flag to `run-autonomous.sh` | L3 | `autonomous-implementation/scripts/run-autonomous.sh` | All RC | ✅ Done |
| L3-2 | Update initializer to filter features by phase | L3 | `autonomous-implementation/agent.py` + `prompts.py` | All RC | ✅ Done |
| L3-3 | Tag Phase A bootstrap features in `app_spec.txt` | L3 | `_bmad-output/app_spec.txt` | RC-1 | ✅ Done |
| L3-4 | Document Phase A/B/C validation gates as checklists | L3 | This plan (Section 3) | RC-1, RC-5 | ✅ Done |
| L4-A | Gitignore `feature_list.json`, `claude-progress.txt`, `autonomous_build_log.md`; `git rm --cached`; push | L4 | `.gitignore` + git | RC-9 | ✅ Done |
| L4-B | Add ⛔ remote-sync prohibition to `coding_prompt.md` and `CLAUDE.md` (Sections 5.8, 9) | L4 | Both files | RC-9 | ✅ Done |
| L4-C | Add `jorge-at-sf` account check to `coding_prompt.md` STEP 1 and `CLAUDE.md` (Sections 5.9, 11) | L4 | Both files | RC-10 | ✅ Done |

---

## 6. Success Definition

**The autonomous implementation process is stable when:**

1. **CI is green** — All GitHub Actions workflows in `Seven-Fortunas-Internal/7f-infrastructure-project` pass consistently without manual intervention.

2. **No cascade failures** — `collect-metrics` does not trip its threshold after a
   bulk autonomous deployment (NFR-4.6 grace period active).

3. **Sentinel fires correctly** — When any monitored workflow fails, Workflow Sentinel
   detects it within 5 minutes and creates a GitHub Issue with Claude analysis.

4. **Quality gates prevent merging bad output** — A PR that adds a non-compliant
   workflow (violating any of the 8 NFR-5.6 constraints) is blocked by CI before
   merge.

5. **The next full run uses phased architecture** — Phase A completes and is green
   before Phase B starts. Phase B completes and is green before Phase C starts. No
   full 53-feature re-run is needed to fix issues from one phase.

6. **The local project directory is clean** — Only planning artifacts, agent
   infrastructure, and config files at root. No log debris, no stale extraction
   scripts, no backup files.

7. **A re-run of a single phase takes <45 minutes** — If a future phase needs
   re-running (spec change, new requirement), it takes less than an hour, not 2+.

---

*Document Version: 1.0*
*Next review: After Layer 1 patches are applied and CI is confirmed green*
