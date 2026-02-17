---
inputDocuments: ['_bmad-output/planning-artifacts/product-brief-7F_github-2026-02-10.md']
date: 2026-02-10
author: Mary (Business Analyst) with Jorge
project_name: Seven Fortunas AI-Native Enterprise Infrastructure
version: 1.0
status: draft
document_type: architecture
---

# Architecture Document: Seven Fortunas AI-Native Enterprise Infrastructure

**Project:** GitHub Organization, Second Brain & 7F Lens Intelligence Platform
**Date:** 2026-02-10
**Version:** 1.0
**Author:** Mary (Business Analyst Agent) with Jorge
**Status:** Draft - Ready for Technical Review

---

## Executive Summary

This architecture document defines the technical design, patterns, and architectural decisions for Seven Fortunas's AI-native enterprise infrastructure. The system comprises three integrated platforms:

1. **GitHub Organization Architecture** - Two-org model with team-based structure
2. **Seven Fortunas Second Brain** - Progressive disclosure knowledge system
3. **7F Lens Intelligence Platform** - Multi-dimensional dashboards with AI summarization

**Critical Innovation:** Self-service infrastructure through BMAD skills, enabling founding team to configure systems without creating bottlenecks.

**BMAD-First Strategy:** Leverage existing BMAD library (70+ skills/workflows) to accelerate delivery. Only create custom skills for Seven Fortunas-specific needs. This reduces MVP development from 356 hours to 48 hours (87% reduction).

**Key Architectural Principles:**
- 🤖 **AI-First Design** - Optimize for AI consumption and generation
- 🔄 **Self-Service** - Enable users through tools, not manual intervention
- 📦 **Progressive Disclosure** - Load information just-in-time
- 🔒 **Security by Default** - Automated scanning, policy enforcement
- 📈 **Zero to Enterprise** - Scale from free tier to enterprise seamlessly
- 🔧 **Leverage, Don't Recreate** - Use BMAD library for proven workflows, create custom only when needed

---

## BMAD Integration Strategy

### Overview

Seven Fortunas adopts the **BMAD (Business Method for AI Development)** methodology as the foundation for all automation and workflows. Analysis shows BMAD already provides 18 of 30 identified automation opportunities (60% coverage), saving 272 hours of development effort.

### BMAD Coverage

| Category | Coverage | Examples |
|----------|----------|----------|
| **AI-Assisted Workflows** | 90% (9/10) | PRD generation, code review, sprint planning, retrospectives |
| **Best Practices Guidance** | 60% (6/10) | Code review checklist, test review, PR workflow |
| **Full Automation** | 30% (3/10) | Documentation generation, project documentation |
| **Total** | 60% (18/30) | 18 workflows ready to use immediately |

### BMAD Skills Available

**Development Workflows:**
- `bmad-bmm-create-prd` - PRD generation
- `bmad-bmm-create-architecture` - Architecture docs & ADRs
- `bmad-bmm-create-story` - User story creation
- `bmad-bmm-dev-story` - Story implementation
- `bmad-bmm-code-review` - Code review workflow
- `bmad-bmm-quick-spec` - Technical specifications
- `bmad-bmm-document-project` - Project documentation

**Process Workflows:**
- `bmad-bmm-sprint-planning` - Sprint planning facilitation
- `bmad-bmm-retrospective` - Retrospective facilitation
- `bmad-bmm-correct-course` - Course correction
- `bmad-bmm-sprint-status` - Sprint status updates

**Quality Workflows:**
- `bmad-bmm-qa-automate` - QA automation
- `bmad-tea-testarch-automate` - Test automation framework
- `bmad-tea-testarch-test-review` - Test review

**Creative Workflows:**
- `bmad-cis-storytelling` - Presentations, pitch decks
- `bmad-cis-presentation-master` - Presentation design
- `bmad-brainstorming` - Brainstorming facilitation

**Plus 20+ specialized agents** (Analyst, Architect, Developer, PM, Scrum Master, QA, etc.)

### Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│           Seven-Fortunas GitHub Organizations                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Seven-Fortunas (Public)          Seven-Fortunas-Internal       │
│  └── second-brain-public/         └── seven-fortunas-brain/     │
│      └── _bmad/ (submodule)           └── _bmad/ (submodule)    │
│          ├── bmm/ (method)                ├── bmm/ (method)     │
│          ├── bmb/ (builder)               ├── bmb/ (builder)    │
│          ├── cis/ (creative)              ├── cis/ (creative)   │
│          ├── tea/ (testing)               ├── tea/ (testing)    │
│          └── core/ (framework)            └── core/ (framework) │
│                                                                  │
│      └── .claude/commands/            └── .claude/commands/     │
│          ├── bmad-* (symlinks)            ├── bmad-* (symlinks) │
│          └── 7f-* (custom skills)         └── 7f-* (custom)     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                            ↓
                    Git Submodule
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│        https://github.com/bmad-method/bmad-method.git           │
│                  (Official BMAD Repository)                      │
└─────────────────────────────────────────────────────────────────┘
```

### Implementation Steps

**Step 1: Add BMAD as Submodule (Day 0)**

```bash
# In seven-fortunas-brain repo (internal)
cd Seven-Fortunas-Internal/seven-fortunas-brain
git submodule add https://github.com/bmad-method/bmad-method.git _bmad
git add .gitmodules _bmad
git commit -m "Add BMAD as submodule for workflow automation"
git push

# In second-brain-public repo (public)
cd Seven-Fortunas/second-brain-public
git submodule add https://github.com/bmad-method/bmad-method.git _bmad
git add .gitmodules _bmad
git commit -m "Add BMAD as submodule for workflow automation"
git push
```

**Step 2: Create Skill Symlinks (Day 0)**

```bash
# In .claude/commands/ directory
cd .claude/commands

# Create symlinks for frequently used BMAD workflows
ln -s ../../_bmad/bmm/workflows/create-prd/workflow.md bmad-bmm-create-prd.md
ln -s ../../_bmad/bmm/workflows/create-story/workflow.md bmad-bmm-create-story.md
ln -s ../../_bmad/bmm/workflows/code-review/checklist.md bmad-bmm-code-review.md
ln -s ../../_bmad/bmm/workflows/sprint-planning/instructions.md bmad-bmm-sprint-planning.md
# ... repeat for all needed skills

# Or use automation script (create-bmad-symlinks.sh)
```

**Step 3: Document Available Skills (Day 0)**

Create `docs/bmad-skills-reference.md` listing all available BMAD skills with descriptions and use cases.

**Step 4: Update Onboarding (Day 1)**

Add BMAD skills training to founding team onboarding:
- How to invoke BMAD skills (`/bmad-bmm-create-story`)
- When to use which skill
- How to customize BMAD workflows
- How to create new skills using BMAD Builder

### Custom Skills Strategy

**Create custom skills only for Seven Fortunas-specific needs:**

1. **7f-create-repository** - Repo creation with Seven Fortunas standards
2. **7f-brand-system-generator** - Brand definition and application
3. **7f-github-org-configurator** - GitHub org configuration wizard
4. **7f-company-definition-wizard** - Company culture definition
5. **7f-dashboard-configurator** - 7F Lens dashboard configuration
6. **7f-onboard-team-member** - Seven Fortunas-specific onboarding
7. **7f-github-org-search** - Search across Seven Fortunas GitHub orgs

**Use BMAD Builder to create custom skills:**
- Invoke `/bmad-agent-bmb-workflow-builder` or `/bmad-bmb-create-workflow`
- Provide requirements from this Architecture Document
- Let BMAD generate skill structure
- Review, refine, test

### Version Management

**BMAD Submodule Versioning:**
```bash
# Pin to specific BMAD version for stability
cd _bmad
git checkout v6.0.0  # Pin to specific release
cd ..
git add _bmad
git commit -m "Pin BMAD to v6.0.0"

# Update BMAD when needed
cd _bmad
git fetch
git checkout v6.1.0  # Update to new release
cd ..
git add _bmad
git commit -m "Update BMAD to v6.1.0"
```

### Maintenance Strategy

**Quarterly BMAD Review:**
- Check for new BMAD releases
- Review new skills/workflows added to BMAD
- Identify opportunities to replace custom skills with BMAD skills
- Update documentation

**Contribution Back to BMAD:**
- If custom Seven Fortunas skills are generalizable, contribute back to BMAD community
- Share lessons learned and improvements

### Benefits Summary

| Metric | Before BMAD | With BMAD | Improvement |
|--------|-------------|-----------|-------------|
| **Skills Available (MVP)** | 6 | 25 | 4.2x more |
| **Development Hours** | 356 | 48 | 87% reduction |
| **Development Cost** | $53,400 | $7,200 | 87% savings |
| **Time to MVP** | ~50 days | ~11 days | 4.5x faster |
| **ROI** | 528-841% | 2,063-3,095% | 3.9x better |

---

## Table of Contents

1. [System Context](#system-context)
2. [Skill-Creation System Architecture](#skill-creation-system-architecture)
3. [Enabling Skills Architecture](#enabling-skills-architecture)
4. [GitHub Organization Architecture](#github-organization-architecture)
5. [Second Brain Architecture](#second-brain-architecture)
6. [7F Lens Dashboard Architecture](#7f-lens-dashboard-architecture)
7. [Security Architecture](#security-architecture)
8. [Deployment Architecture](#deployment-architecture)
9. [Data Architecture](#data-architecture)
10. [Architectural Decision Records (ADRs)](#architectural-decision-records-adrs)
11. [Technology Stack](#technology-stack)
12. [Integration Points](#integration-points)
13. [Scalability & Performance](#scalability--performance)
14. [Disaster Recovery](#disaster-recovery)
15. [Open Questions](#open-questions)

---

## System Context

### C4 Model - Context Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                     EXTERNAL SYSTEMS                                 │
├─────────────────────────────────────────────────────────────────────┤
│  • GitHub API (org management, repos, actions)                      │
│  • Anthropic API (Claude for AI summarization)                      │
│  • External Data Sources (RSS feeds, Reddit JSON, YouTube RSS)      │
│  • X API (optional - Twitter trends)                                │
│  • Obsidian (optional - visualization client)                       │
└────────────────────────┬────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────────────┐
│             SEVEN FORTUNAS INFRASTRUCTURE (System Boundary)          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────┐  ┌────────────────────┐                   │
│  │  GitHub Orgs       │  │  Second Brain      │                   │
│  │  (Storage & Collab)│  │  (Knowledge Base)  │                   │
│  └────────────────────┘  └────────────────────┘                   │
│                                                                      │
│  ┌────────────────────┐  ┌────────────────────┐                   │
│  │  7F Lens Platform  │  │  BMAD Skills       │                   │
│  │  (Intelligence)    │  │  (Self-Service)    │                   │
│  └────────────────────┘  └────────────────────┘                   │
│                                                                      │
└────────────────────────┬────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────────────┐
│                          USERS                                       │
├─────────────────────────────────────────────────────────────────────┤
│  • Founding Team (Henry, Patrick, Buck, Jorge)                      │
│  • Engineering Team (developers, security engineers)                │
│  • Executive Team (CEO, CTO, advisors)                              │
│  • External Stakeholders (investors, customers, partners)           │
└─────────────────────────────────────────────────────────────────────┘
```

