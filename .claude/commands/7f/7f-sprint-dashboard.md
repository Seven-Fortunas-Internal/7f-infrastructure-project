# 7F Sprint Dashboard

Query and update sprint status using GitHub Projects API.

## Usage

This skill provides interactive sprint management through GitHub Projects:

### View Sprint Status

```bash
/7f-sprint-dashboard status --sprint <sprint-name>
```

Example:
```bash
/7f-sprint-dashboard status --sprint Sprint-2026-W08
```

Displays:
- Sprint goal
- Overall progress
- Status breakdown (done, in-progress, backlog, blocked)
- List of all sprint items

### Update Item Status

```bash
/7f-sprint-dashboard update --item <item-id> --status <new-status>
```

Example:
```bash
/7f-sprint-dashboard update --item STORY-001 --status "In Progress"
```

Updates the status of a sprint item via GitHub Projects API.

### Calculate Sprint Velocity

```bash
/7f-sprint-dashboard velocity --last-n-sprints <n>
```

Example:
```bash
/7f-sprint-dashboard velocity --last-n-sprints 6
```

Calculates average velocity based on last N sprints.

### Show Burndown Chart

```bash
/7f-sprint-dashboard burndown --sprint <sprint-name>
```

Example:
```bash
/7f-sprint-dashboard burndown --sprint Sprint-2026-W08
```

Generates burndown chart data for the specified sprint.

## Implementation

This skill wraps the `scripts/7f-sprint-dashboard.sh` script which interfaces with:
- GitHub Projects API (GraphQL)
- GitHub Issues API
- Sprint velocity calculator
- Burndown chart generator

## Prerequisites

1. **GitHub Projects Board**: Created via setup script
   ```bash
   ./scripts/setup-github-projects-sprint-board.sh
   ```

2. **GitHub Authentication**: gh CLI authenticated
   ```bash
   gh auth status
   ```

3. **GitHub Team Tier**: Required for GitHub Projects ($4/user/month)

## Configuration

Configuration file: `.7f/sprint-dashboard-config.yaml`

Contains:
- Project number
- Project title
- Custom field IDs
- Status field values

## Integration

This skill integrates with:
- **Sprint Management (FR-8.1)**: Sprint creation and review workflows
- **Project Progress Dashboard (FR-8.3)**: Feeds data to overall dashboard
- **GitHub Projects**: Real-time board visualization

## Supported Status Values

- `Backlog` - Not yet started
- `In Progress` - Currently being worked on
- `Done` - Completed
- `Blocked` - Cannot proceed

## Examples

### Daily Standup

```bash
# Check today's sprint status
/7f-sprint-dashboard status --sprint Sprint-2026-W08

# Update your current tasks
/7f-sprint-dashboard update --item STORY-042 --status "In Progress"
```

### Sprint Review

```bash
# View velocity trends
/7f-sprint-dashboard velocity --last-n-sprints 6

# Generate burndown for retrospective
/7f-sprint-dashboard burndown --sprint Sprint-2026-W08
```

### Sprint Planning

```bash
# Check backlog items
/7f-sprint-dashboard status --sprint Next-Sprint

# Calculate capacity based on historical velocity
/7f-sprint-dashboard velocity --last-n-sprints 3
```

## Technical Notes

- Uses GitHub Projects V2 API (GraphQL)
- Requires GitHub Team tier or higher
- Real-time updates (within 5 minutes)
- Board accessible to all organization members
- Integrates with sprint management workflows

## References

- [GitHub Projects Documentation](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [GitHub Projects API](https://docs.github.com/en/graphql/reference/objects#projectv2)
- [Sprint Management Guide](../docs/sprint-management-guide.md)

---

**Owner:** Jorge (VP AI-SecOps)
**Phase:** Phase 2
**Status:** Operational
