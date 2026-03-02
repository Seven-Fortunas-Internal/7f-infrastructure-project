#!/usr/bin/env python3
"""
Generate AI-powered weekly summary of AI advancements.
Uses Claude API (claude-3-5-haiku) to analyze data from dashboards/ai/data/cached_updates.json
Generates: 1-2 paragraphs + 10 bullet points with links
"""

import json
import os
import re
from datetime import datetime
from pathlib import Path

try:
    from anthropic import Anthropic
except ImportError:
    print("ERROR: anthropic library not installed. Run: pip install anthropic")
    exit(1)


def load_cached_data():
    """Load the cached AI advancements data written by update_dashboard.py"""
    data_file = Path("dashboards/ai/data/cached_updates.json")

    if not data_file.exists():
        print(f"WARNING: {data_file} not found, using empty data")
        return {"updates": []}

    with open(data_file, 'r') as f:
        return json.load(f)


def generate_summary(data, api_key):
    """Generate summary using Claude API (haiku model for cost efficiency)"""
    client = Anthropic(api_key=api_key)

    # Prepare context from data - take top 20 updates
    updates = data.get("updates", [])
    updates_text = "\n".join([
        f"- [{item.get('title', 'Untitled')}]({item.get('link', '#')}): {item.get('summary', 'No summary')}"
        for item in updates[:20]  # Limit to 20 items
    ])

    prompt = f"""Summarize top 10 AI developments this week into a professional weekly report.

Here are the latest AI developments:

{updates_text if updates_text else "No new items this week."}

Please generate a summary with:
1. Brief context (1-2 paragraphs) on overall AI landscape trends this week
2. Exactly 10 bullet points highlighting key developments with:
   - Model/tool/research names
   - Link to source (if available)
   - Relevance to digital inclusion and enterprise AI accessibility

Focus on: models, research, tools, regulations.
Emphasize relevance to Seven Fortunas mission (making AI accessible for digital inclusion).

Format the output with clear sections:
## Executive Summary
[1-2 paragraphs]

## Top 10 Developments
[10 numbered bullet points with links]"""

    message = client.messages.create(
        model="claude-3-5-haiku-20241022",
        max_tokens=1024,
        messages=[
            {"role": "user", "content": prompt}
        ]
    )

    return message.content[0].text


def save_summary(summary_text):
    """Save summary to file and update README, keeping last 4 weeks"""
    today = datetime.utcnow().strftime("%Y-%m-%d")
    summary_file = Path(f"dashboards/ai/summaries/{today}.md")

    # Ensure directory exists
    summary_file.parent.mkdir(parents=True, exist_ok=True)

    # Write summary file
    with open(summary_file, 'w') as f:
        f.write(f"# AI Weekly Summary - {today}\n\n")
        f.write(f"*Generated automatically by Claude API (haiku model)*\n\n")
        f.write(summary_text)
        f.write(f"\n\n---\n*Last updated: {datetime.utcnow().isoformat()}Z*\n")

    print(f"Summary saved to: {summary_file}")

    # Update README.md with last 4 weeks of summaries
    readme_file = Path("dashboards/ai/README.md")
    if readme_file.exists():
        with open(readme_file, 'r') as f:
            readme_content = f.read()

        # Insert latest summary at top of Latest Summaries section
        summary_link = f"- [{today}](summaries/{today}.md)"

        if "## Latest Summaries" in readme_content:
            # Find the section and manage 4-week rotation
            lines = readme_content.split('\n')
            new_lines = []
            in_summary_section = False
            summary_count = 0
            archived_lines = []

            for i, line in enumerate(lines):
                if line.startswith("## Latest Summaries"):
                    new_lines.append(line)
                    in_summary_section = True
                    new_lines.append("")
                    new_lines.append(summary_link)
                    summary_count += 1
                    continue

                if in_summary_section:
                    if line.startswith("## ") and not line.startswith("## Latest Summaries"):
                        # End of summaries section, start archiving if needed
                        in_summary_section = False
                        new_lines.append(line)
                    elif line.startswith("- ["):
                        summary_count += 1
                        if summary_count <= 4:  # Keep last 4 weeks
                            new_lines.append(line)
                        else:
                            archived_lines.append(line)
                    else:
                        new_lines.append(line)
                else:
                    new_lines.append(line)

            with open(readme_file, 'w') as f:
                f.write('\n'.join(new_lines))
        else:
            # Add new section
            with open(readme_file, 'a') as f:
                f.write(f"\n\n## Latest Summaries\n\n{summary_link}\n")

        print(f"README updated: {readme_file} (keeping last 4 weeks)")


def main():
    """Main execution"""
    # Get API key from environment
    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key:
        print("ERROR: ANTHROPIC_API_KEY environment variable not set")
        print("Please add ANTHROPIC_API_KEY to GitHub Secrets: https://github.com/Seven-Fortunas/dashboards/settings/secrets/actions")
        exit(1)

    print("Loading cached AI advancements data...")
    data = load_cached_data()

    print(f"Loaded {len(data.get('updates', []))} updates from dashboards/ai/data/cached_updates.json")

    print("Generating AI summary using Claude API (haiku model)...")
    summary = generate_summary(data, api_key)

    print("\n=== Generated Summary ===")
    print(summary)
    print("=" * 50)

    print("\nSaving summary...")
    save_summary(summary)

    print("\n✓ AI weekly summary generation complete!")


if __name__ == "__main__":
    main()
