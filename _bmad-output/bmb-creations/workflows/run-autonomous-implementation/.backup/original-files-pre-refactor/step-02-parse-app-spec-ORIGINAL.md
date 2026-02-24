---
name: 'step-02-parse-app-spec'
description: 'Parse app_spec.txt and extract features with verification criteria'
nextStepFile: './step-03-generate-feature-list.md'
appSpecFile: '{project_folder}/app_spec.txt'
---

# Step 02: Parse app_spec.txt

## STEP GOAL:
Read and parse app_spec.txt XML structure, extract all features with their verification criteria, and prepare data for feature_list.json generation.

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: Data Parser (XML to structured data)
- ✅ Collaborative dialogue: None (automated parsing)
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

**Load complete file into memory:**

```bash
APP_SPEC_FILE="{appSpecFile}"

echo "Reading: $APP_SPEC_FILE"

if [[ ! -f "$APP_SPEC_FILE" ]]; then
    echo "❌ ERROR: app_spec.txt not found"
    echo "   Expected: $APP_SPEC_FILE"
    exit 1
fi

# Read file content
APP_SPEC_CONTENT=$(cat "$APP_SPEC_FILE")

echo "✓ File loaded ($(wc -l < "$APP_SPEC_FILE") lines)"
```

---

### 3. Extract Metadata

**Parse project information from <metadata> section:**

```bash
echo ""
echo "Extracting metadata..."

# Extract metadata fields
PROJECT_NAME=$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string(//metadata/project_name)" - 2>/dev/null)
GENERATED_FROM=$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string(//metadata/generated_from)" - 2>/dev/null)
GENERATED_DATE=$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string(//metadata/generated_date)" - 2>/dev/null)
AUTONOMOUS_READY=$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string(//metadata/autonomous_agent_ready)" - 2>/dev/null)

# Display extracted metadata
echo "  Project: $PROJECT_NAME"
echo "  Generated from: $GENERATED_FROM"
echo "  Generated date: $GENERATED_DATE"
echo "  Autonomous ready: $AUTONOMOUS_READY"

# Validate autonomous_agent_ready flag
if [[ "$AUTONOMOUS_READY" != "true" ]]; then
    echo ""
    echo "⚠️  WARNING: autonomous_agent_ready = $AUTONOMOUS_READY"
    echo "   This app_spec.txt may not be optimized for autonomous implementation."
    echo "   Consider running:"
    echo "   /bmad-bmm-check-autonomous-implementation-readiness"
    echo ""
    read -p "Continue anyway? [y/N]: " CONTINUE_CHOICE
    if [[ "$CONTINUE_CHOICE" != "y" && "$CONTINUE_CHOICE" != "Y" ]]; then
        echo "Aborting."
        exit 14
    fi
fi

echo "✓ Metadata extracted"
```

---

### 4. Extract All Features

**Parse all <feature> elements:**

```bash
echo ""
echo "Extracting features..."

# Count features
FEATURE_COUNT=$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "count(//feature)" - 2>/dev/null)

if [[ "$FEATURE_COUNT" == "0" || -z "$FEATURE_COUNT" ]]; then
    echo "❌ ERROR: No features found in app_spec.txt"
    exit 3
fi

echo "  Found: $FEATURE_COUNT features"
echo ""

# Initialize arrays to store feature data
declare -a FEATURE_IDS
declare -a FEATURE_NAMES
declare -a FEATURE_CATEGORIES
declare -a FEATURE_FUNCTIONAL_CRITERIA
declare -a FEATURE_TECHNICAL_CRITERIA
declare -a FEATURE_INTEGRATION_CRITERIA
declare -a FEATURE_DEPENDENCIES

# Extract each feature
echo "Parsing features:"

for ((i=1; i<=FEATURE_COUNT; i++)); do
    # Extract feature fields
    FEATURE_ID=$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string(//feature[$i]/@id)" - 2>/dev/null)
    FEATURE_NAME=$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string(//feature[$i]/name)" - 2>/dev/null)
    FEATURE_CATEGORY=$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string(//feature[$i]/category)" - 2>/dev/null)

    # Extract verification criteria
    FUNCTIONAL=$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string(//feature[$i]/verification_criteria/functional)" - 2>/dev/null)
    TECHNICAL=$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string(//feature[$i]/verification_criteria/technical)" - 2>/dev/null)
    INTEGRATION=$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string(//feature[$i]/verification_criteria/integration)" - 2>/dev/null)

    # Extract dependencies (comma-separated list of feature IDs)
    DEPENDENCIES=$(echo "$APP_SPEC_CONTENT" | xmllint --xpath "string(//feature[$i]/dependencies)" - 2>/dev/null)

    # Store in arrays
    FEATURE_IDS+=("$FEATURE_ID")
    FEATURE_NAMES+=("$FEATURE_NAME")
    FEATURE_CATEGORIES+=("$FEATURE_CATEGORY")
    FEATURE_FUNCTIONAL_CRITERIA+=("$FUNCTIONAL")
    FEATURE_TECHNICAL_CRITERIA+=("$TECHNICAL")
    FEATURE_INTEGRATION_CRITERIA+=("$INTEGRATION")
    FEATURE_DEPENDENCIES+=("$DEPENDENCIES")

    # Display progress
    echo "  [$i/$FEATURE_COUNT] $FEATURE_ID: $FEATURE_NAME"
done

echo ""
echo "✓ All features extracted"
```

