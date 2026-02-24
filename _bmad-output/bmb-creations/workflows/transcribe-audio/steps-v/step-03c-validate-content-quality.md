---
nextStepFile: './step-03d-calculate-score.md'
---

# STEP GOAL

Validate transcript content, word count, analysis presence, and metadata accuracy. This is the third of four validation check steps.

---

# MANDATORY EXECUTION RULES

1. **READ COMPLETELY** - Read entire step before acting
2. **FOLLOW SEQUENCE** - Execute all sections in order
3. **AUTO-PROCEED** - No user menu, continue automatically

---

# MANDATORY SEQUENCE

## 1. Retrieve Context

Get from workflow context:
- `report_content`, `report_metadata`, `content_metrics`
- `validation_checklist`, `validation_score`

## 2. Announce Phase

```
## Content Quality Validation (30 points)

Checking transcript and analysis content...
```

## 3. Check 5A: Transcript Not Empty

Test: Verify transcript section has content.

Extract transcript section from `report_content`, count words.

Validation:
```
if word_count > 10:
    transcript_not_empty = true, points = 10
elif word_count > 0:
    transcript_not_empty = "minimal", points = 3
else:
    transcript_not_empty = false, points = 0
```

Display:
```
✅/⚠️/❌ Transcript: [PASS/MINIMAL/FAIL]
   Word count: [count]
   Status: [adequate/minimal/empty]
   Points: [10/3/0]/10
```

Update checklist and add points.

## 4. Check 5B: Reasonable Word Count

Test: Check if word count matches audio duration.

Average speaking rate: 135 words/minute

Execute:
```
if duration available:
    expected = duration_minutes * 135
    actual = word_count
    ratio = actual / expected

    if 0.5 <= ratio <= 2.0:
        reasonable = true, points = 5
    else:
        reasonable = false, points = 2
else:
    # Can't validate without duration
    reasonable = "unknown", points = 5
```

Display:
```
✅/⚠️/? Word Count: [PASS/QUESTIONABLE/UNKNOWN]
   Duration: [duration or "not recorded"]
   Expected: ~[estimate] words
   Actual: [actual] words
   Ratio: [ratio or "N/A"]
   Points: [5 or 2]/5
```

Update checklist and add points.

## 5. Check 5C: Analysis Present

Test: If analysis configured, verify sections have content.

Execute:
```
if analysis_types == "None":
    # Not expected
    analysis_present = "N/A", points = 10
else:
    # Check each configured analysis
    for each type in analysis_types:
        if section exists AND has >50 words:
            analysis_ok += 1

    if all present:
        analysis_present = true, points = 10
    elif some present:
        analysis_present = "partial", points = 5
    else:
        analysis_present = false, points = 0
```

Display:
```
✅/⚠️/❌/N/A Analysis: [PASS/PARTIAL/FAIL/N/A]
   Expected: [list or "None"]
   Found: [count]/[total]
   Missing: [list if any]
   Points: [10/5/0]/10
```

Update checklist and add points.

## 6. Check 5D: Metadata Accuracy

Test: Verify metadata values are valid and consistent.

Checks:
- Date format: YYYY-MM-DD pattern
- Model: base/small/medium/large
- Language: valid code or "auto"
- Filename: valid audio extension

Execute:
```
checks_passed = 0
if date matches YYYY-MM-DD: checks_passed += 1
if model in [base,small,medium,large]: checks_passed += 1
if language valid: checks_passed += 1
if filename has audio extension: checks_passed += 1

if checks_passed == 4:
    metadata_accurate = true, points = 5
elif checks_passed >= 3:
    metadata_accurate = "mostly", points = 3
else:
    metadata_accurate = false, points = 0
```

Display:
```
✅/⚠️/❌ Metadata: [PASS/MOSTLY/FAIL]
   Date: [valid/invalid]
   Model: [valid/invalid]
   Language: [valid/invalid]
   Filename: [valid/invalid]
   Points: [5/3/0]/5
```

Update checklist and add points.

## 7. Display Subscore

```
---
**Content Quality Score: [score]/30**
---
```

## 8. Store State

Update workflow context:
- `validation_checklist` (with content quality results)
- `validation_score` (with added points)
- `content_quality_subscore`

## 9. Load Next Step

```
Load and execute: @{workflow-dir}/step-03d-calculate-score.md
```

Display: "Content quality validation complete. Calculating total score..."

---

# SUCCESS METRICS

**Succeeds when:**
- ✅ All 4 checks executed
- ✅ Checklist updated
- ✅ Score updated
- ✅ Next step loaded

---

**Step Type:** Validation (Auto-proceed)
**Subscore:** 30 points maximum
