#!/usr/bin/env bash
# =============================================================================
# validate-workflow-compliance.sh — NFR-5.6 Workflow Authoring Validator
# =============================================================================
# Enforces 8 GitHub Actions authoring constraints that prevent systematic
# first-push CI failures. Used as both a PR required status check (FR-10.1)
# and an autonomous agent pre-commit gate (FR-10.4).
#
# Usage:
#   ./scripts/validate-workflow-compliance.sh [path]
#   path: a .yml file, a directory, or omit for .github/workflows/
#
# Exit: 0 = pass (zero errors), 1 = fail (one or more errors)
# Warnings never block — they are informational.
# =============================================================================

set -uo pipefail

# ── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; NC='\033[0m'

# ── State ────────────────────────────────────────────────────────────────────
TOTAL_ERRORS=0
TOTAL_WARNINGS=0
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ALLOWLIST="${REPO_ROOT}/.github/workflow-compliance.yml"

# ── Helpers ──────────────────────────────────────────────────────────────────
_err()  { echo -e "    ${RED}[ERROR C${1}]${NC} ${2}"; ((TOTAL_ERRORS++)) || true; }
_warn() { echo -e "    ${YELLOW}[WARN  C${1}]${NC} ${2}"; ((TOTAL_WARNINGS++)) || true; }
_ok()   { echo -e "    ${GREEN}[OK    C${1}]${NC} ${2}"; }
_skip() { echo -e "           C${1}  — not applicable"; }

# Check if file+constraint is allow-listed in .github/workflow-compliance.yml
is_allowed() {
  local file_base="$1" constraint="$2"
  [[ -f "$ALLOWLIST" ]] || return 1
  python3 - <<PYEOF 2>/dev/null
import sys, re
try:
    with open("${ALLOWLIST}") as f:
        content = f.read()
    # Look for proximity of file and constraint within same exception block
    blocks = re.split(r'\n\s*-\s+file:', content)
    for block in blocks[1:]:  # skip header
        if re.search(r"^\s*${file_base}", block) and \
           re.search(r"constraint:\s*${constraint}\b", block):
            sys.exit(0)
    sys.exit(1)
except Exception:
    sys.exit(1)
PYEOF
}

# ── C1: npm cache without package-lock.json ──────────────────────────────────
check_c1() {
  local file="$1"
  if grep -qE "cache:\s*'?\"?npm'?\"?|^\s+npm ci\b" "$file" 2>/dev/null; then
    # If cache-dependency-path is set, use that path; otherwise check repo root
    local dep_path
    dep_path="$(grep -oP "cache-dependency-path:\s*\K[^\n]+" "$file" 2>/dev/null | head -1 | tr -d "'\"")"
    if [[ -n "$dep_path" ]]; then
      if [[ -f "${REPO_ROOT}/${dep_path}" ]]; then
        _ok 1 "npm cache with cache-dependency-path — ${dep_path} present"
      else
        _err 1 "npm cache: cache-dependency-path '${dep_path}' not found in repo"
      fi
    elif [[ -f "${REPO_ROOT}/package-lock.json" ]]; then
      _ok 1 "npm cache/ci — package-lock.json present at repo root"
    else
      _err 1 "npm cache/ci used but package-lock.json missing (add cache-dependency-path or commit package-lock.json)"
    fi
  else
    _skip 1
  fi
}

# ── C2: secrets.* in if: conditions ─────────────────────────────────────────
check_c2() {
  local file="$1" file_base
  file_base="$(basename "$file")"
  local matches
  matches="$(grep -nE "^\s+if:\s+.*secrets\." "$file" 2>/dev/null || true)"
  if [[ -n "$matches" ]]; then
    if is_allowed "$file_base" "C2"; then
      _ok 2 "secrets.* in if: (allow-listed)"
    else
      while IFS= read -r line; do
        _err 2 "secrets.* in if: — use continue-on-error: true instead | ${line}"
      done <<< "$matches"
    fi
  else
    _skip 2
  fi
}

# ── C3: Markdown at column 0 inside block scalars (WARNING) ─────────────────
check_c3() {
  local file="$1"
  # Lines starting with ** or ## that are not YAML keys/comments at top level
  local matches
  matches="$(grep -nE "^\*\*[^*]|^##[^!]" "$file" 2>/dev/null || true)"
  if [[ -n "$matches" ]]; then
    while IFS= read -r line; do
      _warn 3 "Possible markdown at col 0 (may exit block scalar) | ${line}"
    done <<< "$matches"
  else
    _skip 3
  fi
}

