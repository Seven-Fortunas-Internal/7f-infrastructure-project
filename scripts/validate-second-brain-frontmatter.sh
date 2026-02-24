#!/bin/bash
# Validation script for Second Brain YAML frontmatter
# FEATURE_008: FR-2.2: Markdown + YAML Dual-Audience Format

set -euo pipefail

SECOND_BRAIN_DIR="${1:-/home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/second-brain-core}"
REQUIRED_FIELDS=("context-level" "relevant-for" "last-updated" "author" "status")
EXIT_CODE=0
VALID_COUNT=0
INVALID_COUNT=0
MISSING_FRONTMATTER=0

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "==================================================================="
echo "Second Brain YAML Frontmatter Validation"
echo "==================================================================="
echo "Directory: $SECOND_BRAIN_DIR"
echo "Required fields: ${REQUIRED_FIELDS[*]}"
echo ""

# Find all markdown files
while IFS= read -r -d '' file; do
    # Extract frontmatter (between first two --- markers)
    if ! grep -q "^---$" "$file"; then
        echo -e "${RED}✗${NC} $file - NO FRONTMATTER"
        ((MISSING_FRONTMATTER++))
        EXIT_CODE=1
        continue
    fi

    # Extract YAML frontmatter
    FRONTMATTER=$(awk '/^---$/{i++}i==1{next}i==2{exit}1' "$file")

    # Check if frontmatter is empty
    if [ -z "$FRONTMATTER" ]; then
        echo -e "${RED}✗${NC} $file - EMPTY FRONTMATTER"
        ((MISSING_FRONTMATTER++))
        EXIT_CODE=1
        continue
    fi

    # Check each required field
    MISSING_FIELDS=()
    for field in "${REQUIRED_FIELDS[@]}"; do
        if ! echo "$FRONTMATTER" | grep -q "^${field}:"; then
            MISSING_FIELDS+=("$field")
        fi
    done

    # Validate date format (ISO 8601: YYYY-MM-DD)
    LAST_UPDATED=$(echo "$FRONTMATTER" | grep "^last-updated:" | sed 's/last-updated: *//;s/"//g;s/'\''//g' | xargs)
    if [ -n "$LAST_UPDATED" ]; then
        if ! echo "$LAST_UPDATED" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
            MISSING_FIELDS+=("last-updated (invalid format: $LAST_UPDATED)")
        fi
    fi

    # Report results
    if [ ${#MISSING_FIELDS[@]} -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $file"
        ((VALID_COUNT++))
    else
        echo -e "${RED}✗${NC} $file - MISSING: ${MISSING_FIELDS[*]}"
        ((INVALID_COUNT++))
        EXIT_CODE=1
    fi
done < <(find "$SECOND_BRAIN_DIR" -name "*.md" -type f -print0)

echo ""
echo "==================================================================="
echo "Summary:"
echo "  Valid:                $VALID_COUNT"
echo "  Invalid:              $INVALID_COUNT"
echo "  Missing frontmatter:  $MISSING_FRONTMATTER"
echo "==================================================================="

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ All files pass validation${NC}"
else
    echo -e "${RED}✗ Validation failed${NC}"
fi

exit $EXIT_CODE
