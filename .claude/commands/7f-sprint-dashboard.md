# 7F Sprint Dashboard

**Skill:** 7f-sprint-dashboard
**Purpose:** Query and update sprint status using GitHub Projects API

## Usage

```bash
# Query current sprint status
/7f-sprint-dashboard --action status

# Update card status
/7f-sprint-dashboard --action update --card CARD_ID --status "In Progress"

# List all sprint boards
/7f-sprint-dashboard --action list-boards

# Create new sprint board
/7f-sprint-dashboard --action create-board --sprint "Sprint 25"
```

## Parameters

- `--action`: Operation to perform (status | update | list-boards | create-board)
- `--sprint`: Sprint ID/name (optional, defaults to current sprint)
- `--card`: Card ID for update operations
- `--status`: New status (Backlog | Ready | In Progress | In Review | Done)
- `--org`: GitHub organization (defaults to Seven-Fortunas)

## Actions

### 1. Query Sprint Status

**Command:**
```bash
/7f-sprint-dashboard --action status --sprint SPRINT_024
```

**Output:**
```
Sprint 24 Status (Mar 1-14, 2026)
================================

Sprint Goal: Complete AI dashboard real-time updates and add fintech dashboard
Team: Engineering (5 members)
Committed: 60 story points
Progress: 45/60 (75%)

Backlog (15 points):
  • STORY_049: Dashboard accessibility (5 points)
  • STORY_050: Dashboard analytics (8 points)
  • STORY_051: Dashboard export feature (2 points)

Ready (0 points):
  (No items)

In Progress (13 points):
  • STORY_048: Mobile responsive design (13 points) - @alice
    Started: Mar 10, Blocked: No

In Review (32 points):
  • STORY_045: Real-time updates (13 points) - @bob
    PR: #234, Reviews: 2/2 approved
  • STORY_046: Fintech dashboard (21 points) - @charlie
    PR: #235, Reviews: 1/2 approved

Done (15 points):
  • STORY_047: Performance optimization (8 points)
  • STORY_044: Dashboard refactoring (5 points)
  • STORY_043: Fix dashboard bugs (2 points)

Blockers: 0
Days Remaining: 4
On Track: Yes (burndown trending toward goal)
```

### 2. Update Card Status

**Command:**
```bash
/7f-sprint-dashboard --action update --card PVTI_abc123 --status "In Progress"
```

**Process:**
1. Authenticate with GitHub API
2. Lookup card in GitHub Projects
3. Move card to specified column
4. Update card metadata (assignee, timestamp)
5. Post comment with status change

**Output:**
```
✓ Card PVTI_abc123 moved to "In Progress"
  Story: STORY_048 - Mobile responsive design
  Assigned: @alice
  Updated: 2026-03-10 14:30 UTC
```

### 3. List Sprint Boards

**Command:**
```bash
/7f-sprint-dashboard --action list-boards --org Seven-Fortunas
```

**Output:**
```
Active Sprint Boards
===================

1. Sprint 24 - Engineering (Mar 1-14)
   URL: https://github.com/orgs/Seven-Fortunas/projects/24
   Items: 12 (15 done, 13 in progress, 2 in review)
   Status: Active

2. Q1 2026 Initiative - Business (Feb 15 - Mar 15)
   URL: https://github.com/orgs/Seven-Fortunas/projects/25
   Items: 18 (8 done, 6 in progress, 4 ready)
   Status: Active

3. Sprint 23 - Engineering (Feb 15-28)
   URL: https://github.com/orgs/Seven-Fortunas/projects/23
   Items: 14 (all done)
   Status: Completed
```

### 4. Create Sprint Board

**Command:**
```bash
/7f-sprint-dashboard --action create-board --sprint "Sprint 25"
```

**Process:**
1. Create new GitHub Project
2. Set up columns: Backlog, Ready, In Progress, In Review, Done
3. Configure automation rules
4. Add sprint metadata (start date, end date, team, capacity)
5. Link to sprint milestone

