# Session Detection Logic

**Purpose:** Define how workflow automatically detects whether to run Path A (Initializer) or Path B (Coding Agent Loop) based on implementation state.

---

## Overview

**Key Innovation:** User never manually selects mode. Workflow automatically detects state and routes to appropriate path.

**Decision Point:** step-01-init.md (CREATE mode entry point)

**Detection Mechanism:** Presence and validity of feature_list.json

---

## Detection Logic (step-01)

### Check 1: Does feature_list.json Exist?

```bash
FEATURE_LIST_FILE="{project_folder}/feature_list.json"

if [[ -f "$FEATURE_LIST_FILE" ]]; then
    # File exists - check validity
    CHECK_2
else
    # File does NOT exist
    ROUTE_TO_PATH_A
fi
```

---

### Check 2: Is feature_list.json Valid JSON?

```bash
if jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then
    # Valid JSON - this is Session 2+
    ROUTE_TO_PATH_B
else
    # Corrupted JSON
    DISPLAY_ERROR_AND_EXIT
fi
```

---

## Routing Logic

### Route to Path A (Initializer)

**Condition:**
- feature_list.json does NOT exist

**Action:**
- Display "Session 1: Initializer Mode" banner
- Continue to step-02 (parse app_spec.txt)

**Rationale:**
- No tracking files = implementation not started
- Need to initialize tracking infrastructure

**Path A Steps:**
1. step-01-init.md (detection, prerequisites)
2. step-02-parse-app-spec.md
3. step-03-generate-feature-list.md
4. step-04-setup-tracking.md
5. step-05-setup-environment.md
6. step-06-initializer-complete.md (end Session 1)

---

### Route to Path B (Coding Agent Loop)

**Condition:**
- feature_list.json EXISTS and is valid JSON

**Action:**
- Load step-01b-continue.md (continuation handler)
- Display "Session N: Resuming Implementation" banner

**Rationale:**
- Tracking files exist = implementation in progress
- Resume from previous state

**Path B Entry:**
1. step-01-init.md (detection)
2. **step-01b-continue.md** (continuation handler)
3. step-07-load-session-state.md
4. ... (loop continues)

---

## State Validation (step-01b)

After routing to Path B, validate state thoroughly:

### Validation Checks

```bash
# 1. feature_list.json is valid JSON (already checked)
jq empty "$FEATURE_LIST_FILE"

# 2. claude-progress.txt exists
[[ -f "$PROGRESS_FILE" ]]

# 3. Required metadata present
jq -e '.metadata.total_features' "$FEATURE_LIST_FILE"
jq -e '.features' "$FEATURE_LIST_FILE"

# 4. Circuit breaker status checked
CB_STATUS=$(grep '^circuit_breaker_status=' "$PROGRESS_FILE" | cut -d= -f2)

if [[ "$CB_STATUS" == "TRIGGERED" ]]; then
    # Exit immediately if circuit breaker already triggered
    exit 42
fi
```

---

## Error Scenarios

### Scenario 1: feature_list.json Exists but Corrupted

**Detection:**
- File exists
- JSON validation fails

**Error Message:**
```
❌ ERROR: feature_list.json is corrupted (invalid JSON)

This file may have been manually edited incorrectly or
interrupted during writing.

Options:
1. Restore from backup: feature_list.json.backup
2. Use EDIT mode to fix (if possible)
3. Delete feature_list.json to start fresh (loses progress)

Exiting with code 10 (corrupted state)
```

**Exit Code:** 10

**Recovery:**
- Restore from backup (if available)
- Delete feature_list.json to restart (loses all progress)
- Manually fix JSON syntax

---

### Scenario 2: feature_list.json Exists but claude-progress.txt Missing

**Detection:**
- feature_list.json valid
- claude-progress.txt missing

**Action:**
- Route to Path B (implementation exists)
- step-01b will detect missing progress file
- Can continue (progress file less critical than feature list)

**Warning Message:**
```
⚠️  WARNING: claude-progress.txt not found

Feature list exists, but progress tracking file missing.
This may indicate:
- Progress file manually deleted
- Incomplete initialization
- File system issue

Continuing implementation, but session history unavailable.
```

---

### Scenario 3: app_spec.txt Missing (Path A)

**Detection:**
- feature_list.json does NOT exist (Path A selected)
- app_spec.txt does NOT exist

**Error Message:**
```
❌ ERROR: app_spec.txt not found

Path: {project_folder}/app_spec.txt

Autonomous implementation requires app_spec.txt as input.

Generate app_spec.txt using:
  /bmad-bmm-create-app-spec

Exiting with code 7 (missing input)
```

**Exit Code:** 7

---

### Scenario 4: Circuit Breaker Already Triggered (Path B)

**Detection:**
- feature_list.json valid (Path B selected)
- claude-progress.txt shows circuit_breaker_status=TRIGGERED

