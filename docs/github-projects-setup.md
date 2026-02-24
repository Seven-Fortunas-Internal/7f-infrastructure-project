# GitHub Projects Setup Guide

**Purpose:** Set up GitHub Projects for sprint management
**Owner:** Jorge (VP AI-SecOps)
**Phase:** Phase 2
**Last Updated:** 2026-02-18

---

## Overview

Seven Fortunas uses GitHub Projects (V2) for sprint board visualization and management.

**Benefits:**
- Native integration with GitHub issues/PRs
- Real-time updates
- Custom fields (sprint, story points, priority)
- Multiple views (board, table, chart)
- Automation rules

**Cost:** GitHub Team tier required ($4/user/month)

---

## Setup Steps

### 1. Enable GitHub Team Tier

**Organization:** Seven-Fortunas-Internal

**Steps:**
1. Go to Organization Settings → Billing
2. Upgrade to GitHub Team plan
3. Add team members

**Cost:** $4/user/month (billed annually: $48/user/year)

---

### 2. Create Sprint Project

**Location:** Organization-level project (not repository-specific)

**Steps:**
1. Navigate to `https://github.com/orgs/Seven-Fortunas-Internal/projects`
2. Click "New Project"
3. Select "Board" template
4. Name: "Seven Fortunas Sprints"
5. Description: "Unified sprint management for all Seven Fortunas work"

---

### 3. Configure Custom Fields

**Required Fields:**

| Field Name | Type | Options | Purpose |
|------------|------|---------|---------|
| Sprint | Text | - | Sprint identifier (e.g., Sprint-2026-W08) |
| Story Points | Number | - | Effort estimate (1, 2, 3, 5, 8, 13, 21) |
| Priority | Single Select | P0, P1, P2, P3 | Work prioritization |
| Team | Single Select | Engineering, Business, Ops | Team assignment |
| Status | Single Select | Backlog, Sprint Backlog, In Progress, Review, Done, Blocked | Workflow state |

**How to Add:**
1. Open project
2. Click "⚙" (Settings)
3. Select "Fields"
4. Click "+ New field"
5. Configure field type and options

---

### 4. Create Board Views

#### View 1: Current Sprint Board
**Purpose:** Kanban board for current sprint

**Configuration:**
- Layout: Board
- Group by: Status
- Filter: `sprint:Sprint-2026-W08` (update per sprint)
- Sort: Priority (High to Low)
- Columns:
  - Sprint Backlog
  - In Progress
  - Review
  - Done
  - Blocked

---

#### View 2: Sprint Backlog
**Purpose:** All planned work for upcoming sprints

**Configuration:**
- Layout: Table
- Filter: `status:Backlog OR status:Sprint Backlog`
- Sort: Priority (High to Low), Story Points (High to Low)
- Visible Fields:
  - Title
  - Assignee
  - Sprint
  - Story Points
  - Priority
  - Labels

---

#### View 3: Burndown Chart
**Purpose:** Visual progress tracking

**Configuration:**
- Layout: Chart
- X-axis: Date
- Y-axis: Story Points Remaining
- Filter: Current sprint only
- Update: Daily

**Note:** Requires GitHub Insights (Team/Enterprise tier)

---

#### View 4: Velocity Trends
**Purpose:** Historical velocity analysis

**Configuration:**
- Layout: Table (with calculated fields)
- Group by: Sprint
- Aggregate: Sum(Story Points) where Status=Done
- Time Range: Last 6 sprints

---

### 5. Set Up Automation Rules

**Rule 1: Auto-Move to In Progress**
- Trigger: PR opened
- Action: Set Status = "In Progress"

**Rule 2: Auto-Move to Review**
- Trigger: PR ready for review
- Action: Set Status = "Review"

**Rule 3: Auto-Move to Done**
- Trigger: Issue closed OR PR merged
- Action: Set Status = "Done"

**Rule 4: Auto-Label Blocked**
- Trigger: Label "blocked" added
- Action: Set Status = "Blocked"

**How to Add:**
1. Project Settings → Workflows
2. Click "+ New workflow"
3. Select trigger and action
4. Save

---

### 6. Add Team Members

**Roles:**
- **Admin:** Jorge (can modify project, add members)
- **Write:** All team members (can update items)
- **Read:** Stakeholders (view-only access)

**How to Add:**
1. Project Settings → Access
2. Click "Invite collaborators"
3. Search by username or email
4. Select role
5. Send invitation

---

## Usage Patterns

