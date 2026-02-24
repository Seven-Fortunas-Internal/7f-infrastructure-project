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

**Execution Rules:** See {workflow_path}/data/universal-step-rules.md

**Role:** Implementation Validator (reality vs tracking checker)
**Protocol:** Read-only validation, collect discrepancies for final report
**Context:** feature_list.json, project files, git history (read-only)
**Dependencies:** State validation from step-01

---

## MANDATORY SEQUENCE

### 1. Display Banner & Initialize

```
═══════════════════════════════════════════════════════
  VALIDATE IMPLEMENTATION
  Verifying Tracking Matches Reality
═══════════════════════════════════════════════════════
```

```bash
echo "Initializing implementation validation..."
IMPL_VALIDATION_PASSED=(); IMPL_VALIDATION_FAILED=(); IMPL_VALIDATION_WARNINGS=()
IMPL_TOTAL_CHECKS=0; IMPL_PASSED_CHECKS=0; IMPL_FAILED_CHECKS=0; IMPL_WARNING_COUNT=0
echo "✓ Implementation validation initialized"
```

---

### 2. Load Feature Statistics

```bash
FEATURE_LIST_FILE="{featureListFile}"
PASS_COUNT=$(jq -r '.features[] | select(.status == "pass") | .id' "$FEATURE_LIST_FILE" 2>/dev/null | wc -l)
IN_PROGRESS_COUNT=$(jq -r '.features[] | select(.status == "in_progress") | .id' "$FEATURE_LIST_FILE" 2>/dev/null | wc -l)
TOTAL_FEATURES=$(jq -r '.metadata.total_features' "$FEATURE_LIST_FILE" 2>/dev/null)
echo "✓ Feature stats: Pass=$PASS_COUNT | InProgress=$IN_PROGRESS_COUNT | Total=$TOTAL_FEATURES"
```

---

### 3. Validate Git Repository

```bash
echo "CHECK 1: GIT REPOSITORY"
PROJECT_FOLDER="{project_folder}"; cd "$PROJECT_FOLDER" || exit 20
IMPL_TOTAL_CHECKS=$((IMPL_TOTAL_CHECKS + 2))

if [[ -d ".git" ]]; then
    echo "✓ Git repository exists"; IMPL_VALIDATION_PASSED+=("Git: Repository exists"); IMPL_PASSED_CHECKS=$((IMPL_PASSED_CHECKS + 1))
else
    echo "❌ Git repository NOT FOUND"; IMPL_VALIDATION_FAILED+=("Git: Repository missing"); IMPL_FAILED_CHECKS=$((IMPL_FAILED_CHECKS + 1))
fi

COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
if [[ $COMMIT_COUNT -gt 0 ]]; then
    echo "✓ Git has $COMMIT_COUNT commits"; IMPL_VALIDATION_PASSED+=("Git: $COMMIT_COUNT commits"); IMPL_PASSED_CHECKS=$((IMPL_PASSED_CHECKS + 1))
else
    echo "⚠️  No commits yet"; IMPL_VALIDATION_WARNINGS+=("Git: No commits"); IMPL_WARNING_COUNT=$((IMPL_WARNING_COUNT + 1))
fi
```

---

### 4. Validate Passed Features Have Commits

```bash
echo "CHECK 2: PASSED FEATURES HAVE COMMITS"
if [[ $PASS_COUNT -gt 0 ]]; then
    PASSED_FEATURE_IDS=($(jq -r '.features[] | select(.status == "pass") | .id' "$FEATURE_LIST_FILE"))
    for FEATURE_ID in "${PASSED_FEATURE_IDS[@]}"; do
        IMPL_TOTAL_CHECKS=$((IMPL_TOTAL_CHECKS + 1)); COMMIT_FOUND=$(git log --all --oneline --grep="$FEATURE_ID" 2>/dev/null | head -1)
        if [[ -n "$COMMIT_FOUND" ]]; then IMPL_PASSED_CHECKS=$((IMPL_PASSED_CHECKS + 1))
        else echo "⚠️  $FEATURE_ID no commit"; IMPL_VALIDATION_WARNINGS+=("Feature: $FEATURE_ID no commit"); IMPL_WARNING_COUNT=$((IMPL_WARNING_COUNT + 1)); fi
    done
    echo "✓ Checked $PASS_COUNT passed features"
else echo "⊘ No passed features"; fi
```

