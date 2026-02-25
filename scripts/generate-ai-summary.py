#!/usr/bin/env python3
"""
Generate AI-powered weekly summary of AI advancements.
Uses Claude API to analyze data from dashboards/ai/data/latest.json
"""

import json
import os
from datetime import datetime
from pathlib import Path

try:
    from anthropic import Anthropic
except ImportError:
    print("ERROR: anthropic library not installed. Run: pip install anthropic")
    exit(1)


def load_latest_data():
    """Load the latest AI advancements data"""
    data_file = Path("outputs/dashboards/ai/data/latest.json")

    if not data_file.exists():
        print(f"WARNING: {data_file} not found, using empty data")
        return {"items": []}

    with open(data_file, 'r') as f:
        return json.load(f)


def generate_summary(data, api_key):
    """Generate summary using Claude API"""
    client = Anthropic(api_key=api_key)

    # Prepare context from data
    items = data.get("items", [])
    items_text = "\n".join([
        f"- {item.get('title', 'Untitled')}: {item.get('summary', 'No summary')}"
        for item in items[:20]  # Limit to 20 items
    ])

    prompt = f"""You are analyzing recent AI advancements for a weekly summary.

Here are the latest items from AI news sources, research papers, and GitHub releases:

{items_text if items_text else "No new items this week."}

Please generate a concise weekly summary (200-300 words) that:
1. Highlights the 3-5 most significant developments
2. Identifies emerging trends or themes
3. Focuses on practical implications for AI practitioners
4. Uses clear, professional language

Keep the tone informative but engaging."""

    message = client.messages.create(
        model="claude-3-5-sonnet-20241022",
        max_tokens=1024,
        messages=[
            {"role": "user", "content": prompt}
        ]
    )

    return message.content[0].text


def save_summary(summary_text):
    """Save summary to file and update README"""
    today = datetime.utcnow().strftime("%Y-%m-%d")
    summary_file = Path(f"outputs/dashboards/ai/summaries/{today}.md")

    # Ensure directory exists
    summary_file.parent.mkdir(parents=True, exist_ok=True)

    # Write summary file
    with open(summary_file, 'w') as f:
        f.write(f"# AI Weekly Summary - {today}\n\n")
        f.write(f"*Generated automatically by Claude API*\n\n")
        f.write(summary_text)
        f.write(f"\n\n---\n*Last updated: {datetime.utcnow().isoformat()}Z*\n")

    print(f"Summary saved to: {summary_file}")

    # Update README.md
    readme_file = Path("outputs/dashboards/ai/README.md")
    if readme_file.exists():
        with open(readme_file, 'r') as f:
            readme_content = f.read()

        # Insert latest summary at top of Latest Summaries section
        summary_link = f"- [{today}](summaries/{today}.md)"

        if "## Latest Summaries" in readme_content:
            # Find the section and insert new link
            lines = readme_content.split('\n')
            new_lines = []
            inserted = False

            for line in lines:
                new_lines.append(line)
                if line.startswith("## Latest Summaries") and not inserted:
                    # Skip next blank line if exists
                    new_lines.append("")
                    new_lines.append(summary_link)
                    inserted = True

            with open(readme_file, 'w') as f:
                f.write('\n'.join(new_lines))
        else:
            # Add new section
            with open(readme_file, 'a') as f:
                f.write(f"\n\n## Latest Summaries\n\n{summary_link}\n")

        print(f"README updated: {readme_file}")


def main():
    """Main execution"""
    # Get API key from environment
    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key:
        print("ERROR: ANTHROPIC_API_KEY environment variable not set")
        print("Please add it to GitHub Secrets and ensure it's passed to this script")
        exit(1)

    print("Loading latest AI advancements data...")
    data = load_latest_data()

    print(f"Loaded {len(data.get('items', []))} items")

    print("Generating AI summary using Claude API...")
    summary = generate_summary(data, api_key)

    print("\n=== Generated Summary ===")
    print(summary)
    print("=" * 50)

    print("\nSaving summary...")
    save_summary(summary)

    print("\n✓ AI weekly summary generation complete!")


if __name__ == "__main__":
    main()
