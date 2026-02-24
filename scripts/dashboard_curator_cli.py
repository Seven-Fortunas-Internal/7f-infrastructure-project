#!/usr/bin/env python3
"""
Dashboard Curator CLI - Manage AI Dashboard Data Sources
Non-interactive command-line interface for managing dashboard data sources
"""

import argparse
import json
import sys
import yaml
from pathlib import Path
from datetime import datetime
import subprocess
import urllib.request
import urllib.error

# Paths
PROJECT_ROOT = Path(__file__).parent.parent
SOURCES_YAML = PROJECT_ROOT / "dashboards/ai/sources.yaml"
AUDIT_LOG = PROJECT_ROOT / "dashboards/ai/config/audit.log"

def load_sources():
    """Load sources.yaml configuration"""
    if not SOURCES_YAML.exists():
        print(f"ERROR: sources.yaml not found at {SOURCES_YAML}", file=sys.stderr)
        sys.exit(1)

    with open(SOURCES_YAML, 'r') as f:
        return yaml.safe_load(f)

def save_sources(config):
    """Save sources.yaml configuration with validation"""
    try:
        # Validate YAML structure
        yaml.safe_dump(config)

        # Write to file
        with open(SOURCES_YAML, 'w') as f:
            yaml.dump(config, f, default_flow_style=False, sort_keys=False)

        return True
    except Exception as e:
        print(f"ERROR: Failed to save sources.yaml: {e}", file=sys.stderr)
        return False

def log_change(action, source_type, name, details=""):
    """Log configuration change to audit trail"""
    AUDIT_LOG.parent.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
    log_entry = f"{timestamp} | {action} | {source_type} | {name}"
    if details:
        log_entry += f" | {details}"

    with open(AUDIT_LOG, 'a') as f:
        f.write(log_entry + "\n")

    print(f"✓ Logged: {log_entry}")

def validate_rss(url):
    """Validate RSS feed by attempting to fetch it"""
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=10) as response:
            if response.status == 200:
                content = response.read()
                # Basic check: should contain <rss or <feed
                if b'<rss' in content or b'<feed' in content:
                    return True, "Valid RSS/Atom feed"
                else:
                    return False, "URL returns 200 but not a valid RSS/Atom feed"
            return False, f"HTTP {response.status}"
    except urllib.error.URLError as e:
        return False, f"Connection error: {e.reason}"
    except Exception as e:
        return False, f"Validation error: {str(e)}"

def validate_reddit(subreddit):
    """Validate Reddit subreddit by checking if it exists"""
    try:
        url = f"https://www.reddit.com/r/{subreddit}/about.json"
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=10) as response:
            if response.status == 200:
                data = json.loads(response.read())
                if 'data' in data and 'display_name' in data['data']:
                    return True, f"Subreddit r/{subreddit} exists"
            return False, f"Subreddit r/{subreddit} not found"
    except Exception as e:
        return False, f"Validation error: {str(e)}"

def validate_youtube(channel_id):
    """Validate YouTube channel ID (basic format check)"""
    # YouTube channel IDs are 24 characters starting with UC
    if len(channel_id) == 24 and channel_id.startswith('UC'):
        return True, "Valid YouTube channel ID format"
    return False, "Invalid YouTube channel ID format (should be 24 chars starting with UC)"

def add_rss(name, url):
    """Add RSS feed to sources.yaml"""
    print(f"\n→ Adding RSS feed: {name}")
    print(f"  URL: {url}")

    # Validate
    print("  Validating RSS feed...")
    valid, message = validate_rss(url)
    if not valid:
        print(f"✗ Validation failed: {message}", file=sys.stderr)
        return False
    print(f"  ✓ {message}")

    # Load config
    config = load_sources()

    # Check for duplicates
    if 'sources' not in config:
        config['sources'] = {}
    if 'rss' not in config['sources']:
        config['sources']['rss'] = []

    for feed in config['sources']['rss']:
        if feed['url'] == url:
            print(f"✗ RSS feed with URL {url} already exists", file=sys.stderr)
            return False

    # Add feed
    new_feed = {
        'name': name,
        'url': url,
        'enabled': True,
        'timeout': 10,
        'retry_attempts': 3
    }
    config['sources']['rss'].append(new_feed)

    # Save
    if save_sources(config):
        log_change('ADD', 'rss', name, f"url={url}")
        print(f"✓ Added RSS feed: {name}")
        return True
    return False

