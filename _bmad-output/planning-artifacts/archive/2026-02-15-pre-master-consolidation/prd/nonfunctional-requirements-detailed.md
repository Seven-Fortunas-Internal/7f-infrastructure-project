## Non-Functional Requirements

**Purpose:** These define HOW WELL the system must perform (not WHAT it must do). Only relevant categories for Seven Fortunas infrastructure are documented.

---

### Security (MOST CRITICAL - Non-Negotiable)

**Context:** Buck's aha moment ("Security on Autopilot") depends on security working flawlessly. This is the highest priority NFR.

#### NFR-SEC-1: Secret Detection & Prevention

**Requirement:** System SHALL prevent secrets from being committed to repositories with 100% detection rate.

**Specific Criteria:**
- Pre-commit hooks (detect-secrets) catch 100% of API keys, tokens, passwords, private keys
- GitHub secret scanning catches bypassed commits within 5 minutes
- Dual-layer protection (local + server-side) cannot be bypassed
- False positive rate < 5% (to avoid alert fatigue)

**Measurement:**
- Buck's adversarial test: Attempt to commit secret → BLOCKED
- Buck's bypass test: Use `--no-verify` → BLOCKED by GitHub Actions
- Buck's obfuscation test: Base64-encoded secret → CAUGHT by GitHub scanning

---

#### NFR-SEC-2: Vulnerability Management

**Requirement:** System SHALL detect and remediate vulnerabilities within defined SLAs.

**Specific Criteria:**
- Dependabot enabled on 100% of repositories
- Critical vulnerabilities patched within 24 hours
- High vulnerabilities patched within 7 days
- Medium/Low vulnerabilities patched in next sprint
- Dependabot PR merge rate >80% within SLA

**Measurement:**
- Dependabot alert count by severity (dashboard)
- Time-to-patch metrics (alert creation → PR merged)
- Audit trail: All security patches documented

---

#### NFR-SEC-3: Access Control & Authentication

**Requirement:** System SHALL enforce principle of least privilege with auditable access control.

**Specific Criteria:**
- 2FA required for 100% of organization members
- Team-based permissions (Leadership=Owner, Engineering=Maintain, Others=Write)
- Branch protection prevents force-push to main (100% enforcement)
- Audit log captures 100% of access changes, permission modifications, repo operations

**Measurement:**
- Attempt to disable 2FA → BLOCKED
- Unauthorized access attempt → DENIED (tested)
- Audit log query: "All permission changes in last 30 days" → Complete results

---

#### NFR-SEC-4: Code Security

**Requirement:** System SHALL detect OWASP Top 10 vulnerabilities before merge.

**Specific Criteria:**
- CodeQL enabled on all security-sensitive repos
- Critical vulnerabilities block PR merge
- Remediation guidance provided (link to CWE, suggest fix, reference best practices)
- Findings dashboard shows open issues by severity

**Measurement:**
- Test vulnerability introduced → DETECTED by CodeQL
- PR with critical vulnerability → BLOCKED from merge
- Remediation guidance clear and actionable (tested)

---

#### NFR-SEC-5: SOC 2 Control Tracking & Evidence Automation (Phase 1.5)

**Requirement:** System SHALL track GitHub security controls in CISO Assistant with automated evidence collection.

**Specific Criteria:**
- **Control Mapping (Phase 1.5):**
  - GitHub branch protection → SOC 2 CC6.1 (Logical and Physical Access Controls)
  - Secret scanning → SOC 2 CC6.6 (Vulnerability Management)
  - 2FA enforcement → SOC 2 CC6.1 (Logical and Physical Access Controls)
  - Dependabot → SOC 2 CC7.1 (System Monitoring)
  - Audit logs → SOC 2 CC7.2 (Change Management)
- **Evidence Collection (Automated):**
  - GitHub API → CISO Assistant: Daily sync of control status
  - Evidence artifacts: Audit logs, branch protection configs, security alerts
  - Compliance dashboard: Real-time control posture visibility
