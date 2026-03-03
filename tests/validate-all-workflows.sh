#!/usr/bin/env bash
# =============================================================================
# tests/validate-all-workflows.sh — P0-006 (NFR-5.6)
# =============================================================================
# Validates every .github/workflows/*.yml against the C1-C8 compliance rules
# enforced by scripts/validate-and-fix-workflow.sh.
#
# Usage:
#   bash tests/validate-all-workflows.sh [--output PATH]
#
# Options:
#   --output PATH   Write JSON report to file (default: stdout)
#
# Exit codes:
#   0 = all workflows pass
#   1 = one or more workflows failed validation
#
# JSON output contract:
# {
#   "test_id": "P0-006",
#   "requirement": "NFR-5.6",
#   "description": "All CI/CD workflows comply with C1-C8 constraints",
#   "status": "PASS" | "FAIL",
#   "message": "...",
#   "duration_ms": N,
#   "detail": {
#     "total": N,
#     "passed": N,
#     "warned": N,
#     "failed": N,
#     "results": [
#       { "workflow": "name.yml", "status": "PASS"|"WARN"|"FAIL", "exit_code": N }
#     ]
#   }
# }
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VALIDATOR="$PROJECT_ROOT/scripts/validate-and-fix-workflow.sh"
WORKFLOWS_DIR="$PROJECT_ROOT/.github/workflows"

OUTPUT_PATH=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --output) OUTPUT_PATH="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# --- Sanity checks ---
if [[ ! -x "$VALIDATOR" ]]; then
    echo "ERROR: Validator not found or not executable: $VALIDATOR" >&2
    exit 1
fi
if [[ ! -d "$WORKFLOWS_DIR" ]]; then
    echo "ERROR: Workflows directory not found: $WORKFLOWS_DIR" >&2
    exit 1
fi

START_MS=$(date +%s%3N)

# Collect results into a temp TSV: workflow_name<TAB>status<TAB>exit_code
RESULTS_TSV=$(mktemp)
trap 'rm -f "$RESULTS_TSV"' EXIT

# --- Validate each workflow ---
while IFS= read -r -d '' workflow_file; do
    workflow_name="$(basename "$workflow_file")"

    set +e
    "$VALIDATOR" "$workflow_file" > /dev/null 2>&1
    exit_code=$?
    set -e

    case $exit_code in
        0) status="PASS" ;;
        2) status="WARN" ;;
        *) status="FAIL" ;;
    esac

    printf '%s\t%s\t%d\n' "$workflow_name" "$status" "$exit_code" >> "$RESULTS_TSV"

done < <(find "$WORKFLOWS_DIR" -maxdepth 1 -name "*.yml" -print0 | sort -z)

END_MS=$(date +%s%3N)
DURATION_MS=$(( END_MS - START_MS ))

# --- Build JSON report via Python (handles encoding cleanly) ---
JSON_REPORT=$(python3 - "$RESULTS_TSV" "$DURATION_MS" <<'PYEOF'
import sys, json

results_file = sys.argv[1]
duration_ms  = int(sys.argv[2])

rows = []
with open(results_file) as f:
    for line in f:
        line = line.rstrip("\n")
        if not line:
            continue
        parts = line.split("\t")
        rows.append({
            "workflow":  parts[0],
            "status":    parts[1],
            "exit_code": int(parts[2]),
        })

total      = len(rows)
pass_count = sum(1 for r in rows if r["status"] == "PASS")
warn_count = sum(1 for r in rows if r["status"] == "WARN")
fail_count = sum(1 for r in rows if r["status"] == "FAIL")

if fail_count > 0:
    overall = "FAIL"
    message = f"{fail_count}/{total} workflows failed NFR-5.6 compliance (C1-C8 constraints)"
else:
    overall = "PASS"
    message = f"All {total} workflows pass NFR-5.6 compliance ({warn_count} with warnings)"

report = {
    "test_id":     "P0-006",
    "requirement": "NFR-5.6",
    "description": "All CI/CD workflows comply with C1-C8 constraints",
    "status":      overall,
    "message":     message,
    "duration_ms": duration_ms,
    "detail": {
        "total":   total,
        "passed":  pass_count,
        "warned":  warn_count,
        "failed":  fail_count,
        "results": rows,
    },
}
print(json.dumps(report, indent=2))
PYEOF
)

# --- Output ---
if [[ -n "$OUTPUT_PATH" ]]; then
    echo "$JSON_REPORT" > "$OUTPUT_PATH"
    python3 -c "import sys,json; d=json.loads(open('$OUTPUT_PATH').read()); print(f'P0-006: {d[\"status\"]} -- {d[\"message\"]}')" >&2
    echo "Report written to: $OUTPUT_PATH" >&2
else
    echo "$JSON_REPORT"
fi

# Exit code based on overall status
echo "$JSON_REPORT" | python3 -c "import sys,json; sys.exit(0 if json.load(sys.stdin)['status']=='PASS' else 1)"
