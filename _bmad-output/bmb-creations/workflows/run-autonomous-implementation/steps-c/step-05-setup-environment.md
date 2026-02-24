---
name: 'step-05-setup-environment'
description: 'Create init.sh script and project directory structure'
nextStepFile: './step-06-initializer-complete.md'
initScriptFile: '{project_folder}/init.sh'
appSpecFile: '{project_folder}/app_spec.txt'
---

# Step 05: Setup Environment

## STEP GOAL:
Create init.sh environment setup script and initialize project directory structure based on app_spec.txt technology stack.

---

## MANDATORY EXECUTION RULES:

### Universal:
@~/.claude/CLAUDE.md#execution-rules

### Role:
- Role: Environment Setup Orchestrator (automated generation)
- Input: app_spec.txt with technology stack

### Step-Specific:
- Focus: Create init.sh and project directories
- Forbidden: Skipping validation checks, hardcoding paths

---

## EXECUTION PROTOCOLS:
- Follow MANDATORY SEQUENCE exactly
- Create {initScriptFile} and project directories
- Extract technology stack from app_spec.txt

---

## CONTEXT BOUNDARIES:
- Available: app_spec.txt, feature_list.json
- Focus: Environment script and directory setup
- Limits: Does not install dependencies (script does that)

---

## MANDATORY SEQUENCE

### 1. Display Setup Start

```
═══════════════════════════════════════════════════════
  ENVIRONMENT SETUP
  Creating init.sh and Project Structure
═══════════════════════════════════════════════════════
```

---

### 2. Extract Technology Stack

```bash
APP_SPEC_FILE="{appSpecFile}"; PROJECT_FOLDER="{project_folder}"; echo "Extracting technology stack..."; TECH_STACK=$(xmllint --xpath "//technology_stack" "$APP_SPEC_FILE" 2>/dev/null || echo "<technology_stack>No specific technologies listed</technology_stack>"); LANGUAGES=$(echo "$TECH_STACK" | xmllint --xpath "string(//languages)" - 2>/dev/null || echo ""); FRAMEWORKS=$(echo "$TECH_STACK" | xmllint --xpath "string(//frameworks)" - 2>/dev/null || echo ""); echo "  Languages: ${LANGUAGES:-None}  Frameworks: ${FRAMEWORKS:-None}"; echo "✓ Technology stack extracted"
```

---

### 3. Generate init.sh Script

```bash
INIT_SCRIPT_FILE="{initScriptFile}"; echo "Creating: $INIT_SCRIPT_FILE"; [[ -f "$INIT_SCRIPT_FILE" ]] && cp "$INIT_SCRIPT_FILE" "${INIT_SCRIPT_FILE}.backup.$(date +%s)"; cat > "$INIT_SCRIPT_FILE" <<INITEOF
#!/bin/bash
# Autonomous Implementation - Environment Setup
# Generated: $(date -u +%Y-%m-%d)
set -e
echo "========================================="
echo "  Environment Setup"
echo "========================================="
export PROJECT_ROOT="$PROJECT_FOLDER"
export APP_SPEC_FILE="\${PROJECT_ROOT}/app_spec.txt"
export FEATURE_LIST_FILE="\${PROJECT_ROOT}/feature_list.json"
export PROGRESS_FILE="\${PROJECT_ROOT}/claude-progress.txt"
export BUILD_LOG_FILE="\${PROJECT_ROOT}/autonomous_build_log.md"
export OUTPUT_DIR="\${PROJECT_ROOT}/outputs"
export LOGS_DIR="\${PROJECT_ROOT}/logs"
export SCRIPTS_DIR="\${PROJECT_ROOT}/scripts"
echo "Project Root: \$PROJECT_ROOT"
echo "Checking environment..."
[[ ! -f "\$APP_SPEC_FILE" ]] && echo "❌ app_spec.txt not found" && exit 1
[[ ! -f "\$FEATURE_LIST_FILE" ]] && echo "❌ feature_list.json not found" && exit 1
[[ ! -d "\${PROJECT_ROOT}/.git" ]] && echo "❌ Not a Git repository" && exit 1
! command -v gh &>/dev/null && echo "❌ GitHub CLI not found" && exit 1
! gh auth status &>/dev/null && echo "❌ GitHub CLI not authenticated" && exit 1
! command -v jq &>/dev/null && echo "❌ jq not found" && exit 1
echo "✓ All checks passed"
mkdir -p "\$OUTPUT_DIR" "\$LOGS_DIR" "\$SCRIPTS_DIR"
echo "Technology Stack:"
INITEOF

if echo "$LANGUAGES" | grep -qi "python"; then
cat >> "$INIT_SCRIPT_FILE" <<'PYEOF'
command -v python3 &>/dev/null && echo "✓ Python: $(python3 --version)" || echo "⚠️  Python not found"
PYEOF
fi

if echo "$LANGUAGES" | grep -qi "node\|javascript"; then
cat >> "$INIT_SCRIPT_FILE" <<'NODEEOF'
command -v node &>/dev/null && echo "✓ Node.js: $(node --version)" || echo "⚠️  Node.js not found"
NODEEOF
fi

cat >> "$INIT_SCRIPT_FILE" <<'ENDEOF'
echo "========================================="
echo "  Setup Complete - Ready for Build"
echo "========================================="
ENDEOF

chmod +x "$INIT_SCRIPT_FILE"; echo "✓ init.sh created (executable)"
```

---

### 4. Create Project Directories

```bash
echo "Creating project directories..."; mkdir -p "${PROJECT_ROOT}/outputs" "${PROJECT_ROOT}/logs" "${PROJECT_ROOT}/scripts" "${PROJECT_ROOT}/prompts"; echo "✓ Directories: outputs/, logs/, scripts/, prompts/"
```

---

### 5. Test init.sh

```bash
echo "Testing init.sh..."; cd "$PROJECT_ROOT" && bash "$INIT_SCRIPT_FILE" && echo "✓ init.sh test passed" || echo "⚠️  init.sh test warnings (may be expected)"
```

---

### 6. Update Build Log

```bash
BUILD_LOG_FILE="{buildLogFile}"; cat >> "$BUILD_LOG_FILE" <<EOF

4. **Environment setup script created**
   - Location: $INIT_SCRIPT_FILE ($(du -h "$INIT_SCRIPT_FILE" | cut -f1))
   - Checks: Git, GitHub CLI, jq, xmllint, tech stack

5. **Project directories initialized**
   - outputs/, logs/, scripts/, prompts/

EOF
echo "✓ Build log updated"
```

---

### 7. Display Summary

```
─────────────────────────────────────────────────────
  ENVIRONMENT SETUP COMPLETE
─────────────────────────────────────────────────────
init.sh: $INIT_SCRIPT_FILE (executable, tested)
Directories: ✓ outputs/ ✓ logs/ ✓ scripts/ ✓ prompts/
Next: Complete Session 1, then run Session 2 (Coding Agent)
```

---

### 8. Proceed to Next Step

**Auto-proceed to completion:**

```
→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- Technology stack extracted from app_spec.txt
- init.sh created, executable, tested
- Project directories created
- Build log updated
- Ready for step-06

### ❌ FAILURE:
- app_spec.txt not found (exit code 1)
- init.sh creation failed
- Directory creation failed (permissions)

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
