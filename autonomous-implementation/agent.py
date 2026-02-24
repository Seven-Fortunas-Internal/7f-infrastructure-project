#!/usr/bin/env python3
"""
Seven Fortunas - Autonomous Implementation Agent
=================================================

Uses Claude Agent SDK to run autonomous development sessions.
Tracks progress via feature_list.json (source of truth).

Architecture:
- Session 1 (Initializer): Parse app_spec.txt → generate feature_list.json
- Session 2+ (Coding Agent): Implement features → test → update tracking → commit → loop

Circuit Breakers:
- MAX_CONSECUTIVE_SESSION_ERRORS: Stop after N consecutive session errors
- MAX_STALL_SESSIONS: Stop if no progress for N iterations
"""

import asyncio
import json
import sys
from pathlib import Path
from datetime import datetime
import argparse
from typing import Tuple

# Add current directory to path for imports
sys.path.insert(0, str(Path(__file__).parent))

from client import create_client
from prompts import get_coding_prompt, get_initializer_prompt, set_project_dir


# Configuration
DEFAULT_MODEL = "sonnet"
AUTO_CONTINUE_DELAY_SECONDS = 5
MAX_CONSECUTIVE_SESSION_ERRORS = 10  # Stop after 10 consecutive errors (not 20 — see note)
MAX_STALL_SESSIONS = 5               # Stop if no new features pass for 5 iterations

# Note on MAX_CONSECUTIVE_SESSION_ERRORS = 10:
# The reference implementation has no limit (always retries). We keep a limit
# because the 7F agent can encounter real blocking errors (API auth, GitHub rate limits)
# that won't self-resolve. 10 gives enough retries for transient failures without
# spinning indefinitely on permanent ones. 20 would be too permissive.


def safe_print(*args, **kwargs):
    """
    Print with BlockingIOError handling.

    Prevents [Errno 11] EAGAIN crashes when stdout is in non-blocking mode,
    which occurs when the script is run piped (e.g. with 2>&1 redirection).
    """
    try:
        print(*args, **kwargs)
    except BlockingIOError:
        pass


class IssueLogger:
    """Append-only logger for tracking errors and warnings to issues.log."""

    def __init__(self, log_file: Path):
        self.log_file = log_file
        self.error_count = 0

    def log_info(self, message: str):
        timestamp = datetime.now().isoformat()
        with open(self.log_file, "a") as f:
            f.write(f"[{timestamp}] INFO: {message}\n")

    def log_warning(self, message: str):
        timestamp = datetime.now().isoformat()
        with open(self.log_file, "a") as f:
            f.write(f"[{timestamp}] WARNING: {message}\n")

    def log_error(self, error_type: str, message: str):
        self.error_count += 1
        timestamp = datetime.now().isoformat()
        with open(self.log_file, "a") as f:
            f.write(f"[{timestamp}] ERROR [{error_type}]: {message}\n")

    def get_error_count(self) -> int:
        return self.error_count


def count_features_by_status(feature_list_path: Path, status: str, max_attempts: int = None) -> int:
    """
    Count features with a specific status in feature_list.json.

    Args:
        feature_list_path: Path to feature_list.json
        status: "pass", "pending", "fail", or "blocked"
        max_attempts: If set, only count features with attempts < max_attempts
    """
    try:
        with open(feature_list_path) as f:
            data = json.load(f)

        features = data.get("features", [])
        count = 0
        for feat in features:
            if feat.get("status") == status:
                if max_attempts is not None:
                    if feat.get("attempts", 0) < max_attempts:
                        count += 1
                else:
                    count += 1
        return count
    except Exception as e:
        safe_print(f"Warning: Could not count features: {e}")
        return 0


