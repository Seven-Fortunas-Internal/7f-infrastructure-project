---
name: 'step-04-setup-tracking'
description: 'Create claude-progress.txt and autonomous_build_log.md for progress tracking'
nextStepFile: './step-05-setup-environment.md'
progressFile: '{project_folder}/claude-progress.txt'
buildLogFile: '{project_folder}/autonomous_build_log.md'
featureListFile: '{project_folder}/feature_list.json'
progressTemplate: '{workflow_path}/templates/claude-progress-template.txt'
buildLogTemplate: '{workflow_path}/templates/autonomous-build-log-template.md'
---

# Step 04: Setup Progress Tracking Files

## STEP GOAL:
Create claude-progress.txt (hybrid format) and autonomous_build_log.md for tracking implementation progress across multiple sessions.

---

## MANDATORY EXECUTION RULES:

### Universal:
- 🛑 NEVER generate without user input
- 📖 Read complete step file before action
- 🔄 When loading with 'C', read entire file
- 📋 Facilitator, not generator

### Role:
- ✅ Role: Tracking System Initializer
- ✅ Collaborative dialogue: None (automated setup)
- ✅ You bring: File generation logic, hybrid format implementation
- ✅ User brings: feature_list.json from step-03

### Step-Specific:
- 🎯 Focus: Create progress tracking files with correct structure
- 🚫 Forbidden: Skipping metadata header, wrong file format
- 💬 Approach: Template-based generation with project-specific data

---

## EXECUTION PROTOCOLS:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Create {progressFile} and {buildLogFile}
- 📖 Use templates if available, generate from scratch if not

---

## CONTEXT BOUNDARIES:
- Available: feature_list.json (from step-03), project metadata
- Focus: Progress tracking file creation
- Limits: Does not implement features or modify feature_list.json
- Dependencies: Requires feature_list.json to exist

---

## MANDATORY SEQUENCE

**Follow exactly. No skip/reorder without user request.**

---

### 1. Display Setup Start

```
═══════════════════════════════════════════════════════
  SETTING UP PROGRESS TRACKING
  Creating claude-progress.txt and autonomous_build_log.md
═══════════════════════════════════════════════════════
```

---

### 2. Load Project Metadata

**Read project information from feature_list.json:**

```bash
FEATURE_LIST_FILE="{featureListFile}"

echo "Loading project metadata..."

if [[ ! -f "$FEATURE_LIST_FILE" ]]; then
    echo "❌ ERROR: feature_list.json not found"
    echo "   Expected: $FEATURE_LIST_FILE"
    echo "   Run step-03 first."
    exit 25
fi

# Extract metadata
PROJECT_NAME=$(jq -r '.metadata.project_name' "$FEATURE_LIST_FILE")
TOTAL_FEATURES=$(jq -r '.metadata.total_features' "$FEATURE_LIST_FILE")
GENERATED_FROM=$(jq -r '.metadata.generated_from' "$FEATURE_LIST_FILE")

echo "  Project: $PROJECT_NAME"
echo "  Features: $TOTAL_FEATURES"
echo "✓ Metadata loaded"
```

---

### 3. Create claude-progress.txt (Hybrid Format)

**Generate progress file with structured metadata + human logs:**

```bash
PROGRESS_FILE="{progressFile}"

echo ""
echo "Creating: $PROGRESS_FILE"

# Check if file already exists
if [[ -f "$PROGRESS_FILE" ]]; then
    echo "  ⚠️  File already exists - will backup"
    BACKUP_FILE="${PROGRESS_FILE}.backup.$(date +%s)"
    cp "$PROGRESS_FILE" "$BACKUP_FILE"
    echo "  Backed up to: $BACKUP_FILE"
fi

# Generate hybrid format file
cat > "$PROGRESS_FILE" <<EOF
# METADATA (Structured - for circuit breaker parsing)
# This section must remain at top of file
# Each line: key=value (no spaces around =)
# DO NOT modify this section manually - use EDIT mode
session_count=1
consecutive_failures=0
last_session_date=$(date -u +%Y-%m-%d)
last_session_success=true
features_completed=0
features_pending=$TOTAL_FEATURES
features_fail=0
features_blocked=0
circuit_breaker_threshold=5
circuit_breaker_status=HEALTHY
last_updated=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# SESSION LOGS (Human-readable - append-only)
# NEVER modify entries below this line
# Only append new session logs
# Format: ## Session N: Type (Date Time)

## Session 1: Initializer ($(date -u +%Y-%m-%d %H:%M:%S))
- Generated feature_list.json with $TOTAL_FEATURES features
- Created claude-progress.txt (this file)
- Initialized tracking structure
- Status: IN_PROGRESS
EOF

if [[ $? -eq 0 ]]; then
    echo "✓ claude-progress.txt created"
else
    echo "❌ ERROR: Failed to create claude-progress.txt"
    exit 26
fi
```

---

### 4. Verify claude-progress.txt

**Validate file structure:**

```bash
echo ""
echo "Verifying claude-progress.txt structure..."

# Check metadata header is parseable
if grep -q '^session_count=' "$PROGRESS_FILE" && \
   grep -q '^consecutive_failures=' "$PROGRESS_FILE" && \
   grep -q '^circuit_breaker_threshold=' "$PROGRESS_FILE"; then
    echo "✓ Metadata header is valid"
else
    echo "❌ ERROR: Metadata header is missing or incomplete"
    exit 27
fi

# Check session log section exists
if grep -q '^## Session 1: Initializer' "$PROGRESS_FILE"; then
    echo "✓ Session log section is valid"
else
    echo "❌ ERROR: Session log section is missing"
    exit 28
fi

echo "✓ claude-progress.txt verified"
```

