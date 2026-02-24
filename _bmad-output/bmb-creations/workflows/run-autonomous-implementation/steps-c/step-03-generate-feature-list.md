---
name: 'step-03-generate-feature-list'
description: 'Generate feature_list.json from parsed app_spec.txt data'
nextStepFile: './step-04-setup-tracking.md'
outputFile: '{project_folder}/feature_list.json'
templateFile: '{workflow_path}/templates/feature-list-template.json'
---

# Step 03: Generate feature_list.json

## STEP GOAL:
Create feature_list.json from parsed app_spec.txt data with all features initialized to "pending" status.

---

## MANDATORY EXECUTION RULES:

**Apply universal rules:** @~/.claude/CLAUDE.md (workflow protocols, file operations)

**Role:** JSON Generator (automated)
**User brings:** Parsed feature arrays from step-02
**You bring:** JSON transformation, validation

**Forbidden:** Skipping features, modifying statuses from "pending"

---

## CONTEXT BOUNDARIES:
- **Input:** Parsed arrays from step-02 (FEATURE_IDS, FEATURE_NAMES, etc.)
- **Output:** {outputFile}
- **Scope:** JSON generation only (no implementation)

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder.**

---

### 1. Display Start

```
═══════════════════════════════════════════════════════
  GENERATING FEATURE_LIST.JSON
  Creating Implementation Tracking Structure
═══════════════════════════════════════════════════════
```

---

### 2. Build Metadata

```bash
echo "Building metadata..."
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

```bash
echo "Building features array ($FEATURE_COUNT features)..."
FEATURES_JSON="["

for ((i=0; i<FEATURE_COUNT; i++)); do
    # Extract data
    FEATURE_ID="${FEATURE_IDS[$i]}"
    FEATURE_NAME="${FEATURE_NAMES[$i]}"
    FEATURE_CATEGORY="${FEATURE_CATEGORIES[$i]}"
    FUNCTIONAL="${FEATURE_FUNCTIONAL_CRITERIA[$i]}"
    TECHNICAL="${FEATURE_TECHNICAL_CRITERIA[$i]}"
    INTEGRATION="${FEATURE_INTEGRATION_CRITERIA[$i]}"
    DEPS="${FEATURE_DEPENDENCIES[$i]}"

    # JSON-escape strings
    NAME_ESC=$(echo "$FEATURE_NAME" | jq -Rs .)
    FUNC_ESC=$(echo "$FUNCTIONAL" | jq -Rs .)
    TECH_ESC=$(echo "$TECHNICAL" | jq -Rs .)
    INTEG_ESC=$(echo "$INTEGRATION" | jq -Rs .)

    # Build dependencies array
    if [[ -n "$DEPS" ]]; then
        DEPS_ARRAY="["
        IFS=',' read -ra DEP_ARRAY <<< "$DEPS"
        for dep in "${DEP_ARRAY[@]}"; do
            dep=$(echo "$dep" | xargs)
            [[ -n "$dep" ]] && DEPS_ARRAY+="\"$dep\","
        done
        DEPS_ARRAY="${DEPS_ARRAY%,}]"
    else
        DEPS_ARRAY="[]"
    fi

    # Build feature object
    FEATURES_JSON+=$(cat <<EOF
    {
      "id": "$FEATURE_ID",
      "name": $NAME_ESC,
      "category": "$FEATURE_CATEGORY",
      "status": "pending",
      "attempts": 0,
      "verification_results": {"functional": null, "technical": null, "integration": null},
      "verification_criteria": {"functional": $FUNC_ESC, "technical": $TECH_ESC, "integration": $INTEG_ESC},
      "dependencies": $DEPS_ARRAY,
      "implementation_notes": "",
      "blocked_reason": "",
      "last_updated": null,
      "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    }
EOF
)

    [[ $i -lt $((FEATURE_COUNT - 1)) ]] && FEATURES_JSON+=","
    [[ $(( (i + 1) % 10 )) -eq 0 ]] && echo "  $((i + 1))/$FEATURE_COUNT processed..."
done

FEATURES_JSON+="]"
echo "✓ Features array built"
```

---

### 4. Assemble & Validate

```bash
echo "Assembling JSON..."
COMPLETE_JSON=$(cat <<EOF
{"metadata": $METADATA_JSON, "features": $FEATURES_JSON}
EOF
)

echo "Validating syntax..."
if echo "$COMPLETE_JSON" | jq empty 2>/dev/null; then
    echo "✓ JSON valid"
else
    echo "❌ ERROR: Invalid JSON (workflow bug)"
    echo "$COMPLETE_JSON" | head -20
    exit 20
fi
```

---

### 5. Save & Verify

```bash
OUTPUT_FILE="{outputFile}"
echo "Saving to: $OUTPUT_FILE"

# Backup if exists
[[ -f "$OUTPUT_FILE" ]] && cp "$OUTPUT_FILE" "${OUTPUT_FILE}.backup.$(date +%s)"

# Write file
echo "$COMPLETE_JSON" > "$OUTPUT_FILE" || { echo "❌ Write failed"; exit 21; }

# Verify
[[ ! -f "$OUTPUT_FILE" ]] && { echo "❌ File not created"; exit 22; }
jq empty "$OUTPUT_FILE" 2>/dev/null || { echo "❌ Invalid JSON in file"; exit 23; }

SAVED_COUNT=$(jq '.features | length' "$OUTPUT_FILE")
[[ "$SAVED_COUNT" != "$FEATURE_COUNT" ]] && { echo "❌ Count mismatch: $SAVED_COUNT != $FEATURE_COUNT"; exit 24; }

echo "✓ File verified ($SAVED_COUNT features)"
```

---

### 6. Display Summary

```
─────────────────────────────────────────────────────
  FEATURE_LIST.JSON GENERATED
─────────────────────────────────────────────────────

File: $OUTPUT_FILE
Size: $(du -h "$OUTPUT_FILE" | cut -f1)
Features: $FEATURE_COUNT (all "pending")

Categories:
$(jq -r '.features | group_by(.category) | .[] | "\(.length) in \(.[0].category)"' "$OUTPUT_FILE")

Dependencies: $(jq -r '.features | map(select(.dependencies | length > 0)) | length' "$OUTPUT_FILE") features

Ready for tracking setup
```

---

### 7. Auto-Proceed

```
Proceeding to setup tracking files...

→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

**SUCCESS:**
- JSON valid (jq parse success)
- File saved to {outputFile}
- Feature count matches parsed data
- All features "pending", attempts=0, verification_results=null

**FAILURE:**
- Exit 20: Invalid JSON syntax
- Exit 21: File write failed
- Exit 22: File not found after write
- Exit 23: Saved file invalid JSON
- Exit 24: Feature count mismatch

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