**Output:**
```
✓ Sprint board created
  Project: Sprint 25 - Engineering
  URL: https://github.com/orgs/Seven-Fortunas/projects/25
  Columns: Backlog, Ready, In Progress, In Review, Done
  Automation: Enabled
  Milestone: Sprint 25 (Mar 15-28, 2026)

Next steps:
1. Add stories/tasks to backlog
2. Assign team members
3. Estimate story points
4. Communicate board URL to team
```

## GitHub Projects API Integration

### Authentication

```bash
# Set GitHub token with projects permission
export GITHUB_TOKEN=$(gh auth token)

# Or use GitHub CLI
gh auth login --scopes project
```

### API Endpoints

**List Projects:**
```bash
gh api graphql -f query='
  query {
    organization(login: "Seven-Fortunas") {
      projectsV2(first: 10) {
        nodes {
          id
          title
          url
        }
      }
    }
  }
'
```

**Get Project Items:**
```bash
gh api graphql -f query='
  query {
    node(id: "PROJECT_ID") {
      ... on ProjectV2 {
        items(first: 50) {
          nodes {
            id
            content {
              ... on Issue {
                title
                state
                assignees(first: 5) {
                  nodes {
                    login
                  }
                }
              }
            }
          }
        }
      }
    }
  }
'
```

**Update Card Status:**
```bash
gh api graphql -f query='
  mutation {
    updateProjectV2ItemFieldValue(
      input: {
        projectId: "PROJECT_ID"
        itemId: "ITEM_ID"
        fieldId: "STATUS_FIELD_ID"
        value: {
          singleSelectOptionId: "IN_PROGRESS_OPTION_ID"
        }
      }
    ) {
      projectV2Item {
        id
      }
    }
  }
'
```

## Board Automation Rules

**Configured automatically when creating sprint board:**

1. **Auto-assign to "In Progress"**
   - Trigger: Issue/PR assigned to user
   - Action: Move to "In Progress" column

2. **Auto-move to "In Review"**
   - Trigger: PR created/reopened
   - Action: Move to "In Review" column

3. **Auto-move to "Done"**
   - Trigger: PR merged or issue closed
   - Action: Move to "Done" column

4. **Auto-remove from board**
   - Trigger: Issue/PR archived
   - Action: Remove from board

## Real-Time Status Updates

Sprint boards are updated within 5 minutes via:

1. **GitHub webhooks** - Instant updates on issue/PR changes
2. **GitHub Actions** - Scheduled sync every 5 minutes
3. **Manual updates** - Via 7f-sprint-dashboard skill

**Sync workflow:** `.github/workflows/sync-sprint-boards.yml`

## Team Access

All team members with GitHub org access can view and update sprint boards.

**Permissions:**
- **Read:** All org members
- **Write:** Team members assigned to sprint
- **Admin:** Scrum Master, Product Owner

## Cost Consideration

GitHub Projects (V2) requires **GitHub Team tier:**
- **Cost:** $4/user/month
- **Features:** Unlimited projects, automation, custom fields
- **Alternative:** GitHub Free tier has limited Projects (classic)

**Recommendation:** Upgrade to GitHub Team for full sprint dashboard features.

## Integration Points

- **Sprint Management (FR-8.1):** Workflows use this skill to create/update boards
- **BMAD Sprint Workflows:** create-sprint and sprint-review call this skill
- **Sprint Metrics:** Board data feeds into velocity calculations

## Troubleshooting

### "Project not found"
- Verify project ID is correct
- Check GitHub token has `project` scope
- Ensure user has access to organization

### "Card update failed"
- Confirm card ID is valid (PVTI_*)
- Check status field exists on project
- Verify user has write permission

### "Real-time updates delayed"
- Check GitHub webhook delivery (Settings > Webhooks)
- Verify sync workflow is running (.github/workflows/sync-sprint-boards.yml)
- GitHub API may have rate limits (check headers)

## References

- [GitHub Projects API Docs](https://docs.github.com/en/graphql/guides/using-the-graphql-api-for-projects)
- [Sprint Management Guide](../docs/sprint-management/sprint-guide.md)
- [GitHub Projects Pricing](https://github.com/pricing)

---

**Owner:** Jorge (VP AI-SecOps)
**Phase:** Phase 2
**Status:** Implemented, requires GitHub Team tier for full features
