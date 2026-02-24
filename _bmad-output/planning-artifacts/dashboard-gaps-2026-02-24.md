---
document_type: gap-analysis
created_date: '2026-02-24'
author: 'Claude Code (audit)'
reviewer: 'Jorge'
status: 'draft - pending dev team review'
related_features: ['FEATURE_015', 'FEATURE_016']
related_spec: '_bmad-output/app_spec.txt'
target_repo: 'Seven-Fortunas/dashboards'
---

# AI Advancements Dashboard — Gap Analysis
**Date:** 2026-02-24
**Audited by:** Claude Code review of `/home/ladmin/seven-fortunas-workspace/dashboards/ai/`
**Compared against:** `master-requirements.md` (FR-4.1, FR-4.2) + `app_spec.txt` (FEATURE_015, FEATURE_016)

---

## Executive Summary

FEATURE_015 (FR-4.1) and FEATURE_016 (FR-4.2) are both marked `status: pass` in `feature_list.json`. This audit found **9 gaps** — 7 in FEATURE_015 and 2 in FEATURE_016. None are blockers to the live site functioning, but several represent spec deviations that affect correctness, UX, and reliability.

| Gap ID | Feature | Severity | Category |
|--------|---------|----------|----------|
| GAP-01 | FEATURE_015 | Medium | CSS — missing 1024px breakpoint |
| GAP-02 | FEATURE_015 | Low | UI — LastUpdated missing next-update display |
| GAP-03 | FEATURE_015 | Medium | UI — all-sources-failure fetch error not handled |
| GAP-04 | FEATURE_015 | Low | Config — sources.yaml in wrong path |
| GAP-05 | FEATURE_015 | Low | Config — Reddit source is r/artificial, not r/LocalLLaMA |
| GAP-06 | FEATURE_015 | Medium | Config — cache staleness threshold is 24h, spec says 7 days |
| GAP-07 | FEATURE_015 | Low | CSS — 44px touch targets not enforced |
| GAP-08 | FEATURE_016 | High | Missing — weekly-ai-summary.yml workflow not created |
| GAP-09 | FEATURE_016 | High | Missing — ai/summaries/ directory and files not created |

---

## Detailed Gap Analysis

---

### GAP-01 — Missing 1024px CSS Breakpoint
**Feature:** FEATURE_015 (FR-4.1)
**Severity:** Medium
**Category:** Responsive CSS

**Spec:**
> Mobile-responsive layout with breakpoints: 320px (mobile), 768px (tablet), 1024px (desktop)

**What exists:**
`dashboard.css` has `@media (max-width: 375px)`, `@media (max-width: 320px)`, and `@media (max-width: 768px)`. No `1024px` breakpoint exists.

**Gap:**
Desktop breakpoint (1024px) is absent. Grid and layout behavior between 768px and max-width (1400px) relies entirely on `auto-fill` behavior rather than explicit breakpoint rules.

**Fix required:**
Add `@media (max-width: 1024px)` block in `dashboard.css` with appropriate column/spacing adjustments for the tablet-to-desktop transition zone.

**Updated AC:**
- `grep -q "max-width: 1024px" ai/src/styles/dashboard.css`

---

### GAP-02 — LastUpdated Component Missing "Next Update" Time
**Feature:** FEATURE_015 (FR-4.1)
**Severity:** Low
**Category:** UI Component

**Spec (from master-ux-specifications.md):**
> `Last Updated: 2026-02-13 14:30 UTC` / `Next Update: 2026-02-13 20:30 UTC`

**What exists:**
`LastUpdated.jsx` renders only: `Last updated: {formatted}`

No next-update calculation is present.

**Gap:**
Users cannot see when the next refresh will happen. Since the cron is `0 */6 * * *`, next update = last_updated + 6 hours, calculable client-side.

**Fix required:**
Update `LastUpdated.jsx` to calculate and display next update time: `last_updated + 6 hours`.

**Updated AC:**
- Dashboard header displays both "Last updated:" and "Next update:" timestamps

---

### GAP-03 — All-Sources-Failure UI: Fetch Error Not Handled
**Feature:** FEATURE_015 (FR-4.1)
**Severity:** Medium
**Category:** Graceful Degradation

**Spec:**
> All sources failure: Display last successful dashboard + error banner: "❌ Unable to fetch new data. Showing cached data from [timestamp]. Retry in 6 hours."
> Max staleness: 7 days; if >7 days old, display error page instead of stale data.

**What exists:**
`App.jsx` catch block:
```js
.catch(err => {
  console.error('Error loading updates:', err)
  setLoading(false)
})
```

When `cached_updates.json` itself fails to load (network error, deploy failure), the app silently shows a blank dashboard — no error state, no banner.

