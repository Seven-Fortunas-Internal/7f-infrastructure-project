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
- MAX_ITERATIONS: Restart after N features (prevents memory growth)
- MAX_CONSECUTIVE_SESSION_ERRORS: Stop after N consecutive errors
- MAX_STALL_SESSIONS: Stop if no progress for N sessions
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

# Default model
DEFAULT_MODEL = "sonnet"
from prompts import get_coding_prompt, get_initializer_prompt, set_project_dir


# Configuration
AUTO_CONTINUE_DELAY_SECONDS = 5
MAX_CONSECUTIVE_SESSION_ERRORS = 5
MAX_STALL_SESSIONS = 5
MAX_ITERATIONS = 10  # Prevent runaway memory growth (restart after 10 iterations)
MAX_CONSECUTIVE_FAILED_SESSIONS = 5  # Circuit breaker: stop after 5 failed sessions
SESSION_FAILURE_THRESHOLD_COMPLETION = 0.50  # Session fails if <50% completion
SESSION_FAILURE_THRESHOLD_BLOCKED = 0.30  # Session fails if >30% features blocked


class IssueLogger:
    """Simple issue logger for tracking errors and warnings."""

    def __init__(self, log_file: Path):
        self.log_file = log_file
        self.error_count = 0

    def log_info(self, message: str):
        """Log info message."""
        timestamp = datetime.now().isoformat()
        with open(self.log_file, "a") as f:
            f.write(f"[{timestamp}] INFO: {message}\n")

    def log_warning(self, message: str):
        """Log warning message."""
        timestamp = datetime.now().isoformat()
        with open(self.log_file, "a") as f:
            f.write(f"[{timestamp}] WARNING: {message}\n")

    def log_error(self, error_type: str, message: str):
        """Log error message."""
        self.error_count += 1
        timestamp = datetime.now().isoformat()
        with open(self.log_file, "a") as f:
            f.write(f"[{timestamp}] ERROR [{error_type}]: {message}\n")

    def get_error_count(self) -> int:
        """Get total error count."""
        return self.error_count


def count_features_by_status(feature_list_path: Path, status: str, max_attempts: int = None) -> int:
    """
    Count features with a specific status.

    Args:
        feature_list_path: Path to feature_list.json
        status: Status to count ("pass", "pending", "fail", "blocked")
        max_attempts: If provided, only count features with attempts < max_attempts

    Returns:
        Count of features matching criteria
    """
    try:
        with open(feature_list_path) as f:
            data = json.load(f)

        features = data.get("features", [])

        count = 0
        for f in features:
            if f.get("status") == status:
                if max_attempts is not None:
                    if f.get("attempts", 0) < max_attempts:
                        count += 1
                else:
                    count += 1

        return count
    except Exception as e:
        print(f"Warning: Could not count features: {e}")
        return 0


def load_session_progress(project_dir: Path) -> dict:
    """Load session progress tracking data."""
    progress_file = project_dir / "session_progress.json"
    if not progress_file.exists():
        return {
            "session_count": 0,
            "consecutive_failed_sessions": 0,
            "last_session_success": True,
            "last_session_date": datetime.now().isoformat(),
            "session_history": []
        }

    with open(progress_file) as f:
        return json.load(f)


def save_session_progress(project_dir: Path, progress: dict):
    """Save session progress tracking data."""
    progress_file = project_dir / "session_progress.json"
    with open(progress_file, "w") as f:
        json.dump(progress, f, indent=2)


def evaluate_session_success(feature_list_path: Path) -> Tuple[bool, str, dict]:
    """
    Evaluate if a session was successful based on completion and blocked rates.

    Returns:
        Tuple of (success: bool, reason: str, stats: dict)
    """
    try:
        with open(feature_list_path) as f:
            data = json.load(f)

        features = data.get("features", [])
        total = len(features)

        if total == 0:
            return False, "No features found", {}

        passing = sum(1 for f in features if f.get("status") == "pass")
        blocked = sum(1 for f in features if f.get("status") == "blocked")
        pending = sum(1 for f in features if f.get("status") == "pending")
        failed = sum(1 for f in features if f.get("status") == "fail")

        completion_rate = passing / total
        blocked_rate = blocked / total

        stats = {
            "total": total,
            "passing": passing,
            "blocked": blocked,
            "pending": pending,
            "failed": failed,
            "completion_rate": completion_rate,
            "blocked_rate": blocked_rate
        }

        # Success criteria:
        # - Completion rate >= 50%
        # - Blocked rate < 30%
        if completion_rate < SESSION_FAILURE_THRESHOLD_COMPLETION:
            return False, f"Completion rate {completion_rate:.1%} < {SESSION_FAILURE_THRESHOLD_COMPLETION:.0%}", stats

        if blocked_rate >= SESSION_FAILURE_THRESHOLD_BLOCKED:
            return False, f"Blocked rate {blocked_rate:.1%} >= {SESSION_FAILURE_THRESHOLD_BLOCKED:.0%}", stats

        return True, "Session successful", stats

    except Exception as e:
        return False, f"Error evaluating session: {e}", {}


