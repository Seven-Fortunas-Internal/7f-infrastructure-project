---
name: 'step-04-setup-tracking'
description: 'Create claude-progress.txt and autonomous_build_log.md for progress tracking'
nextStepFile: './step-05-setup-environment.md'
progressFile: '{project_folder}/claude-progress.txt'
buildLogFile: '{project_folder}/autonomous_build_log.md'
featureListFile: '{project_folder}/feature_list.json'
---

# Step 04: Setup Progress Tracking Files

## STEP GOAL:
Create claude-progress.txt (hybrid format) and autonomous_build_log.md for tracking implementation progress across multiple sessions.

---

## MANDATORY EXECUTION RULES:
@~/.claude/CLAUDE.md (Universal workflow protocols apply)

**Role:** Tracking System Initializer (automated setup)
**Focus:** Create progress tracking files with correct structure
**Forbidden:** Skipping metadata header, wrong file format

---

## CONTEXT BOUNDARIES:
- Available: feature_list.json (from step-03), project metadata
- Focus: Progress tracking file creation
- Limits: Does not implement features or modify feature_list.json
- Dependencies: Requires feature_list.json to exist

---

## MANDATORY SEQUENCE

### 1. Load Project Metadata & Display Header

```bash
FEATURE_LIST_FILE="{featureListFile}"

echo "═══ SETTING UP PROGRESS TRACKING ═══"
echo "Loading project metadata..."

[[ ! -f "$FEATURE_LIST_FILE" ]] && { echo "❌ ERROR: feature_list.json not found. Run step-03 first."; exit 25; }

PROJECT_NAME=$(jq -r '.metadata.project_name' "$FEATURE_LIST_FILE")
TOTAL_FEATURES=$(jq -r '.metadata.total_features' "$FEATURE_LIST_FILE")
GENERATED_FROM=$(jq -r '.metadata.generated_from' "$FEATURE_LIST_FILE")

echo "  Project: $PROJECT_NAME | Features: $TOTAL_FEATURES"
echo "✓ Metadata loaded"
```

---

### 2. Create Tracking Files

```bash
PROGRESS_FILE="{progressFile}"
BUILD_LOG_FILE="{buildLogFile}"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
DATE_HUMAN=$(date -u +%Y-%m-%d %H:%M:%S)

echo ""
echo "Creating tracking files..."

# Backup existing files
for FILE in "$PROGRESS_FILE" "$BUILD_LOG_FILE"; do
    [[ -f "$FILE" ]] && cp "$FILE" "${FILE}.backup.$(date +%s)" && echo "  Backed up: $(basename "$FILE")"
done

# Create claude-progress.txt (hybrid format)
cat > "$PROGRESS_FILE" <<PROGRESS_EOF
# METADATA (Structured - for circuit breaker parsing)
# Each line: key=value (no spaces around =)
# DO NOT modify manually - use EDIT mode
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
last_updated=$TIMESTAMP

# SESSION LOGS (Human-readable - append-only)
# NEVER modify entries below
# Format: ## Session N: Type (Date Time)

## Session 1: Initializer ($DATE_HUMAN)
- Generated feature_list.json with $TOTAL_FEATURES features
- Created claude-progress.txt (this file)
- Initialized tracking structure
- Status: IN_PROGRESS
PROGRESS_EOF

[[ $? -eq 0 ]] && echo "✓ claude-progress.txt created" || { echo "❌ Failed to create claude-progress.txt"; exit 26; }

# Create autonomous_build_log.md
cat > "$BUILD_LOG_FILE" <<LOG_EOF
# Autonomous Implementation Build Log

**Project:** $PROJECT_NAME
**Started:** $DATE_HUMAN
**Generated From:** $GENERATED_FROM
**Total Features:** $TOTAL_FEATURES

---

## Purpose

Append-only chronological record of all autonomous implementation activities.

**Format:** Session logs | Feature details | Test results | Errors | Circuit breaker events

---

## Session 1: Initializer ($DATE_HUMAN)

### Phase: Initialization

#### Actions Taken

1. **Parsed app_spec.txt** → Extracted $TOTAL_FEATURES features
2. **Generated feature_list.json** → All features set to "pending"
3. **Created progress tracking files** → claude-progress.txt + autonomous_build_log.md

#### Files Created

- `feature_list.json` ($(du -h "$FEATURE_LIST_FILE" 2>/dev/null | cut -f1 || echo "unknown"))
- `claude-progress.txt` ($(du -h "$PROGRESS_FILE" 2>/dev/null | cut -f1 || echo "unknown"))
- `autonomous_build_log.md` (this file)

#### Features by Category

$(jq -r '.features | group_by(.category) | .[] | "- \(.[0].category): \(length) features"' "$FEATURE_LIST_FILE" 2>/dev/null)

#### Next Steps

1. Create init.sh (environment setup)
2. Initialize project directory structure
3. Complete Session 1 (Initializer)
4. Start Session 2 (Coding Agent)

### Session Status: IN_PROGRESS

---

LOG_EOF

[[ $? -eq 0 ]] && echo "✓ autonomous_build_log.md created" || { echo "❌ Failed to create autonomous_build_log.md"; exit 29; }
```

---

### 3. Verify Files & Display Summary

```bash
echo ""
echo "Verifying tracking files..."

# Verify structure
grep -q '^session_count=\|^circuit_breaker_threshold=\|^## Session 1:' "$PROGRESS_FILE" || { echo "❌ claude-progress.txt invalid"; exit 27; }
grep -q '^# Autonomous Implementation Build Log\|^## Session 1:' "$BUILD_LOG_FILE" || { echo "❌ autonomous_build_log.md invalid"; exit 30; }

echo "✓ Both files verified"

cat <<SUMMARY

─────────────────────────────────────────────────────
  PROGRESS TRACKING SETUP COMPLETE
─────────────────────────────────────────────────────
Files: claude-progress.txt (hybrid) | autonomous_build_log.md ($(du -h "$BUILD_LOG_FILE" | cut -f1))
Status: $TOTAL_FEATURES features (all pending) | Circuit breaker: HEALTHY | Session: 1

Proceeding to environment setup...
SUMMARY

echo "→ Load, read entire file, then execute {nextStepFile}"
```

---

## 🚨 SUCCESS/FAILURE:

**✅ SUCCESS:** feature_list.json loaded → tracking files created & verified → auto-proceed to step-05

**❌ FAILURE:** Exit 25 (feature_list.json missing) | 26 (progress file) | 27 (progress structure) | 29 (log file) | 30 (log structure)

**Master Rule:** Tracking files must be created with correct structure before proceeding.

---

**Step Version:** 1.1.0
**Created:** 2026-02-17
**Status:** Complete
