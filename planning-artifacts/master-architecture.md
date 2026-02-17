---
title: Architecture Master Document
type: Master Document (4 of 6)
sources: [architecture-7F_github-2026-02-10.md, domain-requirements.md, innovation-analysis.md, ux-design-specification.md]
date: 2026-02-15
author: Mary (Business Analyst) with Jorge
status: Phase 2 - Master Consolidation
version: 1.8.0
editorial-review: Complete (structure + prose + adversarial, 2026-02-15)
adversarial-review: Complete (18 findings resolved, 2026-02-15)
phase-2-additions: Phase 2 architecture components added (Matrix, GitHub Projects, 2026-02-15)
autonomous-readiness-improvements: Technology versions added (REC-1, 2026-02-16)
---

# Architecture Master Document

## System Architecture Overview

**Three Interconnected Systems:**
1. BMAD Skills Platform (conversational infrastructure)
2. Second Brain (progressive disclosure knowledge base)
3. 7F Lens Intelligence Platform (multi-dimensional dashboards)

**Architecture Style:** 3-tier monolithic (Presentation → Business Logic → Data), Git-as-database
**Deployment Model:** GitHub-hosted (Free → Team → Enterprise tiers)
**Security Model:** 5-layer defense (access, code, workflow, data, monitoring)

**Note:** NOT a microservices architecture - Three systems share infrastructure (GitHub), use common data layer (Git), and are deployed together (not independently scalable services)

**Architectural Diagrams:** Visual diagrams for system architecture, data flows, and component interactions are pending creation in Phase 1.5. This document provides comprehensive text-based architecture specifications that can be used to generate diagrams.

---

## Component Architecture

### 1. BMAD Skills Platform
- **Location:** `_bmad/` (Git submodule), `.claude/commands/` (skill stubs)
- **Integration:** BMAD v6.0.0 pinned, 18 adopted + 5 adapted + 3 custom = 26 skills
- **Execution:** Claude Code SDK, conversational interface
- **Skill-Creation Skill:** Meta-skill generates new skills from YAML requirements

### 2. Second Brain
- **Repository:** seven-fortunas-brain (second-brain-core/)
- **Structure:** Progressive disclosure (3-level hierarchy)
- **Format:** Markdown + YAML frontmatter (dual-audience)
- **Directories:** brand/, culture/, domain-expertise/, best-practices/, skills/
- **Entry Point:** index.md (AI agents load first)

### 3. 7F Lens Dashboards
- **Repository:** dashboards/ (public), dashboards-internal/ (private)
- **Data Pipeline:** Fetch (6h) → Aggregate → AI Summarize (weekly) → Display
- **Technology:** GitHub Actions (aggregation), Claude API (summaries), GitHub Pages (hosting)
- **MVP Dashboard:** AI Advancements Tracker

### 4. GitHub Organizations
- **Two-Org Model:** Seven-Fortunas (public), Seven-Fortunas-Internal (private)
- **Team Structure:** 10 teams (5 per org) representing functions, not products
- **Security:** 2FA enforced, Dependabot, secret scanning, push protection, branch protection

### 5. GitHub Projects (Phase 2)
- **Purpose:** Sprint board management, Kanban visualization
- **Integration:** GitHub Projects API for programmatic board updates
- **Structure:** One project per active sprint, columns (Backlog, In Progress, Review, Done, Blocked)
- **Automation:** `7f-sprint-dashboard` skill for conversational board updates

