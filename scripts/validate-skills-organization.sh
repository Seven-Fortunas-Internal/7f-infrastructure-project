#!/bin/bash
# Validate Skills Organization
# Ensures all skills follow Seven Fortunas organization standards

set -e

COMMANDS_DIR=".claude/commands"
ERRORS=0

echo "==================================================================="
echo "Seven Fortunas Skills Organization Validator"
echo "==================================================================="
echo ""

# Check directory structure exists
echo "1. Checking directory structure..."
for dir in 7f bmm bmb cis; do
    if [ ! -d "$COMMANDS_DIR/$dir" ]; then
        echo "   ❌ ERROR: Missing directory: $COMMANDS_DIR/$dir"
        ((ERRORS++))
    else
        echo "   ✅ Directory exists: $COMMANDS_DIR/$dir"
    fi
done
echo ""

# Check for orphaned skills in root
echo "2. Checking for orphaned skills in root..."
ORPHANS=$(ls "$COMMANDS_DIR"/*.md 2>/dev/null | grep -E "bmad-|7f-" | wc -l)
if [ "$ORPHANS" -gt 0 ]; then
    echo "   ⚠️  WARNING: Found $ORPHANS skills in root (should be in category dirs)"
    ls "$COMMANDS_DIR"/*.md 2>/dev/null | grep -E "bmad-|7f-" | while read file; do
        echo "      - $(basename $file)"
    done
    ((ERRORS++))
else
    echo "   ✅ No orphaned skills in root"
fi
echo ""

# Check naming conventions
echo "3. Validating naming conventions..."

# 7F skills
echo "   Checking 7f/ skills..."
INVALID_7F=0
ls "$COMMANDS_DIR/7f"/*.md 2>/dev/null | while read file; do
    basename=$(basename "$file")
    if [[ ! "$basename" =~ ^7f-[a-z-]+\.md$ ]]; then
        echo "      ❌ Invalid name: $basename (should be 7f-{skill-name}.md)"
        ((INVALID_7F++))
    fi
done
if [ "$INVALID_7F" -eq 0 ]; then
    echo "      ✅ All 7f/ skills follow naming convention"
fi

# BMM skills
echo "   Checking bmm/ skills..."
INVALID_BMM=0
ls "$COMMANDS_DIR/bmm"/*.md 2>/dev/null | while read file; do
    basename=$(basename "$file")
    if [[ ! "$basename" =~ ^bmad-(bmm|agent-bmm|tea)-[a-z-]+\.md$ ]]; then
        echo "      ⚠️  Non-standard name: $basename"
    fi
done
echo "      ✅ BMM skills checked"

# BMB skills
echo "   Checking bmb/ skills..."
ls "$COMMANDS_DIR/bmb"/*.md 2>/dev/null | while read file; do
    basename=$(basename "$file")
    if [[ ! "$basename" =~ ^bmad-(bmb|agent-bmb)-[a-z-]+\.md$ ]]; then
        echo "      ⚠️  Non-standard name: $basename"
    fi
done
echo "      ✅ BMB skills checked"

# CIS skills
echo "   Checking cis/ skills..."
ls "$COMMANDS_DIR/cis"/*.md 2>/dev/null | while read file; do
    basename=$(basename "$file")
    if [[ ! "$basename" =~ ^bmad-(cis|agent-cis)-[a-z-]+\.md$ ]]; then
        echo "      ⚠️  Non-standard name: $basename"
    fi
done
echo "      ✅ CIS skills checked"
echo ""

# Check skills-registry.yaml exists
echo "4. Checking skills registry..."
if [ ! -f "$COMMANDS_DIR/skills-registry.yaml" ]; then
    echo "   ❌ ERROR: skills-registry.yaml not found"
    ((ERRORS++))
else
    echo "   ✅ skills-registry.yaml exists"

    # Validate YAML syntax
    if command -v yamllint &>/dev/null; then
        if yamllint "$COMMANDS_DIR/skills-registry.yaml" &>/dev/null; then
            echo "   ✅ skills-registry.yaml is valid YAML"
        else
            echo "   ❌ ERROR: skills-registry.yaml has syntax errors"
            ((ERRORS++))
        fi
    else
        echo "   ⚠️  WARNING: yamllint not installed, skipping YAML validation"
    fi
fi
echo ""

# Check README exists
echo "5. Checking README documentation..."
if [ ! -f "$COMMANDS_DIR/README.md" ]; then
    echo "   ❌ ERROR: README.md not found"
    ((ERRORS++))
else
    echo "   ✅ README.md exists"
fi
echo ""

# Statistics
echo "6. Skills statistics..."
echo "   7F skills: $(ls "$COMMANDS_DIR/7f"/*.md 2>/dev/null | wc -l)"
echo "   BMM skills: $(ls "$COMMANDS_DIR/bmm"/*.md 2>/dev/null | wc -l)"
echo "   BMB skills: $(ls "$COMMANDS_DIR/bmb"/*.md 2>/dev/null | wc -l)"
echo "   CIS skills: $(ls "$COMMANDS_DIR/cis"/*.md 2>/dev/null | wc -l)"
echo "   Utility skills: $(ls "$COMMANDS_DIR"/*.md 2>/dev/null | wc -l)"
echo "   Total: $(find "$COMMANDS_DIR" -name "*.md" | wc -l)"
echo ""

# Summary
echo "==================================================================="
if [ "$ERRORS" -eq 0 ]; then
    echo "✅ VALIDATION PASSED"
    echo "All skills follow Seven Fortunas organization standards."
    exit 0
else
    echo "❌ VALIDATION FAILED"
    echo "Found $ERRORS error(s). Please fix and re-run."
    exit 1
fi
