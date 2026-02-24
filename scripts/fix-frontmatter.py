#!/usr/bin/env python3
"""
Add missing YAML frontmatter fields to Second Brain documents
FEATURE_008: FR-2.2: Markdown + YAML Dual-Audience Format
"""

import os
import re
from pathlib import Path
from datetime import date

SECOND_BRAIN_DIR = Path("/home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/second-brain-core")
REQUIRED_FIELDS = ["context-level", "relevant-for", "last-updated", "author", "status"]
TODAY = date.today().isoformat()

def extract_frontmatter(content):
    """Extract YAML frontmatter from markdown content."""
    match = re.match(r'^---\n(.*?)\n---\n(.*)$', content, re.DOTALL)
    if match:
        return match.group(1), match.group(2)
    return None, content

def has_field(frontmatter, field):
    """Check if frontmatter has a specific field."""
    pattern = f'^{re.escape(field)}:'
    return bool(re.search(pattern, frontmatter, re.MULTILINE))

def process_file(filepath):
    """Process a single markdown file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    frontmatter, body = extract_frontmatter(content)

    if frontmatter is None:
        print(f"  ✗ Skipping {filepath.relative_to(SECOND_BRAIN_DIR)} (no frontmatter)")
        return False

    # Check which fields are missing
    missing_fields = [field for field in REQUIRED_FIELDS if not has_field(frontmatter, field)]

    if not missing_fields:
        print(f"✓ {filepath.relative_to(SECOND_BRAIN_DIR)} (all fields present)")
        return False

    print(f"→ Updating {filepath.relative_to(SECOND_BRAIN_DIR)}")
    for field in missing_fields:
        print(f"    Adding {field}")

    # Add missing fields to frontmatter
    lines = frontmatter.strip().split('\n')

    if not has_field(frontmatter, 'context-level'):
        lines.append('context-level: 3-specific  # TODO: Update with correct level')

    if not has_field(frontmatter, 'relevant-for'):
        lines.append('relevant-for:')
        lines.append('  - ai-agents')
        lines.append('  - humans  # TODO: Update with correct audiences')

    if not has_field(frontmatter, 'last-updated'):
        lines.append(f'last-updated: {TODAY}')

    if not has_field(frontmatter, 'author'):
        lines.append('author: Seven Fortunas Team  # TODO: Update with actual author')

    if not has_field(frontmatter, 'status'):
        lines.append('status: active  # TODO: Update if needed (active|draft|archived|deprecated)')

    # Reconstruct file
    new_content = '---\n' + '\n'.join(lines) + '\n---\n' + body

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)

    return True

def main():
    print("Adding missing frontmatter fields to Second Brain documents...")
    print()

    updated_count = 0

    for filepath in sorted(SECOND_BRAIN_DIR.rglob('*.md')):
        if process_file(filepath):
            updated_count += 1
            print()

    print(f"\nUpdated {updated_count} files")

if __name__ == '__main__':
    main()
