# Extract: PRD Main

**Source:** `prd/prd.md`
**Date:** 2026-02-10 to 2026-02-13 (multi-day consolidation)
**Size:** 778 lines (consolidated document)
**Author:** Mary (Business Analyst) with Jorge

---

## Document Metadata
- **Purpose:** Consolidated Product Requirements Document for Seven Fortunas AI-native infrastructure
- **Format:** Executive summary + references to detailed sub-documents
- **Status:** Complete - Ready for Implementation
- **Type:** Consolidation document (references 9 supporting documents)

---

## Key Content Summary

### Executive Summary (Lines 1-75)
**Product Name:** Seven Fortunas AI-Native Enterprise Infrastructure

**Vision:** Build AI-native enterprise nervous system designed FROM INCEPTION for AI collaboration

**Problem Statement:**
- Existing enterprise infrastructure retrofitted for AI (Slack bots, ChatGPT plugins)
- Not designed for AI-first workflows
- Seven Fortunas needs infrastructure optimized for AI collaboration from Day 1

**Solution:** Three interconnected systems:
1. **BMAD Skills Platform** - Conversational infrastructure management
2. **Second Brain** - Progressive disclosure knowledge base
3. **7F Lens Intelligence Platform** - Multi-dimensional dashboards

**Innovation:** BMAD-first strategy (87% cost reduction, 4.5x faster time to market)

**Target Users:** 4 founding team members (Henry, Patrick, Buck, Jorge) → 10-20 (Phase 2) → 50+ (Phase 3)

**MVP Timeline:** 5 days (Days 1-5)
- Day 1-2: Autonomous agent (60-70% completion)
- Day 3-5: Human refinement (branding, testing, polish)

---

### Success Criteria (Lines 76-150)

