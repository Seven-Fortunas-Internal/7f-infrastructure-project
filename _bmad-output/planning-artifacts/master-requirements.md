---
title: Requirements Master Document
type: Master Document (2 of 6)
sources:
  - prd/prd.md
  - prd/functional-requirements-detailed.md
  - prd/nonfunctional-requirements-detailed.md
  - prd/user-journeys.md
  - domain-requirements.md
date: 2026-02-15
author: Mary (Business Analyst) with Jorge
status: Phase 2 - Master Consolidation
version: 1.10.0
role-corrections: Buck/Jorge responsibilities clarified per Jorge's guidance (2026-02-15)
editorial-review: Complete (structure + prose + adversarial, 2026-02-15)
phase-2-additions: 5 new FRs added (FR-8.1 through FR-8.5, 2026-02-15)
consolidation-expansion: 10 NFRs added during consolidation (24 original → 34 current, better granularity from category-based to numbered system, 2026-02-15)
validation-corrections: Requirement counts corrected (64 → 67 total, 31 NFRs → 34 NFRs, 2026-02-16)
ui-requirements-clarification: FR-4.1 and FR-1.5 acceptance criteria updated to explicitly require React 18.x UI and GitHub Pages deployment (aligned with master-ux-specifications.md and master-architecture.md, 2026-02-18)
phase1-completion: T1→T4 deployment verification standard added; FR-1.5, FR-2.4, FR-3.2, FR-4.1 acceptance criteria strengthened with live URL + asset verification after Phase 1 agent review revealed deployment gaps (2026-02-23)
gap-analysis-corrections: FR-4.1 and FR-4.2 updated after gap audit of live dashboards/ai implementation (2026-02-24); added verifiable ACs for 1024px breakpoint, touch targets, next-update display, all-sources-failure UI, sources.yaml path (ai/config/), Reddit source (r/LocalLLaMA), 7-day cache staleness; FR-4.2 expanded with explicit workflow file, data source path, summaries directory, ANTHROPIC_API_KEY requirement
ci-cd-authoring-standards: NFR-5.6 added (GitHub Actions authoring constraints validated from live CI failures 2026-02-25); NFR-1.1 amended (toolchain version consistency + exclusion patterns); NFR-6.3 amended (lock file prerequisites for dependabot/npm); NFR count 35 → 36 (2026-02-25)
version: 1.13.0
---

# Requirements Master Document

**Contract Compliance:** ✅ Per DOCUMENT-SYNC-EXECUTION-PLAN.md Phase 2, Section 2b
**Zero Information Loss:** All FRs/NFRs from source documents consolidated
**Cross-References:** → [master-ux-specifications.md](master-ux-specifications.md) for UX requirements

---

## Executive Summary

**Total Requirements:** 68 (33 Functional + 35 Non-Functional)
**MVP Requirements:** 28 FRs (Phase 0-1)
**Phase 2 Requirements:** 5 FRs (Collaboration & Project Management)
**NFR Expansion:** Original 24 NFRs expanded to 35 during consolidation + Phase 1 completion (category-based → numbered system; NFR-4.4 T1→T4 web deployment standard added 2026-02-23)
**MVP Timeline:** 5-7 days (Days 1-5, +2 days buffer)
**Autonomous Completion Target:** 60-70% (18-25 of 28 MVP features)
**Quality Gate:** Zero critical security failures

**Stakeholder Responsibilities:** See [master-product-strategy.md](master-product-strategy.md) for founding team roles and responsibilities

---

## Functional Requirements (33 Total: 28 MVP + 5 Phase 2)

### FR Category 1: GitHub Organization & Permissions (6 FRs)

**FR-1.4: GitHub CLI Authentication Verification** ✅ CRITICAL - **BLOCKING ALL GITHUB OPERATIONS**
- **Requirement:** System SHALL verify GitHub CLI is authenticated as `jorge-at-sf` (NOT `jorge-at-gd`) before ANY GitHub operations
- **Rationale:** Wrong account creates orgs under incorrect ownership
- **Enforcement Mechanism:**
  - Pre-flight validation script: `./scripts/validate_github_auth.sh` (TO BE CREATED in Day 0)
  - Script checks: `gh auth status 2>&1 | grep -q "jorge-at-sf"`
  - Exit code 0 = authenticated correctly, non-zero = authentication failure
  - All automation scripts (GitHub repo creation, org setup) call this script first
  - Script failure blocks execution with error: "GitHub CLI not authenticated as jorge-at-sf. Run: gh auth switch --user jorge-at-sf"
  - **Creation Responsibility:** Jorge creates script during Day 0 Foundation phase (15 min, see master-implementation.md)
- **Acceptance Criteria:**
  - ✅ `validate_github_auth.sh` script exists and is executable
  - ✅ Script correctly identifies jorge-at-sf authentication (exit 0)
  - ✅ Script correctly rejects other accounts (exit 1 with clear error)
  - ✅ All automation scripts source this validation before GitHub API calls
  - ✅ Autonomous agent startup script includes pre-flight validation
  - ✅ Verification check documented in autonomous-workflow-guide.md
  - ✅ Manual override requires explicit `--force-account` flag (logged for audit)
- **Priority:** P0 (MVP Day 0) - **BLOCKING ALL GITHUB OPERATIONS**
- **Owner:** Jorge (script creation + manual verification before agent starts)
- **Status:** ✅ CORRECTED in Phase 1 (Autonomous Workflow Guide updated)

**FR-1.1: Create GitHub Organizations**
- **Requirement:** System SHALL create two GitHub organizations: Seven-Fortunas (public) and Seven-Fortunas-Internal (private)
- **Organization Profile Configuration:**
  - **Name:** Seven-Fortunas / Seven-Fortunas-Internal
  - **Display name:** Seven Fortunas / Seven Fortunas (Internal)
  - **Description:** "AI-native digital inclusion platform | Building the future of accessible fintech & edutech" / "Private infrastructure & operations"
  - **Website:** https://seven-fortunas.github.io / (none)
  - **Email:** contact@sevenfortunas.com / (none - internal only)
  - **Location:** San Francisco, CA & Lima, Peru
  - **Logo:** 7F brand mark (to be uploaded by Henry in Phase 1, Day 3; if not uploaded, placeholder "7F" text logo used until available)
  - **README:** .github/profile/README.md (org landing page with mission, values, key projects)
- **Acceptance Criteria:**
  - ✅ Seven-Fortunas org exists with public visibility
  - ✅ Seven-Fortunas-Internal org exists with private visibility
  - ✅ Both orgs have ALL profile fields populated per specification above
  - ✅ Both orgs have .github repo with templates and community health files
  - ✅ Organization README renders correctly on org homepage
- **Priority:** P0 (MVP Day 1)
- **Owner:** Jorge (automated via autonomous agent)

**FR-1.2: Configure Team Structure**
- **Requirement:** System SHALL create 10 teams (5 per org) representing functional areas
- **Teams (Public Org):** Public BD, Public Marketing, Public Engineering, Public Operations, Public Community
- **Teams (Private Org):** BD, Marketing, Engineering, Finance, Operations
- **Acceptance Criteria:**
  - ✅ All 10 teams created with descriptions
  - ✅ Teams have correct default repository access (none, read, write)
  - ✅ Founding team members assigned to appropriate teams
- **Priority:** P0 (MVP Day 1)
- **Owner:** Jorge (automated via autonomous agent)

**FR-1.3: Configure Organization Security Settings**
- **Requirement:** System SHALL enforce security policies at organization level
- **Acceptance Criteria:**
  - ✅ 2FA required for all members (enforced)
  - ✅ Dependabot enabled (security updates + version updates)
  - ✅ Secret scanning enabled with push protection
  - ✅ Default repository permission set to "none" (explicit grants required)
  - ✅ Branch protection configured for all main branches
- **Priority:** P0 (MVP Day 1) - **MOST CRITICAL SECURITY REQUIREMENT**
- **Owner:** Jorge (automated via autonomous agent, tested by Jorge in security testing)

**FR-1.5: Repository Creation & Documentation**
- **Requirement:** System SHALL create 10 repositories (8 MVP + 2 Phase 1.5) with professional documentation, extensible to additional repos in later phases
- **MVP Repositories (8 - Days 1-2):**
  1. **.github** (both orgs) - Org profile, issue/PR templates, reusable workflows
  2. **seven-fortunas.github.io** (public) - Landing page, blog, public documentation
  3. **dashboards** (public) - 7F Lens platform (AI, fintech, edutech trackers)
  4. **second-brain-public** (public) - Sanitized knowledge (curated public content)
  5. **internal-docs** (private) - Onboarding, processes, policies, runbooks
  6. **seven-fortunas-brain** (private) - Full knowledge base (second-brain-core/)
  7. **dashboards-internal** (private) - Full intelligence (strategy, competitive, sensitive data)
  8. **7f-infrastructure-project** (private) - This project's artifacts (PRD, architecture, scripts)
- **Phase 1.5 Repositories (2 - Week 2):**
  9. **ciso-assistant** (private) - SOC 2 compliance management (migrated from personal account)
  10. **automation-scripts** (private) - GitHub operations, compliance evidence collection
- **Acceptance Criteria:**
  - ✅ All 8 MVP repos created by Day 2
  - ✅ Each repo has comprehensive README.md (purpose, setup, usage)
  - ✅ Each repo has LICENSE file (MIT for public, proprietary for private)
  - ✅ Public repos have CODE_OF_CONDUCT.md and CONTRIBUTING.md
  - ✅ All repos have appropriate .gitignore (Python, Node, etc.)
  - ✅ All repos have branch protection configured on main branch
  - ✅ GitHub Pages enabled on dashboards repo: `gh api repos/Seven-Fortunas/dashboards/pages | jq -r '.status'` returns "built"
  - ✅ GitHub Pages enabled on seven-fortunas.github.io repo: `gh api repos/Seven-Fortunas/seven-fortunas.github.io/pages | jq -r '.status'` returns "built"
  - ✅ `.nojekyll` file present on dashboards gh-pages branch (prevents Jekyll from breaking React asset paths): `gh api repos/Seven-Fortunas/dashboards/contents/.nojekyll?ref=gh-pages | jq '.name'` returns `".nojekyll"`
  - ✅ Landing page live with no placeholder/under-construction content: `curl -sf https://seven-fortunas.github.io/ | grep -iv "placeholder\|coming soon\|under construction"` exits 0
  - ✅ AI Dashboard HTML returns 200 (T4.1): `curl -sf https://seven-fortunas.github.io/dashboards/ai/ -o /dev/null`
  - ✅ AI Dashboard JS bundle returns 200 (T4.2 — extract URL from index.html, verify asset loads, not just page HTML)
  - ✅ AI Dashboard CSS bundle returns 200 (T4.3 — same pattern)
  - ✅ Landing page returns 200: `curl -sf https://seven-fortunas.github.io/ -o /dev/null`
  - **Note:** Per NFR-4.4, HTML returning 200 is insufficient — JS/CSS assets must also be verified individually
