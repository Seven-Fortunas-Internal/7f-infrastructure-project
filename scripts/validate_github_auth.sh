#!/usr/bin/env bash
# validate_github_auth.sh
# Validates GitHub CLI authentication for jorge-at-sf account
# Exit 0: Authenticated correctly | Exit 1: Authentication failed

set -euo pipefail

# Constants
REQUIRED_ACCOUNT="jorge-at-sf"
LOG_FILE="${LOG_FILE:-/tmp/github_auth_audit.log}"

# Parse command line arguments
FORCE_ACCOUNT=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --force-account)
            FORCE_ACCOUNT=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [--force-account]" >&2
            exit 1
            ;;
    esac
done

# Function to log to audit trail
log_audit() {
    local message="$1"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[${timestamp}] ${message}" >> "${LOG_FILE}"
}

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "ERROR: GitHub CLI (gh) is not installed" >&2
    log_audit "VALIDATION_FAILED: gh CLI not found"
    exit 1
fi

# Get authentication status
if ! auth_status=$(gh auth status 2>&1); then
    echo "ERROR: GitHub CLI is not authenticated" >&2
    log_audit "VALIDATION_FAILED: No authentication found"
    exit 1
fi

# Check for required account
if echo "${auth_status}" | grep -q "${REQUIRED_ACCOUNT}"; then
    log_audit "VALIDATION_SUCCESS: Authenticated as ${REQUIRED_ACCOUNT}"
    exit 0
else
    # Check if force account override is enabled
    if [[ "${FORCE_ACCOUNT}" == "true" ]]; then
        current_account=$(echo "${auth_status}" | grep -oP 'Logged in to [^ ]+ as \K[^ ]+' || echo "unknown")
        echo "WARNING: Force account override enabled. Using account: ${current_account}" >&2
        log_audit "VALIDATION_OVERRIDE: Force account flag used with account: ${current_account}"
        exit 0
    else
        current_account=$(echo "${auth_status}" | grep -oP 'Logged in to [^ ]+ as \K[^ ]+' || echo "unknown")
        echo "ERROR: GitHub CLI is authenticated as '${current_account}', but '${REQUIRED_ACCOUNT}' is required" >&2
        echo "To override this check, use: $0 --force-account" >&2
        log_audit "VALIDATION_FAILED: Wrong account '${current_account}', expected '${REQUIRED_ACCOUNT}'"
        exit 1
    fi
fi
