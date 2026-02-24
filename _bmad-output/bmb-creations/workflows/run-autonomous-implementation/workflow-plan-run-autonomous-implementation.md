---
stepsCompleted: ['step-01-discovery', 'step-02-classification', 'step-03-requirements', 'step-04-tools', 'step-05-plan-review', 'step-06-design', 'step-07-foundation']
created: 2026-02-16
status: FOUNDATION_COMPLETE
approvedDate: 2026-02-16
designCompletedDate: 2026-02-17
foundationCompletedDate: 2026-02-17
workflowPath: '{project-root}/_bmad-output/bmb-creations/workflows/run-autonomous-implementation/'
---

# Workflow Creation Plan: run-autonomous-implementation

## Discovery Notes

**User's Vision:**
Create a general-purpose BMAD workflow that reads a validated app_spec.txt and autonomously implements all features using a two-agent pattern (Initializer + Coding Agent). This bypasses traditional story creation and enables direct PRD → app_spec.txt → Implementation flow.

**Who It's For:**
- Primary: Autonomous AI agents (Claude with Agent SDK or similar)
- Secondary: Human operators monitoring progress and handling edge cases/blockers

**What It Produces:**
1. **feature_list.json** - Structured tracking of all features with status (pending/in_progress/pass/fail/blocked)
2. **session_progress.json** - Session-level tracking for circuit breaker logic
3. **autonomous_build_log.md** - Human-readable append-only log (tail -f friendly)
4. **Implemented codebase** - All features from app_spec.txt implemented, tested, and committed to git

**Use Cases:**
- **First use:** Build Seven Fortunas GitHub infrastructure (67 features: GitHub orgs, repos, BMAD deployment, Second Brain, 7F Lens dashboards)
- **Future uses:** ANY project with validated app_spec.txt (infrastructure, applications, services, etc.)
- **Reusable:** Domain-agnostic, parameterized for different projects

**Key Features:**
1. **Two-Agent Pattern:**
   - Initializer Mode (Session 1 only): Parse app_spec.txt → generate feature_list.json → setup structure
   - Coding Mode (Sessions 2+): Read state → implement next feature → test → commit → repeat

2. **Safety Features:**
   - Circuit breaker: After 5 consecutive failed sessions → exit code 42
   - Bounded retry: 3 attempts per feature (standard → simplified → minimal)
   - Progress tracking: Resumable after context reset (stateless sessions)

3. **Quality Gates:**
   - Test against verification criteria before marking feature complete
   - Commit frequently to persist progress
   - Log all actions for auditability

4. **Input Requirements:**
   - Validated app_spec.txt (score ≥75 from check-autonomous-implementation-readiness)
   - Project directory with git initialized
   - CLAUDE.md with project-specific instructions

**Key Insights:**
- This workflow EXECUTES the autonomous implementation pattern (not just documents it)
- Must be domain-agnostic (no Seven Fortunas hardcoding)
- Needs robust error handling and progress tracking
- Should integrate with existing BMAD workflows (create-app-spec, check-autonomous-implementation-readiness)
- Critical for AI-native development approach (PRD → app_spec.txt → Autonomous Agent)

**Success Criteria:**
- Can read any valid app_spec.txt
- Generates feature_list.json with all features
- Implements features one-by-one with verification
- Respects circuit breaker and bounded retry logic
- Tracks progress across multiple sessions
- Commits work to git regularly
- Produces human-readable logs

---

## Classification Decisions

**Workflow Name:** run-autonomous-implementation
**Target Path:** `_bmad/bmm/workflows/4-implementation/run-autonomous-implementation/`

**4 Key Decisions:**
1. **Document Output:** Non-Document (false) - Executes implementation, produces tracking files as byproducts
2. **Module Affiliation:** BMM (Business Method Module) - Part of implementation phase (4-implementation category)
3. **Session Type:** Continuable (multi-session) - Session 1 = Initializer, Sessions 2+ = Coding Agent
4. **Lifecycle Support:** Tri-Modal (Create + Edit + Validate) - Full lifecycle with restart variation support

**Structure Implications:**
- **Tri-modal folders:** `steps-c/` (create), `steps-e/` (edit), `steps-v/` (validate)
- **Continuable support:** Needs `step-01-init.md` + `step-01b-continue.md` for session detection
- **Non-document:** No output template needed, focuses on execution and progress tracking
- **Shared data:** `data/` folder contains validation rules, verification patterns, circuit breaker thresholds