### System Actors

| Actor | Role | Primary Use Cases |
|-------|------|-------------------|
| **Founding Team** | Administrators | Configure orgs, define branding, set up dashboards |
| **Engineers** | Contributors | Create repos, commit code, use templates |
| **Executives** | Consumers | View dashboards, access reports, generate content |
| **AI Agents** | Automation | Summarize trends, generate docs, execute workflows |
| **Investors** | Observers | Review public repos, assess organization |

---

## Skill-Creation System Architecture

### Purpose

Enable **meta-programming**: a skill that creates other skills. This allows Jorge to define skill requirements once, and have the meta-skill generate complete, functional BMAD skills automatically.

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                  SKILL-CREATION SKILL (Meta-Skill)                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  INPUT: Skill Requirements                                          │
│  ├─ Skill name and description                                      │
│  ├─ User journey (who, when, why)                                   │
│  ├─ Workflow steps (sequence of actions)                            │
│  ├─ Validation rules (what constitutes success)                     │
│  ├─ Output artifacts (what gets created)                            │
│  └─ Example scenarios                                               │
│                                                                      │
│  PROCESSING: Template-Driven Generation                             │
│  ├─ Parse requirements into structured data                         │
│  ├─ Generate SKILL.md with YAML frontmatter                         │
│  ├─ Create workflow sections (activation, handlers, menu, rules)    │
│  ├─ Generate reference documentation                                │
│  ├─ Create example files                                            │
│  └─ Package into .skill ZIP archive                                 │
│                                                                      │
│  OUTPUT: Complete BMAD Skill                                        │
│  └─ .skill file ready for use                                       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Skill-Creation Skill - Design

#### Input Schema

The skill-creation skill accepts requirements in this format:

```yaml
skill_requirements:
  metadata:
    name: "7f-brand-system-generator"
    description: "Interactive questionnaire for defining and applying company branding"
    version: "1.0"
    author: "Jorge (via skill-creation skill)"

  user_journey:
    who: "CEO or design lead"
    when: "During initial company setup or rebranding"
    why: "Need to define brand identity and apply consistently across all assets"

  workflow_steps:
    - step: 1
      name: "Gather brand requirements"
      actions:
        - "Ask interactive questions about brand identity"
        - "Corporate colors (primary, secondary, accent)"
        - "Typography (heading font, body font)"
        - "Logo assets (file paths or generation requirements)"
        - "Brand voice (formal, casual, technical, friendly)"
      validation:
        - "All required fields completed"
        - "Colors in valid hex format"
        - "Font choices are web-safe or have fallbacks"

    - step: 2
      name: "Generate brand documentation"
      actions:
        - "Create brand/brand.json with structured data"
        - "Create brand/brand-system.md with narrative documentation"
        - "Create brand/tone-of-voice.md with communication guidelines"
      validation:
        - "All files created successfully"
        - "JSON is valid and parseable"

    - step: 3
      name: "Apply branding to assets"
      actions:
        - "Update GitHub org profiles (both orgs)"
        - "Update seven-fortunas.github.io CSS variables"
        - "Update README templates with brand colors"
        - "Update Issue/PR templates with brand voice"
      validation:
        - "All assets updated without errors"
        - "Visual consistency check (manual review)"

  output_artifacts:
    - "brand/brand.json"
    - "brand/brand-system.md"
    - "brand/tone-of-voice.md"
    - "brand/assets/ (directory for logos, icons)"
    - "Updated GitHub org profiles"
    - "Updated seven-fortunas.github.io"

  example_scenarios:
    - scenario: "Seven Fortunas initial branding"
      input:
        colors:
          primary: "#1E3A8A"  # Deep blue
          secondary: "#10B981"  # Emerald green
          accent: "#F59E0B"  # Amber
        fonts:
          heading: "Inter"
          body: "Inter"
        voice: "Professional yet approachable, mission-driven"
      expected_output: "Complete brand system applied to all assets"
```

#### Processing Logic

**Phase 1: Requirements Parsing**
1. Load requirements YAML
2. Validate schema completeness
3. Extract metadata, workflow, outputs

**Phase 2: Skill Template Generation**
```python
def generate_skill(requirements):
    """Generate BMAD skill from requirements"""

    # Generate SKILL.md frontmatter
    frontmatter = {
        'name': requirements.metadata.name,
        'description': requirements.metadata.description,
        'version': requirements.metadata.version,
        'triggers': extract_triggers(requirements.user_journey)
    }

    # Generate activation section
    activation = generate_activation_steps(requirements.workflow_steps)

    # Generate menu items
    menu = generate_menu_from_workflow(requirements.workflow_steps)

    # Generate validation handlers
    validation = generate_validation_logic(requirements.workflow_steps)

    # Assemble SKILL.md
    skill_content = assemble_skill_markdown(
        frontmatter, activation, menu, validation
    )

    # Generate reference documentation
    references = generate_reference_docs(
        requirements.example_scenarios
    )

    # Package as .skill (ZIP archive)
    return create_skill_package(skill_content, references)
```

**Phase 3: Skill Packaging**
1. Create `.skill` ZIP archive
2. Add `SKILL.md` (main workflow)
3. Add `references/` directory with examples
4. Add `tests/` directory with validation scenarios
5. Generate README for skill usage

#### Output Structure

```
7f-brand-system-generator.skill (ZIP archive)
├── SKILL.md                    # Main workflow with YAML frontmatter
├── references/
│   ├── brand-examples.md       # Example brand definitions
│   ├── color-theory.md         # Best practices for color selection
│   └── typography-guide.md     # Font pairing recommendations
├── tests/
│   ├── test-scenario-1.yaml    # Test case: Tech startup branding
│   └── test-scenario-2.yaml    # Test case: Non-profit branding
└── README.md                   # How to use this skill
```

### Skill-Creation Skill - Implementation

**Technology:**
- Python script with Jinja2 templates
- YAML parser (PyYAML)
- ZIP file generation (zipfile module)
- Markdown generation (Python f-strings or templates)

**Location:**
- `.claude/skills/skill-creation-skill.skill`

**Usage:**
```bash
# Invoke via Claude Code
/skill-creation-skill requirements.yaml

# Or via BMAD workflow
claude-code --skill skill-creation-skill --input requirements.yaml
```

### Self-Bootstrapping Consideration

**Philosophical Question:** How do we create the skill-creation skill if we need a skill-creation skill to create skills?

**Answer:** Manual first version, then self-improve.

**Approach:**
1. **Manual Creation (Day 0):** Jorge manually creates v1.0 of skill-creation skill using existing BMAD patterns
2. **Self-Improvement (Day 1+):** Use v1.0 to generate v1.1 by feeding it its own requirements
3. **Iteration:** Each version can improve the next version

**Rationale:** This is how compilers are built (bootstrapping). First compiler written in assembly, then compiler v2 written in the language itself.

---

## Enabling Skills Architecture

### Overview

Five skills that enable founding team to configure infrastructure self-service:

| Skill | Purpose | Primary User | Complexity |
|-------|---------|--------------|------------|
| `7f-brand-system-generator` | Define and apply branding | Henry (CEO) | Medium |
| `7f-github-org-configurator` | Configure orgs/teams/permissions | Patrick (CTO) | High |
| `7f-company-definition-wizard` | Define mission/vision/values | Henry (CEO) | Low |
| `7f-dashboard-configurator` | Configure dashboard data sources | Any founding member | Medium |
| `7f-onboard-team-member` | Automated onboarding | Any founding member | Medium |

### 1. Brand System Generator Skill

#### Purpose
Enable CEO or design lead to define company branding and automatically apply it across all GitHub assets.

#### User Journey
1. **Trigger:** CEO runs `/7f-brand-system-generator`
2. **Interactive Questionnaire:**
   - "What are your primary brand colors?" (hex picker or predefined palettes)
   - "What typography feels right?" (show font pairings)
   - "Upload logo or describe for AI generation"
   - "What's your brand voice?" (formal, casual, technical, friendly)
3. **Preview:** Shows how branding will look on GitHub org, website
4. **Confirmation:** "Apply this branding to all assets?"
5. **Execution:** Updates all files automatically
6. **Output:** Brand documentation + applied branding

#### Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│            7f-brand-system-generator.skill                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  STEP 1: Interactive Questionnaire                                  │
│  ├─ AskUserQuestion tool for color selection                        │
│  ├─ AskUserQuestion tool for typography                             │
│  ├─ File upload for logo (or AI generation prompt)                  │
│  └─ AskUserQuestion tool for brand voice                            │
│                                                                      │
│  STEP 2: Generate Brand Documentation                               │
│  ├─ Write brand/brand.json (structured data)                        │
│  ├─ Write brand/brand-system.md (narrative)                         │
│  ├─ Write brand/tone-of-voice.md (guidelines)                       │
│  └─ Write brand/assets/README.md (asset inventory)                  │
│                                                                      │
│  STEP 3: Preview Changes                                            │
│  ├─ Generate preview of GitHub org profile                          │
│  ├─ Generate preview of seven-fortunas.github.io                    │
│  └─ Show diff of changes to be made                                 │
│                                                                      │
│  STEP 4: Apply Branding (with confirmation)                         │
│  ├─ Update .github/profile/README.md (both orgs)                    │
│  ├─ Update seven-fortunas.github.io/assets/css/style.css           │
│  ├─ Update .github/ISSUE_TEMPLATE/* (voice)                         │
│  ├─ Update .github/PULL_REQUEST_TEMPLATE.md (voice)                 │
│  └─ Commit changes with message                                     │
│                                                                      │
│  STEP 5: Verification                                               │
│  └─ Generate checklist for manual visual review                     │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Key Files Modified

```
second-brain-core/
└── brand/
    ├── brand.json              # Structured data (colors, fonts, assets)
    ├── brand-system.md         # Narrative documentation
    ├── tone-of-voice.md        # Communication guidelines
    └── assets/
        └── README.md           # Asset inventory

Seven-Fortunas/.github/
└── profile/
    └── README.md               # Updated with brand colors/voice

Seven-Fortunas-Internal/.github/
└── profile/
    └── README.md               # Updated with brand colors/voice

seven-fortunas.github.io/
└── assets/
    └── css/
        └── style.css           # Updated CSS variables
```

#### Implementation Details

**Interactive Questions (using AskUserQuestion tool):**

```yaml
questions:
  - question: "What's your primary brand color? This will be used for headers, CTAs, and key UI elements."
    header: "Primary Color"
    multiSelect: false
    options:
      - label: "Deep Blue (#1E3A8A)"
        description: "Professional, trustworthy, tech-focused"
      - label: "Emerald Green (#10B981)"
        description: "Growth, prosperity, innovative"
      - label: "Vibrant Purple (#7C3AED)"
        description: "Creative, bold, forward-thinking"
      - label: "Custom"
        description: "I'll provide a specific hex code"
```

**Brand JSON Schema:**

```json
{
  "name": "Seven Fortunas",
  "version": "1.0",
  "colors": {
    "primary": {
      "hex": "#1E3A8A",
      "name": "Deep Blue",
      "usage": "Headers, CTAs, links"
    },
    "secondary": {
      "hex": "#10B981",
      "name": "Emerald Green",
      "usage": "Success states, highlights"
    },
    "accent": {
      "hex": "#F59E0B",
      "name": "Amber",
      "usage": "Warnings, attention"
    },
    "neutral": {
      "light": "#F9FAFB",
      "medium": "#6B7280",
      "dark": "#111827"
    }
  },
  "typography": {
    "heading": {
      "family": "Inter",
      "weights": [600, 700, 800],
      "fallback": "sans-serif"
    },
    "body": {
      "family": "Inter",
      "weights": [400, 500],
      "fallback": "sans-serif"
    },
    "code": {
      "family": "JetBrains Mono",
      "weights": [400, 500],
      "fallback": "monospace"
    }
  },
  "voice": {
    "tone": "Professional yet approachable",
    "personality": ["Mission-driven", "Innovative", "Inclusive"],
    "avoid": ["Jargon without explanation", "Hype without substance"]
  },
  "assets": {
    "logo": "brand/assets/logo.svg",
    "icon": "brand/assets/icon.svg",
    "favicon": "brand/assets/favicon.ico"
  }
}
```

### 2. GitHub Org Configurator Skill

#### Purpose
Enable CTO or admin to configure GitHub organizations, teams, and permissions through interactive wizard.

#### User Journey
1. **Trigger:** CTO runs `/7f-github-org-configurator`
2. **Wizard Menu:**
   - [1] Create new team
   - [2] Modify team permissions
   - [3] Configure org security settings
   - [4] Set up repository defaults
   - [5] Configure GitHub Actions permissions
3. **Interactive Configuration:** Guided questions for selected action
4. **Preview:** Shows changes to be made
5. **Execution:** Uses GitHub API to apply changes
6. **Documentation:** Updates internal docs with changes

#### Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│            7f-github-org-configurator.skill                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  MENU HANDLER: Create New Team                                      │
│  ├─ Ask: Team name                                                  │
│  ├─ Ask: Team purpose (BD, Engineering, Operations, etc.)           │
│  ├─ Ask: Default repository access (none, read, write, admin)       │
│  ├─ Ask: Team members to add                                        │
│  ├─ Preview team structure                                          │
│  ├─ Execute: gh api --method POST /orgs/{org}/teams {...}           │
│  └─ Document: Update internal-docs/teams/{team-name}.md             │
│                                                                      │
│  MENU HANDLER: Configure Org Security                               │
│  ├─ Ask: Require 2FA for all members? (yes/no)                      │
│  ├─ Ask: Enable Dependabot? (yes/no)                                │
│  ├─ Ask: Enable Secret Scanning? (yes/no)                           │
│  ├─ Ask: Default repo permissions (none, read, write)               │
│  ├─ Preview security settings                                       │
│  ├─ Execute: gh api --method PATCH /orgs/{org} {...}                │
│  └─ Document: Update internal-docs/security-policies.md             │
│                                                                      │
│  MENU HANDLER: Set Up Repository Defaults                           │
│  ├─ Ask: Default branch name (main, master, develop)                │
│  ├─ Ask: Enable issues by default? (yes/no)                         │
│  ├─ Ask: Enable projects by default? (yes/no)                       │
│  ├─ Ask: Enable wiki by default? (yes/no)                           │
│  ├─ Ask: Auto-delete head branches after merge? (yes/no)            │
│  ├─ Execute: Update org settings via GitHub API                     │
│  └─ Document: Update internal-docs/repository-standards.md          │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### GitHub API Integration

**Authentication:**
- Uses `gh` CLI (authenticated via user's GitHub token)
- Requires `admin:org` scope

**Example API Calls:**

```bash
# Create team
gh api --method POST /orgs/Seven-Fortunas/teams \
  -f name="Backend Engineering" \
  -f description="Backend developers and architects" \
  -f privacy="closed" \
  -f permission="push"

# Update org security settings
gh api --method PATCH /orgs/Seven-Fortunas \
  -F two_factor_requirement_enabled=true \
  -F default_repository_permission="none"

# Enable Dependabot for org
gh api --method PUT /orgs/Seven-Fortunas/dependabot/secrets \
  -f name="DEPENDABOT_TOKEN" \
  -f value="..."
```

### 3. Company Definition Wizard Skill

#### Purpose
Enable CEO to define company mission, vision, values through guided interview. Generates culture documentation.

#### User Journey
1. **Trigger:** CEO runs `/7f-company-definition-wizard`
2. **Guided Interview:**
   - "What problem does Seven Fortunas solve?"
   - "Who do you serve? (target customers)"
   - "What's your long-term vision? (5-10 years)"
   - "What are your core values? (3-5 values)"
   - "How do you make decisions? (decision framework)"
3. **AI-Generated Draft:** Claude generates culture docs based on responses
4. **Review & Refine:** CEO edits AI-generated draft
5. **Publish:** Saves to Second Brain, commits to repo

#### Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│            7f-company-definition-wizard.skill                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  STEP 1: Guided Interview (5-10 minutes)                            │
│  ├─ Ask: Mission (problem to solve)                                 │
│  ├─ Ask: Vision (future state)                                      │
│  ├─ Ask: Values (3-5 core principles)                               │
│  ├─ Ask: Target customers (who we serve)                            │
│  └─ Ask: Decision framework (how we choose)                         │
│                                                                      │
│  STEP 2: AI-Generated Documentation                                 │
│  ├─ Prompt Claude with interview responses                          │
│  ├─ Generate culture/mission.md                                     │
│  ├─ Generate culture/vision.md                                      │
│  ├─ Generate culture/values.md                                      │
│  └─ Generate culture/ethos.md                                       │
│                                                                      │
│  STEP 3: Review & Refinement                                        │
│  ├─ Present AI-generated docs to CEO                                │
│  ├─ Allow editing (line-by-line or section-by-section)              │
│  └─ Iterate until CEO approves                                      │
│                                                                      │
│  STEP 4: Publish to Second Brain                                    │
│  ├─ Write files to second-brain-core/culture/                       │
│  ├─ Commit changes to git                                           │
│  └─ Optionally publish to public org (sanitized version)            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Claude API Integration

**Prompt Template:**

```
You are helping define the culture and mission for a startup called Seven Fortunas.

Based on this interview with the CEO:

Mission (problem to solve): {mission_input}
Vision (future state): {vision_input}
Core values: {values_input}
Target customers: {customers_input}
Decision framework: {decision_input}

Please generate the following documents:

1. culture/mission.md - A compelling 1-2 paragraph mission statement
2. culture/vision.md - A vivid 2-3 paragraph vision of the future
3. culture/values.md - Detailed explanation of each core value
4. culture/ethos.md - Overall company culture and operating principles

Write in a tone that is: {brand_voice from brand.json}

Format in Markdown with clear headings, bullet points where appropriate.
```

### 4. Dashboard Configurator Skill

#### Purpose
Enable any team member to configure 7F Lens dashboard data sources (add/remove RSS feeds, Reddit sources, etc.)

#### User Journey
1. **Trigger:** User runs `/7f-dashboard-configurator`
2. **Select Dashboard:** AI, Fintech, EduTech, Security, etc.
3. **Configuration Menu:**
   - [1] Add RSS feed
   - [2] Remove RSS feed
   - [3] Add Reddit subreddit
   - [4] Remove Reddit subreddit
   - [5] Add YouTube channel
   - [6] Configure update frequency
4. **Interactive Input:** Guided questions for selected action
5. **Validation:** Test source (fetch sample data)
6. **Apply:** Update dashboard config file
7. **Trigger Rebuild:** Re-run dashboard aggregation

#### Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│            7f-dashboard-configurator.skill                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  MENU HANDLER: Add RSS Feed                                         │
│  ├─ Ask: Feed URL                                                   │
│  ├─ Ask: Source name (for display)                                  │
│  ├─ Ask: Keywords to filter (optional)                              │
│  ├─ Validate: Fetch feed, parse XML, check for errors               │
│  ├─ Test: Show sample items from feed                               │
│  ├─ Execute: Update dashboards/{dashboard}/config/sources.yaml      │
│  └─ Trigger: Re-run aggregation workflow                            │
│                                                                      │
│  MENU HANDLER: Add Reddit Subreddit                                 │
│  ├─ Ask: Subreddit name (e.g., "MachineLearning")                   │
│  ├─ Ask: Sort by (hot, new, top)                                    │
│  ├─ Ask: Time filter (day, week, month, all)                        │
│  ├─ Validate: Fetch r/{subreddit}.json, check for errors            │
│  ├─ Test: Show sample posts                                         │
│  ├─ Execute: Update config file                                     │
│  └─ Trigger: Re-run aggregation workflow                            │
│                                                                      │
│  MENU HANDLER: Configure Update Frequency                           │
│  ├─ Ask: Update frequency (1h, 6h, 12h, 24h)                        │
│  ├─ Preview: Show cron expression                                   │
│  ├─ Execute: Update .github/workflows/update-dashboard.yml          │
│  └─ Document: Update README with new schedule                       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Dashboard Config Schema

**File:** `dashboards/ai/config/sources.yaml`

```yaml
dashboard:
  name: "AI Advancements Tracker"
  description: "Tracks latest developments in AI/ML"
  update_frequency: "6h"

sources:
  rss_feeds:
    - name: "OpenAI Blog"
      url: "https://openai.com/blog/rss.xml"
      keywords: ["GPT", "model", "release", "research"]

    - name: "Anthropic Blog"
      url: "https://www.anthropic.com/blog/rss.xml"
      keywords: ["Claude", "AI safety", "research"]

  reddit:
    - subreddit: "MachineLearning"
      sort: "hot"
      time_filter: "day"
      keywords: ["breakthrough", "paper", "sota"]

    - subreddit: "LocalLLaMA"
      sort: "hot"
      time_filter: "day"
      keywords: ["release", "model", "quantization"]

  youtube_channels:
    - name: "OpenAI"
      channel_id: "UCXZCJLdBC09xxGZ6gcdrc6A"

    - name: "Two Minute Papers"
      channel_id: "UCbfYPyITQ-7l4upoX8nvctg"

  github_releases:
    - repo: "langchain-ai/langchain"
    - repo: "run-llama/llama_index"

aggregation:
  deduplication: true
  relevance_scoring: true
  max_items: 100
```

### 5. Onboard Team Member Skill

#### Purpose
Automate onboarding process for new team members (founding team and future hires).

#### User Journey
1. **Trigger:** Admin runs `/7f-onboard-team-member`
2. **Collect Info:**
   - New member's name, email, GitHub handle, role
3. **Generate Onboarding Checklist:**
   - GitHub org invitations
   - Team assignments
   - Access to repos
   - Required reading (Second Brain docs)
   - Setup instructions (dev environment)
4. **Execute Automation:**
   - Send GitHub org invites
   - Add to teams
   - Create onboarding issue (personalized checklist)
   - Send welcome email (optional)
5. **Track Progress:**
   - Monitor checklist completion
   - Notify admin when member is fully onboarded

#### Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│            7f-onboard-team-member.skill                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  STEP 1: Collect Member Information                                 │
│  ├─ Ask: Name, email, GitHub handle                                 │
│  ├─ Ask: Role (Engineer, Designer, PM, etc.)                        │
│  ├─ Ask: Start date                                                 │
│  ├─ Ask: Manager/buddy for onboarding                               │
│  └─ Ask: Teams to join                                              │
│                                                                      │
│  STEP 2: Generate Personalized Onboarding                           │
│  ├─ Load onboarding template for role                               │
│  ├─ Customize checklist based on role                               │
│  ├─ Identify Second Brain docs relevant to role                     │
│  └─ Generate welcome message                                        │
│                                                                      │
│  STEP 3: Execute Invitations                                        │
│  ├─ gh api POST /orgs/{org}/invitations (both orgs)                 │
│  ├─ gh api PUT /orgs/{org}/teams/{team}/memberships/{user}          │
│  ├─ Create GitHub Issue: Onboarding Checklist (@{user})             │
│  └─ Optional: Send email via SMTP or GitHub notification            │
│                                                                      │
│  STEP 4: Track Onboarding Progress                                  │
│  ├─ Monitor onboarding issue for checklist completion               │
│  ├─ Send reminders if stalled (after 3 days)                        │
│  └─ Close issue when complete, notify admin                         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Onboarding Issue Template

**File:** `.github/ISSUE_TEMPLATE/onboarding-checklist.md`

```markdown
---
name: Onboarding Checklist
about: Personalized onboarding for new team member
title: "Onboarding: [NAME]"
labels: onboarding
assignees: [GITHUB_HANDLE]
---

# Welcome to Seven Fortunas, [NAME]! 🎉

Your onboarding checklist is below. Check off items as you complete them.

## Week 1: Getting Started

### GitHub & Tools
- [ ] Accept GitHub org invitations (Seven-Fortunas, Seven-Fortunas-Internal)
- [ ] Set up 2FA on GitHub account
- [ ] Install development tools ([dev-environment-setup.md](link))
- [ ] Clone starter repos: `seven-fortunas-brain`, `project-templates`

### Company Context
- [ ] Read [Mission & Vision](link to culture/mission.md)
- [ ] Read [Values & Ethos](link to culture/values.md)
- [ ] Review [Brand System](link to brand/brand-system.md)
- [ ] Watch company overview video (if available)

### Role-Specific (Engineer)
- [ ] Review [Engineering Best Practices](link)
- [ ] Read [Code Review Guidelines](link)
- [ ] Read [Security Policies](link)
- [ ] Set up local development environment
- [ ] Run test suite successfully

### People
- [ ] Schedule 1:1 with manager: @{MANAGER_HANDLE}
- [ ] Meet your buddy: @{BUDDY_HANDLE}
- [ ] Intro meeting with founding team

## Week 2: First Contributions

- [ ] Complete first PR (could be docs improvement)
- [ ] Attend sprint planning
- [ ] Explore 7F Lens dashboards
- [ ] Provide feedback on onboarding process

---

**Questions?** Reach out to your manager @{MANAGER_HANDLE} or buddy @{BUDDY_HANDLE}
```

---

## GitHub Organization Architecture

### Two-Org Model

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Seven-Fortunas (PUBLIC)                          │
├─────────────────────────────────────────────────────────────────────┤
│  Purpose: Public-facing repos, open-source, showcases               │
│  Visibility: Public                                                  │
│  Access: Founding team + public contributors                         │
│                                                                      │
│  Teams:                                                              │
│  ├─ Public BD (business development, marketing)                     │
│  ├─ Public Marketing (content, campaigns)                           │
│  └─ Public Engineering (open-source maintainers)                    │
│                                                                      │
│  Repositories:                                                       │
│  ├─ .github (org profile, templates, community health files)        │
│  ├─ seven-fortunas.github.io (landing page, hosted on GitHub Pages) │
│  ├─ dashboards (7F Lens - public version)                           │
│  ├─ second-brain-public (sanitized knowledge for public)            │
│  ├─ compliance-framework-public (CISO methodology)                  │
│  └─ opensource-* (tools, examples, utilities for community)         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘

                                 ↑
                          ┌──────┴──────┐
                          │   GitHub    │
                          │   Private   │
                          │   Mirrors   │
                          │   App       │
                          └──────┬──────┘
                                 ↓

┌─────────────────────────────────────────────────────────────────────┐
│                 Seven-Fortunas-Internal (PRIVATE)                    │
├─────────────────────────────────────────────────────────────────────┤
│  Purpose: Internal development, proprietary work, full intelligence │
│  Visibility: Private                                                 │
│  Access: Founding team + employees only                              │
│                                                                      │
│  Teams:                                                              │
│  ├─ BD (business development)                                       │
│  ├─ Marketing (growth, content)                                     │
│  ├─ Engineering (developers, DevOps)                                │
│  ├─ Finance (accounting, legal)                                     │
│  └─ Operations (HR, admin)                                          │
│                                                                      │
│  Repositories:                                                       │
│  ├─ internal-docs (onboarding, processes, policies)                 │
│  ├─ second-brain-core (full knowledge base - NOT sanitized)         │
│  ├─ dashboards-internal (7F Lens - full intelligence, no filters)   │
│  ├─ project-templates (reusable templates for new projects)         │
│  ├─ automation-workflows (GitHub Actions library)                   │
│  ├─ 7f-infrastructure-project (this project's planning artifacts)   │
│  └─ [product repos] (actual development work - EduPeru, etc.)       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Team Structure Design

**Design Principle:** Teams represent **functions**, not products. Products are **repositories within teams**.

**Rationale:**
- ✅ Scales better (10 teams, not 50 orgs)
- ✅ Cross-functional collaboration (BD + Engineering on same product)
- ✅ Follows GitHub best practices
- ✅ Easier permissions management

**Example:** EduPeru product
- Repo: `Seven-Fortunas-Internal/eduperu-backend`
- Teams with access:
  - `Engineering` team (write access)
  - `BD` team (read access for context)
  - `Finance` team (read access for billing context)

### Repository Naming Conventions

**Format:** `{product}-{component}[-{detail}]`

**Examples:**
- `eduperu-backend` (EduPeru backend service)
- `eduperu-frontend-web` (EduPeru web frontend)
- `eduperu-docs` (EduPeru documentation)
- `tokenization-platform-core` (Tokenization platform core library)
- `compliance-framework-public` (CISO Assistant - public version)

**Special Repos:**
- `.github` - Organization defaults (templates, profile)
- `seven-fortunas.github.io` - Website (org name required for GitHub Pages)
- `{product}-docs` - Product-specific documentation
- `project-templates` - Reusable templates

### Security Policies

**Organization-Level Settings:**

```yaml
security:
  two_factor_requirement: true  # All members MUST have 2FA
  default_repository_permission: "none"  # Teams must be explicitly granted access

  dependabot:
    enabled: true
    security_updates: true
    version_updates: true

  secret_scanning:
    enabled: true  # Automatically enabled on public repos
    push_protection: true  # Block commits with secrets

  advanced_security:  # Enterprise tier only
    code_scanning: false  # Not available on free tier

branch_protection:
  default_branch: "main"
  required_reviews: 1  # Require at least 1 approval
  require_code_owner_review: false  # Not enforceable on free tier
  dismiss_stale_reviews: true
  require_conversation_resolution: true

actions:
  allowed_actions: "selected"  # Only allow approved actions
  allow_github_actions: true
  allow_verified_creator: true
```

**Implementation:**
- Use `7f-github-org-configurator` skill to apply these settings
- Document policies in `internal-docs/security-policies.md`
- Manual enforcement on free tier (automated on Enterprise)

---

## Second Brain Architecture

### Progressive Disclosure Model

**Principle:** Load information just-in-time, not all-at-once.

**Inspiration:** `/home/ladmin/dev/claude-code-second-brain-skills/`

**Architecture:**

```
second-brain-core/  (Private repo in Seven-Fortunas-Internal)
│
├── index.md                         # Hub - Table of contents with descriptions
│                                    # AI agents load this FIRST
│
├── brand/                           # Brand identity
│   ├── brand.json                  # Structured data (colors, fonts, assets)
│   ├── brand-system.md             # Design philosophy, usage guidelines
│   ├── tone-of-voice.md            # Communication style, examples
│   └── assets/                     # Logos, icons, images
│       ├── logo.svg
│       ├── logo.png
│       ├── icon.svg
│       └── favicon.ico
│
├── culture/                         # Company culture
│   ├── mission.md                  # Mission statement (problem to solve)
│   ├── vision.md                   # Vision (future state)
│   ├── values.md                   # Core values with explanations
│   ├── ethos.md                    # Operating principles
│   └── decision-frameworks/        # How we make decisions
│       ├── RFC-template.md
│       └── ADR-template.md
│
├── domain-expertise/                # Business domain knowledge
│   ├── tokenization/
│   │   ├── overview.md             # What is tokenization?
│   │   ├── use-cases.md            # Real-world applications
│   │   ├── regulations.md          # Compliance requirements
│   │   └── competitors.md          # Competitive landscape
│   │
│   ├── education-peru/
│   │   ├── market-analysis.md      # EduPeru market
│   │   ├── customer-segments.md    # Personas
│   │   ├── competitors.md          # Existing solutions
│   │   └── opportunities.md        # White space
│   │
│   ├── compliance/
│   │   ├── ciso-assistant.md       # CISO Assistant methodology
│   │   ├── frameworks.md           # SOC2, ISO 27001, etc.
│   │   └── automation.md           # How we automate compliance
│   │
│   └── airgap-security/
│       ├── signing-protocol.md     # Multi-party signing
│       └── best-practices.md       # Security best practices
│
├── best-practices/                  # Engineering and operations
│   ├── engineering/
│   │   ├── code-review.md          # How we review code
│   │   ├── testing.md              # Testing philosophy
│   │   ├── security.md             # Security practices
│   │   └── git-workflow.md         # Branching strategy
│   │
│   └── operations/
│       ├── incident-response.md    # How we handle incidents
│       ├── on-call.md              # On-call rotation
│       └── runbooks/
│           ├── deploy-service.md
│           └── rollback.md
│
└── skills/                          # BMAD skills (custom content generation)
    ├── investor-pitch-generator.skill
    ├── compliance-doc-generator.skill
    ├── technical-spec-creator.skill
    └── README.md                   # How to use skills
```

### Index.md Design

**Purpose:** Entry point for AI agents and humans. Describes what's in the Second Brain without overwhelming with content.

**Example:**

```markdown
# Seven Fortunas Second Brain

This is the central knowledge repository for Seven Fortunas. Content is organized by category for progressive disclosure.

## Quick Links

**New Team Members:** Start with [Culture](#culture) → [Domain Expertise](#domain-expertise) → [Best Practices](#best-practices)

**AI Agents:** Load specific sections as needed based on task context.

---

## Brand

Company brand identity, visual design system, and communication guidelines.

**When to load:**
- Generating any customer-facing content (website, pitch deck, docs)
- Creating new GitHub templates
- Designing UIs or marketing materials

**Key Files:**
- [brand/brand.json](brand/brand.json) - Structured data (colors, fonts, assets)
- [brand/brand-system.md](brand/brand-system.md) - Design philosophy
- [brand/tone-of-voice.md](brand/tone-of-voice.md) - How we communicate

---

## Culture

Mission, vision, values, and decision frameworks.

**When to load:**
- Onboarding new team members
- Making strategic decisions (RFCs, ADRs)
- Creating culture-related content

**Key Files:**
- [culture/mission.md](culture/mission.md) - Our mission (why we exist)
- [culture/values.md](culture/values.md) - Core values and principles
- [culture/decision-frameworks/](culture/decision-frameworks/) - How we decide

---

## Domain Expertise

Deep knowledge about our business domains (tokenization, education, compliance, security).

**When to load:**
- Working on domain-specific products
- Researching competitive landscape
- Creating domain-specific documentation

**Domains:**
- [Tokenization](domain-expertise/tokenization/) - Asset tokenization, regulations
- [Education Peru](domain-expertise/education-peru/) - EduPeru market, competitors
- [Compliance](domain-expertise/compliance/) - CISO Assistant, frameworks
- [Airgap Security](domain-expertise/airgap-security/) - Multi-party signing

---

## Best Practices

Engineering and operations guidelines.

**When to load:**
- Reviewing code or architecture
- Setting up new services
- Responding to incidents

**Categories:**
- [Engineering](best-practices/engineering/) - Code review, testing, security
- [Operations](best-practices/operations/) - Incident response, on-call, runbooks

---

## Skills

BMAD skills for generating content using Seven Fortunas context.

**When to load:**
- Generating investor pitch decks
- Creating compliance documentation
- Writing technical specifications

**Available Skills:**
- [investor-pitch-generator.skill](skills/investor-pitch-generator.skill)
- [compliance-doc-generator.skill](skills/compliance-doc-generator.skill)
- [technical-spec-creator.skill](skills/technical-spec-creator.skill)
```

### MCP Server Integration (Future)

**Purpose:** Allow AI agents (Claude Desktop, custom agents) to query Second Brain via MCP protocol.

**Architecture:**

```
┌─────────────────────────────────────────────────────────────────────┐
│                        AI Agent (Claude Desktop)                     │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓ MCP Protocol
┌─────────────────────────────────────────────────────────────────────┐
│                    MCP Server (Python/TypeScript)                    │
├─────────────────────────────────────────────────────────────────────┤
│  Endpoints:                                                          │
│  ├─ /search?query={query} - Semantic search across Second Brain     │
│  ├─ /read?path={path} - Read specific document                      │
│  ├─ /list?category={cat} - List documents in category               │
│  └─ /skill?name={skill} - Execute BMAD skill                        │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓ File System Access
┌─────────────────────────────────────────────────────────────────────┐
│         second-brain-core/ (Git Repo - Cloned Locally)               │
└─────────────────────────────────────────────────────────────────────┘
```

**Implementation** (Phase 2):
- Python MCP server using `anthropic-sdk-python`
- Vector embeddings for semantic search (using Claude API)
- Git sync (auto-pull updates from GitHub)

---

## 7F Lens Dashboard Architecture

### Data Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                        DATA SOURCES (External)                       │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │  RSS Feeds   │  │  GitHub API  │  │  Reddit JSON │             │
│  │  (XML)       │  │  (REST)      │  │  (JSON)      │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │  YouTube RSS │  │  X API       │  │  Web Scraping│             │
│  │  (XML)       │  │  (REST)      │  │  (Phase 2)   │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│               AGGREGATION (GitHub Actions - Scheduled)               │
├─────────────────────────────────────────────────────────────────────┤
│  Script: .github/workflows/update-dashboard-ai.yml                  │
│  Frequency: Every 6 hours (configurable via dashboard-configurator) │
│                                                                      │
│  Steps:                                                              │
│  1. Fetch all sources (RSS, Reddit, GitHub, YouTube, X)             │
│  2. Parse and normalize data                                        │
│  3. Deduplicate (by title, URL, or content hash)                    │
│  4. Filter by keywords (from dashboards/ai/config/sources.yaml)     │
│  5. Sort by date (newest first)                                     │
│  6. Limit to max_items (default: 100)                               │
│  7. Save to dashboards/ai/data/latest.json                          │
│  8. Commit to repo (auto-commit)                                    │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│               AI PROCESSING (Claude API - Weekly)                    │
├─────────────────────────────────────────────────────────────────────┤
│  Script: .github/workflows/weekly-ai-summary.yml                    │
│  Frequency: Every Sunday at 9am UTC                                 │
│                                                                      │
│  Steps:                                                              │
│  1. Load dashboards/ai/data/latest.json                             │
│  2. Send to Claude API with prompt:                                 │
│     "Summarize top 10 developments in AI this week.                 │
│      Focus on: models, research breakthroughs, tools, regulations.  │
│      Relevance to Seven Fortunas mission (digital inclusion)."      │
│  3. Receive Claude's summary (markdown)                             │
│  4. Save to dashboards/ai/summaries/YYYY-MM-DD.md                   │
│  5. Update dashboards/ai/README.md with latest summary              │
│  6. Commit to repo                                                  │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│                   DISPLAY (GitHub Pages / README)                    │
├─────────────────────────────────────────────────────────────────────┤
│  dashboards/ai/README.md (Auto-generated)                           │
│                                                                      │
│  Sections:                                                           │
│  ├─ Weekly Summary (AI-generated, top of page)                      │
│  ├─ Latest Updates (table: title, source, date, link)               │
│  ├─ Trending Topics (word cloud or tag cloud)                       │
│  ├─ Historical Summaries (links to past weeks)                      │
│  └─ Data Sources (list of RSS feeds, Reddit, etc.)                  │
│                                                                      │
│  Rendering:                                                          │
│  ├─ GitHub repo view (README.md automatically rendered)             │
│  ├─ GitHub Pages (seven-fortunas.github.io/dashboards/ai/)          │
│  └─ RSS feed (dashboards/ai/rss.xml - Phase 2)                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Dashboard Directory Structure

```
dashboards/
├── ai/                              # AI Advancements Dashboard (MVP)
│   ├── README.md                   # Main dashboard (auto-generated)
│   ├── config/
│   │   └── sources.yaml            # Data sources configuration
│   ├── data/
│   │   ├── latest.json             # Current aggregated data
│   │   └── archive/                # Historical snapshots (weekly)
│   │       ├── 2026-02-03.json
│   │       └── 2026-02-10.json
│   ├── summaries/                  # AI-generated weekly summaries
│   │   ├── 2026-02-10.md
│   │   └── 2026-02-17.md
│   └── scripts/
│       ├── fetch_sources.py        # Aggregation script
│       └── generate_summary.py     # Claude API integration
│
├── fintech/                         # Fintech Trends Dashboard (Phase 2)
│   └── [same structure as ai/]
│
├── edutech/                         # EduTech Dashboard (Phase 2)
│   └── [same structure as ai/]
│
└── security/                        # Security Intelligence (Phase 2)
    └── [same structure as ai/]
```

### AI Dashboard - Data Schema

**File:** `dashboards/ai/data/latest.json`

```json
{
  "metadata": {
    "generated_at": "2026-02-10T14:30:00Z",
    "source_count": 15,
    "item_count": 98,
    "update_frequency": "6h"
  },
  "items": [
    {
      "id": "sha256_hash_of_content",
      "title": "GPT-5 Released with Multimodal Capabilities",
      "source": "OpenAI Blog",
      "source_type": "rss",
      "url": "https://openai.com/blog/gpt-5-release",
      "published_at": "2026-02-10T10:00:00Z",
      "summary": "OpenAI announces GPT-5 with native image, audio, and video understanding...",
      "keywords": ["GPT-5", "multimodal", "release"],
      "relevance_score": 0.95,
      "category": "model_release"
    },
    {
      "id": "...",
      "title": "New Research: Constitutional AI for Safer Models",
      "source": "Anthropic Blog",
      "source_type": "rss",
      "url": "https://anthropic.com/research/constitutional-ai",
      "published_at": "2026-02-09T15:00:00Z",
      "summary": "Anthropic publishes new research on training AI models to be harmless...",
      "keywords": ["AI safety", "research", "constitutional AI"],
      "relevance_score": 0.88,
      "category": "research"
    },
    ...
  ],
  "trending_topics": [
    {"topic": "multimodal models", "count": 12},
    {"topic": "AI safety", "count": 8},
    {"topic": "open source LLMs", "count": 7}
  ]
}
```

### GitHub Search Skill Architecture

**Purpose:** Help team members find information across GitHub organizations using semantic search.

#### Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│              7f-github-org-search.skill                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  STEP 1: Accept Search Query                                        │
│  ├─ User input: Natural language query                              │
│  ├─ Example: "How do we handle code reviews?"                       │
│  └─ Example: "Find EduPeru backend deployment docs"                 │
│                                                                      │
│  STEP 2: Query Understanding (Claude API)                           │
│  ├─ Send query to Claude for intent extraction                      │
│  ├─ Extract: Keywords, search scope, result type                    │
│  └─ Example output: {keywords: ["code review"], scope: "docs",      │
│                       type: "markdown"}                              │
│                                                                      │
│  STEP 3: Multi-Source Search                                        │
│  ├─ GitHub Code Search API:                                         │
│  │   gh api /search/code?q={keywords}+org:Seven-Fortunas            │
│  ├─ GitHub Issues Search:                                           │
│  │   gh api /search/issues?q={keywords}+org:Seven-Fortunas          │
│  ├─ GitHub Discussions:                                             │
│  │   gh api /search/discussions?q={keywords}                        │
│  └─ Second Brain (local grep):                                      │
│      grep -r "{keywords}" second-brain-core/                        │
│                                                                      │
│  STEP 4: Rank Results                                               │
│  ├─ Score by relevance (keyword match density)                      │
│  ├─ Boost recent results (recency bias)                             │
│  ├─ Boost official docs (best-practices/ > random issues)           │
│  └─ Top 10 results                                                  │
│                                                                      │
│  STEP 5: Present Results                                            │
│  ├─ Markdown table:                                                 │
│  │   | Title | Location | Type | Link |                             │
│  ├─ Snippets showing keyword context                                │
│  └─ Suggest related searches                                        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Implementation Example

```python
# 7f-github-org-search/search.py

import subprocess
import json
from anthropic import Anthropic

client = Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])

def search_github_org(query: str):
    """Search across Seven Fortunas GitHub organizations"""

    # Step 1: Understand query intent
    intent = understand_query(query)

    # Step 2: Search multiple sources
    code_results = search_code(intent['keywords'])
    issue_results = search_issues(intent['keywords'])
    brain_results = search_second_brain(intent['keywords'])

    # Step 3: Rank and merge
    all_results = rank_results(code_results + issue_results + brain_results)

    # Step 4: Present
    return format_results(all_results[:10])

def understand_query(query: str) -> dict:
    """Use Claude to extract intent from natural language query"""
    message = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=200,
        messages=[{
            "role": "user",
            "content": f"""Extract search intent from this query: "{query}"

            Return JSON with:
            - keywords: list of search terms
            - scope: "code", "docs", "issues", "all"
            - type: "markdown", "python", "yaml", "any"

            Example: "How do we handle code reviews?"
            Output: {{"keywords": ["code review", "guidelines"], "scope": "docs", "type": "markdown"}}
            """
        }]
    )
    return json.loads(message.content[0].text)

def search_code(keywords: list[str]) -> list[dict]:
    """Search code using GitHub API"""
    query = " ".join(keywords) + " org:Seven-Fortunas OR org:Seven-Fortunas-Internal"
    result = subprocess.run(
        ["gh", "api", f"/search/code?q={query}"],
        capture_output=True, text=True
    )
    data = json.loads(result.stdout)
    return data.get("items", [])

def search_second_brain(keywords: list[str]) -> list[dict]:
    """Search local Second Brain using grep"""
    results = []
    for keyword in keywords:
        result = subprocess.run(
            ["grep", "-r", "-i", "--include=*.md", keyword, "second-brain-core/"],
            capture_output=True, text=True
        )
        # Parse grep output into structured results
        for line in result.stdout.split("\n"):
            if line:
                file_path, match = line.split(":", 1)
                results.append({
                    "title": file_path.replace("second-brain-core/", ""),
                    "path": file_path,
                    "snippet": match[:100],
                    "type": "second_brain"
                })
    return results

# ... rest of implementation
```

---

## Security Architecture

### Security Layers

```
┌─────────────────────────────────────────────────────────────────────┐
│                      LAYER 1: Access Control                         │
├─────────────────────────────────────────────────────────────────────┤
│  • Organization-level 2FA requirement (enforced)                    │
│  • Team-based permissions (least privilege)                         │
│  • Default repo permission: none (must grant explicitly)            │
│  • GitHub App for automation (scoped permissions)                   │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│                   LAYER 2: Code Security                             │
├─────────────────────────────────────────────────────────────────────┤
│  • Dependabot (dependency vulnerability scanning)                   │
│  • Secret scanning (detect leaked credentials)                      │
│  • Push protection (block commits with secrets)                     │
│  • Branch protection (require reviews, no force push to main)       │
│  • Signed commits (optional but recommended)                        │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│                  LAYER 3: Workflow Security                          │
├─────────────────────────────────────────────────────────────────────┤
│  • GitHub Actions: Only allow approved actions                      │
│  • Secrets management: Use GitHub Secrets, never hardcode           │
│  • Workflow permissions: Minimal required scopes                    │
│  • OIDC for cloud auth (no long-lived credentials)                  │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│                  LAYER 4: Data Security                              │
├─────────────────────────────────────────────────────────────────────┤
│  • Private repos for sensitive data                                 │
│  • Encrypt secrets at rest (GitHub Secrets)                         │
│  • Encrypt secrets in transit (TLS)                                 │
│  • API keys: Rotate regularly, scope minimally                      │
│  • Data classification (public, internal, confidential, restricted) │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│                  LAYER 5: Monitoring & Response                      │
├─────────────────────────────────────────────────────────────────────┤
│  • Audit logs (Enterprise tier - Phase 3)                           │
│  • Security alerts (Dependabot, secret scanning)                    │
│  • Incident response plan (runbooks in Second Brain)                │
│  • Regular security reviews (quarterly)                             │
└─────────────────────────────────────────────────────────────────────┘
```

### Threat Model

| Threat | Mitigation | Residual Risk |
|--------|------------|---------------|
| **Leaked API Keys** | Secret scanning, push protection, rotation | Low (automated detection) |
| **Dependency Vulnerabilities** | Dependabot auto-updates, security alerts | Low (auto-patching) |
| **Unauthorized Access** | 2FA, team permissions, audit logs | Low (strong access controls) |
| **Malicious Code in PR** | Required reviews, branch protection | Medium (human review required) |
| **Insider Threat** | Audit logging, least privilege | Medium (hard to prevent fully) |
| **GitHub Compromise** | Use OIDC, don't store credentials | Low (GitHub's security responsibility) |

### Data Classification

| Classification | Examples | Storage | Access |
|----------------|----------|---------|--------|
| **Public** | Open-source code, blog posts, showcase repos | Public GitHub repos | Anyone |
| **Internal** | Company docs, processes, non-sensitive product code | Private GitHub repos | All employees |
| **Confidential** | Customer data, financial info, security vulnerabilities | Private repos + encrypted | Need-to-know |
| **Restricted** | Legal docs, unreleased M&A, HR records | Encrypted external storage (not GitHub) | Executive only |

**Rule:** GitHub is appropriate for Public, Internal, and Confidential data. Restricted data should NOT be stored in GitHub (use encrypted cloud storage with audit logging).

---

## Deployment Architecture

### Phase 1 (MVP): GitHub Free Tier

```
┌─────────────────────────────────────────────────────────────────────┐
│                          GITHUB.COM                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Seven-Fortunas (Public Org)                                        │
│  ├─ Public repos (unlimited)                                        │
│  ├─ GitHub Actions: Unlimited minutes (public repos)                │
│  └─ GitHub Pages: seven-fortunas.github.io (free)                   │
│                                                                      │
│  Seven-Fortunas-Internal (Private Org)                              │
│  ├─ Private repos (unlimited)                                       │
│  ├─ GitHub Actions: 2,000 minutes/month (private repos)             │
│  └─ No GitHub Pages (private orgs can't publish pages on free tier) │
│                                                                      │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│                      EXTERNAL SERVICES                               │
├─────────────────────────────────────────────────────────────────────┤
│  • Anthropic API (Claude) - ~$0.05-5/month                          │
│  • X API (optional) - $100/month (personal account)                 │
│  • GitHub API - Free (included in free tier)                        │
└─────────────────────────────────────────────────────────────────────┘
```

**Cost:** $0-5/month (excluding optional X API)

**Constraints:**
- 2,000 Actions minutes/month for private repos
- No advanced security features (CodeQL on private repos)
- No required reviewers enforcement
- No audit logs

**Mitigation:**
- Use public repos for dashboards (unlimited Actions)
- Document policies even if not technically enforced
- Manual security reviews

### Phase 2: GitHub Free Tier + Expansions

**Additions:**
- More dashboards (fintech, edutech, security)
- Obsidian vault for Second Brain visualization
- GitHub Private Mirrors App (selective publishing)

**Cost:** $5-15/month (more Claude API usage)

### Phase 3: GitHub Enterprise

```
┌─────────────────────────────────────────────────────────────────────┐
│                    GITHUB ENTERPRISE CLOUD                           │
├─────────────────────────────────────────────────────────────────────┤
│  • All free tier features                                           │
│  • Advanced Security (CodeQL, secret scanning with custom patterns) │
│  • Audit Log API (compliance tracking)                              │
│  • SAML SSO (enterprise identity)                                   │
│  • Required reviewers (enforced policies)                           │
│  • 50,000 Actions minutes/month (can purchase more)                 │
│  • SOC1/SOC2 reports (for customer audits)                          │
│                                                                      │
│  Cost: $21/user/month (50 users = $1,050/month)                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Trigger for upgrade:**
- Series A funding closes
- Enterprise sales conversations begin (SOC2 requirement)
- Team grows beyond 20 people (cost becomes reasonable)

---

## Data Architecture

### Data Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        DATA SOURCES                                  │
├─────────────────────────────────────────────────────────────────────┤
│  RSS Feeds, Reddit, GitHub, YouTube, X API, Web Scraping            │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓ Fetch every 6 hours
┌─────────────────────────────────────────────────────────────────────┐
│                      RAW DATA STORAGE                                │
├─────────────────────────────────────────────────────────────────────┤
│  dashboards/{dashboard}/data/raw-{timestamp}.json                   │
│  (Ephemeral - only kept for debugging)                              │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓ Deduplicate, filter, normalize
┌─────────────────────────────────────────────────────────────────────┐
│                   PROCESSED DATA STORAGE                             │
├─────────────────────────────────────────────────────────────────────┤
│  dashboards/{dashboard}/data/latest.json                            │
│  (Current snapshot - overwritten every 6 hours)                     │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓ Archive weekly
┌─────────────────────────────────────────────────────────────────────┐
│                    HISTORICAL DATA STORAGE                           │
├─────────────────────────────────────────────────────────────────────┤
│  dashboards/{dashboard}/data/archive/{YYYY-MM-DD}.json              │
│  (Weekly snapshots - kept for trend analysis)                       │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓ Summarize weekly with Claude
┌─────────────────────────────────────────────────────────────────────┐
│                       AI SUMMARIES                                   │
├─────────────────────────────────────────────────────────────────────┤
│  dashboards/{dashboard}/summaries/{YYYY-MM-DD}.md                   │
│  (Human-readable AI-generated insights)                             │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓ Display
┌─────────────────────────────────────────────────────────────────────┐
│                         DASHBOARD UI                                 │
├─────────────────────────────────────────────────────────────────────┤
│  dashboards/{dashboard}/README.md (Auto-generated from latest.json) │
└─────────────────────────────────────────────────────────────────────┘
```

### Data Retention

| Data Type | Retention | Rationale |
|-----------|-----------|-----------|
| **Raw data** | 7 days | Debugging only, takes space |
| **Processed data (latest)** | Overwritten every 6h | Current snapshot |
| **Historical archives** | 52 weeks (1 year) | Trend analysis |
| **AI summaries** | Indefinite | Small size, high value |
| **Second Brain docs** | Indefinite (version controlled) | Knowledge base |

### Data Backup

**GitHub as primary storage:**
- All data committed to Git
- GitHub provides redundancy and backups
- No separate backup needed for MVP

**Phase 2 backup strategy:**
- Periodic export to S3 or Google Cloud Storage
- Automated weekly backups
- Cost: ~$1-5/month for storage

---

## Architectural Decision Records (ADRs)

### ADR-001: Two-Org Model vs. Multiple Orgs

**Status:** Accepted

**Context:**
- Need to separate public and private work
- Could use: (A) One org, (B) Two orgs (public/private), (C) Multiple orgs per function

**Decision:** Two organizations (Seven-Fortunas public, Seven-Fortunas-Internal private)

**Rationale:**
- ✅ Clear security boundary (public vs. private)
- ✅ GitHub best practice (minimize orgs)
- ✅ Teams for cross-functional collaboration (not orgs per function)
- ✅ Scales better (10 teams, not 50 orgs)
- ✅ Easier permissions management

**Consequences:**
- Must use teams for access control (not org membership)
- GitHub Private Mirrors App needed for selective publishing
- More complexity than single org, but manageable

---

### ADR-002: Progressive Disclosure for Second Brain

**Status:** Accepted

**Context:**
- Need knowledge base accessible to AI agents
- Could use: (A) All-in-one doc, (B) Separate docs loaded all at once, (C) Progressive disclosure

**Decision:** Progressive disclosure - Load index.md first, load specific sections as needed

**Rationale:**
- ✅ Reduces token usage (load only what's needed)
- ✅ Faster for AI agents (less parsing)
- ✅ Scalable (can grow without overwhelming context)
- ✅ Obsidian-compatible (can visualize graph)

**Consequences:**
- AI agents must use two-step process (index → specific doc)
- More files to manage (vs. monolithic doc)
- Worth the tradeoff for scalability

---

### ADR-003: GitHub Actions for Dashboard Aggregation

**Status:** Accepted

**Context:**
- Need automated data aggregation for dashboards
- Could use: (A) External service (Zapier, n8n), (B) GitHub Actions, (C) Cloud Functions (AWS Lambda)

**Decision:** GitHub Actions (scheduled workflows)

**Rationale:**
- ✅ Free on public repos (unlimited minutes)
- ✅ Co-located with code (no separate infra)
- ✅ Built-in secrets management
- ✅ Easy to debug (logs in GitHub UI)
- ✅ Auto-commit results to repo

**Consequences:**
- 2,000 minute/month limit on private repos (use public repos for dashboards)
- More complex than external service (but free)

---

### ADR-004: Skill-Creation Skill (Meta-Skill)

**Status:** Accepted

**Context:**
- Need to create 5+ BMAD skills for self-service
- Could use: (A) Manual creation, (B) Templates + manual filling, (C) Meta-skill auto-generation

**Decision:** Meta-skill that generates other skills from requirements

**Rationale:**
- ✅ DRY (don't repeat boilerplate for each skill)
- ✅ Consistent structure (all skills follow same pattern)
- ✅ Faster iteration (generate, test, refine)
- ✅ Self-improving (meta-skill can improve itself)

**Consequences:**
- Upfront complexity (must build meta-skill first)
- Philosophical question (how to bootstrap? Answer: manual v1, then self-improve)
- Worth it for 5+ skills

---

### ADR-005: Personal API Keys (MVP) → Corporate Keys (Post-Funding)

**Status:** Accepted

**Context:**
- Need API keys for X and Claude
- Could use: (A) Personal keys, (B) Corporate keys, (C) Wait until corporate keys available

**Decision:** Personal keys for MVP (with authorization), migrate to corporate post-funding

**Rationale:**
- ✅ Unblocks MVP (don't wait for corporate accounts)
- ✅ Lower cost for MVP ($100/month personal X vs. $42k/year enterprise)
- ✅ Clear migration path
- ✅ Legally acceptable (personal account with authorization from account owner)

**Consequences:**
- Must document in API key registry
- Must monitor usage (respect account owner's limits)
- Must migrate post-funding (plan for this)

---

## Technology Stack

### Core Technologies

| Layer | Technology | Rationale |
|-------|------------|-----------|
| **Hosting & Storage** | GitHub | Free, version controlled, familiar |
| **Website** | GitHub Pages | Free, automatic deployment |
| **Automation** | GitHub Actions | Free on public repos, integrated |
| **AI Processing** | Claude API (Anthropic) | Best-in-class summarization, Seven Fortunas has relationship |
| **Second Brain** | Markdown + Git | Simple, version controlled, AI-friendly |
| **Visualization (Phase 2)** | Obsidian | Markdown-native, graph view, mobile app |
| **Search** | GitHub Search API + local grep | Good enough for MVP, can add vector search later |

### Languages & Frameworks

| Purpose | Language/Framework | Rationale |
|---------|-------------------|-----------|
| **Aggregation Scripts** | Python 3.11+ | Great for data processing, rich ecosystem |
| **BMAD Skills** | Markdown + YAML + Python | Simple, declarative, AI-agent friendly |
| **Website** | HTML + CSS (minimal JS) | Static site, fast load, accessible |
| **Dashboards** | Auto-generated Markdown | GitHub renders beautifully, no build step |

### Dependencies (Python)

```txt
# requirements.txt (for dashboard aggregation)

feedparser==6.0.10          # RSS feed parsing
praw==7.7.0                 # Reddit API (if using)
anthropic==0.39.0           # Claude API
requests==2.31.0            # HTTP requests
pyyaml==6.0.1               # YAML parsing
python-dotenv==1.0.0        # Environment variables
```

### GitHub Actions Workflow Example

**File:** `.github/workflows/update-dashboard-ai.yml`

```yaml
name: Update AI Dashboard

on:
  schedule:
    - cron: "0 */6 * * *"  # Every 6 hours
  workflow_dispatch:        # Manual trigger

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install dependencies
        run: |
          cd dashboards/ai/scripts
          pip install -r requirements.txt

      - name: Fetch and aggregate data
        env:
          X_API_BEARER_TOKEN: ${{ secrets.X_API_BEARER_TOKEN_HENRY }}
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY_JORGE }}
        run: |
          cd dashboards/ai/scripts
          python fetch_sources.py

      - name: Commit updated data
        run: |
          git config --global user.name "7F Dashboard Bot"
          git config --global user.email "bot@sevenfortunas.com"
          git add dashboards/ai/data/latest.json
          git add dashboards/ai/README.md
          git commit -m "Update AI dashboard data [automated]" || echo "No changes"
          git push
