"""
Claude Agent SDK Client Wrapper
================================

Configures Claude Agent SDK with proper permissions for autonomous implementation.
Based on the claude-quickstarts reference pattern, adapted for DevOps/GitHub CLI context.

Security layers (defense in depth):
1. Sandbox - OS-level bash command isolation
2. Permissions - File operations restricted to project_dir only
3. Security hooks - Bash commands validated against ALLOWED_COMMANDS (see security.py)
"""

import json
from pathlib import Path

from claude_agent_sdk import ClaudeAgentOptions, ClaudeSDKClient, HookMatcher

from security import bash_security_hook

# Model mapping
MODEL_MAP = {
    "sonnet": "claude-sonnet-4-5-20250929",
    "opus": "claude-opus-4-6",
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

# agent-browser MCP tools for web/URL verification
# Source: https://github.com/vercel-labs/agent-browser
# Install: npm install -g agent-browser && agent-browser install
# Note: Verify exact tool names after install with: agent-browser mcp --list-tools
BROWSER_TOOLS = [
    "mcp__agent-browser__screenshot",
    "mcp__agent-browser__navigate",
    "mcp__agent-browser__click",
    "mcp__agent-browser__fill",
    "mcp__agent-browser__type",
    "mcp__agent-browser__find",
    "mcp__agent-browser__get",
    "mcp__agent-browser__wait",
    "mcp__agent-browser__snapshot",
]


def create_client(project_dir: Path, model: str = "sonnet") -> ClaudeSDKClient:
    """
    Create a Claude Agent SDK client with multi-layered security.

    Args:
        project_dir: Directory for the project (working directory)
        model: Model name (sonnet, opus, haiku) or full model ID

    Returns:
        Configured ClaudeSDKClient

    Security layers (defense in depth):
    1. Sandbox - OS-level bash command isolation
    2. Permissions - File operations restricted to project_dir only
    3. Security hooks - Bash commands validated against allowlist (see security.py)
    """
    model_id = MODEL_MAP.get(model, model)

    # Settings file: sandbox + filesystem permissions
    # Using relative paths (./**) restricts to project_dir since cwd=project_dir
    security_settings = {
        "sandbox": {
            "enabled": True,
            "autoAllowBashIfSandboxed": True
        },
        "permissions": {
            "defaultMode": "acceptEdits",
            "allow": [
                "Read(./**)",
                "Write(./**)",
                "Edit(./**)",
                "Glob(./**)",
                "Grep(./**)",
                # Bash allowed here; actual commands validated by bash_security_hook
                "Bash(*)",
                # agent-browser MCP tools
                *BROWSER_TOOLS,
            ],
        },
    }

    project_dir.mkdir(parents=True, exist_ok=True)

    settings_file = project_dir / ".claude_settings.json"
    with open(settings_file, "w") as f:
        json.dump(security_settings, f, indent=2)

    print(f"✓ Created security settings at {settings_file}")
    print(f"  - Sandbox enabled (OS-level bash isolation)")
    print(f"  - Filesystem restricted to: {project_dir.resolve()}")
    print(f"  - Bash commands restricted to allowlist (see security.py)")
    print(f"  - MCP: agent-browser (web verification)")
    print()

    return ClaudeSDKClient(
        options=ClaudeAgentOptions(
            model=model_id,
            system_prompt=(
                "You are an expert DevOps engineer building AI-native infrastructure. "
                "Follow instructions precisely and make reasonable decisions autonomously."
            ),
            allowed_tools=[*BUILTIN_TOOLS, *BROWSER_TOOLS],
            mcp_servers={
                "agent-browser": {"command": "agent-browser", "args": ["mcp"]}
            },
            hooks={
                "PreToolUse": [
                    HookMatcher(matcher="Bash", hooks=[bash_security_hook]),
                ],
            },
            max_turns=1000,
            cwd=str(project_dir.resolve()),
            settings=str(settings_file.resolve()),
        )
    )
