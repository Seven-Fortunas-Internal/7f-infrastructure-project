#!/usr/bin/env bats
# P2-004, P2-005, P2-006, P2-009 — CI Workflow Structure + Skill Naming
#
# P2-004: ci-health-weekly-report.yml has Monday 09:00 UTC cron
# P2-005: collect-metrics.yml has 24-hour grace period logic
# P2-006: Skill naming conventions in .claude/commands/ subdirectories
# P2-009: deploy-ai-dashboard.yml structure (actual actions/deploy-pages pattern)

PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
WORKFLOWS="${PROJECT_ROOT}/.github/workflows"
COMMANDS="${PROJECT_ROOT}/.claude/commands"

# ===========================================================================
# P2-004 — ci-health-weekly-report.yml Monday 09:00 UTC cron
# ===========================================================================

@test "P2-004-a: ci-health-weekly-report.yml exists" {
    [ -f "${WORKFLOWS}/ci-health-weekly-report.yml" ]
}

@test "P2-004-b: ci-health workflow name is set" {
    grep -q "^name:" "${WORKFLOWS}/ci-health-weekly-report.yml"
}

@test "P2-004-c: cron schedule is Monday 09:00 UTC ('0 9 * * 1')" {
    grep -q "cron: '0 9 \* \* 1'" "${WORKFLOWS}/ci-health-weekly-report.yml"
}

@test "P2-004-d: schedule trigger is present" {
    grep -q "schedule:" "${WORKFLOWS}/ci-health-weekly-report.yml"
}

# ===========================================================================
# P2-005 — collect-metrics.yml 24-hour grace period logic
# ===========================================================================

@test "P2-005-a: collect-metrics.yml exists" {
    [ -f "${WORKFLOWS}/collect-metrics.yml" ]
}

@test "P2-005-b: collect-metrics.yml has a cron schedule" {
    grep -q "cron:" "${WORKFLOWS}/collect-metrics.yml"
}

@test "P2-005-c: 24-hour grace period referenced in collect-metrics.yml" {
    # NFR-4.6: grace period logic uses '24 hours ago' timestamp comparison
    grep -q "24 hours ago" "${WORKFLOWS}/collect-metrics.yml"
}

@test "P2-005-d: grace period uses GRACE_CUTOFF_SECS time comparison" {
    grep -q "GRACE_CUTOFF_SECS" "${WORKFLOWS}/collect-metrics.yml"
}

@test "P2-005-e: grace period is documented with NFR-4.6 reference" {
    grep -q "NFR-4.6" "${WORKFLOWS}/collect-metrics.yml"
}

# ===========================================================================
# P2-006 — Skill naming conventions
# ===========================================================================

@test "P2-006-a: .claude/commands/ directory exists" {
    [ -d "${COMMANDS}" ]
}

@test "P2-006-b: 7f/ subdirectory exists" {
    [ -d "${COMMANDS}/7f" ]
}

@test "P2-006-c: bmb/ subdirectory exists" {
    [ -d "${COMMANDS}/bmb" ]
}

@test "P2-006-d: bmm/ subdirectory exists" {
    [ -d "${COMMANDS}/bmm" ]
}

@test "P2-006-e: cis/ subdirectory exists" {
    [ -d "${COMMANDS}/cis" ]
}

@test "P2-006-f: all files in 7f/ match 7f-*.md prefix" {
    # Every .md file in 7f/ must start with "7f-"
    violations=""
    for f in "${COMMANDS}/7f/"*.md; do
        [ -f "$f" ] || continue
        fname=$(basename "$f")
        [[ "$fname" == 7f-* ]] || violations="${violations} ${fname}"
    done
    [ -z "$violations" ]
}

@test "P2-006-g: all files in bmb/ match bmad-bmb-* or bmad-agent-bmb-* prefix" {
    violations=""
    for f in "${COMMANDS}/bmb/"*.md; do
        [ -f "$f" ] || continue
        fname=$(basename "$f")
        [[ "$fname" == bmad-bmb-* || "$fname" == bmad-agent-bmb-* ]] || violations="${violations} ${fname}"
    done
    [ -z "$violations" ]
}

@test "P2-006-h: all files in bmm/ match bmad-bmm-*, bmad-agent-bmm-*, or bmad-tea-* prefix" {
    # Note: bmm/ also contains bmad-tea-* stubs (TEA agent skills housed in bmm module)
    violations=""
    for f in "${COMMANDS}/bmm/"*.md; do
        [ -f "$f" ] || continue
        fname=$(basename "$f")
        [[ "$fname" == bmad-bmm-* || "$fname" == bmad-agent-bmm-* || "$fname" == bmad-tea-* ]] \
            || violations="${violations} ${fname}"
    done
    [ -z "$violations" ]
}

@test "P2-006-i: all files in cis/ match bmad-cis-* or bmad-agent-cis-* prefix" {
    violations=""
    for f in "${COMMANDS}/cis/"*.md; do
        [ -f "$f" ] || continue
        fname=$(basename "$f")
        [[ "$fname" == bmad-cis-* || "$fname" == bmad-agent-cis-* ]] || violations="${violations} ${fname}"
    done
    [ -z "$violations" ]
}

@test "P2-006-j: README.md exists at .claude/commands/ root" {
    [ -f "${COMMANDS}/README.md" ]
}

@test "P2-006-k: README.md documents the skill categories" {
    # README should mention the module prefixes
    grep -qi "7f\|bmb\|bmm\|cis" "${COMMANDS}/README.md"
}

@test "P2-006-l: at least 10 skills exist across all subdirectories" {
    count=$(find "${COMMANDS}" -name "*.md" -not -name "README.md" | wc -l)
    [ "$count" -ge 10 ]
}

# ===========================================================================
# P2-009 — deploy-ai-dashboard.yml structure
#
# Spec correction: workflow uses actions/upload-pages-artifact + deploy-pages
# (not JamesIves/github-pages-deploy-action — no destination_dir/keep_files).
# Assertions updated to match the actual implementation.
# ===========================================================================

@test "P2-009-a: deploy-ai-dashboard.yml exists" {
    [ -f "${WORKFLOWS}/deploy-ai-dashboard.yml" ]
}

@test "P2-009-b: deploy-ai-dashboard workflow name is set" {
    grep -q "^name:" "${WORKFLOWS}/deploy-ai-dashboard.yml"
}

@test "P2-009-c: workflow has pages write permission" {
    grep -q "pages: write" "${WORKFLOWS}/deploy-ai-dashboard.yml"
}

@test "P2-009-d: workflow triggers on push to dashboards/ai/ path" {
    grep -q "dashboards/ai" "${WORKFLOWS}/deploy-ai-dashboard.yml"
}

@test "P2-009-e: workflow uses actions/upload-pages-artifact to stage build" {
    grep -q "upload-pages-artifact" "${WORKFLOWS}/deploy-ai-dashboard.yml"
}

@test "P2-009-f: workflow uses actions/deploy-pages to publish" {
    grep -q "deploy-pages" "${WORKFLOWS}/deploy-ai-dashboard.yml"
}

@test "P2-009-g: deploy step has continue-on-error: true (C7 compliant)" {
    grep -q "continue-on-error: true" "${WORKFLOWS}/deploy-ai-dashboard.yml"
}
