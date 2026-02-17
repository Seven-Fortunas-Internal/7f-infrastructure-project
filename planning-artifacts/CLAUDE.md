# Planning Artifacts Directory - Agent Instructions

**Location:** `/home/ladmin/dev/GDF/7F_github/_bmad-output/planning-artifacts/`
**Purpose:** Single source of truth for Seven Fortunas AI-Native Enterprise Infrastructure planning
**Status:** 🔍 Post-Adversarial Validation Phase (2026-02-16)
**Owner:** Jorge (VP AI-SecOps)

**CRITICAL ACTIVE WORK:** Comprehensive validation of master documents after 100 adversarial fixes to ensure zero information loss and autonomous implementation readiness

---

## 🔍 ACTIVE WORK: Post-Adversarial Validation (2026-02-16)

**Objective:** Comprehensive validation that master documents retain ALL information and detail after 100 adversarial fixes

**Context:**
- 2026-02-15: Consolidated 14 docs → 6 master docs (zero information loss validated)
- 2026-02-16: Applied 100 adversarial fixes (~380 lines code removed, ~650 lines changed)
- 2026-02-16 NOW: Validating no information loss from fixes, ensuring autonomous implementation readiness

**Validation Criteria:**
1. **Zero Information Loss:** All content from pre-adversarial masters still present
2. **Autonomous Readiness:** master-requirements.md can generate app_spec.txt with score ≥75
3. **Implementation Detail:** Sufficient detail for Day 0-5 autonomous implementation
4. **Requirement Integrity:** Still 28 FRs + 21 NFRs with complete acceptance criteria
5. **Cross-Reference Validity:** All document references still accurate

**Baseline Comparison:** Pre-consolidation (14 original docs) vs Current masters (2026-02-16)

**Blocking Decision:** Must validate 100% before proceeding to Day 0 implementation

**Validation Methodology:**
- Based on original Phase 3 validation from DOCUMENT-SYNC-EXECUTION-PLAN.md
- Content coverage analysis (source → master mapping)
- Feature/requirement count validation (28 FRs, 21 NFRs)
- Autonomous readiness test (can generate app_spec.txt with score ≥75)
- Implementation detail sufficiency check (Day 0-5 timeline)
- Cross-reference validation (all links accurate)

**Key Validation Artifacts:**
- `POST-ADVERSARIAL-VALIDATION-PLAN.md` - **Current validation plan (6 phases, 5 hours)** ← START HERE
- `POST-ADVERSARIAL-VALIDATION-REPORT.md` - Validation results (to be created after execution)
- `/home/ladmin/seven-fortunas-workspace/7f-infrastructure-project/autonomous-workflow-guide-7f-infrastructure.md` - Autonomous agent requirements
- `archive/2026-02-15-pre-master-consolidation/` - Original 14 source documents (baseline)
- `ADVERSARIAL-FIXES-COMPLETE.md` - Record of 100 fixes applied
- `DOCUMENT-SYNC-EXECUTION-PLAN.md` - Original validation methodology (Phase 3 template)

**Success Criteria:**
1. ✅ All 28 FRs + 21 NFRs present with complete acceptance criteria
2. ✅ All architectural decisions from original docs present
3. ✅ Implementation details sufficient for autonomous agent (score ≥75 on readiness check)
4. ✅ No critical information gaps vs original 14 documents
5. ✅ All cross-references between masters valid

---

## Critical Context for AI Agents

**You are working in the federated master documents structure.**

This directory contains 6 master planning documents that are the **single source of truth** for Seven Fortunas infrastructure planning. These replaced 14 overlapping source documents on 2026-02-15, then underwent comprehensive adversarial review and fixes on 2026-02-16.

---

## Your First Steps After Context Compaction

**MANDATORY: Read these files in order:**

1. **[index.md](index.md)** - Start here for navigation and overview
2. **[README.md](README.md)** - Quick start guide
3. **[DOCUMENT-SYNC-EXECUTION-PLAN.md](DOCUMENT-SYNC-EXECUTION-PLAN.md)** - Process contract (how we got here)

