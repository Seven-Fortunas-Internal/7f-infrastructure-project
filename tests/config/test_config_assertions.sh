#!/usr/bin/env bash
# =============================================================================
# tests/config/test_config_assertions.sh — P0-008 (FR-10.1 / FR-10.4)
# =============================================================================
# Verifies that the CI quality gate workflows exist and are structurally correct.
# These workflows form the prevention layer (FR-10.x) that blocks bad code from
# entering the main branch.
#
# Usage:
#   bash tests/config/test_config_assertions.sh [--output PATH]
#
# Exit codes:
#   0 = all assertions pass
#   1 = one or more assertions fail
#
# JSON output contract (7F test format):
# {
#   "test_id": "P0-008",
#   "requirement": "FR-10.1",
#   "status": "PASS" | "FAIL",
#   "message": "...",
#   "duration_ms": N,
#   "detail": {
#     "total": N, "passed": N, "failed": N,
#     "results": [{ "assertion": "...", "status": "PASS"|"FAIL", "detail": "..." }]
#   }
# }
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WORKFLOWS_DIR="$PROJECT_ROOT/.github/workflows"

OUTPUT_PATH=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --output) OUTPUT_PATH="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

START_MS=$(date +%s%3N)

PASS_COUNT=0
FAIL_COUNT=0
RESULTS_TSV=$(mktemp)
trap 'rm -f "$RESULTS_TSV"' EXIT

# ---------------------------------------------------------------------------
# Assertion helpers
# ---------------------------------------------------------------------------

pass() {
    local name="$1" detail="${2:-}"
    PASS_COUNT=$((PASS_COUNT + 1))
    printf '%s\tPASS\t%s\n' "$name" "$detail" >> "$RESULTS_TSV"
    echo "  ✓ $name" >&2
}

fail() {
    local name="$1" detail="${2:-}"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    printf '%s\tFAIL\t%s\n' "$name" "$detail" >> "$RESULTS_TSV"
    echo "  ✗ $name: $detail" >&2
}

assert_file_exists() {
    local name="$1" path="$2"
    if [[ -f "$path" ]]; then
        pass "$name"
    else
        fail "$name" "File not found: $path"
    fi
}

assert_yaml_contains() {
    local name="$1" path="$2" pattern="$3"
    if [[ ! -f "$path" ]]; then
        fail "$name" "File not found: $path"
        return
    fi
    # Use -E for extended regex so | works for alternation
    if grep -Eq "$pattern" "$path"; then
        pass "$name"
    else
        fail "$name" "Pattern '$pattern' not found in $(basename "$path")"
    fi
}

# ---------------------------------------------------------------------------
# P0-008a: Required CI gate workflows exist
# ---------------------------------------------------------------------------
echo "=== P0-008: CI Quality Gate Structure Assertions ===" >&2
echo "" >&2
echo "--- Existence checks ---" >&2

REQUIRED_WORKFLOWS=(
    "workflow-compliance-gate.yml:Workflow Compliance Gate exists (FR-10.1)"
    "python-static-analysis.yml:Python Static Analysis workflow exists (FR-10.3)"
    "workflow-sentinel.yml:Workflow Sentinel exists (FR-9.1 / ADR-006)"
    "secret-reference-audit.yml:Secret Reference Audit exists"
    "test-coverage-validation.yml:Test Coverage Validation exists"
)

for entry in "${REQUIRED_WORKFLOWS[@]}"; do
    filename="${entry%%:*}"
    description="${entry##*:}"
    assert_file_exists "$description" "$WORKFLOWS_DIR/$filename"
done

# ---------------------------------------------------------------------------
# P0-008b: workflow-compliance-gate.yml structure (FR-10.1)
# ---------------------------------------------------------------------------
echo "" >&2
echo "--- workflow-compliance-gate.yml structure (FR-10.1) ---" >&2
WCG="$WORKFLOWS_DIR/workflow-compliance-gate.yml"

assert_yaml_contains \
    "Compliance gate triggers on pull_request" \
    "$WCG" "pull_request"

assert_yaml_contains \
    "Compliance gate monitors .github/workflows/ changes" \
    "$WCG" ".github/workflows/"

assert_yaml_contains \
    "Compliance gate has at least one job" \
    "$WCG" "^jobs:"

assert_yaml_contains \
    "Compliance gate references NFR-5.6 or validate script" \
    "$WCG" "NFR-5\.6|validate.*workflow|[Cc]ompliance"

# ---------------------------------------------------------------------------
# P0-008c: python-static-analysis.yml structure (FR-10.3)
# ---------------------------------------------------------------------------
echo "" >&2
echo "--- python-static-analysis.yml structure (FR-10.3) ---" >&2
PSA="$WORKFLOWS_DIR/python-static-analysis.yml"

assert_yaml_contains \
    "Python analysis triggers on pull_request" \
    "$PSA" "pull_request"

assert_yaml_contains \
    "Python analysis monitors scripts/**" \
    "$PSA" "scripts/"

assert_yaml_contains \
    "Python analysis has at least one job" \
    "$PSA" "^jobs:"

