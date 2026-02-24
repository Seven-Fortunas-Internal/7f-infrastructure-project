# Verification Criteria Guide

**Purpose:** Define how to interpret and test verification criteria from app_spec.txt for autonomous feature implementation.

---

## Overview

Verification criteria validate that a feature implementation meets requirements across three dimensions:

1. **Functional:** Does it work as intended for users?
2. **Technical:** Does it meet technical/quality standards?
3. **Integration:** Does it work with other components?

---

## Verification Criteria Structure (app_spec.txt)

### XML Format

```xml
<feature id="F001">
  <verification_criteria>
    <functional>Repository can be viewed with 'gh repo view'</functional>
    <technical>Repository settings match specifications (private, description)</technical>
    <integration>Repository accessible via GitHub API</integration>
  </verification_criteria>
</feature>
```

### Extracted Data

Stored in feature_list.json:
```json
{
  "id": "F001",
  "verification_criteria": {
    "functional": "Repository can be viewed with 'gh repo view'",
    "technical": "Repository settings match specifications (private, description)",
    "integration": "Repository accessible via GitHub API"
  }
}
```

---

## Test Execution (step-10)

### Test Order

Always execute in this order:
1. Functional
2. Technical
3. Integration

**Why?** Functional test verifies basic operation; if it fails, technical/integration tests likely irrelevant.

### Test Result Types

| Result | Meaning | Affects Overall? |
|--------|---------|------------------|
| `pass` | Test succeeded | ✅ Yes (must pass) |
| `fail` | Test failed | ❌ Yes (causes overall fail) |
| `skip` | No criteria specified | ⊘ No (ignored) |

### Overall Status Logic

```
Overall PASS if: All non-skipped tests pass
Overall FAIL if: Any test fails
```

**Examples:**
- Functional=pass, Technical=pass, Integration=pass → **PASS**
- Functional=pass, Technical=fail, Integration=pass → **FAIL**
- Functional=pass, Technical=skip, Integration=skip → **PASS** (functional passed, others skipped)
- All tests=skip → **PASS** (no criteria to fail)

---

## Functional Criteria

### Purpose
Test if feature works as intended for end-users or external callers.

### What to Test

**Core Functionality:**
- Feature performs its primary purpose
- Expected behavior occurs
- Output/result is correct

**Examples by Feature Type:**

| Feature Type | Functional Test |
|--------------|-----------------|
| GitHub Repo | Repo exists and viewable |
| API Endpoint | API returns expected data |
| Configuration | Setting applied and active |
| File Creation | File exists with correct content |
| Service Setup | Service running and responsive |

### How to Test

**Direct Verification:**
```bash
# Check if entity exists
gh repo view "$ORG/$REPO"

# Check if API responds
curl -f "$API_ENDPOINT"

# Check if file exists with content
[[ -f "$FILE" ]] && grep -q "$EXPECTED" "$FILE"

# Check if service running
systemctl is-active "$SERVICE"
```

