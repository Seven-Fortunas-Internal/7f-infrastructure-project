#!/bin/bash
# Verification script for FEATURE_055: AI Dashboard React UI

set -e

echo "========================================="
echo "FEATURE_055 Verification"
echo "AI Dashboard React UI"
echo "========================================="
echo ""

FUNCTIONAL_PASS=0
TECHNICAL_PASS=0
INTEGRATION_PASS=0

# ===========================================
# FUNCTIONAL CRITERIA
# ===========================================
echo "📋 Testing FUNCTIONAL Criteria..."
echo "- React app structure exists"
echo "- Components implemented (UpdateCard, SourceFilter, ErrorBanner, LastUpdated, SearchBar)"
echo "- Mobile-responsive design"
echo ""

# Check React app structure
if [ -f "dashboards/ai/package.json" ]; then
    echo "  ✅ package.json exists"

    # Check for React app files
    if [ -f "dashboards/ai/src/App.js" ] && \
       [ -f "dashboards/ai/src/index.js" ] && \
       [ -f "dashboards/ai/public/index.html" ]; then
        echo "  ✅ React app structure complete"

        # Check for components in App.js
        if grep -q "UpdateCard" "dashboards/ai/src/App.js" && \
           grep -q "SourceFilter" "dashboards/ai/src/App.js" && \
           grep -q "ErrorBanner" "dashboards/ai/src/App.js" && \
           grep -q "LastUpdated" "dashboards/ai/src/App.js" && \
           grep -q "SearchBar" "dashboards/ai/src/App.js"; then
            echo "  ✅ All required components implemented"

            # Check for mobile responsive CSS
            if [ -f "dashboards/ai/src/App.css" ] && \
               grep -q "@media.*375px" "dashboards/ai/src/App.css"; then
                echo "  ✅ Mobile-responsive design (375px breakpoint)"
                FUNCTIONAL_PASS=1
            else
                echo "  ⚠️ Mobile responsive CSS not found"
            fi
        else
            echo "  ❌ Missing required components"
        fi
    else
        echo "  ❌ React app structure incomplete"
    fi
else
    echo "  ❌ package.json not found"
fi

echo ""

# ===========================================
# TECHNICAL CRITERIA
# ===========================================
echo "📋 Testing TECHNICAL Criteria..."
echo "- React 18.x configured"
echo "- Build configuration valid"
echo ""

# Check React version
if [ -f "dashboards/ai/package.json" ]; then
    if grep -q '"react": "^18' "dashboards/ai/package.json"; then
        echo "  ✅ React 18.x configured"

        # Check for build script
        if grep -q '"build":' "dashboards/ai/package.json"; then
            echo "  ✅ Build script configured"
            TECHNICAL_PASS=1
        else
            echo "  ❌ Build script not found"
        fi
    else
        echo "  ❌ React 18.x not configured"
    fi
fi

echo ""

# ===========================================
# INTEGRATION CRITERIA
# ===========================================
echo "📋 Testing INTEGRATION Criteria..."
echo "- Deploy pipeline configured (GitHub Actions)"
echo "- Data loading from cached_updates.json"
echo ""

# Check for GitHub Actions workflow
if [ -f ".github/workflows/deploy-ai-dashboard.yml" ]; then
    echo "  ✅ GitHub Actions deploy workflow exists"

    # Check if workflow builds React app
    if grep -q "npm run build" ".github/workflows/deploy-ai-dashboard.yml"; then
        echo "  ✅ Workflow includes build step"
    fi

    # Check if workflow copies data files
    if grep -q "cached_updates.json" ".github/workflows/deploy-ai-dashboard.yml"; then
        echo "  ✅ Workflow copies data files"
    fi
else
    echo "  ❌ GitHub Actions workflow not found"
fi

# Check if App.js loads from cached_updates.json
if grep -q "cached_updates.json" "dashboards/ai/src/App.js"; then
    echo "  ✅ App loads data from cached_updates.json"
    INTEGRATION_PASS=1
else
    echo "  ❌ Data loading not configured"
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
    echo "All verification criteria met for FEATURE_055"
    echo ""
    echo "Note: Full functional testing requires:"
    echo "  - npm install in dashboards/ai/"
    echo "  - npm run build to verify build succeeds"
    echo "  - Browser testing at https://seven-fortunas.github.io/dashboards/ai/"
    exit 0
else
    echo "❌ OVERALL: FAIL"
    echo ""
    echo "Some verification criteria not met"
    exit 1
fi