```

---

## Integration Points

### GitHub API Integration

**Authentication:** Personal Access Token (PAT) or GitHub App

**Required Scopes:**
- `repo` - Full control of private repos
- `admin:org` - Manage organizations
- `workflow` - Manage GitHub Actions workflows

**Example API Calls:**

```bash
# Create organization team
gh api --method POST /orgs/Seven-Fortunas/teams \
  -f name="Engineering" \
  -f description="Engineering team" \
  -f privacy="closed"

# List organization members
gh api /orgs/Seven-Fortunas/members

# Get repository
gh api /repos/Seven-Fortunas/seven-fortunas.github.io

# Search code
gh api "/search/code?q=authentication+org:Seven-Fortunas"
```

### Claude API Integration

**Authentication:** API key (stored in GitHub Secrets)

**Usage Pattern:**

```python
from anthropic import Anthropic

client = Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=2000,
    messages=[{
        "role": "user",
        "content": "Summarize these AI developments..."
    }]
)

summary = message.content[0].text
```

**Rate Limits:**
- Standard tier: 50 requests/minute, 40,000 requests/day
- MVP usage: ~10 requests/week (weekly summaries)

**Cost:** ~$0.05-5/month depending on usage

### External Data Source Integration

| Source | Protocol | Authentication | Rate Limit |
|--------|----------|----------------|------------|
| **RSS Feeds** | HTTP GET | None | Unlimited (respect caching headers) |
| **Reddit JSON** | HTTP GET | None | ~60 requests/minute (no auth) |
| **YouTube RSS** | HTTP GET | None | Unlimited |
| **GitHub API** | REST | PAT or GitHub App | 5,000 requests/hour |
| **X API** | REST | Bearer token | 500 requests/month (Free), 10,000 (Basic $100/mo) |

---

## Scalability & Performance

### Current Scale (MVP)

- 4 founding team members
- 2 organizations
- ~10 repositories
- 1 dashboard (AI)
- ~100 data points aggregated every 6 hours

**Performance:**
- Dashboard update: <2 minutes
- Second Brain search: <1 second
- GitHub Actions: <5 minutes per workflow

### Phase 2 Scale

- 10-20 team members
- 2 organizations
- ~30 repositories
- 5 dashboards (AI, fintech, edutech, security, productivity)
- ~500 data points aggregated every 6 hours

**Performance:**
- Dashboard update: <10 minutes
- Second Brain search: <2 seconds (with vector embeddings)
- GitHub Actions: <15 minutes per workflow (parallelized)

### Phase 3 Scale (Enterprise)

- 50-100 team members
- 2 organizations
- ~100 repositories
- 10 dashboards
- ~2,000 data points aggregated every 6 hours

**Performance:**
- Dashboard update: <30 minutes (with caching)
- Second Brain search: <1 second (vector database)
- GitHub Actions: <20 minutes (parallel + distributed)

**Scaling Strategies:**
- Parallel aggregation (fetch sources concurrently)
- Caching (cache unchanged data sources)
- Vector search (replace grep with semantic search)
- Distributed workflows (split aggregation across jobs)

### Bottlenecks & Mitigation

| Bottleneck | Impact | Mitigation |
|------------|--------|------------|
| **GitHub Actions minutes** | Limited to 2,000/month on private repos | Use public repos for dashboards |
| **Claude API cost** | ~$5/month MVP, $50-100/month at scale | Cache summaries, batch requests |
| **Data source rate limits** | X API: 500 requests/month (Free) | Upgrade to Basic ($100/mo) or cache |
| **Git repo size** | Large JSON files bloat repo | Archive old data, use Git LFS |
| **Search performance** | grep slow on large Second Brain | Use vector embeddings (Anthropic API) |

---

## Disaster Recovery

### Backup Strategy

**Primary:** Git version control
- All code, docs, data committed to Git
- GitHub provides redundancy (multiple datacenters)
- Every clone is a backup

**Secondary (Phase 2):** Cloud storage backup
- Weekly export to S3 or Google Cloud Storage
- Automated via GitHub Actions
- Cost: ~$1-5/month

### Recovery Scenarios

| Scenario | Impact | Recovery Time | Recovery Steps |
|----------|--------|---------------|----------------|
| **Accidental deletion of repo** | High | <5 minutes | Restore from GitHub (30-day trash), or clone from local |
| **Bad commit pushed** | Medium | <2 minutes | `git revert` or `git reset --hard` |
| **GitHub outage** | Medium | Wait for GitHub | Work locally, push when restored |
| **Lost API key** | Medium | <10 minutes | Rotate key in service, update GitHub Secret |
| **Malicious actor deletes orgs** | High | <1 day | Recreate orgs, push from local clones, restore settings |
| **Data corruption** | Low | <5 minutes | Roll back to last good commit |

### Business Continuity

**Critical Systems:**
- GitHub organizations (backup: local clones)
- Second Brain (backup: Git + weekly cloud export)
- Dashboards (backup: Git, data is regenerated every 6 hours)

**RTO (Recovery Time Objective):** <4 hours for critical systems
**RPO (Recovery Point Objective):** <6 hours (last data aggregation)

---

## Open Questions

### For Leadership

1. **API Key Approval:** Confirm Henry's approval to use his X API credentials for MVP
2. **Branding Timeline:** Confirm Henry has bandwidth Days 1-3 to define branding
3. **Funding Timeline:** When is Series A expected? (Determines when to upgrade to Enterprise)

### For Technical Team

4. **GitHub Private Mirrors App:** Should we deploy our own instance or use hosted version?
5. **Second Brain MCP Server:** Should we build MCP server in Phase 2, or wait until Phase 3?
6. **Vector Search:** When should we add vector embeddings for search? (Phase 2 or 3?)

### For Product Team

7. **Dashboard Priorities (Phase 2):** Which dashboard after AI? (Fintech, EduTech, or Security?)
8. **Public Content Strategy:** What percentage of Second Brain should be public? (10%? 30%?)
9. **Obsidian vs. Alternatives:** Should we evaluate Notion, Confluence, or other tools?

---

## Appendix

### Reference Implementations

- **Second Brain Example:** `/home/ladmin/dev/claude-code-second-brain-skills/`
- **Autonomous Agent Example:** `/home/ladmin/dev/GDF/airgap_signing_bmad/airgap-autonomous/`
- **GitHub Org Best Practices:** https://docs.github.com/en/enterprise-cloud@latest/admin/concepts/best-practices
- **BMAD Methodology:** `_bmad/` directory in this project

### Further Reading

- [C4 Model for Software Architecture](https://c4model.com/)
- [Architecture Decision Records](https://adr.github.io/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Claude API Documentation](https://docs.anthropic.com/claude/reference/getting-started-with-the-api)
- [Progressive Disclosure in UX](https://www.nngroup.com/articles/progressive-disclosure/)

---

**END OF ARCHITECTURE DOCUMENT**

**Version:** 1.0
**Status:** Draft - Ready for Technical Review
**Next Artifact:** Product Requirements Document (PRD)
**Estimated Review Time:** 60-90 minutes
**Questions/Feedback:** Contact Mary (Business Analyst Agent) or Jorge
