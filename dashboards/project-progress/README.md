# Project Progress Dashboard

Daily-updated visibility into project health and velocity for Seven Fortunas infrastructure project.

## Metrics Collected

- **Sprint Velocity** - Average story points delivered per sprint with trend analysis
- **Feature Completion Rate** - Percentage of features completed vs. total planned
- **Burndown Chart** - Remaining work vs. ideal burndown trajectory
- **Active Blockers** - Features blocked with reasons and owners
- **Team Utilization** - Percentage of planned capacity utilized
- **AI-Generated Weekly Summaries** - Claude-powered insights on project health

## Data Collection

Data is collected from multiple sources and refreshed daily via GitHub Actions:

- **feature_list.json** - Feature status, completion tracking
- **sprint-management/velocity-history.json** - Sprint velocity metrics
- **GitHub Issues API** - Blocker tracking, team assignments
- **GitHub Projects API** - Sprint board status

Collection runs daily at 8:00 AM UTC via `.github/workflows/update-project-progress.yml`.

Historical data is archived for 52 weeks in `dashboards/project-progress/data/archive/`.

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

## Integration with 7F Lens

This dashboard is **Dashboard #2** in the 7F Lens multi-dimensional intelligence platform.

It integrates with:
- **FR-8.1 (Sprint Management)** - Sprint velocity data
- **FR-8.2 (Sprint Dashboard)** - Sprint board visualization
- **FR-4.1 (AI Advancements Dashboard)** - Shared infrastructure and update workflows

All 7F Lens dashboards share common infrastructure:
- GitHub Actions for automated updates
- JSON data format for interoperability
- Mobile-responsive HTML/CSS design
- Weekly AI summaries via Anthropic API

## Phase 2 Implementation Plan

**Current Status:** Phase 1.5 Complete (FR-8.3) - Data collection and basic dashboard

**Phase 2 Enhancements:**
- Interactive charts with Chart.js or D3.js
- Real-time WebSocket updates (optional, daily updates sufficient)
- Team member drill-down views
- Customizable metric thresholds and alerts
- Export to PDF for stakeholder reports
- Integration with Slack for blocker notifications
