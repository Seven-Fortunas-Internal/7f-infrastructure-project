#!/usr/bin/env bash
# create_repositories.sh
# Creates MVP repositories for Seven Fortunas project

set -euo pipefail

# Constants
PUBLIC_ORG="Seven-Fortunas"
PRIVATE_ORG="Seven-Fortunas-Internal"
LOG_FILE="${LOG_FILE:-/tmp/github_repo_creation.log}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to log actions
log_action() {
    local message="$1"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[${timestamp}] ${message}" | tee -a "${LOG_FILE}"
}

# Function to check if repo exists
check_repo_exists() {
    local org="$1"
    local repo="$2"
    if gh api "repos/${org}/${repo}" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to create repository with retry
create_repo_with_retry() {
    local org="$1"
    local repo="$2"
    local description="$3"
    local visibility="$4"  # public or private
    local max_retries=3
    local retry_count=0

    echo -e "${BLUE}Creating repository: ${org}/${repo}${NC}"

    # Check if repo already exists
    if check_repo_exists "${org}" "${repo}"; then
        echo -e "${GREEN}✓ Repository ${repo} already exists${NC}"
        log_action "REPO_EXISTS: ${org}/${repo}"
        return 0
    fi

    # Attempt to create repo with retries
    while [[ $retry_count -lt $max_retries ]]; do
        if gh api "orgs/${org}/repos" \
            -X POST \
            -f name="${repo}" \
            -f description="${description}" \
            -f visibility="${visibility}" \
            -F auto_init=true \
            &>/dev/null; then
            echo -e "${GREEN}✓ Created repository: ${org}/${repo}${NC}"
            log_action "REPO_CREATED: ${org}/${repo} (visibility: ${visibility})"
            return 0
        else
            ((retry_count++))
            if [[ $retry_count -lt $max_retries ]]; then
                echo -e "${YELLOW}⚠ Retry $retry_count/$max_retries for ${repo}...${NC}"
                sleep 2
            fi
        fi
    done

    echo -e "${RED}✗ Failed to create repository: ${repo}${NC}"
    log_action "REPO_CREATION_FAILED: ${org}/${repo}"
    return 1
}

# Function to create README
create_readme() {
    local org="$1"
    local repo="$2"
    local content="$3"

    echo "  Creating README.md..."

    # Create README via API
    if gh api "repos/${org}/${repo}/contents/README.md" \
        -X PUT \
        -f message="docs: Add comprehensive README" \
        -f content="$(echo -n "${content}" | base64)" \
        &>/dev/null; then
        echo -e "  ${GREEN}✓ README created${NC}"
        return 0
    else
        # README might already exist from auto_init
        echo -e "  ${YELLOW}⚠ README already exists or failed${NC}"
        return 0
    fi
}

# Function to create LICENSE file
create_license() {
    local org="$1"
    local repo="$2"
    local license_type="$3"  # mit or proprietary

    echo "  Creating LICENSE..."

    if [[ "${license_type}" == "mit" ]]; then
        license_content="MIT License

Copyright (c) $(date +%Y) Seven Fortunas, Inc

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the \"Software\"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE."
    else
        license_content="Proprietary License

Copyright (c) $(date +%Y) Seven Fortunas, Inc. All rights reserved.

This software and associated documentation files (the \"Software\") are
proprietary to Seven Fortunas, Inc. Unauthorized copying, distribution,
modification, or use of this Software is strictly prohibited."
    fi

    if gh api "repos/${org}/${repo}/contents/LICENSE" \
        -X PUT \
        -f message="docs: Add LICENSE" \
        -f content="$(echo -n "${license_content}" | base64)" \
        &>/dev/null; then
        echo -e "  ${GREEN}✓ LICENSE created${NC}"
        return 0
    else
        echo -e "  ${YELLOW}⚠ LICENSE already exists or failed${NC}"
        return 0
    fi
}

# Validate authentication
echo -e "${YELLOW}Validating GitHub authentication...${NC}"
if ! ./scripts/validate_github_auth.sh; then
    echo -e "${RED}ERROR: GitHub authentication validation failed${NC}"
    log_action "REPO_CREATION_FAILED: Authentication validation failed"
    exit 1
fi
echo -e "${GREEN}✓ GitHub authentication validated${NC}"
log_action "REPO_CREATION_START: Authentication validated"

# Validate organizations exist
echo ""
echo -e "${YELLOW}Validating organizations...${NC}"
if ! gh api "orgs/${PUBLIC_ORG}" &>/dev/null || ! gh api "orgs/${PRIVATE_ORG}" &>/dev/null; then
    echo -e "${RED}ERROR: Organizations do not exist${NC}"
    echo "Run ./scripts/create_github_orgs.sh first"
    exit 1
fi
echo -e "${GREEN}✓ Both organizations validated${NC}"

# Create MVP repositories
echo ""
echo -e "${BLUE}=== Creating MVP Repositories ===${NC}"
echo ""

# Public repositories
echo -e "${BLUE}Public Repositories (${PUBLIC_ORG}):${NC}"

create_repo_with_retry "${PUBLIC_ORG}" ".github" "Organization profile and community health files" "public"
create_repo_with_retry "${PUBLIC_ORG}" "seven-fortunas.github.io" "Seven Fortunas public website" "public"
create_repo_with_retry "${PUBLIC_ORG}" "dashboards" "7F Lens - AI-native enterprise dashboards" "public"
create_repo_with_retry "${PUBLIC_ORG}" "second-brain-public" "Public Second Brain knowledge base" "public"

# Private repositories (Public org)
echo ""
echo -e "${BLUE}Private Repositories (${PUBLIC_ORG}):${NC}"
# Note: These are in PUBLIC_ORG but with private visibility

# Private repositories (Private org)
echo ""
echo -e "${BLUE}Private Repositories (${PRIVATE_ORG}):${NC}"

create_repo_with_retry "${PRIVATE_ORG}" ".github" "Internal organization profile" "private"
create_repo_with_retry "${PRIVATE_ORG}" "internal-docs" "Internal documentation and runbooks" "private"
create_repo_with_retry "${PRIVATE_ORG}" "seven-fortunas-brain" "Seven Fortunas Second Brain (BMAD workflows)" "private"
create_repo_with_retry "${PRIVATE_ORG}" "dashboards-internal" "Internal dashboards and analytics" "private"
create_repo_with_retry "${PRIVATE_ORG}" "7f-infrastructure-project" "Infrastructure automation and IaC" "private"

echo ""
echo -e "${GREEN}✓ Repository creation complete${NC}"
log_action "REPO_CREATION_SUCCESS: All repositories processed"

echo ""
echo "Next steps:"
echo "1. Add README.md files to each repository"
echo "2. Add LICENSE files (MIT for public, proprietary for private)"
echo "3. Add CODE_OF_CONDUCT.md and CONTRIBUTING.md to public repos"
echo "4. Apply branch protection rules (see ./scripts/configure_branch_protection.sh)"
echo ""

exit 0