**Gap:**
The "all sources failure" UI path is unimplemented. There is also no staleness check (7-day max) against `last_updated` timestamp.

**Fix required:**
1. Add `error` state to `App.jsx`. On fetch failure, set error state and render `ErrorBanner` with the "❌ Unable to fetch new data" message.
2. After successful load, check if `last_updated` is >7 days ago; if so, render an error page instead of stale data.

**Updated ACs:**
- When `cached_updates.json` fails to load, `ErrorBanner` shows with message: "❌ Unable to fetch new data. Retry in 6 hours."
- When `last_updated` is >7 days ago, an error page is displayed instead of stale data
- When `last_updated` is 0–7 days old and data loaded from cache, `ErrorBanner` shows: "⚠️ Showing cached data from [timestamp]"

---

### GAP-04 — sources.yaml in Wrong Path
**Feature:** FEATURE_015 (FR-4.1)
**Severity:** Low
**Category:** File Structure

**Spec (master-requirements.md FR-4.3):**
> Updates `dashboards/ai/config/sources.yaml`

**What exists:**
File is at `ai/sources.yaml` (repo root of `ai/`).

**Gap:**
Path deviates from spec. The `7f-dashboard-curator` skill and any future tooling referencing `ai/config/sources.yaml` will need to account for this, or the file must move.

**Fix required:**
Move `ai/sources.yaml` → `ai/config/sources.yaml` and update all references in:
- `ai/scripts/update_dashboard.py` (config_path argument)
- `ai/README.md`
- Any GitHub Actions workflow referencing the path

**Updated AC:**
- `test -f ai/config/sources.yaml`

---

### GAP-05 — Reddit Source: r/artificial Instead of r/LocalLLaMA
**Feature:** FEATURE_015 (FR-4.1)
**Severity:** Low
**Category:** Data Sources

**Spec (master-requirements.md FR-4.1):**
> Reddit (r/MachineLearning, r/LocalLLaMA)

**What exists:**
`ai/sources.yaml` configures `r/MachineLearning` and `r/artificial`.

**Gap:**
`r/LocalLLaMA` is specified in requirements as the second Reddit source; `r/artificial` was substituted.

**Note:** `r/LocalLLaMA` may have been intentionally swapped if access/signal quality was a factor. Dev team should confirm intent before fixing.

**Fix required (if confirmed):**
In `ai/sources.yaml`, change subreddit `artificial` → `LocalLLaMA`.

**Updated AC:**
- `grep -q "LocalLLaMA" ai/config/sources.yaml`

---

### GAP-06 — Cache Staleness: 24h Configured vs 7-Day Spec
**Feature:** FEATURE_015 (FR-4.1)
**Severity:** Medium
**Category:** Graceful Degradation

**Spec (master-requirements.md FR-4.1):**
> Max staleness: 7 days; if >7 days old, display error page instead of stale data

**What exists:**
`ai/sources.yaml`:
```yaml
degradation:
  cache_max_age_hours: 24
```

**Gap:**
Backend degradation threshold is 24 hours. Spec says the UI error page triggers at 7 days, while a warning banner should display between 0 and 7 days when serving cached data. The `update_dashboard.py` script may discard or override data if cache is >24h old, conflicting with the 7-day UI spec.

**Fix required:**
1. Set `cache_max_age_hours: 168` (7 days) in `ai/sources.yaml`
2. Confirm `update_dashboard.py` logic: should it skip writing if >7 days old, or just flag it? Align with spec: data file always written, staleness checked by the UI.

**Updated AC:**
- `grep -q "cache_max_age_hours: 168" ai/config/sources.yaml`
- UI displays warning banner when data is stale but <7 days old
- UI displays error page when data is >7 days old

---

### GAP-07 — Touch Targets Not Explicitly Enforced in CSS
**Feature:** FEATURE_015 (FR-4.1)
**Severity:** Low
**Category:** Mobile / Accessibility

**Spec:**
> Touch targets minimum 44px × 44px

**What exists:**
`dashboard.css` does not set explicit `min-height: 44px` or `min-width: 44px` on interactive elements (`filter-select`, `search-input`, `clear-button`, `read-more`).

**Gap:**
The select and input elements likely meet 44px in practice due to padding, but it is not enforced or verifiable by automated check.

**Fix required:**
Add explicit `min-height: 44px` to `.filter-select`, `.search-input`, `.clear-button`, and `.read-more` in `dashboard.css`.

**Updated AC:**
- `grep -q "min-height: 44px" ai/src/styles/dashboard.css`

---

### GAP-08 — Weekly AI Summaries Workflow Missing (FEATURE_016 — High)
**Feature:** FEATURE_016 (FR-4.2)
**Severity:** High
**Category:** Missing Implementation

