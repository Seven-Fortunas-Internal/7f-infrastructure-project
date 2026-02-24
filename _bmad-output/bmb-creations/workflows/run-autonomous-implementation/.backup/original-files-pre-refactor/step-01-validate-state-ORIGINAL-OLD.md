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
echo ""
echo "Initializing validation..."
VALIDATION_PASSED=()
VALIDATION_FAILED=()
VALIDATION_WARNINGS=()
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_COUNT=0
echo "✓ Validation initialized"
echo ""
```

---

### 2. Validate File Existence

```bash
echo "CHECK 1: FILE EXISTENCE"
echo ""

FEATURE_LIST_FILE="{featureListFile}"
PROGRESS_FILE="{progressFile}"
BUILD_LOG_FILE="{buildLogFile}"

# Check feature_list.json
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if [[ -f "$FEATURE_LIST_FILE" ]]; then
    echo "✓ feature_list.json exists"
    VALIDATION_PASSED+=("File existence: feature_list.json")
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo "❌ feature_list.json NOT FOUND"
    VALIDATION_FAILED+=("File existence: feature_list.json missing")
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check claude-progress.txt
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if [[ -f "$PROGRESS_FILE" ]]; then
    echo "✓ claude-progress.txt exists"
    VALIDATION_PASSED+=("File existence: claude-progress.txt")
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo "❌ claude-progress.txt NOT FOUND"
    VALIDATION_FAILED+=("File existence: claude-progress.txt missing")
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check autonomous_build_log.md
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if [[ -f "$BUILD_LOG_FILE" ]]; then
    echo "✓ autonomous_build_log.md exists"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo "⚠️  autonomous_build_log.md NOT FOUND"
    VALIDATION_WARNINGS+=("Build log missing (optional)")
    WARNING_COUNT=$((WARNING_COUNT + 1))
fi
echo ""
```

---

### 3. Validate JSON Syntax

```bash
echo "CHECK 2: JSON SYNTAX"
echo ""

if [[ -f "$FEATURE_LIST_FILE" ]]; then
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then
        echo "✓ feature_list.json has valid JSON"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo "❌ feature_list.json has INVALID JSON"
        VALIDATION_FAILED+=("JSON syntax: corrupted")
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
fi
echo ""
```

---

### 4. Validate Required Fields

```bash
echo "CHECK 3: REQUIRED FIELDS"
echo ""

if [[ -f "$FEATURE_LIST_FILE" ]] && jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then
    # Check metadata section
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if jq -e '.metadata' "$FEATURE_LIST_FILE" >/dev/null 2>&1; then
        echo "✓ metadata section exists"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo "❌ metadata section MISSING"
        VALIDATION_FAILED+=("Required fields: metadata missing")
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi

    # Check features array
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if jq -e '.features | type == "array"' "$FEATURE_LIST_FILE" >/dev/null 2>&1; then
        echo "✓ features array exists"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo "❌ features array MISSING"
        VALIDATION_FAILED+=("Required fields: features array missing")
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi

    # Check critical metadata fields
    for field in project_name total_features generated_date; do
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        if jq -e ".metadata.$field" "$FEATURE_LIST_FILE" >/dev/null 2>&1; then
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo "❌ metadata.$field MISSING"
            VALIDATION_FAILED+=("Required fields: metadata.$field missing")
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        fi
    done
    echo "✓ Critical metadata fields checked"
fi
echo ""
```

---

### 5. Validate Feature Structure

```bash
echo "CHECK 4: FEATURE STRUCTURE"
echo ""

