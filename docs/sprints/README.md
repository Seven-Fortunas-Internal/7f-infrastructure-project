# Seven Fortunas - Sprint Management

**Location:** `/docs/sprints/`
**Feature:** FR-8.1: Sprint Management
**Status:** Operational

---

## Overview

Unified sprint management system for all Seven Fortunas work (technical and business projects).

**Key Features:**
- BMAD sprint workflows for planning and review
- Flexible terminology support (Technical vs Business)
- Sprint velocity tracking
- GitHub Projects integration
- Sprint dashboards (FR-8.2)

---

## Sprint Workflows

### 1. Sprint Planning (`/bmad-bmm-sprint-planning`)

**Purpose:** Create sprint plan from backlog

**Workflow:**
```bash
/bmad-bmm-sprint-planning
```

**Outputs:**
- `docs/sprints/sprint-{N}/plan.md` - Sprint goals, stories, capacity
- `docs/sprints/sprint-{N}/backlog.yaml` - Sprint backlog items
- GitHub Project board created/updated

**Process:**
1. Review product backlog
2. Select stories for sprint (based on velocity)
3. Break down into tasks
4. Assign to team members
5. Set sprint goals and acceptance criteria

### 2. Sprint Status (`/bmad-bmm-sprint-status`)

**Purpose:** Track sprint progress and identify risks

**Workflow:**
```bash
/bmad-bmm-sprint-status
```

**Outputs:**
- `docs/sprints/sprint-{N}/status.md` - Current status, blockers, risks
- `docs/sprints/sprint-{N}/burndown.json` - Burndown chart data

**Updates:**
- Daily/weekly status
- Identifies at-risk stories
- Routes blocked items to escalation

### 3. Sprint Review (End of Sprint)

**Purpose:** Demo completed work and gather feedback

**Process:**
1. Review completed stories
2. Demo functionality to stakeholders
3. Collect feedback
4. Update product backlog priorities

### 4. Sprint Retrospective

**Purpose:** Improve team process

**Process:**
1. What went well?
2. What could be improved?
3. Action items for next sprint

**Outputs:**
- `docs/sprints/sprint-{N}/retrospective.md`

---

## Flexible Terminology

Supports both **Technical** and **Business** project terminology:

| Concept | Technical Terminology | Business Terminology |
|---------|----------------------|---------------------|
| Vision | Product Vision | Business Initiative |
| Goals | Product Goals | Strategic Objectives |
| Work Units | Epics → Stories | Programs → Tasks |
| Iterations | Sprints | Sprints |
| Delivery | Releases | Milestones |

**Example (Technical):**
- **Product:** Seven Fortunas Infrastructure
- **PRD:** Infrastructure automation and observability
- **Epic:** AI Dashboard Auto-Update Pipeline
- **Stories:** RSS feed parser, Reddit API integration, GitHub Pages deployment
- **Sprint 1:** Implement RSS parser + unit tests

**Example (Business):**
- **Initiative:** Seven Fortunas Go-To-Market Strategy
- **Objective:** Launch marketing website
- **Program:** Website Development
- **Tasks:** Copy writing, design mockups, Webflow implementation
- **Sprint 1:** Write homepage copy + create brand guidelines

---

## Sprint Velocity Tracking

### Velocity Calculation

**Formula:**
```
Velocity = Total Story Points Completed / Sprint Duration

Story Point = Complexity Estimate (1, 2, 3, 5, 8, 13)
```

**Example:**
- Sprint 1: 21 story points completed in 2 weeks = Velocity of 21
- Sprint 2: 18 story points completed in 2 weeks = Velocity of 18
- Average Velocity: (21 + 18) / 2 = 19.5 points per sprint

### Velocity Tracking File

**Location:** `docs/sprints/velocity.yaml`

```yaml
sprints:
  - sprint_id: 1
    start_date: 2026-02-10
    end_date: 2026-02-24
    planned_points: 25
    completed_points: 21
    completion_rate: 0.84
    velocity: 21

  - sprint_id: 2
    start_date: 2026-02-24
    end_date: 2026-03-10
    planned_points: 20
    completed_points: 18
    completion_rate: 0.90
    velocity: 18

average_velocity: 19.5
trend: "stable"
```

### Burndown Charts

**Data Format:** `docs/sprints/sprint-{N}/burndown.json`

```json
{
  "sprint_id": 1,
  "start_date": "2026-02-10",
  "end_date": "2026-02-24",
  "total_points": 25,
  "daily_progress": [
    {"date": "2026-02-10", "remaining": 25, "completed": 0},
    {"date": "2026-02-11", "remaining": 23, "completed": 2},
    {"date": "2026-02-12", "remaining": 20, "completed": 5},
    ...
    {"date": "2026-02-24", "remaining": 4, "completed": 21}
  ],
  "ideal_burndown": [25, 23, 21, 19, 17, 15, 13, 11, 9, 7, 5, 3, 1, 0],
  "status": "behind_schedule"
}
```