---

### 5. Validate In-Progress Features

```bash
echo "CHECK 3: IN-PROGRESS STATUS"; IMPL_TOTAL_CHECKS=$((IMPL_TOTAL_CHECKS + 1))
if [[ $IN_PROGRESS_COUNT -gt 0 ]]; then
    echo "⚠️  $IN_PROGRESS_COUNT in_progress (may need reset)"
    jq -r '.features[] | select(.status == "in_progress") | "  - \(.id): \(.name) (attempts: \(.attempts))"' "$FEATURE_LIST_FILE"
    IMPL_VALIDATION_WARNINGS+=("In-progress: $IN_PROGRESS_COUNT stuck"); IMPL_WARNING_COUNT=$((IMPL_WARNING_COUNT + 1))
else echo "✓ No stuck in_progress"; IMPL_VALIDATION_PASSED+=("In-progress: None stuck"); IMPL_PASSED_CHECKS=$((IMPL_PASSED_CHECKS + 1)); fi
```

---

### 6. Validate Verification Results

```bash
echo "CHECK 4: VERIFICATION RESULTS"
if [[ $PASS_COUNT -gt 0 ]]; then
    PASSED_FEATURE_IDS=($(jq -r '.features[] | select(.status == "pass") | .id' "$FEATURE_LIST_FILE")); MISSING_RESULTS=0
    for FEATURE_ID in "${PASSED_FEATURE_IDS[@]}"; do
        IMPL_TOTAL_CHECKS=$((IMPL_TOTAL_CHECKS + 1))
        HAS_RESULTS=$(jq -r --arg id "$FEATURE_ID" '.features[] | select(.id == $id) | has("verification_results")' "$FEATURE_LIST_FILE")
        if [[ "$HAS_RESULTS" == "true" ]]; then IMPL_PASSED_CHECKS=$((IMPL_PASSED_CHECKS + 1))
        else echo "⚠️  $FEATURE_ID no verification_results"; IMPL_VALIDATION_WARNINGS+=("Verification: $FEATURE_ID missing"); IMPL_WARNING_COUNT=$((IMPL_WARNING_COUNT + 1)); MISSING_RESULTS=$((MISSING_RESULTS + 1)); fi
    done
    [[ $MISSING_RESULTS -eq 0 ]] && echo "✓ All have verification_results" && IMPL_VALIDATION_PASSED+=("Verification: All have results")
else echo "⊘ No passed features"; fi
```

---

### 7. Validate Attempts Consistency

```bash
echo "CHECK 5: ATTEMPTS CONSISTENCY"
INCONSISTENT=$(jq -r '.features[] | select(.status == "pending" and .attempts > 0) | .id' "$FEATURE_LIST_FILE" | wc -l); IMPL_TOTAL_CHECKS=$((IMPL_TOTAL_CHECKS + 1))
if [[ $INCONSISTENT -gt 0 ]]; then
    echo "⚠️  $INCONSISTENT pending with attempts > 0 (manual edits?)"
    jq -r '.features[] | select(.status == "pending" and .attempts > 0) | "  - \(.id): \(.name) (attempts: \(.attempts))"' "$FEATURE_LIST_FILE"
    IMPL_VALIDATION_WARNINGS+=("Attempts: $INCONSISTENT pending have attempts"); IMPL_WARNING_COUNT=$((IMPL_WARNING_COUNT + 1))
else echo "✓ Attempts consistent"; IMPL_VALIDATION_PASSED+=("Attempts: Consistent"); IMPL_PASSED_CHECKS=$((IMPL_PASSED_CHECKS + 1)); fi
```

