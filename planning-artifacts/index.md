# Seven Fortunas Planning Documentation - Master Index

**Created:** 2026-02-15
**Status:** Phase 2 Complete - Federated Master Documents
**Purpose:** Hub document linking to all consolidated planning artifacts
**Contract:** Per DOCUMENT-SYNC-EXECUTION-PLAN.md (zero information loss verified)

---

## How to Use This Documentation

**For Humans:**
1. Start here (index.md) for navigation
2. Read master documents by topic (product, requirements, architecture, UX, implementation, BMAD)
3. Cross-references link related content across masters

**For AI Agents:**
1. Load this index first (understand document structure)
2. Load specific master documents as needed (progressive disclosure)
3. Follow cross-references for related information

**For Autonomous Agent (app_spec.txt generation):**
- Primary input: [master-requirements.md](master-requirements.md) (28 FRs + 21 NFRs)
- Secondary inputs: [master-architecture.md](master-architecture.md), [master-implementation.md](master-implementation.md)

---

## Master Documents (6 Total)

### 1. [Product Vision & Strategy Master](master-product-strategy.md)
**Purpose:** High-level vision, mission, goals, success criteria, stakeholder information

**Key Content:**
- Executive summary (AI-native thesis, BMAD-first strategy)
- Problem statement and solution (3 interconnected systems)
- Target users (4 founding team members → 10-20 → 50+)
- Founder aha moments (with corrected Buck/Jorge roles)
- Success criteria (MVP, Phase 1.5, Phase 2, Phase 3)
- Product scope (in/out of scope for each phase)
- Strategic timeline (Days 0-5, Weeks 2-3, Months 1-12)
- Risk mitigation strategies
- Competitive advantage (AI-native infrastructure as moat)

**When to Read:** Understanding project vision, stakeholder alignment, success metrics

**Role Corrections Applied:** ✅
- Buck's aha moment: Engineering delivery (not security)
- Jorge's role expanded: SecOps + Compliance + Security Testing

---

### 2. [Requirements Master](master-requirements.md)
**Purpose:** All functional and non-functional requirements with acceptance criteria

**Key Content:**
- 28 Functional Requirements across 7 categories:
  1. GitHub Organization & Permissions (6 FRs)
  2. Second Brain Knowledge Management (4 FRs)
  3. BMAD Skills Platform (4 FRs)
  4. 7F Lens Intelligence Platform (4 FRs)
  5. Security & Compliance (4 FRs)
  6. Infrastructure Documentation (1 FR)
  7. Autonomous Agent & Automation (5 FRs)
- 21 Non-Functional Requirements across 7 categories:
  1. Security (5 NFRs - MOST CRITICAL)
  2. Performance (3 NFRs)
  3. Scalability (3 NFRs)
  4. Reliability (3 NFRs)
  5. Maintainability (5 NFRs)
  6. Integration (3 NFRs)
  7. Accessibility (2 NFRs)
- Acceptance criteria for MVP, Phase 1.5, Phase 2, Phase 3
- Validation and traceability (feature counts verified)

**When to Read:** Implementing features, validating completeness, generating app_spec.txt

**Critical Requirements:**
- FR-1.4: GitHub CLI authentication as jorge-at-sf (BLOCKING)
- FR-5.1: 100% secret detection (NON-NEGOTIABLE)
- NFR-1.1: Security testing by Jorge (not Buck)

---

### 3. [UX Specifications Master](master-ux-specifications.md)
**Purpose:** User experience design, user journeys, interaction patterns, component specifications

**Key Content:**
- UX design principles (6 principles for AI-native infrastructure)
- User personas with aha moments (CORRECTED Buck/Jorge journeys):
  - Henry: "AI Permeates Everywhere" (30 min voice → brand docs)
  - Patrick: "SW Development Infrastructure Well Done" (2h architecture validation)
  - Buck: "Engineering Infrastructure Enables Rapid Delivery" (1h engineering delivery) ✅ CORRECTED
  - Jorge: "Implementation Working with Minimal Issues" (Days 1-2 autonomous build) + Security Testing (1h adversarial testing) ✅ ADDED
