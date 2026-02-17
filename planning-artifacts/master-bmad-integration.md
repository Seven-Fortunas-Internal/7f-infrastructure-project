---
title: BMAD Integration Master Document
type: Master Document (6 of 6)
sources: [bmad-skill-mapping-2026-02-10.md, ai-automation-opportunities-analysis-2026-02-10.md]
date: 2026-02-15
author: Mary (Business Analyst) with Jorge
status: Phase 2 - Master Consolidation
version: 1.8.0
editorial-review: Complete (structure + prose + adversarial, 2026-02-15)
adversarial-review: Complete (18 findings resolved, 2026-02-15)
phase-2-additions: 6 new items added (2 BMAD sprint skills, 3 custom skills, 1 integration, 2026-02-15)
---

# BMAD Integration Master Document

## BMAD Strategy

**BMAD-First Approach:** Leverage 70+ existing BMAD skills instead of building from scratch
**Coverage:** 60% of identified needs met by existing BMAD (18 skills adopted), 14% by adapted skills (5 skills), 26% custom (3 skills)
**ROI:** Estimated 81% cost reduction ($7,000 vs $36,000), 4.5x faster time to market (1.75 weeks vs 9 weeks) - **All estimates subject to validation after Phase 1.5 completion**

### ROI Calculation Breakdown

**Scenario A: Build All Skills from Scratch (No BMAD)**

| Activity | Hours | Rate | Cost |
|----------|-------|------|------|
| Design 26 skill workflows | 52h (2h each) | $100/h | $5,200 |
| Implement 26 skills | 130h (5h each) | $100/h | $13,000 |
| Test 26 skills | 52h (2h each) | $100/h | $5,200 |
| Document 26 skills | 26h (1h each) | $100/h | $2,600 |
| Integration testing | 40h | $100/h | $4,000 |
| Bug fixes (20% rework) | 60h | $100/h | $6,000 |
| **Total** | **360h** | | **$36,000** |

**Timeline:** 360h ÷ 40h/week = 9 weeks (with 1 developer)

**Scenario B: BMAD-First Approach (Actual Plan)**

| Activity | Hours | Rate | Cost | Notes |
|----------|-------|------|------|-------|
| BMAD setup + 18 skill stubs | 3h | $100/h | $300 | Phase 0 |
| Build 2 custom skills | 12h | $100/h | $1,200 | Phase 1: 7f-repo-template, 7f-dashboard-curator |
| Adapt 5 BMAD skills | 15h (3h each) | $100/h | $1,500 | Phase 1.5: brand, pptx, excalidraw, sop, meta-skill |
| Test 25 skills | 25h (1h each) | $100/h | $2,500 | Reduced time (BMAD pre-tested) |
| Document 7 custom/adapted | 7h | $100/h | $700 | BMAD skills pre-documented |
| Integration testing | 8h | $100/h | $800 | Reduced scope (focus on custom integrations) |
| **Total** | **70h** | | **$7,000** |

**Timeline:** 70h ÷ 40h/week = 1.75 weeks (with 1 developer)

**ROI Summary:**
- **Cost savings:** $36,000 - $7,000 = $29,000 (81% reduction)
- **Time savings:** 9 weeks - 1.75 weeks = 7.25 weeks (4.5x faster)
- **Effort reduction:** 360h - 70h = 290h (81% less work)

**Assumptions (All estimates require post-implementation validation):**
1. Jorge billing rate: $100/h (conservative for ROI calculation; actual SF market rate $150-200/h would increase absolute costs but maintain same % reduction)
2. Skill complexity: Average 5h to build from scratch (range: 2-12h)
3. BMAD adaptation: 3h per skill (60% less than building from scratch)
4. Testing time: 50% less with BMAD (pre-tested, only test integrations)
5. BMAD skills require zero customization (adopted as-is)

**Sensitivity Analysis:**

| What If... | Impact on ROI | New Cost | New Timeline |
|------------|---------------|----------|--------------|
| Adaptation takes 2x longer (6h/skill) | 15h → 30h (+15h) | $8,500 (+21%) | 2.1 weeks (+20%) |
| Custom skills take 2x longer (10h each) | 12h → 24h (+12h) | $8,200 (+17%) | 2.0 weeks (+14%) |
| 50% of BMAD skills need adaptation | 18 adopted → 9 adopted, 9 adapted | $11,200 (+60%) | 2.8 weeks (+60%) |
| BMAD doesn't exist (worst case) | Full build from scratch | $36,000 (baseline) | 9 weeks (baseline) |

**Break-even Analysis:**
- BMAD adoption is cost-effective if >5 skills can be used (18% of needs)
- Seven Fortunas: 18/26 skills = 69% adopted → **4x better than break-even**

**Validation Status:** **All ROI figures are estimated (pre-implementation) and subject to validation**
- After Phase 1.5 complete: Compare actual hours vs estimates, update this section with actuals
- Actual costs may vary ±30% based on unexpected complexity, integration issues, or scope changes
- **Maintenance costs not included in ROI:** Ongoing maintenance estimated at 2-4h/month ($200-400/month at $100/h rate), includes bug fixes, BMAD upgrades, skill updates (see Skill Lifecycle Management section for details)

---

## Available Skills (31 Total + 1 Integration)

**MVP Delivery (Phase 0-1.5):** 25 skills
- 18 BMAD adopted (Phase 0)
- 2 custom built (Phase 1): 7f-repo-template, 7f-dashboard-curator
- 5 adapted (Phase 1.5): 7f-brand-system-generator, 7f-pptx-generator, 7f-excalidraw-generator, 7f-sop-generator, 7f-skill-creator

**Phase 2 Additions:** +6 items (2 BMAD + 3 custom + 1 integration)
- 2 BMAD sprint skills: bmad-bmm-create-sprint, bmad-bmm-sprint-review
- 3 custom skills: 7f-sprint-dashboard, 7f-secrets-manager, 7f-manage-profile
- 1 custom integration: Matrix + GitHub Bot

**Total:** 31 skills + 1 integration

### 20 BMAD Skills (Adopted As-Is: 18 MVP + 2 Phase 2)

**Business Method (bmm) - 8 skills (6 MVP + 2 Phase 2):**
1. bmad-bmm-create-prd - Generate Product Requirements Document
2. bmad-bmm-create-architecture - Generate system architecture document
3. bmad-bmm-create-story - Create user stories with acceptance criteria
4. bmad-bmm-create-epic - Create epics from high-level requirements
5. bmad-bmm-transcribe-audio - Transcribe audio files to text
6. bmad-bmm-create-sop - Create standard operating procedures
7. bmad-bmm-create-sprint - Sprint planning (Phase 2)
8. bmad-bmm-sprint-review - Sprint retrospectives (Phase 2)

