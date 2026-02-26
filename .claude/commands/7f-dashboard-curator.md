---
description: "Manage dashboard data sources for AI, Fintech, EduTech, and Security dashboards"
tags: ["dashboard", "ai", "fintech", "edutech", "security", "configuration", "data-sources"]
---

# Dashboard Curator Skill

Manage data sources for all Seven Fortunas dashboards:
- **AI Dashboard:** dashboards/ai/ (AI/ML advancements)
- **Fintech Dashboard:** dashboards/fintech/ (Financial technology trends)
- **EduTech Dashboard:** dashboards/edutech/ (Educational technology, Peru market focus)
- **Security Dashboard:** dashboards/security/ (Security intelligence and vulnerabilities)

## Usage

This skill provides commands to add/remove data sources for any dashboard using the `--dashboard` parameter.

**Available Dashboards:**
- `ai` (default) - AI/ML advancements
- `fintech` - Financial technology trends
- `edutech` - Educational technology (Peru market focus)
- `security` - Security intelligence and vulnerabilities

**Add RSS Feed:**
```bash
# AI dashboard (default)
python3 scripts/dashboard_curator_cli.py add-rss "Feed Name" "https://example.com/feed.xml"

# Other dashboards
python3 scripts/dashboard_curator_cli.py --dashboard fintech add-rss "Fintech News" "https://example.com/feed.xml"
python3 scripts/dashboard_curator_cli.py --dashboard edutech add-rss "EduTech News" "https://example.com/feed.xml"
python3 scripts/dashboard_curator_cli.py --dashboard security add-rss "Security Feed" "https://example.com/feed.xml"
```

**Remove RSS Feed:**
```bash
python3 scripts/dashboard_curator_cli.py --dashboard fintech remove-rss "Feed Name"
```

**Add Reddit Subreddit:**
```bash
python3 scripts/dashboard_curator_cli.py --dashboard fintech add-reddit "Display Name" "subreddit_name"
```

**Remove Reddit Subreddit:**
```bash
python3 scripts/dashboard_curator_cli.py --dashboard fintech remove-reddit "Display Name"
```

**Add YouTube Channel:**
```bash
python3 scripts/dashboard_curator_cli.py --dashboard fintech add-youtube "Channel Name" "UCxxxxxxxxxxxxxxxxxx"
```

**List All Sources:**
```bash
# AI dashboard (default)
python3 scripts/dashboard_curator_cli.py list

# Specific dashboard
python3 scripts/dashboard_curator_cli.py --dashboard fintech list
python3 scripts/dashboard_curator_cli.py --dashboard edutech list
python3 scripts/dashboard_curator_cli.py --dashboard security list
```

**Trigger Dashboard Rebuild:**
```bash
python3 scripts/dashboard_curator_cli.py --dashboard fintech rebuild
```

## Features

- ✅ **Validation:** Tests data sources before adding (RSS feed fetch, Reddit subreddit lookup, YouTube channel ID format)
- ✅ **Safe Updates:** Uses PyYAML safe parsing to update `dashboards/ai/config/sources.yaml`
- ✅ **Audit Trail:** Logs all configuration changes to `dashboards/ai/config/audit.log`
- ✅ **Auto-Rebuild:** Triggers GitHub Actions workflow after configuration updates
- ✅ **Duplicate Prevention:** Checks for existing sources before adding

## Configuration File

Data sources are stored in:
```
dashboards/ai/config/sources.yaml
```

Structure:
```yaml
sources:
  rss:
    - name: "Source Name"
      url: "https://example.com/feed.xml"
      enabled: true
      timeout: 10
      retry_attempts: 3

  reddit:
    - name: "r/SubredditName"
      subreddit: "SubredditName"
      enabled: true
      timeout: 10
      retry_attempts: 3
      limit: 10

  youtube:
    - name: "Channel Name"
      channel_id: "UCxxxxxxxxxxxxxxxxxx"
      enabled: true
      timeout: 10
      retry_attempts: 3
      limit: 5
```

## Audit Log

All changes are logged to:
```
dashboards/ai/config/audit.log
```

Format:
```
2026-02-24T20:30:00Z | ADD | rss | AI Weekly | url=https://example.com/feed.xml
2026-02-24T20:35:00Z | REMOVE | reddit | r/example |
```

## Integration

- **Auto-Update Pipeline (FR-4.1):** Changes trigger GitHub Actions workflow `update-dashboard.yml`
- **Validation:** All sources validated before adding to prevent broken feeds
- **Graceful Degradation:** Dashboard continues working if individual sources fail

## Examples

**Add a new AI research blog:**
```bash
python3 scripts/dashboard_curator_cli.py add-rss "Anthropic Research" "https://www.anthropic.com/research/rss.xml"
```

**Add community subreddit:**
```bash
python3 scripts/dashboard_curator_cli.py add-reddit "r/LocalLLaMA" "LocalLLaMA"
```

**Add YouTube AI channel:**
```bash
python3 scripts/dashboard_curator_cli.py add-youtube "AI Explained" "UCbfYPyITQ-7l4upoX8nvctg"
```

**Skip auto-rebuild (for batch operations):**
```bash
python3 scripts/dashboard_curator_cli.py add-rss "Feed 1" "https://feed1.com/rss" --no-rebuild
python3 scripts/dashboard_curator_cli.py add-rss "Feed 2" "https://feed2.com/rss" --no-rebuild
python3 scripts/dashboard_curator_cli.py rebuild
```

---

**Implementation:** `scripts/dashboard_curator_cli.py`
**Configuration:** `dashboards/ai/config/sources.yaml`
**Audit Log:** `dashboards/ai/config/audit.log`
**Workflow:** `dashboards/ai/.github/workflows/update-dashboard.yml`
