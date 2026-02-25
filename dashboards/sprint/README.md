# Sprint Dashboard

Interactive dashboard for viewing and updating sprint status using GitHub Projects.

## Overview

The Sprint Dashboard leverages GitHub Projects V2 for sprint board management, providing:
- Real-time sprint status (updated within 5 minutes)
- Sprint backlog, in-progress, completed, and blocked items
- Team member assignments and progress tracking
- Integration with sprint management workflows (FR-8.1)

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│               GitHub Projects (Web UI)                  │
│  - Sprint boards (Kanban view)                          │
│  - Real-time updates via webhooks                       │
│  - Team collaboration                                   │
└────────────────┬────────────────────────────────────────┘
                 │
                 │ GitHub Projects API (GraphQL)
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│          7f-sprint-dashboard Skill                      │
│  - Query sprint status                                  │
│  - Update card positions                                │
│  - Create new sprint boards                             │
│  - List active sprints                                  │
└────────────────┬────────────────────────────────────────┘
                 │
                 ├─► Sprint Management (FR-8.1)
                 ├─► BMAD Workflows (create-sprint, sprint-review)
                 └─► Sprint Metrics (velocity, burndown)
```

## Setup

### 1. GitHub Team Tier Required

GitHub Projects V2 requires GitHub Team tier:
- **Cost:** $4/user/month
- **Features:** Unlimited projects, automation, custom fields
- **Alternative:** GitHub Free has Projects Classic (limited features)

**Upgrade:**
```bash
# Go to GitHub organization settings
https://github.com/organizations/Seven-Fortunas/billing

# Select "GitHub Team" plan
# Add payment method and confirm
```

### 2. Create Sprint Board Template

**Using 7f-sprint-dashboard skill:**
```bash
/7f-sprint-dashboard --action create-board --sprint "Sprint 25"
```

**Manually via GitHub:**
1. Go to https://github.com/orgs/Seven-Fortunas/projects
2. Click "New project"
3. Select "Board" template
4. Name: "Sprint 25 - Engineering"
5. Add columns: Backlog, Ready, In Progress, In Review, Done

### 3. Configure Automation

**Built-in automation rules:**
- **Assigned → In Progress:** When issue assigned to user
- **PR Created → In Review:** When PR opened
- **PR Merged → Done:** When PR merged
- **Issue Closed → Done:** When issue closed

**Custom rules (optional):**
- Label "blocked" → Flag item
- Stale items (> 7 days in progress) → Alert
- Sprint end date approaching → Reminder

### 4. Enable Real-Time Sync

Workflow `.github/workflows/sync-sprint-boards.yml` runs every 5 minutes to:
- Update board metrics
- Check for blocked items
- Export data for dashboard visualization
- Notify team of status changes

**Manual sync:**
```bash
gh workflow run sync-sprint-boards.yml
```

## Usage

### Query Sprint Status

```bash
# Current sprint
/7f-sprint-dashboard --action status

# Specific sprint
/7f-sprint-dashboard --action status --sprint SPRINT_024
```

**Output:**
- Sprint goal and timeline
- Items by column (Backlog, Ready, In Progress, In Review, Done)
- Blocked items
- Progress percentage
- Days remaining
- On-track indicator

### Update Card Status

```bash
# Move card to "In Progress"
/7f-sprint-dashboard --action update --card PVTI_abc123 --status "In Progress"

# Move to "Done"
/7f-sprint-dashboard --action update --card PVTI_abc123 --status "Done"
```

### List Sprint Boards

```bash
# All active sprints
/7f-sprint-dashboard --action list-boards

# Specific organization
/7f-sprint-dashboard --action list-boards --org Seven-Fortunas-Internal
```

### Create New Sprint Board

```bash
# Engineering sprint (2 weeks)
/7f-sprint-dashboard --action create-board --sprint "Sprint 26"

