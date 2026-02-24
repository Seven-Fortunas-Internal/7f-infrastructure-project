# App Spec Coverage Checklist

**Purpose:** Standard checklist for validating app_spec.txt coverage of PRD requirements.

---

## Coverage Assessment Process

### Step 1: Extract All Requirements

**From PRD, extract:**
- All Functional Requirements (FRs) with IDs
- All Non-Functional Requirements (NFRs) with IDs
- User journeys requiring implementation
- Domain/business rules requiring enforcement

### Step 2: Extract All Features

**From app_spec.txt, extract:**
- All feature specifications
- Feature names/IDs
- Feature descriptions
- Acceptance criteria per feature

### Step 3: Build Traceability Matrix

**For each requirement, determine:**
- Which app_spec.txt feature(s) address it
- Coverage level: Full / Partial / None

---

## Coverage Classification

### ✅ Fully Covered

**Criteria:**
- Requirement has corresponding feature(s) in app_spec.txt
- Feature specification addresses all aspects of the requirement
- Acceptance criteria in app_spec.txt validate requirement satisfaction
- No gaps in coverage

**Example:**
```
FR-AUTH-1: User login with email/password
✅ Covered by: Feature "Authentication Module"
  - Email/password validation specified
  - Session management defined
  - Error handling covered
  - AC validates successful login
```

### ⚠️ Partially Covered

**Criteria:**
- Requirement has corresponding feature in app_spec.txt
- Feature addresses some but not all aspects
- Gaps exist in specification
- Some acceptance criteria missing

**Example:**
```
FR-EXPORT-2: Export data in CSV, JSON, and XML formats
⚠️ Partially Covered by: Feature "Data Export"
  - CSV and JSON formats specified
  - Missing: XML format
  - Gap: No specification for XML export
```

### ❌ Not Covered

**Criteria:**
- No feature in app_spec.txt addresses this requirement
- Requirement completely absent from implementation plan

**Example:**
```
FR-NOTIF-5: Real-time browser notifications
❌ Not Covered
  - No feature specification for notifications
  - No mention of notification system
  - Gap: Entire requirement unaddressed
```

---

## Coverage Scoring

### Functional Requirements Coverage

**Formula:**
```
FR Coverage = ((Fully Covered * 1.0) + (Partially Covered * 0.5)) / Total FRs * 100
```

**Score Interpretation:**
- **90-100%:** Excellent coverage - All FRs addressed
- **75-89%:** Good coverage - Minor gaps
- **60-74%:** Adequate coverage - Moderate gaps
- **45-59%:** Poor coverage - Significant gaps
- **0-44%:** Critical coverage - Major requirements missing

### Non-Functional Requirements Coverage

**Formula:**
```
NFR Coverage = ((Fully Covered * 1.0) + (Partially Covered * 0.5)) / Total NFRs * 100
```

**Score Interpretation:**
- **85-100%:** Excellent - All critical NFRs covered
- **70-84%:** Good - Most NFRs covered
- **55-69%:** Adequate - Some NFR gaps
- **40-54%:** Poor - Many NFR gaps
- **0-39%:** Critical - Critical NFRs missing

### Overall Coverage Score

**Weighted Formula:**
```
Overall Coverage = (FR Coverage * 0.70) + (NFR Coverage * 0.30)
```

Functional requirements weighted higher (70%) because they drive core features.

---

## Critical Coverage Gaps

### High-Priority Requirements

**Must be covered:**
- Security-related FRs (authentication, authorization, data protection)
- Core user journeys (primary use cases)
- Critical NFRs (security, performance, reliability)
- Compliance requirements

**Gap Severity:**
- **Critical Gap:** High-priority requirement not covered
- **Major Gap:** Standard requirement not covered
- **Minor Gap:** Nice-to-have requirement not covered

### NFR-Specific Considerations

**Security NFRs:**
- Must have explicit feature coverage
- No implicit assumptions
- Clear implementation guidance

**Performance NFRs:**
- Should specify caching, optimization strategies
- Response time targets should map to features

**Scalability NFRs:**
- Should specify horizontal/vertical scaling approach
- Load handling should be addressed

---

## Unmapped Features Check

### Reverse Traceability

**For each app_spec.txt feature:**
- Does it map to a PRD requirement?
- If no mapping, classify:
  - **Implementation Detail:** Supporting infrastructure (acceptable)
  - **Missing PRD Requirement:** Should be in PRD
  - **Scope Creep:** Feature not in original scope (flag)

**Example:**
```
Feature: "Database Connection Pooling"
- No direct PRD requirement
- Classification: Implementation Detail (acceptable)
- Reason: Supports performance NFRs

Feature: "Social Media Sharing"
- No PRD requirement
- Classification: Scope Creep (flag)
- Reason: Not in original PRD scope
```

---

## Coverage Assessment Checklist

**During coverage validation, verify:**

- [ ] All FRs extracted from PRD
- [ ] All NFRs extracted from PRD
- [ ] All features extracted from app_spec.txt
- [ ] Each requirement mapped to feature (or marked not covered)
- [ ] Each feature mapped to requirement (or classified as implementation detail/scope creep)
- [ ] Coverage scores calculated accurately
- [ ] Critical gaps identified
- [ ] Recommendations for closing gaps provided

---

## Coverage Report Template

```markdown
## App Spec Coverage Analysis

**Overall Coverage:** {score}/100

**Functional Requirements:**
- Total FRs: {count}
- Fully Covered: {count} ({percentage}%)
- Partially Covered: {count} ({percentage}%)
- Not Covered: {count} ({percentage}%)
- FR Coverage Score: {score}/100

**Non-Functional Requirements:**
- Total NFRs: {count}
- Fully Covered: {count} ({percentage}%)
- Partially Covered: {count} ({percentage}%)
- Not Covered: {count} ({percentage}%)
- NFR Coverage Score: {score}/100

**Critical Gaps ({count}):**
1. {FR/NFR-ID}: {Description} - Not Covered
2. {FR/NFR-ID}: {Description} - Partially Covered (Missing: {gap})

**Unmapped Features ({count}):**
1. {Feature Name} - Classification: {Implementation Detail/Missing PRD/Scope Creep}

**Recommendation:**
{Specific actions to close coverage gaps}
```

---

**Last Updated:** 2026-02-10
**Version:** 1.0
**Workflow:** check-autonomous-implementation-readiness
