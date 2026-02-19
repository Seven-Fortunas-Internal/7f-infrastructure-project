#!/bin/bash
# Track Skill Usage
# Logs skill invocations for governance and analytics

set -e

USAGE_LOG=".claude/commands/.skill-usage.log"
SKILL_NAME="$1"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

if [ -z "$SKILL_NAME" ]; then
    echo "Usage: $0 <skill-name>"
    exit 1
fi

# Ensure log file exists
touch "$USAGE_LOG"

# Log invocation
echo "$TIMESTAMP|$SKILL_NAME|$USER|$PWD" >> "$USAGE_LOG"

# Optional: Display confirmation (comment out for production)
# echo "✅ Tracked usage: $SKILL_NAME"
