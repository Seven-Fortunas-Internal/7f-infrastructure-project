# BMAD Sprint Review & Retrospective Workflow

**Workflow:** bmad-bmm-sprint-review
**Module:** BMM (BMAD Management Module)
**Purpose:** Conduct sprint review and retrospective at end of sprint

## Usage

```bash
# Review current sprint
/bmad-bmm-sprint-review --sprint SPRINT_024

# Review with custom retrospective format
/bmad-bmm-sprint-review --sprint SPRINT_024 --retro-format mad-sad-glad
```

## Parameters

- `--sprint`: Sprint ID to review
- `--retro-format`: Retrospective format (start-stop-continue | mad-sad-glad | 4ls)
- `--stakeholders`: List of stakeholders for demo invitation

## Workflow Steps

### 1. Calculate Sprint Metrics

**Velocity:**
- Stories/tasks completed vs. committed
- Story points/hours delivered
- Completion rate percentage

**Quality:**
- Bugs introduced during sprint
- Code review feedback
- Test coverage changes

**Efficiency:**
- Cycle time per story/task
- Time in each status (backlog → done)
- Blocked time analysis

### 2. Generate Sprint Report

Create `sprints/SPRINT_024/sprint-report.md`:

```markdown
# Sprint 24 Review Report

**Sprint Period:** March 1-14, 2026
**Team:** Engineering
**Committed:** 60 story points
**Completed:** 55 story points
**Completion Rate:** 92%

## Completed Work

### High Priority (Completed)
- ✅ STORY_045: Real-time AI dashboard updates (13 points)
- ✅ STORY_046: Fintech dashboard implementation (21 points)
- ✅ STORY_047: Dashboard performance optimization (8 points)

### Medium Priority (Completed)
- ✅ STORY_048: Mobile responsive design (13 points)

### Not Completed (Carried Over)
- ⏭️ STORY_049: Dashboard accessibility improvements (5 points)
  - Reason: Deprioritized for critical bug fix
  - Status: Moved to Sprint 25 backlog

## Velocity Analysis

- **Sprint 24 Velocity:** 55 points
- **Sprint 23 Velocity:** 52 points
- **Trend:** +6% (improving)
- **Team Average:** 53 points/sprint

## Burndown Chart

![Burndown](./burndown.png)

## Sprint Goal Achievement

**Goal:** "Complete AI dashboard real-time updates and add fintech dashboard"

**Result:** ✅ ACHIEVED
- Real-time updates deployed to production
- Fintech dashboard live at https://dashboards.seven-fortunas.com/fintech
- Performance improved by 40%
- Mobile responsive on all screen sizes

## Blockers & Issues

1. **API Rate Limiting** (Days 5-7)
   - Impact: 2-day delay on real-time updates
   - Resolution: Implemented caching layer
   - Prevention: Add rate limit monitoring to all dashboards

2. **Design Review Delay** (Day 10)
   - Impact: 1-day delay on fintech dashboard
   - Resolution: Approved design with minor tweaks
   - Prevention: Earlier design review in sprint planning

## Lessons Learned

### What Went Well
- Team collaboration on complex features
- Early integration testing caught issues
- Daily standups kept everyone aligned

### What Could Improve
- Earlier stakeholder involvement in design
- Better estimation for mobile responsive work
- More time for accessibility features

### Action Items for Next Sprint
- [ ] Schedule design reviews during sprint planning
- [ ] Add accessibility to definition of done
- [ ] Increase mobile testing buffer by 20%
```

### 3. Conduct Sprint Review (Demo)

**Agenda:**
1. Sprint goal recap (2 min)
2. Demo completed features (20 min)
3. Metrics review (5 min)
4. Q&A (10 min)

**Deliverables:**
- Working software demonstration
- Stakeholder feedback collected
- Product backlog updates

### 4. Conduct Sprint Retrospective

**Format Options:**

**Start/Stop/Continue:**
- Start doing: New practices to adopt
- Stop doing: Things that aren't working
- Continue doing: Practices to keep

**Mad/Sad/Glad:**
- Mad: What frustrated us
- Sad: What disappointed us
- Glad: What made us happy

**4 Ls:**
- Liked: What we enjoyed
- Learned: What we discovered
- Lacked: What was missing
- Longed for: What we wish we had

**Output:** `sprints/SPRINT_024/retrospective.md`

### 5. Update Velocity Tracking

Update `sprint-management/velocity-history.json`:

```json
{
  "sprints": [
    {
      "id": "SPRINT_024",
      "completed": "2026-03-14",
      "committed": 60,
      "delivered": 55,
      "completion_rate": 0.92,
      "team_size": 5,
      "velocity_per_person": 11
    }
  ],
  "averages": {
    "last_3_sprints": 53,
    "last_6_sprints": 51,
    "all_time": 48
  }
}
```

### 6. Close Sprint in GitHub Projects

- Move remaining items to next sprint or backlog
- Archive sprint board
- Update sprint milestone status
- Generate completion report

### 7. Plan Next Sprint

- Review backlog priorities
- Carry over incomplete stories
- Adjust capacity based on team changes
- Schedule sprint planning meeting

## Output

- Sprint report document
- Retrospective notes
- Updated velocity metrics
- Next sprint backlog (preliminary)

## Integration

- Velocity data displayed in Sprint Dashboard (FR-8.2)
- Completion rates feed Project Progress Dashboard (FR-8.3)
- Lessons learned added to knowledge base

## References

- BMAD Sprint Review: https://github.com/bmad-method/bmad-method/blob/main/bmm/workflows/sprint-review/
- Retrospective Formats: `docs/sprint-management/retrospective-formats.md`
- Velocity Tracking: `sprint-management/velocity-history.json`
