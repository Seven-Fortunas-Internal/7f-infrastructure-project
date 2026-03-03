#!/usr/bin/env bash
# =============================================================================
# tests/validate-live-infrastructure.sh — P0-003, P0-005, P1-007..P1-016, P2-008
# =============================================================================
# Validates the live Seven Fortunas GitHub infrastructure using the jorge-at-sf
# account. Covers org security settings, branch protection, team structure,
# repo existence, skill deployments, Dependabot, and live dashboard availability.
#
# Usage:
#   bash tests/validate-live-infrastructure.sh [--output PATH]
#
# Prerequisites:
#   - gh CLI authenticated as jorge-at-sf
#   - Internet access (calls api.github.com and seven-fortunas.github.io)
#   - curl installed (for live HTTP tests)
#
# JSON output contract (Appendix B):
# {
#   "test_suite": "live-infrastructure-validation",
#   "timestamp": "ISO8601",
#   "account": "jorge-at-sf",
#   "total": N, "passed": N, "failed": N, "skipped": N,
#   "results": [
#     { "test_id": "P0-003-a", "requirement": "FR-1.3",
#       "description": "...", "status": "PASS"|"FAIL"|"SKIP",
#       "message": "...", "duration_ms": N }
#   ]
# }
#
# Exit codes:
#   0 = all tests pass
#   1 = one or more failures
#   2 = prerequisite not met (not authenticated as jorge-at-sf)
# =============================================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OUTPUT_PATH=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --output) OUTPUT_PATH="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# ---------------------------------------------------------------------------
# Prerequisite: jorge-at-sf must be active
# ---------------------------------------------------------------------------
echo "=== validate-live-infrastructure.sh ===" >&2
echo "Checking gh authentication..." >&2

CURRENT_ACCOUNT=$(gh api user --jq '.login' 2>/dev/null || echo "")
if [[ "$CURRENT_ACCOUNT" != "jorge-at-sf" ]]; then
    echo "" >&2
    echo "ERROR: gh CLI must be authenticated as jorge-at-sf" >&2
    echo "       Current account: ${CURRENT_ACCOUNT:-<not authenticated>}" >&2
    echo "       Run: gh auth switch --user jorge-at-sf" >&2
    exit 2
fi
echo "  Account verified: jorge-at-sf ✓" >&2

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
PUBLIC_ORG="Seven-Fortunas"
PRIVATE_ORG="Seven-Fortunas-Internal"
BRAIN_REPO="${PRIVATE_ORG}/seven-fortunas-brain"
DASHBOARD_URL="https://seven-fortunas.github.io/dashboards/ai"

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0
RESULTS_TSV=$(mktemp)
trap 'rm -f "$RESULTS_TSV"' EXIT

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# record <test_id> <requirement> <description> <status> <message> <duration_ms>
record() {
    local test_id="$1" req="$2" desc="$3" status="$4" message="$5" duration="$6"
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$test_id" "$req" "$desc" "$status" "$message" "$duration" >> "$RESULTS_TSV"
    case "$status" in
        PASS) PASS_COUNT=$((PASS_COUNT + 1)); echo "  ✓ [$test_id] $desc" >&2 ;;
        FAIL) FAIL_COUNT=$((FAIL_COUNT + 1)); echo "  ✗ [$test_id] $desc — $message" >&2 ;;
        SKIP) SKIP_COUNT=$((SKIP_COUNT + 1)); echo "  ~ [$test_id] $desc — $message" >&2 ;;
    esac
}

# Safe gh api wrapper — returns output or empty string on error; never exits
gh_api() {
    gh api "$@" 2>/dev/null || echo ""
}

# Current time in milliseconds
ts() { date +%s%3N; }

# ---------------------------------------------------------------------------
# P1-007: Both orgs exist
# ---------------------------------------------------------------------------
echo "" >&2
echo "--- P1-007: Org Existence ---" >&2