#### Primary Success Metrics
1. **Autonomous Agent Completion:** 60-70% of MVP features (18-25 of 28)
2. **Founder Aha Moments:** All 4 validated by Day 5
3. **Leadership Demo Rating:** 7+/10 (Henry + Patrick)
4. **Security Testing:** 100% secret detection (Buck's adversarial tests)
5. **Onboarding Time:** <2 hours per founder

#### Founding Team Aha Moments
**Henry (CEO) - "AI Permeates Everywhere" (30 Minutes)**
- Voice input → AI structuring → 20% refinement → Professional docs
- Success: Brand system created in 30 min vs 6 weeks

**Patrick (CTO) - "SW Development Infrastructure Well Done" (2 Hours)**
- GitHub CLI → Architecture docs → Security validation → Code review skill
- Success: Infrastructure validated, confidence in quality

**Buck (VP Engineering) - "Security on Autopilot" (1 Hour)** 🔥 ROLE ISSUE
- Pre-commit blocks → GitHub Actions catches bypass → Secret scanning alerts
- Success: Security controls work, no manual reviews needed
- **NOTE:** Jorge clarified this should be "Engineering delivery" aha moment, NOT security

**Jorge (VP AI-SecOps) - "Implementation Working with Minimal Issues" (Days 1-2)**
- Feature tracking → Bounded retries → Test-before-commit → 60-70% completion
- Success: Autonomous agent functional, minimal debugging

#### Secondary Success Metrics
- GitHub CLI operations functional (Day 1)
- 26 operational skills (Day 1)
- Zero critical security failures (Day 5)
- All founders productive in infrastructure (Day 5)
- Technical documentation comprehensible in 2 hours (Day 5)

---

### Product Scope (Lines 151-245)

#### MVP Scope (Week 1)
**In Scope:**
- 2 GitHub organizations (Seven-Fortunas, Seven-Fortunas-Internal)
- 10 teams (5 per org)
- 8-10 repositories with professional documentation
- Security controls (Dependabot, secret scanning, branch protection, 2FA)
- 4 founding team members onboarded
- BMAD v6.0.0 as submodule
- 26 operational skills (18 BMAD + 5 adapted + 3 custom)
- Second Brain scaffolded
- AI Advancements Dashboard (auto-updating every 6 hours)
- Voice input system (OpenAI Whisper)
- 20+ GitHub Actions workflows
- Autonomous agent (60-70% completion)

**Out of Scope (Deferred to Phase 1.5+):**
- CISO Assistant migration
- SOC 2 control mapping
- Additional dashboards (fintech, edutech, security)
- GitHub Enterprise tier
- Mobile optimization
- Advanced search (vector embeddings)
- Real-time collaboration
- Custom authentication
- Payment processing

#### Phase 1.5 Scope (Weeks 2-3)
- CISO Assistant migration to Seven-Fortunas-Internal
- GitHub → CISO Assistant integration (SOC 2 control mapping)
- 10+ AI-first GitHub operation skills
- Skill organization system
- Skill governance (prevent proliferation)

#### Phase 2 Scope (Months 1-3)
- 3+ additional dashboards
- 10-20 team members onboarded
- 5+ public showcase repos
- Enhanced Second Brain (complete domain expertise)
- Obsidian integration (optional)
- GitHub Private Mirrors App
- Vector search

#### Phase 3 Scope (Months 6-12)
- GitHub Enterprise tier (SOC 2 reporting, SAML SSO)
- 6+ dashboards
- 20+ custom Seven Fortunas skills
- 50+ team members
- SOC 2 Type 2 audit in progress
- Advanced features (real-time updates, collaborative editing, personalization)

---

### User Personas (Lines 246-330)

**Henry (CEO) - The Visionary Leader**
- Strategic direction, fundraising, brand steward
- Primary needs: Brand generation, investor materials, voice input
- Devices: MacBook Pro, iPhone
- Pain points: Time scarcity, context switching
- Tech comfort: Medium (prefers voice over typing)

**Patrick (CTO) - The Quality Guardian**
- Technical architecture, infrastructure validation, engineering excellence
- Primary needs: Architecture docs, code review, security validation
- Devices: Linux workstation, MacBook Pro, Terminal-first
- Pain points: Poor documentation, shortcuts for speed
- Tech comfort: High (command-line power user)

**Buck (VP Engineering) - The Security Watchdog** 🔥 EXPANDED ROLE
- **Role (per PRD):** Engineering projects, apps, backend infrastructure, token management, application security, code review, test infrastructure, compliance
- Primary needs: Automated security controls, engineering project delivery
- Devices: Linux workstation
- Pain points: Manual security reviews, compliance overhead
- Tech comfort: High (security-focused engineer)
- **NOTE:** Role description matches UX spec (Feb 14), but Jorge clarified compliance should be Jorge's

**Jorge (VP AI-SecOps) - The AI & Security Infrastructure Architect**
- AI infrastructure, security domain expert, DevOps automation, autonomous agent orchestration
- Primary needs: Autonomous agent infra, security standards, compliance tooling
- Devices: Linux workstation, Claude Code, Bash scripts
- Pain points: Context degradation, bottleneck for team
- Tech comfort: Expert (AI + security + DevOps)

---

### User Stories (Lines 331-420)
**See:** [user-journeys.md](user-journeys.md) for complete narratives

**Story 1: Henry Creates Brand Documentation**
- As CEO, I want to define branding via voice input
- So that professional brand system is generated in 30 minutes
- Acceptance: brand.json, brand-system.md, applied to all assets

**Story 2: Patrick Validates Infrastructure**
- As CTO, I want to validate infrastructure quality via GitHub CLI
- So that I can trust the foundation for product development
- Acceptance: Architecture docs readable, security validated, code review skill functional

**Story 3: Buck Tests Security Controls** 🔥 SECURITY TESTING JOURNEY
- As VP Engineering, I want to test security controls adversarially
- So that I know infrastructure prevents security incidents
- Acceptance: Secret detection 100%, bypass attempts caught, dashboard shows 100% compliance
- **NOTE:** Jorge clarified this should be Jorge's journey (Security Testing = SecOps)

**Story 4: Jorge Launches Autonomous Agent**
- As VP AI-SecOps, I want to launch autonomous agent with bounded retries
- So that 60-70% of infrastructure is built autonomously in 24-48 hours
- Acceptance: 18-25 features "pass" status, zero broken features, progress tracked

---

### Functional Requirements Summary (Lines 421-507)
**See:** [functional-requirements-detailed.md](functional-requirements-detailed.md) for complete FRs

**7 FR Capability Areas (28 FRs Total):**

1. **GitHub Organization & Permissions** (6 FRs)
   - Create orgs (public/private), teams, permissions, branch protection

2. **Second Brain Knowledge Management** (4 FRs)
   - Progressive disclosure, markdown structure, voice input, search

3. **BMAD Skills Platform** (4 FRs)
   - 26 operational skills, skill-creation skill, organization system, governance

4. **7F Lens Intelligence Platform** (4 FRs)
   - AI Advancements Dashboard, auto-update, AI-generated summaries, configurator

5. **Security & Compliance** (4 FRs)
   - Secret detection, Dependabot, branch protection, SOC 2 prep

6. **Infrastructure Documentation** (1 FR)
   - README at every level, self-documenting patterns

7. **Autonomous Agent & Automation** (5 FRs)
   - Autonomous agent infrastructure, bounded retries, testing, progress tracking, GitHub Actions

**Total:** 28 Functional Requirements (all testable, implementation-agnostic)

---

### Non-Functional Requirements Summary (Lines 509-557)
**See:** [nonfunctional-requirements-detailed.md](nonfunctional-requirements-detailed.md) for complete NFRs

**7 NFR Quality Attributes (21 NFRs Total):**

1. **Security (5 NFRs - MOST CRITICAL)**
   - Secret detection 100%
   - Vulnerability SLAs (Critical 24h, High 7d)
   - Access control & 2FA
   - Code security (OWASP Top 10)
   - SOC 2 control tracking

2. **Performance (3 NFRs)**
   - Interactive response <2s (95th percentile)
   - Dashboard update <10min
   - Autonomous agent 60-70% completion in 24-48h

3. **Scalability (3 NFRs)**
   - Team growth (4 → 50, <10% degradation)
   - Repository growth (100+ repos, 200+ workflows)
   - Data growth (12+ months historical)

4. **Reliability (3 NFRs)**
   - Workflow reliability (99% success rate)
   - Graceful degradation
   - Disaster recovery (1h RTO, last-commit RPO)

5. **Maintainability (5 NFRs)**
   - Self-documenting (comprehensible in 2 hours)
   - Consistent patterns
   - Minimal custom code
   - Clear ownership
   - Skill governance

6. **Integration (3 NFRs)**
   - API rate limit compliance
   - External dependency resilience
   - Backward compatibility (1+ year)

7. **Accessibility (2 NFRs)**
   - CLI accessibility
   - Phase 2 improvements (Codespaces, web alternatives)

**Total:** 21 Non-Functional Requirements (all measurable)

---

### Constraints & Assumptions (Lines 561-669)

#### Technical Constraints

**GitHub CLI Account (CRITICAL):** 🔥 EXPLICIT REQUIREMENT
- **Constraint:** MUST use `jorge-at-sf` account for all Seven Fortunas operations
- **Risk:** Using `jorge-at-gd` will create orgs/repos in wrong organization
- **Mitigation:** Verify before ANY operation: `gh auth status | grep jorge-at-sf`
- **Enforcement:** Add check to agent scripts, CLAUDE.md warnings

**GitHub Tier Limits:**
- MVP: GitHub Free (3,000 Actions min/month)
- Phase 1.5-2: GitHub Team ($4/user/month)
- Phase 3: GitHub Enterprise ($21/user/month)

**Autonomous Agent Capacity:**
- Assumption: 60-70% completion (18-25 of 28 features)
- Constraint: Bounded retries (max 3), 30-min timeout per feature
- Risk: If <50%, extend timeline or reduce scope

**CISO Assistant Dependency (Phase 1.5):**
- Assumption: Already deployed, well-documented for migration
- Constraint: Phase 1.5 requires migration + integration (Week 2-3)
- Risk: If blocked, defer SOC 2 automation to Phase 2

#### Timeline Assumptions
- **MVP:** Days 1-5 (autonomous Days 1-2, human refinement Days 3-5)
- **Phase 1.5:** Weeks 2-3 (CISO Assistant migration + AI-first skills)
- **Phase 2:** Months 1-3 (additional dashboards, team expansion)
- **Phase 3:** Months 6-12 (GitHub Enterprise, 50+ team members)

#### Resource Assumptions
**Jorge:** Setup/monitoring (Days 1-2), refinement (Days 3-5), enabler not bottleneck (Phase 2+)
**Henry:** Real branding (Days 3-5), brand validation + investor materials (Phase 1.5+)
**Patrick:** Architecture validation (Day 3), technical oversight (Phase 1.5+)
**Buck:** Security testing (Day 3), security monitoring (Phase 2+)

#### Operational Assumptions
**AI-First Philosophy:**
- MVP: "Recommended approach" (manual allowed)
- Phase 1.5: "Required for Tier 1 operations" (manual discouraged)
- Phase 2: "Enforced via audit alerts" (manual flagged)

**Skill Management:**
- Enhanced skill-creator prevents 80%+ duplicates
- Quarterly reviews keep library lean
- Risk: Without governance, could grow to 100+ (unmanageable)

**Compliance Approach:**
- MVP: Security controls (foundation for SOC 2)
- Phase 1.5: SOC 2 control mapping + automated evidence
- Phase 3: SOC 2 Type 2 audit ready

#### External Dependencies
- Claude Code SDK: Stable API, bounded retries work
- BMAD Library: v6.0.0 stable, 18 skills functional
- OpenAI Whisper API: Cross-platform installation
- Dashboard Data Sources: RSS, GitHub, Reddit APIs available

---

### Release Criteria (Lines 672-746)

#### MVP Release (Week 1)
**Must-Have (Non-Negotiable):**
- ✅ 2 GitHub orgs created
- ✅ 10 teams structured
- ✅ 8-10 repositories with professional docs
- ✅ Security enabled (Dependabot, secret scanning, branch protection, 2FA)
- ✅ 4 founders onboarded
- ✅ BMAD v6.0.0 deployed
- ✅ 26 operational skills
- ✅ Second Brain scaffolded
- ✅ AI Advancements Dashboard live
- ✅ Voice input documented and tested
- ✅ 20+ GitHub Actions workflows
- ✅ All changes committed to git
- ✅ Zero critical security failures

**Success Metrics:**
- ✅ Autonomous agent: 60-70% completion (18-25 of 28)
- ✅ All 4 founder aha moments validated
- ✅ Leadership demo: 7+/10 rating
- ✅ Security testing: Buck's tests pass (100% detection)
- ✅ Onboarding: <2 hours per founder

#### Phase 1.5 Release (Weeks 2-3)
**Must-Have:**
- ✅ CISO Assistant migrated
- ✅ GitHub controls mapped to SOC 2
- ✅ Automated evidence collection
- ✅ Compliance dashboard
- ✅ 10+ AI-first GitHub operation skills
- ✅ Skill organization system
- ✅ Skill governance

**Success Metrics:**
- ✅ Control drift alert: <15 minutes
- ✅ Evidence sync: Daily functional
- ✅ AI-first adoption: 80%+
- ✅ Skill proliferation: <5 duplicates

#### Phase 2 Release (Months 1-3)
**Must-Have:**
- ✅ 3+ additional dashboards
- ✅ 10-20 team members onboarded
- ✅ 5+ public showcase repos
- ✅ Enhanced Second Brain

**Success Metrics:**
- ✅ Jorge support: <2 hours/week
- ✅ Onboarding: All productive in 1-2 days
- ✅ Public presence: First external contribution

#### Phase 3 Release (Months 6-12)
**Must-Have:**
- ✅ GitHub Enterprise tier
- ✅ 6+ dashboards
- ✅ 20+ custom Seven Fortunas skills
- ✅ 50+ team members supported

**Success Metrics:**
- ✅ SOC 2 Type 2 audit in progress
- ✅ Infrastructure scales to 50+ without changes
- ✅ Public dashboards generate inbound leads

---

### Supporting Documentation (Lines 749-778)

**Detailed Specifications (Sub-Documents):**
- user-journeys.md - 4 comprehensive narratives
- functional-requirements-detailed.md - 28 FRs with acceptance criteria
- nonfunctional-requirements-detailed.md - 21 NFRs with measurements
- domain-requirements.md - DevOps/Infrastructure, Security, Integration
- innovation-analysis.md - AI-native validation, risk mitigation

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

## Critical Information

**Document Type:** Consolidation document (references 9 supporting sub-documents)

**Document Status:** Complete - Ready for Implementation

**Timeline:** 5-day MVP (Days 1-5), Phase 1.5 (Weeks 2-3), Phase 2 (Months 1-3), Phase 3 (Months 6-12)

**Success Metrics:**
- Autonomous agent: 60-70% completion
- 4 founder aha moments validated
- Leadership demo: 7+/10
- Security testing: 100% detection
- Onboarding: <2 hours per founder

**Critical Requirements:**
- **jorge-at-sf GitHub account** (EXPLICITLY stated, Lines 565-569)
- 26 operational skills (18 BMAD + 5 adapted + 3 custom)
- 28 functional requirements
- 21 non-functional requirements
- Zero critical security failures

**Buck's Role (Lines 291-307):**
- Engineering projects, apps, backend infrastructure
- Token management
- Application security
- Code review, test infrastructure
- **Compliance** (per PRD, but Jorge clarified compliance should be Jorge's)

**Buck's Aha Moment (Lines 117-124):**
- "Security on Autopilot" (1 hour)
- Security testing journey (pre-commit, bypass attempts, secret scanning)
- **NOTE:** Jorge clarified aha moment should be "engineering delivery", NOT security

---

## Ambiguities / Questions

**GitHub Account Requirement:**
- PRD explicitly states jorge-at-sf requirement (Lines 565-569)
- Consistent with Functional Requirements FR-7.1.4
- ✅ No conflict

**Skill Count:**
- PRD says 26 operational skills (18 BMAD + 5 adapted + 3 custom)
- Consistent across all documents
- ✅ No conflict

**Feature Count:**
- PRD says 28 functional requirements
- Consistent with Functional Requirements document
- ✅ No conflict

**Buck's Role & Aha Moment (CONFLICT WITH JORGE'S GUIDANCE):**
- **PRD Buck's Role (Lines 291-307):** Includes compliance
- **Jorge's Clarification:** Compliance should be Jorge's (VP AI-SecOps), NOT Buck's
- **PRD Buck's Aha Moment (Lines 117-124):** "Security on Autopilot" (security testing)
- **Jorge's Clarification:** Aha moment should be "engineering delivery", NOT security
- **Security Testing Journey:** Should be Jorge's journey (SecOps), NOT Buck's
- 🔥 **CRITICAL CONFLICT:** PRD needs update to reflect Jorge's role clarifications

**Timeline Terminology:**
- PRD consistently says "5 days" (Days 1-5)
- Earlier confusion about "3 days" appears resolved
- ✅ No conflict

---

## Related Documents
- Created Feb 10-13 (multi-day consolidation process)
- Consolidates: 9 supporting sub-documents
- References: Product Brief, Architecture, BMAD Skill Mapping, Action Plan, Autonomous Workflow Guide
- Referenced by: UX Design Specification (created Feb 14 AFTER PRD)
- Provides: Complete requirements for autonomous agent implementation
