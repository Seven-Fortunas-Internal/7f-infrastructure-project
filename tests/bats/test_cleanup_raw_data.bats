#!/usr/bin/env bats
# =============================================================================
# P6-005 / P3-005: cleanup_raw_data.sh Tests
# Requirement: Data retention script must have a safe dry-run mode
# NFR: NFR-4.2, R-014
# =============================================================================
# Tests:
#   1. --dry-run exits 0
#   2. --dry-run prints candidate files but does not delete them
#   3. Unknown option exits 1
#   4. --days requires a positive integer argument
#   5. --dir outside project root is rejected (exit 1)
#   6. Empty directory exits 0 cleanly
#   7. No matching files (all within retention window) exits 0

SCRIPT="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)/scripts/cleanup_raw_data.sh"

setup() {
    WORK_DIR="$(mktemp -d)"
    RAW_DIR="$WORK_DIR/outputs/raw"
    mkdir -p "$RAW_DIR"
    # Override project root so the safety check accepts WORK_DIR
    export CLEANUP_PROJECT_ROOT="$WORK_DIR"
}

teardown() {
    rm -rf "$WORK_DIR"
}

# Helper: create an old file (older than 30 days)
_make_old_file() {
    local path="$1"
    touch "$path"
    # Set mtime to 40 days ago
    touch -d "40 days ago" "$path"
}

# Helper: create a recent file (1 day old — within retention window)
_make_recent_file() {
    local path="$1"
    touch "$path"
    touch -d "1 day ago" "$path"
}

# ---------------------------------------------------------------------------
# 1. --dry-run exits 0
# ---------------------------------------------------------------------------
@test "dry-run exits 0 when directory is empty" {
    run bash "$SCRIPT" --dry-run --dir "$RAW_DIR"
    [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# 2. --dry-run prints candidates but does not delete them
# ---------------------------------------------------------------------------
@test "dry-run prints old file name but does not delete it" {
    _make_old_file "$RAW_DIR/old_data.json"

    run bash "$SCRIPT" --dry-run --dir "$RAW_DIR" --days 30
    [ "$status" -eq 0 ]

    # Output should mention the file
    [[ "$output" == *"old_data.json"* ]]

    # File must still exist
    [ -f "$RAW_DIR/old_data.json" ]
}

@test "dry-run output contains DRY RUN label" {
    run bash "$SCRIPT" --dry-run --dir "$RAW_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"DRY RUN"* ]]
}

# ---------------------------------------------------------------------------
# 3. Unknown option exits 1
# ---------------------------------------------------------------------------
@test "unknown option exits 1" {
    run bash "$SCRIPT" --unknown-flag
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown option"* ]] || [[ "$output" == *"ERROR"* ]]
}

# ---------------------------------------------------------------------------
# 4. --days requires a positive integer
# ---------------------------------------------------------------------------
@test "--days without value exits 1" {
    run bash "$SCRIPT" --days
    [ "$status" -eq 1 ]
}

@test "--days with non-numeric value exits 1" {
    run bash "$SCRIPT" --days abc
    [ "$status" -eq 1 ]
}

# ---------------------------------------------------------------------------
# 5. --dir outside project root is rejected
# ---------------------------------------------------------------------------
@test "directory outside project root is rejected" {
    run bash "$SCRIPT" --dry-run --dir /tmp
    [ "$status" -eq 1 ]
    [[ "$output" == *"outside"* ]] || [[ "$output" == *"ERROR"* ]]
}

# ---------------------------------------------------------------------------
# 6. Empty directory exits 0 cleanly
# ---------------------------------------------------------------------------
@test "empty raw directory exits 0 with nothing-to-clean message" {
    run bash "$SCRIPT" --dry-run --dir "$RAW_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"nothing to clean"* ]] || [[ "$output" == *"does not exist"* ]] || [[ "$output" == *"No files"* ]]
}

# ---------------------------------------------------------------------------
# 7. Recent files are not flagged for deletion
# ---------------------------------------------------------------------------
@test "recent files are not listed for deletion in dry-run" {
    _make_recent_file "$RAW_DIR/recent_data.json"

    run bash "$SCRIPT" --dry-run --dir "$RAW_DIR" --days 30
    [ "$status" -eq 0 ]

    # File must still exist
    [ -f "$RAW_DIR/recent_data.json" ]
    # Output should say no matching files
    [[ "$output" == *"No files"* ]] || [[ "$output" == *"0 total"* ]] || ! [[ "$output" == *"recent_data.json"* ]]
}
