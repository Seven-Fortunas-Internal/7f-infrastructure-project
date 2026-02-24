# Seven Fortunas Sprint Management System

## Overview

The Seven Fortunas Sprint Management System provides unified sprint planning and tracking across all organizational work using BMAD workflows integrated with GitHub Projects.

## Core Workflows

### 1. Sprint Planning (`/bmad-bmm-sprint-planning`)

**Purpose:** Generate and manage sprint status tracking for implementation phases.

**What it does:**
- Extracts all epics and stories from epic files
- Creates a `sprint-status.yaml` tracking file
- Auto-detects work item status based on file existence
- Tracks status through the complete development lifecycle

**When to use:**
- At start of each sprint to generate initial status
- Mid-sprint to refresh auto-detected statuses
- After creating new story files

**Location:** `_bmad/bmm/workflows/4-implementation/sprint-planning/`

### 2. Sprint Status Management (`/bmad-bmm-sprint-status`)

**Purpose:** Update individual work item statuses during development.

**When to use:**
- Mark epic as `in-progress` when starting work
- Update story status as it progresses
- Mark retrospective as `done` after completion

## Dual Terminology Support

The system supports flexible terminology for different project types:

### Technical Projects (Engineering)
```
Product Requirements Document (PRD)
  ↓
Epics
  ↓
User Stories
  ↓
Sprints
```

### Business Projects (Operations)
```
Initiative
  ↓
Objectives
  ↓
Tasks
  ↓
Sprints
```

**Implementation Note:** Both use the same underlying BMAD workflow structure. The terminology is presentation-only and can be customized per project.

## Status State Machine

### Epic Status Flow
```
backlog → in-progress → done
```

- **backlog**: Epic not yet started
- **in-progress**: Epic actively being worked on (stories being created/implemented)
- **done**: All stories in epic completed

### Story Status Flow
```
backlog → ready-for-dev → in-progress → review → done
```

