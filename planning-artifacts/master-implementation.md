---
title: Implementation Guide Master Document
type: Master Document (5 of 6)
sources: [action-plan-mvp-2026-02-10.md, autonomous-workflow-guide-7f-infrastructure.md, manual-testing-plan.md]
date: 2026-02-15
author: Mary (Business Analyst) with Jorge
status: Phase 2 - Master Consolidation
version: 1.6.0
role-corrections: ✅ Buck's aha moment test corrected (engineering delivery), Jorge's security testing added
editorial-review: Complete (structure + prose + adversarial, 2026-02-15)
phase-2-additions: GitHub Discussions setup added to Day 0 (2026-02-15)
---

# Implementation Guide Master Document

## Execution Strategy

**Approach:** Autonomous-first (60-70% automated Days 1-2) + Human refinement (Days 3-5)
**Agent:** Claude Code SDK with two-agent pattern (initializer + coding)
**Success Target:** 18-25 of 28 features "pass" status by end of Day 2
**Testing Philosophy:** Agent-first testing (automated) before human testing

---

## Timeline: 5-7 Day MVP (Days 0-5 baseline + buffer)

**Realistic Assessment:** 5-day timeline is BASELINE assuming no issues. Realistic delivery: 5-7 days with buffer for debugging, blocked features, and founder availability constraints.

**Built-In Buffer by Phase:**
- Day 0: 8h planned + 2h buffer (25% contingency) = 10h total
- Days 1-2: 40h autonomous work + 8h monitoring/intervention = 48h total
- Day 3: 6h aha moment validation + 2h retry/debugging = 8h total
- Days 4-5: 16h polish/demo + 4h final fixes = 20h total
- **Total: 86 hours with buffer vs 70 hours baseline (23% contingency)**

### Day 0: Foundation & BMAD Deployment (Jorge, 8-9 hours planned + 2h buffer = 10-11h total)

**Prerequisites Validation (30 min):**
- Run `./scripts/validate_environment.sh` to check all prerequisites
- Checks: Python 3.11+, Claude Code CLI installed, Git configured, gh CLI authenticated
- Exits with error code if any prerequisite missing
- Output: `environment_validation_report.txt`
- Script implementation: See `/scripts/validate_environment.sh` (to be created Day 0)

**1. BMAD v6.0.0 Installation (1 hour):**
```bash
git submodule add https://github.com/bmad-dev/bmad.git _bmad
git submodule update --init --recursive
cd _bmad && git checkout v6.0.0
cd .. && git add _bmad && git commit -m "Add BMAD v6.0.0 as submodule"
```

**2. Skill Stubs Creation (2 hours):**
```bash
./scripts/create_skill_stubs.sh
# Creates 18 BMAD skill stubs in .claude/commands/
# Validates each stub references correct workflow path
# Output: skill_stubs_validation_report.txt
```

**3. GitHub CLI Authentication Verification (30 min) - CRITICAL:**
- Run `./scripts/validate_github_auth.sh` to verify correct GitHub account
- Checks: `gh auth status -h` (host check, not grep parsing which is brittle)
- Verifies authenticated as jorge-at-sf (correct account)
- Exit 0 if correct, Exit 1 with error message if wrong account or not authenticated
- Blocks all GitHub operations if validation fails (pre-flight safety check)
- Logs: `github_auth_validation.log`
- Script implementation: See `/scripts/validate_github_auth.sh` (to be created Day 0)

**4. Autonomous Agent Scripts Setup (2 hours):**
```bash
./scripts/setup_autonomous_agent.sh
# Creates: run_autonomous_continuous.sh, agent_config.yaml, logging setup
# Validates: Claude API key, GitHub token, script permissions
# Output: agent_setup_validation_report.txt
```

