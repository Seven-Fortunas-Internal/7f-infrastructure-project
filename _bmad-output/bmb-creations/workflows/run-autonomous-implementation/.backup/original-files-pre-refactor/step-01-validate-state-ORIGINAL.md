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

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: State Validator (integrity checker)
- ✅ Collaborative dialogue: None (automated validation)
- ✅ You bring: Validation logic, error detection
- ✅ User brings: Implementation to validate

### Step-Specific:
- 🎯 Focus: Tracking file integrity and consistency
- 🚫 Forbidden: Making repairs (report only)
- 💬 Approach: Systematic checks with clear pass/fail

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Read-only validation (no modifications)
- 📖 Collect all validation results for final report

---

## CONTEXT BOUNDARIES:
- Available: All tracking files (read-only)
- Focus: File integrity and consistency validation
- Limits: Does not validate implementation code (that's step-02)
- Dependencies: Requires tracking files exist

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Validation Banner

```
═══════════════════════════════════════════════════════
  VALIDATE MODE - State Integrity Check
  Verifying Tracking File Consistency
═══════════════════════════════════════════════════════
```

---

### 2. Initialize Validation Results

**Prepare result tracking:**

```bash
echo ""
echo "Initializing validation..."

# Validation result arrays
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

### 3. Validate File Existence

**Check all required files exist:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 1: FILE EXISTENCE"
echo "─────────────────────────────────────────────────────"
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
    VALIDATION_PASSED+=("File existence: autonomous_build_log.md")
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo "⚠️  autonomous_build_log.md NOT FOUND"
    VALIDATION_WARNINGS+=("File existence: autonomous_build_log.md missing (optional)")
    WARNING_COUNT=$((WARNING_COUNT + 1))
fi

echo ""
```

---

### 4. Validate JSON Syntax

**Ensure feature_list.json is valid JSON:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 2: JSON SYNTAX"
echo "─────────────────────────────────────────────────────"
echo ""

if [[ -f "$FEATURE_LIST_FILE" ]]; then
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then
        echo "✓ feature_list.json has valid JSON syntax"
        VALIDATION_PASSED+=("JSON syntax: feature_list.json valid")
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo "❌ feature_list.json has INVALID JSON syntax"
        echo "   File is corrupted or manually edited incorrectly"
        VALIDATION_FAILED+=("JSON syntax: feature_list.json corrupted")
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
else
    echo "⊘ Skipped (file missing)"
fi

echo ""
```

---

### 5. Validate Required Fields

**Check feature_list.json has all required structure:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 3: REQUIRED FIELDS"
echo "─────────────────────────────────────────────────────"
echo ""

if [[ -f "$FEATURE_LIST_FILE" ]] && jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then

    # Check metadata section
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if jq -e '.metadata' "$FEATURE_LIST_FILE" >/dev/null 2>&1; then
        echo "✓ metadata section exists"
        VALIDATION_PASSED+=("Required fields: metadata section present")
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo "❌ metadata section MISSING"
        VALIDATION_FAILED+=("Required fields: metadata section missing")
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi

    # Check features array
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if jq -e '.features | type == "array"' "$FEATURE_LIST_FILE" >/dev/null 2>&1; then
        echo "✓ features array exists"
        VALIDATION_PASSED+=("Required fields: features array present")
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo "❌ features array MISSING or wrong type"
        VALIDATION_FAILED+=("Required fields: features array missing/invalid")
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi

    # Check critical metadata fields
    for field in project_name total_features generated_date; do
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        if jq -e ".metadata.$field" "$FEATURE_LIST_FILE" >/dev/null 2>&1; then
            echo "✓ metadata.$field exists"
            VALIDATION_PASSED+=("Required fields: metadata.$field present")
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo "❌ metadata.$field MISSING"
            VALIDATION_FAILED+=("Required fields: metadata.$field missing")
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        fi
    done

else
    echo "⊘ Skipped (file missing or invalid JSON)"
fi

echo ""
```

---

### 6. Validate Feature Structure

**Ensure all features have required fields:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 4: FEATURE STRUCTURE"
echo "─────────────────────────────────────────────────────"
echo ""

if [[ -f "$FEATURE_LIST_FILE" ]] && jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then

    FEATURE_COUNT=$(jq -r '.features | length' "$FEATURE_LIST_FILE")
    echo "Validating $FEATURE_COUNT features..."
    echo ""

    # Check each feature has required fields
    REQUIRED_FIELDS=("id" "name" "status" "attempts" "category" "verification_criteria")

    for i in $(seq 0 $((FEATURE_COUNT - 1))); do
        FEATURE_ID=$(jq -r ".features[$i].id" "$FEATURE_LIST_FILE")

        for field in "${REQUIRED_FIELDS[@]}"; do
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

            if jq -e ".features[$i].$field" "$FEATURE_LIST_FILE" >/dev/null 2>&1; then
                PASSED_CHECKS=$((PASSED_CHECKS + 1))
            else
                echo "❌ Feature $FEATURE_ID missing field: $field"
                VALIDATION_FAILED+=("Feature structure: $FEATURE_ID missing $field")
                FAILED_CHECKS=$((FAILED_CHECKS + 1))
            fi
        done
    done

    if [[ $FAILED_CHECKS -eq 0 ]]; then
        echo "✓ All features have required fields"
        VALIDATION_PASSED+=("Feature structure: All features valid")
    fi

else
    echo "⊘ Skipped (file missing or invalid JSON)"
fi

echo ""
```

---

### 7. Validate Status Values

**Ensure all status values are valid:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 5: STATUS VALUES"
echo "─────────────────────────────────────────────────────"
echo ""

if [[ -f "$FEATURE_LIST_FILE" ]] && jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then

    VALID_STATUSES=("pending" "in_progress" "pass" "fail" "blocked")
    INVALID_STATUS_COUNT=0

    # Check each feature's status
    while IFS= read -r status_line; do
        FEATURE_ID=$(echo "$status_line" | cut -d'|' -f1)
        STATUS=$(echo "$status_line" | cut -d'|' -f2)

        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

        if [[ " ${VALID_STATUSES[@]} " =~ " ${STATUS} " ]]; then
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo "❌ Feature $FEATURE_ID has invalid status: '$STATUS'"
            VALIDATION_FAILED+=("Status values: $FEATURE_ID has invalid status '$STATUS'")
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            INVALID_STATUS_COUNT=$((INVALID_STATUS_COUNT + 1))
        fi
    done < <(jq -r '.features[] | "\(.id)|\(.status)"' "$FEATURE_LIST_FILE")

    if [[ $INVALID_STATUS_COUNT -eq 0 ]]; then
        echo "✓ All feature statuses are valid"
        VALIDATION_PASSED+=("Status values: All statuses valid")
    fi

else
    echo "⊘ Skipped (file missing or invalid JSON)"
fi

echo ""
```

---

### 8. Validate Metadata Consistency

**Check feature counts match actual features:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 6: METADATA CONSISTENCY"
echo "─────────────────────────────────────────────────────"
echo ""

if [[ -f "$FEATURE_LIST_FILE" ]] && jq empty "$FEATURE_LIST_FILE" 2>/dev/null; then

    # Check total_features matches array length
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    DECLARED_TOTAL=$(jq -r '.metadata.total_features' "$FEATURE_LIST_FILE")
    ACTUAL_TOTAL=$(jq -r '.features | length' "$FEATURE_LIST_FILE")

    if [[ $DECLARED_TOTAL -eq $ACTUAL_TOTAL ]]; then
        echo "✓ total_features ($DECLARED_TOTAL) matches features array length ($ACTUAL_TOTAL)"
        VALIDATION_PASSED+=("Metadata consistency: total_features matches")
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo "❌ total_features MISMATCH"
        echo "   Declared: $DECLARED_TOTAL"
        echo "   Actual: $ACTUAL_TOTAL"
        VALIDATION_FAILED+=("Metadata consistency: total_features mismatch ($DECLARED_TOTAL vs $ACTUAL_TOTAL)")
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi

else
    echo "⊘ Skipped (file missing or invalid JSON)"
fi

echo ""
```

---

### 9. Validate Progress File Format

**Check claude-progress.txt has required metadata:**

```bash
echo "─────────────────────────────────────────────────────"
echo "  CHECK 7: PROGRESS FILE FORMAT"
echo "─────────────────────────────────────────────────────"
echo ""

if [[ -f "$PROGRESS_FILE" ]]; then

    REQUIRED_METADATA=("session_count" "consecutive_failures" "circuit_breaker_threshold" "circuit_breaker_status")

    for field in "${REQUIRED_METADATA[@]}"; do
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

        if grep -q "^${field}=" "$PROGRESS_FILE"; then
            echo "✓ $field present"
            VALIDATION_PASSED+=("Progress format: $field present")
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo "❌ $field MISSING"
            VALIDATION_FAILED+=("Progress format: $field missing")
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        fi
    done

else
    echo "⊘ Skipped (file missing)"
fi

echo ""
```

---

### 10. Display Validation Summary

```
─────────────────────────────────────────────────────
  STATE VALIDATION SUMMARY
─────────────────────────────────────────────────────

Total Checks: $TOTAL_CHECKS
  ✓ Passed:  $PASSED_CHECKS
  ❌ Failed:  $FAILED_CHECKS
  ⚠️  Warnings: $WARNING_COUNT

Overall Result: $(if [[ $FAILED_CHECKS -eq 0 ]]; then echo "✓ PASS"; else echo "❌ FAIL"; fi)

$(if [[ $FAILED_CHECKS -gt 0 ]]; then
    echo ""
    echo "Critical Issues Found:"
    for failure in "${VALIDATION_FAILED[@]}"; do
        echo "  - $failure"
    done
fi)

$(if [[ $WARNING_COUNT -gt 0 ]]; then
    echo ""
    echo "Warnings:"
    for warning in "${VALIDATION_WARNINGS[@]}"; do
        echo "  - $warning"
    done
fi)

Next: Validate implementation against tracking
```

---

### 11. Store Results for Final Report

**Export validation data for step-04:**

```bash
# Export for final report
export STATE_VALIDATION_PASSED=$PASSED_CHECKS
export STATE_VALIDATION_FAILED=$FAILED_CHECKS
export STATE_VALIDATION_WARNINGS=$WARNING_COUNT
export STATE_VALIDATION_TOTAL=$TOTAL_CHECKS
export STATE_VALIDATION_RESULT=$(if [[ $FAILED_CHECKS -eq 0 ]]; then echo "PASS"; else echo "FAIL"; fi)

echo ""
echo "✓ Results stored for final report"
echo ""
```

---

### 12. Proceed to Next Step

**Menu Handling Logic:**
- This step uses **Auto-proceed** (no menu)
- State validation complete, proceed to implementation validation

**Execution:**

```
Proceeding to implementation validation...

→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- Validation initialized
- File existence checked (feature_list.json, claude-progress.txt, build log)
- JSON syntax validated
- Required fields checked (metadata, features array)
- Feature structure validated (all required fields present)
- Status values validated (all valid enum values)
- Metadata consistency checked (total_features matches)
- Progress file format validated (required metadata present)
- Validation summary displayed
- Results exported for final report
- Ready for step-02 (implementation validation)

### ❌ FAILURE:
- (None - validation always completes)
- Failures recorded in validation results for reporting

**Master Rule:** State validation must check all tracking file integrity without making repairs.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