**Functional vs Non-Functional:**
- ✅ Functional: "Does it do what it's supposed to do?"
- ❌ Not functional: "Is the code pretty?" (that's technical)

### Pass Criteria

**Functional test passes when:**
- Core behavior works as described in feature spec
- User/system can successfully use the feature
- Expected outcome achieved

**Example:**
```bash
# Functional: Can we view the repo?
if gh repo view "$ORG/$REPO" >/dev/null 2>&1; then
    FUNCTIONAL_RESULT="pass"
else
    FUNCTIONAL_RESULT="fail"
    FUNCTIONAL_ERROR="Repository not viewable"
fi
```

---

## Technical Criteria

### Purpose
Test if implementation meets technical standards, code quality, or configuration correctness.

### What to Test

**Code Quality:**
- Syntax correctness
- Linting passes
- Follows conventions

**Configuration Correctness:**
- Required fields present
- Valid format (JSON, YAML, XML)
- Settings match specifications

**Standards Compliance:**
- Naming conventions
- File permissions
- Security settings

**Examples by Feature Type:**

| Feature Type | Technical Test |
|--------------|----------------|
| GitHub Repo | Repo settings (private, description) correct |
| API Endpoint | OpenAPI spec valid, follows REST conventions |
| Configuration | YAML syntax valid, required fields present |
| File Creation | File permissions correct, format valid |
| Service Setup | Service configured per standards, logs properly |

### How to Test

**Syntax Validation:**
```bash
# Validate JSON
jq empty config.json

# Validate YAML
yamllint config.yaml

# Validate XML
xmllint --noout spec.xml
```

**Settings Verification:**
```bash
# Check repo settings
VISIBILITY=$(gh repo view "$ORG/$REPO" --json visibility -q .visibility)
if [[ "$VISIBILITY" == "PRIVATE" ]]; then
    TECHNICAL_RESULT="pass"
fi

# Check required fields
if jq -e '.required_field' config.json >/dev/null; then
    TECHNICAL_RESULT="pass"
fi
```

**Standards Compliance:**
```bash
# Check naming convention
if [[ "$REPO_NAME" =~ ^[a-z0-9-]+$ ]]; then
    TECHNICAL_RESULT="pass"
fi

# Check file permissions
if [[ $(stat -c %a "$FILE") == "644" ]]; then
    TECHNICAL_RESULT="pass"
fi
```

### Pass Criteria

**Technical test passes when:**
- Implementation meets quality/standards
- Configuration is correct
- No technical debt introduced

---

## Integration Criteria

### Purpose
Test if feature integrates correctly with other components, systems, or services.

### What to Test

**Connectivity:**
- External API accessible
- Service can communicate with dependencies
- Network connectivity works

**Cross-Feature Dependencies:**
- Feature works with other features
- References resolve correctly
- Data flows between components

**Permissions & Access:**
- Feature has required permissions
- Authentication works
- Authorization correct

**Examples by Feature Type:**

| Feature Type | Integration Test |
|--------------|------------------|
| GitHub Repo | Repo accessible via GitHub API |
| API Endpoint | Endpoint callable from other services |
| Configuration | Config used by dependent services |
| File Creation | File referenced by other components |
| Service Setup | Service communicates with dependencies |

### How to Test

**API Connectivity:**
```bash
# Test GitHub API access
if gh api "repos/$ORG/$REPO" >/dev/null 2>&1; then
    INTEGRATION_RESULT="pass"
fi

# Test REST API endpoint
if curl -f "$API_ENDPOINT" >/dev/null 2>&1; then
    INTEGRATION_RESULT="pass"
fi
```

**Cross-Feature References:**
```bash
# Check if symlink resolves
if [[ -L "$SYMLINK" ]] && [[ -e "$SYMLINK" ]]; then
    INTEGRATION_RESULT="pass"
fi

# Check if service can read config
if service_command --check-config config.yaml; then
    INTEGRATION_RESULT="pass"
fi
```

**Permissions:**
```bash
# Check if can perform required operation
if gh repo view "$ORG/$REPO" --json permissions -q .permissions.admin | grep -q true; then
    INTEGRATION_RESULT="pass"
fi
```

### Pass Criteria

**Integration test passes when:**
- Feature accessible by dependent systems
- Communication works bidirectionally
- Permissions allow required operations

---

## Writing Good Verification Criteria (for app_spec.txt authors)

### Functional Criteria Guidelines

**Good:**
- "Repository can be cloned with 'git clone'"
- "API returns 200 OK with valid JSON response"
- "Configuration file activates feature when service restarted"

**Bad:**
- "Code is well-written" (subjective, not testable)
- "Implementation is fast" (vague)
- "Repo created" (too generic, what's the test?)

### Technical Criteria Guidelines

**Good:**
- "Repository visibility set to 'private'"
- "API follows OpenAPI 3.0 specification"
- "Configuration file uses YAML format with required fields: name, version"

**Bad:**
- "Good code quality" (subjective)
- "Fast response time" (no specific threshold)
- "Proper configuration" (what does "proper" mean?)

### Integration Criteria Guidelines

**Good:**
- "Repository accessible via GitHub API endpoint 'GET /repos/{org}/{repo}'"
- "API authenticates using OAuth2 with provided credentials"
- "Configuration file readable by systemd service"

**Bad:**
- "Works with other features" (which features?)
- "Integrates well" (how?)
- "Can be accessed" (accessed how, by whom?)

### Testability Checklist

For each criterion, ask:
- ✅ Can it be tested automatically with a command/script?
- ✅ Is the expected outcome clear and unambiguous?
- ✅ Can it pass or fail definitively?

---

## Test Execution Patterns

### Pattern 1: Command Success/Failure

```bash
if command_here; then
    TEST_RESULT="pass"
else
    TEST_RESULT="fail"
    TEST_ERROR="Command failed: $?"
fi
```

**Use for:** Binary checks (exists/doesn't exist, succeeds/fails)

---

### Pattern 2: Output Matching

```bash
OUTPUT=$(command_here 2>&1)

if echo "$OUTPUT" | grep -q "$EXPECTED_PATTERN"; then
    TEST_RESULT="pass"
else
    TEST_RESULT="fail"
    TEST_ERROR="Expected pattern not found in output"
fi
```

**Use for:** Checking specific values in output

---

### Pattern 3: JSON/YAML Validation

```bash
if jq -e "$JSON_PATH" file.json >/dev/null 2>&1; then
    VALUE=$(jq -r "$JSON_PATH" file.json)

    if [[ "$VALUE" == "$EXPECTED" ]]; then
        TEST_RESULT="pass"
    else
        TEST_RESULT="fail"
        TEST_ERROR="Expected: $EXPECTED, Got: $VALUE"
    fi
else
    TEST_RESULT="fail"
    TEST_ERROR="JSON path not found: $JSON_PATH"
fi
```

**Use for:** Configuration validation

---

### Pattern 4: Multi-Check (All Must Pass)

```bash
CHECKS_PASSED=0
CHECKS_TOTAL=3

# Check 1
if check1_command; then
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
fi

# Check 2
if check2_command; then
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
fi

# Check 3
if check3_command; then
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
fi

if [[ $CHECKS_PASSED -eq $CHECKS_TOTAL ]]; then
    TEST_RESULT="pass"
else
    TEST_RESULT="fail"
    TEST_ERROR="Only $CHECKS_PASSED/$CHECKS_TOTAL checks passed"
fi
```

**Use for:** Multiple conditions must all be true

---

## Error Handling in Tests

### Capture Detailed Errors

**Bad:**
```bash
if ! command; then
    TEST_ERROR="Failed"
fi
```

**Good:**
```bash
ERROR_MSG=$(command 2>&1)

if [[ $? -ne 0 ]]; then
    TEST_ERROR="Command failed: $ERROR_MSG"
fi
```

### Distinguish Error Types

```bash
if ! command_here; then
    EXIT_CODE=$?

    case $EXIT_CODE in
        1) TEST_ERROR="General error" ;;
        2) TEST_ERROR="Syntax error" ;;
        127) TEST_ERROR="Command not found" ;;
        *) TEST_ERROR="Unknown error (exit code: $EXIT_CODE)" ;;
    esac

    TEST_RESULT="fail"
fi
```

---

## Domain-Specific Test Examples

### GitHub Features

```bash
# Functional: Repo exists
gh repo view "$ORG/$REPO" >/dev/null 2>&1

# Technical: Repo visibility private
[[ "$(gh repo view "$ORG/$REPO" --json visibility -q .visibility)" == "PRIVATE" ]]

# Integration: Repo accessible via API
gh api "repos/$ORG/$REPO" >/dev/null 2>&1
```

### File Features

```bash
# Functional: File exists with content
[[ -f "$FILE" ]] && [[ -s "$FILE" ]]

# Technical: File permissions correct
[[ $(stat -c %a "$FILE") == "644" ]]

# Integration: File readable by service
sudo -u "$SERVICE_USER" cat "$FILE" >/dev/null 2>&1
```

### API Features

```bash
# Functional: API returns 200 OK
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$API_ENDPOINT")
[[ "$HTTP_CODE" == "200" ]]

# Technical: API response valid JSON
curl -s "$API_ENDPOINT" | jq empty

# Integration: API requires authentication
curl -s -H "Authorization: Bearer $TOKEN" "$API_ENDPOINT" | grep -q "success"
```

---

## Troubleshooting Verification Failures

### Functional Test Fails

**Check:**
1. Was implementation actually executed?
2. Did implementation complete without errors?
3. Is the expected result actually created?
4. Is the test command correct?

### Technical Test Fails

**Check:**
1. Are configuration settings applied?
2. Is syntax valid?
3. Are required fields present?
4. Do standards match project conventions?

### Integration Test Fails

**Check:**
1. Are external dependencies available?
2. Are credentials configured?
3. Are permissions granted?
4. Is network connectivity working?

---

**Version:** 1.0.0
**Created:** 2026-02-17
**Applies To:** run-autonomous-implementation workflow
