# Extract: BMAD Skill Mapping Analysis

**Source:** `bmad-skill-mapping-2026-02-10.md`
**Date:** 2026-02-10
**Size:** 537 lines, 18KB
**Author:** Mary with Jorge

---

## Document Metadata
- **Purpose:** Map 37 automation opportunities to existing BMAD skills
- **Key Finding:** BMAD covers 18 of 37 opportunities (60%), saving 272 hours
- **Status:** Draft

---

## Key Content Sections

### Executive Summary (Lines 18-34)
- **BMAD Coverage:** 60% overall (18 of 30 opportunities)
  - Category A (Full Automation): 30% (3 of 10)
  - Category B (AI-Assisted): 90% (9 of 10) 🎉
  - Category C (Best Practices): 60% (6 of 10)
- **Strategic Impact:** 272 hours saved (34 working days)

### BMAD Skills Available - Category B (Lines 60-79)
Excellent coverage of AI-Assisted workflows:
1. B2: ADRs → `bmad-bmm-create-architecture`
2. B3: PRD → `bmad-bmm-create-prd` ✅ (used for this project!)
3. B4: Stories → `bmad-bmm-create-story` + `bmad-bmm-create-epics-and-stories`
4. B5: Code Review → `bmad-bmm-code-review`
5. B6: Tech Specs → `bmad-bmm-quick-spec`
6. B7: Sprint Planning → `bmad-bmm-sprint-planning`
7. B8: Retrospectives → `bmad-bmm-retrospective`
8. B9: Runbooks → `bmad-bmm-document-project` (partial)
9. B10: Pitch Decks → `bmad-cis-storytelling` + `bmad-cis-presentation-master`

**Gap:** Only B1 (Branding) needs custom skill

### BMAD Agents Available (Lines 108-148)
20+ specialized agents documented:
- **BMM Agents:** Analyst (Mary!), Architect, Developer, PM, Scrum Master, QA, UX Designer, Tech Writer, Quick Flow Solo Dev
- **BMB Agents:** Agent Builder, Workflow Builder, Module Builder
- **CIS Agents:** Brainstorming Coach (used!), Design Thinking, Innovation Strategist, Problem Solver, Storyteller, Presentation Master
- **TEA Agents:** TEA (test strategy)

### Custom Skills Needed (Lines 150-225)
**MVP (7 skills, 48 hours):**
1. 7f-create-repository (4 hours)
2. 7f-brand-system-generator (8 hours)
3. 7f-github-org-configurator (8 hours)
4. 7f-company-definition-wizard (6 hours)
5. 7f-dashboard-configurator (6 hours)
6. 7f-onboard-team-member (8 hours)
7. 7f-github-org-search (8 hours)

**Phase 1 (3 skills, 24 hours):**
8. 7f-security-scan-and-fix (12 hours)
9. 7f-api-design-guide (6 hours)
10. 7f-database-design-guide (6 hours)

**Phase 2 (2 skills, 12 hours):**
11. 7f-incident-response-guide (8 hours)
12. 7f-git-commit-guide (4 hours)

**Total Custom:** 12 skills, 84 hours

### Deployment Strategy (Lines 228-324)
**Submodule Approach:**
```bash
git submodule add https://github.com/bmad-method/bmad-method.git _bmad
```
- Deploy to both GitHub orgs (internal + public)
- Symlink skills to `.claude/commands/`
- Pin to specific BMAD version for stability

**Alternative:** Package approach (npm/pip) - deferred to Phase 2

### Revised MVP Inventory (Lines 327-370)
**Original Plan:** 6 skills
**Revised Plan:** 25 skills!
- 7 custom Seven Fortunas skills
- 18 BMAD skills adopted
- 20+ BMAD agents available on demand

### Development Effort Comparison (Lines 373-402)
**Before BMAD:**
- 37 skills to create
- 356 hours development
- $53,400 cost

**After BMAD:**
- 12 custom skills (7 MVP + 3 Phase 1 + 2 Phase 2)
- 84 hours development
- $12,600 cost
- **Savings: $40,800 (76% reduction)**
- **Time savings: 272 hours (87% reduction)**

**ROI Improvement:**
- Original ROI: 528-841%
- With BMAD: **2,063-3,095%** (20-31x return!)
- Payback period: <1 week

### Implementation Roadmap (Lines 404-464)
**Day 0 (Today):**
- Add BMAD as submodule ✅ (done)
- Create skill mapping ✅ (this doc)
- Update Architecture Document
- Update Product Brief

**Day 0-1:**
- Create 7 custom skills using `bmad-bmb-create-workflow`

**Day 1:**
- Deploy BMAD to GitHub orgs
- Symlink skills
- Document in READMEs

**Day 2-5:**
- Use skills to build MVP infrastructure

### Strategic Benefits (Lines 476-496)
**Time to Market:**
- Original: ~50 days total
- With BMAD: ~11 days total
- **Acceleration: 4.5x faster**

**Quality:**
- Battle-tested workflows
- Community support
- Best practices baked in

**Scalability:**
- 70+ BMAD skills available
- Can adopt more as needed

---

## Critical Information
- **60% BMAD coverage** = massive leverage
- **272 hours saved** by adopting BMAD
- **25 skills in MVP** (7 custom + 18 BMAD) vs. original 6
- **4.5x faster delivery**
- **20-31x ROI** with BMAD adoption

---

## Ambiguities / Questions
- None - clear strategic recommendation to adopt BMAD

---

## Related Documents
- Builds on AI Automation Analysis (30 opportunities)
- Informs Architecture Document (BMAD deployment strategy)
- Informs Product Brief (revised skill count)
