## Domain-Specific Requirements

### Domain Classification

**From Step 2 Discovery:**
- **Domain:** DevOps/Infrastructure
- **Complexity:** Medium-High
- **Project Context:** Greenfield (no legacy constraints)

### 1. Compliance & Regulatory

**GitHub Security & Compliance:**
- **Branch Protection Rules** - Required for all production repos (no force-push to main)
- **2FA Enforcement** - Mandatory for all organization members
- **Secret Scanning** - GitHub Advanced Security (detect API keys, tokens, credentials)
- **Dependabot Alerts** - Automated vulnerability scanning and dependency updates
- **Audit Logging** - Track all org changes, access, and configuration modifications
- **SOC2 Type 2 Readiness** (Post-MVP, Month 6-12) - GitHub Enterprise tier for SOC1/SOC2 reporting

**Security Standards:**
- **OWASP Top 10** - CodeQL scanning for common vulnerabilities (XSS, SQL injection, etc.)
- **Pre-commit Hooks** - detect-secrets, code quality checks
- **Security-First Development** - All security features enabled by default, not opt-in

**Data Privacy:**
- **No PII in public repos** - Placeholder data only, real user data in private repos
- **API Key Management** - GitHub Actions secrets, never committed to repos
- **GDPR Compliance** (Future) - User profile data handling, right to deletion

---

### 2. Technical Constraints

**AI-Native Infrastructure:**
- **Progressive Disclosure Architecture** - Load context only when needed, keep agent context efficient
- **YAML-Based Configuration** - User profiles, brand systems, dashboard configs all in YAML (AI-parseable)
- **Markdown-First Documentation** - All documentation in markdown (AI-accessible, version-controlled)
- **Structured Knowledge** - Second Brain designed for both human understanding and AI ingestion

**Security Constraints:**
- **Zero Secrets Committed** - 100% detection rate via pre-commit hooks + GitHub scanning
- **Air-Gapped Secret Management** - Sensitive operations use hardware tokens (future: YubiKey support)
- **Principle of Least Privilege** - Team-based access control, role-based permissions
- **Immutable Audit Trail** - All commits, PRs, config changes tracked in Git history

**Performance & Reliability:**
- **Dashboard Auto-Update** - Every 6 hours via GitHub Actions cron
- **Bounded Retry Logic** - Autonomous agent: max 3 attempts per feature before marking blocked
- **Graceful Degradation** - If external API unavailable (X, Reddit), dashboard continues with other sources
- **Testing Built-In** - No feature marked "pass" without passing tests

**Scalability Constraints:**
- **GitHub Free Tier** (MVP) - 3,000 Actions minutes/month, public repos unlimited
- **GitHub Team Tier** (Post-Funding, Month 3-6) - $4/user/month, 3,000 Actions minutes/month
- **GitHub Enterprise** (Post-Funding, Month 6-12) - $21/user/month, SOC2 reporting, SAML SSO
- **Infrastructure-as-Code** - All configuration in Git (can rebuild from scratch)

---

### 3. Integration Requirements

**GitHub Ecosystem:**
- **GitHub CLI (`gh`)** - Programmatic org/repo management, automation
- **GitHub Actions** - CI/CD, dashboard updates, security scanning
- **GitHub REST API** - Dashboard data collection (repo stats, releases, issues)
- **GitHub GraphQL API** (Future) - More efficient queries for 7F Lens dashboards

**BMAD Library Integration:**
- **Submodule Pattern** - `git submodule add https://github.com/bmad-method/bmad-method.git _bmad`
- **Pinned Version** - `v6.0.0` (no surprise breaking changes)
- **Symlink Skills** - `.claude/commands/bmad-*.md` → `_bmad/bmm/workflows/*/workflow.md`
- **18 BMAD Skills** - bmm-create-prd, bmm-code-review, bmm-create-story, cis-storytelling, etc.

**Claude Code SDK:**
- **Autonomous Agent Pattern** - Two-agent (initializer + coding), bounded retries
- **Feature Tracking** - `feature_list.json` (pending/pass/fail/blocked)
- **Progress Logging** - `claude-progress.txt` (session logs)
- **Prompt Templates** - `prompts/initializer_prompt.md`, `prompts/coding_prompt.md`

**Voice Input System:**
- **OpenAI Whisper API** - Cross-platform speech-to-text
- **Local Installation** - Linux/macOS/Windows (WSL) support
- **Web Fallback** - Windows (non-WSL) and mobile via browser
- **Integration Points** - BMAD skills, brand system generator, content creation