- **CISO Assistant Integration (Phase 1.5):**
  - Migrate CISO Assistant from personal repo to Seven-Fortunas-Internal org
  - Configure GitHub integration (API keys, webhooks)
  - Integration guide: `/7f-compliance-integration-guide` skill
- **Continuous Compliance:**
  - Control drift detection: Alert if branch protection disabled
  - Quarterly control reviews: Automated report generation
  - Audit-ready: All evidence stored, organized, accessible

**Measurement (Phase 1.5):**
- [ ] CISO Assistant deployed in Seven-Fortunas-Internal org
- [ ] GitHub controls mapped to SOC 2 requirements (documented)
- [ ] Evidence collection automated (daily sync functional)
- [ ] Compliance dashboard shows real-time control posture
- [ ] Control drift alert tested (disable branch protection → Alert within 15 minutes)

**MVP Preparation:**
- Document GitHub security controls implemented (basis for Phase 1.5 mapping)
- Identify CISO Assistant migration requirements
- Design control mapping strategy (research GitHub → SOC 2 alignment)

---

### Performance

**Context:** User-facing operations must be fast enough to feel responsive. Autonomous agent must complete infrastructure build within 5-day timeline.

#### NFR-PERF-1: Interactive Response Time

**Requirement:** User-initiated operations SHALL complete within 2 seconds for 95th percentile.

**Specific Criteria:**
- Skill invocation (e.g., `/bmad-help`) → Response within 2 seconds
- GitHub API queries (e.g., list repos) → Response within 2 seconds
- Voice input transcription (Whisper) → Response within 3 seconds
- Profile load (AI agent reads YAML) → Response within 1 second

**Measurement:**
- Performance testing during MVP validation
- User feedback: "Feels responsive" vs. "Feels sluggish"
- Latency metrics logged (p50, p95, p99)

---

#### NFR-PERF-2: Dashboard Auto-Update

**Requirement:** Dashboard data collection and updates SHALL complete within 10 minutes per cycle.

**Specific Criteria:**
- RSS feed aggregation: < 2 minutes for all sources
- GitHub releases fetch: < 2 minutes for all repos
- Reddit API calls: < 3 minutes for all subreddits
- Claude API summarization: < 5 minutes per summary
- Total cycle time: < 10 minutes (allows for 6-hour cron frequency)

**Measurement:**
- GitHub Actions workflow duration (logged)
- If any step exceeds threshold → Alert
- Graceful degradation if API fails (continue with other sources)

---

#### NFR-PERF-3: Autonomous Agent Efficiency

**Requirement:** Autonomous agent SHALL complete 60-70% of MVP features (18-25 features) within 24-48 hours.

**Specific Criteria:**
- Feature implementation: < 30 minutes per feature (average)
- Bounded retry timeout: 30 minutes per feature (max)
- Testing time: < 5 minutes per feature
- No feature has >3 retry attempts (agent moves on)

**Measurement:**
- feature_list.json shows 18-25 "pass" status
- claude-progress.txt logs completion rate
- Timeline: Day 1-2 complete (autonomous), Day 3-5 refinement (human)

---

### Scalability

**Context:** Infrastructure must support 4 founders → 10-20 team members → 50+ without architectural changes.

#### NFR-SCALE-1: Team Growth

**Requirement:** System SHALL support 10x user growth (4 → 50 users) without performance degradation >10%.

**Specific Criteria:**
- GitHub operations (clone, push, PR) maintain performance with 50+ users
- Second Brain searchability scales to 1000+ documents
- Dashboard data collection unaffected by team size (data sources are external)
- BMAD skills performance independent of team size (stateless)

**Measurement:**
- Baseline performance with 4 users (MVP)
- Re-test with 10 users (Month 1-3)
- Re-test with 50 users (Month 6-12)
- Performance degradation < 10% at each milestone

---

#### NFR-SCALE-2: Repository & Workflow Growth

**Requirement:** System SHALL support 100+ repositories and 200+ GitHub Actions workflows without operational issues.

