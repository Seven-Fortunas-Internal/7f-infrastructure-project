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

# ---------------------------------------------------------------------------
# Helpers for live-deletion tests
# ---------------------------------------------------------------------------
_make_exactly_n_days_old() {
    local path="$1"
    local n="$2"
    touch "$path"
    touch -d "${n} days ago" "$path"
}

# ---------------------------------------------------------------------------
# 8. Live deletion: old file IS actually removed from filesystem
# ---------------------------------------------------------------------------
@test "live: old file is deleted (no --dry-run)" {
    _make_old_file "$RAW_DIR/stale.json"

    run bash "$SCRIPT" --dir "$RAW_DIR" --days 30
    [ "$status" -eq 0 ]

    # File must be gone
    [ ! -f "$RAW_DIR/stale.json" ]
}

# ---------------------------------------------------------------------------
# 9. Live deletion: recent file is NOT deleted
# ---------------------------------------------------------------------------
@test "live: recent file is NOT deleted" {
    _make_recent_file "$RAW_DIR/fresh.json"

    run bash "$SCRIPT" --dir "$RAW_DIR" --days 30
    [ "$status" -eq 0 ]

    # File must still exist
    [ -f "$RAW_DIR/fresh.json" ]
}

# ---------------------------------------------------------------------------
# 10. Boundary: file exactly 30 days old is NOT deleted (-mtime +30 = strictly > 30)
# ---------------------------------------------------------------------------
@test "boundary: file exactly 30 days old is NOT deleted" {
    _make_exactly_n_days_old "$RAW_DIR/boundary_30.json" 30

    run bash "$SCRIPT" --dir "$RAW_DIR" --days 30
    [ "$status" -eq 0 ]

    # 30 days old does NOT satisfy -mtime +30 (strictly greater than 30)
    [ -f "$RAW_DIR/boundary_30.json" ]
}

# ---------------------------------------------------------------------------
# 11. Boundary: file exactly 31 days old IS deleted (-mtime +30 satisfied)
# ---------------------------------------------------------------------------
@test "boundary: file exactly 31 days old IS deleted" {
    _make_exactly_n_days_old "$RAW_DIR/boundary_31.json" 31

    run bash "$SCRIPT" --dir "$RAW_DIR" --days 30
    [ "$status" -eq 0 ]

    # 31 days old satisfies -mtime +30
    [ ! -f "$RAW_DIR/boundary_31.json" ]
}

# ---------------------------------------------------------------------------
# 12. Filename with spaces is deleted correctly
# ---------------------------------------------------------------------------
@test "live: filename with spaces is deleted" {
    local spaced_file="$RAW_DIR/file with spaces.json"
    _make_old_file "$spaced_file"

    run bash "$SCRIPT" --dir "$RAW_DIR" --days 30
    [ "$status" -eq 0 ]

    [ ! -f "$spaced_file" ]
}

# ---------------------------------------------------------------------------
# 13. Filename with special characters ($, !, #) is deleted correctly
# ---------------------------------------------------------------------------
@test "live: filename with special characters is deleted" {
    local special_file="$RAW_DIR/file#with!chars.json"
    _make_old_file "$special_file"

    run bash "$SCRIPT" --dir "$RAW_DIR" --days 30
    [ "$status" -eq 0 ]

    [ ! -f "$special_file" ]
}

# ---------------------------------------------------------------------------
# 14. Multiple old files: all deleted; multiple recent files: all kept
# ---------------------------------------------------------------------------
@test "live: multiple old files all deleted, recent files all kept" {
    _make_old_file "$RAW_DIR/old1.json"
    _make_old_file "$RAW_DIR/old2.json"
    _make_old_file "$RAW_DIR/old3.json"
    _make_recent_file "$RAW_DIR/keep1.json"
    _make_recent_file "$RAW_DIR/keep2.json"

    run bash "$SCRIPT" --dir "$RAW_DIR" --days 30
    [ "$status" -eq 0 ]

    [ ! -f "$RAW_DIR/old1.json" ]
    [ ! -f "$RAW_DIR/old2.json" ]
    [ ! -f "$RAW_DIR/old3.json" ]
    [ -f "$RAW_DIR/keep1.json" ]
    [ -f "$RAW_DIR/keep2.json" ]
}

# ---------------------------------------------------------------------------
# 15. Nested subdirectory: old file in subdir is deleted (find is recursive)
# ---------------------------------------------------------------------------
@test "live: old file in nested subdirectory is deleted" {
    mkdir -p "$RAW_DIR/nested/deep"
    _make_old_file "$RAW_DIR/nested/deep/old_nested.json"

    run bash "$SCRIPT" --dir "$RAW_DIR" --days 30
    [ "$status" -eq 0 ]

    [ ! -f "$RAW_DIR/nested/deep/old_nested.json" ]
}

# ---------------------------------------------------------------------------
# 16. Partial deletion: some deleted (old), some kept (recent); output reports both
# ---------------------------------------------------------------------------
@test "live: partial deletion reports deleted count correctly" {
    _make_old_file "$RAW_DIR/gone.json"
    _make_recent_file "$RAW_DIR/stays.json"

    run bash "$SCRIPT" --dir "$RAW_DIR" --days 30
    [ "$status" -eq 0 ]

    [ ! -f "$RAW_DIR/gone.json" ]
    [ -f "$RAW_DIR/stays.json" ]
    # Output should confirm 1 deleted
    [[ "$output" == *"1 deleted"* ]]
}

# ---------------------------------------------------------------------------
# 17. Permission error: rm fails → script exits 1 and reports failed count
#     Uses PATH override so the fake rm always fails (hermetic — no filesystem perms)
# ---------------------------------------------------------------------------
@test "live: rm failure exits 1 and reports failed count" {
    _make_old_file "$RAW_DIR/locked.json"

    # Create a fake rm that always fails
    local fake_bin="$WORK_DIR/fakebin"
    mkdir -p "$fake_bin"
    printf '#!/bin/bash\necho "rm: cannot remove: Permission denied" >&2; exit 1\n' > "$fake_bin/rm"
    chmod +x "$fake_bin/rm"

    run env PATH="$fake_bin:$PATH" bash "$SCRIPT" --dir "$RAW_DIR" --days 30
    [ "$status" -eq 1 ]

    # Output must report a failure
    [[ "$output" == *"failed"* ]] || [[ "$output" == *"FAILED"* ]] || [[ "$output" == *"Failed"* ]]
}
