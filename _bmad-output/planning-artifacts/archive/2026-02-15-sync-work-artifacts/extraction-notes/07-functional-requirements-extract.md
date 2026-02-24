# Extract: Functional Requirements Detailed

**Source:** `prd/functional-requirements-detailed.md`
**Date:** Not specified (part of PRD created Feb 13)
**Size:** 919 lines
**Author:** Part of PRD by Mary with Jorge

---

## Document Metadata
- **Purpose:** Detailed functional requirements across 7 capability areas
- **Format:** WHO/WHAT requirements with acceptance criteria
- **Total:** 28 functional requirements (FR-1.1 through FR-7.5)

---

## Key Content Summary

### Capability Overview (Lines 3-14)
**7 Core Capability Areas:**
1. GitHub Organization & Repository Management
2. BMAD Library & Skill System
3. Second Brain Knowledge Management
4. 7F Lens Intelligence Platform
5. Security & Compliance
6. User Profile & Voice Input
7. Autonomous Agent & Automation

---

### 1. GitHub Organization & Repository Management (Lines 17-95)

**FR-1.1: Organization Structure**
- 2 GitHub orgs (Seven-Fortunas public, Seven-Fortunas-Internal private)
- 10 teams (5 per org): Leadership, Engineering, AI/ML, Security, Content
- Team membership via GitHub CLI automation
- 2FA enforcement for all members

**FR-1.2: Repository Creation & Templates**
- Minimum 10 repositories with professional documentation
- Repository templates (public vs internal)
- Each repo includes: README.md, CLAUDE.md, .gitignore, LICENSE
- `7f-repo-template-generator` skill for creating new repos

**FR-1.3: Branch Protection & Access Control**
- Branch protection on all `main` branches (no force-push, require reviews)
- Team-based permissions (Leadership=Owner, Engineering=Maintain, Others=Write)
- Permission auditing via GitHub CLI
- Audit log for all access changes

---

### 2. BMAD Library & Skill System (Lines 97-276)

**FR-2.1: BMAD Library Deployment**
- BMAD v6.0.0 as Git submodule (pinned, no auto-updates)
- 18 BMAD skills symlinked to `.claude/commands/`
- Verify skills invocable via Claude Code
- Document usage in Second Brain

**FR-2.2: Adapted Skills (5 skills)**
- `brand-voice-generator` → `7f-brand-system-generator`
- `pptx-generator` → `7f-presentation-generator`
- `excalidraw-diagram` → `7f-diagram-generator`
- `sop-creator` → `7f-documentation-generator`
- `skill-creator` used as-is (meta-skill)

**FR-2.3: Custom Seven Fortunas Skills (3 skills)**
- `7f-manage-profile`: YAML profile creation/updates/queries
- `7f-dashboard-curator`: Dashboard configuration, data source management
- `7f-repo-template-generator`: Repository scaffolding

**FR-2.4: Skill Discoverability & Organization**
- Skill catalog in Second Brain (all 26 skills with descriptions, examples)
- `/bmad-help` command shows available skills
- Skills organized by category (Infrastructure, Security, Planning, Development, Content, Management)
- Skill tier/level (Tier 1: Production, Tier 2: Beta, Tier 3: Experimental)

**FR-2.5: Skill Governance & Lifecycle Management**
- Enhanced `skill-creator` searches existing skills BEFORE creating new
- Suggest enhancement vs new creation (>80% overlap = enhance)
- Skill tiers for governance (Tier 1/2/3)
- Usage tracking and stale skill flagging (0 usage in 90 days)

**FR-2.6: AI-First GitHub Operations (Foundation)**
- Foundation skills: `7f-create-repo`, `7f-add-member`
- Acceptance workflow patterns (Pattern A: High Risk=Approve first, Pattern B: Low Risk=Execute then review)
- Audit trail for all skill-based operations
- CLAUDE.md documents AI-first as "recommended approach" (MVP), "required" (Phase 1.5)

---

### 3. Second Brain Knowledge Management (Lines 278-399)

