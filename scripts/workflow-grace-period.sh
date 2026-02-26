#!/usr/bin/env bash
# =============================================================================
# workflow-grace-period.sh — NFR-4.6: Metrics Cascade Failure Prevention
# =============================================================================
# Checks if a workflow file is within the 24-hour grace period after deployment.
# Used by collect-metrics.yml and track-workflow-reliability.yml to prevent
# newly-deployed workflows from triggering ERROR thresholds.
#
# Usage:
#   source scripts/workflow-grace-period.sh
#   if is_in_grace_period "workflow-name.yml"; then
#       echo "Workflow is in grace period"
#   fi
#
# Exit codes:
#   0 = workflow is in grace period (< 24 hours since last commit)
#   1 = workflow is not in grace period (≥ 24 hours since last commit)
#   2 = error (workflow file not found, API failure, etc.)
#
# Grace period: Exactly 24 hours (86400 seconds)
# =============================================================================

GRACE_PERIOD_HOURS=24
GRACE_PERIOD_SECONDS=$((GRACE_PERIOD_HOURS * 3600))

# Function to check if workflow is in grace period
is_in_grace_period() {
    local workflow_file="$1"
    local workflow_path=".github/workflows/${workflow_file}"

    # Validate input
    if [[ -z "$workflow_file" ]]; then
        echo "Error: Workflow file name required" >&2
        return 2
    fi

    # Check if workflow file exists locally
    if [[ ! -f "$workflow_path" ]]; then
        echo "Error: Workflow file not found: $workflow_path" >&2
        return 2
    fi

    # Get repository info
    local repo_owner repo_name
    repo_owner=$(gh repo view --json owner --jq '.owner.login' 2>/dev/null)
    repo_name=$(gh repo view --json name --jq '.name' 2>/dev/null)

    if [[ -z "$repo_owner" ]] || [[ -z "$repo_name" ]]; then
        echo "Error: Failed to get repository info" >&2
        return 2
    fi

    # Query GitHub API for last commit to this workflow file
    local last_commit_date
    last_commit_date=$(gh api "/repos/${repo_owner}/${repo_name}/commits?path=${workflow_path}&per_page=1" \
        --jq '.[0].commit.committer.date' 2>/dev/null)

    if [[ -z "$last_commit_date" ]]; then
        echo "Warning: No commit history found for $workflow_file (may be new file)" >&2
        # Treat new files as within grace period
        return 0
    fi

    # Convert to Unix timestamp
    local commit_timestamp
    commit_timestamp=$(date -d "$last_commit_date" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$last_commit_date" +%s 2>/dev/null)

    if [[ -z "$commit_timestamp" ]]; then
        echo "Error: Failed to parse commit date: $last_commit_date" >&2
        return 2
    fi

    # Get current timestamp
    local current_timestamp
    current_timestamp=$(date +%s)

    # Calculate age
    local age_seconds=$((current_timestamp - commit_timestamp))

    # Check if within grace period
    if [[ $age_seconds -lt $GRACE_PERIOD_SECONDS ]]; then
        local age_hours=$((age_seconds / 3600))
        echo "✓ Workflow $workflow_file is in grace period (${age_hours}h old, < ${GRACE_PERIOD_HOURS}h)" >&2
        return 0
    else
        local age_hours=$((age_seconds / 3600))
        echo "✗ Workflow $workflow_file is past grace period (${age_hours}h old, ≥ ${GRACE_PERIOD_HOURS}h)" >&2
        return 1
    fi
}

# Function to get workflows in grace period (for reporting)
get_grace_period_workflows() {
    local workflows_dir=".github/workflows"

    if [[ ! -d "$workflows_dir" ]]; then
        echo "[]"
        return 0
    fi

    local grace_workflows=()

    for workflow_file in "$workflows_dir"/*.yml; do
        if [[ -f "$workflow_file" ]]; then
            local filename
            filename=$(basename "$workflow_file")

            if is_in_grace_period "$filename" 2>/dev/null; then
                grace_workflows+=("$filename")
            fi
        fi
    done

    # Output as JSON array
    printf '%s\n' "${grace_workflows[@]}" | jq -R . | jq -s .
}

# Export functions if sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f is_in_grace_period
    export -f get_grace_period_workflows
fi
