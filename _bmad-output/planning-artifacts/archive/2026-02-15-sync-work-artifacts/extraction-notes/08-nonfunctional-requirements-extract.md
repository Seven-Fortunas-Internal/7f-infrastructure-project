# Extract: Non-Functional Requirements Detailed

**Source:** `prd/nonfunctional-requirements-detailed.md`
**Date:** Not specified (part of PRD created Feb 13)
**Size:** 509 lines
**Author:** Part of PRD by Mary with Jorge

---

## Document Metadata
- **Purpose:** Define HOW WELL the system must perform (not WHAT it must do)
- **Format:** Quantitative requirements with specific measurements
- **Categories:** Security (MOST CRITICAL), Performance, Scalability, Reliability, Maintainability, Integration, Accessibility

---

## Key Content Summary

### Security - MOST CRITICAL (Non-Negotiable) (Lines 7-116)

**Context:** Buck's aha moment ("Security on Autopilot") depends on security working flawlessly. Highest priority NFR.

**NFR-SEC-1: Secret Detection & Prevention**
- **Requirement:** 100% detection rate for secrets
- **Criteria:**
  - Pre-commit hooks catch 100% of API keys/tokens/passwords/private keys
  - GitHub scanning catches bypassed commits within 5 minutes
  - Dual-layer protection cannot be bypassed
  - False positive rate <5% (avoid alert fatigue)
- **Measurement:** Buck's adversarial tests (commit secret → BLOCKED, bypass with --no-verify → BLOCKED, Base64-encoded → CAUGHT)

**NFR-SEC-2: Vulnerability Management**
- **Requirement:** Detect and remediate within defined SLAs
- **Criteria:**
  - Dependabot on 100% of repositories
  - Critical: 24 hours, High: 7 days, Medium/Low: next sprint
  - Dependabot PR merge rate >80% within SLA
- **Measurement:** Dependabot alert dashboard, time-to-patch metrics, audit trail

**NFR-SEC-3: Access Control & Authentication**
- **Requirement:** Enforce principle of least privilege with auditable access control
- **Criteria:**
  - 2FA required for 100% of members
  - Team-based permissions (Leadership=Owner, Engineering=Maintain, Others=Write)
  - Branch protection prevents force-push (100% enforcement)
  - Audit log captures 100% of access changes
- **Measurement:** Attempt to disable 2FA → BLOCKED, unauthorized access → DENIED, audit log query completeness

**NFR-SEC-4: Code Security**
- **Requirement:** Detect OWASP Top 10 vulnerabilities before merge
- **Criteria:**
  - CodeQL on all security-sensitive repos
  - Critical vulnerabilities block PR merge
  - Remediation guidance provided (CWE link, fix suggestion, best practices)
  - Findings dashboard by severity
- **Measurement:** Test vulnerability → DETECTED, PR with critical → BLOCKED, remediation guidance actionable

**NFR-SEC-5: SOC 2 Control Tracking & Evidence Automation (Phase 1.5)**
- **Requirement:** Track GitHub security controls in CISO Assistant with automated evidence collection
- **Criteria:**
  - Control mapping (GitHub branch protection → SOC 2 CC6.1, secret scanning → CC6.6, 2FA → CC6.1, Dependabot → CC7.1, audit logs → CC7.2)
  - Evidence collection: GitHub API → CISO Assistant daily sync
  - Compliance dashboard: Real-time control posture visibility
  - Continuous compliance: Control drift detection, quarterly reviews, audit-ready evidence
- **Measurement (Phase 1.5):** CISO Assistant deployed, controls mapped, evidence collection automated, compliance dashboard functional, drift alert tested
- **MVP Preparation:** Document controls implemented, identify CISO Assistant migration requirements, design control mapping strategy

---

### Performance (Lines 118-172)

**Context:** User-facing operations must feel responsive. Autonomous agent must complete within 5-day timeline.

**NFR-PERF-1: Interactive Response Time**
- **Requirement:** User operations complete within 2 seconds for 95th percentile
- **Criteria:** Skill invocation <2s, GitHub API queries <2s, Voice input <3s, Profile load <1s
- **Measurement:** Performance testing during MVP, user feedback ("feels responsive"), latency metrics (p50, p95, p99)

**NFR-PERF-2: Dashboard Auto-Update**
- **Requirement:** Dashboard updates complete within 10 minutes per cycle
- **Criteria:** RSS <2min, GitHub <2min, Reddit <3min, Claude <5min, Total <10min
- **Measurement:** GitHub Actions workflow duration, alert if exceeds threshold, graceful degradation if API fails

**NFR-PERF-3: Autonomous Agent Efficiency**
- **Requirement:** 60-70% of MVP features (18-25) complete within 24-48 hours
- **Criteria:** <30min average per feature, 30min timeout max, <5min testing, no feature >3 attempts
- **Measurement:** feature_list.json shows 18-25 "pass", claude-progress.txt logs completion rate, timeline validation

---

### Scalability (Lines 174-228)