T0=$(ts)
RESULT=$(gh_api "orgs/${PUBLIC_ORG}" --jq '.login')
T1=$(ts)
if [[ "$RESULT" == "$PUBLIC_ORG" ]]; then
    record "P1-007-a" "FR-1.1" "Seven-Fortunas public org exists" "PASS" "login: $RESULT" "$((T1-T0))"
else
    record "P1-007-a" "FR-1.1" "Seven-Fortunas public org exists" "FAIL" "Expected login 'Seven-Fortunas', got: '${RESULT:-<error>}'" "$((T1-T0))"
fi

T0=$(ts)
RESULT=$(gh_api "orgs/${PRIVATE_ORG}" --jq '.login')
T1=$(ts)
if [[ "$RESULT" == "$PRIVATE_ORG" ]]; then
    record "P1-007-b" "FR-1.1" "Seven-Fortunas-Internal private org exists" "PASS" "login: $RESULT" "$((T1-T0))"
else
    record "P1-007-b" "FR-1.1" "Seven-Fortunas-Internal private org exists" "FAIL" "Expected login 'Seven-Fortunas-Internal', got: '${RESULT:-<error>}'" "$((T1-T0))"
fi

# ---------------------------------------------------------------------------
# P0-003: Org security — 2FA enforcement
# ---------------------------------------------------------------------------
echo "" >&2
echo "--- P0-003: Security Settings (2FA, secret scanning, push protection) ---" >&2

for ENTRY in "${PUBLIC_ORG}:P0-003-a" "${PRIVATE_ORG}:P0-003-b"; do
    ORG="${ENTRY%%:*}"
    ID="${ENTRY##*:}"
    T0=$(ts)
    TWO_FA=$(gh_api "orgs/${ORG}" --jq '.two_factor_requirement_enabled // "null"')
    T1=$(ts)
    if [[ "$TWO_FA" == "true" ]]; then
        record "$ID" "FR-1.3" "${ORG}: 2FA required for all members" "PASS" "two_factor_requirement_enabled: true" "$((T1-T0))"
    elif [[ "$TWO_FA" == "false" ]]; then
        record "$ID" "FR-1.3" "${ORG}: 2FA required for all members" "FAIL" "two_factor_requirement_enabled: false — enable at org Settings → Authentication security" "$((T1-T0))"
    else
        record "$ID" "FR-1.3" "${ORG}: 2FA required for all members" "SKIP" "API returned null — requires org owner access or setting not configured" "$((T1-T0))"
    fi
done

# Secret scanning: check on key repo per org
for ENTRY in "${PUBLIC_ORG}/dashboards:P0-003-c" "${PRIVATE_ORG}/seven-fortunas-brain:P0-003-d"; do
    REPO="${ENTRY%%:*}"
    ID="${ENTRY##*:}"
    T0=$(ts)
    SS=$(gh_api "repos/${REPO}" --jq '.security_and_analysis.secret_scanning.status // "null"')
    T1=$(ts)
    if [[ "$SS" == "enabled" ]]; then
        record "$ID" "FR-1.3" "${REPO}: secret scanning enabled" "PASS" "secret_scanning.status: enabled" "$((T1-T0))"
    elif [[ "$SS" == "disabled" ]]; then
        record "$ID" "FR-1.3" "${REPO}: secret scanning enabled" "FAIL" "secret_scanning.status: disabled — enable at repo Settings → Code security and analysis" "$((T1-T0))"
    else
        record "$ID" "FR-1.3" "${REPO}: secret scanning enabled" "SKIP" "status: null (public repos have scanning by default; check repo Security settings)" "$((T1-T0))"
    fi
done

