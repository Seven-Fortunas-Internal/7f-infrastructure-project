# Extract: Action Plan MVP

**Source:** `action-plan-mvp-2026-02-10.md`
**Date:** 2026-02-10
**Size:** 918 lines
**Author:** Mary (Business Analyst) with Jorge

---

## Document Metadata
- **Purpose:** Day-by-day 5-day MVP execution plan
- **Format:** Operational checklist with bash commands, validation steps, risk mitigation
- **Timeline:** Days 0-5 (setup through demo)
- **Status:** Ready to Execute

---

## Key Content Summary

### Overview (Lines 9-16)
**Timeline:** 5 days (Days 0-5)
**Approach:** BMAD-first strategy (leverage 70+ existing skills, create 7 custom)
**Deliverable:** 25 operational skills, 2 GitHub orgs, 1 live dashboard, real branding

---

### Day 0: Foundation & BMAD Deployment (Lines 17-349)

**Step 1: Review & Approval (1 hour)**
- Review Product Brief, Architecture, BMAD Skill Mapping, Action Plan
- Approve to proceed

**Step 2: Create GitHub Organizations (1 hour)**
- Create Seven-Fortunas (public)
- Create Seven-Fortunas-Internal (private)
- Configure basic settings, placeholder logo

**Step 3: Create Core Repositories (1 hour)**
- seven-fortunas-brain (private, Second Brain)
- 7f-infrastructure-project (private, planning artifacts)
- seven-fortunas.github.io (public, website)
- dashboards (public, 7F Lens)

**Step 4: Deploy BMAD Library (1 hour)**
- Add BMAD as submodule (git submodule add)
- Pin to v6.0.0 for stability
- Create symlinks to .claude/commands/ (18 skills)
- Script: create-bmad-symlinks.sh

**Step 5: Create Custom Skills (4 hours)**
- Use BMAD Workflow Builder (/bmad-bmb-create-workflow)
- 7 skills: create-repository, brand-system-generator, github-org-configurator, company-definition-wizard, dashboard-configurator, onboard-team-member, github-org-search
- Test each skill before moving to next

**Day 0 Summary:**
- 2 GitHub orgs created
- 6 core repos initialized
- BMAD library deployed (70+ skills)
- 7 custom skills created
- **Total: 25 skills operational**
- Time: ~8 hours
- Cost: $0

---

### Day 1: Infrastructure Scaffolding (Lines 351-433)

**Morning: Autonomous Agent Setup (2 hours)**
- Create app_spec.txt (28 features from PRD)
- Launch autonomous coding agent
- Agent scaffolds with placeholder branding

**Afternoon: Henry Defines Branding (3 hours)**
- Henry runs /7f-brand-system-generator
- Interactive questionnaire (colors, fonts, logo, voice)
- Skill auto-generates: brand.json, brand-system.md, tone-of-voice.md
- Skill auto-applies: GitHub orgs, website, templates

**Evening: Project Migration (1 hour)**
- Copy planning artifacts to 7f-infrastructure-project repo
- Commit to git with comprehensive message

---

### Day 2: Configuration & Setup (Lines 435-525)

**Morning: Patrick Reviews Architecture (2 hours)**
- Reviews Architecture Document
- Reviews GitHub org structure, security policies
- Uses /7f-github-org-configurator
- Configures: 2FA, Dependabot, secret scanning, team structure

**Afternoon: Henry Defines Company Culture (2 hours)**
- Runs /7f-company-definition-wizard
- Defines mission, vision, values, target customers, decision framework
- Generates: culture/mission.md, vision.md, values.md, ethos.md

**Evening: Dashboard Configuration (2 hours)**
- Uses /7f-dashboard-configurator
- Configures AI dashboard sources (RSS, Reddit, GitHub)
- Generates: config/sources.yaml, scripts/fetch_sources.py, GitHub Actions workflow
- Tests dashboard aggregation

---

### Day 3: Quality Review & Branding Finalization (Lines 527-594)

**Morning: Buck Reviews Security (2 hours)**
- Reviews GitHub org security settings
- Repository branch protection, secret scanning, Dependabot
- Uses /bmad-tea-testarch-test-review
- Documents findings

**Afternoon: Jorge Quality Review (2 hours)**
- Reviews branding consistency
- Tests all BMAD skills
- Reviews dashboard data quality, documentation completeness

**Evening: Branding Edge Cases (2 hours)**
- Manual fixes for assets skill couldn't update
- Fine-tuning CSS, colors, fonts
- Ensures visual consistency

---

### Day 4: Documentation & Testing (Lines 595-687)

**Morning: Documentation Generation (2 hours)**
- Uses /bmad-bmm-document-project
- Generates: Org READMEs, Contributing guidelines, Code of Conduct, Security policy
- Creates Organization Standing Up guide
- BMAD skills reference

