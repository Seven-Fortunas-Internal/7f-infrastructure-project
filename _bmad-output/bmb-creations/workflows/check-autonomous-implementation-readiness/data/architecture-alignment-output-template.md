# Architecture Alignment Output Template

## Purpose

Standard template for appending architecture alignment assessment results to readiness assessment output file.

## Template Structure

```markdown
### 3. Architecture Alignment Assessment

**Overall Architecture Score:** {combined_score}/100
- Alignment Score: {alignment_score}/100
- Technology Stack Clarity: {tech_stack_score}/100
- Coding Standards Specificity: {coding_standards_score}/100

**Architectural Compliance:**
- {Areas where PRD/app_spec align with architecture}

**Misalignments:**
- {Areas where PRD/app_spec conflict with architecture}

**Technology Stack Assessment:**
- PRD Technologies: {list}
- app_spec Technologies: {list}
- Architecture Technologies: {list}
- Consistency: {✅ Aligned / ⚠️ Mismatches found}
- Clarity: {Versions specified / Generic references / Missing specifications}
- Agent-Readiness: {✅ Clear enough for autonomous implementation / ⚠️ Needs clarification}

**Coding Standards Assessment:**
- Specificity: {Concrete guidance / Generic guidance / Missing}
- Actionability: {Can agent follow standards? ✅/⚠️/❌}
- Examples Provided: {✅ Yes / ❌ No}
- Critical Gaps: {List any missing or vague standards}

**Key ADRs Validated:**
- ADR-{number}: {Decision} - {Compliance status}
- ADR-{number}: {Decision} - {Compliance status}

**Architectural Risks:**
- {Risk 1}: {Impact} - {Mitigation}
- {Risk 2}: {Impact} - {Mitigation}

**Recommendation:**
- {Specific recommendations for resolving misalignments}
- {Specific recommendations for clarifying tech stack}
- {Specific recommendations for improving coding standards}

---
```

## Frontmatter Update

Update the output file frontmatter with:

```yaml
analysis_phase: 'architecture-alignment-complete'
architecture_alignment_score: {alignment_score}
tech_stack_clarity_score: {tech_stack_score}
coding_standards_specificity_score: {coding_standards_score}
combined_architecture_score: {combined_score}
architectural_violations_count: {count}
```

## Field Descriptions

### Scores

- **combined_score**: Weighted average (Alignment * 0.5 + Tech Stack * 0.25 + Coding Standards * 0.25)
- **alignment_score**: Compliance with architectural constraints (0-100)
- **tech_stack_score**: Technology specification clarity (0-100)
- **coding_standards_score**: Standards specificity and actionability (0-100)

### Architectural Compliance

List areas where PRD requirements and app_spec.txt features align with:
- Documented architecture patterns
- Technology stack requirements
- Design decisions from ADRs
- Security/scalability constraints

### Misalignments

List areas where PRD requirements or app_spec.txt features:
- Contradict architectural decisions
- Violate design patterns
- Assume technologies outside approved stack
- Ignore documented constraints

### Technology Stack Assessment

- **PRD Technologies**: Technologies mentioned in PRD
- **app_spec Technologies**: Technologies specified in app_spec.txt `<technology_stack>`
- **Architecture Technologies**: Technologies mandated in architecture docs
- **Consistency**: Cross-document alignment check
- **Clarity**: Version specificity assessment
- **Agent-Readiness**: Can autonomous agent implement with given detail?

### Coding Standards Assessment

- **Specificity**: Concrete vs generic guidance level
- **Actionability**: Can agent follow without human interpretation?
- **Examples Provided**: Are patterns illustrated?
- **Critical Gaps**: Missing or vague standards blocking autonomous implementation

### Key ADRs Validated

List relevant Architecture Decision Records with:
- ADR number
- Decision summary
- Compliance status (aligned / conflicted / violated)

### Architectural Risks

For each identified risk:
- **Risk Category**: Type of risk (e.g., scalability, security, maintainability)
- **Impact**: High/Medium/Low
- **Mitigation**: Recommended action to address risk

### Recommendations

Specific actions to:
- Resolve architectural misalignments
- Clarify technology stack specifications
- Improve coding standards specificity
- Address identified risks
