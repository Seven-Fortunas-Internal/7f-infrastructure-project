#!/usr/bin/env bats
# =============================================================================
# P0-007: Auth Guard Tests
# Requirement: FR-5.2 / R-011 — validate_github_auth.sh must enforce jorge-at-sf
# =============================================================================
# Tests:
#   - Happy path: jorge-at-sf is active account → exit 0
#   - Wrong account (jorge-at-gd) → exit 1 with error message
#   - No gh CLI installed → exit 1
#   - gh not authenticated → exit 1
#   - --force-account override with wrong account → exit 0 with warning
#   - Unknown CLI option → exit 1

SCRIPT_UNDER_TEST="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)/scripts/validate_github_auth.sh"

setup() {
    # Temp dir for mock binaries; prepend to PATH so our gh overrides the real one
    MOCK_DIR="$(mktemp -d)"
    export PATH="$MOCK_DIR:$PATH"
    # Redirect audit log to temp file to avoid polluting real log
    export LOG_FILE="$(mktemp)"
}

teardown() {
    rm -rf "$MOCK_DIR"
    rm -f "$LOG_FILE"
}

# Helper: create a mock gh that returns a given auth_status output and exit code
_mock_gh_auth() {
    local output="$1"
    local exit_code="${2:-0}"
    cat > "$MOCK_DIR/gh" <<MOCK_EOF
#!/usr/bin/env bash
if [[ "\$1" == "auth" && "\$2" == "status" ]]; then
    echo "$output" >&2
    exit $exit_code
fi
exit 0
MOCK_EOF
    chmod +x "$MOCK_DIR/gh"
}

# Helper: remove mock gh entirely (simulates gh not installed)
_no_gh() {
    rm -f "$MOCK_DIR/gh"
}

# =============================================================================
# HAPPY PATH
# =============================================================================

@test "happy path: jorge-at-sf is active account → exit 0" {
    _mock_gh_auth "Logged in to github.com as jorge-at-sf (oauth_token)"

    run bash "$SCRIPT_UNDER_TEST"

    [ "$status" -eq 0 ]
}

@test "happy path: audit log records VALIDATION_SUCCESS" {
    _mock_gh_auth "Logged in to github.com as jorge-at-sf (oauth_token)"

    run bash "$SCRIPT_UNDER_TEST"

    [ "$status" -eq 0 ]
    grep -q "VALIDATION_SUCCESS" "$LOG_FILE"
}

# =============================================================================
# WRONG ACCOUNT
# =============================================================================

@test "wrong account (jorge-at-gd) → exit 1" {
    _mock_gh_auth "Logged in to github.com as jorge-at-gd (oauth_token)"

    run bash "$SCRIPT_UNDER_TEST"

    [ "$status" -eq 1 ]
}

@test "wrong account → stderr contains required account name" {
    _mock_gh_auth "Logged in to github.com as jorge-at-gd (oauth_token)"

    run bash "$SCRIPT_UNDER_TEST"

    [ "$status" -eq 1 ]
    [[ "$output" == *"jorge-at-sf"* ]]
}

@test "wrong account → stderr mentions force-account option" {
    _mock_gh_auth "Logged in to github.com as jorge-at-gd (oauth_token)"

    run bash "$SCRIPT_UNDER_TEST"

    [ "$status" -eq 1 ]
    [[ "$output" == *"--force-account"* ]]
}

@test "wrong account → audit log records VALIDATION_FAILED" {
    _mock_gh_auth "Logged in to github.com as jorge-at-gd (oauth_token)"

    run bash "$SCRIPT_UNDER_TEST"

    [ "$status" -eq 1 ]
    grep -q "VALIDATION_FAILED" "$LOG_FILE"
}

# =============================================================================
# NO GH CLI
# =============================================================================

# Helper: build a stripped env for "gh not installed" tests.
# We use env -i with only MOCK_DIR on PATH, plus explicit /usr/bin/bash.
# MOCK_DIR must contain: date (for log_audit), but NOT gh.
_setup_no_gh_env() {
    cat > "$MOCK_DIR/date" <<'DATEEOF'
#!/usr/bin/env bash
echo "2026-01-01T00:00:00Z"
DATEEOF
    chmod +x "$MOCK_DIR/date"
    # Symlink bash into MOCK_DIR so env finds it when searching restricted PATH
    ln -sf /usr/bin/bash "$MOCK_DIR/bash"
}

@test "gh CLI not installed → exit 1" {
    _setup_no_gh_env

    run env -i HOME="$HOME" LOG_FILE="$LOG_FILE" PATH="$MOCK_DIR" \
        bash "$SCRIPT_UNDER_TEST"

    [ "$status" -eq 1 ]
}

@test "gh CLI not installed → stderr mentions gh not installed" {
    _setup_no_gh_env

    run env -i HOME="$HOME" LOG_FILE="$LOG_FILE" PATH="$MOCK_DIR" \
        bash "$SCRIPT_UNDER_TEST"

    [ "$status" -eq 1 ]
    [[ "$output" == *"not installed"* ]]
}

# =============================================================================
# NOT AUTHENTICATED
# =============================================================================

@test "gh not authenticated → exit 1" {
    # gh auth status returns exit 1 when not logged in
    _mock_gh_auth "You are not logged in to any GitHub hosts" 1

    run bash "$SCRIPT_UNDER_TEST"

    [ "$status" -eq 1 ]
}

@test "gh not authenticated → stderr mentions not authenticated" {
    _mock_gh_auth "You are not logged in to any GitHub hosts" 1

    run bash "$SCRIPT_UNDER_TEST"

    [ "$status" -eq 1 ]
    [[ "$output" == *"not authenticated"* ]]
}

# =============================================================================
# FORCE ACCOUNT OVERRIDE
# =============================================================================

@test "--force-account with wrong account → exit 0 (override)" {
    _mock_gh_auth "Logged in to github.com as jorge-at-gd (oauth_token)"

    run bash "$SCRIPT_UNDER_TEST" --force-account

    [ "$status" -eq 0 ]
}

@test "--force-account override → stderr contains WARNING" {
    _mock_gh_auth "Logged in to github.com as jorge-at-gd (oauth_token)"

    run bash "$SCRIPT_UNDER_TEST" --force-account

    [ "$status" -eq 0 ]
    [[ "$output" == *"WARNING"* ]] || [[ "$output" == *"Force account"* ]]
}

@test "--force-account override → audit log records VALIDATION_OVERRIDE" {
    _mock_gh_auth "Logged in to github.com as jorge-at-gd (oauth_token)"

    run bash "$SCRIPT_UNDER_TEST" --force-account

    [ "$status" -eq 0 ]
    grep -q "VALIDATION_OVERRIDE" "$LOG_FILE"
}

# =============================================================================
# UNKNOWN OPTION
# =============================================================================

@test "unknown CLI option → exit 1" {
    _mock_gh_auth "Logged in to github.com as jorge-at-sf (oauth_token)"

    run bash "$SCRIPT_UNDER_TEST" --invalid-option

    [ "$status" -eq 1 ]
}

@test "unknown CLI option → stderr contains Usage" {
    _mock_gh_auth "Logged in to github.com as jorge-at-sf (oauth_token)"

    run bash "$SCRIPT_UNDER_TEST" --invalid-option

    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage"* ]]
}