# Business sprint (4 weeks)
/7f-sprint-dashboard --action create-board --sprint "Q2 2026 Initiative"
```

## Board Structure

### Columns

1. **Backlog**
   - Future work not committed to sprint
   - Prioritized by product owner
   - Estimated (story points or hours)

2. **Ready**
   - Refined and ready to start
   - Acceptance criteria defined
   - Dependencies resolved

3. **In Progress**
   - Currently being worked on
   - Assigned to team member
   - Updated daily

4. **In Review**
   - Work completed, awaiting review
   - PR created or deliverable submitted
   - Code review, QA, stakeholder feedback

5. **Done**
   - Reviewed, tested, and accepted
   - Meets definition of done
   - Increments sprint progress

### Card Metadata

Each card includes:
- **Title:** Story/task name
- **ID:** STORY_XXX or TASK_XXX
- **Estimate:** Story points or hours
- **Assignee:** Team member responsible
- **Labels:** Priority, type, sprint
- **Milestone:** Sprint number
- **Custom fields:** Status, blocked reason, dependencies

## Integration

### Sprint Management (FR-8.1)

BMAD workflows automatically create and update sprint boards:

```bash
# Create sprint → Creates GitHub Projects board
/bmad-bmm-create-sprint --type engineering --name "Sprint 25"

# Sprint review → Updates board metrics
/bmad-bmm-sprint-review --sprint SPRINT_024
```

### Sprint Metrics

Board data feeds into velocity tracking:
- `sprint-management/velocity-history.json` updated on sprint close
- Burndown chart generated from daily board snapshots
- Completion rate calculated from Done vs. Committed items

## Real-Time Updates

Sprint boards update within **5 minutes** via:

1. **Webhooks (instant):**
   - Issue assigned/closed
   - PR opened/merged
   - Card moved manually

2. **GitHub Actions (5 min):**
   - Sync workflow runs every 5 minutes
   - Updates dashboard data
   - Checks for blockers

3. **Manual (on-demand):**
   - 7f-sprint-dashboard skill
   - GitHub Projects web UI
   - GitHub API/CLI

## Team Access

All GitHub organization members can access sprint boards.

**Permissions:**
- **Read:** All org members (view boards)
- **Write:** Team members in sprint (move cards)
- **Admin:** Scrum Master, Product Owner (configure board)

**Team onboarding:**
1. Add to GitHub organization
2. Assign to team (e.g., @Seven-Fortunas/engineering)
3. Add to sprint milestone
4. Share board URL

## Cost Analysis

**GitHub Team tier:**
- **Price:** $4/user/month
- **For 10 users:** $40/month ($480/year)
- **Features:** Unlimited projects, automation, 50,000 Actions minutes

**Alternative (Free tier):**
- Projects Classic (limited)
- Manual card moves (no automation)
- Basic Kanban boards

**Recommendation:** Upgrade to Team tier for full sprint dashboard capabilities.

## Troubleshooting

### Board not updating
- Check webhook delivery (Settings > Webhooks)
- Verify sync workflow is running (Actions tab)
- Confirm user has write permission

### Card moves failing
- Verify GitHub token has `project` scope
- Check rate limits (gh api rate_limit)
- Ensure card ID is correct (PVTI_*)

### Automation not working
- Projects V2 automation requires Team tier
- Re-configure rules in project settings
- Check GitHub status page for incidents

## References

- [GitHub Projects V2 Docs](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [Sprint Management Guide](../../docs/sprint-management/sprint-guide.md)
- [7f-sprint-dashboard Skill](../../.claude/commands/7f-sprint-dashboard.md)
- [GitHub Projects API](https://docs.github.com/en/graphql/guides/using-the-graphql-api-for-projects)

---

**Owner:** Jorge (VP AI-SecOps)
**Phase:** Phase 2
**Dependencies:** FR-8.1 (Sprint Management), GitHub Team tier
**Status:** Implemented, requires tier upgrade for full features
