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
FORCE_REASON=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --force-account)
            FORCE_ACCOUNT=true
            shift
            ;;
        --reason)
            # HIGH-001: --force-account requires a --reason argument
            if [[ -z "${2:-}" ]]; then
                echo "ERROR: --reason requires a non-empty string argument" >&2
                echo "Usage: $0 [--force-account --reason \"<reason>\"]" >&2
                exit 1
            fi
            FORCE_REASON="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [--force-account --reason \"<reason>\"]" >&2
            exit 1
            ;;
    esac
done

# HIGH-001: If --force-account was provided without --reason, require it
if [[ "${FORCE_ACCOUNT}" == "true" && -z "${FORCE_REASON}" ]]; then
    echo "ERROR: --force-account requires --reason <reason>" >&2
    echo "Usage: $0 --force-account --reason \"emergency hotfix\"" >&2
    exit 1
fi

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

# HIGH-002: Use exact match via gh api user --jq '.login' instead of substring grep
CURRENT_LOGIN=$(gh api user --jq '.login' 2>/dev/null || echo "")

# Check for required account using exact match
if [[ "$CURRENT_LOGIN" == "$REQUIRED_ACCOUNT" ]]; then
    log_audit "VALIDATION_SUCCESS: Authenticated as ${REQUIRED_ACCOUNT}"
    exit 0
else
    # Check if force account override is enabled
    if [[ "${FORCE_ACCOUNT}" == "true" ]]; then
        echo "WARNING: Force account override enabled. Using account: ${CURRENT_LOGIN}" >&2
        echo "WARNING: Reason: ${FORCE_REASON}" >&2

        # HIGH-001: Log caller context for audit trail
        log_audit "VALIDATION_OVERRIDE: Force account flag used with account: ${CURRENT_LOGIN} | Reason: ${FORCE_REASON} | PPID: ${PPID} | Caller: ${BASH_SOURCE[0]} | Run: ${GITHUB_RUN_ID:-local}"

        # HIGH-001: Write warning to GitHub Step Summary if available
        if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
            echo "WARNING: validate_github_auth: --force-account bypass used by PID $PPID (Run: ${GITHUB_RUN_ID:-local})" >> "$GITHUB_STEP_SUMMARY"
        fi

        exit 0
    else
        echo "ERROR: GitHub CLI is authenticated as '${CURRENT_LOGIN}', but '${REQUIRED_ACCOUNT}' is required" >&2
        echo "To override this check, use: $0 --force-account --reason \"<reason>\"" >&2
        log_audit "VALIDATION_FAILED: Wrong account '${CURRENT_LOGIN}', expected '${REQUIRED_ACCOUNT}'"
        exit 1
    fi
fi
