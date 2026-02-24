# Autonomous Implementation - Task-Specific Instructions

**Location:** `/home/ladmin/dev/GDF/7F_github/autonomous-implementation/`
**Purpose:** Convert BMAD workflow to Python Agent SDK architecture for true autonomous implementation
**Task Type:** One-time setup

---

## CRITICAL - Context Recovery After Compaction

If resuming after context compaction, **READ THESE FILES FIRST:**

1. **Architecture Plan (Comprehensive Guide):**
   ```
   @/home/ladmin/dev/GDF/7F_github/AUTONOMOUS-IMPLEMENTATION-PLAN.md
   ```

2. **Reference Implementation (Proven Pattern):**
   ```
   @/home/ladmin/dev/GDF/airgap_signing_bmad/airgap-autonomous/phase-4-integration/agent.py
   @/home/ladmin/dev/GDF/airgap_signing_bmad/airgap-autonomous/phase-4-integration/scripts/run_autonomous_continuous.sh
   ```

---

## Current Task

**Objective:** Create Python Agent SDK-based autonomous implementation system

**Why:** BMAD workflows via Claude Code trigger 15-20 permission prompts per feature (defeats autonomy)

**Solution:** Use Claude Agent SDK (Python) to make direct API calls, bypassing permission system

---

## Working Directory

```
/home/ladmin/dev/GDF/7F_github/autonomous-implementation/  (YOU ARE HERE)
├── CLAUDE.md                    # This file
├── agent.py                     # Core autonomous agent (CREATE)
├── client.py                    # Claude SDK wrapper (CREATE)
├── prompts.py                   # Prompt loader (CREATE)
├── prompts/                     # Prompt templates
│   ├── initializer_prompt.md   # Session 1: Parse app_spec.txt (CREATE)
│   └── coding_prompt.md        # Session 2+: Implement features (CREATE)
└── scripts/
    └── run-autonomous.sh       # Unified launcher (CREATE)
```

**Parent directory (project root):**
```
../app_spec.txt                  # Feature specification (42 features) ✅
../feature_list.json             # Implementation tracking ✅
../claude-progress.txt           # Progress metadata ✅
../autonomous_build_log.md       # Detailed log ✅
```

---

## Implementation Checklist

### Phase 1: Core Agent Files (2-3 hours)

- [ ] **agent.py** - Core autonomous agent
  - Source: `/home/ladmin/dev/GDF/airgap_signing_bmad/airgap-autonomous/phase-4-integration/agent.py`
  - Adaptations: Remove airgap-specific code, use existing tracking files
  - Features: Two-mode system (initializer/coding), circuit breakers, progress tracking

- [ ] **client.py** - Claude SDK client wrapper
  - Simple wrapper for model selection (sonnet/opus/haiku)
  - Model mapping to full model IDs

- [ ] **prompts.py** - Prompt loading utilities
  - Load prompt templates from prompts/ directory
  - Inject project directory for sandbox isolation

- [ ] **prompts/initializer_prompt.md** - Session 1 prompt
  - Parse app_spec.txt (42 features)
  - Generate feature_list.json
  - Initialize tracking files

- [ ] **prompts/coding_prompt.md** - Session 2+ prompt
  - Implement features one by one
  - Bounded retry strategy (STANDARD → SIMPLIFIED → MINIMAL)
  - Update tracking, commit, loop

---

### Phase 2: Launcher Script (1 hour)

- [ ] **scripts/run-autonomous.sh** - Unified launcher
  - Pre-flight checks (git, app_spec.txt, venv, dependencies)
  - Arguments: --single, --model, --max-iterations
  - Progress display before launch
  - Circuit breaker detection (exit code 42)

---

### Phase 3: Testing (1 hour)

- [ ] **Test Session 1 (Initializer)**
  - Remove existing tracking files (fresh start)
  - Run: `./scripts/run-autonomous.sh --single --model sonnet`
  - Verify: feature_list.json created with 42 features

- [ ] **Test Session 2 (Single Feature)**
  - Run: `./scripts/run-autonomous.sh --single`
  - Verify: FEATURE_001 status changes to "pass"
  - Verify: Git commit created

- [ ] **Test Continuous Mode (3 Features)**
  - Run: `./scripts/run-autonomous.sh --max-iterations 3`
  - Verify: 3+ features completed
  - Verify: Circuit breaker didn't trigger

---

### Phase 4: Documentation (1 hour)

- [ ] **Create usage guide** - AUTONOMOUS-IMPLEMENTATION-GUIDE.md
  - Quick start
  - Command reference
  - Troubleshooting
  - When to use BMAD EDIT mode vs agent

- [ ] **Update main CLAUDE.md** - Reference this task

---

## Key Implementation Points

### Circuit Breakers (Prevent Infinite Loops)