### Sprint Planning (Monday)
1. Filter view: `status:Backlog`
2. Sort by Priority
3. Drag high-priority items to "Sprint Backlog" column
4. Set "Sprint" field to current sprint (e.g., Sprint-2026-W08)
5. Estimate story points
6. Assign team members

---

### Daily Updates
1. Team members update card status as work progresses
2. Move cards between columns (Backlog → In Progress → Review → Done)
3. Flag blockers with "blocked" label (auto-moves to Blocked column)

---

### Sprint Review (Friday)
1. Filter view: Current sprint
2. Review "Done" items (demo work)
3. Discuss "Blocked" items
4. Move incomplete items back to Backlog or next sprint

---

## API Access

### Generate Personal Access Token

**Scopes Required:**
- `project` (read/write projects)
- `repo` (read repository data)
- `read:org` (read organization data)

**Steps:**
1. GitHub Settings → Developer Settings → Personal Access Tokens → Tokens (classic)
2. Generate new token (classic)
3. Select scopes: `project`, `repo`, `read:org`
4. Copy token (save securely - won't be shown again)

**Use in Scripts:**
```bash
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxx"
python scripts/sprint-management/sprint_dashboard.py status --sprint Sprint-2026-W08
```

---

### GraphQL API Examples

#### Query Sprint Items
```graphql
query {
  organization(login: "Seven-Fortunas-Internal") {
    projectV2(number: 1) {
      title
      items(first: 100) {
        nodes {
          id
          content {
            ... on Issue {
              number
              title
              state
              assignees(first: 5) {
                nodes {
                  login
                }
              }
            }
          }
          fieldValues(first: 10) {
            nodes {
              ... on ProjectV2ItemFieldTextValue {
                text
                field {
                  ... on ProjectV2FieldCommon {
                    name
                  }
                }
              }
              ... on ProjectV2ItemFieldNumberValue {
                number
                field {
                  ... on ProjectV2FieldCommon {
                    name
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

---

#### Update Item Status
```graphql
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "PVT_xxxxxxxxxxxxx"
    itemId: "PVTI_xxxxxxxxxxxxx"
    fieldId: "PVTF_xxxxxxxxxxxxx"
    value: {
      singleSelectOptionId: "PVTSSOID_xxxxxxxxxxxxx"
    }
  }) {
    projectV2Item {
      id
    }
  }
}
```

**Note:** IDs are obtained from initial query. See [GitHub Projects API docs](https://docs.github.com/en/graphql/reference/objects#projectv2).

---

## Integration with Other Tools

### GitHub Actions
GitHub Actions can update project items automatically:

```yaml
- name: Update project item
  uses: actions/github-script@v7
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    script: |
      const itemId = context.payload.issue.node_id;
      // GraphQL mutation to update item...
```

---

### Claude Code Skills
The `/7f-sprint-dashboard` skill uses GitHub Projects API to:
- Query sprint status
- Update item fields
- Calculate velocity
- Generate burndown data

**Setup:**
```bash
# Set environment variable
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxx"

# Use skill in Claude Code
/7f-sprint-dashboard status --sprint Sprint-2026-W08
```

---

## Troubleshooting

### Issue: Can't see Projects tab
**Solution:** Upgrade to GitHub Team tier ($4/user/month)

### Issue: API returns 404
**Solution:** Verify project number and organization name. Use GraphQL explorer to test queries.

### Issue: Can't update item fields
**Solution:** Check token has `project` scope. Verify you have Write access to project.

### Issue: Automation rules not triggering
**Solution:** Check workflow is enabled. Verify trigger conditions match event.

---

## Best Practices

✅ **DO:**
- Keep project board updated daily
- Use descriptive issue titles
- Add story points before sprint planning
- Review blocked items in daily standup
- Archive completed sprints regularly

❌ **DON'T:**
- Create multiple projects (use single board with sprint field)
- Skip story point estimation
- Let blocked items sit without updates
- Change sprint scope mid-sprint

---

## References

- [GitHub Projects Documentation](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [GitHub Projects API (GraphQL)](https://docs.github.com/en/graphql/reference/objects#projectv2)
- [Sprint Management Guide](sprint-management-guide.md)
- FR-8.1: Sprint Management
- FR-8.2: Sprint Dashboard

---

**Next Steps:**
1. Upgrade organization to GitHub Team tier
2. Create "Seven Fortunas Sprints" project
3. Configure custom fields and views
4. Set up automation rules
5. Generate personal access token
6. Test sprint_dashboard.py script
7. Run first sprint using GitHub Projects