---

### 8. Validate Blocked Reasons

```bash
echo "CHECK 6: BLOCKED REASONS"
BLOCKED_COUNT=$(jq -r '.features[] | select(.status == "blocked") | .id' "$FEATURE_LIST_FILE" | wc -l)
if [[ $BLOCKED_COUNT -gt 0 ]]; then
    BLOCKED_IDS=($(jq -r '.features[] | select(.status == "blocked") | .id' "$FEATURE_LIST_FILE")); MISSING_REASONS=0
    for FEATURE_ID in "${BLOCKED_IDS[@]}"; do
        IMPL_TOTAL_CHECKS=$((IMPL_TOTAL_CHECKS + 1))
        HAS_REASON=$(jq -r --arg id "$FEATURE_ID" '.features[] | select(.id == $id) | has("blocked_reason")' "$FEATURE_LIST_FILE")
        if [[ "$HAS_REASON" == "true" ]]; then IMPL_PASSED_CHECKS=$((IMPL_PASSED_CHECKS + 1))
        else echo "⚠️  $FEATURE_ID no blocked_reason"; IMPL_VALIDATION_WARNINGS+=("Blocked: $FEATURE_ID missing reason"); IMPL_WARNING_COUNT=$((IMPL_WARNING_COUNT + 1)); MISSING_REASONS=$((MISSING_REASONS + 1)); fi
    done
    [[ $MISSING_REASONS -eq 0 ]] && echo "✓ All have blocked_reason" && IMPL_VALIDATION_PASSED+=("Blocked: All have reason")
else IMPL_TOTAL_CHECKS=$((IMPL_TOTAL_CHECKS + 1)); echo "✓ No blocked features"; IMPL_VALIDATION_PASSED+=("Blocked: None"); IMPL_PASSED_CHECKS=$((IMPL_PASSED_CHECKS + 1)); fi
```

---

### 9. Display Summary & Store Results

```bash
echo "─────────────────────────────────────────────────────"
echo "  IMPLEMENTATION VALIDATION SUMMARY"
echo "─────────────────────────────────────────────────────"
echo "Total: $IMPL_TOTAL_CHECKS | Passed: $IMPL_PASSED_CHECKS | Failed: $IMPL_FAILED_CHECKS | Warnings: $IMPL_WARNING_COUNT"
echo "Result: $(if [[ $IMPL_FAILED_CHECKS -eq 0 ]]; then echo "✓ PASS"; else echo "❌ FAIL"; fi)"
[[ $IMPL_FAILED_CHECKS -gt 0 ]] && echo "Critical Issues:" && for f in "${IMPL_VALIDATION_FAILED[@]}"; do echo "  - $f"; done
[[ $IMPL_WARNING_COUNT -gt 0 ]] && echo "Warnings:" && for w in "${IMPL_VALIDATION_WARNINGS[@]}"; do echo "  - $w"; done
echo "Next: Validate circuit breaker logic"

export IMPL_VALIDATION_PASSED=$IMPL_PASSED_CHECKS; export IMPL_VALIDATION_FAILED=$IMPL_FAILED_CHECKS
export IMPL_VALIDATION_WARNINGS=$IMPL_WARNING_COUNT; export IMPL_VALIDATION_TOTAL=$IMPL_TOTAL_CHECKS
export IMPL_VALIDATION_RESULT=$(if [[ $IMPL_FAILED_CHECKS -eq 0 ]]; then echo "PASS"; else echo "FAIL"; fi)
echo "✓ Results stored"
```

---

### 10. Proceed to Next Step

**Auto-proceed** - No menu.

```
→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

See {workflow_path}/data/universal-step-rules.md for standard outcomes.

**Master Rule:** Implementation validation must verify tracking state matches actual implementation reality.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
