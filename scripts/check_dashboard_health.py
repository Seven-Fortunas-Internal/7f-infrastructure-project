#!/usr/bin/env python3
"""
Dashboard Health Checker
Creates GitHub issue if dashboard has persistent failures (>24h)
"""

import json
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path
import requests

def check_health():
    """Check dashboard health and create issue if needed"""
    metadata_file = Path("dashboards/ai/data/cache_metadata.json")

    if not metadata_file.exists():
        print("No metadata file found - first run?")
        return

    with open(metadata_file, 'r') as f:
        metadata = json.load(f)

    last_update = datetime.fromisoformat(metadata.get('last_successful_update', datetime.utcnow().isoformat()))
    age_hours = (datetime.utcnow() - last_update).total_seconds() / 3600

    # Check if persistent failure (>24h)
    if age_hours > 24:
        print(f"Persistent failure detected: {age_hours:.1f} hours since last successful update")
        create_github_issue(age_hours, metadata)
    else:
        print(f"Dashboard health OK: Last update {age_hours:.1f} hours ago")

def create_github_issue(age_hours: float, metadata: dict):
    """Create GitHub issue for persistent dashboard failure"""
    token = os.environ.get('GITHUB_TOKEN')
    if not token:
        print("GITHUB_TOKEN not set - cannot create issue")
        return

    repo = os.environ.get('GITHUB_REPOSITORY')
    if not repo:
        print("GITHUB_REPOSITORY not set - cannot create issue")
        return

    issue_title = f"AI Dashboard: Persistent Failure ({age_hours:.0f}h)"
    issue_body = f"""## AI Advancements Dashboard Failure

**Duration:** {age_hours:.1f} hours
**Last Successful Update:** {metadata.get('last_successful_update', 'Unknown')}

### Issue Details
The AI Advancements Dashboard has been experiencing failures for over 24 hours.

### Troubleshooting Steps
1. Check GitHub Actions logs for the `Update AI Advancements Dashboard` workflow
2. Verify data source availability (RSS feeds, GitHub API, Reddit API)
3. Check API credentials (REDDIT_CLIENT_ID, REDDIT_CLIENT_SECRET)
4. Review rate limits (GitHub API, Reddit API)

### Auto-Generated
This issue was automatically created by the dashboard health checker.
"""

    url = f"https://api.github.com/repos/{repo}/issues"
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json'
    }

    data = {
        'title': issue_title,
        'body': issue_body,
        'labels': ['dashboard', 'automated', 'critical']
    }

    try:
        response = requests.post(url, headers=headers, json=data)
        response.raise_for_status()
        print(f"GitHub issue created: {response.json()['html_url']}")
    except Exception as e:
        print(f"Failed to create GitHub issue: {e}")

if __name__ == '__main__':
    check_health()