**Builder (bmb) - 7 skills:**
9. bmad-bmb-create-workflow - Create BMAD workflow from requirements
10. bmad-bmb-validate-workflow - Validate workflow structure and completeness
11. bmad-bmb-create-github-repo - Create GitHub repository with templates
12. bmad-bmb-configure-ci-cd - Configure CI/CD pipelines
13. bmad-bmb-create-docker - Generate Dockerfile and docker-compose
14. bmad-bmb-create-test - Generate test suites (unit, integration, e2e)
15. bmad-bmb-code-review - AI-powered code review

**Creative Intelligence (cis) - 5 skills:**
16. bmad-cis-generate-content - Generate marketing/technical content
17. bmad-cis-brand-voice - Apply brand voice to content
18. bmad-cis-generate-pptx - Generate PowerPoint presentations
19. bmad-cis-generate-diagram - Generate architecture diagrams (Excalidraw)
20. bmad-cis-summarize - Summarize long documents

### 5 Adapted Skills (BMAD-Based, Seven Fortunas Customized)

19. **7f-brand-system-generator** (adapted from bmad-cis-brand-voice)
    - Purpose: Henry creates brand system via voice input
    - Customization: Integrated with OpenAI Whisper, outputs brand.json + brand-system.md + tone-of-voice.md, applies branding to all GitHub assets
    - Owner: Jorge (creation), Henry (primary user)

20. **7f-pptx-generator** (adapted from bmad-cis-generate-pptx)
    - Purpose: Generate investor pitch decks with Seven Fortunas branding
    - Customization: Uses brand.json for colors/fonts, Seven Fortunas templates
    - Owner: Henry (primary user)

21. **7f-excalidraw-generator** (adapted from bmad-cis-generate-diagram)
    - Purpose: Generate architecture diagrams in Excalidraw format
    - Customization: Seven Fortunas color palette, consistent iconography
    - Owner: Patrick (primary user)

22. **7f-sop-generator** (adapted from bmad-bmm-create-sop)
    - Purpose: Generate SOPs for Seven Fortunas operations
    - Customization: Seven Fortunas SOP template, brand voice
    - Owner: Operations team

23. **7f-skill-creator** (adapted from bmad-bmb-create-workflow) - **META-SKILL**
    - Purpose: Generate new Seven Fortunas skills from YAML requirements
    - Customization: Seven Fortunas skill structure, search-before-create, usage tracking
    - Owner: Jorge

### 3 Custom Skills (Built from Scratch: 2 MVP + 1 Phase 2)

24. **7f-manage-profile** *(Phase 2)*
    - **Purpose:** User profile management (set preferences, notification settings, skill access tiers)
    - **Why Custom:** Seven Fortunas-specific user management, no BMAD equivalent
    - **Functionality:**
      - Set user preferences (timezone, language, notification frequency)
      - Configure skill access (which skills user can invoke)
      - Manage notification channels (email, Slack, GitHub)
    - **Data Model:** JSON file per user (`.claude/profiles/{username}.json`)
    - **Acceptance Criteria:**
      - User can set preferences via conversational interface (no manual JSON editing)
      - Preferences persist across sessions
      - Invalid inputs handled gracefully (with validation error messages)
    - **Owner:** Jorge
    - **Effort:** 8-12 hours (data model 2h, CRUD operations 4h, validation 2h, testing 2-4h)

25. **7f-dashboard-curator**
    - **Purpose:** Add/remove data sources for 7F Lens dashboards without YAML editing
    - **Why Custom:** Specific to 7F Lens architecture (sources.yaml schema), no BMAD equivalent
    - **Functionality:**
      - Add new source: name, URL, type (RSS/JSON/API), fetch frequency
      - Remove source: select from list, confirm deletion
      - Validate source: test API call, check data format
      - Update sources.yaml atomically (no partial writes)
    - **Data File:** `dashboards/config/sources.yaml`
    - **Acceptance Criteria:**
      - Source added successfully → sources.yaml updated → next aggregation includes new source
      - Invalid URL rejected with error message (not silently added)
      - Duplicate source detection (prevent adding same URL twice)
      - Removal confirmation required (no accidental deletion)
    - **Owner:** Jorge (creation), All founders (users)
    - **Effort:** 4-6 hours (YAML parsing 1h, CRUD operations 2h, validation 1h, testing 1-2h)

26. **7f-repo-template**
    - **Purpose:** Repository scaffolding with Seven Fortunas security/CI/CD standards
    - **Why Custom:** Seven Fortunas-specific templates (security policies, CI/CD workflows), no BMAD equivalent
    - **Functionality:**
      - Ask: repo name, type (frontend/backend/infra), owner, visibility (public/private)
      - Generate: README.md with branding, .github/workflows/ci.yml, SECURITY.md, CODEOWNERS
      - Apply: Seven Fortunas standards (branch protection, secret scanning, Dependabot)
      - Create: GitHub repo via API (or provide git commands)
    - **Templates:** `_bmad/7f/workflows/repo-template/templates/*.j2`
    - **Acceptance Criteria:**
      - Repository created with all required files (README, SECURITY, CI/CD, CODEOWNERS)
      - CI/CD workflow triggers on push (validates setup)
      - Security templates present (SECURITY.md mentions bug bounty process)
      - Seven Fortunas branding applied (logo, colors, footer)
    - **Owner:** Buck (primary user for engineering repos)
    - **Effort:** 4-6 hours (templates 2h, workflow logic 1h, GitHub API integration 1h, testing 1-2h)

### Phase 2 Skills & Integrations (3 Custom Skills + 1 Integration)

**27. 7f-sprint-dashboard** (v1.0.0)
- **Purpose:** Interactive sprint board management via conversational interface
- **Why Custom:** GitHub Projects API integration specific to Seven Fortunas sprint workflow
- **Functionality:**
  - Query sprint status: "Show me current sprint backlog"
  - Update card status: "Move feature FR-8.1 to In Progress"
  - Add sprint notes: "Add blocker note to FR-8.3: waiting on API key"
  - Display sprint metrics: velocity, burndown, completion rate
- **Integration:** GitHub Projects API (same rate limit as GitHub API)
- **Acceptance Criteria:**
  - Skill can list all cards in current sprint board
  - Skill can move cards between columns (Backlog → In Progress → Done)
  - Skill can add/update card labels and notes
  - Changes reflected in GitHub Projects web UI within 5 minutes
- **Owner:** Jorge
- **Effort:** 12-16 hours (GraphQL API learning 3-4h, integration 4-5h, conversational interface 3-4h, testing 2-3h)
- **Priority:** Phase 2

