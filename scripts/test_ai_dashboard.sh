#!/bin/bash
# Test FR-4.1: AI Advancements Dashboard (MVP)

set -e

echo "============================================================"
echo "Testing FEATURE_015: AI Advancements Dashboard (MVP)"
echo "============================================================"
echo

# Clone latest from GitHub
echo "Cloning latest dashboards repository..."
rm -rf /tmp/dashboards-verify
git clone https://github.com/Seven-Fortunas/dashboards.git /tmp/dashboards-verify 2>&1 | grep -v "^Cloning" || true
cd /tmp/dashboards-verify

echo

# Test 1: Verify sources.yaml is in config directory
echo "Test 1: Verify ai/config/sources.yaml exists"
echo "------------------------------------------------------------"
if [[ -f "ai/config/sources.yaml" ]]; then
    echo "✓ ai/config/sources.yaml exists"
else
    echo "✗ ai/config/sources.yaml not found"
    exit 1
fi

if [[ -f "ai/sources.yaml" ]]; then
    echo "✗ ai/sources.yaml still exists (should be moved to config/)"
    exit 1
else
    echo "✓ ai/sources.yaml removed (correctly moved to config/)"
fi

echo

# Test 2: Verify cache_max_age_hours is 168
echo "Test 2: Verify cache_max_age_hours: 168"
echo "------------------------------------------------------------"
if grep -q "cache_max_age_hours: 168" ai/config/sources.yaml; then
    echo "✓ cache_max_age_hours set to 168 (7 days)"
else
    ACTUAL=$(grep "cache_max_age_hours:" ai/config/sources.yaml || echo "NOT_FOUND")
    echo "✗ cache_max_age_hours not set to 168"
    echo "  Actual: $ACTUAL"
    exit 1
fi

echo

# Test 3: Verify r/LocalLLaMA is in Reddit sources
echo "Test 3: Verify r/LocalLLaMA Reddit source"
echo "------------------------------------------------------------"
if grep -q "LocalLLaMA" ai/config/sources.yaml; then
    echo "✓ LocalLLaMA Reddit source present"
else
    echo "✗ LocalLLaMA not found in sources"
    exit 1
fi

echo

# Test 4: Verify React 18.x dependency
echo "Test 4: Verify React 18.x in package.json"
echo "------------------------------------------------------------"
if grep -q '"react": "\^18' ai/package.json; then
    REACT_VERSION=$(grep '"react"' ai/package.json | head -1)
    echo "✓ React 18.x dependency present"
    echo "  $REACT_VERSION"
else
    echo "✗ React 18.x not found"
    exit 1
fi

echo

# Test 5: Verify build succeeds
echo "Test 5: Verify npm build succeeds"
echo "------------------------------------------------------------"
cd ai
if npm ci --silent 2>&1 | grep -q "error"; then
    echo "✗ npm install failed"
    exit 1
fi

if npm run build 2>&1 | grep -q "error"; then
    echo "✗ npm build failed"
    exit 1
fi

if [[ -d "dist" ]]; then
    echo "✓ Build succeeded, dist/ directory created"
else
    echo "✗ Build did not create dist/ directory"
    exit 1
fi

cd ..

echo

# Test 6: Verify CSS has mobile media query
echo "Test 6: Verify @media (max-width: 1024px) in CSS"
echo "------------------------------------------------------------"
if grep -q "max-width: 1024px" ai/src/styles/dashboard.css; then
    echo "✓ Mobile media query present"
else
    echo "✗ @media (max-width: 1024px) not found"
    exit 1
fi

echo

# Test 7: Verify CSS has touch target sizing
echo "Test 7: Verify min-height: 44px touch targets"
echo "------------------------------------------------------------"
if grep -q "min-height: 44px" ai/src/styles/dashboard.css; then
    echo "✓ Touch target sizing present"
else
    echo "✗ min-height: 44px not found"
    exit 1
fi

echo

# Test 8: Verify LastUpdated component shows next update
echo "Test 8: Verify LastUpdated shows next update time"
echo "------------------------------------------------------------"
if grep -q "nextUpdate" ai/src/components/LastUpdated.jsx; then
    echo "✓ LastUpdated calculates next update time"
else
    echo "✗ nextUpdate not found in LastUpdated component"
    exit 1
fi

if grep -q "+ 6 \* 60 \* 60 \* 1000" ai/src/components/LastUpdated.jsx; then
    echo "✓ Next update calculation uses +6 hours"
else
    echo "✗ +6 hours calculation not found"
    exit 1
fi

echo

# Test 9: Verify App.jsx has staleness check
echo "Test 9: Verify App.jsx staleness check (> 7 days)"
echo "------------------------------------------------------------"
if grep -q "hoursDiff > 168" ai/src/App.jsx; then
    echo "✓ Staleness check present (> 168 hours)"
else
    echo "✗ Staleness check not found"
    exit 1
fi

echo

# Test 10: Verify App.jsx has error state
echo "Test 10: Verify App.jsx error handling"
echo "------------------------------------------------------------"
if grep -q "ErrorBanner" ai/src/App.jsx; then
    echo "✓ ErrorBanner component used"
else
    echo "✗ ErrorBanner not found"
    exit 1
fi

if grep -q "setError" ai/src/App.jsx; then
    echo "✓ Error state management present"
else
    echo "✗ Error state not found"
    exit 1
fi

echo

# Test 11: Verify GitHub Actions cron schedule
echo "Test 11: Verify GitHub Actions cron schedule"
echo "------------------------------------------------------------"
if grep -q "0 \*/6 \* \* \*" .github/workflows/update-ai-dashboard.yml; then
    echo "✓ Cron schedule correct (every 6 hours)"
else
    echo "✗ Cron schedule incorrect"
    exit 1
fi

echo

# Summary
echo "============================================================"
echo "FEATURE_015 Test Results: ALL TESTS PASSED"
echo "============================================================"
echo
echo "✓ sources.yaml moved to config/sources.yaml"
echo "✓ cache_max_age_hours set to 168 (7 days)"
echo "✓ r/LocalLLaMA Reddit source added"
echo "✓ React 18.x dependency present"
echo "✓ Build succeeds (npm ci && npm run build)"
echo "✓ Mobile responsive CSS (@media max-width: 1024px)"
echo "✓ Touch target sizing (min-height: 44px)"
echo "✓ LastUpdated shows next update time (+6 hours)"
echo "✓ App.jsx staleness check (> 7 days)"
echo "✓ App.jsx error handling (ErrorBanner)"
echo "✓ GitHub Actions cron schedule (0 */6 * * *)"
echo
echo "AI Advancements Dashboard meets all FR-4.1 requirements."
echo "============================================================"
