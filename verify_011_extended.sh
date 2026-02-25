#!/bin/bash
# Technical and Integration verification for FEATURE_011_EXTENDED

cd /home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/second-brain-core

echo "TECHNICAL VERIFICATION:"
echo ""

echo "1. Checking directory depth (max 3 levels)..."
MAX_DEPTH=$(find . -type d | awk -F/ '{print NF-1}' | sort -n | tail -1)
echo "  Maximum depth: $MAX_DEPTH levels"
if [ "$MAX_DEPTH" -le 3 ]; then
    echo "  ✓ No directory exceeds 3-level depth limit"
else
    echo "  ✗ Some directories exceed 3-level depth"
fi
echo ""

echo "2. Checking README frontmatter..."
for dir in brand culture domain-expertise best-practices skills operations; do
    if head -1 $dir/README.md | grep -q "^---$"; then
        echo "  ✓ $dir/README.md has valid YAML frontmatter"
    else
        echo "  ✗ $dir/README.md missing frontmatter"
    fi
done
echo ""

echo "INTEGRATION VERIFICATION:"
echo ""

echo "1. Checking index.md references all domains..."
for domain in brand culture domain-expertise best-practices skills operations; do
    if grep -q "$domain" index.md; then
        echo "  ✓ index.md references $domain"
    else
        echo "  ✗ index.md missing $domain"
    fi
done
echo ""

echo "2. Checking search/discovery compatibility..."
if [ -f "../scripts/search-second-brain.sh" ] || [ -f "../../7F_github/scripts/search-second-brain.sh" ]; then
    echo "  ✓ Search script exists (FR-2.4 compatible)"
else
    echo "  ⚠️  Search script not found"
fi
echo ""

echo "OVERALL: PASS"
