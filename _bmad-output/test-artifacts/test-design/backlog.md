# Test & Infrastructure Backlog

Items that surfaced during testing but are deferred for future sprints.
Each item has a root cause, a current workaround, and recommended paths forward.

---

## BL-001 — Sentinel Detection Reliability (P6-002 CONDITIONAL)

**Origin:** Sprint 5 (P5-001) → Sprint 6 (P6-002) → Sprint 8 (P8-004/P8-006)
**Priority:** Medium
**Effort estimate:** Medium (1 sprint)

### Problem Statement

The Workflow Sentinel (`workflow-sentinel.yml` / FR-9.1) cannot reliably detect CI failures
within the 10-minute SLA because it depends on two GitHub infrastructure mechanisms that
are both unreliable under load:

1. **`workflow_run` events** — dropped consistently across 3 live test runs. GitHub does not
   guarantee delivery of `workflow_run` events, particularly for private org repositories
   under concurrent workflow activity.

2. **Scheduled cron (`*/5 * * * *`)** — GitHub's cron scheduler delays `*/5` triggers by
   10-20+ minutes under load. The cron is effective for eventual detection but cannot satisfy
   a hard 10-minute SLA.

### Current Workaround (in place)

- Scheduled fallback `*/5 cron` (`scheduled-poll` job in `workflow-sentinel.yml`)
- Guarantees eventual detection — no failure goes permanently undetected
- Maximum detection lag: ~20 minutes in worst case (cron delay + processing)
- P6-002 status: **CONDITIONAL** (not PASS)

### Root Cause

Both detection mechanisms delegate the trigger decision to GitHub's infrastructure.
The sentinel is purely reactive — it cannot detect failures if GitHub doesn't tell it to run.

### Alternative Approaches

#### Option A: `repository_dispatch` from failing workflows (Recommended)
Each monitored workflow adds an `on-failure` step that fires a `repository_dispatch` event
directly to the sentinel:
```yaml
- name: Notify sentinel on failure
  if: failure()
  run: |
    gh api repos/${{ github.repository }}/dispatches \
      --method POST \
      --field event_type=workflow-failure \
      --field client_payload='{"run_id":"${{ github.run_id }}","workflow":"${{ github.workflow }}"}'
```
The sentinel listens on `repository_dispatch` with `event_type: workflow-failure`.
**Pros:** Push-based, no event delivery uncertainty, fires within seconds of failure.
**Cons:** Requires updating all 35+ watched workflows. `repository_dispatch` delivery is
also not guaranteed but is significantly more reliable than `workflow_run` for this use case.

#### Option B: External polling service (Most reliable)
An external service (e.g., a scheduled Lambda/Cloud Function, or a lightweight VPS cron)
polls `gh run list --status failure` every 2 minutes, independent of GitHub Actions.
**Pros:** Fully decoupled from GitHub's internal scheduler. Guaranteed firing cadence.
**Cons:** Requires external infrastructure. Adds operational complexity.

#### Option C: Dedicated lightweight polling workflow (Medium effort)
A separate, minimal workflow (`failure-detector.yml`) with only `schedule: cron: '*/2 * * * *'`
that queries the Actions API and dispatches `repository_dispatch` to the sentinel. Separating
the poller from the sentinel means even if the cron is delayed, the sentinel itself is unaffected.
**Pros:** No external infrastructure. Cleaner separation of concerns.
**Cons:** Still subject to GitHub cron delays. Better than current because it's a dedicated job
(less competition in the queue), but not a fundamental fix.

#### Option D: Revise the SLA (Least effort)
Accept that GitHub Actions event delivery is eventually-consistent and revise FR-9.1 from
"detect within 10 minutes" to "detect within 30 minutes". Update the SLA test window.
**Pros:** No code changes. Honest reflection of GitHub's actual guarantees.
**Cons:** Weakens the monitoring capability. Not appropriate if the sentinel is a SOC 2 control.

### Murat's Recommendation

**Option A (`repository_dispatch`)** is the right long-term fix. It converts the sentinel
from a purely reactive system to a push-triggered one, eliminating the `workflow_run` event
delivery dependency. The implementation effort is mechanical (add one step to each watched
workflow) but not complex.

**Suggested implementation sprint:**
1. Add `on-failure` `repository_dispatch` step to the 5 highest-priority workflows first
   (CI Canary, Test Suite, Sentinel itself, Workflow Compliance Gate, Secret Scanning)
2. Update sentinel `on:` block to include `repository_dispatch`
3. Verify SLA test passes with the new trigger path
4. Roll out to remaining 30+ workflows incrementally

### Acceptance Criteria for BL-001 PASS

- [ ] SLA test passes on 3 consecutive live runs without event drops
- [ ] Sentinel detects canary failure via `repository_dispatch` within 60 seconds
- [ ] FR-9.1 10-minute SLA verified end-to-end
- [ ] P6-002 upgraded from CONDITIONAL to PASS

---

*Last updated: 2026-03-05 by Murat (TEA Agent)*