**FR-3.1: Directory Structure**
- Scaffolded structure: brand-system/, culture/, domain-expertise/, best-practices/, skills/, architecture/, profiles/, _bmad/, .claude/commands/
- README.md in each directory
- Obsidian vault compatibility
- Markdown-first documentation (no Word/PDFs)

**FR-3.2: Progressive Disclosure**
- Content organized by specificity (Level 1: Overview, Level 2: Domain, Level 3: Detail)
- YAML frontmatter for metadata (context-level, relevant-for, last-updated)
- AI agent queries ("Load brand context" → Returns brand-system/ overview)
- No duplicate content (reference existing docs)

**FR-3.3: Placeholder Content (MVP)**
- Generic placeholders for all directories
- All marked with TODO comments for founder refinement
- BRANDING_GUIDE.md for Henry with instructions
- No time wasted on visual design

**FR-3.4: User Profiles**
- YAML profile schema (name, role, communication_style, expertise, preferences)
- 4 founder profiles created
- `7f-manage-profile` skill for profile management
- AI agents can load profile context

---

### 4. 7F Lens Intelligence Platform (Lines 401-519)

**FR-4.1: AI Advancements Dashboard (MVP)**
- Data sources: RSS feeds (OpenAI, Anthropic, Google AI, Meta AI, arXiv), GitHub releases (LangChain, LlamaIndex), Reddit (r/MachineLearning, r/LocalLLaMA)
- Update every 6 hours via GitHub Actions cron
- Weekly AI summary using Claude API (Sundays)
- Structured markdown display in README.md
- Graceful degradation (if Reddit fails, continue with RSS/GitHub)

**FR-4.2: Dashboard Configuration**
- YAML configuration for data sources, update frequency, layout
- Config validation on save (URLs reachable, API keys present, syntax valid)
- `7f-dashboard-curator` skill for config management
- Configuration changes without redeploying workflows

**FR-4.3: Dashboard Automation**
- Workflow: `update-ai-dashboard.yml` (cron every 6 hours)
- Workflow: `weekly-ai-summary.yml` (cron Sundays 9am)
- GitHub Actions secrets (ANTHROPIC_API_KEY, REDDIT_CLIENT_ID, never commit)
- Workflow logs accessible for debugging

**FR-4.4: Future Dashboards (Post-MVP)**
- Templates: Fintech Trends, EduTech Intelligence, Security Intelligence, Infrastructure Health
- Deferred to Phase 2

---

### 5. Security & Compliance (Lines 521-638)

**FR-5.1: Secret Detection (Pre-Commit + GitHub)**
- Pre-commit hook using `detect-secrets` (API keys, tokens, passwords, private keys)
- GitHub secret scanning (scan every push, alert within minutes)
- Dual-layer protection (cannot bypass with --no-verify alone)
- Education documentation ("How to use GitHub Actions secrets")

**FR-5.2: Dependency Management (Dependabot)**
- Dependabot on all repos (security updates auto-PR, weekly version updates)
- Dependabot alerts (email, dashboard, severity-based triage)
- Patch process (Critical: 24 hours, High: 1 week, Medium/Low: next sprint)
- Track Dependabot PR merge rate (target >80%)

**FR-5.3: Code Scanning (CodeQL)**
- CodeQL on security-sensitive repos (JavaScript, Python, Go)
- Scan every pull request, block merge if critical vulnerabilities
- CodeQL queries (OWASP Top 10, optional custom queries)
- Clear remediation guidance (link to CWE, suggest fix, reference best practices)

**FR-5.4: Audit & Compliance**
- Log all events to Git history (commits, PRs, config changes)
- GitHub audit log (user invites, permission changes, repo operations)
- Support audit queries ("Who accessed repo X?", "When was Dependabot enabled?")
- SOC2 preparation (Phase 3: document controls, maintain audit trail, GitHub Enterprise)

---

### 6. User Profile & Voice Input (Lines 640-710)

**FR-6.1: Voice Input System (OpenAI Whisper)**
- Cross-platform installation (Linux native, macOS Homebrew, Windows WSL, web fallback for non-WSL/mobile)
- Integration with BMAD skills, brand generator, content creation
- Documentation (installation per platform, usage examples, troubleshooting)
- Graceful error handling (show transcription for review, allow editing, retry if poor quality)