**5. app_spec.txt Generation from PRD (2 hours):**
```bash
./scripts/generate_app_spec.sh _bmad-output/planning-artifacts/master-requirements.md
# Process:
#   1. Extracts all 28 FRs from master-requirements.md (FR-1.1 to FR-7.5)
#   2. For each FR: feature_id, title, description, acceptance_criteria, priority
#   3. Generates app_spec.txt in Claude Code agent format
#   4. Validates: all 28 features present, required fields populated, syntax valid
# Output: app_spec.txt (input for autonomous agent)
# Validation: ./scripts/validate_app_spec.sh app_spec.txt
```

**6. GitHub Discussions Setup (10-15 min) - MVP Communication:**
```bash
# Verify repo exists and user has admin permissions
gh repo view Seven-Fortunas-Internal/7f-infrastructure-project || echo "Error: Repo not found or no access"

# Enable Discussions on infrastructure-project repo
gh repo edit Seven-Fortunas-Internal/7f-infrastructure-project --enable-discussions

# Create discussion categories via GitHub web UI (manual for MVP):
# Navigate to: repo Settings → Features → Discussions → Categories
# Create 3 categories (extensible, add more as needed):
# - Announcements (team updates and releases)
# - Ideas (feature requests, brainstorming)
# - Q&A (technical questions, how-to guides)
# Note: Sprint Planning category deferred to Phase 2 when sprint management (FR-8.1) is implemented

# Verify Discussions enabled
gh api repos/Seven-Fortunas-Internal/7f-infrastructure-project | jq -r '.has_discussions'
# Expected output: true (string, not JSON boolean)
```

**Day 0 Success Criteria:**
- Environment validation passes (all prerequisites met)
- GitHub CLI authenticated as jorge-at-sf (validated by script)
- 18 BMAD skill stubs created and validated
- app_spec.txt generated with all 28 features (validation passes)
- Autonomous agent scripts executable and configured
- GitHub Discussions enabled with 3 categories created (Announcements, Ideas, Q&A - verified via API check returning true)

**Day 0 Rollback Procedures (If Critical Failure):**
- **BMAD submodule issue:** Remove submodule (`git submodule deinit _bmad && git rm _bmad`), re-add with correct version
- **Skill stubs corrupted:** Delete `.claude/commands/bmad-*.md`, re-run `./scripts/create_skill_stubs.sh`
- **app_spec.txt invalid:** Regenerate from master-requirements.md using `./scripts/generate_app_spec.sh`
- **GitHub Discussions errors:** Disable discussions (`gh repo edit --disable-discussions`), retry or defer to manual setup
- **Wrong GitHub account:** Logout (`gh auth logout`), re-authenticate with correct account
- **Full Day 0 rollback:** Reset repo to pre-Day-0 commit (`git reset --hard <commit-sha>`), restart Day 0 from scratch

### Days 1-2: Autonomous Agent Build (60-70% Completion)
**Target:** 18-25 of 28 features completed

**Agent Workflow:**
1. Initialize from app_spec.txt
2. Create feature_list.json (28 features with status tracking - see schema below)
3. For each feature:
   - Attempt implementation
   - Run tests (unit, integration, manual validation)
   - Mark "pass" ONLY if ALL pass criteria met (see below)
   - Retry up to 3 times if fail
   - Mark "blocked" after 3 failures, log detailed reason, continue to next
4. Update progress (feature_list.json, claude-progress.txt, autonomous_build_log.md)

**feature_list.json Schema:**
```json
{
  "features": [
    {
      "id": "FR-1.1",
      "name": "Create GitHub Organizations",
      "status": "pending | in_progress | pass | blocked",
      "attempt": 1,
      "start_time": "2026-02-15T10:00:00Z",
      "end_time": "2026-02-15T10:15:00Z",
      "duration_seconds": 900,
      "tests": {
        "unit": "pass | fail | skipped",
        "integration": "pass | fail | skipped",
        "manual_validation": "pass | fail | pending"
      },
      "pass_criteria_met": {
        "code_complete": true,
        "tests_passing": true,
        "documented": true,
        "validated": false
      },
      "blocking_reason": null,
      "retry_history": []
    }
  ],
  "summary": {
    "total": 28,
    "pending": 10,
    "in_progress": 1,
    "pass": 15,
    "blocked": 2
  }
}
```

