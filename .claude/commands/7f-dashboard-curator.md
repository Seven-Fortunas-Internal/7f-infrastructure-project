# Dashboard Curator Skill

**Skill ID:** 7f-dashboard-curator
**Purpose:** Configure AI Advancements Dashboard data sources
**Owner:** Jorge

---

## Overview

This skill allows you to manage the AI Advancements Dashboard data sources by:
- Adding/removing RSS feeds
- Adding/removing Reddit subreddits
- Adding/removing YouTube channels
- Configuring update frequency
- Validating data sources before saving

All changes are logged to an audit trail and trigger an automatic dashboard rebuild.

---

## Usage

Invoke this skill from Claude Code:
```
/7f-dashboard-curator
```

---

## Operations

### 1. Add RSS Feed

Add a new RSS feed to the dashboard data sources.

**Required information:**
- Feed URL (validated before saving)
- Display name
- Optional: Keywords for filtering

**Example:**
```
Add RSS Feed:
- URL: https://blog.anthropic.com/rss.xml
- Name: Anthropic Blog
```

### 2. Remove RSS Feed

Remove an existing RSS feed by name or URL.

**Example:**
```
Remove RSS Feed:
- Name: Anthropic Blog
```

### 3. Add Reddit Subreddit

Add a new subreddit to track.

**Required information:**
- Subreddit name (without r/ prefix)
- Optional: Post limit (default: 10)

**Example:**
```
Add Reddit Subreddit:
- Subreddit: MachineLearning
- Limit: 10
```

### 4. Remove Reddit Subreddit

Remove an existing subreddit by name.

### 5. Add YouTube Channel

Add a YouTube channel to track.

**Required information:**
- Channel ID
- Display name
- Optional: Video limit (default: 5)

**Example:**
```
Add YouTube Channel:
- Channel ID: UCbfYPyITQ-7l4upoX8nvctg
- Name: Two Minute Papers
- Limit: 5
```

### 6. Configure Update Frequency

Change the dashboard update frequency.

**Options:**
- Every 6 hours (default)
- Every 12 hours
- Daily

---

## Implementation

When invoked, this skill:

1. **Loads current configuration** from `dashboards/ai/sources.yaml`
2. **Presents menu** of available operations
3. **Collects user input** for the selected operation
4. **Validates data source** (test fetch before saving)
5. **Updates configuration** with safe YAML parsing
6. **Logs change** to audit trail (`dashboards/ai/config/audit.log`)
7. **Triggers rebuild** by running dashboard update script

---

## Validation

Before saving any data source:
- **RSS feeds:** Test fetch and parse feed
- **Reddit subreddits:** Verify subreddit exists
- **YouTube channels:** Verify channel ID is valid

---

## Audit Trail

All configuration changes are logged to:
```
dashboards/ai/config/audit.log
```

Log format:
```
[2026-02-18 04:45:00 UTC] ADD_RSS_FEED: Anthropic Blog (https://blog.anthropic.com/rss.xml) - User: Jorge
[2026-02-18 04:46:00 UTC] REMOVE_REDDIT: r/artificial - User: Jorge
```

---

## Files Modified

- `dashboards/ai/sources.yaml` - Data source configuration
- `dashboards/ai/config/audit.log` - Audit trail
- `dashboards/ai/README.md` - Dashboard (via rebuild)

---

## Technical Details

**Implementation script:** `scripts/dashboard_curator.py`
**Configuration file:** `dashboards/ai/sources.yaml`
**Audit log:** `dashboards/ai/config/audit.log`

---

## Workflow Steps

**Step 1: Initialize**
- Load current configuration from sources.yaml
- Display current data sources summary

**Step 2: Present Menu**
- Add RSS Feed
- Remove RSS Feed
- Add Reddit Subreddit
- Remove Reddit Subreddit
- Add YouTube Channel
- Remove YouTube Channel
- Configure Update Frequency
- View Audit Log
- Exit

**Step 3: Execute Operation**
- Collect user input
- Validate data source
- Update configuration
- Log change
- Trigger rebuild

**Step 4: Confirm**
- Display updated configuration
- Confirm dashboard rebuild triggered

---

## Error Handling

- **Invalid URL:** Display error, don't save
- **Duplicate source:** Warn user, ask to overwrite
- **Validation failure:** Display error details, don't save
- **YAML parse error:** Display error, restore backup

---

## Example Session

```
$ /7f-dashboard-curator

=== Dashboard Curator ===

Current configuration:
- RSS Feeds: 4 sources
- Reddit: 2 subreddits
- YouTube: 2 channels
- Update frequency: Every 6 hours

Select operation:
1. Add RSS Feed
2. Remove RSS Feed
3. Add Reddit Subreddit
4. Remove Reddit Subreddit
5. Add YouTube Channel
6. Remove YouTube Channel
7. Configure Update Frequency
8. View Audit Log
9. Exit

> 1

Enter RSS feed URL: https://mistral.ai/news/rss.xml
Enter display name: Mistral AI Blog

Validating feed... ✓ Valid (12 entries found)

Configuration updated!
Audit log entry created.
Triggering dashboard rebuild...

Dashboard rebuild complete!
```

---

**Note:** This is a Claude Code skill. Invoke with `/7f-dashboard-curator` from the Claude Code interface.
