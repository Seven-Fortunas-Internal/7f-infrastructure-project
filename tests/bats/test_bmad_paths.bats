#!/usr/bin/env bats
# =============================================================================
# P1-010: BMAD Submodule & Skill Stubs Path Validation (FR-3.1)
#         Verifies _bmad submodule is present and initialized, 18+ skill stubs
#         exist in .claude/commands/, and agent stubs reference real files.
#
# Run: bats tests/bats/test_bmad_paths.bats
# =============================================================================

PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
COMMANDS_DIR="${PROJECT_ROOT}/.claude/commands"
BMAD_DIR="${PROJECT_ROOT}/_bmad"

# =============================================================================
# _bmad submodule
# =============================================================================

@test "P1-010-a: _bmad directory exists (submodule initialized)" {
    [ -d "$BMAD_DIR" ]
}

@test "P1-010-b: _bmad is tracked in git (present in repository)" {
    cd "$PROJECT_ROOT"
    # _bmad is a tracked directory (BMAD library committed directly to repo)
    git ls-files --error-unmatch _bmad/README.md
}

@test "P1-010-c: _bmad/core/ directory exists" {
    [ -d "${BMAD_DIR}/core" ]
}

@test "P1-010-d: _bmad/bmb/ directory exists" {
    [ -d "${BMAD_DIR}/bmb" ]
}

@test "P1-010-e: _bmad/bmm/ directory exists" {
    [ -d "${BMAD_DIR}/bmm" ]
}

@test "P1-010-f: _bmad/tea/ directory exists (TEA agent module)" {
    [ -d "${BMAD_DIR}/tea" ]
}

# =============================================================================
# Skill stubs — count and required files
# =============================================================================

@test "P1-010-g: 18 or more skill stubs exist in .claude/commands/ (all .md except README)" {
    count=$(find "$COMMANDS_DIR" -name "*.md" ! -name "README.md" | wc -l)
    [ "$count" -ge 18 ]
}

@test "P1-010-h: 7f/ subdirectory contains Seven Fortunas custom skills" {
    [ -d "${COMMANDS_DIR}/7f" ]
}

@test "P1-010-i: 7f-sprint-management.md skill stub exists" {
    [ -f "${COMMANDS_DIR}/7f/7f-sprint-management.md" ]
}

@test "P1-010-j: team-communication.md skill stub exists" {
    [ -f "${COMMANDS_DIR}/team-communication.md" ]
}

@test "P1-010-k: bmad-agent-tea-tea.md (TEA agent stub) exists" {
    [ -f "${COMMANDS_DIR}/bmad-agent-tea-tea.md" ]
}

@test "P1-010-l: bmad-agent-bmad-master.md stub exists" {
    [ -f "${COMMANDS_DIR}/bmad-agent-bmad-master.md" ]
}

@test "P1-010-m: bmad-help.md skill stub exists" {
    [ -f "${COMMANDS_DIR}/bmad-help.md" ]
}

# =============================================================================
# Skill stub {project-root} path resolution
# =============================================================================

@test "P1-010-n: TEA agent stub references a real _bmad path" {
    # The stub should reference {project-root}/_bmad/tea/agents/tea.md
    stub="${COMMANDS_DIR}/bmad-agent-tea-tea.md"
    # Extract the referenced path and verify it exists
    ref_path=$(grep -o '_bmad/[^ ]*\.md' "$stub" | head -1)
    [ -n "$ref_path" ]
    [ -f "${PROJECT_ROOT}/${ref_path}" ]
}

@test "P1-010-o: BMAD master stub references a real _bmad path" {
    stub="${COMMANDS_DIR}/bmad-agent-bmad-master.md"
    ref_path=$(grep -o '_bmad/[^ ]*\.md' "$stub" | head -1)
    [ -n "$ref_path" ]
    [ -f "${PROJECT_ROOT}/${ref_path}" ]
}

@test "P1-010-p: skills-registry.yaml exists in .claude/commands/" {
    [ -f "${COMMANDS_DIR}/skills-registry.yaml" ]
}
