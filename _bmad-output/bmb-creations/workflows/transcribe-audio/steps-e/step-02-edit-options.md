---
nextStepFile: './step-03-edit-complete.md'
---

# STEP GOAL

Present edit options, gather new configuration, execute selected operations, and prepare updated content.

---

# MANDATORY EXECUTION RULES

1. READ COMPLETELY - Read entire step before acting
2. FOLLOW SEQUENCE - Execute all sections in order
3. BRANCH CORRECTLY - Execute only selected operations
4. PRESERVE ORIGINALS - Never modify original files

---

# MANDATORY SEQUENCE

## 1. Retrieve Context

Get from workflow context:
- `report_path`, `report_metadata`, `audio_file`
- `current_model`, `current_language`, `current_analysis_types`
- `output_dir`

Locate and validate original audio file exists.

## 2. Present Edit Menu

```
## Edit Actions

[R] Re-transcribe Audio
    Change model (current: [model])
    Change language (current: [language])
    Generate additional formats

[A] Regenerate AI Analysis
    Add/remove analysis types
    Current: [list or "None"]

[B] Both Re-transcribe AND Regenerate

[C] Cancel

**Selection:**
```

Wait for input. Store in `edit_action`.

## 3. Process Selection

**If [R]:** Execute section 4 (Reconfigure Transcription)
**If [A]:** Execute section 5 (Reconfigure Analysis)
**If [B]:** Execute sections 4 then 5
**If [C]:** Display "Cancelled" and HALT

## 4. Reconfigure Transcription

**Only if edit_action = 'R' or 'B'**

### 4A. Model Selection

Load: `@{workflow-dir}/data/whisper-models.md`

```
### Model (Current: [current_model])

[K] Keep current
[B] Base - Fastest
[S] Small - Balanced
[M] Medium - Accurate

**Selection:**
```

Store in `new_model`.

### 4B. Language Selection

Load: `@{workflow-dir}/data/language-codes.md`

```
### Language (Current: [current_language])

[K] Keep current
[A] Auto-detect
[E] English
[S] Spanish
[O] Other (specify)

**Selection:**
```

Store in `new_language`.

### 4C. Output Formats

Load: `@{workflow-dir}/data/output-formats.md`

```
### Formats

[K] Keep existing
[T] TXT only
[S] TXT + SRT
[V] TXT + VTT
[J] TXT + JSON
[A] ALL formats

**Selection:**
```

Store in `new_output_format`.

### 4D. Execute Re-transcription

```
### Re-transcribing...

🎙️ Model: [new_model]
   Language: [new_language]
   Formats: [new_output_format]
```

Build and execute Whisper command:
```bash
whisper "[audio_file]" --model [new_model] --output_dir "[output_dir]" --output_format [new_output_format] [--language [new_language if not auto]] --verbose False
```

Capture results, store in `new_transcript_content`.

Display: `✅ Re-transcription complete`

## 5. Reconfigure Analysis

**Only if edit_action = 'A' or 'B'**

### 5A. Review Current

```
### Current Analysis: [list or "None"]

[R] Replace - Select new analyses
[A] Add - Keep existing, add more
[K] Keep - Regenerate with same types

**Selection:**
```

Store in `analysis_action`.

### 5B. Select Types

**If [R] or empty current:**

```
### Select Analyses

[ ] S - Summary
[ ] A - Action Items
[ ] T - Themes & Key Points
[ ] Q - Key Quotes
[ ] C - Custom Analysis
[ ] X - Skip (remove all)

Enter letters: (e.g., "SAT")

**Selection:**
```

**If [A]:** Show only missing types.

**If [K]:** Use `current_analysis_types`.

Store in `new_analysis_types`.

### 5C. Configure

For Summary: Prompt for length and focus.
For Custom: Prompt for analysis text.

### 5D. Generate Analysis

Determine source: Use `new_transcript_content` if re-transcribed, else read existing.

For each type in `new_analysis_types`:
```
### Generating [type]...
🤖 AI processing...
```

Execute LLM generation (reuse Create step-06 prompts).

Store in `new_analysis_results`.

Display: `✅ [type] complete`

## 6. Summary of Changes

```
---

## Edit Complete

**Transcription:**
[If re-transcribed:]
✅ Re-transcribed with [model]
   Language: [language]
   Files: [count]

[Else:] Original preserved

**Analysis:**
[If regenerated:]
✅ Generated [count]: [list]

[Else:] Original preserved

**Timestamp:** [datetime]

---

Saving updated report...
```

## 7. Store Updated Content

Store in workflow context:
- `new_transcript_content` (if applicable)
- `new_analysis_results` (if applicable)
- `new_model`, `new_language`, `new_analysis_types`
- `edit_timestamp`
- `changes_summary`

Prepare edit history for frontmatter:
```yaml
edit_history:
  - timestamp: [edit_timestamp]
    changes: [summary]
```

## 8. Load Next Step

```
Load and execute: @{workflow-dir}/step-03-edit-complete.md
```

---

# SUCCESS METRICS

**Succeeds when:**
- ✅ Edit action selected
- ✅ Configuration gathered
- ✅ Operations executed
- ✅ New content generated
- ✅ Changes stored
- ✅ Next step loaded

---

**Step Type:** Branch step (Edit operations)
