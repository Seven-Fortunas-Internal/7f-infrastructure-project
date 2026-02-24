# App Spec Validation Patterns

**Purpose:** Comprehensive validation patterns for app_spec.txt quality assessment based on create-app-spec workflow research.

**Version:** 2.0
**Last Updated:** 2026-02-13
**Source:** Patterns discovered during create-app-spec workflow development

---

## 1. Structure Validation

### 10 Required XML Sections

Every app_spec.txt MUST contain these sections:

1. **metadata** - Project info, generation date, feature count
2. **overview** - Project purpose, scope, context
3. **technology_stack** - Languages, frameworks, databases, infrastructure
4. **coding_standards** - Naming conventions, patterns, best practices
5. **core_features** - All feature specifications
6. **non_functional_requirements** - Performance, security, scalability, compliance
7. **testing_strategy** - Unit, integration, E2E test requirements
8. **deployment_instructions** - CI/CD, infrastructure, monitoring
9. **reference_documentation** - Links to PRD, architecture, external docs
10. **success_criteria** - Overall project completion definition

**Validation Check:**
```
✅ All 10 sections present
⚠️ Missing sections: {list}
❌ Critical sections missing (metadata, core_features, success_criteria)
```

### XML Well-Formedness

**Validation Check:**
- All tags properly nested
- All opening tags have closing tags
- No malformed XML syntax
- Proper escaping of special characters

**Common Issues:**
- Unclosed tags (e.g., `<feature>` without `</feature>`)
- Improper nesting (e.g., `<a><b></a></b>`)
- Unescaped characters (e.g., `<` or `>` in text content)

### Frontmatter Validation

**Required Fields:**
```yaml
project_name: "Project Name"
generated_date: "YYYY-MM-DD"
feature_count: XX
prd_source: "path/to/prd.md"
workflow_version: "X.X"
```

**Validation Check:**
- All required fields present
- Date format valid (YYYY-MM-DD)
- Feature count matches actual features in spec

---

## 2. Feature Quality Validation

### Atomic Task Principle

**Rule:** One feature = one independently implementable task

**✅ Good Atomicity:**
- Feature can be implemented without other features (except dependencies)
- Clear single purpose
- 2-5 requirements typical
- One developer can implement in reasonable time

**❌ Too Broad:**
- >5 requirements
- Multiple distinct capabilities mixed
- Would naturally split into multiple features
- Example: "Complete user management system" (should be: login, registration, profile, etc.)

**❌ Too Trivial:**
- Single-line code change
- Configuration change only
- Not feature-worthy
- Example: "Change button color to blue"

### Required Feature Elements

Every feature MUST have:
- **Feature ID:** Sequential FEATURE_XXX format (FEATURE_001, FEATURE_002, etc.)
- **Name:** Clear, descriptive (4-8 words typical)
- **Description:** Explains what and why (2-4 sentences)
- **Requirements:** 2-5 specific, actionable requirements
- **Acceptance Criteria:** Verification criteria (see section 3)
- **Dependencies:** Empty or valid FEATURE_XXX references
- **Constraints:** Empty or specific technical/business constraints

**Validation Check per Feature:**
```
✅ All required elements present
⚠️ Missing optional elements (constraints, dependencies)
❌ Missing critical elements (name, description, requirements, acceptance_criteria)
```

### Feature ID Validation

**Rules:**
- Sequential: FEATURE_001, FEATURE_002, FEATURE_003... (no gaps)
- Format: FEATURE_ prefix + 3-digit zero-padded number
- No gaps in sequence (indicates deleted features or ID errors)

**Validation Check:**
```
✅ Sequential IDs with no gaps
⚠️ Gaps detected at: FEATURE_005, FEATURE_012 (may be acceptable for removed features)
❌ Non-sequential or invalid format
```

---

## 3. Verification Criteria Quality

### The 3 Types Required

Every feature MUST have all 3 types of verification criteria:

#### 1. Functional Verification (2-3 criteria per feature)

**Purpose:** Verify functional requirements met

**Pattern:**
```
"Feature [performs action] [under condition] as specified in [requirement]"
"Feature handles [edge case/error condition] correctly by [expected behavior]"
"Feature produces [expected output] given [specific input]"
```

**✅ Good Examples:**
- "User can login with valid email and password credentials"
- "System displays error message 'Invalid credentials' for wrong password"
- "System creates session token and redirects to dashboard on successful login"

