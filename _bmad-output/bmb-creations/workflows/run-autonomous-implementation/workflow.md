---
name: 'run-autonomous-implementation'
description: 'Execute autonomous agent implementation using two-agent pattern'
workflowType: 'autonomous-implementation'
module: 'bmm'
category: '4-implementation'
version: '1.0.0'
created: '2026-02-17'
author: 'Wendy (Workflow Builder) with Jorge'
tags: ['autonomous', 'implementation', 'circuit-breaker', 'two-agent-pattern']
modes:
  - create
  - edit
  - validate
sessionType: 'continuable'
outputType: 'non-document'
---

# Autonomous Implementation Workflow

**Purpose:** Execute autonomous agent implementation from validated app_spec.txt using two-agent pattern (Initializer + Coding Agent).

**Key Features:**
- Two-agent pattern with automatic session detection
- Circuit breaker (exit code 42) after 5 consecutive failed sessions
- Bounded retry (3 attempts per feature)
- Hybrid progress tracking (structured + human-readable)
- Domain-agnostic (works with any validated app_spec.txt)

---

## INITIALIZATION SEQUENCE

**CRITICAL:** This workflow has three modes. Determine which mode to run.

---

### 1. Mode Determination

**Check invocation flags or user intent:**

```
Invocation patterns:
- No flags / "create" / -c → CREATE mode
- "edit" / -e / --mode=edit → EDIT mode
- "validate" / -v / --mode=validate → VALIDATE mode
```

**If mode unclear, ask user:**

```
This workflow supports three modes:

[C] CREATE - Run autonomous implementation (Initializer or Coding Agent)
[E] EDIT - Modify feature statuses, circuit breaker settings
[V] VALIDATE - Check implementation state and generate report

Which mode would you like to run?
```

**Wait for user input, then route accordingly.**

---

### 2. Route to Mode Entry Point

#### IF CREATE Mode Selected:

**Purpose:** Execute autonomous implementation (Session 1 = Initializer, Sessions 2+ = Coding Agent)

**Entry point:** `./steps-c/step-01-init.md`

**What it does:**
- Detects if this is Session 1 (Initializer) or Session 2+ (Coding Agent)
- Session 1: Parses app_spec.txt → generates feature_list.json → sets up tracking
- Session 2+: Reads state → implements features → tests → commits → loops

**When to use:**
- Starting new project (no feature_list.json exists)
- Continuing implementation (feature_list.json exists)
- Running autonomous agent sessions

---

#### IF EDIT Mode Selected:

**Purpose:** Manually adjust feature statuses, circuit breaker settings, bounded retry attempts

**Entry point:** `./steps-e/step-01-assess.md`

**What it does:**
- Loads current implementation state
- Presents edit options (features, circuit breaker, retry counts)
- Saves modified state
- Optionally triggers validation

**When to use:**
- After circuit breaker triggers (reset consecutive_failures)
- To reset failed features to pending for retry
- To mark blocked features as pending after fixing external issues
- To adjust circuit breaker threshold

---

#### IF VALIDATE Mode Selected:

**Purpose:** Verify implementation state integrity and generate quality report

**Entry point:** `./steps-v/step-01-validate-state.md`

**What it does:**
- Validates tracking files (JSON syntax, required fields)
- Verifies implementation matches status claims
- Checks circuit breaker state accuracy
- Generates autonomous_validation_report.md

**When to use:**
- After implementation sessions (verify progress)
- Before deploying to production (final check)
- After EDIT mode changes (verify modifications)
- Investigating issues (diagnostic report)

---

## 3. Execute Selected Mode

**Based on user selection, load and execute the appropriate entry point:**

```markdown
### Load Entry Point

**IF CREATE mode:**
"Starting CREATE mode (autonomous implementation)..."
→ Load, read entire file, then execute `./steps-c/step-01-init.md`

**IF EDIT mode:**
"Starting EDIT mode (manual adjustments)..."
→ Load, read entire file, then execute `./steps-e/step-01-assess.md`

**IF VALIDATE mode:**
"Starting VALIDATE mode (state verification)..."
→ Load, read entire file, then execute `./steps-v/step-01-validate-state.md`
```

---

## WORKFLOW CHARACTERISTICS

**Type:** Non-Document (execution workflow with tracking byproducts)
**Module:** BMM (Business Method Module)
**Category:** 4-implementation
**Structure:** Tri-modal (Create/Edit/Validate)
**Session:** Continuable (multi-session support)
**Autonomy:** 95% automated

---

## INPUT REQUIREMENTS