def generate_summary_report(project_dir: Path, progress: dict, feature_list_path: Path):
    """Generate autonomous_summary_report.md with completion stats and blocked features."""
    try:
        with open(feature_list_path) as f:
            data = json.load(f)

        features = data.get("features", [])
        blocked_features = [f for f in features if f.get("status") == "blocked"]

        report_path = project_dir / "autonomous_summary_report.md"

        with open(report_path, "w") as f:
            f.write("# Seven Fortunas - Autonomous Implementation Summary Report\n\n")
            f.write(f"**Generated:** {datetime.now().isoformat()}\n\n")
            f.write("---\n\n")

            f.write("## Circuit Breaker Triggered\n\n")
            f.write(f"**Reason:** {progress['consecutive_failed_sessions']} consecutive failed sessions (threshold: {MAX_CONSECUTIVE_FAILED_SESSIONS})\n\n")

            f.write("## Completion Statistics\n\n")
            last_session = progress['session_history'][-1] if progress['session_history'] else {}
            stats = last_session.get('stats', {})

            f.write(f"- **Total Features:** {stats.get('total', 0)}\n")
            f.write(f"- **Passing:** {stats.get('passing', 0)}\n")
            f.write(f"- **Blocked:** {stats.get('blocked', 0)}\n")
            f.write(f"- **Pending:** {stats.get('pending', 0)}\n")
            f.write(f"- **Failed (retry eligible):** {stats.get('failed', 0)}\n")
            f.write(f"- **Completion Rate:** {stats.get('completion_rate', 0):.1%}\n")
            f.write(f"- **Blocked Rate:** {stats.get('blocked_rate', 0):.1%}\n\n")

            f.write("## Blocked Features\n\n")
            if blocked_features:
                for feat in blocked_features:
                    f.write(f"### {feat['id']}: {feat['name']}\n\n")
                    f.write(f"**Category:** {feat.get('category', 'Unknown')}\n\n")
                    f.write(f"**Attempts:** {feat.get('attempts', 0)}\n\n")

                    notes = feat.get('implementation_notes', '')
                    if notes:
                        f.write(f"**Notes:** {notes}\n\n")

                    f.write("**Verification Results:**\n")
                    vr = feat.get('verification_results', {})
                    f.write(f"- Functional: {vr.get('functional', 'N/A')}\n")
                    f.write(f"- Technical: {vr.get('technical', 'N/A')}\n")
                    f.write(f"- Integration: {vr.get('integration', 'N/A')}\n\n")
            else:
                f.write("*No blocked features*\n\n")

            f.write("## Root Causes\n\n")
            f.write("*Analyze blocked features to identify common patterns:*\n\n")
            f.write("- External dependencies unavailable\n")
            f.write("- Insufficient requirements clarity\n")
            f.write("- Technical limitations\n")
            f.write("- Implementation complexity exceeds agent capability\n\n")

            f.write("## Next Steps\n\n")
            f.write("1. **Review Blocked Features:** Investigate root causes for each blocked feature\n")
            f.write("2. **Manual Implementation:** Complete blocked features manually or with human assistance\n")
            f.write("3. **Update Requirements:** Clarify ambiguous requirements\n")
            f.write("4. **Retry with Fixes:** Re-run autonomous agent after addressing blockers\n")
            f.write("5. **Architecture Review:** Consider if blocked features indicate architectural issues\n\n")

            f.write("## Session History\n\n")
            f.write("| Session | Date | Success | Completion | Blocked | Reason |\n")
            f.write("|---------|------|---------|------------|---------|--------|\n")
            for i, session in enumerate(progress['session_history'][-10:], 1):
                date = session.get('date', 'Unknown')[:10]
                success = "✅" if session.get('success') else "❌"
                s = session.get('stats', {})
                completion = f"{s.get('completion_rate', 0):.0%}"
                blocked = f"{s.get('blocked_rate', 0):.0%}"
                reason = session.get('reason', 'N/A')[:50]
                f.write(f"| {i} | {date} | {success} | {completion} | {blocked} | {reason} |\n")

        print(f"\n📄 Summary report generated: {report_path}")

    except Exception as e:
        print(f"Warning: Could not generate summary report: {e}")


