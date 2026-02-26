#!/usr/bin/env python3
"""Scan project for README.md coverage"""
import os
from pathlib import Path

root = Path('/home/ladmin/dev/GDF/7F_github')
all_dirs = []
has_readme = []
missing_readme = []

# Skip common directories that don't need READMEs
skip_dirs = {'.git', 'node_modules', '__pycache__', '.pytest_cache', 'dist', 'build', '.venv', 'venv', '.claude'}

for dirpath, dirnames, filenames in os.walk(root):
    # Filter out skip directories
    dirnames[:] = [d for d in dirnames if d not in skip_dirs]

    rel_path = Path(dirpath).relative_to(root)
    all_dirs.append(str(rel_path))

    if 'README.md' in filenames:
        has_readme.append(str(rel_path))
    else:
        missing_readme.append(str(rel_path))

print(f"Total directories: {len(all_dirs)}")
print(f"With README.md: {len(has_readme)}")
print(f"Missing README.md: {len(missing_readme)}")
print()
print(f"Coverage: {len(has_readme)}/{len(all_dirs)} ({100*len(has_readme)//len(all_dirs)}%)")
print()
print("Directories missing README.md:")
for d in sorted(missing_readme):
    print(f"  - {d}")