def remove_rss(name):
    """Remove RSS feed from sources.yaml"""
    print(f"\n→ Removing RSS feed: {name}")

    config = load_sources()

    if 'sources' not in config or 'rss' not in config['sources']:
        print("✗ No RSS feeds configured", file=sys.stderr)
        return False

    original_count = len(config['sources']['rss'])
    config['sources']['rss'] = [f for f in config['sources']['rss'] if f['name'] != name]

    if len(config['sources']['rss']) == original_count:
        print(f"✗ RSS feed '{name}' not found", file=sys.stderr)
        return False

    if save_sources(config):
        log_change('REMOVE', 'rss', name)
        print(f"✓ Removed RSS feed: {name}")
        return True
    return False

def add_reddit(name, subreddit):
    """Add Reddit subreddit to sources.yaml"""
    print(f"\n→ Adding Reddit subreddit: {name}")
    print(f"  Subreddit: r/{subreddit}")

    # Validate
    print("  Validating subreddit...")
    valid, message = validate_reddit(subreddit)
    if not valid:
        print(f"✗ Validation failed: {message}", file=sys.stderr)
        return False
    print(f"  ✓ {message}")

    # Load config
    config = load_sources()

    if 'sources' not in config:
        config['sources'] = {}
    if 'reddit' not in config['sources']:
        config['sources']['reddit'] = []

    # Check for duplicates
    for sub in config['sources']['reddit']:
        if sub['subreddit'] == subreddit:
            print(f"✗ Subreddit r/{subreddit} already exists", file=sys.stderr)
            return False

    # Add subreddit
    new_sub = {
        'name': name,
        'subreddit': subreddit,
        'enabled': True,
        'timeout': 10,
        'retry_attempts': 3,
        'limit': 10
    }
    config['sources']['reddit'].append(new_sub)

    if save_sources(config):
        log_change('ADD', 'reddit', name, f"subreddit={subreddit}")
        print(f"✓ Added Reddit subreddit: {name}")
        return True
    return False

def remove_reddit(name):
    """Remove Reddit subreddit from sources.yaml"""
    print(f"\n→ Removing Reddit subreddit: {name}")

    config = load_sources()

    if 'sources' not in config or 'reddit' not in config['sources']:
        print("✗ No Reddit subreddits configured", file=sys.stderr)
        return False

    original_count = len(config['sources']['reddit'])
    config['sources']['reddit'] = [s for s in config['sources']['reddit'] if s['name'] != name]

    if len(config['sources']['reddit']) == original_count:
        print(f"✗ Reddit subreddit '{name}' not found", file=sys.stderr)
        return False

    if save_sources(config):
        log_change('REMOVE', 'reddit', name)
        print(f"✓ Removed Reddit subreddit: {name}")
        return True
    return False

def add_youtube(name, channel_id):
    """Add YouTube channel to sources.yaml"""
    print(f"\n→ Adding YouTube channel: {name}")
    print(f"  Channel ID: {channel_id}")

    # Validate
    print("  Validating channel ID...")
    valid, message = validate_youtube(channel_id)
    if not valid:
        print(f"✗ Validation failed: {message}", file=sys.stderr)
        return False
    print(f"  ✓ {message}")

    # Load config
    config = load_sources()

    if 'sources' not in config:
        config['sources'] = {}
    if 'youtube' not in config['sources']:
        config['sources']['youtube'] = []

    # Check for duplicates
    for channel in config['sources']['youtube']:
        if channel['channel_id'] == channel_id:
            print(f"✗ YouTube channel {channel_id} already exists", file=sys.stderr)
            return False

    # Add channel
    new_channel = {
        'name': name,
        'channel_id': channel_id,
        'enabled': True,
        'timeout': 10,
        'retry_attempts': 3,
        'limit': 5
    }
    config['sources']['youtube'].append(new_channel)

    if save_sources(config):
        log_change('ADD', 'youtube', name, f"channel_id={channel_id}")
        print(f"✓ Added YouTube channel: {name}")
        return True
    return False

