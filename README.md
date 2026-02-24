# Seven Fortunas Infrastructure Project

AI-native enterprise infrastructure with autonomous implementation, multi-domain dashboards, and SOC 2 compliance.

---

## Overview

Seven Fortunas is an AI-first infrastructure project leveraging autonomous agents, BMAD methodology, and Claude Code to build secure, compliant, scalable systems.

**Key Innovations:**
- **Autonomous Implementation:** Agent-driven feature development (25/42 features complete)
- **Multi-Domain Dashboards:** AI, Fintech, EduTech, Security intelligence
- **BMAD Integration:** 80+ business method workflows
- **SOC 2 Ready:** Automated compliance evidence collection
- **Self-Documenting:** README at every directory level

---

## Directory Structure

```
/home/ladmin/dev/GDF/7F_github/
├── README.md                    # This file
├── CLAUDE.md                    # Agent instructions for this workspace
├── _bmad/                       # BMAD library (70+ workflows)
│   ├── bmm/                     # Business Method workflows
│   ├── bmb/                     # Builder workflows
│   ├── cis/                     # Creative Intelligence workflows
│   ├── tea/                     # Testing workflows
│   └── core/                    # Core framework
├── _bmad-output/                # Generated planning artifacts
│   ├── planning-artifacts/      # Product Brief, Architecture, PRD, etc.
│   │   ├── product-brief-7F_github-2026-02-10.md
│   │   ├── architecture-7F_github-2026-02-10.md
│   │   ├── bmad-skill-mapping-2026-02-10.md
│   │   ├── action-plan-mvp-2026-02-10.md
│   │   ├── autonomous-workflow-guide-7f-infrastructure.md
│   │   └── prd.md (in progress)
│   └── implementation-artifacts/ # (future: generated during implementation)
└── .claude/                     # Claude Code configuration
    └── commands/                # BMAD skill symlinks
        └── bmad-*.md            # 70+ skill invocation stubs
```

---

## Project Structure

```
7F_github/
├── .claude/                    # Claude Code configuration
│   ├── commands/               # Skills (80+ BMAD + custom)
│   └── README.md
├── .github/workflows/          # GitHub Actions automation
├── _bmad/                      # BMAD library (80+ workflows)
│   ├── bmb/                    # Builder workflows
│   ├── bmm/                    # Business Method workflows
│   ├── cis/                    # Creative Intelligence workflows
│   └── tea/                    # Test Architecture workflows
├── compliance/                 # SOC 2 evidence collection
│   ├── evidence/               # Daily evidence (YYYY-MM-DD)
│   └── README.md
├── dashboards/                 # Multi-domain dashboards
│   ├── ai/                     # AI Advancements Dashboard
│   ├── fintech/                # Fintech Trends Dashboard
│   ├── edutech/                # EduTech Dashboard
│   ├── security/               # Security Intelligence Dashboard
│   ├── compliance/             # SOC 2 Compliance Dashboard
│   └── README.md
├── docs/                       # Documentation
│   ├── soc2-control-mapping.md
│   ├── readme-templates.md
│   └── README.md
├── scripts/                    # Automation scripts
│   ├── setup/                  # Organization setup
│   ├── dashboards/             # Dashboard management
│   ├── compliance/             # SOC 2 evidence collection
│   └── README.md
├── app_spec.txt                # Feature specification
├── feature_list.json           # Implementation tracking
├── autonomous_build_log.md     # Detailed implementation log
├── claude-progress.txt         # Progress metadata
└── README.md                   # This file
```

---

## Navigation

Quick links to key areas:

| Area | Path | Description |
|------|------|-------------|
| **Dashboards** | [dashboards/](dashboards/) | Multi-domain intelligence dashboards |
| **Scripts** | [scripts/](scripts/) | Automation scripts |
| **Docs** | [docs/](docs/) | Documentation |
| **Compliance** | [compliance/](compliance/) | SOC 2 evidence |
| **BMAD** | [_bmad/](_bmad/) | Business Method Architecture (80+ workflows) |
| **Skills** | [.claude/commands/](.claude/commands/) | Claude Code skills |

