# Coverage Scoring Formulas

**Purpose:** Calculation formulas for PRD-to-app_spec coverage analysis.

**Version:** 1.0
**Last Updated:** 2026-02-13
**Used By:** Step 4 - App Spec Coverage Validation

---

## Functional Requirements Coverage Formula

**Coverage Classification:**
- **Fully covered:** Feature specification addresses requirement completely
- **Partially covered:** Feature touches requirement but incomplete
- **Not covered:** No feature addresses this requirement

**Coverage Score Calculation:**
```
FR Coverage Score = ((Fully Covered × 1.0) + (Partially Covered × 0.5)) / Total FRs × 100
```

**Example:**
- Total FRs: 20
- Fully covered: 15
- Partially covered: 3
- Not covered: 2
- FR Coverage Score = ((15 × 1.0) + (3 × 0.5)) / 20 × 100 = **82.5%**

---

## Non-Functional Requirements Coverage Formula

**Coverage Classification:**
- **Fully covered:** NFR specification addresses requirement completely
- **Partially covered:** NFR touches requirement but incomplete
- **Not covered:** No NFR section addresses this requirement

**Coverage Score Calculation:**
```
NFR Coverage Score = ((Fully Covered × 1.0) + (Partially Covered × 0.5)) / Total NFRs × 100
```

**Example:**
- Total NFRs: 10
- Fully covered: 7
- Partially covered: 2
- Not covered: 1
- NFR Coverage Score = ((7 × 1.0) + (2 × 0.5)) / 10 × 100 = **80%**

---

## Overall Coverage Score Calculation

**Weighted Average (Functional Requirements weighted more heavily):**
```
Overall Coverage Score = (FR Coverage Score × 0.7) + (NFR Coverage Score × 0.3)
```

**Rationale:** Functional requirements typically represent the core feature set, so they receive 70% weight vs. 30% for NFRs.

**Example:**
- FR Coverage Score: 82.5%
- NFR Coverage Score: 80%
- Overall Coverage Score = (82.5 × 0.7) + (80 × 0.3) = **81.75%**

---

## Coverage Rating Thresholds

| Score Range | Rating | Interpretation |
|-------------|--------|----------------|
| 90-100 | Excellent | Comprehensive coverage, ready for implementation |
| 75-89 | Good | Strong coverage, minor gaps acceptable |
| 60-74 | Fair | Adequate coverage, some gaps need addressing |
| 40-59 | Poor | Significant gaps, requires app_spec refinement |
| 0-39 | Critical | Insufficient coverage, major gaps block implementation |

---

## Presentation Format

**Coverage Scores Section:**
```markdown
**Functional Requirements Coverage:**
- Fully covered: {count} ({percentage}%)
- Partially covered: {count} ({percentage}%)
- Not covered: {count} ({percentage}%)
- **FR Coverage Score:** {score}/100

**Non-Functional Requirements Coverage:**
- Fully covered: {count} ({percentage}%)
- Partially covered: {count} ({percentage}%)
- Not covered: {count} ({percentage}%)
- **NFR Coverage Score:** {score}/100

**Overall Coverage Score:** {overall_score}/100 ({rating})
```