**Restart Variations Supported:**
1. **Clean Slate** - Delete feature_list.json → Initializer mode (Session 1)
2. **Resume/Continue** - Keep feature_list.json → Coding mode (Sessions 2+)
3. **Selective Retry** - Edit mode to modify feature status/configuration
4. **Validate Progress** - Validate mode to check implementation status

---

## Requirements

**Flow Structure:**
- Pattern: Branching + Looping
  - Branches on session detection (feature_list.json exists → Coding mode, else → Initializer mode)
  - Loops within Coding mode (implement → test → commit → repeat until done/blocked)
- Phases:
  1. Session Detection (determines Initializer vs Coding mode)
  2. Initializer Mode (Session 1): Parse app_spec.txt → generate feature_list.json → setup structure
  3. Coding Mode (Sessions 2+): Read state → implement feature → test → update → commit → loop
  4. Circuit Breaker Check (after each session): Track failures, trigger exit if threshold reached
- Estimated steps:
  - Initializer path: ~5-7 steps
  - Coding path: ~8-10 steps (implementation loop)
  - Edit mode: ~3-4 steps
  - Validate mode: ~3-4 steps

**User Interaction:**
- Style: Mostly Autonomous with strategic checkpoints
- Decision points:
  - Initial invocation: Start new (Clean Slate) vs Resume (Continue) [automatic detection]
  - When blocked features detected: How to unblock? [human intervention needed]
  - Circuit breaker triggered: Fix issues and retry vs abort? [human decision]
- Checkpoint frequency:
  - After each session (optional progress review)
  - When circuit breaker triggers (mandatory)
  - When features are blocked (as needed)

**Inputs Required:**
- Required:
  - app_spec.txt (validated, score ≥75 from check-autonomous-implementation-readiness)
  - Project directory path (target for implementation, with git initialized)
  - CLAUDE.md (project-specific agent instructions)
- Optional:
  - Existing feature_list.json (for resume/continue mode)
  - session_progress.json (for circuit breaker state tracking)
  - autonomous_build_log.md (for progress history)
- Prerequisites:
  - Git repository initialized in project directory
  - GitHub CLI authenticated (if implementing GitHub-related features)
  - Required tools/dependencies for specific feature implementations (project-specific)

**Output Specifications:**
- Type: Non-Document (execution workflow with tracking byproducts)
- Primary Output: Implemented codebase (all features from app_spec.txt implemented, tested, committed to git)
- Progress Tracking Files:
  - feature_list.json (structured status: pending/in_progress/pass/fail/blocked)
  - session_progress.json (session count, consecutive failures, completion rates)
  - autonomous_build_log.md (human-readable append-only log, tail -f friendly)
- Additional Outputs:
  - Git commits (frequent, with descriptive messages)
  - autonomous_summary_report.md (generated when circuit breaker triggers)
- Frequency: Continuous across multiple sessions until completion

**Success Criteria:**
- All features in app_spec.txt marked "pass" in feature_list.json
- All implemented features pass functional, technical, and integration verification criteria
- All work committed to git with descriptive messages
- No features remain in "fail" status (only "pass" or "blocked")
- Code follows standards from app_spec.txt coding_standards section
- Progress tracking files complete and accurate
- Git history is clean and provides clear audit trail
- Blocked features clearly identified with reasons
- Can resume safely after interruption

**Instruction Style:**
- Overall: Mixed (Intent-Based + Prescriptive)
- Intent-Based for:
  - Feature implementation logic (adapt to different feature types)
  - Problem-solving when features fail (try different approaches)
  - Testing verification criteria (interpret and apply creatively)
  - Handling edge cases and unexpected situations
- Prescriptive for:
  - Session detection logic (exact: feature_list.json exists → Coding mode, else → Initializer)
  - Circuit breaker rules (exactly 5 consecutive failed sessions → exit code 42)
  - Bounded retry logic (exactly 3 attempts: standard → simplified → minimal)
  - Progress tracking updates (specific JSON structure, required fields)
  - Git commit format (specific message format, Co-Authored-By tag)
- Notes: Critical control flow and safety features need precision; implementation details need flexibility