**❌ Bad Examples:**
- "Feature works correctly" (not measurable)
- "Login functions as expected" (not specific)

#### 2. Technical Verification (2-3 criteria per feature)

**Purpose:** Verify coding standards, quality thresholds met

**Pattern:**
```
"Code follows [specific coding standard or pattern] from PRD"
"Unit tests achieve [X]% coverage for [component]"
"Implementation uses [specified technology/library/framework]"
"No [specific vulnerability type] detected by static analysis"
```

**✅ Good Examples:**
- "Authentication code follows secure password hashing standards (bcrypt/argon2)"
- "Unit tests cover login success, failure, and edge cases (90%+ coverage)"
- "No hardcoded credentials or secrets in code"

**❌ Bad Examples:**
- "Code is high quality" (not measurable)
- "Tests are comprehensive" (not specific)

#### 3. Integration Verification (1-2 criteria per feature)

**Purpose:** Verify integration with dependencies, no regressions

**Pattern:**
```
"Feature integrates with [dependency feature/service] correctly"
"Feature does not break [existing functionality]"
"Data flows correctly between [component A] and [component B]"
```

**✅ Good Examples:**
- "Login integrates with session management (FEATURE_002)"
- "Login does not affect registration or password reset flows"

**❌ Bad Examples:**
- "Feature integrates well" (not specific)
- "No side effects" (not verifiable)

### Quality Standards for All Criteria

#### Measurability Test

**Question:** Can an autonomous agent objectively determine pass/fail?

**✅ Measurable:**
- "API returns 200 status code for valid request"
- "Unit test coverage >80%"
- "Page load time <2 seconds"

**❌ Not Measurable:**
- "API performs well" (what is "well"?)
- "Code is clean" (subjective)
- "Design looks good" (subjective)

#### Testability Test

**Question:** Can this be tested through automated tests or manual verification?

**✅ Testable:**
- "Login succeeds with valid credentials" (automated test)
- "Error message displayed for invalid email format" (automated test)
- "GDPR data deletion request processed within 30 days" (manual verification)

**❌ Not Testable:**
- "System is secure" (too broad, not a single test)
- "Feature is robust" (ambiguous)

#### Specificity Test

**Question:** Does this reference specific requirements, standards, or outcomes?

**✅ Specific:**
- "Follows React component naming conventions from coding standards"
- "Uses JWT tokens with 1-hour expiration as specified in PRD"
- "Integrates with SendGrid API for email delivery"

**❌ Not Specific:**
- "Follows best practices" (which practices?)
- "Uses industry standards" (which standards?)
- "Works correctly" (how is "correctly" defined?)

### Criteria Anti-Patterns

**Vague Terms Without Definition:**
- "properly", "correctly", "well", "appropriately" (without defining what these mean)
- Example Bad: "System handles errors properly"
- Example Good: "System logs error with stack trace and returns 500 status code"

**Generic Success Statements:**
- "Feature works correctly"
- "Feature performs as expected"
- "Feature meets requirements"

**Untestable Absolutes:**
- "Feature never fails"
- "System is 100% secure"
- "No bugs exist"

**Missing Context:**
- "Feature handles errors" (which errors? how?)
- "System validates input" (what validation? what rules?)
- "Code follows standards" (which standards?)

---

## 4. Category Distribution Validation

### 7 Domain Categories

Every feature MUST be assigned to exactly ONE of these categories:

1. **Infrastructure & Foundation** - Core services, data models, auth, config
2. **User Interface** - Screens, components, forms, navigation
3. **Business Logic** - Workflows, calculations, rules, algorithms
4. **Integration** - APIs, external services, data sync, webhooks
5. **DevOps & Deployment** - CI/CD, infrastructure, monitoring, logging
6. **Security & Compliance** - Authorization, encryption, audit, compliance
7. **Testing & Quality** - Test infrastructure, test data, quality gates

**Validation Rules:**
- ✅ All features assigned to one of 7 categories (no custom categories)
- ✅ No single category >60% of total features
- ✅ At least 3 categories represented
- ✅ Infrastructure category present for non-trivial projects

### Expected Distribution (Guidelines)

**Balanced app_spec:**
- Infrastructure: 10-20%
- User Interface: 20-30% (for user-facing apps)
- Business Logic: 25-35%
- Integration: 5-15%
- DevOps: 5-10%
- Security: 5-15%
- Testing: 5-10%

