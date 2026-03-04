#!/usr/bin/env bats
# =============================================================================
# P1-004: Unit tests for validate-workflow-compliance.sh (C1-C8)
#         and validate-and-fix-workflow.sh (YAML gate + auto-fix)
# Requirement: NFR-5.6 — 8 authoring constraints that prevent CI failures.
#
# Run: bats tests/bats/test_workflow_validator.bats
# =============================================================================

PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
VALIDATOR="${PROJECT_ROOT}/scripts/validate-workflow-compliance.sh"
FIXER="${PROJECT_ROOT}/scripts/validate-and-fix-workflow.sh"

setup() {
    WORK_DIR="$(mktemp -d)"
    WF="${WORK_DIR}/test-workflow.yml"
}

teardown() {
    rm -rf "$WORK_DIR"
}

# Write content to $WF (the test workflow file)
wf() { cat > "$WF"; }

# Run the compliance validator against $WF, from the project root so that
# git rev-parse --show-toplevel resolves to the real repo (needed for C1
# package-lock.json lookups and the allow-list path).
run_validator() {
    cd "$PROJECT_ROOT"
    run bash "$VALIDATOR" "$WF"
}

# =============================================================================
# C1: npm cache used without package-lock.json
# =============================================================================

@test "C1: 'cache: npm' without package-lock.json at root → ERROR C1" {
    wf <<'YAML'
name: Test C1 Violation
on: push
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/setup-node@v4
        with:
          cache: 'npm'
      - run: echo hello
YAML
    run_validator
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR C1"* ]]
}

@test "C1: 'cache: npm' with valid cache-dependency-path → OK C1" {
    wf <<'YAML'
name: Test C1 Pass
on: push
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/setup-node@v4
        with:
          cache: 'npm'
          cache-dependency-path: dashboards/ai/package-lock.json
      - run: echo hello
YAML
    run_validator
    [ "$status" -eq 0 ]
    [[ "$output" == *"OK"*"C1"* ]]
}

@test "C1: no npm cache used → C1 not checked" {
    wf <<'YAML'
name: Test No NPM
on: push
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo hello
YAML
    run_validator
    [ "$status" -eq 0 ]
}

# =============================================================================
# C2a: ${{ secrets.X }} in run: blocks — ERROR (expression injection)
# C2b: if: secrets.X != '' in step conditions — WARNING only (code smell)
# =============================================================================

@test "C2a: \${{ secrets.X }} in run: → ERROR C2, exit 1" {
    wf <<'YAML'
name: Test C2a Violation
on: push
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Inject secret into shell
        run: deploy.sh --key "${{ secrets.DEPLOY_KEY }}"
YAML
    run_validator
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR C2"* ]]
}

@test "C2a: secrets in env: block (not run:) → C2a not triggered" {
    wf <<'YAML'
name: Test C2a Clean
on: push
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Safe secret usage
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
        run: deploy.sh --key "$DEPLOY_KEY"
YAML
    run_validator
    [ "$status" -eq 0 ]
    [[ "$output" != *"ERROR C2"* ]]
}

@test "C2b: secrets.* in if: → WARN C2 only, exit 0 (not blocked)" {
    wf <<'YAML'
name: Test C2b Warning
on: push
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Conditional deploy
        if: secrets.DEPLOY_KEY != ''
        run: echo deploy
YAML
    run_validator
    [ "$status" -eq 0 ]
    [[ "$output" == *"WARN"*"C2"* ]]
    [[ "$output" != *"ERROR C2"* ]]
}

@test "C2: no secrets usage → C2a and C2b not triggered" {
    wf <<'YAML'
name: Test C2 Clean
on: push
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Always runs
        run: echo clean
YAML
    run_validator
    [ "$status" -eq 0 ]
    [[ "$output" != *"ERROR C2"* ]]
    [[ "$output" != *"WARN"*"C2"* ]]
}

# =============================================================================
# C3: Markdown at column 0 (WARNING only — never blocks)
# =============================================================================

@test "C3: markdown at column 0 → WARN C3 but exit 0 (non-blocking)" {
    wf <<'YAML'
name: Test C3 Warning
on: push
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: |
          echo hello
**bold text at col 0**
YAML
    run_validator
    [ "$status" -eq 0 ]
    [[ "$output" == *"WARN"*"C3"* ]]
}

@test "C3: no markdown at column 0 → C3 not triggered" {
    wf <<'YAML'
name: Test C3 Clean
on: push
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo hello
YAML
    run_validator
    [ "$status" -eq 0 ]
    [[ "$output" != *"C3"* || "$output" == *"not applicable"* ]]
}

# =============================================================================
# C4: Bot commit loop — git add overlaps on.push.paths trigger
# =============================================================================

