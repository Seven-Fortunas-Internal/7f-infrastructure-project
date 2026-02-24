# Test-Before-Pass Requirement

**Version:** 1.0  
**Date:** 2026-02-23  
**Owner:** Jorge (VP AI-SecOps)  
**Category:** Testing & Quality

## Overview

The Test-Before-Pass Requirement ensures that NO feature is marked as "pass" without successful execution of all verification tests. This is a MANDATORY quality gate enforced by the autonomous implementation agent.

## Requirement Statement

**SHALL:** All features MUST have tests (unit, integration, or manual) that pass before being marked "pass" in feature_list.json.

**SHALL NOT:** The agent SHALL NOT mark a feature as "pass" if any verification test fails or is not executed.

## Test Categories

Every feature MUST be verified against THREE categories:

### 1. Functional Tests
**Purpose:** Verify what the feature does (user-facing behavior)

**Examples:**
- Execute 'gh auth status' and verify 'Logged in' message appears
- Dashboard displays AI news feed within 5 seconds
- Secret detection blocks commit with exposed API key

**Pass Criteria:** Feature behaves as specified in requirements

### 2. Technical Tests
**Purpose:** Verify how it's implemented (internal correctness)

**Examples:**
- Command exits with status code 0
- API response format matches schema
- Configuration file follows template structure

**Pass Criteria:** Implementation is technically sound and follows patterns

### 3. Integration Tests
**Purpose:** Verify how it works with other systems

**Examples:**
- GitHub API integration authenticates successfully
- Dashboard pulls data from correct repository
- Compliance evidence syncs to CISO Assistant

**Pass Criteria:** Feature integrates correctly with dependencies

## feature_list.json Tracking

### Verification Results Structure

```json
{
  "id": "FEATURE_XXX",
  "name": "Feature Name",
  "status": "pass",
  "attempts": 1,
  "verification_results": {
    "functional": "pass",
    "technical": "pass",
    "integration": "pass"
  }
}
```

### Status Transitions

**Pending → Pass:**
- REQUIRES: All three verification tests = "pass"
- REQUIRES: attempts >= 1 (feature was actually implemented)
- BLOCKS: If any test = "fail" or "pending"

**Pending → Fail:**
- OCCURS: If implementation complete but tests fail
- REQUIRES: attempts++ and retry with SIMPLIFIED or MINIMAL approach

**Pending/Fail → Blocked:**
- OCCURS: After 3 failed attempts
- REQUIRES: implementation_notes documenting failure reason

## Enforcement Mechanism

### Autonomous Agent Workflow

```
1. Select next pending feature
   ↓
2. Implement feature (STANDARD/SIMPLIFIED/MINIMAL)
   ↓
3. Run verification tests (ALL THREE CATEGORIES)
   ↓
4. Evaluate results:
   - All pass? → Mark "pass", commit, continue
   - Any fail? → Mark "fail", increment attempts, retry
   - 3rd failure? → Mark "blocked", document, continue
   ↓
5. Update feature_list.json
   ↓
6. Update progress tracking
   ↓
7. Commit (if pass)
   ↓
8. Loop to next feature
```

### Test Execution

**Location:** Verification tests are executed inline during feature implementation

**Format:**
```bash
# Functional test
if [test condition]; then
    FUNCTIONAL="pass"
else
    FUNCTIONAL="fail"
fi

# Technical test
if [test condition]; then
    TECHNICAL="pass"
else
    TECHNICAL="fail"
fi

# Integration test
if [test condition]; then
    INTEGRATION="pass"
else
    INTEGRATION="fail"
fi

# Overall status
if [[ "$FUNCTIONAL" == "pass" && "$TECHNICAL" == "pass" && "$INTEGRATION" == "pass" ]]; then
    OVERALL_STATUS="pass"
else
    OVERALL_STATUS="fail"
fi
```

**Logging:** All test results logged to autonomous_build_log.md

### Update Tracking