**Context:** Infrastructure must support 4 founders → 10-20 → 50+ without architectural changes.

**NFR-SCALE-1: Team Growth**
- **Requirement:** Support 10x growth (4 → 50 users) with <10% performance degradation
- **Criteria:** GitHub operations maintain performance, Second Brain searchable to 1000+ docs, Dashboard unaffected by team size, BMAD skills stateless
- **Measurement:** Baseline at 4 users (MVP), re-test at 10 (Month 1-3), re-test at 50 (Month 6-12), <10% degradation at each milestone

**NFR-SCALE-2: Repository & Workflow Growth**
- **Requirement:** Support 100+ repositories and 200+ GitHub Actions workflows
- **Criteria:** Repo creation <5min via template, Monitor Actions minutes (upgrade at 80%), Dashboard scales to 6+ active, BMAD scales to 50+ custom skills
- **Measurement:** Repo count 10 (MVP) → 50 (Phase 2) → 100+ (Phase 3), Actions minutes tracking, workflow execution time consistency

**NFR-SCALE-3: Data Growth**
- **Requirement:** Dashboard supports 12+ months historical analysis without degradation
- **Criteria:** Data in Git (markdown), 12+ months retention, Search <5s full-text, Data export (CSV/JSON)
- **Measurement:** Test search at 3/6/12 months, storage usage monitored, alert if approaching GitHub limits

---

### Reliability (Lines 230-284)