@test "C4: 'git add .' with on.push.paths trigger → ERROR C4" {
    wf <<'YAML'
name: Test C4 Violation
on:
  push:
    paths:
      - 'outputs/**'
jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - run: |
          echo data > outputs/result.txt
          git add .
          git commit -m "update"
          git push refs/heads/feature/test || echo "skipped"
YAML
    run_validator
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR C4"* ]]
}

@test "C4: git add overlapping path with push.paths trigger → ERROR C4" {
    wf <<'YAML'
name: Test C4 Path Overlap
on:
  push:
    paths:
      - 'metrics/**'
jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - run: |
          git add metrics/
          git commit -m "update metrics"
          git push refs/heads/feature/test || echo "skipped"
YAML
    run_validator
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR C4"* ]]
}

@test "C4: no overlap between git add and push.paths → C4 clean" {
    wf <<'YAML'
name: Test C4 Clean
on:
  push:
    paths:
      - 'outputs/**'
jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - run: |
          git add other-directory/
          git commit -m "update"
          git push refs/heads/feature/test || echo "skipped"
YAML
    run_validator
    [ "$status" -eq 0 ]
    [[ "$output" != *"ERROR C4"* ]]
}

# =============================================================================
# C5: Bare git push without fallback
# =============================================================================

@test "C5: bare 'git push' with no fallback → ERROR C5, exit 1" {
    wf <<'YAML'
name: Test C5 Violation
on: push
jobs:
  push-job:
    runs-on: ubuntu-latest
    steps:
      - run: |
          git add .
          git commit -m "update"
          git push
YAML
    run_validator
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR C5"* ]]
}

@test "C5: 'git push || echo skipped' → C5 not triggered" {
    wf <<'YAML'
name: Test C5 With Fallback
on: push
jobs:
  push-job:
    runs-on: ubuntu-latest
    steps:
      - run: |
          git add .
          git commit -m "update"
          git push || echo "skipped - protected branch"
YAML
    run_validator
    [ "$status" -eq 0 ]
    [[ "$output" != *"ERROR C5"* ]]
}

@test "C5: push to explicit non-main branch → C5 not triggered" {
    wf <<'YAML'
name: Test C5 Explicit Branch
on: push
jobs:
  push-job:
    runs-on: ubuntu-latest
    steps:
      - run: git push refs/heads/compliance/update
YAML
    run_validator
    [ "$status" -eq 0 ]
    [[ "$output" != *"ERROR C5"* ]]
}

# =============================================================================
# C6: Duplicate concurrency group names (WARNING only — never blocks)
# =============================================================================

@test "C6: duplicate concurrency group across two files → WARN C6 but exit 0" {
    # Write two files with the same concurrency group name
    cat > "${WORK_DIR}/workflow-a.yml" <<'YAML'
name: Workflow A
on: push
concurrency:
  group: ci-pipeline
  cancel-in-progress: true
jobs:
  a:
    runs-on: ubuntu-latest
    steps:
      - run: echo a
YAML
    cat > "${WORK_DIR}/workflow-b.yml" <<'YAML'
name: Workflow B
on: push
concurrency:
  group: ci-pipeline
  cancel-in-progress: true
jobs:
  b:
    runs-on: ubuntu-latest
    steps:
      - run: echo b
YAML
    cd "$PROJECT_ROOT"
    run bash "$VALIDATOR" "$WORK_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"WARN"*"C6"* ]]
}

@test "C6: unique concurrency groups → C6 OK" {
    cat > "${WORK_DIR}/workflow-a.yml" <<'YAML'
name: Workflow A
on: push
concurrency:
  group: pipeline-a
  cancel-in-progress: true
jobs:
  a:
    runs-on: ubuntu-latest
    steps:
      - run: echo a
YAML
    cat > "${WORK_DIR}/workflow-b.yml" <<'YAML'
name: Workflow B
on: push
concurrency:
  group: pipeline-b
  cancel-in-progress: true
jobs:
  b:
    runs-on: ubuntu-latest
    steps:
      - run: echo b
YAML
    cd "$PROJECT_ROOT"
    run bash "$VALIDATOR" "$WORK_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" != *"WARN"*"C6"* ]]
}

# =============================================================================
# C7: actions/deploy-pages without continue-on-error: true
# =============================================================================

@test "C7: deploy-pages without continue-on-error → ERROR C7, exit 1" {
    wf <<'YAML'
name: Test C7 Violation
on: push
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        uses: actions/deploy-pages@v4
YAML
    run_validator
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR C7"* ]]
}

