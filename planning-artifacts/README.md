# Seven Fortunas Planning Artifacts

**Status:** ✅ Master Documents Active (as of 2026-02-15)
**Structure:** Federated master documents (6 masters + index)
**Purpose:** Single source of truth for Seven Fortunas AI-native infrastructure planning

---

## Quick Start

**→ Start here:** [index.md](index.md) - Hub document with navigation

**→ For implementation:** [master-requirements.md](master-requirements.md) - 28 FRs + 21 NFRs

**→ For architecture:** [master-architecture.md](master-architecture.md) - System design + ADRs

---

## Master Documents (6 Total)

1. **[master-product-strategy.md](master-product-strategy.md)** - Vision, mission, goals, success criteria
2. **[master-requirements.md](master-requirements.md)** - 28 FRs + 21 NFRs with acceptance criteria
3. **[master-ux-specifications.md](master-ux-specifications.md)** - User journeys, interaction patterns, component specs
4. **[master-architecture.md](master-architecture.md)** - System architecture, ADRs, technology stack
5. **[master-implementation.md](master-implementation.md)** - 5-day MVP timeline, autonomous agent setup
6. **[master-bmad-integration.md](master-bmad-integration.md)** - 26 skills breakdown, deployment strategy

**Plus:** [index.md](index.md) - Hub document linking all masters

---

## What Changed (2026-02-15)

**Before:** 14 overlapping planning documents with conflicting information
**After:** 6 federated master documents with zero information loss

**Process:** DOCUMENT-SYNC-EXECUTION-PLAN.md (5 phases)
**Result:** Single source of truth, easier navigation, role corrections applied

**Critical Corrections:**
- ✅ Buck's aha moment: Engineering delivery (not security)
- ✅ Jorge's role expanded: SecOps + Compliance + Security Testing
- ✅ GitHub authentication: jorge-at-sf requirement documented

**See:** [CHANGELOG.md](CHANGELOG.md) for detailed changes

---

## Archived Documents

**Original 14 source documents:** `archive/2026-02-15-pre-master-consolidation/`
**Process artifacts:** `archive/2026-02-15-sync-work-artifacts/`

**Why archived:** Consolidated into masters, preserved for reference (NEVER deleted)

---

## Maintenance

**How to update:** See [MAINTENANCE-GUIDE.md](MAINTENANCE-GUIDE.md)

**When to update a master:**
- Vision/mission changes → master-product-strategy.md
- New requirements → master-requirements.md (track as "growing list")
- UX patterns change → master-ux-specifications.md
- Architecture decisions → master-architecture.md (add new ADR)
- Timeline updates → master-implementation.md
- New skills added → master-bmad-integration.md (track as "growing list")

**When to create new doc (not update master):**
- Temporary artifacts (spikes, POCs)
- Phase-specific content (not evergreen)
- Reference material (not core planning)

---

## For AI Agents

**Agent instructions:** See [CLAUDE.md](CLAUDE.md) in this directory

**Key context:**
- Load [index.md](index.md) first for navigation
- Masters use progressive disclosure (load specific sections as needed)
- Role corrections applied: Buck = Engineering delivery, Jorge = SecOps + Compliance
- Contract: [DOCUMENT-SYNC-EXECUTION-PLAN.md](DOCUMENT-SYNC-EXECUTION-PLAN.md)

---

## Validation

**Zero information loss:** Verified via validation-report.md (archived)
**Feature counts:** 28 FRs, 21 NFRs, 26 skills (all validated)
**Role corrections:** Buck/Jorge responsibilities correctly delineated
**Cross-references:** All links validated (15/15 working)

---

**Document Owner:** Jorge (VP AI-SecOps)
**Created by:** Mary (Business Analyst Agent)
**Approved:** 2026-02-15
**Version:** 1.0
