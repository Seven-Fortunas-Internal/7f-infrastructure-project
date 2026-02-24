#!/bin/bash
# Generate README.md files at every directory level
# FEATURE_023: FR-6.1: Self-Documenting Architecture

set -euo pipefail

PROJECT_ROOT="${1:-.}"
TEMPLATE_DIR="/home/ladmin/dev/GDF/7F_github/templates"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Generating README.md files at every directory level...${NC}"
echo "Project root: $PROJECT_ROOT"
echo ""

CREATED_COUNT=0
SKIPPED_COUNT=0

# Find all directories (excluding .git, node_modules, etc.)
while IFS= read -r -d '' dir; do
    # Skip excluded directories
    if [[ "$dir" == *"/.git"* ]] || \
       [[ "$dir" == *"/node_modules"* ]] || \
       [[ "$dir" == *"/.venv"* ]] || \
       [[ "$dir" == *"/__pycache__"* ]] || \
       [[ "$dir" == *"/dist"* ]] || \
       [[ "$dir" == *"/build"* ]]; then
        continue
    fi

    README_PATH="$dir/README.md"

    # Skip if README already exists
    if [ -f "$README_PATH" ]; then
        echo -e "  ${GREEN}✓${NC} $dir (README already exists)"
        ((SKIPPED_COUNT++))
        continue
    fi

    # Get directory name and parent
    DIR_NAME=$(basename "$dir")
    PARENT_DIR=$(dirname "$dir" | sed "s|^$PROJECT_ROOT/||")

    # Determine directory type and purpose
    PURPOSE=""
    case "$DIR_NAME" in
        scripts)
            PURPOSE="Automation scripts and utilities for project operations"
            ;;
        src)
            PURPOSE="Source code for the application"
            ;;
        tests)
            PURPOSE="Test files and test utilities"
            ;;
        docs)
            PURPOSE="Project documentation and guides"
            ;;
        templates)
            PURPOSE="Templates for code generation and scaffolding"
            ;;
        .claude)
            PURPOSE="Claude Code configuration and skills"
            ;;
        commands)
            PURPOSE="Claude Code skill stubs and command definitions"
            ;;
        _bmad*)
            PURPOSE="BMAD library workflows and utilities"
            ;;
        *)
            PURPOSE="TODO: Add description of this directory's purpose"
            ;;
    esac

    # Generate README content
    cat > "$README_PATH" << EOF
# $DIR_NAME

## Purpose

$PURPOSE

## Contents

<!-- List key files and subdirectories here -->

TODO: Document the contents of this directory

## Usage

<!-- Describe how to use the contents of this directory -->

TODO: Add usage instructions

---

**Parent:** [$PARENT_DIR](../)
**Last Updated:** $(date +%Y-%m-%d)
EOF

    echo -e "  ${BLUE}→${NC} Created README in $dir"
    ((CREATED_COUNT++))

done < <(find "$PROJECT_ROOT" -type d -print0 | sort -z)

echo ""
echo "==================================================================="
echo "Summary:"
echo "  Created:  $CREATED_COUNT READMEs"
echo "  Skipped:  $SKIPPED_COUNT (already exist)"
echo "==================================================================="
