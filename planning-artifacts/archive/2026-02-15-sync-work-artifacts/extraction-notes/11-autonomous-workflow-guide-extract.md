# Extract: Autonomous Workflow Guide

**Source:** `autonomous-workflow-guide-7f-infrastructure.md`
**Date:** 2026-02-10
**Size:** 1014 lines
**Author:** Mary (Business Analyst) with Jorge

---

## Document Metadata
- **Purpose:** Setup and execution guide for autonomous AI agent (Claude Code SDK)
- **Reference Project:** Based on `/home/ladmin/dev/GDF/airgap_signing_bmad/airgap-autonomous/` patterns
- **Scope:** Infrastructure build automation (60-70% autonomous completion)

---

## Key Content Summary

### Overview (Lines 17-30)
**Autonomous workflow enables Claude Code to develop infrastructure independently:**
- Creates GitHub repositories
- Sets up organization structure
- Deploys BMAD library
- Scaffolds Second Brain
- Implements 7F Lens dashboards
- Configures automation workflows

**Key Principle:** 60-70% automated, 30-40% human refinement

---

### Key Components (Lines 32-96)

**1. app_spec.txt - Single Source of Truth**
- Infrastructure requirements (GitHub orgs, repos, teams)
- Second Brain structure
- 7F Lens dashboard specifications
- BMAD deployment instructions
- Security requirements
- Automation workflows
- Location: Seven-Fortunas-Internal/7f-infrastructure-project/app_spec.txt

**2. feature_list.json - Progress Tracking**
- Features with id, name, status, category
- Status values: pending, pass, fail, blocked
- Updated after each feature implementation
- Example format provided (Lines 49-72)

**3. claude-progress*.txt - Session Logs**
- Features implemented
- Repositories created
- Files committed
- Issues encountered
- Next steps

**4. CLAUDE.md - Agent Instructions**
- Project context
- Development rules (commit frequently, test thoroughly)
- Security requirements (no secrets)
- What NOT to do (no real branding - placeholders only)

---

### Two-Agent Pattern (Lines 99-143)

**Initializer Agent (Session 1 Only):**
- Runs when feature_list.json does NOT exist
- Generates feature_list.json from app_spec.txt (30-50 features)
- Creates init.sh
- Initializes git repository
- Sets up directory structure
- Optionally starts implementing first features
- Prompt: prompts/initializer_prompt.md

**Coding Agent (Sessions 2+):**
- Runs when feature_list.json DOES exist
- Finds next pending/failing feature
- Implements the feature
- Tests implementation
- Updates feature_list.json to "pass"
- Commits changes to git
- Updates claude-progress.txt
- Repeats until context fills up
- Prompt: prompts/coding_prompt.md

---

### Project Structure (Lines 145-171)
```
Seven-Fortunas-Internal/7f-infrastructure-project/
├── CLAUDE.md
├── app_spec.txt
├── feature_list.json
├── claude-progress.txt
├── claude-progress-session*.txt
├── init.sh
├── scripts/ (run_autonomous.sh, run_autonomous_continuous.sh, agent.py, client.py, prompts.py)
├── prompts/ (initializer_prompt.md, coding_prompt.md)
├── outputs/ (generated artifacts)
└── .git/
```

---

### Installation & Setup (Lines 173-263)

**Prerequisites:**
1. Python 3.10+ with claude-agent-sdk
2. ANTHROPIC_API_KEY in environment
3. GitHub CLI authenticated
4. Archon MCP Server (optional, for task tracking)

**Setup Steps:**
1. Create project directory
2. Copy template files from airgap reference
3. Generate app_spec.txt from PRD (28-30 features)
4. Create CLAUDE.md instructions
5. Create initializer_prompt.md
6. Create coding_prompt.md
7. Customize client.py for Seven Fortunas

