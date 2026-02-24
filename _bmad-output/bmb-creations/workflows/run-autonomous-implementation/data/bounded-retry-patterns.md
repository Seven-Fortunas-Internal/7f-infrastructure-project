# Bounded Retry Patterns

**Purpose:** Define progressive degradation retry strategy for feature implementation failures.

---

## Overview

**Bounded Retry:** Each feature gets exactly **3 attempts** before being marked "blocked."

**Progressive Degradation:** Each attempt uses a simpler approach than the previous.

**Rationale:** If a feature fails repeatedly with comprehensive approaches, simplification may help. After 3 attempts, human intervention is more effective than continued automation.

---

## Retry Progression

### Attempt 1: STANDARD Implementation
**When:** First attempt, feature status = "pending", attempts = 0

**Approach:** Comprehensive, full-featured implementation
- Complete error handling
- All edge cases considered
- Defensive programming
- Comprehensive logging
- Full validation

**Example (GitHub Repo Creation):**
```bash
# Full implementation with all options
gh repo create "$ORG/$REPO_NAME" \
    --private \
    --description "$DESCRIPTION" \
    --gitignore "$GITIGNORE_TEMPLATE" \
    --license "$LICENSE" \
    --add-readme \
    --enable-issues \
    --enable-wiki

# Verify repo created
if gh repo view "$ORG/$REPO_NAME" >/dev/null 2>&1; then
    echo "✓ Repository created successfully"
else
    echo "❌ Repository creation failed"
    exit 1
fi
```

**Success:** Mark status="pass", done
**Failure:** Mark status="fail", attempts=1, retry in next session

---

### Attempt 2: SIMPLIFIED Implementation
**When:** Second attempt, feature status = "fail", attempts = 1

**Approach:** Streamlined, core functionality only
- Minimal error handling (essential only)
- Focus on primary use case
- Remove optional features
- Simplified validation

**Example (GitHub Repo Creation):**
```bash
# Simplified implementation - core options only
gh repo create "$ORG/$REPO_NAME" \
    --private \
    --description "$DESCRIPTION"

# Basic verification only
if gh repo view "$ORG/$REPO_NAME" >/dev/null 2>&1; then
    echo "✓ Repository created"
else
    exit 1
fi
```

**Success:** Mark status="pass", done
**Failure:** Mark status="fail", attempts=2, retry in next session

---

### Attempt 3: MINIMAL Implementation
**When:** Third attempt, feature status = "fail", attempts = 2

**Approach:** Bare minimum to satisfy verification criteria
- No error handling (fail fast)
- Absolute simplest approach
- Only what's required to pass verification
- Last chance before blocking

**Example (GitHub Repo Creation):**
```bash
# Minimal implementation - bare minimum
gh repo create "$ORG/$REPO_NAME" --private

# Minimal check
gh repo view "$ORG/$REPO_NAME" >/dev/null 2>&1
```

**Success:** Mark status="pass", done
**Failure:** Mark status="blocked", attempts=3, document blocked_reason

---

### After 3 Attempts: BLOCKED
**When:** Third attempt fails, feature status = "fail", attempts = 3

**Actions:**
1. Mark status="blocked"
2. Set blocked_reason with clear explanation
3. Log to build log
4. Increment circuit breaker consecutive_failures
5. Move to next feature

**Example blocked_reason:**
```
"Failed 3 implementation attempts. Last error: GitHub API authentication failed (401 Unauthorized). Requires manual credential configuration."
```

**Recovery:**
- User fixes root cause (e.g., configure credentials)
- Use EDIT mode to reset feature:
  - Change status back to "pending"
  - Reset attempts to 0
  - Clear blocked_reason
- Resume workflow to retry

---

## Implementation Strategy by Attempt

### Attempt 1: STANDARD

**Characteristics:**
- ✅ Comprehensive error handling
- ✅ Input validation
- ✅ Detailed logging
- ✅ Edge case handling
- ✅ Graceful degradation
- ✅ Cleanup on failure

