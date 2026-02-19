#!/bin/bash
# README Coverage Validator
# Checks that README.md exists at every directory level

set -e

echo "=== README Coverage Validator ==="

# Configuration
ROOT_DIR="${1:-.}"
MISSING_READMES=()
TOTAL_DIRS=0
COVERED_DIRS=0

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check directory for README
check_directory() {
    local dir="$1"
    TOTAL_DIRS=$((TOTAL_DIRS + 1))

    # Skip hidden directories (except .github)
    if [[ "$(basename "$dir")" == .* ]] && [[ "$(basename "$dir")" != ".github" ]]; then
        return
    fi

    # Skip common build/dependency directories
    case "$(basename "$dir")" in
        node_modules|venv|__pycache__|.git|.pytest_cache|.mypy_cache|dist|build)
            return
            ;;
    esac

    # Check for README.md
    if [[ -f "$dir/README.md" ]]; then
        COVERED_DIRS=$((COVERED_DIRS + 1))
        echo -e "${GREEN}✓${NC} $dir"
    else
        MISSING_READMES+=("$dir")
        echo -e "${RED}✗${NC} $dir - Missing README.md"
    fi
}

# Recursively check all directories
echo "Scanning directories..."
echo ""

while IFS= read -r -d '' dir; do
    check_directory "$dir"
done < <(find "$ROOT_DIR" -type d -print0)

# Summary
echo ""
echo "=== Summary ==="
echo "Total directories: $TOTAL_DIRS"
echo "Covered with README: $COVERED_DIRS"
echo "Missing README: ${#MISSING_READMES[@]}"

if [[ ${#MISSING_READMES[@]} -eq 0 ]]; then
    echo -e "${GREEN}✓ All directories have README.md${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠  ${#MISSING_READMES[@]} directories missing README.md${NC}"
    echo ""
    echo "Missing READMEs:"
    for dir in "${MISSING_READMES[@]}"; do
        echo "  - $dir"
    done
    exit 1
fi
