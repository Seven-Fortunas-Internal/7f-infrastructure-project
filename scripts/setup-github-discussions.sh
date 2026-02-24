#!/bin/bash
# setup-github-discussions.sh - Enable and configure GitHub Discussions

set -euo pipefail

# Configuration
GITHUB_ORG="${GITHUB_ORG:-Seven-Fortunas-Internal}"
REPO="${REPO:-7f-infrastructure-project}"

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
setup-github-discussions.sh - Enable GitHub Discussions

Usage:
  $0 [options]

Options:
  --org NAME     GitHub organization (default: Seven-Fortunas-Internal)
  --repo NAME    Repository name (default: 7f-infrastructure-project)
  --help         Show this help message

Examples:
  $0
  $0 --org MyOrg --repo my-repo

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --org)
            GITHUB_ORG="$2"
            shift 2
            ;;
        --repo)
            REPO="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

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

FULL_REPO="$GITHUB_ORG/$REPO"

info "Enabling GitHub Discussions for $FULL_REPO..."
echo ""

# Enable discussions
gh repo edit "$FULL_REPO" --enable-discussions 2>/dev/null || {
    warn "Failed to enable discussions (may already be enabled or permission denied)"
}

# Verify discussions enabled
DISCUSSIONS_ENABLED=$(gh api "repos/$FULL_REPO" | jq -r '.has_discussions')

if [[ "$DISCUSSIONS_ENABLED" == "true" ]]; then
    log "✓ GitHub Discussions enabled"
else
    error "Failed to enable GitHub Discussions"
    error "Ensure you have admin permissions for: $FULL_REPO"
    exit 1
fi

# Display summary
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  GitHub Discussions Setup Complete"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Repository: $FULL_REPO"
echo "Discussions: Enabled"
echo ""
echo "NEXT STEPS:"
echo ""
echo "1. Create discussion categories:"
echo "   - Visit: https://github.com/$FULL_REPO/discussions/categories"
echo "   - Add categories: Announcements, General, Q&A, Ideas, Show and Tell"
echo ""
echo "2. Create your first discussion:"
echo "   gh discussion create \\"
echo "     --repo $FULL_REPO \\"
echo "     --category General \\"
echo "     --title 'Welcome to Seven Fortunas Discussions' \\"
echo "     --body 'Use this space for team communication'"
echo ""
echo "3. View discussions:"
echo "   https://github.com/$FULL_REPO/discussions"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""

exit 0
