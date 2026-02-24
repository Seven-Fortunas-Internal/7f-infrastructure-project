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
MAX_CONSECUTIVE_FAILED_SESSIONS = 5  # Stop after 5 consecutive failed sessions (FEATURE_025)
SESSION_FAILURE_THRESHOLD_COMPLETION = 0.5  # Session fails if completion rate < 50%
SESSION_FAILURE_THRESHOLD_BLOCKED = 0.3     # Session fails if > 30% features blocked
ATTEMPT_TIMEOUT_SECONDS = 30 * 60        # 30 minutes per attempt (FEATURE_025)

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


def evaluate_session_success(passing: int, total: int, blocked: int) -> bool:
    """
    Evaluate if a session was successful based on completion and blocked rates.

    Args:
        passing: Number of features that passed
        total: Total number of features attempted
        blocked: Number of features marked as blocked

    Returns:
        True if session successful, False otherwise
    """
    if total == 0:
        return False

    completion_rate = passing / total
    blocked_rate = blocked / total if total > 0 else 0

    # Session fails if completion rate < 50% OR blocked rate > 30%
    if completion_rate < SESSION_FAILURE_THRESHOLD_COMPLETION:
        return False
    if blocked_rate > SESSION_FAILURE_THRESHOLD_BLOCKED:
        return False

    return True


def load_session_progress(project_dir: Path) -> dict:
    """Load session_progress.json or create default structure"""
    progress_file = project_dir / "session_progress.json"

    if progress_file.exists():
        try:
            with open(progress_file) as f:
                return json.load(f)
        except Exception:
            pass

    # Default structure
    return {
        "session_count": 0,
        "consecutive_failed_sessions": 0,
        "session_history": [],
        "last_updated": datetime.now().isoformat()
    }


def save_session_progress(project_dir: Path, progress: dict):
    """Save session_progress.json"""
    progress_file = project_dir / "session_progress.json"
    progress["last_updated"] = datetime.now().isoformat()

    with open(progress_file, 'w') as f:
        json.dump(progress, f, indent=2)


def is_session_failed(feature_list_path: Path, start_passing: int, end_passing: int) -> bool:
    """
    Determine if a session failed based on completion rate and blocked features.

    Session fails if:
    - Completion rate < 50% (not enough progress made)
    - OR > 30% of total features are blocked
    """
    try:
        with open(feature_list_path) as f:
            data = json.load(f)

        total_features = data.get("metadata", {}).get("total_features", 0)
        if total_features == 0:
            return False  # Can't determine failure without knowing total

        # Calculate completion rate for this session
        features_completed = end_passing - start_passing
        pending = count_features_by_status(feature_list_path, "pending")
        fail_retry = count_features_by_status(feature_list_path, "fail", max_attempts=3)
        remaining = pending + fail_retry

        if remaining == 0:
            # All done - not a failure
            return False

        completion_rate = features_completed / remaining if remaining > 0 else 0

        # Check blocked threshold
        blocked = count_features_by_status(feature_list_path, "blocked")
        blocked_rate = blocked / total_features

        # Session fails if completion rate too low OR too many blocked
        failed = (completion_rate < SESSION_FAIL_COMPLETION_THRESHOLD or
                  blocked_rate > SESSION_FAIL_BLOCKED_THRESHOLD)

        return failed
    except Exception as e:
        safe_print(f"Warning: Could not determine session failure: {e}")
        return False


