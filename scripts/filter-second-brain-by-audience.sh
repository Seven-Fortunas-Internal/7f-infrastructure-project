#!/bin/bash
# AI Filter Script for Second Brain Documents
# FEATURE_008: FR-2.2: Filter documents by relevant-for field

set -euo pipefail

SECOND_BRAIN_DIR="${SECOND_BRAIN_DIR:-/home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/second-brain-core}"
AUDIENCE="${1:-ai-agents}"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ $# -eq 0 ]; then
    echo "Usage: $0 <audience> [directory]"
    echo ""
    echo "Audience options:"
    echo "  ai-agents    - Documents for AI consumption"
    echo "  humans       - Documents for human readers"
    echo "  developers   - Documents for developers"
    echo "  operations   - Documents for ops/SRE teams"
    echo "  executives   - Documents for leadership"
    echo ""
    echo "Example:"
    echo "  $0 ai-agents"
    echo "  $0 developers /path/to/second-brain"
    exit 1
fi

if [ $# -ge 2 ]; then
    SECOND_BRAIN_DIR="$2"
fi

echo -e "${BLUE}Filtering Second Brain documents for audience: $AUDIENCE${NC}"
echo "Directory: $SECOND_BRAIN_DIR"
echo ""

MATCH_COUNT=0

# Find all markdown files
while IFS= read -r -d '' file; do
    # Extract frontmatter
    if ! grep -q "^---$" "$file"; then
        continue
    fi

    # Extract YAML frontmatter
    FRONTMATTER=$(awk '/^---$/{i++}i==1{next}i==2{exit}1' "$file")

    # Check if relevant-for field contains the target audience
    # Handle both formats: relevant-for: [list] and relevant-for:\n  - item
    if echo "$FRONTMATTER" | grep -A 10 "^relevant-for:" | grep -q "$AUDIENCE"; then
        echo -e "${GREEN}✓${NC} $file"
        ((MATCH_COUNT++))
    fi
done < <(find "$SECOND_BRAIN_DIR" -name "*.md" -type f -print0)

echo ""
echo "Found $MATCH_COUNT documents for audience: $AUDIENCE"