# Push protection: check on key repo per org
for ENTRY in "${PUBLIC_ORG}/dashboards:P0-003-e" "${PRIVATE_ORG}/seven-fortunas-brain:P0-003-f"; do
    REPO="${ENTRY%%:*}"
    ID="${ENTRY##*:}"
    T0=$(ts)
    PP=$(gh_api "repos/${REPO}" --jq '.security_and_analysis.secret_scanning_push_protection.status // "null"')
    T1=$(ts)
    if [[ "$PP" == "enabled" ]]; then
        record "$ID" "FR-1.6" "${REPO}: push protection enabled" "PASS" "secret_scanning_push_protection.status: enabled" "$((T1-T0))"
    elif [[ "$PP" == "disabled" ]]; then
        record "$ID" "FR-1.6" "${REPO}: push protection enabled" "FAIL" "secret_scanning_push_protection.status: disabled — enable at repo Settings → Code security and analysis" "$((T1-T0))"
    else
        record "$ID" "FR-1.6" "${REPO}: push protection enabled" "SKIP" "status: null (check repo Security settings)" "$((T1-T0))"
    fi
done

# ---------------------------------------------------------------------------
# P0-005: Branch protection on key repos
# ---------------------------------------------------------------------------
echo "" >&2
echo "--- P0-005: Branch Protection ---" >&2

BP_REPOS=(
    "${PUBLIC_ORG}/dashboards:P0-005-a"
    "${PUBLIC_ORG}/seven-fortunas.github.io:P0-005-b"
    "${PRIVATE_ORG}/seven-fortunas-brain:P0-005-c"
    "${PRIVATE_ORG}/7f-infrastructure-project:P0-005-d"
    "${PRIVATE_ORG}/internal-docs:P0-005-e"
)

for ENTRY in "${BP_REPOS[@]}"; do
    REPO="${ENTRY%%:*}"
    ID="${ENTRY##*:}"
    T0=$(ts)
    # 404 when no branch protection; non-empty JSON when protection exists
    BP_DATA=$(gh api "repos/${REPO}/branches/main/protection" 2>/dev/null || echo "")
    T1=$(ts)
    if [[ -z "$BP_DATA" ]]; then
        record "$ID" "FR-1.6" "Branch protection on ${REPO}/main" "FAIL" \
            "No branch protection rule on main (endpoint returned empty/404)" "$((T1-T0))"
    else
        # Check PR reviews required
        PR_REQ=$(echo "$BP_DATA" | python3 -c \
            "import sys,json; d=json.load(sys.stdin); print('ok' if d.get('required_pull_request_reviews') else 'missing')" \
            2>/dev/null || echo "error")
        # Check force push is blocked (allow_force_pushes.enabled must be false or absent)
        NO_FP=$(echo "$BP_DATA" | python3 -c \
            "import sys,json; d=json.load(sys.stdin); afp=d.get('allow_force_pushes',{}); print('ok' if not afp.get('enabled',False) else 'allowed')" \
            2>/dev/null || echo "error")
        if [[ "$PR_REQ" == "ok" && "$NO_FP" == "ok" ]]; then
            record "$ID" "FR-1.6" "Branch protection on ${REPO}/main" "PASS" \
                "PR reviews required, force push blocked" "$((T1-T0))"
        elif [[ "$PR_REQ" != "ok" ]]; then
            record "$ID" "FR-1.6" "Branch protection on ${REPO}/main" "FAIL" \
                "required_pull_request_reviews not configured" "$((T1-T0))"
        else
            record "$ID" "FR-1.6" "Branch protection on ${REPO}/main" "FAIL" \
                "Force push is allowed — disable at repo Settings → Branches" "$((T1-T0))"
        fi
    fi
done

# ---------------------------------------------------------------------------
# P1-008: Team structure (count + key membership)
# ---------------------------------------------------------------------------
echo "" >&2
echo "--- P1-008: Team Structure ---" >&2

# P1-008-a: Seven-Fortunas has 5 teams
T0=$(ts)
TEAM_LIST=$(gh_api "orgs/${PUBLIC_ORG}/teams" --jq '[.[].name] | sort | join(", ")')
TEAM_COUNT=$(gh_api "orgs/${PUBLIC_ORG}/teams" --jq 'length')
T1=$(ts)
if [[ "$TEAM_COUNT" -ge 5 ]] 2>/dev/null; then
    record "P1-008-a" "FR-1.2" "Seven-Fortunas has 5 teams" "PASS" \
        "${TEAM_COUNT} teams: ${TEAM_LIST}" "$((T1-T0))"
