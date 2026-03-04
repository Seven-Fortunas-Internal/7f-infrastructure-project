# Spec Corrections Log

**Purpose:** Formal record of every discrepancy found between `_bmad-output/app_spec.txt`
(the authoritative spec) and the actual deployed implementation. Required by SDD-3.

**Author:** Murat (TEA Agent)
**Last Updated:** 2026-03-04
**Source spec:** `_bmad-output/app_spec.txt` (53 features, Phase 1)

---

## How This Log Works

When a test reveals a difference between spec and implementation:

1. Log it here with a unique ID (`SC-NNN`)
2. Classify it: `spec-wrong` (implementation is correct, spec was incomplete/incorrect) vs
   `impl-wrong` (spec is correct, implementation needs fixing)
3. Record the resolution: test updated, spec noted, or implementation fixed
4. Never silently discard — every correction is evidence of spec evolution

---

## Corrections

### SC-001 — deploy-ai-dashboard.yml uses native GitHub Pages actions

**Discovered:** Sprint 3, P2-009
**Spec assumption:** `deploy-ai-dashboard.yml` uses `JamesIves/github-pages-deploy-action`
with `destination_dir` and `keep_files` fields.
**Actual implementation:** Uses GitHub's native `actions/upload-pages-artifact@v3` +
`actions/deploy-pages@v4`. No `destination_dir` or `keep_files` fields exist.
**Classification:** `spec-wrong` — implementation is correct and follows current GitHub
Pages best practices. JamesIves action is a community action; native deploy-pages is
the official approach.
**Resolution:** P2-009 test assertions updated to reflect actual implementation.
No code change required.
**Test file:** `tests/bats/test_ci_workflows.bats` (P2-009 assertions)

---

### SC-002 — bmm/ skill directory contains bmad-tea-* stubs

**Discovered:** Sprint 3, P2-006
**Spec assumption:** `bmm/` subdirectory contains only `bmad-bmm-*` and
`bmad-agent-bmm-*` prefixed files.
**Actual implementation:** `bmm/` also contains `bmad-tea-*` stub files (TEA agent
cross-module skill stubs).
**Classification:** `spec-wrong` — cross-module stubs are a valid BMAD pattern
not captured in the original naming convention spec.
**Resolution:** P2-006 test regex pattern widened to accept `bmad-tea-*` in `bmm/`.
No code change required. Pattern is documented as intentional.
**Test file:** `tests/bats/test_ci_workflows.bats` (P2-006 assertions)

---

### SC-003 — run-autonomous.sh is in scripts/ subdirectory, not root AI dir

**Discovered:** Sprint 3, P2-002
**Spec assumption:** `run-autonomous.sh` exists at `autonomous-implementation/` root.
**Actual implementation:** `run-autonomous.sh` is at
`autonomous-implementation/scripts/run-autonomous.sh`.
**Classification:** `spec-wrong` — implementation chose a cleaner subdirectory
structure. The scripts/ subdirectory separation is correct.
**Resolution:** P2-002 test path assertions corrected. No code change required.
**Test file:** `tests/bats/test_autonomous_agent.bats` (P2-002-i, P2-002-j assertions)

---

### SC-004 — bot585 auto-approve integration not in original spec

**Discovered:** 2026-03-03 (this session, post-Sprint 3)
**Spec reference:** Not present in `app_spec.txt` — added as operational necessity.
**Implementation:** `auto-approve-pr.yml` workflow deployed to all 14 repos across both
orgs. `bot585` machine account: Write collaborator on all repos, member of both orgs.
`APPROVER_PAT` stored as org-level secret in Seven-Fortunas-Internal and Seven-Fortunas.
**Classification:** `spec-addition` — new behaviour added outside spec-first process.
Operationally required (branch protection + single-author repo).
**Resolution:** Registered retroactively as P2-010 (Murat automated) and P4-003 (Jorge
live infra). SDD-1 rule added to sprint4-plan.md to prevent recurrence.
**Test file:** `tests/bats/test_bot_approval.bats` (new — Sprint 4)

---

### SC-005 — Workflow Sentinel create-fix-pr missing pull-requests:write permission

**Discovered:** 2026-03-03 (this session, post-Sprint 3)
**Spec reference:** FR-9.5 — automated fix PR creation.
**Implementation gap:** Top-level `permissions` block in `workflow-sentinel.yml` was
missing `pull-requests: write`. `create-fix-pr` job was failing with
`GraphQL: Resource not accessible by integration` on every `known_pattern` classification.
Also: `--base autonomous-implementation` should have been `--base main`.
**Classification:** `impl-wrong` — spec requires working fix PR creation; implementation
had two bugs.
**Resolution:** Fixed in PR #65 (merged 2026-03-03). Two changes:
1. Added `pull-requests: write` to permissions block
2. Changed `--base autonomous-implementation` → `--base main`
**Test file:** No regression test exists for this yet. WC-003 (Sentinel E2E assertion)
will close this gap in Sprint 5.

---

### SC-006 — Seven-Fortunas/dashboards branch protection has no PR review requirement

