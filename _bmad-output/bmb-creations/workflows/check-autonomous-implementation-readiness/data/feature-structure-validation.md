# Feature Structure Validation Standards

## Required Feature Elements

For each feature in app_spec.txt, check required components:

- ✅/❌ Feature ID (FEATURE_XXX format)
- ✅/❌ Feature name (clear, descriptive)
- ✅/❌ Description (explains what and why)
- ✅/❌ Requirements list (2-5 specific requirements typical)
- ✅/❌ Acceptance criteria (present and defined)
- ✅/❌ Dependencies (if any, with valid FEATURE_XXX references)
- ✅/❌ Constraints (if any)

## Granularity Check

- ✅ Atomic (one independently implementable task)
- ⚠️ Too broad (>5 requirements, likely needs splitting)
- ⚠️ Too trivial (single-line change, not feature-worthy)

## Structure Validation Presentation Template

Present structural findings:

```
**Feature Structure Validation:**
- Features with all required elements: {count}/{total}
- Features too broad (>5 requirements): {count}
- Features too trivial: {count}
- Missing acceptance criteria: {count} features
- Missing dependencies section: {count} features
```
