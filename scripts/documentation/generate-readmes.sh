#!/usr/bin/env bash
# generate-readmes.sh
# Generates README.md files for directories that don't have them

set -euo pipefail

# Configuration
TARGET_DIR="${TARGET_DIR:-.}"
DRY_RUN="${DRY_RUN:-false}"
TEMPLATE_DIR="${TEMPLATE_DIR:-docs/templates}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== README.md Generator ===${NC}"
echo "Target directory: ${TARGET_DIR}"
echo "Template directory: ${TEMPLATE_DIR}"
echo "Dry run: ${DRY_RUN}"
echo ""

# Function to detect directory type
detect_directory_type() {
    local dir="$1"
    
    # Root directory
    if [ "$dir" = "." ] || [ "$dir" = "${TARGET_DIR}" ]; then
        echo "root"
        return
    fi
    
    # Check for code indicators
    if ls "$dir"/*.py &>/dev/null || \
       ls "$dir"/*.js &>/dev/null || \
       ls "$dir"/*.ts &>/dev/null || \
       ls "$dir"/*.go &>/dev/null || \
       ls "$dir"/*.rs &>/dev/null; then
        echo "code"
        return
    fi
    
    # Check for architecture indicators
    if [[ "$dir" == *"/docs/architecture"* ]] || \
       [[ "$dir" == *"/architecture"* ]] || \
       [ -f "$dir/adr/README.md" ]; then
        echo "architecture"
        return
    fi
    
    # Default to directory type
    echo "directory"
}

# Function to generate README from template
generate_readme() {
    local dir="$1"
    local type="$2"
    local readme_path="${dir}/README.md"
    
    # Skip if README already exists
    if [ -f "$readme_path" ]; then
        if [ "$VERBOSE" = "true" ]; then
            echo -e "  ${YELLOW}⊘${NC} ${readme_path} (already exists)"
        fi
        return
    fi
    
    # Get directory name
    local dir_name
    dir_name=$(basename "$dir")
    
    # Generate content based on type
    case "$type" in
        root)
            local template="${TEMPLATE_DIR}/README-root.md"
            if [ ! -f "$template" ]; then
                echo -e "  ${YELLOW}⚠️${NC} Template not found: ${template}"
                return
            fi
            
            if [ "$DRY_RUN" = "true" ]; then
                echo -e "  ${BLUE}[DRY RUN]${NC} Would create ${readme_path} from ${template}"
            else
                cp "$template" "$readme_path"
                echo -e "  ${GREEN}✓${NC} Created ${readme_path} (root)"
            fi
            ;;
            
        code)
            local template="${TEMPLATE_DIR}/README-code.md"
            if [ ! -f "$template" ]; then
                echo -e "  ${YELLOW}⚠️${NC} Template not found: ${template}"
                return
            fi
            
            if [ "$DRY_RUN" = "true" ]; then
                echo -e "  ${BLUE}[DRY RUN]${NC} Would create ${readme_path} from ${template}"
            else
                cp "$template" "$readme_path"
                sed -i "s/\[Component\/Module Name\]/${dir_name}/g" "$readme_path"
                echo -e "  ${GREEN}✓${NC} Created ${readme_path} (code)"
            fi
            ;;
            
        architecture)
            local template="${TEMPLATE_DIR}/README-architecture.md"
            if [ ! -f "$template" ]; then
                echo -e "  ${YELLOW}⚠️${NC} Template not found: ${template}"
                return
            fi
            
            if [ "$DRY_RUN" = "true" ]; then
                echo -e "  ${BLUE}[DRY RUN]${NC} Would create ${readme_path} from ${template}"
            else
                cp "$template" "$readme_path"
                sed -i "s/\[System\/Component\]/${dir_name}/g" "$readme_path"
                echo -e "  ${GREEN}✓${NC} Created ${readme_path} (architecture)"
            fi
            ;;
            
        directory)
            local template="${TEMPLATE_DIR}/README-directory.md"
            if [ ! -f "$template" ]; then
                # Create simple directory README inline
                if [ "$DRY_RUN" = "true" ]; then
                    echo -e "  ${BLUE}[DRY RUN]${NC} Would create ${readme_path} (directory)"
                else
                    cat > "$readme_path" << EOFR
# ${dir_name}

**Purpose:** [Why this directory exists]

## Contents

$(ls -1 "$dir" 2>/dev/null | grep -v "README.md" | sed 's/^/- `/' | sed 's/$/` - [Description]/' || echo "- [Empty directory]")

## Usage

[How to use the contents of this directory]

## Related Documentation

- [Link to parent README](../README.md)

---

**Last Updated:** $(date +%Y-%m-%d)
EOFR
                    echo -e "  ${GREEN}✓${NC} Created ${readme_path} (directory)"
                fi
            else
                if [ "$DRY_RUN" = "true" ]; then
                    echo -e "  ${BLUE}[DRY RUN]${NC} Would create ${readme_path} from ${template}"
                else
                    cp "$template" "$readme_path"
                    sed -i "s/\[Directory Name\]/${dir_name}/g" "$readme_path"
                    echo -e "  ${GREEN}✓${NC} Created ${readme_path} (directory)"
                fi
            fi
            ;;
    esac
}

# Find all directories without README.md
DIRS=$(find "${TARGET_DIR}" -type d \
    -not -path "*/\.*" \
    -not -path "*/node_modules/*" \
    -not -path "*/venv/*" \
    -not -path "*/env/*" \
    -not -path "*/__pycache__/*" \
    -not -path "*/dist/*" \
    -not -path "*/build/*" | sort)

GENERATED=0

for DIR in $DIRS; do
    if [ ! -f "${DIR}/README.md" ]; then
        TYPE=$(detect_directory_type "$DIR")
        generate_readme "$DIR" "$TYPE"
        GENERATED=$((GENERATED + 1))
    fi
done

# Summary
echo ""
echo -e "${BLUE}=== Summary ===${NC}"
if [ "$DRY_RUN" = "true" ]; then
    echo "Would generate: ${GENERATED} README files"
    echo ""
    echo "Run without DRY_RUN=true to actually generate files:"
    echo "  DRY_RUN=false bash scripts/documentation/generate-readmes.sh"
else
    echo "Generated: ${GENERATED} README files"
    
    if [ ${GENERATED} -gt 0 ]; then
        echo ""
        echo -e "${GREEN}✅ README generation complete${NC}"
        echo ""
        echo "Next steps:"
        echo "1. Review generated READMEs and fill in placeholders"
        echo "2. Run validation: bash scripts/documentation/validate-readmes.sh"
        echo "3. Commit changes: git add . && git commit -m 'docs: Add README files'"
    else
        echo ""
        echo -e "${GREEN}✅ All directories already have README files${NC}"
    fi
fi