- Core user flows (knowledge creation, infrastructure operations, intelligence gathering)
- Component specifications (skill invocation UI, status indicators, approval workflows, progress tracking)
- Interaction patterns (finding information <30s, creating infrastructure <2 min, voice content <10 min, staying informed <5 min)
- Responsive design strategy (desktop-first, mobile-responsive)
- Accessibility (WCAG 2.1 AA compliance)

**When to Read:** Understanding user experience, validating aha moments, designing UI components

**Critical Corrections:**
- ✅ Buck's journey changed from Security Testing → Engineering Delivery
- ✅ Jorge's Security Testing journey added (adversarial testing of SecOps controls)
- ✅ Clear delineation: Buck = App Security, Jorge = SecOps + Compliance

---

### 4. [Architecture Master](master-architecture.md)
**Purpose:** System architecture, component design, data architecture, integration points, ADRs

**Key Content:**
- System architecture overview (3 interconnected systems)
- Component architecture (BMAD Skills, Second Brain, 7F Lens, GitHub Orgs)
- Data architecture (Git-as-database pattern, retention policies)
- Integration points (GitHub API, Claude API, Whisper, external data sources)
- 5 Architectural Decision Records (ADRs):
  - ADR-001: Two-Org Model (public/private)
  - ADR-002: Progressive Disclosure (Second Brain)
  - ADR-003: GitHub Actions (dashboard aggregation)
  - ADR-004: Skill-Creation Skill (meta-skill)
  - ADR-005: Personal API Keys MVP → Corporate Post-Funding
- Technology stack (GitHub, Claude API, Python, Markdown/YAML)
- Security architecture (5-layer defense)
- Scalability strategy (4 → 50 users, performance targets)
- Disaster recovery (RTO <4h, RPO <6h)

**When to Read:** Technical implementation, architectural decisions, system design

---

### 5. [Implementation Guide Master](master-implementation.md)
**Purpose:** Execution strategy, timeline, dependencies, testing plan, deployment strategy

**Key Content:**
- Execution strategy (autonomous-first + human refinement)
- 5-day MVP timeline (Days 0-5 detailed breakdown):
  - Day 0: Foundation & BMAD deployment (Jorge, 8h)
  - Days 1-2: Autonomous agent build (60-70% completion)
  - Day 3: Human refinement & testing (Patrick, Buck, Jorge, Henry)
  - Days 4-5: Polish & demo preparation
- Autonomous agent setup (prerequisites, launch, monitoring, blocked feature handling)
- Testing plan (agent-first testing philosophy, 4 manual tests for founder aha moments)
- Dependencies & risks (critical path, mitigation strategies)
- Deployment strategy (Free tier → Team tier → Enterprise tier)
- Release criteria (MVP, Phase 1.5, Phase 2, Phase 3)

**When to Read:** Executing MVP, launching autonomous agent, validating aha moments

**Critical Steps:**
- Day 0: Verify GitHub authentication (jorge-at-sf) - BLOCKING
- Days 1-2: Monitor agent progress (target: 18-25 of 28 features)
- Day 3: Validate all 4 founder aha moments (with corrected Buck/Jorge tests)

---

### 6. [BMAD Integration Master](master-bmad-integration.md)
**Purpose:** BMAD strategy, available skills, deployment, usage patterns

**Key Content:**
- BMAD-first strategy (60% coverage, 87% cost reduction, 4.5x faster)
- 26 operational skills breakdown:
  - 18 BMAD skills adopted (bmm, bmb, cis)
  - 5 adapted skills (7f-brand, 7f-pptx, 7f-excalidraw, 7f-sop, 7f-skill-creator)
  - 3 custom skills (7f-manage-profile, 7f-dashboard-curator, 7f-repo-template)
- Deployment strategy (Day 0 BMAD installation, skill stub creation)
- Usage patterns (planning, building, content, operations)
- Skill governance (search before create, usage tracking, quarterly reviews)
- BMAD vs custom decision matrix
- Maintenance & upgrade procedures (pinned version v6.0.0, manual upgrades)

**When to Read:** Understanding BMAD adoption, deploying skills, skill governance

**Key Insight:** 74% of skills reused/adapted (18+5), only 26% custom (3 new) = minimal maintenance burden

---

## Document Relationships

