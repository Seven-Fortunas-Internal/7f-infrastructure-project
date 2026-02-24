# Extract: Architecture Document

**Source:** `architecture-7F_github-2026-02-10.md`
**Date:** 2026-02-10
**Size:** 2327 lines (110KB)
**Author:** Mary (Business Analyst) with Jorge

---

## Document Metadata
- **Purpose:** Complete technical architecture for Seven Fortunas AI-native infrastructure
- **Format:** C4 Model (Context, Container, Component levels), ADRs, technology stack
- **Status:** Draft - Ready for Technical Review
- **Next Artifact:** PRD

---

## Key Content Summary

### System Context (Lines 1-150)
**Core Thesis:** AI-native enterprise nervous system designed FROM INCEPTION for AI collaboration

**3 Interconnected Systems:**
1. **BMAD Skills Platform** - Conversational infrastructure management
2. **Second Brain** - Progressive disclosure knowledge base
3. **7F Lens Intelligence Platform** - Multi-dimensional dashboards

**Founding Team:**
- Henry (CEO) - Strategic direction, branding
- Patrick (CTO) - Technical excellence, validation
- Buck (VP Engineering) - Engineering delivery, application security
- Jorge (VP AI-SecOps) - AI infrastructure, security operations

---

### BMAD Library Integration (Lines 152-310)
**Why BMAD:**
- 70+ existing skills → 60% coverage of identified needs
- 87% cost reduction (48h vs 356h)
- 4.5x faster time to market
- Proven patterns vs building from scratch

**Integration Pattern:**
```
_bmad/ (Git submodule - BMAD v6.0.0 pinned)
├── bmm/ (Business Method - planning, discovery, creation)
├── bmb/ (Builder - coding, infrastructure, workflow orchestration)
├── cis/ (Creative Intelligence - content generation, AI-powered creation)
└── core/ (Shared utilities, prompt engineering patterns)
```

**26 Skills Total:**
- 18 BMAD skills (adopted as-is)
- 5 adapted skills (brand-voice, pptx, excalidraw, sop, skill-creator)
- 3 custom skills (manage-profile, dashboard-curator, repo-template)

---

### Skill-Creation Skill (Meta-Skill) (Lines 311-508)
**Innovation:** Skill that creates other skills from YAML requirements

**Architecture:**
```
requirements.yaml → skill-creation-skill → .skill package (ZIP)
├── SKILL.md (workflow with YAML frontmatter)
├── references/ (examples, best practices)
├── tests/ (validation scenarios)
└── README.md (usage instructions)
```

**Bootstrapping Approach:**
1. Manual v1.0 creation (Jorge, Day 0)
2. Self-improvement v1.1 (use v1.0 to generate v1.1)
3. Iteration (each version improves next)

**Example Requirements (Lines 372-408):**
- Brand system generator
- GitHub org configurator
- Company definition wizard
- Dashboard configurator
- Onboard team member

---

### Enabling Skills Architecture (Lines 511-1056)

#### 1. Brand System Generator (Lines 525-681)
**Purpose:** CEO defines branding, auto-apply to all GitHub assets

**User Journey:**
1. Interactive questionnaire (colors, fonts, logo, voice)
2. AI generates brand documentation (brand.json, brand-system.md)
3. Preview changes (GitHub org, website)
4. Apply branding (with confirmation)
5. Verification checklist

**Key Files Modified:**
- `second-brain-core/brand/`
- `.github/profile/README.md` (both orgs)
- `seven-fortunas.github.io/assets/css/style.css`

#### 2. GitHub Org Configurator (Lines 682-762)
**Purpose:** Configure orgs, teams, permissions through wizard

**Menu Options:**
- Create new team
- Modify team permissions
- Configure org security settings
- Set up repository defaults
- Configure GitHub Actions permissions

**GitHub API Integration:**
- Uses `gh` CLI (requires `admin:org` scope)
- Authentication via Personal Access Token
- **CRITICAL:** Must use jorge-at-sf account

#### 3. Company Definition Wizard (Lines 764-841)
**Purpose:** CEO defines mission/vision/values, AI generates culture docs

**Guided Interview:**
- Problem to solve (mission)
- Future state (vision)
- Core values (3-5 principles)
- Target customers
- Decision framework

**Claude API Integration:**
- Prompt engineering for culture doc generation
- Uses brand voice from brand.json
- Human refinement loop (20% editing)

#### 4. Dashboard Configurator (Lines 842-942)
**Purpose:** Add/remove data sources for 7F Lens dashboards

**Configuration Options:**
- Add/remove RSS feeds
- Add/remove Reddit subreddits
- Add/remove YouTube channels
- Configure update frequency

