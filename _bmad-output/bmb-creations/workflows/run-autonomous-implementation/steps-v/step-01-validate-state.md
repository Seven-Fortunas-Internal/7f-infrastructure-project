---
name: 'step-01-validate-state'
description: 'Validate tracking file integrity and consistency'
nextStepFile: './step-02-validate-implementation.md'
featureListFile: '{project_folder}/feature_list.json'
progressFile: '{project_folder}/claude-progress.txt'
buildLogFile: '{project_folder}/autonomous_build_log.md'
---

# Step 01: Validate State (VALIDATE Mode)

## STEP GOAL:
Validate tracking file integrity, JSON syntax, metadata consistency, and file existence.

**Execution Rules:** See {workflow_path}/data/universal-step-rules.md

---

## Role & Context

**Role:** State Validator (integrity checker)
**Focus:** Tracking file integrity and consistency validation
**Approach:** Systematic checks with clear pass/fail results
**Dependencies:** Requires tracking files exist

---

## MANDATORY SEQUENCE

### 1. Display Banner & Initialize

```
═══════════════════════════════════════════════════════
  VALIDATE MODE - State Integrity Check
═══════════════════════════════════════════════════════
```

```bash
VALIDATION_PASSED=(); VALIDATION_FAILED=(); VALIDATION_WARNINGS=()
TOTAL_CHECKS=0; PASSED_CHECKS=0; FAILED_CHECKS=0; WARNING_COUNT=0
FEATURE_LIST_FILE="{featureListFile}"; PROGRESS_FILE="{progressFile}"; BUILD_LOG_FILE="{buildLogFile}"
echo "✓ Validation initialized"
```

---

### 2. Validate File Existence & JSON Syntax

```bash
echo "CHECK 1-2: FILE EXISTENCE & JSON SYNTAX"
for file in "$FEATURE_LIST_FILE|feature_list.json|critical" "$PROGRESS_FILE|claude-progress.txt|critical" "$BUILD_LOG_FILE|autonomous_build_log.md|optional"; do
    IFS='|' read -r path name type <<< "$file"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if [[ -f "$path" ]]; then
        echo "✓ $name exists"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        [[ "$name" == "feature_list.json" ]] && { TOTAL_CHECKS=$((TOTAL_CHECKS + 1)); jq empty "$path" 2>/dev/null && { echo "✓ Valid JSON"; PASSED_CHECKS=$((PASSED_CHECKS + 1)); } || { echo "❌ Invalid JSON"; VALIDATION_FAILED+=("JSON syntax corrupted"); FAILED_CHECKS=$((FAILED_CHECKS + 1)); }; }
    else
        [[ "$type" == "critical" ]] && { echo "❌ $name missing"; VALIDATION_FAILED+=("$name missing"); FAILED_CHECKS=$((FAILED_CHECKS + 1)); } || { echo "⚠️  $name missing (optional)"; WARNING_COUNT=$((WARNING_COUNT + 1)); }
    fi
done
```

---

### 3. Validate Required Fields & Feature Structure

```bash
echo "CHECK 3-4: REQUIRED FIELDS & STRUCTURE"
if [[ -f "$FEATURE_LIST_FILE" ]] && jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then
    for check in "metadata:metadata section" "features|array:features array" "metadata.project_name:project_name" "metadata.total_features:total_features" "metadata.generated_date:generated_date"; do
        IFS=':' read -r path desc <<< "$check"
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        jq -e ".$path" "$FEATURE_LIST_FILE" >/dev/null 2>&1 && PASSED_CHECKS=$((PASSED_CHECKS + 1)) || { echo "❌ $desc missing"; VALIDATION_FAILED+=("$desc missing"); FAILED_CHECKS=$((FAILED_CHECKS + 1)); }
    done
    echo "✓ Metadata structure validated"

    FEATURE_COUNT=$(jq -r '.features|length' "$FEATURE_LIST_FILE")
    echo "Validating $FEATURE_COUNT features..."
    for field in id name status attempts category verification_criteria; do
        for i in $(seq 0 $((FEATURE_COUNT - 1))); do
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
            jq -e ".features[$i].$field" "$FEATURE_LIST_FILE" >/dev/null 2>&1 && PASSED_CHECKS=$((PASSED_CHECKS + 1)) || { FEATURE_ID=$(jq -r ".features[$i].id" "$FEATURE_LIST_FILE"); echo "❌ $FEATURE_ID.$field missing"; VALIDATION_FAILED+=("$FEATURE_ID.$field"); FAILED_CHECKS=$((FAILED_CHECKS + 1)); }
        done
    done
    echo "✓ Feature structure validated"
fi
```