@test "C7: deploy-pages with continue-on-error: true → OK C7" {
    wf <<'YAML'
name: Test C7 Pass
on: push
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        uses: actions/deploy-pages@v4
        continue-on-error: true
YAML
    run_validator
    [ "$status" -eq 0 ]
    [[ "$output" == *"OK"*"C7"* ]]
}

# =============================================================================
# C8: Paid org license tools without continue-on-error: true
# =============================================================================

@test "C8: gitleaks-action without continue-on-error → ERROR C8, exit 1" {
    wf <<'YAML'
name: Test C8 Violation
on: push
jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - name: Scan for secrets
        uses: zricethezav/gitleaks-action@v2
YAML
    run_validator
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR C8"* ]]
}

@test "C8: gitleaks-action with continue-on-error: true → OK C8" {
    wf <<'YAML'
name: Test C8 Pass
on: push
jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - name: Scan for secrets
        uses: zricethezav/gitleaks-action@v2
        continue-on-error: true
YAML
    run_validator
    [ "$status" -eq 0 ]
    [[ "$output" == *"OK"*"C8"* ]]
}

# =============================================================================
# YAML syntax gate (in validate-and-fix-workflow.sh outer script)
# =============================================================================

@test "YAML gate: invalid YAML syntax → exit 1 before C1-C8 checks" {
    cat > "$WF" <<'YAML'
name: Broken Workflow
on: push
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo hello
      bad: yaml: [unclosed
YAML
    cd "$PROJECT_ROOT"
    run bash "$FIXER" "$WF"
    [ "$status" -eq 1 ]
    [[ "$output" == *"YAML SYNTAX ERROR"* ]]
}

@test "YAML gate: valid YAML with no violations → exit 0" {
    wf <<'YAML'
name: Clean Workflow
on: push
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo hello
YAML
    cd "$PROJECT_ROOT"
    run bash "$FIXER" "$WF"
    [ "$status" -eq 0 ]
}

# =============================================================================
# Auto-fix: C2a (secrets in run:) and C2b (secrets in if:) and C5 (bare git push)
# =============================================================================

@test "CRIT-003: C2a \${{ secrets.X }} in run: is NOT auto-fixed — reported as error, exit 1" {
    # C2a violations (expression injection) must never be auto-fixed.
    # ${{ secrets.X }} in run: blocks is a real injection risk.
    # This test asserts: C2a is reported as an error, exits non-zero, file not mutated.
    wf <<'YAML'
name: Test C2a No-Autofix
on: push
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy with injected secret
        run: deploy.sh --key "${{ secrets.DEPLOY_KEY }}"
YAML
    cd "$PROJECT_ROOT"
    run bash "$FIXER" "$WF"
    # Script must exit non-zero (C2a is an unfixable error)
    [ "$status" -ne 0 ]
    # Save fixer output before any subsequent run calls overwrite $output
    FIXER_OUTPUT="$output"
    # The file must NOT contain continue-on-error (auto-fix must NOT have run)
    [[ "$(cat "$WF")" != *"continue-on-error: true"* ]]
    # The ${{ secrets. expression must still be present (file not mutated)
    run bash -c "grep -q 'secrets\.' \"$WF\""
    [ "$status" -eq 0 ]
    # Fixer output must mention C2 (reported to stdout)
    [[ "$FIXER_OUTPUT" == *"C2"* ]]
}

@test "CRIT-003: C2b secrets in if: is a WARNING only — exits 0, file not mutated" {
    # C2b violations (if: secrets.X) are warnings, not errors — they do not block CI.
    # The fixer must exit 0 and must NOT convert the if: condition to continue-on-error.
    wf <<'YAML'
name: Test C2b Warning Only
on: push
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Conditional deploy
        if: secrets.DEPLOY_KEY != ''
        run: echo deploy
YAML
    cd "$PROJECT_ROOT"
    run bash "$FIXER" "$WF"
    # C2b is a warning — must exit 0 (no unfixable errors)
    [ "$status" -eq 0 ]
    # The file must NOT contain continue-on-error (auto-fix must NOT have run)
    [[ "$(cat "$WF")" != *"continue-on-error: true"* ]]
    # The if: secrets. line must still be present (file not mutated)
    run bash -c "grep -qE '^\s+if:.*secrets\.' \"$WF\""
    [ "$status" -eq 0 ]
}

@test "Auto-fix C5: bare git push gets fallback appended" {
    wf <<'YAML'
name: Test C5 Autofix
on: push
jobs:
  push-job:
    runs-on: ubuntu-latest
    steps:
      - run: |
          git add .
          git commit -m "update"
          git push
YAML
    cd "$PROJECT_ROOT"
    run bash "$FIXER" "$WF"
    [ "$status" -eq 0 ]
    # The fixed file should have a fallback on the git push line
    [[ "$(cat "$WF")" == *"git push"*"||"* ]]
}