**Dashboard Config Schema (sources.yaml):**
```yaml
dashboard:
  name: "AI Advancements Tracker"
  update_frequency: "6h"
sources:
  rss_feeds: [...]
  reddit: [...]
  youtube_channels: [...]
  github_releases: [...]
```

#### 5. Onboard Team Member (Lines 944-1056)
**Purpose:** Automate onboarding for new team members

**Workflow:**
1. Collect member info (name, email, GitHub, role)
2. Generate personalized onboarding checklist
3. Execute invitations (gh API calls)
4. Track progress (monitor issue completion)

**Onboarding Issue Template:**
- Week 1: GitHub/tools, company context, role-specific, people
- Week 2: First contributions

---

### GitHub Organization Architecture (Lines 1059-1195)

#### Two-Org Model
**Seven-Fortunas (PUBLIC):**
- Purpose: Public-facing repos, open-source, showcases
- Teams: Public BD, Public Marketing, Public Engineering
- Key repos: .github, seven-fortunas.github.io, dashboards, second-brain-public

**Seven-Fortunas-Internal (PRIVATE):**
- Purpose: Internal development, proprietary work
- Teams: BD, Marketing, Engineering, Finance, Operations
- Key repos: internal-docs, second-brain-core, dashboards-internal, 7f-infrastructure-project

**Team Structure Design Principle:**
- Teams represent FUNCTIONS, not products
- Products are REPOSITORIES within teams
- Scales better (10 teams, not 50 orgs)

**Repository Naming:** `{product}-{component}[-{detail}]`

**Security Policies:**
- Organization-level 2FA requirement (enforced)
- Dependabot + secret scanning + push protection
- Branch protection (require reviews)
- Default repo permission: "none" (explicit grants only)

---

### Second Brain Architecture (Lines 1196-1402)

#### Progressive Disclosure Model
**Principle:** Load information just-in-time, not all-at-once

**Directory Structure:**
```
second-brain-core/
├── index.md                    # Hub - AI agents load FIRST
├── brand/                      # Brand identity
├── culture/                    # Mission, vision, values
├── domain-expertise/           # Business domain knowledge
│   ├── tokenization/
│   ├── education-peru/
│   ├── compliance/
│   └── airgap-security/
├── best-practices/             # Engineering & operations
│   ├── engineering/
│   └── operations/
└── skills/                     # BMAD skills (custom)
```

**Index.md Design:**
- Entry point for AI agents and humans
- Describes content categories
- "When to load" guidance for each section
- Quick links for navigation

**MCP Server Integration (Future - Phase 2):**
- Allow Claude Desktop to query Second Brain via MCP protocol
- Endpoints: /search, /read, /list, /skill
- Vector embeddings for semantic search

---

### 7F Lens Dashboard Architecture (Lines 1405-1683)

#### Data Pipeline
```
DATA SOURCES (RSS, GitHub, Reddit, YouTube, X)
    ↓ Fetch every 6 hours
RAW DATA STORAGE (ephemeral, debugging only)
    ↓ Deduplicate, filter, normalize
PROCESSED DATA (latest.json, overwritten every 6h)
    ↓ Archive weekly
HISTORICAL DATA (archive/{YYYY-MM-DD}.json)
    ↓ Summarize with Claude
AI SUMMARIES ({YYYY-MM-DD}.md)
    ↓ Display
DASHBOARD UI (README.md auto-generated)
```

**Dashboard Directory Structure:**
```
dashboards/ai/
├── README.md                   # Main dashboard (auto-generated)
├── config/sources.yaml         # Data sources
├── data/
│   ├── latest.json
│   └── archive/
├── summaries/                  # AI-generated weekly
└── scripts/
    ├── fetch_sources.py
    └── generate_summary.py
```

**Data Schema (latest.json):**
- Metadata (generated_at, source_count, item_count)
- Items array (id, title, source, url, published_at, summary, keywords, relevance_score)
- Trending topics

**GitHub Search Skill (Lines 1555-1682):**
- Natural language query → Claude extracts intent
- Multi-source search (GitHub API, Second Brain grep)
- Rank by relevance, recency, authority
- Present top 10 results

---

### Security Architecture (Lines 1686-1759)

#### Security Layers
1. **Access Control:** 2FA, team permissions, least privilege, GitHub App
2. **Code Security:** Dependabot, secret scanning, push protection, branch protection
3. **Workflow Security:** Approved actions only, GitHub Secrets, OIDC
4. **Data Security:** Private repos, encryption at rest/transit, API key rotation
5. **Monitoring & Response:** Audit logs (Phase 3), security alerts, incident runbooks

**Threat Model:**
- Leaked API keys → Secret scanning (Low risk)
- Dependency vulnerabilities → Dependabot (Low risk)
- Unauthorized access → 2FA + audit logs (Low risk)
- Malicious code in PR → Required reviews (Medium risk)
- Insider threat → Audit logging (Medium risk)

