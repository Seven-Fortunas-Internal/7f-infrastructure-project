#!/bin/bash
# 7f-secrets-manager.sh - Manage GitHub organization secrets

set -euo pipefail

# Configuration
GITHUB_ORG="${GITHUB_ORG:-Seven-Fortunas-Internal}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
log() { echo -e "${GREEN}[INFO]${NC} $*"; }
info() { echo -e "${BLUE}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

show_help() {
    cat <<EOF
7f-secrets-manager - Manage GitHub organization secrets

Usage:
  $0 <action> [options]

Actions:
  list           List all organization secrets
  add NAME       Add a new secret
  update NAME    Update existing secret value
  delete NAME    Delete a secret
  rotate NAME    Rotate a secret (guided process)
  help           Show this help message

Environment:
  GITHUB_ORG     Organization name (default: Seven-Fortunas-Internal)

Examples:
  $0 list
  $0 add ANTHROPIC_API_KEY
  $0 update ANTHROPIC_API_KEY
  $0 delete OLD_API_KEY
  $0 rotate ANTHROPIC_API_KEY

EOF
}

# Validate prerequisites
if ! command -v gh &> /dev/null; then
    error "GitHub CLI (gh) not installed"
    error "Install: https://cli.github.com/"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    error "GitHub CLI not authenticated"
    error "Run: gh auth login"
    exit 1
fi

# Actions
action_list() {
    info "Organization Secrets ($GITHUB_ORG):"
    echo ""

    gh secret list --org "$GITHUB_ORG" 2>/dev/null || {
        error "Failed to list secrets"
        error "Ensure you have organization owner permissions"
        exit 1
    }
}

action_add() {
    local name="$1"

    if [[ -z "$name" ]]; then
        error "Missing secret name"
        echo "Usage: $0 add SECRET_NAME"
        exit 1
    fi

    info "Adding secret: $name"
    echo ""

    # Prompt for value
    read -sp "Enter value for $name: " value
    echo ""

    if [[ -z "$value" ]]; then
        error "Secret value cannot be empty"
        exit 1
    fi

    # Set secret
    echo "$value" | gh secret set "$name" \
        --org "$GITHUB_ORG" \
        --visibility all || {
        error "Failed to add secret"
        exit 1
    }

    echo ""
    log "✓ Secret $name added successfully"
    log "  Organization: $GITHUB_ORG"
    log "  Visibility: All repositories"
    log "  Encrypted: Yes (AES-256-GCM)"
}

action_update() {
    local name="$1"

    if [[ -z "$name" ]]; then
        error "Missing secret name"
        echo "Usage: $0 update SECRET_NAME"
        exit 1
    fi

    info "Updating secret: $name"
    echo ""

    # Prompt for new value
    read -sp "Enter new value for $name: " value
    echo ""

    if [[ -z "$value" ]]; then
        error "Secret value cannot be empty"
        exit 1
    fi

    # Update secret
    echo "$value" | gh secret set "$name" --org "$GITHUB_ORG" || {
        error "Failed to update secret"
        exit 1
    }

    echo ""
    log "✓ Secret $name updated successfully"
    log "  Last Updated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    warn "Reminder: Test the new key in a workflow before revoking the old one."
}

action_delete() {
    local name="$1"

    if [[ -z "$name" ]]; then
        error "Missing secret name"
        echo "Usage: $0 delete SECRET_NAME"
        exit 1
    fi

    warn "⚠️  WARNING: This will permanently delete $name"
    echo ""

    read -p "Are you sure you want to delete this secret? (y/N): " confirm

    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        info "Deletion cancelled"
        exit 0
    fi

    # Delete secret
    gh secret delete "$name" --org "$GITHUB_ORG" || {
        error "Failed to delete secret"
        exit 1
    }

    log "✓ Secret $name deleted successfully"
}

action_rotate() {
    local name="$1"

    if [[ -z "$name" ]]; then
        error "Missing secret name"
        echo "Usage: $0 rotate SECRET_NAME"
        exit 1
    fi

    info "Secret Rotation Guide for $name"
    echo ""
    echo "Step 1: Generate new API key"
    echo "  - Visit the appropriate service console"
    echo "  - Generate new API key"
    echo "  - Copy new key value"
    echo ""
    echo "Step 2: Update GitHub Secret"
    echo "  Run: gh secret set $name --org $GITHUB_ORG"
    echo ""
    echo "Step 3: Test new key"
    echo "  - Trigger test workflow"
    echo "  - Monitor for errors"
    echo ""
    echo "Step 4: Revoke old key"
    echo "  - Return to service console"
    echo "  - Revoke previous key"
    echo ""

    read -p "Would you like to update the secret now? (y/N): " update

    if [[ "$update" == "y" || "$update" == "Y" ]]; then
        action_update "$name"
    else
        info "Rotation guide displayed. Update secret when ready."
    fi

    log "✓ Rotation process initiated"
    log "  Next rotation due: $(date -u -d '+90 days' +%Y-%m-%d) (90 days)"
}

# Main
ACTION="${1:-help}"

case $ACTION in
    list)
        action_list
        ;;
    add)
        action_add "${2:-}"
        ;;
    update)
        action_update "${2:-}"
        ;;
    delete)
        action_delete "${2:-}"
        ;;
    rotate)
        action_rotate "${2:-}"
        ;;
    help|-h|--help)
        show_help
        ;;
    *)
        error "Unknown action: $ACTION"
        echo ""
        show_help
        exit 1
        ;;
esac

exit 0
