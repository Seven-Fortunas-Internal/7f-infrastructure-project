## Features & Requirements

### Capability Overview

Seven Fortunas infrastructure delivers **7 core capability areas** that enable AI-native enterprise operations:

1. **GitHub Organization & Repository Management** - Multi-org structure with security-first configuration
2. **BMAD Library & Skill System** - 26 operational skills for self-service AI collaboration
3. **Second Brain Knowledge Management** - Progressive disclosure architecture for AI agents and humans
4. **7F Lens Intelligence Platform** - Multi-dimensional dashboards tracking AI/fintech/edutech trends
5. **Security & Compliance** - Automated security controls and audit trails
6. **User Profile & Voice Input** - Personalization and natural language interaction
7. **Autonomous Agent & Automation** - Infrastructure orchestration and workflow automation

---

### 1. GitHub Organization & Repository Management

**WHO:** All founding team members, future team members, autonomous agent
**WHAT:** Multi-org GitHub infrastructure with consistent structure, security controls, and self-service capabilities

#### FR-1.1: Organization Structure

**Capability:** Create and manage two-org GitHub model (public + internal) with role-based team structure

**Requirements:**
- **FR-1.1.1:** System SHALL create two GitHub organizations:
  - `Seven-Fortunas` (public visibility)
  - `Seven-Fortunas-Internal` (private visibility)
- **FR-1.1.2:** System SHALL create 10 teams (5 per org) with defined roles:
  - Leadership, Engineering, AI/ML, Security, Content
- **FR-1.1.3:** System SHALL support team membership management via GitHub CLI automation
- **FR-1.1.4:** System SHALL enforce 2FA requirement for all organization members

**Acceptance:**
- [ ] Both organizations accessible via GitHub web UI
- [ ] 10 teams created with correct visibility settings
- [ ] 4 founding team members assigned to appropriate teams
- [ ] 2FA enforced (attempt to disable fails)

---

#### FR-1.2: Repository Creation & Templates

**Capability:** Generate repositories with consistent structure, documentation, and security configuration

**Requirements:**
- **FR-1.2.1:** System SHALL create minimum 10 repositories with professional documentation:
  - `seven-fortunas-brain` (Second Brain)
  - `dashboards` (7F Lens Platform)
  - `seven-fortunas.github.io` (public website)
  - `infrastructure-automation` (scripts, workflows)
  - 6+ additional repos (showcase, tools, examples)
- **FR-1.2.2:** System SHALL provide repository templates for:
  - Public repositories (LICENSE, CONTRIBUTING.md, CODE_OF_CONDUCT.md)
  - Internal repositories (SECURITY.md, ARCHITECTURE.md)
- **FR-1.2.3:** Each repository SHALL include:
  - Comprehensive README.md (purpose, setup, usage)
  - CLAUDE.md (agent instructions)
  - .gitignore (language-appropriate)
  - LICENSE file (appropriate for public/internal)
- **FR-1.2.4:** System SHALL support `7f-repo-template-generator` skill for creating new repos

**Acceptance:**
- [ ] 10 repositories created with all required files
- [ ] README.md in each repo explains purpose clearly
- [ ] CLAUDE.md provides agent guidance
- [ ] Templates reusable for future repo creation

---

#### FR-1.3: Branch Protection & Access Control

**Capability:** Enforce security policies and prevent destructive operations

**Requirements:**
- **FR-1.3.1:** System SHALL enable branch protection on all `main` branches:
  - No force-push allowed
  - Require pull request reviews (1+ approvals)
  - Require status checks to pass
  - Require linear history
- **FR-1.3.2:** System SHALL configure team-based permissions:
  - Leadership: Owner access
  - Engineering: Maintain access
  - AI/ML, Security, Content: Write access
- **FR-1.3.3:** System SHALL support permission auditing via GitHub CLI
- **FR-1.3.4:** System SHALL log all access changes to audit trail

**Acceptance:**
- [ ] Force-push to main fails (tested)
- [ ] Unauthorized access denied (tested)
- [ ] Audit log shows all permission changes
- [ ] Team permissions match intended roles

---

### 2. BMAD Library & Skill System

**WHO:** All founding team members (skill users), Jorge (skill creator), autonomous agent (skill executor)
**WHAT:** Self-service AI collaboration through 26 operational skills (18 BMAD + 5 adapted + 3 custom)

#### FR-2.1: BMAD Library Deployment

**Capability:** Deploy BMAD v6.0.0 with 18 production-tested workflows as Git submodule

**Requirements:**
- **FR-2.1.1:** System SHALL add BMAD as Git submodule:
  - Repository: `https://github.com/bmad-method/bmad-method.git`
  - Version: Pinned to `v6.0.0` (no auto-updates)
  - Location: `_bmad/` directory in seven-fortunas-brain repo
