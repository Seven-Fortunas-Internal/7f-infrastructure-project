"""
Prompt Loading Utilities
========================

Functions for loading prompt templates from the prompts directory.
Injects project directory path for sandbox isolation.
"""

from pathlib import Path
from typing import Optional


PROMPTS_DIR = Path(__file__).parent / "prompts"

# Global project directory - set by agent.py before loading prompts
_project_dir: Optional[Path] = None


def set_project_dir(project_dir: Path) -> None:
    """
    Set the project directory for prompt injection.

    CRITICAL: Must be called before loading prompts to ensure
    sandbox isolation and correct file paths.
    """
    global _project_dir
    _project_dir = project_dir.resolve()


def load_prompt(name: str) -> str:
    """
    Load a prompt template from the prompts directory.

    Automatically injects project directory context at the beginning
    of the prompt to handle sandbox isolation issues.

    Args:
        name: Prompt filename without extension (e.g., "initializer_prompt")

    Returns:
        Prompt content with project directory injected
    """
    prompt_path = PROMPTS_DIR / f"{name}.md"

    if not prompt_path.exists():
        raise FileNotFoundError(f"Prompt template not found: {prompt_path}")

    content = prompt_path.read_text()

    # Inject project directory path into prompts
    if _project_dir is not None:
        # Add project path context at the beginning of the prompt
        project_context = f"""
## CRITICAL: PROJECT DIRECTORY

**Your working directory is:** `{_project_dir}`

**ALWAYS use absolute paths. The sandbox may create an isolated temp directory.**

Before running any commands, first change to the project directory:
```bash
cd {_project_dir}
```

Then verify you're in the correct location:
```bash
pwd  # Should show: {_project_dir}
ls app_spec.txt feature_list.json  # Should exist (or will be created)
```

---

"""
        content = project_context + content

    return content


def get_initializer_prompt() -> str:
    """
    Load the initializer prompt for Session 1.

    Returns:
        Prompt content for parsing app_spec.txt and generating feature_list.json
    """
    return load_prompt("initializer_prompt")


def get_coding_prompt() -> str:
    """
    Load the coding agent prompt for subsequent sessions (Session 2+).

    Returns:
        Prompt content for implementing features autonomously
    """
    return load_prompt("coding_prompt")