**Error Message:**
```
❌ Circuit breaker already TRIGGERED

Implementation was stopped due to repeated failures.

Review diagnostic report:
  cat {project_folder}/autonomous_summary_report.md

Reset circuit breaker before resuming:
  /bmad-bmm-run-autonomous-implementation --mode=edit
  Select [C] Circuit Breaker
  Select [A] Reset All

Exiting with code 42 (circuit breaker)
```

**Exit Code:** 42

---

## Session Number Determination

### How to Determine Current Session

**From claude-progress.txt:**
```bash
SESSION_COUNT=$(grep '^session_count=' "$PROGRESS_FILE" | cut -d= -f2)
CURRENT_SESSION=$((SESSION_COUNT + 1))
```

**Display:**
```
═══════════════════════════════════════════════════════
  SESSION $CURRENT_SESSION: Implementation
  Resuming from Previous State
═══════════════════════════════════════════════════════
```

---

## Detection Edge Cases

### Edge Case 1: feature_list.json Empty File

**Detection:**
- File exists (not -f check passes)
- But file size = 0 bytes

**Result:** JSON validation fails → Error message (corrupted state)

---

### Edge Case 2: feature_list.json from Different Project

**Detection:**
- Valid JSON
- But metadata.project_name doesn't match current context

**Handling:**
- Not detectable automatically (no built-in check)
- User responsibility to ensure correct directory
- Could add validation check comparing project names

---

### Edge Case 3: Partial Initialization (Session 1 Interrupted)

**Scenario:**
- Session 1 started (Path A)
- feature_list.json created (step-03)
- But session interrupted before completion (step-06)

**Detection:**
- feature_list.json exists (Path B selected)
- But claude-progress.txt may not exist yet

**Handling:**
- Route to Path B (file exists)
- Path B handles missing progress file gracefully
- Implementation can continue

**Alternative:** Could add "initialization_complete" flag to metadata, but unnecessary complexity.

---

## Best Practices

### For Users

1. **Don't Manually Create feature_list.json**
   - Let Path A (Initializer) create it
   - Manual creation may skip important initialization

2. **Don't Delete Tracking Files Mid-Implementation**
   - Deleting feature_list.json restarts from scratch
   - Use EDIT mode to modify state instead

3. **Keep Backups**
   - Backup feature_list.json before manual edits
   - Workflow creates backups automatically during updates

### For Workflow Designers

1. **Detection Should Be Fast**
   - File existence check is O(1)
   - JSON validation is quick for small files
   - Don't add complex detection logic

2. **Fail Safe on Corruption**
   - Exit with clear error message
   - Don't try to auto-repair (data loss risk)
   - Provide recovery options

3. **Route Early**
   - Detect in step-01 (first CREATE step)
   - Don't delay routing decision
   - Clear separation between Path A and Path B

---

## Detection Flow Diagram

```
User runs: /bmad-bmm-run-autonomous-implementation

                    ↓
         step-01-init.md (CREATE mode entry)
                    ↓
         Does feature_list.json exist?
                    ↓
         ┌──────────┴──────────┐
         NO                    YES
         ↓                      ↓
    PATH A                 Is JSON valid?
    (Initializer)              ↓
         ↓              ┌───────┴───────┐
    step-02 →      YES (Path B)    NO (ERROR)
    step-03 →           ↓               ↓
    step-04 →      step-01b       Exit 10
    step-05 →           ↓          (corrupted)
    step-06      Circuit breaker
    (done)       already triggered?
                        ↓
                ┌───────┴───────┐
               NO              YES
                ↓               ↓
           PATH B          Exit 42
      (Coding Agent)     (circuit breaker)
                ↓
           step-07 →
           step-08 →
           ...
           (loop)
```

---

## Validation in VALIDATE Mode

**VALIDATE mode also uses session detection logic:**

1. Check if feature_list.json exists
2. If NO → Error (nothing to validate)
3. If YES → Proceed with validation (steps-v)

**Error Message (no feature_list.json):**
```
❌ ERROR: No implementation to validate

feature_list.json not found.

Run CREATE mode first to initialize implementation.

Exiting (nothing to validate)
```

---

## Testing Detection Logic

### Test Case 1: Clean Slate

**Setup:**
- Delete feature_list.json
- Delete claude-progress.txt

**Expected:**
- Route to Path A (Initializer)
- Session 1 created

### Test Case 2: Resume

**Setup:**
- feature_list.json exists (valid JSON)
- claude-progress.txt exists

**Expected:**
- Route to Path B (Coding Agent)
- Session N (N > 1)

### Test Case 3: Corrupted State

**Setup:**
- feature_list.json exists (invalid JSON)

**Expected:**
- Error message displayed
- Exit code 10
- No route selected

### Test Case 4: Circuit Breaker Triggered

**Setup:**
- feature_list.json valid
- claude-progress.txt has circuit_breaker_status=TRIGGERED

**Expected:**
- Path B selected
- step-01b detects trigger
- Exit code 42 immediately

---

**Version:** 1.0.0
**Created:** 2026-02-17
**Applies To:** run-autonomous-implementation workflow
