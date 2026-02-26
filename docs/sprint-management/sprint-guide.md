# Seven Fortunas Sprint Management Guide

## Overview

Seven Fortunas uses a unified sprint framework that supports both engineering and business projects with flexible terminology.

## Sprint Terminology

### Engineering Projects (Technical)
- **PRD** → **Epics** → **Stories** → **Tasks** → **Sprints**
- Estimation: Story points (Fibonacci: 1, 2, 3, 5, 8, 13, 21)
- Duration: 2-week sprints (standard)
- Team: Engineering, QA, DevOps

### Business Projects (Non-Technical)
- **Initiative** → **Objectives** → **Tasks** → **Subtasks** → **Sprints**
- Estimation: Hours (1h, 2h, 4h, 8h, 16h, 32h)
- Duration: 1-4 week sprints (flexible)
- Team: Business, Marketing, Operations

## Sprint Workflow

### 1. Sprint Planning
- **When:** First day of sprint
- **Duration:** 2 hours (engineering) or 1 hour (business)
- **Participants:** Team + Product Owner + Scrum Master
- **Output:** Sprint backlog, sprint goal, capacity allocation

**Inputs:**
- Prioritized product backlog
- Team velocity from previous sprints
- Team capacity (accounting for PTO, holidays)
- Dependencies and blockers

**Process:**
1. Review sprint goal
2. Select top-priority items from backlog
3. Estimate effort (story points or hours)
4. Assign to team members
5. Create sprint board in GitHub Projects

### 2. Daily Standup
- **When:** Every weekday at 9:00 AM UTC
- **Duration:** 15 minutes max
- **Format:** Async (Slack thread) or Sync (video call)
- **Questions:**
  1. What did I complete yesterday?
  2. What am I working on today?
  3. Any blockers or dependencies?

**Best Practices:**
- Keep updates concise (2-3 sentences)
- Raise blockers immediately
- Follow up on blockers in DMs/threads
- Update task status in GitHub Projects

### 3. Sprint Review
- **When:** Last day of sprint (before retrospective)
- **Duration:** 1 hour
- **Participants:** Team + Stakeholders + Product Owner
- **Output:** Demo, stakeholder feedback, backlog updates

**Agenda:**
1. Sprint goal recap (5 min)
2. Demo completed work (30 min)
3. Metrics review (10 min)
4. Stakeholder Q&A (10 min)
5. Backlog refinement (5 min)

**Demo Guidelines:**
- Show working software/deliverables
- Explain business value
- Highlight challenges overcome
- Collect feedback for next sprint

### 4. Sprint Retrospective
- **When:** Last day of sprint (after review)
- **Duration:** 45 minutes
- **Participants:** Team only (safe space)
- **Output:** Action items for improvement

**Format:** Start/Stop/Continue
- **Start:** What should we start doing?
- **Stop:** What should we stop doing?
- **Continue:** What should we keep doing?

**Rules:**
- No blame - focus on process, not people
- Everyone contributes
- Action items must be specific and measurable
- Review previous action items first

## Sprint Metrics

### Velocity
**Definition:** Average story points (or hours) completed per sprint

**Calculation:**
```
Velocity = Total completed story points / Number of sprints
```

**Usage:**
- Capacity planning for future sprints
- Team performance trend analysis
- Forecasting release dates

### Burndown Chart
**Definition:** Visual representation of work remaining vs. time

**X-axis:** Days in sprint
**Y-axis:** Story points/hours remaining

**Ideal line:** Linear from total committed to zero
**Actual line:** Real progress (may fluctuate)

**Analysis:**
- Above ideal = behind schedule
- Below ideal = ahead of schedule
- Flat line = no progress (investigate blockers)

### Completion Rate
**Definition:** Percentage of committed work completed

**Calculation:**
```
Completion Rate = (Completed points / Committed points) × 100%
```

**Targets:**
- **85-100%:** Excellent (realistic planning)
- **70-84%:** Good (minor adjustments needed)
- **< 70%:** Poor (investigate planning or execution issues)

## GitHub Projects Integration

### Board Structure

**Columns:**
1. **Backlog:** Future work, not committed to sprint
2. **Ready:** Refined stories, ready to start
3. **In Progress:** Currently being worked on
4. **In Review:** Code/work completed, awaiting review
5. **Done:** Reviewed, tested, and accepted

### Automation Rules

- **Auto-move to In Progress:** When issue assigned
- **Auto-move to In Review:** When PR created
- **Auto-move to Done:** When PR merged
- **Auto-archive:** Done items after 7 days

### Labels

- `sprint:SPRINT_024` - Sprint identifier
- `priority:P0` - Critical (must complete)
- `priority:P1` - High (should complete)
- `priority:P2` - Medium (nice to have)
- `blocked` - Cannot proceed without dependency
- `carry-over` - From previous sprint

## Sprint Velocity Tracking

### File: `sprint-management/velocity-history.json`

```json
{
  "team": "Engineering",
  "sprints": [
    {
      "id": "SPRINT_024",
      "name": "AI Dashboard Enhancements",
      "start_date": "2026-03-01",
      "end_date": "2026-03-14",
      "duration_weeks": 2,
      "team_size": 5,
      "committed_points": 60,
      "delivered_points": 55,
      "completion_rate": 0.92,
      "velocity_per_person": 11,
      "carried_over": 5,
      "bugs_introduced": 2,
      "blockers": 2
    }
  ],
  "averages": {
    "last_3_sprints": {
      "velocity": 53,
      "completion_rate": 0.89,
      "velocity_per_person": 11
    },
    "last_6_sprints": {
      "velocity": 51,
      "completion_rate": 0.87,
      "velocity_per_person": 10
    },
    "all_time": {
      "velocity": 48,
      "completion_rate": 0.85,
      "velocity_per_person": 10
    }
  }
}
```

## Best Practices

### Do's ✅
- Commit to realistic capacity (70-80% of max)
- Break down large stories (max 13 points)
- Update task status daily
- Celebrate sprint successes
- Act on retrospective action items
- Maintain consistent sprint duration

### Don'ts ❌
- Don't add scope mid-sprint (except critical bugs)
- Don't skip retrospectives
- Don't carry over more than 20% of work
- Don't ignore velocity trends
- Don't blame individuals in retrospectives
- Don't change sprint duration frequently

## Tools

- **Sprint Planning:** BMAD workflows (`/bmad-bmm-create-sprint`)
- **Sprint Review:** BMAD workflows (`/bmad-bmm-sprint-review`)
- **Task Tracking:** GitHub Projects
- **Daily Standup:** Slack (#standup channels)
- **Metrics:** Sprint Dashboard (FR-8.2)
- **Velocity:** Automated calculation in sprint-review workflow

## References

- [BMAD Sprint Workflows](https://github.com/bmad-method/bmad-method/tree/main/bmm/workflows)
- [Sprint Dashboard](../dashboards/sprint/README.md)
- [GitHub Projects Guide](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [Agile Sprint Best Practices](https://www.scrum.org/resources/what-is-a-sprint-in-scrum)

---

**Owner:** Jorge (VP AI-SecOps)
**Status:** Phase 2
**Last Updated:** 2026-02-25
