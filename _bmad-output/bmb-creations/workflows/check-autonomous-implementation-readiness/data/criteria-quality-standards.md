# Verification Criteria Quality Standards

## 3 Types Required

For each feature's acceptance_criteria, assess quality against patterns:

### 1. Functional Verification (2-3 criteria per feature)
- Verifies functional requirements met
- Measurable pass/fail
- Example: "User can login with valid credentials"

### 2. Technical Verification (2-3 criteria per feature)
- Verifies coding standards, quality thresholds
- Example: "Unit tests achieve 90%+ coverage"

### 3. Integration Verification (1-2 criteria per feature)
- Verifies integration with dependencies
- Example: "Login integrates with session management (FEATURE_002)"

## Quality Checks

### ✅ Measurable
- Objective pass/fail determination possible
- No vague terms like "properly", "correctly", "well" without definition
- Example Good: "API returns 200 status for valid request"
- Example Bad: "API performs well"

### ✅ Testable
- Can be automated or manually verified
- Clear verification method
- Example Good: "Error message displayed for invalid email format"
- Example Bad: "System is secure"

### ✅ Specific
- References concrete requirements or standards
- Not generic statements
- Example Good: "Follows React naming conventions from coding standards"
- Example Bad: "Follows best practices"

## Criteria Quality Scoring Formula

Criteria Quality Score per Feature:
- All 3 types present: +50 points
- All criteria measurable: +25 points
- All criteria testable: +15 points
- All criteria specific: +10 points
- Total: {score}/100

## Criteria Quality Presentation Template

Present criteria quality findings:

```
**Verification Criteria Quality:**
- Features with all 3 types: {count}/{total}
- Features with measurable criteria: {count}/{total}
- Features with testable criteria: {count}/{total}
- Features with specific criteria: {count}/{total}
- Average criteria quality score: {score}/100

**Common Criteria Issues:**
- Vague terms without definition: {count} features
- Generic success statements: {count} features
- Missing integration verification: {count} features
- Untestable criteria: {count} features
```

## Common Criteria Issues Patterns

- Vague terms without definition
- Generic success statements
- Missing integration verification
- Untestable criteria