### 6. Matrix Communication Platform (Phase 2)
- **Homeserver:** Self-hosted Synapse v1.98+ (mature, recommended) or Dendrite v0.13+ (lightweight alternative if RAM-constrained)
- **Decision Criteria:** Synapse for <20 users (mature, 2GB RAM), Dendrite if RAM <1GB (beta stability trade-off)
- **Deployment:** Docker container on dedicated VPS only (DigitalOcean/Linode $12-20/month, 2GB RAM minimum)
- **Channels:** Mirror GitHub structure (#infrastructure, #dashboards, #brain, #general)
- **GitHub Bot:** Posts PR/issue/CI updates to relevant Matrix channels
- **Security:** E2E encryption (Olm/Megolm), federated identity
- **Storage:** PostgreSQL only (4GB RAM, 50GB disk for 1 year message history with 10 users)
- **Backup:** Daily automated backups to cloud storage (Backblaze B2 $0.005/GB), 30-day retention, RTO <4h (restore time), RPO <24h (data loss window - last backup before failure)
- **Monitoring:** UptimeRobot (free tier, 5-min checks), PagerDuty alerts (free tier) to Jorge + Buck

---

## Component Interactions & Data Flow

### Critical Data Flow Paths

#### 1. Authentication Flow
```
User → GitHub OAuth → BMAD Skills Platform
  ↓
Verify 2FA enforced
  ↓
Check team membership (least privilege)
  ↓
Grant token with minimal scopes
  ↓
Store in GitHub Secrets (encrypted at rest)
  ↓
Skills access GitHub API (authenticated)
```

**Error Handling:** Failed auth → 401 Unauthorized → Log to audit → Display user-friendly message → Prompt re-authentication

#### 2. Secret Scanning Flow (FR-5 Core Feature)
```
User invokes /bmad-secret-scan [repo-url]
  ↓
BMAD skill validates inputs
  ↓
GitHub API: Clone repository (authenticated)
  ↓
Python script: Scan files with regex patterns
  ↓
Detect secrets (≥99.5% detection, ≤0.5% false negatives per NFR-1.1)
  ↓
Generate scan report (JSON)
  ↓
Store in Second Brain (second-brain-core/reports/)
  ↓
Display summary in Claude Code interface
```

**Error Propagation:**
- **GitHub API failure (rate limit):** Retry with exponential backoff → Display wait time to user
- **Repository too large (>1GB):** Warn user → Offer shallow clone option
- **Scan timeout (>5min):** Cancel → Save partial results → Flag timeout in report
- **Parse error:** Skip file → Log error → Continue scan → Report unparsable files

#### 3. Dashboard Aggregation Flow
```
GitHub Actions cron (every 6h)
  ↓
Fetch data from 6-10 external APIs in parallel:
  - RSS feeds (feedparser)
  - Reddit (praw)
  - YouTube (RSS)
  - X API (if available)
  - Arxiv (RSS)
  - GitHub releases (GitHub API)
  ↓
Aggregate into latest.json (overwrite)
  ↓
Archive previous to archive/YYYY-MM-DD.json
  ↓
Commit to Git (audit trail)
  ↓
Trigger weekly summary (Sunday 00:00 UTC)
  ↓
Claude API: Generate weekly summary (~10 API calls)
  ↓
Store summary in summaries/YYYY-WW.md
  ↓
GitHub Pages: Display updated dashboard
```

**Error Propagation:**
- **Single API failure:** Skip that source → Log error → Continue with remaining sources → Display partial data
- **All APIs fail:** Use cached data from previous run → Display staleness warning
- **Claude API rate limit:** Queue summary → Retry next hour → Display stale summary meanwhile
- **Git commit conflict:** Retry with pull → Merge → Commit

### Cross-Layer Communication

**Layer 1: Presentation (GitHub Pages, Claude Code UI)**
- **To Business Logic:** HTTPS requests with auth tokens, skill invocations
- **Error Handling:** Display user-friendly messages, log technical details, offer retry

**Layer 2: Business Logic (BMAD Skills, GitHub Actions)**
- **To Data Layer:** GitHub API calls (CRUD operations), file writes (Git commits)
- **To Presentation:** JSON responses, Markdown reports, status updates
- **Error Handling:** Validate inputs, catch exceptions, return structured errors, emit structured logs

**Layer 3: Data Layer (Git repositories, GitHub API)**
- **To Business Logic:** API responses (JSON), file contents, commit status
- **Error Handling:** Rate limit responses (429), authentication errors (401), not found (404)

**Integration Protocols:**
- **GitHub API:** REST API, OAuth authentication, rate limit headers (X-RateLimit-Remaining)
- **Claude API:** REST API, Bearer token auth, streaming responses for long summaries
- **External APIs:** Varies (OAuth, API keys, public RSS)

---

## Data Architecture

**Git-as-Database Pattern:**
- All data committed to Git (version control, backup, audit trail)
- Dashboard data: latest.json (current), archive/ (historical), summaries/ (AI-generated)
- Second Brain: Markdown files with YAML frontmatter
- Configuration: YAML files (sources.yaml for dashboards)

**Data Retention:**

| Data Type | Retention Period | Storage System | Deletion Procedure | Rationale |
|-----------|------------------|----------------|-------------------|-----------|
| **Raw API responses** | 7 days | Git (`data/raw/YYYY-MM-DD/`) | Automated: GitHub Action deletes files >7 days old (runs daily 01:00 UTC) | Debugging recent aggregation issues |
| **Processed latest.json** | Overwritten every 6h | Git (`data/latest.json`) | Overwrite on each run (no deletion needed) | Current dashboard state |
| **Historical archives** | 52 weeks | Git (`data/archive/YYYY-MM-DD.json`) | Automated: GitHub Action deletes files >52 weeks old (runs monthly) | Trend analysis, historical lookups |
| **AI weekly summaries** | Indefinite | Git (`summaries/YYYY-WW.md`) | Manual deletion only (user decision) | Long-term insights, searchable history |
| **Second Brain content** | Indefinite | Git (`second-brain-core/`) | Manual deletion only (version controlled, no auto-deletion) | Knowledge base, durable reference |
| **Scan reports** | 90 days | Git (`second-brain-core/reports/scans/`) | Automated: GitHub Action deletes >90 days (runs monthly) | Compliance audit trail |
| **Audit logs** | 1 year (Phase 3) | GitHub audit log API + archive | GitHub native retention (1yr) + manual export to cloud storage | Security compliance, forensics |

**Deletion Scripts:**
- `scripts/cleanup_raw_data.sh` - Deletes raw data >7 days (cron: daily 01:00 UTC)
- `scripts/cleanup_archives.sh` - Deletes archives >52 weeks (cron: 1st of month)
- `scripts/cleanup_scan_reports.sh` - Deletes scan reports >90 days (cron: 1st of month)

**Data Lifecycle Management:**
1. **Ingestion:** External APIs → Raw data (7-day TTL)
2. **Processing:** Raw → Aggregated (latest.json, overwrite every 6h)
3. **Archival:** Aggregated → Historical archive (52-week TTL)
4. **Summarization:** Historical → AI summary (indefinite)
5. **Deletion:** Automated cleanup scripts (run via GitHub Actions)

---

## Integration Points

**GitHub API:** 5,000 req/hour (authenticated), org management, repo operations, team/permission management
**GitHub Projects API (Phase 2):** Sprint board management, card status updates, backlog queries (GraphQL API, 5,000 points/hour rate limit; note: GraphQL queries have variable point costs - simple queries: 1-5 points, complex queries with multiple resources: 20-50+ points; actual usage depends on query complexity)
**GitHub Secrets API:** Org-level secret storage/retrieval, encrypted at rest by GitHub (same rate limit as GitHub API)
**GitHub Discussions:** Asynchronous communication, threaded conversations, searchable (no API rate limit, web UI + GraphQL API)
**Claude API:** 50 req/min, 40K req/day, weekly dashboard summaries (~10 req/week), ~$0.05-5/month
**OpenAI Whisper:** Voice transcription (MacOS native, Linux CLI)
**Matrix Homeserver (Phase 2):** Self-hosted real-time chat, E2E encryption, federation support (no rate limits, self-hosted)
**External Data:** RSS feeds (unlimited), Reddit JSON (60 req/min), YouTube RSS (unlimited), X API (Basic $100/mo provides 10K req/month; Free tier discontinued April 2023)

---

## Architectural Decision Records (ADRs)

### ADR-001: Two-Org Model
**Decision:** Use two orgs (public/private) instead of multiple orgs per function
**Rationale:** Clear security boundary, scales better (10 teams not 50 orgs), easier permissions
**Consequences:**
- Must use teams for access control (10 teams × 5 permissions = 50 configurations)
- Need GitHub Private Mirrors App for selective publishing (see below)
- Upfront complexity cost: ~8 hours (org setup 2h, team structure 3h, permission audit 2h, testing 1h) - **Note:** Time estimates are illustrative based on similar projects, not formal benchmarks
- **Cost Comparison:** Two-org model ($0 MVP, $48/mo Phase 2 with GitHub Team) vs. multi-org model ($0 MVP, $192+/mo Phase 2 with 4+ GitHub Team orgs)

**GitHub Private Mirrors App Design:**
- **Purpose:** Selectively publish internal docs to public repos (e.g., sanitized architecture docs, public Second Brain excerpts)
- **Authentication:** GitHub App with read access to Seven-Fortunas-Internal, write access to Seven-Fortunas
- **Permissions:** Repository contents (read private), Contents (write public), Metadata (read both)
- **Lifecycle:**
  1. User tags internal file with `public-mirror: true` in YAML frontmatter
  2. GitHub Action (runs on push to main) detects tagged files
  3. App copies file to public repo (strips sensitive sections marked `<!-- internal-only -->`)
  4. Commits to public repo with attribution
  5. User reviews public PR before merge
- **Delivery:** Phase 2 (post-MVP) - MVP uses manual copy/paste
- **Cost:** 16-24 hours development (GitHub App setup 4h, sync logic 8-12h, testing 4-8h) - **Note:** Time estimates are illustrative based on similar integrations, not formal benchmarks

### ADR-002: Progressive Disclosure (Second Brain)
**Decision:** Load index.md first, specific sections as needed
**Rationale:** Reduces token usage, faster for AI, scalable, Obsidian-compatible
**Consequences:** Two-step loading (index → specific doc), more files to manage

### ADR-003: GitHub Actions for Dashboards
**Decision:** Use GitHub Actions for aggregation (not Zapier, Lambda)
**Rationale:** Free on public repos, co-located with code, built-in secrets, easy debugging
**Consequences:** 2,000 min/month limit on private repos (use public for dashboards)

### ADR-004: Skill-Creation Skill (Meta-Skill)
**Decision:** Auto-generate skills from YAML requirements
**Rationale:** DRY, consistent structure, faster iteration, self-improving
**Consequences:**
- Upfront complexity cost: ~12 hours (template design 4h, generator logic 6h, testing 2h) - **Note:** Time estimates are illustrative based on similar automation, not formal benchmarks
- Breakdown: 3 components (YAML parser, template engine, validation logic), ~400 lines Python
- ROI threshold: 6 skills (12h ÷ 2h saved per skill = 6 skills to break even)
- MVP has 3 custom skills → Build manually for MVP, create meta-skill in Phase 2 when adding 6+ more skills (at breakeven point)

### ADR-005: Personal API Keys MVP → Corporate Post-Funding
**Decision:** Use personal API keys for MVP, migrate post-funding
**Rationale:** Unblocks MVP, lower cost, clear migration path
**Consequences:** Must document in registry, monitor usage, plan migration

---

## BMAD Library Management

### Versioning Strategy
- **Current:** BMAD v6.0.0 (pinned via Git submodule SHA)
- **Update Cadence:** Quarterly review, update only if critical bugs or needed features
- **Version Pinning:** Lock to specific commit SHA, not branch (prevents surprise breaking changes)

### Migration Plan (BMAD Updates)

**Pre-Migration (Preparation):**
1. Review BMAD CHANGELOG for breaking changes
2. Identify affected skills (18 adopted + 5 adapted = 23 skills to check)
3. Create feature branch: `bmad-upgrade-v6.1.0`
4. Estimated time: 1-2 hours

**Migration (Execution):**
1. Update submodule: `git submodule update --remote _bmad`
2. Run test suite: `./scripts/test_all_skills.sh` (tests 26 skills)
3. Fix broken skills (adapted skills most likely to break)
4. Update skill stubs if API changed
5. Manual smoke test: Invoke 5 critical skills (secret-scan, create-prd, dashboard-setup, second-brain-init, org-setup)
6. Estimated time: 2-4 hours (depends on breaking changes)

**Rollback Procedure:**
1. Revert submodule commit: `git submodule update --init`
2. Checkout previous SHA: `cd _bmad && git checkout <previous-sha>`
3. Verify skills work: `./scripts/test_all_skills.sh`
4. Estimated time: 15 minutes

**Testing Strategy:**
- Unit tests: Python scripts (`pytest` for aggregation scripts)
- Integration tests: Skill invocation via Claude Code (manual)
- Smoke tests: 5 critical skills (automated via shell script)

### Skill Packaging & Distribution

**Packaging Format:**
```
_bmad/{module}/workflows/{category}/{workflow-name}/
├── workflow.md              # Main workflow definition
├── steps/
│   ├── create-*.md         # Generative steps
│   ├── edit-*.md           # Transformation steps
│   └── validate-*.md       # Quality gates
├── data/
│   └── *.yaml              # Configuration data
└── templates/
    └── *.md                # Output templates
```

**Skill Stub Format:**
```markdown
# bmad-{module}-{workflow-name}

Read and follow: {project-root}/_bmad/{module}/workflows/{category}/{workflow-name}/workflow.md
```

**Distribution Channels:**
1. **Direct (MVP):** Copy `_bmad/` directory + `.claude/commands/` stubs to consuming project
2. **Git Submodule (Phase 2):** Add as submodule, symlink skill stubs
3. **BMAD Registry (Phase 3):** Publish to central registry, `bmad install <skill-name>`

**Versioning:**
- Skills versioned with BMAD library (no independent versioning for MVP)
- Custom skills: Version in Git (tag releases: `v1.0.0`)
- Breaking changes: Major version bump, migration guide in CHANGELOG

---

## Technology Stack

**Core:** GitHub (hosting/storage/automation), GitHub Pages (website), GitHub Actions (automation), Claude API (AI processing), Markdown + Git (Second Brain)

### Core Languages

- **Python:** 3.11+ (for automation scripts, dashboard aggregation)
- **JavaScript:** ES6+ (for dashboard UI)
- **Bash:** 5.x (for shell scripts)
- **Markdown + YAML:** (for BMAD skills, Second Brain content)
- **HTML + CSS:** (for website presentation)

### Frameworks & Platforms

- **BMAD:** v6.0.0 (pinned via Git submodule)
- **React:** 18.x (for 7F Lens dashboards)
- **Node.js:** 18 LTS+ (for build tools, GitHub Actions)
- **GitHub Actions:** Latest (CI/CD automation)

### AI/ML

- **Claude API:** Latest (claude-sonnet-4-5-20250929 for AI processing)
- **OpenAI Whisper:** 3.0+ (voice transcription, MVP optional feature for FR-2.3/Henry Day 3 validation, not required infrastructure)

### Infrastructure & Tools

- **Git:** 2.40+
- **GitHub CLI (gh):** 2.40+
- **Docker:** 24+ (optional, Phase 2)

### Python Dependencies

- feedparser (RSS parsing)
- praw (Reddit API)
- anthropic (Claude API client)
- requests (HTTP client)
- pyyaml (YAML parsing)
- python-dotenv (environment variables)

---

## Deployment Architecture

### Environment Topology

**MVP (Single Environment):**
```
Production Environment (GitHub.com)
├── Organization: Seven-Fortunas (public)
│   ├── Repos: dashboards, bmad-skills
│   ├── GitHub Pages: dashboards.sevenfortunas.com
│   └── GitHub Actions: Dashboard aggregation (2,000 min/month free)
├── Organization: Seven-Fortunas-Internal (private)
│   ├── Repos: infrastructure-project, brain-internal
│   ├── GitHub Actions: Automation (2,000 min/month paid)
│   └── Secret storage: GitHub Secrets (org-level)
└── Developer Machines: MacOS/Linux
    ├── Claude Code: BMAD skills execution
    ├── Git: Local clones, push to GitHub
    └── Python 3.11+: Script development
```

**No staging environment for MVP** - Git version control provides rollback safety

### Deployment Procedures

**BMAD Skills Deployment:**
1. Develop skill in `_bmad/{module}/workflows/{category}/{workflow-name}/`
2. Create skill stub in `.claude/commands/bmad-{module}-{workflow-name}.md`
3. Test locally with Claude Code (skill invocation validation)
4. Commit to Git (feature branch)
5. Merge to main (after manual review)
6. Distribute: Git submodule update in consumer repos
7. **Rollback:** Git revert commit, submodule update to previous version

**Dashboard Deployment:**
1. Update aggregation script in `scripts/aggregate.py`
2. Update `sources.yaml` configuration
3. Commit to main (direct commit for MVP, PRs post-Phase 1)
4. GitHub Actions: Auto-deploy on push to main
5. GitHub Pages: Rebuild site (<2 min)
6. **Rollback:** Git revert commit, GitHub Actions re-run

**Second Brain Deployment:**
1. Edit Markdown files in `second-brain-core/`
2. Update index.md if new sections added
3. Commit to main (direct commit for MVP)
4. **Rollback:** Git revert commit

### Failure Modes by Component

**BMAD Skills Platform:**
- **GitHub API unavailable:** Skills fail → Display error → User retries manually
- **Claude Code crash:** Restart Claude Code → Resume from last committed state
- **Skill syntax error:** Validation catches → Fix → Redeploy

**Second Brain:**
- **Markdown parse error:** Agent displays raw markdown → User fixes manually
- **Index.md missing:** Agent cannot load Second Brain → Alert user → Restore from Git history
- **Circular references:** Agent detects loop → Display error → User fixes structure

**7F Lens Dashboards:**
- **GitHub Actions quota exceeded:** Wait until next month → Display stale data → User manually triggers with personal account
- **All external APIs fail:** Display cached data (last 6h) → Show staleness warning
- **Claude API quota exceeded:** Skip weekly summary → Display previous week's summary → User manually generates
- **GitHub Pages build fails:** Display previous version → Alert owner → Fix HTML/CSS error

---

## Error Handling & Resilience

### GitHub API Integration Error Handling

**Rate Limit Handling (5,000 req/hour):**
- Exponential backoff with rate limit awareness
- For 429 (rate limited): Wait if <5 min until reset, fail fast if >5 min
- For 401: Prompt user to re-authenticate (`gh auth login`)
- For 403: Raise permission error
- For 404: Return None (resource doesn't exist, not an error)
- For 5xx: Exponential backoff (1s, 2s, 4s) with max 3 retries
- Implementation: See `/scripts/github_api_utils.py` (to be created Day 0)

**Authentication Failure Handling:**
1. Detect: 401 Unauthorized response
2. Log: Audit log entry (failed auth attempt, timestamp, user, endpoint)
3. User notification: "GitHub authentication failed. Please re-authenticate with `gh auth login`"
4. Recovery: Prompt re-authentication, verify token scopes
5. Prevention: Token expiry check before API calls (proactive refresh)

**Outage Handling (GitHub API unavailable):**
1. Detect: 5xx errors, connection timeout (10s), DNS resolution failure
2. Circuit breaker: Open after 5 consecutive failures (30s cool-down)
3. Fallback: Use cached data if available (display staleness warning)
4. User notification: "GitHub API is experiencing issues. Retrying automatically..."
5. Status page check: Query https://www.githubstatus.com/api/v2/status.json
6. Recovery: Exponential backoff (1s, 2s, 4s, 8s, 16s), max 5 retries

### Failure Modes by Architecture Tier

#### Tier 1: Presentation Layer

| Failure Mode | Detection | Impact | Mitigation | Recovery Time |
|--------------|-----------|--------|------------|---------------|
| **GitHub Pages down** | HTTP 503, timeout | Dashboard inaccessible | Display cached version (CDN), status page | 2-4 hours (GitHub incident) |
| **Claude Code crash** | Process exit, unhandled exception | Skill execution interrupted | Auto-save work in progress, restart Claude Code | <2 minutes (manual restart) |
| **Browser tab crash** | Tab unresponsive | Dashboard view lost | Service worker cache, reload page | <10 seconds (manual refresh) |

#### Tier 2: Business Logic Layer

| Failure Mode | Detection | Impact | Mitigation | Recovery Time |
|--------------|-----------|--------|------------|---------------|
| **BMAD skill syntax error** | Skill validation failure | Skill unusable | Rollback to previous version (Git), fix syntax | <30 minutes (manual fix) |
| **Python script exception** | Unhandled exception, exit code ≠0 | Aggregation/scan fails | Try-catch blocks, log error, skip item, continue | <5 minutes (auto-retry) |
| **GitHub Action timeout** | 6h cron job runs >10 min | Stale dashboard data | Split into parallel jobs, reduce API calls | <6 hours (next run) |
| **Claude API quota exceeded** | 429 response, 40K req/day | Summary generation fails | Queue summaries, use cached summary, upgrade tier | <24 hours (quota reset) |

#### Tier 3: Data Layer

| Failure Mode | Detection | Impact | Mitigation | Recovery Time |
|--------------|-----------|--------|------------|---------------|
| **Git merge conflict** | Merge error, conflicting commits | Data write blocked | Auto-merge strategy (ours), manual resolution if complex | <15 minutes (auto/manual) |
| **Corrupted JSON file** | JSON parse error | Dashboard displays error | Validate before commit, rollback to previous version | <10 minutes (Git revert) |
| **Repository size limit** | >1GB warning, API rejection | New data cannot be committed | Prune old data, use Git LFS (Large File Storage) for files >50MB, split repos | 1-2 hours (cleanup) |
| **External API deprecation** | 410 Gone, sunset header | Data source unavailable | Remove source from config, update documentation | <1 hour (config update) |

### Cascading Failure Prevention

**Circuit Breaker Pattern (Critical Integrations):**
- Prevents cascading failures from external API outages
- States: CLOSED (normal), OPEN (failing fast), HALF_OPEN (testing recovery)
- GitHub API: Failure threshold 5, timeout 30 seconds
- Claude API: Failure threshold 3, timeout 60 seconds
- Implementation: See `/scripts/circuit_breaker.py` (to be created Day 0)
```

**Bulkhead Pattern (Resource Isolation):**
- Separate GitHub Action workflows for each dashboard (failure in one doesn't affect others)
- Separate API tokens for different services (GitHub, Claude, X) - if one revoked, others continue
- Per-skill timeouts (one hanging skill doesn't block others)

**Graceful Degradation Strategies:**

| Component | Full Service | Degraded Service | User Impact |
|-----------|--------------|------------------|-------------|
| **7F Lens Dashboard** | Real-time data (<6h old) | Cached data (<52 weeks old) | User sees stale data with timestamp |
| **Secret Scanning** | Full repo scan (<5 min) | Shallow scan (recent commits only) | Faster but less comprehensive scan |
| **Second Brain** | Full index loaded | Critical sections only | Slower responses, more API calls |
| **Weekly Summaries** | Claude API summaries | Human-written summaries | Less frequent updates, manual effort |

**User Impact Assessment (Degradation Levels):**

**Level 1 - Minor Degradation (Acceptable):**
- Dashboard data 6-24h old
- Secret scan takes 30s-2min (vs <30s)
- Claude responses delayed 5-10s
- **User Action:** None required, informational notice

**Level 2 - Moderate Degradation (Workaround Needed):**
- Dashboard data 1-7 days old
- Secret scan timeout (use shallow scan)
- Claude API unavailable (manual summaries)
- **User Action:** Accept reduced functionality or manual workaround

**Level 3 - Severe Degradation (Service Disrupted):**
- Dashboard data >7 days old (only archives available)
- Secret scan unavailable (external tool needed)
- Second Brain inaccessible (Git clone needed)
- **User Action:** Wait for recovery or use fallback systems

**Level 4 - Total Failure (Service Down):**
- GitHub unavailable (cannot access any repos)
- No cached data available
- All APIs failing
- **User Action:** Wait for GitHub incident resolution (2-4 hours typical)

---

## Security Architecture (5 Layers)

### Layer 1: Access Control

**Authentication Flows:**

**Developer Authentication (GitHub CLI):**
```
1. User runs: gh auth login
2. GitHub: Generate device code
3. User: Navigate to github.com/login/device, enter code
4. GitHub: Verify user identity (username/password + 2FA)
5. User: Authorize GitHub CLI (select scopes: repo, read:org, workflow)
6. GitHub: Generate OAuth token (stored in ~/.config/gh/hosts.yml)
7. Claude Code: Reads token via gh CLI (no direct token access)
```

**GitHub Actions Authentication (OIDC):**
```
1. Workflow starts: GitHub generates OIDC token (JWT)
2. Token claims: repo, ref, workflow, actor, environment
3. Workflow exchanges OIDC token for API token (no long-lived secrets)
4. API calls: Authenticated with scoped token (expires after workflow)
```

**Least Privilege Enforcement:**

| Role | GitHub Permission | Scope | Rationale |
|------|-------------------|-------|-----------|
| **Founders (Jorge, Buck)** | Admin | Org-wide | Full control, org setup, security config |
| **Core Team (Bel, Lauren, Lissa)** | Write | Team repos only | Development, no org-level changes |
| **Contributors (future)** | Read | Public repos only | View code, submit PRs (no direct push) |
| **GitHub Actions** | Write | Workflow repo only | Commit aggregated data, no cross-repo access |
| **GitHub Private Mirrors App** | Read (internal) + Write (public) | Specific repos only | Selective publishing, no admin access |

**2FA Enforcement:**
- Org setting: Required for all members (GitHub org policy)
- Verification: GitHub enforces at login (TOTP, SMS, hardware key)
- Bypass prevention: No exceptions, no fallback to password-only

### Layer 2: Code Security

**Dependabot Configuration:**
- Package ecosystem: pip (for `/scripts/` directory Python dependencies)
- Schedule: Weekly updates
- Open PR limit: 5 concurrent
- Reviewers: jorge-at-sf, buck-at-sf
- Configuration file: `.github/dependabot.yml` (to be created Day 0)

**Secret Scanning:**
- GitHub native: Enabled on all repos (detects AWS keys, GitHub tokens, etc.)
- Push protection: Blocks commits containing detected secrets
- Custom patterns: Add proprietary API key patterns (Phase 2)

**Branch Protection Rules (main branch):**
- Require pull request reviews: 1 approval (Phase 2), 0 for MVP (direct push)
- Require status checks: GitHub Actions tests pass
- Require branches to be up to date
- Restrict push access: Founders only (MVP), Core Team (Phase 2)

### Layer 3: Workflow Security

**Approved GitHub Actions (Allowlist):**
```yaml
# Org setting: Actions permissions
allowed_actions: selected
allowed_actions_list:
  - actions/checkout@v4         # Official GitHub action
  - actions/setup-python@v5     # Official GitHub action
  - anthropics/claude-api@v1    # Verified publisher
```

**GitHub Secrets Management:**

| Secret Name | Scope | Rotation | Access |
|-------------|-------|----------|--------|
| `GITHUB_TOKEN` | Automatic (per workflow) | Per run (ephemeral) | GitHub Actions only |
| `CLAUDE_API_KEY` | Org-level | 90 days | Dashboard workflows only |
| `REDDIT_CLIENT_SECRET` | Org-level | 180 days | Dashboard workflows only |
| `X_API_KEY` | Org-level | 180 days | Dashboard workflows only |

**Secret Rotation Procedure:**
1. Generate new API key in provider dashboard
2. Test new key in development (workflow_dispatch trigger)
3. Update GitHub Secret (org settings)
4. Verify production workflow uses new key (monitor logs)
5. Revoke old key in provider dashboard (after 24h grace period)
6. Document rotation in security log

**OIDC Configuration (Phase 2):**
- No long-lived secrets for cloud providers
- GitHub generates short-lived tokens per workflow
- Cloud provider trusts GitHub's OIDC issuer

### Layer 4: Data Security

**Encryption:**
- At rest: GitHub encrypts all data (AES-256)
- In transit: HTTPS only (TLS 1.3)
- Secrets: GitHub Secrets encrypted with org-specific keys

**Secrets Management (Application-Level):**
- Use environment variables loaded from GitHub Secrets (NEVER hardcode)
- Validate secret format before use (e.g., Claude keys must start with `sk-ant-`)
- Fail fast if secrets are missing or invalid format
- Implementation: See `/scripts/secrets_validator.py` (to be created Day 0)

**API Key Rotation Schedule:**
- GitHub personal access tokens: 90 days (GitHub Security Best Practices recommendation)
- Claude API keys: 90 days (balances security vs. operational overhead; quarterly rotation reduces compromise window while minimizing disruption)
- External API keys (Reddit, X): 180 days (lower risk, less frequent rotation acceptable)
- Emergency rotation: <24 hours (if compromised)

**Data Classification:**

| Classification | Examples | Storage | Access |
|----------------|----------|---------|--------|
| **Public** | Dashboard data, public Second Brain | Public repos | Anyone (read), Team (write) |
| **Internal** | Architecture docs, sprint notes | Private repos | Team only |
| **Confidential** | API keys, personal data | GitHub Secrets, local env | Founders only |
| **Restricted** | Security incidents, financial data | Encrypted cloud storage (Phase 3) | Jorge + Buck only |

### Layer 5: Monitoring & Audit

**Audit Logging (Phase 3 - Manual for MVP):**

**What to Log:**
- Authentication: Login/logout, 2FA events, failed auth
- Authorization: Permission grants/revokes, team membership changes
- Data access: Repo clones, file reads (sensitive docs only)
- Data modification: Commits, PR merges, settings changes
- API usage: GitHub API calls (rate limit tracking), Claude API calls (cost tracking)
- Security events: Secret scanning alerts, Dependabot alerts, push protection blocks

**Log Retention:**
- GitHub audit log: 90 days (GitHub Free/Team tier default; 180 days requires GitHub Enterprise $21/user/month)
- Exported logs: 1 year (compliance requirement)
- Security incidents: 7 years (legal requirement)

**Structured Logging Format:**
```json
{
  "timestamp": "2026-02-15T10:30:00Z",
  "event_type": "authentication.success",
  "actor": "jorge-at-sf",
  "resource": "Seven-Fortunas-Internal/infrastructure-project",
  "action": "repo.clone",
  "ip_address": "203.0.113.42",
  "user_agent": "git/2.43.0",
  "result": "success"
}
```

**Security Alerts (Automated):**
- Dependabot: Email to founders when critical vulnerability detected
- Secret scanning: Block push + email to author + Slack notification (Phase 2)
- Failed authentication: 5 failures in 10 min → Lock account + notify founders
- Unusual API usage: >80% rate limit → Slack alert → Investigate

**Incident Runbooks (Phase 2):**
- **Compromised API key:** Rotate key (see Layer 3), audit access logs, assess impact
- **Unauthorized access:** Revoke access, reset 2FA, force password reset, investigate
- **Data leak:** Assess exposure, notify affected parties, rotate all secrets, incident report

---

## Monitoring & Observability

### Metrics Collection

**System Metrics (GitHub Actions):**

| Metric | Source | Frequency | Alerting Threshold |
|--------|--------|-----------|-------------------|
| **Aggregation duration** | Workflow logs | Every 6h | >10 min (target: <2 min) |
| **API success rate** | Workflow logs | Every 6h | <95% (target: >99%) |
| **Rate limit remaining** | GitHub API response headers | Per request | <500 req (out of 5,000) |
| **Claude API cost** | API response metadata | Weekly | >$10/month (budget: $5-10/month MVP, $10-15/month Phase 2) |
| **Dashboard page load time** | GitHub Pages analytics | Daily | >5 sec (target: <2 sec) |
| **Secret scan duration** | BMAD skill logs | Per scan | >5 min (target: <2 min) |

**Business Metrics (Dashboard Analytics):**
- User visits per day (Google Analytics or Plausible)
- Skill invocations per week (Claude Code telemetry, opt-in)
- Second Brain searches per day (GitHub repo insights)
- Weekly summary engagement (time spent reading)

**Collection Tools:**
- **MVP:** GitHub Actions logs (manual review), Python logging to stdout
- **Phase 2:** Structured JSON logs, aggregated to `logs/YYYY-MM-DD.json`
- **Phase 3:** Metrics API (Prometheus format), Grafana dashboard

### Alerting Strategy

**Critical Alerts (Page founders immediately):**
- [ ] GitHub API authentication failure (BMAD skills unusable)
- [ ] Dashboard aggregation fails for >24 hours (data severely stale)
- [ ] Security alert: Secret scanning detection (potential leak)
- [ ] Rate limit exhausted for >1 hour (API calls blocked)

**Warning Alerts (Slack notification, review within 4h):**
- [ ] Aggregation duration >5 min (performance degradation)
- [ ] API success rate <98% (reliability concern)
- [ ] Claude API cost >$15/month (budget overrun risk)
- [ ] Rate limit <1,000 requests remaining (approaching limit)

**Info Alerts (Log only, review weekly):**
- [ ] Dependabot security update available
- [ ] New contributor submitted PR
- [ ] Dashboard traffic spike (>2x normal)

**Alerting Channels:**
- **MVP:** Email to jorge@sevenfortunas.com
- **Phase 2:** Slack channel (#7f-alerts)
- **Phase 3:** PagerDuty (critical only)

### Debugging & Troubleshooting

**Structured Logging (Python Scripts):**
- Emit JSON-formatted logs with timestamp, level, event_type, message, and context
- Format: `{"timestamp": "2026-02-16T12:00:00Z", "level": "INFO", "event_type": "aggregation.start", "message": "...", ...}`
- Use for aggregation workflows, API calls, error tracking
- Implementation: See `/scripts/logger.py` (to be created Day 0)

**Debug Mode (Development):**
- Enable with `DEBUG=1` environment variable
- Includes: request/response payloads, retry attempts with backoff times, rate limit headers, execution duration per step
- Use for troubleshooting API failures and performance issues

**Tracing (Phase 3):**
- Trace ID: UUID generated per workflow run, propagated to all API calls
- Parent-child spans: Aggregation → API calls → Processing → Storage
- Tool: OpenTelemetry (Python SDK), export to Jaeger or Honeycomb

**Log Retention:**
- GitHub Actions logs: 90 days (GitHub default)
- Exported structured logs: 1 year (debugging historical issues)
- Error logs: 2 years (compliance, incident analysis)

### Service Level Objectives (SLOs)

**MVP SLOs (Target):**

| Service | Metric | SLO | Measurement |
|---------|--------|-----|-------------|
| **7F Lens Dashboard** | Availability | 99.5% uptime | GitHub Pages uptime (GitHub SLA) |
| **7F Lens Dashboard** | Latency | p95 <5 sec page load | Real User Monitoring (RUM) |
| **7F Lens Dashboard** | Freshness | Data <6h old 99% of time | Aggregation success rate |
| **Secret Scanning** | Success rate | ≥99.5% detection rate | BMAD skill logs + Jorge's adversarial testing |
| **Secret Scanning** | Latency | p95 <5 min scan duration | BMAD skill logs |
| **Second Brain** | Availability | 99.9% uptime | GitHub uptime (infrastructure) |
| **BMAD Skills** | Reliability | 98% skills execute successfully | Claude Code telemetry |

**SLO Monitoring:**
- **MVP:** Manual calculation weekly (review logs)
- **Phase 2:** Automated SLO dashboard (Grafana + Prometheus)
- **Phase 3:** SLO-based alerting (alert when SLO budget 50% consumed)

**SLO Violation Response:**
1. Alert triggered (SLO budget consumed)
2. Founder reviews metrics (identify root cause)
3. Create incident ticket (GitHub issue)
4. Implement fix (code change, config update, infrastructure scaling)
5. Post-mortem (document lessons learned, update runbooks)

---

## Scalability Strategy & Bottleneck Analysis

### Capacity Tiers

| Tier | Users | Repos | Dashboards | Data Points/6h | Dashboard Latency | Search Latency | Scaling Technique |
|------|-------|-------|------------|----------------|-------------------|----------------|-------------------|
| **MVP** | 4 | 10 | 1 | ~100 | <2 min | <1 sec | Serial aggregation |
| **Phase 2** | 10-20 | 30 | 5 | ~500 | <10 min | <2 sec | Parallel aggregation, caching |
| **Phase 3** | 50-100 | 100 | 10 | ~2,000 | <30 min | <1 sec | Distributed workflows, vector DB |
| **Phase 4** | 100-500 | 500 | 50 | ~10,000 | <60 min | <500 ms | Dedicated aggregation service, CDN (major rearchitecture) |

### Bottleneck Identification

**Current Bottlenecks (MVP):**

| Bottleneck | Component | Impact | Threshold | Mitigation |
|------------|-----------|--------|-----------|------------|
| **GitHub API rate limit** | Dashboard aggregation | Cannot fetch data if limit exceeded | 5,000 req/hour | Caching, batch requests, multiple tokens (Phase 2) |
| **Serial aggregation** | Dashboard workflow | Linear scaling (6 sources × 30s = 3 min) | >10 sources = >5 min | Parallel aggregation (Phase 2) |
| **Git repository size** | All components | Slow clones, push rejected if >1GB | 1 GB repo size | Git LFS (Large File Storage for files >50MB), prune old data, split repos |
| **Claude API cost** | Weekly summaries | Cost grows linearly with dashboards | >10 dashboards = >$50/month | Batching, caching, cheaper models (Haiku) |
| **GitHub Actions concurrency** | Multiple workflows | Max 20 concurrent jobs (Free tier) | >20 workflows queued | Upgrade to Team ($4/user/month), sequence workflows |
| **Linear search (Second Brain)** | BMAD skills, Claude queries | O(n) search in markdown files | >1,000 files = >5 sec | Vector DB (Phase 3), full-text search (Algolia) |

**Projected Bottlenecks (Phase 2+):**

| Bottleneck | Phase | Impact | Mitigation |
|------------|-------|--------|------------|
| **Founder bandwidth** | Phase 2 | Cannot review all PRs, approve all workflows | Delegate to Core Team, automate approvals (trusted contributors) |
| **GitHub Pages bandwidth** | Phase 3 | Free tier: 100 GB/month, >10K visitors may exceed | CDN (Cloudflare Free tier: 100K req/day), optimize assets (compress images) |
| **Dashboard aggregation duration** | Phase 3 | Serial: 50 sources × 30s = 25 min (unacceptable) | Distributed: Split into 5 parallel workflows (5 min total) |
| **Claude API rate limit** | Phase 4 | 50 req/min, 100 dashboards × 10 req/week = 1,000 req/week (sustainable) but batch jobs may spike | Queue summaries, spread generation over 24h window (major rearchitecture in Phase 4) |

### Scaling Techniques

**Parallel Aggregation (Phase 2):**
```yaml
# .github/workflows/aggregate-parallel.yml
jobs:
  aggregate-rss:
    runs-on: ubuntu-latest
    # Runs in parallel with other jobs

  aggregate-reddit:
    runs-on: ubuntu-latest

  aggregate-youtube:
    runs-on: ubuntu-latest

  aggregate-x:
    runs-on: ubuntu-latest

  combine-results:
    needs: [aggregate-rss, aggregate-reddit, aggregate-youtube, aggregate-x]
    # Waits for all parallel jobs to complete
```

**Caching Strategy (Phase 2):**
- Cache external API responses for 1 hour (avoid redundant calls)
- Cache processed data (skip re-processing unchanged sources)
- Cache GitHub API responses (repo metadata, team lists)

**Vector Search (Phase 3):**
- Embedding model: sentence-transformers/all-MiniLM-L6-v2 (384-dim embeddings)
- Vector DB: Pinecone, Weaviate, or Chroma (decision Phase 3)
- Index: HNSW (Hierarchical Navigable Small World) for O(log n) average search (O(n) worst case)
- Metadata: Store file_path and section for result linking
- Query performance: <100ms for 10K documents (top_k=5 results)
- Use case: Semantic search across Second Brain content
- Implementation: See `/scripts/vector_search.py` (to be created Phase 3)

**Distributed Workflows (Phase 3):**
- Split dashboard aggregation into 10 parallel workflows (one per dashboard)
- Use workflow_dispatch to trigger manually (not all on cron)
- Stagger cron schedules (Dashboard 1: 00:00, Dashboard 2: 00:30, etc.)

**Rate Limit Mitigation:**
- Use multiple GitHub personal access tokens (rotate per request)
- Implement token pool with least-recently-used selection
- Monitor X-RateLimit-Remaining header, switch tokens proactively

### Performance Optimization Roadmap

**Phase 1 (MVP) - Acceptable Performance:**
- ✅ Serial aggregation (simple, predictable)
- ✅ No caching (fresh data every run)
- ✅ Linear search in Second Brain (<100 files)

**Phase 2 (Growth) - Optimized Performance:**
- [ ] Parallel aggregation (3 min → <1 min for 6 sources)
- [ ] HTTP caching (1 hour TTL, reduce API calls by 50%)
- [ ] GitHub API token rotation (avoid rate limits)
- [ ] Second Brain index (pre-generated ToC, faster navigation)

**Phase 3 (Scale) - High Performance:**
- [ ] Distributed workflows (10 dashboards in parallel, <5 min total)
- [ ] Vector search (O(log n), <100ms for 1,000 files)
- [ ] CDN for dashboard (Cloudflare, reduce latency from 2s → 200ms)
- [ ] Incremental aggregation (only fetch new data since last run)

**Phase 4 (Enterprise) - Maximum Performance (Major Rearchitecture):**
- [ ] Dedicated aggregation service (not GitHub Actions, custom infrastructure - significant architectural change)
- [ ] Real-time updates (WebSockets, Server-Sent Events instead of 6h polling)
- [ ] Multi-region deployment (CDN + edge functions, <100ms global latency)
- [ ] Database (PostgreSQL or DynamoDB, retire Git-as-database for hot data)

---

## Disaster Recovery

**Backup:** Git version control (GitHub redundancy), weekly cloud export (Phase 2)
**RTO:** <4 hours for critical systems (restore time)
**RPO:** <24 hours (data loss window - aligns with Matrix backup RPO and daily aggregation cycles)
**Recovery:** GitHub trash (30-day), local clones, cloud backups
