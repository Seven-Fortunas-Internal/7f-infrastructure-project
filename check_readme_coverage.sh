#!/bin/bash
# Check README.md coverage across project

echo "=== README Coverage Check ==="
echo ""

echo "1. Root README..."
if [ -f "README.md" ]; then
    echo "  ✓ Root README.md exists"
else
    echo "  ✗ Root README.md missing"
fi
echo ""

echo "2. Directory READMEs (sample)..."
for dir in . docs scripts .claude/commands dashboards compliance; do
    if [ -d "$dir" ]; then
        if [ -f "$dir/README.md" ]; then
            echo "  ✓ $dir/README.md"
        else
            echo "  ✗ $dir/README.md missing"
        fi
    fi
done
echo ""

echo "3. Checking for README validation script..."
if [ -f "scripts/validate-readme-coverage.sh" ] || [ -f "scripts/generate-readme-tree.sh" ]; then
    echo "  ✓ README validation/generation script exists"
else
    echo "  ⚠️  README validation script not found"
fi
