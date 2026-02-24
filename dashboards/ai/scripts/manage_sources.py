#!/usr/bin/env python3
"""
AI Dashboard Data Source Manager
Manage data sources for AI Advancements Dashboard (FR-4.3)

Usage:
    python manage_sources.py add-rss --url URL --name NAME [--keywords KEYWORDS]
    python manage_sources.py remove-rss --name NAME
    python manage_sources.py add-reddit --subreddit SUBREDDIT
    python manage_sources.py remove-reddit --subreddit SUBREDDIT
    python manage_sources.py add-youtube --channel CHANNEL_ID --name NAME
    python manage_sources.py set-frequency --hours HOURS
    python manage_sources.py list
"""

import argparse
import sys
import yaml
from pathlib import Path
from datetime import datetime
import requests

SOURCES_FILE = Path(__file__).parent.parent / "sources.yaml"
AUDIT_LOG = Path(__file__).parent.parent / "config" / "source_changes.log"


def load_sources():
    """Load sources.yaml"""
    if not SOURCES_FILE.exists():
        print(f"Error: {SOURCES_FILE} not found")
        sys.exit(1)

    with open(SOURCES_FILE, 'r') as f:
        return yaml.safe_load(f)


def save_sources(data):
    """Save sources.yaml"""
    with open(SOURCES_FILE, 'w') as f:
        yaml.dump(data, f, default_flow_style=False, sort_keys=False)


def log_change(action, details):
    """Log configuration change to audit trail"""
    AUDIT_LOG.parent.mkdir(exist_ok=True)

    timestamp = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")
    log_entry = f"{timestamp} | {action} | {details}\n"

    with open(AUDIT_LOG, 'a') as f:
        f.write(log_entry)


def validate_url(url):
    """Validate URL by attempting to fetch it"""
    try:
        response = requests.head(url, timeout=10, allow_redirects=True)
        return response.status_code < 400
    except Exception as e:
        print(f"Warning: Could not validate URL: {e}")
        return False


def add_rss(args):
    """Add RSS feed"""
    sources = load_sources()

    # Validate URL
    if not validate_url(args.url):
        response = input(f"URL validation failed for {args.url}. Add anyway? (y/N): ")
        if response.lower() != 'y':
            print("Operation cancelled")
            return

    # Check for duplicates
    if 'rss' not in sources['sources']:
        sources['sources']['rss'] = []

    for feed in sources['sources']['rss']:
        if feed['name'] == args.name:
            print(f"Error: RSS feed '{args.name}' already exists")
            sys.exit(1)

    # Add new feed
    new_feed = {
        'name': args.name,
        'url': args.url,
        'enabled': True,
        'timeout': 10,
        'retry_attempts': 3
    }

    if args.keywords:
        new_feed['keywords'] = args.keywords.split(',')

    sources['sources']['rss'].append(new_feed)
    save_sources(sources)

    log_change("ADD_RSS", f"name={args.name}, url={args.url}")

    print(f"✅ Added RSS feed: {args.name}")
    print(f"   URL: {args.url}")
    if args.keywords:
        print(f"   Keywords: {args.keywords}")


def remove_rss(args):
    """Remove RSS feed"""
    sources = load_sources()

    if 'rss' not in sources['sources']:
        print("No RSS feeds configured")
        return

    original_count = len(sources['sources']['rss'])
    sources['sources']['rss'] = [
        feed for feed in sources['sources']['rss']
        if feed['name'] != args.name
    ]

    if len(sources['sources']['rss']) == original_count:
        print(f"Error: RSS feed '{args.name}' not found")
        sys.exit(1)

    save_sources(sources)
    log_change("REMOVE_RSS", f"name={args.name}")

    print(f"✅ Removed RSS feed: {args.name}")


def add_reddit(args):
    """Add Reddit subreddit"""
    sources = load_sources()

    if 'reddit' not in sources['sources']:
        sources['sources']['reddit'] = []

    # Check for duplicates
    for sub in sources['sources']['reddit']:
        if sub['subreddit'] == args.subreddit:
            print(f"Error: Reddit subreddit '{args.subreddit}' already exists")
            sys.exit(1)

    # Add new subreddit
    new_sub = {
        'subreddit': args.subreddit,
        'enabled': True,
        'timeout': 10,
        'retry_attempts': 3,
        'limit': 25  # Number of posts to fetch
    }

    sources['sources']['reddit'].append(new_sub)
    save_sources(sources)

    log_change("ADD_REDDIT", f"subreddit={args.subreddit}")

    print(f"✅ Added Reddit subreddit: r/{args.subreddit}")


def remove_reddit(args):
    """Remove Reddit subreddit"""
    sources = load_sources()

    if 'reddit' not in sources['sources']:
        print("No Reddit subreddits configured")
        return

    original_count = len(sources['sources']['reddit'])
    sources['sources']['reddit'] = [
        sub for sub in sources['sources']['reddit']
        if sub['subreddit'] != args.subreddit
    ]

    if len(sources['sources']['reddit']) == original_count:
        print(f"Error: Reddit subreddit '{args.subreddit}' not found")
        sys.exit(1)

    save_sources(sources)
    log_change("REMOVE_REDDIT", f"subreddit={args.subreddit}")

    print(f"✅ Removed Reddit subreddit: r/{args.subreddit}")


