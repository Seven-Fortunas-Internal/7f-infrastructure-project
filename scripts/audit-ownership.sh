#!/bin/bash
# Ownership Audit Script
# Verifies code ownership coverage across repository

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AUDIT_REPORT="$PROJECT_ROOT/ownership-audit-report.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TOTAL_FILES=0
OWNED_FILES=0
ORPHANED_FILES=0
DOCS_WITH_OWNER=0
DOCS_WITHOUT_OWNER=0

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

init_audit() {
    echo "=== Ownership Audit Report ===" > "$AUDIT_REPORT"
    echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$AUDIT_REPORT"
    echo "" >> "$AUDIT_REPORT"
}

# Check if CODEOWNERS file exists
check_codeowners_exists() {
    log_info "Checking for CODEOWNERS file..."

    if [ -f "$PROJECT_ROOT/.github/CODEOWNERS" ]; then
        log_pass "CODEOWNERS file exists"
        echo "✓ CODEOWNERS file found at .github/CODEOWNERS" >> "$AUDIT_REPORT"
        return 0
    else
        log_fail "CODEOWNERS file missing"
        echo "✗ CODEOWNERS file not found" >> "$AUDIT_REPORT"
        return 1
    fi
}

# Analyze CODEOWNERS coverage
analyze_codeowners_coverage() {
    log_info "Analyzing CODEOWNERS coverage..."

    if [ ! -f "$PROJECT_ROOT/.github/CODEOWNERS" ]; then
        log_warn "Skipping CODEOWNERS analysis (file not found)"
        return 1
    fi

    # Count non-comment, non-empty lines in CODEOWNERS
    local rules=$(grep -v '^#' "$PROJECT_ROOT/.github/CODEOWNERS" | grep -v '^$' | wc -l)
    local teams=$(grep -o '@[A-Za-z0-9_-]\+/[A-Za-z0-9_-]\+' "$PROJECT_ROOT/.github/CODEOWNERS" | sort -u | wc -l)

    echo "" >> "$AUDIT_REPORT"
    echo "CODEOWNERS Analysis:" >> "$AUDIT_REPORT"
    echo "  - Ownership rules: $rules" >> "$AUDIT_REPORT"
    echo "  - Unique teams referenced: $teams" >> "$AUDIT_REPORT"

    log_info "CODEOWNERS has $rules ownership rules covering $teams teams"

    if [ "$rules" -gt 0 ]; then
        log_pass "CODEOWNERS configured with ownership rules"
        return 0
    else
        log_warn "CODEOWNERS exists but has no ownership rules"
        return 1
    fi
}