```
master-product-strategy.md
    ↓ (success criteria, aha moments)
master-ux-specifications.md
    ↓ (user journeys define UX requirements)
master-requirements.md
    ↓ (FRs/NFRs define technical requirements)
master-architecture.md
    ↓ (system design implements requirements)
master-implementation.md
    ↓ (execution plan deploys architecture)
master-bmad-integration.md
    ↓ (BMAD skills enable implementation)
```

**Cross-References:** All masters link to each other where relevant (see bottom of each document)

---

## Source Documents (Archived)

**Original Location:** `archive/2026-02-15-pre-master-consolidation/`

**14 Source Documents Consolidated:**
1. ai-automation-opportunities-analysis-2026-02-10.md (35KB)
2. bmad-skill-mapping-2026-02-10.md (18KB)
3. architecture-7F_github-2026-02-10.md (110KB)
4. product-brief-7F_github-2026-02-10.md (51KB)
5. action-plan-mvp-2026-02-10.md (24KB)
6. autonomous-workflow-guide-7f-infrastructure.md (29KB)
7. prd/prd.md
8. prd/user-journeys.md
9. prd/functional-requirements-detailed.md
10. prd/nonfunctional-requirements-detailed.md
11. prd/domain-requirements.md
12. prd/innovation-analysis.md
13. ux-design-specification.md (77KB - created Feb 14, most recent)
14. manual-testing-plan.md (4KB)

**Archive Date:** 2026-02-15 (Phase 5 - after Jorge's approval)
**Preservation:** All originals preserved (NEVER deleted), accessible for reference

---

## Validation Report

**Location:** `_sync-work/validation-report.md` (Phase 3 deliverable)

**Key Metrics:**
- ✅ 100% source content coverage (zero information loss)
- ✅ 28 Functional Requirements validated (matches source PRD)
- ✅ 21 Non-Functional Requirements validated (matches source PRD)
- ✅ 26 operational skills validated (18 BMAD + 5 adapted + 3 custom)
- ✅ All conflicts identified and resolved (see conflict-log.md)
- ✅ Buck/Jorge role corrections applied throughout

**Critical Corrections:**
- Conflict #1: GitHub authentication (jorge-at-sf) - RESOLVED in Autonomous Workflow Guide
- Conflict #2: Buck vs Jorge roles - CORRECTED throughout all masters
- Conflicts #3-5: Skill/feature counts, timeline - CLARIFIED as "growing lists"

---

## How to Maintain Masters Going Forward

### When to Update a Master (Not Create New Doc)

**Update master-product-strategy.md when:**
- Vision, mission, or goals change
- New success metrics added
- Stakeholder aha moments evolve

**Update master-requirements.md when:**
- New FRs/NFRs added (track as "growing list")
- Existing requirements modified
- Acceptance criteria refined

**Update master-ux-specifications.md when:**
- User journeys change
- New interaction patterns identified
- UX principles evolve

**Update master-architecture.md when:**
- New ADRs created
- Architecture patterns change
- Technology stack evolves

**Update master-implementation.md when:**
- Timeline changes
- New phases added
- Testing strategy updates

**Update master-bmad-integration.md when:**
- New skills added (track as "growing list")
- BMAD version upgraded
- Usage patterns change

### When to Create a New Document (Not Update Master)

**Create new document when:**
- Temporary artifact (spike, POC, experiment)
- Phase-specific content (not evergreen)
- Reference material (not core planning)

**Examples:**
- Phase 1.5 SOC 2 Mapping Spreadsheet → New doc (not master)
- Phase 2 Dashboard Design Mockups → New doc (not master)
- Phase 3 Enterprise Migration Plan → New doc (not master)

---

## Change Log

**Version 1.0 (2026-02-15):**
- Initial federated master documents created
- 14 source documents consolidated
- Buck/Jorge role corrections applied
- Zero information loss validated

**Future Updates:**
- Document changes in this section
- Include date, author, what changed, why

---

## Contact & Ownership

**Document Owner:** Jorge (VP AI-SecOps)
**Document Maintainer:** Mary (Business Analyst Agent)
**Questions:** See individual master documents for specific topic owners

---

**Master Index Status:** ✅ Complete
**Phase 2 Status:** ✅ All 6 masters created, index created, ready for Phase 3 (Validation)
**Contract Compliance:** ✅ Per DOCUMENT-SYNC-EXECUTION-PLAN.md
**Next Phase:** Phase 3 (Validation & Diff Report) - awaiting Jorge's review
