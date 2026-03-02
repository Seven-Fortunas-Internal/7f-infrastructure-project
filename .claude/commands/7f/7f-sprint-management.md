---
description: "Unified sprint management for Seven Fortunas work (engineering and business projects)"
tags: ["sprint", "project-management", "velocity", "burndown", "github-projects"]
---

# Seven Fortunas Sprint Management

Unified sprint planning and tracking system supporting both technical and business projects.

## Overview

The Seven Fortunas sprint management system provides:
- **BMAD Workflows:** Structured sprint planning and status tracking
- **Velocity Tracking:** Historical velocity calculation for planning
- **Burndown Charts:** Real-time sprint progress visualization
- **GitHub Projects Integration:** Kanban board sync
- **Flexible Terminology:** Support for both technical and business project types

## Quick Start

### 1. Sprint Planning (BMAD Workflow)

Use the BMAD sprint planning workflow to create sprint-status.yaml tracking file:

```bash
# From Claude Code
/bmad-bmm-sprint-planning
```

This workflow:
- Extracts all epics and stories from planning artifacts
- Generates sprint-status.yaml with complete backlog
- Tracks: TODO → IN_PROGRESS → DONE → VERIFIED
- Supports both engineering (PRD→Epics→Stories) and business (Initiative→Objectives→Tasks) terminology

### 2. View Sprint Status

```bash
bash scripts/7f-sprint-dashboard.sh status --sprint Sprint-2026-W08
```

### 3. Update Item Status

```bash
bash scripts/7f-sprint-dashboard.sh update --item STORY-001 --status "In Progress"
```

### 4. Calculate Sprint Velocity

```bash
# CLI
bash scripts/7f-sprint-dashboard.sh velocity --last-n-sprints 6

# Python (detailed report)
python3 scripts/sprint-management/calculate_velocity.py --last-n-sprints 6 --output velocity-report.txt
```

### 5. View Burndown Chart

```bash
bash scripts/7f-sprint-dashboard.sh burndown --sprint Sprint-2026-W08
```

### 6. Sync to GitHub Projects

```bash
# First time: Create GitHub Projects board
bash scripts/setup-github-projects-sprint-board.sh --org Seven-Fortunas-Internal

# Sync sprint data to GitHub Projects
python3 scripts/sprint-management/sync_sprint_to_github.py
```

## Terminology Support

The system supports flexible terminology for different project types:

### Technical Projects (Engineering)
- **Planning:** PRD → Epics → Stories → Tasks
- **Execution:** Sprints (1-2 weeks)
- **Metrics:** Story points, velocity, burndown
- **Tools:** GitHub Issues, Projects, Pull Requests

### Business Projects
- **Planning:** Initiative → Objectives → Tasks → Sub-tasks
- **Execution:** Sprints (1-2 weeks)
- **Metrics:** Task completion, velocity, progress %
- **Tools:** GitHub Discussions, Projects, Milestones

**How it works:**
- BMAD workflows use configurable field names in `_bmad/bmm/config.yaml`
- Scripts accept both "story" and "task" terminology
- GitHub Projects custom fields map to either terminology
- Velocity calculated as items/sprint (agnostic to item type)

## Files and Directories

### Configuration
```
.7f/sprint-dashboard-config.yaml  # Sprint dashboard configuration
_bmad/bmm/config.yaml              # BMAD project configuration
```

### Tracking Files
```
_bmad-output/implementation-artifacts/sprint-status.yaml  # Current sprint status
```

### Scripts
```
scripts/7f-sprint-dashboard.sh                # Main sprint dashboard CLI
scripts/calculate-sprint-velocity.sh          # Velocity calculation wrapper
scripts/setup-github-projects-sprint-board.sh # GitHub Projects board setup
scripts/sprint-management/                    # Python implementation scripts
├── calculate_velocity.py                     # Velocity calculator
├── generate_burndown.py                      # Burndown chart generator
├── sprint_dashboard.py                       # Dashboard implementation
└── sync_sprint_to_github.py                  # GitHub sync script
```

### BMAD Workflows
```
_bmad/bmm/workflows/4-implementation/sprint-planning/  # Sprint planning workflow
_bmad/bmm/workflows/4-implementation/sprint-status/    # Sprint status workflow
```

## Integration Points

### Sprint Dashboard (FR-8.2)
Sprint data is consumed by the sprint dashboard at `dashboards/sprint/`:
- Real-time velocity display
- Burndown chart visualization
- Sprint health indicators
- Capacity planning recommendations

**Integration:** `scripts/7f-sprint-dashboard.sh` provides data API

### Project Progress Dashboard (FR-8.3)
Sprint data feeds into project progress dashboard:
- Overall completion percentage
- Feature delivery timeline
- Risk identification (velocity drop, blocked stories)
- Milestone tracking

**Integration:** `sprint-status.yaml` is the data source

### GitHub Projects
Sprint data syncs to GitHub Projects for team visibility:
- Automated board creation
- Custom fields for sprint tracking
- Real-time status updates
- Integration with Issues and Pull Requests

**Integration:** `sync_sprint_to_github.py` handles bidirectional sync

## Sprint Workflow

### Planning Phase
1. **Create Sprint:** Run `/bmad-bmm-sprint-planning` to generate sprint-status.yaml
2. **Set Capacity:** Update sprint capacity in sprint-status.yaml (team velocity)
3. **Select Stories:** Mark stories as TODO for current sprint
4. **Sync to GitHub:** Run sync script to create GitHub Project board

