#!/usr/bin/env python3
"""
Autonomous Agent Runner
Executes Claude SDK agent for infrastructure implementation
"""

import os
import sys
import json
from datetime import datetime
from pathlib import Path

# Import Claude SDK components
from client import get_claude_client, get_model_name
from prompts import get_project_root, get_initializer_prompt, get_coding_prompt

# Circuit breaker configuration
MAX_ITERATIONS = 10  # Features per session
MAX_CONSECUTIVE_SESSION_ERRORS = 5
MAX_STALL_SESSIONS = 5

def update_progress_file(session_type, features_completed=0, status="HEALTHY"):
    """
    Update claude-progress.txt with session results

    Args:
        session_type (str): "initializer" or "coding"
        features_completed (int): Number of features completed this session
        status (str): Circuit breaker status
    """
    project_root = get_project_root()
    progress_file = project_root / "claude-progress.txt"

    timestamp = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")

    # Read current progress
    with open(progress_file, 'r') as f:
        lines = f.readlines()

    # Update metadata
    new_lines = []
    for line in lines:
        if line.startswith("features_completed="):
            current = int(line.split("=")[1].strip())
            new_lines.append(f"features_completed={current + features_completed}\n")
        elif line.startswith("circuit_breaker_status="):
            new_lines.append(f"circuit_breaker_status={status}\n")
        elif line.startswith("last_session_date="):
            new_lines.append(f"last_session_date={datetime.utcnow().strftime('%Y-%m-%d')}\n")
        elif line.startswith("last_updated="):
            new_lines.append(f"last_updated={timestamp}\n")
        else:
            new_lines.append(line)

    # Write updated progress
    with open(progress_file, 'w') as f:
        f.writelines(new_lines)

def run_agent(session_type="coding", max_iterations=MAX_ITERATIONS):
    """
    Run autonomous agent session

    Args:
        session_type (str): "initializer" or "coding"
        max_iterations (int): Max features to process

    Returns:
        dict: Session results
    """
    try:
        # Initialize client
        client = get_claude_client()
        model = get_model_name()

        # Load appropriate prompt
        if session_type == "initializer":
            prompt = get_initializer_prompt()
        else:
            prompt = get_coding_prompt()

        print(f"Starting {session_type} agent session...")
        print(f"Model: {model}")
        print(f"Max iterations: {max_iterations}")
        print("-" * 60)

        # Create message to Claude
        response = client.messages.create(
            model=model,
            max_tokens=8000,
            messages=[
                {
                    "role": "user",
                    "content": prompt
                }
            ]
        )

        # Process response
        result = {
            "session_type": session_type,
            "model": model,
            "timestamp": datetime.utcnow().isoformat(),
            "response": response.content[0].text if response.content else "",
            "usage": {
                "input_tokens": response.usage.input_tokens,
                "output_tokens": response.usage.output_tokens
            }
        }

        print("\nSession completed successfully")
        print(f"Tokens used: {result['usage']['input_tokens']} in, {result['usage']['output_tokens']} out")

        return result

    except Exception as e:
        print(f"✗ Agent session failed: {e}")
        return {
            "error": str(e),
            "session_type": session_type,
            "timestamp": datetime.utcnow().isoformat()
        }

def main():
    """Main entry point for agent runner"""

    # Parse command line arguments
    session_type = sys.argv[1] if len(sys.argv) > 1 else "coding"
    max_iterations = int(sys.argv[2]) if len(sys.argv) > 2 else MAX_ITERATIONS

    if session_type not in ["initializer", "coding"]:
        print(f"Invalid session type: {session_type}")
        print("Usage: python agent.py [initializer|coding] [max_iterations]")
        sys.exit(1)

    # Run agent session
    result = run_agent(session_type, max_iterations)

    # Update progress tracking
    if "error" not in result:
        update_progress_file(session_type, features_completed=0, status="HEALTHY")
        sys.exit(0)
    else:
        update_progress_file(session_type, features_completed=0, status="ERROR")
        sys.exit(1)

if __name__ == "__main__":
    main()