**Warning Flags:**
- Any category >60%: Inappropriate domination, likely miscategorization
- Infrastructure <5% for complex projects: Missing foundational features
- Fewer than 3 categories: Scope too narrow or miscategorization

---

## 5. Dependency Management Validation

### Dependency Rules

**Valid Dependency Reference:**
- Format: FEATURE_XXX where XXX is 3-digit zero-padded number
- Referenced feature MUST exist in spec
- Dependency MUST be logically sound (no circular dependencies)

**Validation Checks:**

**✅ All references valid:**
- Every FEATURE_XXX reference points to existing feature
- No broken references (FEATURE_099 when only 50 features exist)

**✅ No circular dependencies:**
- FEATURE_001 depends on FEATURE_002
- FEATURE_002 depends on FEATURE_003
- FEATURE_003 does NOT depend on FEATURE_001 (circular)

**✅ Dependencies logical:**
- Login (FEATURE_001) depends on User Database (FEATURE_000) ✅
- User Database (FEATURE_000) depends on Login (FEATURE_001) ❌ (illogical)

**✅ Hard dependencies marked:**
- MUST vs SHOULD dependencies clear
- Optional dependencies noted as such

---

## 6. Completeness Validation

### Feature Count Appropriateness

**Guidelines (flexible based on project):**
- Simple projects: 10-20 features
- Moderate complexity: 30-50 features
- High complexity: 50-100+ features

**Validation:**
- ✅ Feature count appropriate for project scope (from PRD)
- ⚠️ Too few features: Possible missing capabilities or features too broad
- ⚠️ Too many features: Possible over-granularity or scope creep

### PRD Coverage

**Validation:**
- ✅ All major PRD sections/capabilities represented
- ⚠️ Some PRD sections not covered by any features
- ❌ Major capabilities from PRD missing

### Non-Functional Requirements

**Validation:**
- ✅ NFR section present with specific requirements
- ⚠️ NFR section generic or vague
- ❌ NFR section missing or empty

### Testing Strategy

**Validation:**
- ✅ Testing strategy defined with specific requirements
- ⚠️ Testing strategy generic
- ❌ Testing strategy missing

---

## 7. Technology Stack Clarity

### Specificity Requirements

**✅ Excellent Clarity:**
- Languages with versions: "Python 3.11+", "TypeScript 5.x"
- Frameworks with versions: "React 18.x", "FastAPI 0.100+"
- Databases with types/versions: "PostgreSQL 15+", "Redis 7.x"
- Infrastructure specifics: "Docker 24.x", "Kubernetes 1.28+"

**⚠️ Needs Improvement:**
- Vague versions: "Python 3.x", "latest React"
- Generic mentions: "SQL database", "modern framework"
- Missing deployment environment

**❌ Critical Gap:**
- No versions specified
- Generic "industry standard" language
- Missing critical stack components

**Validation Scoring:**
- 90-100: All technologies with specific versions
- 70-89: Most clear, some version gaps
- 50-69: Many vague references
- 0-49: Critical specification gaps

---

## 8. Coding Standards Specificity

### Actionable Guidance Requirements

**✅ Concrete Guidance:**
- Naming conventions: Specific patterns ("camelCase for variables", "PascalCase for components")
- File organization: Specific structure ("features/ organized by domain")
- Code patterns: Specific examples ("Use React hooks pattern", "Repository pattern for data access")
- Error handling: Specific patterns ("try-catch with typed errors", "return Result<T, E> type")
- Testing: Specific thresholds ("80% unit test coverage", "E2E tests for all user flows")

**⚠️ Generic Guidance:**
- "Follow best practices" (which?)
- "Write clean code" (what defines clean?)
- "Use industry standards" (which?)
- "Test thoroughly" (how much? what kind?)

**❌ No Guidance:**
- Empty coding_standards section
- Only platitudes without actionable rules
- No specific patterns or examples

**Validation Scoring:**
- 90-100: All standards concrete with examples
- 70-89: Most clear, some generic statements
- 50-69: Mix of specific and generic
- 0-49: Mostly generic or missing

**Agent-Readiness:**
- Can autonomous agent follow standards? ✅ Yes / ⚠️ Partially / ❌ No

---

## 9. Overall Quality Score Calculation

### Component Scores (from validation steps)

1. **Structure Validation** (0-100)
   - 10 required sections present: +50
   - XML well-formed: +30
   - Frontmatter complete: +20