**Dashboard Data Sources:**
- **RSS Feeds** - OpenAI Blog, Anthropic Blog, Google AI, Meta AI, arXiv
- **GitHub API** - LangChain releases, LlamaIndex releases, framework updates
- **Reddit API** - r/MachineLearning, r/LocalLLaMA sentiment
- **X API** (Optional, post-funding) - AI influencer tracking, community sentiment
- **Claude API** - Weekly AI summary generation

---

### 4. Existing Skills to Leverage

**Critical Discovery:** Existing skills in `/home/ladmin/dev/claude-code-second-brain-skills/` directly map to Seven Fortunas requirements. These skills can be **adapted** instead of built from scratch.

#### **Skills to Adapt for Seven Fortunas MVP (5 skills, 10 hours)**

| Existing Skill | Seven Fortunas Adaptation | Effort | Priority | Maps to Journey |
|----------------|---------------------------|--------|----------|-----------------|
| **brand-voice-generator** | → `7f-brand-system-generator` | 2 hours | ⭐⭐⭐⭐⭐ Critical | Henry (CEO) - Brand ethos |
| **pptx-generator** | → `7f-presentation-generator` | 1 hour | ⭐⭐⭐⭐⭐ Critical | Henry (CEO) - Investor pitch |
| **excalidraw-diagram** | → `7f-diagram-generator` | 2 hours | ⭐⭐⭐⭐ High | Patrick (CTO) - Architecture docs |
| **sop-creator** | → `7f-documentation-generator` | 1 hour | ⭐⭐⭐⭐ High | Patrick/Buck - Procedures |
| **skill-creator** | Use as-is (meta-skill) | 0 hours | ⭐⭐⭐⭐⭐ Critical | Jorge - Create custom skills |

**Adaptation Details:**

**1. `brand-voice-generator` → `7f-brand-system-generator`**
- **Current Capability:** Creates `brand.json`, `config.json`, `brand-system.md`, `tone-of-voice.md`
- **Adaptation Needed:**
  - Customize prompts for Seven Fortunas domain (digital inclusion, marginalized communities)
  - Add Seven Fortunas color palette (primary, secondary, accent)
  - Reference Seven Fortunas mission/values in tone-of-voice template
  - Output to `seven-fortunas-brain/brand-system/`
- **Maps to Journey:** Henry (CEO) - Shaping company ethos with AI collaboration
- **MVP Impact:** Enables Henry's "aha moment" - brand generation in hours, not weeks

**2. `pptx-generator` → `7f-presentation-generator`**
- **Current Capability:** 16 slide layouts, carousel mode, brand integration, python-pptx
- **Adaptation Needed:**
  - Minimal (works after brand system created)
  - Optional: Add Seven Fortunas-specific slide templates (pitch deck, investor update)
  - Load brand system from `seven-fortunas-brain/brand-system/`
- **Maps to Journey:** Henry (CEO) - Investor presentation preparation
- **MVP Impact:** Professional investor materials in 2 hours instead of 2 days

**3. `excalidraw-diagram` → `7f-diagram-generator`** *(Elevated to MVP)*
- **Current Capability:** Visual diagrams with semantic colors, pattern library (fan-out, convergence, tree, spiral, cloud)
- **Adaptation Needed:**
  - Customize color palette for Seven Fortunas brand (replace default blue scheme)
  - Add domain-specific patterns (workflow diagrams, architecture diagrams, org charts)
  - Output to Second Brain `architecture/` directory
- **Maps to Journey:** Patrick (CTO) - Architecture documentation with visual clarity
- **MVP Impact:** Architecture diagrams for ADRs, onboarding docs, leadership demos
- **Jorge's Rationale:** "Very good to create documentation diagrams - consider making part of MVP PRD"

**4. `sop-creator` → `7f-documentation-generator`**
- **Current Capability:** Runbooks, playbooks, technical docs with "Definition of Done" structure
- **Adaptation Needed:**
  - Minor branding (Seven Fortunas header/footer)
  - Output to Second Brain `best-practices/` directory
  - Optional: Add templates for onboarding docs, architecture docs
- **Maps to Journey:** Patrick (CTO) - Architecture documentation, Buck (VP Eng) - Security procedures
- **MVP Impact:** Comprehensive documentation for onboarding, operations, security

**5. `skill-creator` (Use as-is)**
- **Current Capability:** Meta-skill for creating new skills with YAML frontmatter, progressive disclosure
- **Adaptation Needed:** None (use directly)
- **Maps to Journey:** Jorge (VP AI-SecOps) - Creating custom Seven Fortunas skills
- **MVP Impact:** Guide for creating remaining net-new skills efficiently

#### **Skills to Use As-Is (Optional, Post-MVP)**

