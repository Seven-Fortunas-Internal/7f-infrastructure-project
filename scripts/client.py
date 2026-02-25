#!/usr/bin/env python3
"""
Claude SDK Client Configuration
Provides authenticated client for autonomous agent operations
"""

import os
from anthropic import Anthropic

def get_claude_client():
    """
    Initialize and return authenticated Claude client

    Returns:
        Anthropic: Configured client instance

    Raises:
        ValueError: If ANTHROPIC_API_KEY not set
    """
    api_key = os.environ.get("ANTHROPIC_API_KEY")

    if not api_key:
        raise ValueError(
            "ANTHROPIC_API_KEY environment variable not set. "
            "Set it with: export ANTHROPIC_API_KEY='your-key-here'"
        )

    return Anthropic(api_key=api_key)

def get_model_name():
    """
    Get the Claude model to use for autonomous operations

    Returns:
        str: Model identifier
    """
    # Use Claude Sonnet 4.5 as specified in requirements
    return "claude-sonnet-4-5-20250929"

if __name__ == "__main__":
    # Test client initialization
    try:
        client = get_claude_client()
        model = get_model_name()
        print(f"✓ Claude client initialized successfully")
        print(f"✓ Using model: {model}")
    except ValueError as e:
        print(f"✗ Client initialization failed: {e}")
        exit(1)
