---
name: 'step-03-generate-feature-list'
description: 'Generate feature_list.json from parsed app_spec.txt data'
nextStepFile: './step-04-setup-tracking.md'
outputFile: '{project_folder}/feature_list.json'
templateFile: '{workflow_path}/templates/feature-list-template.json'
---

# Step 03: Generate feature_list.json

## STEP GOAL:
Create feature_list.json from parsed app_spec.txt data with all features initialized to "pending" status, ready for autonomous implementation.

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: JSON Generator (structured tracking file creator)
- ✅ Collaborative dialogue: None (automated generation)
- ✅ You bring: JSON structure generation, data transformation
- ✅ User brings: Parsed feature data from step-02

### Step-Specific:
- 🎯 Focus: Generate valid, complete feature_list.json
- 🚫 Forbidden: Skipping features, modifying statuses from "pending"
- 💬 Approach: Systematic JSON construction with validation

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Create and save {outputFile}
- 📖 Use template structure from {templateFile} if available

---

## CONTEXT BOUNDARIES:
- Available: Parsed feature data from step-02 (arrays in memory)
- Focus: JSON file generation
- Limits: Does not implement features (only creates tracking structure)
- Dependencies: Requires parsed data from step-02

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Generation Start

```
═══════════════════════════════════════════════════════
  GENERATING FEATURE_LIST.JSON
  Creating Implementation Tracking Structure
═══════════════════════════════════════════════════════
```

---

### 2. Prepare Metadata Section

**Create metadata object:**

```bash
echo "Building metadata..."

# Use data from step-02
METADATA_JSON=$(cat <<EOF
{
  "project_name": "$PROJECT_NAME",
  "generated_from": "$GENERATED_FROM",
  "generated_date": "$(date -u +%Y-%m-%d)",
  "total_features": $FEATURE_COUNT,
  "autonomous_agent_ready": true,
  "workflow_version": "1.0.0",
  "created_by": "run-autonomous-implementation workflow"
}
EOF
)

echo "✓ Metadata prepared"
```

---

### 3. Build Features Array

**Transform parsed data into JSON array:**

```bash
echo ""
echo "Building features array..."
echo "  Processing $FEATURE_COUNT features..."

# Start building features array
FEATURES_JSON="["

for ((i=0; i<FEATURE_COUNT; i++)); do
    FEATURE_ID="${FEATURE_IDS[$i]}"
    FEATURE_NAME="${FEATURE_NAMES[$i]}"
    FEATURE_CATEGORY="${FEATURE_CATEGORIES[$i]}"
    FUNCTIONAL_CRITERIA="${FEATURE_FUNCTIONAL_CRITERIA[$i]}"
    TECHNICAL_CRITERIA="${FEATURE_TECHNICAL_CRITERIA[$i]}"
    INTEGRATION_CRITERIA="${FEATURE_INTEGRATION_CRITERIA[$i]}"
    DEPENDENCIES="${FEATURE_DEPENDENCIES[$i]}"

    # Escape special characters for JSON
    FEATURE_NAME_ESCAPED=$(echo "$FEATURE_NAME" | jq -Rs .)
    FUNCTIONAL_ESCAPED=$(echo "$FUNCTIONAL_CRITERIA" | jq -Rs .)
    TECHNICAL_ESCAPED=$(echo "$TECHNICAL_CRITERIA" | jq -Rs .)
    INTEGRATION_ESCAPED=$(echo "$INTEGRATION_CRITERIA" | jq -Rs .)

    # Build dependencies array
    if [[ -n "$DEPENDENCIES" ]]; then
        # Split comma-separated dependencies into JSON array
        DEPS_ARRAY="["
        IFS=',' read -ra DEP_ARRAY <<< "$DEPENDENCIES"
        for dep in "${DEP_ARRAY[@]}"; do
            dep_trimmed=$(echo "$dep" | xargs) # trim whitespace
            if [[ -n "$dep_trimmed" ]]; then
                DEPS_ARRAY+="\"$dep_trimmed\","
            fi
        done
        # Remove trailing comma and close array
        DEPS_ARRAY="${DEPS_ARRAY%,}]"
    else
        DEPS_ARRAY="[]"
    fi

    # Build feature object
    FEATURE_OBJ=$(cat <<EOF
    {
      "id": "$FEATURE_ID",
      "name": $FEATURE_NAME_ESCAPED,
      "category": "$FEATURE_CATEGORY",
      "status": "pending",
      "attempts": 0,
      "verification_results": {
        "functional": null,
        "technical": null,
        "integration": null
      },
      "verification_criteria": {
        "functional": $FUNCTIONAL_ESCAPED,
        "technical": $TECHNICAL_ESCAPED,
        "integration": $INTEGRATION_ESCAPED
      },
      "dependencies": $DEPS_ARRAY,
      "implementation_notes": "",
      "blocked_reason": "",
      "last_updated": null,
      "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    }
EOF
)

    # Add to features array
    FEATURES_JSON+="$FEATURE_OBJ"

    # Add comma if not last element
    if [[ $i -lt $((FEATURE_COUNT - 1)) ]]; then
        FEATURES_JSON+=","
    fi

    # Progress indicator
    if [[ $(( (i + 1) % 10 )) -eq 0 ]]; then
        echo "    Processed $((i + 1))/$FEATURE_COUNT features..."
    fi
done

# Close features array
FEATURES_JSON+="]"

echo "✓ Features array built ($FEATURE_COUNT features)"
```

