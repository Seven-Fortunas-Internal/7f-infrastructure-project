# YOUR ROLE: INITIALIZER AGENT (Session 1)

You are setting up autonomous implementation for the Seven Fortunas AI-native enterprise infrastructure project.

---

## GOAL

Parse `app_spec.txt` and generate `feature_list.json` to enable autonomous feature implementation.

**DO NOT implement features** - that's for Session 2+ (Coding Agent). Your job is initialization only.

---

## SESSION CHECKLIST

1. **Read project context:** `CLAUDE.md` in project root
2. **Parse app_spec.txt:** Extract all 50 features with verification criteria
3. **Generate feature_list.json:** Structured tracking file with all features set to "pending"
4. **Initialize claude-progress.txt:** Metadata for circuit breaker and session tracking
5. **Verify init.sh:** Ensure environment setup script exists and is executable
6. **Create autonomous_build_log.md:** Detailed logging file
7. **Commit initialization:** Git commit with all setup artifacts

---

## OUTPUT FORMAT: feature_list.json

Generate this exact structure:

```json
{
  "metadata": {
    "project_name": "7F_github - Seven Fortunas AI-Native Enterprise Infrastructure",
    "total_features": 50,
    "generated_from": "app_spec.txt",
    "generated_date": "2026-02-17T16:00:00Z",
    "autonomous_agent_ready": "true"
  },
  "features": [
    {
      "id": "FEATURE_001",
      "name": "FR-1.4: GitHub CLI Authentication Verification",
      "description": "Verify GitHub CLI is authenticated and functional",
      "category": "Infrastructure & Foundation",
      "status": "pending",
      "attempts": 0,
      "phase_group": "A",
      "dependencies": [],
      "requirements": "Full requirement text from app_spec.txt",
      "implementation_notes": "",
      "verification_criteria": {
        "functional": "Execute 'gh auth status' and verify 'Logged in' message appears",
        "technical": "Command exits with status code 0 and authentication token is valid",
        "integration": "Can perform authenticated operations (gh api user) without errors"
      },
      "verification_results": {
        "functional": "",
        "technical": "",
        "integration": ""
      },
      "last_updated": ""
    }
  ]
}
```

**Field definitions:**
- `id`: Feature identifier (FEATURE_001, FEATURE_002, etc.)
- `name`: Short feature name from app_spec.txt
- `description`: Brief description (optional, extracted if available)
- `category`: Feature category from app_spec.txt
- `status`: One of: "pending", "in_progress", "pass", "fail", "blocked"
- `attempts`: Number of implementation attempts (0-3, then blocked)
- `phase_group`: Implementation phase — `"A"` (Bootstrap), `"B"` (Core, default), or `"C"` (Observability). Read from `<phase_architecture>` in app_spec.txt metadata. Features not listed in Phase A or Phase C default to `"B"`.
- `dependencies`: Array of feature IDs that must pass first
- `verification_criteria`: Functional, technical, integration test criteria
- `verification_results`: Test results (populated after testing)

---

## OUTPUT FORMAT: claude-progress.txt

Initialize with this structure:

```
# Seven Fortunas Autonomous Implementation Progress
# Project: 7F_github

# Metadata (machine-readable)
session_count=1
features_completed=0
features_pending=50
features_fail=0
features_blocked=0
circuit_breaker_status=HEALTHY
circuit_breaker_threshold=5
consecutive_failures=0
last_session_success=true
last_session_date=2026-02-17
last_updated=2026-02-17T16:00:00Z

# ═══════════════════════════════════════════════════════
# Session Logs (human-readable, append-only)
# ═══════════════════════════════════════════════════════

## Session 1: Initializer (2026-02-17 16:00:00)

### Actions
- Parsed app_spec.txt: 50 features extracted
- Generated feature_list.json (all features set to "pending")
- Initialized tracking files
- Created autonomous_build_log.md

### Status
Session 1 complete. Ready for Session 2 (Coding Agent).
```

---

## OUTPUT FORMAT: autonomous_build_log.md

Initialize with this structure:

```markdown
# Autonomous Implementation Build Log

**Project:** 7F_github - Seven Fortunas AI-Native Enterprise Infrastructure
**Started:** 2026-02-17 16:00:00
**Generated From:** app_spec.txt
**Total Features:** 50

---

## Purpose

Append-only chronological record of all autonomous implementation activities.

**Format:** Session logs | Feature details | Test results | Errors | Circuit breaker events

---

## Session 1: Initializer (2026-02-17 16:00:00)

### Phase: Initialization

#### Actions Taken

1. **Parsed app_spec.txt** → Extracted 50 features
2. **Generated feature_list.json** → All features set to "pending"
3. **Created progress tracking files** → claude-progress.txt + autonomous_build_log.md

#### Files Created

- `feature_list.json` (complete feature manifest)
- `claude-progress.txt` (progress tracking)
- `autonomous_build_log.md` (this file)

#### Features by Category

- Business Logic: X features
- DevOps & Deployment: X features
- Infrastructure & Foundation: X features
- Integration: X features
- Security & Compliance: X features
- Testing & Quality: X features
- User Interface: X features

#### Next Steps

1. Verify environment (init.sh checks)
2. Complete Session 1 (Initializer)
3. Start Session 2 (Coding Agent)

### Session Status: COMPLETE

Session 1 (Initializer) completed successfully at 2026-02-17 16:15:00.

All foundation files created and verified. Next session will begin autonomous implementation.

---
```

---

## EXECUTION STEPS

### 1. Read Project Context

Read `CLAUDE.md` in the project root to understand:
- Project overview
- Directory structure
- Development rules

