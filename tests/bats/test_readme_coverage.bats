#!/usr/bin/env bats
# =============================================================================
# P1-014: README Coverage — All Key Directories (FR-6.1)
#         Verifies README.md exists at the root of every significant directory
#         in the 7f-infrastructure-project (top-level and major subdirectories).
#
# Run: bats tests/bats/test_readme_coverage.bats
# =============================================================================

PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"

# Helper: assert README.md exists in a directory
has_readme() { [ -f "${PROJECT_ROOT}/$1/README.md" ]; }

# =============================================================================
# Root
# =============================================================================

@test "P1-014-a: README.md exists at project root" {
    [ -f "${PROJECT_ROOT}/README.md" ]
}

# =============================================================================
# Top-level directories
# =============================================================================

@test "P1-014-b: autonomous-implementation/README.md" { has_readme "autonomous-implementation"; }
@test "P1-014-c: _bmad/README.md" { has_readme "_bmad"; }
@test "P1-014-d: _bmad-output/README.md" { has_readme "_bmad-output"; }
@test "P1-014-e: .claude/README.md" { has_readme ".claude"; }
@test "P1-014-f: compliance/README.md" { has_readme "compliance"; }
@test "P1-014-g: config/README.md" { has_readme "config"; }
@test "P1-014-h: costs/README.md" { has_readme "costs"; }
@test "P1-014-i: dashboards/README.md" { has_readme "dashboards"; }
@test "P1-014-j: docs/README.md" { has_readme "docs"; }
@test "P1-014-k: .github/README.md" { has_readme ".github"; }
@test "P1-014-l: metrics/README.md" { has_readme "metrics"; }
@test "P1-014-m: outputs/README.md" { has_readme "outputs"; }
@test "P1-014-n: prompts/README.md" { has_readme "prompts"; }
@test "P1-014-o: scripts/README.md" { has_readme "scripts"; }
@test "P1-014-p: second-brain/README.md" { has_readme "second-brain"; }
@test "P1-014-q: sprint-management/README.md" { has_readme "sprint-management"; }
@test "P1-014-r: templates/README.md" { has_readme "templates"; }
@test "P1-014-s: tests/README.md" { has_readme "tests"; }
@test "P1-014-t: utils/README.md" { has_readme "utils"; }

# =============================================================================
# Key subdirectories
# =============================================================================

@test "P1-014-u: .claude/commands/README.md" { has_readme ".claude/commands"; }
@test "P1-014-v: .github/workflows/README.md" { has_readme ".github/workflows"; }
@test "P1-014-w: _bmad/core/README.md" { has_readme "_bmad/core"; }
@test "P1-014-x: _bmad/bmb/README.md" { has_readme "_bmad/bmb"; }
@test "P1-014-y: _bmad/bmm/README.md" { has_readme "_bmad/bmm"; }
@test "P1-014-z: _bmad/tea/README.md" { has_readme "_bmad/tea"; }
@test "P1-014-aa: _bmad-output/planning-artifacts/README.md" { has_readme "_bmad-output/planning-artifacts"; }
@test "P1-014-ab: _bmad-output/test-artifacts/README.md" { has_readme "_bmad-output/test-artifacts"; }
@test "P1-014-ac: compliance/soc2/README.md" { has_readme "compliance/soc2"; }
@test "P1-014-ad: compliance/evidence/README.md" { has_readme "compliance/evidence"; }
@test "P1-014-ae: dashboards/ai/README.md" { has_readme "dashboards/ai"; }
@test "P1-014-af: docs/security/README.md" { has_readme "docs/security"; }
@test "P1-014-ag: docs/devops/README.md" { has_readme "docs/devops"; }
@test "P1-014-ah: scripts/compliance/README.md" { has_readme "scripts/compliance"; }
@test "P1-014-ai: tests/secret-detection/README.md" { has_readme "tests/secret-detection"; }