**Then load specific masters as needed:**
- Product strategy questions → [master-product-strategy.md](master-product-strategy.md)
- Requirements questions → [master-requirements.md](master-requirements.md)
- UX questions → [master-ux-specifications.md](master-ux-specifications.md)
- Architecture questions → [master-architecture.md](master-architecture.md)
- Implementation questions → [master-implementation.md](master-implementation.md)
- BMAD skills questions → [master-bmad-integration.md](master-bmad-integration.md)

---

## Document Structure (Post-Consolidation)

### Active Documents (Current Directory)
```
planning-artifacts/
├── index.md                          # Hub document (start here)
├── README.md                         # Quick start guide
├── CLAUDE.md                         # This file (agent instructions)
├── DOCUMENT-SYNC-EXECUTION-PLAN.md   # Process contract
├── MAINTENANCE-GUIDE.md              # How to update masters
├── CHANGELOG.md                      # Version history
├── master-product-strategy.md        # Vision, mission, goals
├── master-requirements.md            # 28 FRs + 21 NFRs
├── master-ux-specifications.md       # User journeys, interaction patterns
├── master-architecture.md            # System design, ADRs
├── master-implementation.md          # 5-day MVP timeline
├── master-bmad-integration.md        # 26 skills breakdown
└── archive/                          # Original docs (DO NOT USE)
    ├── 2026-02-15-pre-master-consolidation/  # 14 original source docs
    └── 2026-02-15-sync-work-artifacts/       # Process working files
```

---

## Critical Rules for Agents Working Here

### 1. Master Documents are Single Source of Truth

**DO:**
- ✅ Reference master documents for authoritative information
- ✅ Update masters when information changes (see MAINTENANCE-GUIDE.md)
- ✅ Load index.md first for navigation
- ✅ Use progressive disclosure (load only sections you need)

