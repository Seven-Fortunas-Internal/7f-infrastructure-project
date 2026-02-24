# Final Assessment Output Template

## Purpose

Provides standardized markdown template for the final assessment section of the readiness report, ensuring consistent structure and completeness.

## Template Structure

### Section 1: Overall Readiness Assessment

```markdown
## Overall Readiness Assessment

**Overall Readiness Score:** {readiness_score} / 100

**Dimension Breakdown:**
- PRD Analysis: {prd_quality_score}/100
- App Spec Coverage: {appspec_coverage_score}/100
- Architecture Alignment: {architecture_alignment_score}/100
- Feature Quality: {feature_quality_score}/100

**Go/No-Go Decision:** {go_no_go}

**Rationale:**
{decision_rationale}
```

**Field Specifications:**

- `{readiness_score}`: Weighted average (calculated in step-07)
  - PRD Quality: 20% weight
  - App Spec Coverage: 25% weight
  - Architecture Alignment: 20% weight
  - Feature Quality: 35% weight

- `{prd_quality_score}`: From step-03 frontmatter
- `{appspec_coverage_score}`: From step-04 frontmatter
- `{architecture_alignment_score}`: From step-05 frontmatter
- `{feature_quality_score}`: From step-06 frontmatter

- `{go_no_go}`: One of: `GO`, `CONDITIONAL GO`, `NO-GO`
- `{decision_rationale}`: 2-4 sentences explaining decision based on scores and blockers

---

### Section 2: Action Items

```markdown
---

## Action Items

### Critical (Must Address Before Implementation)

1. **{Action item title}** - Source: {step-XX}
   - **Issue:** {Description of gap/blocker}
   - **Impact:** {Why this blocks autonomous implementation}
   - **Suggested Fix:** {How to address}
   - **Effort:** {Estimated time}

2. {Additional critical items...}

### High Priority (Should Address Before Implementation)

1. **{Action item title}** - Source: {step-XX}
   - **Issue:** {Description of concern}
   - **Impact:** {Why this affects implementation quality}
   - **Suggested Fix:** {How to address}
   - **Effort:** {Estimated time}

2. {Additional high priority items...}

### Medium Priority (Address During Implementation)

1. **{Action item title}** - Source: {step-XX}
   - **Issue:** {Description of improvement}
   - **Impact:** {Minor quality impact}
   - **Suggested Fix:** {How to address}
   - **Effort:** {Estimated time}

2. {Additional medium priority items...}

### Low Priority (Nice to Have)

1. **{Action item title}** - Source: {step-XX}
   - **Issue:** {Description of enhancement}
   - **Impact:** {Marginal value}
   - **Suggested Fix:** {How to address}
   - **Effort:** {Estimated time}

2. {Additional low priority items...}
```

**Field Specifications:**

- `{Action item title}`: Brief imperative phrase (e.g., "Define data models for core entities")
- `{step-XX}`: Reference to source analysis step (step-02 through step-06)
- **Issue:** What's wrong, missing, or needs improvement
- **Impact:** Specific consequence for autonomous implementation
- **Suggested Fix:** Actionable recommendation
- **Effort:** Estimated time (hours/days)

**Prioritization:**
- Extract from all prior steps (02-06)
- Apply prioritization framework
- Include at least 1 item per priority level (if issues exist)
- Reference specific findings from analysis

---

### Section 3: Recommendations for Autonomous Agent Success

```markdown
---

## Recommendations for Autonomous Agent Success

**Implementation Strategy:**
- {Recommendation based on readiness level}
- {Approach tailored to GO/CONDITIONAL GO/NO-GO decision}

**Risk Mitigation:**
- {Key risk identified across dimensions}
- {Specific mitigation strategy}
- {Monitoring approach during implementation}

**Success Criteria:**
- {Measurable criterion for successful autonomous implementation}
- {Acceptance threshold or metric}
- {Verification method}

**Autonomous Agent Configuration:**
- {Recommendations for agent setup based on feature quality findings}
- {Suggested tools, frameworks, or constraints}
- {Monitoring and intervention points}
```

**Field Specifications:**

**For GO Decisions:**
- Implementation Strategy: Recommended approach (e.g., "Proceed with phased rollout starting with high-quality features")
- Risk Mitigation: Key risks and mitigation (e.g., "Monitor F-003 authentication implementation closely due to moderate quality score")
- Success Criteria: Measurable outcomes (e.g., "All critical features implemented per spec within 3 sprints")
- Agent Configuration: Setup recommendations (e.g., "Enable strict validation mode, require human review for features scored <70")

**For CONDITIONAL GO Decisions:**
- Implementation Strategy: Conditions-first approach (e.g., "Address 3 critical action items, then proceed in 2-week increments")
- Risk Mitigation: Condition monitoring (e.g., "Re-assess coverage after addressing gaps, halt if new blockers emerge")
- Success Criteria: Gated milestones (e.g., "Conditions met within 1 week, feature quality improves to 70+ after first iteration")
- Agent Configuration: Constrained setup (e.g., "Limit agent to high-quality features only until conditions resolved")

**For NO-GO Decisions:**
- Implementation Strategy: Remediation plan (e.g., "Complete critical action items, re-run assessment in 2-3 weeks")
- Risk Mitigation: Alternative approaches (e.g., "Consider human-led development for unclear features, hybrid approach for well-defined features")
- Success Criteria: Readiness thresholds (e.g., "Achieve overall score ≥75, app spec coverage ≥70, resolve all critical blockers")
- Agent Configuration: Hold implementation (e.g., "Do not configure autonomous agents until readiness criteria met")

---

### Section 4: Assessment Footer

```markdown
---

**Assessment Completed:** {created_date}
**Assessed By:** {user_name}
**Workflow:** check-autonomous-implementation-readiness v1.0
**Overall Readiness:** {readiness_score}/100 - {go_no_go}
```

**Field Specifications:**
- `{created_date}`: ISO 8601 timestamp (from initialization)
- `{user_name}`: User name (from initialization)
- `{readiness_score}`: Overall readiness score
- `{go_no_go}`: Final decision

---

## Frontmatter Update Specification

After completing the final assessment sections, update the output file frontmatter:

```yaml
analysis_phase: 'complete'
readiness_score: {overall_readiness_score}
go_no_go: '{GO | CONDITIONAL GO | NO-GO}'
critical_action_items_count: {count}
assessment_completed: {timestamp}
```

**Field Specifications:**
- `analysis_phase`: Set to `'complete'`
- `readiness_score`: Overall weighted average (0-100)
- `go_no_go`: Decision outcome (one of three values)
- `critical_action_items_count`: Number of critical priority items
- `assessment_completed`: ISO 8601 timestamp

---

## Score Interpretation Guidelines

**90-100 (Excellent):**
- Ready for autonomous implementation
- Minor optimizations only
- High confidence in agent success

**75-89 (Good):**
- Ready with minor refinements
- Some areas to improve during implementation
- Moderate confidence in agent success

**60-74 (Fair):**
- Conditional readiness
- Moderate improvements needed first
- Proceed with caution and monitoring

**45-59 (Poor):**
- Not ready for autonomous implementation
- Significant work required
- High risk of agent failure

**0-44 (Critical):**
- Fundamentally not ready
- Major gaps across dimensions
- Do not proceed with autonomous implementation

---

## Template Version

**Version:** 1.0
**Last Updated:** 2026-02-13
**Workflow:** check-autonomous-implementation-readiness
**Output File:** readiness-assessment-{project_name}.md
