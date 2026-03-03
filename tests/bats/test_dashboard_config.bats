#!/usr/bin/env bats
# =============================================================================
# P1-006: Dashboard configuration assertions (FR-4.1)
#         Validates ai/config/sources.yaml and dashboards/ai/vite.config.js
#         have the required structure, sources, and build settings.
#
# Run: bats tests/bats/test_dashboard_config.bats
# =============================================================================

PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
SOURCES_YAML="${PROJECT_ROOT}/dashboards/ai/config/sources.yaml"
VITE_CONFIG="${PROJECT_ROOT}/dashboards/ai/vite.config.js"
PACKAGE_JSON="${PROJECT_ROOT}/dashboards/ai/package.json"

# =============================================================================
# sources.yaml — existence and required fields
# =============================================================================

@test "P1-006-a: dashboards/ai/config/sources.yaml exists" {
    [ -f "$SOURCES_YAML" ]
}

@test "P1-006-b: cache_max_age_hours is 168 (7-day cache per spec)" {
    grep -q "cache_max_age_hours: 168" "$SOURCES_YAML"
}

@test "P1-006-c: LocalLLaMA source is present" {
    grep -q "LocalLLaMA" "$SOURCES_YAML"
}

@test "P1-006-d: degradation warning_threshold is 0.5" {
    grep -q "warning_threshold: 0.5" "$SOURCES_YAML"
}

@test "P1-006-e: at least one RSS source is enabled" {
    # sources.yaml must have an rss: section with at least one enabled: true
    run grep -A3 "rss:" "$SOURCES_YAML"
    [[ "$output" == *"enabled: true"* ]]
}

@test "P1-006-f: at least one GitHub source is enabled" {
    run grep -A3 "github:" "$SOURCES_YAML"
    [[ "$output" == *"enabled: true"* ]]
}

@test "P1-006-g: cache directory points to dashboards/ai/data" {
    grep -q "directory: dashboards/ai/data" "$SOURCES_YAML"
}

@test "P1-006-h: OpenAI Blog RSS source is present" {
    grep -q "OpenAI Blog" "$SOURCES_YAML"
}

@test "P1-006-i: Anthropic Blog RSS source is present" {
    grep -q "Anthropic Blog" "$SOURCES_YAML"
}

# =============================================================================
# vite.config.js — build and base path
# =============================================================================

@test "P1-006-j: dashboards/ai/vite.config.js exists" {
    [ -f "$VITE_CONFIG" ]
}

@test "P1-006-k: vite base path is '/dashboards/ai/' (GitHub Pages deployment)" {
    grep -q "base: '/dashboards/ai/'" "$VITE_CONFIG"
}

@test "P1-006-l: vite outDir is 'dist'" {
    grep -q "outDir: 'dist'" "$VITE_CONFIG"
}

@test "P1-006-m: vite test environment is jsdom" {
    grep -q "environment: 'jsdom'" "$VITE_CONFIG"
}

# =============================================================================
# package.json — dependency assertions
# =============================================================================

@test "P1-006-n: package.json exists" {
    [ -f "$PACKAGE_JSON" ]
}

@test "P1-006-o: react 18 is a dependency" {
    grep -q '"react":' "$PACKAGE_JSON"
    run grep '"react":' "$PACKAGE_JSON"
    [[ "$output" == *"18"* ]]
}

@test "P1-006-p: vitest is a devDependency" {
    grep -q '"vitest":' "$PACKAGE_JSON"
}

@test "P1-006-q: @testing-library/react is a devDependency" {
    grep -q '"@testing-library/react":' "$PACKAGE_JSON"
}
