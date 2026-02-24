---
name: 'step-01-init'
description: 'Initialize workflow and detect session type (Initializer vs Coding Agent)'
continueFile: './step-01b-continue.md'
nextStepFile: './step-02-parse-app-spec.md'
outputFile: '{project_folder}/feature_list.json'
appSpecFile: '{project_folder}/app_spec.txt'
claudeMdFile: '{project_folder}/CLAUDE.md'
---

# Step 01: Initialize Workflow and Detect Session Type

## STEP GOAL:
Detect whether this is Session 1 (Initializer mode) or Session 2+ (Coding Agent mode) by checking for existing feature_list.json, validate prerequisites, and route to appropriate path.

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: Autonomous Implementation Orchestrator (Session Detection)
- ✅ Collaborative dialogue: Minimal (fully automated detection)
- ✅ You bring: Session detection logic, environment validation
- ✅ User brings: Project directory, app_spec.txt, prerequisites

### Step-Specific:
- 🎯 Focus: Detect session type and validate prerequisites
- 🚫 Forbidden: Skipping validation checks, proceeding without valid app_spec.txt
- 💬 Approach: Automated checks with clear status messages

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 This step does NOT save/update output file (routing only)
- 📖 Load continuation or next step based on detection

---

## CONTEXT BOUNDARIES:
- Available: Project folder path, app_spec.txt path, git/gh CLI
- Focus: Session type detection, prerequisite validation
- Limits: Does not implement features or modify state
- Dependencies: Requires app_spec.txt, git, GitHub CLI

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Session Detection Start

```
═══════════════════════════════════════════════════════
  AUTONOMOUS IMPLEMENTATION WORKFLOW
  Session Detection & Initialization
═══════════════════════════════════════════════════════
```

---

### 2. Check for Existing Workflow State

**CRITICAL:** Determine if this is Session 1 (Initializer) or Session 2+ (Coding Agent)

**Detection logic:**

```bash
PROJECT_FOLDER="{project_folder}"
FEATURE_LIST="${PROJECT_FOLDER}/feature_list.json"

# Check if feature_list.json exists
if [[ -f "$FEATURE_LIST" ]]; then
    # File exists - verify it's valid
    if jq empty "$FEATURE_LIST" 2>/dev/null; then
        # Valid JSON - check if it has features
        FEATURE_COUNT=$(jq '.features | length' "$FEATURE_LIST" 2>/dev/null)

        if [[ $FEATURE_COUNT -gt 0 ]]; then
            # Valid existing workflow detected
            SESSION_TYPE="CODING"
            echo "🔄 EXISTING WORKFLOW DETECTED"
            echo ""
            echo "   Session Type: Coding Agent (Session 2+)"
            echo "   Features: $FEATURE_COUNT"
            echo "   Status: Continuing implementation"
            echo ""
            echo "Loading continuation..."
            echo ""

            # Load continuation step immediately
            # This prevents falling through to Initializer mode
            load_and_execute "{continueFile}"
            exit 0
        fi
    else
        # File exists but is corrupted
        echo "⚠️  WARNING: feature_list.json exists but is corrupted"
        echo ""
        echo "   File: $FEATURE_LIST"
        echo "   Issue: Invalid JSON syntax"
        echo ""
        echo "Options:"
        echo "  [R] Restore from git history (if available)"
        echo "  [F] Start fresh (delete corrupted file and regenerate)"
        echo "  [X] Exit workflow (manual investigation)"
        echo ""
        read -p "Your choice: " CORRUPT_CHOICE

        case $CORRUPT_CHOICE in
            R|r)
                echo "Attempting to restore from git..."
                if git log --all --full-history -- "$FEATURE_LIST" &>/dev/null; then
                    echo ""
                    echo "Available versions:"
                    git log --oneline --all --full-history -- "$FEATURE_LIST" | head -5
                    echo ""
                    read -p "Enter commit hash to restore (or 'X' to cancel): " COMMIT_HASH
                    if [[ "$COMMIT_HASH" != "X" && "$COMMIT_HASH" != "x" ]]; then
                        git checkout "$COMMIT_HASH" -- "$FEATURE_LIST"
                        echo "✓ Restored feature_list.json from $COMMIT_HASH"
                        echo "Restarting session detection..."
                        # Re-run detection (recursive call to this step)
                        load_and_execute "./step-01-init.md"
                        exit 0
                    fi
                fi
                echo "Restore failed. Exiting."
                exit 10
                ;;
            F|f)
                echo "Deleting corrupted file..."
                rm -f "$FEATURE_LIST"
                echo "✓ Deleted. Starting fresh as Initializer mode."
                echo ""
                # Fall through to Initializer mode
                ;;
            *)
                echo "Exiting for manual investigation."
                exit 10
                ;;
        esac
    fi
fi

# No valid workflow found - this is Session 1 (Initializer)
SESSION_TYPE="INITIALIZER"
echo "✨ NEW WORKFLOW DETECTED"
echo ""
echo "   Session Type: Initializer (Session 1)"
echo "   Purpose: Parse app_spec.txt and set up tracking"
echo "   Next: Parse app_spec.txt → generate feature_list.json"
echo ""
```

**Key behaviors:**
- If valid feature_list.json exists → Load continuation step immediately, exit
- If corrupted → Offer recovery options
- If missing → Continue to Initializer mode

---

### 3. Validate Prerequisites (Initializer Mode Only)

