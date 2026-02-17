---
stepsCompleted: ['step-01-init', 'step-02-discovery', 'step-03-success', 'step-04-journeys', 'step-05-domain', 'step-06-innovation', 'step-07-project-type', 'step-08-scoping', 'step-09-functional', 'step-10-nonfunctional', 'step-11-polish', 'step-12-split']
inputDocuments:
  - '_bmad-output/planning-artifacts/product-brief-7F_github-2026-02-10.md'
  - '_bmad-output/planning-artifacts/architecture-7F_github-2026-02-10.md'
  - '_bmad-output/planning-artifacts/bmad-skill-mapping-2026-02-10.md'
  - '_bmad-output/planning-artifacts/action-plan-mvp-2026-02-10.md'
  - '_bmad-output/planning-artifacts/autonomous-workflow-guide-7f-infrastructure.md'
supportingDocuments:
  - 'prd/user-journeys.md'
  - 'prd/functional-requirements-detailed.md'
  - 'prd/nonfunctional-requirements-detailed.md'
  - 'prd/domain-requirements.md'
  - 'prd/innovation-analysis.md'
workflowType: 'prd'
date: 2026-02-10
author: Mary (Business Analyst) with Jorge
project_name: Seven Fortunas AI-Native Enterprise Infrastructure
version: 1.0
status: complete
completedDate: 2026-02-13
classification:
  projectType: Enterprise Infrastructure
  domain: DevOps/Infrastructure
  complexity: Medium-High
  projectContext: greenfield
---

# Product Requirements Document - Seven Fortunas AI-Native Enterprise Infrastructure

**Project:** GitHub Organization, Second Brain & 7F Lens Intelligence Platform
**Author:** Mary (Business Analyst) with Jorge
**Date:** 2026-02-10
**Version:** 1.0
**Status:** Complete

---

## Document Control

**Input Documents Loaded:**
- ✅ Product Brief (52KB) - High-level vision, goals, MVP scope
- ✅ Architecture Document (112KB) - Technical design, BMAD strategy, ADRs
- ✅ BMAD Skill Mapping (18KB) - 25 skills breakdown (7 custom + 18 BMAD)
- ✅ Action Plan (24KB) - 5-day execution timeline
- ✅ Autonomous Workflow Guide (110KB) - Claude Code SDK implementation approach

**Supporting Documents (Detailed Specifications):**
- 📄 [User Journeys](user-journeys.md) - 4 detailed narratives (Henry, Patrick, Buck, Jorge)
- 📄 [Functional Requirements (Detailed)](functional-requirements-detailed.md) - 28 FRs across 7 capability areas
- 📄 [Non-Functional Requirements (Detailed)](nonfunctional-requirements-detailed.md) - 21 NFRs across 7 categories
- 📄 [Domain Requirements](domain-requirements.md) - DevOps/Infrastructure, Security, Integration
- 📄 [Innovation Analysis](innovation-analysis.md) - AI-native approach, BMAD-first, autonomous agent validation

**Project Type:** Greenfield (new infrastructure, no legacy system)

**Methodology:** BMAD-first strategy (leverage 70+ existing BMAD skills, create 7 custom)

---

## Executive Summary

**Vision:** Build AI-native enterprise infrastructure for Seven Fortunas that enables 4 founders to scale from inception to 50+ person team without architectural redesign.

**Project:** GitHub Organizations (public + internal), Second Brain knowledge system, 7F Lens Intelligence Platform (AI dashboard), BMAD library deployment (70+ skills), autonomous infrastructure build (60-70% automated).

**Target Users:** Four founding team members with distinct success moments:
- **Henry (CEO):** "AI permeates everywhere; I can shape our ethos easily"
- **Patrick (CTO):** "SW development infrastructure is well done"
- **Buck (VP Eng):** "Security on autopilot"
- **Jorge (VP AI-SecOps):** "Implementation working with minimal issues"

**Differentiation:** First AI-native enterprise nervous system that:
1. Designs for AI from inception (not retrofitting)
2. Leverages autonomous agents to build 60-70% of infrastructure (5-day MVP vs. 3-6 month industry baseline)
3. Combines BMAD library (18 skills) + adapted skills (5) + custom skills (3) = 26 operational skills
4. Permeates AI thoughtfully in everything (brand generation, architecture docs, code review, security scanning, infrastructure build)

