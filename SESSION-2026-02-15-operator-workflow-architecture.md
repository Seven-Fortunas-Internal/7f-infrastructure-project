# Session: Operator Workflow Architecture & Style Guide Planning

**Date:** 2026-02-15
**Session Focus:** Addressing critical gaps in operator onboarding and organizational standards
**Status:** Planning & Analysis Phase
**Participants:** Jorge (VP AI-SecOps), Sally (UX Designer)

---

## Executive Summary

Two critical architectural questions emerged during seven-fortunas-brain deployment:

1. **Operator Workflow Gap:** How does an operator invoke AI agents from the second brain in VS Code? What's the repo setup workflow?
2. **Style Guide Completeness:** Do we need additional style guides beyond markdown best practices?

**Key Finding:** The second-brain architecture is well-designed but **operator onboarding is undefined**. This is a significant gap that could block adoption.

---

## Question 1: Operator Workflow & VS Code Integration

### The Problem Statement

**Jorge's Question:**
> "The plan is to create a sophisticated AI-dependent GitHub organization. My question is about how an operator is going to invoke any of the AI agents available in the second brain? Do we need to clone the entire organization GitHub so we can open a terminal and access these agents? How about accessing the speech-to-text service? I'm proposing we create a `repo-creation` BMAD workflow to help streamline this process for the operator. How does that work from my VS Code IDE?"

### Current State Analysis

**What Exists:**
- ✅ seven-fortunas-brain repository with BMAD library (submodule)
- ✅ Custom Seven Fortunas skills (in planning)
- ✅ `.claude/commands/` directory structure
- ✅ Speech-to-text integration (voice-input-guide.md)

**What's Missing:**
- ❌ **Operator onboarding documentation** - No guide for "how do I get started?"
- ❌ **Workspace setup guide** - No defined pattern for organizing local repos
- ❌ **Repo creation workflow** - Manual, error-prone process
- ❌ **VS Code integration guide** - No documentation on IDE setup
- ❌ **Speech-to-text setup instructions** - References exist but no setup guide

### Architectural Patterns Considered

#### Pattern A: Central Second Brain Clone
```bash
~/seven-fortunas-workspace/
├── seven-fortunas-brain/        # Clone ONCE (central reference)
├── 7f-infrastructure-project/   # Working repo 1
├── dashboards/                  # Working repo 2
└── my-new-project/              # Working repo 3
```

**Pros:**
- Single source of truth for second brain
- Easy updates (pull once, affects all projects)
- Consistent skill versions across projects

**Cons:**
- Path dependencies (brain must be at specific location)
- Manual skill copying/symlinking per project
- Not portable (team members need same directory structure)
- Breaks if brain repo moved

**Current Implicit Assumption:** This is what the architecture currently assumes but never documents.

---

#### Pattern B: Second Brain as Submodule
```bash
my-new-project/
├── _bmad/                  # BMAD library (submodule)
├── seven-fortunas-brain/   # Second brain (submodule)
└── .claude/
    └── CLAUDE.md           # References ../seven-fortunas-brain
```

**Pros:**
- Self-contained (repo includes all dependencies)
- Portable (clone once, everything works)
- Version pinning (each project can pin brain version)

**Cons:**
- Duplication across projects (brain cloned N times)
- Submodule update complexity (must update each project)
- Larger repo sizes

**Industry Examples:** Similar to how some projects include vendored dependencies.

---

#### Pattern C: BMAD Workflow Automation (RECOMMENDED)

**Concept:** Create `repo-creation` workflow that automates the entire setup process.

**Workflow: `bmad-7f-repo-create`**

**Invocation:**
```bash
# From seven-fortunas-brain repo (cloned locally)
/bmad-7f-repo-create
```

**Interactive Prompts:**
1. "Project name?" → `my-awesome-project`
2. "GitHub organization?" → `Seven-Fortunas-Internal` vs `Seven-Fortunas` (public)
3. "Project type?" → `infrastructure` | `app` | `documentation` | `dashboard`
4. "Include speech-to-text?" → `yes` | `no`
5. "Include custom skills?" → Select from checklist (brand-system-generator, documentation-generator, etc.)
6. "BMAD installation method?" → `per-project` | `symlink-to-brain`

**Workflow Execution Steps:**

**Step 1: GitHub Repo Creation**
- Use `gh` CLI to create repo in specified org
- Set repo description, visibility, default branch
- Initialize with README template
- Configure repo settings (Issues, Projects, Wiki, etc.)

**Step 2: Local Clone & Structure**
- Clone new repo to `~/seven-fortunas-workspace/`
- Create directory structure based on project type
- Generate `.gitignore` from template

**Step 3: BMAD Installation**
- Run `npx bmad-method install` in new repo
- Install BMAD library to `_bmad/` directory
- Create `.claude/commands/` directory

**Step 4: Seven Fortunas Skills Integration**
- Copy selected custom skills from brain to project
- OR symlink to central brain (based on user preference)
- Create skill stubs in `.claude/commands/`
- Test skill loading

**Step 5: Project CLAUDE.md Generation**
- Generate project-specific CLAUDE.md
- Include references to second brain
- Add project-specific context (type, purpose, team)
- Include skill usage examples

**Step 6: VS Code Workspace Configuration**
- Create `.vscode/settings.json`
- Configure extensions (Claude Code, Markdown, etc.)
- Set up tasks and launch configurations
- Generate `project.code-workspace` file

**Step 7: Speech-to-Text Setup (Optional)**
- Copy speech-to-text scripts from brain
- Configure API keys (prompt for input or use env vars)
- Test transcription service
- Add usage instructions to README

**Step 8: Commit & Push**
- Git add all generated files
- Create initial commit: "chore: initialize project with BMAD and Seven Fortunas skills"
- Push to remote
- Display success message with next steps

**Step 9: Open in VS Code**
- Offer to open project in VS Code
- If yes, run `code project.code-workspace`

