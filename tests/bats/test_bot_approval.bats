#!/usr/bin/env bats
# =============================================================================
# P2-010 — Auto-Approve Workflow Structure (FR-new / SC-004)
# =============================================================================
# Validates the canonical auto-approve-pr.yml against the bot585 integration
# spec (documented retroactively per SDD-1). Tests the local canonical copy;
# live deployment across all 14 repos is validated separately in P4-003
# (validate-live-infrastructure.sh — Jorge runs with jorge-at-sf).
#
# Spec reference: .github/workflows/auto-approve-pr.yml
# SC reference  : _bmad-output/test-artifacts/test-design/spec-corrections.md SC-004
# =============================================================================

WORKFLOW_FILE=".github/workflows/auto-approve-pr.yml"

# ---------------------------------------------------------------------------
# File existence
# ---------------------------------------------------------------------------

@test "P2-010-a: auto-approve-pr.yml exists in canonical location" {
  [ -f "$WORKFLOW_FILE" ]
}

# ---------------------------------------------------------------------------
# Workflow identity
# ---------------------------------------------------------------------------

@test "P2-010-b: workflow name is 'Auto-Approve PR (7f-ci-bot)'" {
  run grep -c "^name: Auto-Approve PR (7f-ci-bot)" "$WORKFLOW_FILE"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

# ---------------------------------------------------------------------------
# Trigger configuration
# ---------------------------------------------------------------------------

@test "P2-010-c: trigger is pull_request" {
  run grep -c "pull_request:" "$WORKFLOW_FILE"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

@test "P2-010-d: trigger includes 'opened' event type" {
  run grep -c "opened" "$WORKFLOW_FILE"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

@test "P2-010-e: trigger includes 'synchronize' event type (re-fires on new commits)" {
  run grep -c "synchronize" "$WORKFLOW_FILE"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

@test "P2-010-f: trigger includes 'ready_for_review' event type (draft → ready)" {
  run grep -c "ready_for_review" "$WORKFLOW_FILE"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

@test "P2-010-g: trigger branches includes main" {
  run grep -c "main" "$WORKFLOW_FILE"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

# ---------------------------------------------------------------------------
# Concurrency (prevents race conditions on rapid pushes to same PR)
# ---------------------------------------------------------------------------

@test "P2-010-h: concurrency group is defined" {
  run grep -c "concurrency:" "$WORKFLOW_FILE"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

@test "P2-010-i: concurrency group includes PR number (unique per PR)" {
  run grep -c "pull_request.number" "$WORKFLOW_FILE"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

@test "P2-010-j: cancel-in-progress is true (no stale approval jobs)" {
  run grep -c "cancel-in-progress: true" "$WORKFLOW_FILE"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

# ---------------------------------------------------------------------------
# Security — actor guard
# ---------------------------------------------------------------------------

@test "P2-010-k: job fires only for jorge-at-sf (actor guard present)" {
  run grep -c "jorge-at-sf" "$WORKFLOW_FILE"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

@test "P2-010-l: actor guard uses github.actor (not github.triggering_actor)" {
  run grep -c "github.actor == 'jorge-at-sf'" "$WORKFLOW_FILE"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

# ---------------------------------------------------------------------------
# Secret usage
# ---------------------------------------------------------------------------

@test "P2-010-m: APPROVER_PAT secret is referenced (not GITHUB_TOKEN)" {
  run grep -c "APPROVER_PAT" "$WORKFLOW_FILE"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

@test "P2-010-n: GITHUB_TOKEN is NOT used as GH_TOKEN (bot approval requires dedicated PAT)" {
  # GITHUB_TOKEN cannot approve PRs opened by the same actor; APPROVER_PAT must be used
  run grep "GH_TOKEN: \${{ secrets.GITHUB_TOKEN }}" "$WORKFLOW_FILE"
  [ "$status" -ne 0 ]
}

# ---------------------------------------------------------------------------
# Approval mechanics
# ---------------------------------------------------------------------------

@test "P2-010-o: gh pr review --approve command is present" {
  run grep -c "\-\-approve" "$WORKFLOW_FILE"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

@test "P2-010-p: approval body message references CI status checks" {
  run grep -c "CI status checks" "$WORKFLOW_FILE"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

@test "P2-010-q: workflow is valid YAML (bash -n equivalent via python)" {
  run python3 -c "import yaml; yaml.safe_load(open('$WORKFLOW_FILE'))"
  [ "$status" -eq 0 ]
}