# ── C4: Bot commit loop — git add path overlaps on.push.paths trigger ────────
check_c4() {
  local file="$1"
  python3 - "$file" <<'PYEOF' 2>/dev/null
import sys, re

file = sys.argv[1]
try:
    with open(file) as f:
        content = f.read()

    # Extract on.push.paths values (simple regex, handles most real cases)
    push_paths_m = re.search(
        r'\bon:\s*\n(?:.*\n)*?.*?push:\s*\n((?:.*\n)*?)(?=\n\S|\Z)',
        content
    )
    if not push_paths_m:
        # Also try the inline-push variant: on: [push] (no paths, so no loop risk)
        sys.exit(0)

    push_section = push_paths_m.group(0)
    paths_m = re.findall(r'paths:\s*\n((?:\s+- [^\n]+\n?)+)', push_section)
    if not paths_m:
        sys.exit(0)

    push_paths = []
    for pm in paths_m:
        for item in re.findall(r'-\s*([^\n]+)', pm):
            push_paths.append(item.strip().strip("'\""))

    # Find git add paths in run: blocks
    git_adds = re.findall(r'git add\s+([^\n]+)', content)
    if not git_adds:
        sys.exit(0)

    found_overlap = False
    for push_path in push_paths:
        push_base = push_path.rstrip('/**').rstrip('/*').rstrip('/')
        for git_add in git_adds:
            git_add = git_add.strip().strip("'\"")
            if git_add == '.' or git_add == '-A':
                # 'git add .' or 'git add -A' commits everything — always a loop risk
                if push_paths:
                    print(f"    \033[0;31m[ERROR C4]\033[0m bot commit loop: 'git add {git_add}' with on.push.paths trigger '{push_path}'")
                    found_overlap = True
            elif git_add.startswith(push_base) or push_base.startswith(git_add.rstrip('/')):
                print(f"    \033[0;31m[ERROR C4]\033[0m bot commit loop: git add '{git_add}' overlaps push path '{push_path}'")
                found_overlap = True

    sys.exit(1 if found_overlap else 0)

except Exception:
    sys.exit(0)  # Parse errors are not C4 violations
PYEOF
  local rc=$?
  if [[ $rc -eq 0 ]]; then
    _skip 4
  else
    ((TOTAL_ERRORS++)) || true
  fi
}

# ── C5: Protected branch push without fallback ───────────────────────────────
check_c5() {
  local file="$1" file_base
  file_base="$(basename "$file")"
  # Find bare "git push" lines (not in comments) without || on the same line
  local matches
  matches="$(grep -nE "^\s+git push(\s|$)" "$file" 2>/dev/null | grep -vE "\|\|" || true)"
  if [[ -n "$matches" ]]; then
    if is_allowed "$file_base" "C5"; then
      _ok 5 "bare git push (allow-listed)"
    else
      while IFS= read -r line; do
        _err 5 "git push without '|| echo skipped' fallback | ${line}"
      done <<< "$matches"
    fi
  else
    _skip 5
  fi
}

# ── C7: actions/deploy-pages without continue-on-error: true ────────────────
check_c7() {
  local file="$1"
  local line_nums
  line_nums="$(grep -n "uses: actions/deploy-pages" "$file" 2>/dev/null | cut -d: -f1 || true)"
  [[ -z "$line_nums" ]] && { _skip 7; return; }

  while IFS= read -r lnum; do
    local start=$(( lnum - 6 )) end=$(( lnum + 6 ))
    [[ $start -lt 1 ]] && start=1
    local context
    context="$(sed -n "${start},${end}p" "$file" 2>/dev/null || true)"
    if echo "$context" | grep -q "continue-on-error: true"; then
      _ok 7 "deploy-pages has continue-on-error: true (line $lnum)"
    else
      _err 7 "actions/deploy-pages at line $lnum missing 'continue-on-error: true'"
    fi
  done <<< "$line_nums"
}