**Specific Criteria:**
- Repository creation time: < 5 minutes per repo (via template)
- GitHub Actions minutes: Monitor usage, upgrade tier if >80% consumed
- Dashboard scales to 6+ active dashboards (Phase 3)
- BMAD library scales to 50+ custom skills (Phase 3)

**Measurement:**
- Repo count: 10 (MVP) → 50 (Phase 2) → 100+ (Phase 3)
- Actions minutes usage: Track monthly, alert at 80%
- Workflow execution time remains consistent as count grows

---

#### NFR-SCALE-3: Data Growth

**Requirement:** Dashboard data SHALL support 12+ months of historical analysis without performance degradation.

**Specific Criteria:**
- Dashboard data stored in Git (markdown files)
- Data retention: 12+ months (unlimited storage, GitHub free tier)
- Search performance: < 5 seconds for full-text search across all data
- Data export: Support CSV/JSON export for external analysis

**Measurement:**
- Data collection starts MVP (Month 1)
- Test search performance at 3 months, 6 months, 12 months
- Storage usage monitored (alert if approaching GitHub limits)

---

### Reliability

**Context:** Automated workflows must run without silent failures. Dashboards must auto-update reliably. Autonomous agent must complete with minimal issues (Jorge's aha moment).

#### NFR-REL-1: Workflow Reliability

**Requirement:** GitHub Actions workflows SHALL have 99% success rate for scheduled jobs.

**Specific Criteria:**
- Dashboard auto-update (every 6 hours) → 99% success rate
- Weekly AI summary (Sundays) → 100% success rate (critical for leadership)
- Security scanning (every push) → 100% success rate (non-negotiable)
- Notification on failure: Slack/email within 5 minutes

**Measurement:**
- Workflow success rate: Successful runs / Total runs
- Alert response time: Failure detected → Team notified
- Root cause analysis for failures >1% threshold

---

#### NFR-REL-2: Graceful Degradation

**Requirement:** System SHALL continue operating at reduced capacity when external dependencies fail.

**Specific Criteria:**
- Dashboard: If Reddit API fails, continue with RSS and GitHub sources (80% functionality)
- Voice input: If Whisper fails, fallback to manual typing (100% functionality, lower UX)
- BMAD skills: If submodule unavailable, fallback to core skills (70% functionality)
- No complete system failure from single dependency outage

**Measurement:**
- Simulate API failures (kill Reddit API)
- Verify dashboard updates with remaining sources
- User can still complete workflows (may be slower/less convenient)

---

#### NFR-REL-3: Disaster Recovery

**Requirement:** System SHALL be fully restorable from Git history within 1 hour.

**Specific Criteria:**
- All infrastructure as code (Git)
- Configuration backed up in Git (100% coverage)
- Documented recovery procedures (CLAUDE.md, README.md)
- Recovery time objective (RTO): 1 hour
- Recovery point objective (RPO): Last Git commit (minutes)

**Measurement:**
- Disaster recovery drill: Delete repo → Restore from backup → Verify functionality
- RTO test: Time from incident detection to full restoration
- Documentation test: Can new team member follow recovery procedures?

---

### Maintainability

**Context:** Infrastructure must be sustainable long-term without Jorge as bottleneck. Self-documenting architecture.

#### NFR-MAINT-1: Self-Documenting Architecture

**Requirement:** System SHALL be comprehensible to new team members within 2 hours.

**Specific Criteria:**
- Every repo has comprehensive README.md (purpose, setup, usage)
- CLAUDE.md explains how everything works (agent instructions)
- Architecture documentation (ADRs, technical specs) up-to-date
- No tribal knowledge (100% documented in Second Brain)

**Measurement:**
- Onboarding test: New team member (no prior context) completes onboarding in < 2 hours
- Documentation completeness: Grep for "TODO", "FIXME" → < 5 instances
- Knowledge gap test: Ask team member "How does X work?" → Can find answer in docs

---

#### NFR-MAINT-2: Consistent Patterns

**Requirement:** System SHALL use consistent structure and naming conventions across all repositories.

**Specific Criteria:**
- Repository naming: `{Org}-{Domain}-{Component}` (consistent)
- File structure: All repos follow template (CLAUDE.md, README, .gitignore, LICENSE)
- Workflow naming: `{action}-{target}.yml` (e.g., `update-ai-dashboard.yml`)
- Code style: Language-appropriate linters (ESLint for JS, Black for Python)

**Measurement:**
- Audit all repos for pattern compliance
- Naming convention violations: 0 (enforced by templates)
- Workflow consistency: All follow same structure

---

#### NFR-MAINT-3: Minimal Custom Code

**Requirement:** System SHALL leverage existing libraries and frameworks to minimize custom code maintenance.

**Specific Criteria:**
- BMAD library: 18 skills (maintained by community, not Seven Fortunas)
- Adapted skills: 5 skills (minimal customization, 10 hours total)
- Custom code: 3 skills only (12 hours total)
- Dependency updates: Dependabot automates 90%+ of maintenance

**Measurement:**
- Lines of custom code: < 5,000 (minimal surface area)
- Maintenance burden: < 2 hours/week for routine updates
- Dependabot PR merge rate: >80% (automation working)

---

#### NFR-MAINT-4: Clear Ownership

**Requirement:** Every system component SHALL have documented maintainer and escalation path.

**Specific Criteria:**
- Repository: CODEOWNERS file specifies maintainers
- Workflows: Comments specify owner (e.g., `# Owner: Jorge, AI Dashboard automation`)
- Skills: Skill metadata includes `author` field
- Escalation: CLAUDE.md documents "If X fails, contact Y"

**Measurement:**
- Ownership completeness: 100% of repos have CODEOWNERS
- Escalation test: New team member knows who to contact for each system
- Bus factor: >2 people can maintain critical systems

---

#### NFR-MAINT-5: Skill Governance & Lifecycle Management

**Requirement:** System SHALL prevent skill proliferation through intelligent skill management.

**Specific Criteria:**
- **Skill Creation Governance:**
  - `skill-creator` searches existing skills BEFORE creating new
  - If >80% capability overlap → Suggest enhancement
  - If <80% overlap → Approve new skill creation
  - Enhancement rationale documented in skill metadata
- **Skill Organization:**
  - Categorized library (Infrastructure, Security, Compliance, Content, Development, Management)
  - Tier classification (Tier 1: Production, Tier 2: Beta, Tier 3: Experimental)
  - Discoverable via `/bmad-help` (category + tier filters)
- **Skill Lifecycle:**
  - Usage tracking: Increment counter on each invocation
  - Stale detection: Flag skills with 0 usage in 90 days
  - Quarterly review: Deprecate or enhance stale skills
  - Deprecation process: Mark as deprecated → Archive after 1 quarter of 0 usage
- **RBAC-Like Permissions (Phase 1.5):**
  - Tier 1 operations: Some require skills (blocked from manual UI)
  - Tier 2 operations: Skills encouraged (manual UI discouraged)
  - Tier 3 operations: Skills optional (experimental, use with caution)

**Measurement:**
- [ ] `skill-creator` searches existing before creating (test with duplicate request)
- [ ] Enhancement suggested when >80% overlap (test with similar skill)
- [ ] All skills categorized and tiered (catalog audit)
- [ ] Usage tracking functional (mock invocations logged)
- [ ] Stale skill report generated (quarterly automated report)
- [ ] RBAC enforcement tested (Phase 1.5: manual Tier 1 operation → Blocked or flagged)

**MVP Focus:**
- Skill categorization and tier classification
- Enhanced `skill-creator` with search capability
- Usage tracking foundation

**Phase 1.5 Addition:**
- RBAC-like permissions for AI-first enforcement
- Quarterly stale skill review automation

---

### Integration

**Context:** System integrates with GitHub, BMAD, Claude API, OpenAI Whisper, dashboard data sources.

#### NFR-INT-1: API Rate Limit Compliance

**Requirement:** System SHALL respect all external API rate limits to avoid service disruption.

**Specific Criteria:**
- GitHub API: < 5,000 requests/hour (stay under 5,000 limit)
- Reddit API: 60 requests/minute (stay under 100 limit)
- Claude API: < 50 API calls/day (within budget cap)
- OpenAI Whisper API: < 100 transcriptions/hour (reasonable usage)

**Measurement:**
- API usage monitoring (log all API calls)
- Alert if usage >80% of limit
- Graceful handling of 429 (rate limit) responses (retry with exponential backoff)

---

#### NFR-INT-2: External Dependency Resilience

**Requirement:** System SHALL handle external API failures without data loss or user disruption.

**Specific Criteria:**
- Retry logic: Max 3 attempts with exponential backoff (5s, 15s, 45s)
- Error logging: All API failures logged with context (which API, error code, timestamp)
- User notification: If user-initiated action fails, show clear error message with guidance
- Data persistence: No data loss from transient API failures (queue for retry)

**Measurement:**
- API failure test: Simulate API outage → System retries → Succeeds on recovery
- Error message clarity: User understands what failed and what to do
- Data loss: 0 instances from API failures

---

#### NFR-INT-3: Backward Compatibility

**Requirement:** System SHALL maintain backward compatibility for 1+ year when updating dependencies.

**Specific Criteria:**
- BMAD library: Pinned to v6.0.0 (no surprise breaking changes)
- Claude API: Use stable API version (not beta)
- GitHub API: Monitor deprecation notices, migrate 6+ months before EOL
- OpenAI Whisper: Use stable model versions

**Measurement:**
- Dependency update test: Upgrade BMAD → Verify all skills still work
- Breaking change count: 0 per year (proactive migration)
- Deprecation monitoring: Alert 6 months before EOL

---

### Accessibility (Limited Scope for MVP)

**Context:** CLI barrier accepted for MVP. Improved in Phase 2 (Codespaces, web alternatives). Focus on comprehensive documentation and onboarding for CLI users.

#### NFR-ACCESS-1: CLI Accessibility

**Requirement:** System SHALL provide comprehensive documentation and onboarding to minimize CLI barrier.

**Specific Criteria:**
- Onboarding tutorial: Step-by-step guide for CLI installation and usage
- Error messages: Clear guidance on fixing issues (not cryptic terminal errors)
- `/bmad-help` command: Discover available skills without reading docs
- Video tutorials: Optional for non-developers (screen recording of common workflows)

**Measurement:**
- Non-developer onboarding time: < 4 hours (double developer time)
- Onboarding completion rate: >90% (few drop out due to CLI barrier)
- Feedback: "CLI was easier than expected" (post-onboarding survey)

---

#### NFR-ACCESS-2: Phase 2 Accessibility Improvements (Deferred)

**Requirement:** System SHALL explore non-CLI access options in Phase 2 for non-developers.

**Specific Criteria (Phase 2 scope):**
- GitHub Codespaces: Terminal in browser (no local CLI required)
- GitHub Discussions Bot: Invoke skills via natural language comments (lower fidelity)
- Web portal (if funded): Browser-based UI for skill invocation (highest UX)

**Measurement:**
- Deferred to Phase 2 (not MVP)
- User feedback: "Would you prefer web UI over CLI?" (inform Phase 2 priorities)

---

### Non-Functional Requirements Summary

**Critical NFRs (Non-Negotiable):**
- 🔒 **Security**: 100% secret detection, vulnerability SLAs, 2FA enforcement, CodeQL scanning
- ⚡ **Performance**: < 2s interactive response, < 10min dashboard updates, 60-70% autonomous completion
- 📈 **Scalability**: 10x user growth, 100+ repos, 12+ months data retention
- 🛡️ **Reliability**: 99% workflow success rate, graceful degradation, 1-hour disaster recovery
- 🔧 **Maintainability**: Self-documenting, consistent patterns, minimal custom code, clear ownership
- 🔌 **Integration**: API rate limit compliance, external dependency resilience, backward compatibility

**Acceptable Trade-offs:**
- 🌐 **Accessibility**: CLI-only for MVP (improved Phase 2) - Comprehensive docs/onboarding mitigate barrier

**All NFRs are specific, measurable, and traceable to user aha moments and business success criteria.**

---