- **Priority:** P0 (MVP Day 1-2)
- **Owner:** Jorge (automated via autonomous agent)

**FR-1.6: Branch Protection Rules**
- **Requirement:** System SHALL configure branch protection for all main branches
- **Acceptance Criteria:**
  - ✅ Require pull request before merging
  - ✅ Require at least 1 approval (where enforceable on Free tier)
  - ✅ Dismiss stale pull request approvals when new commits pushed
  - ✅ Require conversation resolution before merging
  - ✅ Do not allow force pushes to main
  - ✅ Do not allow branch deletion
- **Priority:** P0 (MVP Day 1)
- **Owner:** Jorge (automated via autonomous agent)

---

### FR Category 2: Second Brain Knowledge Management (4 FRs)

**FR-2.1: Progressive Disclosure Structure**
- **Requirement:** Second Brain SHALL use 3-level progressive disclosure hierarchy
- **Structure:**
  ```
  second-brain-core/
  ├── index.md                    # Level 1: Hub (AI agents load FIRST)
  ├── brand/                      # Level 2: Domain directories
  │   ├── brand.json              # Level 3: Specific documents
  │   ├── brand-system.md
  │   └── tone-of-voice.md
  ├── culture/
  ├── domain-expertise/
  ├── best-practices/
  └── skills/
  ```
- **Acceptance Criteria:**
  - ✅ index.md exists with table of contents
  - ✅ Each directory has README.md
  - ✅ Never more than 3 levels deep
  - ✅ YAML frontmatter on all documents (context-level, relevant-for, last-updated)
- **Priority:** P0 (MVP Day 1)
- **Owner:** Jorge (scaffolding automated, Henry populates brand content Days 3-5)
- **Cross-Reference:** → [master-architecture.md](master-architecture.md) for Second Brain architecture

**FR-2.2: Markdown + YAML Dual-Audience Format**
- **Requirement:** All Second Brain documents SHALL use markdown body + YAML frontmatter for dual-audience (humans + AI)
- **YAML Schema:**
  ```yaml
  ---
  context-level: overview | domain | detail
  relevant-for: [skill-names, user-roles, domains]
  last-updated: YYYY-MM-DD
  author: Name
  status: draft | complete | deprecated
  ---
  ```
- **Acceptance Criteria:**
  - ✅ All .md files have YAML frontmatter
  - ✅ AI agents can filter by relevant-for
  - ✅ Humans can browse without reading YAML
  - ✅ Obsidian-compatible (optional visualization)
- **Priority:** P0 (MVP Day 1)
- **Owner:** Jorge (template creation), Henry (content creation)

**FR-2.3: Voice Input System (OpenAI Whisper)**
- **Requirement:** System SHALL support voice-to-text transcription with clear failure handling and fallback UX
- **Voice Input Workflow:**
  1. User invokes skill with voice flag: `/7f-brand-system-generator --voice`
  2. System displays: "🎤 Recording... Press Ctrl+C to stop recording"
  3. User speaks (5-10 minutes), presses Ctrl+C when done
  4. System transcribes via OpenAI Whisper → displays transcript for review
  5. User confirms or re-records → AI structures content → user refines 20%
- **Failure Handling & Fallback UX:**
  - **No microphone detected:**
    - Error: "❌ No microphone detected. Install system audio driver or use --text mode."
    - Auto-fallback: Prompt user to type input instead
  - **Whisper installation missing:**
    - Error: "❌ OpenAI Whisper not installed. Run: pip install openai-whisper"
    - Offer: "Type input instead? (y/n)"
  - **Poor audio quality (Whisper confidence <60%):**
    - Warning: "⚠️ Low transcription confidence. Review transcript carefully or re-record."
    - Show transcript with confidence score: "[87%] This is the transcript..."
  - **Transcription empty (silence detected):**
    - Error: "❌ No speech detected. Check microphone or try again."
    - Offer re-record or fallback to typing
  - **Manual fallback trigger:** User can press 'T' during "Recording..." to switch to typing mode immediately
