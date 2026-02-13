---
date: 2026-02-10
author: Mary (Business Analyst) with Jorge
project_name: Seven Fortunas AI-Native Enterprise Infrastructure
document_type: autonomous_workflow_guide
status: ready_to_execute
---

# Autonomous Workflow Guide - Seven Fortunas Infrastructure

**Purpose:** Explains how to set up and run the autonomous AI agent to build the Seven Fortunas GitHub infrastructure using Claude Code SDK.

**Reference Project:** Based on patterns from `/home/ladmin/dev/GDF/airgap_signing_bmad/airgap-autonomous/`

---

## Overview

The autonomous workflow enables Claude Code to develop the Seven Fortunas infrastructure independently:
- Creates GitHub repositories
- Sets up organization structure
- Deploys BMAD library
- Scaffolds Second Brain
- Implements 7F Lens dashboards
- Configures automation workflows

**Key Principle:** 60-70% automated, 30-40% human refinement (branding, content curation)

---

## Key Components

### 1. Specification Document (`app_spec.txt`)

The **single source of truth** for what to build. Generated from PRD, contains:
- Infrastructure requirements (GitHub orgs, repos, teams)
- Second Brain structure (brand, culture, domain expertise)
- 7F Lens dashboard specifications (AI tracker, data sources)
- BMAD deployment instructions (submodules, symlinks)
- Security requirements (Dependabot, secret scanning)
- Automation workflows (GitHub Actions)

**Location:** `Seven-Fortunas-Internal/7f-infrastructure-project/app_spec.txt`

### 2. Feature Tracking (`feature_list.json`)

Tracks implementation progress for each infrastructure component:

```json
{
  "features": [
    {
      "id": "F001",
      "name": "Create Seven-Fortunas GitHub Organization",
      "status": "pass",
      "category": "github_setup"
    },
    {
      "id": "F002",
      "name": "Create Seven-Fortunas-Internal GitHub Organization",
      "status": "pass",
      "category": "github_setup"
    },
    {
      "id": "F003",
      "name": "Deploy BMAD library as submodule",
      "status": "pending",
      "category": "bmad_deployment"
    }
  ]
}
```

**Status values:**
- `pending` - Not yet implemented
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

- Feature requirements changed (new app_spec.txt)
- Want to regenerate feature list with different structure
- Project got into broken state
- Testing new approach

### Files to Delete for Fresh Start

```bash
cd /home/ladmin/dev/GDF/7F_github/Seven-Fortunas-Internal/7f-infrastructure-project

# CRITICAL: Delete feature_list.json (triggers initializer)
rm feature_list.json

# RECOMMENDED: Also delete these
rm -f claude-progress*.txt
rm -f .issue_tracker_state.json
rm -f issues.log

# OPTIONAL: Delete generated outputs (if starting from scratch)
rm -rf outputs/

# DO NOT DELETE:
# - CLAUDE.md (agent instructions)
# - app_spec.txt (specification)
# - scripts/ (agent runner)
# - prompts/ (agent prompts)
```

### Restart Process

```bash
# 1. Delete state files (as above)
rm feature_list.json

# 2. Restart agent
./scripts/run_autonomous.sh

# 3. Initializer agent runs
#    - Generates new feature_list.json from app_spec.txt
#    - Creates fresh project structure
#    - Starts implementation from beginning
```

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
