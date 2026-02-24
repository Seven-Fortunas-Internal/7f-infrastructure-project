# PRD Scoring Formulas

## Overall PRD Score Calculation

**Weighted Average Formula:**

```
Overall PRD Score = (Completeness × 0.25) + (FR Quality × 0.30) + (NFR Quality × 0.25) + (Success Criteria × 0.20)
```

**Weighting Rationale:**
- **Completeness (25%):** Structural foundation - all sections present
- **FR Quality (30%):** Highest weight - FRs drive implementation
- **NFR Quality (25%):** Critical for production readiness
- **Success Criteria (20%):** Important for validation, but secondary to requirements

---

## Score Interpretation Thresholds

**Overall PRD Score Ratings:**

| Score Range | Rating | Interpretation | Recommendation |
|-------------|--------|----------------|----------------|
| **90-100** | Excellent | PRD is comprehensive, clear, and ready for autonomous implementation | Proceed confidently |
| **70-89** | Good | PRD is solid with minor gaps; implementation can proceed with clarifications | Address gaps during implementation |
| **50-69** | Fair | PRD has significant gaps; risky to proceed without improvements | Revise PRD before autonomous implementation |
| **0-49** | Poor | PRD is insufficient for autonomous implementation | Major PRD revision required |

---

## Dimension-Specific Scoring

**Completeness Score:**
- Count present required sections
- Weight by section substantiveness (thin sections count as 0.5)
- Formula: `(present_sections / total_required_sections) × 100`

**FR Quality Score:**
- Average clarity, testability, completeness, and AC quality
- Use scoring bands from quality assessment criteria
- Formula: `(clarity + testability + completeness + AC) / 4`

**NFR Quality Score:**
- Average coverage, specificity, feasibility, and priority clarity
- Use scoring bands from quality assessment criteria
- Formula: `(coverage + specificity + feasibility + priority) / 4`

**Success Criteria Score:**
- Average clarity, alignment, and feasibility
- Use scoring bands from quality assessment criteria
- Formula: `(clarity + alignment + feasibility) / 3`

---

**Calculation Notes:**

1. **Evidence Required:** Each score must have supporting evidence from PRD
2. **No Rounding:** Use precise scores (e.g., 87.5, not 88)
3. **Document Gaps:** List specific gaps that reduce scores
4. **Objective Assessment:** Apply criteria consistently