| Skill | Relevance | When to Deploy |
|-------|-----------|----------------|
| **linkedin-post** | Thought leadership content | Month 1-3 (Growth phase) |
| **x-post** | X/Twitter content generation | Month 1-3 (Growth phase) |

#### **Skills to Create from Scratch (3 skills, 12 hours)**

| New Skill | Purpose | Effort | Priority |
|-----------|---------|--------|----------|
| **7f-manage-profile** | User profile YAML management (create, update, query) | 4 hours | ⭐⭐⭐⭐ High |
| **7f-dashboard-curator** | 7F Lens dashboard configuration (data sources, layouts) | 4 hours | ⭐⭐⭐⭐ High |
| **7f-repo-template-generator** | GitHub repo scaffolding (CLAUDE.md, README, security config) | 4 hours | ⭐⭐⭐ Medium |

**Revised Skill Implementation Strategy:**
- **Before:** 7 skills from scratch = 32 hours (4 hours/skill × 7 skills + 4 hours meta-skill)
- **After (with excalidraw-diagram in MVP):** 5 adapted + 3 new = 22 hours
- **Savings:** 10 hours (31% reduction)

**MVP Skill Count:**
- **18 BMAD skills** (submodule, no custom work)
- **5 adapted skills** (brand, pptx, excalidraw, sop, skill-creator)
- **3 new skills** (profile, dashboard, repo-template)
- **Total: 26 operational skills** (up from original 25)

---

### 5. Risk Mitigations

**Autonomous Agent Risks:**

| Risk | Mitigation |
|------|-----------|
| **Agent gets stuck in infinite loop** | Bounded retry logic (max 3 attempts), timeout after 30 minutes |
| **Agent hallucinates broken code** | Testing built into cycle (no "pass" without tests passing) |
| **Agent commits secrets** | Pre-commit hooks block, GitHub Actions double-check |
| **Agent makes destructive changes** | Git history preserves all changes, can rollback |
| **Agent exceeds API limits** | Claude API budget cap ($50/month), monitoring alerts |

**Security Risks:**

| Risk | Mitigation |
|------|-----------|
| **Secrets committed to Git** | detect-secrets pre-commit hook, GitHub secret scanning, education |
| **Vulnerable dependencies** | Dependabot automated updates, security alerts, patch process |
| **Unauthorized access** | 2FA required, team-based permissions, audit logs |
| **Data breach (future)** | Encryption at rest, encryption in transit, SOC2 compliance |
| **Supply chain attack** | BMAD pinned to specific version, verify Git submodule integrity |

**Scalability Risks:**

| Risk | Mitigation |
|------|-----------|
| **GitHub Actions minutes exhausted** | Monitor usage, optimize workflows, upgrade tier if needed |
| **Dashboard data sources rate-limited** | Respectful polling (every 6 hours), caching, graceful degradation |
| **Knowledge base becomes unmanageable** | Progressive disclosure architecture, clear taxonomy, search functionality |
| **Too many repos to manage** | Consistent naming, repo templates, automation scripts |

**Team Risks:**

| Risk | Mitigation |
|------|-----------|
| **Jorge becomes bottleneck** | Self-service skills, BMAD library, comprehensive documentation |
| **New team members overwhelmed** | Structured onboarding, Second Brain, mentor assignment |
| **Knowledge silos** | Everything documented in Second Brain, no tribal knowledge |
| **Bus factor (key person dependency)** | Multiple founders with Owner access, documented procedures |

---

### Domain Requirements Summary

This is a **Medium-High complexity** DevOps/Infrastructure project with:

1. **Security-First Mandate** - Non-negotiable security controls (Buck's aha moment depends on this)
2. **AI-Native Architecture** - Progressive disclosure, YAML configs, markdown-first docs
3. **Autonomous Development** - 60-70% built by Claude Code SDK agent with bounded retries
4. **Existing Skills Leverage** - 5 skills adapted from claude-code-second-brain-skills (31% time savings)
5. **Visual Documentation** - Excalidraw diagrams for architecture, workflows, onboarding (Jorge's insight)
6. **Greenfield Advantage** - No legacy constraints, can design for AI from inception
7. **Scalability Built-In** - Infrastructure supports 4 → 10 → 50+ without redesign

**Critical Path Dependencies:**
1. Brand system generation (Henry) → PPTX generator (investor pitch)
2. BMAD library deployment → Skill adaptation → Custom skill creation
3. Security controls (Buck) → Team confidence → Autonomous agent launch
4. Second Brain structure → Progressive disclosure → AI agent effectiveness
5. **Excalidraw diagrams (Patrick) → Architecture clarity → Team alignment**

---