**Output:**
```
✅ Repository created: github.com/Seven-Fortunas-Internal/my-awesome-project
✅ BMAD installed: 70+ workflows available
✅ Seven Fortunas skills: 5 custom skills configured
✅ VS Code workspace: my-awesome-project.code-workspace created
✅ Speech-to-text: Configured and tested

Next steps:
1. Review README.md for project-specific instructions
2. Explore available skills: /bmad-help
3. Start creating: /bmad-bmm-create-architecture (or other workflows)

Open in VS Code now? [Y/n]
```

---

### ⭐ ARCHITECTURAL DECISION: GitHub-Only + Sparse Checkout (APPROVED)

**Decision Date:** 2026-02-15
**Decision Maker:** Jorge (VP AI-SecOps)
**Status:** ✅ Approved - Replaces Obsidian-based approaches

#### Rationale

After evaluating multiple architectural patterns, the team chose **GitHub-only with sparse-checkout** for the following reasons:

**Key Concerns Addressed:**
1. ✅ **IP Protection** - Sparse checkout means operators only clone needed directories, not sensitive content
2. ✅ **Security** - GitHub Teams control access; no need to trust full clones
3. ✅ **Efficiency** - Small, on-demand clones instead of large brain repo
4. ✅ **No Cost** - GitHub already paid for; no Obsidian Publish subscription ($8-20/mo)
5. ✅ **Standard Tools** - VS Code, git, GitHub (no new dependencies)
6. ✅ **Offline Capable** - Sparse checkouts are local files (work offline)

**Why Not Obsidian?**
- Obsidian features (graph view, backlinks) are "nice-to-have" for knowledge AUTHORS
- Operators (knowledge CONSUMERS) don't need these features
- VS Code + GitHub web UI provides sufficient UX
- Can always add Obsidian later as optional tool for authors

#### Final Architecture: GitHub-Centric with Sparse Checkout

```
┌─────────────────────────────────────────────────────────────┐
│ LAYER 1: Skills Repository (Full Clone - Required)          │
├─────────────────────────────────────────────────────────────┤
│ Repo: seven-fortunas-skills                                 │
│ Size: ~50MB (lightweight)                                    │
│ Clone: Full clone by all operators                          │
│ Contains:                                                    │
│   ├── _bmad/           # BMAD library (70+ workflows)       │
│   ├── .claude/         # Command stubs                      │
│   └── README.md        # Getting started guide              │
│                                                              │
│ Distribution: git clone (standard)                          │
│ Updates: git pull (standard)                                │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ LAYER 2: Brain Repository (Sparse Checkout - On-Demand)     │
├─────────────────────────────────────────────────────────────┤
│ Repo: seven-fortunas-brain                                  │
│ Size: Variable (only clone needed directories)              │
│ Clone: Via BMAD workflows (automated sparse checkout)       │
│ Contains:                                                    │
│   ├── brand/              # Public content                  │
│   ├── culture/            # Public content                  │
│   ├── standards/          # Public content                  │
│   ├── best-practices/     # Internal content                │
│   └── domain-expertise/   # SENSITIVE (restricted access)   │
│                                                              │
│ Access Patterns:                                             │
│   • Web browsing: GitHub web UI (no clone needed)           │
│   • Fetch specific topics: /bmad-7f-fetch-knowledge         │
│   • Full authoring: Full clone (authors only)               │
│                                                              │
│ Cache Location: ~/.seven-fortunas-cache/                    │
│ Auto-expire: 7 days (configurable)                          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ LAYER 3: Project Knowledge Cache (Temporary Symlinks)       │
├─────────────────────────────────────────────────────────────┤
│ Location: ./knowledge/ (in project directory)               │
│ Content: Symlinks to cached brain directories               │
│ Managed by: BMAD knowledge workflows                        │
│ Lifecycle:                                                   │
│   1. Fetch: /bmad-7f-fetch-knowledge --topic security       │
│   2. Use: Claude Code reads from ./knowledge/security       │
│   3. Expire: Auto-removed after 7 days or manual cleanup    │
│                                                              │
│ Benefits:                                                    │
│   • No permanent brain clone                                 │
│   • Only fetch what's needed                                 │
│   • Automatic cleanup                                        │
│   • Claude Code integration seamless                         │
└─────────────────────────────────────────────────────────────┘
```

#### Operator Workflows (GitHub-Only)

**Workflow 1: Browse Knowledge (Zero Setup)**
```bash
# Open GitHub in browser - no clone needed
https://github.com/Seven-Fortunas-Internal/seven-fortunas-brain

# Navigate folders, read rendered markdown
# GitHub UI provides excellent markdown rendering
# Search within repo using GitHub search
```

**Workflow 2: Fetch Knowledge for Project (Sparse Checkout)**
```bash
# In project directory where you need knowledge
/bmad-7f-fetch-knowledge --topic security --expires 7d

# What happens behind the scenes:
# 1. Sparse clone to ~/.seven-fortunas-cache/security-{timestamp}
# 2. Symlink to ./knowledge/security
# 3. Update project CLAUDE.md with knowledge location
# 4. Claude Code can now read ./knowledge/security/*.md
```

**Workflow 3: List Cached Knowledge**
```bash
/bmad-7f-list-knowledge

# Output:
# Cached knowledge:
#   security (expires 2026-02-22)
#   brand (expires 2026-02-20)
# Total disk usage: 15 MB
```

**Workflow 4: Cleanup Expired Knowledge**
```bash
/bmad-7f-cleanup-knowledge

# Or auto-cleanup via cron:
# Removes caches older than expiration date
# Frees disk space
```

**Workflow 5: Author/Edit Knowledge (Full Clone - Authors Only)**
```bash
# Knowledge authors need full clone
git clone seven-fortunas-brain.git
cd seven-fortunas-brain

# Edit in VS Code
code .

# Optional: Open in Obsidian for better authoring UX
# (Obsidian is optional tool for authors, not required)

# Commit and push
git add -A
git commit -m "Update security standards"
git push origin main
```

#### Git Sparse-Checkout Implementation

