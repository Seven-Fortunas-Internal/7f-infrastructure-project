---
nextStepFile: './step-03b-validate-report-quality.md'
---

# STEP GOAL

Validate file structure, folder organization, file presence, and file organization. This is the first of four validation check steps.

---

# MANDATORY EXECUTION RULES

1. **READ COMPLETELY** - Read this entire step file before taking any action
2. **FOLLOW SEQUENCE** - Execute all numbered sections in order
3. **AUTO-PROCEED** - No user menu, auto-proceed after checks

---

# MANDATORY SEQUENCE

## 1. Retrieve Context

Get from workflow context:
- `report_path`, `report_dir`
- `report_metadata`, `content_metrics`
- `validation_checklist`, `validation_score`

## 2. Announce Phase

```
## File Structure Validation (20 points)

Checking file organization and presence...
```

## 3. Check 3A: Report Exists

Report was already loaded in step-01.

**Result:** ✅ PASS

Update checklist: `file_structure.report_exists = true`

Add 5 points to `validation_score`.

## 4. Check 3B: Dated Directory

Test: Verify report is in `transcriptions/YYYY-MM-DD/` structure.

Execute:
```python
if report_dir matches "transcriptions/\d{4}-\d{2}-\d{2}":
    dated_directory = true, points = 5
else:
    dated_directory = false, points = 0
```

Display:
```
✅/❌ Dated Directory: [PASS/FAIL]
   Path: [report_dir]
   Points: [5 or 0]/5
```

Update checklist and add points.

## 5. Check 3C: Raw Files Exist

Test: Verify raw transcript files exist.

Get base filename from `report_metadata['audio_file']`.

Check for expected files:
```bash
ls -1 "[report_dir]"/[base_filename].*
```

Expected: `.txt` (always), `.srt`, `.vtt`, `.json` (if configured)

Validation:
```
if all expected found: points = 5
elif some found: points = 2
else: points = 0
```

Display:
```
✅/⚠️/❌ Raw Files: [PASS/PARTIAL/FAIL]
   Expected: [count], Found: [count]
   Missing: [list if any]
   Points: [5/2/0]/5
```

Update checklist and add points.

## 6. Check 3D: Organization

Test: All files in same directory.

Execute:
```bash
find "[report_dir]" -maxdepth 1 -type f | wc -l
```

Validation:
```
if all transcript files in report_dir:
    organization_correct = true, points = 5
else:
    organization_correct = false, points = 0
```

Display:
```
✅/❌ Organization: [PASS/FAIL]
   Files in directory: [count]
   Points: [5 or 0]/5
```

Update checklist and add points.

## 7. Display Subscore

```
---
**File Structure Score: [score]/20**
---
```

## 8. Store State

Update workflow context:
- `validation_checklist` (with file structure results)
- `validation_score` (with added points)
- `file_structure_subscore`

## 9. Load Next Step

```
Load and execute: @{workflow-dir}/step-03b-validate-report-quality.md
```

Display: "File structure validation complete. Proceeding to report quality..."

---

# SUCCESS METRICS

**Succeeds when:**
- ✅ All 4 checks executed
- ✅ Checklist updated
- ✅ Score updated
- ✅ Next step loaded

---

**Step Type:** Validation (Auto-proceed)
**Subscore:** 20 points maximum
