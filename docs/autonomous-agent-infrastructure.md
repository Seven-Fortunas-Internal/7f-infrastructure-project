---
title: Autonomous Agent Infrastructure
type: reference
description: Documentation for the Claude Code SDK autonomous agent implementation
version: 1.0.0
last_updated: 2026-02-17
status: active
author: Jorge
context_level: technical
relevant_for: ["developers", "ai-agents", "operations"]
tags: ["autonomous-agents", "claude-code", "infrastructure", "automation"]
---

# Autonomous Agent Infrastructure

**Claude Code SDK-based autonomous implementation system**

## Overview

The Seven Fortunas project uses a **two-agent autonomous implementation pattern** powered by Claude Code SDK and Claude Sonnet 4.5 model.

### Key Components

1. **app_spec.txt** - Feature specification (input)
2. **feature_list.json** - Implementation tracking (state)
3. **claude-progress.txt** - Progress metadata (monitoring)
4. **autonomous_build_log.md** - Detailed execution log (audit trail)
5. **scripts/** - Automation and verification scripts (implementation)

## Architecture

### Two-Agent Pattern

**Agent 1: Initializer (Planning)**
- **Role:** Parse PRD, extract features, initialize tracking
- **Input:** app_spec.txt (generated from PRD)
- **Output:** feature_list.json (all features marked "pending")
- **Runtime:** Single execution at project start

**Agent 2: Coding (Implementation)**
- **Role:** Implement features autonomously with bounded retry
- **Input:** feature_list.json (reads next pending feature)
- **Output:** Code, tests, documentation, updated tracking files
- **Runtime:** Continuous loop until all features complete

### Model Configuration

**Model:** `claude-sonnet-4-5-20250929`
- Latest Claude Sonnet 4.5 release
- Optimized for code generation and autonomous execution
- Zero permission prompts via Python Agent SDK

## File Specifications

### app_spec.txt

**Format:** XML with YAML frontmatter
**Purpose:** Feature specification generated from PRD
**Structure:**
```xml
---
stepsCompleted: [...]
feature_count: 42
workflow_status: 'completed'
---

<?xml version="1.0" encoding="UTF-8"?>
<application_specification>
  <metadata>...</metadata>
  <feature_list>
    <feature id="FEATURE_001">
      <name>FR-1.4: GitHub CLI Authentication Verification</name>
      <description>...</description>
      <requirements>...</requirements>
      <verification_criteria>...</verification_criteria>
    </feature>
  </feature_list>
</application_specification>
```

**Generation:** Created by BMAD workflow `/bmad-bmb-create-app-spec`

### feature_list.json

**Format:** JSON
**Purpose:** Track implementation status for all features
**Structure:**
```json
{
  "metadata": {
    "generated_date": "2026-02-17",
    "project_name": "7F_github",
    "total_features": 42
  },
  "features": [
    {
      "id": "FEATURE_001",
      "name": "FR-1.4: GitHub CLI Authentication Verification",
      "status": "pass",
      "attempts": 1,
      "dependencies": [],
      "verification_results": {
        "functional": "pass",
        "technical": "pass",
        "integration": "pass"
      },
      "last_updated": "2026-02-17T19:23:00Z"
    }
  ]
}
```

**Status Values:**
- `pending` - Not yet started
- `pass` - Successfully implemented and verified
- `fail` - Failed implementation (< 3 attempts)
- `blocked` - Cannot proceed (3+ attempts or dependency issue)

### claude-progress.txt

**Format:** Plain text (machine-readable)
**Purpose:** Quick progress overview for monitoring
**Structure:**
```
# Seven Fortunas Autonomous Implementation Progress

session_count=1
features_completed=11
features_pending=31
features_fail=0
features_blocked=0
circuit_breaker_status=HEALTHY
last_updated=2026-02-17T20:05:00Z

## Session Logs
- FEATURE_001: PASS
- FEATURE_002: PASS
...
```

**Monitoring:**
```bash
# Watch progress in real-time
tail -f claude-progress.txt

# Check completion percentage
grep "^features_completed=" claude-progress.txt
```

### autonomous_build_log.md

**Format:** Markdown
**Purpose:** Detailed execution log with verification results
**Structure:**
```markdown
### FEATURE_001: FR-1.4: GitHub CLI Authentication Verification
**Started:** 2026-02-17 19:23:00 | **Approach:** STANDARD | **Category:** Infrastructure

#### Implementation Actions:
1. Analyzed requirements
2. Created verification script: scripts/validate_github_auth.sh
3. Ran verification tests

#### Verification Testing
1. **Functional Test:** PASS
2. **Technical Test:** PASS
3. **Integration Test:** PASS

#### Git Commit
**Hash:** 57d7006
**Type:** feat
---
```

**Usage:**
```bash
# Monitor implementation details
tail -f autonomous_build_log.md

# Review specific feature
grep -A 30 "FEATURE_024" autonomous_build_log.md
```

## Implementation Workflow

### Bounded Retry Strategy

Each feature uses a **3-attempt bounded retry** with progressive simplification:

**Attempt 1: STANDARD (5-10 min)**
- Full implementation with all requirements
- Complete error handling and tests
- All verification criteria must pass

**Attempt 2: SIMPLIFIED (3-5 min)**
- Core functionality only
- Basic error handling
- Focus on functional criteria

**Attempt 3: MINIMAL (1-2 min)**
- Bare essentials
- Placeholders acceptable
- Must satisfy functional criteria minimum

**Attempt 4+: BLOCKED**
- Mark feature as blocked
- Document reason in implementation_notes
- Move to next feature

### Verification Criteria

Every feature must pass three types of verification:

**Functional Criteria** (User-facing)
- What the feature does from user perspective
- Example: "Execute command and verify output message"

**Technical Criteria** (Internal correctness)
- How it's implemented under the hood
- Example: "Command exits with status code 0"

**Integration Criteria** (System interaction)
- How it works with other components
- Example: "Can perform authenticated operations"

## Monitoring & Control

### Real-Time Monitoring

```bash
# Watch overall progress
watch -n 5 'cat claude-progress.txt | grep "features_"'

# Watch detailed logs
tail -f autonomous_build_log.md

# Check current feature
jq -r '.features[] | select(.status == "in_progress") | .id' feature_list.json
```

### Circuit Breakers

Automatic stops when:
1. **MAX_ITERATIONS** reached (default: 10 features per session)
2. **MAX_CONSECUTIVE_SESSION_ERRORS** (default: 5 errors)
3. **MAX_STALL_SESSIONS** (default: 5 sessions with no progress)
4. **All features complete**

### Manual Control

```bash
# Stop current session
pkill -f "python.*agent.py"

# Resume from where it stopped
./scripts/run-autonomous.sh --continuous

# Run single feature
./scripts/run-autonomous.sh --single FEATURE_024
```

## Directory Structure

```
/home/ladmin/dev/GDF/7F_github/
├── app_spec.txt                    # Feature specification (input)
├── feature_list.json               # Implementation tracking
├── claude-progress.txt             # Progress metadata
├── autonomous_build_log.md         # Detailed log
├── scripts/                        # Implementation scripts
│   ├── validate_github_auth.sh
│   ├── create_github_orgs.sh
│   └── ...
├── docs/                           # Documentation
│   └── autonomous-agent-infrastructure.md
└── autonomous-implementation/      # Agent framework (if using Python SDK)
    ├── agent.py                    # Core agent logic
    ├── client.py                   # Claude API client
    └── prompts/                    # Agent prompts
```

## Usage Examples

### Initialize New Project

```bash
# 1. Generate app_spec.txt from PRD
/bmad-bmb-create-app-spec

# 2. Initialize feature tracking (Initializer agent)
python agent.py --mode initialize

# 3. Start autonomous implementation (Coding agent)
python agent.py --mode coding --continuous
```

### Resume Implementation

```bash
# Continue from where we left off
python agent.py --mode coding --continuous
```

### Single Feature Implementation

```bash
# Implement specific feature
python agent.py --mode coding --feature FEATURE_024
```

## Troubleshooting

### Issue: Feature marked as blocked

**Cause:** 3 failed attempts or unsatisfied dependencies

**Solution:**
1. Check implementation_notes in feature_list.json
2. Resolve dependency issues
3. Reset status to "pending" and retry

### Issue: Circuit breaker triggered

**Cause:** Too many consecutive errors or stalls

**Solution:**
1. Review autonomous_build_log.md for errors
2. Fix systemic issues (permissions, dependencies)
3. Reset circuit breaker and resume

### Issue: Verification tests failing

**Cause:** Implementation doesn't meet criteria

**Solution:**
1. Review verification_criteria in feature_list.json
2. Check verification_results for which test failed
3. Re-implement with focus on failing criterion

## Best Practices

1. **Monitor Progress:** Use `tail -f` to watch logs in real-time
2. **Commit Frequently:** Agent commits after each passing feature
3. **Review Blockers:** Address blocked features promptly
4. **Trust Verification:** All three criteria must pass
5. **Let It Run:** Agent makes reasonable decisions autonomously

## References

- **BMAD Workflows:** `_bmad/bmb/workflows/`
- **Agent Prompts:** `autonomous-implementation/prompts/`
- **Implementation Plan:** `AUTONOMOUS-IMPLEMENTATION-PLAN.md`

---

**Document Metadata:**
- **Type:** Technical Reference
- **Version:** 1.0.0
- **Last Updated:** 2026-02-17
- **Context:** Technical (implementation details)
- **Audience:** Developers, AI agents, operations teams