---

## Purpose & Workflow

### 1. Planning Phase (Current)

**What happens here:**
- Create planning artifacts using BMAD workflows
- Product Brief, Architecture, PRD generation
- Strategy documents and analysis
- All artifacts saved to `_bmad-output/planning-artifacts/`

**Outputs:**
- Product Brief ✅
- Architecture Document ✅
- BMAD Skill Mapping ✅
- Action Plan ✅
- Autonomous Workflow Guide ✅
- PRD (in progress) 🔄

### 2. Deployment Phase (Next)

**What happens:**
- Planning artifacts are copied to GitHub repositories
- Autonomous agent scripts are set up
- Infrastructure is built using autonomous agent
- Results are deployed to production GitHub orgs

**Flow:**
```
Local Development (here)
    ↓
Planning Artifacts Generated
    ↓
Copied to GitHub Repos
    ↓
Autonomous Agent Builds Infrastructure
    ↓
Production GitHub Organizations
```

---

## Relationship to GitHub Repositories

This local workspace feeds THREE GitHub repositories:

### 1. Seven-Fortunas-Internal/7f-infrastructure-project

**Purpose:** Planning artifacts and autonomous agent configuration
**Location:** `/home/ladmin/seven-fortunas-workspace/7f-infrastructure-project/`
**Contains:**
- Autonomous Workflow Guide
- CLAUDE.md (agent instructions)
- README.md (project overview)
- app_spec.txt (generated from PRD)
- Autonomous agent scripts (to be created)

### 2. Seven-Fortunas-Internal/seven-fortunas-brain

**Purpose:** Second Brain content (knowledge management)
**Location:** `/home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/`
**Contains:**
- Brand system
- Culture documentation
- Domain expertise
- Best practices
- Custom skills
- BMAD library (submodule)

### 3. Seven-Fortunas/dashboards

**Purpose:** 7F Lens Intelligence Platform
**Location:** `/home/ladmin/seven-fortunas-workspace/dashboards/`
**Contains:**
- AI Advancements Tracker
- Dashboard automation workflows
- Data source configurations

---

## BMAD Library

This workspace has the BMAD library deployed in `_bmad/` with 70+ production-ready workflows:

**Available Skills (via symlinks in `.claude/commands/`):**
- `/bmad-bmm-create-prd` - Generate Product Requirements Documents
- `/bmad-bmm-create-architecture` - Create architecture docs & ADRs
- `/bmad-bmm-create-story` - Generate user stories
- `/bmad-bmm-code-review` - Facilitate code reviews
- `/bmad-bmm-sprint-planning` - Run sprint planning sessions
- `/bmad-cis-storytelling` - Create presentations & pitch decks
- ... and 60+ more

**How to use:**
```bash
# Invoke a BMAD skill in Claude Code
/bmad-bmm-create-prd

# Or navigate to workflow directly
cat .claude/commands/bmad-bmm-create-prd.md
```

---

## Current Project Status

| Phase | Status | Artifacts |
|-------|--------|-----------|
| **Planning** | 🔄 In Progress | Product Brief ✅, Architecture ✅, PRD 🔄 |
| **Agent Setup** | ⏭️ Pending | Scripts, prompts, app_spec.txt |
| **Autonomous Build** | ⏭️ Pending | Infrastructure scaffolding (Days 1-2) |
| **Human Refinement** | ⏭️ Pending | Branding, content curation (Days 3-5) |
| **MVP Demo** | ⏭️ Pending | Leadership review (Day 5) |

---

## Key Planning Artifacts

### Product Brief (52KB) ✅
**File:** `_bmad-output/planning-artifacts/product-brief-7F_github-2026-02-10.md`

**Key Points:**
- Two-org GitHub model (public + internal)
- BMAD-first strategy (70+ skills, create 7 custom)
- 25 operational skills in MVP (vs. original 6)
- 87% cost reduction ($7,200 vs. $53,400)
- 5-day timeline with 60-70% automation

### Architecture Document (112KB) ✅
**File:** `_bmad-output/planning-artifacts/architecture-7F_github-2026-02-10.md`