**Approach:** BMAD-first methodology with Claude Code SDK autonomous agent (bounded retries, testing built-in, progress tracking).

**Timeline:**
- **MVP (Week 1):** Core infrastructure + security controls (Days 1-2 autonomous, Days 3-5 human refinement)
- **Phase 1.5 (Weeks 2-3):** CISO Assistant + SOC 2 integration, AI-first GitHub operations
- **Phase 2 (Months 1-3):** Additional dashboards, team expansion (10-20 members)
- **Phase 3 (Months 6-12):** GitHub Enterprise tier, SOC 2 Type 2 audit ready, 50+ team members

**Success Metrics:** 60-70% autonomous completion (18-25 features), all 4 founder aha moments achieved, leadership demo impresses (7+/10 rating), zero critical security failures.

---

## Success Criteria

### User Success

**Primary Users:** Four founding team members, each with distinct success moments:

**Henry (CEO) - "AI Permeates Everywhere"**
- **Success Moment:** "I can shape our organization's ethos easily in collaboration with AI"
- **Measurable:** Can generate brand documentation, culture docs, and strategic content using BMAD skills without waiting for bottleneck
- **Outcome:** Feels empowered to define company identity with AI as collaborative partner

**Patrick (CTO) - "So Easy to Get Things Done"**
- **Success Moment:** "Using AI to accomplish tasks is effortless; SW development infrastructure is well done"
- **Measurable:** Can review technical architecture, validate security configs, and verify infrastructure quality using automated tools
- **Outcome:** Confidence that infrastructure supports engineering excellence

**Buck (VP Engineering) - "Security on Autopilot"**
- **Success Moment:** "It's flagging any attempts to push sensitive data; code review and test infrastructure already configured"
- **Measurable:** Dependabot alerts active, secret scanning catches commits, pre-commit hooks prevent security issues
- **Outcome:** Can focus on building features, not manually checking for security issues

**Jorge (VP AI-SecOps) - "It Just Works"**
- **Success Moment:** "The implementation is working with minimal or no issues"
- **Measurable:** Autonomous agent completes 60-70% with <5 blocked features, team self-sufficient after onboarding
- **Outcome:** Enabler not bottleneck; team can operate infrastructure without constant Jorge intervention

### Business Success

**Primary Metric:** Significant productivity and scalability from all participants

**Measurable Indicators:**

**Productivity Gains:**
- New team members productive in 1-2 days (vs. industry baseline 1-2 weeks)
- Time to find document < 30 seconds (vs. minutes of searching)
- "Where is X?" Slack messages reduced by 50%
- Content generation time reduced 3-4x (voice input + AI collaboration)

**Scalability Proof Points:**
- Infrastructure supports 4 founders → expands to 10-20 → scales to 50+ without architectural changes
- Self-service model validated: Founding team can configure systems using BMAD skills without Jorge as bottleneck
- Reusable patterns established: New repos, workflows, dashboards can be created quickly using templates

**Strategic Impact:**
- Leadership demo impresses for funding (organized, professional, AI-driven)
- Infrastructure becomes catalyst for other AI-focused applications (proven pattern)
- Demonstrates Seven Fortunas's AI-native approach to investors and partners

### Technical Success

**Security - MOST IMPORTANT (Non-Negotiable):**

**Must-Have Security Criteria:**
- ✅ Zero secrets committed to repositories (detect-secrets pre-commit hook catches 100%)
- ✅ Dependabot enabled on all repos (automated vulnerability scanning)
- ✅ Secret scanning active on all repos (GitHub catches API keys, tokens)
- ✅ Code scanning (CodeQL) on security-sensitive repos
- ✅ Branch protection rules enforced (no force-push to main)
- ✅ 2FA required for all founding team members
- ✅ Audit trail: All commits, PR reviews, config changes tracked

**Friendliness (Developer Experience):**
- ✅ Clear documentation: Every repo has comprehensive README
- ✅ Onboarding speed: New member can clone, setup, contribute in < 2 hours
- ✅ BMAD skills discoverable: `/bmad-help` works, skills documented
- ✅ Error messages helpful: When something fails, clear guidance on fixing

