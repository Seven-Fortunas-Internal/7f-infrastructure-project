---
nextStepFile: './step-07-output-summary.md'
autonomousModeGuide: '../data/autonomous-mode-handling.md'
---

# STEP GOAL

Offer optional AI analysis of transcribed content with multi-select options. Execute selected analyses and prepare content for final report.

---

# MANDATORY EXECUTION RULES

1. READ COMPLETELY - Read entire step before acting
2. FOLLOW SEQUENCE - Execute all sections in order
3. MULTI-SELECT - Allow multiple analysis selections
4. OPTIONAL - Respect if user skips

---

# MANDATORY SEQUENCE

## 1. Check Autonomous Mode

**Reference:** Load {autonomousModeGuide} for AI analysis defaults.

**IF autonomous_mode = true:**

Apply AI analysis defaults (see {autonomousModeGuide} section "AI Analysis"):
- Default: Skip analysis (fast transcription focus)
- Check for --analysis flag (opt-in for analysis types)
- For multiple files: Use combined mode
- Display autonomous mode message
- Route to section 4 (if analysis) or section 7 (if skipped)

**IF autonomous_mode = false:**
Continue to section 1b (Retrieve Context)

## 1b. Retrieve Context

Get from workflow context:
- `transcripts` array (with transcript_content)
- `file_count`, `output_dir`

## 2. Multi-File Strategy (If Applicable)

**ONLY if autonomous_mode = false**

**If `file_count > 1`:**

```
## Multiple Transcripts ([count] files)

[C] Combined - Analyze as one document
[I] Individual - Analyze separately
[S] Skip Analysis

**Selection:**
```

#### Menu Handling Logic:

**EXECUTION RULES:**
- ALWAYS halt and wait for user input after presenting menu
- Process selection and route appropriately

**Process:**
- [C]: Merge all into `analysis_text`, set `analysis_mode = "combined"`
- [I]: Keep separate, set `analysis_mode = "individual"`
- [S]: Set `skip_analysis = true`, jump to section 7

**If `file_count == 1`:**
- Set `analysis_text = transcripts[0].transcript_content`
- Set `analysis_mode = "single"`

## 3. Analysis Type Selection

**ONLY if autonomous_mode = false**

```
---

## AI Analysis Options

Select one or more (or skip):

[ ] S - Summary (configurable length/focus)
[ ] A - Action Items (todos, decisions, next steps)
[ ] T - Themes & Key Points (main topics)
[ ] Q - Key Quotes (notable statements)
[ ] C - Custom Analysis (your prompt)
[ ] X - Skip Analysis

Enter letters: (e.g., "SA" for Summary + Actions)

**Selection:**
```

#### Menu Handling Logic:

**EXECUTION RULES:**
- ALWAYS halt and wait for user input after presenting menu
- Parse multi-select input and process accordingly

Parse and store in `analysis_types` array.

**If "X":** Set `skip_analysis = true`, jump to section 7.

**If "C" selected:** Prompt for custom analysis text, store in `custom_analysis_prompt`.

**If "S" selected:**
```
### Summary Config

Length: [B]rief / [S]tandard / [D]etailed (default: S)
Focus areas (optional): [text or blank]
```
Store in `summary_config`.

**Confirm:**
```
✅ Selected: [count] analyses
   - [list types]

[C] Continue
[R] Revise

**Selection:**
```

If [R]: Return to start of section 3.

## 4. Generate Analyses

For each type in `analysis_types`:

```
### Generating [Type]...
🤖 AI processing...
```

**Use appropriate prompt:**

**Summary:**
```
System: Expert at summarizing spoken content.
User: Create [length] summary. [Focus: {areas}]
Transcript: {content}
```

**Action Items:**
```
System: Expert at extracting actionable insights.
User: Identify: 1) Action items/todos, 2) Decisions, 3) Next steps
Format as bulleted list.
Transcript: {content}
```

**Themes:**
```
System: Expert at identifying themes.
User: Analyze and identify: 1) Main themes (3-5), 2) Key points per theme, 3) Patterns
Transcript: {content}
```

**Quotes:**
```
System: Expert at identifying impactful statements.
User: Extract 5-10 key quotes that are insightful, memorable, or represent key ideas.
Include brief context for each.
Transcript: {content}
```

**Custom:**
```
System: Expert analyst of spoken content.
User: {custom_analysis_prompt}
Transcript: {content}
```

Execute LLM, capture result, store in `analysis_results` object.

Display: `✅ [Type] complete`

## 5. Analysis Summary

```
---

## AI Analysis Complete

**Generated:** [count] analyses
[List types]

**Content:**
- Summary: [word count if applicable]
- Action Items: [count if applicable]
- Themes: [count if applicable]
- Quotes: [count if applicable]
- Custom: [present if applicable]

All content will be included in final report.

---

Proceeding to output summary...
```

## 6. Store Results

Store in workflow context:
- `analysis_results` object
- `analysis_types` array
- `skip_analysis` boolean

## 7. Handle Skip

**If `skip_analysis == true`:**
```
---

## Skipping Analysis

Transcription complete. Raw files ready.

Proceeding to output summary...
```

Store: `skip_analysis = true`, `analysis_results = null`

## 8. Load Next Step

```
Load and execute: @{workflow-dir}/step-07-output-summary.md
```

---

# SUCCESS METRICS

**Succeeds when:**
- ✅ Options presented
- ✅ Selections made
- ✅ Analyses generated
- ✅ Results captured
- ✅ Next step loaded

---

**Step Type:** Branch step (Multi-select with AI generation)