**CLAUDE.md Critical Sections (Lines 269-344):**
- Project context (what you're building)
- Working directory (Seven-Fortunas-Internal/7f-infrastructure-project)
- Development rules (git commits, testing, security)
- Branding (PLACEHOLDER only, no real branding)
- BMAD deployment (submodule, symlinks, pinned version)
- Bounded retries (max 3 attempts, then mark blocked)
- What NOT to do (no push until review, no real branding, no secrets)
- Archon integration (update tasks)

---

### Running Autonomous Agent (Lines 601-669)

**Single Session (Manual Control):**
```bash
./scripts/run_autonomous.sh           # First run (initializer)
./scripts/run_autonomous.sh           # Subsequent (coding)
./scripts/run_autonomous.sh --model opus
```

**Continuous Mode (Walk Away):**
```bash
./scripts/run_autonomous_continuous.sh
```
- Runs 10 iterations
- Commits changes
- Auto-restarts with fresh context
- Stops when all features pass/blocked
- Memory optimization

**Workflow Cycle (Lines 641-669):**
1. Read feature_list.json
2. Find next pending/failing feature
3. Read app_spec.txt for requirements
4. Check existing repos/files
5. Implement (create GitHub org, repo, files)
6. Test (verify with gh CLI, file checks)
7. Update feature_list.json (pass/fail/blocked)
8. Commit changes to git
9. Log progress in claude-progress.txt
10. Update Archon tasks (if connected)
11. Repeat from step 1

---

### Testing Strategy (Lines 671-697)

**Autonomous Testing (Agent Does):**
- GitHub org exists: `gh api /orgs/Seven-Fortunas` returns 200
- Repo created: `gh repo view Seven-Fortunas/dashboards`
- Files exist: `ls app_spec.txt`
- JSON valid: `python -m json.tool feature_list.json`
- YAML valid: `yamllint .github/workflows/update-dashboard.yml`
- BMAD submodule: `git submodule status`
- Symlinks work: `ls -la .claude/commands/bmad-*`

**Human Testing Required:**
- Visual branding (subjective)
- Dashboard content (domain expert)
- GitHub org security (security engineer)
- BMAD skill functionality (workflow execution)

---

### Bounded Retries & Issue Tracking (Lines 699-741)

**Issue Detection:**
- Tracks in .issue_tracker_state.json
- Records: feature_id, attempts, last_error, blocked status, blocked_reason

**Issue Resolution Flow:**
- Feature fails → Increment attempts
- If attempts < 3: Retry with different approach
- If attempts >= 3: Mark as blocked, move to next
- Log in issues.log and .issue_tracker_state.json

**Common Blocking Issues:**
- GitHub API auth failure → Human runs gh auth login
- X API requires paid tier → Skip or web fallback
- Cannot push to GitHub → Configure git remote
- BMAD submodule URL wrong → Provide correct URL

---

### Restarting Phase (Clean Slate) (Lines 743-789)

**When to Restart:**
- Feature requirements changed
- Want to regenerate feature list
- Project in broken state
- Testing new approach

**Files to Delete:**
- feature_list.json (CRITICAL - triggers initializer)
- claude-progress*.txt (RECOMMENDED)
- .issue_tracker_state.json (RECOMMENDED)
- issues.log (RECOMMENDED)
- outputs/ (OPTIONAL)

**DO NOT DELETE:**
- CLAUDE.md, app_spec.txt, scripts/, prompts/

---

### Human Interaction Points (Lines 791-820)

1. **Initial Setup (Day 0):** Provide app_spec.txt, configure CLAUDE.md, authenticate GitHub CLI, start agent
2. **Branding Application (Days 3-4):** Henry runs 7f-brand-system-generator
3. **Content Curation (Days 3-5):** Patrick/Buck/Jorge review output
4. **Founding Team Onboarding (Day 5):** Invite members, configure 2FA/permissions, walkthrough
5. **MVP Demo (Day 5):** Leadership reviews, gathers feedback

---

### Security Considerations (Lines 821-847)

**Agent CAN Do:**
- Create GitHub orgs and repos
- Write files in project directory
- Commit to git (local)
- Run GitHub CLI commands
- Execute bash (sandboxed)

**Agent CANNOT Do:**
- Push to GitHub (requires human authorization)
- Execute with sudo
- Modify system settings
- Store secrets in code
- Enable paid GitHub features

**Security Checks:**
- Pre-commit hooks (detect-secrets)
- GitHub secret scanning enabled
- Dependabot enabled
- No hardcoded credentials
- API keys via GitHub Actions secrets only

---

### Expected Timeline (Lines 883-909)

**Day 1 (Session 1):**
- Initializer generates feature_list.json (~30-50 features)
- Creates basic structure
- Initializes git
- Implements F001-F005 (orgs, basic repos)
- Output: ~5 features complete

**Day 2 (Sessions 2-5):**
- BMAD deployment (F010-F015)
- Second Brain structure (F016-F020)
- Dashboard skeleton (F021-F025)
- Output: ~15 features complete, 50% scaffolded

**Days 3-4 (Sessions 6-10):**
- Dashboard automation (F026-F030)
- GitHub Actions workflows
- Edge cases, blocked features
- Output: ~25 features complete, 80% functional

**Day 5 (Final polish):**
- Human refinement, branding
- Manual testing, verification
- Founding team onboarding
- Output: MVP complete, demo ready

---

### Troubleshooting (Lines 911-969)

**Agent Stuck in Loop:**
- Check .issue_tracker_state.json
- Review issues.log
- May need human intervention
- Mark feature as blocked manually

**GitHub API Failures:**
- Not authenticated: gh auth login
- Rate limit exceeded: Wait 1 hour
- Insufficient permissions: Check org membership

**BMAD Submodule Issues:**
- Verify git config (user.name, user.email)
- Test submodule manually
- Check network

**Commits Not Appearing:**
- Pre-commit hooks failing (detect-secrets)
- Git not configured
- Sandbox permissions issue

---

### Success Criteria (Lines 971-995)

**MVP Complete When:**
- 25+ features marked "pass"
- 2 GitHub orgs created
- 6+ repositories initialized
- BMAD library deployed as submodule
- Second Brain structure scaffolded
- AI Advancements Dashboard implemented
- GitHub Actions workflows configured
- All changes committed to git
- Documentation generated
- Security features enabled
- Ready for human branding

**Quality Indicators:**
- No features remain "fail" (only pass/blocked)
- Descriptive git commit messages
- No hardcoded secrets
- README files in all repos
- BMAD symlinks functional

---

### Next Steps After Completion (Lines 997-1007)

1. Review agent output
2. Apply real branding (Henry runs 7f-brand-system-generator)
3. Curate content (Patrick/Buck review)
4. Handle blocked features (Jorge resolves)
5. Test BMAD skills (verify symlinks)
6. Onboard founding team
7. Demo to leadership

---

## Critical Information

**Reference Project:** Based on airgap-autonomous patterns at `/home/ladmin/dev/GDF/airgap_signing_bmad/airgap-autonomous/`

**Two-Agent Pattern:** Initializer (Session 1) creates feature list, Coding (Sessions 2+) implements features

**Bounded Retries:** Max 3 attempts per feature, then mark blocked and move on (prevents infinite loops)

**Testing Built-In:** No feature marked "pass" without tests passing (quality gate)

**Placeholder Branding:** Agent uses placeholders only, real branding applied by Henry post-agent (Days 3-4)

**GitHub Account:** Must be authenticated as jorge-at-sf (NOT jorge-at-gd) - CRITICAL per FR-7.1.4

**Expected Completion:** 60-70% autonomous (18-25 features out of 28-30 total)

**Progress Tracking:** feature_list.json is source of truth for status

---

## Ambiguities / Questions

**Feature Count:** Guide mentions 28-30 features but doesn't specify exact number. PRD has 28 functional requirements.

**GitHub Authentication:** Guide doesn't explicitly mention jorge-at-sf requirement, but this is critical per functional requirements FR-7.1.4.

**BMAD Pinning:** Guide says pin to v6.0.0 but doesn't provide verification step to confirm version.

---

## Related Documents
- Implements Architecture Document autonomous patterns
- References Action Plan for Day 1-2 execution
- Uses PRD to generate app_spec.txt
- Supports Product Brief autonomous agent strategy
