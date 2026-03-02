# 7F Dashboard Curator

Manage AI dashboard data sources (RSS feeds, Reddit subreddits, YouTube channels) with validation and automatic rebuild triggering.

## Usage

This skill provides commands to add, remove, and manage dashboard data sources across multiple dashboards (AI, FinTech, EduTech, Security).

### Add RSS Feed

```bash
/7f-dashboard-curator add-rss <name> <url> [--no-rebuild]
```

Example:
```bash
/7f-dashboard-curator add-rss "AI Weekly" "https://example.com/ai-weekly.xml"
```

Adds an RSS feed with:
- URL validation (fetches and validates feed structure)
- Duplicate detection
- Automatic audit logging
- Dashboard rebuild trigger (unless `--no-rebuild` specified)

### Remove RSS Feed

```bash
/7f-dashboard-curator remove-rss <name>
```

Example:
```bash
/7f-dashboard-curator remove-rss "AI Weekly"
```

Removes an RSS feed by name from the configuration.

### Add Reddit Subreddit

```bash
/7f-dashboard-curator add-reddit <name> <subreddit> [--no-rebuild]
```

Example:
```bash
/7f-dashboard-curator add-reddit "ML Community" "MachineLearning"
```

Adds a Reddit subreddit with:
- Subreddit existence validation (checks via Reddit API)
- Duplicate detection
- Automatic audit logging
- Dashboard rebuild trigger

### Remove Reddit Subreddit

```bash
/7f-dashboard-curator remove-reddit <name>
```

Example:
```bash
/7f-dashboard-curator remove-reddit "ML Community"
```

Removes a Reddit subreddit from the configuration.

### Add YouTube Channel

```bash
/7f-dashboard-curator add-youtube <name> <channel_id> [--no-rebuild]
```

Example:
```bash
/7f-dashboard-curator add-youtube "AI Explained" "UCbfYPyITQ-7l4upoX8nvctg"
```

Adds a YouTube channel with:
- Channel ID format validation (24-char, starts with UC)
- Duplicate detection
- Automatic audit logging
- Dashboard rebuild trigger

### Remove YouTube Channel

```bash
/7f-dashboard-curator remove-youtube <name>
```

Example:
```bash
/7f-dashboard-curator remove-youtube "AI Explained"
```

Removes a YouTube channel from the configuration.

### List Sources

```bash
/7f-dashboard-curator list [--dashboard {ai|fintech|edutech|security}]
```

Example:
```bash
/7f-dashboard-curator list
/7f-dashboard-curator list --dashboard fintech
```

Lists all configured data sources for the specified dashboard, showing:
- RSS feeds
- GitHub repositories
- Reddit subreddits
- YouTube channels
- Twitter/X accounts (if configured)

### Trigger Rebuild

```bash
/7f-dashboard-curator rebuild [--dashboard {ai|fintech|edutech|security}]
```

Example:
```bash
/7f-dashboard-curator rebuild
```

Manually triggers the dashboard rebuild workflow via GitHub Actions.

## Dashboard Selection

By default, commands operate on the `ai` dashboard. To work with other dashboards:

```bash
/7f-dashboard-curator --dashboard fintech add-rss "FinTech News" "https://example.com/fintech.xml"
/7f-dashboard-curator --dashboard edutech list
/7f-dashboard-curator --dashboard security rebuild
```

Supported dashboards:
- `ai` (default) - AI Advancements Dashboard
- `fintech` - FinTech Industry Dashboard
- `edutech` - EduTech Sector Dashboard
- `security` - Security & Compliance Dashboard

## Validation Rules

### RSS Feeds
- URL must return valid RSS or Atom feed
- Feed must contain at least one entry
- HTTP status must be 200
- Response must contain `<rss` or `<feed` tags

### Reddit Subreddits
- Subreddit must exist on Reddit
- Verified via Reddit JSON API
- Case-insensitive name handling