### Required Files
- **app_spec.txt** - Validated feature specification (score ≥75 from check-autonomous-implementation-readiness)
- **CLAUDE.md** - Project-specific agent instructions
- **Git repository** - Initialized in project directory

### Optional Files (for continuation)
- **feature_list.json** - Existing implementation state (Session 2+ only)
- **claude-progress.txt** - Session history and circuit breaker state
- **autonomous_build_log.md** - Detailed implementation log

### Prerequisites
- Git CLI installed
- GitHub CLI installed and authenticated (`gh auth status`)
- Required project dependencies (per app_spec.txt)

---

## OUTPUT ARTIFACTS

### Primary Output
- **Implemented codebase** - All features from app_spec.txt implemented and tested

### Progress Tracking Files
- **feature_list.json** - Feature statuses (pending/in_progress/pass/fail/blocked)
- **claude-progress.txt** - Hybrid format (structured metadata + session logs)
- **autonomous_build_log.md** - Detailed append-only log

### Additional Outputs
- **Git commits** - Frequent commits with descriptive messages
- **init.sh** - Environment setup script (Session 1)
- **autonomous_summary_report.md** - Circuit breaker report (if triggered)
- **autonomous_validation_report.md** - Validation results (VALIDATE mode)

---

## SUCCESS CRITERIA

**Implementation complete when:**
- ✅ All features in app_spec.txt marked "pass" in feature_list.json
- ✅ All implemented features pass verification criteria
- ✅ All work committed to git with descriptive messages
- ✅ No features remain in "fail" status (only "pass" or "blocked")
- ✅ Blocked features clearly documented with reasons
- ✅ Can resume safely after interruption

---

## SPECIAL FEATURES

### 1. Two-Agent Pattern
- **Initializer Agent (Session 1):** Parses app_spec.txt, generates feature_list.json, sets up structure
- **Coding Agent (Sessions 2+):** Implements features one-by-one, tests, commits, loops

**Automatic Detection:** step-01-init.md checks for feature_list.json to determine session type

---

### 2. Circuit Breaker (Exit Code 42)
- **Tracks:** consecutive_failures in claude-progress.txt
- **Threshold:** 5 consecutive failed sessions (configurable)
- **Trigger:** Generates autonomous_summary_report.md, exits with code 42
- **Recovery:** Human fixes issues, uses EDIT mode to reset, restarts workflow

**Session Failure Definition:** No feature status changes, no progress made

---

### 3. Bounded Retry with Progressive Degradation
- **Attempt 1:** Standard implementation (5-10 minutes)
- **Attempt 2:** Simplified approach (3-5 minutes)
- **Attempt 3:** Minimal essentials (1-2 minutes)
- **Attempt 4+:** Mark blocked, move to next feature (0 minutes)

**Prevents:** Wasting time on impossible features

---

### 4. Hybrid Progress Tracking
**Format:** claude-progress.txt
- **Top:** Structured metadata (parseable for circuit breaker)
- **Bottom:** Human-readable session logs (append-only)

---

### 5. Loop-Back Architecture
**Location:** step-13-check-completion.md
- **[L] Loop:** More features → step-08
- **[C] Complete:** All done → step-14
- **[X] Circuit Breaker:** Failures exceeded → exit 42

---

## TROUBLESHOOTING

### Circuit Breaker Triggered
**Symptom:** Workflow exits with code 42
**Cause:** 5 consecutive sessions made no progress
**Solution:**
1. Review autonomous_summary_report.md
2. Fix blocked features (API auth, dependencies)
3. Use EDIT mode to reset consecutive_failures
4. Restart workflow

### Feature Stuck in Fail Status
**Symptom:** Same feature fails repeatedly
**Cause:** Verification criteria too strict or external blocker
**Solution:**
1. Check autonomous_build_log.md for error details
2. Use EDIT mode to reset attempts to 0
3. Fix external blocker if applicable
4. Or mark as blocked if not fixable

### Corrupted State Files
**Symptom:** JSON parse errors, missing files
**Cause:** Manual editing, interrupted writes
**Solution:**
1. Restore from git: `git checkout feature_list.json`
2. Or start fresh: delete feature_list.json, restart workflow
3. Or use VALIDATE mode to diagnose issues

---

## NEXT STEPS AFTER WORKFLOW.MD

**This is the entry point only.**

**Workflow execution happens in step files:**
- CREATE mode: See `./steps-c/` directory
- EDIT mode: See `./steps-e/` directory
- VALIDATE mode: See `./steps-v/` directory

**Data and templates:**
- Reference data: `./data/` directory
- Output templates: `./templates/` directory

---

**Workflow Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Foundation Complete, Ready for Step Files
