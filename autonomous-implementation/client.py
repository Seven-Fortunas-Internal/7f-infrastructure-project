"""
Claude Agent SDK Client Wrapper
================================

Configures Claude Agent SDK with proper permissions for autonomous implementation.
Based on proven airgap-autonomous pattern.
"""

import json
from pathlib import Path

from claude_agent_sdk import ClaudeAgentOptions, ClaudeSDKClient

# Model mapping
MODEL_MAP = {
    "sonnet": "claude-sonnet-4-5-20250929",
    "opus": "claude-opus-4-6-20250902",
    "haiku": "claude-haiku-4-5-20251001",
}

# Built-in tools
BUILTIN_TOOLS = [
    "Read",
    "Write",
    "Edit",
    "Glob",
    "Grep",
    "Bash",
]


def create_client(project_dir: Path, model: str = "sonnet") -> ClaudeSDKClient:
    """
    Create a Claude Agent SDK client with proper permissions configuration.

    Args:
        project_dir: Directory for the project (working directory)
        model: Model name (sonnet, opus, haiku) or full model ID

    Returns:
        Configured ClaudeSDKClient with autonomous permissions

    Security configuration:
    1. Sandbox enabled - OS-level bash command isolation
    2. Permissions - File operations restricted to project_dir only
    3. Auto-approve edits within project directory
    """
    # Get full model ID
    model_id = MODEL_MAP.get(model, model)

    # Create comprehensive security settings
    # Note: Using relative paths ("./**") restricts access to project directory
    # since cwd is set to project_dir
    security_settings = {
        "sandbox": {
            "enabled": True,
            "autoAllowBashIfSandboxed": True
        },
        "permissions": {
            "defaultMode": "acceptEdits",  # Auto-approve edits within allowed directories
            "allow": [
                # Allow all file operations within the project directory
                "Read(./**)",
                "Write(./**)",
                "Edit(./**)",
                "Glob(./**)",
                "Grep(./**)",
                # Bash permission granted for autonomous operation
                "Bash(*)",
            ],
        },
    }

    # Ensure project directory exists before creating settings file
    project_dir.mkdir(parents=True, exist_ok=True)

    # Write settings to a file in the project directory
    settings_file = project_dir / ".claude_settings.json"
    with open(settings_file, "w") as f:
        json.dump(security_settings, f, indent=2)

    print(f"✓ Created security settings at {settings_file}")
    print(f"  - Sandbox enabled (OS-level bash isolation)")
    print(f"  - Filesystem restricted to: {project_dir.resolve()}")
    print(f"  - Auto-approve: Read/Write/Edit/Glob/Grep/Bash")
    print()

    return ClaudeSDKClient(
        options=ClaudeAgentOptions(
            model=model_id,
            system_prompt="You are an expert DevOps engineer building AI-native infrastructure. Follow instructions precisely and make reasonable decisions autonomously.",
            allowed_tools=BUILTIN_TOOLS,
            max_turns=1000,
            cwd=str(project_dir.resolve()),
            settings=str(settings_file.resolve()),  # Critical: pass settings file path
        )
    )