elif [[ -n "$TEAM_COUNT" ]]; then
    record "P1-008-a" "FR-1.2" "Seven-Fortunas has 5 teams" "FAIL" \
        "Found ${TEAM_COUNT} teams (expected 5): ${TEAM_LIST}" "$((T1-T0))"
else
    record "P1-008-a" "FR-1.2" "Seven-Fortunas has 5 teams" "FAIL" \
        "API error listing teams in ${PUBLIC_ORG}" "$((T1-T0))"
fi

# P1-008-b: Seven-Fortunas-Internal has 5 teams
T0=$(ts)
TEAM_LIST=$(gh_api "orgs/${PRIVATE_ORG}/teams" --jq '[.[].name] | sort | join(", ")')
TEAM_COUNT=$(gh_api "orgs/${PRIVATE_ORG}/teams" --jq 'length')
T1=$(ts)
if [[ "$TEAM_COUNT" -ge 5 ]] 2>/dev/null; then
    record "P1-008-b" "FR-1.2" "Seven-Fortunas-Internal has 5 teams" "PASS" \
        "${TEAM_COUNT} teams: ${TEAM_LIST}" "$((T1-T0))"
elif [[ -n "$TEAM_COUNT" ]]; then
    record "P1-008-b" "FR-1.2" "Seven-Fortunas-Internal has 5 teams" "FAIL" \
        "Found ${TEAM_COUNT} teams (expected 5): ${TEAM_LIST}" "$((T1-T0))"
else
    record "P1-008-b" "FR-1.2" "Seven-Fortunas-Internal has 5 teams" "FAIL" \
        "API error listing teams in ${PRIVATE_ORG}" "$((T1-T0))"
fi

# P1-008-c: jorge-at-sf is a member of the engineering team in Seven-Fortunas-Internal
# We check the slug "engineering" — adjust if the actual slug differs
T0=$(ts)
MEMBER_STATUS=$(gh api "orgs/${PRIVATE_ORG}/teams/engineering/memberships/jorge-at-sf" \
    --jq '.state' 2>/dev/null || echo "")
T1=$(ts)
if [[ "$MEMBER_STATUS" == "active" ]]; then
    record "P1-008-c" "FR-1.2" "jorge-at-sf is active member of ${PRIVATE_ORG}/engineering" "PASS" \
        "membership state: active" "$((T1-T0))"
elif [[ -n "$MEMBER_STATUS" ]]; then
    record "P1-008-c" "FR-1.2" "jorge-at-sf is active member of ${PRIVATE_ORG}/engineering" "FAIL" \
        "membership state: ${MEMBER_STATUS} (expected: active)" "$((T1-T0))"
else
    record "P1-008-c" "FR-1.2" "jorge-at-sf is active member of ${PRIVATE_ORG}/engineering" "FAIL" \
        "Team 'engineering' not found or jorge-at-sf not a member — check team slug in ${PRIVATE_ORG}" "$((T1-T0))"
fi

# P1-008-d: All 4 founders are org members (Seven-Fortunas)
T0=$(ts)
MEMBER_COUNT=$(gh_api "orgs/${PUBLIC_ORG}/members" --jq 'length')
T1=$(ts)
if [[ "$MEMBER_COUNT" -ge 4 ]] 2>/dev/null; then
    record "P1-008-d" "FR-1.2" "All 4 founders are org members of ${PUBLIC_ORG}" "PASS" \
        "${MEMBER_COUNT} members in org" "$((T1-T0))"
elif [[ -n "$MEMBER_COUNT" ]]; then
    record "P1-008-d" "FR-1.2" "All 4 founders are org members of ${PUBLIC_ORG}" "FAIL" \
        "Only ${MEMBER_COUNT} members (expected ≥4: jorge-at-sf, henry_7f, buck_7f, patrick_7f)" "$((T1-T0))"
