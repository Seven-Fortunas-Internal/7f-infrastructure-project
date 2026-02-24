# Circuit Breaker Rules

**Purpose:** Define circuit breaker logic, trigger conditions, and reset procedures for autonomous implementation workflow.

---

## Overview

The circuit breaker pattern prevents infinite loops and runaway failures in autonomous implementation by automatically stopping execution after repeated failures.

**Key Concept:** If implementation repeatedly fails to make progress, human intervention is needed to diagnose and fix root causes.

---

## Circuit Breaker States

### HEALTHY
- **Meaning:** Normal operation, implementation proceeding successfully
- **Condition:** consecutive_failures < threshold
- **Workflow Behavior:** Continue implementing features
- **Display:** ✓ HEALTHY

### TRIGGERED
- **Meaning:** Too many consecutive failures, execution halted
- **Condition:** consecutive_failures >= threshold
- **Workflow Behavior:** Exit immediately with code 42, generate diagnostic report
- **Display:** 🔴 TRIGGERED

### COMPLETE
- **Meaning:** Implementation finished successfully (all features done)
- **Condition:** All features pass or blocked, workflow completed normally
- **Workflow Behavior:** Normal completion (step-14)
- **Display:** ✓ COMPLETE

---

## Threshold Configuration

### Default Threshold: 5

**Recommended Range:** 3-10

**Considerations:**

| Threshold | Characteristics | Use Case |
|-----------|----------------|----------|
| 1-2 | Very sensitive, triggers quickly | High-risk environments, expensive operations |
| 3-5 | Balanced, allows reasonable retries | Most implementations (recommended) |
| 6-10 | More tolerant, allows many retries | Complex features with expected failures |
| 11+ | Too high, defeats purpose | Not recommended |

**Configuration:**
- Stored in claude-progress.txt as `circuit_breaker_threshold=N`
- Editable via EDIT mode
- Applied immediately (no restart needed)

---

## Consecutive Failures Tracking

### What Counts as a Session Failure?

**Session Succeeds IF:**
- At least ONE feature changed to "pass" status
- Progress was made

**Session Fails IF:**
- ZERO features changed to "pass" status
- No meaningful progress

### Failure Counter Logic

**Increment consecutive_failures:**
- When session completes with no features passed
- After step-13 determines session failed

**Reset consecutive_failures to 0:**
- When session completes with at least one feature passed
- After step-13 determines session succeeded
- Manual reset via EDIT mode

**Important:** Failures must be CONSECUTIVE. A single success resets the counter.

---

## Trigger Logic

### Automatic Trigger

**Step-13 checks after EVERY session:**

```bash
if [[ consecutive_failures >= threshold ]]; then
    circuit_breaker_status=TRIGGERED
    exit 42
fi
```

### Trigger Actions

When circuit breaker triggers:

1. **Update Status**
   - Set circuit_breaker_status=TRIGGERED in claude-progress.txt

2. **Generate Report**
   - Create autonomous_summary_report.md
   - Include:
     - Current feature statistics
     - Last 5 sessions summary
     - All blocked features
     - All failed features (retry eligible)
     - Recommended actions

3. **Exit with Code 42**
   - Distinct exit code for circuit breaker
   - Allows external scripts to detect circuit breaker vs other errors

4. **Display Message**
   ```
   ═══════════════════════════════════════════════════════
     CIRCUIT BREAKER TRIGGERED
     Human Intervention Required
   ═══════════════════════════════════════════════════════

   Consecutive Failures: N
   Threshold: M

   Review autonomous_summary_report.md for details.
   ```

---

## Pre-Check Logic (Session 2+)

### Before Starting Implementation

**Step-01b pre-checks circuit breaker status:**

```bash
if [[ circuit_breaker_status == "TRIGGERED" ]]; then
    echo "Circuit breaker already TRIGGERED"
    echo "Reset via EDIT mode before resuming"
    exit 42
fi
```

**Purpose:** Prevent wasted work if circuit breaker already triggered.

---

## Reset Procedures

### Option 1: Manual Reset via EDIT Mode

**Steps:**
1. Run workflow in EDIT mode:
   ```bash
   /bmad-bmm-run-autonomous-implementation --mode=edit
   ```

2. Select [C] Circuit Breaker

3. Choose reset option:
   - [F] Reset consecutive_failures to 0
   - [A] Reset all (failures + status)

4. Exit EDIT mode

5. Resume CREATE mode

**When to Use:**
- After fixing root cause of failures
- After addressing blocked features manually
- When ready to retry implementation

### Option 2: Adjust Threshold

**Steps:**
1. Run EDIT mode
2. Select [C] Circuit Breaker
3. Select [T] Change Threshold
4. Enter new threshold (higher = more tolerant)

**When to Use:**
- Threshold too aggressive for feature complexity
- Expected failure rate higher than threshold allows
- Need more attempts before intervention

**Caution:** Don't just increase threshold without fixing root causes.

---

## Diagnostic Workflow

### When Circuit Breaker Triggers

**1. Review Summary Report**
```bash
cat {project_folder}/autonomous_summary_report.md
```