**"Pass" Status Criteria (ALL 4 must be met, aligns with JSON schema fields):**
1. **Code Complete:** Feature implementation finished, no TODO comments in critical paths
2. **Tests Passing:** Unit tests pass (if applicable), integration tests pass (if applicable)
3. **Documented:** README updated, comments added for complex logic, ADR created (if architectural decision)
4. **Validated:** Manual validation confirms feature works as expected (human smoke test)

Note: JSON schema has 4 boolean fields (code_complete, tests_passing, documented, validated) - criterion 5 "No Critical Errors" is implicit in all 4 checks

**"Blocked" Status Criteria (Mark after 3 attempts if ANY apply):**
1. Requirement ambiguous or contradictory (needs human clarification)
2. External dependency unavailable (API, library, service)
3. Complexity exceeds agent capability (requires human architectural decision)
4. Tests consistently fail despite 3 different approaches
5. BMAD library bug or limitation prevents implementation

**Bounded Retry Logic:**
- Attempt 1: Standard implementation
- Attempt 2: Simplified approach
- Attempt 3: Minimal viable version
- After 3 failures: Mark blocked, log reason, continue

**Progress Monitoring:**
```bash
tail -f autonomous_build_log.md
cat feature_list.json | grep status
```

### Day 3: Human Refinement & Testing

**Morning: Patrick Validates Architecture (2 hours)**
- Review architecture docs (ADRs)
- Test code review skill
- Validate security settings
- **Aha Moment:** "SW development infrastructure is well done"

**Afternoon: Buck Tests Engineering Delivery (2-3 hours)** ✅ CORRECTED
- **Operation 1 (45 min):** Deploy test microservice using infrastructure
  - Use /7f-repo-template to create test-microservice repo
  - Clone, add simple Express.js "Hello World" API
  - Push to trigger CI/CD
- **Operation 2 (30 min):** Validate CI/CD pipeline functionality
  - Verify build completes (<5 min)
  - Verify tests run automatically
  - Verify deployment to staging environment
- **Operation 3 (30 min):** Test app-level security configuration
  - Validate JWT authentication endpoint
  - Test rate limiting (send 100 requests, verify throttling)
  - Review security headers (HTTPS, CSP, X-Frame-Options)
- **Operation 4 (30 min):** Test rollback procedures
  - Deploy intentionally broken version
  - Trigger rollback to previous version
  - Verify service restored within 2 minutes
- **Aha Moment:** "Engineering infrastructure enables rapid delivery" (validated if all 4 operations complete successfully)

**Afternoon: Jorge Tests Security Controls (2 hours)** ✅ ADDED
- **Test 1 (30 min):** Commit secret → Pre-commit hook blocks
  - Create test repo, add hardcoded API key to code
  - Attempt commit → verify pre-commit hook catches and blocks
  - Verify error message is clear and actionable
- **Test 2 (30 min):** Bypass pre-commit with --no-verify
  - Commit with --no-verify flag (bypasses local hook)
  - Push to GitHub → verify GitHub Actions workflow catches secret
  - Verify push blocked with alert sent
- **Test 3 (30 min):** Base64-encoded secret
  - Encode API key in base64, commit
  - Verify GitHub secret scanning detects pattern
  - Verify push protection blocks commit
- **Test 4 (30 min):** Security dashboard review
  - Open dashboards-internal/security/
  - Review compliance posture (target: ≥99% controls passing)
  - Check Dependabot alerts (0 critical expected)
  - Review secret scanning history (all test attempts logged, 0 real secrets leaked)
- **Aha Moment:** "Security controls work. Infrastructure is protected." (validated if ≥99% detection rate across all tests)

**Evening: Henry Begins Brand Application (3 hours)**
- Run /7f-brand-system-generator
- Voice input for brand definition
- AI structures content, Henry refines 20%
- Apply branding to GitHub assets

### Days 4-5: Polish & Demo Preparation