def remove_youtube(name):
    """Remove YouTube channel from sources.yaml"""
    print(f"\n→ Removing YouTube channel: {name}")

    config = load_sources()

    if 'sources' not in config or 'youtube' not in config['sources']:
        print("✗ No YouTube channels configured", file=sys.stderr)
        return False

    original_count = len(config['sources']['youtube'])
    config['sources']['youtube'] = [c for c in config['sources']['youtube'] if c['name'] != name]

    if len(config['sources']['youtube']) == original_count:
        print(f"✗ YouTube channel '{name}' not found", file=sys.stderr)
        return False

    if save_sources(config):
        log_change('REMOVE', 'youtube', name)
        print(f"✓ Removed YouTube channel: {name}")
        return True
    return False

def list_sources():
    """List all configured data sources"""
    config = load_sources()

    print("\n═══════════════════════════════════════════════════════")
    print("AI DASHBOARD DATA SOURCES")
    print("═══════════════════════════════════════════════════════\n")

    if 'sources' not in config:
        print("No sources configured")
        return

    sources = config['sources']

    # RSS Feeds
    if 'rss' in sources and sources['rss']:
        print("RSS FEEDS:")
        for feed in sources['rss']:
            status = "✓" if feed.get('enabled', True) else "✗"
            print(f"  {status} {feed['name']}")
            print(f"     URL: {feed['url']}")
        print()

    # GitHub Repos
    if 'github' in sources and sources['github']:
        print("GITHUB REPOS:")
        for repo in sources['github']:
            status = "✓" if repo.get('enabled', True) else "✗"
            print(f"  {status} {repo['name']}")
            print(f"     Repo: {repo['repo']}")
        print()

    # Reddit Subreddits
    if 'reddit' in sources and sources['reddit']:
        print("REDDIT SUBREDDITS:")
        for sub in sources['reddit']:
            status = "✓" if sub.get('enabled', True) else "✗"
            print(f"  {status} {sub['name']}")
            print(f"     r/{sub['subreddit']}")
        print()

    # YouTube Channels
    if 'youtube' in sources and sources['youtube']:
        print("YOUTUBE CHANNELS:")
        for channel in sources['youtube']:
            status = "✓" if channel.get('enabled', True) else "✗"
            print(f"  {status} {channel['name']}")
            print(f"     ID: {channel['channel_id']}")
        print()

def trigger_rebuild():
    """Trigger dashboard rebuild via GitHub Actions workflow_dispatch"""
    print("\n→ Triggering dashboard rebuild via GitHub Actions...")

    try:
        # Check if running in a repository context
        result = subprocess.run(
            ['git', 'remote', 'get-url', 'origin'],
            capture_output=True,
            text=True,
            timeout=5,
            cwd=PROJECT_ROOT
        )

        if result.returncode != 0:
            print("  Note: Not in a git repository, skipping workflow trigger")
            return True

        # Trigger workflow via gh CLI
        result = subprocess.run(
            ['gh', 'workflow', 'run', 'update-dashboard.yml',
             '--repo', 'Seven-Fortunas/dashboards'],
            capture_output=True,
            text=True,
            timeout=10
        )

        if result.returncode == 0:
            print("✓ Dashboard rebuild triggered successfully")
            print("  View status: gh run list --repo Seven-Fortunas/dashboards --workflow update-dashboard.yml --limit 1")
            return True
        else:
            # Not a fatal error - configuration was still updated
            print(f"⚠ Warning: Could not trigger rebuild: {result.stderr}")
            print("  Dashboard configuration updated successfully")
            print("  Rebuild will occur on next scheduled run or manual trigger")
            return True
    except Exception as e:
        print(f"⚠ Warning: Error triggering rebuild: {e}")
        print("  Dashboard configuration updated successfully")
        return True

