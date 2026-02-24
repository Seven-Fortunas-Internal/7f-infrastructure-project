# Coverage Analysis Output Template

**Purpose:** Standard markdown template for appending coverage analysis results to readiness assessment.

**Version:** 1.0
**Last Updated:** 2026-02-13
**Used By:** Step 4 - App Spec Coverage Validation

---

## Output File Section Template

```markdown
### 2. App Spec Coverage Analysis

**Coverage Score:** {overall_coverage_score}/100
**Feature Mapping Completeness:** {percentage}%

**Structure Validation:**
- XML Sections: {count}/10 required sections present {✅ Complete / ⚠️ Missing: {list}}
- XML Well-Formed: {✅ Yes / ❌ No - {errors}}
- Frontmatter Complete: {✅ Yes / ❌ Missing: {fields}}
- Feature IDs Sequential: {✅ No gaps / ⚠️ Gaps at: {list}}

**Coverage Breakdown:**
- Functional Requirements: {fr_coverage_score}/100 ({fully_covered}/{total_frs} fully covered)
- Non-Functional Requirements: {nfr_coverage_score}/100 ({fully_covered}/{total_nfrs} fully covered)

**Well-Covered Requirements:**
- {List top 3-5 requirements with complete coverage}

**Coverage Gaps:**

**Not Covered ({count}):**
- {FR/NFR-ID}: {Description}
- {FR/NFR-ID}: {Description}

**Partially Covered ({count}):**
- {FR/NFR-ID}: {Description} - Missing: {specific gap}
- {FR/NFR-ID}: {Description} - Missing: {specific gap}

**Features Without PRD Mapping ({count}):**
- {Feature Name} - {Reason: scope creep / missing PRD req / implementation detail}

**Recommendation:**
- {Specific recommendations for app_spec.txt improvements to close gaps}

---
```

---

## Frontmatter Update Specification

**Add these fields to output file frontmatter:**

```yaml
analysis_phase: 'appspec-coverage-complete'
appspec_coverage_score: {overall_coverage_score}
fr_coverage: {fr_coverage_score}
nfr_coverage: {nfr_coverage_score}
coverage_gaps_count: {total_gaps}
appspec_structure_valid: {true/false}
appspec_xml_wellformed: {true/false}
appspec_feature_id_sequential: {true/false}
```

---

## Structure Validation Presentation

**When all validations pass:**
```markdown
**Structure Validation:**
- XML Sections: 10/10 required sections present ✅ Complete
- XML Well-Formed: ✅ Yes
- Frontmatter Complete: ✅ Yes
- Feature IDs Sequential: ✅ No gaps
```

**When issues found:**
```markdown
**Structure Validation:**
- XML Sections: 8/10 required sections present ⚠️ Missing: deployment_instructions, success_criteria
- XML Well-Formed: ❌ No - Unclosed tag at line 145
- Frontmatter Complete: ⚠️ Missing: workflow_version
- Feature IDs Sequential: ⚠️ Gaps at: FEATURE_005, FEATURE_012
```

---

## Coverage Breakdown Format

**Standard format for presenting FR and NFR coverage:**

```markdown
**Coverage Breakdown:**
- Functional Requirements: 82.5/100 (15/20 fully covered)
  - Fully: 15 (75%)
  - Partially: 3 (15%)
  - Not covered: 2 (10%)
- Non-Functional Requirements: 80/100 (7/10 fully covered)
  - Fully: 7 (70%)
  - Partially: 2 (20%)
  - Not covered: 1 (10%)
```

---

## Gap Identification Format

**Requirements Not Covered:**
```markdown
**Not Covered (2):**
- FR-18: Real-time collaboration features - No feature in app_spec.txt addresses WebSocket or real-time sync
- NFR-PERF-3: Page load <2 seconds - No performance requirements specified in app_spec.txt
```

**Requirements Partially Covered:**
```markdown
**Partially Covered (5):**
- FR-03: Data export functionality - FEATURE_012 handles JSON export, but CSV and Excel formats missing
- FR-07: Advanced search with filters - FEATURE_015 implements basic search, missing date range and multi-criteria filters
- NFR-SEC-2: Role-based access control (RBAC) - FEATURE_002 defines user roles, but permission matrix not specified
```

**Features Without PRD Mapping:**
```markdown
**Features Without PRD Mapping (3):**
- FEATURE_025: Database migration scripts - Implementation detail (acceptable)
- FEATURE_031: Admin dashboard analytics - Not in PRD scope (potential scope creep)
- FEATURE_042: Logging infrastructure - Supporting feature (acceptable)

**Note:** Features without PRD mapping may indicate:
- Scope creep (out-of-scope features added)
- Missing PRD requirements
- Implementation details (acceptable if supporting core features)
```

---

## Recommendations Format

**Provide specific, actionable recommendations:**

```markdown
**Recommendation:**
- Add real-time collaboration features (WebSocket support) to address FR-18
- Expand FEATURE_012 to include CSV and Excel export formats for FR-03 compliance
- Specify RBAC permission matrix in FEATURE_002 to fully cover NFR-SEC-2
- Add performance requirements section to NFR with <2s page load target (NFR-PERF-3)
- Review FEATURE_031 (Admin analytics) - not in PRD scope, confirm if required or remove
```

---

**Usage Note:** Agent should populate this template with actual data from coverage analysis, maintaining consistent formatting and providing specific evidence for all claims.