**Day 4 Morning (3 hours):** Henry completes brand application
- Apply brand to remaining repos
- Review and refine AI-generated content
- Validate brand consistency across all assets

**Day 4 Afternoon (12-16 hours total across team):** Bug fixes, edge cases, testing
- **Jorge (6-8 hours):** Fix blocked features, debug failed tests, security validation
- **Patrick (3-4 hours):** Code review, architectural validation, ADR review
- **Buck (2-3 hours):** Engineering delivery smoke tests, CI/CD edge cases
- **Henry (1 hour):** Brand application final review

**Reality Check:** 28 features × 20-30 min/feature for review/fixes = 9-14 hours minimum effort. 12-16 hour team total realistic (distributed across 4 founders working in parallel) for catch-all debugging phase.

**Day 5 Morning (3 hours):** Final polish, documentation review
- All founders: 2 hours collaborative review
- Jorge: 1 hour final documentation pass (README updates, CHANGELOG)

**Day 5 Afternoon (2 hours):** Leadership demo
- Audience: Future leadership, potential customers, or stakeholders beyond the 4 founders
- Presenters: Henry + Patrick + Buck + Jorge
- Demo format: Live walkthrough of aha moments + Q&A

---

## Autonomous Agent Setup

### Prerequisites

**CRITICAL: Run environment validation BEFORE starting autonomous agent**

**1. Environment Validation Script (./scripts/validate_environment.sh):**
- Validates 6 prerequisites: Python 3.11+, Claude Code CLI, Git configuration, GitHub CLI auth (jorge-at-sf), ANTHROPIC_API_KEY, Python dependencies
- Exits with error code 1 if any check fails
- Provides actionable error messages with fix commands
- Full implementation: Create script in `/scripts/validate_environment.sh` during Day 0
- Key checks:
  - Python version comparison with sort -V
  - Claude CLI command availability
  - Git user.name configured
  - GitHub CLI auth status verification (use `gh auth status -h` for host check, not grep)
  - Environment variables set
  - Python anthropic, feedparser, praw imports

**2. GitHub CLI Authentication Validation Script (./scripts/validate_github_auth.sh):**
- Validates GitHub CLI authenticated as correct account (jorge-at-sf)
- CRITICAL safety check: Prevents creating orgs under wrong account
- Parses `gh auth status` to extract current account
- Exits with error and guidance if wrong account detected
- Full implementation: Create script in `/scripts/validate_github_auth.sh` during Day 0
- Recommendation: Use `gh auth status -h` for host/account extraction instead of grep parsing for reliability

**3. Manual Prerequisites Setup:**
```bash
# Install Python dependencies
pip install -r requirements.txt

# Make all scripts executable
chmod +x ./scripts/*.sh

# Verify environment
./scripts/validate_environment.sh

# If validation passes, proceed to Day 0
```

### Launch Autonomous Agent

```bash
./scripts/run_autonomous_continuous.sh
```

**What Happens (Happy Path):**
1. Initializer agent reads app_spec.txt
2. Creates feature_list.json with 28 features
3. Coding agent implements features sequentially
4. Progress logged to autonomous_build_log.md
5. Jorge monitors via `tail -f autonomous_build_log.md`

**Failure Scenarios & Recovery:**

**Scenario 1: Initializer Agent Fails to Parse app_spec.txt**
- **Symptoms:** Agent crashes immediately, no feature_list.json created
- **Diagnosis:** Check app_spec.txt syntax, validate with `./scripts/validate_app_spec.sh`
- **Recovery:** Fix app_spec.txt syntax errors, restart initializer agent
- **Prevention:** Always run validation script before launching agent

**Scenario 2: feature_list.json Syntax Error**
- **Symptoms:** Coding agent fails to start, JSON parse error in logs
- **Diagnosis:** Validate JSON with `python3 -m json.tool feature_list.json` or `jq . feature_list.json`
- **Recovery:**
  1. If corrupted: Restore from backup (`cp feature_list.json.backup feature_list.json`)
  2. If no backup: Regenerate from app_spec.txt using initializer agent
  3. Fix specific syntax error (missing comma, unclosed bracket) if identifiable
  4. Restart coding agent after fix
