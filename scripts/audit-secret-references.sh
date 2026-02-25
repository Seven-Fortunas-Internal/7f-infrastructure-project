#!/usr/bin/env bash
# =============================================================================
# audit-secret-references.sh — FR-10.2: Secret Reference Audit
# =============================================================================
# Cross-references secrets.$VAR used in workflow files against the actual
# configured secrets in the repository. Undefined secrets block merge.
#
# Usage:
#   ./scripts/audit-secret-references.sh [workflow-dir] [--repo owner/repo]
#   GH_TOKEN must be set (uses gh CLI)
#
# Exit: 0 = pass, 1 = undefined secrets found (not in manifest)
# =============================================================================

set -uo pipefail

RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; NC='\033[0m'

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
WORKFLOW_DIR="${REPO_ROOT}/.github/workflows"
SECRETS_MANIFEST="${REPO_ROOT}/.secrets-manifest.yml"
REPO="${GITHUB_REPOSITORY:-}"

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO="$2"; shift 2 ;;
    *) WORKFLOW_DIR="$1"; shift ;;
  esac
done

ERRORS=0
WARNINGS=0

_err()  { echo -e "  ${RED}[UNDEF]${NC}  $1"; ((ERRORS++)) || true; }
_warn() { echo -e "  ${YELLOW}[PLAN] ${NC}  $1 (in .secrets-manifest.yml — WARNING only)"; ((WARNINGS++)) || true; }
_ok()   { echo -e "  ${GREEN}[OK]   ${NC}  $1"; }

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " FR-10.2 Secret Reference Audit"
echo " Workflows: $WORKFLOW_DIR"
[[ -n "$REPO" ]] && echo " Repository: $REPO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── 1. Extract all secrets.XXX references from workflow files ─────────────────
echo ""
echo "Extracting secret references from workflows..."
ALL_REFS="$(grep -roh '\${{ *secrets\.[A-Z_][A-Z0-9_]* *}}' "${WORKFLOW_DIR}"/*.yml 2>/dev/null | \
  grep -oP 'secrets\.\K[A-Z_][A-Z0-9_]*' | sort -u || true)"

# Also include GITHUB_TOKEN — always available, not in gh secret list
BUILTIN_SECRETS="GITHUB_TOKEN"

if [[ -z "$ALL_REFS" ]]; then
  echo "  No secrets.* references found in workflows."
  exit 0
fi

echo "  Found references: $(echo "$ALL_REFS" | wc -l | tr -d ' ')"

# ── 2. Get configured secrets from GitHub ────────────────────────────────────
CONFIGURED=""
if [[ -n "$REPO" ]]; then
  echo "  Fetching configured secrets from GitHub..."
  CONFIGURED="$(gh secret list --repo "$REPO" --json name --jq '.[].name' 2>/dev/null | sort || true)"
  if [[ -z "$CONFIGURED" ]]; then
    echo -e "  ${YELLOW}Warning: Could not fetch secrets list (check GH_TOKEN permissions)${NC}"
    echo "  Skipping remote validation — check manually."
    exit 0
  fi
  echo "  Configured secrets: $(echo "$CONFIGURED" | wc -l | tr -d ' ')"
else
  echo "  No --repo specified; skipping remote validation (run with GITHUB_REPOSITORY set)."
  exit 0
fi

# ── 3. Load planned secrets from manifest (optional) ─────────────────────────
PLANNED=""
if [[ -f "$SECRETS_MANIFEST" ]]; then
  PLANNED="$(grep -oP 'name:\s*\K[A-Z_][A-Z0-9_]*' "$SECRETS_MANIFEST" 2>/dev/null | sort || true)"
  echo "  Planned secrets (manifest): $(echo "$PLANNED" | wc -l | tr -d ' ')"
fi

# ── 4. Cross-reference ────────────────────────────────────────────────────────
echo ""
echo "Checking each reference..."
while IFS= read -r secret; do
  [[ -z "$secret" ]] && continue

  # Built-in secrets — always available
  if echo "$BUILTIN_SECRETS" | grep -qw "$secret"; then
    _ok "${secret} (GitHub built-in)"
    continue
  fi

  # Configured in repo
  if echo "$CONFIGURED" | grep -qw "$secret"; then
    _ok "$secret"
    continue
  fi

  # In secrets manifest (planned — WARNING, not ERROR)
  if [[ -n "$PLANNED" ]] && echo "$PLANNED" | grep -qw "$secret"; then
    _warn "$secret"
    continue
  fi

  # Not configured, not planned → ERROR
  _err "$secret — not configured in repository and not in .secrets-manifest.yml"
done <<< "$ALL_REFS"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf " Undefined secrets : %d\n" "$ERRORS"
printf " Planned (warn)    : %d\n" "$WARNINGS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ $ERRORS -eq 0 ]]; then
  echo -e " ${GREEN}PASS${NC} — All secret references are configured or planned"
  exit 0
else
  echo -e " ${RED}FAIL${NC} — ${ERRORS} undefined secret(s) block merge"
  echo "  Add them to the repository secrets or declare them as 'planned' in .secrets-manifest.yml"
  exit 1
fi
