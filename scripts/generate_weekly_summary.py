#!/usr/bin/env python3
"""
Weekly AI Summary Generator
Generates AI-powered weekly summaries using Claude API
"""

import json
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path
from anthropic import Anthropic

class WeeklySummaryGenerator:
    def __init__(self):
        self.api_key = os.environ.get('ANTHROPIC_API_KEY')
        if not self.api_key:
            raise ValueError("ANTHROPIC_API_KEY environment variable not set")

        self.client = Anthropic(api_key=self.api_key)
        self.cache_file = Path("dashboards/ai/data/cached_updates.json")
        self.summaries_dir = Path("dashboards/ai/summaries")
        self.summaries_dir.mkdir(parents=True, exist_ok=True)

        # Get date range for this week
        today = datetime.utcnow()
        self.week_end = today
        self.week_start = today - timedelta(days=7)
        self.summary_date = today.strftime('%Y-%m-%d')

    def load_weekly_data(self):
        """Load data from the past week"""
        if not self.cache_file.exists():
            print("No cached data found")
            return []

        with open(self.cache_file, 'r') as f:
            data = json.load(f)

        updates = data.get('updates', [])
        print(f"Loaded {len(updates)} updates from cache")
        return updates

    def create_claude_prompt(self, updates):
        """Create prompt for Claude API"""
        updates_text = "\n\n".join([
            f"**{update['source']}** ({update['type']})\n"
            f"Title: {update['title']}\n"
            f"Link: {update['link']}\n"
            f"Published: {update['published']}\n"
            f"Summary: {update.get('summary', 'N/A')}"
            for update in updates[:50]  # Limit to 50 most recent
        ])

        prompt = f"""You are an AI research analyst tasked with creating a weekly summary of AI advancements.

Here are the latest AI updates from the past week:

{updates_text}

Please create a concise weekly summary with the following structure:

# AI Advancements Weekly Summary - {self.summary_date}

## Key Highlights
[2-3 bullet points of the most significant developments]

## Major Releases
[List of important library/framework releases with brief descriptions]

## Research & Papers
[Notable research papers or blog posts]

## Industry News
[Significant industry announcements or trends]

## Looking Ahead
[1-2 sentences about potential implications or upcoming events]

Keep the summary concise (300-500 words), focus on the most impactful developments, and write for a technical audience (VP AI-SecOps).
"""
        return prompt

    def generate_summary(self, updates):
        """Generate summary using Claude API"""
        if not updates:
            print("No updates to summarize")
            return None

        prompt = self.create_claude_prompt(updates)

        print("Generating summary with Claude API...")
        try:
            message = self.client.messages.create(
                model="claude-sonnet-4-20250514",
                max_tokens=2000,
                temperature=0.7,
                messages=[
                    {"role": "user", "content": prompt}
                ]
            )

            summary = message.content[0].text
            print(f"Summary generated ({len(summary)} characters)")

            # Track API usage
            usage = {
                'input_tokens': message.usage.input_tokens,
                'output_tokens': message.usage.output_tokens,
                'timestamp': datetime.utcnow().isoformat()
            }
            print(f"API usage: {usage['input_tokens']} input tokens, {usage['output_tokens']} output tokens")

            return summary

        except Exception as e:
            print(f"Error generating summary: {e}")
            return None

    def save_summary(self, summary):
        """Save summary to file"""
        if not summary:
            return None

        summary_file = self.summaries_dir / f"{self.summary_date}.md"
        with open(summary_file, 'w') as f:
            f.write(summary)

        print(f"Summary saved to {summary_file}")
        return summary_file

    def update_readme(self, summary):
        """Update README.md with latest summary"""
        if not summary:
            return

        readme_path = Path("dashboards/ai/README.md")

        # Read existing README
        with open(readme_path, 'r') as f:
            readme_content = f.read()

        # Extract just the key highlights section
        summary_lines = summary.split('\n')
        highlights_start = None
        highlights_end = None

        for i, line in enumerate(summary_lines):
            if line.strip().startswith('## Key Highlights'):
                highlights_start = i + 1
            elif highlights_start is not None and line.strip().startswith('##'):
                highlights_end = i
                break

        if highlights_start and highlights_end:
            highlights = '\n'.join(summary_lines[highlights_start:highlights_end]).strip()
        else:
            highlights = "Recent AI advancements tracked. See full summary in summaries/ directory."

        # Create summary section
        summary_section = f"""

## Latest Weekly Summary ({self.summary_date})

{highlights}

[Read full summary →](summaries/{self.summary_date}.md)

---

"""

        # Insert or update summary section in README
        if "## Latest Weekly Summary" in readme_content:
            # Replace existing summary
            lines = readme_content.split('\n')
            new_lines = []
            skip = False

            for line in lines:
                if line.startswith("## Latest Weekly Summary"):
                    skip = True
                    continue
                elif skip and line.startswith("---"):
                    skip = False
                    continue
                elif not skip:
                    new_lines.append(line)

            # Insert new summary after "Last Updated" section
            for i, line in enumerate(new_lines):
                if line.startswith("**Last Updated:**"):
                    new_lines.insert(i + 1, summary_section)
                    break

            readme_content = '\n'.join(new_lines)
        else:
            # Add summary section after "Last Updated"
            lines = readme_content.split('\n')
            for i, line in enumerate(lines):
                if line.startswith("**Last Updated:**"):
                    lines.insert(i + 1, summary_section)
                    break
            readme_content = '\n'.join(lines)

        # Save updated README
        with open(readme_path, 'w') as f:
            f.write(readme_content)

        print(f"README.md updated with summary")

    def run(self):
        """Main execution flow"""
        print(f"Starting weekly summary generation for {self.summary_date}...")

        # Load data
        updates = self.load_weekly_data()

        # Generate summary
        summary = self.generate_summary(updates)

        if summary:
            # Save summary
            self.save_summary(summary)

            # Update README
            self.update_readme(summary)

            print("Weekly summary generation complete!")
        else:
            print("Failed to generate summary")
            sys.exit(1)

if __name__ == '__main__':
    try:
        generator = WeeklySummaryGenerator()
        generator.run()
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
