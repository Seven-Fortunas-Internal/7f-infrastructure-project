#!/bin/bash
# Verification script for FEATURE_057: Company Website Landing Page

set -e

echo "========================================="
echo "FEATURE_057 Verification"
echo "Company Website Landing Page"
echo "========================================="
echo ""

FUNCTIONAL_PASS=0
TECHNICAL_PASS=0
INTEGRATION_PASS=0

# ===========================================
# FUNCTIONAL CRITERIA
# ===========================================
echo "📋 Testing FUNCTIONAL Criteria..."
echo "- Landing page exists at root (index.html)"
echo "- Links to dashboards"
echo "- About section with mission and team"
echo "- Mobile-responsive"
echo ""

# Check if index.html exists
if [ -f "index.html" ]; then
    echo "  ✅ index.html exists at root"

    # Check for dashboard links
    if grep -q "dashboards/ai/" "index.html"; then
        echo "  ✅ Link to AI dashboard present"
    fi

    # Check for about section
    if grep -q "About Seven Fortunas" "index.html" && \
       grep -q "Mission" "index.html" && \
       grep -q "Jorge" "index.html"; then
        echo "  ✅ About section with mission and team"
    fi

    # Check for mobile responsive design
    if grep -q "@media.*max-width.*768px" "index.html" || \
       grep -q "@media.*max-width.*375px" "index.html"; then
        echo "  ✅ Mobile-responsive design"
        FUNCTIONAL_PASS=1
    else
        echo "  ⚠️ Mobile responsive CSS not found"
    fi
else
    echo "  ❌ index.html not found"
fi

echo ""

# ===========================================
# TECHNICAL CRITERIA
# ===========================================
echo "📋 Testing TECHNICAL Criteria..."
echo "- index.html is valid HTML5"
echo "- Professional design and branding"
echo ""

# Check if index.html is valid HTML
if [ -f "index.html" ]; then
    # Check for DOCTYPE
    if head -1 "index.html" | grep -qi "<!DOCTYPE html>"; then
        echo "  ✅ Valid HTML5 DOCTYPE"

        # Check for essential HTML structure
        if grep -q "<html" "index.html" && \
           grep -q "<head>" "index.html" && \
           grep -q "<body>" "index.html"; then
            echo "  ✅ Valid HTML structure"

            # Check for company branding
            if grep -q "Seven Fortunas" "index.html"; then
                echo "  ✅ Company branding present"
                TECHNICAL_PASS=1
            fi
        fi
    else
        echo "  ❌ Invalid HTML structure"
    fi
else
    echo "  ❌ index.html not found"
fi

echo ""

# ===========================================
# INTEGRATION CRITERIA
# ===========================================
echo "📋 Testing INTEGRATION Criteria..."
echo "- Links to FEATURE_055 (AI Dashboard)"
echo "- Ready for GitHub Pages deployment (FEATURE_056)"
echo ""

# Check for AI dashboard link
if [ -f "index.html" ]; then
    if grep -q "dashboards/ai/" "index.html"; then
        echo "  ✅ Links to AI Dashboard (FEATURE_055)"

        # Check if link is properly formatted for GitHub Pages
        if grep -q 'href="dashboards/ai/"' "index.html"; then
            echo "  ✅ Link formatted for GitHub Pages"
            INTEGRATION_PASS=1
        fi
    else
        echo "  ❌ No link to AI Dashboard"
    fi
fi

echo ""
echo "========================================="
echo "VERIFICATION RESULTS"
echo "========================================="
echo ""

if [ $FUNCTIONAL_PASS -eq 1 ]; then
    echo "✅ FUNCTIONAL: PASS"
else
    echo "❌ FUNCTIONAL: FAIL"
fi

if [ $TECHNICAL_PASS -eq 1 ]; then
    echo "✅ TECHNICAL: PASS"
else
    echo "❌ TECHNICAL: FAIL"
fi

if [ $INTEGRATION_PASS -eq 1 ]; then
    echo "✅ INTEGRATION: PASS"
else
    echo "❌ INTEGRATION: FAIL"
fi

echo ""

if [ $FUNCTIONAL_PASS -eq 1 ] && [ $TECHNICAL_PASS -eq 1 ] && [ $INTEGRATION_PASS -eq 1 ]; then
    echo "🎉 OVERALL: PASS"
    echo ""
    echo "All verification criteria met for FEATURE_057"
    echo ""
    echo "Landing page ready for deployment to:"
    echo "  https://seven-fortunas.github.io/"
    exit 0
else
    echo "❌ OVERALL: FAIL"
    echo ""
    echo "Some verification criteria not met"
    exit 1
fi