**28. 7f-secrets-manager** (v1.0.0)
- **Purpose:** Conversational interface for GitHub Secrets org-level management
- **Why Custom:** Simplify GitHub CLI commands for non-technical founders
- **Functionality:**
  - List secrets: "What API keys are stored?" → Shows secret names (not values)
  - Add secret: "Store Claude API key" → Prompts for value, calls `gh secret set`
  - Rotate secret: "Rotate Claude API key" → Prompts for new value, updates, logs rotation
  - Audit access: "Who accessed secrets recently?" (Phase 3: GitHub Enterprise audit log)
- **Integration:** GitHub Secrets API via GitHub CLI (`gh secret` commands)
- **Acceptance Criteria:**
  - Skill can list all org-level secret names
  - Skill can add new secrets (with confirmation)
  - Skill can update existing secrets (with rotation log entry)
  - All operations logged to `.claude/secrets-audit.log`
  - Documentation in Second Brain (second-brain-core/operations/secrets-management.md)
- **Owner:** Jorge
- **Effort:** 4-6 hours (CLI wrapper 2h, conversational interface 1h, audit logging 1h, testing 1-2h)
- **Priority:** Phase 2

**29. Matrix + GitHub Bot Integration** *(Custom Integration, not a skill)*
- **Purpose:** Real-time team communication integrated with GitHub workflow
- **Why Custom:** Self-hosted Matrix with GitHub event notifications
- **Components:**
  - **Matrix Homeserver:** Synapse (Python) or Dendrite (Go, lightweight)
  - **GitHub Bot:** Node.js webhook listener → Matrix SDK
  - **Channels:** Mirror GitHub repos (#infrastructure, #dashboards, #brain, #general)
- **Functionality:**
  - Bot posts to Matrix when:
    - PR opened/merged/closed
    - Issue created/assigned/closed
    - CI/CD success/failure
    - Security alert (Dependabot, secret scanning)
  - E2E encryption for all channels (Olm/Megolm)
  - Unlimited message history (local storage, no cloud limits)
- **Deployment:**
  - Docker Compose: Matrix homeserver + PostgreSQL + Bot
  - VPS (persistent, always-on; GitHub Codespaces NOT recommended - requires manual restart after 30-day inactivity, no always-on guarantee)
  - Domain: matrix.sevenfortunas.com (or matrix.7f.internal for private)
- **Acceptance Criteria:**
  - Matrix homeserver accessible and stable (99% uptime)
  - All founders onboarded (Element client, rooms joined)
  - GitHub Bot authenticated and posting events
  - E2E encryption enabled and keys backed up
  - Bot posts within 30 seconds of GitHub event
  - Message history retained indefinitely (no deletion)
- **Owner:** Jorge (deployment), All founders (users)
- **Effort:** 40-60 hours (Matrix deploy 12-16h, Bot development 16-24h, security hardening 8-12h, testing/docs 4-8h)
- **Note:** Includes production-grade error handling, webhook security (HMAC), rate limiting, monitoring setup
- **Priority:** Phase 2

---

## Deployment Strategy

### Phase 0: BMAD Library Setup (Jorge, 2-3 hours)

**Objective:** Install BMAD library and create skill stubs for 18 adopted skills

**1. Add BMAD as Git Submodule (15 min):**
```bash
cd /path/to/7f-infrastructure-project
git submodule add https://github.com/bmad-dev/bmad.git _bmad
git submodule update --init --recursive
cd _bmad && git checkout v6.0.0  # Pin to stable version (verify v6.0.0 exists: git tag -l "v6.0.0")
cd .. && git add .gitmodules _bmad && git commit -m "Add BMAD v6.0.0 as submodule"
```

**2. Create Skill Stubs for 18 BMAD Skills (45 min):**
```bash
mkdir -p .claude/commands

# Business Method (6 skills) - 10 min
for skill in create-prd create-architecture create-story create-epic transcribe-audio create-sop; do
  cat > .claude/commands/bmad-bmm-$skill.md << EOF
# bmad-bmm-$skill

Invoke BMAD workflow: @{project-root}/_bmad/bmm/workflows/$skill/workflow.md
EOF
done

# Builder (7 skills) - 12 min
for skill in create-workflow validate-workflow create-github-repo configure-ci-cd create-docker create-test code-review; do
  cat > .claude/commands/bmad-bmb-$skill.md << EOF
# bmad-bmb-$skill

Invoke BMAD workflow: @{project-root}/_bmad/bmb/workflows/$skill/workflow.md
EOF
done

# Creative Intelligence (5 skills) - 8 min
for skill in generate-content brand-voice generate-pptx generate-diagram summarize; do
  cat > .claude/commands/bmad-cis-$skill.md << EOF
# bmad-cis-$skill

Invoke BMAD workflow: @{project-root}/_bmad/cis/workflows/$skill/workflow.md
EOF
done

# Commit skill stubs - 5 min
git add .claude/commands/bmad-*.md
git commit -m "Add 18 BMAD skill stubs"
```

**3. Test BMAD Skills (10 min):**
```bash
# Test 3 representative skills (one from each module) by invoking them
# Note: claude-code CLI does not have a --test flag; instead verify skill loads without errors
/bmad-bmm-create-prd   # Should present workflow menu
/bmad-bmb-create-workflow
/bmad-cis-summarize

# If any fail, check submodule path and skill stub syntax
```

**4. Verification (5 min):**
```bash
ls .claude/commands/bmad-*.md | wc -l  # Should show 18
git log --oneline -5  # Should show BMAD commits
cd _bmad && git describe --tags  # Should show v6.0.0
```

**Estimated Total: 2-3 hours** (including debugging time)

---

### Phase 1: Custom Skill Development (Jorge, 16-24 hours over 3-5 days)

**Objective:** Build 3 custom skills from scratch (manual, no meta-skill yet)

**Bootstrap Strategy:**
- 7f-skill-creator (meta-skill) doesn't exist yet - can't use it to create itself
- Build first 3 custom skills manually to learn BMAD structure
- Build 7f-skill-creator last (once we understand skill patterns)
- Use 7f-skill-creator for future skills (Phase 2+)

**Skill #1: 7f-repo-template (4-6 hours, Day 1-2)**

**Purpose:** Repository scaffolding with Seven Fortunas security/CI/CD standards

**Implementation:**
1. Create workflow structure (1h):
   ```bash
   mkdir -p _bmad/7f/workflows/repo-template/{steps,data,templates}
   touch _bmad/7f/workflows/repo-template/workflow.md
   ```

2. Define workflow.md (1h):
   ```yaml
   ---
   name: 7f-repo-template
   description: Create GitHub repo with Seven Fortunas standards
   steps: [create-01-gather-requirements, create-02-generate-repo-structure, validate-01-check-structure]
   ---
   ```

3. Create step files (2h):
   - create-01-gather-requirements.md (ask: repo name, type, owner, visibility)
   - create-02-generate-repo-structure.md (generate: README, .github/workflows, security templates)
   - validate-01-check-structure.md (verify: all required files present)

4. Create templates (1h):
   - templates/README.md.j2 (Jinja2 template with Seven Fortunas branding)
   - templates/security-policy.md
   - templates/ci-cd.yml (GitHub Actions workflow)

5. Test manually (30 min)

**Skill #2: 7f-dashboard-curator (4-6 hours, Day 2-3)**

**Purpose:** Add/remove data sources for 7F Lens dashboards without YAML editing

**Implementation:**
1. Create workflow structure (1h)
2. Define workflow steps (2h):
   - create-01-select-action.md (ask: add or remove source?)
   - create-02-configure-source.md (for add: name, URL, type, frequency)
   - edit-01-update-sources-yaml.md (modify sources.yaml)
   - validate-01-test-fetch.md (test API call, verify data format)
3. Add error handling (1h): Invalid URL, rate limit check, duplicate source detection
4. Test with real dashboard (1-2h)

**Skill #3: 7f-manage-profile (8-12 hours, Day 3-5) - **DEFERRED TO PHASE 2**

**Purpose:** User profile management (preferences, notification settings)

**Rationale for Deferral:**
- Most complex skill (requires data persistence, schema design)
- Not MVP-critical (can use manual config for 4 founders)
- Better to build after learning from first 2 skills

**Phase 1 Delivery:** 2 of 3 custom skills (7f-repo-template, 7f-dashboard-curator)

---

### Phase 1.5: Adapted Skills + Meta-Skill (Jorge, 12-16 hours over 2-3 days)

**Objective:** Adapt 5 BMAD skills for Seven Fortunas branding + build meta-skill

**Adapted Skill #1: 7f-brand-system-generator (2-3 hours)**
- Base: bmad-cis-brand-voice
- Adaptation: Integrate OpenAI Whisper (MacOS: native, Linux: whisper-cli)
- Output: brand.json (colors, fonts, logo URLs) + brand-system.md + tone-of-voice.md
- Testing: Henry records 5-min brand voice memo → generates brand system

**Adapted Skill #2: 7f-pptx-generator (2-3 hours)**
- Base: bmad-cis-generate-pptx
- Adaptation: Read brand.json, apply colors/fonts to PowerPoint template
- Dependency: Requires 7f-brand-system-generator output
- Testing: Generate investor pitch deck with Seven Fortunas branding

**Adapted Skill #3: 7f-excalidraw-generator (2-3 hours)**
- Base: bmad-cis-generate-diagram
- Adaptation: Apply Seven Fortunas color palette (#1E3A8A, #F59E0B, etc.)
- Output: Excalidraw JSON format
- Testing: Generate architecture diagram for 7F Lens

**Adapted Skill #4: 7f-sop-generator (2-3 hours)**
- Base: bmad-bmm-create-sop
- Adaptation: Seven Fortunas SOP template (header, footer, approval section)
- Testing: Generate SOP for incident response

**Adapted Skill #5: 7f-skill-creator (4-6 hours) - META-SKILL**
- Base: bmad-bmb-create-workflow
- Adaptation:
  - Search existing skills before creating (grep .claude/commands/, fuzzy match)
  - Seven Fortunas skill naming convention (7f-* prefix)
  - Usage tracking instrumentation (log invocations to .claude/usage.log)
- Testing: Use it to generate a test skill, verify all files created correctly

**Phase 1.5 Delivery:** 5 adapted skills + 1 meta-skill

---

### Summary: Skill Deployment Timeline

| Phase | Duration | Deliverables | Jorge Effort |
|-------|----------|--------------|--------------|
| **Phase 0** | 2-3 hours (Day 0) | BMAD v6.0.0 + 18 skill stubs | Setup, testing |
| **Phase 1** | 8-12 hours (Day 1-3) | 2 custom skills (repo-template, dashboard-curator) | Manual development |
| **Phase 1.5** | 12-16 hours (Day 4-7) | 5 adapted skills + meta-skill (skill-creator) | Adaptation, testing |
| **Phase 2+** | <2 hours per skill | Future skills generated with 7f-skill-creator | Automated |

**Total Initial Investment:** 22-31 hours (Phase 0 + 1 + 1.5)
**MVP Delivery:** 25 of 31 skills (7f-manage-profile deferred to Phase 2 along with 5 other Phase 2 skills)

---

## Usage Patterns

### Pattern 1: Planning & Discovery (bmm)
**When:** Creating PRD, architecture, user stories, SOPs
**Skills:** bmad-bmm-create-prd, bmad-bmm-create-architecture, bmad-bmm-create-story
**Example:** "Jorge needs PRD" → /bmad-bmm-create-prd → Guided interview → PRD generated

### Pattern 2: Building & Automation (bmb)
**When:** Creating repos, workflows, CI/CD, tests
**Skills:** bmad-bmb-create-github-repo, bmad-bmb-configure-ci-cd, bmad-bmb-create-test
**Example:** "Buck needs new service repo" → /7f-repo-template → Repo created with security/CI/CD

### Pattern 3: Content & Brand (cis + 7f)
**When:** Creating brand content, presentations, diagrams
**Skills:** 7f-brand-system-generator, 7f-pptx-generator, 7f-excalidraw-generator
**Example:** "Henry needs pitch deck" → /7f-pptx-generator → Deck with Seven Fortunas branding

### Pattern 4: Operations & Maintenance (7f)
**When:** Managing dashboards, user profiles, repo templates
**Skills:** 7f-dashboard-curator, 7f-manage-profile
**Example:** "Add new AI blog to dashboard" → /7f-dashboard-curator → Source added, dashboard rebuilds

---

## Skill Discovery & Documentation

### How Team Learns 26 Skills

**Challenge:** 26 skills is overwhelming - how do team members discover and learn them?

**Solution: Progressive Discovery (3 levels)**

**Level 1: Skill Catalog (Quick Reference)**
- Location: `docs/skill-catalog.md` in infrastructure repo
- Format: Table with skill name, purpose (one sentence), primary user
- Update: After each new skill added
- Usage: Team member scans table, identifies relevant skill

**Example:**
| Skill | Purpose | Primary User |
|-------|---------|--------------|
| bmad-bmm-create-prd | Generate Product Requirements Document | Product Manager |
| 7f-repo-template | Create repo with Seven Fortunas standards | Buck (engineering) |
| 7f-dashboard-curator | Add/remove dashboard data sources | All founders |

**Level 2: Skill README (Detailed Guide)**
- Location: Each skill has `README.md` in workflow directory
- Format: Purpose, Usage Example, Parameters, Outputs, Common Errors
- Update: When skill created/modified
- Usage: Team member needs details before first use

**Example: _bmad/7f/workflows/repo-template/README.md**
```markdown
# 7f-repo-template

## Purpose
Create GitHub repository with Seven Fortunas security and CI/CD standards.

## Usage
/7f-repo-template

You'll be asked:
1. Repository name (e.g., "api-gateway")
2. Type (frontend/backend/infrastructure)
3. Owner (Buck/Jorge/Patrick)
4. Visibility (public/private)

## Outputs
- GitHub repository created
- README.md with Seven Fortunas branding
- .github/workflows/ci.yml (CI/CD pipeline)
- SECURITY.md (security policy)
- CODEOWNERS (code review assignments)

## Common Errors
- "Repository already exists" → Choose different name
- "GitHub API rate limit" → Wait 1 hour or use different token
```

**Level 3: Interactive Help (In-Skill)**
- Location: Built into each skill workflow
- Format: Contextual help messages, examples, validation errors
- Update: Continuous (as part of skill development)
- Usage: Team member invokes skill, gets guidance inline

**Onboarding Process (New Team Member):**
1. Read skill catalog (15 min) - understand what's available
2. Shadow experienced user (30 min) - watch 3-5 skills in action
3. Try 3 skills yourself (1 hour) - hands-on practice with guidance
4. Reference README as needed (ongoing)

---

## Skill Governance (Phase 1.5+)

### Search Before Create (7f-skill-creator Enhancement)

**Problem:** Team members create duplicate skills because they don't know existing ones

**Solution: Automated search before skill creation**

**Algorithm (Fuzzy Matching):**
- List all existing skills from `.claude/commands/*.md` directory
- Calculate Levenshtein distance (edit distance) between new skill name and each existing skill name
- Normalize similarity score to 0-1 range (1 = perfect match)
- Filter matches above threshold (default: 0.7 = 70% similarity)
- Return top matches sorted by similarity (highest first) with skill name, similarity score, and purpose
- Example: Searching "create-github-repository" returns:
  - bmad-bmb-create-github-repo (85% similarity) - "Create GitHub repo with templates"
  - 7f-repo-template (72% similarity) - "Repo with Seven Fortunas standards"
- Libraries: `fuzzywuzzy` (Python), `Levenshtein` (fast C implementation)
- Implementation: See `/scripts/skill_search.py` (to be created Phase 2)

**User Experience:**
```
User: /7f-skill-creator
Agent: What skill would you like to create?
User: A skill to create GitHub repositories with our standards
Agent: ⚠️ Found similar existing skills:
  1. 7f-repo-template (85% match) - Repo with Seven Fortunas standards
  2. bmad-bmb-create-github-repo (72% match) - Create GitHub repo with templates

Would you like to:
  A) Use existing skill (recommended)
  B) Adapt existing skill
  C) Create new skill anyway
User: A
Agent: Great! Try /7f-repo-template instead.
```

**Implementation:**
- Phase 1.5 (manual): Jorge reviews new skill requests, suggests existing skills
- Phase 2 (automated): Fuzzy matching algorithm in 7f-skill-creator
- Libraries: `fuzzywuzzy` (Python), `Levenshtein` (fast C implementation)

**False Positive Handling:**
- Threshold: 70% similarity (tunable based on false positive rate)
- User can override: "Create anyway" option always available
- Feedback loop: Track false positives (suggested skill not actually useful)

### Usage Tracking Implementation

**Objective:** Understand which skills used, by whom, how often

**Privacy-First Approach:**
- No PII collected (no file contents, no conversation logs)
- Aggregate metrics only (skill invocation counts)
- Opt-in for team (can disable in .claude/config.yaml)

**Data Collection (Lightweight):**
```bash
# .claude/usage.log (append-only log file)
# Format: ISO timestamp | username | skill name | status (started|completed|aborted)

2026-02-15T10:30:00Z | jorge | 7f-repo-template | started
2026-02-15T10:35:00Z | jorge | 7f-repo-template | completed
2026-02-15T11:00:00Z | buck | bmad-bmb-create-test | started
2026-02-15T11:02:00Z | buck | bmad-bmb-create-test | aborted
```

**Metrics Dashboard (Phase 2):**
```bash
# scripts/analyze_skill_usage.sh
cat .claude/usage.log | grep "completed" | cut -d'|' -f3 | sort | uniq -c | sort -rn

# Output:
# 45 7f-repo-template
# 23 bmad-bmm-create-prd
# 18 7f-dashboard-curator
# 12 bmad-bmb-create-test
#  8 bmad-cis-summarize
#  2 7f-excalidraw-generator (candidate for deprecation if <5 uses)
```

**Usage Tracking Instrumentation:**
- Automatic: Claude Code logs skill invocations (if enabled in settings)
- Manual: Add logging to skill workflow.md (optional)
- Storage: Local file (`.claude/usage.log`), Git-ignored (not committed)

**Opt-out:**
```yaml
# .claude/config.yaml
usage_tracking:
  enabled: false  # Set to false to disable tracking
```

### Quarterly Skill Reviews

**Schedule:** Last week of Jan, Apr, Jul, Oct (1-2 hour meeting)

**Attendees:**
- Jorge (primary maintainer, required)
- Buck (backup maintainer, optional)
- One representative from each team (optional, provide input)

**Agenda (90 min meeting):**
1. **Review usage metrics (30 min):**
   - Which skills used most? (celebrate successes)
   - Which skills unused? (candidates for deprecation)
   - Which skills have high abort rate? (need improvement)

2. **Deprecation decisions (30 min):**
   - Stale skills: <5 uses in 90 days (unless critical infrastructure)
   - Duplicate skills: Consolidate similar skills (merge or retire)
   - Broken skills: Not working, no one using, fix or remove

3. **Roadmap planning (30 min):**
   - New skill requests (from GitHub issues)
   - Adaptation needs (BMAD skills need Seven Fortunas customization)
   - BMAD upgrade planning (if new version available)

**Decision Authority:**
- Jorge has final say (primary maintainer)
- Consensus preferred (team input valued)
- Document decisions in meeting notes (GitHub issue or wiki page)

**Deprecation Criteria (Objective):**
- **Automatic candidate:** <5 invocations in 90 days
- **Exemptions:** Infrastructure skills (used rarely but critical, e.g., disaster recovery)
- **Override:** Team vote (if skill valuable despite low usage)

**Target:** <5 duplicate skills created per quarter (measured via search-before-create feature)

---

## BMAD vs Custom Decision Matrix

**Decision Framework (Objective Criteria):**

### Step 1: Search BMAD Library
```bash
# Search by keyword
grep -ri "github.*repository" _bmad/*/workflows/*/workflow.md

# Or use skill catalog
cat _bmad/CATALOG.md | grep -i "github"
```

### Step 2: Assess Match Quality (Scoring 0-10)

**Functionality Match (0-10 points):**
- **10 points:** Exact match (100% of requirements met)
- **8-9 points:** Strong match (80-99% requirements met, minor customization)
- **6-7 points:** Moderate match (60-79% requirements met, significant customization)
- **3-5 points:** Weak match (30-59% requirements met, major rework)
- **0-2 points:** Poor match (<30% requirements met)

**How to measure:**
1. List required features (e.g., "create repo, apply security templates, configure CI/CD")
2. Check which features BMAD skill provides
3. Calculate: (Features provided / Total features required) × 10

**Example: 7f-repo-template**
- Required: Create repo (✓), Security templates (✗), Seven Fortunas CI/CD (✗), Branding (✗)
- BMAD provides: 1/4 features = 25% = 2.5 points
- **Verdict:** Build custom (weak match)

**Maintenance Quality (0-10 points):**
- **10 points:** Active (updated <3 months ago, >5 contributors, tests present)
- **7-9 points:** Maintained (updated <6 months ago, 2-5 contributors)
- **4-6 points:** Stable (updated <1 year ago, 1 contributor, no major bugs)
- **1-3 points:** Stale (updated >1 year ago, abandoned issues)
- **0 points:** Deprecated (marked as deprecated in BMAD)

**Customization Effort (0-10 points):**
- **10 points:** Zero customization (adopt as-is)
- **8-9 points:** Minimal (change config, <2h work)
- **6-7 points:** Moderate (modify 1-2 files, 2-5h work)
- **3-5 points:** Significant (rewrite 30-50%, 5-10h work)
- **0-2 points:** Extensive (rewrite >50%, >10h work)

**How to measure:**
1. Estimate hours to customize BMAD skill (H_custom)
2. Estimate hours to build from scratch (H_scratch, typically 5-12h)
3. Calculate: 10 × (1 - H_custom / H_scratch)

**Example: 7f-brand-system-generator**
- H_custom: 3h (integrate Whisper, change output format)
- H_scratch: 8h (build entire voice → JSON pipeline)
- Score: 10 × (1 - 3/8) = 6.25 points (moderate customization)

### Step 3: Decision Logic

**Total Score = Functionality + Maintenance + (10 - Customization_Effort)**

| Total Score | Decision | Action |
|-------------|----------|--------|
| **25-30** | ✅ **Adopt as-is** | No customization, use BMAD directly |
| **20-24** | ✅ **Adapt BMAD** | Fork and customize, maintain Seven Fortunas version |
| **15-19** | ⚠️ **Build custom, reference BMAD** | Use BMAD as inspiration, build from scratch |
| **0-14** | ❌ **Build custom, ignore BMAD** | No relevant BMAD skill, full custom build |

**Special Cases:**

**No BMAD Equivalent:**
- Skip scoring, build custom immediately
- Example: 7f-dashboard-curator (no BMAD dashboard skill)

**Seven Fortunas-Specific Logic:**
- Even if BMAD score high, build custom if core logic is 7F-specific
- Example: 7f-manage-profile (user profile schema is 7F-specific)

**Security/Compliance Requirements:**
- If BMAD skill doesn't meet security standards, build custom
- Example: Secret management skill without encryption → build custom

**Decision Examples:**

| Skill | Func | Maint | Custom | Total | Decision |
|-------|------|-------|--------|-------|----------|
| bmad-bmm-create-prd | 10 | 10 | 10 (0h) | 30 | ✅ Adopt |
| 7f-brand-system-generator | 7 | 9 | 6 (3h) | 22 | ✅ Adapt |
| 7f-repo-template | 3 | 9 | 3 (7h) | 15 | ⚠️ Custom (reference) |
| 7f-dashboard-curator | 0 | N/A | N/A | N/A | ❌ Custom (no equivalent) |

---

## Testing Strategy

### Skill Testing Levels

**Level 1: Smoke Tests (Quick validation, <5 min per skill)**
- Invoke skill and verify menu appears without syntax errors
- Check that workflow.md loads and YAML frontmatter parses correctly
- Expected: Skill presents menu/prompts without errors
- Failure modes: File not found, YAML parse error, circular dependency
- Implementation: Manual invocation (e.g., `/bmad-bmm-create-prd`)

**Level 2: Functional Tests (Verify skill executes correctly, 10-20 min per skill)**
- Invoke skill with test inputs
- Verify expected outputs generated
- Check error handling (invalid inputs, missing dependencies)

**Example: Test 7f-repo-template**
```bash
# Test input: repo name "test-service", type "backend", owner "Buck"
/7f-repo-template
# Expected outputs:
# - .github/workflows/ci.yml created
# - README.md with Seven Fortunas branding
# - SECURITY.md present
# - All templates applied correctly
```

**Level 3: Integration Tests (Skills work together, 1-2 hours total)**
- Test skill dependencies (e.g., 7f-pptx-generator requires 7f-brand-system-generator output)
- Test data flow between skills
- Verify end-to-end workflows

**Example: Brand system workflow**
```
1. /7f-brand-system-generator → generates brand.json
2. /7f-pptx-generator → uses brand.json for styling
3. Verify: PowerPoint has correct colors/fonts from brand.json
```

**Level 4: User Acceptance Testing (Team members test, 2-4 hours)**
- Henry tests voice input skills (7f-brand-system-generator, bmad-bmm-transcribe-audio)
- Buck tests engineering skills (7f-repo-template, bmad-bmb-create-test)
- Jorge tests all skills (comprehensive validation)
- Lissa tests documentation skills (bmad-bmm-create-sop, bmad-cis-summarize)

### Regression Testing (After BMAD Upgrades)

**Scope:** Test all 18 adopted BMAD skills (5 adapted skills inherit BMAD changes)

**Automated Regression Test Suite (Phase 2):**
```bash
#!/bin/bash
# scripts/test_bmad_skills.sh

SKILLS=(
  "bmad-bmm-create-prd"
  "bmad-bmm-create-architecture"
  # ... all 18 BMAD skills
)

for skill in "${SKILLS[@]}"; do
  echo "Testing $skill..."
  claude-code --skill "$skill" --test || echo "❌ FAILED: $skill"
done
```

**Manual Regression Tests (MVP):**
1. Test 5 critical skills (one from each category):
   - bmad-bmm-create-prd (Business Method)
   - bmad-bmb-create-workflow (Builder)
   - bmad-cis-summarize (Creative Intelligence)
   - 7f-repo-template (Custom)
   - 7f-brand-system-generator (Adapted)

2. Time estimate: 1-2 hours (20 min per skill × 5 skills)

3. Pass criteria:
   - Skill loads without errors
   - Core functionality works (creates expected outputs)
   - Error handling works (graceful failure on invalid inputs)
   - No breaking changes affecting Seven Fortunas customizations

**Failure Response:**
- If 0-2 skills fail → Fix individually (2-4 hours)
- If 3-5 skills fail → Investigate BMAD breaking changes, might need broad fixes (4-8 hours)
- If >5 skills fail → Rollback BMAD upgrade, defer to next quarter

---

## Maintenance & Upgrades

### BMAD Version Management

**Current:** v6.0.0 (pinned via Git submodule SHA)
**Upgrade Policy:** Manual upgrades only (no auto-updates)
**Upgrade Cadence:** Quarterly (Jan, Apr, Jul, Oct) or for critical security patches

**Upgrade Process (4-8 hours):**

**Step 1: Review & Plan (1-2 hours)**
```bash
# Check BMAD changelog for new version
cd _bmad
git fetch --tags
git log v6.0.0..v6.1.0 --oneline  # Review commits since current version

# Look for:
# - Breaking changes (API changes, file structure changes)
# - New features (relevant to Seven Fortunas?)
# - Bug fixes (do we have workarounds to remove?)
# - Security patches (prioritize these)
```

**Step 2: Create Staging Branch (15 min)**
```bash
cd /path/to/7f-infrastructure-project
git checkout -b bmad-upgrade-v6.1.0
cd _bmad
git checkout v6.1.0  # Update submodule to new version
cd ..
git add _bmad
git commit -m "Test: Upgrade BMAD to v6.1.0"
```

**Step 3: Regression Testing (1-2 hours)**
- Run automated regression test suite (Phase 2) OR
- Run manual regression tests on 5 critical skills (MVP)
- Document any failures in GitHub issue

**Step 4: Fix Breaking Changes (0-4 hours, depends on scope)**

**Common breaking changes:**
- Workflow file structure changed → Update skill stubs
- Step naming convention changed → Update references
- YAML schema changed → Update workflow.md frontmatter
- Dependencies added → Install new dependencies

**Step 5: Merge to Main (15 min)**
```bash
# If all tests pass:
git checkout main
git merge bmad-upgrade-v6.1.0
git push origin main

# Update production (pull on developer machines)
git submodule update --init --recursive
```

**Rollback Procedure (15 min):**
```bash
cd _bmad
git checkout v6.0.0  # Revert to previous version
cd ..
git add _bmad
git commit -m "Rollback BMAD to v6.0.0 due to breaking changes"
```

**Security Update Policy:**

| Severity | Description | Response Time | Testing | Approval |
|----------|-------------|---------------|---------|----------|
| **Critical (P0)** | Remote code execution, credential leak | <4 hours | 3 most-used skills only | Jorge (solo decision) |
| **High (P1)** | Privilege escalation, data exposure | <24 hours | 5 critical skills | Jorge + Buck review |
| **Medium (P2)** | DoS, information disclosure | <1 week | Full regression (18 skills) | Standard upgrade process |
| **Low (P3)** | Minor security hardening | Next quarterly | Full regression | Standard upgrade process |

**Emergency Security Patch Process (P0/P1, <4 hours):**
1. **Triage (15 min):** Review CVE, assess impact on Seven Fortunas
2. **Apply patch (30 min):** Update BMAD submodule to patched version
3. **Expedited testing (1h):** Test 3-5 most-used skills (not full regression)
4. **Deploy (15 min):** Merge to main, notify team in Slack
5. **Post-mortem (1h, within 24h):** Document incident, lessons learned

**Stability vs Security Trade-off:**
- **MVP (Phase 0-1.5):** Prioritize stability (pin versions, upgrade quarterly)
- **Production (Phase 2+):** Balance stability + security (emergency patches for P0/P1)
- **Principle:** Security patches applied immediately (risk of breakage < risk of exploit)

### Seven Fortunas Skill Maintenance

**Owner:** Jorge (creator and primary maintainer)
**Backup:** Buck (Phase 2, for engineering skills: 7f-repo-template, bmad-bmb-*)

**Bug Fix SLA (Realistic):**
- **P0 (Critical - skill unusable):** <8 hours (business hours only, M-F 9am-5pm PT)
  - Example: 7f-repo-template crashes on invocation
  - Jorge availability: 40h/week, 8h/day (weekends/holidays excluded - bugs reported Friday evening will be addressed Monday morning)
  - For true emergencies outside business hours, escalate to Buck as backup
  - Backup: If Jorge unavailable >24h, escalate to Buck
- **P1 (High - workaround exists):** Within 1 week
  - Example: 7f-dashboard-curator doesn't validate URLs, but manual YAML edit works
- **P2 (Medium - cosmetic issues):** Next quarterly review
  - Example: 7f-pptx-generator uses wrong shade of blue

**Enhancement Process:**
- Quarterly reviews (last week of Jan, Apr, Jul, Oct)
- Proposals submitted via GitHub issues (label: enhancement)
- Jorge reviews, prioritizes, schedules for next sprint

**Deprecation Process (90-day notice):**
1. Mark skill as deprecated (add warning in skill stub)
2. Announce in team Slack (#7f-announcements)
3. Document migration path (what to use instead)
4. Remove skill after 90 days (archive to `_bmad/7f/deprecated/`)

**Skill Archival Retention Policy:**
- Archived skills retained for 2 years (24 months) in `_bmad/7f/deprecated/`
- Includes full workflow files, CHANGELOG.md, deprecation notice
- Rationale: Allows reference for historical context, rollback if needed, learning from past decisions
- After 2 years: Permanent deletion (Git history still available)

**Example Deprecation Notice:**
```markdown
# 7f-old-skill (⚠️ DEPRECATED)

**Deprecation Notice:** This skill will be removed on 2026-05-15.
**Migration:** Use 7f-new-skill instead.
**Reason:** Functionality merged into 7f-new-skill for better integration.

[Legacy workflow still available at...]
```

---

## Skill Dependency Management

### Dependency Types

**Type 1: Data Dependencies (Output → Input)**
- Skill A produces output file that Skill B consumes
- Example: 7f-brand-system-generator creates brand.json → 7f-pptx-generator reads brand.json

**Type 2: Sequential Dependencies (Order Matters)**
- Skill A must complete before Skill B can start
- Example: bmad-bmb-create-github-repo → bmad-bmb-configure-ci-cd (repo must exist first)

**Type 3: Optional Dependencies (Enhanced Functionality)**
- Skill B works standalone, but better with Skill A output
- Example: bmad-cis-summarize works without brand.json, but applies brand voice if available

### Dependency Declaration

**In Skill Workflow Frontmatter (YAML):**
- Declare `dependencies` section with `required` and `optional` arrays
- Each dependency specifies: skill name, expected output file, file location, validation command
- Required dependencies: Skill cannot run without these
- Optional dependencies: Enhance functionality if available, graceful degradation if missing
- Example: 7f-pptx-generator requires 7f-brand-system-generator (brand.json), optionally uses bmad-cis-brand-voice
- Validation: Use jq, grep, or custom validation commands to verify output file format

### Dependency Validation (Pre-Execution Check)

**Automatic Validation (Phase 2):**
- Before skill execution, check all required dependencies
- For each required dependency:
  1. Check if output file exists at specified location
  2. Run validation command to verify file format/content
  3. If missing or invalid: Raise DependencyError with actionable guidance
- If all satisfied: Proceed with skill execution
- User feedback: Clear error messages with "Run: /skill-name first" guidance
- Implementation: See `/scripts/validate_dependencies.py` (to be created Phase 2)

**User Experience:**
```
User: /7f-pptx-generator
Agent: ❌ Required dependency missing: 7f-brand-system-generator
       Expected output: .seven-fortunas/brand.json
       Run: /7f-brand-system-generator first

User: /7f-brand-system-generator
Agent: [Generates brand.json]
       ✓ Brand system generated

User: /7f-pptx-generator
Agent: ✓ All dependencies satisfied
       [Generates PowerPoint with branding]
```

**Error Handling for Missing Skills:**
- **Skill not found:** "Error: Skill '/unknown-skill' not found. Run '/help' to list available skills."
- **Skill file missing:** "Error: Skill file not found at .claude/commands/skill-name.md. Check BMAD submodule or reinstall."
- **Workflow file missing:** "Error: Workflow file not found at _bmad/module/workflows/skill-name/workflow.md. Update BMAD submodule."
- **Circular dependency:** "Error: Circular dependency detected: Skill A → B → C → A. Refactor skill dependencies."
- **User guidance:** All errors include actionable next steps (reinstall, update submodule, refactor, contact support)

### Dependency Graph (Phase 2)

**Visualization:**
```
7f-brand-system-generator
  ├─> 7f-pptx-generator (required)
  ├─> 7f-excalidraw-generator (required)
  └─> bmad-cis-generate-content (optional)

bmad-bmb-create-github-repo
  └─> bmad-bmb-configure-ci-cd (sequential)

7f-repo-template
  └─> bmad-bmb-create-github-repo (calls internally)
```

**Command:**
```bash
# Show dependency graph for a skill
claude-code --skill 7f-pptx-generator --show-deps

# Output:
# 7f-pptx-generator requires:
#   - 7f-brand-system-generator (provides brand.json)
```

### Circular Dependency Prevention

**Detection (During Skill Creation):**
- 7f-skill-creator checks for cycles when adding dependencies
- Algorithm: Depth-first search for cycles in dependency graph
- If cycle detected: Error message, require user to refactor

**Example Circular Dependency (Invalid):**
```
Skill A depends on Skill B
Skill B depends on Skill A
❌ Circular dependency detected
```

---

## Skill Versioning Strategy

### BMAD Skills (Adopted)

**Versioning:** Tied to BMAD library version
- Current: BMAD v6.0.0 → All 18 adopted skills at v6.0.0
- Upgrade: BMAD v6.1.0 → All 18 skills upgrade together

**No independent versioning for adopted skills (simplifies maintenance)**

### Seven Fortunas Custom/Adapted Skills

**Versioning:** Independent semantic versioning (semver 2.0)

**Version Format:** `MAJOR.MINOR.PATCH` (e.g., 1.2.3)

**Version Bumps:**
- **MAJOR:** Breaking changes (incompatible with previous version)
  - Example: Change output format (brand.json schema change)
  - Requires: Migration guide, deprecation notice (90 days)
- **MINOR:** New features (backward compatible)
  - Example: Add new optional parameter, new output field
  - Requires: Documentation update, release notes
- **PATCH:** Bug fixes (backward compatible)
  - Example: Fix validation error, improve error message
  - Requires: Brief changelog entry

**Version Tracking:**
```yaml
# In workflow.md frontmatter
---
name: 7f-brand-system-generator
version: 1.2.3
bmad_base_version: 6.0.0  # REQUIRED for adapted BMAD skills, documents base version and adaptation lineage
changelog: CHANGELOG.md
---
```

**Changelog Format (CHANGELOG.md):**
```markdown
# 7f-brand-system-generator Changelog

## [1.2.3] - 2026-03-15
### Fixed
- Validation error when brand colors array empty

## [1.2.0] - 2026-02-28
### Added
- Support for secondary brand colors (palette expansion)

## [1.1.0] - 2026-02-15
### Added
- Integration with OpenAI Whisper for voice input
```

### Version Compatibility Matrix (Phase 2)

**When skills depend on each other:**

| 7f-pptx-generator | Compatible 7f-brand-system-generator | Notes |
|-------------------|--------------------------------------|-------|
| v1.0.x | v1.0.x - v1.2.x | Major version must match |
| v1.1.x | v1.0.x - v1.2.x | Minor version backward compatible |
| v2.0.x | v2.0.x+ | Breaking change: new brand.json schema |

**Enforcement (Automated Check):**
```python
def check_version_compatibility(skill_a, skill_b):
    """Check if two skill versions are compatible"""
    a_major, a_minor, a_patch = parse_version(skill_a.version)
    b_major, b_minor, b_patch = parse_version(skill_b.version)

    # Major version must match (breaking changes)
    if a_major != b_major:
        raise IncompatibleVersionError(
            f"{skill_a.name} v{skill_a.version} incompatible with "
            f"{skill_b.name} v{skill_b.version}\n"
            f"Upgrade {skill_b.name} to v{a_major}.x.x"
        )
```

### Version Pinning (Production Stability)

**Development (MVP):** Latest version always used
- Pros: Automatic bug fixes, always up-to-date
- Cons: Breaking changes can surprise users

**Production (Phase 2+):** Pin major version
- Example: `7f-brand-system-generator@1.x` (any v1 version accepted)
- Pros: Stability, no surprise breaking changes
- Cons: Must manually upgrade for new features

**Configuration:**
```yaml
# .claude/config.yaml
skill_versions:
  7f-brand-system-generator: "1.x"  # Pin to v1
  7f-pptx-generator: "latest"       # Always use latest
  7f-dashboard-curator: "2.3.1"     # Pin to exact version
```