---

## Tools Configuration

**Core BMAD Tools:**
- **Party Mode:** Excluded - Workflow is execution-focused, not creative/collaborative ideation
- **Advanced Elicitation:** Included - Integration point: VALIDATE mode for deep failure analysis and root cause investigation
- **Brainstorming:** Excluded - Implementation strategies defined by app_spec.txt, not brainstormed

**LLM Features:**
- **Web-Browsing:** Included - Use case: Look up current API docs, dependency versions, error messages, technology examples during implementation
  - **Specific Implementation:** vercel-labs agent-browser (https://github.com/vercel-labs/agent-browser)
- **File I/O:** Included (Mandatory) - Operations: Create/read/update feature_list.json, claude-progress.txt, autonomous_build_log.md, init.sh, app_spec.txt, implemented code/configs
- **Sub-Agents:** Excluded - Keep implementation simple and sequential
- **Sub-Processes:** Excluded - Sequential operation for reliability and clear progress tracking

**Memory:**
- Type: Continuable (multi-session)
- Tracking:
  - feature_list.json (feature status across sessions)
  - claude-progress.txt (hybrid format: structured metadata header + human-readable session logs)
  - autonomous_build_log.md (detailed append-only log)
- Continuation: step-01b-continue.md detects feature_list.json presence for session routing
- Sidecar File: Excluded (redundant - already have comprehensive state tracking)

**External Integrations:**
- **vercel-labs agent-browser** - MCP server for web browsing (requires installation)
- **Git operations** - Via bash commands (git CLI)
- **GitHub operations** - Via bash commands (gh CLI)
- **No additional MCP servers** - Bash commands preferred for simplicity

**Installation Requirements:**
- vercel-labs agent-browser (https://github.com/vercel-labs/agent-browser)
- User preference: Comfortable with installation

---

## WORKFLOW DESIGN (Complete)

**Design Date:** 2026-02-17
**Design Status:** APPROVED_FOR_FOUNDATION
**Total Design Phases:** 10

---

## Phase 1: Step Structure Design

### CREATE Mode - Complete Structure

#### Path A: Initializer Mode (Session 1) - 6 Steps

| Step | File | Type | Goal | Menu | Size |
|------|------|------|------|------|------|
| 01 | step-01-init.md | Init (Continuable) | Detect session type, route accordingly | Auto-proceed | ~150 |
| 02 | step-02-parse-app-spec.md | Middle (Simple) | Read and parse app_spec.txt XML | Auto-proceed | ~150 |
| 03 | step-03-generate-feature-list.md | Middle (Simple) | Create feature_list.json from features | Auto-proceed | ~150 |
| 04 | step-04-setup-tracking.md | Middle (Simple) | Create progress tracking files | Auto-proceed | ~150 |
| 05 | step-05-setup-environment.md | Middle (Simple) | Create init.sh and directory structure | Auto-proceed | ~150 |
| 06 | step-06-initializer-complete.md | Final | Display summary, guide to Session 2 | None | ~100 |

**Total:** ~850 lines

#### Path B: Coding Mode (Sessions 2+) - 9 Steps (with loop)

| Step | File | Type | Goal | Menu | Size |
|------|------|------|------|------|------|
| 01b | step-01b-continue.md | Continuation | Detect existing workflow, route to Coding | Auto-proceed | ~200 |
| 07 | step-07-load-session-state.md | Middle (Simple) | Read and display implementation status | Auto-proceed | ~150 |
| 08 | step-08-select-next-feature.md | Middle (Simple) | Find next pending/fail feature | Auto-proceed | ~200 |
| 09 | step-09-implement-feature.md | Middle (Standard A/P/C) | Implement selected feature (core work) | A/P/C | ~250 |
| 10 | step-10-test-feature.md | Validation Sequence | Run verification criteria tests | Auto-proceed | ~200 |
| 11 | step-11-update-tracking.md | Middle (Simple) | Update feature status based on tests | Auto-proceed | ~150 |
| 12 | step-12-commit-work.md | Middle (Simple) | Git commit with standard format | Auto-proceed | ~150 |
| 13 | step-13-check-completion.md | Branch (L/C/X) | Loop, Complete, or Circuit Breaker | Branch | ~200 |
| 14 | step-14-complete.md | Final | Display final summary | None | ~150 |

**Total:** ~1,650 lines
**Loop:** step-13 → step-08 (repeats until done/blocked/circuit breaker)

### EDIT Mode - 4 Steps

| Step | File | Type | Goal | Menu | Size |
|------|------|------|------|------|------|
| 01 | step-01-assess.md | Init (Non-Continuable) | Load state, display edit options | Custom (F/C/B/X) | ~200 |
| 02 | step-02-edit-features.md | Middle (Standard A/P/C) | Modify feature statuses, retry counts | A/P/C | ~200 |
| 03 | step-03-edit-circuit-breaker.md | Middle (Simple) | Adjust circuit breaker thresholds | C only | ~150 |
| 04 | step-04-complete.md | Final | Save changes, optional validation | Optional validation | ~150 |

**Total:** ~700 lines

### VALIDATE Mode - 4 Steps

| Step | File | Type | Goal | Menu | Size |
|------|------|------|------|------|------|
| 01 | step-01-validate-state.md | Validation Sequence | Verify tracking files integrity | Auto-proceed | ~150 |
| 02 | step-02-validate-implementation.md | Validation Sequence | Check implemented features match status | Auto-proceed | ~200 |
| 03 | step-03-validate-circuit-breaker.md | Validation Sequence | Check circuit breaker state consistency | Auto-proceed | ~150 |
| 04 | step-04-generate-report.md | Final | Create validation report | None | ~200 |

**Total:** ~700 lines

### Summary

- **Total Steps:** 23 step files
- **Total Lines:** ~3,900 lines (steps only)
- **CREATE mode:** 14 steps (6 Initializer + 1 continuation + 8 Coding loop)
- **EDIT mode:** 4 steps
- **VALIDATE mode:** 4 steps
- **Plus:** workflow.md (~300 lines), data files (~1,000 lines), templates (~500 lines)
- **Grand Total:** ~5,700 lines across 30+ files

---

## Phase 2: Continuation Support Assessment

**Status:** ✅ CONTINUABLE

**Implementation:**
- step-01-init.md checks for feature_list.json existence
- If exists → loads step-01b-continue.md (Coding mode)
- If not exists → continues to step-02 (Initializer mode)
- Automatic detection (no user prompt)
- Fail-safe: Corrupted file falls back to Initializer

**Session Routing:**
```
feature_list.json EXISTS + VALID → step-01b-continue.md → step-07 (Coding mode)
feature_list.json MISSING or INVALID → step-02 (Initializer mode)
```

---

## Phase 3: Interaction Pattern Design

### Menu Pattern Assignments

| Step | Pattern | Rationale |
|------|---------|-----------|
| step-01 to step-08 | Auto-proceed | Automated setup/state loading |
| **step-09** | **A/P/C** | Only interactive step (implementation may need refinement) |
| step-10 to step-12 | Auto-proceed | Test, update, commit sequence |
| **step-13** | **Branch (L/C/X)** | Loop decision point |
| step-14 | None (final) | Completion |
| EDIT step-01 | Custom (F/C/B/X) | Edit mode menu |
| EDIT step-02 | A/P/C | Feature modifications |
| EDIT step-03 to step-04 | C only | Simple adjustments |
| VALIDATE all | Auto-proceed | Validation sequence |

**Key Design Decision:** Only step-09 in Coding loop has A/P menu (95% automated, 5% interactive)

---

## Phase 4: Data Flow Design

### Input Documents (Read-Only)
- **app_spec.txt** - Feature specifications (XML)
- **CLAUDE.md** - Agent instructions
- **init.sh** - Environment setup (created Session 1, rarely modified)

### State Tracking (Read/Write)
- **feature_list.json** - Feature status, attempts, verification results
- **claude-progress.txt** - Hybrid: metadata header + session logs
- **autonomous_build_log.md** - Detailed append-only log

### Output Artifacts
- **Git commits** - Implemented features
- **Repos/Files/Configs** - Infrastructure components
- **Validation reports** - Quality check results

### State File Formats

**feature_list.json:**
```json
{
  "metadata": {"project_name": "...", "total_features": 67},
  "features": [
    {
      "id": "FEATURE_001",
      "name": "...",
      "status": "pass|fail|pending|blocked",
      "attempts": 0-3,
      "verification_results": {
        "functional": "pass|fail|null",
        "technical": "pass|fail|null",
        "integration": "pass|fail|null"
      },
      "blocked_reason": "...",
      "last_updated": "2026-02-17T10:30:00Z"
    }
  ]
}
```

**claude-progress.txt (Hybrid Format):**
```txt
# METADATA (Structured - for circuit breaker)
session_count=12
consecutive_failures=2
circuit_breaker_threshold=5
circuit_breaker_status=HEALTHY

# SESSION LOGS (Human-readable - append-only)
## Session 1: Initializer (2026-02-16 09:00)
- Generated feature_list.json...

## Session 2: Coding Agent (2026-02-16 10:30)
- Implemented FEATURE_001 → PASS
...
```

### Critical Data Flow Rules
1. **Immutable app_spec.txt** - Never modified
2. **Append-only logs** - autonomous_build_log.md never truncated
3. **Atomic updates** - feature_list.json updated per feature
4. **Session isolation** - Each session reads fresh state from disk
5. **Git as checkpoint** - All progress committed before session end

---

## Phase 5: File Structure Design

### Directory Structure
```
_bmad/bmm/workflows/4-implementation/run-autonomous-implementation/
├── workflow.md                    # Entry point (mode routing)
├── data/                          # Shared reference (6 files)
│   ├── autonomous-implementation-standards.md
│   ├── circuit-breaker-rules.md
│   ├── bounded-retry-patterns.md
│   ├── verification-criteria-guide.md
│   ├── session-detection-logic.md
│   └── git-commit-standards.md
├── templates/                     # Output templates (5 files)
│   ├── feature-list-template.json
│   ├── claude-progress-template.txt
│   ├── autonomous-build-log-template.md
│   ├── init-sh-template.sh
│   └── validation-report-template.md
├── steps-c/                       # CREATE mode (14 files)
├── steps-e/                       # EDIT mode (4 files)
└── steps-v/                       # VALIDATE mode (4 files)
```

**Total Files:** 30 (1 workflow + 6 data + 5 templates + 14 create + 4 edit + 4 validate)

### Data Files Purpose

1. **autonomous-implementation-standards.md** (~200 lines)
   - Feature implementation principles
   - Status definitions
   - Session lifecycle rules

2. **circuit-breaker-rules.md** (~150 lines)
   - Session success/failure definitions
   - Consecutive failure tracking
   - Exit code 42 behavior
   - Recovery procedures

3. **bounded-retry-patterns.md** (~200 lines)
   - Three-attempt strategy (standard → simplified → minimal)
   - Retry degradation examples
   - Logging requirements

4. **verification-criteria-guide.md** (~250 lines)
   - Three criteria types (functional, technical, integration)
   - Testing strategies by feature type
   - Pass/fail determination rules

5. **session-detection-logic.md** (~150 lines)
   - Decision tree (feature_list.json exists → Coding, else → Initializer)
   - Validation checks
   - Edge case handling (corrupted state)

6. **git-commit-standards.md** (~100 lines)
   - Commit message format
   - Type prefixes (feat, fix, docs, config, test)
   - Commit frequency strategy

---

## Phase 6: Role and Persona Definition

### Primary Role
**Name:** Autonomous Implementation Orchestrator
**Expertise:** DevOps, Infrastructure Automation, Git Workflows, QA
**Autonomy:** High (95% automated, 5% human decision points)

### Communication Style by Mode

**Initializer Mode (Session 1):**
- **Tone:** Methodical and informative
- **Voice:** Process-focused narrator
- **Example:** "Parsing app_spec.txt... Found 67 features across 7 categories."

**Coding Mode (Sessions 2+):**
- **Tone:** Concise and action-oriented
- **Voice:** Efficient implementer
- **Example:** "Session 3 starting... Selected: FEATURE_006 - Deploy BMAD submodule"

**EDIT Mode:**
- **Tone:** Consultative and precise
- **Voice:** Technical advisor
- **Example:** "Circuit breaker: 2/5 failures. What would you like to edit?"

**VALIDATE Mode:**
- **Tone:** Analytical and objective
- **Voice:** Quality auditor
- **Example:** "Checking state integrity... ⚠ 2 issues found (see report)"

### Persona Traits
1. **Execution-Focused** - Prioritizes action over discussion
2. **Progress-Transparent** - Real-time status updates
3. **Failure-Resilient** - Treats failures as expected, not exceptional
4. **State-Aware** - Always references current state in context
5. **Non-Judgmental** - Reports issues objectively

### Decision Points

**NEVER Ask:**
- Whether to proceed to next automated step
- Whether to create standard tracking files
- Whether to commit after successful implementation

**ALWAYS Ask:**
- Which mode to run (if not specified)
- Whether to reset circuit breaker after manual intervention
- Manual feature selection (if dependencies conflict)

**Status Symbols:**
```
✓ - Pass/Success/Complete
⚠ - Warning/Attention needed
❌ - Fail/Error/Critical
🔴 - Circuit breaker triggered
⏳ - In progress
📊 - Summary/Report
```

---

## Phase 7: Validation and Error Handling

### Three-Layer Validation Architecture

**Layer 1: Input Validation (Before Execution)**
- app_spec.txt existence and structure
- State files integrity (if continuing)
- Environment prerequisites (git, gh CLI authenticated)
- Exit codes: 1-9

**Layer 2: Runtime Validation (During Execution)**
- Feature implementation success
- Verification criteria pass/fail (functional, technical, integration)
- State update integrity with atomic rollback
- Exit codes: 20-39

**Layer 3: Post-Execution Validation (VALIDATE Mode)**
- State consistency checks
- Implementation verification
- Circuit breaker accuracy
- Report generation
- Exit codes: 50-59

### Error Taxonomy

| Category | Code Range | Recovery Strategy |
|----------|------------|-------------------|
| Initialization | 1-9 | Exit, fix prerequisites, restart |
| State Corruption | 10-19 | Restore from git or clean slate |
| Runtime | 20-29 | Rollback state, mark feature as fail |
| Feature Implementation | 30-39 | Bounded retry (3 attempts), then block |
| Circuit Breaker | 40-49 | Generate report, exit, human intervention |
| Validation | 50-59 | Generate report, recommend fixes |

### Error Handling Patterns

1. **Fail-Fast** - Critical errors (missing prerequisites)
2. **Retry with Degradation** - Feature failures (3 attempts)
3. **Rollback and Retry** - State corruption (atomic updates with backup)
4. **Graceful Degradation** - Circuit breaker (exit code 42)

### Validation Checks (VALIDATE Mode)

**5 Validation Dimensions:**
1. **File Integrity** (CRITICAL) - JSON syntax, required fields, no duplicates
2. **Status Consistency** (HIGH) - "pass" has results, "blocked" has reason
3. **Implementation Verification** (MEDIUM) - Files exist, tests re-runnable
4. **Circuit Breaker Accuracy** (HIGH) - Metadata calculations correct
5. **Dependency Tracking** (MEDIUM) - No circular deps, references valid

---

## Phase 8: Subprocess Optimization Design

**Decision:** ❌ **SUBPROCESSES EXCLUDED**

**Rationale:**
1. Stateful dependencies between features
2. Circuit breaker requires linear session progression
3. Git commit ordering needs clarity
4. Simpler debugging with sequential operations
5. Clear progress tracking for user

**Architecture:** Sequential execution only (one feature at a time)

**Identified Opportunities (NOT Implemented):**
- Multi-feature verification parallelization (saves ~20s, low priority)
- Batch feature implementation (high complexity, low benefit)
- Validation mode parallelization (moderate benefit, may add in v2.0)

**Alternative Optimizations (Implemented):**
1. **Smart Feature Selection** - Independent features first
2. **Bounded Retry with Degradation** - Don't waste time on hopeless features
3. **Incremental Commits** - Persist after each feature (not batch at end)
4. **Lazy Loading** - Parse only selected feature (not all 67 upfront)

**Performance Profile:**
- Session 1 (Initializer): 2-5 minutes
- Session 2-N (Coding): 10-30 minutes each (3-8 features)
- Total implementation: 3-6 hours (10-15 sessions)
- Human time: 30 minutes (review + EDIT adjustments)

---

## Phase 9: Special Features Design

### Feature 1: Two-Agent Pattern (Session Detection)
**Implementation:** step-01-init.md checks feature_list.json existence
- EXISTS + VALID → step-01b-continue.md → Coding mode
- MISSING or INVALID → step-02 → Initializer mode
- **Fully automatic** (no user prompt)

### Feature 2: Circuit Breaker with Exit Code 42
**Tracking:** consecutive_failures in claude-progress.txt metadata
**Threshold:** 5 consecutive failed sessions (configurable)
**Trigger:** Generate autonomous_summary_report.md, exit code 42
**Recovery:** Human fixes issues, uses EDIT mode to reset, restarts

**Session Success Definition:**
- At least 1 feature: pending → pass
- OR at least 1 feature: fail → pass
- OR any attempted features this session

**Session Failure Definition:**
- No feature status changes
- No progress made (same state as session start)

### Feature 3: Bounded Retry with Progressive Degradation
**Three-Attempt Strategy:**

| Attempt | Approach | Time Budget | Description |
|---------|----------|-------------|-------------|
| 1 | Standard | 5-10 min | Full implementation per app_spec.txt |
| 2 | Simplified | 3-5 min | Skip optional requirements |
| 3 | Minimal | 1-2 min | Bare essentials only |
| 4+ | Block | 0 min | Mark blocked, move to next feature |

**Tracking:** attempts field in feature_list.json (incremented in step-11)

### Feature 4: Hybrid Progress Tracking
**Format:** claude-progress.txt
- **Top section:** Structured metadata (key=value, parseable)
  - session_count, consecutive_failures, circuit_breaker_status, etc.
- **Bottom section:** Human-readable session logs (append-only)
  - "## Session N: Type (Date)" format

**Updates:**
- Metadata: Updated in-place via sed (step-13)
- Logs: Appended only (never modified)

### Feature 5: Loop-Back Architecture
**Implementation:** step-13-check-completion.md branches:
- **[L] Loop** → load step-08 (more features to implement)
- **[C] Complete** → load step-14 (all done)
- **[X] Circuit Breaker** → exit 42 (failures exceeded threshold)

**Loop Condition:**
```
IF (pending features > 0) OR (fail features with attempts < 3):
    → Loop to step-08
ELSE IF all features pass or blocked:
    → Complete (step-14)
ELSE IF consecutive_failures >= threshold:
    → Exit 42
```

### Feature 6: Cross-Mode Transitions
- **CREATE → VALIDATE:** Step-14 offers validation trigger
- **EDIT → VALIDATE:** Step-04 offers validation trigger
- **VALIDATE → EDIT:** Report recommends EDIT mode for fixes
- **All modes accessible via workflow.md mode selection**

### Feature 7: Restart Variation Support
1. **Clean Slate:** Delete feature_list.json → Initializer mode
2. **Resume/Continue:** Keep feature_list.json → Coding mode (automatic)
3. **Selective Retry:** EDIT mode to reset specific features
4. **Validate Progress:** VALIDATE mode to check state

### Feature 8: Web Browsing for Implementation Research
**Tool:** vercel-labs agent-browser (MCP server)
**Use Cases:**
- Look up current API documentation during implementation
- Research error messages when features fail
- Find technology examples for complex features
**Integration:** Available in step-09 (implementation step)

---

## Design Summary

**Workflow Characteristics:**
- **Type:** Non-Document (execution workflow)
- **Module:** BMM (Business Method Module)
- **Category:** 4-implementation
- **Structure:** Tri-modal (Create/Edit/Validate)
- **Session:** Continuable (multi-session support)
- **Autonomy:** 95% automated (only step-09 has interactive menu in Coding loop)

**Key Innovations:**
1. ✅ Two-agent pattern with automatic session detection
2. ✅ Circuit breaker (exit code 42) prevents infinite loops
3. ✅ Bounded retry (3 attempts) with progressive degradation
4. ✅ Hybrid progress tracking (structured + human-readable)
5. ✅ Loop-back architecture (step-13 → step-08)
6. ✅ Domain-agnostic (works with any validated app_spec.txt)

**File Deliverables:**
- 1 workflow.md (entry point)
- 23 step files (14 create + 4 edit + 4 validate + 1 continuation)
- 6 data files (standards, rules, patterns, guides)
- 5 templates (output file structures)
- **Total:** 35 files, ~5,700 lines

**Next Phase:** Foundation (create workflow.md and directory structure)

---

**Design Approved Date:** 2026-02-17
**Ready for Step 7: Foundation Phase**