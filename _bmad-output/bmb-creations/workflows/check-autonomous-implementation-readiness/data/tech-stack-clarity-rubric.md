# Technology Stack Clarity Rubric

## Purpose

Evaluate the specificity and clarity of technology stack specifications in app_spec.txt for autonomous agent implementation readiness.

## Assessment Criteria

### ✅ Clearly Specified (Excellent)

Technologies with full specificity:
- **Languages**: Versions specified (e.g., "Python 3.11+", "TypeScript 5.x")
- **Frameworks**: Versions specified (e.g., "React 18.x", "FastAPI 0.100+")
- **Databases**: Specific types and versions (e.g., "PostgreSQL 15+", "Redis 7.x")
- **Infrastructure**: Concrete specifications (e.g., "Docker 24.x", "Kubernetes 1.28+")

### ⚠️ Somewhat Clear (Needs Improvement)

Technologies with partial specificity:
- **Vague versions**: (e.g., "Python 3.x", "latest React")
- **Generic mentions**: (e.g., "SQL database", "modern framework")
- **Missing deployment environment details**

### ❌ Unclear (Critical Gap)

Technologies with insufficient detail:
- **No versions specified**
- **Generic "industry standard" language**
- **Missing critical technology stack components**

## Scoring Bands

| Score | Criteria |
|-------|----------|
| 90-100 | All technologies specified with versions |
| 70-89 | Most technologies clear, some version gaps |
| 50-69 | Many vague references, missing versions |
| 0-49 | Critical gaps in technology specification |

## Assessment Questions

When evaluating technology stack clarity:

1. Are all major technology choices explicitly named?
2. Are version numbers or version ranges specified?
3. Can an autonomous agent determine exact dependencies to install?
4. Are deployment environments and infrastructure specified?
5. Are development tools and build systems clearly defined?
6. Is there enough detail to create a reproducible environment?

## Agent-Readiness Impact

**High Clarity (90-100)**: Autonomous agent can immediately determine dependencies, setup scripts, and environment configuration.

**Medium Clarity (70-89)**: Agent can proceed with assumptions, but may need clarification for edge cases.

**Low Clarity (50-69)**: Agent will struggle with environment setup and dependency resolution.

**Critical Gaps (0-49)**: Autonomous implementation blocked without technology clarification.