assert_yaml_contains \
    "Python analysis references mypy or pylint" \
    "$PSA" "mypy|pylint"

# ---------------------------------------------------------------------------
# P0-008d: workflow-sentinel.yml structure (FR-9.1 / ADR-006)
# ---------------------------------------------------------------------------
echo "" >&2
echo "--- workflow-sentinel.yml structure (FR-9.1) ---" >&2
WS="$WORKFLOWS_DIR/workflow-sentinel.yml"

assert_yaml_contains \
    "Sentinel has workflow_run trigger (FR-9.1)" \
    "$WS" "workflow_run"

assert_yaml_contains \
    "Sentinel monitors at least one workflow" \
    "$WS" "workflows:"

assert_yaml_contains \
    "Sentinel has at least one job" \
    "$WS" "^jobs:"

assert_yaml_contains \
    "Sentinel calls classify or Claude analysis step" \
    "$WS" "classify|[Cc]laude|anthropic|Anthropic"

# ---------------------------------------------------------------------------
# P0-008e: All gate workflows use GITHUB_TOKEN or secrets pattern (NFR-7.2)
# ---------------------------------------------------------------------------
echo "" >&2
echo "--- Secret hygiene (NFR-7.2) ---" >&2

for wf in "$WCG" "$PSA" "$WS"; do
    name="$(basename "$wf") has no hardcoded tokens"
    if grep -qiE "(ghp_|sk-ant-|AKIA)[A-Za-z0-9]" "$wf"; then
        fail "$name" "Possible hardcoded token found"
    else
        pass "$name"
    fi
done

# ---------------------------------------------------------------------------
# P0-008f: All gate workflows have timeout-minutes (NFR-5.5)
# ---------------------------------------------------------------------------
echo "" >&2
echo "--- Timeout guards (NFR-5.5) ---" >&2

for wf in "$WCG" "$PSA"; do
    name="$(basename "$wf") has timeout-minutes"
    if grep -q "timeout-minutes" "$wf"; then
        pass "$name"
    else
        fail "$name" "No timeout-minutes found — risk of hung jobs"
    fi
done

# ---------------------------------------------------------------------------
# P0-008g: workflow-compliance-gate blocks PRs (has pull_request event)
# ---------------------------------------------------------------------------
echo "" >&2
echo "--- PR blocking gate check (FR-10.1) ---" >&2

# The compliance gate must run on opened/synchronize/reopened to block PRs
WCG_TYPES=$(grep -A5 "pull_request:" "$WCG" | grep "types:" || echo "")
if echo "$WCG_TYPES" | grep -qE "synchronize|opened"; then
    pass "Compliance gate triggers on PR open/synchronize events"
else
    fail "Compliance gate triggers on PR open/synchronize events" \
         "types: must include 'synchronize' to block new pushes"
fi

# ---------------------------------------------------------------------------
# Build JSON output
# ---------------------------------------------------------------------------
END_MS=$(date +%s%3N)
DURATION_MS=$(( END_MS - START_MS ))

TOTAL=$(( PASS_COUNT + FAIL_COUNT ))

if [[ $FAIL_COUNT -gt 0 ]]; then
    OVERALL_STATUS="FAIL"
    MESSAGE="$FAIL_COUNT/$TOTAL CI quality gate assertions failed (FR-10.1)"
else
    OVERALL_STATUS="PASS"
    MESSAGE="All $TOTAL CI quality gate structure assertions passed"
fi

JSON_REPORT=$(python3 - "$RESULTS_TSV" "$DURATION_MS" "$OVERALL_STATUS" "$MESSAGE" "$PASS_COUNT" "$FAIL_COUNT" "$TOTAL" <<'PYEOF'
import sys, json

results_file  = sys.argv[1]
duration_ms   = int(sys.argv[2])
overall       = sys.argv[3]
message       = sys.argv[4]
pass_count    = int(sys.argv[5])
fail_count    = int(sys.argv[6])
total         = int(sys.argv[7])

rows = []
with open(results_file) as f:
    for line in f:
        line = line.rstrip("\n")
        if not line:
            continue
        parts = line.split("\t", 2)
        rows.append({
            "assertion": parts[0],
            "status":    parts[1],
            "detail":    parts[2] if len(parts) > 2 else "",
        })

report = {
    "test_id":     "P0-008",
    "requirement": "FR-10.1",
    "description": "CI quality gate workflows exist and are structurally correct",
    "status":      overall,
    "message":     message,
    "duration_ms": duration_ms,
    "detail": {
        "total":   total,
        "passed":  pass_count,
        "failed":  fail_count,
        "results": rows,
    },
}
print(json.dumps(report, indent=2))
PYEOF
)

echo "" >&2
echo "P0-008: $OVERALL_STATUS — $MESSAGE" >&2

if [[ -n "$OUTPUT_PATH" ]]; then
    echo "$JSON_REPORT" > "$OUTPUT_PATH"
    echo "Report written to: $OUTPUT_PATH" >&2
else
    echo "$JSON_REPORT"
fi

[[ "$OVERALL_STATUS" == "PASS" ]] && exit 0 || exit 1
