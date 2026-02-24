#!/usr/bin/env python3
"""
Dashboard Curator
Interactive tool for managing AI Advancements Dashboard data sources
"""

import json
import os
import sys
from datetime import datetime
from pathlib import Path
import yaml
import feedparser
import requests

class DashboardCurator:
    def __init__(self):
        self.sources_file = Path("dashboards/ai/sources.yaml")
        self.audit_log = Path("dashboards/ai/config/audit.log")
        self.audit_log.parent.mkdir(parents=True, exist_ok=True)

        if not self.sources_file.exists():
            print(f"Error: {self.sources_file} not found")
            sys.exit(1)

        self.load_config()

    def load_config(self):
        """Load current configuration"""
        with open(self.sources_file, 'r') as f:
            self.config = yaml.safe_load(f)

    def save_config(self):
        """Save configuration to file"""
        # Create backup
        backup_file = self.sources_file.with_suffix('.yaml.backup')
        with open(backup_file, 'w') as f:
            yaml.safe_dump(self.config, f, default_flow_style=False, sort_keys=False)

        # Save updated config
        with open(self.sources_file, 'w') as f:
            yaml.safe_dump(self.config, f, default_flow_style=False, sort_keys=False)

    def log_change(self, operation, details, user="System"):
        """Log configuration change to audit trail"""
        timestamp = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')
        log_entry = f"[{timestamp}] {operation}: {details} - User: {user}\n"

        with open(self.audit_log, 'a') as f:
            f.write(log_entry)

        print(f"Audit log entry created: {operation}")

    def validate_rss_feed(self, url):
        """Validate RSS feed URL"""
        try:
            feed = feedparser.parse(url)
            if feed.bozo:
                return False, f"Feed parsing error: {feed.bozo_exception}"

            if not feed.entries:
                return False, "No entries found in feed"

            return True, f"Valid feed ({len(feed.entries)} entries found)"
        except Exception as e:
            return False, str(e)

    def validate_reddit_subreddit(self, subreddit):
        """Validate Reddit subreddit exists"""
        try:
            url = f"https://www.reddit.com/r/{subreddit}/about.json"
            headers = {'User-Agent': 'DashboardCurator/1.0'}
            response = requests.get(url, headers=headers, timeout=10)

            if response.status_code == 404:
                return False, "Subreddit not found"
            elif response.status_code != 200:
                return False, f"HTTP {response.status_code}"

            return True, "Valid subreddit"
        except Exception as e:
            return False, str(e)

    def validate_youtube_channel(self, channel_id):
        """Validate YouTube channel ID"""
        try:
            url = f"https://www.youtube.com/feeds/videos.xml?channel_id={channel_id}"
            feed = feedparser.parse(url)

            if feed.bozo or not feed.entries:
                return False, "Invalid channel ID or no videos found"

            return True, f"Valid channel ({len(feed.entries)} videos found)"
        except Exception as e:
            return False, str(e)

    def display_summary(self):
        """Display current configuration summary"""
        print("\n=== Current Configuration ===")
        print(f"RSS Feeds: {len(self.config['sources']['rss'])} sources")
        print(f"GitHub Repos: {len(self.config['sources']['github'])} repos")
        print(f"Reddit: {len(self.config['sources']['reddit'])} subreddits")
        print(f"YouTube: {len(self.config['sources']['youtube'])} channels")
        print(f"X API: {len(self.config['sources']['x_api'])} accounts")
        print()

    def add_rss_feed(self):
        """Add new RSS feed"""
        print("\n=== Add RSS Feed ===")
        url = input("Enter RSS feed URL: ").strip()
        name = input("Enter display name: ").strip()

        if not url or not name:
            print("Error: URL and name are required")
            return

        # Check for duplicates
        for feed in self.config['sources']['rss']:
            if feed['url'] == url:
                print(f"Error: Feed already exists: {feed['name']}")
                return

        # Validate feed
        print("Validating feed...", end=" ", flush=True)
        valid, message = self.validate_rss_feed(url)

        if not valid:
            print(f"✗ Invalid feed: {message}")
            return

        print(f"✓ {message}")

        # Add to config
        new_feed = {
            'name': name,
            'url': url,
            'enabled': True,
            'timeout': 10,
            'retry_attempts': 3
        }
        self.config['sources']['rss'].append(new_feed)
        self.save_config()

        # Log change
        self.log_change("ADD_RSS_FEED", f"{name} ({url})")

        print(f"✓ RSS feed added: {name}")

    def remove_rss_feed(self):
        """Remove RSS feed"""
        print("\n=== Remove RSS Feed ===")
        print("Current RSS feeds:")
        for i, feed in enumerate(self.config['sources']['rss'], 1):
            print(f"{i}. {feed['name']} ({feed['url']})")

        choice = input("\nEnter number to remove (or 0 to cancel): ").strip()

        try:
            idx = int(choice) - 1
            if idx < 0:
                print("Cancelled")
                return
            if idx >= len(self.config['sources']['rss']):
                print("Error: Invalid choice")
                return

            removed = self.config['sources']['rss'].pop(idx)
            self.save_config()

            # Log change
            self.log_change("REMOVE_RSS_FEED", f"{removed['name']} ({removed['url']})")

            print(f"✓ RSS feed removed: {removed['name']}")
        except ValueError:
            print("Error: Invalid input")

    def add_reddit_subreddit(self):
        """Add Reddit subreddit"""
        print("\n=== Add Reddit Subreddit ===")
        subreddit = input("Enter subreddit name (without r/): ").strip()
        limit = input("Enter post limit (default: 10): ").strip() or "10"

        if not subreddit:
            print("Error: Subreddit name required")
            return

        # Check for duplicates
        for sub in self.config['sources']['reddit']:
            if sub['subreddit'] == subreddit:
                print(f"Error: Subreddit already exists: r/{subreddit}")
                return

        # Validate subreddit
        print("Validating subreddit...", end=" ", flush=True)
        valid, message = self.validate_reddit_subreddit(subreddit)

        if not valid:
            print(f"✗ Invalid subreddit: {message}")
            return

        print(f"✓ {message}")

        # Add to config
        new_sub = {
            'name': f"r/{subreddit}",
            'subreddit': subreddit,
            'enabled': True,
            'timeout': 10,
            'retry_attempts': 3,
            'limit': int(limit)
        }
        self.config['sources']['reddit'].append(new_sub)
        self.save_config()

        # Log change
        self.log_change("ADD_REDDIT", f"r/{subreddit} (limit: {limit})")

        print(f"✓ Reddit subreddit added: r/{subreddit}")

    def remove_reddit_subreddit(self):
        """Remove Reddit subreddit"""
        print("\n=== Remove Reddit Subreddit ===")
        print("Current subreddits:")
        for i, sub in enumerate(self.config['sources']['reddit'], 1):
            print(f"{i}. {sub['name']}")

        choice = input("\nEnter number to remove (or 0 to cancel): ").strip()

        try:
            idx = int(choice) - 1
            if idx < 0:
                print("Cancelled")
                return
            if idx >= len(self.config['sources']['reddit']):
                print("Error: Invalid choice")
                return

            removed = self.config['sources']['reddit'].pop(idx)
            self.save_config()

            # Log change
            self.log_change("REMOVE_REDDIT", f"{removed['name']}")

            print(f"✓ Reddit subreddit removed: {removed['name']}")
        except ValueError:
            print("Error: Invalid input")

    def add_youtube_channel(self):
        """Add YouTube channel"""
        print("\n=== Add YouTube Channel ===")
        channel_id = input("Enter YouTube channel ID: ").strip()
        name = input("Enter display name: ").strip()
        limit = input("Enter video limit (default: 5): ").strip() or "5"

        if not channel_id or not name:
            print("Error: Channel ID and name are required")
            return

        # Check for duplicates
        for channel in self.config['sources']['youtube']:
            if channel['channel_id'] == channel_id:
                print(f"Error: Channel already exists: {channel['name']}")
                return

        # Validate channel
        print("Validating channel...", end=" ", flush=True)
        valid, message = self.validate_youtube_channel(channel_id)

        if not valid:
            print(f"✗ Invalid channel: {message}")
            return

        print(f"✓ {message}")

        # Add to config
        new_channel = {
            'name': name,
            'channel_id': channel_id,
            'enabled': True,
            'timeout': 10,
            'retry_attempts': 3,
            'limit': int(limit)
        }
        self.config['sources']['youtube'].append(new_channel)
        self.save_config()

        # Log change
        self.log_change("ADD_YOUTUBE", f"{name} (channel_id: {channel_id})")

        print(f"✓ YouTube channel added: {name}")

    def view_audit_log(self):
        """Display audit log"""
        print("\n=== Audit Log ===")
        if not self.audit_log.exists():
            print("No audit log entries")
            return

        with open(self.audit_log, 'r') as f:
            entries = f.readlines()

        if not entries:
            print("No audit log entries")
            return

        # Display last 20 entries
        for entry in entries[-20:]:
            print(entry.strip())

    def trigger_rebuild(self):
        """Trigger dashboard rebuild"""
        print("\nTriggering dashboard rebuild...")
        try:
            import subprocess
            result = subprocess.run(
                ['python3', 'scripts/update_ai_dashboard.py'],
                capture_output=True,
                text=True,
                timeout=60
            )

            if result.returncode == 0:
                print("✓ Dashboard rebuild complete!")
            else:
                print(f"✗ Dashboard rebuild failed: {result.stderr}")
        except Exception as e:
            print(f"✗ Error triggering rebuild: {e}")

    def main_menu(self):
        """Display main menu and handle user input"""
        while True:
            self.display_summary()

            print("=== Dashboard Curator ===")
            print("1. Add RSS Feed")
            print("2. Remove RSS Feed")
            print("3. Add Reddit Subreddit")
            print("4. Remove Reddit Subreddit")
            print("5. Add YouTube Channel")
            print("6. View Audit Log")
            print("7. Trigger Dashboard Rebuild")
            print("8. Exit")

            choice = input("\nSelect operation: ").strip()

            if choice == '1':
                self.add_rss_feed()
            elif choice == '2':
                self.remove_rss_feed()
            elif choice == '3':
                self.add_reddit_subreddit()
            elif choice == '4':
                self.remove_reddit_subreddit()
            elif choice == '5':
                self.add_youtube_channel()
            elif choice == '6':
                self.view_audit_log()
            elif choice == '7':
                self.trigger_rebuild()
            elif choice == '8':
                print("Exiting...")
                break
            else:
                print("Invalid choice")

            input("\nPress Enter to continue...")

if __name__ == '__main__':
    try:
        curator = DashboardCurator()
        curator.main_menu()
    except KeyboardInterrupt:
        print("\nExiting...")
        sys.exit(0)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
