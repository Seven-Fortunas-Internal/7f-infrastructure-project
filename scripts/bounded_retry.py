#!/usr/bin/env python3
"""
Bounded Retry Logic with Session-Level Circuit Breaker

Implements FR-7.2: 3-attempt retry strategy for failed features
with automatic blocking and comprehensive failure logging.

Usage:
    python3 bounded_retry.py <feature_id> <implementation_script>

Example:
    python3 bounded_retry.py FEATURE_001 ./scripts/implement_feature_001.sh
"""

import json
import sys
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path

# Retry configuration
MAX_ATTEMPTS = 3
TIMEOUT_SECONDS = 1800  # 30 minutes per attempt

# Approach levels
APPROACHES = {
    1: "STANDARD",
    2: "SIMPLIFIED",
    3: "MINIMAL"
}

def load_feature_list():
    """Load feature_list.json"""
    with open('feature_list.json', 'r') as f:
        return json.load(f)

def save_feature_list(data):
    """Save feature_list.json atomically"""
    with open('feature_list.json.tmp', 'w') as f:
        json.dump(data, f, indent=2)
    Path('feature_list.json.tmp').rename('feature_list.json')

def update_feature_status(feature_id, status, attempts, error_msg=None):
    """Update feature status in feature_list.json"""
    data = load_feature_list()

    for feature in data['features']:
        if feature['id'] == feature_id:
            feature['status'] = status
            feature['attempts'] = attempts
            feature['last_updated'] = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')

            if error_msg:
                # Append to implementation_notes
                if feature['implementation_notes']:
                    feature['implementation_notes'] += f"\n\nAttempt {attempts} failed: {error_msg}"
                else:
                    feature['implementation_notes'] = f"Attempt {attempts} failed: {error_msg}"

            if status == 'blocked':
                feature['blocked_reason'] = f"Failed after {attempts} attempts. See implementation_notes for details."

            break

    save_feature_list(data)

def log_attempt(feature_id, attempt, approach, result, error_msg=None):
    """Log attempt to autonomous_build_log.md"""
    timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S')

    log_entry = f"""
#### Retry Attempt {attempt} - {approach}
**Timestamp:** {timestamp}
**Feature:** {feature_id}
**Result:** {result}
"""

    if error_msg:
        log_entry += f"""**Error:** {error_msg}
"""

    log_entry += "\n---\n"

    with open('autonomous_build_log.md', 'a') as f:
        f.write(log_entry)

def execute_with_timeout(command, timeout):
    """Execute command with timeout"""
    try:
        result = subprocess.run(
            command,
            shell=True,
            timeout=timeout,
            capture_output=True,
            text=True
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", f"Timeout after {timeout} seconds"
    except Exception as e:
        return -1, "", str(e)

def bounded_retry(feature_id, implementation_script):
    """
    Execute feature implementation with bounded retry logic

    Args:
        feature_id: Feature ID (e.g., FEATURE_001)
        implementation_script: Path to implementation script

    Returns:
        bool: True if feature passed, False if blocked
    """
    data = load_feature_list()
    feature = None

    for f in data['features']:
        if f['id'] == feature_id:
            feature = f
            break

    if not feature:
        print(f"✗ Feature {feature_id} not found in feature_list.json")
        return False

    current_attempts = feature['attempts']

    # Check if already blocked
    if feature['status'] == 'blocked':
        print(f"✗ Feature {feature_id} is already blocked")
        return False

    # Check if already passed
    if feature['status'] == 'pass':
        print(f"✓ Feature {feature_id} already passed")
        return True

    # Execute retry loop
    for attempt in range(current_attempts + 1, MAX_ATTEMPTS + 1):
        approach = APPROACHES[attempt]

        print(f"\n{'='*60}")
        print(f"Attempt {attempt}/{MAX_ATTEMPTS}: {approach}")
        print(f"Feature: {feature_id} - {feature['name']}")
        print(f"Timeout: {TIMEOUT_SECONDS}s ({TIMEOUT_SECONDS//60} minutes)")
        print(f"{'='*60}\n")

        # Update status to indicate in-progress
        update_feature_status(feature_id, 'pending', attempt)

        # Execute implementation script with approach environment variable
        env_command = f"export APPROACH={approach} && {implementation_script}"

        start_time = time.time()
        returncode, stdout, stderr = execute_with_timeout(env_command, TIMEOUT_SECONDS)
        elapsed = time.time() - start_time

        print(f"\nExecution completed in {elapsed:.1f}s")
        print(f"Return code: {returncode}")

        if returncode == 0:
            # Success!
            print(f"✓ Feature {feature_id} PASSED on attempt {attempt} ({approach})")
            update_feature_status(feature_id, 'pass', attempt)
            log_attempt(feature_id, attempt, approach, 'PASS')
            return True
        else:
            # Failure
            error_msg = stderr if stderr else stdout
            error_msg = error_msg[:500]  # Limit error message length

            print(f"✗ Attempt {attempt} FAILED")
            print(f"Error: {error_msg[:200]}")

            log_attempt(feature_id, attempt, approach, 'FAIL', error_msg)

            if attempt < MAX_ATTEMPTS:
                print(f"\nRetrying with {APPROACHES[attempt + 1]} approach...")
                update_feature_status(feature_id, 'fail', attempt, error_msg)
            else:
                # Max attempts reached - mark as blocked
                print(f"\n✗ Feature {feature_id} BLOCKED after {MAX_ATTEMPTS} attempts")
                update_feature_status(feature_id, 'blocked', attempt, error_msg)
                log_attempt(feature_id, attempt, 'BLOCKED', 'BLOCKED',
                           f"Max attempts ({MAX_ATTEMPTS}) reached")
                return False

    return False

def main():
    """Main entry point"""
    if len(sys.argv) != 3:
        print("Usage: python3 bounded_retry.py <feature_id> <implementation_script>")
        print("\nExample:")
        print("  python3 bounded_retry.py FEATURE_001 ./scripts/implement_feature_001.sh")
        sys.exit(1)

    feature_id = sys.argv[1]
    implementation_script = sys.argv[2]

    # Verify implementation script exists
    if not Path(implementation_script).exists():
        print(f"✗ Implementation script not found: {implementation_script}")
        sys.exit(1)

    # Execute bounded retry
    success = bounded_retry(feature_id, implementation_script)

    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