**Context:** Automated workflows must run without silent failures. Dashboards auto-update reliably. Autonomous agent completes with minimal issues (Jorge's aha moment).

**NFR-REL-1: Workflow Reliability**
- **Requirement:** 99% success rate for scheduled jobs
- **Criteria:** Dashboard auto-update 99% success, Weekly summary 100% success, Security scanning 100% success, Notification within 5min on failure
- **Measurement:** Success rate = Successful runs / Total runs, Alert response time, Root cause analysis for >1% failures

**NFR-REL-2: Graceful Degradation**
- **Requirement:** Continue operating at reduced capacity when external dependencies fail
- **Criteria:** Dashboard without Reddit = 80% functionality, Voice input fallback to typing = 100% functionality, BMAD without submodule = 70% functionality, No complete system failure from single dependency
- **Measurement:** Simulate API failures, verify remaining sources work, user can complete workflows

**NFR-REL-3: Disaster Recovery**
- **Requirement:** Fully restorable from Git history within 1 hour
- **Criteria:** All infrastructure as code, 100% config backed up, Documented recovery procedures, RTO: 1 hour, RPO: Last Git commit
- **Measurement:** Disaster recovery drill (delete → restore → verify), RTO test, documentation test (new team member can follow)

---

### Maintainability (Lines 286-398)

**Context:** Infrastructure must be sustainable long-term without Jorge as bottleneck. Self-documenting architecture.

**NFR-MAINT-1: Self-Documenting Architecture**
- **Requirement:** Comprehensible to new team members within 2 hours
- **Criteria:** Every repo has comprehensive README.md, CLAUDE.md explains everything, Architecture docs up-to-date, 100% documented in Second Brain
- **Measurement:** Onboarding <2 hours, Documentation completeness (<5 TODOs), Knowledge gap test (can find answer in docs)

**NFR-MAINT-2: Consistent Patterns**
- **Requirement:** Consistent structure and naming across all repositories
- **Criteria:** Repository naming convention, File structure (all follow template), Workflow naming pattern, Code style (language-appropriate linters)
- **Measurement:** Audit repos for compliance, 0 naming violations, workflow consistency

**NFR-MAINT-3: Minimal Custom Code**
- **Requirement:** Leverage existing libraries to minimize custom code maintenance
- **Criteria:** 18 BMAD skills (community maintained), 5 adapted skills (10 hours), 3 custom skills (12 hours), Dependabot automates 90%+ maintenance
- **Measurement:** <5,000 lines custom code, <2 hours/week maintenance, >80% Dependabot PR merge rate

**NFR-MAINT-4: Clear Ownership**
- **Requirement:** Every component has documented maintainer and escalation path
- **Criteria:** CODEOWNERS file in all repos, Workflow comments specify owner, Skills have `author` metadata, CLAUDE.md documents escalation
- **Measurement:** 100% repos have CODEOWNERS, Escalation test (new team knows who to contact), Bus factor >2 for critical systems

**NFR-MAINT-5: Skill Governance & Lifecycle Management**
- **Requirement:** Prevent skill proliferation through intelligent management
- **Criteria:**
  - **Skill Creation Governance:** Search existing before creating, >80% overlap = suggest enhancement, <80% = approve new
  - **Skill Organization:** Categorized library, tier classification (1/2/3), discoverable via `/bmad-help`
  - **Skill Lifecycle:** Usage tracking, stale detection (0 usage in 90 days), quarterly review, deprecation process
  - **RBAC-Like Permissions (Phase 1.5):** Tier 1 operations require skills (blocked from manual), Tier 2 encouraged, Tier 3 optional
- **Measurement:** skill-creator searches before creating, enhancement suggested at >80% overlap, all skills categorized/tiered, usage tracking functional, stale skill reports, RBAC enforcement tested (Phase 1.5)
- **MVP Focus:** Categorization, tier classification, enhanced skill-creator, usage tracking foundation
- **Phase 1.5 Addition:** RBAC-like permissions, quarterly stale review automation

---

### Integration (Lines 400-454)

**Context:** System integrates with GitHub, BMAD, Claude API, OpenAI Whisper, dashboard data sources.

**NFR-INT-1: API Rate Limit Compliance**
- **Requirement:** Respect all external API rate limits to avoid disruption
- **Criteria:** GitHub <5K requests/hour, Reddit <60 requests/minute, Claude <50 calls/day, Whisper <100 transcriptions/hour
- **Measurement:** API usage monitoring, alert at >80% of limit, graceful 429 handling (retry with exponential backoff)

**NFR-INT-2: External Dependency Resilience**
- **Requirement:** Handle external API failures without data loss or user disruption
- **Criteria:** Retry logic (max 3 with exponential backoff: 5s, 15s, 45s), Error logging with context, Clear user notifications, Data persistence (queue for retry)
- **Measurement:** API failure test (simulate outage → retries → succeeds), error message clarity, 0 data loss

**NFR-INT-3: Backward Compatibility**
- **Requirement:** Maintain backward compatibility for 1+ year when updating dependencies
- **Criteria:** BMAD pinned to v6.0.0, Claude API stable version (not beta), GitHub API 6+ months before EOL migration, Whisper stable models
- **Measurement:** Dependency update test (upgrade → verify all works), 0 breaking changes per year, deprecation monitoring (alert 6 months before EOL)

---

### Accessibility (Limited Scope for MVP) (Lines 456-491)

**Context:** CLI barrier accepted for MVP. Improved in Phase 2 (Codespaces, web). Focus on comprehensive docs/onboarding.

**NFR-ACCESS-1: CLI Accessibility**
- **Requirement:** Comprehensive documentation and onboarding to minimize CLI barrier
- **Criteria:** Step-by-step tutorial, Clear error messages, `/bmad-help` command, Optional video tutorials
- **Measurement:** Non-developer onboarding <4 hours (2x developer time), >90% completion rate, feedback "CLI easier than expected"

**NFR-ACCESS-2: Phase 2 Accessibility Improvements (Deferred)**
- **Requirement:** Explore non-CLI options in Phase 2
- **Criteria (Phase 2):** GitHub Codespaces (terminal in browser), GitHub Discussions Bot (natural language), Web portal (if funded)
- **Measurement:** Deferred to Phase 2, user feedback informs priorities

---

## NFR Summary (Lines 492-508)

**Critical NFRs (Non-Negotiable):**
- 🔒 **Security**: 100% secret detection, vulnerability SLAs, 2FA enforcement, CodeQL scanning
- ⚡ **Performance**: <2s interactive, <10min dashboard updates, 60-70% autonomous completion
- 📈 **Scalability**: 10x user growth, 100+ repos, 12+ months data retention
- 🛡️ **Reliability**: 99% workflow success, graceful degradation, 1-hour disaster recovery
- 🔧 **Maintainability**: Self-documenting, consistent patterns, minimal custom code, clear ownership
- 🔌 **Integration**: API rate limit compliance, external dependency resilience, backward compatibility

**Acceptable Trade-offs:**
- 🌐 **Accessibility**: CLI-only for MVP (improved Phase 2) - Comprehensive docs/onboarding mitigate barrier

**All NFRs are specific, measurable, traceable to user aha moments and business success criteria.**

---

## Critical Information

**Total Non-Functional Requirements: 21 (NFR-SEC-1 through NFR-ACCESS-2)**

**Most Critical: Security (Lines 7-116)**
- Buck's aha moment depends entirely on security NFRs
- 100% secret detection is non-negotiable
- Vulnerability SLAs must be met
- SOC 2 preparation begins in MVP (full implementation Phase 1.5)

**Key Measurements:**
- Buck's adversarial tests validate security NFRs
- Performance metrics (p50, p95, p99) track responsiveness
- feature_list.json validates autonomous agent efficiency (60-70% target)
- Onboarding time (<2 hours) validates maintainability

**Phase 1.5 Additions:**
- NFR-SEC-5 full implementation: CISO Assistant integration, SOC 2 control automation
- NFR-MAINT-5 enhancement: RBAC-like permissions for AI-first enforcement

---

## Ambiguities / Questions

**None identified** - All NFRs are specific, measurable, and testable

**Important Note:** NFR-SEC-5 (SOC 2) has MVP preparation steps documented even though full implementation is Phase 1.5. This ensures foundation is ready.

---

## Related Documents
- Supports Functional Requirements (defines quality standards)
- Validates Innovation Analysis (performance/reliability of autonomous agent)
- Enables User Journeys (security = Buck's aha, performance = all aha moments)
- Traceable to Success Criteria in Product Brief