async def run_agent_session(
    client,
    prompt: str,
    issue_logger: IssueLogger,
    max_turns: int = 1000
) -> Tuple[str, str]:
    """
    Run a single agent session using Claude Agent SDK.

    Args:
        client: Claude Agent SDK client
        prompt: Prompt to send to agent
        issue_logger: Logger for errors and warnings
        max_turns: Maximum conversation turns

    Returns:
        Tuple of (status, response) where status is 'success', 'error', or 'interrupted'
    """
    print("Sending prompt to Claude Agent SDK...\n")
    tool_errors = []

    try:
        # Send the query
        await client.query(prompt)

        # Collect response text
        response_text = ""
        async for msg in client.receive_response():
            msg_type = type(msg).__name__

            # Handle AssistantMessage (text and tool use)
            if msg_type == "AssistantMessage" and hasattr(msg, "content"):
                for block in msg.content:
                    block_type = type(block).__name__

                    if block_type == "TextBlock" and hasattr(block, "text"):
                        response_text += block.text
                        print(block.text, end="", flush=True)
                    elif block_type == "ToolUseBlock" and hasattr(block, "name"):
                        print(f"\n[Tool: {block.name}]", flush=True)
                        if hasattr(block, "input"):
                            input_str = str(block.input)
                            if len(input_str) > 200:
                                print(f"   Input: {input_str[:200]}...", flush=True)
                            else:
                                print(f"   Input: {input_str}", flush=True)

            # Handle UserMessage (tool results)
            elif msg_type == "UserMessage" and hasattr(msg, "content"):
                for block in msg.content:
                    block_type = type(block).__name__

                    if block_type == "ToolResultBlock":
                        result_content = getattr(block, "content", "")
                        is_error = getattr(block, "is_error", False)

                        # Check if command was blocked
                        if "blocked" in str(result_content).lower():
                            print(f"   [BLOCKED] {result_content}", flush=True)
                            tool_errors.append(f"BLOCKED: {str(result_content)[:200]}")
                        elif is_error:
                            error_str = str(result_content)[:500]
                            print(f"   [Error] {error_str}", flush=True)
                            tool_errors.append(f"TOOL_ERROR: {error_str}")
                        else:
                            print("   [Done]", flush=True)

        print("\n" + "-" * 70 + "\n")

        # Log tool errors
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
    parser.add_argument("--max-iterations", type=int, default=MAX_ITERATIONS, help="Maximum iterations (default: 10 for memory management)")
    parser.add_argument("--single", action="store_true", help="Run single iteration only")
    args = parser.parse_args()

    # Project directory is parent of autonomous-implementation/
    project_dir = Path(__file__).parent.parent.absolute()
    feature_list = project_dir / "feature_list.json"

    # Set project directory for prompt injection (CRITICAL for sandbox isolation)
    set_project_dir(project_dir)

    # Initialize
    issue_logger = IssueLogger(project_dir / "issues.log")
    issue_logger.log_info("=" * 60)
    issue_logger.log_info(f"Session started at {datetime.now().isoformat()}")
    issue_logger.log_info("=" * 60)

    # Display header
    print("=" * 60)
    print("Seven Fortunas - Autonomous Implementation Agent")
    print("=" * 60)
    print(f"Project: {project_dir}")
    print(f"Model: {args.model}")
    print(f"Issues logged to: {project_dir}/issues.log")
    print("-" * 60)
    print()

    # Check if this is a fresh start or continuation
    is_first_run = not feature_list.exists()

    if is_first_run:
        print("Fresh start - will use initializer agent")
        print()
        print("=" * 60)
        print("  NOTE: First session takes 5-10 minutes!")
        print("  The agent is generating feature_list.json from app_spec.txt.")
        print("=" * 60)
        print()
    else:
        print("Continuing existing project")
        passing = count_features_by_status(feature_list, "pass")
        pending = count_features_by_status(feature_list, "pending")
        fail_retry = count_features_by_status(feature_list, "fail", max_attempts=3)
        remaining = pending + fail_retry
        print(f"Progress: {passing} passing, {remaining} remaining")

    # Load session progress (for circuit breaker)
    session_progress = load_session_progress(project_dir)
    session_progress["session_count"] += 1
    session_start_passing = count_features_by_status(feature_list, "pass")

    # Check circuit breaker
    if session_progress["consecutive_failed_sessions"] >= MAX_CONSECUTIVE_FAILED_SESSIONS:
        print("\n" + "=" * 60)
        print("  CIRCUIT BREAKER TRIGGERED")
        print("=" * 60)
        print(f"\n{MAX_CONSECUTIVE_FAILED_SESSIONS} consecutive failed sessions detected.")
        print("Generating summary report and terminating...\n")

        generate_summary_report(project_dir, session_progress, feature_list)
        sys.exit(42)  # Exit code 42 indicates circuit breaker termination

    iteration = 0
    consecutive_errors = 0
    stall_count = 0
    previous_passing = session_start_passing

    while iteration < args.max_iterations:
        iteration += 1

        # Count progress
        passing = count_features_by_status(feature_list, "pass")
        pending = count_features_by_status(feature_list, "pending")
        fail_retry = count_features_by_status(feature_list, "fail", max_attempts=3)
        remaining = pending + fail_retry

        print(f"\n{'=' * 60}")
        print(f"Iteration {iteration} | Tests: {passing} passing, {remaining} remaining")
        print(f"{'=' * 60}\n")

        issue_logger.log_info("-" * 40)
        issue_logger.log_info(f"Iteration {iteration} | Tests: {passing} passing, {remaining} remaining")

        # Check if all features complete
        if remaining == 0 and passing > 0:
            print("\n" + "=" * 60)
            print("ALL FEATURES COMPLETE! Agent done.")
            print("=" * 60)
            break

        # Check progress stall
        if iteration > 1:
            if passing == previous_passing:
                stall_count += 1
                if stall_count >= MAX_STALL_SESSIONS:
                    print(f"\n{'=' * 60}")
                    print("  STOPPING: NO PROGRESS DETECTED")
                    print(f"{'=' * 60}")
                    print(f"\nNo test progress for {stall_count} consecutive sessions.")
                    issue_logger.log_warning(f"Progress stall detected after {stall_count} sessions")
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

        # Create fresh client for each iteration
        client = create_client(project_dir=project_dir, model=args.model)

        # Run session with async context manager
        async with client:
            status, response = await run_agent_session(
                client,
                prompt,
                issue_logger
            )

        if status == "interrupted":
            print("\n\nSession interrupted by user.")
            break
        elif status == "error":
            consecutive_errors += 1
            print(f"\nError in iteration {iteration}: {response}")
            if consecutive_errors >= MAX_CONSECUTIVE_SESSION_ERRORS:
                print(f"\n{MAX_CONSECUTIVE_SESSION_ERRORS} consecutive errors. Stopping.")
                break
            continue
        else:
            consecutive_errors = 0

        # Check progress after iteration
        new_passing = count_features_by_status(feature_list, "pass")
        new_remaining = count_features_by_status(feature_list, "pending") + \
                        count_features_by_status(feature_list, "fail", max_attempts=3)

        if new_passing > passing:
            print(f"\n✅ Progress: {passing} → {new_passing} tests passing")

        if args.single:
            print("\nSingle iteration mode. Stopping.")
            break

        # Brief pause between iterations
        if new_remaining > 0:
            print(f"\nAuto-continuing in {AUTO_CONTINUE_DELAY_SECONDS}s... (Ctrl+C to stop)")
            try:
                await asyncio.sleep(AUTO_CONTINUE_DELAY_SECONDS)
            except KeyboardInterrupt:
                print("\nStopped by user.")
                break

    # Final summary
    passing = count_features_by_status(feature_list, "pass")
    pending = count_features_by_status(feature_list, "pending")
    fail_retry = count_features_by_status(feature_list, "fail", max_attempts=3)
    remaining = pending + fail_retry

    print(f"\n" + "=" * 60)
    print(f"Session complete. Tests: {passing} passing, {remaining} remaining")
    print("=" * 60)

    # Evaluate session success (circuit breaker logic)
    session_success, session_reason, session_stats = evaluate_session_success(feature_list)

    # Update session progress
    session_progress["last_session_date"] = datetime.now().isoformat()
    session_progress["last_session_success"] = session_success

    if session_success:
        session_progress["consecutive_failed_sessions"] = 0
        print(f"\n✅ Session SUCCESSFUL: {session_reason}")
    else:
        session_progress["consecutive_failed_sessions"] += 1
        print(f"\n❌ Session FAILED: {session_reason}")
        print(f"   Consecutive failures: {session_progress['consecutive_failed_sessions']}/{MAX_CONSECUTIVE_FAILED_SESSIONS}")

        if session_progress["consecutive_failed_sessions"] >= MAX_CONSECUTIVE_FAILED_SESSIONS:
            print(f"\n⚠️  Circuit breaker will trigger on next run!")

    # Add to session history
    session_progress["session_history"].append({
        "session_number": session_progress["session_count"],
        "date": datetime.now().isoformat(),
        "success": session_success,
        "reason": session_reason,
        "stats": session_stats
    })

    # Save session progress
    save_session_progress(project_dir, session_progress)
    print(f"\n📊 Session progress saved to: session_progress.json")

    # Log session errors
    error_count = issue_logger.get_error_count()
    if error_count > 0:
        print(f"\n⚠️  Session Errors: {error_count}")
        print(f"   See: {issue_logger.log_file}")


if __name__ == "__main__":
    asyncio.run(main())