**Key Points:**
- BMAD Integration Strategy
- User Profile Architecture (YAML-based)
- Voice Input Integration (OpenAI Whisper)
- Skill-Creation System (meta-skill)
- 15+ Architectural Decision Records (ADRs)

### BMAD Skill Mapping (18KB) ✅
**File:** `_bmad-output/planning-artifacts/bmad-skill-mapping-2026-02-10.md`

**Key Points:**
- 60% coverage by existing BMAD skills
- 18 BMAD skills adopted (no custom build needed)
- 7 custom Seven Fortunas skills to create
- 272 hours saved (87% reduction)

### Autonomous Workflow Guide (110KB) ✅
**File:** `_bmad-output/planning-artifacts/autonomous-workflow-guide-7f-infrastructure.md`

**Key Points:**
- Claude Code SDK setup instructions
- Two-agent pattern (initializer + coding)
- Bounded retries (max 3 attempts per feature)
- Testing built into development cycle
- Script templates and prompts

### PRD (In Progress) 🔄
**File:** `_bmad-output/planning-artifacts/prd.md`

**Status:** Step 1 of 11 complete (initialization)
**Next:** Step 2 - Project Discovery

---

## Quick Commands

### Navigate to Project Workspaces

```bash
# This local workspace
cd /home/ladmin/dev/GDF/7F_github

# Infrastructure project repo
cd /home/ladmin/seven-fortunas-workspace/7f-infrastructure-project

# Second Brain repo
cd /home/ladmin/seven-fortunas-workspace/seven-fortunas-brain

# Dashboards repo
cd /home/ladmin/seven-fortunas-workspace/dashboards
```

### View Planning Artifacts

```bash
# List all planning artifacts
ls -lh _bmad-output/planning-artifacts/

# Read Product Brief
cat _bmad-output/planning-artifacts/product-brief-7F_github-2026-02-10.md

# Read PRD (in progress)
cat _bmad-output/planning-artifacts/prd.md
```

### Invoke BMAD Skills

```bash
# In Claude Code, use slash commands
/bmad-bmm-create-prd
/bmad-bmm-create-architecture
/bmad-bmm-create-story

# Or read the skill stub
cat .claude/commands/bmad-bmm-create-prd.md
```

---

## Team Access

**Who uses this workspace:**
- **Jorge (VP AI-SecOps)** - Primary user, creates planning artifacts
- **Mary (Business Analyst Agent)** - Facilitates BMAD workflows
- **Other BMAD Agents** - Architect, Developer, PM, Scrum Master

**Who does NOT directly use this:**
- Henry, Patrick, Buck (they interact with GitHub repos, not this local workspace)

---

## Success Criteria

This workspace has served its purpose when:
- ✅ All planning artifacts complete (Product Brief, Architecture, PRD)
- ✅ `app_spec.txt` generated from PRD
- ✅ Artifacts copied to appropriate GitHub repositories
- ✅ Autonomous agent ready to launch
- ✅ Infrastructure project kickoff successful

---

## Resources

**BMAD Documentation:**
- BMAD library: `_bmad/` (70+ workflows)
- Skill stubs: `.claude/commands/bmad-*.md`
- BMAD help: `/bmad-help` (in Claude Code)

**Planning Artifacts:**
- All documents: `_bmad-output/planning-artifacts/`
- Current status: See table above

**GitHub Repositories:**
- Infrastructure Project: https://github.com/Seven-Fortunas-Internal/7f-infrastructure-project
- Second Brain: https://github.com/Seven-Fortunas-Internal/seven-fortunas-brain
- Dashboards: https://github.com/Seven-Fortunas/dashboards

---

## Notes

- This is a **local development workspace** - not a Git repository itself
- Planning artifacts are copied to Git repos when ready
- BMAD library stays here (deployed to repos as submodule separately)
- Do not commit this directory to Git (it's a working directory)

---

**Created:** 2026-02-10
**Owner:** Jorge (VP AI-SecOps)
**Purpose:** Planning & development workspace for Seven Fortunas infrastructure