**Check for:**
- Common failure patterns
- Blocked features (external dependencies)
- Failed features (retry eligible)

**2. Identify Root Causes**

**Common causes:**
- Missing external dependencies (APIs, credentials, tools)
- Incorrect app_spec.txt (unrealistic features)
- Environmental issues (permissions, network)
- Implementation agent limitations

**3. Take Corrective Action**

**For external dependencies:**
- Install missing tools
- Configure API access
- Set up credentials
- Fix permissions

**For app_spec issues:**
- Review feature specifications
- Simplify complex features
- Remove unrealistic features
- Use EDIT mode to mark features as blocked manually

**For environmental issues:**
- Fix network connectivity
- Correct file permissions
- Install required software

**4. Reset Circuit Breaker**
- Use EDIT mode to reset consecutive_failures
- Status will auto-reset to HEALTHY

**5. Resume Implementation**
```bash
/bmad-bmm-run-autonomous-implementation
```

---

## Status Consistency Rules

### Status Determination Logic

**Status should be TRIGGERED when:**
```
consecutive_failures >= threshold
```

**Status should be HEALTHY when:**
```
consecutive_failures < threshold
AND circuit_breaker_status != COMPLETE
```

**Status should be COMPLETE when:**
```
Workflow finished normally (step-14 reached)
```

### Automatic Status Updates

**Circuit breaker status is automatically updated in:**

- **Step-13:** After determining session outcome
  - Sets TRIGGERED if consecutive_failures >= threshold
  - Keeps HEALTHY if consecutive_failures < threshold

- **Step-14:** After completion
  - Sets COMPLETE when all features done

- **EDIT mode:** When user modifies
  - Auto-resets to HEALTHY if consecutive_failures set to 0
  - Auto-adjusts based on new threshold

---

## Circuit Breaker Validation

### Consistency Checks (VALIDATE Mode)

**VALIDATE mode (step-03) checks:**

1. **Threshold range:** 1-99 (valid), 3-10 (recommended)
2. **Consecutive failures range:** 0-99
3. **Status consistency:**
   - If consecutive_failures >= threshold, status should be TRIGGERED
   - If consecutive_failures < threshold, status should be HEALTHY or COMPLETE
4. **Status value:** Valid enum (HEALTHY/TRIGGERED/COMPLETE)
5. **Trigger logic:** Status correctly reflects trigger conditions

**Validation failures indicate:**
- Manual edits to tracking files
- Workflow bugs (report if found)
- Inconsistent state requiring correction

---

## Best Practices

### For Users

1. **Monitor Consecutive Failures**
   - Check claude-progress.txt regularly
   - If failures incrementing, investigate early

2. **Don't Just Increase Threshold**
   - Increasing threshold without fixing causes wastes time
   - Circuit breaker is a symptom, not the problem

3. **Review Summary Report When Triggered**
   - Report contains diagnostic information
   - Identify patterns before resetting

4. **Fix Root Causes Before Resuming**
   - Circuit breaker will trigger again if issues persist
   - Address underlying problems first

### For Workflow Designers

1. **Set Threshold Based on Feature Complexity**
   - Simple features: lower threshold (3-5)
   - Complex features: higher threshold (5-10)

2. **Log Failure Reasons Clearly**
   - Help users diagnose issues
   - Include actionable error messages

3. **Provide Diagnostic Tools**
   - Summary reports
   - Validation mode
   - Clear status indicators

---

## Circuit Breaker Metrics

### Track Over Time

**Useful metrics:**
- Threshold value (changes over time)
- Consecutive failures (trend)
- Number of circuit breaker triggers
- Time to resolution (trigger → reset)
- Features completed before trigger

**Analysis:**
- High trigger rate → threshold too low or features too complex
- Long resolution time → root causes hard to diagnose
- Low consecutive failures at trigger → threshold working correctly

---

## Exit Codes

| Exit Code | Meaning | Circuit Breaker State |
|-----------|---------|----------------------|
| 0 | Normal exit (no work or validation complete) | Not triggered |
| 42 | Circuit breaker triggered | TRIGGERED |
| 1-6 | Prerequisite failures | N/A |
| 8 | Invalid app_spec.xml | N/A |
| 10 | Corrupted feature_list.json | N/A |
| 20+ | Step-specific errors | Varies |

**Note:** Exit code 42 is ONLY for circuit breaker triggers.

---

## Troubleshooting

### Q: Circuit breaker triggered but consecutive_failures < threshold?

**A:** Inconsistent state. Use VALIDATE mode to check, then EDIT mode to correct.

### Q: How do I prevent circuit breaker entirely?

**A:** Set threshold very high (99), but NOT RECOMMENDED. Circuit breaker protects against runaway failures.

### Q: Circuit breaker keeps triggering even after reset?

**A:** Root cause not fixed. Review summary report, fix underlying issues before resuming.

### Q: Can I disable circuit breaker?

**A:** No. Circuit breaker is fundamental to bounded autonomy. Adjust threshold if needed, but don't circumvent.

---

**Version:** 1.0.0
**Created:** 2026-02-17
**Applies To:** run-autonomous-implementation workflow
