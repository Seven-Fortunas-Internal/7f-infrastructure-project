---
name: 'step-08-select-next-feature'
description: 'Select next feature to implement based on priority and dependencies'
nextStepFile: './step-09-implement-feature.md'
featureListFile: '{project_folder}/feature_list.json'
appSpecFile: '{project_folder}/app_spec.txt'
---

# Step 08: Select Next Feature

## STEP GOAL:
Identify and select the next actionable feature for implementation based on dependencies, retry eligibility, and priority.

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: Feature Selector (intelligent prioritization)
- ✅ Collaborative dialogue: None (automated selection with smart logic)
- ✅ You bring: Dependency analysis, priority logic
- ✅ User brings: feature_list.json state from step-07

### Step-Specific:
- 🎯 Focus: Select optimal feature for implementation
- 🚫 Forbidden: Selecting blocked features, ignoring dependencies
- 💬 Approach: Priority-based selection with dependency validation

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Store selected feature in memory (don't modify feature_list.json yet)
- 📖 Load feature details from app_spec.txt

---

## CONTEXT BOUNDARIES:
- Available: feature_list.json (from step-07), app_spec.txt
- Focus: Feature selection and details loading
- Limits: Does not implement features (that's step-09)
- Dependencies: Requires actionable features (validated in step-07)

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Selection Start

```
═══════════════════════════════════════════════════════
  SELECTING NEXT FEATURE
  Priority-Based Selection with Dependency Analysis
═══════════════════════════════════════════════════════
```

---

### 2. Build Candidate List

**Identify all actionable features:**

```bash
FEATURE_LIST_FILE="{featureListFile}"

echo ""
echo "Building candidate list..."

# Load feature list
FEATURE_LIST=$(cat "$FEATURE_LIST_FILE")

# Get features with status="pending" (never attempted)
PENDING_FEATURES=$(echo "$FEATURE_LIST" | jq -r '.features[] | select(.status == "pending") | .id')

# Get features with status="fail" and attempts < 3 (retry eligible)
RETRY_FEATURES=$(echo "$FEATURE_LIST" | jq -r '.features[] | select(.status == "fail" and .attempts < 3) | .id')

# Combine into candidates array
CANDIDATES=()
while IFS= read -r id; do
    [[ -n "$id" ]] && CANDIDATES+=("$id")
done <<< "$PENDING_FEATURES"

while IFS= read -r id; do
    [[ -n "$id" ]] && CANDIDATES+=("$id")
done <<< "$RETRY_FEATURES"

CANDIDATE_COUNT=${#CANDIDATES[@]}

echo "  Candidates: $CANDIDATE_COUNT features"
echo "    - Pending (never tried): $(echo "$PENDING_FEATURES" | grep -c .)"
echo "    - Retry eligible (fail, attempts < 3): $(echo "$RETRY_FEATURES" | grep -c .)"
echo ""

if [[ $CANDIDATE_COUNT -eq 0 ]]; then
    echo "❌ ERROR: No actionable features (this should not happen)"
    echo "   step-07 should have detected this."
    exit 33
fi
```

---

### 3. Filter by Dependencies

**Remove features with unsatisfied dependencies:**

```bash
echo "Checking dependencies..."

AVAILABLE_FEATURES=()

for candidate_id in "${CANDIDATES[@]}"; do
    # Get dependencies for this feature
    DEPENDENCIES=$(echo "$FEATURE_LIST" | jq -r --arg id "$candidate_id" '.features[] | select(.id == $id) | .dependencies[]' 2>/dev/null)

    # If no dependencies, feature is available
    if [[ -z "$DEPENDENCIES" ]]; then
        AVAILABLE_FEATURES+=("$candidate_id")
        continue
    fi

    # Check if all dependencies are satisfied (status = "pass")
    ALL_SATISFIED=true
    while IFS= read -r dep_id; do
        [[ -z "$dep_id" ]] && continue

        DEP_STATUS=$(echo "$FEATURE_LIST" | jq -r --arg id "$dep_id" '.features[] | select(.id == $id) | .status')

        if [[ "$DEP_STATUS" != "pass" ]]; then
            ALL_SATISFIED=false
            break
        fi
    done <<< "$DEPENDENCIES"

    if [[ "$ALL_SATISFIED" == "true" ]]; then
        AVAILABLE_FEATURES+=("$candidate_id")
    fi
done

AVAILABLE_COUNT=${#AVAILABLE_FEATURES[@]}

echo "  Available (dependencies satisfied): $AVAILABLE_COUNT features"
echo ""

if [[ $AVAILABLE_COUNT -eq 0 ]]; then
    echo "⚠️  No features available (all have unsatisfied dependencies)"
    echo ""
    echo "  This indicates a dependency deadlock or all actionable features are blocked."
    echo ""
    echo "  Options:"
    echo "  1. Use EDIT mode to manually mark dependencies as complete"
    echo "  2. Review dependency graph for circular dependencies"
    echo "  3. Manually implement blocking features"
    echo ""
    exit 34
fi
```

---

### 4. Prioritize Features

**Apply priority logic:**

```bash
echo "Applying priority logic..."

# Priority rules:
# 1. Pending features (never tried) over retry features
# 2. Features with no dependencies first
# 3. Lower feature ID numbers first (sequential order)

# Separate pending from retry
PENDING_AVAILABLE=()
RETRY_AVAILABLE=()

for feature_id in "${AVAILABLE_FEATURES[@]}"; do
    STATUS=$(echo "$FEATURE_LIST" | jq -r --arg id "$feature_id" '.features[] | select(.id == $id) | .status')

    if [[ "$STATUS" == "pending" ]]; then
        PENDING_AVAILABLE+=("$feature_id")
    elif [[ "$STATUS" == "fail" ]]; then
        RETRY_AVAILABLE+=("$feature_id")
    fi
done

# Sort each group by feature ID (sequential order)
if [[ ${#PENDING_AVAILABLE[@]} -gt 0 ]]; then
    IFS=$'\n' PENDING_SORTED=($(sort <<<"${PENDING_AVAILABLE[*]}"))
    unset IFS
fi

if [[ ${#RETRY_AVAILABLE[@]} -gt 0 ]]; then
    IFS=$'\n' RETRY_SORTED=($(sort <<<"${RETRY_AVAILABLE[*]}"))
    unset IFS
fi

# Priority: Pending first, then retry
PRIORITIZED_FEATURES=()
[[ ${#PENDING_SORTED[@]} -gt 0 ]] && PRIORITIZED_FEATURES+=("${PENDING_SORTED[@]}")
[[ ${#RETRY_SORTED[@]} -gt 0 ]] && PRIORITIZED_FEATURES+=("${RETRY_SORTED[@]}")

echo "  Prioritized: ${#PRIORITIZED_FEATURES[@]} features"
echo "    - Pending: ${#PENDING_SORTED[@]}"
echo "    - Retry: ${#RETRY_SORTED[@]}"
echo ""
```

---

### 5. Select Top Priority Feature

**Choose the first feature from prioritized list:**

```bash
echo "Selecting feature..."

SELECTED_FEATURE_ID="${PRIORITIZED_FEATURES[0]}"

if [[ -z "$SELECTED_FEATURE_ID" ]]; then
    echo "❌ ERROR: No feature could be selected"
    exit 35
fi

# Load feature details
FEATURE_NAME=$(echo "$FEATURE_LIST" | jq -r --arg id "$SELECTED_FEATURE_ID" '.features[] | select(.id == $id) | .name')
FEATURE_CATEGORY=$(echo "$FEATURE_LIST" | jq -r --arg id "$SELECTED_FEATURE_ID" '.features[] | select(.id == $id) | .category')
FEATURE_STATUS=$(echo "$FEATURE_LIST" | jq -r --arg id "$SELECTED_FEATURE_ID" '.features[] | select(.id == $id) | .status')
FEATURE_ATTEMPTS=$(echo "$FEATURE_LIST" | jq -r --arg id "$SELECTED_FEATURE_ID" '.features[] | select(.id == $id) | .attempts')

echo "✓ Selected: $SELECTED_FEATURE_ID"
echo "  Name: $FEATURE_NAME"
echo "  Category: $FEATURE_CATEGORY"
echo "  Status: $FEATURE_STATUS"
echo "  Attempts: $FEATURE_ATTEMPTS"
```

---

### 6. Load Feature Details from app_spec.txt

**Extract complete feature specification:**

```bash
APP_SPEC_FILE="{appSpecFile}"

echo ""
echo "Loading feature details from app_spec.txt..."

# Find feature in XML
FEATURE_XML=$(xmllint --xpath "//feature[@id='$SELECTED_FEATURE_ID']" "$APP_SPEC_FILE" 2>/dev/null)

if [[ -z "$FEATURE_XML" ]]; then
    echo "⚠️  Warning: Feature not found in app_spec.txt"
    echo "   Using data from feature_list.json only"

    # Load from feature_list.json
    FEATURE_DESCRIPTION=$(echo "$FEATURE_LIST" | jq -r --arg id "$SELECTED_FEATURE_ID" '.features[] | select(.id == $id) | .name')
    FUNCTIONAL_CRITERIA=$(echo "$FEATURE_LIST" | jq -r --arg id "$SELECTED_FEATURE_ID" '.features[] | select(.id == $id) | .verification_criteria.functional // ""')
    TECHNICAL_CRITERIA=$(echo "$FEATURE_LIST" | jq -r --arg id "$SELECTED_FEATURE_ID" '.features[] | select(.id == $id) | .verification_criteria.technical // ""')
    INTEGRATION_CRITERIA=$(echo "$FEATURE_LIST" | jq -r --arg id "$SELECTED_FEATURE_ID" '.features[] | select(.id == $id) | .verification_criteria.integration // ""')
else
    # Extract from app_spec.txt (preferred)
    FEATURE_DESCRIPTION=$(echo "$FEATURE_XML" | xmllint --xpath "string(//description)" - 2>/dev/null)
    FEATURE_REQUIREMENTS=$(echo "$FEATURE_XML" | xmllint --xpath "string(//requirements)" - 2>/dev/null)
    FUNCTIONAL_CRITERIA=$(echo "$FEATURE_XML" | xmllint --xpath "string(//verification_criteria/functional)" - 2>/dev/null)
    TECHNICAL_CRITERIA=$(echo "$FEATURE_XML" | xmllint --xpath "string(//verification_criteria/technical)" - 2>/dev/null)
    INTEGRATION_CRITERIA=$(echo "$FEATURE_XML" | xmllint --xpath "string(//verification_criteria/integration)" - 2>/dev/null)
    IMPLEMENTATION_NOTES=$(echo "$FEATURE_XML" | xmllint --xpath "string(//implementation_notes)" - 2>/dev/null)
fi

echo "✓ Feature details loaded"
```

---

### 7. Display Selected Feature Summary

```
─────────────────────────────────────────────────────
  SELECTED FEATURE
─────────────────────────────────────────────────────

ID: $SELECTED_FEATURE_ID
Name: $FEATURE_NAME
Category: $FEATURE_CATEGORY
Status: $FEATURE_STATUS (attempt $(($FEATURE_ATTEMPTS + 1)))

Description:
$(echo "$FEATURE_DESCRIPTION" | fold -w 60 -s | sed 's/^/  /')

$(if [[ -n "$FEATURE_REQUIREMENTS" ]]; then
    echo ""
    echo "Requirements:"
    echo "$FEATURE_REQUIREMENTS" | fold -w 60 -s | sed 's/^/  /'
fi)

Verification Criteria:
  Functional: $(if [[ -n "$FUNCTIONAL_CRITERIA" ]]; then echo "✓ Defined"; else echo "⚠️ Not defined"; fi)
  Technical: $(if [[ -n "$TECHNICAL_CRITERIA" ]]; then echo "✓ Defined"; else echo "⚠️ Not defined"; fi)
  Integration: $(if [[ -n "$INTEGRATION_CRITERIA" ]]; then echo "✓ Defined"; else echo "⚠️ Not defined"; fi)

$(if [[ -n "$IMPLEMENTATION_NOTES" ]]; then
    echo ""
    echo "Implementation Notes:"
    echo "$IMPLEMENTATION_NOTES" | fold -w 60 -s | sed 's/^/  /'
fi)

$(if [[ $FEATURE_ATTEMPTS -gt 0 ]]; then
    echo ""
    echo "⚠️  This is a RETRY (previous attempts: $FEATURE_ATTEMPTS)"
    echo "  Using $(if [[ $FEATURE_ATTEMPTS -eq 1 ]]; then echo "simplified"; elif [[ $FEATURE_ATTEMPTS -eq 2 ]]; then echo "minimal"; fi) approach"
fi)

Ready for implementation
```

---

### 8. Store Selection in Memory

**Prepare data for next step:**

```bash
# Export selected feature data for step-09
export SELECTED_FEATURE_ID
export FEATURE_NAME
export FEATURE_CATEGORY
export FEATURE_STATUS
export FEATURE_ATTEMPTS
export FEATURE_DESCRIPTION
export FEATURE_REQUIREMENTS
export FUNCTIONAL_CRITERIA
export TECHNICAL_CRITERIA
export INTEGRATION_CRITERIA
export IMPLEMENTATION_NOTES

echo ""
echo "✓ Feature data prepared for implementation"
```

---

### 9. Proceed to Next Step

**Menu Handling Logic:**
- This step uses **Auto-proceed** (no menu)
- Selected feature stored in memory
- Next step will implement this feature

**Execution:**

```
Proceeding to feature implementation...

→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- Candidate features identified (pending + retry eligible)
- Dependencies validated (only features with satisfied deps selected)
- Priority applied (pending > retry, sequential order)
- Top priority feature selected
- Feature details loaded from app_spec.txt (or feature_list.json fallback)
- Verification criteria extracted
- Feature data stored in memory for step-09
- Ready for implementation

### ❌ FAILURE:
- No actionable features (exit code 33, should not happen)
- Dependency deadlock (all features blocked by unsatisfied deps) (exit code 34)
- Selection failed (exit code 35)

**Master Rule:** Must select valid, actionable feature before proceeding to implementation.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