**Technical Details:**
```bash
# BMAD workflow uses git sparse-checkout under the hood
git clone --filter=blob:none --sparse \
  github.com/Seven-Fortunas-Internal/seven-fortunas-brain.git \
  ~/.seven-fortunas-cache/security-{timestamp}

cd ~/.seven-fortunas-cache/security-{timestamp}

# Only download specific directories
git sparse-checkout set best-practices/security standards/security-standards.md

# Result: Only security-related files downloaded, not entire brain
# Disk usage: ~5MB instead of ~500MB
```

#### Claude Code Integration

**Project CLAUDE.md Pattern:**
```markdown
# Project: my-awesome-project

## Knowledge Cache

Knowledge is fetched on-demand from seven-fortunas-brain via sparse checkout.

Currently cached:
- ./knowledge/security (expires 2026-02-22)
  - Source: best-practices/security
  - Fetched: 2026-02-15 via /bmad-7f-fetch-knowledge

When you need knowledge:
1. Read from ./knowledge/ directory (already cached)
2. If not cached: Ask user to run /bmad-7f-fetch-knowledge --topic <topic>
3. Never clone full brain repository
```

#### Benefits of GitHub-Only Approach

| Benefit | Description | Impact |
|---------|-------------|--------|
| **No New Dependencies** | Uses GitHub, VS Code, git (already in stack) | Zero onboarding friction |
| **IP Protection** | Sparse checkout = only fetch approved directories | Sensitive content never leaves GitHub |
| **Zero Cost** | No Obsidian Publish subscription | $96-240/year saved |
| **Offline Capable** | Cached knowledge works offline | Reliable for remote work |
| **Standard Git Workflow** | Team already knows git | No training needed |
| **Scalable** | Brain can grow to GB size without affecting operators | Future-proof |
| **Auditable** | Git history shows who accessed what | Security compliance |
| **Flexible** | Can add Obsidian later as optional author tool | Not locked in |

---

### Required Documentation

#### Document 1: `docs/operator-getting-started.md`

**Purpose:** Comprehensive onboarding guide for new operators

**Contents:**
1. **Prerequisites**
   - VS Code installed with Claude Code extension
   - GitHub CLI (`gh`) authenticated
   - Node.js (for BMAD installation)
   - Seven Fortunas workspace directory structure

2. **First-Time Setup**
   - Clone seven-fortunas-brain to `~/seven-fortunas-workspace/`
   - Install BMAD: `npx bmad-method install`
   - Configure speech-to-text service (API keys)
   - Test BMAD skills: `/bmad-help`

3. **Daily Workflow**
   - How to create new project repos (`/bmad-7f-repo-create`)
   - How to invoke BMAD skills from VS Code
   - How to update second brain (git pull)
   - How to update BMAD library (npx bmad-method install)

4. **Speech-to-Text Usage**
   - How to record audio
   - How to transcribe to markdown
   - How to use with BMAD workflows
   - Troubleshooting common issues

5. **Troubleshooting**
   - "Skill not found" errors
   - BMAD installation issues
   - VS Code integration problems
   - GitHub authentication failures

**Estimated Size:** 400-600 lines (within limits for How-To Guide per markdown-best-practices.md)

---

#### Document 2: `docs/workspace-architecture.md`

**Purpose:** Explain the seven-fortunas workspace organization philosophy

**Contents:**
1. **Workspace Philosophy**
   - Why centralized workspace structure
   - Benefits for AI agent collaboration
   - Consistency across team members

2. **Directory Structure**
   ```
   ~/seven-fortunas-workspace/
   ├── seven-fortunas-brain/           # Second brain (knowledge base)
   ├── 7f-infrastructure-project/      # Infrastructure planning
   ├── dashboards/                     # 7F Lens dashboards
   └── [project-name]/                 # Your projects
   ```

3. **Second Brain Architecture**
   - What goes in the brain vs project repos
   - How projects reference the brain
   - Update strategy (when to pull latest)

4. **Project Repository Patterns**
   - Naming conventions
   - Directory structure standards
   - CLAUDE.md patterns
   - README templates

5. **Integration Points**
   - How VS Code workspaces work
   - How Claude Code finds skills
   - How speech-to-text integrates
   - How BMAD workflows discover files

**Estimated Size:** 300-500 lines (within ADR/Reference Doc limits)

---

#### Document 3: `docs/speech-to-text-setup.md`

**Purpose:** Step-by-step guide for configuring speech-to-text service

**Contents:**
1. **Service Overview**
   - What speech-to-text service does
   - When to use it (voice-first content creation)
   - Integration with BMAD workflows

2. **Installation**
   - Prerequisites (Python, API keys, etc.)
   - Install scripts from brain
   - Configure authentication
   - Test transcription

3. **Usage Patterns**
   - Recording audio (tools, formats)
   - Transcription command examples
   - Integration with brand-system-generator
   - Integration with documentation workflows

4. **Best Practices**
   - Audio quality tips
   - Effective speaking patterns for transcription
   - Reviewing/editing transcribed content
   - When NOT to use speech-to-text

5. **Troubleshooting**
   - API authentication errors
   - Audio format issues
   - Transcription quality problems
   - Performance optimization

**Estimated Size:** 250-400 lines (How-To Guide size)

---

### Recommended BMAD Workflows for Implementation

#### Task 1: Create Operator Documentation Suite

**Workflow:** `bmad-bmm-create-documentation` (use for each doc)
**Agent:** Technical Writer
**Module:** BMM (Business Method)
**Input:** This session doc + existing voice-input-guide.md
**Output:** 3 comprehensive operator guides
**Estimated Effort:** 2-3 hours per document (6-9 hours total)

**Steps:**
1. `/bmad-bmm-create-documentation` for operator-getting-started.md
2. `/bmad-bmm-create-documentation` for workspace-architecture.md
3. `/bmad-bmm-create-documentation` for speech-to-text-setup.md
4. Review and refine with Jorge's input
5. Deploy to seven-fortunas-brain/docs/

---

#### Task 2: Create `repo-creation` Workflow