def generate_summary_report(project_dir: Path, issue_logger: IssueLogger):
    """Generate autonomous_summary_report.md when circuit breaker triggers"""
    feature_list = project_dir / "feature_list.json"
    report_file = project_dir / "autonomous_summary_report.md"

    try:
        # Collect statistics
        passing = count_features_by_status(feature_list, "pass")
        pending = count_features_by_status(feature_list, "pending")
        failed = count_features_by_status(feature_list, "fail")
        blocked = count_features_by_status(feature_list, "blocked")

        with open(feature_list) as f:
            data = json.load(f)

        total = data.get("metadata", {}).get("total_features", passing + pending + failed + blocked)
        completion_pct = (passing / total * 100) if total > 0 else 0

        # Get blocked features details
        blocked_features = []
        for feat in data.get("features", []):
            if feat.get("status") == "blocked":
                blocked_features.append({
                    "id": feat.get("id"),
                    "name": feat.get("name"),
                    "attempts": feat.get("attempts", 0),
                    "notes": feat.get("implementation_notes", "")
                })

        # Generate report
        report = f"""# Autonomous Implementation - Summary Report

**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
**Reason:** Circuit breaker triggered (5 consecutive failed sessions)

## Completion Statistics

| Metric | Count | Percentage |
|--------|-------|------------|
| **Total Features** | {total} | 100% |
| **Completed (Pass)** | {passing} | {completion_pct:.1f}% |
| **Pending** | {pending} | {pending/total*100 if total > 0 else 0:.1f}% |
| **Failed (Retrying)** | {failed} | {failed/total*100 if total > 0 else 0:.1f}% |
| **Blocked** | {blocked} | {blocked/total*100 if total > 0 else 0:.1f}% |

## Blocked Features

The following features are blocked after 3 failed attempts:

"""

        if blocked_features:
            for feat in blocked_features:
                report += f"""### {feat['id']}: {feat['name']}
- **Attempts:** {feat['attempts']}
- **Notes:** {feat['notes'] or 'No notes recorded'}

"""
        else:
            report += "*No blocked features*\n\n"

        report += """## Root Causes

Based on error logs, common failure patterns include:

"""

        # Add recent errors from issues.log
        issues_log = project_dir / "issues.log"
        if issues_log.exists():
            with open(issues_log) as f:
                lines = f.readlines()

            # Get last 20 error entries
            error_lines = [line for line in lines if "ERROR" in line][-20:]

            if error_lines:
                report += "**Recent Errors:**\n```\n"
                for line in error_lines:
                    report += line
                report += "```\n\n"

        report += """## Next Steps

1. **Review Blocked Features:** Investigate each blocked feature to determine root cause
   - Check implementation_notes in feature_list.json
   - Review autonomous_build_log.md for detailed failure context
   - Check issues.log for error patterns

2. **Fix External Dependencies:** Address any blocking issues
   - API authentication (GitHub, Reddit, etc.)
   - Missing dependencies or tools
   - Network/firewall restrictions
   - Rate limits or quotas

3. **Reset Features:** If issues are resolved, reset blocked features to pending
   ```bash
   jq '(.features[] | select(.status == "blocked")) |= (.status = "pending" | .attempts = 0)' feature_list.json > feature_list.json.tmp
   mv feature_list.json.tmp feature_list.json
   ```

4. **Restart Agent:** Resume autonomous implementation
   ```bash
   ./autonomous-implementation/scripts/run-autonomous.sh
   ```

5. **Consider Manual Implementation:** For persistently blocked features, consider manual implementation or simplified approach

## Files to Review

- `autonomous_build_log.md` - Detailed implementation log with all attempts
- `issues.log` - Error tracking and warnings
- `feature_list.json` - Feature status and verification results
- `session_progress.json` - Session-level metrics
- `claude-progress.txt` - High-level progress summary

---

*Report generated by Seven Fortunas Autonomous Agent (FEATURE_025)*
"""

        with open(report_file, 'w') as f:
            f.write(report)

        safe_print(f"\n✓ Summary report generated: {report_file}")
        issue_logger.log_info(f"Generated summary report: {report_file}")

    except Exception as e:
        safe_print(f"Warning: Could not generate summary report: {e}")
        issue_logger.log_error("report_generation", f"Failed to generate summary: {e}")


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

    # Load session progress (FEATURE_025)
    session_progress = load_session_progress(project_dir)
    consecutive_failed_sessions = session_progress.get("consecutive_failed_sessions", 0)

    if consecutive_failed_sessions > 0:
        safe_print(f"⚠️  Warning: {consecutive_failed_sessions} consecutive failed sessions recorded")
        safe_print()

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

        # Track session start state
        session_start_passing = passing

        # Run agent session with timeout (FEATURE_025: 30 min hard timeout)
        async with client:
            try:
                status, response = await asyncio.wait_for(
                    run_agent_session(client, prompt, issue_logger),
                    timeout=ATTEMPT_TIMEOUT_SECONDS
                )
            except asyncio.TimeoutError:
                status = "error"
                response = f"Session timeout after {ATTEMPT_TIMEOUT_SECONDS/60} minutes"
                safe_print(f"\n⏱️  TIMEOUT: Session exceeded {ATTEMPT_TIMEOUT_SECONDS/60} minute limit")
                issue_logger.log_error("timeout", response)

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
