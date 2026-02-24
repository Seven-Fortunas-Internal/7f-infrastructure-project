# Coding Standards Specificity Rubric

## Purpose

Assess the actionability and specificity of coding standards in app_spec.txt for autonomous agent code generation.

## Assessment Criteria

### ✅ Concrete Guidance (Excellent)

Standards with specific, actionable rules:

- **Naming conventions**: Specific patterns (e.g., "camelCase for variables", "PascalCase for components")
- **File organization**: Specific structure (e.g., "features/ organized by domain")
- **Code patterns**: Specific examples (e.g., "Use React hooks pattern", "Repository pattern for data access")
- **Error handling**: Specific patterns (e.g., "try-catch with typed errors", "return Result<T, E> type")
- **Testing requirements**: Specific thresholds (e.g., "80% unit test coverage", "E2E tests for all user flows")

### ⚠️ Generic Guidance (Needs Improvement)

Standards that lack specificity:

- "Follow best practices" (which practices?)
- "Write clean code" (what defines clean?)
- "Use industry standards" (which standards?)
- "Test thoroughly" (how much? what kind?)

### ❌ No Guidance (Critical Gap)

Insufficient or missing standards:

- Empty coding_standards section
- Only platitudes without actionable rules
- No specific patterns or examples

## Scoring Bands

| Score | Criteria |
|-------|----------|
| 90-100 | All standards have concrete, actionable guidance with examples |
| 70-89 | Most standards clear, some generic statements |
| 50-69 | Mix of specific and generic, lacks examples |
| 0-49 | Mostly generic or missing |

## Agent-Readiness Assessment

### Question: Can an autonomous agent follow these standards?

**✅ Yes (90-100 score)**: Agent can generate code that adheres to all specified standards without human intervention.

**⚠️ Partially (50-89 score)**: Agent can follow some standards but will make assumptions for generic guidance.

**❌ No (0-49 score)**: Agent cannot determine coding style, patterns, or quality expectations.

### Justification Criteria

When assessing agent-readiness:

1. Are naming conventions specific enough to generate consistent code?
2. Is file organization clear enough to place new files correctly?
3. Are error handling patterns specific enough to handle exceptions consistently?
4. Are testing requirements measurable and verifiable?
5. Are code patterns illustrated with examples or clear descriptions?
6. Can the agent self-validate code quality against these standards?

## Impact on Autonomous Implementation

**High Specificity (90-100)**: Agent produces code matching project conventions on first pass.

**Medium Specificity (70-89)**: Agent produces functional code but may require style corrections.

**Low Specificity (50-69)**: Agent code may work but will likely deviate from project style.

**No Specificity (0-49)**: Agent cannot ensure code quality or consistency.