- **Prevention:** Initializer agent validates JSON before writing, create backup before modifications

**Scenario 3: Agent Crashes Mid-Run**
- **Symptoms:** No log updates for >30 minutes, process not running
- **Diagnosis:** Check autonomous_build_log.md for last entry, inspect process exit code
- **Recovery:**
  ```bash
  # Check last completed feature
  cat feature_list.json | jq '.features[] | select(.status=="pass") | .id' | tail -1

  # Restart from checkpoint
  ./scripts/restart_autonomous_agent.sh --from-feature FR-X.Y
  ```
- **Prevention:** Agent should write checkpoint every 5 features

**Scenario 4: Agent Stuck in Infinite Loop**
- **Symptoms:** Same log line repeating, no progress for >1 hour, high CPU usage
- **Diagnosis:** Check for repeated error messages, identify stuck feature
- **Recovery:**
  ```bash
  # Kill agent process
  pkill -f run_autonomous_continuous

  # Mark current feature as blocked
  ./scripts/mark_feature_blocked.sh FR-X.Y "Agent stuck in infinite loop"

  # Restart agent, it will skip blocked feature
  ./scripts/run_autonomous_continuous.sh --resume
  ```
- **Prevention:** 30-minute timeout per feature attempt (enforced by agent)

### Monitoring Progress

**Real-Time Log Monitoring:**
```bash
tail -f autonomous_build_log.md
```

**What to Look For (Actionable Monitoring Guidance):**

**✅ Good Signs (Agent Working Correctly):**
- New feature IDs appearing every 15-45 minutes
- Status transitions: `pending → in_progress → pass`
- Test output showing PASS verdicts
- Progress percentage increasing steadily
- Log entries: "Feature FR-X.Y completed successfully"

**⚠️ Warning Signs (Potential Issues, Action Required):**
- Same feature attempt >2 times → **Action:** Review error logs, prepare to mark blocked or intervene manually
- Retry logic activating frequently (>5 retries in 2 hours) → **Action:** Check API connectivity, rate limits, or requirement clarity
- Test failures with same error message → **Action:** Systematic issue detected, investigate root cause (dependency, configuration, or requirement error)
- Slow progress: <1 feature/hour → **Action:** Agent struggling with complexity, consider manual implementation for current feature
- Warning messages about API rate limits approaching → **Action:** Reduce concurrency or add delays between requests

**🚨 Urgent Action Required:**
- No log updates for >30 minutes (agent likely crashed)
- Error message repeating >10 times (infinite loop)
- All recent features marked "blocked" (fundamental issue, abort)
- Critical error: "ANTHROPIC_API_KEY invalid" (fix immediately)
- JSON syntax error (corrupted feature_list.json, restore from backup)

**Feature Status Queries:**
```bash
# Current status summary
cat feature_list.json | jq '.summary'

# Recently completed features (last 5)
cat feature_list.json | jq '.features[] | select(.status=="pass") | .id' | tail -5

# Blocked features with reasons
cat feature_list.json | jq '.features[] | select(.status=="blocked") | {id, name, blocking_reason}'

# Currently in progress
cat feature_list.json | jq '.features[] | select(.status=="in_progress")'

# Progress percentage (requires bc: apt-get install bc or brew install bc)
echo "scale=2; $(cat feature_list.json | jq '[.features[] | select(.status=="pass")] | length') * 100 / 28" | bc
```

**Intervention Decision Tree:**
1. **Progress <40% after 24h:** Review blocked features, prepare for manual completion fallback (Jorge implements 8-12h, extend timeline to Day 6-7)
2. **>5 blocked features:** Pause agent, investigate common failure pattern (architecture issue, API problem, or requirement ambiguity)
3. **Agent crashed:** Follow recovery procedures (see Failure Scenarios above)
4. **API rate limit warnings:** Reduce agent concurrency or add delays

