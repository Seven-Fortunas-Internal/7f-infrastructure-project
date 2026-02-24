# PRD Analysis Output Template

## Markdown Section to Append to Output File

```markdown
## Assessment Dimensions

### 1. PRD Analysis

**Completeness Score:** {completeness_score}/100
**Quality Score:** {overall_score}/100

**Strengths:**
- {Key strength 1 - specific section/requirement reference}
- {Key strength 2 - specific section/requirement reference}
- {Key strength 3 - specific section/requirement reference}

**Gaps:**
- {Gap 1 - specific section missing or ambiguity with reference}
- {Gap 2 - specific section missing or ambiguity with reference}
- {Gap 3 - specific section missing or ambiguity with reference}

**Functional Requirements:**
- Quality Score: {fr_score}/100
- **Summary:** {Brief assessment of FR quality - reference specific FRs}
- **Issues:** {List specific ambiguous or untestable FRs with FR IDs}

**Non-Functional Requirements:**
- Quality Score: {nfr_score}/100
- **Coverage:** {List covered NFR categories: Security, Performance, Scalability, Reliability}
- **Gaps:** {List missing or vague NFRs with specific examples}

**Success Criteria:**
- Quality Score: {sc_score}/100
- **Defined Metrics:** {List success metrics from PRD}
- **Gaps:** {List areas without clear success criteria}

**Recommendation:**
- **Go/No-Go:** {Ready to proceed / Needs revision}
- **Required Actions:** {Specific recommendations for PRD improvements before implementation}
  1. {Action 1 with specific PRD section/requirement reference}
  2. {Action 2 with specific PRD section/requirement reference}
  3. {Action 3 with specific PRD section/requirement reference}

---
```

---

## Frontmatter Updates

**Add these fields to output file frontmatter:**

```yaml
analysis_phase: 'prd-analysis-complete'
prd_completeness_score: {completeness_score}
prd_quality_score: {overall_score}
prd_fr_quality_score: {fr_score}
prd_nfr_quality_score: {nfr_score}
prd_success_criteria_score: {sc_score}
prd_gaps_count: {count of identified gaps}
prd_ambiguities_count: {count of ambiguities requiring clarification}
```

---

## User Summary Presentation

**Present to user after appending to file:**

```
**PRD Analysis Complete**

**Overall PRD Score:** {overall_score}/100

**Key Findings:**
- Completeness: {completeness_score}/100
- Functional Requirements: {fr_score}/100
- Non-Functional Requirements: {nfr_score}/100
- Success Criteria: {sc_score}/100

**Critical Gaps:** {gaps_count} identified
**Ambiguities:** {ambiguities_count} require clarification

**Assessment:** {PRD is ready for autonomous implementation / PRD needs revision before proceeding}

**Next:** App Spec Coverage Validation - We'll verify how well app_spec.txt covers these PRD requirements.
```

---

**Template Usage Notes:**

1. **Replace all placeholders** with actual scores and findings
2. **Provide specific references** - no generic comments
3. **Link to evidence** - cite PRD sections, FR IDs, NFR IDs
4. **Be actionable** - recommendations must be specific and measurable