# ── C8: Paid org license tools without continue-on-error: true ───────────────
check_c8() {
  local file="$1"
  local paid_tools=("gitleaks-action" "advanced-security")

  for tool in "${paid_tools[@]}"; do
    local line_nums
    line_nums="$(grep -n "uses:.*${tool}" "$file" 2>/dev/null | cut -d: -f1 || true)"
    [[ -z "$line_nums" ]] && continue

    while IFS= read -r lnum; do
      local start=$(( lnum - 6 )) end=$(( lnum + 6 ))
      [[ $start -lt 1 ]] && start=1
      local context
      context="$(sed -n "${start},${end}p" "$file" 2>/dev/null || true)"
      if echo "$context" | grep -q "continue-on-error: true"; then
        _ok 8 "${tool} has continue-on-error: true (line $lnum)"
      else
        _err 8 "${tool} at line $lnum missing 'continue-on-error: true' (license required)"
      fi
    done <<< "$line_nums"
  done
  # Only _skip if no paid tools found
  local found_any=false
  for tool in "${paid_tools[@]}"; do
    grep -q "uses:.*${tool}" "$file" 2>/dev/null && found_any=true && break
  done
  $found_any || _skip 8
}

# ── C6 (global): Duplicate concurrency group names ───────────────────────────
check_c6_global() {
  local workflow_dir="$1"
  echo ""
  echo "C6: Concurrency group uniqueness (global)"

  # Extract all group: values, normalize github context vars to VAR placeholder
  local all_groups
  all_groups="$(grep -rh "^\s*group:" "${workflow_dir}" 2>/dev/null | \
    sed 's/.*group:\s*//' | \
    sed "s/\${{ [^}]* }}/VAR/g" | \
    sed "s/'//g; s/\"//g" | \
    sort || true)"

  if [[ -z "$all_groups" ]]; then
    echo -e "    ${GREEN}[OK    C6]${NC} No concurrency groups defined"
    return
  fi

  local duplicates
  duplicates="$(echo "$all_groups" | uniq -d || true)"

  if [[ -n "$duplicates" ]]; then
    while IFS= read -r group; do
      _warn 6 "Duplicate concurrency group: '${group}'"
    done <<< "$duplicates"
  else
    echo -e "    ${GREEN}[OK    C6]${NC} All concurrency groups unique ($(echo "$all_groups" | wc -l | tr -d ' ') defined)"
  fi
}

# ── Check a single workflow file ─────────────────────────────────────────────
check_file() {
  local file="$1"
  local before_errors=$TOTAL_ERRORS
  local before_warnings=$TOTAL_WARNINGS

  echo ""
  echo "▶ $(basename "$file")"
  check_c1 "$file"
  check_c2 "$file"
  check_c3 "$file"
  check_c4 "$file"
  check_c5 "$file"
  check_c7 "$file"
  check_c8 "$file"

  local file_errors=$(( TOTAL_ERRORS - before_errors ))
  local file_warns=$(( TOTAL_WARNINGS - before_warnings ))
  if [[ $file_errors -eq 0 && $file_warns -eq 0 ]]; then
    echo -e "    ${GREEN}✓ clean${NC}"
  fi
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
  local target="${1:-${REPO_ROOT}/.github/workflows}"

  local files=()
  if [[ -f "$target" ]]; then
    files=("$target")
  elif [[ -d "$target" ]]; then
    while IFS= read -r f; do
      files+=("$f")
    done < <(find "$target" -maxdepth 1 \( -name "*.yml" -o -name "*.yaml" \) | sort)
  else
    echo "Error: '$target' is not a file or directory" >&2
    exit 1
  fi

  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No workflow files found in $target"
    exit 0
  fi

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " NFR-5.6 Workflow Compliance Validator"
  echo " Target: $target"
  [[ -f "$ALLOWLIST" ]] && echo " Allow-list: $ALLOWLIST"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  for file in "${files[@]}"; do
    check_file "$file"
  done

  # Global check: concurrency groups (needs all files)
  local workflow_dir
  if [[ -f "$target" ]]; then
    workflow_dir="$(dirname "$target")"
  else
    workflow_dir="$target"
  fi
  check_c6_global "$workflow_dir"

  # ── Summary ─────────────────────────────────────────────────────────────
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  printf " Files checked : %d\n" "${#files[@]}"
  printf " Errors        : %d\n" "$TOTAL_ERRORS"
  printf " Warnings      : %d\n" "$TOTAL_WARNINGS"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if [[ $TOTAL_ERRORS -eq 0 ]]; then
    echo -e " ${GREEN}PASS${NC} — All NFR-5.6 constraints satisfied"
    exit 0
  else
    echo -e " ${RED}FAIL${NC} — ${TOTAL_ERRORS} error(s) must be resolved before merge"
    exit 1
  fi
}

main "$@"