- **Acceptance Criteria:**
  - ✅ OpenAI Whisper installed on primary device (Henry's MacBook Pro for MVP; installation procedure documented in Second Brain for other devices/users)
  - ✅ Voice input integration documented in skill README with examples
  - ✅ Henry can dictate content successfully (5-10 min speaking → transcription → 20% editing)
  - ✅ All 5 failure scenarios tested with appropriate error messages displayed
  - ✅ Fallback to typing works seamlessly (no data loss, clear transition)
  - ✅ Confidence score displayed when <80% (user can decide whether to trust transcript)
- **Priority:** P1 (MVP Day 3 - Henry's aha moment depends on this)
- **Owner:** Jorge (installation/testing), Henry (usage validation)
- **Cross-Reference:** → [master-ux-specifications.md](master-ux-specifications.md) for voice UX design

**FR-2.4: Search & Discovery**
- **Requirement:** Users SHALL be able to find information in Second Brain within 2 clicks (browsing path) or 15 seconds (search query), whichever method user prefers
- **Methods:**
  - Browsing: index.md → domain README → specific doc
  - Searching: grep, Obsidian Quick Switcher, GitHub search
  - AI-assisted: Natural language queries via `search-second-brain.sh` Claude Code skill
- **Search Skill Deployment:** `search-second-brain.sh` SHALL be deployed as a Claude Code skill to `.claude/commands/` in `Seven-Fortunas-Internal/seven-fortunas-brain` repo so team members can invoke it from any Claude Code session connected to the brain
- **Acceptance Criteria:**
  - ✅ Index.md provides clear navigation
  - ✅ README at every directory level
  - ✅ Grep search functional (documented in README)
  - ✅ `search-second-brain.sh` skill deployed: `gh api repos/Seven-Fortunas-Internal/seven-fortunas-brain/contents/.claude/commands/search-second-brain.sh | jq '.name'` returns `"search-second-brain.sh"`
  - ✅ Skill README documents usage (how to invoke, what it searches, examples)
  - ✅ Patrick can find architecture docs in <2 minutes (aha moment)
- **Priority:** P0 (MVP Day 3 - Patrick's aha moment depends on this)
- **Owner:** Jorge (structure), All founders (validation)

---

### FR Category 3: BMAD Skills Platform (4 FRs)

**FR-3.1: BMAD Library Integration**
- **Requirement:** System SHALL integrate BMAD v6.0.0 as Git submodule with 18 adopted skills operational
- **18 BMAD Skills Adopted (Complete List):**

  **Business Method (bmm) - 6 skills:**
  1. bmad-bmm-create-prd - Generate Product Requirements Document
  2. bmad-bmm-create-architecture - Generate system architecture document
  3. bmad-bmm-create-story - Create user stories with acceptance criteria
  4. bmad-bmm-create-epic - Create epics from high-level requirements
  5. bmad-bmm-transcribe-audio - Transcribe audio files to text
  6. bmad-bmm-create-sop - Create standard operating procedures

  **Builder (bmb) - 7 skills:**
  7. bmad-bmb-create-workflow - Create BMAD workflow from requirements
  8. bmad-bmb-validate-workflow - Validate workflow structure and completeness
  9. bmad-bmb-create-github-repo - Create GitHub repository with templates
  10. bmad-bmb-configure-ci-cd - Configure CI/CD pipelines
  11. bmad-bmb-create-docker - Generate Dockerfile and docker-compose
  12. bmad-bmb-create-test - Generate test suites (unit, integration, e2e)
  13. bmad-bmb-code-review - AI-powered code review

  **Creative Intelligence (cis) - 5 skills:**
  14. bmad-cis-generate-content - Generate marketing/technical content
  15. bmad-cis-brand-voice - Apply brand voice to content
  16. bmad-cis-generate-pptx - Generate PowerPoint presentations
  17. bmad-cis-generate-diagram - Generate architecture diagrams (Excalidraw)
  18. bmad-cis-summarize - Summarize long documents

- **Acceptance Criteria:**
  - ✅ _bmad/ directory exists as Git submodule at project root
  - ✅ BMAD v6.0.0 pinned (git submodule locked to specific commit SHA)
  - ✅ BMAD Update Policy: Quarterly review (see master-bmad-integration.md); security patches applied within 4-24h depending on severity (P0: 4h, P1: 24h)
  - ✅ 18 skill stub files in .claude/commands/ directory (one per skill)
  - ✅ All skills invocable via /bmad-* commands in Claude Code
  - ✅ Jorge can successfully invoke each skill and complete basic workflow
- **Priority:** P0 (MVP Day 0)
- **Owner:** Jorge
- **Cross-Reference:** → [master-bmad-integration.md](master-bmad-integration.md) for detailed skill descriptions and usage patterns

**FR-3.2: Custom Seven Fortunas Skills**
- **Requirement:** System SHALL provide 7 custom/adapted Seven Fortunas skills (MVP): 5 adapted from BMAD (7f-brand-system-generator, 7f-pptx-generator, 7f-excalidraw-generator, 7f-sop-generator, 7f-skill-creator) + 2 built from scratch (7f-dashboard-curator, 7f-repo-template). NOTE: 7f-manage-profile deferred to Phase 2.
- **5 Adapted Skills:**
  1. 7f-brand-system-generator (adapted from cis-brand-voice)
  2. 7f-pptx-generator (adapted from bmad-cis-generate-pptx)
  3. 7f-excalidraw-generator (adapted from bmad-cis-generate-diagram)
  4. 7f-sop-generator (adapted from bmad-bmm-create-sop)
  5. 7f-skill-creator (adapted from bmad-bmb-create-workflow) - META-SKILL
- **2 New Custom Skills (MVP):**
  1. 7f-dashboard-curator (add/remove dashboard sources)
  2. 7f-repo-template (repository scaffolding)
- **Phase 2 Skill:**
  1. 7f-manage-profile (user profile management) - Deferred to Phase 2
- **Acceptance Criteria:**
  - ✅ All 7 MVP skills deployed to `.claude/commands/` in `Seven-Fortunas-Internal/seven-fortunas-brain`
  - ✅ Each skill file accessible via `gh api repos/Seven-Fortunas-Internal/seven-fortunas-brain/contents/.claude/commands/<skill-name>.md`
  - ✅ Skills verified individually: 7f-brand-system-generator, 7f-pptx-generator, 7f-excalidraw-generator, 7f-sop-generator, 7f-skill-creator, 7f-dashboard-curator, 7f-repo-template
  - ✅ Skills count verified: `gh api repos/Seven-Fortunas-Internal/seven-fortunas-brain/contents/.claude/commands/ | jq '[.[] | select(.name | startswith("7f-"))] | length'` returns 7
  - ✅ Henry can use brand-system-generator (aha moment)
  - ✅ Jorge can use dashboard-curator
  - ✅ skill-creator (meta-skill) can generate new skills from YAML
- **Priority:** P0 (MVP Day 1-2)
- **Owner:** Jorge
- **Note:** Total operational skills (MVP) = 18 BMAD + 5 adapted + 2 custom = **25 skills** ✅ (7f-manage-profile deferred to Phase 2)

**FR-3.3: Skill Organization System**
- **Requirement:** System SHALL organize skills by category and tier to prevent proliferation
- **Categories:**
  - Business Method (bmm): Planning, discovery, creation
  - Builder (bmb): Coding, infrastructure, workflows
  - Creative Intelligence (cis): Content generation, AI-powered
  - Seven Fortunas (7f): Company-specific operations
- **Tiers:**
  - Tier 1: Mission-critical (used daily)
  - Tier 2: Important (used weekly)
  - Tier 3: Occasional (used monthly)
- **Acceptance Criteria:**
  - ✅ Skills organized in .claude/commands/ by category
  - ✅ README documents tiers
  - ✅ Search-before-create guidance in skill-creator
- **Priority:** P2 (Phase 1.5 - Weeks 2-3)
- **Owner:** Jorge

**FR-3.4: Skill Governance (Prevent Proliferation)**
- **Requirement:** System SHALL prevent duplicate skill creation through enhanced skill-creator
- **Governance Mechanisms:**
  - Search existing skills before creating new
  - Usage tracking (which skills are actually used)
  - Quarterly skill reviews (deprecate stale skills)
  - Consolidation recommendations (merge similar skills)
- **Acceptance Criteria:**
  - ✅ skill-creator searches before creating
  - ✅ <5 duplicate skills created in Phase 1.5
  - ✅ Usage tracking operational
  - ✅ Quarterly review process documented
- **Priority:** P2 (Phase 1.5 - Weeks 2-3)
- **Owner:** Jorge

---

### FR Category 4: 7F Lens Intelligence Platform (4 FRs)

**FR-4.1: AI Advancements Dashboard (MVP)**
- **Requirement:** System SHALL provide auto-updating AI Advancements Tracker dashboard with graceful degradation on failures
- **Data Sources:**
  - RSS feeds (OpenAI blog, Anthropic blog, etc.)
  - GitHub releases (langchain, llama_index, etc.)
  - Reddit (r/MachineLearning, r/LocalLLaMA) — `r/LocalLLaMA` is the required second subreddit; `r/artificial` is not a valid substitute
  - YouTube channels (OpenAI, Two Minute Papers) — disabled by default; YouTube RSS feeds return 404/500 from CI runner IPs
  - X API (optional, $100/month)
- **Configuration File (Critical):**
  - Sources config MUST be at `ai/config/sources.yaml` — not `ai/sources.yaml`
  - This path is used by `update_dashboard.py`, the `/7f-dashboard-curator` skill (FR-4.3), and all references
  - `degradation.cache_max_age_hours` MUST be `168` (7 days), not 24 hours — aligns with the 7-day max staleness rule below
  - Verify: `test -f ai/config/sources.yaml`
  - Verify: `grep -q "cache_max_age_hours: 168" ai/config/sources.yaml`
  - Verify: `grep -q "LocalLLaMA" ai/config/sources.yaml`
- **Graceful Degradation Specification:**
  - **Single source failure:** Skip failed source, continue with remaining sources, log warning
  - **Multiple source failures (≥50%):** Generate dashboard with available data + warning banner: "⚠️ Limited data: X of Y sources unavailable"
  - **All sources failure / cached_updates.json fetch error:** When `cached_updates.json` fails to load (network error, deploy failure, or all sources down), the React app MUST display `ErrorBanner` with message: "❌ Unable to fetch new data. Retry in 6 hours." — a blank/empty dashboard is NOT acceptable
  - **Stale cached data (0–7 days old):** Display data with warning banner: "⚠️ Showing cached data from [timestamp]"
  - **Stale cached data (>7 days old):** Display error page instead of stale data — do not render the dashboard
  - **Claude API failure (summaries):** Skip AI summary generation, display raw aggregated data
  - **Persistent failures (>24h):** GitHub Issue auto-created, Jorge notified via email
- **Source Location:** `ai/` directory in `Seven-Fortunas/dashboards` repo (not `dashboards/ai/` — the repo name is `dashboards`, source lives at repo root under `ai/`)
- **Build Configuration (Critical):**
  - `ai/vite.config.js` MUST have `base: '/dashboards/ai/'` — without this, built JS/CSS asset paths are absolute (`/assets/...`) and 404 when served from the subdirectory path
  - Verify: `grep -q "base: '/dashboards/ai/'" ai/vite.config.js`
- **Deploy Workflow:** `Seven-Fortunas/dashboards/.github/workflows/deploy-ai-dashboard.yml` using `peaceiris/actions-gh-pages@v4` with `destination_dir: ai` and `keep_files: true`; triggers on push to `ai/**` AND on `workflow_run` completion of "Update AI Dashboard Data" (enables data update → auto-rebuild pipeline)
- **UI Component Requirements:**
  - `LastUpdated` component MUST display both last update time and next scheduled update time: `Last updated: [timestamp] UTC | Next update: [timestamp + 6h] UTC`
  - `App.jsx` MUST have an error state: when `fetch('./data/cached_updates.json')` rejects, set error state and render `ErrorBanner` — the current silent `console.error` + empty state is not compliant
  - `App.jsx` MUST check `last_updated` timestamp after successful load; if >7 days old, render error page instead of dashboard
- **Acceptance Criteria:**
  - ✅ Dashboard auto-updates every 6 hours (GitHub Actions cron: 0 */6 * * *)
  - ✅ React 18.x single-page application deployed to GitHub Pages at https://seven-fortunas.github.io/dashboards/ai/
  - ✅ Package.json exists with React 18.x dependency: `grep -q '"react": "^18' ai/package.json`
  - ✅ Vite base path correct: `grep -q "base: '/dashboards/ai/'" ai/vite.config.js`
  - ✅ Build succeeds: `cd ai && npm ci && npm run build`
  - ✅ Built index.html references correct asset paths: `grep -q '/dashboards/ai/assets/' ai/dist/index.html`
  - ✅ GitHub Actions deploy workflow exists: `.github/workflows/deploy-ai-dashboard.yml` present in repo
  - ✅ Deploy workflow uses `destination_dir: ai` and `keep_files: true`
  - ✅ Deploy workflow has `workflow_run` trigger for data auto-rebuild
  - ✅ React components implemented: UpdateCard, SourceFilter, ErrorBanner, SearchBar, LastUpdated (per master-ux-specifications.md)
  - ✅ CSS has explicit breakpoint at 1024px: `grep -q "max-width: 1024px" ai/src/styles/dashboard.css`
  - ✅ Touch targets enforced: interactive elements have `min-height: 44px` in CSS: `grep -q "min-height: 44px" ai/src/styles/dashboard.css`
  - ✅ `LastUpdated` component displays next update time (last_updated + 6h)
  - ✅ `App.jsx` renders `ErrorBanner` when `cached_updates.json` fetch fails (not a blank page)
  - ✅ `App.jsx` renders error page when `last_updated` is >7 days ago
  - ✅ Sources config at correct path: `test -f ai/config/sources.yaml`
  - ✅ Reddit source is r/LocalLLaMA: `grep -q "LocalLLaMA" ai/config/sources.yaml`
  - ✅ Cache staleness threshold is 7 days: `grep -q "cache_max_age_hours: 168" ai/config/sources.yaml`
  - ✅ Performance: First Contentful Paint <2 seconds, Time to Interactive <5 seconds
  - ✅ Leadership can review in 5 minutes (content above the fold)
  - ✅ Graceful degradation tested (simulate each failure scenario, verify behavior matches spec)
  - ✅ T4 LIVE — dashboard HTML returns 200: `curl -sf https://seven-fortunas.github.io/dashboards/ai/ -o /dev/null`
  - ✅ T4 LIVE — JS bundle loads (extract URL from live index.html, verify 200, not just HTML)
  - ✅ T4 LIVE — CSS bundle loads (same pattern)
  - ✅ T4 LIVE — data endpoint returns 14+ updates: `curl -sf https://seven-fortunas.github.io/dashboards/ai/data/cached_updates.json | jq '.updates | length'` ≥ 14
  - **Note:** Per NFR-4.4, agent must NOT mark pass until all T1→T4 tiers pass in order
- **Priority:** P0 (MVP Day 1-2)
- **Owner:** Jorge (automated via autonomous agent)

**FR-4.2: AI-Generated Weekly Summaries**
- **Requirement:** System SHALL generate AI-powered weekly summaries using Claude API
- **Workflow File:** `.github/workflows/weekly-ai-summary.yml` — this file does not yet exist and must be created
- **Trigger:** `schedule: cron: '0 9 * * 0'` (Sundays 9am UTC) + `workflow_dispatch` for manual runs
- **Steps:**
  1. Checkout repo
  2. Setup Python 3.11
  3. Load `ai/public/data/cached_updates.json` (this is the live data file written by `update_dashboard.py` — not `latest.json`)
  4. Send to Claude API (`claude-3-5-haiku` model for cost efficiency) with prompt: "Summarize top 10 AI developments this week. Focus on: models, research, tools, regulations. Relevance to Seven Fortunas mission (digital inclusion)."
  5. Write summary to `ai/summaries/YYYY-MM-DD.md` (format: 1-2 paragraphs + 10 bullet points with links)
  6. Prepend summary to `ai/README.md` (keep last 4 weeks of summaries in README, archive older ones)
  7. Git commit: `chore(dashboard): Weekly AI summary YYYY-MM-DD` and push
- **Directory:** `ai/summaries/` MUST exist in the repo; scaffold with `.gitkeep` before first workflow run
- **Secret Required:** `ANTHROPIC_API_KEY` stored in `Seven-Fortunas/dashboards` GitHub Secrets — **Jorge must add this manually before the workflow can run**
- **Acceptance Criteria:**
  - ✅ `.github/workflows/weekly-ai-summary.yml` exists with Sunday 9am UTC cron schedule
  - ✅ `ai/summaries/` directory exists: `test -d ai/summaries`
  - ✅ Workflow uses `ANTHROPIC_API_KEY` secret (not hardcoded)
  - ✅ On workflow run, creates `ai/summaries/YYYY-MM-DD.md` with correct format (1-2 paragraphs + 10 bullet points)
  - ✅ `ai/README.md` updated with latest summary after each run
  - ✅ Cost <$5/month (haiku model at ~$0.25/MTok input; weekly runs with ~10K tokens = ~$0.002/run = ~$0.10/month)
- **Priority:** P0 (MVP Day 1-2)
- **Owner:** Jorge (automated via autonomous agent; ANTHROPIC_API_KEY setup is a manual prerequisite)

**FR-4.3: Dashboard Configurator Skill**
- **Requirement:** Users SHALL be able to add/remove dashboard data sources via /7f-dashboard-curator skill
- **Operations:**
  - Add RSS feed (URL, name, keywords)
  - Remove RSS feed
  - Add Reddit subreddit
  - Remove Reddit subreddit
  - Add YouTube channel
  - Configure update frequency
- **Acceptance Criteria:**
  - ✅ Skill validates data sources (test fetch)
  - ✅ Updates dashboards/ai/config/sources.yaml
  - ✅ Triggers dashboard rebuild
  - ✅ No YAML editing required (conversational interface)
- **Priority:** P1 (MVP Day 2-3)
- **Owner:** Jorge

**FR-4.4: Additional Dashboards (Phase 2)**
- **Requirement:** System SHALL support multiple domain dashboards beyond AI
- **Phase 2 Dashboards:**
  - Fintech Trends Dashboard
  - EduTech Dashboard (Peru market focus)
  - Security Intelligence Dashboard
- **Acceptance Criteria:**
  - ✅ Each dashboard has same structure as AI dashboard
  - ✅ dashboard-curator works for all dashboards
  - ✅ Each has dedicated config/sources.yaml
  - ✅ Each generates weekly summaries
- **Priority:** P3 (Phase 2 - Months 1-3)
- **Owner:** Team (self-service via dashboard-curator)

---

### FR Category 5: Security & Compliance (4 FRs)

**FR-5.1: Secret Detection & Prevention** ✅ MOST CRITICAL
- **Requirement:** System SHALL detect and prevent secrets from being committed using multi-layer defense
- **Target Detection Rate:** ≥99.5% detection rate, ≤0.5% false negative rate (measured against OWASP Secret Scanning Benchmark v2.0)
- **Detection Layers:**
  - Layer 1: Pre-commit hooks (local, .git/hooks/pre-commit) - regex + entropy analysis
  - Layer 2: GitHub Actions (remote, check on push) - pattern matching + contextual analysis
  - Layer 3: GitHub secret scanning (repository-level) - proprietary detection
  - Layer 4: Push protection (blocks commits with high-confidence secrets)
- **Known Limitations:**
  - Binary files: Limited detection capability (base64/hex encoded secrets detectable, compiled binaries not)
  - Novel secret formats: May not detect custom secret patterns not in detection rules
  - Obfuscated secrets: Split-across-files or heavy encoding may evade detection
  - Mitigation: Quarterly pattern updates (Owner: Jorge, scheduled with BMAD skill reviews) + manual code review for cryptographic operations
- **Acceptance Criteria:**
  - ✅ Pre-commit hook installed on all developer machines (setup script validates installation)
  - ✅ GitHub Actions workflow validates all commits (fails CI on detection)
  - ✅ Secret scanning enabled on all repos (org-level policy enforced)
  - ✅ Push protection enabled (blocks high-confidence detections)
  - ✅ **Jorge's security testing** validates ≥99% detection across 20+ test cases (cleartext, base64, env vars, encoded) ✅ CORRECTED - Jorge, not Buck
  - ✅ False negative tracking system operational (logs misses for pattern improvement)
- **Priority:** P0 (MVP Day 1) - **NON-NEGOTIABLE**
- **Owner:** Jorge (SecOps)
- **Validation:** Jorge's aha moment depends on this working

**FR-5.2: Dependency Vulnerability Management**
- **Requirement:** System SHALL automatically detect and patch dependency vulnerabilities
- **SLAs:**
  - Critical vulnerabilities: Patch within 24 hours
  - High vulnerabilities: Patch within 7 days
  - Medium/Low: Patch within 30 days
- **Acceptance Criteria:**
  - ✅ Dependabot enabled on all repos
  - ✅ Security updates auto-merged (if tests pass)
  - ✅ Version updates create PRs for review
  - ✅ Vulnerability alerts to Slack/email
- **Priority:** P0 (MVP Day 1)
- **Owner:** Jorge (SecOps)

**FR-5.3: Access Control & Authentication**
- **Requirement:** System SHALL enforce principle of least privilege and 2FA
- **Policies:**
  - 2FA required for all organization members (enforced)
  - Default repository permission: none (explicit grants required)
  - Team-based access control (not individual grants)
  - GitHub App authentication for automation (not personal tokens)
- **Acceptance Criteria:**
  - ✅ 2FA enforcement active
  - ✅ All founders have 2FA enabled
  - ✅ Teams configured with appropriate access levels
  - ✅ GitHub App created for automation (Phase 1.5)
- **Priority:** P0 (MVP Day 1)
- **Owner:** Jorge (SecOps)

**FR-5.4: SOC 2 Preparation (Phase 1.5)**
- **Requirement:** System SHALL implement security controls that map to SOC 2 Trust Service Criteria
- **SOC 2 Controls:**
  - CC6.1: Logical access controls
  - CC6.6: Vulnerability management
  - CC6.7: Environmental change management
  - CC7.2: System monitoring
  - CC8.1: Change management
- **Phase 1.5 Deliverables:**
  - CISO Assistant migrated to Seven-Fortunas-Internal
  - GitHub controls mapped to SOC 2 requirements
  - Automated evidence collection (GitHub API → CISO Assistant)
  - Compliance dashboard (real-time control posture)
- **Acceptance Criteria:**
  - ✅ CISO Assistant integrated (Weeks 2-3)
  - ✅ Control mapping complete
  - ✅ Evidence sync functional (daily)
  - ✅ Control drift alerts (<15 minutes)
- **Priority:** P2 (Phase 1.5 - Weeks 2-3)
- **Owner:** Jorge (compliance)

---

### FR Category 6: Infrastructure Documentation (1 FR)

**FR-6.1: Self-Documenting Architecture**
- **Requirement:** System SHALL have README.md at every directory level
- **Documentation Requirements:**
  - Root README: Project overview, quick start, navigation
  - Directory READMEs: Purpose, contents, usage
  - Code READMEs: Setup, dependencies, examples
  - Architecture READMEs: Design decisions, patterns, ADRs
- **Acceptance Criteria:**
  - ✅ README at root of every repo
  - ✅ README in every directory (including empty ones)
  - ✅ README files link to deeper documentation
  - ✅ Patrick can understand architecture in 2 hours (aha moment)
- **Priority:** P0 (MVP Day 1-2)
- **Owner:** Jorge (automated via autonomous agent)

---

### FR Category 7: Autonomous Agent & Automation (5 FRs)

**FR-7.1: Autonomous Agent Infrastructure**
- **Requirement:** System SHALL use Claude Code SDK for autonomous infrastructure build
- **Agent Configuration:**
  - Model: claude-sonnet-4-5-20250929
  - Two-agent pattern: Initializer (planning) + Coding (implementation)
  - Input: app_spec.txt (generated from PRD)
  - Output: feature_list.json, claude-progress.txt, autonomous_build_log.md
- **Acceptance Criteria:**
  - ✅ Autonomous agent scripts in ./scripts/ directory
  - ✅ run_autonomous_continuous.sh executable
  - ✅ app_spec.txt generated from PRD
  - ✅ Jorge can monitor progress (tail -f logs)
- **Priority:** P0 (MVP Day 0)
- **Owner:** Jorge
- **Cross-Reference:** → [master-implementation.md](master-implementation.md) for agent setup

**FR-7.2: Bounded Retry Logic**
- **Requirement:** Agent SHALL retry failed features max 3 times, then mark blocked with detailed logging
- **Retry Strategy:**
  - Attempt 1: Standard implementation (full requirements as specified in acceptance criteria)
  - Attempt 2: Simplified approach (reduce scope: remove "nice-to-have" features specified with "SHOULD" in requirements; keep "SHALL" features only)
  - Attempt 3: Minimal viable version (core functionality only: simplest implementation that satisfies primary acceptance criteria)
  - After 3 failures: Mark blocked, log comprehensive failure details, continue to next feature
  - **Simplification Criteria:** Agent evaluates feature complexity and systematically removes optional components (advanced error handling, edge case coverage, optimization features) while preserving core functionality
- **Logging Specification:**
  - **Log location:** `autonomous_build_log.md` (append-only) + `feature_list.json` (structured)
  - **Log format (per attempt):**
    ```json
    {
      "feature_id": "FR-7.2",
      "attempt": 2,
      "timestamp": "2026-02-15T14:32:11Z",
      "approach": "simplified",
      "duration_seconds": 127,
      "error_type": "test_failure",
      "error_message": "Unit test test_retry_logic_bounds failed: AssertionError",
      "stack_trace": "...",
      "next_action": "retry_attempt_3"
    }
    ```
  - **Blocked feature notification:** Append to autonomous_build_log.md + log WARNING in console + update feature_list.json status="blocked"
  - **No automated notifications** (Jorge monitors log via tail -f)
- **Session-Level Circuit Breaker:**
  - **Definition:** A "session" = One complete pass through all remaining features (not yet completed/blocked)
  - **Session failure criteria:** Session fails if ANY of:
    - Completion rate < 50% (fewer than 14 of 28 MVP features completed by session end)
    - OR >30% of attempted features blocked in this session (unable to complete after 3 retries each)
    - OR critical infrastructure blocker (auth failure, API outage, missing dependencies)
  - **Circuit breaker trigger:** After 5 consecutive failed sessions:
    - **Action:** Terminate autonomous loop immediately (do not start session 6)
    - **Log:** "🛑 CIRCUIT BREAKER ACTIVATED: 5 consecutive sessions failed. Autonomous implementation terminated. Human intervention required."
    - **Generate summary report:** `autonomous_summary_report.md` with:
      - Features completed successfully (count + list with links)
      - Features blocked (count + list with failure reasons)
      - Root cause analysis (API issues? Unclear requirements? Agent capability limits?)
      - Recommended next steps for human (which features need manual implementation)
    - **Exit code:** 42 (circuit breaker triggered)
  - **Reset condition:** Circuit breaker counter resets to 0 after successful session (≥50% completion rate AND <30% blocked)
  - **Progress tracking:** `session_progress.json` tracks session count, failures, completion rates
  - **Rationale:** Prevents infinite loops, conserves resources (compute time, API credits), provides clear escalation path
- **Acceptance Criteria:**
  - ✅ Retry logic implemented in agent scripts (max 3 attempts enforced)
  - ✅ Retry count tracked in feature_list.json (attempt: 1/2/3)
  - ✅ All attempt failures logged with complete error context (message, stack, duration)
  - ✅ Blocked features logged with failure summary across all 3 attempts
  - ✅ Agent never gets stuck in infinite loop (hard timeout: 30 min per attempt)
  - ✅ Session-level circuit breaker enforced (max 5 failed sessions)
  - ✅ Circuit breaker generates summary report with actionable recommendations
  - ✅ Circuit breaker exits with code 42 for monitoring/alerting integration
- **Priority:** P0 (MVP Day 1-2)
- **Owner:** Jorge

**FR-7.3: Test-Before-Pass Requirement**
- **Requirement:** Agent SHALL NOT mark feature as "pass" without tests
- **Testing Requirement:**
  - All features must have tests (unit, integration, or manual)
  - Tests must pass before feature marked "pass"
  - Features without tests marked "incomplete" (not "pass")
- **Acceptance Criteria:**
  - ✅ Agent generates tests for all features
  - ✅ Tests run before marking feature complete
  - ✅ feature_list.json shows test status
  - ✅ Zero broken features in final deliverable
- **Priority:** P0 (MVP Day 1-2)
- **Owner:** Jorge (monitoring)

**FR-7.4: Progress Tracking**
- **Requirement:** System SHALL provide real-time progress visibility
- **Tracking Mechanisms:**
  - feature_list.json: Status of all 28 features
  - claude-progress.txt: Current task, elapsed time
  - autonomous_build_log.md: Detailed activity log
  - Console output: Real-time agent actions
- **Acceptance Criteria:**
  - ✅ Jorge can run `tail -f autonomous_build_log.md`
  - ✅ feature_list.json updates in real-time
  - ✅ Progress percentage calculated (18-25 of 28 = 60-70%)
  - ✅ Blocked features identified immediately
- **Priority:** P0 (MVP Day 1-2)
- **Owner:** Jorge (monitoring)

**FR-7.5: GitHub Actions Workflows**
- **Requirement:** System SHALL automate recurring tasks via GitHub Actions
- **Core Workflows (6 MVP + 14 Phase 1.5-2):**

  **MVP (6 critical workflows):**
  1. update-ai-dashboard.yml (every 6 hours)
  2. weekly-ai-summary.yml (Sundays 9am UTC)
  3. dependabot-auto-merge.yml (security updates)
  4. pre-commit-validation.yml (on push)
  5. test-suite.yml (on PR)
  6. deploy-website.yml (on main push)

  **Phase 1.5-2 (14 additional workflows):**
  7. update-fintech-dashboard.yml
  8. update-edutech-dashboard.yml
  9. update-security-dashboard.yml
  10. ciso-assistant-sync.yml (daily evidence collection)
  11. secret-scanning-report.yml (weekly)
  12. dependency-audit.yml (weekly)
  13. compliance-check.yml (daily)
  14. broken-links-check.yml (weekly)
  15. markdown-lint.yml (on PR)
  16. spell-check.yml (on PR)
  17. backup-repositories.yml (weekly)
  18. cleanup-old-data.yml (monthly)
  19. skill-usage-report.yml (monthly)
  20. release-notes-generator.yml (on tag)
- **Acceptance Criteria:**
  - ✅ All workflows in .github/workflows/ directories
  - ✅ Workflows use GitHub Secrets for sensitive data
  - ✅ Workflows have descriptive names and comments
  - ✅ Workflow failures alert team
- **Priority:** P0 (MVP Day 1-2)
- **Owner:** Jorge (automated via autonomous agent)

### FR Category 8: Collaboration & Project Management (5 FRs) - **PHASE 2**

**FR-8.1: Sprint Management**
- **Requirement:** System SHALL support unified sprint planning for all Seven Fortunas work (technical and business projects)
- **Validation Note:** BMAD sprint workflows designed for software projects; business project fit to be validated in Phase 2 with pilot (e.g., marketing campaign sprint)
- **Functionality:**
  - Use BMAD sprint workflows (`bmad-bmm-create-sprint`, `bmad-bmm-sprint-review`)
  - Support flexible terminology: Technical (PRD→Epics→Stories→Sprints), Business (Initiative→Objectives→Tasks→Sprints)
  - Track sprint velocity (defined as: stories/tasks completed per sprint; default sprint duration: 2 weeks, configurable per project), burndown charts, completion rate
  - Integrate with GitHub Projects for Kanban board visualization
- **Acceptance Criteria:**
  - ✅ BMAD sprint workflows adopted (bmad-bmm-create-sprint, bmad-bmm-sprint-review)
  - ✅ Sprint planning works for both engineering and business projects
  - ✅ Sprint data synced to GitHub Projects boards
  - ✅ Sprint retrospectives capture lessons learned
  - ✅ Velocity metrics calculated (stories/tasks completed per sprint)
- **Priority:** Phase 2
- **Owner:** Jorge (setup), All founders (users)
- **BMAD Skills:** Adopt existing (bmad-bmm-create-sprint, bmad-bmm-sprint-review)

**FR-8.2: Sprint Dashboard**
- **Requirement:** System SHALL provide interactive dashboard to view and update sprint status
- **Functionality:**
  - Leverage GitHub Projects API for sprint board management
  - Display sprint backlog, in-progress, completed, blocked items
  - Update sprint status via `7f-sprint-dashboard` skill (move cards, update status, add notes)
  - Use GitHub Projects web interface (no custom UI build required)
- **Acceptance Criteria:**
  - ✅ GitHub Projects boards created for each active sprint
  - ✅ `7f-sprint-dashboard` skill can query sprint status
  - ✅ Skill can update card status via GitHub API (move columns, add labels)
  - ✅ Sprint board accessible to all team members (correct permissions)
  - ✅ Board reflects real-time status (updated within 5 minutes of changes)
- **Priority:** Phase 2
- **Owner:** Jorge (skill creation), All founders (users)
- **BMAD Skills:** Custom `7f-sprint-dashboard` (4-6h build)
- **Cost Note:** GitHub Projects requires GitHub Team tier for private repos ($4/user/month = $16/month for 4 founders)

**FR-8.3: Project Progress Dashboard**
- **Requirement:** System SHALL provide daily-updated visibility into project health and velocity across all active projects (data refreshed daily via cron, not real-time)
- **Functionality:**
  - Display metrics: Sprint velocity, feature completion rate (33 FRs tracked), burndown charts, active blockers/risks
  - Data sources: GitHub Projects API (sprint data), GitHub Issues API (blockers, feature status), GitHub Commits API (activity)
  - Aggregation: Daily cron job → `project-progress-latest.json` (same pattern as AI dashboard)
  - AI-generated weekly summary: "Progress this week: X features completed, Y blocked, Z commits"
  - Integrated into 7F Lens as Dashboard #2 (after AI Advancements Tracker)
- **Acceptance Criteria:**
  - ✅ Dashboard displays current sprint velocity (features completed per sprint)
  - ✅ Feature completion tracked (33 FRs: X completed, Y in progress, Z blocked)
  - ✅ Burndown chart shows work remaining vs time
  - ✅ Blockers highlighted with owner and resolution target date
  - ✅ Weekly AI summary generated (Claude API) with key insights
  - ✅ Historical data archived (52 weeks retention, same as AI dashboard)
  - ✅ Dashboard accessible at dashboards.sevenfortunas.com/project-progress
- **Priority:** Phase 2
- **Owner:** Jorge (dashboard creation)
- **BMAD Skills:** Extend 7F Lens architecture (8-12h build)

**FR-8.4: Shared Secrets Management**
- **Requirement:** System SHALL provide secure API key sharing between founders using GitHub-native solution
- **Functionality:**
  - Use GitHub Secrets org-level for API key storage (encrypted at rest by GitHub)
  - Founders store secrets via GitHub CLI: `gh secret set API_NAME --org Seven-Fortunas-Internal`
  - Founders retrieve secrets via GitHub web UI (repo Settings → Secrets) or GitHub API (secret values NOT retrievable via `gh` CLI - CLI can only list names)
  - `7f-secrets-manager` skill provides a conversational interface for listing names, adding/rotating secrets (uses GitHub API, not CLI)
- **Acceptance Criteria:**
  - ✅ GitHub Secrets org-level enabled for Seven-Fortunas-Internal
  - ✅ Retrieval procedure documented in Second Brain (second-brain-core/operations/secrets-management.md)
  - ✅ `7f-secrets-manager` skill can list available secrets (names only, not values)
  - ✅ Skill can rotate secrets (prompt for new value, update GitHub Secrets, log rotation)
  - ✅ All founders can access org-level secrets (team permissions configured)
  - ✅ Audit log tracks secret access (Phase 3: GitHub Enterprise audit log)
- **Priority:** Phase 2
- **Owner:** Jorge (skill creation, documentation)
- **BMAD Skills:** Custom `7f-secrets-manager` (4-6h build)

**FR-8.5: Team Communication**
- **Requirement:** System SHALL provide asynchronous and real-time communication channels integrated with GitHub workflow
- **Functionality:**
  - **MVP (Phase 0):** GitHub Discussions for async communication (announcements, Q&A, ideas, sprint planning)
  - **Phase 2:** Matrix server (self-hosted) with GitHub Bot integration
    - Matrix channels mirror GitHub repos and teams
    - GitHub Bot posts PR reviews, issue updates, CI/CD status, security alerts to Matrix
    - E2E encryption for sensitive discussions
    - Self-hosted (no vendor lock-in, message history limited by VPS disk space: estimated 1-2 years for 10 users with 50GB disk)
- **Acceptance Criteria (MVP - Phase 0):**
  - ✅ GitHub Discussions enabled on infrastructure-project repo
  - ✅ Discussion categories created: Announcements, Ideas, Q&A, Sprint Planning
  - ✅ Team members can post and reply to discussions
  - ✅ Discussions searchable and linkable from issues/PRs
- **Acceptance Criteria (Phase 2 - Matrix):**
  - ✅ Matrix homeserver deployed (self-hosted, Synapse or Dendrite)
  - ✅ Matrix channels created for each GitHub repo (#infrastructure, #dashboards, #brain)
  - ✅ GitHub Bot authenticated and posting to Matrix channels
  - ✅ Bot posts: PR opened/merged, issue created/closed, CI/CD success/failure, security alerts
  - ✅ E2E encryption enabled for all channels
  - ✅ Message history retained based on available VPS disk space (estimated 1-2 years for 10 users with 50GB disk)
  - ✅ All founders onboarded to Matrix (Element client installed, rooms joined)
- **Priority:** MVP (Discussions), Phase 2 (Matrix)
- **Owner:** Jorge (Discussions setup MVP, Matrix deployment Phase 2)
- **BMAD Skills:** Custom Matrix + GitHub Bot integration (20-30h build, Phase 2)
- **Infrastructure Cost:** VPS hosting $10-20/month, domain $12/year, ongoing maintenance 2-4h/month
- **Operational Note:** Requires designated operator for security patches, backups, monitoring (Jorge primary, Buck backup)

---

## Non-Functional Requirements (31 Total)

### NFR Category 1: Security (5 NFRs) - MOST CRITICAL

**NFR-1.1: Secret Detection Rate**
- **Requirement:** System SHALL maintain ≥99.5% secret detection rate with ≤0.5% false negative rate
- **Measurement Method:**
  - Baseline: Industry-standard secret detection test suite (GitHub native patterns + TruffleHog community regexes, ~100 test cases: AWS keys, GitHub tokens, API keys, database credentials, private keys)
  - Jorge's adversarial testing (Day 3): 20+ real-world attack scenarios (cleartext, base64, env vars, split secrets, encoded)
  - Quarterly validation: Re-run test suite after pattern updates
  - Toolchain version consistency: `.secrets.baseline` SHALL be generated using the same version of detect-secrets pinned in `.pre-commit-config.yaml`. Version mismatch causes "plugin not found" failures in CI (e.g., `GitLabTokenDetector` added in v1.5.0 is absent in v1.4.0). Exclusion patterns SHALL cover `.git/.*`, `venv/.*`, `tests/secret-detection/.*`, and any scripts containing intentional test key fixtures.
- **Target Performance:**
  - Detection rate: ≥99.5% (≥99 of 100 test cases detected)
  - False negative rate: ≤0.5% (≤1 of 100 real secrets missed)
  - False positive rate: ≤5% acceptable (better to over-alert than miss secrets)
  - Detection latency: <30 seconds (pre-commit), <5 minutes (GitHub Actions)
- **Known Gaps:** Binary files, novel formats, heavy obfuscation (documented in FR-5.1 limitations)
- **Improvement Plan:** Quarterly pattern updates based on false negative log review
- **Priority:** P0 - NON-NEGOTIABLE
- **Owner:** Jorge (SecOps, security testing)

**NFR-1.2: Vulnerability Patch SLAs**
- **Requirement:** System SHALL patch vulnerabilities per SLA
- **SLAs:**
  - Critical: 24 hours
  - High: 7 days
  - Medium: 30 days
  - Low: 90 days
- **Measurement:** Dependabot dashboard, manual audit
- **Priority:** P0
- **Owner:** Jorge (SecOps)

**NFR-1.3: Access Control Enforcement**
- **Requirement:** System SHALL enforce principle of least privilege
- **Policies:**
  - 2FA: 100% compliance (enforced)
  - Default permission: none (explicit grants only)
  - Team-based access (not individual)
- **Measurement:** GitHub org settings audit, manual review
- **Priority:** P0
- **Owner:** Jorge (SecOps)

**NFR-1.4: Code Security (OWASP Top 10)**
- **Requirement:** System SHALL detect OWASP Top 10 vulnerabilities
- **Detection Methods:**
  - Dependabot (dependency vulnerabilities)
  - Secret scanning (A02: Cryptographic Failures)
  - Manual code review (all others)
- **Measurement:** Code review checklist, security audit
- **Priority:** P0
- **Owner:** Buck (application security), Jorge (infrastructure security)

**NFR-1.5: SOC 2 Control Tracking (Phase 1.5)**
- **Requirement:** System SHALL track SOC 2 control posture in real-time
- **Controls:** CC6.1, CC6.6, CC6.7, CC7.2, CC8.1 (minimum)
- **Measurement:** CISO Assistant dashboard, automated evidence collection
- **Target:** Control drift alerts within 15 minutes
- **Priority:** P2 (Phase 1.5)
- **Owner:** Jorge (compliance)

---

### NFR Category 2: Performance (3 NFRs)

**NFR-2.1: Interactive Response Time**
- **Requirement:** System SHALL respond to user interactions in <2 seconds (95th percentile)
- **Interactions:**
  - GitHub web UI loading
  - Claude Code skill invocation
  - Dashboard page load
  - Second Brain search
- **Measurement (CLI-executable — no browser required):**
  - Dashboard page load total time: `curl -w "time_total:%{time_total}\n" -o /dev/null -s https://seven-fortunas.github.io/dashboards/ai/` (expect <2s)
  - Dashboard TTFB: `curl -w "time_starttransfer:%{time_starttransfer}\n" -o /dev/null -s https://seven-fortunas.github.io/dashboards/ai/` (expect <0.5s)
  - Lighthouse performance score (CI): `npx lighthouse https://seven-fortunas.github.io/dashboards/ai/ --output json --chrome-flags="--headless --no-sandbox" | jq '.categories.performance.score'` (expect ≥0.8)
  - First Contentful Paint from Lighthouse JSON: `jq '.audits["first-contentful-paint"].numericValue'` (expect <2000ms)
  - Time to Interactive from Lighthouse JSON: `jq '.audits["interactive"].numericValue'` (expect <5000ms)
  - Second Brain search response time: `time ./scripts/search-second-brain.sh "BMAD" > /dev/null` (expect <15s)
  - Note: GitHub web UI load time is not agent-verifiable (external service); validate via curl TTFB as proxy
- **Target:** <2s for 95% of interactions
- **Priority:** P1
- **Owner:** Jorge (monitoring)

**NFR-2.2: Dashboard Auto-Update Performance**
- **Requirement:** Dashboard aggregation SHALL complete in <10 minutes per cycle
- **Measurement:** GitHub Actions workflow duration
- **Target:** <10 min per dashboard (AI, Fintech, EduTech, Security)
- **Priority:** P1
- **Owner:** Jorge

**NFR-2.3: Autonomous Agent Efficiency**
- **Requirement:** Autonomous agent SHALL complete 60-70% of features in 24-48 hours (hypothesis to be validated)
- **Target Rationale:**
  - **Industry observation:** AI coding assistants (GitHub Copilot Workspace, Cursor, Replit Agent) demonstrate 40-50% autonomous completion for greenfield projects based on public demos, user anecdotes, and vendor claims (not peer-reviewed benchmarks or controlled studies)
  - **Seven Fortunas advantages:** Well-defined requirements (28 FRs with acceptance criteria), BMAD templates (reduce decision paralysis), bounded retry logic (fail fast)
  - **Conservative estimate:** 60-70% target assumes 20-30% of features require human intervention (complex integrations, ambiguous requirements, novel patterns)
  - **Validation approach:** This is a HYPOTHESIS - actual performance will be measured and documented for future planning
- **Measurement:**
  - Primary: feature_list.json completion rate (count features with status="pass")
  - Secondary: Time to completion for each feature (track efficiency trends)
  - Qualitative: Jorge's assessment of code quality (not just "working" but "production-ready")
- **Target:** 18-25 of 28 features "pass" status (actual range: TBD after MVP)
- **Success Criteria:**
  - Minimum acceptable: ≥50% completion (14+ features) to avoid extending MVP timeline
  - Target: 60-70% completion (18-25 features) based on hypothesis
  - Stretch: >70% completion (20+ features) would validate aggressive automation
- **Post-MVP Action:** Document actual performance in lessons-learned.md, adjust Phase 1.5 estimates accordingly
- **Priority:** P0 (MVP success criterion)
- **Owner:** Jorge

---

### NFR Category 3: Scalability (3 NFRs)

**NFR-3.1: Team Growth Scalability**
- **Requirement:** System SHALL scale from 4 to 50 users with <10% performance degradation
- **Measurement:** Response times, workflow durations at different team sizes
- **Target:** <10% slowdown from baseline
- **Priority:** P1 (Phase 3)
- **Owner:** Jorge

**NFR-3.2: Repository & Workflow Growth**
- **Requirement:** System SHALL support 100+ repositories and 200+ workflows
- **Measurement:** GitHub org statistics, manual count
- **Target:** No architectural changes required
- **Priority:** P1 (Phase 2-3)
- **Owner:** Jorge

**NFR-3.3: Data Growth (Historical Analysis)**
- **Requirement:** System SHALL store 12+ months of dashboard data for trend analysis
- **Measurement:** dashboards/*/data/archive/ directory size
- **Target:** 12 months of weekly snapshots
- **Priority:** P2 (Phase 2)
- **Owner:** Jorge

---

### NFR Category 4: Reliability (3 NFRs)

**NFR-4.1: Workflow Reliability**
- **Requirement:** GitHub Actions workflows SHALL succeed 99% of the time (excluding confirmed external service outages)
- **External Service Outage Definition:**
  - **GitHub Status Page:** Incident posted at https://www.githubstatus.com/ affecting Actions service (yellow/red indicator)
  - **Third-party API outage:** Service status page confirms degradation (e.g., status.anthropic.com, status.openai.com)
  - **Network outage:** Verified via multiple monitoring services (e.g., DownDetector, Pingdom) showing widespread issues
  - **Decision authority:** Jorge (primary) or Buck (backup if Jorge unavailable >4h) determines if failure qualifies as external outage (check status pages, verify with team)
  - **Documentation:** All external outage classifications logged in incidents.md with evidence (status page URL, timestamp)
- **Exclusions (NOT external outages):**
  - Configuration errors (our fault - missing secrets, wrong permissions)
  - Code bugs (our fault - script errors, logic issues)
  - Rate limit exceeded (our fault - poor throttling)
  - Timeout due to inefficient code (our fault - optimize workflow)
- **Measurement:**
  - Total workflows: Count all GitHub Actions runs (success + failure)
  - Internal failures: Failures NOT classified as external outages
  - Failure rate: (internal failures / total workflows) * 100%
  - Target: <1% internal failure rate
- **Reporting:** Monthly workflow reliability report (success rate, failure breakdown, external vs internal)
- **Priority:** P1
- **Owner:** Jorge

**NFR-4.2: Graceful Degradation**
- **Requirement:** System SHALL continue at reduced capacity when external dependencies fail
- **Examples:**
  - If RSS feed down: Skip feed, continue aggregation
  - If Claude API down: Defer summary generation
  - If GitHub down: Work locally, sync when restored
- **Measurement (CLI-executable failure simulation):**
  - Simulate RSS feed failure: set invalid URL in test config, run aggregation script, verify exit code 0 and `jq '.failure_count > 0' cached_updates.json` is true
  - Simulate Claude API failure: `ANTHROPIC_API_KEY=invalid python3 scripts/generate-summary.py`; verify exits 0 with warning, does not crash
  - Verify error banner data: `jq '.failures | length > 0' cached_updates.json` after simulated failure (expect true)
  - Verify dashboard still produces output: `jq '.updates | length > 0' cached_updates.json` despite failures (expect true)
  - Verify staleness guard: inject timestamp >7 days old into cached_updates.json, verify aggregation script replaces rather than serving stale data
- **Priority:** P1
- **Owner:** Jorge

**NFR-4.3: Disaster Recovery**
- **Requirement:** System SHALL recover within 1 hour (RTO), losing <6 hours of data (RPO), validated through quarterly DR testing
- **RTO:** Recovery Time Objective = 1 hour (from incident declaration to full service restoration)
- **RPO:** Recovery Point Objective = Last data aggregation (6 hours max)
- **Testing Requirements:**
  - DR drills every 3 months starting Month 2 (first drill Month 2, then Month 5, Month 8, Month 11) - simulate: GitHub org deletion, repository corruption, secrets compromise, infrastructure account loss
  - Each drill documented with: scenario, steps, actual RTO/RPO, issues found, remediation
  - DR runbooks updated within 48 hours of drill completion
  - Success criteria: Restore within RTO/RPO targets in ≥80% of drills
- **Measurement:** Simulated disaster recovery drill execution logs, actual recovery times
- **Priority:** P2 (Phase 2 - first drill by Month 2)
- **Owner:** Jorge
- **Cross-Reference:** → [master-architecture.md](master-architecture.md) for disaster recovery procedures

**NFR-4.4: Web Deployment Verification Standard (T1→T4)**
- **Requirement:** All features deploying to a public URL SHALL be verified through four sequential tiers before marked complete; "files committed" does not equal "deployment working"
- **Verification Tiers (mandatory order):**
  - **T1 SOURCE:** Files exist locally with correct content and configuration (e.g., correct vite base path, workflow YAML present)
  - **T2 COMMITTED:** Files exist in correct GitHub repo/branch, verified via `gh api` — not assumed from local state
  - **T3 BUILT:** GitHub Actions workflow completed with `conclusion: success` — agent MUST poll and wait, not proceed immediately after push
  - **T4 LIVE:** Public URL returns HTTP 200 AND all JS/CSS assets referenced in HTML return HTTP 200 AND data endpoint returns valid JSON with expected record count
- **T4 Is Not "HTML Returns 200":** HTML can return 200 while JS/CSS assets 404 — the page appears loaded but React never boots. All asset URLs must be extracted from the built index.html and verified individually.
- **Asset Verification Pattern:**
  ```bash
  curl -sf -o /tmp/index.html <live-url>
  JS_PATH=$(grep -o 'src="/[^"]*\.js"' /tmp/index.html | head -1 | sed 's/src="//;s/"//')
  curl -sf "https://<host>${JS_PATH}" -o /dev/null && echo "PASS: JS bundle loads"
  CSS_PATH=$(grep -o 'href="/[^"]*\.css"' /tmp/index.html | head -1 | sed 's/href="//;s/"//')
  curl -sf "https://<host>${CSS_PATH}" -o /dev/null && echo "PASS: CSS bundle loads"
  ```
- **GitHub Actions Poll Pattern:**
  ```bash
  for i in $(seq 1 20); do
    STATUS=$(gh run list --repo <org>/<repo> --workflow <file.yml> \
      --limit 1 --json status,conclusion | jq -r '.[0] | "\(.status):\(.conclusion)"')
    [[ "$STATUS" == "completed:success" ]] && break
    [[ "$STATUS" == "completed:"* ]] && echo "FAIL: workflow failed" && exit 1
    sleep 30
  done
  ```
- **Lesson Learned (Phase 1 Agent Review 2026-02-23):** Autonomous agent marked FR-4.1 (AI Dashboard) as pass after files were committed, but the live deployment was broken — vite base path was wrong, causing JS 404. T1→T4 standard was created to prevent recurrence.
- **Applies To:** FR-1.5 (GitHub Pages), FR-4.1 (AI Dashboard), any future FR involving a public URL
- **Priority:** P0 (cross-cutting, applies to all web deployment features)
- **Owner:** Jorge (standard), autonomous agent (enforcement per feature)

---

### NFR Category 5: Maintainability (5 NFRs)

**NFR-5.1: Self-Documenting Architecture**
- **Requirement:** New team member SHALL understand architecture in <2 hours
- **Documentation:**
  - README at every directory level
  - ADRs for architectural decisions
  - Inline comments for complex logic
  - CLAUDE.md with AI agent context
- **Measurement:** Patrick's aha moment (Day 3), new team member onboarding time
- **Target:** <2 hours to comprehension
- **Priority:** P0 (MVP Day 3)
- **Owner:** Jorge (documentation), Patrick (validation)

**NFR-5.2: Consistent Patterns**
- **Requirement:** System SHALL follow consistent naming, structure, and workflow patterns
- **Patterns:**
  - Repository naming: `{product}-{component}[-{detail}]`
  - Branch naming: `feature/{name}`, `fix/{name}`, `docs/{name}`
  - Commit messages: Conventional Commits (feat, fix, docs, chore)
  - Workflow naming: `{action}-{target}.yml`
- **Measurement:** Manual code review, linting tools
- **Priority:** P1
- **Owner:** Jorge (enforcement)

**NFR-5.3: Minimal Custom Code**
- **Requirement:** System SHALL minimize custom code by leveraging BMAD library
- **Target:** 26% custom skills (8 of 26 total), 74% BMAD/adapted
- **Rationale:** Lower maintenance burden, battle-tested patterns
- **Measurement:** Skill count tracking
- **Priority:** P0 (BMAD-first strategy)
- **Owner:** Jorge

**NFR-5.4: Clear Ownership**
- **Requirement:** All code, docs, and workflows SHALL have clear ownership
- **Mechanisms:**
  - CODEOWNERS file in each repo
  - Frontmatter with author field
  - Team assignments for repos
  - Escalation paths documented
- **Measurement:** CODEOWNERS coverage, manual audit
- **Priority:** P1
- **Owner:** Jorge (setup), All (adherence)

**NFR-5.5: Skill Governance**
- **Requirement:** System SHALL prevent skill proliferation to <5 duplicate skills per quarter
- **Governance:**
  - Search before create
  - Usage tracking
  - Quarterly reviews
  - Consolidation recommendations
- **Measurement:** Skill count growth rate, duplicate detection
- **Target:** <5 duplicates per quarter
- **Priority:** P2 (Phase 1.5)
- **Owner:** Jorge

**NFR-5.6: GitHub Actions Workflow Authoring Standards**
- **Requirement:** GitHub Actions workflows SHALL comply with platform-specific authoring constraints that cannot be caught by local testing or linting.
- **Rationale:** Several GitHub Actions behaviors diverge from local execution and produce first-push CI failures. These constraints represent validated failure modes from live operation (2026-02-25) — each maps to a concrete failure type observed in the Seven Fortunas CI.
- **Mandatory Constraints:**
  1. **npm lock file required** — Any workflow using `cache: npm` or `npm ci` SHALL have a committed `package-lock.json` in the repository. Failure mode: "Some specified paths were not resolved, unable to cache dependencies"
  2. **No `secrets.*` in `if:` conditions** — `secrets.*` references are not valid in GitHub Actions `if:` expressions. Notification/email steps SHALL use `continue-on-error: true` instead of `if: secrets.X != ''` guards. Failure mode: Workflow silently shows 0s runtime with a workflow-file annotation error
  3. **YAML block scalars: no markdown at column 0** — Markdown text (`**bold**`, `- list`, `## heading`) at column 0 inside a YAML block scalar exits the block unexpectedly. Multi-line issue/PR bodies with markdown SHALL be extracted to shell scripts using heredoc. Failure mode: YAML parse error at the offending line
  4. **Bot commit loop prevention** — Workflows that commit to a repository path SHALL NOT include that path in their `on.push.paths` trigger. Failure mode: bot commit re-triggers the same workflow → infinite loop
  5. **Protected branch push fallback** — Bot `git push` to `main` SHALL include `|| echo "skipped"` fallback when branch protection rules are in effect. Failure mode: workflow fails with "Changes must be made through a pull request"
  6. **Unique concurrency groups** — Each workflow SHALL use a unique, descriptive `concurrency.group` value. Shared group names with `cancel-in-progress: true` cause competing workflows to cancel each other. Failure mode: later-triggered workflow is cancelled with no error
  7. **GitHub Pages deploy: `continue-on-error: true`** — All `actions/deploy-pages` steps SHALL have `continue-on-error: true`. GitHub Pages may not be enabled in all deployment environments. Failure mode: HttpError: Not Found fails the entire workflow
  8. **Paid org license tools** — Actions requiring vendor licenses for GitHub organization use (e.g., `gitleaks-action@v2`) SHALL have `continue-on-error: true` unless the license secret is confirmed configured. Failure mode: "License key is required" terminates the workflow
- **Acceptance Criteria:**
  - ✅ All generated workflows pass CI on first push (no 0s failures, no YAML parse errors)
  - ✅ No bot commit trigger loops (verify push paths do not include auto-committed directories)
  - ✅ `package-lock.json` committed before any workflow specifying `cache: npm`
  - ✅ All `actions/deploy-pages` steps have `continue-on-error: true`
  - ✅ All notification/email steps use `continue-on-error: true`, not `if: secrets.X != ''`
  - ✅ `concurrency.group` values are unique across all workflows in `.github/workflows/`
- **Priority:** P0 (cross-cutting — prevents systematic first-push CI failures across all features)
- **Owner:** Jorge (standard), autonomous agent (generation compliance)

---

### NFR Category 6: Integration (3 NFRs)

**NFR-6.1: API Rate Limit Compliance**
- **Requirement:** System SHALL respect rate limits of all external APIs
- **APIs & Limits:**
  - GitHub API: 5,000 req/hour (authenticated)
  - Claude API: 50 req/min, 40,000 req/day
  - Reddit JSON: 60 req/min (unauthenticated)
  - OpenAI Whisper: No documented limit (use responsibly)
  - X API: Basic $100/mo tier provides 10,000 req/month (Free tier discontinued April 2023; MVP uses RSS/public data only, paid tier Phase 2 subject to budget approval)
- **Measurement:** API usage dashboards, error logs
- **Priority:** P0
- **Owner:** Jorge

**NFR-6.2: External Dependency Resilience**
- **Requirement:** System SHALL implement retry logic and error logging for external dependencies
- **Retry Strategy:**
  - Exponential backoff (1s, 2s, 4s, 8s)
  - Max 5 retries per operation
  - Clear error logging
  - Fallback to degraded mode
- **Measurement:** Error logs, uptime monitoring
- **Priority:** P1
- **Owner:** Jorge

**NFR-6.3: Backward Compatibility**
- **Requirement:** System SHALL maintain backward compatibility for dependencies for 1+ year
- **Policy:**
  - Pin BMAD version (no auto-updates)
  - Test before upgrading major versions
  - Maintain migration guides
  - Deprecation notices 90 days in advance
  - Lock file prerequisites: Dependabot SHALL NOT be configured for `pip` or `npm` ecosystems unless `requirements.txt` or `package-lock.json` respectively exist in the repository. Missing lock files cause Dependabot to silently report no updates and `cache: npm` CI steps to fail with a path resolution error.
- **Measurement:** Dependency version tracking, manual audits
- **Priority:** P2
- **Owner:** Jorge

---

### NFR Category 7: Accessibility (2 NFRs)

**NFR-7.1: CLI Accessibility**
- **Requirement:** All CLI tools SHALL have comprehensive documentation and onboarding
- **Documentation:**
  - README with quick start
  - Command reference
  - Examples and tutorials
  - Troubleshooting guide
- **Measurement:** New team member onboarding time (<2 hours)
- **Target:** All founders productive within 2 hours
- **Priority:** P0 (MVP Day 3)
- **Owner:** Jorge (docs), All (validation)

**NFR-7.2: Phase 2 Accessibility Improvements**
- **Requirement:** Phase 2 SHALL improve accessibility beyond CLI
- **Improvements:**
  - GitHub Codespaces integration (cloud development)
  - Web-based alternatives for CLI tools
  - Mobile-responsive dashboards (read-only)
  - Voice input on mobile (Phase 2 priority)
- **Measurement:** User feedback, usage analytics
- **Priority:** P3 (Phase 2 - Months 1-3)
- **Owner:** Team

---

### NFR Category 8: Observability & Monitoring (4 NFRs)

**NFR-8.1: Structured Logging**
- **Requirement:** All systems SHALL emit structured logs with consistent format and severity levels
- **Log Levels:** ERROR (failures), WARN (degraded state), INFO (key events), DEBUG (troubleshooting)
- **Log Format:** JSON with timestamp, severity, component, message, context (user_id, request_id, feature_id)
- **Log Retention:**
  - ERROR/WARN: 90 days (searchable)
  - INFO: 30 days
  - DEBUG: 7 days (or disabled in production)
- **Measurement:** Log format validation, manual spot-checks
- **Priority:** P1 (Phase 1.5)
- **Owner:** Jorge

**NFR-8.2: System Metrics & Alerting**
- **Requirement:** System SHALL collect and alert on key operational metrics
- **Metrics:**
  - Infrastructure: Workflow success rate, API rate limit usage (%), storage usage
  - Performance: Dashboard generation time, skill execution time, search latency
  - Security: Secret detection attempts, failed authentication, suspicious activity
  - Business: Daily active users, skill invocation count, dashboard views
- **Alerting:**
  - Critical: Workflow failure rate >5%, API rate limit >90%, security incidents (page Jorge immediately via PagerDuty free tier with SMS/push notifications; backup: direct SMS to Jorge's mobile if PagerDuty unavailable)
  - Warning: Workflow failure rate >2%, API rate limit >75%, performance degradation >20%
- **Measurement:** Alert response time, false positive rate
- **Priority:** P1 (Phase 1.5)
- **Owner:** Jorge

**NFR-8.3: Debugging & Troubleshooting**
- **Requirement:** System SHALL provide debugging workflows for common failure scenarios
- **Debugging Tools:**
  - Autonomous agent: `./scripts/debug_agent.sh <feature_id>` (shows logs, retries, state)
  - GitHub workflows: `gh run view <run_id> --log` (full workflow logs)
  - Secret detection: `./scripts/test_secret_detection.sh` (validate detection layers)
- **Common Failure Runbooks:**
  - "Dashboard not updating" → Check GitHub Actions status → Verify API keys → Review rate limits
  - "Secret detection false positive" → Review detection pattern → Update exclusion rules → Redeploy
  - "Skill invocation timeout" → Check Claude API status → Review request payload → Retry with smaller context
- **Measurement:** Mean time to resolution (MTTR) for common issues <30 minutes
- **Priority:** P1 (Phase 1.5)
- **Owner:** Jorge

**NFR-8.4: Production Troubleshooting Access**
- **Requirement:** On-call engineer SHALL have diagnostic access without compromising security
- **Access Model:**
  - Read-only access to logs, metrics, workflow runs
  - No direct access to secrets (use secret rotation if compromise suspected)
  - Audit trail for all diagnostic queries
- **Acceptance Criteria:**
  - ✅ Jorge can query last 24h of ERROR logs in <2 minutes
  - ✅ Jorge can identify failed workflow and root cause in <10 minutes
  - ✅ All diagnostic access logged to audit trail
- **Priority:** P1 (Phase 1.5)
- **Owner:** Jorge

---

### NFR Category 9: Cost Management (3 NFRs)

**NFR-9.1: API Cost Tracking**
- **Requirement:** System SHALL track and alert on API usage costs
- **Tracked APIs:**
  - Claude API: ~$0.015/1K input tokens, ~$0.075/1K output tokens (track daily spend)
  - X API: $100/month (Basic tier, 10K requests/month - track usage %)
  - GitHub Actions: 2,000 minutes/month free (private repos, track usage %)
- **Cost Budgets (Revised):**
  - MVP (Month 1): $5-10/month (Claude API only, GitHub free tier)
  - Phase 2 (Months 2-3): $130-150/month (Claude $10, X API $100, GitHub Projects $16, Matrix VPS $15)
  - Phase 3 (Months 6-12): $300-500/month (includes GitHub Team tier expansion)
- **Alerts:**
  - Warning: 75% of monthly budget consumed
  - Critical: 90% of monthly budget consumed (pause non-critical workflows)
- **Measurement:** Daily cost dashboard, monthly cost reports
- **Priority:** P1 (Phase 1.5)
- **Owner:** Jorge

**NFR-9.2: Rate Limit Enforcement**
- **Requirement:** System SHALL enforce rate limits to prevent runaway costs
- **Rate Limits:**
  - Claude API: Max 40 requests/hour per dashboard (prevents runaway loops)
  - X API: Max 9,000 requests/month (10K limit - 10% safety buffer)
  - GitHub API: Max 4,500 requests/hour (5K limit - 10% safety buffer)
- **Enforcement:**
  - Workflow-level throttling (sleep between requests)
  - Circuit breaker pattern (stop after 5 consecutive failures)
  - Manual override requires explicit approval (Jorge approves for security-critical overrides, team lead approves for operational overrides) + justification logged to audit trail
- **Measurement:** Rate limit violations (target: zero)
- **Priority:** P1 (Phase 1.5)
- **Owner:** Jorge

**NFR-9.3: Resource Optimization**
- **Requirement:** System SHALL optimize resource usage to minimize costs
- **Optimization Targets:**
  - Dashboard aggregation: Parallel API calls (reduce wall-clock time)
  - Claude API usage: Cache responses for 6 hours (avoid duplicate summaries)
  - GitHub Actions: Use public repos for dashboards (unlimited minutes)
  - Storage: Archive old data, compress logs
- **Measurement:** Month-over-month cost trend (target: <10% increase as usage scales)
- **Priority:** P2 (Phase 2)
- **Owner:** Jorge

---

### NFR Category 10: Data Management (3 NFRs)

**NFR-10.1: Data Migration & Versioning**
- **Requirement:** System SHALL support backward-compatible data format changes
- **Migration Strategy:**
  - Semantic versioning for data schemas (e.g., dashboard-config-v2.yaml)
  - Migration scripts in ./scripts/migrations/ directory
  - Automated migration on version upgrade (with rollback support; rollback SLA: <30 min for schema changes, <5 min for config-only changes)
  - No manual data editing required for version upgrades
- **Acceptance Criteria:**
  - ✅ Schema version documented in all data files (YAML frontmatter: schema-version: 2.0)
  - ✅ Migration script exists for each schema change
  - ✅ Migration tested on copy of production data before deployment
  - ✅ Rollback script available for each migration
- **Priority:** P2 (Phase 2 - before first schema change)
- **Owner:** Jorge

**NFR-10.2: Data Integrity & Validation**
- **Requirement:** System SHALL validate data integrity on read and write operations
- **Validation:**
  - YAML schema validation (reject malformed configs)
  - Required field validation (reject incomplete data)
  - Cross-reference validation (ensure linked entities exist)
  - Encoding validation (UTF-8, no null bytes)
- **Error Handling:**
  - Validation failures logged with clear error message
  - Invalid data rejected (fail fast, don't corrupt)
  - Validation errors reported to owner (via GitHub issue)
- **Measurement:** Validation failure rate, data corruption incidents (target: zero)
- **Priority:** P1 (Phase 1.5)
- **Owner:** Jorge

**NFR-10.3: Data Archival & Retention**
- **Requirement:** System SHALL archive old data according to retention policy
- **Retention Policies:**
  - Dashboard raw data: 7 days (debugging only)
  - Dashboard aggregated data: Overwritten every 6 hours (latest snapshot only)
  - Dashboard historical archives: 52 weeks (weekly snapshots)
  - AI summaries: Indefinite (part of knowledge base)
  - Second Brain: Indefinite (version controlled)
  - Logs: ERROR/WARN 90 days, INFO 30 days, DEBUG 7 days
- **Archival Process:**
  - Weekly: Archive old dashboard snapshots to dashboards/ai/archive/YYYY-MM-DD.json
  - Monthly: Compress archived data (gzip)
  - Quarterly: Purge data older than retention period
- **Measurement:** Storage growth rate, archival job success rate
- **Priority:** P2 (Phase 2)
- **Owner:** Jorge

---


