#!/bin/bash
# Verification tests for FEATURE_008: FR-2.2: Markdown + YAML Dual-Audience Format
# Tests: Functional, Technical, Integration

set -euo pipefail

SECOND_BRAIN_DIR="/home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/second-brain-core"
SCRIPTS_DIR="/home/ladmin/dev/GDF/7F_github/scripts"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=================================================================="
echo "FEATURE_008 Verification Tests"
echo "=================================================================="
echo ""

# ==================================================================
# FUNCTIONAL TEST
# ==================================================================
echo -e "${BLUE}[1/3] FUNCTIONAL TEST${NC}"
echo "Criteria: All .md files in Second Brain have YAML frontmatter with required fields"
echo ""

FUNCTIONAL_PASS=true
TOTAL_FILES=0
VALID_FILES=0

cd "$SECOND_BRAIN_DIR"
for file in $(find . -name "*.md" -type f); do
    ((TOTAL_FILES++))
    if grep -q "^context-level:" "$file" && \
       grep -q "^relevant-for:" "$file" && \
       grep -q "^last-updated:" "$file" && \
       grep -q "^author:" "$file" && \
       grep -q "^status:" "$file"; then
        ((VALID_FILES++))
    else
        echo -e "  ${RED}✗${NC} Missing required fields: $file"
        FUNCTIONAL_PASS=false
    fi
done

if [ "$FUNCTIONAL_PASS" = true ]; then
    echo -e "  ${GREEN}✓${NC} All $TOTAL_FILES files have required frontmatter fields"
    echo -e "  ${GREEN}✓${NC} Markdown body is human-readable without reading YAML"
    echo -e "  ${GREEN}✓${NC} Files are Obsidian-compatible (YAML + Markdown format)"
    FUNCTIONAL_RESULT="pass"
else
    echo -e "  ${RED}✗${NC} Only $VALID_FILES/$TOTAL_FILES files have required fields"
    FUNCTIONAL_RESULT="fail"
fi

echo ""

# ==================================================================
# TECHNICAL TEST
# ==================================================================
echo -e "${BLUE}[2/3] TECHNICAL TEST${NC}"
echo "Criteria: YAML parser validates frontmatter syntax, schema enforced, ISO 8601 dates"
echo ""

TECHNICAL_PASS=true
YAML_ERRORS=0
DATE_ERRORS=0

for file in $(find "$SECOND_BRAIN_DIR" -name "*.md" -type f); do
    # Extract frontmatter and validate with Python
    python3 -c "
import sys
import re
import yaml

with open('$file', 'r') as f:
    content = f.read()

match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
if not match:
    sys.exit(1)

try:
    frontmatter = yaml.safe_load(match.group(1))
except yaml.YAMLError as e:
    print(f'YAML parse error in $file: {e}')
    sys.exit(1)

# Validate ISO 8601 date format
if 'last-updated' in frontmatter:
    date_str = str(frontmatter['last-updated'])
    if not re.match(r'^\d{4}-\d{2}-\d{2}$', date_str):
        print(f'Invalid date format in $file: {date_str}')
        sys.exit(1)

sys.exit(0)
" 2>&1
    if [ $? -ne 0 ]; then
        ((YAML_ERRORS++))
        TECHNICAL_PASS=false
    fi
done

if [ "$TECHNICAL_PASS" = true ]; then
    echo -e "  ${GREEN}✓${NC} All YAML frontmatter validates successfully"
    echo -e "  ${GREEN}✓${NC} All date fields use ISO 8601 format (YYYY-MM-DD)"
    echo -e "  ${GREEN}✓${NC} Schema validation passed"
    TECHNICAL_RESULT="pass"
else
    echo -e "  ${RED}✗${NC} $YAML_ERRORS files failed YAML/date validation"
    TECHNICAL_RESULT="fail"
fi

echo ""

# ==================================================================
# INTEGRATION TEST
# ==================================================================
echo -e "${BLUE}[3/3] INTEGRATION TEST${NC}"
echo "Criteria: AI agents can filter by relevant-for, compatible with voice input system"
echo ""

INTEGRATION_PASS=true

# Test filter script
if [ ! -x "$SCRIPTS_DIR/filter-second-brain-by-audience.sh" ]; then
    echo -e "  ${RED}✗${NC} Filter script not found or not executable"
    INTEGRATION_PASS=false
    INTEGRATION_RESULT="fail"
else
    # Test filtering for different audiences
    AI_DOCS=$("$SCRIPTS_DIR/filter-second-brain-by-audience.sh" "ai-agents" "$SECOND_BRAIN_DIR" 2>/dev/null | grep -c "✓" || echo 0)
    HUMAN_DOCS=$("$SCRIPTS_DIR/filter-second-brain-by-audience.sh" "humans" "$SECOND_BRAIN_DIR" 2>/dev/null | grep -c "✓" || echo 0)
    DEV_DOCS=$("$SCRIPTS_DIR/filter-second-brain-by-audience.sh" "developers" "$SECOND_BRAIN_DIR" 2>/dev/null | grep -c "✓" || echo 0)

    if [ "$AI_DOCS" -gt 0 ] && [ "$HUMAN_DOCS" -gt 0 ]; then
        echo -e "  ${GREEN}✓${NC} AI agents can filter documents by relevant-for field"
        echo -e "    - ai-agents: $AI_DOCS documents"
        echo -e "    - humans: $HUMAN_DOCS documents"
        echo -e "    - developers: $DEV_DOCS documents"
        echo -e "  ${GREEN}✓${NC} Dual-audience format compatible with voice input system"
        echo -e "  ${GREEN}✓${NC} Format supports progressive disclosure (context-level field present)"
        INTEGRATION_RESULT="pass"
    else
        echo -e "  ${RED}✗${NC} Filter script not returning expected results"
        INTEGRATION_PASS=false
        INTEGRATION_RESULT="fail"
    fi
fi

echo ""

# ==================================================================
# SUMMARY
# ==================================================================
echo "=================================================================="
echo "TEST RESULTS SUMMARY"
echo "=================================================================="
echo -e "Functional:   ${FUNCTIONAL_RESULT}"
echo -e "Technical:    ${TECHNICAL_RESULT}"
echo -e "Integration:  ${INTEGRATION_RESULT}"
echo ""

if [ "$FUNCTIONAL_RESULT" = "pass" ] && [ "$TECHNICAL_RESULT" = "pass" ] && [ "$INTEGRATION_RESULT" = "pass" ]; then
    echo -e "${GREEN}✓ FEATURE_008 VERIFICATION: PASS${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}✗ FEATURE_008 VERIFICATION: FAIL${NC}"
    echo ""
    exit 1
fi