**Data Classification:**
- **Public:** Open-source code, blog posts → Public GitHub repos
- **Internal:** Company docs, processes → Private GitHub repos
- **Confidential:** Customer data, financials → Private repos + encrypted
- **Restricted:** Legal, M&A, HR → NOT in GitHub (external encrypted storage)

---

### Deployment Architecture (Lines 1763-1837)

#### Phase 1 (MVP): GitHub Free Tier
**Services:**
- GitHub.com (public + private orgs)
- GitHub Actions (2,000 min/month private, unlimited public)
- GitHub Pages (free for seven-fortunas.github.io)
- Anthropic API (~$0.05-5/month)
- X API ($100/month, optional)

**Cost:** $0-5/month (excluding optional X API)

**Constraints:**
- 2,000 Actions minutes/month (private repos)
- No advanced security (CodeQL on private repos)
- No required reviewers enforcement
- No audit logs

**Mitigation:** Use public repos for dashboards, document policies, manual reviews

#### Phase 2: Expansions
- More dashboards (fintech, edutech, security)
- Obsidian vault for Second Brain
- GitHub Private Mirrors App

**Cost:** $5-15/month

#### Phase 3: GitHub Enterprise
- Advanced Security (CodeQL, custom secret patterns)
- Audit Log API
- SAML SSO
- Required reviewers (enforced)
- 50,000 Actions minutes/month
- SOC1/SOC2 reports

**Cost:** $21/user/month (50 users = $1,050/month)

**Trigger:** Series A funding, SOC 2 requirement, team >20

---

### Data Architecture (Lines 1840-1907)

#### Data Flow
- Data sources → Raw data (7 days retention)
- → Processed data (overwritten every 6h)
- → Historical archives (52 weeks retention)
- → AI summaries (indefinite retention)
- → Dashboard UI

**Data Retention:**
- Raw data: 7 days (debugging only)
- Processed latest: Overwritten every 6h
- Historical archives: 1 year
- AI summaries: Indefinite
- Second Brain: Indefinite (version controlled)

**Backup Strategy:**
- **MVP:** Git version control (GitHub provides redundancy)
- **Phase 2:** Weekly export to S3/GCS (~$1-5/month)

**Recovery Scenarios:**
- Accidental deletion: <5 min (restore from GitHub trash)
- Bad commit: <2 min (git revert)
- GitHub outage: Work locally
- Lost API key: <10 min (rotate key)
- Malicious deletion: <1 day (recreate from clones)

**RTO:** <4 hours for critical systems
**RPO:** <6 hours (last data aggregation)

---

### Architectural Decision Records (Lines 1910-2025)

#### ADR-001: Two-Org Model vs. Multiple Orgs
**Decision:** Two organizations (public/private)
**Rationale:** Clear security boundary, scales better, easier permissions

#### ADR-002: Progressive Disclosure for Second Brain
**Decision:** Load index.md first, specific sections as needed
**Rationale:** Reduces tokens, faster, scalable, Obsidian-compatible

#### ADR-003: GitHub Actions for Dashboard Aggregation
**Decision:** Scheduled workflows (not external service)
**Rationale:** Free on public repos, co-located with code, built-in secrets

#### ADR-004: Skill-Creation Skill (Meta-Skill)
**Decision:** Auto-generate skills from requirements
**Rationale:** DRY, consistent structure, faster iteration, self-improving

#### ADR-005: Personal API Keys (MVP) → Corporate Keys (Post-Funding)
**Decision:** Personal keys for MVP, migrate post-funding
**Rationale:** Unblocks MVP, lower cost, clear migration path

---

### Technology Stack (Lines 2028-2108)

**Core Technologies:**
- Hosting & Storage: GitHub
- Website: GitHub Pages
- Automation: GitHub Actions
- AI Processing: Claude API
- Second Brain: Markdown + Git
- Visualization: Obsidian (Phase 2)
- Search: GitHub Search API + local grep

**Languages:**
- Aggregation Scripts: Python 3.11+
- BMAD Skills: Markdown + YAML + Python
- Website: HTML + CSS (minimal JS)
- Dashboards: Auto-generated Markdown

**Dependencies (Python):**
```
feedparser==6.0.10
praw==7.7.0
anthropic==0.39.0
requests==2.31.0
pyyaml==6.0.1
python-dotenv==1.0.0
```

**GitHub Actions Workflow Example (Lines 2064-2108):**
- Update AI Dashboard workflow
- Cron: Every 6 hours
- Steps: Checkout → Setup Python → Install deps → Fetch/aggregate → Commit

---