2. **Feature Structure Quality** (0-100)
   - All features have required elements: +40
   - Atomic granularity (not too broad/trivial): +30
   - Sequential IDs: +15
   - Feature count appropriate: +15

3. **Verification Criteria Quality** (0-100)
   - All 3 types present per feature: +50
   - All criteria measurable: +25
   - All criteria testable: +15
   - All criteria specific: +10

4. **Category Distribution** (0-100)
   - All features categorized (no custom): +40
   - Balanced distribution (<60% any category): +30
   - 3+ categories represented: +20
   - Infrastructure present: +10

5. **Dependency Quality** (0-100)
   - All references valid: +40
   - No circular dependencies: +30
   - Dependencies logical: +20
   - Hard dependencies marked: +10

6. **Completeness** (0-100)
   - Feature count appropriate: +25
   - All PRD sections covered: +35
   - NFRs addressed: +20
   - Testing strategy defined: +20

7. **Technology Stack Clarity** (0-100)
   - All technologies with versions: +60
   - Deployment environment clear: +20
   - Infrastructure specified: +20

8. **Coding Standards Specificity** (0-100)
   - All standards concrete/actionable: +60
   - Examples provided: +20
   - Agent can follow: +20

### Overall Quality Score

**Composite Score:**
```
Overall = (Structure + Feature Structure + Criteria Quality +
           Category Distribution + Dependency Quality + Completeness +
           Tech Stack + Coding Standards) / 8
```

**Quality Rating:**
- **90-100: Excellent** - Ready for autonomous implementation
- **75-89: Good** - Minor improvements recommended
- **60-74: Fair** - Moderate improvements needed
- **40-59: Poor** - Significant work required
- **0-39: Critical** - Not ready for autonomous implementation

---

## 10. Validation Report Template

```markdown
## App Spec Validation Report

**Overall Quality Score:** {score}/100
**Quality Rating:** {Excellent/Good/Fair/Poor/Critical}

### Component Scores

| Component | Score | Status |
|-----------|-------|--------|
| Structure Validation | {score}/100 | {✅/⚠️/❌} |
| Feature Structure Quality | {score}/100 | {✅/⚠️/❌} |
| Verification Criteria Quality | {score}/100 | {✅/⚠️/❌} |
| Category Distribution | {score}/100 | {✅/⚠️/❌} |
| Dependency Quality | {score}/100 | {✅/⚠️/❌} |
| Completeness | {score}/100 | {✅/⚠️/❌} |
| Technology Stack Clarity | {score}/100 | {✅/⚠️/❌} |
| Coding Standards Specificity | {score}/100 | {✅/⚠️/❌} |

### Structure Validation

- 10 Required Sections: {X/10 present}
- XML Well-Formed: {✅/❌}
- Frontmatter Complete: {✅/❌}
- Feature IDs Sequential: {✅/⚠️}

### Feature Quality

- Total Features: {count}
- Atomic Features: {count} ({percentage}%)
- Too Broad: {count}
- Too Trivial: {count}
- Missing Required Elements: {count}

### Verification Criteria

- Features with all 3 types: {count}/{total}
- Measurable criteria: {count}/{total}
- Testable criteria: {count}/{total}
- Specific criteria: {count}/{total}

### Category Distribution

| Category | Count | Percentage |
|----------|-------|------------|
| Infrastructure | {count} | {pct}% |
| User Interface | {count} | {pct}% |
| Business Logic | {count} | {pct}% |
| Integration | {count} | {pct}% |
| DevOps | {count} | {pct}% |
| Security | {count} | {pct}% |
| Testing | {count} | {pct}% |

- Balanced: {✅/⚠️}
- All categorized: {✅/❌}

### Dependencies

- All references valid: {✅/❌} ({broken_count} broken)
- No circular dependencies: {✅/❌} ({cycle_count} cycles)
- Dependencies logical: {✅/⚠️}

### Critical Issues

{List any critical issues that block autonomous implementation}

### Recommendations

{Specific, actionable recommendations for improving app_spec.txt quality}

### Autonomous Implementation Readiness

**Overall Assessment:** {Ready / Needs Refinement / Not Ready}

**Rationale:** {Specific justification based on validation findings}
```

---

**Last Updated:** 2026-02-13
**Version:** 2.0
**Workflow:** check-autonomous-implementation-readiness
**Based On:** Patterns from create-app-spec workflow validation research
