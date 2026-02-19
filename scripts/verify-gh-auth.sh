#!/bin/bash
# FEATURE_001: GitHub CLI Authentication Verification
# Verifies GitHub CLI is authenticated and functional

set -e

echo "Verifying GitHub CLI Authentication..."
echo ""

# Functional Criterion: Execute 'gh auth status' and verify 'Logged in' message
echo "1. Functional Check: gh auth status"
if gh auth status 2>&1 | grep -q "Logged in"; then
    echo "   ✓ PASS: 'Logged in' message found"
else
    echo "   ✗ FAIL: Not logged in"
    exit 1
fi

# Technical Criterion: Command exits with status code 0 and token is valid
echo "2. Technical Check: Exit code and token validity"
if gh auth status &>/dev/null; then
    echo "   ✓ PASS: Exit code 0, authentication token valid"
else
    echo "   ✗ FAIL: Authentication check failed"
    exit 2
fi

# Integration Criterion: Can perform authenticated operations
echo "3. Integration Check: Authenticated API operations"
if gh api user &>/dev/null; then
    USERNAME=$(gh api user | jq -r '.login')
    echo "   ✓ PASS: Successfully called authenticated API (user: $USERNAME)"
else
    echo "   ✗ FAIL: Cannot perform authenticated operations"
    exit 3
fi

echo ""
echo "✅ All verification criteria passed"
echo "   GitHub CLI is properly authenticated and operational"