**Afternoon: Integration Testing (3 hours)**
- Tests end-to-end workflows:
  - Story creation (/bmad-bmm-create-story)
  - Development workflow (/bmad-bmm-dev-story)
  - Sprint planning (/bmad-bmm-sprint-planning)
  - Dashboard auto-update

**Evening: Prepare Demo Materials (1 hour)**
- Create demo script
- Prepare metrics slide (5 days, $0, 25 skills, 60-70% automated)

---

### Day 5: Onboarding & Final Polish (Lines 689-807)

**Morning: Founding Team Onboarding (3 hours)**
- Use /7f-onboard-team-member for each founder
  - Henry (@henry_7f) - CEO, Owner all teams
  - Patrick (@patrick_7f) - CTO, Owner Engineering/Operations
  - Buck (@buck_7f) - VP Eng, Member Engineering
  - Jorge (@jorge_7f) - VP AI-SecOps, Member Engineering/Operations
- Conduct onboarding walkthrough

**Afternoon: Final Polish (2 hours)**
- Final checks (all repos have README, .gitignore, LICENSE)
- Create retrospective document (/bmad-bmm-retrospective)

**Evening: Leadership Demo (1 hour)**
- Present MVP (overview, live demo, metrics, Q&A, next steps)

---

## Success Criteria Checklist (Lines 809-843)

**Infrastructure:**
- 2 GitHub orgs
- 10 teams (5 per org)
- 8-10 repositories
- BMAD library deployed (70+ skills)
- Real Seven Fortunas branding

**Automation:**
- 25 skills operational (7 custom + 18 BMAD)
- AI dashboard auto-updating every 6 hours
- 20+ GitHub Actions workflows
- Security scanning enabled

**Team:**
- 4 founders onboarded with appropriate access
- Onboarding documentation complete

**Documentation:**
- Product Brief, Architecture, BMAD skills reference
- Organization Standing Up guide
- All repos have READMEs

**Quality:**
- Patrick reviewed architecture
- Buck reviewed security
- Jorge reviewed consistency
- All custom skills tested
- End-to-end workflows tested

---

## Risk Mitigation (Lines 845-855)

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Skill creation >4 hours | Medium | Medium | Use BMAD Builder, prioritize MVP skills |
| Henry unavailable Days 1-3 | Low | High | Schedule ahead, Patrick backup |
| BMAD skills don't work | Low | Medium | Test each, use community support |
| GitHub API rate limits | Low | Low | Authenticated requests, cache |
| Autonomous agent low quality | Medium | Medium | Daily reviews, manual fallback |

---

## Communication Plan (Lines 857-875)

**Daily Standup (15 min):**
- What completed, what's planned, blockers

**End-of-Day Update:**
- Progress summary, metrics, issues resolved

**Stakeholder Updates:**
- Day 0: Foundation, BMAD deployed, 25 skills operational
- Day 2: Orgs configured, branding defined, dashboard live
- Day 4: Documentation complete, testing done
- Day 5: Founders onboarded, MVP complete, demo ready

---

## Tools & Resources (Lines 877-897)

**Required Tools:**
- GitHub account with org creation
- GitHub CLI (gh)
- Claude Code
- Git
- Python 3.11+

**Documentation:**
- Product Brief, Architecture, BMAD Skill Mapping in `_bmad-output/planning-artifacts/`

---

## Celebration Plan (Lines 899-909)

**End of Day 5:**
- MVP complete 🎉
- Leadership demo successful ✅
- Use /bmad-party-mode 🎊
- Capture lessons learned
- Plan Phase 2 kickoff

---

## Critical Information

**Timeline Clarification:**
- **5 days total** (Days 0-5), not 3 days
- Day 0 is critical setup day (8 hours)
- Days 1-5 are execution

**Skill Count:**
- 25 operational skills (7 custom + 18 BMAD)
- No mention of meta-skill (skill-creator) in totals

**Branding Approach:**
- Self-service by Henry (Days 1-3)
- Skill auto-applies branding
- Jorge handles edge cases (Days 3-4)
- Real branding by Day 4

**Founding Team Roles:**
- Henry: Owner all teams (CEO)
- Patrick: Owner Engineering/Operations (CTO)
- Buck: Member Engineering (VP Eng)
- Jorge: Member Engineering/Operations (VP AI-SecOps)

**Key Dependencies:**
- Day 0 must complete before Day 1
- Henry must be available Days 1-3 for branding
- Patrick/Buck needed for reviews Days 2-4

---

## Ambiguities / Questions

**Skill count discrepancy:** Action Plan says 25 skills (7 custom + 18 BMAD), but Product Brief says 26 skills. Need to verify if skill-creator (meta-skill) is included or separate.

**GitHub account names:** Uses @henry_7f, @patrick_7f, @buck_7f, @jorge_7f - consistent with Product Brief.

---

## Related Documents
- Implements Product Brief timeline
- References Architecture Document for technical details
- Uses BMAD Skill Mapping for skill requirements
- Supports Autonomous Workflow Guide execution
