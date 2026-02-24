---
nextStepFile: './step-03c-validate-content-quality.md'
---

# STEP GOAL

Validate markdown syntax, frontmatter completeness, and required sections presence. This is the second of four validation check steps.

---

# MANDATORY EXECUTION RULES

1. **READ COMPLETELY** - Read entire step before acting
2. **FOLLOW SEQUENCE** - Execute all sections in order
3. **AUTO-PROCEED** - No user menu, continue automatically

---

# MANDATORY SEQUENCE

## 1. Retrieve Context

Get from workflow context:
- `report_content`, `report_metadata`
- `validation_checklist`, `validation_score`

## 2. Announce Phase

```
## Report Quality Validation (30 points)

Checking markdown syntax and structure...
```

## 3. Check 4A: Valid Markdown

Test: Check report content for valid markdown syntax.

Execute checks:
- Frontmatter present (starts with `---`)
- Code blocks balanced (count ``` markers, must be even)
- Headers use # syntax

Validation:
```
if all checks pass:
    valid_markdown = true, points = 10
else:
    valid_markdown = false, points = 0
```

Display:
```
✅/❌ Markdown Syntax: [PASS/FAIL]
   Frontmatter: [present/missing]
   Code blocks: [balanced/unbalanced]
   Headers: [valid/invalid]
   Points: [10 or 0]/10
```

Update checklist and add points.

## 4. Check 4B: Complete Frontmatter

Test: Verify frontmatter has required fields.

Required: `audio_file`, `date`, `model`, `language`

Parse frontmatter YAML and check each field.

Validation:
```
if all 4 required present:
    complete_frontmatter = true, points = 10
elif 3/4 present:
    complete_frontmatter = "partial", points = 5
else:
    complete_frontmatter = false, points = 0
```

Display:
```
✅/⚠️/❌ Frontmatter: [PASS/PARTIAL/FAIL]
   Required: [count]/4
   Missing: [list if any]
   Points: [10/5/0]/10
```

Update checklist and add points.

## 5. Check 4C: Required Sections

Test: Verify report has required sections.

Required sections:
- Metadata section
- Transcript section
- Raw Files section

Optional (based on `analysis_types`):
- AI Analysis sections (if configured)

Search report_content for section headers.

Validation:
```
if all required present AND analysis sections correct:
    required_sections = true, points = 10
elif most present:
    required_sections = "partial", points = 5
else:
    required_sections = false, points = 0
```

Display:
```
✅/⚠️/❌ Sections: [PASS/PARTIAL/FAIL]
   Required: [count]/3
   Analysis: [status]
   Missing: [list if any]
   Points: [10/5/0]/10
```

Update checklist and add points.

## 6. Display Subscore

```
---
**Report Quality Score: [score]/30**
---
```

## 7. Store State

Update workflow context:
- `validation_checklist` (with report quality results)
- `validation_score` (with added points)
- `report_quality_subscore`

## 8. Load Next Step

```
Load and execute: @{workflow-dir}/step-03c-validate-content-quality.md
```

Display: "Report quality validation complete. Proceeding to content quality..."

---

# SUCCESS METRICS

**Succeeds when:**
- ✅ All 3 checks executed
- ✅ Checklist updated
- ✅ Score updated
- ✅ Next step loaded

---

**Step Type:** Validation (Auto-proceed)
**Subscore:** 30 points maximum
