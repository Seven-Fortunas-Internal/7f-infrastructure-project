---
name: 'step-08-select-next-feature'
description: 'Select next feature to implement based on priority and dependencies'
nextStepFile: './step-09-implement-feature.md'
featureListFile: '{project_folder}/feature_list.json'
appSpecFile: '{project_folder}/app_spec.txt'
---

# Step 08: Select Next Feature

## STEP GOAL:
Select next actionable feature based on dependencies, retry eligibility, and priority.

---

## EXECUTION RULES:

**See: Universal Rules (Global CLAUDE.md)**

**Role:**
- Feature Selector (automated priority logic)
- Input: feature_list.json (from step-07)
- Output: Selected feature data in memory

**Constraints:**
- 🚫 Never select blocked features
- 🚫 Never ignore dependencies
- 🚫 Never modify feature_list.json (step-09 does this)

---

## CONTEXT BOUNDARIES:
- Available: feature_list.json, app_spec.txt
- Focus: Selection and data loading only
- Next: step-09 implements

---

## MANDATORY SEQUENCE

### 1. Display Selection Start

```
═══════════════════════════════════════════════════════
  SELECTING NEXT FEATURE
  Priority-Based Selection with Dependency Analysis
═══════════════════════════════════════════════════════
```

---

### 2. Build Candidate List

**Actionable features: pending OR (fail AND attempts < 3)**

```bash
FEATURE_LIST_FILE="{featureListFile}"
echo "Building candidate list..."

FEATURE_LIST=$(cat "$FEATURE_LIST_FILE")

# Candidates: pending OR (fail AND attempts < 3)
PENDING=$(echo "$FEATURE_LIST" | jq -r '.features[] | select(.status == "pending") | .id')
RETRY=$(echo "$FEATURE_LIST" | jq -r '.features[] | select(.status == "fail" and .attempts < 3) | .id')

CANDIDATES=()
while IFS= read -r id; do [[ -n "$id" ]] && CANDIDATES+=("$id"); done <<< "$PENDING"
while IFS= read -r id; do [[ -n "$id" ]] && CANDIDATES+=("$id"); done <<< "$RETRY"

echo "  Candidates: ${#CANDIDATES[@]} (Pending: $(echo "$PENDING" | grep -c .), Retry: $(echo "$RETRY" | grep -c .))"

[[ ${#CANDIDATES[@]} -eq 0 ]] && echo "❌ No candidates (step-07 validation failed)" && exit 33
```

---

### 3. Filter by Dependencies

**Only features with all deps satisfied (status=pass)**

```bash
echo "Checking dependencies..."

AVAILABLE=()
for cid in "${CANDIDATES[@]}"; do
    DEPS=$(echo "$FEATURE_LIST" | jq -r --arg id "$cid" '.features[] | select(.id == $id) | .dependencies[]' 2>/dev/null)

    [[ -z "$DEPS" ]] && AVAILABLE+=("$cid") && continue

    ALL_SATISFIED=true
    while IFS= read -r dep; do
        [[ -z "$dep" ]] && continue
        DEP_STATUS=$(echo "$FEATURE_LIST" | jq -r --arg id "$dep" '.features[] | select(.id == $id) | .status')
        [[ "$DEP_STATUS" != "pass" ]] && ALL_SATISFIED=false && break
    done <<< "$DEPS"

    [[ "$ALL_SATISFIED" == "true" ]] && AVAILABLE+=("$cid")
done

echo "  Available: ${#AVAILABLE[@]}"

if [[ ${#AVAILABLE[@]} -eq 0 ]]; then
    echo "⚠️  Dependency deadlock - all features blocked"
    echo "  Solutions: Edit deps manually, review for circular deps, implement blocking features"
    exit 34
fi
```

---

### 4. Prioritize Features

**Priority: Pending > Retry, then by ID (sequential)**

```bash
echo "Applying priority..."

PENDING_AV=()
RETRY_AV=()

for fid in "${AVAILABLE[@]}"; do
    STATUS=$(echo "$FEATURE_LIST" | jq -r --arg id "$fid" '.features[] | select(.id == $id) | .status')
    [[ "$STATUS" == "pending" ]] && PENDING_AV+=("$fid") || RETRY_AV+=("$fid")
done

# Sort by ID
[[ ${#PENDING_AV[@]} -gt 0 ]] && IFS=$'\n' PENDING_AV=($(sort <<<"${PENDING_AV[*]}")) && unset IFS
[[ ${#RETRY_AV[@]} -gt 0 ]] && IFS=$'\n' RETRY_AV=($(sort <<<"${RETRY_AV[*]}")) && unset IFS

PRIORITIZED=()
[[ ${#PENDING_AV[@]} -gt 0 ]] && PRIORITIZED+=("${PENDING_AV[@]}")
[[ ${#RETRY_AV[@]} -gt 0 ]] && PRIORITIZED+=("${RETRY_AV[@]}")

echo "  Prioritized: ${#PRIORITIZED[@]} (Pending: ${#PENDING_AV[@]}, Retry: ${#RETRY_AV[@]})"
```

---

### 5. Select Top Priority