**Code Patterns:**
```bash
# Validate inputs
if [[ -z "$REQUIRED_VAR" ]]; then
    echo "❌ ERROR: REQUIRED_VAR not set"
    exit 1
fi

# Execute with error handling
if ! command_here; then
    echo "❌ Command failed, attempting cleanup"
    cleanup_function
    exit 1
fi

# Verify result
if ! verification_check; then
    echo "❌ Verification failed"
    exit 1
fi

echo "✓ Feature implemented successfully"
```

---

### Attempt 2: SIMPLIFIED

**Characteristics:**
- ⊘ Minimal error handling (essentials only)
- ⊘ Basic input validation
- ⊘ Reduced logging
- ❌ No edge case handling
- ❌ No graceful degradation
- ⊘ Basic cleanup

**Code Patterns:**
```bash
# Basic validation
[[ -n "$REQUIRED_VAR" ]] || exit 1

# Execute with simple error check
command_here || exit 1

# Basic verification
verification_check || exit 1

echo "✓ Done"
```

---

### Attempt 3: MINIMAL

**Characteristics:**
- ❌ No error handling (fail fast)
- ❌ No input validation
- ❌ No logging
- ❌ No edge cases
- ❌ No cleanup
- ⊘ Verification only

**Code Patterns:**
```bash
# Minimal implementation
command_here
verification_check
```

**Philosophy:** "Let it fail loudly and immediately if anything wrong."

---

## Retry Decision Logic

### When to Retry (Next Session)

**Conditions:**
- status = "fail"
- attempts < 3

**Action:**
- Feature eligible for selection in step-08
- Will be retried with next approach (SIMPLIFIED or MINIMAL)

### When to Block (No More Retries)

**Conditions:**
- status = "fail"
- attempts = 3 (after third failure)

**Action:**
- Change status to "blocked"
- Set blocked_reason
- Feature NOT eligible for selection
- Requires manual intervention via EDIT mode

---

## Failure Reason Tracking

### implementation_notes Field

After each failure, update feature's `implementation_notes`:

**Format:**
```
"Attempt N failed: <primary error message>"
```

**Examples:**
- `"Attempt 1 failed: GitHub API returned 404 - repository already exists"`
- `"Attempt 2 failed: Network timeout connecting to API"`
- `"Attempt 3 failed: Permission denied - insufficient credentials"`

**Purpose:**
- Help diagnose issues
- Identify patterns across retries
- Inform blocked_reason after 3rd failure

---

## Verification Criteria Approach by Attempt

### Attempt 1: Test All Criteria

**Functional:** Comprehensive test
**Technical:** Full validation
**Integration:** Complete integration check

**Example:**
```bash
# Functional: Does it work end-to-end?
test_end_to_end_functionality

# Technical: Is code quality good?
run_linters
check_syntax
validate_standards

# Integration: Does it integrate well?
test_api_connectivity
check_cross_feature_references
verify_permissions
```

---

### Attempt 2: Focus on Critical Criteria

**Functional:** Basic test (core functionality only)
**Technical:** Essential validation (syntax, required fields)
**Integration:** Primary integrations only

**Example:**
```bash
# Functional: Basic check
test_core_functionality

# Technical: Syntax only
check_syntax

# Integration: Main integration
test_primary_api_connection
```

---

### Attempt 3: Minimum to Pass Verification

**Functional:** Does it technically work?
**Technical:** Is it syntactically valid?
**Integration:** Can it be accessed?

**Example:**
```bash
# Functional: Exists and responds
curl -f "$ENDPOINT" >/dev/null 2>&1

# Technical: Valid JSON
jq empty config.json

# Integration: Reachable
ping -c 1 "$SERVICE" >/dev/null 2>&1
```

---

## Special Cases

### External Dependency Failures

**Symptoms:**
- Same error across all 3 attempts
- Error messages indicate external issue (API auth, network, permissions)

**Actions:**
1. Mark blocked after attempt 3
2. blocked_reason should clearly identify external dependency
3. Circuit breaker may trigger if multiple features fail for same reason

**Example blocked_reason:**
```
"GitHub API authentication failed (401). Requires GH_TOKEN environment variable with repo scope."
```

**Resolution:**
- User sets up external dependency
- Use EDIT mode to reset feature
- Retry succeeds on next run

---

### Implementation Logic Errors

