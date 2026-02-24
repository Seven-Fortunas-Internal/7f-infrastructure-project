# BMAD Skills Reference - Seven Fortunas

**Last Updated:** 2026-02-14
**Purpose:** Quick reference for all available BMAD skills in Seven Fortunas Second Brain

---

## Overview

This repository includes 70+ standard BMAD workflows plus **2 custom Seven Fortunas workflows** for autonomous agent implementation.

### How to Use

**Discover available workflows:**
```bash
/bmad-help
```

**Invoke a workflow:**
```bash
/bmad-bmm-create-prd           # Standard BMAD workflow
/bmad-bmm-create-app-spec      # Custom Seven Fortunas workflow
```

---

## Custom Seven Fortunas Workflows

### 1. Create App Spec (`/bmad-bmm-create-app-spec`)

**Purpose:** Transform PRD into `app_spec.txt` - the single source of truth for autonomous coding agents

**When to Use:**
- After completing PRD
- As an **alternative** to Create Epics and Stories
- For autonomous agent implementation (not traditional sprint-based development)

**Pattern:** `PRD → app_spec.txt → Autonomous Agent`

**Agent:** Mary (📊 Business Analyst)
**Phase:** 3-solutioning
**Output:** `app_spec.txt` in planning artifacts

**Key Features:**
- Extracts 28-30 features from PRD
- Categorizes features (Core, User-Facing, Backend, Infrastructure, etc.)
- Provides clear, actionable specifications for autonomous coding agents
- Supports Clean Slate, Evolutionary, and Partial Regeneration modes

---

### 2. Check Autonomous Implementation Readiness (`/bmad-bmm-check-autonomous-implementation-readiness`)

**Purpose:** Validate PRD readiness for autonomous agent implementation by checking app_spec.txt coverage and architecture alignment

**When to Use:**
- After creating app_spec.txt
- As an **alternative** to Check Implementation Readiness (for autonomous workflows)
- Before launching autonomous agent implementation

**Pattern:** `PRD + app_spec.txt + Architecture → Readiness Report`

**Agent:** Winston (🏗️ Architect)
**Phase:** 3-solutioning
**Output:** Readiness report with scoring (0-100)

**Key Features:**
- Validates app_spec.txt coverage (all PRD features included?)
- Checks architecture alignment
- Assesses feature specification quality
- Provides actionable recommendations
- Tri-modal: Create, Edit, Validate modes

---

## Standard BMAD Workflows

For complete list of 70+ standard BMAD workflows, run:

```bash
/bmad-help
```

### Key Standard Workflows (Quick Reference)

#### Analysis Phase (1-analysis)
- **Brainstorm Project** (`/bmad-brainstorming`) - Ideation techniques
- **Market Research** (`/bmad-bmm-market-research`) - Market analysis
- **Create Brief** (`/bmad-bmm-create-product-brief`) - Product brief creation

#### Planning Phase (2-planning)
- **Create PRD** (`/bmad-bmm-create-prd`) - Product Requirements Document
- **Validate PRD** (`/bmad-bmm-validate-prd`) - PRD quality check
- **Create UX** (`/bmad-bmm-create-ux-design`) - UX design workflows

#### Solutioning Phase (3-solutioning)
- **Create Architecture** (`/bmad-bmm-create-architecture`) - Technical architecture
- **Create Epics and Stories** (`/bmad-bmm-create-epics-and-stories`) - Traditional sprint planning
- **Create App Spec** (`/bmad-bmm-create-app-spec`) - 🆕 Autonomous agent alternative
- **Check Implementation Readiness** (`/bmad-bmm-check-implementation-readiness`) - Standard readiness check
- **Check Autonomous Implementation Readiness** (`/bmad-bmm-check-autonomous-implementation-readiness`) - 🆕 Autonomous readiness check

#### Implementation Phase (4-implementation)
- **Sprint Planning** (`/bmad-bmm-sprint-planning`) - Generate sprint plan
- **Create Story** (`/bmad-bmm-create-story`) - Story preparation
- **Dev Story** (`/bmad-bmm-dev-story`) - Story implementation
- **Code Review** (`/bmad-bmm-code-review`) - Quality review
- **QA Automation Test** (`/bmad-bmm-qa-automate`) - Test generation

#### Anytime Utilities
- **Document Project** (`/bmad-bmm-document-project`) - Generate project docs
- **Generate Project Context** (`/bmad-bmm-generate-project-context`) - Create project-context.md
- **Quick Spec** (`/bmad-bmm-quick-spec`) - Fast spec for small tasks
- **Quick Dev** (`/bmad-bmm-quick-dev`) - Rapid implementation without full planning

---

## Workflow Patterns

### Traditional Pattern (Sprint-Based)
```
Product Brief → PRD → Architecture → Epics & Stories → Sprint Planning → Implementation
```

### Autonomous Pattern (Seven Fortunas)
```
Product Brief → PRD → Architecture → app_spec.txt → Autonomous Agent → Implementation
```

**Key Difference:** Replace Epics/Stories + Sprint Planning with app_spec.txt for autonomous agents.

---

## Module Categories

- **BMM** (Business Method Module) - Product, planning, implementation workflows
- **BMB** (Builder Module) - Create workflows, agents, modules
- **CIS** (Creative Intelligence Suite) - Innovation, design thinking, storytelling
- **TEA** (Test Engineering & Automation) - Testing architecture and automation
- **Core** - Universal tools (brainstorming, help, indexing)

---

## Getting Help

**General help:**
```bash
/bmad-help
```

**Workflow-specific help:**
Load any workflow and follow step-by-step instructions.

**Documentation:**
- BMAD official docs: https://bmad.ai/docs
- Seven Fortunas Second Brain: `/docs/` directory
- Project context: See README.md

---

## Contributing

Custom workflows for Seven Fortunas should:
1. Be placed in appropriate BMAD module directory
2. Follow BMAD workflow architecture (step-file design, tri-modal structure)
3. Be registered in both:
   - Module-level: `_bmad/{module}/module-help.csv`
   - Global: `_bmad/_config/bmad-help.csv`
4. Be documented in this file
5. Include skill stub in `.claude/commands/`

---

**Version:** 1.0
**Owner:** Jorge (@jorge-at-sf)
**Maintained by:** Seven Fortunas VP AI-SecOps
