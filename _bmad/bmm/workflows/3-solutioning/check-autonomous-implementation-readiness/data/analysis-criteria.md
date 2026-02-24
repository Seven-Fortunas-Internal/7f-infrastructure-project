# PRD Analysis Criteria

**Purpose:** Standard criteria for evaluating PRD completeness and quality in autonomous implementation readiness assessments.

---

## PRD Completeness Criteria

### Required Sections

**Core Sections (Must Have):**
1. Executive Summary / Overview
2. Success Criteria / Goals
3. User Journeys / Use Cases
4. Functional Requirements (FRs)
5. Non-Functional Requirements (NFRs)

**Supporting Sections (Should Have):**
6. Domain Requirements / Business Rules
7. Out of Scope / Constraints
8. Assumptions and Dependencies
9. Acceptance Criteria

**Scoring:**
- All 9 sections present and substantive: 95-100
- All 5 core + 2-3 supporting: 85-94
- All 5 core + 1 supporting: 75-84
- All 5 core, thin supporting: 65-74
- 4/5 core sections: 55-64
- 3/5 core sections: 40-54
- <3 core sections: 0-39

---

## Functional Requirements (FR) Quality Criteria

### Clarity
- **Clear (3 points):** Specific, unambiguous, uses precise language
- **Adequate (2 points):** Generally clear but has minor ambiguities
- **Unclear (0-1 points):** Vague, ambiguous, open to multiple interpretations

### Testability
- **Testable (3 points):** Can be objectively verified/tested
- **Partially Testable (2 points):** Some aspects testable, others subjective
- **Untestable (0-1 points):** Cannot be objectively verified

### Completeness
- **Complete (3 points):** All aspects of the requirement specified
- **Mostly Complete (2 points):** Minor gaps, but generally sufficient
- **Incomplete (0-1 points):** Major gaps in specification

### Acceptance Criteria
- **Explicit AC (3 points):** Clear, specific acceptance criteria defined
- **Implicit AC (2 points):** Acceptance criteria inferable but not explicit
- **No AC (0-1 points):** No acceptance criteria provided

**FR Quality Score:** Sum all FRs, divide by (count * 12) * 100

**Score Interpretation:**
- 90-100: Excellent FR quality
- 75-89: Good FR quality, minor improvements
- 60-74: Adequate FR quality, needs refinement
- 45-59: Poor FR quality, significant work needed
- 0-44: Critical FR quality issues

---

## Non-Functional Requirements (NFR) Quality Criteria

### Coverage Categories

**Critical NFR Categories (Must Cover):**
1. Security (authentication, authorization, data protection)
2. Performance (response times, throughput)
3. Scalability (concurrent users, data volume growth)

**Important NFR Categories (Should Cover):**
4. Reliability (uptime, error handling, recovery)
5. Maintainability (code quality, documentation, testability)
6. Accessibility (WCAG compliance, assistive technology support)

### NFR Specificity

**Measurable (3 points):**
- Quantifiable metrics (e.g., "API response time < 200ms for 95th percentile")
- Testable criteria
- Clear targets

**Semi-Measurable (2 points):**
- General targets (e.g., "fast response times")
- Some quantification
- Mostly clear

**Vague (0-1 points):**
- No metrics (e.g., "should be secure")
- Untestable
- Unclear expectations

**NFR Coverage Score:**
- All 6 categories covered with measurable NFRs: 95-100
- All 3 critical + 2 important: 85-94
- All 3 critical + 1 important: 75-84
- All 3 critical categories: 65-74
- 2/3 critical categories: 45-64
- 1/3 critical categories: 20-44
- 0 critical categories: 0-19

---

## Success Criteria Quality

### Clarity of Metrics
- **Clear Metrics:** Specific, measurable success indicators defined
- **Vague Metrics:** General goals without measurement criteria
- **No Metrics:** No success criteria defined

### Alignment with Requirements
- **Aligned:** Success criteria directly map to FRs/NFRs
- **Partially Aligned:** Some mapping, some disconnect
- **Misaligned:** Success criteria don't reflect requirements

### Feasibility
- **Realistic:** Success criteria achievable with specified requirements
- **Challenging:** Ambitious but achievable
- **Unrealistic:** Success criteria exceed specified requirements

**Success Criteria Score:**
- Clear, aligned, realistic metrics: 90-100
- Mostly clear and aligned: 75-89
- Some clarity, some alignment: 60-74
- Vague or misaligned: 40-59
- No success criteria: 0-39

---

## Overall PRD Quality Calculation

**Weighted Average:**
- Completeness: 25%
- FR Quality: 30%
- NFR Quality: 25%
- Success Criteria: 20%

**Overall PRD Score** = (Completeness * 0.25) + (FR * 0.30) + (NFR * 0.25) + (Success * 0.20)

**Interpretation:**
- **90-100:** Excellent - Ready for autonomous implementation
- **75-89:** Good - Minor refinements recommended
- **60-74:** Adequate - Some improvements needed
- **45-59:** Poor - Significant work required
- **0-44:** Critical - Not ready for implementation

---

## Red Flags (Immediate Concerns)

**Critical Issues:**
- Missing security NFRs
- No functional requirements defined
- No acceptance criteria for any FR
- Success criteria completely absent
- Major ambiguities in core requirements

**Major Issues:**
- <50% of FRs have acceptance criteria
- Vague NFRs across multiple categories
- Success criteria don't align with requirements
- Missing 2+ core sections

**Moderate Issues:**
- Some FRs lack acceptance criteria
- Some NFRs are vague
- Supporting sections thin or missing
- Minor ambiguities in requirements

---

**Last Updated:** 2026-02-10
**Version:** 1.0
**Workflow:** check-autonomous-implementation-readiness
