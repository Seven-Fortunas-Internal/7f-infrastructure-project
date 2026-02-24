# Go/No-Go Decision Framework

## Purpose

Provides clear decision criteria and logic for determining whether a project is ready for autonomous agent implementation based on assessment scores and blockers.

## Decision Logic

### GO (Approve for Autonomous Implementation)

**Criteria:**
- Overall Score ≥ 75 AND
- No critical blockers (from step-06) AND
- App Spec Coverage ≥ 70 AND
- Feature Quality ≥ 70

**Rationale:**
Project demonstrates sufficient completeness, quality, and clarity across all dimensions. Autonomous agents have clear specifications to work from with minimal ambiguity or risk.

**Typical Indicators:**
- Well-defined requirements in PRD
- Comprehensive app_spec.txt coverage
- Strong architectural alignment
- High-quality feature definitions

---

### CONDITIONAL GO (Approve with Conditions)

**Criteria:**
- Overall Score 60-74 OR
- 1-2 critical blockers with clear mitigation path OR
- App Spec Coverage 60-69 with plan to address gaps

**Rationale:**
Project has moderate readiness with specific, addressable gaps. Implementation can proceed if conditions are met first, or risks are actively mitigated during development.

**Typical Indicators:**
- Most requirements defined but some gaps
- Partial app_spec coverage with known gaps
- Some architectural concerns but workable
- Moderate feature quality with improvement path

**Conditions to Document:**
- Specific items that must be addressed
- Estimated effort to resolve
- Acceptable risk mitigation strategies
- Monitoring plan during implementation

---

### NO-GO (Do Not Proceed)

**Criteria:**
- Overall Score < 60 OR
- 3+ critical blockers OR
- App Spec Coverage < 60 OR
- Feature Quality < 60

**Rationale:**
Project lacks sufficient clarity, completeness, or quality for autonomous implementation. High risk of agent confusion, wasted effort, or implementation failure.

**Typical Indicators:**
- Significant requirements gaps in PRD
- Incomplete or missing app_spec coverage
- Multiple architectural violations
- Poor feature definitions with ambiguity

**Next Steps:**
- Identify critical improvements needed
- Estimate effort to reach minimum readiness
- Consider alternative approaches (human-led, hybrid)
- Re-assess after improvements completed

---

## Decision Output Format

```yaml
go_no_go: 'GO' | 'CONDITIONAL GO' | 'NO-GO'
decision_rationale: '{Clear explanation based on scores and blockers}'
```

**Rationale Guidelines:**
- Reference specific scores that drove decision
- Cite critical blockers or gaps (if applicable)
- Explain why threshold was/wasn't met
- Provide evidence from analysis dimensions
- Keep concise but specific (2-3 sentences)

**Examples:**

**GO Example:**
```
Overall Score: 82/100. All dimensions exceed 70, no critical blockers identified.
PRD and app_spec provide comprehensive specification. Ready for autonomous implementation.
```

**CONDITIONAL GO Example:**
```
Overall Score: 68/100. App Spec Coverage at 65% with 8 missing requirements.
One critical blocker: unclear authentication flow. Approve if authentication is
clarified and missing requirements added to app_spec within 1 week.
```

**NO-GO Example:**
```
Overall Score: 54/100. App Spec Coverage below threshold at 58%, Feature Quality
at 56%. Four critical blockers including undefined data models and missing API
contracts. Requires 2-3 weeks of refinement before reassessment.
```

---

## Framework Version

**Version:** 1.0
**Last Updated:** 2026-02-13
**Workflow:** check-autonomous-implementation-readiness