**FR-6.2: User Onboarding**
- `7f-onboard-member` skill (create profile, grant access, assign teams, welcome message)
- Onboarding checklist (GitHub invitation, 2FA, clone repo, install voice input, complete profile, test skills)
- Onboarding tutorial (comprehensive guide, example workflows, Q&A)
- Track onboarding completion (time to productivity target <2 hours, blockers, feedback)

---

### 7. Autonomous Agent & Automation (Lines 712-899)

**FR-7.1: Autonomous Agent Infrastructure**
- Agent scripts (`run_autonomous.sh`, `run_autonomous_continuous.sh`, `agent.py`, `client.py`, `prompts.py`)
- Agent prompts (`initializer_prompt.md`, `coding_prompt.md`)
- Generate `app_spec.txt` from PRD
- Environment: ANTHROPIC_API_KEY, working directory, **GitHub CLI authenticated as `jorge-at-sf` (NOT `jorge-at-gd`) - CRITICAL**

**FR-7.2: Bounded Retry Logic**
- Max 3 attempts per feature (Attempt 1: initial, 2: alternative, 3: workaround, 4+: mark blocked)
- Track failures in `.issue_tracker_state.json` (feature_id, attempts, last_error, blocked_reason)
- Update `feature_list.json` when blocking (status="blocked", blocked_reason documented)
- Timeout features after 30 minutes

**FR-7.3: Testing Built Into Development Cycle**
- Test every implementation (GitHub org exists, repo created, file exists, JSON/YAML valid, submodule present, symlinks work)
- Mark "pass" ONLY when ALL tests succeed
- Commit changes ONLY after tests pass
- Log test results in `claude-progress.txt`

**FR-7.4: Progress Tracking**
- Generate `feature_list.json` (features with id, name, description, status, attempts, test_results)
- Update after each feature (status: pending → pass|fail|blocked, attempts increment, log test output)
- Session progress in `claude-progress.txt` (timestamps, implementations, errors, blocked features)
- Progress summary command (jq query to show pass/blocked/pending counts)

**FR-7.5: GitHub Actions Workflows (20+ workflows)**
- Security workflows (secret-scanning, dependency-scanning, code-scanning)
- Dashboard workflows (update-ai-dashboard, weekly-ai-summary)
- Testing workflows (test-skills, test-infrastructure)
- Maintenance workflows (sync-bmad, audit-compliance)

---

## Critical Information

**Total Functional Requirements: 28 (FR-1.1 through FR-7.5)**

**MVP Scope:**
- All 28 FRs must be implemented for MVP
- Each FR has specific acceptance criteria (checkboxes)
- Implementation-agnostic (describes WHAT, not HOW)

**Key Dependencies:**
- FR-2.x (BMAD & Skills) enables all user journeys
- FR-5.x (Security) is non-negotiable (Buck's aha moment)
- FR-7.x (Autonomous Agent) determines 60-70% completion rate (Jorge's aha moment)

**CRITICAL Requirement:**
- **FR-7.1.4:** GitHub CLI must be authenticated as `jorge-at-sf` (NOT `jorge-at-gd`) before ANY org operations
- Verification command: `gh auth status | grep jorge-at-sf`

**Skill Count Breakdown:**
- 18 BMAD skills (FR-2.1)
- 5 adapted skills (FR-2.2)
- 3 custom skills (FR-2.3)
- **Total: 26 operational skills**

**Phase 1.5 Additions (Not MVP):**
- FR-2.6 full implementation: AI-first GitHub operations with enforcement
- FR-5.4 enhancement: CISO Assistant integration for SOC 2

---

## Ambiguities / Questions

**Potential Conflict:** FR-2.4 mentions "26 skills total" but earlier docs said 25 skills. Need to verify final count with Jorge.

**GitHub Account Issue:** FR-7.1.4 specifies `jorge-at-sf` account but need to verify Jorge has this account set up.

---

## Related Documents
- Maps to User Journeys (each FR enables specific aha moments)
- Implements Innovation Analysis (AI-native, autonomous agent, BMAD-first)
- Supports Non-Functional Requirements (security, performance, maintainability)
- Traceable to Product Brief capabilities
