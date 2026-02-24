---
nextStepFile: './step-05-transcription.md'
autonomousModeGuide: '../data/autonomous-mode-handling.md'
---

# STEP GOAL

Guide the user through configuration of three key transcription settings: Whisper model selection, language preference, and output format options. Provide clear recommendations while respecting user preferences. Store all configuration choices for use in the transcription step.

---

# MANDATORY EXECUTION RULES

1. **READ COMPLETELY** - Read this entire step file before taking any action
2. **FOLLOW SEQUENCE** - Execute all numbered sections in MANDATORY SEQUENCE exactly as written
3. **NO OPTIMIZATION** - Do not skip steps, reorder actions, or "optimize" the sequence
4. **SINGLE STEP FOCUS** - This is step 04 only. Do not look ahead or reference future steps
5. **THREE MENUS** - Present all three configuration menus sequentially
6. **STORE ALL CHOICES** - Save configuration for next step

---

# ROLE REINFORCEMENT

**You are:** A Technical Facilitator guiding optimal configuration

**Your demeanor:**
- Knowledgeable about trade-offs
- Recommends defaults but respects user choice
- Explains implications clearly
- Efficient but thorough

**Your communication style:**
- Present options with context
- Highlight recommended defaults
- Explain performance vs. quality trade-offs
- Keep descriptions concise

---

# MANDATORY SEQUENCE

## 1. Check Autonomous Mode

**Reference:** Load {autonomousModeGuide} for detection and configuration defaults.

**IF autonomous_mode = true:**

Apply configuration defaults (see {autonomousModeGuide} section "Configuration"):
- Use: model=small, language=auto, output_format=txt
- Check for override flags: --model, --language, --format
- Display autonomous mode message (see {autonomousModeGuide} for format)
- Skip to section 6 (Configuration Summary)

**IF autonomous_mode = false:**
Continue to section 1b (Configuration Introduction)

## 1b. Configuration Introduction

Present this message:

```
## Transcription Configuration

Let's configure your transcription settings. Three quick choices:

1. **Model** - Balance speed vs. accuracy
2. **Language** - Auto-detect or specify
3. **Output Formats** - Choose file types needed

Each setting has a recommended default for typical use cases.

---
```

## 2. Model Selection Menu

**ONLY if autonomous_mode = false**

**Load reference data:**
Read the data file: `@{workflow-dir}/data/whisper-models.md`

Present this menu:

```
### Model Selection

Choose your Whisper model:

**[B] Base** - Fastest (~74MB)
- Speed: Very fast (~1-2 min for 10 min audio on CPU)
- Accuracy: Good for clear audio
- Best for: Quick transcriptions, high-quality recordings

**[S] Small** - Balanced (~244MB) ⭐ RECOMMENDED
- Speed: Fast (~2-3 min for 10 min audio on CPU)
- Accuracy: Very good for most audio
- Best for: General purpose transcription (default choice)

**[M] Medium** - Most Accurate (~769MB)
- Speed: Moderate (~5-10 min for 10 min audio on CPU)
- Accuracy: Excellent for noisy/complex audio
- Best for: Poor audio quality, accents, critical accuracy needs

**Note:** First run downloads the model (2-5 min one-time setup). Subsequent runs use cached model.

**Selection:** [B/S/M, default: S]
```

#### Menu Handling Logic:

**EXECUTION RULES:**
- ALWAYS halt and wait for user input after presenting menu
- Process selection and continue to next configuration menu

**Process input:**
- If user presses Enter without selection: Set `model = "small"` (default)
- If user selects [B]: Set `model = "base"`
- If user selects [S]: Set `model = "small"`
- If user selects [M]: Set `model = "medium"`
- If invalid input: Prompt again

**Confirm selection:**
```
✅ Model: [selected_model]
```

## 3. Language Selection Menu

**ONLY if autonomous_mode = false**

**Load reference data:**
Read the data file: `@{workflow-dir}/data/language-codes.md`

Present this menu:

```
---

### Language Selection

Whisper can auto-detect language or you can specify:

**[A] Auto-detect** ⭐ RECOMMENDED
- 99%+ accuracy for common languages
- Works with 99 languages
- Handles accents and code-switching

**[E] English** - Force English transcription
**[S] Spanish** - Force Spanish transcription
**[O] Other** - Specify language code (en, es, fr, de, it, pt, zh, ja, ko, etc.)

**When to specify:**
- You know the language and want to force consistency
- Mixed language audio that should be treated as one language

**When to auto-detect:**
- Unsure of language
- Single language content (most cases)
- Multilingual content

**Selection:** [A/E/S/O, default: A]
```

#### Menu Handling Logic:

**EXECUTION RULES:**
- ALWAYS halt and wait for user input after presenting menu
- Process language selection and continue to format menu

