# Feature Dependency Validation Standards

## Dependency Validation Checklist

Check dependency management quality:

**Dependency Validation:**
- All dependency references (FEATURE_XXX) exist: {✅ Yes / ❌ No - {count} broken references}
- No circular dependencies: {✅ Yes / ❌ No - {list cycles}}
- Dependencies make logical sense: {✅ Yes / ⚠️ Concerns: {list}}
- Hard dependencies clearly marked: {✅ Yes / ⚠️ Ambiguous}

## Dependency Issues Presentation Template

```
**Dependency Issues:**
- Broken references: {count} ({list})
- Circular dependencies: {count} ({list cycles})
- Questionable dependencies: {count} ({list with reasons})
```

## Dependency Quality Scoring

**Dependency Quality Score:** {0-100}

Calculate based on:
- Valid references: Major factor (all valid = 50 points)
- No circular dependencies: Critical factor (none = 30 points)
- Logical dependencies: Quality factor (all logical = 20 points)
