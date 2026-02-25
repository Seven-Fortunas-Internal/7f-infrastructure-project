# Project Progress Dashboard

Daily-updated visibility into project health and velocity for Seven Fortunas infrastructure project.

## Metrics

- Sprint velocity and trends
- Feature completion rate  
- Burndown charts
- Active blockers
- AI-generated weekly summaries

## Setup

```bash
# Collect data
python3 dashboards/project-progress/scripts/collect-project-data.py

# View dashboard
cd dashboards/project-progress && python3 -m http.server 8080
```

## Data Sources

- feature_list.json
- sprint-management/velocity-history.json
- GitHub Issues API

## Integration

- 7F Lens Dashboard #2
- Sprint Management (FR-8.1)
- Sprint Dashboard (FR-8.2)
