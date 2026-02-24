# Verification Criteria Patterns for App Spec

This document defines patterns and best practices for generating measurable, testable verification criteria.

## Purpose

Every feature in an app_spec.txt requires verification criteria to enable autonomous agents to validate successful implementation. These criteria must be:
- **Measurable:** Objective pass/fail determination possible
- **Testable:** Can be automated or manually verified
- **Specific:** References concrete requirements, not generic statements

## The Three Types of Criteria

### 1. Functional Verification (2-3 criteria per feature)

**Purpose:** Verify that the feature implements the specified functional requirements correctly.

**Pattern:**
```
"Feature [performs action] [under condition] as specified in [requirement]"
"Feature handles [edge case/error condition] correctly by [expected behavior]"
"Feature produces [expected output] given [specific input]"
```

**Good Examples:**
- "User can login with valid email and password credentials"
- "System displays error message for invalid credentials"
- "System creates session token and redirects to dashboard on successful login"
- "Payment calculation includes tax based on user's billing address state"
- "API returns 404 status code for non-existent resource IDs"

**Bad Examples (too generic):**
- "Feature works correctly" ❌ (not measurable)
- "Login functions as expected" ❌ (not specific)
- "System behaves properly" ❌ (vague)

### 2. Technical Verification (2-3 criteria per feature)

**Purpose:** Verify that the implementation follows coding standards, achieves quality thresholds, and uses specified technologies.

**Pattern:**
```
"Code follows [specific coding standard or pattern] from PRD"
"Unit tests achieve [X]% coverage for [component]"
"Implementation uses [specified technology/library/framework]"
"No [specific vulnerability type] detected by static analysis"
"Performance meets [specific threshold] under [conditions]"
```

**Good Examples:**
- "Authentication code follows secure password hashing standards (bcrypt/argon2)"
- "Unit tests cover login success, failure, and edge cases (90%+ coverage)"
- "No hardcoded credentials or secrets in code"
- "API response time <200ms for 95th percentile under normal load"
- "Database queries use parameterized statements (no SQL injection risk)"

**Bad Examples (too generic):**
- "Code is high quality" ❌ (not measurable)
- "Tests are comprehensive" ❌ (not specific)
- "Performance is good" ❌ (no threshold)

### 3. Integration Verification (1-2 criteria per feature)

**Purpose:** Verify that the feature integrates correctly with dependencies and doesn't break existing functionality.

**Pattern:**
```
"Feature integrates with [dependency feature/service] correctly"
"Feature does not break [existing functionality]"
"Feature works with [specified external service/API]"
"Data flows correctly between [component A] and [component B]"
```

**Good Examples:**
- "Login integrates with session management (FEATURE_002)"
- "Login does not affect registration or password reset flows"
- "User profile API returns data in format expected by mobile app"
- "Payment processing communicates with Stripe API successfully"

**Bad Examples (too generic):**
- "Feature integrates well" ❌ (not specific)
- "No side effects" ❌ (not verifiable)
- "Works with other features" ❌ (too vague)

---

## Quality Standards

### Measurability Test

**Every criterion must pass this test:** Can an autonomous agent objectively determine pass/fail?

**Measurable criteria:**
- "API returns 200 status code for valid request" ✅
- "Unit test coverage >80%" ✅
- "Page load time <2 seconds" ✅

**Non-measurable criteria:**
- "API performs well" ❌ (what is "well"?)
- "Code is clean" ❌ (subjective)
- "Design looks good" ❌ (subjective)

### Testability Test

**Every criterion must be testable** through automated tests or manual verification steps.

**Testable criteria:**
- "Login succeeds with valid credentials" ✅ (automated test)
- "Error message displayed for invalid email format" ✅ (automated test)
- "GDPR data deletion request processed within 30 days" ✅ (manual verification)

**Non-testable criteria:**
- "System is secure" ❌ (too broad, not a single test)
- "Feature is robust" ❌ (ambiguous)

### Specificity Test

**Every criterion must reference specific requirements, standards, or outcomes.**

