# BMAD Sprint Creation Workflow

**Workflow:** bmad-bmm-create-sprint
**Module:** BMM (BMAD Management Module)
**Purpose:** Create a new sprint for engineering or business projects

## Usage

```bash
# For engineering sprints
/bmad-bmm-create-sprint --type engineering --name "Sprint 24" --duration 2weeks

# For business sprints
/bmad-bmm-create-sprint --type business --name "Q1 2026 Sprint 1" --duration 3weeks
```

## Parameters

- `--type`: Sprint type (engineering | business)
- `--name`: Sprint name/identifier
- `--duration`: Sprint duration (1week | 2weeks | 3weeks | 4weeks)
- `--start-date`: Optional start date (defaults to next Monday)
- `--team`: Optional team name (defaults to current team)

## Workflow Steps

### 1. Gather Sprint Requirements

- Sprint goal/objective
- Team capacity (available hours)
- Holidays/PTO to account for
- Dependencies from previous sprint

### 2. Create Sprint Structure

**For Engineering Projects:**
- PRD → Epics → Stories → Tasks
- Stories estimated in story points
- Tasks assigned to team members

**For Business Projects:**
- Initiative → Objectives → Tasks → Subtasks
- Tasks estimated in hours
- Tasks assigned to stakeholders

### 3. Set Sprint Metadata

```yaml
sprint:
  id: SPRINT_024
  name: "Sprint 24 - AI Dashboard Enhancements"
  type: engineering
  duration: 2 weeks
  start_date: 2026-03-01
  end_date: 2026-03-14
  team: Engineering
  capacity: 80 story points
  goal: "Complete AI dashboard real-time updates and add fintech dashboard"
```

### 4. Create GitHub Project Board

- Create new GitHub Projects board
- Set up columns: Backlog, Ready, In Progress, In Review, Done
- Link to sprint milestone
- Add sprint goal to board description

### 5. Populate Sprint Backlog

- Pull stories/tasks from product backlog
- Prioritize by business value and dependencies
- Assign story points or hour estimates
- Assign to team members

### 6. Generate Sprint Plan Document

Create `sprints/SPRINT_024/sprint-plan.md`:

```markdown
# Sprint 24: AI Dashboard Enhancements

**Duration:** March 1-14, 2026 (2 weeks)
**Team:** Engineering (5 developers)
**Capacity:** 80 story points
**Goal:** Complete AI dashboard real-time updates and add fintech dashboard

## Sprint Backlog

### High Priority
- [ ] STORY_045: Real-time AI dashboard updates (13 points)
- [ ] STORY_046: Fintech dashboard implementation (21 points)

### Medium Priority
- [ ] STORY_047: Dashboard performance optimization (8 points)
- [ ] STORY_048: Mobile responsive design (13 points)

### Low Priority
- [ ] STORY_049: Dashboard accessibility improvements (5 points)

**Total Committed:** 60 points (75% capacity for safety margin)

## Daily Standup Schedule
- Time: 9:00 AM UTC
- Location: #engineering-standup Slack channel
- Format: Async updates in thread

## Sprint Review
- Date: March 14, 2026
- Attendees: Engineering team + Product stakeholders
- Demo: Live dashboard demonstration

## Sprint Retrospective
- Date: March 14, 2026 (after review)
- Format: Start/Stop/Continue
- Facilitator: Scrum Master
```

### 7. Create Sprint Tracking Files

- `sprints/SPRINT_024/burndown.json` - Daily progress tracking
- `sprints/SPRINT_024/velocity.json` - Velocity calculation
- `sprints/SPRINT_024/retrospective.md` - Lessons learned template

### 8. Set Up Automation

- GitHub Actions workflow for daily burndown updates
- Slack notifications for sprint milestones
- Automatic sprint completion detection

## Output

- GitHub Projects board URL
- Sprint plan document path
- Sprint tracking sheet link
- Team notification confirmation

## Integration

- Links to Sprint Dashboard (FR-8.2)
- Syncs with Project Progress Dashboard (FR-8.3)
- Feeds into velocity metrics

## References

- BMAD Sprint Workflow: https://github.com/bmad-method/bmad-method/blob/main/bmm/workflows/create-sprint/
- Seven Fortunas Sprint Guide: `docs/sprint-management/sprint-guide.md`