```python
MAX_ITERATIONS = 10              # Restart after 10 features (memory management)
MAX_CONSECUTIVE_SESSION_ERRORS = 5  # Stop after 5 consecutive errors
MAX_STALL_SESSIONS = 5           # Stop if no progress for 5 sessions
```

### Two-Mode System

```python
if not feature_list.exists():
    prompt = get_initializer_prompt()  # Session 1
else:
    prompt = get_coding_prompt()        # Session 2+
```

### Progress Tracking

```python
passing = count_features_by_status(feature_list, "pass")
pending = count_features_by_status(feature_list, "pending")
fail_retry = count_features_by_status(feature_list, "fail", max_attempts=3)
remaining = pending + fail_retry
```

---

## Critical Rules

### File Operations
- ✅ **Use Read before Write/Edit** (always!)
- ✅ **Use absolute paths** for all project files
- ✅ **Commit after each passing feature**
- ❌ **Don't skip testing** (verify autonomous flow works)

### Agent Behavior
- ✅ **Make reasonable decisions** (don't stop to ask questions)
- ✅ **Implement, test, commit, loop** (no summaries between features)
- ✅ **Use bounded retry** (3 attempts, then mark blocked)
- ❌ **Don't implement BMAD workflow logic** (use Python agent pattern)

### Project Isolation
- ✅ **Inject project directory** in prompts (sandbox may create temp dirs)
- ✅ **Verify location** before running commands: `cd $PROJECT_DIR && pwd`
- ✅ **Use venv Python** (`./venv/bin/python`, not system python)

---

## Testing Commands

**From project root:**
```bash
# Fresh start (initializer)
cd /home/ladmin/dev/GDF/7F_github
rm -f feature_list.json claude-progress.txt autonomous_build_log.md
./autonomous-implementation/scripts/run-autonomous.sh --single --model sonnet

# Single feature (coding agent)
./autonomous-implementation/scripts/run-autonomous.sh --single

# Continuous (3 iterations)
./autonomous-implementation/scripts/run-autonomous.sh --max-iterations 3

# Full autonomous run (default: 10 iterations)
./autonomous-implementation/scripts/run-autonomous.sh
```

---

## When to Use What

### Use Python Agent (`./scripts/run-autonomous.sh`)
- ✅ Autonomous implementation (unattended)
- ✅ Bulk work (10+ features)
- ✅ Walk away scenarios (hours)

### Use BMAD Workflow (`/bmad-bmm-run-autonomous-implementation`)
- ✅ EDIT mode: Fix stuck features, reset circuit breaker
- ✅ VALIDATE mode: Verify tracking state integrity
- ❌ CREATE mode: Deprecated (use Python agent instead)

---

## Success Criteria

**Phase 1 Complete:**
- [ ] All 5 Python files created (agent.py, client.py, prompts.py, 2 prompts)
- [ ] Files follow reference implementation pattern
- [ ] Circuit breakers implemented

**Phase 2 Complete:**
- [ ] Launcher script created and executable
- [ ] Pre-flight checks implemented
- [ ] Arguments work (--single, --model, --max-iterations)

**Phase 3 Complete:**
- [ ] Session 1 generates feature_list.json (42 features)
- [ ] Session 2 implements FEATURE_001 (status: pass)
- [ ] Continuous mode implements 3+ features
- [ ] Zero permission prompts during execution

**Phase 4 Complete:**
- [ ] Usage guide created
- [ ] Main CLAUDE.md updated
- [ ] Task complete, ready for production use

---

## Estimated Timeline

| Phase | Duration | Tasks |
|-------|----------|-------|
| 1. Core Agent Files | 2-3 hours | agent.py, client.py, prompts.py, 2 prompt templates |
| 2. Launcher Script | 1 hour | run-autonomous.sh with pre-flight checks |
| 3. Testing | 1 hour | Session 1 + 2 + continuous mode |
| 4. Documentation | 1 hour | Usage guide + CLAUDE.md updates |
| **Total** | **5-6 hours** | **Complete autonomous system** |

---

## Resources

**Reference Implementation:**
- `/home/ladmin/dev/GDF/airgap_signing_bmad/airgap-autonomous/phase-4-integration/`
  - agent.py (main reference)
  - scripts/run_autonomous_continuous.sh (launcher reference)
  - prompts/coding_prompt.md (prompt reference)

**Planning Documents:**
- `../AUTONOMOUS-IMPLEMENTATION-PLAN.md` (comprehensive architecture guide)

**Tracking Files:**
- `../app_spec.txt` (input - 42 features)
- `../feature_list.json` (state tracking)
- `../claude-progress.txt` (metadata)
- `../autonomous_build_log.md` (detailed log)

---

**Document Version:** 1.0
**Last Updated:** 2026-02-17
**Task Status:** Setup Phase
**Owner:** Jorge (VP AI-SecOps)
