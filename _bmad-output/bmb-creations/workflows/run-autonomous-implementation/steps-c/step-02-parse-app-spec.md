---
name: 'step-02-parse-app-spec'
description: 'Parse app_spec.txt and extract features with verification criteria'
nextStepFile: './step-03-generate-feature-list.md'
appSpecFile: '{project_folder}/app_spec.txt'
---

# Step 02: Parse app_spec.txt

## STEP GOAL:
Read and parse app_spec.txt XML structure, extract all features with verification criteria, and prepare data for feature_list.json generation.

---

## MANDATORY EXECUTION RULES:

### Universal:
@~/.claude/rules/universal-workflow-rules.md

### Role:
- ✅ Role: Data Parser (XML to structured data)
- ✅ Collaborative: None (automated parsing)
- ✅ You bring: XML parsing logic, data extraction
- ✅ User brings: Valid app_spec.txt

### Step-Specific:
- 🎯 Focus: Extract all features and verification criteria
- 🚫 Forbidden: Skipping features, modifying app_spec.txt
- 💬 Approach: Systematic XML parsing with validation

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Store parsed data in memory for next step (don't write files yet)
- 📖 Read app_spec.txt completely

---

## CONTEXT BOUNDARIES:
- Available: app_spec.txt (validated in step-01)
- Focus: Feature extraction, criteria parsing
- Limits: Does not create files (that's step-03)
- Dependencies: Valid XML structure required

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Parsing Start

```
═══════════════════════════════════════════════════════
  PARSING APP_SPEC.TXT
  Extracting Features and Verification Criteria
═══════════════════════════════════════════════════════
```

---

### 2. Read app_spec.txt

```bash
APP_SPEC_FILE="{appSpecFile}"
echo "Reading: $APP_SPEC_FILE"

[[ ! -f "$APP_SPEC_FILE" ]] && echo "❌ ERROR: app_spec.txt not found at $APP_SPEC_FILE" && exit 1

APP_SPEC_CONTENT=$(cat "$APP_SPEC_FILE")
echo "✓ File loaded ($(wc -l < "$APP_SPEC_FILE") lines)"
```

---

### 3. Extract Metadata

```bash
echo ""
echo "Extracting metadata..."

# Use xmllint for all metadata extraction
PROJECT_NAME=$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string(//metadata/project_name)" - 2>/dev/null)
GENERATED_FROM=$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string(//metadata/generated_from)" - 2>/dev/null)
GENERATED_DATE=$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string(//metadata/generated_date)" - 2>/dev/null)
AUTONOMOUS_READY=$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string(//metadata/autonomous_agent_ready)" - 2>/dev/null)

echo "  Project: $PROJECT_NAME | Generated: $GENERATED_DATE | Autonomous: $AUTONOMOUS_READY"

# Validate autonomous_agent_ready flag (optional field)
if [[ -z "$AUTONOMOUS_READY" ]]; then
    # Field missing or empty - treat as non-fatal warning
    echo "⚠️  INFO: autonomous_agent_ready field not found (optional)"
    echo "   For best results, consider running: /bmad-bmm-check-autonomous-implementation-readiness"
    AUTONOMOUS_READY="unknown"
elif [[ "$AUTONOMOUS_READY" == "false" ]]; then
    # Explicitly set to false - log warning but continue autonomously
    echo "⚠️  WARNING: autonomous_agent_ready = false"
    echo "   This app_spec may not be suitable for autonomous implementation."
    echo "   Consider running: /bmad-bmm-check-autonomous-implementation-readiness"
    echo "   Continuing with autonomous implementation (circuit breaker will protect against repeated failures)"
elif [[ "$AUTONOMOUS_READY" != "true" ]]; then
    # Some other value - warn but continue
    echo "⚠️  WARNING: autonomous_agent_ready = $AUTONOMOUS_READY (expected 'true' or 'false')"
    echo "   Consider running: /bmad-bmm-check-autonomous-implementation-readiness"
fi

echo "✓ Metadata extracted"
```

---

### 4. Extract All Features

```bash
echo ""
echo "Extracting features..."

FEATURE_COUNT=$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "count(//feature)" - 2>/dev/null)
[[ "$FEATURE_COUNT" == "0" || -z "$FEATURE_COUNT" ]] && echo "❌ ERROR: No features found" && exit 3

echo "  Found: $FEATURE_COUNT features"
echo ""

# Initialize arrays
declare -a FEATURE_IDS FEATURE_NAMES FEATURE_CATEGORIES
declare -a FEATURE_FUNCTIONAL_CRITERIA FEATURE_TECHNICAL_CRITERIA FEATURE_INTEGRATION_CRITERIA
declare -a FEATURE_DEPENDENCIES

# Extract features using xmllint XPath with loop consolidation
echo "Parsing features:"
for ((i=1; i<=FEATURE_COUNT; i++)); do
    XPATH_BASE="//feature[$i]"

    FEATURE_IDS+=("$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string($XPATH_BASE/@id)" - 2>/dev/null)")
    FEATURE_NAMES+=("$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string($XPATH_BASE/name)" - 2>/dev/null)")
    FEATURE_CATEGORIES+=("$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string($XPATH_BASE/category)" - 2>/dev/null)")
    FEATURE_FUNCTIONAL_CRITERIA+=("$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string($XPATH_BASE/verification_criteria/functional)" - 2>/dev/null)")
    FEATURE_TECHNICAL_CRITERIA+=("$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string($XPATH_BASE/verification_criteria/technical)" - 2>/dev/null)")
    FEATURE_INTEGRATION_CRITERIA+=("$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string($XPATH_BASE/verification_criteria/integration)" - 2>/dev/null)")
    FEATURE_DEPENDENCIES+=("$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string($XPATH_BASE/dependencies)" - 2>/dev/null)")

    echo "  [$i/$FEATURE_COUNT] ${FEATURE_IDS[$((i-1))]}: ${FEATURE_NAMES[$((i-1))]}"
done

echo ""
echo "✓ All features extracted"
```

---

### 5. Validate Feature Data

```bash
echo ""
echo "Validating extracted data..."

VALIDATION_ERRORS=0

for ((i=0; i<FEATURE_COUNT; i++)); do
    FID="${FEATURE_IDS[$i]}"

    [[ -z "$FID" ]] && echo "  ❌ Feature $((i+1)): Missing ID" && ((VALIDATION_ERRORS++))
    [[ -z "${FEATURE_NAMES[$i]}" ]] && echo "  ❌ Feature $FID: Missing name" && ((VALIDATION_ERRORS++))

    if [[ -z "${FEATURE_CATEGORIES[$i]}" ]]; then
        echo "  ⚠️  Feature $FID: Missing category (using 'Uncategorized')"
        FEATURE_CATEGORIES[$i]="Uncategorized"
    fi

    # Check at least one verification criterion exists
    [[ -z "${FEATURE_FUNCTIONAL_CRITERIA[$i]}" ]] && \
    [[ -z "${FEATURE_TECHNICAL_CRITERIA[$i]}" ]] && \
    [[ -z "${FEATURE_INTEGRATION_CRITERIA[$i]}" ]] && \
    echo "  ⚠️  Feature $FID: No verification criteria (tests will be minimal)"
done

if [[ $VALIDATION_ERRORS -gt 0 ]]; then
    echo ""
    echo "❌ Validation failed: $VALIDATION_ERRORS errors found"
    echo "   Fix with: /bmad-bmm-create-app-spec"
    exit 15
fi

echo "✓ Validation passed (0 errors)"
```

---

### 6. Display Parsing Summary

```bash
echo ""
echo "─────────────────────────────────────────────────────"
echo "  PARSING COMPLETE"
echo "─────────────────────────────────────────────────────"
echo ""
echo "Project: $PROJECT_NAME"
echo "Features Extracted: $FEATURE_COUNT"
echo ""
echo "Features by Category:"
for category in $(printf '%s\n' "${FEATURE_CATEGORIES[@]}" | sort -u); do
    count=$(printf '%s\n' "${FEATURE_CATEGORIES[@]}" | grep -c "^$category$")
    echo "  - $category: $count"
done
echo ""
echo "Verification Criteria Coverage:"
functional_count=$(printf '%s\n' "${FEATURE_FUNCTIONAL_CRITERIA[@]}" | grep -v '^$' | wc -l)
technical_count=$(printf '%s\n' "${FEATURE_TECHNICAL_CRITERIA[@]}" | grep -v '^$' | wc -l)
integration_count=$(printf '%s\n' "${FEATURE_INTEGRATION_CRITERIA[@]}" | grep -v '^$' | wc -l)
echo "  - Functional: $functional_count/$FEATURE_COUNT features"
echo "  - Technical: $technical_count/$FEATURE_COUNT features"
echo "  - Integration: $integration_count/$FEATURE_COUNT features"
echo ""
echo "Ready to generate feature_list.json"
```

---

### 7. Proceed to Next Step

**Auto-proceed (no menu):**

```
Proceeding to generate feature_list.json...

→ Load, read entire file, then execute {nextStepFile}
```

**Note:** Parsed data arrays passed to next step via environment.

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- app_spec.txt read, metadata extracted
- All features with IDs, names, categories extracted
- Verification criteria (functional, technical, integration) extracted
- Dependencies extracted, validation passed
- Data stored in memory for step-03

### ❌ FAILURE:
- app_spec.txt not found (exit 1)
- No features found (exit 3)
- autonomous_agent_ready = false + user decline (exit 14)
- Validation errors (missing IDs/names) (exit 15)

**Master Rule:** All features must be extracted before proceeding.

---

**Step Version:** 1.0.1-refactored
**Created:** 2026-02-17
**Status:** Complete
