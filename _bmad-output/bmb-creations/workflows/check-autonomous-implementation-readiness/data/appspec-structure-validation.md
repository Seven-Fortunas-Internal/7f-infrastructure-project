# App Spec Structure Validation Rules

**Purpose:** Basic structure validation rules for app_spec.txt before analyzing coverage.

**Version:** 1.0
**Last Updated:** 2026-02-13
**Used By:** Step 4 - App Spec Coverage Validation

---

## 10 Required XML Sections

Every app_spec.txt MUST contain these sections:

1. **metadata** - Project info, generation date, feature count
2. **overview** - Project purpose, scope, context
3. **technology_stack** - Languages, frameworks, databases, infrastructure
4. **coding_standards** - Naming conventions, patterns, best practices
5. **core_features** - All feature specifications
6. **non_functional_requirements** - Performance, security, scalability, compliance
7. **testing_strategy** - Unit, integration, E2E test requirements
8. **deployment_instructions** - CI/CD, infrastructure, monitoring
9. **reference_documentation** - Links to PRD, architecture, external docs
10. **success_criteria** - Overall project completion definition

---

## XML Well-Formedness Criteria

**Validation Checks:**
- All tags properly nested (no interleaved tags)
- All opening tags have corresponding closing tags
- No malformed XML syntax
- Proper escaping of special characters (< > & in content)

**Common Issues to Check:**
- Unclosed tags (e.g., `<feature>` without `</feature>`)
- Improper nesting (e.g., `<a><b></a></b>`)
- Unescaped characters (e.g., `<` or `>` in text content)

---

## Frontmatter Validation Rules

**Required Fields:**
```yaml
project_name: "Project Name"
generated_date: "YYYY-MM-DD"
feature_count: XX
prd_source: "path/to/prd.md"
workflow_version: "X.X"
```

**Validation Checks:**
- All required fields present
- Date format valid (YYYY-MM-DD)
- Feature count is a positive integer

---

## Feature ID Sequential Validation

**Expected Format:** FEATURE_001, FEATURE_002, FEATURE_003, etc.

**Validation Rules:**
- Sequential numbering (no gaps in sequence)
- Format: FEATURE_ prefix + 3-digit zero-padded number
- Starting from FEATURE_001 (or FEATURE_000 if used)

**Validation Output:**
- ✅ **Sequential IDs with no gaps** - All features numbered consecutively
- ⚠️ **Gaps detected at:** {list} - May indicate removed features or ID errors
- ❌ **Non-sequential or invalid format** - ID pattern broken

---

## Structure Validation Presentation Template

```markdown
**app_spec.txt Structure Validation:**
- XML Sections: {count}/10 required sections present
- XML Well-Formed: {✅ Yes / ❌ No}
- Frontmatter Complete: {✅ Yes / ❌ No}
- Feature IDs Sequential: {✅ No gaps / ⚠️ Gaps at: {list}}

{If any missing sections, list them:}
**Missing Sections:**
- {section_name}
- {section_name}

{If XML issues found:}
**XML Issues:**
- {issue_description}

{If frontmatter issues found:}
**Frontmatter Issues:**
- {missing_field or validation_error}
```

---

**Note:** If structure validation fails, note as critical issue but continue with coverage analysis using available content.