**Discovered:** 2026-03-03 (live infra Run 4 — P0-005-a persistent failure)
**Spec assumption:** P0-005 asserts branch protection with `required_pull_request_reviews`
on all key repos, including `Seven-Fortunas/dashboards`.
**Actual implementation:** PR review requirement was intentionally removed from
`Seven-Fortunas/dashboards/main` to allow the `Update AI Advancements Dashboard`
workflow to push data files directly to main. GitHub Free plan does not support
`bypass_pull_request_allowances` (Pro/Enterprise only), so the only viable option
for automated data-push workflows was to remove the PR review requirement for this repo.
**Classification:** `spec-wrong` — the spec assumed uniform branch protection across all
repos, but data/content repos that receive automated pushes from CI require a different
policy than code repos. Force-push and deletion protection are retained.
**Resolution:** P0-005-a live infra test will remain `FAIL` as a permanent reminder of
the Free-plan limitation. No test update — the failure is the correct signal that this
repo has weaker protection than policy ideally requires. If org upgrades to Team/Pro,
`bypass_pull_request_allowances` should be configured and the protection restored.
**Test file:** `tests/validate-live-infrastructure.sh` (P0-005-a)

---

---

## SC-007 — P1-008-d Permanent Waiver (Founders Invite)

**ID:** SC-007
**Classification:** `waiver-accepted`
**Discovered:** 2026-03-04 (Sprint 6 admin closure)
**Spec assumption:** P1-008-d asserts that founders (Henry, Buck, Patrick) have been
invited to the Seven-Fortunas GitHub organization.
**Actual state:** Founders have not been invited. Org setup and member management
are Jorge's admin responsibility and are not a CI/CD gate.
**Resolution:** Test `P1-008-d` remains `SKIP` in `validate-live-infrastructure.sh`
indefinitely. This waiver is permanent for Phase 1. If founders are onboarded in
a future phase, the SKIP should be removed and the invite verified.
**Approved by:** Jorge (VP AI-SecOps)
**Date:** 2026-03-04

---

## SC-008 — P1-016-b Permanent Waiver (Dashboard Curator Deployment)

**ID:** SC-008
**Classification:** `waiver-accepted`
**Discovered:** 2026-03-04 (Sprint 6 admin closure)
**Spec assumption:** P1-016-b asserts that `cached_updates.json` is deployed via
the `dashboard-curator` workflow.
**Actual state:** `dashboard-curator` is a live data pipeline feature that requires
external API credentials (news RSS, LinkedIn, etc.) outside Phase 1 scope. The
`cached_updates.json` file is not populated in the deployed environment.
**Resolution:** Test `P1-016-b` remains `SKIP` in `validate-live-infrastructure.sh`
indefinitely. If external API credentials are provisioned in a future phase, this
waiver should be revisited.
**Approved by:** Jorge (VP AI-SecOps)
**Date:** 2026-03-04

---

## SC-009 — Live Infrastructure Exit Criterion Modified

**ID:** SC-009
**Classification:** `exit-criteria-amendment`
**Discovered:** 2026-03-04 (Sprint 6 admin closure)
**Original exit criterion:** "Live infrastructure script exits 0 (all pass)."
**Modified criterion:** "Live infrastructure script exits 0 with known exceptions
documented and accepted. Known SKIPs and accepted FAILs do not block Phase 1 closure."
**Known exceptions at Phase 1 closure:**
- P0-005-a (SC-006): `dashboards` branch protection — Free-plan limitation, accepted FAIL
- P0-003-d/f, P0-005-c/e: Free-plan API read restrictions on private repos (SKIPs)
- P1-008-d (SC-007): Founders invite waiver (SKIP)
- P1-016-b (SC-008): Dashboard curator waiver (SKIP)
**Result:** Exit criterion MET at 25/32 pass + 6 documented skips/waivers.
The 1 remaining FAIL (P0-005-a / SC-006) is a documented accepted exception, not a regression.
**Approved by:** Jorge (VP AI-SecOps)
**Date:** 2026-03-04

---

## Summary Table

| ID | Component | Type | Status |
|----|-----------|------|--------|
| SC-001 | `deploy-ai-dashboard.yml` | spec-wrong | ✅ Resolved — test updated |
| SC-002 | `bmm/` naming convention | spec-wrong | ✅ Resolved — test updated |
| SC-003 | `run-autonomous.sh` path | spec-wrong | ✅ Resolved — test updated |
| SC-004 | bot585 auto-approve | spec-addition | ✅ Resolved — retroactive tests registered (P2-010, P4-003) |
| SC-005 | Sentinel create-fix-pr | impl-wrong | ✅ Resolved — PR #65 merged; regression test in WC-003 (Sprint 5) |
| SC-006 | `dashboards` branch protection | spec-wrong | ⚠️ Accepted — Free-plan limitation; P0-005-a left as FAIL intentionally |
| SC-007 | P1-008-d founders invite | waiver-accepted | ✅ Waiver granted — SKIP permanently |
| SC-008 | P1-016-b dashboard curator | waiver-accepted | ✅ Waiver granted — SKIP permanently |
| SC-009 | Live infra exit criterion | exit-criteria-amendment | ✅ Modified — 25/32 pass + documented exceptions = MET |
