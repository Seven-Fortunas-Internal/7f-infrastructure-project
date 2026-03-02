#!/usr/bin/env python3
"""
Add README.md to all directories missing one.

Usage:
    python scripts/add-missing-readmes.py
    python scripts/add-missing-readmes.py --dry-run
"""

import os
import sys
from pathlib import Path

README_TEMPLATE = """# {directory_name}

**Purpose:** [Why this directory exists]

## Contents

- `[file/directory]` - [Description]
- `[file/directory]` - [Description]
- `[file/directory]` - [Description]

## Usage

[How to use the contents of this directory]

```bash
# Example command or code snippet
[example]
```

## Related Documentation

- [Link to parent README](../README.md)
- [Link to related docs](../docs/[doc-name].md)

---

**Last Updated:** [YYYY-MM-DD]
"""

def find_directories_without_readme(root_path='.'):
    """Find all directories without README.md"""
    missing = []

    for root, dirs, files in os.walk(root_path, topdown=True):
        # Skip hidden dirs and venv
        dirs[:] = [d for d in dirs if not d.startswith('.') and d != 'venv']

        readme_path = os.path.join(root, 'README.md')
        if not os.path.exists(readme_path):
            missing.append(root)

    return missing

def create_readme(directory_path, dry_run=False):
    """Create README.md in specified directory"""
    directory_name = os.path.basename(directory_path) or 'root'
    content = README_TEMPLATE.format(directory_name=directory_name)

    readme_path = os.path.join(directory_path, 'README.md')

    if dry_run:
        print(f"Would create: {readme_path}")
    else:
        with open(readme_path, 'w') as f:
            f.write(content)
        print(f"Created: {readme_path}")

def main():
    dry_run = '--dry-run' in sys.argv

    missing = find_directories_without_readme()

    print(f"Found {len(missing)} directories without README.md")
    print()

    if dry_run:
        print("DRY RUN MODE - No files will be created")
        print()

    for directory in missing:
        create_readme(directory, dry_run=dry_run)

    print()
    print(f"{'Would create' if dry_run else 'Created'} {len(missing)} README files")

if __name__ == '__main__':
    main()
