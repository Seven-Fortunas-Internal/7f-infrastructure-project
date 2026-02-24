# Autonomous Implementation Standards

**Purpose:** Define quality and execution standards for autonomous implementation sessions.

---

## Core Principles

### 1. Domain Agnostic
- Workflow must work with ANY validated app_spec.txt
- No hardcoded assumptions about feature types
- Generic verification criteria interpretation
- Flexible implementation approach

### 2. Bounded Autonomy
- Circuit breaker prevents infinite loops
- Bounded retry (3 attempts max per feature)
- Automatic escalation on persistent failures
- Human intervention triggers when needed

### 3. State Integrity
- Atomic updates with rollback capability
- JSON validation after every modification
- Backup before any destructive operation
- Consistent metadata across tracking files

### 4. Traceability
- Every action logged to autonomous_build_log.md
- Git commits for all feature implementations
- Timestamp tracking for all state changes
- Session history preserved

---

## Implementation Quality Standards

### Feature Implementation

**MUST:**
- ✅ Read and understand feature specification fully
- ✅ Generate implementation plan before coding
- ✅ Follow domain-specific best practices
- ✅ Create working, functional code
- ✅ Self-test before marking complete
- ✅ Commit atomically with descriptive message

**MUST NOT:**
- ❌ Generate placeholder/mock implementations
- ❌ Skip error handling
- ❌ Ignore verification criteria
- ❌ Make unsafe assumptions
- ❌ Create security vulnerabilities

### Verification Execution

**Functional Criteria:**
- Tests if feature works as intended for end-users
- Validates core functionality is present
- Checks expected behavior occurs
- Examples: API returns correct data, file created with content, service responds

**Technical Criteria:**
- Tests if implementation meets technical standards
- Validates code quality, syntax correctness
- Checks configuration validity
- Examples: YAML syntax valid, required fields present, naming conventions followed

**Integration Criteria:**
- Tests if feature integrates with other components
- Validates dependencies work correctly
- Checks cross-feature interactions
- Examples: API connectivity works, file links resolve, permissions correct

**Pass Logic:**
- ALL non-skipped tests must pass
- ANY failure = overall FAIL
- If ALL tests skipped = PASS (no criteria to fail)

### Retry Strategy (Bounded Retry)

**Attempt 1: STANDARD Implementation**
- Full implementation with comprehensive error handling
- Complete feature with all verification criteria addressed
- Detailed implementation notes

**Attempt 2: SIMPLIFIED Implementation**
- Streamlined approach with reduced complexity
- Focus on core functionality only
- Simplified error handling

**Attempt 3: MINIMAL Implementation**
- Bare minimum to satisfy verification criteria
- Absolute simplest approach
- Last chance before blocking

**After 3 Attempts:**
- Feature marked "blocked"
- blocked_reason documented
- Circuit breaker check (consecutive failures)
- Human intervention recommended

---

## Session Execution Standards

### Session Detection

**Clean Slate (Session 1):**
- feature_list.json does NOT exist
- Run Path A (Initializer)
- Generate feature_list.json, claude-progress.txt, init.sh
- Set up tracking infrastructure

**Resume (Session 2+):**
- feature_list.json EXISTS and valid
- Run Path B (Coding Agent Loop)
- Load existing state and continue
- Auto-detect without user intervention

### Session Success Criteria

**Session Succeeds IF:**
- At least ONE feature status changed from non-pass to "pass"
- OR: No actionable features remain (all complete/blocked)

**Session Fails IF:**
- No features completed
- All implementation attempts failed
- No progress made

### Circuit Breaker Rules

**Trigger Conditions:**
- consecutive_failures >= threshold (default: 5)
- Threshold configurable (recommended: 3-10)

**When Triggered:**
- Workflow exits immediately with code 42
- Generate autonomous_summary_report.md
- Provide diagnostic information
- Recommend corrective actions

**Reset Conditions:**
- Manual reset via EDIT mode
- After fixing root causes
- User confirms ready to resume

---

