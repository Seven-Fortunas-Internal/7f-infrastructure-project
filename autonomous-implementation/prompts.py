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


def get_coding_prompt(phase: Optional[str] = None) -> str:
    """
    Load the coding agent prompt for subsequent sessions (Session 2+).

    Args:
        phase: If set ("A", "B", or "C"), injects a phase constraint preamble
               that restricts the agent to only implement features in that phase.

    Returns:
        Prompt content for implementing features autonomously
    """
    content = load_prompt("coding_prompt")

    if phase:
        phase_names = {"A": "Bootstrap", "B": "Core Features", "C": "Observability"}
        sentinel_note = (
            "\n**SENTINEL RULE:** FEATURE_055 (FR-9.1 Workflow Sentinel) MUST be the "
            "very last feature you implement in this phase. Skip it until all other "
            "Phase C features are complete (pending=0 for Phase C, excluding FEATURE_055).\n"
            if phase == "C" else ""
        )
        phase_preamble = f"""## ⚠️ PHASE CONSTRAINT — Phase {phase}: {phase_names[phase]}

**You are running in Phase {phase} mode. Only implement features where `phase_group == "{phase}"` in feature_list.json.**

When selecting the next feature, add a phase filter:
```bash
jq -r '.features[] |
  select(.status == "pending" or (.status == "fail" and .attempts < 3)) |
  select(.phase_group == "{phase}") |
  .id' feature_list.json | head -1
```
{sentinel_note}
When all Phase {phase} features show pending=0 (for your phase filter), do NOT continue to other phases.
Run the post-run validation sweep (Step 7 below), then stop. The human will validate before launching Phase {"B" if phase == "A" else "C" if phase == "B" else "DONE"}.

---

"""
        content = phase_preamble + content

    return content
