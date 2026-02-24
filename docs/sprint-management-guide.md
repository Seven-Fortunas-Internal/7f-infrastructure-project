# Seven Fortunas Sprint Management Guide

**Owner:** Jorge (VP AI-SecOps)
**Status:** Phase 2 Implementation
**Last Updated:** 2026-02-18

---

## Overview

Seven Fortunas uses unified sprint planning for all work streams:
- **Engineering Projects:** PRD → Epics → Stories → Sprints
- **Business Projects:** Initiative → Objectives → Tasks → Sprints

Both use BMAD workflows for planning and execution tracking.

---

## Sprint Structure

### Sprint Duration
- **Standard:** 2 weeks (10 business days)
- **Phase 1:** 1 week sprints (for MVP velocity)
- **Phase 2+:** 2 week sprints (stable velocity)

### Sprint Cadence
- **Monday:** Sprint Planning
- **Daily:** Standup (async via Slack)
- **Friday:** Sprint Review + Retrospective

---

## BMAD Sprint Workflows

### 1. Sprint Planning (`bmad-bmm-create-sprint`)
**Purpose:** Plan sprint goals, assign work items, estimate capacity

**Usage:**
```bash
# In Claude Code
/bmad-bmm-create-sprint
```

**Inputs:**
- Sprint number (e.g., Sprint-2026-W08)
- Sprint goal statement
- Available capacity (story points or hours)
- Backlog of epics/stories/tasks

**Outputs:**
- `sprint-plan.md` (sprint goals, capacity, work items)
- `sprint-backlog.yaml` (structured work items)
- Updated project board (GitHub Projects)

**Process:**
1. Review previous sprint velocity
2. Define sprint goal
3. Select high-priority work items
4. Estimate story points/hours
5. Assign team members
6. Publish sprint plan

---

### 2. Sprint Review (`bmad-bmm-sprint-review`)
**Purpose:** Evaluate completed work, calculate velocity, capture lessons

**Usage:**
```bash
# In Claude Code
/bmad-bmm-sprint-review
```

**Inputs:**
- Sprint plan (from planning)
- Completed work items
- Blocked/incomplete items

**Outputs:**
- `sprint-review.md` (completed items, velocity, retrospective)
- `lessons-learned.md` (what went well, what to improve)
- Updated velocity metrics

**Process:**
1. Demo completed work
2. Calculate actual velocity
3. Review blocked items
4. Conduct retrospective
5. Identify action items
6. Archive sprint artifacts

---

## Flexible Terminology Support

### Engineering Projects
**Hierarchy:** PRD → Epic → Story → Sprint

**Example:**
```yaml
prd: "Seven Fortunas Infrastructure"
epics:
  - EPIC-001: "GitHub Organization Setup"
    stories:
      - STORY-001: "Create GitHub orgs"
      - STORY-002: "Configure security settings"
sprint:
  number: Sprint-2026-W08
  goal: "Complete GitHub infrastructure setup"
  capacity: 40 story points
  items:
    - STORY-001 (8 points)
    - STORY-002 (13 points)
```

---

### Business Projects
**Hierarchy:** Initiative → Objective → Task → Sprint

**Example:**
```yaml
initiative: "Seven Fortunas Market Launch"
objectives:
  - OBJ-001: "Partner Outreach Campaign"
    tasks:
      - TASK-001: "Identify 20 potential partners"
      - TASK-002: "Draft partnership proposal"
sprint:
  number: Sprint-2026-W08
  goal: "Complete partner outreach strategy"
  capacity: 30 hours
  items:
    - TASK-001 (12 hours)
    - TASK-002 (8 hours)
```

---

## Sprint Metrics

### Velocity Tracking
**Story Points (Engineering):**
- Small: 1-3 points (< 1 day)
- Medium: 5-8 points (1-2 days)
- Large: 13 points (3-5 days)
- Epic: 21+ points (break down further)

**Hours (Business):**
- Direct hour estimates
- Track actual vs. estimated
- Adjust capacity based on utilization

**Formula:**
```
Velocity = Sum(Completed Story Points) / Number of Sprints
```

**Burndown Chart:**
- Track remaining work daily
- Visualize progress vs. ideal burndown
- Identify impediments early

---

### Completion Rate
```
Completion Rate = (Completed Items / Planned Items) × 100%
```

**Targets:**
- **MVP Phase:** 70-80% (learning velocity)
- **Phase 1:** 80-90% (stable velocity)
- **Phase 2+:** 85-95% (predictable delivery)

---

## GitHub Projects Integration

### Board Setup
**Columns:**
1. **Backlog** - Prioritized work items
2. **Sprint Backlog** - Items for current sprint
3. **In Progress** - Actively being worked
4. **Review** - Awaiting review/testing
5. **Done** - Completed items

**Automation:**
- Auto-move cards based on PR status
- Auto-close items when PR merged
- Label-based filtering

---

### Sprint Board Views
**View 1: Current Sprint**
- Filter: `sprint:current`
- Group by: Assignee
- Sort by: Priority

**View 2: Burndown**
- Chart: Remaining story points over time
- Update: Daily