**Symptoms:**
- Different errors on each attempt
- Errors suggest code bugs or logic flaws

**Actions:**
1. Progressive degradation may help (simpler = fewer bugs)
2. If minimal approach still fails, mark blocked
3. blocked_reason should describe implementation challenge

**Example blocked_reason:**
```
"Complex API integration failed across 3 attempts with different errors. May require custom implementation or alternative approach."
```

**Resolution:**
- User implements manually or provides guidance
- Use EDIT mode to mark as "pass" (if manual implementation)
- Or reset to retry with updated guidance

---

## Attempt Selection in step-09

### Determining Current Attempt Number

**From feature_list.json:**
```bash
FEATURE_ATTEMPTS=$(jq -r --arg id "$SELECTED_FEATURE_ID" \
    '.features[] | select(.id == $id) | .attempts' \
    "$FEATURE_LIST_FILE")
```

**Attempt will be:** `FEATURE_ATTEMPTS + 1`

### Approach Selection Logic

```bash
if [[ $FEATURE_ATTEMPTS -eq 0 ]]; then
    APPROACH="STANDARD"
elif [[ $FEATURE_ATTEMPTS -eq 1 ]]; then
    APPROACH="SIMPLIFIED"
elif [[ $FEATURE_ATTEMPTS -eq 2 ]]; then
    APPROACH="MINIMAL"
else
    # Should not reach here (blocked at attempts=3)
    APPROACH="BLOCKED"
fi
```

### Communicating Approach to Implementation

**Display to user (or agent) before implementation:**
```
─────────────────────────────────────────────────────
  IMPLEMENTATION APPROACH: $APPROACH
─────────────────────────────────────────────────────

$(case "$APPROACH" in
    STANDARD)
        echo "First attempt - Use comprehensive implementation with full error handling"
        ;;
    SIMPLIFIED)
        echo "Second attempt - Use simplified approach, focus on core functionality"
        ;;
    MINIMAL)
        echo "Final attempt - Use minimal implementation to satisfy verification criteria"
        ;;
esac)
```

---

## Retry Statistics

### Tracking Retry Metrics

**In feature_list.json:**
- `attempts`: Number of implementation attempts (0-3)
- `status`: Current status (pending/in_progress/pass/fail/blocked)
- `implementation_notes`: Error messages from failed attempts

**Useful Metrics:**
- Features passed on first attempt (attempts=1, status=pass)
- Features requiring retry (attempts>1, status=pass)
- Features blocked (status=blocked, attempts=3)
- Retry success rate by attempt number

---

## Best Practices

### For Implementation Agents

1. **Attempt 1: Be Thorough**
   - Don't cut corners
   - Implement proper error handling
   - Think through edge cases

2. **Attempt 2: Be Pragmatic**
   - Focus on what's essential
   - Remove nice-to-haves
   - Simplify complexity

3. **Attempt 3: Be Desperate**
   - Absolute minimum
   - Just make it pass verification
   - Fail fast if not working

### For Users

1. **Review Blocked Features**
   - Check blocked_reason for patterns
   - Fix external dependencies
   - Provide implementation guidance if needed

2. **Don't Overuse EDIT Mode**
   - Let retry logic work
   - Manual intervention after 3 attempts is appropriate
   - Don't keep resetting attempts indefinitely

3. **Monitor Retry Patterns**
   - High retry rate → features too complex or app_spec unclear
   - Low retry rate → implementation agent effective
   - Blocked features → external dependencies or limitations

---

## Examples by Feature Type

### GitHub Repository Creation

**Attempt 1:** Full options (gitignore, license, README, issues, wiki)
**Attempt 2:** Basic options (private, description only)
**Attempt 3:** Minimal (just repo name, private flag)

### API Configuration

**Attempt 1:** Complete validation, retry logic, timeout handling
**Attempt 2:** Basic validation, simple retry, default timeout
**Attempt 3:** No validation, no retry, immediate execution

### File Creation

**Attempt 1:** Template-based, validation, permissions check, error handling
**Attempt 2:** Basic content, syntax check only
**Attempt 3:** Empty file or minimal content

---

**Version:** 1.0.0
**Created:** 2026-02-17
**Applies To:** run-autonomous-implementation workflow