- **backlog**: Story only exists in epic file
- **ready-for-dev**: Story file created in `stories/` directory
- **in-progress**: Developer actively working on implementation
- **review**: Ready for code review (via Dev's code-review workflow)
- **done**: Completed and merged

### Retrospective Status
```
optional ↔ done
```

- **optional**: Ready to be conducted but not required
- **done**: Retrospective completed

## Sprint Metrics

### Velocity Calculation

**Sprint Velocity** = Number of stories completed / Sprint duration

The system tracks:
- Stories planned vs. completed
- Story completion rate
- Average velocity across sprints
- Velocity trends

**Tool:** Use `scripts/calculate-sprint-velocity.sh` to compute metrics.

### Burndown Charts

Track remaining work over sprint duration.

**Data points:**
- Total stories at sprint start
- Stories completed each day
- Remaining stories
- Target completion line

**Tool:** Use `scripts/generate-burndown-data.sh` to extract data for visualization.

### Completion Rate

**Completion Rate** = (Stories done / Total stories) × 100%

Tracks overall progress and predicts sprint completion.

## GitHub Projects Integration

### Overview

Sprint data syncs to GitHub Projects for Kanban board visualization.

### Setup Process

1. **Create GitHub Project Board**
   ```bash
   gh project create --owner Seven-Fortunas-Internal --title "7F Infrastructure Sprint"
   ```

2. **Configure Board Columns**
   - Backlog
   - Ready for Dev
   - In Progress
   - Review
   - Done

3. **Map Story Files to Issues**
   ```bash
   # Use scripts/sync-stories-to-github.sh
   ./scripts/sync-stories-to-github.sh
   ```

4. **Auto-sync on Status Changes**
   - BMAD workflows update `sprint-status.yaml`
   - GitHub Action watches for changes
   - Issues automatically move between columns

### Sync Tool

**Script:** `scripts/sync-stories-to-github.sh`

**What it does:**
1. Reads `sprint-status.yaml`
2. Creates/updates GitHub issues for each story
3. Sets issue labels based on epic
4. Moves issues to correct project column based on status
5. Updates issue descriptions with story details

**Usage:**
```bash
# Sync all stories
./scripts/sync-stories-to-github.sh

# Sync specific epic
./scripts/sync-stories-to-github.sh --epic 1

# Dry run (preview changes)
./scripts/sync-stories-to-github.sh --dry-run
```

## Sprint Workflow Example

### Starting a New Sprint

1. **Generate Sprint Status**
   ```
   /bmad-bmm-sprint-planning
   ```

2. **Review Generated Status**
   ```bash
   cat _bmad-output/implementation-artifacts/sprint-status.yaml
   ```

3. **Sync to GitHub Projects**
   ```bash
   ./scripts/sync-stories-to-github.sh
   ```

4. **Mark Epic as In Progress**
   ```
   /bmad-bmm-sprint-status
   # Select epic, set status to "in-progress"
   ```

### During Sprint

1. **Create Story File** (moves to `ready-for-dev` automatically)
   ```
   /bmad-bmm-create-story
   ```

2. **Start Working on Story** (manual update)
   ```
   /bmad-bmm-sprint-status
   # Select story, set status to "in-progress"
   ```

3. **Complete Story**
   ```
   /bmad-bmm-sprint-status
   # Select story, set status to "review" or "done"
   ```

4. **Sync Changes**
   ```bash
   ./scripts/sync-stories-to-github.sh
   ```

### End of Sprint

1. **Run Sprint Metrics**
   ```bash
   ./scripts/calculate-sprint-velocity.sh
   ./scripts/generate-burndown-data.sh
   ```

2. **Conduct Retrospective**
   - Review velocity and completion rate
   - Identify blockers and improvements
   - Update retrospective status to `done`

3. **Mark Epic as Done** (if all stories complete)
   ```
   /bmad-bmm-sprint-status
   ```

## Best Practices

### Epic and Story Management

1. **Epic Activation**: Mark epic as `in-progress` when starting work on its first story
2. **Sequential Default**: Stories are typically worked in order, but parallel work is supported
3. **Parallel Work**: Multiple stories can be `in-progress` if team capacity allows
4. **Review Before Done**: Stories should pass through `review` status before `done`
5. **Learning Transfer**: Create next story after previous one is `done` to incorporate learnings

### Sprint Planning

1. **Right-sized Stories**: Each story should be completable within 1-3 days
2. **Buffer Capacity**: Plan for 80% of team capacity to account for interruptions
3. **Dependencies First**: Complete foundational stories before dependent work
4. **Regular Sync**: Update GitHub Projects daily to maintain visibility

### Metrics and Reporting

1. **Track Velocity**: Record velocity for each sprint to improve estimation
2. **Daily Burndown**: Update burndown data daily for accurate progress tracking
3. **Retrospectives**: Always complete retrospectives to capture lessons learned
4. **Trend Analysis**: Review velocity trends across multiple sprints

## Integration Points

### Sprint Dashboard (FR-8.2)

Sprint management integrates with the sprint dashboard for real-time visualization:
- Current sprint status
- Velocity chart
- Burndown chart
- Story completion timeline

**Dashboard:** `dashboards/sprint-dashboard/`

### Project Progress Dashboard (FR-8.3)

Sprint data feeds into project-level progress tracking:
- Cross-epic progress
- Overall project velocity
- Milestone tracking
- Resource allocation

**Dashboard:** `dashboards/project-progress/`

## Troubleshooting

### Story Status Not Auto-Updating

**Symptom:** New story file created but status still shows `backlog`

**Solution:**
```bash
# Re-run sprint planning to refresh auto-detection
/bmad-bmm-sprint-planning
```

### GitHub Sync Failing

**Symptom:** `sync-stories-to-github.sh` fails with API errors

**Solution:**
```bash
# Verify GitHub authentication
gh auth status

# Check GitHub Projects API access
gh api graphql --field query='query { viewer { login } }'

# Re-run with verbose logging
./scripts/sync-stories-to-github.sh --verbose
```

### Velocity Calculation Incorrect

**Symptom:** Sprint velocity doesn't match actual completion

**Solution:**
```bash
# Verify sprint-status.yaml has correct status values
cat _bmad-output/implementation-artifacts/sprint-status.yaml

# Manually count done stories
grep "done" _bmad-output/implementation-artifacts/sprint-status.yaml | wc -l

# Re-run velocity calculation with debugging
./scripts/calculate-sprint-velocity.sh --debug
```

## Files and Locations

```
_bmad/bmm/workflows/4-implementation/sprint-planning/  # Sprint planning workflow
_bmad-output/implementation-artifacts/sprint-status.yaml  # Sprint tracking file
docs/sprint-management/  # This documentation
scripts/calculate-sprint-velocity.sh  # Velocity calculator
scripts/generate-burndown-data.sh  # Burndown data generator
scripts/sync-stories-to-github.sh  # GitHub Projects sync
dashboards/sprint-dashboard/  # Sprint visualization
```

## References

- **BMAD Sprint Planning:** `_bmad/bmm/workflows/4-implementation/sprint-planning/instructions.md`
- **Sprint Status Template:** `_bmad/bmm/workflows/4-implementation/sprint-planning/sprint-status-template.yaml`
- **Seven Fortunas BMAD Guide:** `docs/bmad-integration/README.md`
- **GitHub Projects API:** https://docs.github.com/en/graphql/guides/forming-calls-with-graphql

---

**Version:** 1.0
**Last Updated:** 2026-02-23
**Owner:** Jorge (VP AI-SecOps)
**Status:** Operational