### Integration Points (Lines 2111-2180)

**GitHub API:**
- Authentication: PAT or GitHub App
- Required scopes: repo, admin:org, workflow
- Example calls: Create team, list members, search code

**Claude API:**
- Authentication: API key (GitHub Secrets)
- Model: claude-sonnet-4-5-20250929
- Rate limits: 50 req/min, 40K req/day
- MVP usage: ~10 req/week
- Cost: ~$0.05-5/month

**External Data Sources:**
- RSS Feeds: HTTP GET, no auth, unlimited
- Reddit JSON: HTTP GET, no auth, ~60 req/min
- YouTube RSS: HTTP GET, no auth, unlimited
- GitHub API: REST, PAT, 5K req/hour
- X API: REST, Bearer token, 500 req/month (Free) or 10K (Basic $100/mo)

---

### Scalability & Performance (Lines 2183-2238)

**Current Scale (MVP):**
- 4 founders, 2 orgs, ~10 repos, 1 dashboard, ~100 data points/6h
- Performance: <2 min dashboard, <1 sec search, <5 min workflows

**Phase 2 Scale:**
- 10-20 members, ~30 repos, 5 dashboards, ~500 data points/6h
- Performance: <10 min dashboard, <2 sec search, <15 min workflows

**Phase 3 Scale:**
- 50-100 members, ~100 repos, 10 dashboards, ~2K data points/6h
- Performance: <30 min dashboard, <1 sec search (vector DB), <20 min workflows

**Scaling Strategies:**
- Parallel aggregation (concurrent fetches)
- Caching (unchanged data sources)
- Vector search (replace grep)
- Distributed workflows

**Bottlenecks & Mitigation:**
- GitHub Actions minutes → Use public repos
- Claude API cost → Cache summaries, batch requests
- Data source rate limits → Upgrade or cache
- Git repo size → Archive old data, use Git LFS
- Search performance → Vector embeddings

---

### Open Questions (Lines 2279-2297)

**For Leadership:**
1. Confirm Henry's X API credentials approval for MVP
2. Confirm Henry has bandwidth Days 1-3 for branding
3. When is Series A expected?

**For Technical Team:**
4. GitHub Private Mirrors App: Deploy own or use hosted?
5. Second Brain MCP Server: Phase 2 or Phase 3?
6. Vector Search: When to add? (Phase 2 or 3?)

**For Product Team:**
7. Dashboard priorities Phase 2: Fintech, EduTech, or Security first?
8. Public content strategy: What % of Second Brain public? (10%? 30%?)
9. Obsidian vs. alternatives: Evaluate Notion, Confluence?

---

## Critical Information

**Document Status:** Draft - Ready for Technical Review (estimated 60-90 min review)

**Next Artifact:** Product Requirements Document (PRD)

**Key Decisions:**
- Two-org model (public/private)
- Progressive disclosure (Second Brain)
- GitHub Actions (dashboard aggregation)
- Skill-creation skill (meta-skill)
- Personal API keys MVP → Corporate post-funding

**Security-First:**
- 5-layer security architecture
- Threat model with mitigations
- Data classification system
- **CRITICAL:** jorge-at-sf GitHub account required

**BMAD-First:**
- 70+ skills → 60% coverage
- 87% cost reduction
- 4.5x faster time to market
- 26 operational skills (18 BMAD + 5 adapted + 3 custom)

**Technology Choices:**
- GitHub (hosting, version control, automation)
- Claude API (AI processing)
- Python 3.11+ (aggregation scripts)
- Markdown + YAML (BMAD skills)

---

## Ambiguities / Questions

**GitHub Account:**
- Architecture mentions jorge-at-sf requirement throughout
- Consistent with Functional Requirements FR-7.1.4
- ✅ No conflict

**Skill Count:**
- Architecture says 26 operational skills (18 BMAD + 5 adapted + 3 custom)
- Consistent with Product Brief and BMAD Skill Mapping
- ✅ No conflict

**Feature Count:**
- Architecture doesn't specify 28 features (not its scope)
- ✅ No conflict

**Buck vs Jorge Roles:**
- Architecture mentions founding team (Lines 141-148)
- Buck: "Engineering projects, apps, backend, security testing"
- Jorge: "AI infrastructure, security operations"
- **Potential issue:** Doesn't clearly delineate application security vs SecOps
- **Note:** This was written Feb 10, BEFORE UX spec (Feb 14) expanded Buck's role

---

## Related Documents
- Created Feb 10 (same day as Product Brief, BMAD Skill Mapping)
- Referenced by: PRD Main, UX Design Specification
- References: Product Brief, BMAD Skill Mapping
- Provides technical depth for Product Brief's high-level vision
- Complements Functional/Non-Functional Requirements with system design