**Workflow:** `bmad-bmb-workflow-create-workflow`
**Agent:** BMAD Builder
**Module:** BMB (Builder)
**Input:** Workflow specification (from this session doc)
**Output:** Complete `bmad-7f-repo-create` workflow
**Estimated Effort:** 8-12 hours (complex workflow with many steps)

**Complexity Assessment:**
- **High Complexity** - This workflow has 9 distinct steps
- **External Dependencies** - GitHub API, gh CLI, VS Code, speech-to-text service
- **User Input Required** - Multiple interactive prompts
- **File Generation** - Creates many files (CLAUDE.md, workspace config, scripts)
- **Error Handling** - Must handle GitHub failures, permission issues, etc.

**Recommendation:** **Plan this carefully as multi-phase project**

**Phase 1: MVP Workflow (Simplified)**
- Create GitHub repo (gh CLI)
- Clone locally
- Install BMAD
- Generate basic CLAUDE.md
- Test with single project type

**Phase 2: Add Skills Integration**
- Copy/symlink Seven Fortunas skills
- Create skill stubs
- Test skill loading
- Add validation step

**Phase 3: VS Code Integration**
- Generate workspace files
- Configure settings
- Add tasks/launch configs
- Auto-open in VS Code

**Phase 4: Speech-to-Text Integration**
- Copy speech-to-text scripts
- Configure API keys
- Test transcription
- Add usage docs

**Steps to Create:**
1. `/bmad-bmb-workflow-create-workflow` - Start workflow creation process
2. Follow BMAD workflow-create-workflow steps (Discovery → Classification → Requirements → Tools → Design → Foundation → Build)
3. Create workflow.md with all metadata
4. Build 9 step files (step-01-init through step-09-open-vscode)
5. Add validation steps
6. Create templates (CLAUDE.md template, workspace template, etc.)
7. Test workflow end-to-end
8. Deploy to seven-fortunas-brain

**Critical Success Factors:**
- Must use BMAD `workflow-create-workflow` process (NOT manual creation)
- Must validate with `bmad-bmb-validate-workflow`
- Must test with real project creation scenarios
- Must handle errors gracefully (network failures, auth issues, etc.)

---

#### Task 3: Update seven-fortunas-brain README

**Workflow:** Manual edit (small change)
**Agent:** Sally (UX Designer) or Jorge
**Module:** N/A
**Input:** New operator docs created above
**Output:** Updated README with "Getting Started" section
**Estimated Effort:** 15 minutes

**Changes:**
- Add "Getting Started" section with links to new docs
- Update "For Humans" section with operator workflow steps
- Add "Creating New Repos" section referencing `/bmad-7f-repo-create`

---

## Question 2: Style Guide Completeness

### Current State

**Style Guides That Exist:**
- ✅ **Markdown/Documentation Style Guide** - `standards/markdown-best-practices.md` (1,662 lines)
  - Size limits by document type
  - Diagram guidelines (Mermaid, images, ASCII art)
  - Effective line counting system
  - Progressive disclosure patterns
  - YAML frontmatter standards
  - Deployed to seven-fortunas-brain

**Style Guides Referenced But Not Created:**

| Guide | Location | Status | Mentioned In |
|-------|----------|--------|--------------|
| **Brand/Voice Style Guide** | `brand/brand-system.md` | ❌ Not created | README.md, PRD, Architecture |
| **Code Style Guide** | `standards/code-style-guide.md` | ❌ Not created | standards/README.md |
| **Security Standards** | `standards/security-standards.md` | ❌ Not created | standards/README.md |

### Analysis: What Style Guides Are Needed?

#### Guide 1: Brand/Voice Style Guide

**Purpose:** Define Seven Fortunas brand identity, voice, tone, messaging

**Current Plan:** Generated by `7f-brand-system-generator` skill (custom workflow)

**Contents (per PRD/Architecture):**
- Corporate colors (primary, secondary, accent)
- Typography (heading font, body font, sizes)
- Logo assets (SVG, PNG, usage guidelines)
- Brand voice (formal vs casual, technical vs friendly)
- Messaging framework (taglines, value propositions)
- Visual examples (applied to GitHub org, website)

**Status:**
- Skill design documented in Architecture doc
- Skill not yet built (pending workflow creation)
- Brand directory doesn't exist yet in seven-fortunas-brain

**Dependencies:**
- Henry (CEO) must run the generator skill to create brand content
- Workflow must be built first (custom Seven Fortunas skill)

**Recommendation:** This is a **separate project** - create brand-system-generator workflow, then run it.

---

#### Guide 2: Code Style Guide

**Purpose:** Define coding standards across all Seven Fortunas repositories

**Scope:**
1. **Language-Specific Conventions**
   - Python (PEP 8, type hints, docstrings)
   - JavaScript/TypeScript (ESLint, Prettier, naming)
   - Shell scripts (bash best practices, shellcheck)
   - YAML/JSON (formatting, validation)

2. **Repository Standards**
   - Directory structure patterns
   - File naming conventions
   - Module organization
   - Import/export patterns

3. **Documentation Standards**
   - Inline comments (when/how)
   - Docstrings/JSDoc (required fields)
   - README sections (consistent structure)
   - API documentation (OpenAPI/Swagger)

4. **Testing Standards**
   - Test file naming (*.test.py, *.spec.ts)
   - Test organization (unit, integration, e2e)
   - Coverage requirements (80% minimum)
   - Mocking patterns

5. **Git Commit Standards**
   - Conventional commits (feat:, fix:, docs:, etc.)
   - Commit message format
   - PR title conventions
   - Co-authored-by attribution (AI collaboration)

6. **Linting & Formatting**
   - Pre-commit hooks required
   - Linter configurations (.eslintrc, .flake8)
   - Formatter configurations (.prettierrc, black)
   - CI/CD integration (fail on lint errors)

