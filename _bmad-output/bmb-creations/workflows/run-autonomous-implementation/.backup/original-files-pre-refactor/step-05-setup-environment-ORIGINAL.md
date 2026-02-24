---
name: 'step-05-setup-environment'
description: 'Create init.sh script and project directory structure'
nextStepFile: './step-06-initializer-complete.md'
initScriptFile: '{project_folder}/init.sh'
appSpecFile: '{project_folder}/app_spec.txt'
featureListFile: '{project_folder}/feature_list.json'
initScriptTemplate: '{workflow_path}/templates/init-sh-template.sh'
---

# Step 05: Setup Environment

## STEP GOAL:
Create init.sh environment setup script and initialize project directory structure based on app_spec.txt technology stack.

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: Environment Setup Orchestrator
- ✅ Collaborative dialogue: None (automated generation)
- ✅ You bring: Script generation, directory creation logic
- ✅ User brings: app_spec.txt with technology stack

### Step-Specific:
- 🎯 Focus: Create init.sh and project directories
- 🚫 Forbidden: Skipping validation checks, hardcoding paths
- 💬 Approach: Template-based script generation with project-specific values

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Create {initScriptFile} and project directories
- 📖 Extract technology stack from app_spec.txt

---

## CONTEXT BOUNDARIES:
- Available: app_spec.txt, feature_list.json
- Focus: Environment script and directory setup
- Limits: Does not install dependencies (script does that)
- Dependencies: Requires app_spec.txt and feature_list.json

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Setup Start

```
═══════════════════════════════════════════════════════
  ENVIRONMENT SETUP
  Creating init.sh and Project Structure
═══════════════════════════════════════════════════════
```

---

### 2. Extract Technology Stack from app_spec.txt

**Parse required tools and dependencies:**

```bash
APP_SPEC_FILE="{appSpecFile}"
PROJECT_FOLDER="{project_folder}"

echo "Extracting technology stack..."

# Extract technology stack section
TECH_STACK=$(xmllint --xpath "//technology_stack" "$APP_SPEC_FILE" 2>/dev/null || echo "")

if [[ -z "$TECH_STACK" ]]; then
    echo "  ⚠️  Warning: No technology_stack section found"
    echo "  Will create minimal init.sh"
    TECH_STACK="<technology_stack>No specific technologies listed</technology_stack>"
fi

# Extract specific sections
LANGUAGES=$(echo "$TECH_STACK" | xmllint --xpath "string(//languages)" - 2>/dev/null || echo "")
FRAMEWORKS=$(echo "$TECH_STACK" | xmllint --xpath "string(//frameworks)" - 2>/dev/null || echo "")
DATABASES=$(echo "$TECH_STACK" | xmllint --xpath "string(//databases)" - 2>/dev/null || echo "")
INFRASTRUCTURE=$(echo "$TECH_STACK" | xmllint --xpath "string(//infrastructure)" - 2>/dev/null || echo "")

echo "  Languages: ${LANGUAGES:-None specified}"
echo "  Frameworks: ${FRAMEWORKS:-None specified}"
echo "  Databases: ${DATABASES:-None specified}"
echo "  Infrastructure: ${INFRASTRUCTURE:-None specified}"
echo "✓ Technology stack extracted"
```

---

### 3. Generate init.sh Script

**Create environment setup script:**

