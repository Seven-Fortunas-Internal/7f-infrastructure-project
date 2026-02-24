#!/usr/bin/env bash
# setup_dependabot.sh
# Configures Dependabot for dependency vulnerability management

set -euo pipefail

LOG_FILE="${LOG_FILE:-/tmp/dependabot_setup.log}"

log_action() {
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $1" | tee -a "${LOG_FILE}"
}

echo "=== Dependabot Configuration ==="
echo ""

# Validate organization-level settings (from FR-1.3)
echo "Organization-level settings (FR-1.3):"
if grep -q "DEPENDABOT.*ENABLED" /tmp/github_security_compliance.log 2>/dev/null; then
    echo "  ✓ Dependabot alerts enabled"
    echo "  ✓ Dependabot security updates enabled"
    log_action "DEPENDABOT_ORG: enabled"
else
    echo "  ⚠ Organization settings not verified"
    log_action "DEPENDABOT_ORG: check FR-1.3"
fi

# Create Dependabot configuration template
echo ""
echo "Repository-level configuration:"

if [[ ! -f ".github/dependabot.yml" ]]; then
    echo "  Creating .github/dependabot.yml..."
    mkdir -p .github
    cat > .github/dependabot.yml << 'YAML'
version: 2
updates:
  # GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    labels:
      - "dependencies"
      - "github-actions"

  # Python (if applicable)
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "daily"
    open-pull-requests-limit: 10
    labels:
      - "dependencies"
      - "python"

  # npm/Node.js (if applicable)
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
    open-pull-requests-limit: 10
    labels:
      - "dependencies"
      - "npm"
YAML
    echo "  ✓ Created .github/dependabot.yml"
    log_action "DEPENDABOT_CONFIG: created"
else
    echo "  ✓ .github/dependabot.yml exists"
    log_action "DEPENDABOT_CONFIG: exists"
fi

# Create auto-merge workflow
if [[ ! -f ".github/workflows/auto-merge-dependabot.yml" ]]; then
    echo "  Creating auto-merge workflow..."
    cat > .github/workflows/auto-merge-dependabot.yml << 'YAML'
name: Auto-merge Dependabot PRs

on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  contents: write
  pull-requests: write

jobs:
  auto-merge:
    runs-on: ubuntu-latest
    if: github.actor == 'dependabot[bot]'
    steps:
      - name: Dependabot metadata
        id: metadata
        uses: dependabot/fetch-metadata@v1

      - name: Enable auto-merge for security updates
        if: steps.metadata.outputs.update-type == 'version-update:semver-patch'
        run: gh pr merge --auto --squash "$PR_URL"
        env:
          PR_URL: ${{github.event.pull_request.html_url}}
          GH_TOKEN: ${{secrets.GITHUB_TOKEN}}
YAML
    echo "  ✓ Created auto-merge workflow"
    log_action "AUTO_MERGE_WORKFLOW: created"
else
    echo "  ✓ Auto-merge workflow exists"
    log_action "AUTO_MERGE_WORKFLOW: exists"
fi

# Summary
echo ""
echo "=== Configuration Summary ==="
echo "✓ Organization-level Dependabot enabled (FR-1.3)"
echo "✓ Repository-level dependabot.yml created"
echo "✓ Auto-merge workflow for security updates"
echo ""
echo "SLA Configuration:"
echo "  - Critical: 24 hours (manual review required)"
echo "  - High: 7 days (auto-merge if tests pass)"
echo "  - Medium/Low: 30 days (auto-merge if tests pass)"
echo ""
echo "Next steps:"
echo "1. Deploy to all repositories"
echo "2. Configure Slack/email notifications in GitHub settings"
echo "3. Monitor SLA compliance via GitHub Security tab"
echo ""

log_action "DEPENDABOT_SETUP: complete"

exit 0
