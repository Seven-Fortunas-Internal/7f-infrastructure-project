# Action Item Prioritization Framework

## Purpose

Provides clear criteria for classifying action items by priority level (Critical, High, Medium, Low) based on impact to autonomous implementation readiness.

## Priority Levels

### Critical (Must Address Before Implementation)

**Definition:**
Action items that block autonomous implementation or pose high risk of failure if not resolved.

**Criteria:**
- Items that block autonomous implementation
- Critical blockers from step-06 feature quality analysis
- Architectural violations from step-05
- Requirements with no coverage from step-04 (0% coverage)
- Missing or undefined core functionality
- Ambiguous specifications in critical features

**Examples:**
- "Define data models for User and Organization entities (currently undefined)"
- "Resolve architectural violation: Direct database access in UI components"
- "Add authentication/authorization requirements to app_spec (missing from PRD)"
- "Clarify conflicting requirements in feature F-003 (auth vs. SSO)"

**Impact if Not Addressed:**
Autonomous agents will be blocked, produce incorrect implementations, or waste significant effort.

**Typical Effort:**
1-5 days per item (varies by complexity)

---

### High Priority (Should Address Before Implementation)

**Definition:**
Action items that significantly improve implementation success rate but aren't absolute blockers.

**Criteria:**
- Moderate quality issues from feature analysis
- Partial coverage gaps (some coverage but incomplete)
- Architectural concerns (not full violations)
- Moderate-quality feature definitions needing improvement
- Missing non-functional requirements
- Incomplete acceptance criteria

**Examples:**
- "Add performance requirements for search feature (SLA undefined)"
- "Expand API contract details for F-007 (partial coverage at 60%)"
- "Improve architectural compliance from 'Moderate' to 'Strong' for integration layer"
- "Clarify user personas in PRD (vague role definitions)"

**Impact if Not Addressed:**
Autonomous agents may produce suboptimal implementations, require rework, or miss requirements.

**Typical Effort:**
0.5-2 days per item

---

### Medium Priority (Address During Implementation)

**Definition:**
Action items that improve quality or completeness but can be handled during development iterations.

**Criteria:**
- Low-priority quality improvements
- Nice-to-have feature enhancements
- Process optimizations
- Documentation improvements (non-critical)
- Minor architectural improvements
- Non-blocking technical debt

**Examples:**
- "Add error message examples to feature specifications"
- "Document assumed user workflows for edge cases"
- "Improve consistency in terminology across PRD sections"
- "Add diagrams for complex feature interactions"

**Impact if Not Addressed:**
Minor quality impact, potential for small clarifications during implementation.

**Typical Effort:**
1-4 hours per item

---

### Low Priority (Nice to Have)

**Definition:**
Action items that provide marginal value or are purely cosmetic/organizational.

**Criteria:**
- Documentation formatting improvements
- Process optimizations (no direct implementation impact)
- Future-state enhancements (post-v1)
- Stylistic improvements to specifications
- Additional examples or illustrations

**Examples:**
- "Add table of contents to PRD for easier navigation"
- "Standardize heading capitalization across all documents"
- "Create visual mockups for dashboard (already specified in text)"
- "Document lessons learned for future PRD creation"

**Impact if Not Addressed:**
No meaningful impact on autonomous implementation success.

**Typical Effort:**
<1 hour per item

---

## Prioritization Decision Rules

### Rule 1: Impact Over Effort
Prioritize by implementation impact, not by how easy/hard to fix.

**Example:**
- Critical: "Define undefined data model" (high effort, high impact)
- Low: "Fix typo in feature name" (low effort, low impact)

### Rule 2: Blocker = Critical
Any item that would cause autonomous agents to halt or fail is Critical, regardless of scope.

### Rule 3: Coverage Gaps by Severity
- 0% coverage → Critical
- <50% coverage → High Priority
- 50-80% coverage → Medium Priority
- >80% coverage → Low Priority (refinement)

### Rule 4: Architectural Issues by Type
- Violation → Critical
- Concern → High Priority
- Suggestion → Medium Priority

### Rule 5: Feature Quality by Score
- Score <50 → Critical
- Score 50-69 → High Priority
- Score 70-84 → Medium Priority
- Score 85+ → Low Priority (optimization)

---

## Action Item Format

```markdown
### {Priority Level} ({count})

1. **{Action Item Title}** - {Source: step-XX}
   - **Issue:** {What's wrong or missing}
   - **Impact:** {Why this matters for autonomous implementation}
   - **Suggested Fix:** {How to address this}
   - **Effort:** {Estimated time to resolve}
```

**Example:**

```markdown
### Critical (3)

1. **Define Data Models for Core Entities** - Source: step-04
   - **Issue:** User, Organization, and Project entities referenced but not defined in PRD or app_spec
   - **Impact:** Autonomous agents cannot implement features without data structure specifications
   - **Suggested Fix:** Add entity relationship diagram and field definitions to architecture doc, reference in app_spec
   - **Effort:** 2-3 days
```

---

## Framework Version

**Version:** 1.0
**Last Updated:** 2026-02-13
**Workflow:** check-autonomous-implementation-readiness
