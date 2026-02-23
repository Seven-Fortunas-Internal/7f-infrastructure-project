---
date: 2026-02-10
lastUpdated: 2026-02-13
author: Mary (Business Analyst) with Jorge
project_name: Seven Fortunas AI-Native Enterprise Infrastructure
document_type: autonomous_workflow_guide
status: production_ready
version: 2.0
---

# Autonomous Workflow Guide - Seven Fortunas Infrastructure

**Purpose:** Complete guide to the AI-native implementation pattern using BMAD workflows and autonomous agents to build the Seven Fortunas GitHub infrastructure.

**Key Innovation:** PRD → app_spec.txt → Autonomous Agent (bypassing traditional Epics/Stories)

**Reference Project:** Based on patterns from `/home/ladmin/dev/GDF/airgap_signing_bmad/airgap-autonomous/`

---

## Table of Contents

1. [Overview: AI-Native Implementation Pattern](#overview-ai-native-implementation-pattern)
2. [The Complete Workflow](#the-complete-workflow)
3. [BMAD Workflows for Autonomous Implementation](#bmad-workflows-for-autonomous-implementation)
4. [app_spec.txt Structure](#appspectxt-structure)
5. [Feature Quality Standards](#feature-quality-standards)
6. [Restart Variation Patterns](#restart-variation-patterns)
7. [Working with Large PRDs](#working-with-large-prds)
8. [Quality Gates](#quality-gates)
9. [Two-Agent Pattern](#two-agent-pattern)
10. [Best Practices](#best-practices)
11. [Seven Fortunas Specific](#seven-fortunas-specific)
12. [Troubleshooting](#troubleshooting)

---

## Overview: AI-Native Implementation Pattern

### Traditional vs AI-Native Approach

**Traditional Agile Approach:**
```
PRD → Epics → User Stories → Tasks → Implementation
```
- Time-consuming story creation
- Human interpretation between each step
- Frequent context switching
- Difficult for autonomous agents to parse

**AI-Native Approach (Seven Fortunas):**
```
PRD → app_spec.txt → Autonomous Agent → Implementation
```
- Single source of truth for agents
- Direct feature extraction from requirements
- Optimized for autonomous implementation
- 5-10x faster setup time

### Why This is Better for Autonomous Agents

**app_spec.txt provides:**
- Atomic, independently implementable features
- Clear verification criteria (measurable, testable)
- Explicit dependencies (FEATURE_XXX references)
- Structured XML format (easy to parse)
- Single file (no navigation complexity)
- Agent-ready language (no ambiguity)

**Agents can:**
- Start implementing immediately (no story grooming)
- Validate success objectively (pass/fail criteria)
- Track progress simply (feature_list.json)
- Resume after context reset (stateless operation)

### Seven Fortunas Use Case

**Project:** Build entire AI-native enterprise infrastructure
- Creates GitHub repositories
- Sets up organization structure
- Deploys BMAD library
- Scaffolds Second Brain
- Implements 7F Lens dashboards
- Configures automation workflows

**Key Principle:** 60-70% automated, 30-40% human refinement (branding, content curation)

---

---

## The Complete Workflow

### Step 1: Create app_spec.txt from PRD

**BMAD Command:** `/bmad-bmm-create-app-spec`

**What it does:**
- Transforms PRD into structured app_spec.txt
- Extracts atomic, independently implementable features
- Auto-categorizes features into 7 domain categories
- Auto-generates verification criteria for each feature
- Creates single source of truth for autonomous agents

**When to use:**
- After PRD is complete
- Before starting autonomous agent implementation
- When requirements change (merge mode preserves manual edits)

**Tri-Modal Operation:**

1. **CREATE Mode (Default)** - Generate new app_spec.txt from PRD
   - Input: PRD file or directory with multiple .md files
   - Output: app_spec.txt with all 10 required sections
   - Process: Analysis → Extraction → Categorization → Criteria → XML Population
   - Time: 5-15 minutes depending on PRD complexity

2. **EDIT Mode** - Modify existing app_spec.txt
   - Operations: Add/Delete/Modify features, Recategorize, Update criteria
   - Supports: Surgical edits without PRD re-processing
   - Use case: Quality refinements, granularity adjustments

3. **VALIDATE Mode** - Check app_spec.txt quality
   - Runs 8 quality checks (see Quality Gates section)
   - Generates validation report with quality score
   - Recommends improvements

**Pattern 4 Parallel Execution:**
For large multi-file PRDs like Seven Fortunas:
- Reads multiple PRD files in parallel (5x speedup for 5-file PRD)
- Extracts features from multiple sections simultaneously
- Generates criteria for 30+ features in parallel
- Automatically activates for PRDs with 3+ feature sections

**Example invocation:**
```bash
cd /home/ladmin/seven-fortunas-workspace/7f-infrastructure-project
# In Claude Code
/bmad-bmm-create-app-spec

# Workflow asks for PRD path
> /home/ladmin/seven-fortunas-workspace/7f-infrastructure-project/docs/prd/

# Discovers multiple .md files, extracts features, generates app_spec.txt
```

---

### Step 2: Validate app_spec.txt Quality

**BMAD Command:** `/bmad-bmm-check-autonomous-implementation-readiness`

**What it validates:**
8 quality dimensions with weighted scoring:
1. **Structure Validation (15%)** - All 10 XML sections present
2. **Granularity Assessment (20%)** - Features are atomic tasks
3. **Distribution Analysis (10%)** - Balanced across 7 categories
4. **Criteria Quality (20%)** - Measurable, testable, specific
5. **Dependencies Check (10%)** - No circular dependencies
6. **Metadata Completeness (10%)** - Project info, agent-ready flag
7. **Technology Stack (5%)** - Clear, specific versions
8. **Agent Readiness (10%)** - No ambiguous language

**Quality Score Interpretation:**
- **90-100: Excellent** - Ready for autonomous implementation
- **75-89: Good** - Minor improvements recommended but usable
- **60-74: Acceptable** - Address warnings before proceeding
- **< 60: Needs Work** - Significant issues must be fixed

**When to iterate vs proceed:**
- Score ≥75: Proceed with autonomous agent
- Score 60-74: Fix critical issues, re-run validation
- Score <60: Use EDIT mode to improve quality, re-validate

**Example validation report:**
```
═══════════════════════════════════════
   APP_SPEC VALIDATION REPORT
═══════════════════════════════════════

File: app_spec.txt
Validated: 2026-02-13

OVERALL STATUS: PASS
OVERALL SCORE: 85/100

DIMENSION SCORES:
- Structure: 100/100 ✅
- Granularity: 85/100 ✅
- Distribution: 90/100 ✅
- Criteria Quality: 80/100 ✅
- Dependencies: 100/100 ✅
- Metadata: 100/100 ✅
- Tech Stack: 100/100 ✅
- Agent Readiness: 75/100 ⚠️

ISSUES IDENTIFIED:
- 3 features have vague criteria (FEATURE_012, FEATURE_023, FEATURE_034)

RECOMMENDATIONS:
- Use EDIT mode to refine criteria for flagged features
- Consider splitting FEATURE_023 (too complex for single task)
```

---

### Step 3: Use app_spec.txt with Autonomous Agent

Once app_spec.txt is validated, it becomes the input to the autonomous agent pattern.

**Two-Agent Pattern:**

1. **Initializer Agent (Session 1 only)**
   - Reads app_spec.txt
   - Generates feature_list.json from features
   - Sets up project structure
   - May implement first features

2. **Coding Agent (Sessions 2+)**
   - Reads feature_list.json for progress
   - Reads app_spec.txt for requirements
   - Implements next pending feature
   - Updates feature_list.json status
   - Commits and repeats

**How agents use the spec:**
- Parse XML to extract feature by ID
- Read requirements, constraints, dependencies
- Use verification criteria for testing
- Update feature_list.json status (pending → pass/fail)

**Progress tracking:**
```json
{
  "features": [
    {
      "id": "FEATURE_001",
      "name": "Create Seven-Fortunas Public Organization",
      "status": "pass",
      "verification_results": {
        "functional": "pass",
        "technical": "pass",
        "integration": "pass"
      }
    },
    {
      "id": "FEATURE_002",
      "name": "Create Seven-Fortunas-Internal Private Organization",
      "status": "in_progress"
    }
  ]
}
```

---

## BMAD Workflows for Autonomous Implementation

### Workflow 1: create-app-spec

**Full Name:** `bmad-bmm-create-app-spec`
**Location:** `_bmad/bmm/workflows/3-solutioning/create-app-spec/`
**Purpose:** Transform PRD into app_spec.txt

**Key Features:**
- Tri-modal structure (Create/Edit/Validate)
- Restart variations (Clean Slate/Evolutionary/Partial Regen)
- Multi-file PRD support (directory discovery)
- Pattern 4 parallel optimization (30+ features)
- Auto-categorization (7 domain categories)
- Auto-criteria generation (3 types per feature)
- Flexible feature count (granularity-first)

**When to use each mode:**

**CREATE Mode:**
- Starting new project (no existing app_spec.txt)
- PRD has been substantially rewritten
- Want complete regeneration with new patterns

**EDIT Mode:**
- Need to adjust specific features
- Recategorize features
- Update verification criteria
- Split/merge features for better granularity
- No PRD changes, just refinement

**VALIDATE Mode:**
- After creating app_spec.txt
- After making edits
- Before starting autonomous agent
- To identify quality issues

**Invocation:**
```bash
# CREATE mode (default)
/bmad-bmm-create-app-spec

# EDIT mode (explicit)
/bmad-bmm-create-app-spec --mode=edit

# VALIDATE mode (explicit)
/bmad-bmm-create-app-spec --mode=validate
```

---

### Workflow 2: check-autonomous-implementation-readiness

**Full Name:** `bmad-bmm-check-autonomous-implementation-readiness`
**Location:** `_bmad/bmm/workflows/3-solutioning/check-autonomous-implementation-readiness/`
**Purpose:** Validate app_spec.txt quality for autonomous agents

**8 Quality Checks:**

1. **Structure Validation (Weight: 15%)**
   - All 10 required XML sections present
   - Valid XML syntax (well-formed)
   - Sequential feature IDs (no gaps or duplicates)

2. **Granularity Assessment (Weight: 20%)**
   - Features follow atomic task principle
   - One feature = one independently implementable task
   - Can be completed in single coding session
   - Flags features that are too large or too trivial

3. **Distribution Analysis (Weight: 10%)**
   - Balanced across 7 domain categories
   - No single category >60% (inappropriate domination)
   - At least 3 categories represented
   - Infrastructure baseline check (<5% for complex projects)

4. **Criteria Quality (Weight: 20%)**
   - Every feature has verification criteria
   - Criteria are measurable (objective pass/fail)
   - Criteria are testable (automated or manual)
   - Criteria are specific (not generic statements)
   - Three types present: Functional, Technical, Integration

5. **Dependencies Check (Weight: 10%)**
   - No circular dependencies
   - All referenced features exist (FEATURE_XXX)
   - Dependencies form valid DAG (directed acyclic graph)
   - Blocked features flagged

6. **Metadata Completeness (Weight: 10%)**
   - Project name present
   - Generation date present
   - PRD version referenced
   - autonomous_agent_ready flag = true

7. **Technology Stack (Weight: 5%)**
   - Languages specified with versions
   - Frameworks specified with versions
   - Databases specified with versions
   - Clear and specific (not generic)

8. **Agent Readiness (Weight: 10%)**
   - No ambiguous language ("should", "maybe", "consider")
   - Action verbs (imperative statements)
   - Clear constraints (what NOT to do)
   - No subjective terms ("good", "clean", "intuitive")

**Scoring Logic:**
```
Overall Score = Σ(dimension_score × weight)

Example:
Structure: 100 × 0.15 = 15.0
Granularity: 85 × 0.20 = 17.0
Distribution: 90 × 0.10 = 9.0
Criteria: 80 × 0.20 = 16.0
Dependencies: 100 × 0.10 = 10.0
Metadata: 100 × 0.10 = 10.0
Tech Stack: 100 × 0.05 = 5.0
Agent Readiness: 75 × 0.10 = 7.5
─────────────────────────────
Overall Score = 89.5/100
```

**Output:**
- Validation report (markdown format)
- Quality score with interpretation
- List of issues with severity
- Specific recommendations for improvement
- Optional export (JSON for automation)

---

## Key Components

### 1. Specification Document (`app_spec.txt`)

The **single source of truth** for what to build. Generated from PRD using `/bmad-bmm-create-app-spec`, contains:
- Infrastructure requirements (GitHub orgs, repos, teams)
- Second Brain structure (brand, culture, domain expertise)
- 7F Lens dashboard specifications (AI tracker, data sources)
- BMAD deployment instructions (submodules, symlinks)
- Security requirements (Dependabot, secret scanning)
- Automation workflows (GitHub Actions)

**Location:** `Seven-Fortunas-Internal/7f-infrastructure-project/app_spec.txt`

**Creation Process:**
1. Run `/bmad-bmm-create-app-spec` with PRD as input
2. Workflow extracts 40+ features from PRD
3. Auto-categorizes into 7 domains
4. Generates verification criteria automatically
5. Outputs structured XML with 10 required sections

---

## app_spec.txt Structure

### The 10 Required XML Sections

Every app_spec.txt generated by the create-app-spec workflow contains these sections:

#### 1. `<metadata>` - Project Information

**Purpose:** Identifies project and generation details

**Contents:**
- `project_name` - Name of the project
- `generated_from` - PRD version or filename
- `generated_date` - Timestamp of generation
- `autonomous_agent_ready` - Flag indicating agent-readiness (true/false)

**Example:**
```xml
<metadata>
  <project_name>Seven Fortunas Infrastructure</project_name>
  <generated_from>PRD v1.0 (infrastructure-prd.md)</generated_from>
  <generated_date>2026-02-13</generated_date>
  <autonomous_agent_ready>true</autonomous_agent_ready>
</metadata>
```

---

#### 2. `<overview>` - Executive Summary

**Purpose:** High-level project description and objectives

**Contents:**
- Executive summary (2-3 paragraphs from PRD introduction)
- Key objectives (bullet points from PRD goals)

**Example:**
```xml
<overview>
Seven Fortunas is building an AI-native enterprise infrastructure to enable
digital inclusion through technology. This spec covers the initial infrastructure
setup including GitHub organizations, knowledge management systems, and intelligence
dashboards.

Key Objectives:
- Establish public and internal GitHub organizations
- Deploy BMAD methodology framework
- Scaffold Second Brain knowledge system
- Implement 7F Lens intelligence platform
</overview>
```

---

#### 3. `<technology_stack>` - Languages, Frameworks, Databases

**Purpose:** Specifies all technologies with versions

**Contents:**
- Languages (Python 3.10+, JavaScript ES6, etc.)
- Frameworks (React 18, FastAPI 0.104, etc.)
- Databases (PostgreSQL 15, Redis 7, etc.)
- Infrastructure (Docker, Kubernetes, GitHub Actions)

**Critical:** Version numbers must be specified (not generic "latest")

**Example:**
```xml
<technology_stack>
  <languages>
    - Python 3.10+
    - JavaScript ES6+
    - Bash 5.x
  </languages>
  <frameworks>
    - React 18.x (for dashboards)
    - FastAPI 0.104+ (for API services)
    - MkDocs 1.5+ (for documentation)
  </frameworks>
  <databases>
    - PostgreSQL 15+ (primary data store)
    - Redis 7+ (caching layer)
  </databases>
  <infrastructure>
    - Docker 24+
    - GitHub Actions (CI/CD)
    - Git submodules (BMAD deployment)
  </infrastructure>
</technology_stack>
```

---

#### 4. `<coding_standards>` - Style Guides & Conventions

**Purpose:** Enforces consistency across codebase

**Contents:**
- Style guides (PEP 8 for Python, Airbnb for JavaScript)
- Naming conventions (snake_case, camelCase, kebab-case)
- File organization patterns
- Commit message format

**Example:**
```xml
<coding_standards>
  <style_guides>
    - Python: PEP 8 with Black formatter
    - JavaScript: Airbnb style guide
    - Markdown: CommonMark spec
  </style_guides>
  <naming_conventions>
    - Python: snake_case for functions, PascalCase for classes
    - JavaScript: camelCase for variables, PascalCase for components
    - Files: kebab-case for all filenames
  </naming_conventions>
  <file_organization>
    - Group by feature, not by file type
    - Co-locate tests with implementation
    - README.md in every directory
  </file_organization>
  <commit_format>
    type(scope): description

    Examples:
    feat(github): Create Seven-Fortunas organization
    fix(bmad): Correct submodule URL
    docs(readme): Update installation instructions
  </commit_format>
</coding_standards>
```

---

#### 5. `<core_features>` - Grouped Features (THIS IS THE BIG ONE)

**Purpose:** All features organized by 7 domain categories

**Structure:** Nested feature groups with individual features

**The 7 Domain Categories:**
1. **Infrastructure & Foundation** - Core services, auth, data models
2. **User Interface** - Screens, components, forms, navigation
3. **Business Logic** - Workflows, calculations, rules, algorithms
4. **Integration** - APIs, external services, webhooks, data sync
5. **DevOps & Deployment** - CI/CD, monitoring, logging, infrastructure
6. **Security & Compliance** - Authorization, encryption, audit logs
7. **Testing & Quality** - Test frameworks, mocks, quality gates

**Feature Format:**
```xml
<core_features>
  <feature_group name="Infrastructure & Foundation">
    <feature id="FEATURE_001">
      <name>Create Seven-Fortunas Public Organization</name>
      <description>
        Create public GitHub organization for open-source repositories
        and community engagement.
      </description>
      <requirements>
        - Organization name: "Seven-Fortunas"
        - Visibility: Public
        - Description: "AI-native enterprise infrastructure for digital inclusion"
        - Enable security features (Dependabot, secret scanning)
        - Configure default repository permissions
        - Add placeholder logo (will be replaced with real branding)
      </requirements>
      <acceptance_criteria>
        - Organization exists at https://github.com/Seven-Fortunas
        - Organization is public
        - Description is set correctly
        - Security features enabled
      </acceptance_criteria>
      <verification_criteria>
        <functional_verification>
          - Organization accessible via GitHub API (GET /orgs/Seven-Fortunas returns 200)
          - Organization page renders with correct name and description
          - Security scanning active (check organization settings)
        </functional_verification>
        <technical_verification>
          - Organization created using GitHub CLI or API (not manual web interface)
          - Audit log shows creation event
          - Default branch protection rules configured
        </technical_verification>
        <integration_verification>
          - Organization does not conflict with existing GitHub entities
          - Ready for repository creation (FEATURE_003 can proceed)
        </integration_verification>
      </verification_criteria>
      <dependencies>
        None (first feature, foundational)
      </dependencies>
      <constraints>
        - DO NOT apply real Seven Fortunas branding (use placeholder only)
        - DO NOT enable paid GitHub features (stay on Free tier)
        - DO NOT commit any API keys or secrets to code
      </constraints>
    </feature>
  </feature_group>

  <!-- Additional 39+ features in their respective categories -->
</core_features>
```

**Key Points:**
- Each feature has unique sequential ID (FEATURE_001, FEATURE_002, ...)
- Features grouped by category for logical organization
- Three types of verification criteria (Functional, Technical, Integration)
- Dependencies reference other features by ID
- Constraints specify what NOT to do

---

#### 6. `<non_functional_requirements>` - Performance, Security, Scalability

**Purpose:** System-wide quality attributes

**Contents:**
- Performance targets (response times, throughput)
- Security requirements (encryption, auth, compliance)
- Scalability constraints (load handling, data volume)
- Monitoring needs (metrics, alerts, observability)

**Example:**
```xml
<non_functional_requirements>
  <performance>
    - GitHub API calls: <500ms response time (95th percentile)
    - Dashboard page load: <2 seconds (LCP)
    - BMAD skill invocation: <5 seconds (excluding LLM)
  </performance>
  <security>
    - All secrets managed via GitHub Actions secrets (no hardcoded credentials)
    - Enable Dependabot on all repositories
    - Enable secret scanning on all repositories
    - 2FA required for all organization members
  </security>
  <scalability>
    - Support 50+ repositories per organization
    - Support 10+ team members initially (expandable to 100+)
    - BMAD library (70+ workflows) loaded via submodule
  </scalability>
  <monitoring>
    - GitHub Actions workflow status dashboard
    - Repository activity metrics (commits, PRs, issues)
    - Security alert tracking (Dependabot, secret scanning)
  </monitoring>
</non_functional_requirements>
```

---

#### 7. `<testing_strategy>` - Unit, Integration, E2E Approach

**Purpose:** Defines testing approach for each layer

**Contents:**
- Unit test approach (frameworks, coverage targets)
- Integration test approach (API testing, service interaction)
- E2E test approach (user workflows, dashboard testing)

**Example:**
```xml
<testing_strategy>
  <unit_tests>
    - Framework: pytest for Python, Jest for JavaScript
    - Coverage target: 80% for business logic, 60% for infrastructure code
    - Run on every commit via GitHub Actions
  </unit_tests>
  <integration_tests>
    - GitHub API integration: Verify org/repo creation via gh CLI
    - BMAD submodule: Verify submodule checkout and symlinks
    - File existence: Verify README.md, CLAUDE.md, app_spec.txt present
  </integration_tests>
  <e2e_tests>
    - Dashboard rendering: Visual regression testing with Playwright
    - Navigation: Verify all menu links functional
    - Data loading: Verify dashboards load data from sources
  </e2e_tests>
</testing_strategy>
```

---

#### 8. `<deployment_instructions>` - Build Process, Targets

**Purpose:** How to deploy the project

**Contents:**
- Build process (commands, tools)
- Deployment targets (environments)
- Configuration management (environment variables, secrets)

**Example:**
```xml
<deployment_instructions>
  <build_process>
    1. Clone repository
    2. Initialize submodules: git submodule update --init --recursive
    3. Run setup script: ./init.sh
    4. Verify installation: ./scripts/verify.sh
  </build_process>
  <deployment_targets>
    - Development: Local machine with GitHub CLI authenticated
    - Production: GitHub.com organizations (Seven-Fortunas, Seven-Fortunas-Internal)
  </deployment_targets>
  <configuration>
    - ANTHROPIC_API_KEY: Required for autonomous agent (GitHub Actions secret)
    - GITHUB_TOKEN: Auto-provided by GitHub Actions
    - No other secrets required for initial deployment
  </configuration>
</deployment_instructions>
```

---

#### 9. `<reference_documentation>` - Links to ADRs, Tech Specs

**Purpose:** Points to additional documentation

**Contents:**
- Architecture Decision Records (ADRs)
- Technical specifications
- Design documents
- External references (BMAD docs, GitHub docs)

**Example:**
```xml
<reference_documentation>
  <adrs>
    - ADR-001: Choice of GitHub over GitLab (doc/adr/001-github-choice.md)
    - ADR-002: BMAD deployment via submodule (doc/adr/002-bmad-submodule.md)
  </adrs>
  <technical_specs>
    - Second Brain structure: docs/second-brain-spec.md
    - 7F Lens architecture: docs/7f-lens-architecture.md
  </technical_specs>
  <external_references>
    - BMAD documentation: https://bmad-method.github.io/
    - GitHub API docs: https://docs.github.com/en/rest
    - React 18 docs: https://react.dev/
  </external_references>
</reference_documentation>
```

---

#### 10. `<success_criteria>` - Overall Project Success Metrics

**Purpose:** Define when project is "done"

**Contents:**
- Measurable completion criteria
- Quality thresholds
- Acceptance conditions

**Example:**
```xml
<success_criteria>
  - All 40+ features marked "pass" in feature_list.json
  - 2 GitHub organizations created and configured
  - 6+ repositories created with README.md and CLAUDE.md
  - BMAD library deployed as submodule with working symlinks
  - Second Brain structure scaffolded with placeholder content
  - AI Advancements Dashboard implemented and rendering
  - GitHub Actions workflows configured and passing
  - No hardcoded secrets in codebase (security scan clean)
  - All repositories have Dependabot and secret scanning enabled
  - Documentation complete (READMEs, installation guides)
  - Ready for human branding application by CEO
</success_criteria>
```

---

## Feature Quality Standards

### Atomic Task Principle

**Definition:** One feature = one independently implementable task

**Characteristics:**
- Can be completed in single coding session (typically 1-4 hours)
- Has clear beginning and end
- Minimal dependencies on other features
- Can be tested independently
- Has measurable success criteria

**Good Examples:**
- ✅ FEATURE_001: Create Seven-Fortunas Public Organization
- ✅ FEATURE_005: Add BMAD library as git submodule
- ✅ FEATURE_012: Create AI Advancements Dashboard skeleton

**Bad Examples (too large):**
- ❌ "Implement entire Second Brain system" (should be 5-10 features)
- ❌ "Build complete dashboard platform" (should be split by dashboard type)
- ❌ "Set up all automation" (should be per-workflow features)

**Bad Examples (too trivial):**
- ❌ "Create README.md file" (combine with repo creation)
- ❌ "Add newline to config" (not a feature, part of another task)

---

### The 7 Domain Categories

Features are auto-categorized into these domains for logical organization:

#### 1. Infrastructure & Foundation (10-20% of features)

**Typical features:**
- Database schema and models
- Authentication and session management
- API key management
- Configuration systems
- Core data structures
- Caching layers

**Seven Fortunas examples:**
- Create GitHub organizations
- Initialize git repository
- Set up project directory structure

---

#### 2. User Interface (20-30% of features for user-facing apps)

**Typical features:**
- Web pages and screens
- UI components and widgets
- Forms and input validation
- Navigation menus
- Dashboards and visualizations

**Seven Fortunas examples:**
- 7F Lens AI Advancements Dashboard
- 7F Lens Fintech Innovations Dashboard
- Navigation menu component

---

#### 3. Business Logic (25-35% of features)

**Typical features:**
- Business process workflows
- Calculation engines
- Validation rules
- Data transformations
- Notification logic

**Seven Fortunas examples:**
- Data aggregation for AI trends
- Filtering logic for dashboard cards
- Update frequency rules

---

#### 4. Integration (5-15% of features)

**Typical features:**
- REST/GraphQL APIs
- External service integrations
- Data import/export
- Webhooks
- Data synchronization

**Seven Fortunas examples:**
- GitHub API integration for repo creation
- BMAD submodule integration
- Data source connectors for dashboards

---

#### 5. DevOps & Deployment (5-10% of features)

**Typical features:**
- CI/CD pipelines
- Containerization
- Infrastructure as code
- Monitoring and alerting
- Deployment scripts

**Seven Fortunas examples:**
- GitHub Actions workflow for dashboard updates
- Automated BMAD library updates
- Repository health monitoring

---

#### 6. Security & Compliance (5-15% of features)

**Typical features:**
- Role-based access control
- Encryption
- Audit logging
- Compliance checks
- Security scanning

**Seven Fortunas examples:**
- Enable Dependabot on all repos
- Enable secret scanning on all repos
- Configure 2FA requirements
- Audit log setup

---

#### 7. Testing & Quality (5-10% of features)

**Typical features:**
- Test frameworks and runners
- Mock data generators
- Test fixtures
- Quality gates
- Test automation

**Seven Fortunas examples:**
- Integration test suite for GitHub API calls
- Dashboard rendering tests
- BMAD skill invocation tests

---

### Verification Criteria (3 Types per Feature)

Every feature requires three types of verification criteria:

#### 1. Functional Verification (2-3 criteria)

**Purpose:** Verify feature implements specified requirements correctly

**Pattern:**
```
"Feature [performs action] [under condition] as specified in [requirement]"
"Feature handles [edge case/error condition] correctly by [expected behavior]"
```

**Good Examples:**
- "Organization accessible via GitHub API (GET /orgs/Seven-Fortunas returns 200)"
- "Repository created with correct visibility (public/private)"
- "Dashboard displays AI trends from last 30 days"

**Bad Examples:**
- "Feature works correctly" (not measurable)
- "System behaves as expected" (vague)

---

#### 2. Technical Verification (2-3 criteria)

**Purpose:** Verify implementation follows standards and achieves quality thresholds

**Pattern:**
```
"Code follows [specific coding standard or pattern] from PRD"
"Unit tests achieve [X]% coverage for [component]"
"Implementation uses [specified technology/library/framework]"
"Performance meets [specific threshold] under [conditions]"
```

**Good Examples:**
- "Organization created using GitHub CLI (not manual web interface)"
- "Commit message follows conventional commit format"
- "Dashboard page load time <2 seconds (LCP)"

**Bad Examples:**
- "Code is high quality" (not measurable)
- "Performance is good" (no threshold)

---

#### 3. Integration Verification (1-2 criteria)

**Purpose:** Verify feature integrates with dependencies and doesn't break existing functionality

**Pattern:**
```
"Feature integrates with [dependency feature/service] correctly"
"Feature does not break [existing functionality]"
```

**Good Examples:**
- "Repository creation does not affect existing organization settings"
- "BMAD submodule integrates with project git repository"
- "Dashboard navigation links to other dashboards"

**Bad Examples:**
- "Feature integrates well" (not specific)
- "No side effects" (not verifiable)

---

## Restart Variation Patterns

The create-app-spec workflow supports three restart patterns for different scenarios:

### 1. Clean Slate Restart

**When to use:**
- PRD has been substantially rewritten
- Existing app_spec has structural issues
- Want to apply new patterns/learnings
- Starting fresh project

**How to trigger:**
- Delete existing app_spec.txt
- Run `/bmad-bmm-create-app-spec`
- Workflow starts from beginning

**Or via menu:**
- Run `/bmad-bmm-create-app-spec` (detects existing file)
- Select [O]verwrite when prompted

**Effect:**
- Complete regeneration from PRD
- All features re-extracted
- All criteria re-generated
- Feature IDs reset to FEATURE_001, FEATURE_002, ...
- Manual edits lost

**Best for:**
- Major PRD revisions
- Experimental initial attempts
- Learning from mistakes

---

### 2. Evolutionary Restart (Merge Mode)

**When to use:**
- PRD has updates (features added, removed, or modified)
- Existing app_spec has manual edits worth preserving
- Want incremental updates, not complete regeneration
- Feature IDs referenced elsewhere (docs, tracking systems)

**How to trigger:**
- Keep existing app_spec.txt
- Run `/bmad-bmm-create-app-spec`
- Select [M]erge when prompted

**Effect:**
- Intelligently merges PRD updates with existing app_spec
- Adds new features with sequential IDs (continues from highest existing)
- Updates changed features (preserves manual criteria edits where possible)
- Flags removed features for review (doesn't auto-delete)
- Keeps unchanged features untouched

**Merge Analysis Example:**
```
**Merge Analysis:**
- New features detected: 5
- Changed features detected: 3
- Removed features detected: 2
- Unchanged features: 23

**Merge Strategy:**
- Add 5 new features (assign IDs FEATURE_034 through FEATURE_038)
- Update 3 changed features (preserve manual edits where possible)
- Flag 2 removed features for review (mark as "removed_from_prd")
- Keep 23 unchanged features as-is
```

**Best for:**
- Mature app_specs with manual refinements
- PRD updates during active development
- Preserving feature ID references
- Continuous improvement workflow

---

### 3. Partial Regeneration (Edit Mode)

**When to use:**
- No PRD changes, just refining existing spec
- Need to adjust categories, criteria, or granularity
- Quality improvements to existing spec
- Fixing issues found in validation

**How to trigger:**
- Run `/bmad-bmm-create-app-spec --mode=edit`
- Or from CREATE mode final review, select [E]dit

**Edit Operations Available:**
- [A]dd Features - Manually add new features
- [D]elete Features - Remove specific features by ID
- [M]odify Features - Edit name/description/requirements
- [R]ecategorize - Change feature categories
- [U]pdate Criteria - Modify verification criteria
- [G]ranularity Adjust - Split or merge features
- [E]licitation - Deep quality review (Advanced Elicitation tool)
- [S]ave Changes - Write changes to file
- [C]ancel - Exit without saving

**Effect:**
- Surgical precision (change only what needs changing)
- No PRD required
- Full control over edits
- Preserves everything not explicitly edited

**Best for:**
- Quality refinements post-validation
- Category rebalancing (too many in one category)
- Criteria quality improvements
- Splitting features that are too large

---

### Decision Matrix

| Scenario | PRD Changed? | Manual Edits? | Recommended Pattern |
|----------|--------------|---------------|---------------------|
| Initial creation | N/A | N/A | CREATE mode |
| PRD substantially rewritten | Yes (major) | No | Clean Slate |
| PRD has small updates | Yes (minor) | Yes | Evolutionary (Merge) |
| No PRD changes, just refinement | No | Yes | Partial Regen (Edit) |
| Preserving feature IDs critical | N/A | Yes | Evolutionary or Edit |
| Learning from mistakes | N/A | No | Clean Slate |

---

## Working with Large PRDs

Seven Fortunas infrastructure PRD is large (multiple architecture documents). The create-app-spec workflow optimizes for this.

### Pattern 4 Parallel Execution

**Automatically activates when:**
- PRD input is directory with 3+ markdown files
- OR single PRD has 3+ feature-bearing sections
- OR 30+ features detected during extraction

**Performance Benefits:**

**Multi-file PRD Reading:**
- Sequential: 5 files × 2 min/file = 10 minutes
- Parallel: 5 files in parallel = 2 minutes (5x speedup)

**Feature Extraction:**
- Sequential: 40 features × 30 sec/feature = 20 minutes
- Parallel: 40 features in 5 parallel batches = 4 minutes (5x speedup)

**Criteria Generation:**
- Sequential: 40 features × 3 criteria × 20 sec = 40 minutes
- Parallel: 40 features in 5 parallel batches = 8 minutes (5x speedup)

**Total Workflow Time:**
- Sequential: ~70 minutes
- Parallel: ~15 minutes (4.7x speedup)

### Seven Fortunas Specific Optimization

**Input:** `/home/ladmin/seven-fortunas-workspace/7f-infrastructure-project/docs/prd/`

**Contains:**
- infrastructure-overview.md
- github-organizations.md
- second-brain-structure.md
- 7f-lens-dashboards.md
- bmad-deployment.md

**Pattern 4 Execution:**
1. Reads all 5 files in parallel (2 minutes vs 10 minutes)
2. Extracts features from each file in parallel
3. Merges feature lists (ensures no duplicates)
4. Categorizes 40+ features in parallel batches
5. Generates 120+ criteria (3 per feature) in parallel

**Result:** 15-minute workflow instead of 70 minutes

---

---

## Quality Gates

### Before Autonomous Implementation

Run these checks before starting the autonomous agent:

**1. app_spec.txt Exists**
```bash
ls -lh app_spec.txt
# Should show file with reasonable size (50KB-200KB typical)
```

**2. Quality Score ≥75 (Good or better)**
```bash
# Run validation workflow
/bmad-bmm-check-autonomous-implementation-readiness

# Check quality score in report
# Minimum: 75/100
# Recommended: 85/100
# Excellent: 90/100
```

**3. All 10 XML Sections Present**
Validation workflow checks this automatically. Critical failures:
- Missing core_features section
- Missing technology_stack
- Missing metadata

**4. Feature Granularity Appropriate**
Manual review:
- No features that are obvious multi-day efforts
- No features that are trivial (combine with others)
- Each feature is independently implementable

**5. Verification Criteria Measurable and Testable**
Sample check:
- Read FEATURE_001 through FEATURE_005
- Every feature should have specific, testable criteria
- No generic statements like "works correctly" or "performs well"

**6. No Circular Dependencies**
Validation workflow checks this automatically. Review warnings about:
- Features that depend on each other (circular)
- Long dependency chains (may indicate granularity issues)

**7. Agent-Ready Language**
Manual review of 5-10 random features:
- Action verbs (imperative statements)
- No ambiguous terms ("should", "maybe", "consider")
- No subjective terms ("good", "clean", "intuitive")
- Clear constraints (what NOT to do)

**Quality Gate Checklist:**
- [ ] app_spec.txt exists and is readable
- [ ] Quality score ≥75 (validation report)
- [ ] All 10 sections present (validation report)
- [ ] Feature granularity looks reasonable (manual review)
- [ ] Verification criteria are specific (manual review)
- [ ] No circular dependencies (validation report)
- [ ] Agent-ready language (manual review)
- [ ] Ready to create feature_list.json

---

### During Implementation

The Coding Agent tracks progress in `feature_list.json`:

**Status Values:**
- `pending` - Not yet implemented
- `in_progress` - Currently being worked on
- `pass` - Implemented and all verification criteria met
- `fail` - Implementation attempted but verification failed
- `blocked` - Waiting on dependency or external resource

**Progress Monitoring:**
```bash
# Count completed features
grep '"status": "pass"' feature_list.json | wc -l

# List blocked features
grep -A 3 '"status": "blocked"' feature_list.json

# Check current feature
grep -A 5 '"status": "in_progress"' feature_list.json
```

**Verification During Implementation:**
Each feature marked "pass" only when:
- All functional verification criteria pass
- All technical verification criteria pass
- All integration verification criteria pass
- Changes committed to git
- Logged in claude-progress.txt

---

## Two-Agent Pattern

### Initializer Agent (Session 1 Only)

**When it runs:** First session when `feature_list.json` does NOT exist

**Responsibilities:**
1. Read `app_spec.txt` to understand infrastructure requirements
2. **Generate `feature_list.json`** from all features in app_spec
3. Create `init.sh` (environment setup script)
4. Initialize git repository (if needed)
5. Set up basic directory structure
6. Optionally start implementing first features

**Prompt:** `prompts/initializer_prompt.md`

**Key characteristics:**
- Creates foundation for all future sessions
- Generates comprehensive feature list by parsing XML
- Extracts feature IDs, names, categories, verification criteria
- Sets all features to "status": "pending" initially
- May take 10-20 minutes on first run

**feature_list.json Structure:**
```json
{
  "project": "Seven Fortunas Infrastructure",
  "generated_from": "app_spec.txt",
  "generated_date": "2026-02-13",
  "total_features": 42,
  "features": [
    {
      "id": "FEATURE_001",
      "name": "Create Seven-Fortunas Public Organization",
      "category": "Infrastructure & Foundation",
      "description": "Create public GitHub org for open-source repositories",
      "status": "pending",
      "verification_criteria": {
        "functional": [
          "Organization accessible via GitHub API",
          "Organization page renders with correct name"
        ],
        "technical": [
          "Created using GitHub CLI or API",
          "Audit log shows creation event"
        ],
        "integration": [
          "Ready for repository creation"
        ]
      },
      "dependencies": []
    }
  ]
}
```

---

### Coding Agent (Sessions 2+)

**When it runs:** All subsequent sessions when `feature_list.json` DOES exist

**Responsibilities:**
1. Read existing `feature_list.json` to see current state
2. Find next feature with `status: "pending"` or `status: "fail"`
3. Read app_spec.txt for full feature requirements
4. Implement the feature (create repos, files, configs)
5. Test implementation using verification criteria
6. Update `feature_list.json` (change status to `pass` or `fail`)
7. Commit changes to git
8. Update `claude-progress.txt`
9. Repeat until context fills up

**Prompt:** `prompts/coding_prompt.md`

**Key characteristics:**
- Fresh context window (no memory of previous sessions)
- Picks up where last session left off using `feature_list.json` state
- Focus on completing 1+ features per session
- Commits frequently to persist progress
- Uses verification criteria from app_spec.txt for testing

**Example Implementation Cycle:**
```bash
# 1. Check feature_list.json for next pending feature
grep -A 10 '"status": "pending"' feature_list.json | head -n 10

# 2. Read app_spec.txt for FEATURE_003 requirements
grep -A 50 'id="FEATURE_003"' app_spec.txt

# 3. Implement feature
gh repo create Seven-Fortunas-Internal/seven-fortunas-brain --private

# 4. Test against verification criteria
gh repo view Seven-Fortunas-Internal/seven-fortunas-brain  # Functional
ls seven-fortunas-brain/README.md  # Technical
# ... (all criteria)

# 5. Update feature_list.json
# Change FEATURE_003 status to "pass"

# 6. Commit
git add feature_list.json seven-fortunas-brain/
git commit -m "feat(FEATURE_003): Create seven-fortunas-brain repository"

# 7. Log progress
echo "FEATURE_003: Created seven-fortunas-brain repository" >> claude-progress.txt

# 8. Repeat with FEATURE_004
```

---

## Best Practices

### PRD Quality (Input to create-app-spec)

**For best results, PRD should have:**
- Clear feature descriptions (not just high-level goals)
- Technology stack specified (languages, frameworks, versions)
- Non-functional requirements included (performance, security)
- Acceptance criteria where possible (workflow can expand these)

**Avoid:**
- Vague requirements ("should be fast", "must be secure")
- Missing technology details ("use a database" - which one?)
- Inconsistent feature granularity (mix of epics and tasks)

---

### app_spec.txt Maintenance

**After initial creation:**
1. Run VALIDATE mode periodically (after major PRD updates)
2. Use EDIT mode for refinements (don't regenerate unless needed)
3. Re-run CREATE with Merge for PRD updates (preserves manual edits)
4. Keep feature IDs stable (don't renumber)

**Version control:**
- Commit app_spec.txt to git after creation
- Commit after each EDIT session
- Commit after Merge operations
- Tag versions when starting new implementation phase

**When to regenerate (Clean Slate):**
- PRD substantially rewritten (>50% changed)
- Feature structure fundamentally wrong
- Quality score consistently <60 after multiple edit attempts

**When to merge (Evolutionary):**
- PRD has updates (new features, changed requirements)
- Want to preserve manual criteria edits
- Feature IDs referenced in external docs
- Incremental improvement workflow

---

### Autonomous Agent Usage

**Initializer Best Practices:**
- Let it finish completely before stopping (generates feature_list.json)
- Review generated feature_list.json before continuing
- Verify feature count matches app_spec.txt expectations

**Coding Agent Best Practices:**
- Run in single-session mode first (manual control)
- Review commits after each session
- Check for blocked features (may need human intervention)
- Use continuous mode only after initial sessions prove stable

**Progress Tracking:**
- Check claude-progress.txt regularly
- Monitor blocked features (may indicate PRD issues)
- Review verification results (pass/fail by criteria type)

**When to intervene:**
- Feature fails 3+ times (bounded retry exhausted)
- GitHub API authentication issues
- External dependencies unavailable

---

### Update app_spec.txt as Requirements Evolve

**Scenario: New requirements discovered during implementation**

1. **Update PRD** with new requirements
2. **Run create-app-spec with Merge or EDIT mode**
   - Merge: PRD changed (adds new features with sequential IDs, preserves existing)
   - Edit: No PRD changes, just add/modify features directly
3. **Delete `feature_list.json`** — triggers Initializer to regenerate from updated app_spec.txt
4. **Restart the agent** — Initializer sets ALL features (old + new) to `pending`
5. **Coding Agent** re-verifies existing features, then implements new ones

> ⚠️ **Critical: Why delete `feature_list.json` instead of manually appending new features?**
>
> The Coding Agent's re-verification of existing features is a **regression safety net**, not overhead.
> When new features are added (e.g., a new React UI that deploys to the same GitHub Pages repo),
> they can break previously passing features. Re-running all features as `pending` ensures the agent
> catches any regressions introduced by the new work.
>
> **Do NOT manually set existing features back to `pass` after regeneration.** The agent's
> verification cycle is the source of truth. Let it run through everything.
>
> The only exception is when you are certain the new features are fully isolated and cannot
> affect any existing functionality — in that case, manually appending the new features as
> `pending` to the existing `feature_list.json` is acceptable.

**Scenario: Feature needs to be split (too large)**

1. **Run create-app-spec in EDIT mode**
2. **Delete overly large feature**
3. **Add 2-3 smaller features** with appropriate granularity
4. **Delete `feature_list.json`** to trigger full re-verification (preferred)
   - OR manually update `feature_list.json` if features are fully isolated
5. **Coding Agent** implements new granular features

---

## Seven Fortunas Specific

### Infrastructure Project Characteristics

**Large Multi-File PRD:**
- 5 markdown files covering different aspects
- Total PRD size: ~150KB
- Feature count: 40+ features expected

**Pattern 4 Optimization Critical:**
- Without: ~70 minutes to process PRD
- With: ~15 minutes to process PRD
- Automatic activation for 3+ files

**Complex Feature Set:**
- GitHub organizations and repositories
- BMAD library deployment (submodule complexity)
- Second Brain scaffolding (directory structure)
- Multiple dashboards (AI, Fintech, Edutech)
- Automation workflows (GitHub Actions)

**Evolutionary Restart Preferred:**
- Manual refinements to branding instructions
- Feature criteria tuned for autonomous agent
- Feature IDs referenced in project tracking
- Incremental PRD updates during Phase 1

---

### Repository Structure

**Planning Repository:**
```
Seven-Fortunas-Internal/7f-infrastructure-project/
├── docs/
│   ├── prd/                     # Multi-file PRD input
│   │   ├── infrastructure-overview.md
│   │   ├── github-organizations.md
│   │   ├── second-brain-structure.md
│   │   ├── 7f-lens-dashboards.md
│   │   └── bmad-deployment.md
│   └── 00-project-meta/
│       ├── AUTONOMOUS_WORKFLOW_GUIDE.md  # This document
│       └── autonomous-patterns.md
├── app_spec.txt                 # Generated by create-app-spec workflow
├── CLAUDE.md                    # Agent instructions
├── feature_list.json            # Generated by Initializer agent
├── claude-progress.txt          # Progress log
└── scripts/
    ├── run_autonomous.sh
    ├── run_autonomous_continuous.sh
    └── agent.py
```

**BMAD Workflows Location:**
```
seven-fortunas-brain/_bmad/bmm/workflows/3-solutioning/
├── create-app-spec/
│   ├── workflow.md
│   ├── steps-c/                 # CREATE mode (9 files)
│   ├── steps-e/                 # EDIT mode (3 files)
│   ├── steps-v/                 # VALIDATE mode (3 files)
│   ├── data/                    # Reference data
│   └── templates/               # Output templates
└── check-autonomous-implementation-readiness/
    ├── workflow.md
    ├── steps/                   # Validation steps
    └── data/                    # Validation criteria
```

**Skill Stubs:**
```
seven-fortunas-brain/.claude/commands/
├── bmad-bmm-create-app-spec.md
└── bmad-bmm-check-autonomous-implementation-readiness.md
```

---

### Seven Fortunas Workflow Example

**Step 1: Create app_spec.txt**
```bash
cd /home/ladmin/seven-fortunas-workspace/7f-infrastructure-project

# In Claude Code, invoke workflow
/bmad-bmm-create-app-spec

# Workflow prompts for PRD path
> /home/ladmin/seven-fortunas-workspace/7f-infrastructure-project/docs/prd/

# Workflow discovers 5 markdown files
# Reads in parallel (2 minutes)
# Extracts 42 features
# Categorizes into 7 domains
# Generates 126 verification criteria (3 per feature)
# Outputs app_spec.txt (85KB)

# Total time: ~15 minutes
```

**Step 2: Validate Quality**
```bash
# In Claude Code
/bmad-bmm-check-autonomous-implementation-readiness

# Enter path when prompted
> /home/ladmin/seven-fortunas-workspace/7f-infrastructure-project/app_spec.txt

# Runs 8 validation checks
# Quality score: 87/100 (Good)
# Minor warnings about 2 feature criteria
# Recommendation: Proceed with autonomous agent

# Total time: ~3 minutes
```

**Step 3: Optional Refinements**
```bash
# Address validation warnings with EDIT mode
/bmad-bmm-create-app-spec --mode=edit

# Select features to refine
# Update criteria for FEATURE_012, FEATURE_023
# Save changes

# Re-validate
/bmad-bmm-check-autonomous-implementation-readiness
# Quality score: 92/100 (Excellent)
```

**Step 4: Start Autonomous Agent**
```bash
# Copy app_spec.txt to agent directory
cp app_spec.txt ./

# Run initializer agent (generates feature_list.json)
./scripts/run_autonomous.sh

# Review feature_list.json
cat feature_list.json | jq '.features | length'
# Output: 42 features

# Run coding agent sessions
./scripts/run_autonomous.sh  # Session 2
./scripts/run_autonomous.sh  # Session 3
# ... continue until complete
```

---

## Troubleshooting

### app_spec.txt Quality Issues

**Symptom:** Validation score <75

**Common causes:**
- Generic verification criteria ("works correctly", "performs well")
- Features too large (multi-day efforts)
- Missing dependencies
- Ambiguous language ("should", "might", "consider")

**Solutions:**
1. Run validation to identify specific issues
2. Use EDIT mode to fix flagged features
3. Focus on most impactful dimension (criteria quality usually highest weight)
4. Re-validate after each round of fixes
5. Target score ≥75 before proceeding

---

### Merge Mode Conflicts

**Symptom:** Manual edits lost during merge

**Cause:** PRD changes overlapped with manual edits

**Prevention:**
- Commit app_spec.txt before running merge
- Review merge plan before approving
- Use version control to track changes

**Recovery:**
- Git checkout previous version
- Re-apply manual edits in EDIT mode
- Re-run merge with different strategy

---

### Feature Granularity Issues

**Symptom:** Features too large or too small

**Too large indicators:**
- Feature description >10 lines
- Multiple acceptance criteria that could be separate features
- Estimated implementation >4 hours

**Too small indicators:**
- Feature is part of another feature (e.g., "Create README" as separate from "Create repo")
- No meaningful verification criteria
- Trivial to implement (<30 minutes)

**Solution:**
1. Use EDIT mode
2. Select [G]ranularity Adjust option
3. Split large features into 2-3 smaller ones
4. Merge small features into larger logical units
5. Ensure each feature is independently implementable

---

### Autonomous Agent Stuck

**Symptom:** Agent attempting same feature repeatedly

**Common causes:**
- Verification criteria too strict (can't pass)
- GitHub API authentication expired
- External dependency unavailable

**Solutions:**
1. Check `.issue_tracker_state.json` for error details
2. Review last error in `issues.log`
3. May need to relax verification criteria (EDIT mode)
4. Mark feature as blocked manually if external blocker
5. Agent will move to next feature after 3 failed attempts

---

### BMAD Workflow Errors

**Symptom:** Workflow fails to load or execute

**Common causes:**
- Workflow files not in correct location
- Skill stub references wrong path
- File permissions issue

**Solutions:**
```bash
# Verify workflow files exist
ls -la /home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/_bmad/bmm/workflows/3-solutioning/create-app-spec/

# Verify skill stub exists
ls -la /home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/.claude/commands/bmad-bmm-create-app-spec.md

# Check skill stub content (should reference workflow.md)
cat /home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/.claude/commands/bmad-bmm-create-app-spec.md

# Expected:
# @{project-root}/_bmad/bmm/workflows/3-solutioning/create-app-spec/workflow.md
```

---

### Large PRD Performance

**Symptom:** create-app-spec workflow taking >30 minutes

**Cause:** Pattern 4 not activating (need 3+ files or 3+ sections)

**Check:**
```bash
# Count PRD files
ls docs/prd/*.md | wc -l
# Should be ≥3 for Pattern 4

# If single file, check feature sections
grep -c "^## " docs/prd/infrastructure.md
# Should be ≥3 for Pattern 4
```

**Solution:**
- If single large file, split into multiple files by section
- OR accept longer processing time (workflow still works)

---

### 2. Feature Tracking (`feature_list.json`)

Tracks implementation progress for each infrastructure component:

```json
{
  "features": [
    {
      "id": "FEATURE_001",
      "name": "Create Seven-Fortunas GitHub Organization",
      "status": "pass",
      "category": "Infrastructure & Foundation"
    },
    {
      "id": "FEATURE_002",
      "name": "Create Seven-Fortunas-Internal GitHub Organization",
      "status": "pass",
      "category": "Infrastructure & Foundation"
    },
    {
      "id": "FEATURE_003",
      "name": "Deploy BMAD library as submodule",
      "status": "pending",
      "category": "Integration"
    }
  ]
}
```

**Status values:**
- `pending` - Not yet implemented
- `in_progress` - Currently being worked on
- `pass` - Implemented and tested
- `fail` - Implementation attempted but failing
- `blocked` - Waiting on dependency

### 3. Progress Notes (`claude-progress*.txt`)

Session-by-session logs:
- Features implemented
- Repositories created
- Files committed
- Issues encountered
- Next steps

### 4. Instructions (`CLAUDE.md`)

Agent instructions file containing:
- Project context (Seven Fortunas mission, infrastructure goals)
- Development rules (commit frequently, test thoroughly)
- Security requirements (no hardcoded secrets, use GitHub Actions secrets)
- What NOT to do (e.g., don't apply real branding - use placeholders)

---

## Two-Agent Pattern

### Initializer Agent (Session 1 Only)

**When it runs:** First session when `feature_list.json` does NOT exist

**Responsibilities:**
1. Read `app_spec.txt` to understand infrastructure requirements
2. **Generate `feature_list.json`** with all infrastructure tasks (~30-50 features)
3. Create `init.sh` (environment setup script)
4. Initialize git repository (if needed)
5. Set up basic directory structure
6. Optionally start implementing first features (e.g., create GitHub orgs)

**Prompt:** `prompts/initializer_prompt.md`

**Key characteristics:**
- Creates foundation for all future sessions
- Generates comprehensive feature list from app_spec.txt
- Sets up project structure
- May take 10-20 minutes on first run

### Coding Agent (Sessions 2+)

**When it runs:** All subsequent sessions when `feature_list.json` DOES exist

**Responsibilities:**
1. Read existing `feature_list.json` to see current state
2. Find next feature with `status: "pending"` or `status: "fail"`
3. Implement the feature (create repos, files, configs)
4. Test implementation (verify files exist, GitHub API calls succeed)
5. Update `feature_list.json` (change status to `pass`)
6. Commit changes to git
7. Update `claude-progress.txt`
8. Repeat until context fills up

**Prompt:** `prompts/coding_prompt.md`

**Key characteristics:**
- Fresh context window (no memory of previous sessions)
- Picks up where last session left off using `feature_list.json` state
- Focus on completing 1+ features per session
- Commits frequently to persist progress

---

## Project Structure

```
Seven-Fortunas-Internal/7f-infrastructure-project/
├── CLAUDE.md                    # Agent instructions
├── app_spec.txt                 # Infrastructure specification (from PRD)
├── feature_list.json            # Progress tracking
├── claude-progress.txt          # Consolidated progress
├── claude-progress-session*.txt # Per-session logs
├── init.sh                      # Environment setup
├── scripts/
│   ├── run_autonomous.sh        # Single-session launcher
│   ├── run_autonomous_continuous.sh  # Multi-session launcher
│   ├── agent.py                 # Claude SDK agent runner
│   ├── client.py                # SDK client configuration
│   └── prompts.py               # Prompt loading utilities
├── prompts/
│   ├── initializer_prompt.md    # Session 1 prompt
│   └── coding_prompt.md         # Sessions 2+ prompt
├── outputs/                     # Generated artifacts
│   ├── github-orgs/             # Org configurations
│   ├── repositories/            # Repo scaffolds
│   ├── second-brain/            # Second Brain content
│   └── dashboards/              # Dashboard configs
└── .git/                        # Git repository
```

---

## Installation & Setup

### Prerequisites

1. **Python 3.10+** with `claude-agent-sdk`:
```bash
python3 -m venv venv
source venv/bin/activate
pip install claude-agent-sdk
```

2. **Anthropic API Key** in environment:
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

3. **GitHub CLI authenticated**:
```bash
gh auth login
gh auth status
```

4. **Archon MCP Server running** (optional but recommended for task tracking):
```bash
# Check if Archon is running
curl -s http://localhost:8051/mcp
```

---

## Setting Up Autonomous Agent

### Step 1: Create Project Directory

```bash
cd /home/ladmin/dev/GDF/7F_github
mkdir -p Seven-Fortunas-Internal/7f-infrastructure-project
cd Seven-Fortunas-Internal/7f-infrastructure-project
```

### Step 2: Copy Template Files

```bash
# Copy autonomous agent scripts from airgap reference
cp -r /home/ladmin/dev/GDF/airgap_signing_bmad/airgap-autonomous/phase-3-frontend/scripts/ .
cp /home/ladmin/dev/GDF/airgap_signing_bmad/airgap-autonomous/phase-3-frontend/agent.py .
cp /home/ladmin/dev/GDF/airgap_signing_bmad/airgap-autonomous/phase-3-frontend/client.py .
cp /home/ladmin/dev/GDF/airgap_signing_bmad/airgap-autonomous/phase-3-frontend/prompts.py .

# Create prompts directory
mkdir -p prompts
```

### Step 3: Generate `app_spec.txt` from PRD

After creating the PRD, extract features into `app_spec.txt` format:

```txt
# Seven Fortunas Infrastructure - Feature Specification

## SECTION 1: GITHUB ORGANIZATION SETUP

FEATURE_001: Create Seven-Fortunas Public Organization
- Create GitHub organization named "Seven-Fortunas"
- Set organization to public
- Add description: "AI-native enterprise infrastructure for digital inclusion"
- Add placeholder logo (will be replaced with real branding)
- Configure default repository permissions
- Enable security features (Dependabot, secret scanning)

FEATURE_002: Create Seven-Fortunas-Internal Private Organization
- Create GitHub organization named "Seven-Fortunas-Internal"
- Set organization to private
- Add description: "Internal development and operations"
- Add placeholder logo
- Configure default repository permissions
- Enable security features

## SECTION 2: REPOSITORY CREATION

FEATURE_003: Create seven-fortunas-brain Repository
- Repository: Seven-Fortunas-Internal/seven-fortunas-brain
- Private repository
- Initialize with README.md
- Create directory structure:
  - brand/
  - culture/
  - domain-expertise/
  - best-practices/
  - skills/
  - _bmad/ (will be populated by submodule)

... (continue for all 28-30 features)
```

### Step 4: Create CLAUDE.md Instructions

```markdown
# Seven Fortunas Infrastructure - Agent Instructions

## Project Context

You are building the AI-native enterprise infrastructure for Seven Fortunas, consisting of:
1. GitHub Organizations (public and internal)
2. Second Brain (knowledge management system)
3. 7F Lens Intelligence Platform (AI/fintech/edutech dashboards)
4. BMAD Library Deployment (70+ workflow skills)

## Your Working Directory

**CRITICAL:** Your project directory is:
`/home/ladmin/dev/GDF/7F_github/Seven-Fortunas-Internal/7f-infrastructure-project`

Always `cd` to this directory before running any commands.

## Development Rules

### Git Commits
- Commit after completing each feature
- Use descriptive commit messages: "feat: Create Seven-Fortunas GitHub org"
- Include Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>

### Testing
- Verify GitHub API calls succeed (check HTTP status codes)
- Test file creation (use `ls`, `cat` to verify)
- Validate JSON/YAML syntax (use linters)

### Security
- NEVER commit API keys or secrets to git
- Use GitHub Actions secrets for sensitive data
- Enable Dependabot and secret scanning on all repos

### Branding
- Use PLACEHOLDER branding only (blue/green/amber colors)
- Add comments: "TODO: Replace with real Seven Fortunas branding"
- Do NOT attempt to create real logos or detailed branding

### BMAD Deployment
- Add BMAD as git submodule (not direct copy)
- Create symlinks in .claude/commands/ for BMAD skills
- Pin to specific BMAD version (v6.0.0)

### Bounded Retries
- If a feature fails < 3 times: Retry with different approach
- If a feature fails ≥ 3 times: Mark as blocked, move to next feature
- Log blocking issues in issues.log

## What NOT to Do

- ❌ Don't push to GitHub until human review (commit locally only)
- ❌ Don't create real Seven Fortunas branding (Henry will do this)
- ❌ Don't enable paid GitHub features (stay on Free tier)
- ❌ Don't commit secrets or API keys
- ❌ Don't spend > 3 attempts on same failing feature

## Archon Integration

If Archon MCP is available:
- Update Archon tasks as you complete features
- Use task_id from feature_list.json metadata
- Mark tasks as "doing" when starting, "done" when complete

## Success Criteria

A feature is "complete" when:
- Files/repos created and committed to git
- GitHub API calls return success (200/201 status codes)
- Tests pass (file existence, syntax validation)
- Logged in claude-progress.txt
- feature_list.json updated to "pass"
```

### Step 5: Create Initializer Prompt

**File:** `prompts/initializer_prompt.md`

```markdown
## YOUR ROLE - INITIALIZER AGENT (Session 1)

You are setting up the foundation for Seven Fortunas infrastructure development.

### CRITICAL FIRST TASK: Create feature_list.json

Read `app_spec.txt` and create `feature_list.json` with **30-50 detailed features**.

**Format:**
```json
[
  {
    "id": "F001",
    "name": "Create Seven-Fortunas Public Organization",
    "category": "github_setup",
    "description": "Create public GitHub org with placeholder branding",
    "status": "pending",
    "tests": [
      "Organization exists at https://github.com/Seven-Fortunas",
      "Organization is public",
      "Description is set correctly",
      "Security features enabled (Dependabot, secret scanning)"
    ]
  },
  ...
]
```

**Requirements:**
- Minimum 30 features covering all sections of app_spec.txt
- Categories: "github_setup", "repo_creation", "bmad_deployment", "second_brain", "dashboards", "automation"
- ALL features start with "status": "pending"
- Include verification tests for each feature

### SECOND TASK: Initialize Git Repository

```bash
cd /home/ladmin/dev/GDF/7F_github/Seven-Fortunas-Internal/7f-infrastructure-project
git init
git config user.name "Claude Autonomous Agent"
git config user.email "noreply@anthropic.com"
```

### THIRD TASK: Create init.sh

Environment setup script for future sessions.

### FOURTH TASK: Start Implementation

Begin implementing F001 (Create Seven-Fortunas org) if time permits.
```

### Step 6: Create Coding Prompt

**File:** `prompts/coding_prompt.md`

```markdown
## YOUR ROLE - CODING AGENT (Session 2+)

You are continuing the Seven Fortunas infrastructure build.

### YOUR PROCESS

1. **Read feature_list.json** - Find next pending/failing feature
2. **Read app_spec.txt** - Get requirements for that feature
3. **Check existing files** - See what's already done
4. **Implement the feature** - Create repos, files, configs
5. **Test your work** - Verify with GitHub CLI, file checks
6. **Update feature_list.json** - Mark as "pass" if tests pass
7. **Commit to git** - Descriptive message with feature ID
8. **Update claude-progress.txt** - Log what you did
9. **REPEAT** - Continue until context fills up

### EXAMPLE IMPLEMENTATION

Feature: "Create seven-fortunas-brain repository"

```bash
# 1. Change to project directory
cd /home/ladmin/dev/GDF/7F_github/Seven-Fortunas-Internal/7f-infrastructure-project

# 2. Create repository via GitHub CLI
gh repo create Seven-Fortunas-Internal/seven-fortunas-brain \
  --private \
  --description "Seven Fortunas Second Brain - Knowledge management system" \
  --clone

# 3. Initialize README
cd seven-fortunas-brain
cat > README.md <<'EOF'
# Seven Fortunas Second Brain
...
EOF

# 4. Create directory structure
mkdir -p brand culture domain-expertise best-practices skills

# 5. Commit
git add .
git commit -m "feat(F003): Create seven-fortunas-brain repository

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# 6. Push
git push -u origin main

# 7. Verify success
gh repo view Seven-Fortunas-Internal/seven-fortunas-brain
```

### TESTING STRATEGY

**GitHub Operations:**
- Use `gh repo view` to verify repo exists
- Check HTTP status codes from API calls
- Verify branches, files, settings

**File Operations:**
- Use `ls -la` to verify files created
- Use `cat` to verify file contents
- Use linters to validate syntax (JSON, YAML, Markdown)

**BMAD Operations:**
- Verify submodule added: `git submodule status`
- Check symlinks: `ls -la .claude/commands/`
- Test skill invocation: `cat .claude/commands/bmad-bmm-create-prd.md`

### BOUNDED RETRIES

If a feature fails:
- **Attempt 1:** Try initial approach
- **Attempt 2:** Try alternative approach (different API, different tool)
- **Attempt 3:** Try workaround or minimal implementation
- **Attempt 4+:** Mark as "blocked", log issue, move to next feature

**Example:**
```json
{
  "id": "F015",
  "name": "Enable X API integration",
  "status": "blocked",
  "blocked_reason": "X API requires paid account, needs human to authorize",
  "attempts": 3
}
```

### COMMIT FREQUENTLY

- After each feature: 1 commit
- After 3-5 features: Push to remote (if authorized)
- After major section: Update progress notes

### SUCCESS CRITERIA

Mark feature as "pass" only when:
- ✅ All implementation steps completed
- ✅ All tests pass
- ✅ Changes committed to git
- ✅ Logged in progress notes
```

### Step 7: Customize client.py for Seven Fortunas

```python
"""
Claude SDK Client Configuration for Seven Fortunas Infrastructure
==================================================================
"""

import json
from pathlib import Path

from claude_agent_sdk import ClaudeAgentOptions, ClaudeSDKClient


# Archon MCP tools for task/project management
ARCHON_TOOLS = [
    "mcp__archon__health_check",
    "mcp__archon__session_info",
    "mcp__archon__find_projects",
    "mcp__archon__manage_project",
    "mcp__archon__find_tasks",
    "mcp__archon__manage_task",
]

# Built-in tools for file operations and GitHub
BUILTIN_TOOLS = [
    "Read",
    "Write",
    "Edit",
    "Glob",
    "Grep",
    "Bash",
]


def create_client(project_dir: Path, model: str) -> ClaudeSDKClient:
    """
    Create a Claude Agent SDK client for Seven Fortunas infrastructure.

    Args:
        project_dir: Directory for the project
        model: Claude model to use (sonnet, opus, haiku)

    Returns:
        Configured ClaudeSDKClient
    """
    # Create security settings
    security_settings = {
        "sandbox": {"enabled": True, "autoAllowBashIfSandboxed": True},
        "permissions": {
            "defaultMode": "acceptEdits",
            "allow": [
                "Read(./**)",
                "Write(./**)",
                "Edit(./**)",
                "Glob(./**)",
                "Grep(./**)",
                "Bash(*)",
                *ARCHON_TOOLS,
            ],
        },
    }

    # Ensure project directory exists
    project_dir.mkdir(parents=True, exist_ok=True)

    # Write settings file
    settings_file = project_dir / ".claude_settings.json"
    with open(settings_file, "w") as f:
        json.dump(security_settings, f, indent=2)

    return ClaudeSDKClient(
        options=ClaudeAgentOptions(
            model=model,
            system_prompt="You are an expert DevOps engineer building AI-native enterprise infrastructure for Seven Fortunas. You specialize in GitHub organization setup, knowledge management systems, and automation workflows.",
            allowed_tools=[
                *BUILTIN_TOOLS,
                *ARCHON_TOOLS,
            ],
            mcp_servers={
                "archon": {"type": "http", "url": "http://localhost:8051/mcp"}
            },
            max_turns=1000,
            cwd=str(project_dir.resolve()),
            settings=str(settings_file.resolve()),
        )
    )
```

---

## Running the Autonomous Agent

### Single Session (Manual Control)

```bash
cd /home/ladmin/dev/GDF/7F_github/Seven-Fortunas-Internal/7f-infrastructure-project

# First run (initializer agent)
./scripts/run_autonomous.sh

# Subsequent runs (coding agent)
./scripts/run_autonomous.sh

# Use different model
./scripts/run_autonomous.sh --model opus
```

### Continuous Mode (Walk Away)

```bash
# Auto-restarts every 10 iterations until all features complete
./scripts/run_autonomous_continuous.sh

# Or with specific model
./scripts/run_autonomous_continuous.sh --model opus
```

**Continuous mode:**
- Runs agent for 10 iterations
- Commits all changes
- Auto-restarts with fresh context
- Stops when all features pass or blocked
- Memory optimization (prevents context bloat)

---

## Workflow Cycle

```
┌─────────────────────────────────────────────────────────┐
│              AUTONOMOUS INFRASTRUCTURE CYCLE             │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  1. READ feature_list.json                              │
│         ↓                                                │
│  2. FIND next pending/failing feature                   │
│         ↓                                                │
│  3. READ app_spec.txt for requirements                  │
│         ↓                                                │
│  4. CHECK existing repos/files                          │
│         ↓                                                │
│  5. IMPLEMENT (create GitHub org, repo, files)          │
│         ↓                                                │
│  6. TEST (verify with gh CLI, file checks)              │
│         ↓                                                │
│  7. UPDATE feature_list.json (pass/fail/blocked)        │
│         ↓                                                │
│  8. COMMIT changes to git                               │
│         ↓                                                │
│  9. LOG progress in claude-progress.txt                 │
│         ↓                                                │
│  10. UPDATE Archon tasks (if connected)                 │
│         ↓                                                │
│  11. REPEAT from step 1                                 │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Testing Strategy

### Autonomous Testing (Agent Does This)

| Test Type | Approach |
|-----------|----------|
| GitHub org exists | `gh api /orgs/Seven-Fortunas` returns 200 |
| Repo created | `gh repo view Seven-Fortunas/dashboards` succeeds |
| Files exist | `ls app_spec.txt` returns success |
| JSON valid | `python -m json.tool feature_list.json` succeeds |
| YAML valid | `yamllint .github/workflows/update-dashboard.yml` |
| BMAD submodule | `git submodule status` shows _bmad |
| Symlinks work | `ls -la .claude/commands/bmad-*` shows symlinks |

### Human Testing Required

| Test Type | Reason |
|-----------|--------|
| Visual branding | Subjective assessment by CEO |
| Dashboard content | Domain expert reviews AI trends |
| GitHub org security | Security engineer validates policies |
| BMAD skill functionality | Test actual workflow execution |

---

## Issue Tracking & Bounded Retries

### Automatic Issue Detection

The agent tracks issues in `.issue_tracker_state.json`:

```json
{
  "F015": {
    "feature_id": "F015",
    "feature_name": "Enable X API integration",
    "attempts": 3,
    "last_error": "HTTP 401: X API requires authentication",
    "blocked": true,
    "blocked_reason": "Needs human to authorize X API key"
  }
}
```

### Issue Resolution Flow

```
Feature fails
    ↓
Increment attempt count
    ↓
If attempts < 3: Retry with different approach
    ↓
If attempts >= 3: Mark as blocked, move to next feature
    ↓
Log issue in issues.log and .issue_tracker_state.json
    ↓
Continue with next pending feature
```

### Common Blocking Issues

| Issue | Solution |
|-------|----------|
| GitHub API auth failure | Human must run `gh auth login` |
| X API requires paid tier | Skip or use web fallback approach |
| Cannot push to GitHub | Human must configure git remote |
| BMAD submodule URL wrong | Human must provide correct BMAD repo URL |

---

## Restarting a Phase (Clean Slate)

### When to Restart

- **Adding new features to app_spec.txt** (most common — see note below)
- Feature requirements changed (new app_spec.txt)
- Want to regenerate feature list with different structure
- Project got into broken state
- Testing new approach

> **Adding new features is the most common restart trigger.**
> When you add features via `create-app-spec` EDIT or Merge mode, always delete
> `feature_list.json` so the Initializer regenerates the complete feature list from scratch.
> This ensures existing features are re-verified as a regression safety net — the Coding Agent
> verifies them against their criteria before marking `pass`, catching anything broken by the
> new implementation. This is intentional behaviour, not overhead.

### Files to Delete for Fresh Start

```bash
cd /home/ladmin/dev/GDF/7F_github

# CRITICAL: Delete feature_list.json (triggers Initializer on next run)
rm feature_list.json

# RECOMMENDED: Also delete these
rm -f claude-progress*.txt
rm -f .issue_tracker_state.json
# NOTE: Keep issues.log for historical record unless doing a true clean slate

# OPTIONAL: Delete generated outputs (only if starting from scratch)
rm -rf outputs/

# DO NOT DELETE:
# - CLAUDE.md (agent instructions)
# - app_spec.txt (specification — this is your updated source of truth)
# - scripts/ (agent runner)
# - prompts/ (agent prompts)
```

### Restart Process

```bash
# 1. Update app_spec.txt with new features (EDIT or Merge mode)
#    /bmad-bmm-create-app-spec  →  select E (Edit) or Merge

# 2. Delete feature_list.json (triggers Initializer)
rm feature_list.json

# 3. Restart agent
unset CLAUDECODE && ./autonomous-implementation/scripts/run-autonomous.sh --max-iterations 20

# 4. Initializer agent runs (Session 1)
#    - Parses updated app_spec.txt
#    - Generates new feature_list.json with ALL features as pending
#    - Do NOT manually change any status to pass — let the agent verify

# 5. Coding Agent runs (Sessions 2+)
#    - Re-verifies existing features (regression check) → marks pass/fail
#    - Implements new pending features
#    - Any failures surface regressions introduced by new work
```

> ⚠️ **Common Mistake to Avoid**
>
> After the Initializer regenerates `feature_list.json` with all features as `pending`,
> do **not** manually set previously-implemented features back to `pass` to "save time".
> The re-verification is the point. A feature that was `pass` in Phase 1 may `fail` in Phase 2
> if a new feature changed shared infrastructure (GitHub Pages config, repo structure,
> Actions workflows, etc.). Let the agent find these regressions automatically.

---

## Human Interaction Points

The autonomous workflow minimizes human interaction, but requires human involvement at:

1. **Initial Setup (Day 0)**
   - Provide app_spec.txt from PRD
   - Configure CLAUDE.md instructions
   - Authenticate GitHub CLI
   - Start autonomous agent

2. **Branding Application (Days 3-4)**
   - Henry runs `7f-brand-system-generator` skill
   - Apply real Seven Fortunas branding to agent output

3. **Content Curation (Days 3-5)**
   - Patrick reviews technical accuracy
   - Buck validates security configurations
   - Jorge handles edge cases

4. **Founding Team Onboarding (Day 5)**
   - Invite team members to GitHub orgs
   - Configure 2FA and permissions
   - Walkthrough of infrastructure

5. **MVP Demo (Day 5)**
   - Leadership reviews final infrastructure
   - Gather feedback for Phase 2

---

## Security Considerations

### What the Agent CAN Do

- Create GitHub organizations and repositories
- Write files in project directory
- Commit to git (local)
- Run GitHub CLI commands
- Execute bash commands (sandboxed)

### What the Agent CANNOT Do

- Push to GitHub (requires human authorization)
- Execute with sudo
- Modify system settings
- Store secrets in code
- Enable paid GitHub features

### Security Checks

- Pre-commit hooks (detect-secrets)
- GitHub secret scanning enabled on all repos
- Dependabot enabled on all repos
- No hardcoded credentials
- API keys via GitHub Actions secrets only

---

## Monitoring & Progress Tracking

### Check Current Status

```bash
# View progress summary
cat claude-progress.txt

# Count completed features
grep '"status": "pass"' feature_list.json | wc -l

# List blocked features
grep '"status": "blocked"' feature_list.json

# View last session log
cat claude-progress-session$(date +%Y%m%d).txt
```

### Archon Task Tracking

If Archon MCP is connected:

```bash
# Check Archon tasks
curl -s http://localhost:8051/mcp | jq '.tasks'

# Or use Archon CLI
archon tasks list --project-id=<project_id>
```

---

## Expected Timeline

### Day 1 (Session 1)
- Initializer agent generates feature_list.json (~30-50 features)
- Creates basic project structure
- Initializes git repository
- Implements F001-F005 (GitHub org creation, basic repos)
- **Output:** ~5 features complete, foundation established

### Day 2 (Sessions 2-5)
- Coding agent implements BMAD deployment (F010-F015)
- Creates Second Brain structure (F016-F020)
- Sets up 7F Lens dashboard skeleton (F021-F025)
- **Output:** ~15 features complete, 50% infrastructure scaffolded

### Days 3-4 (Sessions 6-10)
- Completes dashboard automation (F026-F030)
- Sets up GitHub Actions workflows
- Handles edge cases and blocked features
- **Output:** ~25 features complete, 80% infrastructure functional

### Day 5 (Final polish)
- Human refinement and branding application
- Manual testing and verification
- Founding team onboarding
- **Output:** MVP complete, ready for demo

---

## Troubleshooting

### Agent Stuck in Loop

**Symptoms:**
- Same feature failing repeatedly
- No progress for multiple iterations
- Error logs repeating same message

**Solutions:**
1. Check `.issue_tracker_state.json` for failure counts
2. Review last error in `issues.log`
3. May need human intervention to unblock
4. Consider marking feature as "blocked" manually

### GitHub API Failures

**Common causes:**
- Not authenticated: Run `gh auth login`
- Rate limit exceeded: Wait 1 hour or use different token
- Insufficient permissions: Check org membership

### BMAD Submodule Issues

**Common causes:**
- BMAD repo URL incorrect in app_spec.txt
- Git credentials not configured
- Network issues

**Solutions:**
```bash
# Verify git config
git config user.name
git config user.email

# Test submodule manually
git submodule add https://github.com/bmad-method/bmad-method.git _bmad
```

### Commits Not Appearing

**Common causes:**
- Pre-commit hooks failing (detect-secrets)
- Git not configured
- Sandbox permissions issue

**Solutions:**
```bash
# Check git status
git status

# View commit log
git log --oneline -10

# Check pre-commit hooks
ls -la .git/hooks/
```

---

## Success Criteria

### MVP Complete When:

- ✅ 25+ features marked "pass" in feature_list.json
- ✅ 2 GitHub orgs created (Seven-Fortunas, Seven-Fortunas-Internal)
- ✅ 6+ repositories created and initialized
- ✅ BMAD library deployed as submodule
- ✅ Second Brain structure scaffolded
- ✅ AI Advancements Dashboard implemented
- ✅ GitHub Actions workflows configured
- ✅ All changes committed to git
- ✅ Documentation generated (READMEs, guides)
- ✅ Security features enabled (Dependabot, secret scanning)
- ✅ Ready for human branding application

### Quality Indicators

- No features remain "fail" status (only "pass" or "blocked")
- All git commits have descriptive messages
- No hardcoded secrets in codebase
- README files present in all repos
- BMAD symlinks functional

---

## Next Steps After Autonomous Agent Completes

1. **Review agent output** - Check all created repos, files, configs
2. **Apply real branding** - Henry runs `7f-brand-system-generator`
3. **Curate content** - Patrick/Buck review technical accuracy
4. **Handle blocked features** - Jorge resolves any blocking issues
5. **Test BMAD skills** - Verify symlinks and skill invocation
6. **Onboard founding team** - Invite to GitHub orgs
7. **Demo to leadership** - Showcase MVP

---

**Document Version:** 1.0
**Last Updated:** 2026-02-10
**Maintainer:** Jorge (VP AI-SecOps)
**Reference:** Based on airgap-autonomous patterns