**Only execute if SESSION_TYPE="INITIALIZER":**

#### 3.1 Verify app_spec.txt exists

```bash
APP_SPEC_FILE="{appSpecFile}"

if [[ ! -f "$APP_SPEC_FILE" ]]; then
    echo "❌ CRITICAL ERROR: app_spec.txt not found"
    echo ""
    echo "   Required: $APP_SPEC_FILE"
    echo ""
    echo "   Create it first using:"
    echo "   /bmad-bmm-create-app-spec"
    echo ""
    echo "   Then validate with:"
    echo "   /bmad-bmm-check-autonomous-implementation-readiness"
    echo ""
    echo "Exiting workflow (error code 1)"
    exit 1
fi

echo "✓ app_spec.txt found"
```

---

#### 3.2 Validate XML structure

```bash
if ! command -v xmllint &>/dev/null; then
    echo "⚠️  Warning: xmllint not found, skipping XML validation"
else
    if ! xmllint --noout "$APP_SPEC_FILE" 2>/dev/null; then
        echo "❌ CRITICAL ERROR: Invalid XML syntax in app_spec.txt"
        echo ""
        echo "   File: $APP_SPEC_FILE"
        echo ""
        echo "   Validate and fix with:"
        echo "   /bmad-bmm-check-autonomous-implementation-readiness"
        echo ""
        echo "   Or regenerate with:"
        echo "   /bmad-bmm-create-app-spec"
        echo ""
        echo "Exiting workflow (error code 2)"
        exit 2
    fi
    echo "✓ app_spec.txt is valid XML"
fi
```

---

#### 3.3 Check for features

```bash
FEATURE_COUNT=$(grep -c '<feature' "$APP_SPEC_FILE" 2>/dev/null || echo "0")

if [[ "$FEATURE_COUNT" -eq 0 ]]; then
    echo "❌ CRITICAL ERROR: No features found in app_spec.txt"
    echo ""
    echo "   File: $APP_SPEC_FILE"
    echo "   Features found: 0"
    echo ""
    echo "   Regenerate with:"
    echo "   /bmad-bmm-create-app-spec"
    echo ""
    echo "Exiting workflow (error code 3)"
    exit 3
fi

echo "✓ Found $FEATURE_COUNT features in app_spec.txt"
```

---

#### 3.4 Verify Git is installed

```bash
if ! command -v git &>/dev/null; then
    echo "❌ CRITICAL ERROR: git not found"
    echo ""
    echo "   Git is required for autonomous implementation."
    echo "   Install from: https://git-scm.com/downloads"
    echo ""
    echo "Exiting workflow (error code 4)"
    exit 4
fi

echo "✓ Git is installed"
```

---

#### 3.5 Verify GitHub CLI is installed

```bash
if ! command -v gh &>/dev/null; then
    echo "❌ CRITICAL ERROR: GitHub CLI not found"
    echo ""
    echo "   GitHub CLI is required for repository operations."
    echo "   Install from: https://cli.github.com/"
    echo ""
    echo "Exiting workflow (error code 5)"
    exit 5
fi

echo "✓ GitHub CLI is installed"
```

---

#### 3.6 Verify GitHub CLI is authenticated

```bash
if ! gh auth status 2>&1 | grep -q "Logged in"; then
    echo "❌ CRITICAL ERROR: GitHub CLI not authenticated"
    echo ""
    echo "   Authenticate with:"
    echo "   gh auth login"
    echo ""
    echo "   Then verify with:"
    echo "   gh auth status"
    echo ""
    echo "Exiting workflow (error code 6)"
    exit 6
fi

echo "✓ GitHub CLI is authenticated"
```

---

#### 3.7 Check for CLAUDE.md (optional but recommended)

```bash
CLAUDE_MD_FILE="{claudeMdFile}"

if [[ -f "$CLAUDE_MD_FILE" ]]; then
    echo "✓ CLAUDE.md found (agent instructions available)"
else
    echo "⚠️  Warning: CLAUDE.md not found (recommended but not required)"
    echo "   Consider creating project-specific agent instructions"
fi
```

---

### 4. Display Prerequisites Summary

```
─────────────────────────────────────────────────────
  PREREQUISITES CHECK COMPLETE
─────────────────────────────────────────────────────

Session Type: $SESSION_TYPE

Prerequisites:
✓ app_spec.txt exists ($FEATURE_COUNT features)
✓ Valid XML structure
✓ Git installed
✓ GitHub CLI installed and authenticated
$(if [[ -f "$CLAUDE_MD_FILE" ]]; then echo "✓ CLAUDE.md available"; else echo "⚠ CLAUDE.md missing (optional)"; fi)

Ready to proceed to Initializer mode.
```

---

### 5. Proceed to Next Step

**Menu Handling Logic:**
- This step uses **Auto-proceed** (no menu)
- After validation completes, automatically load next step

**Execution:**

```
Proceeding to parse app_spec.txt...

→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- Session type detected (Initializer or Coding)
- If Coding: Continuation step loaded successfully
- If Initializer: All prerequisites validated, ready to parse app_spec.txt

### ❌ FAILURE:
- app_spec.txt missing or invalid (exit code 1-3)
- Git or GitHub CLI missing/not authenticated (exit code 4-6)
- Corrupted state with no recovery option (exit code 10)

**Master Rule:** Skipping validation checks FORBIDDEN.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
