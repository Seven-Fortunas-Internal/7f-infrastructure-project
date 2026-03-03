#!/usr/bin/env bats
# =============================================================================
# P1-017: Weekly AI Summary Workflow (FR-4.2)
#         Verifies weekly-ai-summary.yml has Sunday 09:00 UTC cron,
#         references ANTHROPIC_API_KEY via secrets (not hardcoded),
#         and the summaries output directory exists.
#
# Run: bats tests/bats/test_weekly_summary.bats
# =============================================================================

PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
WORKFLOW="${PROJECT_ROOT}/.github/workflows/weekly-ai-summary.yml"
SUMMARIES_DIR="${PROJECT_ROOT}/dashboards/ai/summaries"

# =============================================================================
# Workflow file structure
# =============================================================================

@test "P1-017-a: .github/workflows/weekly-ai-summary.yml exists" {
    [ -f "$WORKFLOW" ]
}

@test "P1-017-b: workflow has name: Weekly AI Summary" {
    grep -q "^name: Weekly AI Summary" "$WORKFLOW"
}

@test "P1-017-c: cron schedule is Sunday 09:00 UTC ('0 9 * * 0')" {
    grep -q "cron: '0 9 \* \* 0'" "$WORKFLOW"
}

@test "P1-017-d: workflow_dispatch trigger is present (manual run allowed)" {
    grep -q "workflow_dispatch" "$WORKFLOW"
}

# =============================================================================
# Security: API key must be a secret reference, never hardcoded
# =============================================================================

@test "P1-017-e: ANTHROPIC_API_KEY is read from secrets (not hardcoded)" {
    grep -q "ANTHROPIC_API_KEY.*secrets\.ANTHROPIC_API_KEY" "$WORKFLOW"
}

@test "P1-017-f: no hardcoded API key value (sk- prefix) in workflow" {
    run grep -c "sk-ant-" "$WORKFLOW"
    [ "$output" = "0" ]
}

# =============================================================================
# Output: summaries directory and script reference
# =============================================================================

@test "P1-017-g: dashboards/ai/summaries/ directory exists" {
    [ -d "$SUMMARIES_DIR" ]
}

@test "P1-017-h: workflow references generate_weekly_summary.py script" {
    grep -q "generate_weekly_summary.py" "$WORKFLOW"
}

@test "P1-017-i: workflow outputs to dashboards/ai/summaries" {
    grep -q "dashboards/ai/summaries" "$WORKFLOW"
}

# =============================================================================
# Resilience: git push has a fallback (no bare push that could fail CI)
# =============================================================================

@test "P1-017-j: git push in workflow has a fallback (|| echo ...)" {
    run grep "git push" "$WORKFLOW"
    [[ "$output" == *"||"* ]]
}
