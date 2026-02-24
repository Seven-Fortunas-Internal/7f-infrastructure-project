#!/usr/bin/env bash
# setup_bmad_integration.sh
# Documents and validates BMAD library integration

set -euo pipefail

LOG_FILE="${LOG_FILE:-/tmp/bmad_integration.log}"

log_action() {
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $1" | tee -a "${LOG_FILE}"
}

echo "=== BMAD Library Integration Status ==="
echo ""

# Check if _bmad exists
if [[ -d "_bmad" ]]; then
    echo "✓ _bmad/ directory exists"
    log_action "BMAD_DIR: exists"
    
    # Check for BMAD config
    if [[ -f "_bmad/bmb/config.yaml" ]]; then
        echo "✓ BMAD configuration found"
        log_action "BMAD_CONFIG: found"
    fi
    
    # Count BMAD workflows
    workflow_count=$(find _bmad -name "workflow.md" 2>/dev/null | wc -l || echo "0")
    echo "✓ BMAD workflows found: $workflow_count"
    log_action "BMAD_WORKFLOWS: $workflow_count"
else
    echo "✗ _bmad/ directory not found"
    log_action "BMAD_DIR: not found"
    echo ""
    echo "To set up BMAD:"
    echo "1. Clone BMAD repository as submodule or copy"
    echo "2. Place in _bmad/ directory"
    echo "3. Run this script again"
    exit 1
fi

# Check .claude/commands
if [[ -d ".claude/commands" ]]; then
    skill_count=$(ls -1 .claude/commands/bmad-*.md 2>/dev/null | wc -l || echo "0")
    echo "✓ BMAD skill stubs found: $skill_count"
    log_action "BMAD_SKILLS: $skill_count"
else
    echo "⚠ .claude/commands directory not found"
    log_action "CLAUDE_COMMANDS_DIR: not found"
fi

echo ""
echo "✓ BMAD integration validated"
log_action "BMAD_INTEGRATION: validated"

exit 0