- **FR-2.1.2:** System SHALL create symlinks for 18 BMAD skills:
  - Location: `.claude/commands/bmad-*.md`
  - Target: `../../_bmad/[module]/workflows/[workflow]/workflow.md`
  - Skills: create-prd, create-story, code-review, sprint-planning, retrospective, etc.
- **FR-2.1.3:** System SHALL verify BMAD skills are invocable via Claude Code
- **FR-2.1.4:** System SHALL document BMAD skill usage in Second Brain

**Acceptance:**
- [ ] `git submodule status` shows `_bmad` at v6.0.0
- [ ] 18 symlinks created and functional
- [ ] `/bmad-bmm-create-prd` invocable in Claude Code
- [ ] Documentation lists available BMAD skills

---

#### FR-2.2: Adapted Skills (5 skills)

**Capability:** Adapt existing claude-code-second-brain-skills for Seven Fortunas branding and workflows

**Requirements:**
- **FR-2.2.1:** System SHALL adapt `brand-voice-generator` → `7f-brand-system-generator`:
  - Customize for digital inclusion domain
  - Output to `seven-fortunas-brain/brand-system/`
  - Generate: brand.json, config.json, brand-system.md, tone-of-voice.md
- **FR-2.2.2:** System SHALL adapt `pptx-generator` → `7f-presentation-generator`:
  - Load brand system from Second Brain
  - Support 16 slide layouts
  - Optional: Seven Fortunas pitch deck templates
- **FR-2.2.3:** System SHALL adapt `excalidraw-diagram` → `7f-diagram-generator`:
  - Customize color palette for Seven Fortunas brand
  - Add domain-specific patterns (workflow, architecture, org charts)
  - Output to Second Brain `architecture/` directory
- **FR-2.2.4:** System SHALL adapt `sop-creator` → `7f-documentation-generator`:
  - Output to `best-practices/` directory
  - Add Seven Fortunas branding
- **FR-2.2.5:** System SHALL use `skill-creator` as-is (meta-skill for creating custom skills)

**Acceptance:**
- [ ] Henry can invoke `/7f-brand-system-generator` and generate brand docs
- [ ] Patrick can invoke `/7f-diagram-generator` and create architecture diagrams
- [ ] Adapted skills output to correct Second Brain directories
- [ ] `skill-creator` used to guide custom skill creation

---

#### FR-2.3: Custom Seven Fortunas Skills (3 skills)

**Capability:** Create net-new skills specific to Seven Fortunas operations

**Requirements:**
- **FR-2.3.1:** System SHALL create `7f-manage-profile` skill:
  - YAML profile creation for new team members
  - Profile updates (communication style, expertise, preferences)
  - Profile queries (load context for AI agents)
  - Location: `seven-fortunas-brain/profiles/[username].yml`
- **FR-2.3.2:** System SHALL create `7f-dashboard-curator` skill:
  - Dashboard configuration (data sources, update frequency, layout)
  - Data source management (add/remove RSS feeds, GitHub repos, APIs)
  - Dashboard testing (validate data collection, API keys)
- **FR-2.3.3:** System SHALL create `7f-repo-template-generator` skill:
  - Repository scaffolding (CLAUDE.md, README, security config)
  - Support public vs. internal templates
  - Consistent structure across all repos

**Acceptance:**
- [ ] Jorge can create new team member profile using `/7f-manage-profile`
- [ ] Dashboard curator can add new data source to AI Dashboard
- [ ] Repo template generator creates consistent repo structure
- [ ] All 3 skills documented and tested

---

#### FR-2.4: Skill Discoverability & Organization

**Capability:** Make all 26 skills discoverable, documented, and accessible to team with intelligent organization

**Requirements:**
- **FR-2.4.1:** System SHALL provide skill catalog in Second Brain:
  - List all 26 skills with descriptions
  - Usage examples for each skill
  - Skill invocation syntax
  - Skill tier/level (Tier 1: Production, Tier 2: Beta, Tier 3: Experimental)
- **FR-2.4.2:** System SHALL support `/bmad-help` command to show available skills
- **FR-2.4.3:** System SHALL organize skills by category (like BMAD library):
  - **Infrastructure** (create-repo, add-member, update-permissions, configure-security) [Phase 1.5]
  - **Security & Compliance** (compliance-integration-guide) [Phase 1.5]
  - **Planning** (create-prd, create-story, sprint-planning) [BMAD]
  - **Development** (code-review, testing) [BMAD]
  - **Content** (brand-system, presentation, diagram, documentation) [MVP]
  - **Management** (manage-profile, dashboard-curator, repo-template) [MVP]
- **FR-2.4.4:** System SHALL verify all skills are symlinked in `.claude/commands/`

**Acceptance:**
- [ ] New team member can discover all skills by category
- [ ] `/bmad-help` lists skills with tier levels
- [ ] Skill catalog includes usage examples and tier classification
- [ ] All symlinks functional

---

#### FR-2.5: Skill Governance & Lifecycle Management