**Visualization:** Sprint Dashboard (FR-8.2) renders burndown charts

---

## GitHub Projects Integration

### Setup

**1. Create GitHub Project:**
```bash
gh project create --owner Seven-Fortunas-Internal --title "Seven Fortunas Sprint"
```

**2. Configure Board Columns:**
- Backlog
- Sprint Backlog
- In Progress
- In Review
- Done

**3. Link Issues to Project:**
```bash
gh issue create --title "Implement RSS parser" --label "story" --project "Seven Fortunas Sprint"
```

### Sync Sprint Data to GitHub

**Script:** `scripts/sync-sprint-to-github.sh`

```bash
#!/bin/bash
# Sync docs/sprints/sprint-{N}/backlog.yaml to GitHub Project

SPRINT_ID=$1
PROJECT_ID=$2

# Parse backlog.yaml
STORIES=$(yq '.stories[].title' docs/sprints/sprint-$SPRINT_ID/backlog.yaml)

# Create GitHub issues for each story
while IFS= read -r story; do
    gh issue create \
        --title "$story" \
        --label "sprint-$SPRINT_ID" \
        --project "$PROJECT_ID"
done <<< "$STORIES"
```

**Automation:** GitHub Actions workflow triggers on sprint plan commits

---

## Sprint Dashboard (FR-8.2)

**Location:** `dashboards/sprint/`
**Live URL:** https://seven-fortunas.github.io/dashboards/sprint/

**Features:**
- Current sprint status
- Burndown chart
- Velocity trend
- Team capacity
- Blocked items
- Recent completions

**Data Source:** `docs/sprints/` directory

---

## Usage Examples

### Start New Sprint

```bash
# 1. Run sprint planning workflow
/bmad-bmm-sprint-planning

# 2. Select stories from backlog (interactive)
# Workflow guides you through story selection

# 3. Sprint plan created
docs/sprints/sprint-2/plan.md
docs/sprints/sprint-2/backlog.yaml

# 4. Sync to GitHub Project
./scripts/sync-sprint-to-github.sh 2 PVT_kwDOBKz...
```

### Track Sprint Progress

```bash
# Daily: Update sprint status
/bmad-bmm-sprint-status

# Updates burndown data
docs/sprints/sprint-2/burndown.json

# Sprint dashboard auto-updates
```

### End Sprint

```bash
# 1. Sprint review (demo completed work)
# Document in docs/sprints/sprint-2/review.md

# 2. Sprint retrospective
# Document in docs/sprints/sprint-2/retrospective.md

# 3. Update velocity.yaml
# Calculate completed points and velocity
```

---

## Best Practices

### Sprint Duration
- **Technical projects:** 2 weeks
- **Business projects:** 1-2 weeks (more flexible)

### Story Sizing
- **1 point:** < 2 hours
- **2 points:** 2-4 hours
- **3 points:** 4-8 hours
- **5 points:** 1 day
- **8 points:** 2-3 days
- **13 points:** 1 week (should be split into smaller stories)

### Velocity Planning
- **New team:** Start conservatively (60-70% capacity)
- **Established team:** Use average velocity from last 3 sprints
- **Account for:** Meetings, code review, interruptions (20-30% buffer)

### Sprint Goals
- **SMART:** Specific, Measurable, Achievable, Relevant, Time-bound
- **Focus:** 1-3 major goals per sprint (not a laundry list)
- **Value:** Each goal delivers tangible value to stakeholders

---

## Troubleshooting

### Sprint Velocity Too Low
- Review task estimates (too optimistic?)
- Identify time sinks (meetings, interruptions)
- Improve backlog grooming
- Reduce WIP (Work In Progress)

### Stories Frequently Blocked
- Improve dependency management
- Front-load dependency resolution
- Add slack time for unknowns
- Escalate blockers faster

### Scope Creep Mid-Sprint
- Enforce sprint commitment
- New work goes to next sprint
- Only swap if emergency (rare)
- Communicate scope changes to stakeholders

---

## Files

```
docs/sprints/
├── README.md (this file)
├── velocity.yaml (historical velocity data)
├── sprint-1/
│   ├── plan.md
│   ├── backlog.yaml
│   ├── burndown.json
│   ├── status.md
│   ├── review.md
│   └── retrospective.md
├── sprint-2/
│   └── ... (same structure)
└── templates/
    ├── plan-template.md
    ├── status-template.md
    ├── review-template.md
    └── retrospective-template.md
```

---

## Integration Points

- **BMAD Workflows:** Sprint planning and status workflows
- **Sprint Dashboard (FR-8.2):** Real-time sprint visualization
- **Project Progress Dashboard (FR-8.3):** Long-term velocity trends
- **GitHub Projects:** Kanban board sync
- **feature_list.json:** Feature completion tracking

---

**Document Version:** 1.0
**Last Updated:** 2026-02-24
**Owner:** Jorge (VP AI-SecOps)