---

### 4. Validate Status Values & Metadata Consistency

```bash
echo "CHECK 5-6: STATUS VALUES & METADATA"
if [[ -f "$FEATURE_LIST_FILE" ]] && jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then
    VALID_STATUSES="pending in_progress pass fail blocked"
    INVALID_COUNT=0
    while IFS='|' read -r id status; do
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        [[ " $VALID_STATUSES " =~ " $status " ]] && PASSED_CHECKS=$((PASSED_CHECKS + 1)) || { echo "❌ $id: invalid status '$status'"; VALIDATION_FAILED+=("$id invalid status"); FAILED_CHECKS=$((FAILED_CHECKS + 1)); INVALID_COUNT=$((INVALID_COUNT + 1)); }
    done < <(jq -r '.features[]|"\(.id)|\(.status)"' "$FEATURE_LIST_FILE")
    [[ $INVALID_COUNT -eq 0 ]] && echo "✓ All statuses valid"

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    DECLARED=$(jq -r '.metadata.total_features' "$FEATURE_LIST_FILE")
    ACTUAL=$(jq -r '.features|length' "$FEATURE_LIST_FILE")
    [[ $DECLARED -eq $ACTUAL ]] && { echo "✓ total_features consistent"; PASSED_CHECKS=$((PASSED_CHECKS + 1)); } || { echo "❌ total_features mismatch: declared=$DECLARED actual=$ACTUAL"; VALIDATION_FAILED+=("total_features mismatch"); FAILED_CHECKS=$((FAILED_CHECKS + 1)); }
fi
```

---

### 5. Validate Progress File Format

```bash
echo "CHECK 7: PROGRESS FILE FORMAT"
if [[ -f "$PROGRESS_FILE" ]]; then
    for field in session_count consecutive_failures circuit_breaker_threshold circuit_breaker_status; do
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        grep -q "^${field}=" "$PROGRESS_FILE" && PASSED_CHECKS=$((PASSED_CHECKS + 1)) || { echo "❌ $field missing"; VALIDATION_FAILED+=("$field"); FAILED_CHECKS=$((FAILED_CHECKS + 1)); }
    done
    echo "✓ Progress metadata validated"
fi
```

---

### 6. Display Summary & Store Results

```
─────────────────────────────────────────────────────
  STATE VALIDATION SUMMARY
─────────────────────────────────────────────────────

Total Checks: $TOTAL_CHECKS
  ✓ Passed:  $PASSED_CHECKS
  ❌ Failed:  $FAILED_CHECKS
  ⚠️  Warnings: $WARNING_COUNT

Overall: $(if [[ $FAILED_CHECKS -eq 0 ]]; then echo "✓ PASS"; else echo "❌ FAIL"; fi)
```

```bash
export STATE_VALIDATION_PASSED=$PASSED_CHECKS STATE_VALIDATION_FAILED=$FAILED_CHECKS STATE_VALIDATION_WARNINGS=$WARNING_COUNT STATE_VALIDATION_TOTAL=$TOTAL_CHECKS STATE_VALIDATION_RESULT=$(if [[ $FAILED_CHECKS -eq 0 ]]; then echo "PASS"; else echo "FAIL"; fi)
echo "✓ Results stored | Proceeding to implementation validation..."
```

---

### 7. Proceed to Next Step

**Auto-proceed (no menu)**

```
→ Load, read entire file, then execute {nextStepFile}
```

---

## SUCCESS/FAILURE

**See {workflow_path}/data/universal-step-rules.md for standard criteria**

### ✅ SUCCESS:
- All checks executed (file existence, JSON syntax, required fields, feature structure, status values, metadata consistency, progress format)
- Results exported for final report
- Ready for step-02

### ❌ FAILURE:
- (None - validation always completes, failures recorded in results)

---

**Step Version:** 1.0.2 (Ultra-refactored)
**Created:** 2026-02-17
**Status:** Complete