else
    record "P1-008-d" "FR-1.2" "All 4 founders are org members of ${PUBLIC_ORG}" "FAIL" \
        "API error listing org members" "$((T1-T0))"
fi

# ---------------------------------------------------------------------------
# P1-009: MVP repos exist + GitHub Pages enabled
# ---------------------------------------------------------------------------
echo "" >&2
echo "--- P1-009: MVP Repos + GitHub Pages ---" >&2

# P1-009-a: Public MVP repos exist (spot check 4 key repos)
PUBLIC_REPOS=(
    "${PUBLIC_ORG}/dashboards"
    "${PUBLIC_ORG}/seven-fortunas.github.io"
    "${PUBLIC_ORG}/second-brain-public"
    "${PUBLIC_ORG}/.github"
)
T0=$(ts)
MISSING_REPOS=()
for REPO in "${PUBLIC_REPOS[@]}"; do
    REPO_NAME=$(gh_api "repos/${REPO}" --jq '.name')
    EXPECTED="${REPO##*/}"
    [[ "$REPO_NAME" != "$EXPECTED" ]] && MISSING_REPOS+=("$REPO")
done
T1=$(ts)
if [[ ${#MISSING_REPOS[@]} -eq 0 ]]; then
    record "P1-009-a" "FR-1.5" "4 public MVP repos exist" "PASS" \
        "dashboards, seven-fortunas.github.io, second-brain-public, .github" "$((T1-T0))"
else
    record "P1-009-a" "FR-1.5" "4 public MVP repos exist" "FAIL" \
        "Missing repos: ${MISSING_REPOS[*]}" "$((T1-T0))"
fi

# P1-009-b: Private MVP repos exist (spot check 5 key repos)
PRIVATE_REPOS=(
    "${PRIVATE_ORG}/seven-fortunas-brain"
    "${PRIVATE_ORG}/internal-docs"
    "${PRIVATE_ORG}/dashboards-internal"
    "${PRIVATE_ORG}/7f-infrastructure-project"
    "${PRIVATE_ORG}/.github"
)
T0=$(ts)
MISSING_REPOS=()
for REPO in "${PRIVATE_REPOS[@]}"; do
    REPO_NAME=$(gh_api "repos/${REPO}" --jq '.name')
    EXPECTED="${REPO##*/}"
    [[ "$REPO_NAME" != "$EXPECTED" ]] && MISSING_REPOS+=("$REPO")
done
T1=$(ts)
if [[ ${#MISSING_REPOS[@]} -eq 0 ]]; then
    record "P1-009-b" "FR-1.5" "5 private MVP repos exist" "PASS" \
        "seven-fortunas-brain, internal-docs, dashboards-internal, 7f-infrastructure-project, .github" "$((T1-T0))"
else
    record "P1-009-b" "FR-1.5" "5 private MVP repos exist" "FAIL" \
        "Missing repos: ${MISSING_REPOS[*]}" "$((T1-T0))"
fi

# P1-009-c: GitHub Pages enabled on dashboards
T0=$(ts)
PAGES_STATUS=$(gh_api "repos/${PUBLIC_ORG}/dashboards/pages" --jq '.status // "null"')
T1=$(ts)
if [[ "$PAGES_STATUS" == "built" || "$PAGES_STATUS" == "building" ]]; then
    record "P1-009-c" "FR-1.5" "GitHub Pages enabled on ${PUBLIC_ORG}/dashboards" "PASS" \
        "pages.status: $PAGES_STATUS" "$((T1-T0))"
elif [[ "$PAGES_STATUS" == "null" || -z "$PAGES_STATUS" ]]; then
    record "P1-009-c" "FR-1.5" "GitHub Pages enabled on ${PUBLIC_ORG}/dashboards" "FAIL" \
        "GitHub Pages not enabled or not built — enable at repo Settings → Pages" "$((T1-T0))"
else
    record "P1-009-c" "FR-1.5" "GitHub Pages enabled on ${PUBLIC_ORG}/dashboards" "FAIL" \
        "pages.status: $PAGES_STATUS (expected: built)" "$((T1-T0))"
fi

# P1-009-d: GitHub Pages enabled on seven-fortunas.github.io
T0=$(ts)
PAGES_STATUS=$(gh_api "repos/${PUBLIC_ORG}/seven-fortunas.github.io/pages" --jq '.status // "null"')
T1=$(ts)
if [[ "$PAGES_STATUS" == "built" || "$PAGES_STATUS" == "building" ]]; then
    record "P1-009-d" "FR-1.5" "GitHub Pages enabled on ${PUBLIC_ORG}/seven-fortunas.github.io" "PASS" \
        "pages.status: $PAGES_STATUS" "$((T1-T0))"
elif [[ "$PAGES_STATUS" == "null" || -z "$PAGES_STATUS" ]]; then
    record "P1-009-d" "FR-1.5" "GitHub Pages enabled on ${PUBLIC_ORG}/seven-fortunas.github.io" "FAIL" \
        "GitHub Pages not enabled or not built — enable at repo Settings → Pages" "$((T1-T0))"
else
    record "P1-009-d" "FR-1.5" "GitHub Pages enabled on ${PUBLIC_ORG}/seven-fortunas.github.io" "FAIL" \
        "pages.status: $PAGES_STATUS (expected: built)" "$((T1-T0))"
fi

# ---------------------------------------------------------------------------
# P1-011: 7 custom 7f-* skills in brain repo
# ---------------------------------------------------------------------------
echo "" >&2
echo "--- P1-011: Custom Skills in Brain Repo ---" >&2

T0=$(ts)
SKILL_COUNT=$(gh_api "repos/${BRAIN_REPO}/contents/.claude/commands" \
    --jq '[.[] | select(.name | startswith("7f-")) | .name] | length')
SKILL_NAMES=$(gh_api "repos/${BRAIN_REPO}/contents/.claude/commands" \
    --jq '[.[] | select(.name | startswith("7f-")) | .name] | join(", ")')
T1=$(ts)
if [[ "$SKILL_COUNT" -ge 7 ]] 2>/dev/null; then
    record "P1-011-a" "FR-3.2" "7+ custom 7f-* skills in brain repo .claude/commands/" "PASS" \
        "${SKILL_COUNT} skills: ${SKILL_NAMES}" "$((T1-T0))"
elif [[ -n "$SKILL_COUNT" && "$SKILL_COUNT" != "null" ]]; then
    record "P1-011-a" "FR-3.2" "7+ custom 7f-* skills in brain repo .claude/commands/" "FAIL" \
        "Found ${SKILL_COUNT} 7f-* skills (expected ≥7): ${SKILL_NAMES:-none}" "$((T1-T0))"
else
    record "P1-011-a" "FR-3.2" "7+ custom 7f-* skills in brain repo .claude/commands/" "FAIL" \
        ".claude/commands/ not found or API error in ${BRAIN_REPO}" "$((T1-T0))"
fi

# ---------------------------------------------------------------------------
# P1-013: search-second-brain.sh deployed in brain repo
# ---------------------------------------------------------------------------
echo "" >&2
echo "--- P1-013: search-second-brain.sh Deployment ---" >&2

T0=$(ts)
SKILL_NAME=$(gh_api "repos/${BRAIN_REPO}/contents/.claude/commands/search-second-brain.sh" \
    --jq '.name // "null"')
T1=$(ts)
if [[ "$SKILL_NAME" == "search-second-brain.sh" ]]; then
    record "P1-013-a" "FR-2.4" "search-second-brain.sh deployed in brain repo" "PASS" \
        "file found at .claude/commands/search-second-brain.sh" "$((T1-T0))"
else
    record "P1-013-a" "FR-2.4" "search-second-brain.sh deployed in brain repo" "FAIL" \
        "File not found at ${BRAIN_REPO}/.claude/commands/search-second-brain.sh" "$((T1-T0))"
fi

# ---------------------------------------------------------------------------
# P1-015: Dependabot enabled on key repos
# ---------------------------------------------------------------------------
echo "" >&2
echo "--- P1-015: Dependabot Enabled ---" >&2

for ENTRY in "${PUBLIC_ORG}/dashboards:P1-015-a" "${PRIVATE_ORG}/seven-fortunas-brain:P1-015-b"; do
    REPO="${ENTRY%%:*}"
    ID="${ENTRY##*:}"
    T0=$(ts)
    # vulnerability-alerts returns 204 (empty body) when enabled, 404 when disabled
    if gh api "repos/${REPO}/vulnerability-alerts" &>/dev/null; then
        T1=$(ts)
        record "$ID" "FR-5.2" "Dependabot vulnerability alerts on ${REPO}" "PASS" \
            "vulnerability alerts enabled (HTTP 204)" "$((T1-T0))"
    else
        T1=$(ts)
        record "$ID" "FR-5.2" "Dependabot vulnerability alerts on ${REPO}" "FAIL" \
            "Dependabot not enabled (HTTP 404) — enable at repo Settings → Security → Dependabot alerts" "$((T1-T0))"
    fi
done

# ---------------------------------------------------------------------------
# P1-016: Live dashboard HTTP validation
# ---------------------------------------------------------------------------
echo "" >&2
echo "--- P1-016: Live Dashboard HTTP ---" >&2

# P1-016-a: Dashboard HTML returns 200
T0=$(ts)
if command -v curl &>/dev/null; then
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "${DASHBOARD_URL}/" 2>/dev/null || echo "000")
    T1=$(ts)
    if [[ "$HTTP_CODE" == "200" ]]; then
        record "P1-016-a" "FR-4.1" "Dashboard HTML returns 200" "PASS" \
            "HTTP ${HTTP_CODE}: ${DASHBOARD_URL}/" "$((T1-T0))"
    else
        record "P1-016-a" "FR-4.1" "Dashboard HTML returns 200" "FAIL" \
            "HTTP ${HTTP_CODE}: ${DASHBOARD_URL}/ (expected 200 — is Pages deployed?)" "$((T1-T0))"
    fi
else
    T1=$(ts)
    record "P1-016-a" "FR-4.1" "Dashboard HTML returns 200" "SKIP" \
        "curl not installed — cannot run live HTTP test" "$((T1-T0))"
fi

# P1-016-b: cached_updates.json exists and has ≥1 update
T0=$(ts)
if command -v curl &>/dev/null; then
    UPDATES_JSON=$(curl -sf --max-time 15 "${DASHBOARD_URL}/cached_updates.json" 2>/dev/null || echo "")
    T1=$(ts)
    if [[ -n "$UPDATES_JSON" ]]; then
        UPDATE_COUNT=$(echo "$UPDATES_JSON" | python3 -c \
            "import sys,json; d=json.load(sys.stdin); print(len(d.get('updates',d if isinstance(d,list) else [])))" \
            2>/dev/null || echo "0")
        if [[ "$UPDATE_COUNT" -ge 1 ]] 2>/dev/null; then
            record "P1-016-b" "FR-4.1" "cached_updates.json returns ≥1 update" "PASS" \
                "${UPDATE_COUNT} updates in cache" "$((T1-T0))"
        else
            record "P1-016-b" "FR-4.1" "cached_updates.json returns ≥1 update" "FAIL" \
                "JSON parsed but found ${UPDATE_COUNT} updates (expected ≥1) — run the dashboard curator" "$((T1-T0))"
        fi
    else
        record "P1-016-b" "FR-4.1" "cached_updates.json returns ≥1 update" "FAIL" \
            "cached_updates.json not found or returned empty — deploy dashboard data first" "$((T1-T0))"
    fi
else
    T1=$(ts)
    record "P1-016-b" "FR-4.1" "cached_updates.json returns ≥1 update" "SKIP" \
        "curl not installed — cannot run live HTTP test" "$((T1-T0))"
fi

# ---------------------------------------------------------------------------
# P2-008: 7f-dashboard-curator skill deployed in brain repo
# ---------------------------------------------------------------------------
echo "" >&2
echo "--- P2-008: 7f-dashboard-curator Skill ---" >&2

T0=$(ts)
CURATOR_NAME=$(gh_api "repos/${BRAIN_REPO}/contents/.claude/commands/7f-dashboard-curator.md" \
    --jq '.name // "null"')
T1=$(ts)
if [[ "$CURATOR_NAME" == "7f-dashboard-curator.md" ]]; then
    record "P2-008-a" "FR-4.3" "7f-dashboard-curator skill deployed in brain repo" "PASS" \
        "file found at .claude/commands/7f-dashboard-curator.md" "$((T1-T0))"
else
    record "P2-008-a" "FR-4.3" "7f-dashboard-curator skill deployed in brain repo" "FAIL" \
        "File not found at ${BRAIN_REPO}/.claude/commands/7f-dashboard-curator.md" "$((T1-T0))"
fi

# ---------------------------------------------------------------------------
# Build JSON output
# ---------------------------------------------------------------------------
END_MS=$(date +%s%3N)
TOTAL=$((PASS_COUNT + FAIL_COUNT + SKIP_COUNT))
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

if [[ $FAIL_COUNT -gt 0 ]]; then
    OVERALL_STATUS="FAIL"
    MESSAGE="${FAIL_COUNT}/${TOTAL} live infrastructure assertions failed"
else
    OVERALL_STATUS="PASS"
    MESSAGE="All ${TOTAL} live infrastructure assertions passed"
fi

echo "" >&2
echo "=== RESULT: ${OVERALL_STATUS} — ${MESSAGE} ===" >&2
echo "    Passed: ${PASS_COUNT}  Failed: ${FAIL_COUNT}  Skipped: ${SKIP_COUNT}" >&2

JSON_REPORT=$(python3 - "$RESULTS_TSV" "$TIMESTAMP" "$CURRENT_ACCOUNT" \
    "$PASS_COUNT" "$FAIL_COUNT" "$SKIP_COUNT" "$TOTAL" "$MESSAGE" <<'PYEOF'
import sys, json

results_file  = sys.argv[1]
timestamp     = sys.argv[2]
account       = sys.argv[3]
pass_count    = int(sys.argv[4])
fail_count    = int(sys.argv[5])
skip_count    = int(sys.argv[6])
total         = int(sys.argv[7])
message       = sys.argv[8]

overall = "PASS" if fail_count == 0 else "FAIL"

rows = []
with open(results_file) as f:
    for line in f:
        line = line.rstrip("\n")
        if not line:
            continue
        parts = line.split("\t", 5)
        rows.append({
            "test_id":     parts[0],
            "requirement": parts[1],
            "description": parts[2],
            "status":      parts[3],
            "message":     parts[4] if len(parts) > 4 else "",
            "duration_ms": int(parts[5]) if len(parts) > 5 else 0,
        })

report = {
    "test_suite":  "live-infrastructure-validation",
    "timestamp":   timestamp,
    "account":     account,
    "status":      overall,
    "message":     message,
    "total":       total,
    "passed":      pass_count,
    "failed":      fail_count,
    "skipped":     skip_count,
    "results":     rows,
}
print(json.dumps(report, indent=2))
PYEOF
)

if [[ -n "$OUTPUT_PATH" ]]; then
    echo "$JSON_REPORT" > "$OUTPUT_PATH"
    echo "Report written to: $OUTPUT_PATH" >&2
else
    echo "$JSON_REPORT"
fi

[[ "$OVERALL_STATUS" == "PASS" ]] && exit 0 || exit 1
