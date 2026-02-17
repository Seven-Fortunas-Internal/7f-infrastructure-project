# Extract: Domain Requirements

**Source:** `prd/domain-requirements.md`
**Date:** Not specified (part of PRD created Feb 13)
**Size:** 246 lines
**Author:** Part of PRD by Mary with Jorge

---

## Document Metadata
- **Domain:** DevOps/Infrastructure
- **Complexity:** Medium-High
- **Project Context:** Greenfield (no legacy constraints)
- **Purpose:** Technical constraints, integration requirements, risk mitigations

---

## Key Content Sections

### 1. Compliance & Regulatory (Lines 10-30)
**GitHub Security & Compliance:**
- Branch Protection Rules (no force-push to main)
- 2FA Enforcement (mandatory for all members)
- Secret Scanning (GitHub Advanced Security)
- Dependabot Alerts (automated vulnerability scanning)
- Audit Logging (track all org changes)
- SOC2 Type 2 Readiness (Post-MVP, Month 6-12, GitHub Enterprise tier)

**Security Standards:**
- OWASP Top 10 (CodeQL scanning)
- Pre-commit Hooks (detect-secrets, code quality)
- Security-First Development (enabled by default, not opt-in)

**Data Privacy:**
- No PII in public repos
- API Key Management (GitHub Actions secrets only)
- GDPR Compliance (Future)

---

### 2. Technical Constraints (Lines 33-58)
**AI-Native Infrastructure:**
- Progressive Disclosure Architecture (efficient agent context)
- YAML-Based Configuration (user profiles, brand, dashboards)
- Markdown-First Documentation (AI-accessible, version-controlled)
- Structured Knowledge (Second Brain for humans + AI)

**Security Constraints:**
- Zero Secrets Committed (100% detection)
- Air-Gapped Secret Management (hardware tokens, future YubiKey)
- Principle of Least Privilege (team-based access, RBAC)
- Immutable Audit Trail (Git history)

**Performance & Reliability:**
- Dashboard Auto-Update (every 6 hours, GitHub Actions cron)
- Bounded Retry Logic (autonomous agent: max 3 attempts)
- Graceful Degradation (if external API unavailable)
- Testing Built-In (no "pass" without tests)

**Scalability Constraints:**
- GitHub Free Tier (MVP) - 3,000 Actions minutes/month
- GitHub Team Tier (Post-Funding, Month 3-6) - $4/user/month
- GitHub Enterprise (Post-Funding, Month 6-12) - $21/user/month, SOC2, SAML SSO
- Infrastructure-as-Code (can rebuild from scratch)

---

### 3. Integration Requirements (Lines 61-94)
**GitHub Ecosystem:**
- GitHub CLI (`gh`) - Programmatic org/repo management
- GitHub Actions - CI/CD, dashboard updates, security scanning
- GitHub REST API - Dashboard data collection
- GitHub GraphQL API (Future) - Efficient queries for 7F Lens

**BMAD Library Integration:**
- Submodule Pattern: `git submodule add https://github.com/bmad-method/bmad-method.git _bmad`
- Pinned Version: `v6.0.0` (stability)
- Symlink Skills: `.claude/commands/bmad-*.md`
- 18 BMAD Skills adopted

**Claude Code SDK:**
- Two-agent pattern (initializer + coding)
- Feature Tracking (`feature_list.json`)
- Progress Logging (`claude-progress.txt`)
- Prompt Templates (initializer, coding)

**Voice Input System:**
- OpenAI Whisper API (cross-platform speech-to-text)
- Local Installation (Linux/macOS/Windows WSL)
- Web Fallback (Windows non-WSL, mobile)
- Integration: BMAD skills, brand generator, content creation

**Dashboard Data Sources:**
- RSS Feeds (OpenAI, Anthropic, Google AI, Meta AI, arXiv)
- GitHub API (LangChain, LlamaIndex releases)
- Reddit API (r/MachineLearning, r/LocalLLaMA)
- X API (Optional, post-funding)
- Claude API (Weekly AI summary)

---

### 4. Existing Skills to Leverage (Lines 97-183)
**CRITICAL DISCOVERY:** Existing skills in `/home/ladmin/dev/claude-code-second-brain-skills/` directly map to requirements.

**Skills to Adapt for MVP (5 skills, 10 hours):**

| Existing Skill | Seven Fortunas Adaptation | Effort | Maps to Journey |
|---|---|---|---|
| **brand-voice-generator** | → `7f-brand-system-generator` | 2 hours | Henry (CEO) - Brand ethos |
| **pptx-generator** | → `7f-presentation-generator` | 1 hour | Henry (CEO) - Investor pitch |
| **excalidraw-diagram** | → `7f-diagram-generator` | 2 hours | Patrick (CTO) - Architecture docs |
| **sop-creator** | → `7f-documentation-generator` | 1 hour | Patrick/Buck - Procedures |
| **skill-creator** | Use as-is (meta-skill) | 0 hours | Jorge - Create custom skills |