## Git Commit Standards

### Commit Frequency
- After each feature implementation (pass or fail)
- Before context switches
- When circuit breaker about to trigger
- At session boundaries

### Commit Message Format

**Success:**
```
feat(FEATURE_ID): Feature Name

Implemented and verified feature.

Verification results:
- Functional: pass
- Technical: pass
- Integration: pass

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Failure:**
```
fix(FEATURE_ID): Feature Name (attempt N)

Implementation attempt N failed.

Failure reasons:
- Functional: error message
- Technical: error message

Feature will retry in next session.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

### What to Commit
- Implementation code/files
- feature_list.json (updated status)
- claude-progress.txt (updated metadata)
- autonomous_build_log.md (session logs)

**DO NOT commit:**
- Temporary files
- Build artifacts
- Credentials/secrets
- IDE configuration

---

## Error Handling Standards

### Recoverable Errors
- Retry with simplified approach
- Document error in implementation_notes
- Increment attempts counter
- Continue to next feature

### Non-Recoverable Errors
- Mark feature "blocked"
- Document blocked_reason clearly
- Log to build log
- Continue to next feature

### Fatal Errors
- Invalid app_spec.xml (exit code 8)
- Corrupted tracking files (exit code 10)
- Git repository missing (exit code 11)
- Missing prerequisites (exit codes 1-6)

---

## State Management Standards

### Atomic Updates
1. Create backup of file
2. Modify file (to .tmp)
3. Validate modification
4. Commit (move .tmp to original)
5. Remove backup

**Rollback if:**
- Validation fails
- Corruption detected
- Update incomplete

### Metadata Consistency

**feature_list.json:**
- metadata.total_features = features array length
- All features have required fields
- Status values are valid enums
- Attempts counter ≥ 0

**claude-progress.txt:**
- feature counts match feature_list.json
- consecutive_failures ≥ 0
- threshold ≥ 1
- circuit_breaker_status valid enum

---

## Performance Standards

### Sequential Execution
- No parallel processing (reliability over speed)
- One feature at a time
- Complete verification before moving to next
- Predictable execution flow

### Resource Limits
- No infinite loops
- Bounded retry (3 attempts max)
- Circuit breaker prevents runaway
- Timeout on long-running operations

---

## Documentation Standards

### Build Log (autonomous_build_log.md)
- Append-only (never truncate)
- Timestamp all entries
- Include feature ID in all logs
- Record all decisions and outcomes

### Progress File (claude-progress.txt)
- Hybrid format: structured metadata + human logs
- Metadata parseable by scripts
- Logs human-readable
- Updated every session

### Feature List (feature_list.json)
- Valid JSON always
- Backup before modify
- Validate after modify
- Consistent metadata

---

## Security Standards

### Safe Operations
- ✅ Read existing files
- ✅ Create new files in project directory
- ✅ Modify tracking files atomically
- ✅ Execute safe git commands

### Unsafe Operations (Avoid)
- ❌ Destructive git operations (force push, reset --hard)
- ❌ Deleting files outside project
- ❌ Running arbitrary code from external sources
- ❌ Exposing credentials in logs/commits

---

## Quality Assurance

### Pre-Commit Checks
- All files valid (JSON syntax, YAML syntax, etc.)
- Tracking files consistent
- Git repository clean
- No credentials exposed

### Post-Implementation Checks
- Feature verification passed
- Tracking updated correctly
- Git commit created
- Build log updated

---

## Metrics and Reporting

### Session Metrics
- Features attempted
- Features passed
- Features failed
- Features blocked
- Time elapsed
- Commits created

### Circuit Breaker Metrics
- Consecutive failures
- Threshold
- Status (HEALTHY/TRIGGERED/COMPLETE)
- Last session success

### Progress Metrics
- Total features
- Pass count (% complete)
- Pending count
- Fail count (retry eligible)
- Blocked count

---

**Version:** 1.0.0
**Created:** 2026-02-17
**Applies To:** run-autonomous-implementation workflow
