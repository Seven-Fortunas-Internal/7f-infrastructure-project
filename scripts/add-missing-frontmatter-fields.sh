#!/bin/bash
# Add missing YAML frontmatter fields to Second Brain documents
# FEATURE_008: FR-2.2: Markdown + YAML Dual-Audience Format

set -euo pipefail

SECOND_BRAIN_DIR="/home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/second-brain-core"
TODAY=$(date +%Y-%m-%d)

cd "$SECOND_BRAIN_DIR"

echo "Adding missing frontmatter fields to Second Brain documents..."
echo ""

UPDATED_COUNT=0

for file in $(find . -name "*.md" -type f); do
    # Check if file has all required fields
    HAS_CONTEXT_LEVEL=$(grep -c "^context-level:" "$file" || echo 0)
    HAS_RELEVANT_FOR=$(grep -c "^relevant-for:" "$file" || echo 0)
    HAS_LAST_UPDATED=$(grep -c "^last-updated:" "$file" || echo 0)
    HAS_AUTHOR=$(grep -c "^author:" "$file" || echo 0)
    HAS_STATUS=$(grep -c "^status:" "$file" || echo 0)

    if [[ $HAS_CONTEXT_LEVEL -gt 0 && $HAS_RELEVANT_FOR -gt 0 && $HAS_LAST_UPDATED -gt 0 && $HAS_AUTHOR -gt 0 && $HAS_STATUS -gt 0 ]]; then
        echo "✓ $file (all fields present)"
        continue
    fi

    echo "→ Updating $file"

    # Extract existing frontmatter
    if ! grep -q "^---$" "$file"; then
        echo "  ✗ Skipping (no frontmatter)"
        continue
    fi

    # Create temp file with updated frontmatter
    TMP_FILE="${file}.tmp"
    CONTENT_FILE="${file}.content"

    # Extract content after frontmatter (after second ---)
    sed -n '/^---$/,/^---$/!p' "$file" > "$CONTENT_FILE"

    # Start building new frontmatter
    echo "---" > "$TMP_FILE"

    # Copy existing frontmatter (between --- markers), excluding the markers
    sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d' >> "$TMP_FILE"

    # Add missing fields
    if [[ $HAS_CONTEXT_LEVEL -eq 0 ]]; then
        echo "context-level: 3-specific  # TODO: Update with correct level" >> "$TMP_FILE"
        echo "  Added context-level"
    fi

    if [[ $HAS_RELEVANT_FOR -eq 0 ]]; then
        echo "relevant-for:" >> "$TMP_FILE"
        echo "  - ai-agents" >> "$TMP_FILE"
        echo "  - humans  # TODO: Update with correct audiences" >> "$TMP_FILE"
        echo "  Added relevant-for"
    fi

    if [[ $HAS_LAST_UPDATED -eq 0 ]]; then
        echo "last-updated: $TODAY" >> "$TMP_FILE"
        echo "  Added last-updated"
    fi

    if [[ $HAS_AUTHOR -eq 0 ]]; then
        echo "author: Seven Fortunas Team  # TODO: Update with actual author" >> "$TMP_FILE"
        echo "  Added author"
    fi

    if [[ $HAS_STATUS -eq 0 ]]; then
        echo "status: active  # TODO: Update if needed (active|draft|archived|deprecated)" >> "$TMP_FILE"
        echo "  Added status"
    fi

    # Close frontmatter
    echo "---" >> "$TMP_FILE"

    # Append content
    cat "$CONTENT_FILE" >> "$TMP_FILE"

    # Replace original file
    mv "$TMP_FILE" "$file"
    rm "$CONTENT_FILE"

    ((UPDATED_COUNT++))
    echo ""
done

echo ""
echo "Updated $UPDATED_COUNT files"
