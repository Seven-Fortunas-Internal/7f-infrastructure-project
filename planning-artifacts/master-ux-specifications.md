---
title: UX Specifications Master Document
type: Master Document (3 of 6)
sources:
  - ux-design-specification.md (Feb 14 - most recent)
  - prd/user-journeys.md
  - product-brief-7F_github-2026-02-10.md
date: 2026-02-15
author: Mary (Business Analyst) with Jorge
status: Phase 2 - Master Consolidation
version: 1.0
role-corrections: ✅ CRITICAL - Buck's journey corrected (security testing → engineering delivery), Jorge's security testing journey added
editorial-review: Pending
---

# UX Specifications Master Document

**Contract Compliance:** ✅ Per DOCUMENT-SYNC-EXECUTION-PLAN.md Phase 2, Section 2d
**Critical Corrections:** Buck's user journey and aha moment corrected per Jorge's guidance (2026-02-15)

---

## Executive Summary

**UX Innovation:** AI-native enterprise nervous system designed for dual-audience (humans + AI agents) from inception.

**Core UX Challenges:**
1. Dual-audience design (optimize for humans AND AI)
2. Voice-enabled creation (Henry's primary input method)
3. Progressive disclosure at scale (4 → 50 users)
4. Self-service operations (Jorge enables, not bottleneck)
5. Real-time intelligence (dashboards auto-update)

**Success Metrics:**
- Henry shapes ethos in 30 min (voice → brand docs)
- Patrick validates infrastructure in 2 hours (architecture comprehension)
- Buck sees engineering delivery working in 1 hour ✅ CORRECTED (engineering delivery, not security)
- Jorge achieves 60-70% autonomous build (Days 1-2)
- New members onboard in 1-2 days (self-service)

---

## UX Design Principles

### 1. Voice-Enabled for Creators, Terminal-First for Builders
- **Henry (CEO):** Thinks by speaking, uses voice input for brand/content creation
- **Patrick/Buck/Jorge:** Think in terminal commands, prefer CLI over GUI

### 2. Progressive Disclosure for Humans, Structured Data for AI
- **Pattern:** YAML frontmatter (machine-readable) + Markdown body (human-readable) + README (both)
- **Loading:** Index-first (AI loads index.md, then specific sections as needed)

### 3. Conversational Infrastructure, Not Memorized Commands
- **Anti-Pattern:** Memorizing git commands, kubectl syntax, terraform modules
- **Pattern:** Natural language BMAD skills - "/7f-create-repo my-app public" vs "gh repo create..."

### 4. Trust but Verify, Not Block and Review
- **Pattern A (High-Risk):** Approve-then-execute (delete repo, force push)
- **Pattern B (Low-Risk):** Execute-then-review (create file, update docs)

### 5. Make the Infrastructure the Demo
- Transparent progress tracking (autonomous agent logs visible)
- Decision logging (ADRs, commit messages explain WHY)
- "Making of" documentation (show the work, not just results)

### 6. Optimize for Team Scale (4 → 50), Not Individual Efficiency
- Self-service patterns (enable team, don't centralize)
- Documented processes (repeatable, transferable)
- Automated onboarding (1-2 days for new members)

---

## User Personas & Aha Moments

### Henry (CEO) - The Visionary Leader

**Aha Moment: "AI Permeates Everywhere" (30 Minutes)**

**User Journey:**
1. Opens terminal, invokes: `/7f-brand-system-generator`
2. Skill asks questions via voice:
   - "What are your primary brand colors?"
   - "What typography feels right?"
   - "What's your brand voice?" (professional, casual, technical, friendly)
3. Henry speaks answers (5-10 minutes of dictation)
4. AI structures responses:
   - Extracts key points
   - Adds headings and sections
   - Generates brand.json (structured data)
   - Generates brand-system.md (narrative documentation)
5. Henry reviews and refines (20% editing, 5 minutes)
6. Skill applies branding to all GitHub assets:
   - Updates .github/profile/README.md (both orgs)
   - Updates seven-fortunas.github.io CSS
   - Updates PR/Issue templates with voice
7. **Henry's reaction (expected):** "This would have taken weeks with a consultant. Done in [actual time]."

**Success Criteria (Objective Metrics):**
- ✅ Brand system created (brand.json, brand-system.md, tone-of-voice.md)
- ✅ Applied to all repos automatically
- ✅ **Time:** <3 hours total (target: 30 min voice + 30 min editing, acceptable: <3h with typing fallback)
- ✅ **Transcript accuracy:** ≥70% (measured by comparing transcript to Henry's intent, acceptable threshold for "aha moment")
- ✅ **Editing effort:** <30% of total time (if 30 min creation, <10 min editing = professional output)
- ✅ **Quality:** Brand documentation complete (all required fields populated), coherent structure, grammar correct
- ✅ **Henry's assessment:** Rates experience 7+/10 on "AI accelerated my work" scale

---

### Patrick (CTO) - The Quality Guardian

**Aha Moment: "SW Development Infrastructure is Well Done" (2 Hours)**

**User Journey:**
1. Opens terminal, authenticates GitHub CLI: `gh auth login`
2. Explores org structure:
   ```bash
   gh org list
   gh repo list Seven-Fortunas
   gh repo list Seven-Fortunas-Internal
   ```
3. Reads architecture documentation:
   - Finds second-brain-core/best-practices/engineering/
   - Reads ADRs (architectural decision records)
   - Sees clear rationale for two-org model, progressive disclosure, BMAD-first
4. Tests code review skill:
   - Creates test PR with intentional issues
   - AI catches race condition, references ADR-004
   - **Patrick's reaction:** "AI isn't just syntax checking—it understands our architectural decisions"
5. Validates security settings:
   - Checks Dependabot, secret scanning, branch protection
   - Reviews GitHub Actions workflows
   - Confirms 2FA enforcement
6. **Patrick's final assessment (expected):** "Infrastructure is well done. I trust this foundation."

**Success Criteria (Objective Metrics):**
- ✅ **Architecture comprehensible:** Patrick understands system in <2 hours (measured by ability to explain architecture back without looking at docs)
- ✅ **ADRs complete:** All 5 critical decisions documented (two-org model, progressive disclosure, GitHub Actions, skill-creation skill, API keys)
- ✅ **Security scan passes:** Dependabot 0 critical alerts, secret scanning enabled, 2FA enforced (validated via GitHub security dashboard)
- ✅ **Code quality baseline:** If code review skill exists, spot-check shows it references ADRs correctly
- ✅ **Patrick's assessment:** Rates architecture 7+/10 on quality/completeness scale

---

### Buck (VP Engineering) - The Delivery Enabler

**Aha Moment: "Engineering Infrastructure Enables Rapid Delivery" (1 Hour)**

**User Journey:**
1. Opens terminal, wants to deploy a new microservice to test infrastructure
2. Uses skill to scaffold new service:
   ```bash
   /7f-repo-template my-microservice backend
   ```
3. Skill creates:
   - Repository with CI/CD configured
   - Dockerfile and docker-compose.yml
   - GitHub Actions workflows (build, test, deploy)
   - README with deployment instructions
4. Buck configures app-level security:
   - Sets up API authentication (JWT)
   - Configures rate limiting
   - Adds PCI compliance checks (for payment processing)
5. Tests deployment pipeline:
   - Pushes code to feature branch
   - CI/CD runs tests automatically
   - Merge to main triggers staging deployment
   - Observes smooth deployment (< 5 minutes)
6. Tests rollback procedure:
   - Simulates failed deployment
   - Automatic rollback to previous version (< 2 minutes)
7. **Buck's reaction (expected):** "Engineering team can ship fast. Infrastructure doesn't block us. CI/CD just works."

**Success Criteria (Objective Metrics):**
- ✅ **Deployment speed:** Test microservice deployed in <10 minutes from repo creation to live endpoint
- ✅ **CI/CD functional:** Build completes <5 min, tests run automatically, deployment to staging successful
- ✅ **CI/CD reliability:** Test pass rate ≥95% (spot-check 10 test runs, ≥9 should pass)
- ✅ **App-level security working:** JWT authentication endpoint validates tokens, rate limiting blocks request #101
- ✅ **Rollback tested:** Rollback from broken deployment to previous version completes in <2 minutes, service restored
- ✅ **Buck's assessment:** Rates infrastructure 7+/10 on "ready for engineering team" scale

**Note:** Security testing (pre-commit hooks, secret scanning, adversarial testing) is Jorge's journey below.

---

### Jorge (VP AI-SecOps) - The AI & Security Infrastructure Architect

**Aha Moment: "Implementation Working with Minimal Issues" (Days 1-2)**

**User Journey #1: Autonomous Agent Launch (Primary)**
1. Day 0 Evening: Jorge prepares autonomous agent
   - Generates app_spec.txt from PRD
   - Configures agent scripts (./scripts/run_autonomous_continuous.sh)
   - Verifies GitHub authentication: `gh auth status | grep jorge-at-sf`
2. Day 1 Morning: Jorge launches agent
   ```bash
   ./scripts/run_autonomous_continuous.sh
   ```
3. Jorge monitors progress throughout Day 1-2:
   ```bash
   tail -f autonomous_build_log.md
   cat feature_list.json | grep status
   ```
4. End of Day 1: Jorge reviews progress
   - feature_list.json shows 18 features "pass" (64%)
   - 3 features "blocked" (logged with reasons)
   - 7 features "pending"
   - Zero features "broken" (bounded retries working)
5. Day 2: Agent completes remaining features
   - Final tally: 22 features "pass" (79%), 3 blocked, 3 pending
   - Better than target (60-70%)
6. **Jorge's reaction:** "It's actually working. Not perfect, but working with minimal issues."

**User Journey #2: Security Testing (SecOps) ✅ ADDED PER JORGE'S GUIDANCE**

**Timeframe:** Day 3 Afternoon (1 hour)

**Purpose:** Adversarially test infrastructure security controls to validate SecOps implementation

**Journey:**
1. **Test 1: Commit Secret (Pre-Commit Hook)**
   - Jorge creates test repo, attempts to commit with hardcoded API key
   - Pre-commit hook blocks commit immediately
   - Error message clear: "Secret detected: API_KEY pattern found"
   - ✅ Result: Secret blocked at local layer

2. **Test 2: Bypass Pre-Commit with --no-verify**
   - Jorge attempts: `git commit --no-verify -m "bypass hook"`
   - Commit succeeds locally (expected - pre-commit bypassed)
   - Push to GitHub triggers GitHub Actions workflow
   - Workflow detects secret, blocks push, alerts team
   - ✅ Result: Secret blocked at remote layer

3. **Test 3: Base64-Encoded Secret**
   - Jorge encodes API key in base64, commits
   - GitHub secret scanning detects pattern
   - Push protection blocks commit
   - Alert sent to security dashboard
   - ✅ Result: Encoded secret blocked at repository layer

4. **Test 4: Security Dashboard Review**
   - Jorge opens security dashboard (dashboards-internal/security/)
   - Reviews compliance posture: 100% (all controls passing)
   - Checks Dependabot alerts: 0 critical, 2 medium (auto-patching in progress)
   - Reviews secret scanning history: 3 test attempts logged, 0 real secrets leaked
   - ✅ Result: Full visibility into security posture

5. **Jorge's reaction (expected):** "Security controls work. Infrastructure is protected. SecOps on autopilot."

**Success Criteria (Objective Metrics):**
- ✅ **Secret detection rate:** ≥99% detection across 20+ test cases (cleartext, base64, env vars, encoded) - measured via adversarial testing
- ✅ **Multi-layer validation:** Pre-commit hook catches ≥90%, GitHub Actions catches bypasses, secret scanning catches edge cases
- ✅ **False negative rate:** ≤1% (maximum 1 secret missed out of 100 test cases)
- ✅ **Security dashboard:** ≥99% compliance (measured by controls passing / total controls)
- ✅ **Dependabot:** 0 critical vulnerabilities, 0 high vulnerabilities >7 days old
- ✅ **Jorge's assessment:** Rates security posture 7+/10 on "ready for production" scale

**Note:** This is Jorge's security testing journey (SecOps infrastructure validation), NOT Buck's. Buck focuses on engineering delivery and application-level security.

---

## Core User Flows

### Flow 1: Knowledge Creation & Management (Second Brain)
**Pattern:** Speak/Write → AI Structures → Human Refines → Team Finds Instantly

1. **Input:** Henry dictates 10-minute voice memo about company mission
2. **AI Processing:** Whisper transcribes → Claude structures (extract key points, add headings)
3. **Human Refinement:** Henry edits 20% (5 minutes)
4. **Storage:** Saved to second-brain-core/culture/mission.md with YAML frontmatter
5. **Discovery:** Patrick searches "mission" → Finds doc in <15 seconds

### Flow 2: Infrastructure Operations (GitHub + BMAD Skills)
**Pattern:** Describe Need → AI Configures → System Validates → Audit Trail

1. **Input:** Buck says "/7f-repo-template my-api backend"
2. **AI Configuration:** Skill creates repo, CI/CD, security templates
3. **Validation:** Tests run, security scans pass
4. **Audit Trail:** Commit log shows what was created, by whom, why

### Flow 3: Intelligence Gathering (7F Lens Dashboards)
**Pattern:** Open Dashboard → Latest Trends → AI Summary → Actionable Insights

1. **Automated Collection:** GitHub Actions runs every 6 hours, aggregates data from RSS, GitHub, Reddit
2. **AI Summarization:** Claude API generates weekly summary (Sundays 9am UTC)
3. **Structured Markdown:** dashboards/ai/README.md updates automatically
4. **Leadership Review:** Henry reads 5-minute summary, no manual work needed

---

## Component Specifications

### Component 1: Skill Invocation UI (Terminal-Based)

**Complete 5-Step Flow Example (7f-brand-system-generator):**

**Step 1: Initialization**
```
🔧 7f-brand-system-generator (Step 1 of 5: Initialization)

Welcome! This skill helps you create your brand system via voice or text input.

Estimated time: 10-30 minutes
What you'll create: brand.json, brand-system.md, tone-of-voice.md

Input method:
  [1] Voice input (recommended, ~10 min)
  [2] Text input (~30 min)

> _
```

**Step 2: Primary Configuration** *(existing example)*
```
🔧 7f-brand-system-generator (Step 2 of 5: Primary Brand Colors)

What are your primary brand colors?
Options:
  [1] Deep Blue (#1E3A8A) - Professional, trustworthy
  [2] Emerald Green (#10B981) - Growth, innovative
  [3] Vibrant Purple (#7C3AED) - Creative, bold
  [4] Custom (provide hex code)

> _
```

**Step 3: Additional Configuration**
```
🔧 7f-brand-system-generator (Step 3 of 5: Typography & Voice)

What's your brand voice?
Examples: Professional, Casual, Technical, Friendly, Bold

[Type or speak your answer]
> _
```

**Step 4: Validation & Preview**
```
🔧 7f-brand-system-generator (Step 4 of 5: Review)

Please review your brand system:
  • Primary Color: Deep Blue (#1E3A8A)
  • Typography: Inter (sans-serif)
  • Voice: Professional, approachable
  • Tone: Confident but not arrogant

Is this correct?
  [1] Yes, proceed
  [2] Edit colors
  [3] Edit voice
  [4] Start over

> _
```

**Step 5: Confirmation & Apply**
```
🔧 7f-brand-system-generator (Step 5 of 5: Apply)

⏳ Generating brand system...
✅ brand.json created
✅ brand-system.md created
✅ tone-of-voice.md created

Apply branding to all GitHub repos?
  [1] Yes, apply to all
  [2] No, manual application
  [3] Preview changes first

> _
```

**Design Principles:**
- Clear step indication (Step X of Y with step name)
- Contextual help (descriptions for each option)
- Keyboard shortcuts (1, 2, 3, or custom input)
- Progress visibility (always show current step)
- Review step before final action (prevent mistakes)

### Component 2: Status Indicators
**In Progress:**
```
⏳ Creating repository... (30s elapsed, ~45s remaining)
[████████░░] 80%
```

**Time Estimate Calculation:**
- **Algorithm:** Average of last 10 similar operations (repo creation avg: 60s) × 1.2 safety factor = 72s estimate
- **If exceeds estimate by 2x:** Update message: "(90s elapsed, taking longer than usual...)"
- **If exceeds estimate by 5x:** Update message: "(300s elapsed, investigating delay...)"
- **If exceeds estimate by 10x:** Timeout, show error: "Operation timed out after 10 minutes. Check GitHub status or retry."
- **Accuracy target:** ≥70% of operations complete within estimated time ±20%

**Success:**
```
✅ Repository created successfully
   - URL: https://github.com/Seven-Fortunas/my-repo
   - Default branch: main
   - CI/CD configured
```

**Error:**
```
❌ Failed to create repository
   Reason: Name already exists
   Suggestion: Try 'my-repo-v2' or check existing repos with `gh repo list`
```

### Component 3: Approval Workflows

**High-Risk (Delete Repo):**
```
⚠️  DESTRUCTIVE ACTION
You are about to delete repository: Seven-Fortunas/test-repo

This action CANNOT be undone. All code, issues, PRs will be permanently deleted.

To confirm, type the repository name exactly: _
```

**Error Handling:**
```
# User types "test-repo" (missing org name)
❌ Incorrect. Type the full name: Seven-Fortunas/test-repo

# User types "Seven-Fortunas/Test-Repo" (wrong case)
❌ Case mismatch. Type exactly: Seven-Fortunas/test-repo

# User types "Seven-Fortunas/test-repo " (trailing space)
⚠️  Extra whitespace detected. Did you mean: Seven-Fortunas/test-repo? (y/n)

# User pastes from clipboard with line break
⚠️  Line break detected. Did you mean: Seven-Fortunas/test-repo? (y/n)

# User attempts 3 times incorrectly
❌ Too many incorrect attempts. Deletion cancelled for safety.
```

**Low-Risk (Create Repo):**
```
📝 Ready to create repository
   Name: my-api
   Visibility: private
   Template: backend-service

Proceed? (y/n): _
```

### Component 4: Error State Designs

**Error Scenario 1: Authentication Failed**
```
❌ Authentication Error

GitHub CLI not authenticated or token expired.

What happened: Your GitHub token is invalid or expired.
Impact: Cannot perform GitHub operations.

How to fix:
1. Run: gh auth login
2. Follow prompts to authenticate
3. Verify: gh auth status

Need help? See docs/troubleshooting.md#auth-errors
```

**Error Scenario 2: Rate Limit Exceeded**
```
⚠️  Rate Limit Exceeded

GitHub API: 4,950 / 5,000 requests used this hour.

What happened: You've used 99% of your hourly API quota.
Impact: API calls will be blocked for the next 15 minutes.

What to do:
• Wait 15 minutes for quota reset
• Or: Reduce automation frequency
• Or: Upgrade to higher tier (if available)

Time until reset: 14:23 remaining
```

**Error Scenario 3: API Outage**
```
🔴 Service Unavailable

GitHub API is experiencing issues.

What happened: GitHub's servers are not responding (status: 503).
Impact: Cannot create repos, update settings, or fetch data.

What to do:
1. Check GitHub status: https://www.githubstatus.com/
2. If green: retry operation
3. If red/yellow: wait for GitHub to resolve

Last successful API call: 2 minutes ago
Retry automatically in: 60 seconds
```

**Error Scenario 4: Corrupted Data**
```
❌ Data Validation Error

File: feature_list.json
Error: Invalid JSON syntax at line 42, column 18

What happened: JSON file is corrupted or malformed.
Impact: Autonomous agent cannot read feature list.

How to fix:
1. Backup corrupted file: cp feature_list.json feature_list.json.backup
2. Validate JSON: python3 -m json.tool feature_list.json
3. Fix syntax error at line 42
4. Or restore from last backup: cp feature_list.json.last feature_list.json

Need help? See docs/troubleshooting.md#json-errors
```

**Error Scenario 5: Network Timeout**
```
⏱️  Operation Timed Out

Operation: Fetch dashboard data
Timeout after: 30 seconds

What happened: Network request took too long to complete.
Possible causes: Slow network, server overloaded, firewall blocking

What to do:
1. Check internet connection
2. Retry operation (button below)
3. If persists: check firewall settings

[Retry Now]  [Cancel]
```

**Error Scenario 6: Validation Error**
```
❌ Validation Failed

Repository name: "test repo with spaces"
Error: Repository names cannot contain spaces

What happened: Input doesn't meet requirements.
Requirements:
• Alphanumeric characters, hyphens, underscores only
• No spaces
• Max 100 characters

Suggested fix: "test-repo-with-spaces"

[Use Suggestion]  [Edit Manually]
```

**Error Scenario 7: Permission Denied**
```
🔒 Permission Denied

Operation: Create organization
User: jorge-at-gd (current)
Required: jorge-at-sf

What happened: You're authenticated with the wrong GitHub account.
Impact: Cannot perform organization operations.

How to fix:
1. Switch account: gh auth switch --user jorge-at-sf
2. Verify: gh auth status | grep jorge-at-sf
3. Retry operation

[Switch Account]  [Cancel]
```

**Error Scenario 8: Operation Timeout (Agent)**
```
⏱️  Feature Implementation Timed Out

Feature: FR-5.1 Secret Detection
Attempt: 1 of 3
Duration: 30 minutes (timeout threshold)

What happened: Agent exceeded 30-minute limit for this feature.
Next steps: Agent will retry with simplified approach.

Progress: 18 / 28 features complete (64%)
Status: Continuing with remaining features...

[View Detailed Logs]  [Skip This Feature]
```

**Error Display Principles:**
- **Always show:** What happened, Impact, How to fix
- **Use icons:** ❌ (error), ⚠️ (warning), 🔴 (critical), ⏱️ (timeout), 🔒 (permission)
- **Provide actions:** Buttons for common fixes, links to docs
- **Be specific:** No generic "Error occurred" messages
- **Show context:** What operation, what file, what line number

### Component 5: Progress Tracking (Autonomous Agent)
**Terminal Dashboard (Dynamic Target Display):**
```
🤖 Autonomous Agent Progress
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall: 22/28 features (79%)
Status: ✅ EXCEEDS TARGET (target: 60-70%, actual: 79%)
[████████████████████░░░░] 79%

Current Task: FR-7.5 - GitHub Actions Workflows
├─ Status: In Progress (Attempt 1/3)
├─ Elapsed: 12m 34s
└─ Est. Remaining: ~8m

Recent Completions (Last 5):
  ✅ FR-7.4 - Progress Tracking (3m ago)
  ✅ FR-7.3 - Test-Before-Pass (18m ago)
  ✅ FR-7.2 - Bounded Retry Logic (31m ago)
  ✅ FR-6.1 - Self-Documenting Architecture (47m ago)
  ✅ FR-5.4 - SOC 2 Preparation (1h 2m ago)

Blocked Features (3):
  ⚠️  FR-3.4 - Skill Governance (Phase 1.5 dependency)
  ⚠️  FR-4.4 - Additional Dashboards (Phase 2 scope)
  ⚠️  FR-5.4 - SOC 2 Integration (CISO Assistant migration required)

Next Up:
  ⏭️  FR-1.6 - Branch Protection Rules
  ⏭️  FR-2.4 - Search & Discovery
```

---

## Interaction Patterns

### Pattern 1: Finding Information (Tiered Targets)
**Goal:** Team members find information quickly based on scenario complexity

**Tiered Time Targets:**
- **Tier 1 (Known Location):** 10-30 seconds - User knows general area, navigates directly
  - Example: "Find brand colors" → index.md → brand/ → brand.json
- **Tier 2 (Search Required):** 30-90 seconds - User knows what to search for, uses grep/search
  - Example: "Find code review checklist" → grep "code review" → find best-practices/engineering/
- **Tier 3 (Complex Query):** 2-5 minutes - User explores multiple documents, synthesizes information
  - Example: "Understand entire CI/CD setup" → read multiple docs, follow cross-references

**Methods:**
1. **Browsing:** index.md → domain README → specific doc (2-3 clicks)
2. **Searching:** `grep -r "keyword" second-brain-core/`
3. **AI-Assisted:** "Where are API auth docs?" → Claude searches + returns path + summarizes

**UX Requirements:**
- README at every directory level (for Tier 1 browsing)
- YAML frontmatter filtering (relevant-for field)
- Clear file naming conventions (reduce search time)
- Never >3 levels deep (Tier 1 achievable)

**Validation:** Time 10 common queries across 3 team members, measure against tiers

### Pattern 2: Creating Infrastructure (Realistic Ranges)
**Goal:** Team members create infrastructure self-service with time based on complexity

**Time Targets by Complexity:**
- **Simple Repo (2-5 minutes):** Basic repo with README, no CI/CD
  - Invoke skill, answer 3 questions, repo created
- **Standard Repo (5-8 minutes):** Repo with CI/CD, basic security
  - Invoke skill, configure CI/CD template, validate security settings
- **Complex Repo (8-15 minutes):** Repo with CI/CD, advanced security, compliance
  - Invoke skill, configure app-level security (JWT, rate limiting), validate compliance checklist

**Flow (Standard Repo - 5-8 minutes):**
1. Invoke skill: `/7f-repo-template my-service backend` (10 seconds)
2. Answer 5-7 questions: name, visibility, template, CI/CD, security level (2-3 minutes)
3. Skill creates repo, configures CI/CD, adds security (2-4 minutes)
4. Validation: Verify repo accessible, CI/CD configured (1 minute)
5. Total time: 5-8 minutes (includes validation)

**UX Requirements:**
- Intelligent defaults (security pre-configured, 80% use defaults)
- Context-aware suggestions (previous choices remembered)
- Approval only for risky operations (delete, force push)
- Progress indicators (user knows operation in progress, not stuck)

**Validation:** Time repo creation for 5 different templates, measure against ranges

### Pattern 3: Voice Content Creation (10-60 minutes)
**Goal:** Henry creates professional content via voice significantly faster than manual writing

**Time Targets by Scenario:**
- **Best Case (10-15 minutes):** Voice transcription ≥85% accurate, minimal editing
  - 5 min speaking + 2 min AI structuring + 3 min editing = 10 min
- **Typical Case (20-40 minutes):** Voice transcription 70-85% accurate, moderate editing
  - 10 min speaking + 5 min AI structuring + 15 min editing = 30 min
- **Worst Case / Fallback (40-60 minutes):** Voice fails, Henry types with AI assistance
  - 30 min typing + 10 min AI structuring + 10 min editing = 50 min
- **Manual Baseline:** 6+ weeks with consultant (or 20-40 hours DIY without AI)

**"Professional Content" Definition (Objective Quality Criteria):**
- **Grammar:** ≤5 grammar errors per 1,000 words (validated by Grammarly or similar)
- **Structure:** Clear headings, logical flow, table of contents (if >1,000 words)
- **Completeness:** All required sections populated (brand colors, fonts, voice, examples)
- **Coherence:** Ideas connect logically, no contradictions
- **Editing required:** <30% of total time spent on editing (if 30 min creation, <10 min editing)

**Quality Validation Rubric (Henry rates 1-10):**
- Grammar/spelling: 8+/10 (few errors)
- Structure/organization: 7+/10 (clear, logical)
- Completeness: 8+/10 (all sections covered)
- Accuracy: 7+/10 (reflects intent)
- Overall "professional" quality: 7+/10

**UX Requirements:**
- Real-time feedback (recording indicator, transcription progress, confidence score)
- Clear error messages (no microphone, API failure, transcript quality warning if <70%)
- Retry options (poor audio quality → re-record section)
- Fallback to typing (seamless transition, no data loss)

**Validation:** Henry creates 3 documents via voice, measures time and quality against rubric

### Pattern 4: Staying Informed (5 minutes)
**Goal:** Leadership stays informed on AI/fintech/edutech trends in 5 minutes weekly

**Flow:**
1. Open dashboard: dashboards/ai/README.md
2. Read AI-generated weekly summary (top of page)
3. Scan key developments (bullet points)
4. Done (optional: deep dive into specific trend)

**UX Requirements:**
- Auto-update every 6 hours (no manual work)
- AI-generated summary (concise, actionable)
- Mobile-responsive (read on phone)
- Graceful degradation (if Claude API down, show raw data)

---

## Performance Budgets & Targets

### Load Time Targets (User-Perceived Performance)

**Dashboard Pages (7F Lens):**
- **First Paint:** <1 second (user sees something)
- **First Contentful Paint:** <2 seconds (user sees useful content)
- **Time to Interactive:** <5 seconds (user can interact)
- **Full Load:** <10 seconds (all data loaded, images rendered)
- **Degraded Performance Threshold:** >20 seconds = show "Loading slowly, check connection" warning

**Second Brain Pages (Markdown):**
- **First Paint:** <500ms (static content, should be instant)
- **Time to Interactive:** <2 seconds
- **Search Results:** <3 seconds (including grep/search execution)

**GitHub Pages (Landing Page):**
- **First Paint:** <1 second
- **Time to Interactive:** <3 seconds
- **Mobile (3G):** <5 seconds time to interactive

**Terminal/CLI Operations:**
- **Skill Invocation:** <2 seconds to first prompt
- **Command Execution:** <5 seconds for simple operations (create file, read doc)
- **Complex Operations:** <30 seconds for complex operations (create repo, configure CI/CD)
- **Agent Operations:** <30 minutes per feature (timeout threshold)

### Measurement & Validation

**Tools:**
- **Browser:** Chrome DevTools Performance tab, Lighthouse
- **CLI:** `time` command for operation duration
- **Dashboard:** GitHub Actions workflow duration logs

**Validation Schedule:**
- **MVP (Day 5):** Spot-check 5 key pages/operations
- **Phase 2:** Monthly performance audit
- **Phase 3:** Automated performance monitoring (alert if >2x budget)

### Degraded Performance Handling

**If load time exceeds budget by 2x:**
- Show progress indicator: "Loading... (taking longer than usual)"
- Log performance event for investigation

**If load time exceeds budget by 5x:**
- Show warning: "Slow connection detected. Consider reducing dashboard refresh frequency."
- Offer lightweight alternative (show cached data, reduce real-time updates)

**If load time exceeds budget by 10x (timeout):**
- Show error: "Operation timed out. Please check your connection and retry."
- Offer manual refresh button

---

## Responsive Design Strategy

### MVP: Desktop-First, Mobile-Responsive
**Primary:** Laptop/workstation (70% of team time)
**Secondary:** Mobile (20% - content review, Slack, email)
**Tertiary:** Tablets/other (10%)

**Interface Strategy:**
- **Second Brain:** Markdown + Obsidian/VS Code (platform-agnostic)
- **BMAD Skills:** Claude Code CLI (terminal-based, desktop only for MVP)
- **Dashboards:** GitHub Pages (web, mobile-responsive markdown)
- **Voice Input:** OpenAI Whisper (MacOS native, Linux CLI)

**Mobile Design Specifications (Dashboard Pages Only - MVP):**

**Breakpoints:**
- **Mobile:** 320px - 767px (portrait phones, small landscape)
- **Tablet:** 768px - 1023px (iPads, large phones landscape)
- **Desktop:** 1024px+ (laptops, desktops)

**Mobile Layout (320px - 767px):**
- Single column layout (no sidebars)
- Collapsible sections (tap to expand/collapse)
- Sticky header with navigation menu (hamburger icon)
- Dashboard content: stack vertically, full width
- Tables: horizontal scroll or pivot to cards
- Touch targets: minimum 44px × 44px

**Tablet Layout (768px - 1023px):**
- Two column layout where appropriate
- Dashboard navigation: sidebar (collapsible)
- Tables: full width, responsive columns

**Mobile Navigation Pattern:**
```
┌─────────────────────────┐
│ ☰ 7F Lens    [Search 🔍]│ ← Sticky header
├─────────────────────────┤
│ AI Advancements         │
│ Updated: 2h ago        ↓│ ← Tap to expand
│ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─│
│                         │
│ [Latest Updates Card]   │ ← Cards stack
│ [Latest Updates Card]   │
│ [Latest Updates Card]   │
│                         │
│ [View Full Archive]     │ ← Full-width button
└─────────────────────────┘
```

**Touch Interactions:**
- Tap: Select/expand
- Long press: Show context menu (copy, share)
- Swipe left/right: Navigate between dashboard tabs
- Pull-to-refresh: Update dashboard data
- Pinch-to-zoom: Disabled (use responsive layout instead)

**Phase 2 Mobile Improvements:**
- PWA for dashboards (offline access, install to home screen)
- Mobile skills app (limited subset, read-focused, no CLI required)
- Voice input on mobile (Whisper API)

---

## Accessibility (WCAG 2.1 AA)

### Accessibility Requirements

#### Color Contrast
- Text: 4.5:1 minimum (normal text)
- UI Components: 3:1 minimum (buttons, inputs)
- Brand colors validated for accessibility

#### Keyboard Navigation
- All interactive elements accessible via Tab
- Logical tab order (top-left to bottom-right)
- Skip links for long content
- Escape to cancel operations

#### Screen Reader Support
- Semantic HTML (header, nav, main, article, section)
- ARIA labels for custom components
- Alt text for images (including diagrams)
- Table headers for data tables

#### Voice Input Accessibility
- Alternative: Typing always available
- Clear error messages (no microphone, API failure)
- Retry options (poor transcription quality)
- No voice-only features (always have keyboard alternative)

### Accessibility Validation Plan

**Phase 1: Automated Testing (Days 4-5, 1 hour)**
- **Tool:** WAVE (Web Accessibility Evaluation Tool) browser extension
  - Run on: seven-fortunas.github.io, dashboards/ai/README.md (rendered), dashboard pages
  - Check: Color contrast, missing alt text, heading hierarchy, ARIA labels
  - Target: 0 errors, <5 warnings
- **Tool:** axe DevTools (Chrome/Firefox extension)
  - Run on: Same pages as WAVE
  - Check: WCAG 2.1 AA compliance
  - Target: 0 critical issues, <10 moderate issues
- **Tool:** Lighthouse Accessibility Audit (Chrome DevTools)
  - Run on: seven-fortunas.github.io, dashboard pages
  - Check: Overall accessibility score
  - Target: Score ≥90/100

**Phase 2: Manual Testing (Phase 1.5, 2-3 hours)**
- **Keyboard-Only Navigation (Jorge, 30 min):**
  - Unplug mouse, navigate site/CLI using only keyboard
  - Verify: Can access all features, tab order logical, focus indicators visible
  - Document: Any features inaccessible via keyboard
- **Screen Reader Testing (Jorge or volunteer, 1 hour):**
  - Tool: NVDA (Windows) or VoiceOver (Mac)
  - Test: Navigate Second Brain, read dashboard content, invoke skills
  - Verify: Content announced correctly, navigation makes sense, no confusing ARIA
- **Color Contrast Tool (Jorge, 30 min):**
  - Tool: Contrast Checker (WebAIM)
  - Test: All brand colors against white/black backgrounds
  - Verify: All combinations meet 4.5:1 (text) or 3:1 (UI)
- **Voice Input Alternative (Henry, 30 min):**
  - Test: Complete brand system creation using ONLY typing (no voice)
  - Verify: All voice features have keyboard/typing equivalent
  - Time: Should take <3x voice input time (typing is slower but functional)

**Phase 3: Ongoing Validation (Phase 2+)**
- **Monthly:** Re-run automated tests after major UI changes
- **Quarterly:** Full manual accessibility audit (keyboard, screen reader, contrast)
- **Before releases:** Accessibility checklist (automated + spot-check manual)

**Success Criteria:**
- Automated tools: 0 critical errors, <10 moderate issues total
- Manual testing: All features accessible via keyboard + screen reader
- Voice alternatives: 100% of voice features have keyboard equivalent
- Jorge (as accessibility validator): Rates accessibility 7+/10 on WCAG 2.1 AA compliance

---

## UX Documentation & Handoff

### Priority 1: Critical UX Requirements (MVP Non-Negotiable)

**1. README.md at Every Directory Level**
- **Minimum Content Requirements:**
  - Purpose (1-2 sentences: what this directory contains)
  - Contents (bullet list of subdirectories/files with brief descriptions)
  - Usage (how to find information, who uses this, common tasks)
  - Troubleshooting (optional: link to help if applicable)
- **Template:**
  ```markdown
  # [Directory Name]

  ## Purpose
  [1-2 sentence description]

  ## Contents
  - `subdir/` - [Description]
  - `file.md` - [Description]

  ## Usage
  [How to use this directory]

  ## Related
  - See also: [cross-references]
  ```
- **Validation:** Every directory has README.md with all 3 required sections (Purpose, Contents, Usage)

**2-8:** *(Existing requirements remain as stated)*
2. ✅ YAML frontmatter schema (context-level, relevant-for, last-updated)
3. ✅ Three-level hierarchy strict enforcement (never >3 deep)
4. ✅ Risk-based approval workflows (high-risk = type name to confirm)
5. ✅ Skill invocation consistency (same 5-step pattern across all skills)
6. ✅ Dashboard markdown structure (auto-generated, mobile-responsive)
7. ✅ Git commit conventions (Conventional Commits, Co-Authored-By: Claude)
8. ✅ Security feedback clarity (error messages actionable, no jargon)

### Priority 2: Nice-to-Have (Defer to Phase 1.5 / Phase 2)
1. Voice input integration (OpenAI Whisper) - Phase 1
2. Obsidian wikilink syntax support - Phase 2
3. Dashboard collapsible sections - Phase 2
4. Mobile responsive tables (horizontal scroll) - Phase 2
5. Custom CSS styling (beyond GitHub Pages default) - Phase 2
6. **Historical dashboard archives (>52 weeks) - Phase 2:**

**Archive Browsing UX Design (Phase 2):**
```
┌─────────────────────────────────────┐
│ 7F Lens > AI Advancements > Archive│
├─────────────────────────────────────┤
│ Browse by: [Week ▼] [Month] [Year] │
│                                     │
│ 📅 2026                             │
│  ├─ February                       │
│  │   ├─ Week 3 (Feb 15-21) ✓      │ ← Current week
│  │   ├─ Week 2 (Feb 8-14)         │
│  │   └─ Week 1 (Feb 1-7)          │
│  └─ January                        │
│      ├─ Week 4 (Jan 25-31)        │
│      └─ [Load More...]             │
│                                     │
│ Filter: [All] [Models] [Research]  │
│ Export: [CSV] [JSON]               │
└─────────────────────────────────────┘
```

**Features:**
- Time-series navigation (browse by week/month/year)
- Filter by category (models, research, tools, regulations)
- Compare: Select 2 weeks to compare changes
- Export: Download archive data as CSV/JSON
- Search: Full-text search across all archives
- Visualization: Trend charts (optional, Phase 3)