**Capability:** Prevent skill proliferation through intelligent skill creation and lifecycle management

**Requirements:**
- **FR-2.5.1:** System SHALL enhance `skill-creator` to search existing skills BEFORE creating new:
  - Query: "Create skill for adding GitHub team member"
  - Response: "Found existing skill: `7f-add-member`. Would you like to enhance it or create new?"
  - Search: BMAD library + Seven Fortunas custom skills
- **FR-2.5.2:** System SHALL suggest skill enhancements/modifications instead of net-new creation:
  - If 80%+ capability overlap, suggest modification
  - If <80% overlap, suggest new skill
  - Document enhancement rationale in skill metadata
- **FR-2.5.3:** System SHALL implement skill tiers for governance:
  - **Tier 1 (Production):** Tested, documented, reliable (18 BMAD skills, 8 Seven Fortunas MVP skills)
  - **Tier 2 (Beta):** Functional but needs validation (Phase 1.5 skills)
  - **Tier 3 (Experimental):** Proof-of-concept, use with caution
- **FR-2.5.4:** System SHALL track skill usage and flag stale skills:
  - Usage counter: Increment on each invocation
  - Stale threshold: 0 invocations in 90 days
  - Quarterly review: Deprecate or enhance stale skills

**Acceptance:**
- [ ] `skill-creator` searches existing skills before creating
- [ ] Skill enhancement suggested when >80% overlap
- [ ] All skills tagged with tier (1, 2, or 3)
- [ ] Usage tracking functional (test with mock invocations)
- [ ] Stale skill report generated (list skills with 0 usage in 90 days)

---

#### FR-2.6: AI-First GitHub Operations (Foundation)

**Capability:** Enable AI-first GitHub org management through dedicated skills (full enforcement Phase 1.5)

**Requirements (MVP Foundation):**
- **FR-2.6.1:** System SHALL create foundation GitHub operation skills:
  - `7f-create-repo` (create repository from template)
  - `7f-add-member` (invite team member, assign teams)
  - **Defer to Phase 1.5:** update-permissions, configure-security, create-team, archive-repo
- **FR-2.6.2:** System SHALL implement acceptance workflow patterns:
  - **Pattern A (High Risk):** AI suggests → Human approves → AI executes (repo deletion, permission changes)
  - **Pattern B (Low Risk):** AI executes → Human reviews (repo creation, team assignment)
  - Risk classification documented in skill metadata
- **FR-2.6.3:** System SHALL document AI-first approach in CLAUDE.md:
  - MVP: "Recommended approach" (manual UI still allowed)
  - Phase 1.5: "Required for Tier 1 operations" (manual UI discouraged)
  - Phase 2: "Enforced via audit alerts" (manual changes flagged for review)
- **FR-2.6.4:** System SHALL provide audit trail for all skill-based operations:
  - Log: Skill invocation, parameters, user, timestamp, result
  - Storage: GitHub commit messages (git log) + Second Brain `/audit/` directory

**Acceptance (MVP Foundation):**
- [ ] `7f-create-repo` skill creates repo with correct template
- [ ] `7f-add-member` skill invites user and assigns to teams
- [ ] Acceptance workflow patterns documented
- [ ] Audit log captures all skill invocations
- [ ] CLAUDE.md documents AI-first as "recommended approach"

**Full Implementation (Phase 1.5):**
- [ ] 10+ GitHub operation skills (extended coverage)
- [ ] RBAC-like permissions (some operations require skills)
- [ ] AI-first enforcement (manual UI discouraged, audit alerts enabled)

---

### 3. Second Brain Knowledge Management

**WHO:** All team members (knowledge consumers), AI agents (context loaders), content creators (knowledge authors)
**WHAT:** Progressive disclosure knowledge system with structured content for human and AI access

#### FR-3.1: Directory Structure

**Capability:** Scaffold Second Brain with consistent taxonomy and progressive disclosure architecture

**Requirements:**
- **FR-3.1.1:** System SHALL create directory structure:
  ```
  seven-fortunas-brain/
  ├── brand-system/       # Brand voice, values, messaging
  ├── culture/            # Mission, values, team rituals
  ├── domain-expertise/   # Tokenization, compliance, airgap security
  ├── best-practices/     # Runbooks, SOPs, procedures
  ├── skills/             # Custom Seven Fortunas skills
  ├── architecture/       # ADRs, technical specs, diagrams
  ├── profiles/           # Team member YAML profiles
  ├── _bmad/              # BMAD library (submodule)
  └── .claude/commands/   # Skill invocation symlinks
  ```
- **FR-3.1.2:** System SHALL create README.md in each directory explaining purpose
- **FR-3.1.3:** System SHALL support Obsidian vault compatibility (metadata, links)
- **FR-3.1.4:** System SHALL enforce markdown-first documentation (no Word docs, PDFs)

**Acceptance:**
- [ ] All directories created with README.md
- [ ] Directory structure matches specification
- [ ] Obsidian can open as vault
- [ ] All content in markdown format

