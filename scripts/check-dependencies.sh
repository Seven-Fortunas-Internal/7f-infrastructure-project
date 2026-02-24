#!/bin/bash
# Dependency Version Check Script
# Validates all required dependencies meet minimum version requirements

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0

# Minimum versions
MIN_GIT_VERSION="2.30.0"
MIN_GH_VERSION="2.20.0"
MIN_JQ_VERSION="1.6"
MIN_PYTHON_VERSION="3.8"
MIN_BASH_VERSION="4.4"
MIN_CURL_VERSION="7.68.0"

# Version comparison function
version_ge() {
    printf '%s\n%s' "$2" "$1" | sort -V -C
}

check_git() {
    if command -v git &>/dev/null; then
        local version=$(git --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        if version_ge "$version" "$MIN_GIT_VERSION"; then
            echo -e "${GREEN}✓${NC} Git: $version (>= $MIN_GIT_VERSION)"
            ((CHECKS_PASSED++))
            return 0
        else
            echo -e "${RED}✗${NC} Git: $version (< $MIN_GIT_VERSION required)"
            ((CHECKS_FAILED++))
            return 1
        fi
    else
        echo -e "${RED}✗${NC} Git: not installed"
        ((CHECKS_FAILED++))
        return 1
    fi
}

check_gh() {
    if command -v gh &>/dev/null; then
        local version=$(gh --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        if version_ge "$version" "$MIN_GH_VERSION"; then
            echo -e "${GREEN}✓${NC} GitHub CLI: $version (>= $MIN_GH_VERSION)"
            ((CHECKS_PASSED++))
            return 0
        else
            echo -e "${RED}✗${NC} GitHub CLI: $version (< $MIN_GH_VERSION required)"
            ((CHECKS_FAILED++))
            return 1
        fi
    else
        echo -e "${RED}✗${NC} GitHub CLI: not installed"
        ((CHECKS_FAILED++))
        return 1
    fi
}

check_jq() {
    if command -v jq &>/dev/null; then
        local version=$(jq --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
        if version_ge "$version" "$MIN_JQ_VERSION"; then
            echo -e "${GREEN}✓${NC} jq: $version (>= $MIN_JQ_VERSION)"
            ((CHECKS_PASSED++))
            return 0
        else
            echo -e "${RED}✗${NC} jq: $version (< $MIN_JQ_VERSION required)"
            ((CHECKS_FAILED++))
            return 1
        fi
    else
        echo -e "${RED}✗${NC} jq: not installed"
        ((CHECKS_FAILED++))
        return 1
    fi
}

check_python() {
    if command -v python3 &>/dev/null; then
        local version=$(python3 --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
        if version_ge "$version" "$MIN_PYTHON_VERSION"; then
            echo -e "${GREEN}✓${NC} Python: $version (>= $MIN_PYTHON_VERSION)"
            ((CHECKS_PASSED++))
            return 0
        else
            echo -e "${RED}✗${NC} Python: $version (< $MIN_PYTHON_VERSION required)"
            ((CHECKS_FAILED++))
            return 1
        fi
    else
        echo -e "${RED}✗${NC} Python: not installed"
        ((CHECKS_FAILED++))
        return 1
    fi
}

check_bash() {
    local version=$(bash --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    if version_ge "$version" "$MIN_BASH_VERSION"; then
        echo -e "${GREEN}✓${NC} Bash: $version (>= $MIN_BASH_VERSION)"
        ((CHECKS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} Bash: $version (< $MIN_BASH_VERSION required)"
        ((CHECKS_FAILED++))
        return 1
    fi
}

check_curl() {
    if command -v curl &>/dev/null; then
        local version=$(curl --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        if version_ge "$version" "$MIN_CURL_VERSION"; then
            echo -e "${GREEN}✓${NC} curl: $version (>= $MIN_CURL_VERSION)"
            ((CHECKS_PASSED++))
            return 0
        else
            echo -e "${RED}✗${NC} curl: $version (< $MIN_CURL_VERSION required)"
            ((CHECKS_FAILED++))
            return 1
        fi
    else
        echo -e "${RED}✗${NC} curl: not installed"
        ((CHECKS_FAILED++))
        return 1
    fi
}

check_bmad() {
    if [ -d "$PROJECT_ROOT/_bmad" ]; then
        echo -e "${GREEN}✓${NC} BMAD: Library present in _bmad/"
        ((CHECKS_PASSED++))
        return 0
    else
        echo -e "${YELLOW}⚠${NC} BMAD: Library not found in _bmad/"
        return 0  # Non-critical - may not be needed in all environments
    fi
}

main() {
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

    echo "=== Seven Fortunas Dependency Check ==="
    echo ""

    check_git
    check_gh
    check_jq
    check_python
    check_bash
    check_curl
    check_bmad

    echo ""
    echo "=== Summary ==="
    echo -e "Passed: ${GREEN}$CHECKS_PASSED${NC}"
    echo -e "Failed: ${RED}$CHECKS_FAILED${NC}"
    echo ""

    if [ $CHECKS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ All dependencies meet minimum requirements${NC}"
        return 0
    else
        echo -e "${RED}✗ Some dependencies below minimum versions${NC}"
        echo ""
        echo "See DEPENDENCIES.md for installation instructions"
        return 1
    fi
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