async def run_agent_session(
    client,
    prompt: str,
    issue_logger: IssueLogger,
) -> Tuple[str, str]:
    """
    Run a single agent session using Claude Agent SDK.

    Returns:
        Tuple of (status, response) where status is 'success', 'error', or 'interrupted'
    """
    safe_print("Sending prompt to Claude Agent SDK...\n")
    tool_errors = []

    try:
        await client.query(prompt)

        response_text = ""
        async for msg in client.receive_response():
            msg_type = type(msg).__name__

            if msg_type == "AssistantMessage" and hasattr(msg, "content"):
                for block in msg.content:
                    block_type = type(block).__name__

                    if block_type == "TextBlock" and hasattr(block, "text"):
                        response_text += block.text
                        safe_print(block.text, end="", flush=True)
                    elif block_type == "ToolUseBlock" and hasattr(block, "name"):
                        safe_print(f"\n[Tool: {block.name}]", flush=True)
                        if hasattr(block, "input"):
                            input_str = str(block.input)
                            if len(input_str) > 200:
                                safe_print(f"   Input: {input_str[:200]}...", flush=True)
                            else:
                                safe_print(f"   Input: {input_str}", flush=True)

            elif msg_type == "UserMessage" and hasattr(msg, "content"):
                for block in msg.content:
                    block_type = type(block).__name__

                    if block_type == "ToolResultBlock":
                        result_content = getattr(block, "content", "")
                        is_error = getattr(block, "is_error", False)

                        if "blocked" in str(result_content).lower():
                            safe_print(f"   [BLOCKED] {result_content}", flush=True)
                            tool_errors.append(f"BLOCKED: {str(result_content)[:200]}")
                        elif is_error:
                            error_str = str(result_content)[:500]
                            safe_print(f"   [Error] {error_str}", flush=True)
                            tool_errors.append(f"TOOL_ERROR: {error_str}")
                        else:
                            safe_print("   [Done]", flush=True)

        safe_print("\n" + "-" * 70 + "\n")

        if tool_errors:
            for error in tool_errors:
                issue_logger.log_error("tool_error", error)

        return "success", response_text

    except KeyboardInterrupt:
        return "interrupted", "Session interrupted by user"
    except Exception as e:
        issue_logger.log_error("session_error", f"Session error: {str(e)}")
        return "error", str(e)


