# Feature Quality Review - Output Template

## Markdown Output Format

Append this section to the readiness assessment output file:

```markdown
### 4. Feature Quality Review

**Composite Quality Score:** {composite_score}/100
**Quality Rating:** {Excellent/Good/Fair/Poor/Critical}

**Component Scores:**
- Feature Structure Quality: {structure_score}/100
- Verification Criteria Quality: {criteria_score}/100
- Category Distribution: {distribution_score}/100
- Dependency Quality: {dependency_score}/100
- Completeness: {completeness_score}/100
- Rubric-Based Quality: {rubric_score}/100

**Feature Specification Quality:** {overall_score}/100
**Autonomous Agent Readiness:** {readiness_score}/100

**Quality Breakdown:**
- High-Quality Features: {count} ({percentage}%)
- Medium-Quality Features: {count} ({percentage}%)
- Low-Quality Features: {count} ({percentage}%)

**Feature Structure Validation:**
- Features with all required elements: {count}/{total}
- Features too broad (>5 requirements): {count}
- Features too trivial: {count}
- Missing acceptance criteria: {count}

**Verification Criteria Quality:**
- Features with all 3 types (functional/technical/integration): {count}/{total}
- Features with measurable criteria: {count}/{total}
- Features with testable criteria: {count}/{total}
- Features with specific criteria: {count}/{total}
- Average criteria quality: {score}/100

**Category Distribution:**
- Infrastructure: {count} ({percentage}%)
- User Interface: {count} ({percentage}%)
- Business Logic: {count} ({percentage}%)
- Integration: {count} ({percentage}%)
- DevOps: {count} ({percentage}%)
- Security: {count} ({percentage}%)
- Testing: {count} ({percentage}%)
- Distribution balanced: {✅ Yes / ⚠️ Imbalanced}

**Dependency Quality:**
- All references valid: {✅ Yes / ❌ {count} broken}
- No circular dependencies: {✅ Yes / ❌ {count} cycles}
- Dependencies logical: {✅ Yes / ⚠️ Concerns}

**High-Quality Features:**
- {Feature Name}: {score}/100 - Ready for autonomous implementation

**Quality Concerns:**
- {Feature Name}: {score}/100 - {Specific concerns}

**Common Quality Issues:**
1. {Issue Category}: Affects {count} features
   - Example: {Specific example}
   - Impact: {Impact on autonomous execution}
   - Recommendation: {How to fix}

**Autonomous Agent Patterns:**
- Bounded retry logic: {present/absent}
- Failure recovery: {present/absent}
- Error handling: {present/absent}
- Validation steps: {present/absent}

**Critical Blockers ({count}):**
- {Feature Name}: {Blocker description}
- {Feature Name}: {Blocker description}

**Recommendation:**
- {Specific recommendations for feature specification improvements}
- {Specific recommendations for criteria quality improvements}
- {Specific recommendations for category distribution}
- {Specific recommendations for dependency fixes}

---
```

## Frontmatter Updates

Update the output file frontmatter with these fields:

```yaml
analysis_phase: 'feature-quality-complete'
composite_quality_score: {composite_score}
feature_quality_score: {overall_score}
autonomous_readiness_score: {readiness_score}
feature_structure_score: {structure_score}
criteria_quality_score: {criteria_score}
category_distribution_score: {distribution_score}
dependency_quality_score: {dependency_score}
completeness_score: {completeness_score}
critical_blockers_count: {count}
high_quality_features_count: {count}
```