### Blocked Feature Prevention & Handling

**Pre-Flight Validation (Before Agent Starts):**
```bash
./scripts/validate_requirements.sh app_spec.txt
# Checks:
#   - All 28 features have clear acceptance criteria
#   - Ambiguous requirements flagged (keywords: "might", "possibly", "could" - NOT "should" which is standard requirement language per RFC 2119)
#   - External dependencies documented (API keys, services, tools)
#   - Complexity assessment: flag features likely to block (integrations, novel patterns)
# Output: requirements_validation_report.txt
```

**Complexity Assessment (Proactive Risk Identification):**
- **Low Complexity (likely pass):** CRUD operations, basic GitHub API calls, file generation
- **Medium Complexity (may block):** Multi-step workflows, error handling, testing complex scenarios
- **High Complexity (likely block):** Novel integrations, ambiguous requirements, external API dependencies

**Pre-Flight Actions:**
- **High Complexity Features:** Consider manual implementation or defer to Phase 1.5
- **External Dependencies:** Validate API keys, test endpoints before agent starts
- **Ambiguous Requirements:** Clarify with Jorge before including in app_spec.txt

**Handling Blocked Features (Reactive, After 3 Attempts):**
1. Review autonomous_build_log.md for failure reason
2. Categorize blocking reason:
   - **Ambiguous Requirement:** Update app_spec.txt with clarification, retry
   - **External Dependency:** Fix dependency (API key, service), retry
   - **Complexity Too High:** Manual implementation (Jorge, 1-2 hours)
   - **BMAD Library Issue:** Report bug, manual workaround
3. Options:
   - Simplify requirement (reduce scope to minimal viable)
   - Manual implementation (Jorge implements, marks "pass")
   - Defer to Phase 1.5 (mark as Phase 1.5 scope)
