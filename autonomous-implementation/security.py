"""
Security Hooks for 7F Autonomous Implementation Agent
======================================================

Pre-tool-use hooks that validate bash commands using an allowlist.
Only explicitly permitted commands can run.

Adapted from the claude-quickstarts reference for DevOps/GitHub CLI context.
"""

import os
import re
import shlex


# Allowed commands for DevOps / GitHub infrastructure tasks
ALLOWED_COMMANDS = {
    # File inspection
    "ls",
    "cat",
    "head",
    "tail",
    "wc",
    "grep",
    # File operations
    "cp",
    "mkdir",
    "chmod",    # Making scripts executable; validated separately
    "mv",
    "rm",       # Temp file cleanup only; validated separately
    "touch",
    # Text processing
    "sed",
    "awk",
    "tr",
    "cut",
    "sort",
    "uniq",
    "tee",
    # Utilities
    "pwd",
    "echo",
    "printf",
    "date",
    "sleep",
    "test",
    "diff",
    # JSON / XML processing
    "jq",
    "xmllint",
    # Scripting / Python
    "python3",
    "python",
    "bash",
    "sh",
    # GitHub CLI
    "gh",
    # Version control
    "git",      # Destructive subcommands validated separately
    # HTTP (read-only enforced separately)
    "curl",
    # Process inspection (read-only)
    "ps",
    "which",
    "command",
}

# Commands that need additional validation beyond simple allowlisting
COMMANDS_NEEDING_EXTRA_VALIDATION = {"chmod", "rm", "curl", "git"}


def split_command_segments(command_string: str) -> list[str]:
    """
    Split a compound command into individual segments.
    Handles && and || chaining and semicolons.
    """
    segments = re.split(r"\s*(?:&&|\|\|)\s*", command_string)
    result = []
    for segment in segments:
        sub_segments = re.split(r'(?<!["\'])\s*;\s*(?!["\'])', segment)
        for sub in sub_segments:
            sub = sub.strip()
            if sub:
                result.append(sub)
    return result


def extract_commands(command_string: str) -> list[str]:
    """
    Extract base command names from a shell command string.
    Handles pipes, chaining (&&, ||, ;), and subshells.
    Returns the base command names (without paths).
    """
    commands = []
    segments = re.split(r'(?<!["\'])\s*;\s*(?!["\'])', command_string)

    for segment in segments:
        segment = segment.strip()
        if not segment:
            continue

        try:
            tokens = shlex.split(segment)
        except ValueError:
            return []  # Malformed command — fail safe by blocking

        if not tokens:
            continue

        expect_command = True
        for token in tokens:
            if token in ("|", "||", "&&", "&"):
                expect_command = True
                continue

            if token in (
                "if", "then", "else", "elif", "fi",
                "for", "while", "until", "do", "done",
                "case", "esac", "in", "!", "{", "}",
            ):
                continue

            if token.startswith("-"):
                continue

            # Skip variable assignments (VAR=value)
            if "=" in token and not token.startswith("="):
                continue

            if expect_command:
                commands.append(os.path.basename(token))
                expect_command = False

    return commands


def validate_chmod_command(command_string: str) -> tuple[bool, str]:
    """Only allow chmod +x variants (execute permission). No recursive flags."""
    try:
        tokens = shlex.split(command_string)
    except ValueError:
        return False, "Could not parse chmod command"

    if not tokens or tokens[0] != "chmod":
        return False, "Not a chmod command"

    mode = None
    for token in tokens[1:]:
        if token.startswith("-"):
            return False, f"chmod flags (e.g. -R) are not allowed"
        elif mode is None:
            mode = token

    if mode is None:
        return False, "chmod requires a mode"

    if not re.match(r"^[ugoa]*\+x$", mode):
        return False, f"chmod only allowed with +x mode, got: {mode}"

    return True, ""


