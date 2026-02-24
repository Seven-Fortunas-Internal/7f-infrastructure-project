#!/usr/bin/env python3
"""
AI Advancements Dashboard Updater
Updates dashboard with latest AI news from multiple sources with graceful degradation
"""

import json
import os
import sys
from datetime import datetime, timedelta
from typing import Dict, List, Any
import yaml
import feedparser
import requests
from pathlib import Path

# Optional imports with fallback
try:
    import praw
    REDDIT_AVAILABLE = True
except ImportError:
    REDDIT_AVAILABLE = False

class DashboardUpdater:
    def __init__(self, config_path: str = "dashboards/ai/sources.yaml"):
        with open(config_path, 'r') as f:
            self.config = yaml.safe_load(f)

        self.cache_dir = Path(self.config['cache']['directory'])
        self.cache_dir.mkdir(parents=True, exist_ok=True)

        self.cache_file = self.cache_dir / self.config['cache']['filename']
        self.metadata_file = self.cache_dir / self.config['cache']['metadata_filename']

        self.updates = []
        self.failures = []
        self.source_count = 0
        self.failure_count = 0

    def fetch_rss_feeds(self) -> List[Dict[str, Any]]:
        """Fetch updates from RSS feeds"""
        updates = []
        for source in self.config['sources']['rss']:
            if not source['enabled']:
                continue

            self.source_count += 1
            try:
                feed = feedparser.parse(source['url'])
                if feed.bozo:  # Feed parsing error
                    raise Exception(f"Feed parsing error: {feed.bozo_exception}")

                for entry in feed.entries[:5]:  # Latest 5 entries
                    updates.append({
                        'source': source['name'],
                        'type': 'rss',
                        'title': entry.title,
                        'link': entry.link,
                        'published': entry.get('published', 'N/A'),
                        'summary': entry.get('summary', '')[:200]
                    })
            except Exception as e:
                self.failures.append({'source': source['name'], 'error': str(e)})
                self.failure_count += 1

        return updates

    def fetch_github_releases(self) -> List[Dict[str, Any]]:
        """Fetch latest GitHub releases"""
        updates = []
        token = os.environ.get('GITHUB_TOKEN')
        headers = {'Authorization': f'token {token}'} if token else {}

        for source in self.config['sources']['github']:
            if not source['enabled']:
                continue

            self.source_count += 1
            try:
                url = f"https://api.github.com/repos/{source['repo']}/releases/latest"
                response = requests.get(url, headers=headers, timeout=source['timeout'])
                response.raise_for_status()

                release = response.json()
                updates.append({
                    'source': source['name'],
                    'type': 'github',
                    'title': f"Release {release['tag_name']}",
                    'link': release['html_url'],
                    'published': release['published_at'],
                    'summary': release.get('body', '')[:200]
                })
            except Exception as e:
                self.failures.append({'source': source['name'], 'error': str(e)})
                self.failure_count += 1

        return updates

    def fetch_reddit_posts(self) -> List[Dict[str, Any]]:
        """Fetch top Reddit posts"""
        if not REDDIT_AVAILABLE:
            print("Reddit API not available (praw not installed)")
            return []

        updates = []

        try:
            reddit = praw.Reddit(
                client_id=os.environ.get('REDDIT_CLIENT_ID'),
                client_secret=os.environ.get('REDDIT_CLIENT_SECRET'),
                user_agent=os.environ.get('REDDIT_USER_AGENT', 'AI-Dashboard/1.0')
            )

            for source in self.config['sources']['reddit']:
                if not source['enabled']:
                    continue

                self.source_count += 1
                try:
                    subreddit = reddit.subreddit(source['subreddit'])
                    for post in subreddit.top(time_filter='day', limit=source['limit']):
                        updates.append({
                            'source': f"r/{source['subreddit']}",
                            'type': 'reddit',
                            'title': post.title,
                            'link': f"https://reddit.com{post.permalink}",
                            'published': datetime.fromtimestamp(post.created_utc).isoformat(),
                            'summary': post.selftext[:200] if post.selftext else ''
                        })
                except Exception as e:
                    self.failures.append({'source': source['subreddit'], 'error': str(e)})
                    self.failure_count += 1
        except Exception as e:
            print(f"Reddit authentication failed: {e}")

        return updates

    def fetch_youtube_videos(self) -> List[Dict[str, Any]]:
        """Fetch latest YouTube videos (using RSS feeds, no API key required)"""
        updates = []

        for source in self.config['sources']['youtube']:
            if not source['enabled']:
                continue

            self.source_count += 1
            try:
                # YouTube RSS feed URL
                url = f"https://www.youtube.com/feeds/videos.xml?channel_id={source['channel_id']}"
                feed = feedparser.parse(url)

                if feed.bozo:
                    raise Exception(f"Feed parsing error: {feed.bozo_exception}")

                for entry in feed.entries[:source['limit']]:
                    updates.append({
                        'source': source['name'],
                        'type': 'youtube',
                        'title': entry.title,
                        'link': entry.link,
                        'published': entry.get('published', 'N/A'),
                        'summary': entry.get('summary', '')[:200]
                    })
            except Exception as e:
                self.failures.append({'source': source['name'], 'error': str(e)})
                self.failure_count += 1

        return updates

    def fetch_x_posts(self) -> List[Dict[str, Any]]:
        """Fetch X (Twitter) posts - optional $100/month"""
        updates = []
        api_key = os.environ.get('X_API_KEY')

        if not api_key:
            print("X API key not configured (optional)")
            return updates

        # X API v2 implementation would go here
        # Skipping for MVP since it's optional

        return updates

    def load_cached_data(self) -> Dict[str, Any]:
        """Load cached data if available"""
        try:
            if self.cache_file.exists():
                with open(self.cache_file, 'r') as f:
                    return json.load(f)
        except Exception as e:
            print(f"Failed to load cached data: {e}")

        return {'updates': [], 'timestamp': None}

    def save_cached_data(self):
        """Save current data to cache"""
        cache_data = {
            'updates': self.updates,
            'timestamp': datetime.utcnow().isoformat(),
            'failures': self.failures,
            'failure_count': self.failure_count,
            'source_count': self.source_count
        }

        with open(self.cache_file, 'w') as f:
            json.dump(cache_data, f, indent=2)

        metadata = {
            'last_successful_update': datetime.utcnow().isoformat(),
            'consecutive_failures': 0 if self.updates else 1
        }

        with open(self.metadata_file, 'w') as f:
            json.dump(metadata, f, indent=2)

    def check_degradation_level(self) -> str:
        """Determine degradation level based on failure rate"""
        if self.source_count == 0:
            return 'total_failure'

        failure_rate = self.failure_count / self.source_count
        warning_threshold = self.config['degradation']['warning_threshold']

        if failure_rate >= 1.0:
            return 'total_failure'
        elif failure_rate >= warning_threshold:
            return 'partial_failure'
        elif failure_rate > 0:
            return 'minor_failure'
        else:
            return 'healthy'

    def generate_dashboard(self):
        """Generate README.md dashboard"""
        degradation_level = self.check_degradation_level()

        # Use cached data if total failure
        if degradation_level == 'total_failure':
            cached = self.load_cached_data()
            if cached['updates']:
                self.updates = cached['updates']
                cache_age = datetime.utcnow() - datetime.fromisoformat(cached['timestamp'])
                if cache_age < timedelta(hours=self.config['degradation']['cache_max_age_hours']):
                    degradation_level = 'using_cache'

        # Sort by published date (most recent first)
        self.updates.sort(key=lambda x: x.get('published', ''), reverse=True)

        # Generate markdown
        readme_path = Path("dashboards/ai/README.md")
        with open(readme_path, 'w') as f:
            f.write("# AI Advancements Dashboard\n\n")
            f.write(f"**Last Updated:** {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}\n\n")

            # Status banner
            if degradation_level == 'total_failure':
                f.write("⚠️ **WARNING:** All data sources failed. No cached data available.\n\n")
            elif degradation_level == 'using_cache':
                f.write("⚠️ **WARNING:** All data sources failed. Displaying cached data.\n\n")
            elif degradation_level == 'partial_failure':
                f.write(f"⚠️ **WARNING:** {self.failure_count}/{self.source_count} data sources failed.\n\n")
            elif degradation_level == 'minor_failure':
                f.write(f"ℹ️ **INFO:** {self.failure_count}/{self.source_count} data sources failed.\n\n")

            # Updates table
            if self.updates:
                f.write("## Latest Updates\n\n")
                f.write("| Source | Title | Published |\n")
                f.write("|--------|-------|----------|\n")

                for update in self.updates[:50]:  # Top 50
                    source = update['source']
                    title = update['title'].replace('|', '\\|')[:80]
                    link = update['link']
                    published = update.get('published', 'N/A')[:10]

                    f.write(f"| {source} | [{title}]({link}) | {published} |\n")
            else:
                f.write("No updates available.\n\n")

            # Failure details
            if self.failures:
                f.write("\n## Failed Sources\n\n")
                for failure in self.failures:
                    f.write(f"- **{failure['source']}:** {failure['error']}\n")

        print(f"Dashboard generated: {readme_path}")
        print(f"Status: {degradation_level}")
        print(f"Updates: {len(self.updates)}")
        print(f"Failures: {self.failure_count}/{self.source_count}")

    def run(self):
        """Main execution flow"""
        print("Starting AI Advancements Dashboard update...")

        # Fetch from all sources
        self.updates.extend(self.fetch_rss_feeds())
        self.updates.extend(self.fetch_github_releases())
        self.updates.extend(self.fetch_reddit_posts())
        self.updates.extend(self.fetch_youtube_videos())
        self.updates.extend(self.fetch_x_posts())

        # Save cache
        self.save_cached_data()

        # Generate dashboard
        self.generate_dashboard()

        print("Dashboard update complete!")

if __name__ == '__main__':
    updater = DashboardUpdater()
    updater.run()
