#!/usr/bin/env python3
"""
Prompt Loading Utilities
Loads prompt files for initializer and coding agents
"""

import os
from pathlib import Path

def get_project_root():
    """
    Get the absolute path to the project root directory

    Returns:
        Path: Project root directory
    """
    # Scripts are in /home/ladmin/dev/GDF/7F_github/scripts/
    # Project root is one level up
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    return project_root

def load_prompt(prompt_file):
    """
    Load a prompt file from the prompts/ directory

    Args:
        prompt_file (str): Name of prompt file (e.g., "initializer_prompt.md")

    Returns:
        str: Prompt content

    Raises:
        FileNotFoundError: If prompt file doesn't exist
    """
    project_root = get_project_root()
    prompt_path = project_root / "prompts" / prompt_file

    if not prompt_path.exists():
        raise FileNotFoundError(
            f"Prompt file not found: {prompt_path}\n"
            f"Expected location: {project_root}/prompts/{prompt_file}"
        )

    with open(prompt_path, 'r', encoding='utf-8') as f:
        return f.read()

def get_initializer_prompt():
    """
    Load the initializer agent prompt (Session 1)

    Returns:
        str: Initializer prompt content
    """
    return load_prompt("initializer_prompt.md")

def get_coding_prompt():
    """
    Load the coding agent prompt (Sessions 2+)

    Returns:
        str: Coding prompt content
    """
    return load_prompt("coding_prompt.md")

if __name__ == "__main__":
    # Test prompt loading
    try:
        project_root = get_project_root()
        print(f"✓ Project root: {project_root}")

        init_prompt = get_initializer_prompt()
        print(f"✓ Initializer prompt loaded: {len(init_prompt)} characters")

        coding_prompt = get_coding_prompt()
        print(f"✓ Coding prompt loaded: {len(coding_prompt)} characters")

    except FileNotFoundError as e:
        print(f"✗ Prompt loading failed: {e}")
        exit(1)