---

#### FR-3.2: Progressive Disclosure

**Capability:** Load context only when needed to keep AI agent context efficient

**Requirements:**
- **FR-3.2.1:** System SHALL organize content by specificity levels:
  - Level 1 (Overview): README.md, index files (always loaded)
  - Level 2 (Domain): Category directories (loaded when relevant)
  - Level 3 (Detail): Specific documents (loaded on-demand)
- **FR-3.2.2:** System SHALL use YAML frontmatter for metadata:
  - `context-level`: overview | domain | detail
  - `relevant-for`: [list of skill names or domains]
  - `last-updated`: ISO date
- **FR-3.2.3:** System SHALL support AI agent queries:
  - "Load brand context" → Returns brand-system/ overview
  - "Load tokenization expertise" → Returns domain-expertise/tokenization/
- **FR-3.2.4:** System SHALL avoid duplicate content (reference existing docs, don't copy)

**Acceptance:**
- [ ] AI agent can load overview without full content
- [ ] YAML frontmatter consistent across docs
- [ ] No duplicate content found (test with grep)
- [ ] Context queries return correct content

---

#### FR-3.3: Placeholder Content (MVP)

**Capability:** Scaffold Second Brain with placeholder content for autonomous agent, to be refined by founders

**Requirements:**
- **FR-3.3.1:** System SHALL generate placeholder content:
  - Brand system (generic colors, tone, values)
  - Culture docs (mission placeholder, values placeholder)
  - Domain expertise (directory structure, no detailed content)
  - Best practices (example SOP, runbook templates)
- **FR-3.3.2:** System SHALL mark all placeholder content with comments:
  - `<!-- TODO: Replace with real Seven Fortunas branding (Henry will provide) -->`
- **FR-3.3.3:** System SHALL create `BRANDING_GUIDE.md` for Henry:
  - Instructions for replacing placeholder content
  - Brand system generator usage
  - Content refinement workflow
- **FR-3.3.4:** System SHALL NOT spend time on visual design (focus on functionality)

**Acceptance:**
- [ ] Placeholder content in all directories
- [ ] All placeholders marked with TODO comments
- [ ] BRANDING_GUIDE.md exists with instructions
- [ ] No time wasted on visual design

---

#### FR-3.4: User Profiles

**Capability:** YAML-based profiles for AI agent personalization (load user context, communication style, expertise)

**Requirements:**
- **FR-3.4.1:** System SHALL define YAML profile schema:
  ```yaml
  name: "Henry"
  github_username: "henry_7f"
  role: "CEO"
  communication_style:
    - Strategic thinker
    - Prefers voice input
    - Values brevity
  expertise:
    - Fundraising
    - Brand strategy
    - Digital inclusion
  preferences:
    - Voice input preferred over typing
    - AI collaboration for content generation
    - Weekly investor updates
  ```
- **FR-3.4.2:** System SHALL create profiles for 4 founding team members
- **FR-3.4.3:** System SHALL support `7f-manage-profile` skill for profile management
- **FR-3.4.4:** System SHALL enable AI agents to load profile context:
  - "Who is Henry?" → Returns profile YAML
  - "How does Buck prefer communication?" → Returns communication_style

**Acceptance:**
- [ ] 4 founder profiles created
- [ ] Schema documented
- [ ] AI agents can load profile context
- [ ] `7f-manage-profile` skill functional

---

### 4. 7F Lens Intelligence Platform

**WHO:** Leadership team (strategic insights), Jorge (infrastructure monitoring), future team (trend analysis)
**WHAT:** Multi-dimensional dashboards tracking AI advancements, fintech trends, edutech landscape (MVP: AI Advancements only)

#### FR-4.1: AI Advancements Dashboard (MVP)

**Capability:** Auto-updating dashboard tracking AI research, framework releases, community sentiment

**Requirements:**
- **FR-4.1.1:** System SHALL aggregate data from:
  - RSS feeds: OpenAI Blog, Anthropic Blog, Google AI Blog, Meta AI Blog, arXiv (AI category)
  - GitHub releases: LangChain, LlamaIndex, AutoGen, CrewAI
  - Reddit: r/MachineLearning, r/LocalLLaMA (top posts)
- **FR-4.1.2:** System SHALL update dashboard every 6 hours via GitHub Actions cron
- **FR-4.1.3:** System SHALL generate weekly AI summary using Claude API (Sundays)
- **FR-4.1.4:** System SHALL display data in structured markdown:
  - README.md in dashboards repo
  - Sections: Recent Research, Framework Updates, Community Highlights, Weekly Summary
- **FR-4.1.5:** System SHALL handle API failures gracefully:
  - If Reddit API unavailable, continue with RSS and GitHub
  - Log errors to GitHub Actions logs

**Acceptance:**
- [ ] Dashboard auto-updates every 6 hours
- [ ] Data collected from all configured sources
- [ ] Weekly AI summary generated on Sundays
- [ ] Graceful degradation when API fails
- [ ] README.md shows live data

---

#### FR-4.2: Dashboard Configuration

**Capability:** Configure data sources, update frequency, and layout via `7f-dashboard-curator` skill

**Requirements:**
- **FR-4.2.1:** System SHALL support YAML configuration:
  ```yaml
  dashboard_name: "AI Advancements"
  update_frequency: "6 hours"
  data_sources:
    - type: rss
      url: "https://openai.com/blog/rss.xml"
      limit: 5
    - type: github_releases
      repo: "langchain-ai/langchain"
      limit: 3
    - type: reddit
      subreddit: "MachineLearning"
      sort: "hot"
      limit: 10
  ```
- **FR-4.2.2:** System SHALL validate configuration on save:
  - URLs reachable
  - API keys present (if required)
  - Syntax valid
- **FR-4.2.3:** System SHALL support `7f-dashboard-curator` skill for config management
- **FR-4.2.4:** System SHALL apply configuration changes without redeploying workflows

**Acceptance:**
- [ ] YAML config validated on save
- [ ] Dashboard curator skill can add data source
- [ ] Configuration changes applied without redeploy
- [ ] Invalid config shows clear error message

---

#### FR-4.3: Dashboard Automation

**Capability:** GitHub Actions workflows for data collection, summarization, and display

**Requirements:**
- **FR-4.3.1:** System SHALL create workflow: `update-ai-dashboard.yml`
  - Trigger: Cron every 6 hours
  - Collect data from all configured sources
  - Update README.md with new data
  - Commit changes to repo
- **FR-4.3.2:** System SHALL create workflow: `weekly-ai-summary.yml`
  - Trigger: Cron every Sunday 9am
  - Fetch past 7 days of AI news
  - Call Claude API for summarization
  - Append summary to README.md
- **FR-4.3.3:** System SHALL handle GitHub Actions secrets:
  - ANTHROPIC_API_KEY (for Claude summarization)
  - REDDIT_CLIENT_ID (if Reddit API requires auth)
  - Never commit secrets to repo
- **FR-4.3.4:** System SHALL log all workflow runs to GitHub Actions

**Acceptance:**
- [ ] Cron triggers run on schedule
- [ ] Data collection workflow succeeds
- [ ] Weekly summary workflow generates summary
- [ ] Secrets stored in GitHub Actions, not repo
- [ ] Workflow logs accessible for debugging

---

#### FR-4.4: Future Dashboards (Post-MVP)

**Capability:** Add additional dashboards for fintech, edutech, security, infrastructure health

**Requirements:**
- **FR-4.4.1:** System SHALL support dashboard templates for:
  - Fintech Trends (payments, tokenization, DeFi)
  - EduTech Intelligence (EduPeru market, competitors)
  - Security Intelligence (threats, compliance)
  - Infrastructure Health (inward-looking, AI-based)
- **FR-4.4.2:** System SHALL enable creating new dashboard via `7f-dashboard-curator`
- **FR-4.4.3:** System SHALL reuse automation workflows (same pattern as AI Dashboard)
- **FR-4.4.4:** System SHALL support historical data analysis (12+ months)

**Acceptance:**
- [ ] Dashboard templates defined
- [ ] Curator skill can create new dashboard
- [ ] Automation workflow reusable
- [ ] Deferred to Phase 2 (not MVP)

---

### 5. Security & Compliance

**WHO:** Buck (security validation), all team members (security compliance), automated systems (security enforcement)
**WHAT:** Automated security controls, secret detection, vulnerability management, audit trails

#### FR-5.1: Secret Detection (Pre-Commit + GitHub)

**Capability:** Prevent secrets from being committed to repositories (100% detection rate)

**Requirements:**
- **FR-5.1.1:** System SHALL enable pre-commit hook using `detect-secrets`:
  - Install in all repos via `.pre-commit-config.yaml`
  - Scan for API keys, tokens, passwords, private keys
  - Block commit if secrets detected
  - Provide clear error message with line number
- **FR-5.1.2:** System SHALL enable GitHub secret scanning:
  - Scan every push for leaked credentials
  - Alert within minutes if secret detected
  - Support custom secret patterns (Seven Fortunas-specific)
- **FR-5.1.3:** System SHALL enforce dual-layer protection:
  - Layer 1: Pre-commit hook (local)
  - Layer 2: GitHub Actions check (server-side)
  - Cannot bypass with `--no-verify` alone (GitHub Actions catches)
- **FR-5.1.4:** System SHALL educate users on secret management:
  - Documentation: "How to use GitHub Actions secrets"
  - CLAUDE.md instructions: "NEVER commit secrets"

**Acceptance:**
- [ ] Buck's test: Commit secret → BLOCKED by pre-commit hook
- [ ] Buck's test: Bypass hook with --no-verify → BLOCKED by GitHub Actions
- [ ] Buck's test: Base64-encoded secret → CAUGHT by GitHub scanning
- [ ] Documentation explains secret management

---

#### FR-5.2: Dependency Management (Dependabot)

**Capability:** Automated vulnerability scanning and dependency updates

**Requirements:**
- **FR-5.2.1:** System SHALL enable Dependabot on all repos:
  - Security updates: Auto-create PRs for vulnerabilities
  - Version updates: Weekly PRs for outdated dependencies
  - Support: npm, pip, GitHub Actions, Docker
- **FR-5.2.2:** System SHALL configure Dependabot alerts:
  - Email notifications to team
  - GitHub dashboard visibility
  - Severity-based triage (critical → high → medium → low)
- **FR-5.2.3:** System SHALL establish patch process:
  - Critical: Patch within 24 hours
  - High: Patch within 1 week
  - Medium/Low: Patch in next sprint
- **FR-5.2.4:** System SHALL track Dependabot PR merge rate (target: >80% merged within SLA)

**Acceptance:**
- [ ] Dependabot enabled on all repos
- [ ] Test vulnerability detected and PR created
- [ ] Alerts sent to team email
- [ ] Patch process documented

---

#### FR-5.3: Code Scanning (CodeQL)

**Capability:** Automated vulnerability detection for OWASP Top 10 (XSS, SQL injection, etc.)

**Requirements:**
- **FR-5.3.1:** System SHALL enable CodeQL on security-sensitive repos:
  - Languages: JavaScript, Python, Go (based on repo content)
  - Scan every pull request
  - Block merge if critical vulnerabilities found
- **FR-5.3.2:** System SHALL configure CodeQL queries:
  - Standard queries: OWASP Top 10
  - Custom queries: Seven Fortunas-specific patterns (optional)
- **FR-5.3.3:** System SHALL provide clear remediation guidance:
  - Link to CWE documentation
  - Suggest code fix
  - Reference best practices from Second Brain
- **FR-5.3.4:** System SHALL track CodeQL findings:
  - Dashboard: Open findings by severity
  - Trend: Findings over time (decreasing = improving)

**Acceptance:**
- [ ] CodeQL enabled on applicable repos
- [ ] Test vulnerability detected and PR blocked
- [ ] Remediation guidance clear
- [ ] Dashboard shows findings

---

#### FR-5.4: Audit & Compliance

**Capability:** Immutable audit trail for all infrastructure changes, access control, and security events

**Requirements:**
- **FR-5.4.1:** System SHALL log all events to Git history:
  - Commits (who, when, what)
  - Pull requests (reviewers, approvals)
  - Configuration changes (branch protection, team permissions)
- **FR-5.4.2:** System SHALL enable GitHub audit log (Organization settings):
  - Track: User invites, permission changes, repo creation/deletion
  - Retention: 90 days (GitHub Free tier), export for longer retention
- **FR-5.4.3:** System SHALL support audit queries:
  - "Who accessed repo X in past 30 days?"
  - "When was Dependabot enabled on repo Y?"
  - "All permission changes for user Z"
- **FR-5.4.4:** System SHALL prepare for SOC2 compliance (Phase 3):
  - Document security controls
  - Maintain audit trail
  - GitHub Enterprise tier (SOC1/SOC2 reporting)

**Acceptance:**
- [ ] Git history shows all commits and PRs
- [ ] Audit log accessible via GitHub UI
- [ ] Audit queries answerable
- [ ] SOC2 preparation documented (deferred to Phase 3)

---

### 6. User Profile & Voice Input

**WHO:** All team members (users), AI agents (context loaders)
**WHAT:** Personalization through YAML profiles and natural language interaction via voice input

#### FR-6.1: Voice Input System (OpenAI Whisper)

**Capability:** Cross-platform speech-to-text for rapid content generation and AI collaboration

**Requirements:**
- **FR-6.1.1:** System SHALL provide OpenAI Whisper installation:
  - Linux: Native installation via apt/yum
  - macOS: Homebrew installation
  - Windows (WSL): Linux installation in WSL
  - Windows (non-WSL): Web fallback (browser-based)
  - Mobile: Web fallback (browser-based)
- **FR-6.1.2:** System SHALL support voice input integration:
  - BMAD skills (conversational inputs)
  - Brand system generator (voice responses)
  - Content creation (blog posts, docs)
- **FR-6.1.3:** System SHALL document voice input usage:
  - Installation guide per platform
  - Usage examples (skill invocation, content generation)
  - Troubleshooting common issues
- **FR-6.1.4:** System SHALL handle transcription errors gracefully:
  - Show transcription for user review
  - Allow editing before submission
  - Retry if transcription quality poor

**Acceptance:**
- [ ] Henry can use voice input on macOS for brand generation
- [ ] Voice input works on Linux (Jorge's environment)
- [ ] Web fallback functional for Windows/mobile
- [ ] Documentation covers all platforms

---

#### FR-6.2: User Onboarding

**Capability:** Structured onboarding process for new team members (7f-onboard-member skill)

**Requirements:**
- **FR-6.2.1:** System SHALL provide `7f-onboard-member` skill:
  - Create user profile (YAML)
  - Grant GitHub org access
  - Assign to appropriate teams
  - Provide welcome message with next steps
- **FR-6.2.2:** System SHALL create onboarding checklist:
  - [ ] GitHub invitation accepted
  - [ ] 2FA enabled
  - [ ] Clone second-brain repo
  - [ ] Install voice input (optional)
  - [ ] Run `/7f-onboard-member` skill
  - [ ] Complete profile (communication style, expertise, preferences)
  - [ ] Test skill invocation (try `/bmad-help`)
- **FR-6.2.3:** System SHALL provide onboarding tutorial:
  - Comprehensive guide using as many skills as possible
  - Example workflows (generate brand content, create presentation, review code)
  - Q&A section for common questions
- **FR-6.2.4:** System SHALL track onboarding completion:
  - Time to productivity (target: < 2 hours)
  - Blockers encountered
  - Feedback for improvement

**Acceptance:**
- [ ] New team member completes onboarding in < 2 hours
- [ ] Onboarding checklist all items complete
- [ ] Tutorial guides through key skills
- [ ] Feedback collected for iteration

---

### 7. Autonomous Agent & Automation

**WHO:** Jorge (agent operator), autonomous agent (infrastructure builder), team (automation beneficiaries)
**WHAT:** Claude Code SDK autonomous agent with bounded retries, testing built-in, progress tracking

#### FR-7.1: Autonomous Agent Infrastructure

**Capability:** Claude Code SDK setup with two-agent pattern (initializer + coding)

**Requirements:**
- **FR-7.1.1:** System SHALL create agent scripts:
  - `scripts/run_autonomous.sh` (single-session launcher)
  - `scripts/run_autonomous_continuous.sh` (multi-session launcher)
  - `scripts/agent.py` (Claude SDK agent runner)
  - `scripts/client.py` (SDK client configuration)
  - `scripts/prompts.py` (prompt loading utilities)
- **FR-7.1.2:** System SHALL create agent prompts:
  - `prompts/initializer_prompt.md` (Session 1: feature_list.json generation)
  - `prompts/coding_prompt.md` (Sessions 2+: feature implementation)
- **FR-7.1.3:** System SHALL generate `app_spec.txt` from PRD:
  - Feature list with implementation details
  - Acceptance criteria per feature
  - Dependencies and priorities
- **FR-7.1.4:** System SHALL configure agent environment:
  - ANTHROPIC_API_KEY (Claude Code API key)
  - Working directory: `/home/ladmin/seven-fortunas-workspace/7f-infrastructure-project`
  - **GitHub CLI authenticated as `jorge-at-sf` (NOT `jorge-at-gd`)**
  - **CRITICAL:** Verify GitHub account before ANY org operations: `gh auth status | grep jorge-at-sf`

**Acceptance:**
- [ ] Agent scripts executable
- [ ] Prompts loaded correctly
- [ ] app_spec.txt generated from PRD
- [ ] Environment configured (API key, working dir)
- [ ] **GitHub CLI account verified: `jorge-at-sf` (CRITICAL CHECK)**

---

#### FR-7.2: Bounded Retry Logic

**Capability:** Prevent infinite loops and hallucinations through max 3 attempts per feature

**Requirements:**
- **FR-7.2.1:** System SHALL implement retry logic:
  - Attempt 1: Initial approach (as specified in app_spec.txt)
  - Attempt 2: Alternative approach (different API, different tool)
  - Attempt 3: Workaround or minimal implementation
  - Attempt 4+: Mark as "blocked", log issue, move to next feature
- **FR-7.2.2:** System SHALL track failures in `.issue_tracker_state.json`:
  ```json
  {
    "F015": {
      "feature_id": "F015",
      "feature_name": "Enable X API integration",
      "attempts": 3,
      "last_error": "HTTP 401: X API requires paid account",
      "blocked": true,
      "blocked_reason": "Needs human to authorize X API key"
    }
  }
  ```
- **FR-7.2.3:** System SHALL update `feature_list.json` when blocking:
  ```json
  {
    "id": "F015",
    "name": "Enable X API integration",
    "status": "blocked",
    "blocked_reason": "X API requires paid account, needs human authorization",
    "attempts": 3
  }
  ```
- **FR-7.2.4:** System SHALL timeout features after 30 minutes (prevents stuck loops)

**Acceptance:**
- [ ] Feature fails 3 times → Marked "blocked"
- [ ] No feature has >3 attempts in logs
- [ ] Blocked features documented with clear reason
- [ ] Agent moves to next feature (doesn't get stuck)

---

#### FR-7.3: Testing Built Into Development Cycle

**Capability:** No feature marked "pass" without passing tests (structural, functional, syntactic)

**Requirements:**
- **FR-7.3.1:** System SHALL test every implementation:
  - GitHub org exists: `gh api /orgs/Seven-Fortunas` (HTTP 200)
  - Repo created: `gh repo view Seven-Fortunas/dashboards` (no error)
  - File exists: `ls -la path/to/file` (file listed)
  - JSON valid: `python -m json.tool file.json` (no syntax errors)
  - YAML valid: `yamllint file.yml` (no errors)
  - BMAD submodule: `git submodule status` (shows _bmad)
  - Symlinks work: `ls -la .claude/commands/bmad-*` (symlinks listed)
- **FR-7.3.2:** System SHALL mark feature as "pass" ONLY when ALL tests succeed
- **FR-7.3.3:** System SHALL commit changes ONLY after tests pass:
  ```bash
  # Run tests
  ./scripts/test_feature.sh F015
  # If tests pass, commit
  git add .
  git commit -m "feat(F015): Implement X feature"
  ```
- **FR-7.3.4:** System SHALL log test results in `claude-progress.txt`

**Acceptance:**
- [ ] Feature with failing tests NOT marked "pass"
- [ ] All "pass" features have passed tests (verified in logs)
- [ ] Commits only happen after tests pass
- [ ] Test results logged

---

#### FR-7.4: Progress Tracking

**Capability:** Monitor autonomous agent progress via `feature_list.json` and `claude-progress.txt`

**Requirements:**
- **FR-7.4.1:** System SHALL generate `feature_list.json`:
  ```json
  {
    "features": [
      {
        "id": "F001",
        "name": "Create GitHub organizations",
        "description": "Create Seven-Fortunas (public) and Seven-Fortunas-Internal (private) orgs",
        "status": "pass",
        "attempts": 1,
        "test_results": "✅ All tests passed"
      },
      {
        "id": "F002",
        "name": "Deploy BMAD library",
        "status": "pending",
        "attempts": 0
      }
    ]
  }
  ```
- **FR-7.4.2:** System SHALL update `feature_list.json` after each feature:
  - Status: pending → pass | fail | blocked
  - Attempts: Increment on each try
  - Test results: Log test output
- **FR-7.4.3:** System SHALL log session progress in `claude-progress.txt`:
  - Session start/end timestamps
  - Feature implementations (which, status, duration)
  - Errors and warnings
  - Blocked features with reasons
- **FR-7.4.4:** System SHALL provide progress summary command:
  ```bash
  cat feature_list.json | jq '.features | group_by(.status) | map({status: .[0].status, count: length})'
  # Output: [{"status":"pass","count":18},{"status":"blocked","count":3},{"status":"pending","count":7}]
  ```

**Acceptance:**
- [ ] feature_list.json updated after each feature
- [ ] Progress summary shows 60-70% "pass" rate (MVP target)
- [ ] claude-progress.txt logs all sessions
- [ ] Blocked features documented with clear reasons

---

#### FR-7.5: GitHub Actions Workflows (20+ workflows)

**Capability:** Automate security scanning, dashboard updates, testing, and infrastructure maintenance

**Requirements:**
- **FR-7.5.1:** System SHALL create security workflows:
  - `secret-scanning.yml` (detect secrets in commits)
  - `dependency-scanning.yml` (Dependabot alerts)
  - `code-scanning.yml` (CodeQL for vulnerabilities)
- **FR-7.5.2:** System SHALL create dashboard workflows:
  - `update-ai-dashboard.yml` (every 6 hours)
  - `weekly-ai-summary.yml` (Sundays)
- **FR-7.5.3:** System SHALL create testing workflows:
  - `test-skills.yml` (validate BMAD and custom skills)
  - `test-infrastructure.yml` (validate repos, orgs, permissions)
- **FR-7.5.4:** System SHALL create maintenance workflows:
  - `sync-bmad.yml` (check for BMAD updates, alert if new version)
  - `audit-compliance.yml` (export audit logs monthly)

**Acceptance:**
- [ ] 20+ workflows created across all repos
- [ ] Security workflows run on every push
- [ ] Dashboard workflows run on schedule
- [ ] Workflow failures send notifications

---

### Functional Requirements Summary

**Total Capabilities:** 28 functional requirements across 7 capability areas

**Coverage:**
- ✅ All 4 user journeys supported (Henry, Patrick, Buck, Jorge)
- ✅ All innovation areas implemented (AI-native, autonomous agent, BMAD-first)
- ✅ All security requirements enforced (secret detection, Dependabot, CodeQL, audit)
- ✅ All MVP features included (28 features from Scoping section)

**Validation:**
- Each FR includes acceptance criteria (testable)
- Implementation-agnostic (WHO and WHAT, not HOW)
- Traceable to user journeys and success criteria
- Complete capability contract for downstream work (stories, sprints, implementation)

---