---

### 5. Create autonomous_build_log.md

**Generate detailed append-only log:**

```bash
BUILD_LOG_FILE="{buildLogFile}"

echo ""
echo "Creating: $BUILD_LOG_FILE"

# Check if file already exists
if [[ -f "$BUILD_LOG_FILE" ]]; then
    echo "  ⚠️  File already exists - will backup"
    BACKUP_FILE="${BUILD_LOG_FILE}.backup.$(date +%s)"
    cp "$BUILD_LOG_FILE" "$BACKUP_FILE"
    echo "  Backed up to: $BACKUP_FILE"
fi

# Generate build log
cat > "$BUILD_LOG_FILE" <<EOF
# Autonomous Implementation Build Log

**Project:** $PROJECT_NAME
**Started:** $(date -u +%Y-%m-%d %H:%M:%S)
**Generated From:** $GENERATED_FROM
**Total Features:** $TOTAL_FEATURES

---

## Purpose

This log provides a detailed, chronological record of all autonomous implementation activities. It is append-only and provides a complete audit trail.

**Format:**
- Session-by-session logs
- Feature-by-feature implementation details
- Test results and verification outcomes
- Error messages and recovery actions
- Circuit breaker events

---

## Session 1: Initializer ($(date -u +%Y-%m-%d %H:%M:%S))

### Phase: Initialization

#### Actions Taken

1. **Parsed app_spec.txt**
   - Location: $(realpath "$APP_SPEC_FILE" 2>/dev/null || echo "{appSpecFile}")
   - Features extracted: $TOTAL_FEATURES
   - Metadata extracted: Project name, generation date

2. **Generated feature_list.json**
   - Location: $FEATURE_LIST_FILE
   - Structure: metadata + features array
   - Initial status: All features set to "pending"
   - Attempts: All initialized to 0
   - Dependencies: Extracted and populated

3. **Created progress tracking files**
   - claude-progress.txt (hybrid format: metadata + logs)
   - autonomous_build_log.md (this file)

#### Files Created

- \`feature_list.json\` ($(du -h "$FEATURE_LIST_FILE" 2>/dev/null | cut -f1 || echo "unknown size"))
- \`claude-progress.txt\` ($(du -h "$PROGRESS_FILE" 2>/dev/null | cut -f1 || echo "unknown size"))
- \`autonomous_build_log.md\` (this file)

#### Features by Category

$(jq -r '.features | group_by(.category) | .[] | "- \(.[0].category): \(length) features"' "$FEATURE_LIST_FILE" 2>/dev/null)

#### Next Steps

1. Create init.sh (environment setup script)
2. Initialize project directory structure
3. Complete Session 1 (Initializer)
4. Start Session 2 (Coding Agent) to begin implementation

### Session Status: IN_PROGRESS

---

EOF

if [[ $? -eq 0 ]]; then
    echo "✓ autonomous_build_log.md created"
else
    echo "❌ ERROR: Failed to create autonomous_build_log.md"
    exit 29
fi
```

---

### 6. Verify autonomous_build_log.md

**Validate file structure:**

```bash
echo ""
echo "Verifying autonomous_build_log.md..."

# Check required sections exist
if grep -q '^# Autonomous Implementation Build Log' "$BUILD_LOG_FILE" && \
   grep -q '^## Session 1: Initializer' "$BUILD_LOG_FILE"; then
    echo "✓ Build log structure is valid"
else
    echo "❌ ERROR: Build log structure is incomplete"
    exit 30
fi

echo "✓ autonomous_build_log.md verified"
```

---

### 7. Display Tracking Setup Summary

```
─────────────────────────────────────────────────────
  PROGRESS TRACKING SETUP COMPLETE
─────────────────────────────────────────────────────

Files Created:

1. claude-progress.txt ($PROGRESS_FILE)
   - Format: Hybrid (structured metadata + human logs)
   - Metadata: session_count=1, consecutive_failures=0
   - Circuit breaker: Initialized (threshold=5)
   - Session log: Session 1 entry created

2. autonomous_build_log.md ($BUILD_LOG_FILE)
   - Format: Markdown (append-only)
   - Session 1: Initialization phase logged
   - Size: $(du -h "$BUILD_LOG_FILE" | cut -f1)

Status:
  - feature_list.json: $TOTAL_FEATURES features (all pending)
  - Progress tracking: Ready
  - Circuit breaker: HEALTHY
  - Session count: 1 (Initializer in progress)

Ready for environment setup
```

---

### 8. Proceed to Next Step

**Menu Handling Logic:**
- This step uses **Auto-proceed** (no menu)
- Tracking files are now created
- Next step will create init.sh and directory structure

**Execution:**

```
Proceeding to environment setup...

→ Load, read entire file, then execute {nextStepFile}
```

---

## 🚨 SUCCESS/FAILURE:

### ✅ SUCCESS:
- feature_list.json loaded successfully
- claude-progress.txt created with valid hybrid format
  - Metadata header parseable (key=value format)
  - Session log section initialized
- autonomous_build_log.md created with valid structure
  - Session 1 entry logged
  - Initialization actions documented
- Both files verified (structure checks passed)
- Ready for step-05 (environment setup)

### ❌ FAILURE:
- feature_list.json not found (exit code 25)
- claude-progress.txt creation failed (exit code 26)
- claude-progress.txt metadata header invalid (exit code 27)
- claude-progress.txt session log missing (exit code 28)
- autonomous_build_log.md creation failed (exit code 29)
- autonomous_build_log.md structure invalid (exit code 30)

**Master Rule:** Tracking files must be created with correct structure before proceeding.

---

**Step Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Complete