### YouTube Channels
- Channel ID must be exactly 24 characters
- Must start with "UC" prefix
- Format: UCxxxxxxxxxxxxxxxxxx (where x = alphanumeric)

## Configuration

Data sources are stored in `dashboards/{dashboard}/config/sources.yaml` with structure:

```yaml
sources:
  rss:
  - name: Source Name
    url: https://example.com/feed.xml
    enabled: true
    timeout: 10
    retry_attempts: 3
  reddit:
  - name: Source Name
    subreddit: MachineLearning
    enabled: true
    timeout: 10
    retry_attempts: 3
    limit: 10
  youtube:
  - name: Source Name
    channel_id: UCxxxxxxxxxxxxxxxx
    enabled: true
    timeout: 10
    retry_attempts: 3
    limit: 5
```

## Audit Trail

All configuration changes are logged to `dashboards/{dashboard}/config/audit.log`:

```
2026-03-01T15:30:45Z | ADD | rss | AI Weekly | url=https://example.com/feed.xml
2026-03-01T15:31:20Z | REMOVE | reddit | ML Community |
```

Log entries include:
- ISO 8601 timestamp (UTC)
- Operation type (ADD, REMOVE, UPDATE)
- Source type (rss, reddit, youtube, github)
- Source name
- Additional details (URL, subreddit, channel_id, etc.)

## Integration

This skill integrates with:
- **Dashboard Auto-Update (FR-4.1)**: Feeds configured sources to update engine
- **Dashboard Rebuild (FR-4.3)**: Automatically triggers rebuild after config changes
- **Data Source Management**: Maintains audit trail of all configuration modifications
- **Multiple Dashboards**: Supports AI, FinTech, EduTech, Security dashboards

## Implementation

This skill wraps the `scripts/dashboard_curator_cli.py` script which:
- Manages YAML configuration files
- Validates external data sources
- Maintains audit logs
- Integrates with GitHub Actions for rebuilds
- Supports multiple dashboard instances

## Prerequisites

1. **Dashboard Directories**: `dashboards/{dashboard}/config/` must exist
2. **Configuration Files**: `sources.yaml` must be present
3. **Network Access**: For validation (RSS, Reddit APIs)
4. **GitHub CLI**: `gh` authenticated (for rebuild trigger)

## Error Handling

- Invalid URLs → validation failure, configuration unchanged
- Non-existent subreddits → validation failure, configuration unchanged
- Invalid channel IDs → validation failure, configuration unchanged
- Duplicate sources → rejected, configuration unchanged
- Rebuild trigger failures → non-fatal, configuration persists

## Examples

### Daily Curation Flow

```bash
# Check current sources
/7f-dashboard-curator list

# Add new AI news source
/7f-dashboard-curator add-rss "OpenAI Blog" "https://openai.com/blog/rss.xml"

# Add popular discussion forum
/7f-dashboard-curator add-reddit "ML Discussions" "MachineLearning"

# Verify rebuild triggered
/7f-dashboard-curator rebuild
```

### Multi-Dashboard Management

```bash
# Manage AI dashboard
/7f-dashboard-curator list

# Manage FinTech dashboard
/7f-dashboard-curator --dashboard fintech add-rss "FinTech Daily" "https://example.com/fintech.xml"
/7f-dashboard-curator --dashboard fintech list

# Manage Security dashboard
/7f-dashboard-curator --dashboard security add-reddit "SecurityNews" "netsec"
```

## Technical Details

- Source validation uses external APIs (Reddit, feedparser)
- Timeout: 10 seconds per validation request
- YAML parsing uses safe loading (no arbitrary code execution)
- Backup created before config changes
- All operations logged with timestamps

## References

- [Dashboard Configuration](../docs/dashboard-configuration.md)
- [Sources Schema](../docs/sources-schema.md)
- [GitHub Actions Integration](../docs/github-actions-integration.md)

---

**Owner:** Jorge (VP AI-SecOps)
**Phase:** Phase B
**Feature:** FR-4.3 Dashboard Configurator Skill
**Status:** Operational
