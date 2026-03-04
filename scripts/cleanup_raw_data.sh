#!/usr/bin/env bash
# =============================================================================
# cleanup_raw_data.sh — Data Retention Cleanup Script
#
# Requirement: P3-005 — Data retention script with safe dry-run mode
# FR reference: NFR-4.2 (data hygiene), R-014 (staging data retention)
#
# Usage:
#   bash scripts/cleanup_raw_data.sh [--dry-run] [--days N] [--dir PATH]
#
# Options:
#   --dry-run        Print files that would be deleted; do not delete (default: off)
#   --days N         Delete files older than N days (default: 30)
#   --dir PATH       Directory to clean (default: outputs/raw)
#
# Exit codes:
#   0  Success (or dry-run completed with no errors)
#   1  Invalid arguments, permission error, or unsafe path detected
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
DRY_RUN=false
RETENTION_DAYS=30
TARGET_DIR="outputs/raw"

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --days)
            if [[ -z "${2:-}" || ! "${2}" =~ ^[0-9]+$ ]]; then
                echo "ERROR: --days requires a positive integer" >&2
                exit 1
            fi
            RETENTION_DAYS="$2"
            shift 2
            ;;
        --dir)
            if [[ -z "${2:-}" ]]; then
                echo "ERROR: --dir requires a path argument" >&2
                exit 1
            fi
            TARGET_DIR="$2"
            shift 2
            ;;
        *)
            echo "ERROR: Unknown option: $1" >&2
            echo "Usage: $0 [--dry-run] [--days N] [--dir PATH]" >&2
            exit 1
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Safety: resolve and validate TARGET_DIR
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Allow CLEANUP_PROJECT_ROOT override for testing (must be absolute path)
PROJECT_ROOT="${CLEANUP_PROJECT_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"

# Resolve to absolute path (may not exist yet — don't use realpath -e)
if [[ "$TARGET_DIR" = /* ]]; then
    ABS_TARGET="$TARGET_DIR"
else
    ABS_TARGET="$PROJECT_ROOT/$TARGET_DIR"
fi

# Safety check: target must be inside project root
if [[ "$ABS_TARGET" != "$PROJECT_ROOT"/* ]]; then
    echo "ERROR: Target directory '$ABS_TARGET' is outside the project root '$PROJECT_ROOT'" >&2
    echo "Refusing to clean outside project boundaries." >&2
    exit 1
fi

# Safety check: never touch scripts/ or .github/ — guard against misconfiguration
FORBIDDEN_PATTERNS=("$PROJECT_ROOT/scripts" "$PROJECT_ROOT/.github" "$PROJECT_ROOT/.git")
for forbidden in "${FORBIDDEN_PATTERNS[@]}"; do
    if [[ "$ABS_TARGET" == "$forbidden"* ]]; then
        echo "ERROR: Target '$ABS_TARGET' overlaps forbidden path '$forbidden'" >&2
        exit 1
    fi
done

# ---------------------------------------------------------------------------
# Main logic
# ---------------------------------------------------------------------------
if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY RUN] cleanup_raw_data.sh — no files will be deleted"
else
    echo "[LIVE] cleanup_raw_data.sh — files will be permanently deleted"
fi

echo "Target directory : $ABS_TARGET"
echo "Retention policy : files older than ${RETENTION_DAYS} days"
echo ""

if [[ ! -d "$ABS_TARGET" ]]; then
    echo "Target directory does not exist — nothing to clean."
    exit 0
fi

# Find matching files
FOUND_FILES=()
while IFS= read -r -d '' file; do
    FOUND_FILES+=("$file")
done < <(find "$ABS_TARGET" -type f -mtime +"${RETENTION_DAYS}" -print0 2>/dev/null)

FILE_COUNT="${#FOUND_FILES[@]}"

if [[ "$FILE_COUNT" -eq 0 ]]; then
    echo "No files older than ${RETENTION_DAYS} days found in ${ABS_TARGET}."
    exit 0
fi

echo "Files matching retention policy (${FILE_COUNT} total):"
for file in "${FOUND_FILES[@]}"; do
    echo "  $file"
done
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY RUN] ${FILE_COUNT} file(s) would be deleted. Re-run without --dry-run to execute."
else
    DELETED=0
    FAILED=0
    for file in "${FOUND_FILES[@]}"; do
        if rm -f "$file"; then
            echo "  Deleted: $file"
            (( DELETED++ )) || true
        else
            echo "  ERROR: Failed to delete: $file" >&2
            (( FAILED++ )) || true
        fi
    done

    echo ""
    echo "Cleanup complete: ${DELETED} deleted, ${FAILED} failed."

    if [[ "$FAILED" -gt 0 ]]; then
        exit 1
    fi
fi

exit 0