if [[ -f "$FEATURE_LIST_FILE" ]] && jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then
    FEATURE_COUNT=$(jq -r '.features | length' "$FEATURE_LIST_FILE")
    echo "Validating $FEATURE_COUNT features..."

    REQUIRED_FIELDS=("id" "name" "status" "attempts" "category" "verification_criteria")

    for i in $(seq 0 $((FEATURE_COUNT - 1))); do
        for field in "${REQUIRED_FIELDS[@]}"; do
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
            if jq -e ".features[$i].$field" "$FEATURE_LIST_FILE" >/dev/null 2>&1; then
                PASSED_CHECKS=$((PASSED_CHECKS + 1))
            else
                FEATURE_ID=$(jq -r ".features[$i].id" "$FEATURE_LIST_FILE")
                echo "❌ Feature $FEATURE_ID missing field: $field"
                VALIDATION_FAILED+=("Feature structure: $FEATURE_ID missing $field")
                FAILED_CHECKS=$((FAILED_CHECKS + 1))
            fi
        done
    done

    [[ $FAILED_CHECKS -eq 0 ]] && echo "✓ All features have required fields"
fi
echo ""
```

---

### 6. Validate Status Values

```bash
echo "CHECK 5: STATUS VALUES"
echo ""

if [[ -f "$FEATURE_LIST_FILE" ]] && jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then
    VALID_STATUSES=("pending" "in_progress" "pass" "fail" "blocked")
    INVALID_COUNT=0

    while IFS= read -r status_line; do
        FEATURE_ID=$(echo "$status_line" | cut -d'|' -f1)
        STATUS=$(echo "$status_line" | cut -d'|' -f2)
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

        if [[ " ${VALID_STATUSES[@]} " =~ " ${STATUS} " ]]; then
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo "❌ Feature $FEATURE_ID has invalid status: '$STATUS'"
            VALIDATION_FAILED+=("Status values: $FEATURE_ID invalid status")
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            INVALID_COUNT=$((INVALID_COUNT + 1))
        fi
    done < <(jq -r '.features[] | "\(.id)|\(.status)"' "$FEATURE_LIST_FILE")

    [[ $INVALID_COUNT -eq 0 ]] && echo "✓ All feature statuses are valid"
fi
echo ""
```

---

### 7. Validate Metadata Consistency

```bash
echo "CHECK 6: METADATA CONSISTENCY"
echo ""

if [[ -f "$FEATURE_LIST_FILE" ]] && jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    DECLARED_TOTAL=$(jq -r '.metadata.total_features' "$FEATURE_LIST_FILE")
    ACTUAL_TOTAL=$(jq -r '.features | length' "$FEATURE_LIST_FILE")

    if [[ $DECLARED_TOTAL -eq $ACTUAL_TOTAL ]]; then
        echo "✓ total_features matches array length"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo "❌ total_features MISMATCH: Declared=$DECLARED_TOTAL, Actual=$ACTUAL_TOTAL"
        VALIDATION_FAILED+=("Metadata consistency: total_features mismatch")
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
fi
echo ""
```

---

### 8. Validate Progress File Format

```bash
echo "CHECK 7: PROGRESS FILE FORMAT"
echo ""

if [[ -f "$PROGRESS_FILE" ]]; then
    REQUIRED_METADATA=("session_count" "consecutive_failures" "circuit_breaker_threshold" "circuit_breaker_status")

    for field in "${REQUIRED_METADATA[@]}"; do
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        if grep -q "^${field}=" "$PROGRESS_FILE"; then
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo "❌ $field MISSING"
            VALIDATION_FAILED+=("Progress format: $field missing")
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        fi
    done
    echo "✓ Progress file metadata checked"
fi
echo ""
```

---

### 9. Display Summary & Store Results

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
# Export for final report
export STATE_VALIDATION_PASSED=$PASSED_CHECKS
export STATE_VALIDATION_FAILED=$FAILED_CHECKS
export STATE_VALIDATION_WARNINGS=$WARNING_COUNT
export STATE_VALIDATION_TOTAL=$TOTAL_CHECKS
export STATE_VALIDATION_RESULT=$(if [[ $FAILED_CHECKS -eq 0 ]]; then echo "PASS"; else echo "FAIL"; fi)

echo ""
echo "✓ Results stored for final report"
echo "Proceeding to implementation validation..."
echo ""
```

---

### 10. Proceed to Next Step

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

**Step Version:** 1.0.1 (Refactored)
**Created:** 2026-02-17
**Status:** Complete