**View 3: Velocity Trends**
- Chart: Completed story points per sprint
- Historical: Last 6 sprints

---

## Sprint Workflow Example

### Week 1 (Sprint Planning)
**Monday:**
```bash
# 1. Review previous sprint
/bmad-bmm-sprint-review --sprint Sprint-2026-W07

# 2. Plan new sprint
/bmad-bmm-create-sprint --sprint Sprint-2026-W08

# 3. Sync to GitHub Projects
python scripts/sync_sprint_to_github.py --sprint Sprint-2026-W08
```

**Daily (Tue-Fri):**
- Update GitHub Projects board
- Move cards as work progresses
- Flag blockers with label

**Friday:**
```bash
# Mid-sprint checkpoint
python scripts/generate_burndown.py --sprint Sprint-2026-W08
```

---

### Week 2 (Sprint Execution)
**Monday-Thursday:**
- Continue work on sprint items
- Daily board updates

**Friday:**
```bash
# 1. Sprint review
/bmad-bmm-sprint-review --sprint Sprint-2026-W08

# 2. Generate metrics
python scripts/calculate_velocity.py --sprint Sprint-2026-W08

# 3. Archive sprint
git add sprints/Sprint-2026-W08/
git commit -m "docs(sprint): Sprint 2026-W08 complete"
```

---

## Sprint Retrospective Template

### What Went Well?
- [List successes]

### What Could Be Improved?
- [List challenges]

### Action Items
- [ ] Action 1 (Owner: Name, Due: Date)
- [ ] Action 2 (Owner: Name, Due: Date)

### Velocity Analysis
- **Planned:** X points/hours
- **Completed:** Y points/hours
- **Completion Rate:** Z%
- **Blockers:** [List any blockers]

---

## Phase 2 Pilot: Business Project Fit

### Pilot Objective
Validate sprint methodology for business projects (non-engineering work).

### Test Scenarios
1. **Marketing Campaign Planning**
   - Use Initiative → Objective → Task hierarchy
   - Track hours instead of story points
   - Measure completion rate

2. **Partnership Development**
   - Use Task-based planning
   - Track deliverables (proposals, contracts, meetings)
   - Measure success rate

### Success Criteria
- ✅ Business teams adopt sprint planning
- ✅ Velocity tracking works for non-engineering work
- ✅ Retrospectives capture actionable insights
- ✅ 80%+ satisfaction from business stakeholders

---

## Tools and Scripts

### Sprint Management Scripts
**Location:** `scripts/sprint-management/`

**Available Scripts:**
- `sync_sprint_to_github.py` - Sync sprint plan to GitHub Projects
- `generate_burndown.py` - Generate burndown chart
- `calculate_velocity.py` - Calculate sprint velocity
- `export_sprint_report.py` - Export sprint summary PDF

**Usage:**
```bash
# Sync sprint to GitHub
python scripts/sprint-management/sync_sprint_to_github.py \
  --sprint Sprint-2026-W08 \
  --project-id 12345

# Generate burndown chart
python scripts/sprint-management/generate_burndown.py \
  --sprint Sprint-2026-W08 \
  --output sprints/Sprint-2026-W08/burndown.png

# Calculate velocity
python scripts/sprint-management/calculate_velocity.py \
  --last-n-sprints 6
```

---

## Integration with Dashboards

### Sprint Dashboard (FR-8.2)
**Real-time metrics:**
- Current sprint progress
- Burndown chart
- Velocity trends
- Team utilization

**Data sources:**
- `sprint-plan.md`
- `sprint-backlog.yaml`
- GitHub Projects API
- Git commit history

---

### Project Progress Dashboard (FR-8.3)
**Aggregated view:**
- All active sprints
- Cross-project dependencies
- Resource allocation
- Risk indicators

**Data sources:**
- Sprint summaries
- BMAD workflow outputs
- GitHub milestones
- Team calendars

---

## Best Practices

### Sprint Planning
✅ **DO:**
- Define clear sprint goal
- Include buffer for unexpected work (20%)
- Review velocity trends before committing
- Get team buy-in on capacity estimates

❌ **DON'T:**
- Overcommit beyond historical velocity
- Skip retrospectives
- Change sprint scope mid-sprint
- Plan without accounting for holidays/PTO

---

### Work Item Sizing
✅ **DO:**
- Break large items into smaller ones
- Use consistent estimation method (planning poker)
- Review estimates with team
- Adjust based on actual completion time

❌ **DON'T:**
- Estimate without discussing complexity
- Use different scales across projects
- Skip re-estimation after scope change
- Ignore historical data

---

## References

- [BMAD Sprint Template](_bmad/bmm/workflows/4-implementation/sprint-planning/sprint-status-template.yaml)
- [GitHub Projects Documentation](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [Agile Sprint Planning Guide](https://www.atlassian.com/agile/scrum/sprint-planning)

---

**Next Steps:**
1. Create sprint management scripts (Phase 2)
2. Set up GitHub Projects boards
3. Run first sprint pilot (engineering + business)
4. Iterate based on retrospective feedback