```bash
INIT_SCRIPT_FILE="{initScriptFile}"

echo ""
echo "Creating: $INIT_SCRIPT_FILE"

# Check if file already exists
if [[ -f "$INIT_SCRIPT_FILE" ]]; then
    echo "  ⚠️  File already exists - will backup"
    BACKUP_FILE="${INIT_SCRIPT_FILE}.backup.$(date +%s)"
    cp "$INIT_SCRIPT_FILE" "$BACKUP_FILE"
    echo "  Backed up to: $BACKUP_FILE"
fi

# Generate init.sh
cat > "$INIT_SCRIPT_FILE" <<'INITEOF'
#!/bin/bash
# Autonomous Implementation - Environment Setup
# Generated: $(date -u +%Y-%m-%d %H:%M:%S)
# Project: $PROJECT_NAME

set -e  # Exit on error

echo "========================================="
echo "  Autonomous Implementation"
echo "  Environment Setup"
echo "========================================="
echo ""

# Project directories
export PROJECT_ROOT="$PROJECT_FOLDER"
export APP_SPEC_FILE="${PROJECT_ROOT}/app_spec.txt"
export FEATURE_LIST_FILE="${PROJECT_ROOT}/feature_list.json"
export PROGRESS_FILE="${PROJECT_ROOT}/claude-progress.txt"
export BUILD_LOG_FILE="${PROJECT_ROOT}/autonomous_build_log.md"
export OUTPUT_DIR="${PROJECT_ROOT}/outputs"
export LOGS_DIR="${PROJECT_ROOT}/logs"
export SCRIPTS_DIR="${PROJECT_ROOT}/scripts"

echo "Project Root: $PROJECT_ROOT"
echo ""

# Verify required files exist
echo "Checking required files..."
if [[ ! -f "$APP_SPEC_FILE" ]]; then
    echo "❌ ERROR: app_spec.txt not found"
    exit 1
fi
echo "✓ app_spec.txt found"

if [[ ! -f "$FEATURE_LIST_FILE" ]]; then
    echo "❌ ERROR: feature_list.json not found"
    exit 1
fi
echo "✓ feature_list.json found"

if [[ ! -f "$PROGRESS_FILE" ]]; then
    echo "⚠️  Warning: claude-progress.txt not found (will be created)"
fi

echo ""

# Check Git repository
echo "Checking Git repository..."
if [[ ! -d "${PROJECT_ROOT}/.git" ]]; then
    echo "❌ ERROR: Not a Git repository"
    echo "   Initialize with: git init"
    exit 1
fi
echo "✓ Git repository initialized"

# Check Git user configuration
if ! git config user.name &>/dev/null || ! git config user.email &>/dev/null; then
    echo "⚠️  Warning: Git user not configured"
    echo "   Configure with:"
    echo "   git config user.name 'Your Name'"
    echo "   git config user.email 'your.email@example.com'"
fi

echo ""

# GitHub CLI authentication
echo "Checking GitHub CLI..."
if ! command -v gh &>/dev/null; then
    echo "❌ ERROR: GitHub CLI not found"
    echo "   Install from: https://cli.github.com/"
    exit 1
fi
echo "✓ GitHub CLI installed"

if ! gh auth status &>/dev/null; then
    echo "❌ ERROR: GitHub CLI not authenticated"
    echo "   Authenticate with: gh auth login"
    exit 1
fi
echo "✓ GitHub CLI authenticated"

echo ""

# Verify required tools
echo "Checking required tools..."

# jq (JSON processor)
if ! command -v jq &>/dev/null; then
    echo "❌ ERROR: jq not found"
    echo "   Install: sudo apt-get install jq  # or brew install jq"
    exit 1
fi
echo "✓ jq installed"

# xmllint (XML processor)
if ! command -v xmllint &>/dev/null; then
    echo "⚠️  Warning: xmllint not found (optional but recommended)"
else
    echo "✓ xmllint installed"
fi

echo ""

# Create output directories
echo "Creating project directories..."
mkdir -p "$OUTPUT_DIR"
mkdir -p "$LOGS_DIR"
mkdir -p "$SCRIPTS_DIR"
echo "✓ Directories created"

echo ""

# Technology-specific checks
echo "Technology Stack Checks:"

INITEOF

# Add technology-specific checks based on app_spec.txt
if echo "$LANGUAGES" | grep -qi "python"; then
    cat >> "$INIT_SCRIPT_FILE" <<'INITEOF'
# Python
if command -v python3 &>/dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    echo "✓ Python installed: $PYTHON_VERSION"
else
    echo "⚠️  Python not found (required by app_spec.txt)"
fi

INITEOF
fi

if echo "$LANGUAGES" | grep -qi "node\|javascript"; then
    cat >> "$INIT_SCRIPT_FILE" <<'INITEOF'
# Node.js
if command -v node &>/dev/null; then
    NODE_VERSION=$(node --version)
    echo "✓ Node.js installed: $NODE_VERSION"
else
    echo "⚠️  Node.js not found (required by app_spec.txt)"
fi

INITEOF
fi

# Add final success message
cat >> "$INIT_SCRIPT_FILE" <<'INITEOF'

echo ""
echo "========================================="
echo "  Environment Setup Complete"
echo "========================================="
echo ""
echo "✓ All required tools verified"
echo "✓ Project directories created"
echo "✓ Ready for autonomous implementation"
echo ""
INITEOF

# Make script executable
chmod +x "$INIT_SCRIPT_FILE"

echo "✓ init.sh created and made executable"
```