```bash
echo "Selecting feature..."

SELECTED_FEATURE_ID="${PRIORITIZED[0]}"
[[ -z "$SELECTED_FEATURE_ID" ]] && echo "❌ Selection failed" && exit 35

# Load metadata
FEATURE_NAME=$(echo "$FEATURE_LIST" | jq -r --arg id "$SELECTED_FEATURE_ID" '.features[] | select(.id == $id) | .name')
FEATURE_CATEGORY=$(echo "$FEATURE_LIST" | jq -r --arg id "$SELECTED_FEATURE_ID" '.features[] | select(.id == $id) | .category')
FEATURE_STATUS=$(echo "$FEATURE_LIST" | jq -r --arg id "$SELECTED_FEATURE_ID" '.features[] | select(.id == $id) | .status')
FEATURE_ATTEMPTS=$(echo "$FEATURE_LIST" | jq -r --arg id "$SELECTED_FEATURE_ID" '.features[] | select(.id == $id) | .attempts')

echo "✓ Selected: $SELECTED_FEATURE_ID ($FEATURE_NAME)"
echo "  Category: $FEATURE_CATEGORY | Status: $FEATURE_STATUS | Attempts: $FEATURE_ATTEMPTS"
```

---

### 6. Load Feature Details from app_spec.txt

```bash
APP_SPEC_FILE="{appSpecFile}"
echo "Loading details..."

FEATURE_XML=$(xmllint --xpath "//feature[@id='$SELECTED_FEATURE_ID']" "$APP_SPEC_FILE" 2>/dev/null)

if [[ -z "$FEATURE_XML" ]]; then
    echo "⚠️  Not in app_spec.txt, using feature_list.json"
    FEATURE_DESCRIPTION="$FEATURE_NAME"
    FUNCTIONAL_CRITERIA=$(echo "$FEATURE_LIST" | jq -r --arg id "$SELECTED_FEATURE_ID" '.features[] | select(.id == $id) | .verification_criteria.functional // ""')
    TECHNICAL_CRITERIA=$(echo "$FEATURE_LIST" | jq -r --arg id "$SELECTED_FEATURE_ID" '.features[] | select(.id == $id) | .verification_criteria.technical // ""')
    INTEGRATION_CRITERIA=$(echo "$FEATURE_LIST" | jq -r --arg id "$SELECTED_FEATURE_ID" '.features[] | select(.id == $id) | .verification_criteria.integration // ""')
    FEATURE_REQUIREMENTS=""
    IMPLEMENTATION_NOTES=""
else
    FEATURE_DESCRIPTION=$(echo "$FEATURE_XML" | xmllint --xpath "string(//description)" - 2>/dev/null)
    FEATURE_REQUIREMENTS=$(echo "$FEATURE_XML" | xmllint --xpath "string(//requirements)" - 2>/dev/null)
    FUNCTIONAL_CRITERIA=$(echo "$FEATURE_XML" | xmllint --xpath "string(//verification_criteria/functional)" - 2>/dev/null)
    TECHNICAL_CRITERIA=$(echo "$FEATURE_XML" | xmllint --xpath "string(//verification_criteria/technical)" - 2>/dev/null)
    INTEGRATION_CRITERIA=$(echo "$FEATURE_XML" | xmllint --xpath "string(//verification_criteria/integration)" - 2>/dev/null)
    IMPLEMENTATION_NOTES=$(echo "$FEATURE_XML" | xmllint --xpath "string(//implementation_notes)" - 2>/dev/null)
fi

echo "✓ Details loaded"
```

---

### 7. Display Summary

```
─────────────────────────────────────────────────────
  SELECTED FEATURE
─────────────────────────────────────────────────────

ID: $SELECTED_FEATURE_ID
Name: $FEATURE_NAME
Category: $FEATURE_CATEGORY
Status: $FEATURE_STATUS (attempt $(($FEATURE_ATTEMPTS + 1)))

Description: $(echo "$FEATURE_DESCRIPTION" | head -c 120)...

Criteria: Functional [$(if [[ -n "$FUNCTIONAL_CRITERIA" ]]; then echo "✓"; else echo "⚠"; fi)] | Technical [$(if [[ -n "$TECHNICAL_CRITERIA" ]]; then echo "✓"; else echo "⚠"; fi)] | Integration [$(if [[ -n "$INTEGRATION_CRITERIA" ]]; then echo "✓"; else echo "⚠"; fi)]

$(if [[ $FEATURE_ATTEMPTS -gt 0 ]]; then echo "⚠️  RETRY (attempts: $FEATURE_ATTEMPTS)"; fi)

Ready for implementation
```

---

### 8. Store in Memory

```bash
export SELECTED_FEATURE_ID FEATURE_NAME FEATURE_CATEGORY FEATURE_STATUS FEATURE_ATTEMPTS
export FEATURE_DESCRIPTION FEATURE_REQUIREMENTS
export FUNCTIONAL_CRITERIA TECHNICAL_CRITERIA INTEGRATION_CRITERIA IMPLEMENTATION_NOTES

echo "✓ Data prepared for step-09"
```

---

### 9. Auto-Proceed

```
Proceeding to implementation...

→ Load, read entire file, then execute {nextStepFile}
```

---

## SUCCESS/FAILURE:

**✅ Success:** Feature selected, details loaded, memory exported
**❌ Failure:** No candidates (33), deadlock (34), selection failed (35)

---

**Version:** 1.0.0 | **Created:** 2026-02-17 | **Status:** Refactored
