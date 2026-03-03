#!/usr/bin/env bats
# =============================================================================
# P1-012: Second Brain Directory Structure (FR-2.1)
#         Verifies the second-brain scaffold in the infrastructure repo has
#         the required directory structure, README coverage, and depth limit.
#
# Note: Tests run against the second-brain/ scaffold committed to this repo.
#       The canonical seven-fortunas-brain repo inherits this structure.
#
# Run: bats tests/bats/test_second_brain.bats
# =============================================================================

PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
BRAIN_DIR="${PROJECT_ROOT}/second-brain"

# =============================================================================
# Directory existence
# =============================================================================

@test "P1-012-a: second-brain/ directory exists in the infrastructure repo" {
    [ -d "$BRAIN_DIR" ]
}

@test "P1-012-b: second-brain/best-practices/ subdirectory exists" {
    [ -d "${BRAIN_DIR}/best-practices" ]
}

@test "P1-012-c: second-brain/brand/ subdirectory exists" {
    [ -d "${BRAIN_DIR}/brand" ]
}

@test "P1-012-d: second-brain/culture/ subdirectory exists" {
    [ -d "${BRAIN_DIR}/culture" ]
}

@test "P1-012-e: second-brain/domain-expertise/ subdirectory exists" {
    [ -d "${BRAIN_DIR}/domain-expertise" ]
}

@test "P1-012-f: second-brain/operations/ subdirectory exists" {
    [ -d "${BRAIN_DIR}/operations" ]
}

@test "P1-012-g: second-brain/skills/ subdirectory exists" {
    [ -d "${BRAIN_DIR}/skills" ]
}

# =============================================================================
# README.md coverage in every subdirectory
# =============================================================================

@test "P1-012-h: second-brain/best-practices/README.md exists" {
    [ -f "${BRAIN_DIR}/best-practices/README.md" ]
}

@test "P1-012-i: second-brain/brand/README.md exists" {
    [ -f "${BRAIN_DIR}/brand/README.md" ]
}

@test "P1-012-j: second-brain/culture/README.md exists" {
    [ -f "${BRAIN_DIR}/culture/README.md" ]
}

@test "P1-012-k: second-brain/domain-expertise/README.md exists" {
    [ -f "${BRAIN_DIR}/domain-expertise/README.md" ]
}

@test "P1-012-l: second-brain/operations/README.md exists" {
    [ -f "${BRAIN_DIR}/operations/README.md" ]
}

@test "P1-012-m: second-brain/skills/README.md exists" {
    [ -f "${BRAIN_DIR}/skills/README.md" ]
}

# =============================================================================
# Depth constraint: no path exceeds 3 levels deep under second-brain/
# =============================================================================

@test "P1-012-n: no file path exceeds 3 levels deep under second-brain/" {
    # Depth 1 = second-brain/file
    # Depth 2 = second-brain/subdir/file
    # Depth 3 = second-brain/subdir/subsubdir/file  ← max allowed
    # Depth 4+ = violation
    violation=$(find "$BRAIN_DIR" -mindepth 4 -type f | head -1)
    [ -z "$violation" ]
}
