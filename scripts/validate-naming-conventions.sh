#!/bin/bash
# Naming Conventions Validation Script
# Validates files, branches, and commits against Seven Fortunas naming standards

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VIOLATIONS_FILE="$PROJECT_ROOT/naming-violations.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Logging
log_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED_CHECKS++))
}

log_fail() {
    echo -e "${RED}✗${NC} $1"
    echo "$1" >> "$VIOLATIONS_FILE"
    ((FAILED_CHECKS++))
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

init_validation() {
    echo "=== Seven Fortunas Naming Convention Validation ===" > "$VIOLATIONS_FILE"
    echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$VIOLATIONS_FILE"
    echo "" >> "$VIOLATIONS_FILE"
}

# 1. Validate script names (kebab-case.ext)
validate_scripts() {
    log_info "Validating script names..."
    ((TOTAL_CHECKS++))

    local violations=0
    local script_pattern='^[a-z0-9]+(-[a-z0-9]+)*\.(sh|py|js|ts)$'

    for script in "$PROJECT_ROOT/scripts"/*; do
        if [ -f "$script" ]; then
            local basename=$(basename "$script")

            # Skip special files
            if [[ "$basename" == "README.md" ]] || [[ "$basename" == ".gitkeep" ]]; then
                continue
            fi

            # Check pattern
            if [[ ! "$basename" =~ $script_pattern ]]; then
                # Check if it's a legacy snake_case file
                if [[ "$basename" =~ ^[a-z0-9]+(_[a-z0-9]+)*\.(sh|py|js|ts)$ ]]; then
                    log_warn "Legacy snake_case script: $basename (should be kebab-case)"
                else
                    log_fail "Invalid script name: $basename (must be kebab-case)"
                    ((violations++))
                fi
            fi
        fi
    done

    if [ $violations -eq 0 ]; then
        log_pass "Script naming conventions valid (kebab-case)"
    fi
}

# 2. Validate documentation names (kebab-case.md)
validate_docs() {
    log_info "Validating documentation names..."
    ((TOTAL_CHECKS++))

    local violations=0
    local doc_pattern='^([A-Z]+\.md|[a-z0-9]+(-[a-z0-9]+)*\.md)$'

    if [ -d "$PROJECT_ROOT/docs" ]; then
        for doc in "$PROJECT_ROOT/docs"/*.md; do
            if [ -f "$doc" ]; then
                local basename=$(basename "$doc")

                # Check pattern (allow README.md, CLAUDE.md, etc.)
                if [[ ! "$basename" =~ $doc_pattern ]]; then
                    log_fail "Invalid doc name: $basename (must be kebab-case.md or UPPERCASE.md)"
                    ((violations++))
                fi
            fi
        done
    fi

    if [ $violations -eq 0 ]; then
        log_pass "Documentation naming conventions valid"
    fi
}

# 3. Validate workflow names (kebab-case.yml)
validate_workflows() {
    log_info "Validating workflow names..."
    ((TOTAL_CHECKS++))

    local violations=0
    local workflow_pattern='^[a-z0-9]+(-[a-z0-9]+)*\.(yml|yaml)$'

    if [ -d "$PROJECT_ROOT/.github/workflows" ]; then
        for workflow in "$PROJECT_ROOT/.github/workflows"/*.yml "$PROJECT_ROOT/.github/workflows"/*.yaml; do
            if [ -f "$workflow" ]; then
                local basename=$(basename "$workflow")

                if [[ ! "$basename" =~ $workflow_pattern ]]; then
                    log_fail "Invalid workflow name: $basename (must be kebab-case.yml)"
                    ((violations++))
                fi
            fi
        done
    fi

    if [ $violations -eq 0 ]; then
        log_pass "Workflow naming conventions valid"
    fi
}

# 4. Validate current branch name
validate_branch() {
    log_info "Validating current branch name..."
    ((TOTAL_CHECKS++))

    local branch=$(git branch --show-current 2>/dev/null || echo "main")
    local branch_pattern='^(main|develop|feature/[a-z0-9-]+|fix/[a-z0-9-]+|docs/[a-z0-9-]+|refactor/[a-z0-9-]+|test/[a-z0-9-]+|release/[0-9.]+)$'

    if [[ "$branch" =~ $branch_pattern ]]; then
        log_pass "Branch name valid: $branch"
    else
        log_fail "Invalid branch name: $branch (must match type/description pattern)"
    fi
}

# 5. Validate recent commit messages
validate_commits() {
    log_info "Validating recent commit messages..."
    ((TOTAL_CHECKS++))

    local violations=0
    local commit_pattern='^(feat|fix|docs|style|refactor|test|chore)\([a-zA-Z0-9_-]+\): .+'

    # Check last 10 commits
    while IFS= read -r commit_msg; do
        if [[ ! "$commit_msg" =~ $commit_pattern ]]; then
            # Allow merge commits
            if [[ ! "$commit_msg" =~ ^Merge ]]; then
                log_warn "Non-conventional commit: ${commit_msg:0:60}..."
                ((violations++))
            fi
        fi
    done < <(git log -10 --pretty=format:%s 2>/dev/null || echo "")

    if [ $violations -eq 0 ]; then
        log_pass "Commit messages follow Conventional Commits format"
    else
        log_warn "$violations commit(s) don't follow Conventional Commits (last 10 checked)"
    fi
}

# 6. Validate data file names
validate_data_files() {
    log_info "Validating data file names..."
    ((TOTAL_CHECKS++))

    local violations=0
    local json_pattern='^[a-z0-9]+(-[a-z0-9]+)*\.json$'
    local yaml_pattern='^[a-z0-9]+(-[a-z0-9]+)*\.(yml|yaml)$'

    # Check root level data files
    for file in "$PROJECT_ROOT"/*.json; do
        if [ -f "$file" ]; then
            local basename=$(basename "$file")

            # Skip package.json and other standard files
            if [[ "$basename" == "package.json" ]] || [[ "$basename" == "package-lock.json" ]] || [[ "$basename" == "tsconfig.json" ]]; then
                continue
            fi

            if [[ ! "$basename" =~ $json_pattern ]]; then
                log_fail "Invalid JSON file name: $basename (must be kebab-case.json)"
                ((violations++))
            fi
        fi
    done

    if [ $violations -eq 0 ]; then
        log_pass "Data file naming conventions valid"
    fi
}

# 7. Validate directory names
validate_directories() {
    log_info "Validating directory names..."
    ((TOTAL_CHECKS++))

    local violations=0
    local dir_pattern='^(\.|_)?[a-z0-9]+(-[a-z0-9]+)*$'

    for dir in "$PROJECT_ROOT"/*; do
        if [ -d "$dir" ]; then
            local basename=$(basename "$dir")

            # Skip hidden and special directories
            if [[ "$basename" == "."* ]] || [[ "$basename" == "_bmad"* ]] || [[ "$basename" == "node_modules" ]]; then
                continue
            fi

            if [[ ! "$basename" =~ $dir_pattern ]]; then
                log_fail "Invalid directory name: $basename (must be kebab-case)"
                ((violations++))
            fi
        fi
    done

    if [ $violations -eq 0 ]; then
        log_pass "Directory naming conventions valid"
    fi
}

# 8. Validate feature IDs in feature_list.json
validate_feature_ids() {
    log_info "Validating feature IDs..."
    ((TOTAL_CHECKS++))

    local violations=0

    if [ -f "$PROJECT_ROOT/feature_list.json" ]; then
        local feature_pattern='^(FEATURE_[0-9]{3}|NFR-[0-9]+\.[0-9]+)$'

        while IFS= read -r feature_id; do
            if [[ ! "$feature_id" =~ $feature_pattern ]]; then
                log_fail "Invalid feature ID: $feature_id (must be FEATURE_NNN or NFR-N.N)"
                ((violations++))
            fi
        done < <(jq -r '.features[].id' "$PROJECT_ROOT/feature_list.json" 2>/dev/null || echo "")

        if [ $violations -eq 0 ]; then
            log_pass "Feature IDs follow naming convention"
        fi
    else
        log_warn "feature_list.json not found, skipping feature ID validation"
    fi
}

# Generate report
generate_report() {
    echo ""
    echo "=== Validation Summary ==="
    echo "Total checks: $TOTAL_CHECKS"
    echo -e "${GREEN}Passed: $PASSED_CHECKS${NC}"
    echo -e "${RED}Failed: $FAILED_CHECKS${NC}"
    echo ""

    if [ $FAILED_CHECKS -eq 0 ]; then
        echo -e "${GREEN}✓ All naming conventions validated successfully!${NC}"
        echo ""
        echo "Violations log: $VIOLATIONS_FILE (no violations found)"
        return 0
    else
        echo -e "${RED}✗ Naming convention violations detected${NC}"
        echo "Review violations log: $VIOLATIONS_FILE"
        echo ""
        echo "To fix violations, refer to docs/naming-conventions.md"
        return 1
    fi
}

# Main execution
main() {
    log_info "Starting naming convention validation..."
    echo ""

    init_validation

    validate_scripts
    validate_docs
    validate_workflows
    validate_branch
    validate_commits
    validate_data_files
    validate_directories
    validate_feature_ids

    echo ""
    generate_report
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    cd "$PROJECT_ROOT"
    main "$@"
fi
