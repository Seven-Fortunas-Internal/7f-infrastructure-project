# 7f-sprint-dashboard

**Purpose:** Query and update sprint status using GitHub Projects API

**Category:** Sprint Management
**Owner:** Jorge
**Phase:** Phase 2

---

## Usage

```
/7f-sprint-dashboard [action] [options]
```

**Actions:**
- `status` - Show current sprint status
- `update` - Update sprint item status
- `velocity` - Calculate sprint velocity
- `burndown` - Show sprint burndown chart

---

## Examples

### View Sprint Status
```
/7f-sprint-dashboard status --sprint Sprint-2026-W08
```

**Output:**
```
Sprint: Sprint-2026-W08
Goal: Complete GitHub infrastructure setup
Duration: Feb 19 - Mar 04, 2026

Progress: 12/20 items completed (60%)

Status Breakdown:
  ✓ Done: 12 items (40 story points)
  ⚙ In Progress: 5 items (21 story points)
  ○ To Do: 3 items (13 story points)
  ⚠ Blocked: 0 items

Velocity: 20 points/sprint (last 3 sprints average)
```

---

### Update Item Status
```
/7f-sprint-dashboard update --item STORY-001 --status "In Progress"
```

**Output:**
```
✓ Updated STORY-001: "Create GitHub orgs"
  Status: To Do → In Progress
  Assignee: Jorge
  Sprint: Sprint-2026-W08
```

---

### Calculate Velocity
```
/7f-sprint-dashboard velocity --last-n-sprints 6
```

**Output:**
```
Sprint Velocity Analysis (last 6 sprints):

Sprint-2026-W07: 18 points
Sprint-2026-W06: 22 points
Sprint-2026-W05: 20 points
Sprint-2026-W04: 15 points
Sprint-2026-W03: 19 points
Sprint-2026-W02: 21 points

Average: 19.2 points/sprint
Trend: Stable ±2 points
Confidence: 80% (based on variance)
```

---

### Show Burndown Chart
```
/7f-sprint-dashboard burndown --sprint Sprint-2026-W08
```

**Output:**
```
Sprint Burndown Chart - Sprint-2026-W08

Story Points Remaining:
Day  1: 74 ███████████████████████████████████
Day  2: 68 ████████████████████████████████
Day  3: 63 ██████████████████████████████
Day  4: 58 ███████████████████████████
Day  5: 52 █████████████████████████
Day  6: 47 ██████████████████████
Day  7: 42 ████████████████████
Day  8: 35 ████████████████
Day  9: 28 █████████████
Day 10: 20 ██████████ (today)

Ideal: 22 points remaining
Actual: 20 points remaining
Status: ✓ On track (ahead by 2 points)
```

---

## Implementation (Phase 2)

This skill uses the GitHub Projects API (GraphQL) to:
1. Query sprint board data
2. Update item status/fields
3. Calculate metrics (velocity, burndown)

**Required:**
- GitHub Team tier ($4/user/month for Projects access)
- GitHub personal access token with `project` scope
- Sprint board created in GitHub Projects

**API Calls:**
```graphql
# Query sprint items
query {
  organization(login: "Seven-Fortunas-Internal") {
    projectV2(number: 1) {
      items(first: 100) {
        nodes {
          id
          content {
            ... on Issue {
              number
              title
              state
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
            }
          }
        }
      }
    }
  }
}

# Update item status
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "PROJECT_ID"
    itemId: "ITEM_ID"
    fieldId: "FIELD_ID"
    value: {
      singleSelectOptionId: "OPTION_ID"
    }
  }) {
    projectV2Item {
      id
    }
  }
}
```

---

## Configuration

**Environment Variables:**
```bash
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxx"
export GITHUB_ORG="Seven-Fortunas-Internal"
export SPRINT_PROJECT_NUMBER=1
```

**Config File:** `.7f/sprint-dashboard-config.yaml`
```yaml
github:
  organization: Seven-Fortunas-Internal
  project_number: 1
  token_env_var: GITHUB_TOKEN

sprint:
  default_duration_days: 14
  story_point_field: "Story Points"
  sprint_field: "Sprint"
  status_field: "Status"

metrics:
  velocity_window: 6  # Last N sprints for velocity calculation
  confidence_threshold: 0.8
```

---

## Integration with GitHub Projects

### Board Setup
1. Create GitHub Project in organization
2. Add custom fields:
   - Sprint (text)
   - Story Points (number)
   - Priority (single select)
3. Configure views:
   - Current Sprint (filter by sprint)
   - Burndown (chart view)
   - Velocity (insights view)

### Automation
GitHub Projects can auto-update status based on:
- Issue state (open/closed)
- PR merge status
- Labels (in-progress, blocked, etc.)

---

## See Also
- [Sprint Management Guide](../docs/sprint-management-guide.md)
- [GitHub Projects API Docs](https://docs.github.com/en/graphql/reference/objects#projectv2)
- FR-8.1: Sprint Management
- FR-8.3: Project Progress Dashboard

---

## Implementation

This skill is implemented by: `scripts/7f-sprint-dashboard.sh`

**Usage:**
```bash
# View sprint status
./scripts/7f-sprint-dashboard.sh status --sprint Sprint-2026-W08

# Update item
./scripts/7f-sprint-dashboard.sh update --item STORY-001 --status "In Progress"

# Calculate velocity
./scripts/7f-sprint-dashboard.sh velocity --last-n-sprints 6

# Show burndown
./scripts/7f-sprint-dashboard.sh burndown --sprint Sprint-2026-W08
```

**Setup Required:**
1. Create GitHub Projects board: `./scripts/setup-github-projects-sprint-board.sh`
2. Complete manual setup steps (custom fields, views) - see generated guide
3. Sync stories to board: `./scripts/sync-stories-to-github.sh`

**Status:** Operational (GitHub Projects integration available)
**Dependencies:** GitHub CLI (gh), GitHub Team tier ($4/user/month for Projects)