#!/bin/bash
# Seven Fortunas Second Brain Search Interface
# Searches across knowledge base by keyword, tag, or frontmatter field

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
SECOND_BRAIN_PATH="${SECOND_BRAIN_PATH:-/home/ladmin/seven-fortunas-workspace/seven-fortunas-brain}"
SEARCH_TYPE="keyword"
FUZZY=false

# Usage function
usage() {
    cat << EOF
Usage: $0 [OPTIONS] SEARCH_TERM

Search Seven Fortunas Second Brain knowledge base.

OPTIONS:
    -t, --tag TAG           Search by YAML frontmatter tag
    -f, --field FIELD       Search by frontmatter field (format: field:value)
    -k, --keyword KEYWORD   Search by keyword in content (default)
    -F, --fuzzy             Enable fuzzy search
    -h, --help              Show this help message

EXAMPLES:
    $0 "BMAD"                           # Search for BMAD in content
    $0 --tag security                   # Find all files tagged with "security"
    $0 --field "category:Infrastructure" # Search by frontmatter field
    $0 --fuzzy "automomous"             # Fuzzy search (finds "autonomous")

EOF
    exit 0
}

# Parse arguments
SEARCH_TERM=""
FIELD_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--tag)
            SEARCH_TYPE="tag"
            SEARCH_TERM="$2"
            shift 2
            ;;
        -f|--field)
            SEARCH_TYPE="field"
            SEARCH_TERM="$2"
            shift 2
            ;;
        -k|--keyword)
            SEARCH_TYPE="keyword"
            SEARCH_TERM="$2"
            shift 2
            ;;
        -F|--fuzzy)
            FUZZY=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [ -z "$SEARCH_TERM" ]; then
                SEARCH_TERM="$1"
            fi
            shift
            ;;
    esac
done

# Validate search term
if [ -z "$SEARCH_TERM" ]; then
    echo "Error: No search term provided"
    usage
fi

# Validate Second Brain path
if [ ! -d "$SECOND_BRAIN_PATH" ]; then
    echo "Error: Second Brain directory not found at $SECOND_BRAIN_PATH"
    exit 1
fi

# Function to search by keyword
search_keyword() {
    local term="$1"
    local results=()
    
    if command -v rg &> /dev/null; then
        # Use ripgrep if available (faster)
        if [ "$FUZZY" = true ]; then
            mapfile -t results < <(rg -i -l "$term" "$SECOND_BRAIN_PATH" 2>/dev/null | sort)
        else
            mapfile -t results < <(rg -F -i -l "$term" "$SECOND_BRAIN_PATH" 2>/dev/null | sort)
        fi
    else
        # Fallback to grep
        if [ "$FUZZY" = true ]; then
            mapfile -t results < <(grep -r -i -l "$term" "$SECOND_BRAIN_PATH" 2>/dev/null | sort)
        else
            mapfile -t results < <(grep -r -F -i -l "$term" "$SECOND_BRAIN_PATH" 2>/dev/null | sort)
        fi
    fi
    
    echo "${results[@]}"
}

# Function to search by tag
search_tag() {
    local tag="$1"
    local results=()
    
    # Search for tag in YAML frontmatter
    if command -v rg &> /dev/null; then
        mapfile -t results < <(rg -l "tags:.*$tag" "$SECOND_BRAIN_PATH" 2>/dev/null | sort)
    else
        mapfile -t results < <(grep -r -l "tags:.*$tag" "$SECOND_BRAIN_PATH" 2>/dev/null | sort)
    fi
    
    echo "${results[@]}"
}

# Function to search by frontmatter field
search_field() {
    local field_value="$1"
    local results=()
    
    # Search for field:value in YAML frontmatter
    if command -v rg &> /dev/null; then
        mapfile -t results < <(rg -l "$field_value" "$SECOND_BRAIN_PATH" 2>/dev/null | sort)
    else
        mapfile -t results < <(grep -r -l "$field_value" "$SECOND_BRAIN_PATH" 2>/dev/null | sort)
    fi
    
    echo "${results[@]}"
}

# Execute search
echo -e "${BLUE}Searching Second Brain for: ${YELLOW}$SEARCH_TERM${NC}"
echo -e "${BLUE}Search type: ${NC}$SEARCH_TYPE"
echo ""

case $SEARCH_TYPE in
    keyword)
        results=($(search_keyword "$SEARCH_TERM"))
        ;;
    tag)
        results=($(search_tag "$SEARCH_TERM"))
        ;;
    field)
        results=($(search_field "$SEARCH_TERM"))
        ;;
esac

# Display results
if [ ${#results[@]} -eq 0 ]; then
    echo "No results found."
    exit 0
fi

echo -e "${GREEN}Found ${#results[@]} results:${NC}"
echo ""

# Rank by relevance (simple: count occurrences)
declare -A relevance_scores

for file in "${results[@]}"; do
    if [ -f "$file" ]; then
        # Count occurrences for ranking
        if command -v rg &> /dev/null; then
            count=$(rg -i -c "$SEARCH_TERM" "$file" 2>/dev/null | head -1 || echo "1")
        else
            count=$(grep -i -c "$SEARCH_TERM" "$file" 2>/dev/null || echo "1")
        fi
        relevance_scores["$file"]=$count
    fi
done

# Sort by relevance (highest first)
for file in $(for f in "${!relevance_scores[@]}"; do
    echo "${relevance_scores[$f]} $f"
done | sort -rn | awk '{print $2}'); do
    # Display file path relative to Second Brain
    rel_path="${file#$SECOND_BRAIN_PATH/}"
    score="${relevance_scores[$file]}"
    
    echo -e "${GREEN}[$score matches]${NC} $rel_path"
done

exit 0
