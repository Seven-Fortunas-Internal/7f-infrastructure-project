# PR Review Practices

**Last Updated:** 2026-03-03
**Owner:** Jorge (VP AI-SecOps)

---

## Overview

Seven Fortunas uses an automated bot account (`bot585`) to satisfy the 1-required-reviewer
branch protection rule on all repos. This document defines what that means, when it is
sufficient, and when a human must review before merging.

---

## What bot585 Approval Means

`bot585` approves every PR opened by `jorge-at-sf` that triggers the
`Auto-Approve PR (7f-ci-bot)` workflow. Its approval satisfies the **process gate**
(branch protection requires ≥1 reviewer), not a **content review**.

A bot-approved PR means:
- The author is `jorge-at-sf` (an authorized committer)
- The PR was opened through the normal PR process
- CI status checks still gate the actual merge independently

It does **not** mean anyone read the code.

---

## When Bot Approval Is Sufficient

These change types are low-risk and fully validated by CI — bot approval + green CI is enough:

| Change type | Examples |
|---|---|
| Tests | New test files, updated assertions, coverage improvements |
| Documentation | README updates, docs/, Second Brain content |
| Configuration | Dashboard configs, non-sensitive YAML |
| Minor dependency updates | Patch and minor semver bumps |
| Script additions | New utility scripts in `scripts/` |
| CI/CD iteration | Non-security workflow improvements already covered by NFR-5.6 validator |

---

## When Human Review Is Required Before Merging

Stop and review manually before clicking merge for any of the following:

| Change type | Reason |
|---|---|
| `.github/workflows/` changes | CI is the gate — a workflow change can subvert the gate itself |
| `auto-approve-pr.yml` changes | Directly modifies the approval mechanism |
| Branch protection rule changes | Changes what gates a merge |
| `APPROVER_PAT` or any secret rotation | Access control change |
| `scripts/security*`, `compliance/` | SOC 2 evidence chain integrity |
| Major dependency version bumps | Breaking changes, supply chain risk |
| Any change touching auth, secrets, or access control | High blast radius, hard to reverse |
| Infrastructure-as-code changes | Org settings, team permissions, repo config |

**Rule of thumb:** if a malicious or buggy version of this change could compromise security
or bypass a control, read it before you merge it.

---

## Review Process for High-Risk Changes

1. Open the PR diff in GitHub (`/files` tab)
2. Read every changed line — do not skim workflow files
3. Run affected tests locally if applicable
4. Merge only after you are satisfied

Until the team grows, Jorge is the sole human reviewer. Route to the team when available:
- Security/compliance changes → Jorge
- Workflow/CI changes → Jorge
- Product/content changes → Henry (when ready)

---

## As the Team Grows

Once additional team members have repo write access, assign reviewers explicitly on
sensitive PRs rather than relying solely on bot approval. The bot approval becomes the
floor (process gate), not the ceiling.

Suggested reviewer assignments (once onboarded):
- `jorge-at-sf` ↔ peer review from Henry or Buck for major changes
- Any PR modifying branch protection → requires Jorge approval regardless

---

## Bot Account Maintenance

| Task | Schedule | Action |
|---|---|---|
| Rotate `bot585` PAT | Annually (or immediately if compromised) | Generate new PAT, update `APPROVER_PAT` secret in all repos |
| Verify bot has repo access | When adding a new repo | `gh api repos/ORG/REPO/collaborators/bot585` |
| Review bot activity | Quarterly | Check `bot585` activity log in GitHub org audit log |

For bot account setup instructions, see:
`.github/workflows/auto-approve-pr.yml` (comments at top of file)

---

## Related

- Workflow: `.github/workflows/auto-approve-pr.yml`
- Branch protection: configured per-repo under Settings → Branches
- Second Brain: `second-brain-core/best-practices/git-workflow.md`
