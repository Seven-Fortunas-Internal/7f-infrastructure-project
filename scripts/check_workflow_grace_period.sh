#!/bin/bash
# NFR-4.6: Check if a workflow is in 24h grace period (newly deployed)
# Usage: check_workflow_grace_period.sh <workflow-file-name>
# Exit codes: 0 = in grace period, 1 = not in grace period

set -euo pipefail

WORKFLOW_FILE="${1:-}"
if [[ -z "$WORKFLOW_FILE" ]]; then
  echo "Usage: $0 <workflow-file-name>" >&2
  exit 2
fi

REPO="${GITHUB_REPOSITORY:-Seven-Fortunas-Internal/7f-infrastructure-project}"
GRACE_HOURS=24

# Query the last commit that modified this workflow file
LAST_COMMIT=$(gh api "/repos/${REPO}/commits?path=.github/workflows/${WORKFLOW_FILE}&per_page=1" \
  --jq '.[0].commit.committer.date' 2>/dev/null || echo "")

if [[ -z "$LAST_COMMIT" ]]; then
  # File doesn't exist or API error - not in grace period
  exit 1
fi

# Calculate time difference in seconds
LAST_MODIFIED_TS=$(date -d "$LAST_COMMIT" +%s)
NOW_TS=$(date +%s)
DIFF_SECONDS=$((NOW_TS - LAST_MODIFIED_TS))
GRACE_SECONDS=$((GRACE_HOURS * 3600))

if [[ $DIFF_SECONDS -lt $GRACE_SECONDS ]]; then
  # Within grace period
  HOURS_AGO=$((DIFF_SECONDS / 3600))
  echo "Workflow ${WORKFLOW_FILE} in grace period (modified ${HOURS_AGO}h ago)" >&2
  exit 0
else
  # Grace period expired
  exit 1
fi