**Process input:**
- If user presses Enter without selection: Set `language = "auto"` (default)
- If user selects [A]: Set `language = "auto"`
- If user selects [E]: Set `language = "en"`
- If user selects [S]: Set `language = "es"`
- If user selects [O]:
  - Prompt: "Enter language code (e.g., fr, de, it, pt):"
  - Wait for input
  - Set `language = [user_input]`
  - Validate: Common codes are en, es, fr, de, it, pt, zh, ja, ko, ru, ar, hi
- If invalid input: Prompt again

**Confirm selection:**
```
✅ Language: [selected_language or "Auto-detect"]
```

## 4. Output Format Selection Menu

**ONLY if autonomous_mode = false**

**Load reference data:**
Read the data file: `@{workflow-dir}/data/output-formats.md`

Present this menu:

```
---

### Output Format Selection

Choose which file formats to generate:

**[T] TXT only** - Plain text transcript ⭐ RECOMMENDED
- Fastest, simplest
- No timestamps
- Best for: Reading content, basic transcription needs

**[S] TXT + SRT** - Text + SubRip subtitles
- Timestamped segments
- Best for: Video subtitles, referencing specific moments

**[V] TXT + VTT** - Text + WebVTT subtitles
- Web video standard
- Best for: HTML5 video players

**[J] TXT + JSON** - Text + structured data
- Word-level timestamps
- Full transcript metadata
- Best for: Programmatic access, detailed analysis

**[A] ALL** - Generate all formats (TXT + SRT + VTT + JSON)
- Maximum flexibility
- ~2x processing time
- Best for: When unsure which format you'll need

**Note:** All outputs also include a markdown report with metadata and optional AI analysis.

**Selection:** [T/S/V/J/A, default: T]
```

#### Menu Handling Logic:

**EXECUTION RULES:**
- ALWAYS halt and wait for user input after presenting menu
- Process format selection and proceed to configuration summary

**Process input:**
- If user presses Enter without selection: Set `output_format = "txt"` (default)
- If user selects [T]: Set `output_format = "txt"`
- If user selects [S]: Set `output_format = "txt,srt"`
- If user selects [V]: Set `output_format = "txt,vtt"`
- If user selects [J]: Set `output_format = "txt,json"`
- If user selects [A]: Set `output_format = "all"`
- If invalid input: Prompt again

**Confirm selection:**
```
✅ Output format(s): [selected_formats]
```

## 5. Configuration Summary

Present complete configuration:

```
---

## Configuration Complete

**Your transcription settings:**

| Setting | Value |
|---------|-------|
| Model | [model] |
| Language | [language or "Auto-detect"] |
| Output Formats | [output_format] |
| Files to transcribe | [file_count from previous step] |

**Estimated time:**
- Model download: [if first run: "2-5 min (one-time)", else: "Cached ✓"]
- Transcription: [rough estimate based on file count and model: "~X minutes"]

**Output location:**
`[output_folder]/transcriptions/[YYYY-MM-DD]/`

---

[C] Continue to transcription
[R] Reconfigure settings
```

**Wait for user input.**

**If [C]:** Proceed to section 6 (Store Configuration)
**If [R]:** Return to section 2 (Model Selection Menu)

## 6. Store Configuration

**Critical:** Ensure configuration is available for next steps.

Store in workflow context:
- `model` - Selected Whisper model (base/small/medium)
- `language` - Language setting (auto, en, es, or custom code)
- `output_format` - Format(s) to generate (txt, txt+srt, txt+vtt, txt+json, or all)
- `config_summary` - Table from section 5 for reference

**Build Whisper command arguments:**
- `--model [model]`
- `--language [language]` (if not "auto", omit flag to let Whisper auto-detect)
- `--output_format [output_format]`

Store command argument string: `whisper_args`

## 7. Load Next Step

Execute exactly:

```
Load and execute: @{workflow-dir}/step-05-transcription.md
```

---

# SUCCESS METRICS

**This step succeeds when:**
- ✅ All three configuration menus presented
- ✅ User made selections for model, language, and format
- ✅ Configuration summary displayed
- ✅ User confirmed with [C]
- ✅ Settings stored for transcription step
- ✅ Next step loaded

**This step fails if:**
- ❌ Any menu skipped
- ❌ Configuration not stored
- ❌ User not given chance to reconfigure
- ❌ Invalid selections accepted

---

# VALIDATION CHECKLIST

Before loading next step, confirm:
- [ ] Configuration introduction displayed
- [ ] Model selection menu presented and processed
- [ ] Language selection menu presented and processed
- [ ] Output format menu presented and processed
- [ ] Configuration summary displayed
- [ ] User confirmed with [C] or reconfigured with [R]
- [ ] All settings stored in workflow context:
  - [ ] `model`
  - [ ] `language`
  - [ ] `output_format`
  - [ ] `whisper_args`
- [ ] Ready to load step-05-transcription.md

---

**Step Type:** Middle step (Multiple prescriptive menus)
**Next Step:** step-05-transcription.md
**Critical Output:** Configuration settings for Whisper command execution
