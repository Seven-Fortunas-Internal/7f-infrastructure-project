#!/usr/bin/env bash
# validate-readmes.sh
# Validates that README.md exists at root and all directories

set -euo pipefail

# Configuration
TARGET_DIR="${TARGET_DIR:-.}"
VERBOSE="${VERBOSE:-false}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TOTAL_DIRS=0
DIRS_WITH_README=0
DIRS_WITHOUT_README=0
BROKEN_LINKS=0

echo -e "${BLUE}=== README.md Validation ===${NC}"
echo "Target directory: ${TARGET_DIR}"
echo ""

# Check root README
if [ -f "${TARGET_DIR}/README.md" ]; then
    echo -e "${GREEN}✓ Root README.md exists${NC}"
else
    echo -e "${RED}✗ Root README.md missing${NC}"
    exit 1
fi

# Find all directories (excluding .git, node_modules, venv, etc.)
echo ""
echo -e "${BLUE}Checking directories...${NC}"

DIRS=$(find "${TARGET_DIR}" -type d \
    -not -path "*/\.*" \
    -not -path "*/node_modules/*" \
    -not -path "*/venv/*" \
    -not -path "*/env/*" \
    -not -path "*/__pycache__/*" \
    -not -path "*/dist/*" \
    -not -path "*/build/*" | sort)

MISSING_READMES=()

for DIR in $DIRS; do
    TOTAL_DIRS=$((TOTAL_DIRS + 1))
    
    if [ -f "${DIR}/README.md" ]; then
        DIRS_WITH_README=$((DIRS_WITH_README + 1))
        
        if [ "$VERBOSE" = "true" ]; then
            echo -e "  ${GREEN}✓${NC} ${DIR}/README.md"
        fi
    else
        DIRS_WITHOUT_README=$((DIRS_WITHOUT_README + 1))
        MISSING_READMES+=("${DIR}")
        
        echo -e "  ${RED}✗${NC} ${DIR}/README.md ${RED}(missing)${NC}"
    fi
done

# Summary
echo ""
echo -e "${BLUE}=== Summary ===${NC}"
echo "Total directories: ${TOTAL_DIRS}"
echo -e "${GREEN}Directories with README: ${DIRS_WITH_README}${NC}"
echo -e "${RED}Directories without README: ${DIRS_WITHOUT_README}${NC}"

if [ ${DIRS_WITHOUT_README} -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ All directories have README.md${NC}"
    VALIDATION_PASSED=true
else
    echo ""
    echo -e "${YELLOW}⚠️  Some directories are missing README.md${NC}"
    echo ""
    echo "Missing READMEs:"
    for DIR in "${MISSING_READMES[@]}"; do
        echo "  - ${DIR}/README.md"
    done
    VALIDATION_PASSED=false
fi

# Link validation (optional)
if command -v markdown-link-check &> /dev/null; then
    echo ""
    echo -e "${BLUE}=== Checking links in README files ===${NC}"
    
    for DIR in $DIRS; do
        if [ -f "${DIR}/README.md" ]; then
            if markdown-link-check "${DIR}/README.md" &>/dev/null; then
                if [ "$VERBOSE" = "true" ]; then
                    echo -e "  ${GREEN}✓${NC} ${DIR}/README.md - links valid"
                fi
            else
                echo -e "  ${YELLOW}⚠️${NC} ${DIR}/README.md - broken links detected"
                BROKEN_LINKS=$((BROKEN_LINKS + 1))
            fi
        fi
    done
    
    if [ ${BROKEN_LINKS} -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}⚠️  ${BROKEN_LINKS} README files have broken links${NC}"
        VALIDATION_PASSED=false
    fi
else
    if [ "$VERBOSE" = "true" ]; then
        echo ""
        echo -e "${YELLOW}⚠️  markdown-link-check not installed, skipping link validation${NC}"
        echo "Install with: npm install -g markdown-link-check"
    fi
fi

# Template structure validation
echo ""
echo -e "${BLUE}=== Checking template structure ===${NC}"

check_template_structure() {
    local file="$1"
    local required_sections=("$@")
    shift
    
    local missing_sections=()
    
    for section in "${required_sections[@]}"; do
        if ! grep -q "^## ${section}" "$file"; then
            missing_sections+=("${section}")
        fi
    done
    
    if [ ${#missing_sections[@]} -eq 0 ]; then
        if [ "$VERBOSE" = "true" ]; then
            echo -e "  ${GREEN}✓${NC} ${file} - template structure valid"
        fi
        return 0
    else
        echo -e "  ${YELLOW}⚠️${NC} ${file} - missing sections: ${missing_sections[*]}"
        return 1
    fi
}

# Check root README structure
ROOT_SECTIONS=("Overview" "Quick Start" "Project Structure" "Documentation")
if check_template_structure "${TARGET_DIR}/README.md" "${ROOT_SECTIONS[@]}"; then
    :
else
    VALIDATION_PASSED=false
fi

# Exit
echo ""
if [ "$VALIDATION_PASSED" = true ]; then
    echo -e "${GREEN}✅ README validation passed${NC}"
    exit 0
else
    echo -e "${RED}❌ README validation failed${NC}"
    exit 1
fi