7. **Security Patterns**
   - Secret management (environment variables, never hardcode)
   - Input validation patterns
   - Error handling (don't expose stack traces)
   - Dependency management (regular updates, vulnerability scanning)

**Estimated Size:** 800-1,200 lines (Specifications size limit per markdown-best-practices.md)

**Format:** Similar to Airbnb JavaScript Style Guide or Google Python Style Guide

---

#### Guide 3: Security Standards

**Purpose:** Security requirements, compliance standards, audit procedures

**Scope:**
1. **Access Control**
   - GitHub organization security settings
   - Repository access patterns (least privilege)
   - Branch protection rules (main/master protected)
   - 2FA requirements (mandatory for all members)

2. **Secret Management**
   - Never commit secrets to repos
   - Use GitHub Secrets for CI/CD
   - Environment variable patterns
   - Key rotation schedules

3. **Dependency Security**
   - Dependabot enabled (all repos)
   - Vulnerability scanning (GitHub Advanced Security)
   - Dependency approval process (review before merge)
   - License compliance (approved OSS licenses)

4. **Code Review Requirements**
   - Minimum reviewers (1-2 depending on repo)
   - Security review checklist
   - Required CI checks (tests, linting, security scans)
   - No direct commits to main/master

5. **Compliance Standards**
   - SOC 2 readiness
   - GDPR considerations (data handling)
   - Security incident response process
   - Audit logging requirements

6. **Pre-commit Hooks**
   - Secret scanning (detect-secrets, truffleHog)
   - Linting enforcement
   - Test execution (fast tests only)
   - Commit message validation

7. **CI/CD Security**
   - Pipeline security (no secrets in logs)
   - Container scanning (if using Docker)
   - SAST/DAST integration
   - Deployment approval gates

**Estimated Size:** 600-1,000 lines (Specifications size)

**Format:** Similar to OWASP guidelines or NIST frameworks

---

### Style Guide Priority & Sequencing

| Priority | Guide | Urgency | Blocker For | Owner |
|----------|-------|---------|-------------|-------|
| **P0** | Markdown/Documentation | ✅ DONE | All documentation | Sally (complete) |
| **P1** | Code Style Guide | **HIGH** | Engineering projects | Buck (VP Engineering) |
| **P2** | Security Standards | **HIGH** | Infrastructure MVP | Buck + Jorge |
| **P3** | Brand/Voice Style Guide | **MEDIUM** | Public-facing content | Henry (CEO) |

**Rationale:**
- **Code Style Guide (P1):** Buck needs this for engineering project delivery (his primary responsibility per division of labor)
- **Security Standards (P2):** Required for infrastructure MVP, Buck's security automation goals
- **Brand/Voice (P3):** Important for marketing/fundraising but not blocking technical work

---

### Recommended BMAD Workflows for Style Guides

#### Task 4: Create Code Style Guide

**Workflow:** `bmad-bmm-create-standards-document`
**Alternative:** `bmad-bmm-create-documentation`
**Agent:** Technical Writer (with Buck as SME reviewer)
**Module:** BMM
**Input:** Industry standards (Airbnb JS, Google Python, etc.) + Seven Fortunas context
**Output:** `standards/code-style-guide.md`
**Estimated Effort:** 4-6 hours

**Steps:**
1. Research industry standards (PEP 8, Airbnb, Google)
2. Adapt to Seven Fortunas tech stack (languages used)
3. Document Seven Fortunas-specific conventions
4. Add examples (good vs bad code)
5. Include linter/formatter configurations
6. Buck reviews and approves
7. Deploy to seven-fortunas-brain

**Validation:**
- Apply to existing code (lint 7f-infrastructure-project)
- Verify linter configs work as documented
- Test pre-commit hooks

---

#### Task 5: Create Security Standards

**Workflow:** `bmad-bmm-create-standards-document`
**Agent:** Security Architect (with Buck + Jorge as SME reviewers)
**Module:** BMM
**Input:** OWASP guidelines, SOC 2 requirements, seven-fortunas security posture
**Output:** `standards/security-standards.md`
**Estimated Effort:** 6-8 hours

**Steps:**
1. Research security frameworks (OWASP, NIST, SOC 2)
2. Document Seven Fortunas security requirements
3. Create security checklist (pre-commit, code review)
4. Add compliance requirements
5. Include incident response procedures
6. Buck + Jorge review and approve
7. Deploy to seven-fortunas-brain

**Validation:**
- Test pre-commit hooks against requirements
- Verify GitHub security settings
- Audit existing repos for compliance

---

#### Task 6: Create Brand/Voice Style Guide

**Workflow:** `bmad-7f-brand-system-generator` (custom workflow, not yet created)
**Agent:** Brand Designer (Sally) with Henry (CEO) input
**Module:** Custom Seven Fortunas Skill
**Input:** Henry's vision (voice input), company values, target audience
**Output:** `brand/brand-system.md` + `brand/brand.json` + `brand/assets/`
**Estimated Effort:** 8-12 hours (includes workflow creation + execution)

**Prerequisites:**
- Create `brand-system-generator` workflow first (separate project)
- Henry must allocate time for voice input session (30-60 min)

**Steps:**
1. Create `bmad-7f-brand-system-generator` workflow (use `workflow-create-workflow`)
2. Henry runs workflow (interactive questionnaire)
3. AI generates brand documentation and assets
4. Henry reviews and refines (20% human refinement)
5. Deploy to seven-fortunas-brain
6. Apply branding to GitHub org, website, templates

**Validation:**
- Visual consistency check (GitHub org, website)
- Team feedback (does brand feel authentic?)
- Investor feedback (professional and polished?)

---

## Consolidated Task List

### Immediate Priority (P0) - Operator Onboarding

| Task | Description | BMAD Workflow | Owner | Effort | Dependencies |
|------|-------------|---------------|-------|--------|--------------|
| **1.1** | Create `operator-getting-started.md` | `bmad-bmm-create-documentation` | Sally/Jorge | 2-3h | None |
| **1.2** | Create `workspace-architecture.md` | `bmad-bmm-create-documentation` | Sally/Jorge | 2-3h | None |
| **1.3** | Create `speech-to-text-setup.md` | `bmad-bmm-create-documentation` | Sally/Jorge | 2-3h | voice-input-guide.md |
| **1.4** | Update seven-fortunas-brain README | Manual edit | Sally/Jorge | 15min | Tasks 1.1-1.3 |

**Total Effort:** 6-9 hours
**Deliverable:** Complete operator onboarding documentation suite

---

### High Priority (P1) - Repo Creation Workflow

| Task | Description | BMAD Workflow | Owner | Effort | Dependencies |
|------|-------------|---------------|-------|--------|--------------|
| **2.1** | Design `repo-creation` workflow spec | Manual (planning) | Jorge + Sally | 2-3h | Task 1.1-1.4 |
| **2.2** | Create workflow (Phase 1: MVP) | `bmad-bmb-workflow-create-workflow` | Jorge | 6-8h | Task 2.1 |
| **2.3** | Test workflow with real project | Manual testing | Jorge | 2h | Task 2.2 |
| **2.4** | Create workflow (Phase 2: Skills) | Continue from 2.2 | Jorge | 4-6h | Task 2.3 |
| **2.5** | Create workflow (Phase 3: VS Code) | Continue from 2.2 | Jorge | 3-4h | Task 2.4 |
| **2.6** | Create workflow (Phase 4: Speech) | Continue from 2.2 | Jorge | 2-3h | Task 2.5 |
| **2.7** | Validate with `validate-workflow` | `bmad-bmb-validate-workflow` | Jorge | 30min | Task 2.6 |
| **2.8** | Deploy to seven-fortunas-brain | Git commit + push | Jorge | 15min | Task 2.7 |

**Total Effort:** 20-27 hours
**Deliverable:** Production-ready `bmad-7f-repo-create` workflow

**Recommendation:** This is an **extensive undertaking**. Consider breaking into sprints:
- **Sprint 1:** Operator docs (Tasks 1.1-1.4) - 1 day
- **Sprint 2:** Workflow MVP (Tasks 2.1-2.3) - 2 days
- **Sprint 3:** Full workflow (Tasks 2.4-2.8) - 2-3 days

---

### High Priority (P1) - Knowledge Sparse-Checkout Workflows

**NEW: Required for GitHub-only architecture**

| Task | Description | BMAD Workflow | Owner | Effort | Dependencies |
|------|-------------|---------------|-------|--------|--------------|
| **2.9** | Design `fetch-knowledge` workflow spec | Manual (planning) | Jorge | 1-2h | Task 2.1 |
| **2.10** | Create `bmad-7f-fetch-knowledge` | `bmad-bmb-workflow-create-workflow` | Jorge | 4-6h | Task 2.9 |
| **2.11** | Create `bmad-7f-list-knowledge` | `bmad-bmb-workflow-create-workflow` | Jorge | 2-3h | Task 2.10 |
| **2.12** | Create `bmad-7f-cleanup-knowledge` | `bmad-bmb-workflow-create-workflow` | Jorge | 2-3h | Task 2.10 |
| **2.13** | Test sparse checkout workflows | Manual testing | Jorge | 2h | Task 2.12 |
| **2.14** | Deploy knowledge workflows | Git commit + push | Jorge | 15min | Task 2.13 |

**Total Effort:** 11-16 hours
**Deliverable:** 3 knowledge management workflows

**Workflow Specs:**

**`bmad-7f-fetch-knowledge`**
- Interactive prompts: Topic, expiration days
- Sparse clone to ~/.seven-fortunas-cache/
- Symlink to ./knowledge/{topic}
- Update project CLAUDE.md
- Log fetch metadata (timestamp, source, expiration)

**`bmad-7f-list-knowledge`**
- Scan ./knowledge/ directory
- Read metadata from symlinks
- Display: Topic, size, expiration date, source repo
- Show total cache disk usage

**`bmad-7f-cleanup-knowledge`**
- Find expired caches (compare timestamp to expiration)
- Prompt for confirmation before deletion
- Remove cache directories
- Remove symlinks from ./knowledge/
- Report freed disk space

---

### High Priority (P1) - Code Style Guide

| Task | Description | BMAD Workflow | Owner | Effort | Dependencies |
|------|-------------|---------------|-------|--------|--------------|
| **3.1** | Research industry standards | Manual research | Buck/Jorge | 1-2h | None |
| **3.2** | Create code-style-guide.md draft | `bmad-bmm-create-documentation` | Jorge | 3-4h | Task 3.1 |
| **3.3** | Buck reviews and provides input | Manual review | Buck | 1h | Task 3.2 |
| **3.4** | Refine based on Buck's feedback | Manual edit | Jorge | 1h | Task 3.3 |
| **3.5** | Deploy to seven-fortunas-brain | Git commit + push | Jorge | 15min | Task 3.4 |

**Total Effort:** 6-8 hours
**Deliverable:** `standards/code-style-guide.md`

---

### High Priority (P1) - Security Standards

| Task | Description | BMAD Workflow | Owner | Effort | Dependencies |
|------|-------------|---------------|-------|--------|--------------|
| **4.1** | Research security frameworks | Manual research | Buck/Jorge | 2h | None |
| **4.2** | Create security-standards.md draft | `bmad-bmm-create-documentation` | Jorge | 4-6h | Task 4.1 |
| **4.3** | Buck + Jorge review together | Manual review | Buck + Jorge | 1-2h | Task 4.2 |
| **4.4** | Refine based on review | Manual edit | Jorge | 1h | Task 4.3 |
| **4.5** | Deploy to seven-fortunas-brain | Git commit + push | Jorge | 15min | Task 4.4 |

**Total Effort:** 8-11 hours
**Deliverable:** `standards/security-standards.md`

---

### Medium Priority (P2) - Brand Style Guide

| Task | Description | BMAD Workflow | Owner | Effort | Dependencies |
|------|-------------|---------------|-------|--------|--------------|
| **5.1** | Design brand-system-generator workflow | Manual planning | Sally + Jorge | 2-3h | None |
| **5.2** | Create brand-system-generator workflow | `bmad-bmb-workflow-create-workflow` | Jorge | 6-8h | Task 5.1 |
| **5.3** | Test workflow | Manual testing | Sally | 1h | Task 5.2 |
| **5.4** | Henry runs brand-system-generator | `/bmad-7f-brand-system-generator` | Henry | 1h | Task 5.3 |
| **5.5** | Henry refines brand content (20%) | Manual edit | Henry | 1-2h | Task 5.4 |
| **5.6** | Deploy to seven-fortunas-brain | Git commit + push | Henry/Jorge | 15min | Task 5.5 |

**Total Effort:** 11-15 hours
**Deliverable:** `brand/brand-system.md` + `brand/brand.json` + `brand/assets/`

---

## Recommended Sequencing

### Phase 1: Documentation Foundation (Week 1)
**Goal:** Unblock operator onboarding

- [ ] Task 1.1: operator-getting-started.md (2-3h)
- [ ] Task 1.2: workspace-architecture.md (2-3h)
- [ ] Task 1.3: speech-to-text-setup.md (2-3h)
- [ ] Task 1.4: Update README (15min)

**Total:** 6-9 hours
**Output:** Operators can get started without Jorge's help

---

### Phase 2: Standards Suite (Week 2)
**Goal:** Establish engineering standards

- [ ] Task 3.1-3.5: Code style guide (6-8h)
- [ ] Task 4.1-4.5: Security standards (8-11h)

**Total:** 14-19 hours
**Output:** Buck can enforce standards on engineering projects

---

### Phase 3: Workflow Automation (Weeks 3-4)
**Goal:** Automate repo creation

- [ ] Task 2.1: Design repo-creation workflow (2-3h)
- [ ] Task 2.2: MVP workflow (6-8h)
- [ ] Task 2.3: Test MVP (2h)
- [ ] Task 2.4-2.8: Complete workflow (9-13h)

**Total:** 19-26 hours
**Output:** One-command repo creation with full setup

---

### Phase 4: Brand Identity (Week 5)
**Goal:** Professional brand presence

- [ ] Task 5.1: Design brand-system-generator (2-3h)
- [ ] Task 5.2: Create workflow (6-8h)
- [ ] Task 5.3: Test (1h)
- [ ] Task 5.4-5.6: Henry creates brand (2-3h)

**Total:** 11-15 hours
**Output:** Complete Seven Fortunas brand identity

---

## Critical Decisions Required

### Decision 1: Workspace Architecture Pattern ✅ RESOLVED

**Decision Date:** 2026-02-15
**Decision Maker:** Jorge (VP AI-SecOps)
**Status:** ✅ APPROVED

**Options Evaluated:**
- ~~**A. Central Brain Clone**~~ (simple, path-dependent)
- ~~**B. Brain as Submodule**~~ (portable, duplication)
- ~~**C. Obsidian Publish**~~ (web-based, $8-20/mo)
- **D. GitHub-Only + Sparse Checkout** ✅ CHOSEN

**Final Decision:** **GitHub-Only with Sparse Checkout Workflows**

**Rationale:**
- IP Protection: Operators only clone needed directories via sparse checkout
- Security: GitHub Teams control access; no need to trust full clones
- Efficiency: Small, on-demand clones (5-50MB) instead of large brain repo (500MB+)
- Zero Cost: GitHub already paid for; no Obsidian Publish subscription
- Standard Tools: VS Code, git, GitHub (no new dependencies)
- Offline Capable: Sparse checkouts are local files

**Implementation:**
- Skills repo: Full clone (required, lightweight ~50MB)
- Brain repo: Sparse checkout via BMAD workflows (on-demand)
- Knowledge cache: ~/.seven-fortunas-cache/ (temporary, auto-expire)
- BMAD workflows: `fetch-knowledge`, `list-knowledge`, `cleanup-knowledge`

See "ARCHITECTURAL DECISION: GitHub-Only + Sparse Checkout" section above for full details.

---

### Decision 2: Repo Creation Workflow Phasing

**Options:**
- **A. Build full workflow upfront** (20-27 hours, delayed delivery)
- **B. Phased approach** (MVP first, iterate)
- **C. Manual process documented** (faster, error-prone)

**Recommendation:** **Option B (Phased)** - Deliver MVP quickly, iterate based on real usage.

**Decision Maker:** Jorge
**Timeline:** Before Task 2.1 (workflow design)

---

### Decision 3: Style Guide Ownership

**Question:** Who owns each style guide long-term?

**Recommendation:**
- **Code Style Guide:** Buck (VP Engineering) - aligns with engineering responsibility
- **Security Standards:** Buck + Jorge (shared) - Buck owns application security, Jorge owns infrastructure security
- **Brand/Voice Guide:** Henry (CEO) - brand identity is CEO purview
- **Markdown/Documentation:** Sally (UX Designer) - documentation UX

**Decision Maker:** Jorge + Henry
**Timeline:** Before style guide creation tasks

---

### Decision 4: Speech-to-Text Priority

**Question:** Is speech-to-text critical for MVP or can it be Phase 2?

**Context:**
- Voice-input-guide.md exists (basic instructions)
- Henry wants voice-first content creation (PRD requirement)
- Adds complexity to repo-creation workflow

**Options:**
- **A. Include in operator docs (Phase 1)** - Document existing capability
- **B. Include in repo-creation MVP (Phase 3)** - Automate setup
- **C. Defer to post-MVP** - Focus on core workflows first

**Recommendation:** **Option A** - Document in operator-getting-started.md, automate in repo-creation Phase 4 (optional feature).

**Decision Maker:** Jorge
**Timeline:** Before Task 1.1

---

## Risk Assessment

### Risk 1: Repo Creation Workflow Complexity (HIGH)

**Risk:** Workflow has 9 steps, multiple external dependencies (GitHub API, gh CLI, VS Code), and complex error handling.

**Impact:**
- Development time overruns (20-27h → 40h+)
- Brittle workflow (breaks on edge cases)
- User frustration (workflow fails mid-execution)

**Mitigation:**
- Use phased approach (MVP → iterate)
- Extensive testing with real scenarios
- Clear error messages and recovery instructions
- Fallback to manual process if workflow fails

**Owner:** Jorge
**Status:** Open (need decision on phasing)

---

### Risk 2: Operator Documentation Maintenance (MEDIUM)

**Risk:** Operator docs become stale as architecture evolves.

**Impact:**
- New operators get outdated instructions
- Workflows change but docs don't
- Support burden (Jorge answers same questions)

**Mitigation:**
- Version docs with date stamps
- Review quarterly (or after major changes)
- Add "Last Updated" and "Next Review" frontmatter
- Include "Report Issues" link in each doc

**Owner:** Sally (documentation owner)
**Status:** Design this into Task 1.1-1.3

---

### Risk 3: Style Guide Divergence (MEDIUM)

**Risk:** Code style guide created but not enforced (developers ignore it).

**Impact:**
- Inconsistent code quality
- Code review debates ("my style vs yours")
- Security standards not followed

**Mitigation:**
- Pre-commit hooks enforce standards automatically
- CI/CD fails if linting errors
- Code review checklist references standards
- Regular audits (quarterly)

**Owner:** Buck (VP Engineering)
**Status:** Design enforcement into Task 3.x (code style guide)

---

### Risk 4: BMAD Workflow Validation Failures (LOW-MEDIUM)

**Risk:** Custom workflows fail BMAD validation (file size >250 lines, missing frontmatter, etc.).

**Impact:**
- Re-work required (delays)
- Claude Code can't load workflows
- User frustration

**Mitigation:**
- Always use `workflow-create-workflow` (never manual)
- Validate early and often (`bmad-bmb-validate-workflow`)
- Keep step files <200 lines (per markdown-best-practices.md)
- Test skill loading before deployment

**Owner:** Jorge
**Status:** Apply lessons from `check-autonomous-implementation-readiness` workflow (5 files exceeded 250 lines but still functional)

---

## Next Steps

### Immediate Actions (This Week)

1. ✅ **Jorge Decision:** Choose workspace architecture pattern (Decision 1) - **RESOLVED: GitHub-Only + Sparse Checkout**
2. **Jorge Decision:** Approve phased approach for repo-creation workflow (Decision 2) - Pending
3. **Start Task 1.1:** Create `operator-getting-started.md` using `/bmad-bmm-create-documentation`

### Planning Actions (Next Week)

1. **Review this session doc** with Henry, Patrick, Buck (get buy-in)
2. **Assign owners** for style guides (Decision 3)
3. **Prioritize**: Operator docs vs Standards vs Workflow automation

### Long-Term Actions (Month 1-2)

1. **Execute Phase 1:** Documentation foundation (Week 1)
2. **Execute Phase 2:** Standards suite (Week 2)
3. **Execute Phase 3:** Workflow automation (Weeks 3-4)
4. **Execute Phase 4:** Brand identity (Week 5)

---

## Appendix: BMAD Workflow Reference

### Workflows Recommended in This Document

| Workflow Name | Module | Purpose | Invocation |
|---------------|--------|---------|------------|
| `create-documentation` | BMM | Create comprehensive docs | `/bmad-bmm-create-documentation` |
| `workflow-create-workflow` | BMB | Create new BMAD workflows | `/bmad-bmb-workflow-create-workflow` |
| `validate-workflow` | BMB | Validate workflow structure | `/bmad-bmb-validate-workflow` |
| `create-standards-document` | BMM | Create standards/policy docs | `/bmad-bmm-create-standards-document` |

### Custom Seven Fortunas Workflows (To Be Created)

| Workflow Name | Purpose | Status | Priority |
|---------------|---------|--------|----------|
| `7f-repo-create` | Automate repo setup | Not started | **P1** |
| `7f-fetch-knowledge` | Sparse checkout brain content | Not started | **P1** |
| `7f-list-knowledge` | Show cached knowledge | Not started | **P1** |
| `7f-cleanup-knowledge` | Remove expired caches | Not started | **P1** |
| `7f-brand-system-generator` | Generate brand identity | Not started | P2 |

---

## Document Metadata

**Version:** 1.1
**Created:** 2026-02-15
**Last Updated:** 2026-02-15 (GitHub-only decision added)
**Author:** Sally (UX Designer) with Jorge (VP AI-SecOps)
**Status:** Planning Complete - Ready for Implementation
**Next Review:** After Phase 1 execution (operator docs complete)

**Related Documents:**
- [markdown-best-practices.md](../seven-fortunas-workspace/seven-fortunas-brain/standards/markdown-best-practices.md)
- [PRD](../_bmad-output/planning-artifacts/prd/prd.md)
- [Architecture](../_bmad-output/planning-artifacts/architecture-7F_github-2026-02-10.md)
- [MEMORY.md](../.claude/projects/-home-ladmin-dev-GDF-7F-github/memory/MEMORY.md)

**Session Output:**
- ✅ Architecture analysis complete (5 patterns evaluated including Obsidian options)
- ✅ **GitHub-only + sparse checkout architecture APPROVED**
- ✅ Task breakdown created (26 tasks across 4 phases, including 3 sparse-checkout workflows)
- ✅ BMAD workflow recommendations provided
- ✅ Risk assessment documented
- ✅ Decision 1 RESOLVED: GitHub-only with sparse checkout
- ⏭️ Decisions 2-4 pending review

**Key Decisions:**
- ✅ **Architecture:** GitHub-only with sparse checkout (no Obsidian required for operators)
- ✅ **Skills:** Separate repo (seven-fortunas-skills) - full clone
- ✅ **Knowledge:** On-demand via BMAD workflows (sparse checkout)
- ✅ **Cost:** $0 (GitHub only, no Obsidian Publish subscription)

---

**Total Estimated Effort (All Phases):** 61-84 hours (updated with sparse-checkout workflows)
**Timeline:** 4-5 weeks (if executed sequentially)
**Parallelization Opportunity:** Phase 1 + Phase 2 can overlap (different owners)

**Critical Path:** Operator docs (Phase 1) → Sparse-checkout workflows (Phase 1.5) → Repo creation workflow (Phase 3)

**Critical Path:** Operator documentation (Phase 1) → Repo creation workflow (Phase 3) → Production-ready onboarding