---

### 5. Validate Feature Data

**Ensure extracted data is complete:**

```bash
echo ""
echo "Validating extracted data..."

VALIDATION_ERRORS=0

for ((i=0; i<FEATURE_COUNT; i++)); do
    FEATURE_ID="${FEATURE_IDS[$i]}"

    # Check required fields
    if [[ -z "$FEATURE_ID" ]]; then
        echo "  ❌ Feature $((i+1)): Missing ID"
        ((VALIDATION_ERRORS++))
    fi

    if [[ -z "${FEATURE_NAMES[$i]}" ]]; then
        echo "  ❌ Feature $FEATURE_ID: Missing name"
        ((VALIDATION_ERRORS++))
    fi

    if [[ -z "${FEATURE_CATEGORIES[$i]}" ]]; then
        echo "  ⚠️  Feature $FEATURE_ID: Missing category (will use 'Uncategorized')"
        FEATURE_CATEGORIES[$i]="Uncategorized"
    fi

    # Check verification criteria (at least one should exist)
    if [[ -z "${FEATURE_FUNCTIONAL_CRITERIA[$i]}" ]] && \
       [[ -z "${FEATURE_TECHNICAL_CRITERIA[$i]}" ]] && \
       [[ -z "${FEATURE_INTEGRATION_CRITERIA[$i]}" ]]; then
        echo "  ⚠️  Feature $FEATURE_ID: No verification criteria (tests will be minimal)"
    fi
done

if [[ $VALIDATION_ERRORS -gt 0 ]]; then
    echo ""
    echo "❌ Validation failed: $VALIDATION_ERRORS errors found"
    echo "   Fix app_spec.txt and regenerate with:"
    echo "   /bmad-bmm-create-app-spec"
    exit 15
fi

echo "✓ Validation passed (0 errors)"
```

---

### 6. Display Parsing Summary

```
─────────────────────────────────────────────────────
  PARSING COMPLETE
─────────────────────────────────────────────────────

Project: $PROJECT_NAME
Features Extracted: $FEATURE_COUNT

Features by Category:
$(for category in $(printf '%s\n' "${FEATURE_CATEGORIES[@]}" | sort -u); do
    count=$(printf '%s\n' "${FEATURE_CATEGORIES[@]}" | grep -c "^$category$")
    echo "  - $category: $count"
done)

Verification Criteria Coverage:
$(functional_count=$(printf '%s\n' "${FEATURE_FUNCTIONAL_CRITERIA[@]}" | grep -v '^$' | wc -l); echo "  - Functional: $functional_count/$FEATURE_COUNT features")
$(technical_count=$(printf '%s\n' "${FEATURE_TECHNICAL_CRITERIA[@]}" | grep -v '^$' | wc -l); echo "  - Technical: $technical_count/$FEATURE_COUNT features")
$(integration_count=$(printf '%s\n' "${FEATURE_INTEGRATION_CRITERIA[@]}" | grep -v '^$' | wc -l); echo "  - Integration: $integration_count/$FEATURE_COUNT features")

Ready to generate feature_list.json
```

---

### 7. Proceed to Next Step

**Menu Handling Logic:**
- This step uses **Auto-proceed** (no menu)
- Parsed data is stored in memory (arrays)
- Next step will use this data to generate feature_list.json

**Execution:**

```
Proceeding to generate feature_list.json...

→ Load, read entire file, then execute {nextStepFile}
```

**Note:** The parsed data arrays (FEATURE_IDS, FEATURE_NAMES, etc.) are passed to the next step through the environment.

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- app_spec.txt read successfully
- Metadata extracted (project name, generation date)
- All features extracted with IDs, names, categories
- Verification criteria extracted (functional, technical, integration)
- Dependencies extracted
- Validation passed (no missing required fields)
- Data stored in memory for step-03

### ❌ FAILURE:
- app_spec.txt not found (exit code 1)
- No features found (exit code 3)
- autonomous_agent_ready = false and user declines to continue (exit code 14)
- Validation errors (missing IDs or names) (exit code 15)

**Master Rule:** All features must be extracted before proceeding.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