**Spec:**
> System SHALL generate AI-powered weekly summaries using Claude API
> - Sunday 9am UTC: Trigger GitHub Action (`weekly-ai-summary.yml`)
> - Load `dashboards/ai/data/latest.json`
> - Send to Claude API with prompt
> - Save to `dashboards/ai/summaries/YYYY-MM-DD.md`
> - Update README.md with latest summary

**What exists:**
`.github/workflows/` contains only:
- `deploy-ai-dashboard.yml`
- `update-ai-dashboard.yml`

`weekly-ai-summary.yml` does not exist.

**Gap:**
FEATURE_016 is marked `status: pass` in `feature_list.json` but the workflow has never been created. No summaries are being generated. The `ai/summaries/` directory does not exist.

**Fix required:**
1. Create `.github/workflows/weekly-ai-summary.yml`:
   - Trigger: `schedule: cron: '0 9 * * 0'` (Sundays 9am UTC) + `workflow_dispatch`
   - Steps: checkout → setup Python → load `ai/public/data/cached_updates.json` → call Claude API → write `ai/summaries/YYYY-MM-DD.md` → update `ai/README.md` → commit + push
2. Create `ai/summaries/` directory (add `.gitkeep`)
3. Store `ANTHROPIC_API_KEY` in GitHub Secrets (Jorge action required)
4. Confirm Claude API prompt per spec: "Summarize top 10 AI developments this week. Focus on: models, research, tools, regulations. Relevance to Seven Fortunas mission (digital inclusion)."

**Updated ACs:**
- `.github/workflows/weekly-ai-summary.yml` exists with Sunday 9am UTC cron
- Workflow uses `ANTHROPIC_API_KEY` from GitHub Secrets
- On run, creates `ai/summaries/YYYY-MM-DD.md` with 1-2 paragraphs + 10 bullet points
- `ai/README.md` is updated with latest summary after each run
- Cost: <$5/month (verify with API usage estimates)

**Note:** `ANTHROPIC_API_KEY` must be manually added to GitHub Secrets by Jorge before this feature can be tested.

---

### GAP-09 — ai/summaries/ Directory Missing (FEATURE_016 — High)
**Feature:** FEATURE_016 (FR-4.2)
**Severity:** High (blocks GAP-08)
**Category:** Missing Implementation

**Spec:**
> Save to `dashboards/ai/summaries/YYYY-MM-DD.md`

**What exists:**
No `ai/summaries/` directory in the repo.

**Gap:**
The directory and all summary files are absent. This is a direct consequence of GAP-08 (workflow never ran), but the directory structure itself should be scaffolded.

**Fix required:**
Create `ai/summaries/.gitkeep` to establish the directory. First summary file will be generated by the workflow (GAP-08).

**Updated AC:**
- `test -d ai/summaries`

---

## Impact on feature_list.json

The following feature statuses should be corrected:

| Feature | Current Status | Correct Status | Reason |
|---------|---------------|----------------|--------|
| FEATURE_015 | `pass` | `partial` | 7 gaps exist; core functionality works but ACs not fully met |
| FEATURE_016 | `pass` | `fail` | Workflow never created; feature is entirely unimplemented |

---

## Recommended Action

1. **Dev team reviews this document** and confirms/adjusts any gaps marked for confirmation (GAP-05)
2. **Update `app_spec.txt`** — FEATURE_015 and FEATURE_016 requirements and ACs updated to include gap fixes (see updated entries in `app_spec.txt`)
3. **Update `feature_list.json`** — correct statuses for FEATURE_015 and FEATURE_016
4. **Jorge:** Add `ANTHROPIC_API_KEY` to GitHub Secrets in `Seven-Fortunas/dashboards` repo (required for GAP-08)
5. **Autonomous agent run** — implement fixes for GAP-01 through GAP-09

---

## Files to Modify (Implementation Checklist)

| File | Gaps Addressed |
|------|---------------|
| `ai/src/styles/dashboard.css` | GAP-01 (1024px breakpoint), GAP-07 (touch targets) |
| `ai/src/components/LastUpdated.jsx` | GAP-02 (next update display) |
| `ai/src/App.jsx` | GAP-03 (fetch error state, staleness check) |
| `ai/sources.yaml` → `ai/config/sources.yaml` | GAP-04 (path), GAP-05 (Reddit), GAP-06 (cache age) |
| `ai/scripts/update_dashboard.py` | GAP-04 (config path ref), GAP-06 (staleness logic) |
| `.github/workflows/weekly-ai-summary.yml` | GAP-08 (new file) |
| `ai/summaries/.gitkeep` | GAP-09 (new file) |

**Total files to change/create:** 7
