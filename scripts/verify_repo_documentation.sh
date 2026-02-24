#!/bin/bash
# Repository Documentation Verification
# FEATURE_005: FR-1.5 Repository Creation & Documentation

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Repository Documentation Verification ==="

# MVP repositories to check
PUBLIC_REPOS=(
    "Seven-Fortunas/.github"
    "Seven-Fortunas/seven-fortunas.github.io"
    "Seven-Fortunas/dashboards"
    "Seven-Fortunas/second-brain-public"
)

PRIVATE_REPOS=(
    "Seven-Fortunas-Internal/.github"
    "Seven-Fortunas-Internal/internal-docs"
    "Seven-Fortunas-Internal/seven-fortunas-brain"
    "Seven-Fortunas-Internal/dashboards-internal"
)

check_file() {
    local repo="$1"
    local file="$2"
    
    if gh api "repos/$repo/contents/$file" &> /dev/null; then
        echo -e "${GREEN}    ✅ $file${NC}"
        return 0
    else
        echo -e "${RED}    ❌ $file (missing)${NC}"
        return 1
    fi
}

verify_repo() {
    local repo="$1"
    local is_public="$2"
    
    echo ""
    echo "Verifying: $repo"
    
    # Check if repo exists
    if ! gh api "repos/$repo" &> /dev/null; then
        echo -e "${RED}  ❌ Repository does not exist${NC}"
        return 1
    fi
    
    local pass=true
    
    # Check README
    check_file "$repo" "README.md" || pass=false
    
    # Check LICENSE
    check_file "$repo" "LICENSE" || check_file "$repo" "LICENSE.md" || pass=false
    
    # For public repos, check community health files
    if [[ "$is_public" == "true" ]]; then
        check_file "$repo" "CODE_OF_CONDUCT.md" || pass=false
        check_file "$repo" "CONTRIBUTING.md" || pass=false
    fi
    
    # Check .gitignore
    check_file "$repo" ".gitignore" || echo -e "${YELLOW}    ⚠️  .gitignore (optional)${NC}"
    
    if [[ "$pass" == "true" ]]; then
        echo -e "${GREEN}  ✅ Complete${NC}"
        return 0
    else
        echo -e "${RED}  ❌ Incomplete${NC}"
        return 1
    fi
}

# Verify all repos
TOTAL=0
PASS=0

for repo in "${PUBLIC_REPOS[@]}"; do
    ((TOTAL++))
    verify_repo "$repo" "true" && ((PASS++)) || true
done

for repo in "${PRIVATE_REPOS[@]}"; do
    ((TOTAL++))
    verify_repo "$repo" "false" && ((PASS++)) || true
done

echo ""
echo "==================================="
echo "Results: $PASS/$TOTAL repositories complete"
echo "==================================="

if [[ $PASS -eq $TOTAL ]]; then
    echo -e "${GREEN}✅ All repositories have required documentation${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some repositories missing documentation${NC}"
    exit 1
fi
