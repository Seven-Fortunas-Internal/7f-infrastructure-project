---
name: 'step-02-validate-implementation'
description: 'Validate actual implementation matches tracking state'
nextStepFile: './step-03-validate-circuit-breaker.md'
featureListFile: '{project_folder}/feature_list.json'
progressFile: '{project_folder}/claude-progress.txt'
---

# Step 02: Validate Implementation (VALIDATE Mode)

## STEP GOAL:
Validate that features marked "pass" in tracking actually exist and work, detect orphaned or missing implementations.

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: Implementation Validator (reality vs tracking checker)
- ✅ Collaborative dialogue: None (automated validation)
- ✅ You bring: Implementation checking logic
- ✅ User brings: Implementation to validate

### Step-Specific:
- 🎯 Focus: Verify tracking state matches reality
- 🚫 Forbidden: Making changes to fix issues
- 💬 Approach: Test each "pass" feature, report discrepancies

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Read-only validation (no modifications)
- 📖 Collect discrepancies for final report

---

## CONTEXT BOUNDARIES:
- Available: feature_list.json, project files, git history
- Focus: Implementation vs tracking validation
- Limits: Does not validate circuit breaker logic (that's step-03)
- Dependencies: Requires state validation from step-01

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Implementation Validation Banner

```
═══════════════════════════════════════════════════════
  VALIDATE IMPLEMENTATION
  Verifying Tracking Matches Reality
═══════════════════════════════════════════════════════
```

---

### 2. Initialize Validation Results

**Prepare result tracking:**

```bash
echo ""
echo "Initializing implementation validation..."

# Validation result arrays
IMPL_VALIDATION_PASSED=()
IMPL_VALIDATION_FAILED=()
IMPL_VALIDATION_WARNINGS=()

IMPL_TOTAL_CHECKS=0
IMPL_PASSED_CHECKS=0
IMPL_FAILED_CHECKS=0
IMPL_WARNING_COUNT=0

echo "✓ Implementation validation initialized"
echo ""
```

---

### 3. Load Feature Statistics

**Get features by status:**

```bash
FEATURE_LIST_FILE="{featureListFile}"

echo "Loading feature statistics..."

PASS_COUNT=$(jq -r '.features[] | select(.status == "pass") | .id' "$FEATURE_LIST_FILE" 2>/dev/null | wc -l)
IN_PROGRESS_COUNT=$(jq -r '.features[] | select(.status == "in_progress") | .id' "$FEATURE_LIST_FILE" 2>/dev/null | wc -l)
TOTAL_FEATURES=$(jq -r '.metadata.total_features' "$FEATURE_LIST_FILE" 2>/dev/null)

echo "✓ Feature statistics loaded"
echo "  Pass: $PASS_COUNT"
echo "  In Progress: $IN_PROGRESS_COUNT"
echo "  Total: $TOTAL_FEATURES"
echo ""
```

---

### 4. Validate Git Repository

**Ensure git repo exists and has commits:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 1: GIT REPOSITORY"
echo "─────────────────────────────────────────────────────"
echo ""

PROJECT_FOLDER="{project_folder}"
cd "$PROJECT_FOLDER" || exit 20

# Check git repo exists
IMPL_TOTAL_CHECKS=$((IMPL_TOTAL_CHECKS + 1))
if [[ -d ".git" ]]; then
    echo "✓ Git repository exists"
    IMPL_VALIDATION_PASSED+=("Git: Repository exists")
    IMPL_PASSED_CHECKS=$((IMPL_PASSED_CHECKS + 1))
else
    echo "❌ Git repository NOT FOUND"
    echo "   Expected .git directory in: $PROJECT_FOLDER"
    IMPL_VALIDATION_FAILED+=("Git: Repository missing")
    IMPL_FAILED_CHECKS=$((IMPL_FAILED_CHECKS + 1))
fi

# Check commits exist
IMPL_TOTAL_CHECKS=$((IMPL_TOTAL_CHECKS + 1))
COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")

if [[ $COMMIT_COUNT -gt 0 ]]; then
    echo "✓ Git has $COMMIT_COUNT commits"
    IMPL_VALIDATION_PASSED+=("Git: $COMMIT_COUNT commits present")
    IMPL_PASSED_CHECKS=$((IMPL_PASSED_CHECKS + 1))
else
    echo "⚠️  Git has no commits yet"
    IMPL_VALIDATION_WARNINGS+=("Git: No commits (implementation may not have started)")
    IMPL_WARNING_COUNT=$((IMPL_WARNING_COUNT + 1))
fi

echo ""
```

---

### 5. Validate Passed Features Have Commits

**Check if "pass" features have corresponding git commits:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 2: PASSED FEATURES HAVE COMMITS"
echo "─────────────────────────────────────────────────────"
echo ""

if [[ $PASS_COUNT -gt 0 ]]; then
    echo "Checking $PASS_COUNT passed features for git commits..."
    echo ""

    # Get list of passed feature IDs
    PASSED_FEATURE_IDS=($(jq -r '.features[] | select(.status == "pass") | .id' "$FEATURE_LIST_FILE"))

    for FEATURE_ID in "${PASSED_FEATURE_IDS[@]}"; do
        IMPL_TOTAL_CHECKS=$((IMPL_TOTAL_CHECKS + 1))

        # Search git log for feature ID
        COMMIT_FOUND=$(git log --all --oneline --grep="$FEATURE_ID" 2>/dev/null | head -1)

        if [[ -n "$COMMIT_FOUND" ]]; then
            IMPL_VALIDATION_PASSED+=("Feature commit: $FEATURE_ID has commit")
            IMPL_PASSED_CHECKS=$((IMPL_PASSED_CHECKS + 1))
        else
            echo "⚠️  Feature $FEATURE_ID marked 'pass' but no commit found"
            IMPL_VALIDATION_WARNINGS+=("Feature commit: $FEATURE_ID marked pass but no commit")
            IMPL_WARNING_COUNT=$((IMPL_WARNING_COUNT + 1))
        fi
    done

    if [[ $IMPL_FAILED_CHECKS -eq 0 ]]; then
        echo "✓ All passed features have commits (or warnings logged)"
    fi

else
    echo "⊘ No passed features to check"
fi

echo ""
```

---

### 6. Validate In-Progress Features

**Check for stuck "in_progress" features:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 3: IN-PROGRESS FEATURE STATUS"
echo "─────────────────────────────────────────────────────"
echo ""

if [[ $IN_PROGRESS_COUNT -gt 0 ]]; then
    echo "⚠️  Found $IN_PROGRESS_COUNT features with 'in_progress' status"
    echo ""

    # List in-progress features
    jq -r '.features[] | select(.status == "in_progress") |
        "  - \(.id): \(.name) (attempts: \(.attempts))"' \
        "$FEATURE_LIST_FILE"

    echo ""
    echo "In-progress features may indicate interrupted sessions."
    echo "These should be reset to 'pending' or 'fail' for retry."
    echo ""

    IMPL_VALIDATION_WARNINGS+=("In-progress: $IN_PROGRESS_COUNT features stuck")
    IMPL_WARNING_COUNT=$((IMPL_WARNING_COUNT + 1))

else
    IMPL_TOTAL_CHECKS=$((IMPL_TOTAL_CHECKS + 1))
    echo "✓ No features stuck 'in_progress'"
    IMPL_VALIDATION_PASSED+=("In-progress: No stuck features")
    IMPL_PASSED_CHECKS=$((IMPL_PASSED_CHECKS + 1))
fi

echo ""
```

---

### 7. Validate Verification Results

**Check "pass" features have verification_results:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 4: VERIFICATION RESULTS"
echo "─────────────────────────────────────────────────────"
echo ""

if [[ $PASS_COUNT -gt 0 ]]; then
    echo "Checking verification results for $PASS_COUNT passed features..."
    echo ""

    PASSED_FEATURE_IDS=($(jq -r '.features[] | select(.status == "pass") | .id' "$FEATURE_LIST_FILE"))
    MISSING_RESULTS=0

    for FEATURE_ID in "${PASSED_FEATURE_IDS[@]}"; do
        IMPL_TOTAL_CHECKS=$((IMPL_TOTAL_CHECKS + 1))

        # Check if verification_results exists
        HAS_RESULTS=$(jq -r --arg id "$FEATURE_ID" \
            '.features[] | select(.id == $id) | has("verification_results")' \
            "$FEATURE_LIST_FILE")

        if [[ "$HAS_RESULTS" == "true" ]]; then
            IMPL_PASSED_CHECKS=$((IMPL_PASSED_CHECKS + 1))
        else
            echo "⚠️  Feature $FEATURE_ID marked 'pass' but no verification_results"
            IMPL_VALIDATION_WARNINGS+=("Verification: $FEATURE_ID missing verification_results")
            IMPL_WARNING_COUNT=$((IMPL_WARNING_COUNT + 1))
            MISSING_RESULTS=$((MISSING_RESULTS + 1))
        fi
    done

    if [[ $MISSING_RESULTS -eq 0 ]]; then
        echo "✓ All passed features have verification_results"
        IMPL_VALIDATION_PASSED+=("Verification: All passed features have results")
    fi

else
    echo "⊘ No passed features to check"
fi

echo ""
```

---

### 8. Validate Attempts Consistency

**Check features with attempts > 0 have appropriate status:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 5: ATTEMPTS CONSISTENCY"
echo "─────────────────────────────────────────────────────"
echo ""

echo "Checking attempts consistency..."
echo ""

# Features with attempts > 0 should not be "pending" (unless reset manually)
INCONSISTENT=$(jq -r '.features[] | select(.status == "pending" and .attempts > 0) | .id' "$FEATURE_LIST_FILE" | wc -l)

IMPL_TOTAL_CHECKS=$((IMPL_TOTAL_CHECKS + 1))

if [[ $INCONSISTENT -gt 0 ]]; then
    echo "⚠️  Found $INCONSISTENT features with status='pending' but attempts > 0"
    echo ""

    jq -r '.features[] | select(.status == "pending" and .attempts > 0) |
        "  - \(.id): \(.name) (attempts: \(.attempts))"' \
        "$FEATURE_LIST_FILE"

    echo ""
    echo "This may indicate manual edits or reset operations."
    echo ""

    IMPL_VALIDATION_WARNINGS+=("Attempts: $INCONSISTENT pending features have attempts > 0")
    IMPL_WARNING_COUNT=$((IMPL_WARNING_COUNT + 1))

else
    echo "✓ All attempts counters consistent with status"
    IMPL_VALIDATION_PASSED+=("Attempts: Counters consistent")
    IMPL_PASSED_CHECKS=$((IMPL_PASSED_CHECKS + 1))
fi

echo ""
```

---

### 9. Validate Blocked Reasons

**Check blocked features have blocked_reason:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 6: BLOCKED REASONS"
echo "─────────────────────────────────────────────────────"
echo ""

BLOCKED_COUNT=$(jq -r '.features[] | select(.status == "blocked") | .id' "$FEATURE_LIST_FILE" | wc -l)

if [[ $BLOCKED_COUNT -gt 0 ]]; then
    echo "Checking $BLOCKED_COUNT blocked features for blocked_reason..."
    echo ""

    BLOCKED_IDS=($(jq -r '.features[] | select(.status == "blocked") | .id' "$FEATURE_LIST_FILE"))
    MISSING_REASONS=0

    for FEATURE_ID in "${BLOCKED_IDS[@]}"; do
        IMPL_TOTAL_CHECKS=$((IMPL_TOTAL_CHECKS + 1))

        # Check if blocked_reason exists
        HAS_REASON=$(jq -r --arg id "$FEATURE_ID" \
            '.features[] | select(.id == $id) | has("blocked_reason")' \
            "$FEATURE_LIST_FILE")

        if [[ "$HAS_REASON" == "true" ]]; then
            IMPL_PASSED_CHECKS=$((IMPL_PASSED_CHECKS + 1))
        else
            echo "⚠️  Feature $FEATURE_ID marked 'blocked' but no blocked_reason"
            IMPL_VALIDATION_WARNINGS+=("Blocked: $FEATURE_ID missing blocked_reason")
            IMPL_WARNING_COUNT=$((IMPL_WARNING_COUNT + 1))
            MISSING_REASONS=$((MISSING_REASONS + 1))
        fi
    done

    if [[ $MISSING_REASONS -eq 0 ]]; then
        echo "✓ All blocked features have blocked_reason"
        IMPL_VALIDATION_PASSED+=("Blocked: All blocked features have reason")
    fi

else
    IMPL_TOTAL_CHECKS=$((IMPL_TOTAL_CHECKS + 1))
    echo "✓ No blocked features to check"
    IMPL_VALIDATION_PASSED+=("Blocked: No blocked features")
    IMPL_PASSED_CHECKS=$((IMPL_PASSED_CHECKS + 1))
fi

echo ""
```

---

### 10. Display Implementation Validation Summary

```
─────────────────────────────────────────────────────
  IMPLEMENTATION VALIDATION SUMMARY
─────────────────────────────────────────────────────

Total Checks: $IMPL_TOTAL_CHECKS
  ✓ Passed:  $IMPL_PASSED_CHECKS
  ❌ Failed:  $IMPL_FAILED_CHECKS
  ⚠️  Warnings: $IMPL_WARNING_COUNT

Overall Result: $(if [[ $IMPL_FAILED_CHECKS -eq 0 ]]; then echo "✓ PASS"; else echo "❌ FAIL"; fi)

$(if [[ $IMPL_FAILED_CHECKS -gt 0 ]]; then
    echo ""
    echo "Critical Issues Found:"
    for failure in "${IMPL_VALIDATION_FAILED[@]}"; do
        echo "  - $failure"
    done
fi)

$(if [[ $IMPL_WARNING_COUNT -gt 0 ]]; then
    echo ""
    echo "Warnings:"
    for warning in "${IMPL_VALIDATION_WARNINGS[@]}"; do
        echo "  - $warning"
    done
fi)

Next: Validate circuit breaker logic
```

---

### 11. Store Results for Final Report

**Export validation data for step-04:**

```bash
# Export for final report
export IMPL_VALIDATION_PASSED=$IMPL_PASSED_CHECKS
export IMPL_VALIDATION_FAILED=$IMPL_FAILED_CHECKS
export IMPL_VALIDATION_WARNINGS=$IMPL_WARNING_COUNT
export IMPL_VALIDATION_TOTAL=$IMPL_TOTAL_CHECKS
export IMPL_VALIDATION_RESULT=$(if [[ $IMPL_FAILED_CHECKS -eq 0 ]]; then echo "PASS"; else echo "FAIL"; fi)

echo ""
echo "✓ Results stored for final report"
echo ""
```

---

### 12. Proceed to Next Step

**Menu Handling Logic:**
- This step uses **Auto-proceed** (no menu)
- Implementation validation complete, proceed to circuit breaker validation

**Execution:**

```
Proceeding to circuit breaker validation...

→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- Implementation validation initialized
- Git repository validated (exists, has commits)
- Passed features checked for commits
- In-progress features detected (warnings logged)
- Verification results validated (passed features have results)
- Attempts consistency checked
- Blocked reasons validated (blocked features have reasons)
- Implementation validation summary displayed
- Results exported for final report
- Ready for step-03 (circuit breaker validation)

### ❌ FAILURE:
- (None - validation always completes)
- Failures and warnings recorded in validation results for reporting

**Master Rule:** Implementation validation must verify tracking state matches actual implementation reality.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
