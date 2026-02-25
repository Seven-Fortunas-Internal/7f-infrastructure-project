#!/usr/bin/env python3
"""Generate README.md files for directories missing them"""
import os
from pathlib import Path

root = Path('/home/ladmin/dev/GDF/7F_github')

# Skip common directories that don't need READMEs
skip_dirs = {'.git', 'node_modules', '__pycache__', '.pytest_cache', 'dist', 'build', '.venv', 'venv', '.claude'}

# Directories that should definitely have READMEs
priority_dirs = {
    '.github', '.github/workflows', 'config', 'costs', 'utils', 'utils/logging',
    'scripts/examples', 'scripts/testing', 'compliance/reliability',
    'dashboards/ai/scripts', 'dashboards/fintech/scripts', 'dashboards/edutech/scripts',
    'dashboards/security/scripts', 'docs/scalability', 'docs/security-compliance',
    'docs/security-testing'
}

def generate_readme_content(dir_path):
    """Generate appropriate README content based on directory purpose"""
    dir_name = dir_path.name
    parent = dir_path.parent.name if dir_path.parent != root else "root"

    # Determine purpose based on directory name
    if 'workflow' in str(dir_path):
        title = f"GitHub Actions Workflows"
        purpose = "This directory contains GitHub Actions workflow definitions for automated CI/CD pipelines."
    elif 'scripts' in str(dir_path):
        title = f"{dir_name.title()} Scripts"
        purpose = "This directory contains utility scripts for automation and tooling."
    elif 'config' in str(dir_path):
        title = "Configuration"
        purpose = "This directory contains configuration files and settings."
    elif 'docs' in str(dir_path):
        title = f"{dir_name.title()} Documentation"
        purpose = "This directory contains documentation and guides."
    elif 'test' in str(dir_path):
        title = "Tests"
        purpose = "This directory contains test files and test utilities."
    elif 'compliance' in str(dir_path):
        title = f"{dir_name.title()} Compliance"
        purpose = "This directory contains compliance tracking and evidence."
    elif 'utils' in str(dir_path):
        title = f"{dir_name.title()} Utilities"
        purpose = "This directory contains utility modules and helper functions."
    else:
        title = dir_name.replace('-', ' ').replace('_', ' ').title()
        purpose = f"This directory is part of the {parent} module."

    readme = f"""# {title}

{purpose}

## Contents

*Directory contents will be documented here as files are added.*

## Usage

Refer to individual file documentation for specific usage instructions.

---

**Part of:** Seven Fortunas Infrastructure Project
**Documentation:** See [project README](../../README.md) for overall architecture
"""
    return readme

# Find missing READMEs
missing_count = 0
created_count = 0

for dirpath, dirnames, filenames in os.walk(root):
    dirnames[:] = [d for d in dirnames if d not in skip_dirs]

    rel_path = Path(dirpath).relative_to(root)

    if 'README.md' not in filenames:
        missing_count += 1
        # Only create READMEs for priority directories to avoid cluttering
        if str(rel_path) in priority_dirs or rel_path == Path('.'):
            readme_path = Path(dirpath) / 'README.md'
            content = generate_readme_content(Path(dirpath))

            with open(readme_path, 'w') as f:
                f.write(content)

            created_count += 1
            print(f"✓ Created: {rel_path}/README.md")

print()
print(f"Missing READMEs: {missing_count}")
print(f"Created READMEs: {created_count}")
print(f"Skipped (low priority): {missing_count - created_count}")
