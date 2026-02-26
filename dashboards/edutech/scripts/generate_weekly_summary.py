#!/usr/bin/env python3
"""
Generate EduTech-powered weekly summary from dashboard data
Uses Claude API to analyze and summarize EduTech trends

Usage:
    python generate_weekly_summary.py --output-dir dashboards/edutech/weekly-summaries
"""

import json
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path
import argparse

try:
    from anthropic import Anthropic
except ImportError:
    print("Error: anthropic package not installed")
    print("Install with: pip install anthropic")
    sys.exit(1)


def load_latest_updates(data_dir: Path) -> dict:
    """Load the latest dashboard data"""
    cached_file = data_dir / "cached_updates.json"

    if not cached_file.exists():
        print(f"Error: {cached_file} not found")
        sys.exit(1)

    with open(cached_file, 'r') as f:
        return json.load(f)


def get_week_number() -> tuple:
    """Get current ISO week number and year"""
    now = datetime.utcnow()
    iso_calendar = now.isocalendar()
    return iso_calendar[0], iso_calendar[1]  # year, week


def get_week_date_range() -> tuple:
    """Get Monday-Sunday date range for current week"""
    now = datetime.utcnow()
    # Get Monday of current week
    monday = now - timedelta(days=now.weekday())
    # Get Sunday
    sunday = monday + timedelta(days=6)

    return monday.strftime("%B %d"), sunday.strftime("%B %d, %Y")


def filter_updates_by_week(updates: list) -> list:
    """Filter updates from the last 7 days"""
    one_week_ago = datetime.utcnow() - timedelta(days=7)

    recent_updates = []
    for update in updates:
        try:
            # Parse the published date
            published = update.get('published', '')
            if not published:
                continue

            # Handle multiple date formats
            for fmt in ["%a, %d %b %Y %H:%M:%S %Z", "%Y-%m-%d"]:
                try:
                    pub_date = datetime.strptime(published, fmt)
                    break
                except ValueError:
                    continue
            else:
                # If no format matches, skip
                continue

            if pub_date >= one_week_ago:
                recent_updates.append(update)
        except Exception as e:
            # Skip updates with unparseable dates
            continue

    return recent_updates


def generate_summary_with_claude(updates: list, api_key: str) -> str:
    """Generate summary using Claude API"""
    client = Anthropic(api_key=api_key)

    # Prepare context from updates
    updates_text = "\n\n".join([
        f"**{update['source']}** - {update['title']}\n"
        f"Link: {update['link']}\n"
        f"Published: {update['published']}\n"
        f"Summary: {update.get('summary', 'No summary available')}"
        for update in updates[:30]  # Limit to 30 updates to stay within token limits
    ])

    prompt = f"""You are analyzing recent EduTech trends and developments for an enterprise team with Peru market focus.
Generate a concise weekly summary highlighting the most significant developments.

Focus on:
- Educational technology innovations
- Learning management systems (Moodle, OpenEdX, etc.)
- Digital inclusion and accessibility
- EdTech regulations and policy changes
- Platform updates and new features for education

Here are this week's updates:

{updates_text}

Generate a structured summary with:
1. **Executive Summary** (2-3 sentences)
2. **Key Highlights** (3-5 bullet points)
3. **Notable Releases** (list major releases)
4. **Enterprise Impact** (what matters for educational digital transformation)
5. **Looking Ahead** (trends to watch)

Keep it concise, technical, and actionable. Use markdown formatting.
"""

    message = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=2048,
        messages=[
            {"role": "user", "content": prompt}
        ]
    )

    return message.content[0].text


def save_summary(summary: str, output_dir: Path, year: int, week: int):
    """Save summary to markdown file"""
    output_dir.mkdir(parents=True, exist_ok=True)

    output_file = output_dir / f"{year}-W{week:02d}.md"

    # Add header with metadata
    monday, sunday = get_week_date_range()
    header = f"""# Weekly EduTech Summary - Week {week}, {year}

**Period:** {monday} - {sunday}
**Generated:** {datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")}

---

"""

    full_content = header + summary

    with open(output_file, 'w') as f:
        f.write(full_content)

    print(f"✅ Summary saved: {output_file}")
    return output_file


def update_readme_with_summary(dashboard_dir: Path, summary_file: Path, year: int, week: int):
    """Update README.md with link to latest summary"""
    readme_file = dashboard_dir / "README.md"

    if not readme_file.exists():
        print("Warning: README.md not found, skipping update")
        return

    # Read current README
    with open(readme_file, 'r') as f:
        content = f.read()

    # Check if there's already a Weekly Summary section
    summary_section = f"\n\n## Latest Weekly Summary\n\n**Week {week}, {year}:** [View Summary](weekly-summaries/{year}-W{week:02d}.md)\n\n"

    if "## Latest Weekly Summary" in content:
        # Replace existing section
        import re
        pattern = r"## Latest Weekly Summary\n\n.*?\n\n"
        content = re.sub(pattern, summary_section.lstrip(), content, flags=re.DOTALL)
    else:
        # Add section after first header
        lines = content.split('\n')
        insert_pos = 0
        for i, line in enumerate(lines):
            if line.startswith('##'):
                insert_pos = i
                break

        if insert_pos > 0:
            lines.insert(insert_pos, summary_section.strip())
            content = '\n'.join(lines)
        else:
            content += summary_section

    # Write updated README
    with open(readme_file, 'w') as f:
        f.write(content)

    print(f"✅ README.md updated with link to latest summary")


def main():
    parser = argparse.ArgumentParser(description="Generate EduTech weekly summary")
    parser.add_argument("--output-dir", type=str, required=True,
                        help="Output directory for summaries")
    parser.add_argument("--data-dir", type=str, default="dashboards/edutech/data",
                        help="Data directory with cached_updates.json")

    args = parser.parse_args()

    # Get API key from environment
    api_key = os.environ.get('ANTHROPIC_API_KEY')
    if not api_key:
        print("Error: ANTHROPIC_API_KEY environment variable not set")
        sys.exit(1)

    # Set up paths
    data_dir = Path(args.data_dir)
    output_dir = Path(args.output_dir)
    dashboard_dir = data_dir.parent  # dashboards/edutech/

    print("🤖 Generating EduTech Weekly Summary")
    print("=" * 50)

    # Load updates
    print("📥 Loading dashboard data...")
    data = load_latest_updates(data_dir)
    updates = data.get('updates', [])
    print(f"   Loaded {len(updates)} total updates")

    # Filter to this week
    recent_updates = filter_updates_by_week(updates)
    print(f"   {len(recent_updates)} updates from last 7 days")

    if len(recent_updates) == 0:
        print("⚠️  No recent updates found. Generating summary from all cached data...")
        recent_updates = updates[:20]  # Use most recent 20

    # Generate summary
    print("\n🧠 Generating summary with Claude API...")
    try:
        summary = generate_summary_with_claude(recent_updates, api_key)
        print("   ✅ Summary generated successfully")
    except Exception as e:
        print(f"   ❌ Error generating summary: {e}")
        sys.exit(1)

    # Get week info
    year, week = get_week_number()

    # Save summary
    print(f"\n💾 Saving summary (Week {week}, {year})...")
    summary_file = save_summary(summary, output_dir, year, week)

    # Update README
    print("\n📝 Updating README.md...")
    update_readme_with_summary(dashboard_dir, summary_file, year, week)

    print("\n✅ Weekly summary generation complete!")
    print(f"   File: {summary_file}")
    print("=" * 50)


if __name__ == "__main__":
    main()