**Robustness (Reliability):**
- ✅ Automated workflows don't fail silently (GitHub Actions notifications on failure)
- ✅ Dashboards auto-update every 6 hours without manual intervention
- ✅ BMAD submodule pinned to specific version (no surprise breaking changes)
- ✅ Graceful degradation: If X API unavailable, dashboard still works with other sources

**Resilience (Disaster Recovery):**
- ✅ All infrastructure as code (can rebuild from Git)
- ✅ No single point of failure (multiple founders have Owner access)
- ✅ Documented recovery procedures (CLAUDE.md, README.md)
- ✅ Configuration backed up in Git (can restore to any point in history)

**Maintainability (Long-term Sustainability):**
- ✅ Self-documenting: CLAUDE.md explains how everything works
- ✅ Consistent patterns: All repos follow same structure
- ✅ Minimal custom code: Leverage BMAD (maintained by community)
- ✅ Clear ownership: Each system has documented maintainer

### Measurable Outcomes

**Week 1 (MVP Complete):**
- [ ] All 4 founders complete onboarding in < 2 hours each
- [ ] Security scan catches test secret commit (validates it works)
- [ ] Jorge responds "it just works" when asked about infrastructure status
- [ ] Leadership demo receives positive feedback (7+/10 rating)

**Month 1-3 (Post-MVP):**
- [ ] 10+ team members onboarded, all productive within 1-2 days
- [ ] Zero "where is X?" questions in team channel (self-service working)
- [ ] 3+ dashboards auto-updating (AI, Fintech, EduTech)
- [ ] First external contribution to public repos (validates organization)

**Month 6-12 (Maturity):**
- [ ] Infrastructure supports 50+ person team without architectural changes
- [ ] SOC2 Type 2 audit in progress (validates security approach)
- [ ] Public GitHub showcases generate measurable inbound leads
- [ ] Infrastructure becomes catalyst: 2+ new AI applications built on this pattern

---

## Product Scope

### MVP - Minimum Viable Product (Week 1)

**Must-Have for Success:**

**GitHub Organizations:**
- 2 orgs created (Seven-Fortunas public, Seven-Fortunas-Internal private)
- 10 teams structured (5 per org)
- 8-10 repositories with professional documentation
- Security enabled (Dependabot, secret scanning, branch protection)
- 4 founding team members onboarded with 2FA

**BMAD Library Deployment:**
- BMAD v6.0.0 as submodule in second-brain repo
- 18 BMAD skills symlinked and accessible
- 7 custom Seven Fortunas skills created
- Skills documented and discoverable

**Second Brain (Knowledge Management):**
- Directory structure scaffolded (brand/, culture/, domain-expertise/, best-practices/, skills/)
- Placeholder content (real branding by Henry post-agent)
- Progressive disclosure architecture established
- Obsidian-compatible structure

**7F Lens Intelligence Platform:**
- **AI Advancements Dashboard** (MVP focus - most impressive)
  - RSS feed aggregation (OpenAI, Anthropic, Meta, Google, arXiv)
  - GitHub releases tracking (LangChain, LlamaIndex)
  - Reddit integration (r/MachineLearning, r/LocalLLaMA)
  - Claude API weekly summarization
  - Auto-updating every 6 hours
  - Professional README with live data

