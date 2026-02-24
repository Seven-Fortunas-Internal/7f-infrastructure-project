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
Detect Session 1 (Initializer) or Session 2+ (Coding Agent) by checking feature_list.json, validate prerequisites, and route accordingly.

---

## MANDATORY EXECUTION RULES:

**Reference:** Universal rules (never generate without input, read complete step, facilitator not generator)

**Role:** Autonomous Implementation Orchestrator (Session Detection)
- Minimal dialogue: Fully automated detection
- Agent brings: Session detection logic, environment validation
- User brings: Project directory, app_spec.txt, prerequisites

**Step-Specific:**
- Focus: Session detection + validation
- Forbidden: Skipping checks, proceeding without valid app_spec.txt

---

## EXECUTION PROTOCOLS:
- Follow MANDATORY SEQUENCE exactly
- This step: routing only (no state modification)
- Load continuation or next step based on detection

---

## MANDATORY SEQUENCE

### 1. Display Session Detection Start

```
═══════════════════════════════════════════════════════
  AUTONOMOUS IMPLEMENTATION WORKFLOW
  Session Detection & Initialization
═══════════════════════════════════════════════════════
```

---

### 2. Detect Session Type

**Logic:** Check feature_list.json existence and validity

```bash
PROJECT_FOLDER="{project_folder}"
FEATURE_LIST="${PROJECT_FOLDER}/feature_list.json"

if [[ -f "$FEATURE_LIST" ]] && jq empty "$FEATURE_LIST" 2>/dev/null; then
    FEATURE_COUNT=$(jq '.features | length' "$FEATURE_LIST" 2>/dev/null)

    if [[ $FEATURE_COUNT -gt 0 ]]; then
        echo "🔄 EXISTING WORKFLOW DETECTED"
        echo "   Session: Coding Agent (2+) | Features: $FEATURE_COUNT"
        echo ""
        echo "Loading continuation..."
        load_and_execute "{continueFile}"
        exit 0
    fi
fi

# Handle corrupted JSON
if [[ -f "$FEATURE_LIST" ]]; then
    echo "⚠️  Corrupted feature_list.json detected"
    echo "[R] Restore from git | [F] Start fresh | [X] Exit"
    read -p "Choice: " CHOICE

    case $CHOICE in
        R|r)
            git log --oneline --all --full-history -- "$FEATURE_LIST" | head -5
            read -p "Commit hash (or X): " HASH
            if [[ "$HASH" != [Xx] ]]; then
                git checkout "$HASH" -- "$FEATURE_LIST"
                load_and_execute "./step-01-init.md"
                exit 0
            fi
            ;;
        F|f)
            rm -f "$FEATURE_LIST"
            echo "✓ Deleted. Starting fresh."
            ;;
        *)
            exit 10
            ;;
    esac
fi

# New workflow
echo "✨ NEW WORKFLOW | Session: Initializer (1)"
echo "   Next: Parse app_spec.txt → generate feature_list.json"
echo ""
```

---

### 3. Validate Prerequisites (Initializer Only)

**Only if no valid feature_list.json found**

#### 3.1 Verify app_spec.txt

```bash
APP_SPEC="{appSpecFile}"

if [[ ! -f "$APP_SPEC" ]]; then
    echo "❌ app_spec.txt not found: $APP_SPEC"
    echo "   Create: /bmad-bmm-create-app-spec"
    echo "   Validate: /bmad-bmm-check-autonomous-implementation-readiness"
    exit 1
fi
echo "✓ app_spec.txt found"
```

#### 3.2 Validate XML structure

```bash
if command -v xmllint &>/dev/null; then
    if ! xmllint --noout "$APP_SPEC" 2>/dev/null; then
        echo "❌ Invalid XML in app_spec.txt"
        echo "   Fix: /bmad-bmm-check-autonomous-implementation-readiness"
        exit 2
    fi
    echo "✓ Valid XML"
else
    echo "⚠️  xmllint missing, skipping XML validation"
fi
```

#### 3.3 Check for features

```bash
FEATURE_COUNT=$(grep -c '<feature' "$APP_SPEC" || echo "0")

if [[ "$FEATURE_COUNT" -eq 0 ]]; then
    echo "❌ No features in app_spec.txt"
    echo "   Regenerate: /bmad-bmm-create-app-spec"
    exit 3
fi
echo "✓ $FEATURE_COUNT features found"
```

#### 3.4 Verify tools

```bash
# Git
if ! command -v git &>/dev/null; then
    echo "❌ Git not found | Install: https://git-scm.com/downloads"
    exit 4
fi
echo "✓ Git installed"

# GitHub CLI
if ! command -v gh &>/dev/null; then
    echo "❌ GitHub CLI not found | Install: https://cli.github.com/"
    exit 5
fi
echo "✓ GitHub CLI installed"

# GitHub auth
if ! gh auth status 2>&1 | grep -q "Logged in"; then
    echo "❌ GitHub CLI not authenticated"
    echo "   Authenticate: gh auth login"
    exit 6
fi
echo "✓ GitHub CLI authenticated"
```

#### 3.5 Check CLAUDE.md (optional)

```bash
CLAUDE_MD="{claudeMdFile}"
if [[ -f "$CLAUDE_MD" ]]; then
    echo "✓ CLAUDE.md found"
else
    echo "⚠️  CLAUDE.md missing (optional)"
fi
```

---

### 4. Display Summary

```
─────────────────────────────────────────────────────
  PREREQUISITES COMPLETE
─────────────────────────────────────────────────────
Session: Initializer
Features: $FEATURE_COUNT
Prerequisites: All validated
Ready: Parse app_spec.txt
```

---

### 5. Auto-Proceed to Next Step

```
Proceeding to parse app_spec.txt...

→ Load and execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

**✅ SUCCESS:**
- Session type detected
- Coding: Continuation loaded
- Initializer: Prerequisites validated

**❌ FAILURE:**
- Exit 1-3: app_spec.txt issues
- Exit 4-6: Tool missing/auth failure
- Exit 10: Corrupted state, no recovery

**Master Rule:** Validation checks MANDATORY.

---

**Version:** 1.0.0 | **Created:** 2026-02-17 | **Status:** Complete