---

### 4. Combine into Complete JSON

**Assemble final feature_list.json structure:**

```bash
echo ""
echo "Assembling complete JSON structure..."

COMPLETE_JSON=$(cat <<EOF
{
  "metadata": $METADATA_JSON,
  "features": $FEATURES_JSON
}
EOF
)

echo "✓ JSON structure assembled"
```

---

### 5. Validate JSON Syntax

**Ensure generated JSON is valid before saving:**

```bash
echo ""
echo "Validating JSON syntax..."

# Test if JSON is valid
if echo "$COMPLETE_JSON" | jq empty 2>/dev/null; then
    echo "✓ JSON is valid"
else
    echo "❌ ERROR: Generated JSON is invalid"
    echo ""
    echo "   This is a workflow bug. JSON generation failed."
    echo "   Please report this issue."
    echo ""
    # Display first 20 lines for debugging
    echo "Generated JSON (first 20 lines):"
    echo "$COMPLETE_JSON" | head -20
    echo ""
    exit 20
fi
```

---

### 6. Save to File

**Write feature_list.json to disk:**

```bash
OUTPUT_FILE="{outputFile}"

echo ""
echo "Saving to: $OUTPUT_FILE"

# Create backup if file exists (shouldn't happen in Initializer mode)
if [[ -f "$OUTPUT_FILE" ]]; then
    BACKUP_FILE="${OUTPUT_FILE}.backup.$(date +%s)"
    cp "$OUTPUT_FILE" "$BACKUP_FILE"
    echo "  ⚠️  Existing file backed up to: $BACKUP_FILE"
fi

# Write JSON to file
echo "$COMPLETE_JSON" > "$OUTPUT_FILE"

if [[ $? -eq 0 ]]; then
    echo "✓ File saved successfully"
else
    echo "❌ ERROR: Failed to write file"
    echo "   Check file permissions and disk space"
    exit 21
fi
```

---

### 7. Verify Saved File

**Read back and validate saved file:**

```bash
echo ""
echo "Verifying saved file..."

# Check file exists
if [[ ! -f "$OUTPUT_FILE" ]]; then
    echo "❌ ERROR: File was not created"
    exit 22
fi

# Check file is valid JSON
if ! jq empty "$OUTPUT_FILE" 2>/dev/null; then
    echo "❌ ERROR: Saved file contains invalid JSON"
    exit 23
fi

# Check feature count matches
SAVED_COUNT=$(jq '.features | length' "$OUTPUT_FILE")
if [[ "$SAVED_COUNT" != "$FEATURE_COUNT" ]]; then
    echo "❌ ERROR: Feature count mismatch"
    echo "   Expected: $FEATURE_COUNT"
    echo "   Saved: $SAVED_COUNT"
    exit 24
fi

echo "✓ File verified ($SAVED_COUNT features)"
```

---

### 8. Display Generation Summary

```
─────────────────────────────────────────────────────
  FEATURE_LIST.JSON GENERATED
─────────────────────────────────────────────────────

File: $OUTPUT_FILE
Size: $(du -h "$OUTPUT_FILE" | cut -f1)
Features: $FEATURE_COUNT

Status Initialization:
  - All features: pending
  - Attempts: 0
  - Verification results: null
  - Blocked reason: (empty)

Features by Category:
$(jq -r '.features | group_by(.category) | .[] | "\(.length) features in \(.[0].category)"' "$OUTPUT_FILE")

Features with Dependencies:
$(jq -r '.features | map(select(.dependencies | length > 0)) | length' "$OUTPUT_FILE") features have dependencies

Ready for tracking setup
```

---

### 9. Proceed to Next Step

**Menu Handling Logic:**
- This step uses **Auto-proceed** (no menu)
- feature_list.json is now created
- Next step will create additional tracking files

**Execution:**

```
Proceeding to setup tracking files...

→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- JSON structure assembled correctly
- JSON syntax validated (jq parse successful)
- File saved to {outputFile}
- Saved file verified (exists, valid JSON, correct feature count)
- All features initialized to "pending" status
- Verification results set to null
- Dependencies array populated
- Ready for step-04 (tracking setup)

### ❌ FAILURE:
- JSON generation produced invalid syntax (exit code 20)
- File write failed (permissions or disk space) (exit code 21)
- Saved file not found after write (exit code 22)
- Saved file contains invalid JSON (exit code 23)
- Feature count mismatch (exit code 24)

**Master Rule:** feature_list.json must be valid, complete, and match parsed data.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