**Automation & Infrastructure:**
- 20+ GitHub Actions workflows
- Dashboard auto-update workflow (every 6 hours)
- Weekly AI summary workflow (Sundays)
- Security scanning workflows
- Real Seven Fortunas branding applied (Henry's work)

**User Profile System:**
- YAML schema defined
- 4 founding team profiles created
- AI agents can load and reference profiles
- `7f-manage-profile` skill operational

**Voice Input System:**
- OpenAI Whisper cross-platform installer
- Works on Linux, macOS, Windows (WSL)
- Web fallback for Windows (non-WSL) and mobile
- Documented and tested

---

### Phase 1.5: Compliance & AI-First Governance (Weeks 2-3)

**CISO Assistant + SOC 2 Integration:**
- Migrate CISO Assistant from personal repo to Seven-Fortunas-Internal org
- Map GitHub security controls to SOC 2 requirements
- Automate evidence collection (GitHub API → CISO Assistant)
- Control monitoring dashboard (compliance posture visibility)
- Integration guide skill: `/7f-compliance-integration-guide`

**AI-First GitHub Operations (Foundation → Full Enforcement):**
- Skill organization system (categorized library like BMAD)
- Core GitHub operation skills (create-repo, add-member, update-permissions)
- Skill levels/tiers (Tier 1: Production-ready, Tier 2: Beta, Tier 3: Experimental)
- Skill governance: Search existing before creating new (via enhanced `skill-creator`)
- RBAC-like permissions: Some operations require skills (blocked from manual), others encouraged

**Skill Management Strategy:**
- Prevent skill proliferation through intelligent skill-creator
- Search for existing skills that can be enhanced/modded
- Organize skills by category (Infrastructure, Security, Compliance, Content, Development)
- Deprecate stale/unused skills (review quarterly)

---

### Phase 2: Growth (Months 1-3)

**Additional Dashboards (3-4 dashboards):**
- Fintech Trends Dashboard
- EduTech Intelligence Dashboard
- Security Intelligence Dashboard
- Infrastructure Health Dashboard (inward-looking, AI-based)

**Enhanced Second Brain:**
- Complete domain expertise (tokenization, compliance, airgap security)
- 10+ additional custom skills
- Obsidian vault setup (visualization, mobile access)
- Decision framework templates (RFC, ADR)

**Team Expansion:**
- Onboard 10-20 team members
- Role-based access patterns
- Improved onboarding automation
- Training materials

**Infrastructure Improvements:**
- Centralized logging system
- Disaster recovery procedures
- GitHub Codespaces (terminal in browser)
- Enhanced audit & compliance automation

**Public Presence:**
- 5+ public showcase repos
- Open-source tools/utilities
- Example implementations

---

### Phase 3: Expansion (Months 6-12)

**GitHub Enterprise Tier:**
- SOC1/SOC2 reporting
- SAML SSO
- Advanced secret scanning and CodeQL
- Audit Log API integration

**Full 7F Lens Platform:**
- 6+ dashboards operational
- Predictive analytics (trend forecasting)
- Sentiment analysis
- Real-time alerting
- Historical analysis (12+ months data)

**Mature Second Brain:**
- All domain expertise documented
- 20+ custom skills
- MCP server for AI agent access
- API for programmatic access
- Search functionality (vector embeddings)

**Public Showcase:**
- 20+ public repos
- Thought leadership content
- Community engagement
- Public dashboards driving inbound leads

**Advanced Voice Input:**
- Real-time streaming transcription
- Multi-speaker detection
- Custom wake word
- Voice commands
- Mobile app

---

## User Personas

### Founding Team (Primary Users)

**1. Henry (@henry_7f) - CEO**
- **Role:** Company vision, strategy, fundraising, brand definition
- **Aha Moment:** "AI permeates everywhere; I can shape our organization's ethos easily in collaboration with AI"
- **Primary Needs:**
  - Brand system generation (voice, values, messaging)
  - Investor presentation materials
  - Content creation with AI collaboration
  - Voice input for rapid content generation
- **Success Metric:** Can generate brand documentation and strategic content in hours, not weeks

**2. Patrick (@patrick_7f) - CTO**
- **Role:** Technical architecture, infrastructure validation, engineering excellence
- **Aha Moment:** "Using AI to accomplish tasks is effortless; SW development infrastructure is well done"
- **Primary Needs:**
  - Architecture documentation (ADRs, technical specs)
  - Code review automation
  - Security validation
  - Infrastructure quality assurance
- **Success Metric:** Confident that infrastructure supports engineering excellence without technical debt

**3. Buck (@buck_7f) - VP Engineering**
- **Role:** Engineering projects, apps, backend infrastructure, token management, application security, code review, test infrastructure, compliance
- **Aha Moment:** "It's flagging any attempts to push sensitive data; code review and test infrastructure already configured"
- **Primary Needs:**
  - Automated security controls (pre-commit hooks, secret scanning)
  - Security dashboard visibility
  - Dependabot and vulnerability management
  - Branch protection enforcement
  - Engineering project delivery infrastructure
- **Success Metric:** Security is on autopilot; engineering projects deliver smoothly; can focus on building, not firefighting

**4. Jorge (@jorge_7f) - VP AI-SecOps**
- **Role:** AI infrastructure, security domain expert, DevOps automation, autonomous agent orchestration, skill creation, team enablement
- **Aha Moment:** "The implementation is working with minimal or no issues"
- **Primary Needs:**
  - Autonomous agent infrastructure (Claude Code SDK)
  - Bounded retry logic for resilient automation
  - Feature tracking and progress monitoring
  - Meta-skill for creating domain-specific skills
  - Security standards and compliance tooling
- **Success Metric:** Shifts from "do everything" to "enable everything"; team is self-sufficient; security posture is excellent

---

## User Journeys

**See:** [user-journeys.md](user-journeys.md) for complete narratives

**Journey 1: Henry (CEO)** - Shaping Company Ethos with AI Collaboration
**Journey 2: Patrick (CTO)** - Infrastructure Validation at AI Speed
**Journey 3: Buck (VP Engineering)** - Security on Autopilot
**Journey 4: Jorge (VP AI-SecOps)** - Autonomous Agent Success

**Key Capabilities Revealed by Journeys:**
1. Voice Input System (Henry)
2. Custom Skill Creation (Henry, Jorge)
3. Second Brain Content Structure (Henry, Patrick)
4. AI Collaboration Workflows (Henry)
5. Architecture Documentation (Patrick)
6. Code Review Automation (Patrick)
7. Security Automation (Buck)
8. GitHub CLI Automation (Patrick, Buck, Jorge)
9. Autonomous Agent Infrastructure (Jorge)
10. Feature Tracking System (Jorge)
11. BMAD Library Deployment (All)
12. Dashboard Auto-Update (Future)

---

## Domain-Specific Requirements

**See:** [domain-requirements.md](domain-requirements.md) for complete specifications

**Summary:**
- **Domain:** DevOps/Infrastructure (Medium-High complexity, Greenfield)
- **Compliance:** SOC 2 controls (Phase 1.5), security-first architecture
- **Technical Constraints:** AI-native infrastructure, progressive disclosure, YAML-based configs
- **Integration:** GitHub ecosystem, BMAD library, Claude Code SDK, OpenAI Whisper, dashboard APIs
- **Existing Skills:** 5 adapted from claude-code-second-brain-skills (31% time savings)
- **Risk Mitigations:** Autonomous agent (bounded retries), security (dual-layer protection), scalability (GitHub tier scaling)

---

## Innovation & Novel Patterns

**See:** [innovation-analysis.md](innovation-analysis.md) for complete validation

**Core Innovation Thesis:**

Seven Fortunas infrastructure is the first **AI-native enterprise nervous system** that:
1. **Designs for AI from inception** (not retrofitting)
2. **Leverages autonomous agents to build 60-70%** (bounded retries, testing built-in)
3. **Combines BMAD library + adapted skills** (87% cost reduction)
4. **Permeates AI thoughtfully in everything** (brand, content, docs, security, infrastructure)

**Key Differentiators:**
- 5-day MVP vs. 3-6 month industry baseline (95% faster)
- 26 operational skills (18 BMAD + 5 adapted + 3 custom) vs. 7 skills from scratch (87% cost reduction)
- Security-first from day one (Buck's aha moment depends on this)
- Autonomous agent with bounded retries (no infinite loops, testing built-in)

**Market Context:** No direct competitors combining autonomous agent + BMAD library + progressive disclosure + voice input + Second Brain + 7F Lens dashboards

---

## Features & Requirements

**See:** [functional-requirements-detailed.md](functional-requirements-detailed.md) for complete specifications

### Capability Overview

**7 Core Capability Areas:**

1. **GitHub Organization & Repository Management** (4 FRs)
   - Multi-org structure (public + internal)
   - Repository templates and consistent structure
   - Branch protection and access control
   - Team-based permissions

2. **BMAD Library & Skill System** (6 FRs)
   - BMAD v6.0.0 deployment (18 skills)
   - Adapted skills (5 skills: brand, pptx, diagram, sop, skill-creator)
   - Custom skills (3 skills: manage-profile, dashboard-curator, repo-template)
   - Skill discoverability and organization
   - Skill governance and lifecycle management
   - AI-first GitHub operations (foundation)

3. **Second Brain Knowledge Management** (4 FRs)
   - Directory structure and progressive disclosure
   - Placeholder content (MVP) / real content (Phase 1.5+)
   - User profiles (YAML-based)
   - Obsidian compatibility

4. **7F Lens Intelligence Platform** (4 FRs)
   - AI Advancements Dashboard (MVP)
   - Dashboard configuration (YAML)
   - Dashboard automation (GitHub Actions)
   - Future dashboards (Phase 2+)

5. **Security & Compliance** (4 FRs)
   - Secret detection (pre-commit + GitHub)
   - Dependency management (Dependabot)
   - Code scanning (CodeQL)
   - Audit & compliance (Git history + GitHub audit log)

6. **User Profile & Voice Input** (2 FRs)
   - Voice input system (OpenAI Whisper, cross-platform)
   - User onboarding (7f-onboard-member skill)

7. **Autonomous Agent & Automation** (5 FRs)
   - Autonomous agent infrastructure (Claude Code SDK)
   - Bounded retry logic (max 3 attempts)
   - Testing built into development cycle
   - Progress tracking (feature_list.json, claude-progress.txt)
   - GitHub Actions workflows (20+ workflows)

**Total:** 28 Functional Requirements (all testable, implementation-agnostic)

---

## Non-Functional Requirements

**See:** [nonfunctional-requirements-detailed.md](nonfunctional-requirements-detailed.md) for complete specifications

### Quality Attribute Summary

**7 NFR Categories:**

1. **Security (5 NFRs - MOST CRITICAL)**
   - Secret detection & prevention (100% detection rate)
   - Vulnerability management (SLAs: Critical 24h, High 7d)
   - Access control & authentication (2FA, principle of least privilege)
   - Code security (OWASP Top 10 detection)
   - SOC 2 control tracking (Phase 1.5: CISO Assistant integration)

2. **Performance (3 NFRs)**
   - Interactive response time (< 2s for 95th percentile)
   - Dashboard auto-update (< 10min per cycle)
   - Autonomous agent efficiency (60-70% completion in 24-48h)

3. **Scalability (3 NFRs)**
   - Team growth (4 → 50 users, <10% performance degradation)
   - Repository & workflow growth (100+ repos, 200+ workflows)
   - Data growth (12+ months historical analysis)

4. **Reliability (3 NFRs)**
   - Workflow reliability (99% success rate for scheduled jobs)
   - Graceful degradation (continue at reduced capacity when dependencies fail)
   - Disaster recovery (1-hour RTO, last-commit RPO)

5. **Maintainability (5 NFRs)**
   - Self-documenting architecture (comprehensible in 2 hours)
   - Consistent patterns (naming, structure, workflows)
   - Minimal custom code (BMAD library, adapted skills)
   - Clear ownership (CODEOWNERS, escalation paths)
   - Skill governance (prevent proliferation, lifecycle management)

6. **Integration (3 NFRs)**
   - API rate limit compliance (GitHub, Reddit, Claude, Whisper)
   - External dependency resilience (retry logic, error logging)
   - Backward compatibility (1+ year for dependency updates)

7. **Accessibility (2 NFRs)**
   - CLI accessibility (comprehensive docs, onboarding)
   - Phase 2 improvements (Codespaces, web alternatives)

**Total:** 21 Non-Functional Requirements (all measurable, specific criteria)

---

## Constraints & Assumptions

### Technical Constraints

**GitHub CLI Account (CRITICAL):**
- **Constraint:** MUST use `jorge-at-sf` GitHub CLI account for all Seven Fortunas operations
- **Risk:** Using `jorge-at-gd` (alternative account) will create orgs/repos in wrong organization
- **Mitigation:** Verify account before ANY GitHub operation: `gh auth status | grep jorge-at-sf`
- **Enforcement:** Add check to agent scripts, CLAUDE.md warnings

**GitHub Tier Limits:**
- **MVP:** GitHub Free tier (3,000 Actions minutes/month, public repos unlimited)
- **Phase 1.5-2:** GitHub Team tier ($4/user/month, post-funding)
- **Phase 3:** GitHub Enterprise tier ($21/user/month, SOC 2 reporting, SAML SSO)

**Autonomous Agent Capacity:**
- **Assumption:** Agent can complete 60-70% of MVP features (18-25 of 28 features)
- **Constraint:** Bounded retries (max 3 attempts), 30-minute timeout per feature
- **Risk:** If <50% completion, extend timeline or reduce scope (contingency plan documented)

**CISO Assistant Dependency (Phase 1.5):**
- **Assumption:** CISO Assistant already deployed (personal repo), well-documented for migration
- **Constraint:** Phase 1.5 requires CISO Assistant migration + integration (Week 2-3)
- **Risk:** If migration blocked, defer SOC 2 automation to Phase 2

---

### Timeline Assumptions

**MVP (Week 1, Day 1-5):**
- Autonomous agent: Day 1-2 (60-70% completion)
- Human refinement: Day 3-5 (branding, testing, polish)
- Leadership demo: Day 5 (end of week)

**Phase 1.5 (Weeks 2-3):**
- CISO Assistant migration: Week 2, Day 1-2
- GitHub → CISO Assistant integration: Week 2, Day 3-5
- AI-First GitHub ops skills: Week 3, Day 1-3
- Full enforcement + testing: Week 3, Day 4-5

**Phase 2 (Months 1-3):**
- Additional dashboards, team expansion, public showcase repos

**Phase 3 (Months 6-12):**
- GitHub Enterprise tier, advanced features, mature Second Brain

---

### Resource Assumptions

**Jorge (VP AI-SecOps):**
- MVP: Autonomous agent setup + monitoring (Days 1-2), refinement (Days 3-5)
- Phase 1.5: CISO Assistant migration, AI-first skill creation (Weeks 2-3)
- Phase 2+: Enabler not bottleneck (team self-sufficient)

**Henry (CEO):**
- MVP: Real branding application (Days 3-5)
- Phase 1.5: Brand system validation, investor materials
- Phase 2+: Strategic content creation via AI skills

**Patrick (CTO):**
- MVP: Architecture validation (Day 3)
- Phase 1.5: CISO Assistant integration review, control mapping validation
- Phase 2+: Technical oversight

**Buck (VP Engineering):**
- MVP: Security testing (Day 3)
- Phase 1.5: SOC 2 control validation, compliance audit preparation
- Phase 2+: Security monitoring and response

---

### Operational Assumptions

**AI-First Philosophy:**
- **MVP:** AI-first is "recommended approach" (manual UI still allowed)
- **Phase 1.5:** AI-first is "required for Tier 1 operations" (manual UI discouraged)
- **Phase 2:** AI-first is "enforced via audit alerts" (manual changes flagged)

**Skill Management:**
- **Assumption:** Enhanced `skill-creator` prevents 80%+ of duplicate skills
- **Assumption:** Quarterly skill reviews keep library lean (deprecate stale skills)
- **Risk:** Without governance, skill count could grow to 100+ (unmanageable)

**Compliance Approach:**
- **MVP:** Security controls implemented (foundation for SOC 2)
- **Phase 1.5:** SOC 2 control mapping + automated evidence collection
- **Phase 3:** SOC 2 Type 2 audit ready (GitHub Enterprise tier, 12+ months evidence)

---

### External Dependencies

**Claude Code SDK:**
- Assumption: Stable API, bounded retries work as designed
- Risk: If SDK unavailable, fallback to manual implementation (3-6 month timeline)

**BMAD Library:**
- Assumption: BMAD v6.0.0 stable, 18 skills functional
- Constraint: Pinned version (no auto-updates, manual upgrades only)

**OpenAI Whisper API:**
- Assumption: Cross-platform installation works (Linux, macOS, Windows WSL)
- Fallback: Web-based transcription for Windows/mobile

**Dashboard Data Sources:**
- Assumption: RSS feeds, GitHub API, Reddit API available and stable
- Constraint: Respectful polling (every 6 hours), graceful degradation on failures

---

## Release Criteria

### MVP Release (Week 1)

**Must-Have (Non-Negotiable):**
- ✅ 2 GitHub orgs created (Seven-Fortunas public, Seven-Fortunas-Internal private)
- ✅ 10 teams structured (5 per org)
- ✅ 8-10 repositories with professional documentation
- ✅ Security enabled (Dependabot, secret scanning, branch protection, 2FA)
- ✅ 4 founding team members onboarded
- ✅ BMAD v6.0.0 deployed as submodule
- ✅ 18 BMAD skills + 5 adapted skills + 3 custom skills = 26 operational skills
- ✅ Second Brain scaffolded (directories, placeholder content)
- ✅ AI Advancements Dashboard live (auto-updating every 6 hours)
- ✅ Voice input system (OpenAI Whisper) documented and tested
- ✅ 20+ GitHub Actions workflows configured
- ✅ All changes committed to git
- ✅ Zero critical security failures

**Success Metrics:**
- ✅ Autonomous agent: 60-70% completion rate (18-25 of 28 features)
- ✅ All 4 founder aha moments validated
- ✅ Leadership demo: 7+/10 rating
- ✅ Security testing: Buck's adversarial tests pass (secret detection 100%)
- ✅ Onboarding time: < 2 hours per founder

---

### Phase 1.5 Release (Weeks 2-3)

**Must-Have:**
- ✅ CISO Assistant migrated to Seven-Fortunas-Internal org
- ✅ GitHub security controls mapped to SOC 2 requirements
- ✅ Automated evidence collection (GitHub API → CISO Assistant)
- ✅ Compliance dashboard (real-time control posture)
- ✅ 10+ AI-first GitHub operation skills created
- ✅ Skill organization system (categorized, tiered)
- ✅ Skill governance (search before create, usage tracking)

**Success Metrics:**
- ✅ Control drift detection: Alert within 15 minutes
- ✅ Evidence collection: Daily sync functional
- ✅ AI-first adoption: 80%+ of GitHub operations via skills
- ✅ Skill proliferation prevented: <5 duplicate skills created

---

### Phase 2 Release (Months 1-3)

**Must-Have:**
- ✅ 3+ additional dashboards operational
- ✅ 10-20 team members onboarded
- ✅ 5+ public showcase repos
- ✅ Enhanced Second Brain (complete domain expertise)

**Success Metrics:**
- ✅ Team self-sufficiency: Jorge < 2 hours/week support
- ✅ Onboarding scalability: All team members productive in 1-2 days
- ✅ Public presence: First external contribution received

---

### Phase 3 Release (Months 6-12)

**Must-Have:**
- ✅ GitHub Enterprise tier (SOC 2 reporting, SAML SSO)
- ✅ 6+ dashboards operational
- ✅ 20+ custom Seven Fortunas skills
- ✅ 50+ team members supported

**Success Metrics:**
- ✅ SOC 2 Type 2 audit in progress
- ✅ Infrastructure scales to 50+ without architectural changes
- ✅ Public dashboards generate measurable inbound leads

---

## Appendix

### Supporting Documentation

**Detailed Specifications:**
- [User Journeys](user-journeys.md) - 4 comprehensive narratives
- [Functional Requirements (Detailed)](functional-requirements-detailed.md) - 28 FRs with acceptance criteria
- [Non-Functional Requirements (Detailed)](nonfunctional-requirements-detailed.md) - 21 NFRs with measurements
- [Domain Requirements](domain-requirements.md) - DevOps/Infrastructure, Security, Integration
- [Innovation Analysis](innovation-analysis.md) - AI-native validation, risk mitigation

**Planning Artifacts (Input Documents):**
- Product Brief (52KB)
- Architecture Document (112KB)
- BMAD Skill Mapping (18KB)
- Action Plan (24KB)
- Autonomous Workflow Guide (110KB)

**GitHub Resources:**
- Public Organization: https://github.com/Seven-Fortunas
- Internal Organization: https://github.com/Seven-Fortunas-Internal
- Brain Repository: https://github.com/Seven-Fortunas-Internal/seven-fortunas-brain
- Dashboards Repository: https://github.com/Seven-Fortunas/dashboards

---

**END OF CORE PRD**

*For detailed functional requirements, non-functional requirements, user journeys, domain requirements, and innovation analysis, see supporting documents in this directory.*