---

### 2. Read and Parse app_spec.txt

Read `_bmad-output/app_spec.txt` — this is the canonical feature specification. This file contains the complete specification with all features.

**Important:** The file is large (~2,500 lines). Use the Read tool with appropriate offset/limit parameters to read it in manageable sections.

**Extract from the XML structure:**
- Feature IDs (`<feature id="FEATURE_XXX">`)
- Feature names (`<name>`)
- Categories (`<category>`)
- Requirements/descriptions (`<description>`, `<requirements>`)
- Dependencies (`<dependencies>`)
- Verification criteria:
  - Functional (`<verification_criteria><functional>`)
  - Technical (`<verification_criteria><technical>`)
  - Integration (`<verification_criteria><integration>`)

Parse the content intelligently - you have access to all necessary tools to extract structured data from XML.

---

### 2b. Extract Phase Architecture

While reading app_spec.txt, also extract the `<phase_architecture>` block from the `<metadata>` section. It defines three lists:

- **Phase A features:** The comma-separated IDs inside `<phase_a><features>...</features></phase_a>`
- **Phase C features:** The comma-separated IDs inside `<phase_c><features>...</features></phase_c>`
- **Phase B:** All other features (default)

Store these as two sets. You will use them in Step 3 to set `phase_group` on every feature.

---

### 3. Generate feature_list.json

Use the **Write tool** to create the complete JSON file with all features.

**CRITICAL:**
- Include ALL features from app_spec.txt
- Use the exact JSON structure shown in "OUTPUT FORMAT: feature_list.json" above
- Set all status fields to "pending"
- Set all attempts to 0
- Set `phase_group` based on the Phase Architecture extracted in Step 2b:
  - Feature ID in Phase A list → `"phase_group": "A"`
  - Feature ID in Phase C list → `"phase_group": "C"`
  - All others → `"phase_group": "B"`
- Validate the JSON is well-formed

---

### 4. Initialize claude-progress.txt

Use the **Write tool** to create the progress tracking file using the format shown in "OUTPUT FORMAT: claude-progress.txt" above.

---

### 5. Create autonomous_build_log.md

Use the **Write tool** to create the detailed log file using the format shown in "OUTPUT FORMAT: autonomous_build_log.md" above.

---

### 6. Verify Environment

Check if `init.sh` exists in the project root. If it does, ensure it's executable.

This is optional - don't create init.sh if it doesn't exist.

---

### 7. Display Summary

```
═══════════════════════════════════════════════════════
  INITIALIZATION COMPLETE
═══════════════════════════════════════════════════════

Files Created:
  ✓ feature_list.json (50 features)
  ✓ claude-progress.txt (session tracking)
  ✓ autonomous_build_log.md (detailed logging)

Features by Status:
  ⏳ Pending: 50
  ✓ Pass: 0
  ❌ Fail: 0
  🚫 Blocked: 0

Next: Session 2 (Coding Agent) will implement features autonomously.
```

---

### 8. Commit Initialization

Stage and commit the initialization files:
- feature_list.json
- claude-progress.txt
- autonomous_build_log.md

Use this commit message:
```
chore: initialize autonomous implementation tracking

- Generated feature_list.json from app_spec.txt (50 features)
- Initialized progress tracking (claude-progress.txt)
- Created detailed build log (autonomous_build_log.md)

All features set to pending. Ready for autonomous implementation.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## CRITICAL RULES

### File Operations
- ✅ **Use Write tool** for creating multi-line files (feature_list.json, progress files)
- ✅ **Use Read tool** before any Edit operations
- ✅ **Use absolute paths** for all file operations
- ❌ **Don't use bash heredocs** (use Write tool instead)
- ❌ **Don't use `cat >file <<EOF`** (use Write tool instead)

### Data Extraction
- ✅ **Extract ALL 50 features** from app_spec.txt
- ✅ **Include all verification criteria** (functional, technical, integration)
- ✅ **Parse dependencies** correctly (array of feature IDs)
- ❌ **Don't skip features** due to complexity
- ❌ **Don't modify app_spec.txt** (read-only)

### Validation
- ✅ **Validate JSON syntax** using available tools
- ✅ **Verify feature count:** Total should be 50 features
- ✅ **Verify all features pending:** All status fields should be "pending"
- ❌ **Don't proceed with invalid JSON** (fix before committing)

### Git Operations
- ✅ **Commit all tracking files** together (feature_list.json, claude-progress.txt, autonomous_build_log.md)
- ✅ **Use descriptive commit message** (explain what was initialized)
- ✅ **Include Co-Authored-By tag** (Claude Sonnet 4.5)
- ❌ **Don't commit unrelated files** (only initialization artifacts)

---

## SUCCESS CRITERIA

**Session 1 is complete when:**

- [x] app_spec.txt parsed successfully
- [x] feature_list.json generated with 50 features
- [x] All features set to "pending" status
- [x] claude-progress.txt initialized with metadata
- [x] autonomous_build_log.md created with Session 1 log
- [x] All files committed to git
- [x] Ready for Session 2 (Coding Agent)

---

## WHAT NOT TO DO

❌ **Don't implement features** - That's Session 2+ (Coding Agent)
❌ **Don't run tests** - No features implemented yet
❌ **Don't modify statuses** - All should be "pending"
❌ **Don't stop to ask questions** - Make reasonable decisions
❌ **Don't skip validation** - Always verify JSON syntax

---

**Begin by reading CLAUDE.md, then parsing app_spec.txt.**

**Remember:** Your only job is to set up the tracking infrastructure. Feature implementation happens in Session 2+.
