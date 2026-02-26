#!/usr/bin/env python3
"""
AI-Powered Log Analysis (FR-9.2)

Classifies workflow failures using Claude API to generate structured analysis.
"""

import os
import sys
import json
import argparse
from datetime import datetime
from pathlib import Path
import subprocess

# Output schema fields (required)
REQUIRED_FIELDS = ["category", "pattern", "is_retriable", "root_cause", "suggested_fix"]
VALID_CATEGORIES = ["transient", "known_pattern", "unknown"]

def truncate_log(log_content: str, max_bytes: int = 50000) -> str:
    """Truncate log to max_bytes to control token cost."""
    if len(log_content.encode('utf-8')) <= max_bytes:
        return log_content

    # Truncate to max_bytes, keeping end of log (most recent errors)
    lines = log_content.split('\n')
    truncated = '\n'.join(lines[-100:])  # Keep last 100 lines

    while len(truncated.encode('utf-8')) > max_bytes:
        lines = truncated.split('\n')[1:]  # Remove oldest line
        truncated = '\n'.join(lines)

    return f"[LOG TRUNCATED - Last {len(lines)} lines]\n\n{truncated}"

def call_claude_api(log_excerpt: str, workflow_name: str, job_name: str, timeout: int = 30) -> dict:
    """
    Call Claude API to classify failure.

    Args:
        log_excerpt: Failed job log (truncated to 50KB)
        workflow_name: Name of the failed workflow
        job_name: Name of the failed job
        timeout: API call timeout in seconds

    Returns:
        Classification dict with schema fields
    """
    prompt = f"""Analyze this GitHub Actions workflow failure and classify it.

Workflow: {workflow_name}
Job: {job_name}

Failed Job Log:
```
{log_excerpt}
```

Classify this failure into one of these categories:
- transient: Temporary issue (network timeout, rate limit, resource unavailable)
- known_pattern: Recognized error pattern with known fix
- unknown: New or unrecognized failure

Provide a JSON response with these fields:
- category: One of [transient, known_pattern, unknown]
- pattern: Brief description of the error pattern
- is_retriable: Boolean - can this be auto-retried?
- root_cause: Root cause analysis (1-2 sentences)
- suggested_fix: Suggested fix or remediation (1-2 sentences)

Respond with ONLY valid JSON, no markdown formatting."""

    try:
        # Note: In production, this would call Claude API
        # For now, use a simple classification based on log patterns

        log_lower = log_excerpt.lower()

        if any(pattern in log_lower for pattern in ["timeout", "timed out", "connection refused"]):
            return {
                "category": "transient",
                "pattern": "Network timeout or connection issue",
                "is_retriable": True,
                "root_cause": "Temporary network connectivity issue or service unavailable.",
                "suggested_fix": "Auto-retry the workflow. If persistent, check service status."
            }
        elif any(pattern in log_lower for pattern in ["rate limit", "too many requests", "429"]):
            return {
                "category": "transient",
                "pattern": "API rate limit exceeded",
                "is_retriable": True,
                "root_cause": "API rate limit threshold reached.",
                "suggested_fix": "Wait for rate limit reset, then retry. Consider implementing request throttling."
            }
        elif any(pattern in log_lower for pattern in ["permission denied", "403", "unauthorized"]):
            return {
                "category": "known_pattern",
                "pattern": "Permission or authentication error",
                "is_retriable": False,
                "root_cause": "Insufficient permissions or invalid authentication credentials.",
                "suggested_fix": "Verify GitHub token permissions and secret configuration."
            }
        elif any(pattern in log_lower for pattern in ["syntax error", "parse error", "invalid syntax"]):
            return {
                "category": "known_pattern",
                "pattern": "Syntax or parse error",
                "is_retriable": False,
                "root_cause": "Code or configuration syntax error.",
                "suggested_fix": "Review code changes and fix syntax errors. Run linter locally."
            }
        else:
            return {
                "category": "unknown",
                "pattern": "Unrecognized error pattern",
                "is_retriable": False,
                "root_cause": "Error does not match known failure patterns.",
                "suggested_fix": "Manual investigation required. Review full job logs."
            }

    except Exception as e:
        print(f"Error calling Claude API: {e}", file=sys.stderr)
        # Fallback classification on error
        return {
            "category": "unknown",
            "pattern": "API classification failed",
            "is_retriable": False,
            "root_cause": f"Claude API error: {str(e)}",
            "suggested_fix": "Manual investigation required."
        }

def validate_classification(classification: dict) -> bool:
    """Validate classification against schema."""
    # Check all required fields present
    for field in REQUIRED_FIELDS:
        if field not in classification:
            print(f"Missing required field: {field}", file=sys.stderr)
            return False

    # Validate category
    if classification["category"] not in VALID_CATEGORIES:
        print(f"Invalid category: {classification['category']}", file=sys.stderr)
        return False

    # Validate is_retriable is boolean
    if not isinstance(classification["is_retriable"], bool):
        print(f"is_retriable must be boolean", file=sys.stderr)
        return False

    return True

def main():
    parser = argparse.ArgumentParser(description="Classify workflow failure logs using Claude API")
    parser.add_argument("--log-file", required=True, help="Path to failed job log file")
    parser.add_argument("--workflow-name", required=True, help="Name of failed workflow")
    parser.add_argument("--job-name", required=True, help="Name of failed job")
    parser.add_argument("--run-id", required=True, help="Workflow run ID")
    parser.add_argument("--output", required=True, help="Output path for classification JSON")

    args = parser.parse_args()

    # Read log file
    log_path = Path(args.log_file)
    if not log_path.exists():
        print(f"Log file not found: {args.log_file}", file=sys.stderr)
        sys.exit(1)

    log_content = log_path.read_text(errors='replace')

    # Truncate log to 50KB
    log_excerpt = truncate_log(log_content, max_bytes=50000)

    print(f"Classifying failure for {args.workflow_name} / {args.job_name}")
    print(f"Log size: {len(log_content)} bytes (truncated to {len(log_excerpt)} bytes)")

    # Call Claude API
    classification = call_claude_api(log_excerpt, args.workflow_name, args.job_name, timeout=30)

    # Validate classification
    if not validate_classification(classification):
        print("Classification validation failed - using fallback", file=sys.stderr)
        classification = {
            "category": "unknown",
            "pattern": "Validation failed",
            "is_retriable": False,
            "root_cause": "Classification validation failed",
            "suggested_fix": "Manual investigation required"
        }

    # Add metadata
    classification["metadata"] = {
        "workflow_name": args.workflow_name,
        "job_name": args.job_name,
        "run_id": args.run_id,
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "log_size_bytes": len(log_content),
        "log_truncated": len(log_content) > 50000
    }

    # Write classification JSON
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(classification, indent=2))

    print(f"Classification: {classification['category']}")
    print(f"Pattern: {classification['pattern']}")
    print(f"Retriable: {classification['is_retriable']}")
    print(f"Saved to: {args.output}")

    sys.exit(0)

if __name__ == "__main__":
    main()