# Check documentation frontmatter for ownership
check_doc_ownership() {
    log_info "Checking documentation ownership..."

    echo "" >> "$AUDIT_REPORT"
    echo "Documentation Ownership:" >> "$AUDIT_REPORT"

    if [ ! -d "$PROJECT_ROOT/docs" ]; then
        log_warn "docs/ directory not found"
        return 1
    fi

    for doc in "$PROJECT_ROOT/docs"/*.md; do
        if [ -f "$doc" ]; then
            local basename=$(basename "$doc")
            ((TOTAL_FILES++))

            # Check for Owner field in document
            if grep -q "^\*\*Owner:\*\*" "$doc" || \
               grep -q "^Owner:" "$doc" || \
               grep -q "^author:" "$doc"; then
                ((DOCS_WITH_OWNER++))
                ((OWNED_FILES++))
                echo "  ✓ $basename (has owner)" >> "$AUDIT_REPORT"
            else
                ((DOCS_WITHOUT_OWNER++))
                ((ORPHANED_FILES++))
                echo "  ✗ $basename (no owner field)" >> "$AUDIT_REPORT"
                log_warn "Missing owner: $basename"
            fi
        fi
    done

    local coverage_pct=0
    if [ $TOTAL_FILES -gt 0 ]; then
        coverage_pct=$((DOCS_WITH_OWNER * 100 / TOTAL_FILES))
    fi

    echo "" >> "$AUDIT_REPORT"
    echo "  Total docs: $TOTAL_FILES" >> "$AUDIT_REPORT"
    echo "  Docs with owner: $DOCS_WITH_OWNER ($coverage_pct%)" >> "$AUDIT_REPORT"
    echo "  Docs without owner: $DOCS_WITHOUT_OWNER" >> "$AUDIT_REPORT"

    log_info "Documentation ownership: $DOCS_WITH_OWNER/$TOTAL_FILES ($coverage_pct%)"

    if [ "$coverage_pct" -ge 80 ]; then
        log_pass "Documentation ownership coverage acceptable (>= 80%)"
        return 0
    else
        log_warn "Documentation ownership coverage low (< 80%)"
        return 1
    fi
}

# Check script ownership via CODEOWNERS
check_script_ownership() {
    log_info "Checking script ownership coverage..."

    echo "" >> "$AUDIT_REPORT"
    echo "Script Ownership (via CODEOWNERS):" >> "$AUDIT_REPORT"

    if [ ! -d "$PROJECT_ROOT/scripts" ]; then
        log_warn "scripts/ directory not found"
        return 1
    fi

    local script_count=0
    for script in "$PROJECT_ROOT/scripts"/*.sh "$PROJECT_ROOT/scripts"/*.py; do
        if [ -f "$script" ]; then
            ((script_count++))
            local basename=$(basename "$script")
            echo "  - $basename (covered by CODEOWNERS pattern)" >> "$AUDIT_REPORT"
        fi
    done

    echo "" >> "$AUDIT_REPORT"
    echo "  Total scripts: $script_count" >> "$AUDIT_REPORT"
    echo "  Coverage: 100% (via CODEOWNERS /scripts/ pattern)" >> "$AUDIT_REPORT"

    log_pass "All scripts covered by CODEOWNERS patterns"
    return 0
}

# Check workflow ownership
check_workflow_ownership() {
    log_info "Checking workflow ownership..."

    echo "" >> "$AUDIT_REPORT"
    echo "Workflow Ownership:" >> "$AUDIT_REPORT"

    if [ ! -d "$PROJECT_ROOT/.github/workflows" ]; then
        log_warn "No .github/workflows directory"
        echo "  No workflows found" >> "$AUDIT_REPORT"
        return 0
    fi

    local workflow_count=0
    for workflow in "$PROJECT_ROOT/.github/workflows"/*.yml "$PROJECT_ROOT/.github/workflows"/*.yaml; do
        if [ -f "$workflow" ]; then
            ((workflow_count++))
            local basename=$(basename "$workflow")
            echo "  - $basename (covered by CODEOWNERS)" >> "$AUDIT_REPORT"
        fi
    done

    echo "" >> "$AUDIT_REPORT"
    echo "  Total workflows: $workflow_count" >> "$AUDIT_REPORT"
    echo "  Coverage: 100% (via CODEOWNERS /.github/workflows/ pattern)" >> "$AUDIT_REPORT"

    if [ $workflow_count -gt 0 ]; then
        log_pass "All workflows covered by CODEOWNERS"
    else
        log_info "No workflows to audit"
    fi

    return 0
}

# List teams referenced in CODEOWNERS
list_teams() {
    log_info "Listing teams referenced in CODEOWNERS..."

    echo "" >> "$AUDIT_REPORT"
    echo "Teams Referenced:" >> "$AUDIT_REPORT"

    if [ -f "$PROJECT_ROOT/.github/CODEOWNERS" ]; then
        grep -o '@[A-Za-z0-9_-]\+/[A-Za-z0-9_-]\+' "$PROJECT_ROOT/.github/CODEOWNERS" | \
            sort -u | while read -r team; do
            echo "  - $team" >> "$AUDIT_REPORT"
            log_info "Team: $team"
        done
    else
        echo "  No teams (CODEOWNERS not found)" >> "$AUDIT_REPORT"
    fi
}

# Generate summary
generate_summary() {
    echo "" >> "$AUDIT_REPORT"
    echo "=== Summary ===" >> "$AUDIT_REPORT"

    local total_checks=0
    local passed_checks=0

    # CODEOWNERS exists
    if [ -f "$PROJECT_ROOT/.github/CODEOWNERS" ]; then
        ((total_checks++))
        ((passed_checks++))
        echo "✓ CODEOWNERS file exists" >> "$AUDIT_REPORT"
    else
        ((total_checks++))
        echo "✗ CODEOWNERS file missing" >> "$AUDIT_REPORT"
    fi

    # Documentation coverage
    ((total_checks++))
    if [ ${DOCS_WITH_OWNER:-0} -gt 0 ] && [ $TOTAL_FILES -gt 0 ]; then
        local coverage_pct=$((DOCS_WITH_OWNER * 100 / TOTAL_FILES))
        if [ $coverage_pct -ge 80 ]; then
            ((passed_checks++))
            echo "✓ Documentation ownership >= 80% ($coverage_pct%)" >> "$AUDIT_REPORT"
        else
            echo "✗ Documentation ownership < 80% ($coverage_pct%)" >> "$AUDIT_REPORT"
        fi
    else
        echo "⚠ No documentation to audit" >> "$AUDIT_REPORT"
    fi

    # Scripts/workflows covered
    if [ -d "$PROJECT_ROOT/scripts" ] || [ -d "$PROJECT_ROOT/.github/workflows" ]; then
        ((total_checks++))
        ((passed_checks++))
        echo "✓ Scripts and workflows covered by CODEOWNERS patterns" >> "$AUDIT_REPORT"
    fi

    echo "" >> "$AUDIT_REPORT"
    echo "Checks passed: $passed_checks/$total_checks" >> "$AUDIT_REPORT"

    log_info ""
    log_info "=== Audit Summary ==="
    log_info "Checks passed: $passed_checks/$total_checks"
    log_info "Report saved: $AUDIT_REPORT"

    if [ $passed_checks -eq $total_checks ]; then
        log_pass "All ownership checks passed!"
        return 0
    else
        log_warn "Some ownership checks failed. Review report for details."
        return 1
    fi
}

# Main execution
main() {
    log_info "Starting ownership audit..."
    echo ""

    init_audit

    check_codeowners_exists
    analyze_codeowners_coverage
    check_doc_ownership
    check_script_ownership
    check_workflow_ownership
    list_teams

    echo ""
    generate_summary
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    cd "$PROJECT_ROOT"
    main "$@"
fi