**Adaptation Details:**

**1. brand-voice-generator → 7f-brand-system-generator (2 hours)**
- Creates `brand.json`, `brand-system.md`, `tone-of-voice.md`
- Customization: Seven Fortunas domain (digital inclusion, marginalized communities)
- Add Seven Fortunas color palette
- Output to `seven-fortunas-brain/brand-system/`

**2. pptx-generator → 7f-presentation-generator (1 hour)**
- 16 slide layouts, carousel mode, brand integration, python-pptx
- Minimal adaptation (works after brand system created)
- Optional: Seven Fortunas-specific slide templates

**3. excalidraw-diagram → 7f-diagram-generator (2 hours)** **(ELEVATED TO MVP)**
- Visual diagrams with semantic colors, pattern library
- Customize color palette for Seven Fortunas brand
- Add domain-specific patterns (workflow, architecture, org charts)
- Output to Second Brain `architecture/` directory
- **Jorge's Rationale:** "Very good to create documentation diagrams - consider making part of MVP PRD"

**4. sop-creator → 7f-documentation-generator (1 hour)**
- Runbooks, playbooks, technical docs with "Definition of Done"
- Minor branding adaptation
- Output to Second Brain `best-practices/` directory

**5. skill-creator (Use as-is)**
- Meta-skill for creating new skills with YAML frontmatter
- No adaptation needed

**Skills to Create from Scratch (3 skills, 12 hours):**
1. `7f-manage-profile` - User profile YAML management (4 hours)
2. `7f-dashboard-curator` - 7F Lens configuration (4 hours)
3. `7f-repo-template-generator` - GitHub repo scaffolding (4 hours)

**Revised Skill Strategy:**
- **Before:** 7 skills from scratch = 32 hours
- **After (with excalidraw in MVP):** 5 adapted + 3 new = 22 hours
- **Savings:** 10 hours (31% reduction)

**MVP Skill Count:**
- 18 BMAD skills
- 5 adapted skills
- 3 new skills
- **Total: 26 operational skills** (up from original 25)

---

### 5. Risk Mitigations (Lines 185-224)
**Autonomous Agent Risks:**
- Agent gets stuck → Bounded retries (max 3), timeout (30 min)
- Agent hallucinates → Testing built-in, no "pass" without tests
- Agent commits secrets → Pre-commit hooks block, GitHub Actions double-check
- Agent makes destructive changes → Git history preserves, can rollback
- Agent exceeds API limits → Budget cap ($50/month), monitoring alerts

**Security Risks:**
- Secrets committed → detect-secrets hook, GitHub scanning, education
- Vulnerable dependencies → Dependabot updates, security alerts, patch process
- Unauthorized access → 2FA required, team-based permissions, audit logs
- Data breach (future) → Encryption, SOC2 compliance
- Supply chain attack → BMAD pinned to version, verify submodule integrity

**Scalability Risks:**
- GitHub Actions minutes exhausted → Monitor usage, optimize workflows, upgrade tier
- Dashboard APIs rate-limited → Respectful polling (6 hours), caching, graceful degradation
- Knowledge base unmanageable → Progressive disclosure, clear taxonomy, search
- Too many repos → Consistent naming, repo templates, automation scripts

**Team Risks:**
- Jorge becomes bottleneck → Self-service skills, BMAD library, comprehensive docs
- New team members overwhelmed → Structured onboarding, Second Brain, mentors
- Knowledge silos → Everything documented, no tribal knowledge
- Bus factor → Multiple founders with Owner access, documented procedures

---

## Critical Information
- **Medium-High complexity** DevOps/Infrastructure project
- **Security-First Mandate** - Non-negotiable (Buck's aha moment depends on this)
- **Existing skills leverage** - 31% time savings by adapting 5 skills
- **Excalidraw diagrams elevated to MVP** - Jorge's insight for documentation clarity
- **Greenfield advantage** - No legacy constraints, AI-native from inception
- **26 operational skills** in MVP (increased from 25)

---

## Key Constraints
- **GitHub Free Tier** limits (MVP)
- **Zero secrets committed** (100% detection required)
- **Bounded retries** (max 3 attempts per feature)
- **Progressive disclosure** (efficient agent context)

---

## Ambiguities / Questions
- None - comprehensive technical requirements

---

## Related Documents
- Builds on AI Automation Analysis (30 opportunities)
- Informs Functional Requirements (technical implementation)
- Validates Innovation Analysis (existing skills leverage)
- Supports Architecture Document (technical design)
