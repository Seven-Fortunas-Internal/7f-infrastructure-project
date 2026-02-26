# Sprint Management

Unified sprint framework for engineering and business projects at Seven Fortunas.

## Contents

### BMAD Workflows
- `.claude/commands/bmad-bmm-create-sprint.md` - Create new sprint
- `.claude/commands/bmad-bmm-sprint-review.md` - Review and retrospective

### Velocity Tracking
- `velocity-history.json` - Historical sprint velocity data
- Automatically updated by sprint-review workflow

### Documentation
- `../docs/sprint-management/sprint-guide.md` - Complete sprint management guide

## Quick Start

### Create Sprint

```bash
# Engineering sprint (2 weeks, story points)
/bmad-bmm-create-sprint --type engineering --name "Sprint 1" --duration 2weeks

# Business sprint (3 weeks, hours)
/bmad-bmm-create-sprint --type business --name "Q1 Initiative" --duration 3weeks
```

### Complete Sprint

```bash
# Run sprint review and retrospective
/bmad-bmm-sprint-review --sprint SPRINT_001
```

### View Velocity

```bash
# Check velocity history
cat sprint-management/velocity-history.json

# View averages
jq '.averages' sprint-management/velocity-history.json
```

## Terminology

### Engineering Projects
PRD → Epics → Stories → Tasks
- **Estimation:** Story points (Fibonacci)
- **Duration:** 2 weeks
- **Team:** Engineering

### Business Projects
Initiative → Objectives → Tasks → Subtasks
- **Estimation:** Hours
- **Duration:** 1-4 weeks (flexible)
- **Team:** Business/Operations

## Sprint Metrics

- **Velocity:** Average story points completed per sprint
- **Completion Rate:** % of committed work delivered
- **Burndown:** Work remaining over time
- **Cycle Time:** Average time from start to done

## Integration

- **GitHub Projects:** Sprint board visualization
- **Sprint Dashboard (FR-8.2):** Real-time metrics
- **Project Dashboard (FR-8.3):** Overall progress

## References

- [Sprint Management Guide](../docs/sprint-management/sprint-guide.md)
- [BMAD Workflows](https://github.com/bmad-method/bmad-method)
- [GitHub Projects](https://docs.github.com/en/issues/planning-and-tracking-with-projects)

---

**Owner:** Jorge (VP AI-SecOps)
**Phase:** Phase 2
**Status:** Framework implemented, ready for first sprint