async def main():
    parser = argparse.ArgumentParser(description="Seven Fortunas Autonomous Implementation Agent")
    parser.add_argument("--model", default=DEFAULT_MODEL, help="Model to use (sonnet, opus, haiku)")
    parser.add_argument("--max-iterations", type=int, default=None,
                        help="Optional iteration cap (default: unlimited — runs until all features done)")
    parser.add_argument("--single", action="store_true", help="Run single iteration only (for debugging)")
    args = parser.parse_args()

    # Project directory is parent of autonomous-implementation/
    project_dir = Path(__file__).parent.parent.absolute()
    feature_list = project_dir / "feature_list.json"

    set_project_dir(project_dir)

    issue_logger = IssueLogger(project_dir / "issues.log")
    issue_logger.log_info("=" * 60)
    issue_logger.log_info(f"Session started at {datetime.now().isoformat()}")
    issue_logger.log_info("=" * 60)

    safe_print("=" * 60)
    safe_print("Seven Fortunas - Autonomous Implementation Agent")
    safe_print("=" * 60)
    safe_print(f"Project: {project_dir}")
    safe_print(f"Model: {args.model}")
    safe_print(f"Max iterations: {'unlimited' if not args.max_iterations else args.max_iterations}")
    safe_print(f"Issues logged to: {project_dir}/issues.log")
    safe_print("-" * 60)
    safe_print()

    is_first_run = not feature_list.exists()

    if is_first_run:
        safe_print("Fresh start - will use initializer agent")
        safe_print()
        safe_print("=" * 60)
        safe_print("  NOTE: First session takes 5-10 minutes!")
        safe_print("  The agent is generating feature_list.json from app_spec.txt.")
        safe_print("=" * 60)
        safe_print()
    else:
        passing = count_features_by_status(feature_list, "pass")
        pending = count_features_by_status(feature_list, "pending")
        fail_retry = count_features_by_status(feature_list, "fail", max_attempts=3)
        remaining = pending + fail_retry
        safe_print("Continuing existing project")
        safe_print(f"Progress: {passing} passing, {remaining} remaining")
        safe_print()

    iteration = 0
    consecutive_errors = 0
    stall_count = 0
    previous_passing = count_features_by_status(feature_list, "pass") if feature_list.exists() else 0

    # Run until all features done — like the reference implementation
    while True:
        iteration += 1

        # Optional hard cap (for testing/debugging only)
        if args.max_iterations and iteration > args.max_iterations:
            safe_print(f"\nReached max iterations ({args.max_iterations}). Stopping.")
            safe_print("To continue: run the script again (resumes from current state)")
            break

        # Count current progress
        passing = count_features_by_status(feature_list, "pass")
        pending = count_features_by_status(feature_list, "pending")
        fail_retry = count_features_by_status(feature_list, "fail", max_attempts=3)
        remaining = pending + fail_retry

        safe_print(f"\n{'=' * 60}")
        safe_print(f"Iteration {iteration} | {passing} passing, {remaining} remaining")
        safe_print(f"{'=' * 60}\n")

        issue_logger.log_info("-" * 40)
        issue_logger.log_info(f"Iteration {iteration} | {passing} passing, {remaining} remaining")

        # All features complete — done!
        if remaining == 0 and passing > 0:
            safe_print("\n" + "=" * 60)
            safe_print("ALL FEATURES COMPLETE! Agent done.")
            safe_print("=" * 60)
            break

        # Stall detection: stop if no new features pass after N iterations
        if iteration > 1:
            if passing == previous_passing:
                stall_count += 1
                if stall_count >= MAX_STALL_SESSIONS:
                    safe_print(f"\n{'=' * 60}")
                    safe_print("  STOPPING: NO PROGRESS DETECTED")
                    safe_print(f"{'=' * 60}")
                    safe_print(f"\nNo new features completed for {stall_count} consecutive iterations.")
                    safe_print("Investigate blocked features or check issues.log.")
                    issue_logger.log_warning(f"Progress stall after {stall_count} iterations")
                    break
            else:
                stall_count = 0
        previous_passing = passing

        # Choose prompt based on session type
        if is_first_run:
            prompt = get_initializer_prompt()
            is_first_run = False  # Only use initializer once
        else:
            prompt = get_coding_prompt()

        # Fresh client per iteration (prevents context/memory growth)
        client = create_client(project_dir=project_dir, model=args.model)

        async with client:
            status, response = await run_agent_session(client, prompt, issue_logger)

        if status == "interrupted":
            safe_print("\n\nSession interrupted by user.")
            break
        elif status == "error":
            consecutive_errors += 1
            safe_print(f"\nError in iteration {iteration}: {response}")
            if consecutive_errors >= MAX_CONSECUTIVE_SESSION_ERRORS:
                safe_print(f"\n{MAX_CONSECUTIVE_SESSION_ERRORS} consecutive errors. Stopping for investigation.")
                issue_logger.log_error(
                    "circuit_breaker",
                    f"Stopped after {MAX_CONSECUTIVE_SESSION_ERRORS} consecutive errors. Last: {response}"
                )
                break
            safe_print(f"Retrying... ({consecutive_errors}/{MAX_CONSECUTIVE_SESSION_ERRORS})")
            continue
        else:
            consecutive_errors = 0

        # Show delta progress
        new_passing = count_features_by_status(feature_list, "pass")
        if new_passing > passing:
            safe_print(f"\n✅ Progress: {passing} → {new_passing} features passing")

        if args.single:
            safe_print("\nSingle iteration mode. Stopping.")
            break

        # Brief pause between iterations
        if remaining > 0:
            safe_print(f"\nAuto-continuing in {AUTO_CONTINUE_DELAY_SECONDS}s... (Ctrl+C to stop)")
            try:
                await asyncio.sleep(AUTO_CONTINUE_DELAY_SECONDS)
            except KeyboardInterrupt:
                safe_print("\nStopped by user.")
                break

    # Final summary
    passing = count_features_by_status(feature_list, "pass")
    pending = count_features_by_status(feature_list, "pending")
    fail_retry = count_features_by_status(feature_list, "fail", max_attempts=3)
    remaining = pending + fail_retry

    safe_print(f"\n" + "=" * 60)
    safe_print(f"Session complete. {passing} passing, {remaining} remaining")
    safe_print("=" * 60)

    error_count = issue_logger.get_error_count()
    if error_count > 0:
        safe_print(f"\n⚠️  Session errors: {error_count} — see {issue_logger.log_file}")


if __name__ == "__main__":
    asyncio.run(main())