---

### 4. Create Project Directory Structure

**Initialize basic directories:**

```bash
echo ""
echo "Creating project directory structure..."

PROJECT_ROOT="{project_folder}"

# Standard directories
mkdir -p "${PROJECT_ROOT}/outputs"
mkdir -p "${PROJECT_ROOT}/logs"
mkdir -p "${PROJECT_ROOT}/scripts"
mkdir -p "${PROJECT_ROOT}/prompts"

echo "✓ Directories created:"
echo "  - outputs/ (for generated artifacts)"
echo "  - logs/ (for session logs)"
echo "  - scripts/ (for automation scripts)"
echo "  - prompts/ (for agent prompts)"
```

---

### 5. Test init.sh Script

**Run validation checks:**

```bash
echo ""
echo "Testing init.sh script..."

cd "$PROJECT_ROOT"

if bash "$INIT_SCRIPT_FILE"; then
    echo "✓ init.sh executed successfully"
else
    echo "⚠️  Warning: init.sh encountered issues (see output above)"
    echo "   This may be expected if dependencies aren't installed yet."
fi
```

---

### 6. Update Build Log

**Record environment setup in build log:**

```bash
BUILD_LOG_FILE="{buildLogFile}"

echo ""
echo "Updating build log..."

cat >> "$BUILD_LOG_FILE" <<EOF

4. **Created environment setup script**
   - Location: $INIT_SCRIPT_FILE
   - Size: $(du -h "$INIT_SCRIPT_FILE" | cut -f1)
   - Executable: Yes
   - Technology checks: $(echo "$LANGUAGES" | wc -w) languages

5. **Initialized project directories**
   - outputs/ (generated artifacts)
   - logs/ (session logs)
   - scripts/ (automation)
   - prompts/ (agent prompts)

EOF

echo "✓ Build log updated"
```

---

### 7. Display Environment Setup Summary

```
─────────────────────────────────────────────────────
  ENVIRONMENT SETUP COMPLETE
─────────────────────────────────────────────────────

init.sh Created: $INIT_SCRIPT_FILE
  - Checks: Git, GitHub CLI, jq, xmllint
  - Technology checks: $(echo "$LANGUAGES $FRAMEWORKS" | wc -w) items
  - Status: Executable

Project Directories:
  ✓ outputs/  (for generated files)
  ✓ logs/     (for session logs)
  ✓ scripts/  (for automation)
  ✓ prompts/  (for agent prompts)

Next Steps:
  1. Complete Session 1 (Initializer)
  2. Review generated files
  3. Run Session 2 (Coding Agent) to start implementation

Ready for completion step
```

---

### 8. Proceed to Next Step

**Menu Handling Logic:**
- This step uses **Auto-proceed** (no menu)
- Environment setup is complete
- Next step will show completion summary and guide to Session 2

**Execution:**

```
Proceeding to Initializer completion...

→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- Technology stack extracted from app_spec.txt
- init.sh script created with validation checks
- init.sh made executable (chmod +x)
- Project directories created (outputs/, logs/, scripts/, prompts/)
- init.sh tested (validation checks ran)
- Build log updated with environment setup actions
- Ready for step-06 (Initializer completion)

### ❌ FAILURE:
- app_spec.txt not found (exit code 1)
- init.sh creation failed (file write error)
- Directory creation failed (permissions issue)

**Master Rule:** Environment must be set up correctly before completing Initializer.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