def add_youtube(args):
    """Add YouTube channel"""
    sources = load_sources()

    if 'youtube' not in sources['sources']:
        sources['sources']['youtube'] = []

    # Check for duplicates
    for channel in sources['sources']['youtube']:
        if channel['channel_id'] == args.channel:
            print(f"Error: YouTube channel '{args.name}' already exists")
            sys.exit(1)

    # Add new channel
    new_channel = {
        'name': args.name,
        'channel_id': args.channel,
        'enabled': True,
        'timeout': 10,
        'retry_attempts': 3
    }

    sources['sources']['youtube'].append(new_channel)
    save_sources(sources)

    log_change("ADD_YOUTUBE", f"name={args.name}, channel_id={args.channel}")

    print(f"✅ Added YouTube channel: {args.name}")
    print(f"   Channel ID: {args.channel}")


def set_frequency(args):
    """Set update frequency"""
    # This would update the GitHub Actions cron schedule
    # For now, just document the setting
    print(f"Update frequency: every {args.hours} hours")
    print(f"To apply: Update .github/workflows/update-ai-dashboard.yml")
    print(f"  Change cron to: '0 */{args.hours} * * *'")

    log_change("SET_FREQUENCY", f"hours={args.hours}")


def list_sources(args):
    """List all configured sources"""
    sources = load_sources()

    print("\n📊 AI Dashboard Data Sources")
    print("=" * 60)

    # RSS Feeds
    if 'rss' in sources['sources']:
        print(f"\n📰 RSS Feeds ({len(sources['sources']['rss'])} configured)")
        print("-" * 60)
        for feed in sources['sources']['rss']:
            status = "✅" if feed.get('enabled', True) else "❌"
            print(f"  {status} {feed['name']}")
            print(f"     URL: {feed['url']}")
            if 'keywords' in feed:
                print(f"     Keywords: {', '.join(feed['keywords'])}")

    # GitHub Releases
    if 'github' in sources['sources']:
        print(f"\n🐙 GitHub Releases ({len(sources['sources']['github'])} configured)")
        print("-" * 60)
        for repo in sources['sources']['github']:
            status = "✅" if repo.get('enabled', True) else "❌"
            print(f"  {status} {repo['name']}")
            print(f"     Repo: {repo['repo']}")

    # Reddit
    if 'reddit' in sources['sources']:
        print(f"\n🤖 Reddit Subreddits ({len(sources['sources']['reddit'])} configured)")
        print("-" * 60)
        for sub in sources['sources']['reddit']:
            status = "✅" if sub.get('enabled', True) else "❌"
            print(f"  {status} r/{sub['subreddit']}")

    # YouTube
    if 'youtube' in sources['sources']:
        print(f"\n📺 YouTube Channels ({len(sources['sources']['youtube'])} configured)")
        print("-" * 60)
        for channel in sources['sources']['youtube']:
            status = "✅" if channel.get('enabled', True) else "❌"
            print(f"  {status} {channel['name']}")
            print(f"     Channel ID: {channel['channel_id']}")

    print("\n" + "=" * 60)
    print(f"Total sources: {sum([
        len(sources['sources'].get('rss', [])),
        len(sources['sources'].get('github', [])),
        len(sources['sources'].get('reddit', [])),
        len(sources['sources'].get('youtube', []))
    ])}")
    print()


def main():
    parser = argparse.ArgumentParser(description="Manage AI dashboard data sources")
    subparsers = parser.add_subparsers(dest='command', help='Command to execute')

    # Add RSS feed
    parser_add_rss = subparsers.add_parser('add-rss', help='Add RSS feed')
    parser_add_rss.add_argument('--url', required=True, help='RSS feed URL')
    parser_add_rss.add_argument('--name', required=True, help='Feed name')
    parser_add_rss.add_argument('--keywords', help='Comma-separated keywords')

    # Remove RSS feed
    parser_remove_rss = subparsers.add_parser('remove-rss', help='Remove RSS feed')
    parser_remove_rss.add_argument('--name', required=True, help='Feed name to remove')

    # Add Reddit
    parser_add_reddit = subparsers.add_parser('add-reddit', help='Add Reddit subreddit')
    parser_add_reddit.add_argument('--subreddit', required=True, help='Subreddit name (without r/)')

    # Remove Reddit
    parser_remove_reddit = subparsers.add_parser('remove-reddit', help='Remove Reddit subreddit')
    parser_remove_reddit.add_argument('--subreddit', required=True, help='Subreddit name')

    # Add YouTube
    parser_add_youtube = subparsers.add_parser('add-youtube', help='Add YouTube channel')
    parser_add_youtube.add_argument('--channel', required=True, help='YouTube channel ID')
    parser_add_youtube.add_argument('--name', required=True, help='Channel name')

    # Set frequency
    parser_frequency = subparsers.add_parser('set-frequency', help='Set update frequency')
    parser_frequency.add_argument('--hours', type=int, required=True, help='Update every N hours')

    # List sources
    subparsers.add_parser('list', help='List all configured sources')

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    # Execute command
    commands = {
        'add-rss': add_rss,
        'remove-rss': remove_rss,
        'add-reddit': add_reddit,
        'remove-reddit': remove_reddit,
        'add-youtube': add_youtube,
        'set-frequency': set_frequency,
        'list': list_sources
    }

    commands[args.command](args)


if __name__ == "__main__":
    main()