def main():
    parser = argparse.ArgumentParser(
        description="Dashboard Curator CLI - Manage AI Dashboard Data Sources",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Add RSS feed
  python3 scripts/dashboard_curator_cli.py add-rss "AI Weekly" "https://example.com/feed.xml"

  # Remove RSS feed
  python3 scripts/dashboard_curator_cli.py remove-rss "AI Weekly"

  # Add Reddit subreddit
  python3 scripts/dashboard_curator_cli.py add-reddit "r/LocalLLaMA" "LocalLLaMA"

  # Add YouTube channel
  python3 scripts/dashboard_curator_cli.py add-youtube "AI Explained" "UCbfYPyITQ-7l4upoX8nvctg"

  # List all sources
  python3 scripts/dashboard_curator_cli.py list

  # Trigger rebuild
  python3 scripts/dashboard_curator_cli.py rebuild
        """
    )

    subparsers = parser.add_subparsers(dest='command', help='Command to execute')

    # Add RSS
    add_rss_parser = subparsers.add_parser('add-rss', help='Add RSS feed')
    add_rss_parser.add_argument('name', help='Display name for the feed')
    add_rss_parser.add_argument('url', help='RSS feed URL')
    add_rss_parser.add_argument('--no-rebuild', action='store_true', help='Skip dashboard rebuild')

    # Remove RSS
    remove_rss_parser = subparsers.add_parser('remove-rss', help='Remove RSS feed')
    remove_rss_parser.add_argument('name', help='Name of the feed to remove')
    remove_rss_parser.add_argument('--no-rebuild', action='store_true', help='Skip dashboard rebuild')

    # Add Reddit
    add_reddit_parser = subparsers.add_parser('add-reddit', help='Add Reddit subreddit')
    add_reddit_parser.add_argument('name', help='Display name for the subreddit')
    add_reddit_parser.add_argument('subreddit', help='Subreddit name (without r/)')
    add_reddit_parser.add_argument('--no-rebuild', action='store_true', help='Skip dashboard rebuild')

    # Remove Reddit
    remove_reddit_parser = subparsers.add_parser('remove-reddit', help='Remove Reddit subreddit')
    remove_reddit_parser.add_argument('name', help='Name of the subreddit to remove')
    remove_reddit_parser.add_argument('--no-rebuild', action='store_true', help='Skip dashboard rebuild')

    # Add YouTube
    add_youtube_parser = subparsers.add_parser('add-youtube', help='Add YouTube channel')
    add_youtube_parser.add_argument('name', help='Display name for the channel')
    add_youtube_parser.add_argument('channel_id', help='YouTube channel ID (24 chars, starts with UC)')
    add_youtube_parser.add_argument('--no-rebuild', action='store_true', help='Skip dashboard rebuild')

    # Remove YouTube
    remove_youtube_parser = subparsers.add_parser('remove-youtube', help='Remove YouTube channel')
    remove_youtube_parser.add_argument('name', help='Name of the channel to remove')
    remove_youtube_parser.add_argument('--no-rebuild', action='store_true', help='Skip dashboard rebuild')

    # List sources
    list_parser = subparsers.add_parser('list', help='List all data sources')

    # Rebuild
    rebuild_parser = subparsers.add_parser('rebuild', help='Trigger dashboard rebuild')

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    success = False

    if args.command == 'add-rss':
        success = add_rss(args.name, args.url)
        if success and not args.no_rebuild:
            trigger_rebuild()

    elif args.command == 'remove-rss':
        success = remove_rss(args.name)
        if success and not args.no_rebuild:
            trigger_rebuild()

    elif args.command == 'add-reddit':
        success = add_reddit(args.name, args.subreddit)
        if success and not args.no_rebuild:
            trigger_rebuild()

    elif args.command == 'remove-reddit':
        success = remove_reddit(args.name)
        if success and not args.no_rebuild:
            trigger_rebuild()

    elif args.command == 'add-youtube':
        success = add_youtube(args.name, args.channel_id)
        if success and not args.no_rebuild:
            trigger_rebuild()

    elif args.command == 'remove-youtube':
        success = remove_youtube(args.name)
        if success and not args.no_rebuild:
            trigger_rebuild()

    elif args.command == 'list':
        list_sources()
        success = True

    elif args.command == 'rebuild':
        success = trigger_rebuild()

    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
