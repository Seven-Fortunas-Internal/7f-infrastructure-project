---
name: 'step-09-implement-feature'
description: 'Implement selected feature using bounded retry strategy'
nextStepFile: './step-10-test-feature.md'
featureListFile: '{project_folder}/feature_list.json'
buildLogFile: '{project_folder}/autonomous_build_log.md'
advancedElicitationTask: '{workflow_path}/../../../cis/advanced-elicitation/workflow.xml'
partyModeWorkflow: '{workflow_path}/../../../cis/party-mode/workflow.md'
---

# Step 09: Implement Feature

## GOAL: Implement selected feature using bounded retry (standard → simplified → minimal)

## RULES: See BMAD Core (never generate without input, read complete step, facilitate)
**Role:** Feature Implementer | **User brings:** Selected feature from step-08

## CONTEXT: Selected feature, app_spec.txt, project files | Does NOT test (step-10) or commit (step-12)

---

## MANDATORY SEQUENCE

### 1-2. Start, Determine Approach, Display Requirements, Mark In Progress

```bash
FEATURE_LIST_FILE="{featureListFile}"
BUILD_LOG_FILE="{buildLogFile}"

echo "═══════════════════════════════════════════════════════"
echo "  IMPLEMENTING: $SELECTED_FEATURE_ID - $FEATURE_NAME"
echo "  Category: $FEATURE_CATEGORY | Attempt: $(($FEATURE_ATTEMPTS + 1))/3"
echo "═══════════════════════════════════════════════════════"

# Determine approach
case $FEATURE_ATTEMPTS in
    0) APPROACH="STANDARD"; GUIDANCE="Full implementation | 5-10min | All requirements+criteria";;
    1) APPROACH="SIMPLIFIED"; GUIDANCE="Core only | 3-5min | Skip optional | ⚠️ Attempt 2";;
    2) APPROACH="MINIMAL"; GUIDANCE="Bare essentials | 1-2min | Placeholders OK | ⚠️ Attempt 3";;
    *) echo "❌ ERROR: Feature has $FEATURE_ATTEMPTS attempts (should be blocked)"; exit 36;;
esac
echo "  Strategy: $APPROACH ($GUIDANCE)"

# Display requirements
echo -e "\n─────────────────────────────────────────────────────"
echo "  REQUIREMENTS"
echo "─────────────────────────────────────────────────────"
echo "$FEATURE_DESCRIPTION"
[[ -n "$FEATURE_REQUIREMENTS" ]] && echo -e "\nDetailed:\n$FEATURE_REQUIREMENTS"
[[ -n "$IMPLEMENTATION_NOTES" ]] && echo -e "\nNotes:\n$IMPLEMENTATION_NOTES"
echo -e "\nVerification:"
[[ -n "$FUNCTIONAL_CRITERIA" ]] && echo "  ✓ Functional: $FUNCTIONAL_CRITERIA"
[[ -n "$TECHNICAL_CRITERIA" ]] && echo "  ✓ Technical: $TECHNICAL_CRITERIA"
[[ -n "$INTEGRATION_CRITERIA" ]] && echo "  ✓ Integration: $INTEGRATION_CRITERIA"

# Mark in progress
echo -e "\nMarking in_progress..."
cp "$FEATURE_LIST_FILE" "${FEATURE_LIST_FILE}.backup"
jq --arg id "$SELECTED_FEATURE_ID" '(.features[] | select(.id == $id)) |= .status = "in_progress"' \
   "$FEATURE_LIST_FILE" > "${FEATURE_LIST_FILE}.tmp"
if jq empty "${FEATURE_LIST_FILE}.tmp" 2>/dev/null; then
    mv "${FEATURE_LIST_FILE}.tmp" "$FEATURE_LIST_FILE" && rm -f "${FEATURE_LIST_FILE}.backup"
    echo "✓ Status updated"
else
    echo "❌ Failed to update status"; mv "${FEATURE_LIST_FILE}.backup" "$FEATURE_LIST_FILE"; exit 37
fi
```

---

### 3-4. Execute Implementation, Log, Display Summary

```bash
echo -e "\n─────────────────────────────────────────────────────"
echo "  EXECUTING IMPLEMENTATION"
echo "─────────────────────────────────────────────────────"

# Log start
cat >> "$BUILD_LOG_FILE" <<EOF

### $SELECTED_FEATURE_ID: $FEATURE_NAME
**Started:** $(date -u +%Y-%m-%d %H:%M:%S) | **Approach:** $APPROACH (attempt $(($FEATURE_ATTEMPTS + 1))) | **Category:** $FEATURE_CATEGORY

#### Implementation Actions:
1. **Analyzed requirements** - Feature: $FEATURE_CATEGORY | Approach: $APPROACH | Attempt: $(($FEATURE_ATTEMPTS + 1))
2. **Implementation executed** - (Details logged by autonomous agent during execution)
EOF

# Display approach guidance
case "$APPROACH" in
    STANDARD) echo "STANDARD: Full functionality | All settings | All integrations | All 3 verification criteria";;
    SIMPLIFIED) echo "SIMPLIFIED: Core only | Skip optional configs | Alternative tools OK | Focus functional criteria";;
    MINIMAL) echo "MINIMAL: Bare essentials | Placeholders OK | TODO comments acceptable | Document limitations";;
esac

echo -e "\nStarting implementation...\n"

# ==============================================================
# IMPLEMENTATION SECTION
# ==============================================================
# Autonomous agent executes based on:
# - app_spec.txt requirements | Approach (STANDARD/SIMPLIFIED/MINIMAL) | Category
# Tools: Bash (gh, git, mkdir, cat), File ops (Write, Edit, Read), Web (docs)
# ==============================================================

echo "Implementation executed by autonomous agent..."

# Log completion
cat >> "$BUILD_LOG_FILE" <<EOF
3. **Implementation completed** - Approach: $APPROACH | Status: Ready for verification | Next: Testing criteria
**Completed:** $(date -u +%Y-%m-%d %H:%M:%S)

EOF

echo -e "\n─────────────────────────────────────────────────────"
echo "  IMPLEMENTATION COMPLETE"
echo "─────────────────────────────────────────────────────"
echo "Feature: $SELECTED_FEATURE_ID - $FEATURE_NAME"
echo "Approach: $APPROACH | Attempt: $(($FEATURE_ATTEMPTS + 1))/3"
echo "Actions: Logged in autonomous_build_log.md"
echo "Status: Ready for verification testing"
echo "Next: Test verification criteria"
```

---

### 5. Auto-Proceed to Verification

**AUTONOMOUS:** No user interaction - proceed directly to testing

```bash
echo ""
echo "Proceeding to verification testing..."
echo ""
```

**Auto-proceed to next step:**
```
→ Load, read entire file, then execute {nextStepFile}
```

---

## SUCCESS/FAILURE:

**✅ SUCCESS:** Approach determined | Requirements displayed | Status=in_progress | Implementation executed | Logged | Summary displayed | Menu presented | User selects | If C: Ready for step-10

**❌ FAILURE:** ≥3 attempts (exit 36) | Failed status update (exit 37)

**Master Rule:** Implementation must execute before verification.

---

**Version:** 1.0.0-refactored | **Created:** 2026-02-17 | **Status:** Complete (ONLY interactive step in Coding loop)