**Step 1: Update feature_list.json**
```bash
jq --arg id "$FEATURE_ID" \
   --arg status "$OVERALL_STATUS" \
   --argjson attempts "$ATTEMPTS" \
   --arg func "$FUNCTIONAL" \
   --arg tech "$TECHNICAL" \
   --arg integ "$INTEGRATION" \
   --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   '(.features[] | select(.id == $id)) |= (
     .status = $status |
     .attempts = $attempts |
     .verification_results = {
       "functional": $func,
       "technical": $tech,
       "integration": $integ
     } |
     .last_updated = $timestamp
   )' feature_list.json > feature_list.json.tmp && \
   mv feature_list.json.tmp feature_list.json
```

**Step 2: Commit (only if pass)**
```bash
if [[ "$OVERALL_STATUS" == "pass" ]]; then
    git add -A
    git commit -m "feat(FEATURE_XXX): ..."
fi
```

## Validation

### Pre-Commit Validation

**Script:** `scripts/validate-test-coverage.sh`

**Checks:**
1. All "pass" features have verification_results
2. All "pass" features have all three tests = "pass"
3. No "pass" features have attempts = 0 (untested)

### CI/CD Validation

**GitHub Actions Workflow:** `.github/workflows/test-coverage-validation.yml`

**Triggers:**
- On PR to main branch
- On push to autonomous-implementation branch

**Actions:**
1. Checkout repository
2. Run validation script
3. Fail if any "pass" features lack tests
4. Generate coverage report

## Metrics

### Test Coverage

**Target:** 100% of "pass" features have all three test categories passing

**Measurement:**
```bash
# Count "pass" features
PASS_COUNT=$(jq '[.features[] | select(.status == "pass")] | length' feature_list.json)

# Count "pass" features with all tests passing
TESTED_COUNT=$(jq '[.features[] | 
  select(.status == "pass" and 
         .verification_results.functional == "pass" and 
         .verification_results.technical == "pass" and 
         .verification_results.integration == "pass")] | 
  length' feature_list.json)

# Calculate coverage
COVERAGE=$((TESTED_COUNT * 100 / PASS_COUNT))
echo "Test coverage: ${COVERAGE}%"
```

### Quality Gates

**Gate 1: Feature Completion**
- Threshold: 100% of "pass" features have tests
- Failure: Block merge to main

**Gate 2: Zero Broken Features**
- Threshold: 0 features with status="pass" and any verification_result="fail"
- Failure: Immediate rollback and investigation

## Troubleshooting

### Issue: Feature marked "pass" without tests

**Symptom:** feature_list.json shows status="pass" but verification_results all "pending"

**Root Cause:** Agent bypassed test execution

**Solution:**
1. Revert feature to "pending"
2. Run validation script
3. Re-implement feature with tests
4. Update autonomous agent prompt to enforce tests

### Issue: Tests fail but feature marked "pass"

**Symptom:** feature_list.json shows status="pass" but some verification_results="fail"

**Root Cause:** Agent updated status incorrectly

**Solution:**
1. Revert feature to "fail"
2. Investigate test failures
3. Fix implementation or tests
4. Re-run verification

### Issue: Feature works but lacks integration tests

**Symptom:** Functional and technical pass, but integration="pending"

**Root Cause:** Integration test not written or not executed

**Solution:**
1. Write integration test
2. Execute test
3. Update verification_results
4. Mark "pass" only if integration test passes

## Compliance

### SOC 2 Alignment

**Control:** CC8.1 (Change Management)

**Evidence:**
- feature_list.json with verification_results
- autonomous_build_log.md with test execution logs
- Git commits tied to passing features

**Audit Trail:**
- Every "pass" feature has test results logged
- Timestamp of test execution
- Test criteria documented in app_spec.txt

### ISO 27001 Alignment

**Control:** A.14.2.9 (System Acceptance Testing)

**Evidence:**
- Verification criteria defined per feature
- Test execution before deployment
- Defect tracking (failed features)

## Resources

- **Feature List:** `feature_list.json`
- **Build Log:** `autonomous_build_log.md`
- **Agent Instructions:** Project CLAUDE.md (autonomous workflow section)
- **Validation Script:** `scripts/validate-test-coverage.sh` (to be created)

---

**Next Actions:**
1. Create validation script (scripts/validate-test-coverage.sh)
2. Create CI/CD workflow for test coverage validation
3. Run validation on current feature_list.json
4. Document any violations and remediate