### Execution Phase
1. **Daily Updates:** Team members update story status (TODO → IN_PROGRESS → DONE)
2. **Standup Reference:** Use `7f-sprint-dashboard.sh status` to view current state
3. **Burndown Tracking:** Monitor burndown chart daily for risk detection
4. **Blocker Management:** Blocked stories flagged in sprint-status.yaml

### Review Phase
1. **Sprint Review:** Demo completed stories to stakeholders
2. **Velocity Calculation:** Run velocity script to update historical data
3. **Retrospective:** Use `/bmad-bmm-sprint-status` to generate retrospective
4. **Planning Next Sprint:** Use historical velocity for capacity planning

## Sprint Velocity Calculation

**Formula:**
```
velocity = completed_stories / sprint_duration_weeks
```

**Calculation:**
- Counts stories with `status: DONE or VERIFIED`
- Calculates average over last N sprints (default: 6)
- Excludes blocked or cancelled stories
- Adjusts for team size changes (optional)

**Usage for Planning:**
- Historical velocity = predictable capacity
- Buffer 20% for unknowns and tech debt
- Example: 10 stories/sprint average → plan for 8 stories

## Burndown Chart

Tracks remaining work over sprint duration:
- **Ideal Line:** Linear decrease from total stories to zero
- **Actual Line:** Real completion rate
- **Risk Indicators:** Actual above ideal = behind schedule

**Interpretation:**
- **Flat Line:** No progress (blockers, scope issues)
- **Steep Drop:** High productivity or scope reduction
- **Rising Line:** Scope creep (stories added mid-sprint)

## Sprint Retrospective

Captured in sprint-status.yaml at end of sprint:

```yaml
retrospective:
  what_went_well:
    - "Faster PR reviews"
    - "Better story breakdown"
  what_to_improve:
    - "More precise estimation"
    - "Earlier testing"
  action_items:
    - "Create estimation guide"
    - "Add CI checks for test coverage"
```

## GitHub Projects Configuration

### Board Structure
- **Columns:** TODO, IN PROGRESS, DONE, VERIFIED
- **Custom Fields:**
  - Sprint: Sprint identifier (e.g., Sprint-2026-W08)
  - Story Points: Effort estimate (1, 2, 3, 5, 8, 13)
  - Priority: P0 (critical), P1 (high), P2 (medium), P3 (low)
  - Epic: Parent epic identifier

### Automation Rules
- **Status Sync:** GitHub issue status → sprint-status.yaml (bidirectional)
- **Sprint Assignment:** Drag story to sprint column → auto-assigns sprint field
- **Completion:** PR merged → story moved to DONE

## Troubleshooting

### Issue: Sprint velocity calculation returns 0
**Cause:** No completed stories in sprint-status.yaml
**Solution:** Ensure stories have `status: DONE` or `status: VERIFIED`

### Issue: GitHub sync fails with 404
**Cause:** GitHub Projects board not created
**Solution:** Run `setup-github-projects-sprint-board.sh` first

### Issue: Burndown chart shows flat line
**Cause:** Stories not being updated to IN_PROGRESS/DONE
**Solution:** Remind team to update sprint-status.yaml daily

### Issue: BMAD workflow can't find epic files
**Cause:** Epic files not in expected location
**Solution:** Verify `_bmad-output/planning-artifacts/epic*.md` exist

## Examples

### Example 1: Start New Sprint (Engineering Project)

```bash
# 1. Generate sprint status from epics
/bmad-bmm-sprint-planning

# 2. Edit sprint-status.yaml to select stories for Sprint-2026-W08
# (Mark ~8 stories as TODO based on historical velocity)

# 3. Create GitHub Projects board
bash scripts/setup-github-projects-sprint-board.sh

# 4. Sync to GitHub
python3 scripts/sprint-management/sync_sprint_to_github.py

# 5. View sprint dashboard
bash scripts/7f-sprint-dashboard.sh status --sprint Sprint-2026-W08
```

### Example 2: Daily Sprint Update

```bash
# Update story status (team member completes STORY-042)
bash scripts/7f-sprint-dashboard.sh update --item STORY-042 --status "DONE"

# View burndown
bash scripts/7f-sprint-dashboard.sh burndown --sprint Sprint-2026-W08

# Check if behind schedule
# (If actual line above ideal, discuss blockers in standup)
```

### Example 3: Sprint Retrospective

```bash
# 1. Calculate velocity for last 6 sprints
bash scripts/7f-sprint-dashboard.sh velocity --last-n-sprints 6

# 2. Run sprint status workflow (generates retrospective template)
/bmad-bmm-sprint-status

# 3. Team fills in retrospective section of sprint-status.yaml

# 4. Plan next sprint using calculated velocity
# (Example: Average 9 stories/sprint → plan for 7-8 next sprint)
```

## Configuration Files

### .7f/sprint-dashboard-config.yaml

```yaml
github_org: Seven-Fortunas-Internal
default_sprint_duration_weeks: 2
velocity_calculation_sprints: 6
burndown_update_frequency: daily
```

### _bmad/bmm/config.yaml (Sprint Section)

```yaml
# Sprint configuration
implementation_artifacts: _bmad-output/implementation-artifacts
planning_artifacts: _bmad-output/planning-artifacts

# Terminology (customize for business vs technical projects)
terminology:
  epic: "Epic"          # or "Objective"
  story: "Story"        # or "Task"
  sprint: "Sprint"      # or "Iteration"
```

---

**Implementation:** Multiple scripts and BMAD workflows
**Status:** Active (Phase 2)
**Maintained By:** Seven Fortunas Team
