#!/bin/bash
# Validate README.md coverage across all directories
# FEATURE_023: FR-6.1: Self-Documenting Architecture

set -euo pipefail

PROJECT_ROOT="${1:-.}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "==================================================================="
echo "README.md Coverage Validation"
echo "==================================================================="
echo "Project root: $PROJECT_ROOT"
echo ""

TOTAL_DIRS=0
WITH_README=0
WITHOUT_README=0

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

    ((TOTAL_DIRS++))

    README_PATH="$dir/README.md"

    if [ -f "$README_PATH" ]; then
        ((WITH_README++))
    else
        echo -e "${RED}✗${NC} Missing README: $dir"
        ((WITHOUT_README++))
    fi

done < <(find "$PROJECT_ROOT" -type d -print0 | sort -z)

echo ""
echo "==================================================================="
echo "Summary:"
echo "  Total directories:       $TOTAL_DIRS"
echo "  With README:             $WITH_README"
echo "  Without README:          $WITHOUT_README"
echo "  Coverage:                $(( WITH_README * 100 / TOTAL_DIRS ))%"
echo "==================================================================="

if [ $WITHOUT_README -eq 0 ]; then
    echo -e "${GREEN}✓ All directories have README.md files${NC}"
    exit 0
else
    echo -e "${RED}✗ $WITHOUT_README directories missing README.md${NC}"
    exit 1
fi