def validate_rm_command(command_string: str) -> tuple[bool, str]:
    """
    Block recursive/force rm. Only allow removing temp files
    (*.tmp, *.bak, *.swp, files ending in ~).
    """
    try:
        tokens = shlex.split(command_string)
    except ValueError:
        return False, "Could not parse rm command"

    if not tokens:
        return False, "Empty rm command"

    for token in tokens[1:]:
        if token.startswith("-") and any(c in token for c in ["r", "R", "f"]):
            return False, f"rm flag '{token}' not allowed (no recursive or force)"

    ALLOWED_EXTENSIONS = {".tmp", ".bak", ".swp"}
    targets = [t for t in tokens[1:] if not t.startswith("-")]

    for target in targets:
        basename = os.path.basename(target)
        ext = os.path.splitext(basename)[1]
        is_temp = (
            ext in ALLOWED_EXTENSIONS
            or basename.endswith("~")
            or basename.endswith(".tmp")
        )
        if not is_temp:
            return False, (
                f"rm only allowed on temp files (*.tmp, *.bak, *.swp, *~), got: {target}"
            )

    return True, ""


def validate_curl_command(command_string: str) -> tuple[bool, str]:
    """
    Block curl write operations (POST/PUT/DELETE/PATCH) to external hosts.
    Allows all methods to localhost/127.0.0.1.
    """
    try:
        tokens = shlex.split(command_string)
    except ValueError:
        return False, "Could not parse curl command"

    WRITE_FLAGS = {"-X", "--request", "--data", "-d", "--data-raw",
                   "--data-binary", "--data-urlencode", "--upload-file", "-T"}
    WRITE_METHODS = {"POST", "PUT", "DELETE", "PATCH"}

    i = 1
    while i < len(tokens):
        token = tokens[i]
        if token in WRITE_FLAGS and i + 1 < len(tokens):
            value = tokens[i + 1].upper()
            if value in WRITE_METHODS:
                url_is_local = any(
                    "localhost" in t or "127.0.0.1" in t for t in tokens
                )
                if not url_is_local:
                    return False, f"curl {token} {value} only allowed to localhost"
        i += 1

    return True, ""


def validate_git_command(command_string: str) -> tuple[bool, str]:
    """Block destructive git operations: force-push, reset --hard, clean."""
    try:
        tokens = shlex.split(command_string)
    except ValueError:
        return False, "Could not parse git command"

    if len(tokens) < 2:
        return True, ""

    subcommand = tokens[1]

    if subcommand == "clean":
        return False, "git clean is not allowed"

    if subcommand == "push" and any(t in tokens for t in ("--force", "-f", "--force-with-lease")):
        return False, "Force push is not allowed"

    if subcommand == "reset" and "--hard" in tokens:
        return False, "git reset --hard is not allowed"

    return True, ""


def get_command_for_validation(cmd: str, segments: list[str]) -> str:
    """Find the command segment that contains the given command name."""
    for segment in segments:
        if cmd in extract_commands(segment):
            return segment
    return ""


async def bash_security_hook(input_data, tool_use_id=None, context=None):
    """
    Pre-tool-use hook that validates bash commands against ALLOWED_COMMANDS.

    Returns {} to allow, or {"decision": "block", "reason": "..."} to block.
    """
    if input_data.get("tool_name") != "Bash":
        return {}

    command = input_data.get("tool_input", {}).get("command", "")
    if not command:
        return {}

    commands = extract_commands(command)

    if not commands:
        return {
            "decision": "block",
            "reason": f"Could not parse command for security validation: {command}",
        }

    segments = split_command_segments(command)

    for cmd in commands:
        if cmd not in ALLOWED_COMMANDS:
            return {
                "decision": "block",
                "reason": (
                    f"Command '{cmd}' is not in the allowed list. "
                    f"Allowed: {sorted(ALLOWED_COMMANDS)}"
                ),
            }

        if cmd in COMMANDS_NEEDING_EXTRA_VALIDATION:
            cmd_segment = get_command_for_validation(cmd, segments) or command

            if cmd == "chmod":
                ok, reason = validate_chmod_command(cmd_segment)
            elif cmd == "rm":
                ok, reason = validate_rm_command(cmd_segment)
            elif cmd == "curl":
                ok, reason = validate_curl_command(cmd_segment)
            elif cmd == "git":
                ok, reason = validate_git_command(cmd_segment)
            else:
                ok, reason = True, ""

            if not ok:
                return {"decision": "block", "reason": reason}

    return {}