**Specific criteria:**
- "Follows React component naming conventions from coding standards" ✅
- "Uses JWT tokens with 1-hour expiration as specified in PRD" ✅
- "Integrates with SendGrid API for email delivery" ✅

**Non-specific criteria:**
- "Follows best practices" ❌ (which practices?)
- "Uses industry standards" ❌ (which standards?)
- "Works correctly" ❌ (how is "correctly" defined?)

---

## Patterns from Research

These patterns were identified from analyzing 4 high-quality app_spec.txt examples:

### Pattern 1: Happy Path + Error Path

**For user-facing features, always include:**
1. Happy path criterion (feature works with valid input)
2. Error path criterion (feature handles invalid input gracefully)

**Example (Login feature):**
- Functional: "User successfully logs in with valid email and password"
- Functional: "System displays 'Invalid credentials' error for wrong password"

### Pattern 2: Integration + No Regression

**For features with dependencies, always include:**
1. Integration criterion (works with dependency)
2. No regression criterion (doesn't break existing functionality)

**Example (User profile update):**
- Integration: "Profile updates sync with user session (FEATURE_002)"
- Integration: "Profile update does not affect login or logout functionality"

### Pattern 3: Standard + Measurement

**For technical criteria, always include:**
1. Standard criterion (follows specified pattern/technology)
2. Measurement criterion (achieves quantifiable threshold)

**Example (API endpoint):**
- Technical: "Implements RESTful conventions (GET for retrieval)"
- Technical: "Response time <100ms for 90th percentile"

### Pattern 4: Security Triad

**For security-sensitive features, include all three:**
1. Authentication/Authorization criterion
2. Data protection criterion
3. Audit/Compliance criterion

**Example (Payment processing):**
- Technical: "Uses PCI-compliant tokenization (no card data stored)"
- Technical: "Encrypts payment data in transit (TLS 1.3)"
- Integration: "Logs all payment transactions for audit trail"

---

## Category-Specific Patterns

### Infrastructure & Foundation Features

**Typical functional criteria:**
- "Service starts successfully and listens on configured port"
- "Database connection pool maintains [X] connections"
- "Configuration loads from environment variables correctly"

**Typical technical criteria:**
- "Service restarts automatically on failure (max 3 retries)"
- "Health check endpoint returns status within 100ms"
- "Database migrations run idempotently (safe to re-run)"

**Typical integration criteria:**
- "Integrates with authentication service for request validation"
- "Does not block startup of dependent services"

### User Interface Features

**Typical functional criteria:**
- "Component renders with correct data from props"
- "Form validation displays errors inline for invalid fields"
- "Navigation highlights active menu item"

**Typical technical criteria:**
- "Component follows accessibility standards (ARIA labels)"
- "Page load performance meets Core Web Vitals (LCP <2.5s)"
- "Component unit tests achieve 85%+ coverage"

**Typical integration criteria:**
- "Component consumes API data via Redux state management"
- "UI updates do not cause layout shift (CLS <0.1)"

### Business Logic Features

**Typical functional criteria:**
- "Calculation produces correct result for test cases A, B, C"
- "Workflow transitions through states as defined in state machine"
- "Validation rejects invalid data per business rules"

**Typical technical criteria:**
- "Calculation logic separated into pure functions (unit testable)"
- "Business rules loaded from configuration (not hardcoded)"
- "Performance: processes [X] records per second"

**Typical integration criteria:**
- "Workflow integrates with notification service for state changes"
- "Calculation results persist to database correctly"

### Integration Features

**Typical functional criteria:**
- "API request includes required headers and authentication"
- "Response data parsed correctly into domain models"
- "Webhook verifies signature before processing payload"

**Typical technical criteria:**
- "Implements retry logic with exponential backoff (3 retries max)"
- "Circuit breaker trips after [X] consecutive failures"
- "API client logs all requests/responses for debugging"

**Typical integration criteria:**
- "External API errors propagate as domain exceptions"
- "Integration does not block main application thread"

### DevOps & Deployment Features

**Typical functional criteria:**
- "CI pipeline runs tests on every commit"
- "Deployment completes within [X] minutes"
- "Health check validates all dependencies before traffic"

**Typical technical criteria:**
- "Pipeline fails if test coverage drops below [X]%"
- "Infrastructure deployed via code (no manual steps)"
- "Monitoring alerts fire within [X] seconds of incident"

**Typical integration criteria:**
- "Deployment does not cause downtime (blue-green or rolling)"
- "Monitoring integrates with incident management system"

### Security & Compliance Features

**Typical functional criteria:**
- "User can only access resources they have permission for"
- "Sensitive data redacted in logs and error messages"
- "Compliance report includes all required data points"

**Typical technical criteria:**
- "Authorization checks enforced at API gateway layer"
- "Encryption uses approved algorithms (AES-256)"
- "Security scan finds zero critical/high vulnerabilities"

**Typical integration criteria:**
- "Audit logs sent to centralized SIEM system"
- "Compliance checks integrate with data retention policies"

### Testing & Quality Features

**Typical functional criteria:**
- "Test suite executes all tests and reports results"
- "Mock data generator creates valid test fixtures"
- "Quality gate blocks deployment if criteria not met"

**Typical technical criteria:**
- "Test suite completes within [X] minutes"
- "Mock data covers edge cases and boundary conditions"
- "Quality metrics collected and stored for trending"

**Typical integration criteria:**
- "Test results published to CI/CD dashboard"
- "Quality gate integrates with pull request approval workflow"

---

## Anti-Patterns to Avoid

### 1. Generic Success Statements

❌ "Feature works correctly"
❌ "Feature performs as expected"
❌ "Feature meets requirements"

✅ Instead: Specify exact behavior or outcome

### 2. Vague Quality Terms

❌ "Code is clean"
❌ "Performance is good"
❌ "Design is intuitive"

✅ Instead: Use measurable thresholds or specific standards

### 3. Untestable Absolutes

❌ "Feature never fails"
❌ "System is 100% secure"
❌ "No bugs exist"

✅ Instead: Specify acceptable error rates or security controls

### 4. Missing Context

❌ "Feature handles errors"
❌ "System validates input"
❌ "Code follows standards"

✅ Instead: Specify which errors, what validation, which standards

### 5. Multiple Criteria in One

❌ "Login works, is secure, and performs well"

✅ Instead: Break into separate functional, technical, and integration criteria

---

## Criteria Generation Workflow

### Step 1: Identify Requirements

From the feature's requirements list, identify:
- Primary functional requirement (what it does)
- Key constraints or standards (how it should be done)
- Dependencies (what it integrates with)

### Step 2: Generate Functional Criteria

For each functional requirement:
- Write happy path criterion
- Write error/edge case criterion (if applicable)
- Ensure measurable outcome

### Step 3: Generate Technical Criteria

Based on coding standards and PRD specs:
- Write standard/pattern criterion
- Write quality/threshold criterion
- Write security criterion (if sensitive)

### Step 4: Generate Integration Criteria

Based on dependencies:
- Write integration criterion for each dependency
- Write no-regression criterion for existing features

### Step 5: Validate Quality

Check each criterion against:
- ✅ Measurable (objective pass/fail)
- ✅ Testable (can be verified)
- ✅ Specific (references concrete requirements)

---

## Usage in Workflow

This document is loaded by:
- **step-05-criteria-generation.md** - Uses patterns for automated criteria generation
- **step-02-edit-menu.md** - Reference for manual criteria updates

**Automated generation process:**
1. Load verification patterns from this file
2. For each feature, identify category
3. Apply category-specific patterns
4. Generate 3 types of criteria (functional, technical, integration)
5. Validate criteria quality
6. Store with feature

---

**Version:** 1.0
**Last Updated:** 2026-02-13
**Used By:** create-app-spec workflow (step-05)
**Based On:** Analysis of 4 high-quality app_spec examples from research phase
