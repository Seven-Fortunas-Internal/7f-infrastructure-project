#!/bin/bash
# Validate Seven Fortunas skills organization
# Ensures skills are in correct category directories with proper naming

set -euo pipefail

SKILLS_DIR="/home/ladmin/dev/GDF/7F_github/.claude/commands"
ERRORS=0
WARNINGS=0

echo "🔍 Validating skills organization..."
echo ""

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Define utility skills that are allowed in root
ALLOWED_ROOT=(
    "bmad-help.md"
    "bmad-index-docs.md"
    "bmad-party-mode.md"
    "bmad-brainstorming.md"
    "bmad-editorial-review-prose.md"
    "bmad-editorial-review-structure.md"
    "bmad-review-adversarial-general.md"
    "bmad-shard-doc.md"
    "bmad-agent-bmad-master.md"
    "bmad-agent-tea-tea.md"
    "README.md"
    "skills-registry.yaml"
    "team-communication.md"
)

# Check 1: Verify required directories exist
echo "📁 Checking directory structure..."
REQUIRED_DIRS=("7f" "bmm" "bmb" "cis")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$SKILLS_DIR/$dir" ]; then
        echo -e "${RED}✗ ERROR: Missing required directory: $dir/${NC}"
        ((ERRORS++))
    else
        echo -e "${GREEN}✓ Directory exists: $dir/${NC}"
    fi
done
echo ""

# Check 2: Verify no orphaned skills in root
echo "🚫 Checking for orphaned skills in root..."
cd "$SKILLS_DIR"
for skill in *.md; do
    # Skip non-files
    [ -f "$skill" ] || continue

    # Check if skill is in allowed list
    if [[ " ${ALLOWED_ROOT[@]} " =~ " ${skill} " ]]; then
        continue
    fi

    # Check if skill should be in a subdirectory
    if [[ "$skill" == 7f-*.md ]]; then
        echo -e "${RED}✗ ERROR: 7f skill in root (should be in 7f/): $skill${NC}"
        ((ERRORS++))
    elif [[ "$skill" == bmad-bmm-*.md ]]; then
        echo -e "${RED}✗ ERROR: bmm skill in root (should be in bmm/): $skill${NC}"
        ((ERRORS++))
    elif [[ "$skill" == bmad-bmb-*.md ]]; then
        echo -e "${RED}✗ ERROR: bmb skill in root (should be in bmb/): $skill${NC}"
        ((ERRORS++))
    elif [[ "$skill" == bmad-cis-*.md ]]; then
        echo -e "${RED}✗ ERROR: cis skill in root (should be in cis/): $skill${NC}"
        ((ERRORS++))
    elif [[ "$skill" == bmad-agent-bmm-*.md || "$skill" == bmad-agent-bmb-*.md || "$skill" == bmad-agent-cis-*.md ]]; then
        echo -e "${RED}✗ ERROR: agent in root (should be in module directory): $skill${NC}"
        ((ERRORS++))
    else
        echo -e "${YELLOW}⚠ WARNING: Unclassified skill in root: $skill${NC}"
        ((WARNINGS++))
    fi
done

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ No orphaned skills in root${NC}"
fi
echo ""

# Check 3: Verify naming conventions
echo "📝 Checking naming conventions..."
check_naming() {
    local dir=$1
    local pattern=$2
    local category=$3

    cd "$SKILLS_DIR/$dir"
    for skill in *.md; do
        [ -f "$skill" ] || continue

        if [[ ! "$skill" =~ $pattern ]]; then
            echo -e "${RED}✗ ERROR: Invalid naming in $dir/: $skill (should match $pattern)${NC}"
            ((ERRORS++))
        fi
    done
}

# Check 7f skills
check_naming "7f" "^7f-[a-z0-9-]+\.md$" "7f"

# Check bmm skills (bmad-bmm-* or bmad-agent-bmm-* or bmad-tea-*)
cd "$SKILLS_DIR/bmm"
for skill in *.md; do
    [ -f "$skill" ] || continue

    if [[ ! "$skill" =~ ^bmad-(bmm-|agent-bmm-|tea-)[a-z0-9-]+\.md$ ]]; then
        echo -e "${RED}✗ ERROR: Invalid naming in bmm/: $skill${NC}"
        ((ERRORS++))
    fi
done

# Check bmb skills
check_naming "bmb" "^bmad-(bmb-|agent-bmb-)[a-z0-9-]+\.md$" "bmb"

# Check cis skills
check_naming "cis" "^bmad-(cis-|agent-cis-)[a-z0-9-]+\.md$" "cis"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All skills follow naming conventions${NC}"
fi
echo ""

# Check 4: Verify skills-registry.yaml exists and is valid
echo "📋 Checking skills registry..."
if [ ! -f "$SKILLS_DIR/skills-registry.yaml" ]; then
    echo -e "${RED}✗ ERROR: skills-registry.yaml not found${NC}"
    ((ERRORS++))
else
    # Validate YAML syntax (if yq is available)
    if command -v yq &> /dev/null; then
        if yq eval '.' "$SKILLS_DIR/skills-registry.yaml" > /dev/null 2>&1; then
            echo -e "${GREEN}✓ skills-registry.yaml is valid YAML${NC}"
        else
            echo -e "${RED}✗ ERROR: skills-registry.yaml has invalid YAML syntax${NC}"
            ((ERRORS++))
        fi
    else
        echo -e "${YELLOW}⚠ WARNING: yq not available, skipping YAML validation${NC}"
        ((WARNINGS++))
    fi
fi
echo ""

# Check 5: Verify README exists
echo "📖 Checking README..."
if [ ! -f "$SKILLS_DIR/README.md" ]; then
    echo -e "${RED}✗ ERROR: README.md not found${NC}"
    ((ERRORS++))
else
    # Check if README documents tiers
    if grep -q "Tier 1:" "$SKILLS_DIR/README.md" && \
       grep -q "Tier 2:" "$SKILLS_DIR/README.md" && \
       grep -q "Tier 3:" "$SKILLS_DIR/README.md"; then
        echo -e "${GREEN}✓ README documents skill tiers${NC}"
    else
        echo -e "${RED}✗ ERROR: README missing tier documentation${NC}"
        ((ERRORS++))
    fi

    # Check if README has search-before-create guidance
    if grep -q -i "search.*before.*create" "$SKILLS_DIR/README.md"; then
        echo -e "${GREEN}✓ README has search-before-create guidance${NC}"
    else
        echo -e "${RED}✗ ERROR: README missing search-before-create guidance${NC}"
        ((ERRORS++))
    fi
fi
echo ""

# Summary
echo "════════════════════════════════════════"
echo "Validation Summary:"
echo "════════════════════════════════════════"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed!${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠  ${WARNINGS} warnings (non-critical)${NC}"
    exit 0
else
    echo -e "${RED}❌ ${ERRORS} errors found${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠  ${WARNINGS} warnings${NC}"
    fi
    echo ""
    echo "Please fix errors and run validation again."
    exit 1
fi