**DO NOT:**
- ❌ Reference archived documents (they're outdated)
- ❌ Create parallel documents that compete with masters
- ❌ Skip reading index.md first
- ❌ Load all masters at once (use progressive disclosure)

### 2. Buck vs Jorge Role Attribution (CRITICAL)

**These corrections were applied throughout all masters on 2026-02-15:**

| Role | Person | Responsibilities | Aha Moment |
|------|--------|------------------|------------|
| **VP Engineering** | Buck | App Security (application-level), Engineering Delivery, Product Development | ✅ "Engineering infrastructure enables rapid delivery" |
| **VP AI-SecOps** | Jorge | SecOps (infrastructure security), Compliance, Security Testing (adversarial) | ✅ "Security on Autopilot" |

**Common Mistake:** Don't attribute Security Testing to Buck - that's Jorge's adversarial testing of SecOps controls.

**If you see conflicting role information:** The masters are correct. Any other documents are outdated.

### 3. Growing Lists (Track Latest Counts)

These are intentionally tracked as "growing lists" that evolve:

| Item | Current Count | Where Tracked | Update When |
|------|---------------|---------------|-------------|
| **Functional Requirements (FRs)** | 28 | master-requirements.md | New features added |
| **Non-Functional Requirements (NFRs)** | 21 | master-requirements.md | New constraints added |
| **BMAD Skills** | 26 | master-bmad-integration.md | New skills added/deprecated |

**Do NOT treat these as fixed numbers.** See MAINTENANCE-GUIDE.md for how to add new items.

### 4. Update Process (From MAINTENANCE-GUIDE.md)

**Before updating any master:**
1. Read current version first
2. Locate relevant section
3. Edit with clear explanation of change
4. Update document version in frontmatter (if major change)
5. Add entry to CHANGELOG.md
6. Commit with descriptive message

**Golden Rule:** Update masters, don't create new docs.

**Exception:** Temporary artifacts (spikes, POCs, phase-specific content) can be separate docs.

---

## Common Questions

### "Which document should I reference for [topic]?"

**See index.md** - It has a complete navigation guide by topic.

**Quick reference:**
- Vision/goals → master-product-strategy.md
- Specific requirements → master-requirements.md
- User journeys → master-ux-specifications.md
- Architecture decisions → master-architecture.md
- Timeline/milestones → master-implementation.md
- Skills/workflows → master-bmad-integration.md

### "What happened to [old document name]?"

**All 14 original documents were archived on 2026-02-15.**

Archived location: `archive/2026-02-15-pre-master-consolidation/`

**Why archived:** They contained overlapping/conflicting information. Masters consolidated them with zero information loss.

**Proof of zero loss:** See `archive/2026-02-15-sync-work-artifacts/validation-report.md`

### "Should I create a new requirements document?"

**NO.** Update `master-requirements.md` instead.

See MAINTENANCE-GUIDE.md section "When to Create a New Document (Not Update Master)" for exceptions.

### "I found conflicting information about Buck's aha moment."

**Master documents are correct:** "Engineering infrastructure enables rapid delivery"

**Old (incorrect) version:** "Security on Autopilot" (that's Jorge's aha moment)

This was corrected across all masters on 2026-02-15. See CHANGELOG.md for details.

---

## Process History (Context for Why Masters Exist)

**Problem (Pre-2026-02-15):**
- 14 overlapping planning documents created Feb 10-14
- Conflicting information (Buck vs Jorge roles, feature counts, timelines)
- Navigation confusion (which doc is authoritative?)
- UX spec created AFTER other docs, contained changes not reflected earlier

**Solution (2026-02-15):**
- Consolidated into 6 federated master documents
- Applied role corrections throughout
- Archived originals (not deleted)
- Created index.md for navigation
- Zero information loss verified

**Process:** DOCUMENT-SYNC-EXECUTION-PLAN.md (5 phases)
1. ✅ Phase 1: Inventory & Conflict Resolution
2. ✅ Phase 2: Create Master Documents
3. ✅ Phase 3: Validation (zero information loss)
4. ✅ Phase 4: Review & Approval (Jorge approved 2026-02-15)
5. ✅ Phase 5: Archive & Finalize

**Result:** Single source of truth, easier navigation, role corrections applied.

---

## For Future Maintenance

**When you need to update masters:**
- See [MAINTENANCE-GUIDE.md](MAINTENANCE-GUIDE.md) for complete instructions
- See [CHANGELOG.md](CHANGELOG.md) for version history
- Always commit changes to git with descriptive messages

**Version numbering:**
- Major (1.0 → 2.0): Significant restructuring, role changes, scope changes
- Minor (1.0 → 1.1): New requirements, ADRs, skills (growing lists)
- Patch (1.1.0 → 1.1.1): Typo fixes, clarifications, formatting

---

## Validation Checklist (For Agents)

**Before referencing information, verify:**
- [ ] You've read index.md for navigation
- [ ] You're referencing a master document (not archived doc)
- [ ] You understand Buck vs Jorge role boundaries
- [ ] You know which masters to update (not create new docs)
- [ ] You've checked CHANGELOG.md for recent changes

**If uncertain:** Ask Jorge (VP AI-SecOps) or consult MAINTENANCE-GUIDE.md

---

## Contact

**Questions about planning artifacts:** Jorge (VP AI-SecOps)
**Process questions:** Reference DOCUMENT-SYNC-EXECUTION-PLAN.md
**Maintenance questions:** See MAINTENANCE-GUIDE.md
**AI agent issues:** Reference parent CLAUDE.md at `/home/ladmin/dev/GDF/7F_github/CLAUDE.md`

---

**Document Version:** 1.0
**Created:** 2026-02-15
**Created By:** Mary (Business Analyst Agent)
**Purpose:** Provide context for AI agents after conversation compaction
**Last Updated:** 2026-02-15