4. Continue agent with remaining features (don't block on blockers)

---

## Testing Plan

### Test Fixtures & Setup

**Test Microservice Template (for Buck's validation):**
```
test-microservice/
├── package.json         # Express.js "Hello World" API
├── index.js             # GET / returns {"status": "ok", "message": "Hello from Seven Fortunas"}
├── test/
│   └── api.test.js      # Jest tests (health check, JWT auth, rate limiting)
├── .github/workflows/
│   └── ci-cd.yml        # Build, test, deploy pipeline
├── Dockerfile           # Container image
└── README.md            # Setup and deployment instructions
```

**Test Repository Structure (for GitHub org validation):**
```
test-repo/
├── README.md            # Documentation
├── .gitignore           # Python + Node patterns
├── LICENSE              # MIT
├── CODE_OF_CONDUCT.md   # Standard contributor covenant
├── CONTRIBUTING.md      # Contribution guidelines
└── .github/
    ├── ISSUE_TEMPLATE/
    ├── PULL_REQUEST_TEMPLATE.md
    └── workflows/
        └── pre-commit-validation.yml
```

**Mock Data for Dashboard Testing:**
```
dashboards/ai/test-data/
├── mock-rss-feed.xml    # Sample OpenAI blog entries
├── mock-github-releases.json  # Sample langchain releases
├── mock-reddit-posts.json     # Sample r/MachineLearning posts
└── expected-output.json       # Expected aggregated output for validation
```

**Test Secrets for Security Validation:**
```
test-secrets/
├── cleartext-api-key.txt      # Plain API key (should be caught)
├── base64-encoded-secret.txt  # Base64 encoded (should be caught)
├── env-file-with-secret.env   # .env file with secrets (should be caught)
└── split-secret/              # Secret split across files (edge case)
```

### Agent-First Testing (Automated)
**Philosophy:** Automated testing by agent MUST precede human testing

**Testing Hierarchy:**
1. Agent writes tests (unit, integration)
2. Agent runs tests before marking "pass"
3. Human validates aha moments (Day 3)
4. Human exploratory testing (Days 4-5)

### Manual Testing (Day 3)

**Test 1: Patrick's Infrastructure Validation (2 hours)**
- ✅ Architecture docs comprehensible in 2 hours
- ✅ ADRs demonstrate thoughtful decisions
- ✅ Code review skill references architectural standards
- ✅ Security settings validated (Dependabot, secret scanning, 2FA)
- **Pass Criteria:** Patrick rates architecture 7+/10

**Test 2: Buck's Engineering Delivery Validation (2-3 hours)** ✅ CORRECTED

**Core Validation (2 hours - REQUIRED for aha moment):**
- Deploy test microservice using infrastructure
- CI/CD pipeline functional (build, test, deploy <10 min)
- App-level security configured (JWT, rate limiting)
- Rollback procedures tested and working
- **Pass Criteria:** Deployment smooth, Buck confident team can ship fast

**Optional: PCI Compliance Validation (1 hour additional - Phase 1.5 scope):**
- PCI DSS controls mapping (encryption at rest/transit, access logs, secure coding)
- Cardholder data handling procedures documented
- PCI compliance checklist completion
- **Note:** PCI compliance is separate workstream, not required for MVP aha moment

**Test 3: Jorge's Security Testing (1 hour)** ✅ ADDED
- ✅ Commit secret → Pre-commit hook blocks
- ✅ Bypass with --no-verify → GitHub Actions catches
- ✅ Base64-encoded secret → Secret scanning alerts
- ✅ Security dashboard shows ≥99.5% compliance
- **Pass Criteria:** ≥99.5% secret detection rate, ≤0.5% false negatives (per NFR-1.1)

**Test 4: Henry's Brand Creation (3 hours total for full brand application)**
- ✅ Voice input transcription accurate (OpenAI Whisper)
- ✅ AI structures content (extract key points, add headings)
- ✅ Henry refines 20% (not 80%)
- ✅ Brand applied to all GitHub assets automatically
- **Pass Criteria:** Voice-to-structured-content in 30 min (vs 6 weeks manual baseline), full brand application 3h (vs 6 weeks)

---

## Dependencies & Risks

### Critical Path Dependencies & Fallbacks

**1. Day 0: GitHub CLI Authentication (jorge-at-sf) - BLOCKING**
- **Fallback if Failed:** Manual GitHub org creation via web UI (4 hours)
- **Impact:** Delays Day 1 start by 4 hours, still recoverable
- **Prevention:** Validate with `./scripts/validate_github_auth.sh` before Day 0

**2. Day 1: app_spec.txt Generation from PRD - BLOCKING**
- **Fallback if Failed:** Manual app_spec.txt creation (Jorge, 4 hours)
- **Impact:** Delays autonomous agent start to Day 1 afternoon
- **Prevention:** Validate app_spec.txt with `./scripts/validate_app_spec.sh`

**3. Days 1-2: Autonomous Agent Completes ≥60% - SUCCESS CRITERION**
- **Fallback if <60% completion:**
  - **40-60% range:** Jorge manually implements remaining features (8-12 hours additional work, extend timeline to Day 6-7)
  - **<40% range:** Abort autonomous approach, switch to full manual implementation (32-40 hours, extend to Day 10-12), reduce MVP scope to 18-20 critical features
- **Impact:** Timeline extends 1-5 days, but MVP still achievable with reduced scope or extended effort
- **Decision criteria:** Evaluate at end of Day 2 based on pass rate, blocked features, and remaining complexity
- **Prevention:** Monitor progress hourly, intervene if <40% by end of Day 1

**4. Day 3: Founder Aha Moments Validated - SUCCESS CRITERION**
- **Fallback if Failed:** Async validation (founders review when available)
- **Impact:** Leadership demo shifts to Week 2, but features still functional
- **Prevention:** Pre-confirm founder availability calendar 1 week before MVP

### Risk Mitigation

**Risk: Autonomous Agent <50% Completion**
- **Mitigation:** Reduce scope from 28 to 18 Tier 1 features (see list below), Jorge manually implements remaining (budgeted 16h total across Days 3-5, includes 6-8h Day 4 + 8-10h Days 3&5)

**Tier 1 Features (Must-Have - 18 features for reduced scope):**
1. FR-1.1: Create GitHub Organizations
2. FR-1.2: Configure Team Structure
3. FR-1.3: Configure Organization Security Settings
4. FR-1.4: GitHub CLI Authentication Verification
5. FR-1.5: Repository Creation & Documentation
6. FR-1.6: Branch Protection Rules
7. FR-2.1: Progressive Disclosure Structure (Second Brain)
8. FR-2.2: Markdown + YAML Dual-Audience Format
9. FR-2.4: Search & Discovery
10. FR-3.1: BMAD Library Integration
11. FR-3.2: Custom Seven Fortunas Skills (3 core skills minimum)
12. FR-4.1: AI Advancements Dashboard (MVP)
13. FR-4.2: AI-Generated Weekly Summaries
14. FR-5.1: Secret Detection & Prevention
15. FR-6.1: Self-Documenting Architecture
16. FR-7.1: Autonomous Agent Infrastructure
17. FR-7.3: Test-Before-Pass Requirement
18. FR-7.5: GitHub Actions Workflows (critical workflows only)

**Tier 2 Features (Defer if needed - 8 features listed below, note discrepancy from "10 features" claim):**
- FR-2.3: Voice Input System (Henry's aha moment nice-to-have)
- FR-3.3, FR-3.4: Skill organization & governance (Phase 1.5)
- FR-4.3, FR-4.4: Dashboard configurator, additional dashboards (Phase 2)
- FR-5.2, FR-5.3, FR-5.4: Dependency management, access control details, SOC 2 prep
- FR-7.2, FR-7.4: Bounded retry logic, progress tracking (agent improvements)

**Risk: Voice Input (Whisper) Installation Issues**
- **Mitigation:** Fallback to typing, alternative web-based transcription (Otter.ai)

**Risk: GitHub Free Tier Constraints**
- **Mitigation:** Use public repos for dashboards (unlimited Actions), upgrade to Team tier post-MVP ($4/user/month)

---

## Deployment Strategy

### Phase 1 (MVP): GitHub Free Tier
- **Infrastructure:** GitHub.com (public + private orgs)
- **Automation:** GitHub Actions (2,000 min/month private, unlimited public)
- **Hosting:** GitHub Pages (seven-fortunas.github.io)
- **AI Processing:** Claude API (~$0.05-5/month)
- **Cost:** $0-5/month (excluding optional X API $100/month)

### Phase 1.5 (Weeks 2-3): CISO Assistant Integration
- CISO Assistant migration to Seven-Fortunas-Internal
- GitHub → CISO Assistant evidence sync
- 10+ AI-first GitHub operation skills

### Phase 2 (Months 1-3): Team Expansion
- 10-20 team members onboarded
- 3 additional dashboards (fintech, edutech, security - extensible beyond 3 based on demand)
- GitHub Team tier ($4/user/month, post-funding)

### Phase 3 (Months 6-12): Enterprise Maturity
- GitHub Enterprise tier ($21/user/month)
- Advanced Security (CodeQL, audit logs, SAML SSO)
- 50+ team members, SOC 2 Type 2 audit in progress

---

## Release Criteria

### MVP Release (Day 5)
- ✅ Autonomous agent: 60-70% completion (18-25 of 28 features)
- ✅ All 4 founder aha moments validated
- ✅ Leadership demo: Positive reception (7+/10 on usefulness/excitement scale from audience, measured via post-demo survey)
- ✅ Security testing: ≥99.5% secret detection rate (Jorge's adversarial tests per NFR-1.1)
- ✅ Onboarding: <2 hours per founder
- ✅ Zero critical security failures

### Phase 1.5 Release (Week 3)
- ✅ CISO Assistant integrated
- ✅ SOC 2 control mapping complete
- ✅ Evidence sync functional (daily)
- ✅ <5 duplicate skills created
