# Autonomous Mode Handling

**Purpose:** Shared logic for handling autonomous mode across all workflow steps.

---

## Detection Methods

**Check for autonomous mode using any of these methods:**

1. **Flag detection:** `--autonomous` in invocation
2. **Environment variable:** `BMAD_AUTONOMOUS=true`
3. **User context:** `AUTONOMOUS_MODE=true`

**If detected:**
- Set `autonomous_mode = true`
- Skip interactive menus
- Use default values (see below)
- Display autonomous mode messages

**If not detected:**
- Set `autonomous_mode = false`
- Proceed with normal interactive workflow

---

## Default Configuration

**When autonomous_mode = true, use these defaults:**

### Input Discovery (step-03)
- **Mode:** Determined by arguments
- **Required arguments:**
  - `--directory <path>` - Directory scan mode
  - `--file <path>` - Single file mode
  - `--files <path1> <path2> ...` - Multiple files mode
- **No argument:** Error and halt

### Configuration (step-04)
- **Model:** small (balanced speed/accuracy)
- **Language:** auto (auto-detect)
- **Output Format:** txt (text only)
- **Overrides:**
  - `--model [base|small|medium]`
  - `--language [code]`
  - `--format [txt|srt|vtt|json|all]`

### AI Analysis (step-06)
- **Default:** Skip analysis (fast transcription focus)
- **Opt-in:** `--analysis "A"` for action items
  - Examples: "SA" (summary+actions), "SATQ" (all)
- **Multi-file mode:** Combined analysis

---

## Step Integration Pattern

**Each step should follow this pattern:**

### 1. Check Autonomous Mode (First Section)

```markdown
## 1. Check Autonomous Mode

**IF autonomous_mode = true:**

[Step-specific autonomous behavior]
- Use defaults from data/autonomous-mode-handling.md
- Check for override flags
- Display autonomous mode message
- Skip to appropriate section

**IF autonomous_mode = false:**
Continue to section 1b (Interactive Mode)

## 1b. [Original Step Name]

[Original interactive content]
```

### 2. Conditional Menus

**All interactive menus should be conditional:**

```markdown
## N. Menu Title

**ONLY if autonomous_mode = false**

[Menu display and handling]
```

---

## Display Messages

**Autonomous mode detected:**
```
## Autonomous Mode: [Step Name]

Using default settings:
- [Setting 1]: [Value]
- [Setting 2]: [Value]

[If overrides: "Override detected: --flag value"]

Proceeding with [action]...
```

**Autonomous mode without required input:**
```
## ❌ Autonomous Mode Error

Autonomous mode requires [requirement].

Usage: /bmad-bmm-transcribe-audio --autonomous --[required-flag] <value>

Example: /bmad-bmm-transcribe-audio --autonomous --directory ~/audio
```

---

## Benefits of Autonomous Mode

**For users:**
- Batch processing without operator interaction
- Scripting and CI/CD integration
- Consistent, predictable behavior
- Faster execution (no wait for user input)

**Use cases:**
- Process 100+ audio files overnight
- Scheduled cron jobs
- API-triggered transcription
- CI/CD pipeline integration
- Automated workflows

---

## Implementation Notes

**File size optimization:**
- This shared data file reduces duplication across 5+ step files
- Each step references this file instead of duplicating logic
- Estimated savings: 15-40 lines per step file

**Maintenance:**
- Update defaults in ONE place (this file)
- All steps automatically inherit changes
- Consistency guaranteed

**BMAD compliance:**
- Follows DRY (Don't Repeat Yourself) principle
- Maintains step-file architecture
- Progressive disclosure preserved
- Intent-based design
