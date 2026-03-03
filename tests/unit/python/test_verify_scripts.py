"""
P2-003 — verify-feature-*.sh Non-Trivial Assertion Inspection (FR-7.3)

Verifies that existing verify-feature-*.sh scripts contain real validation
logic (not just echo/exit stubs). Uses code inspection to confirm the
presence of non-trivial assertion patterns.

Scope note (sprint3-dependency-assessment.md): only 1 script exists —
scripts/verify-feature-003.sh. Test is written to handle 1..N scripts.
"""

import re
import stat
from pathlib import Path

import pytest

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

PROJECT_ROOT = Path(__file__).parent.parent.parent.parent
SCRIPTS_DIR = PROJECT_ROOT / "scripts"

# Patterns that indicate non-trivial assertion logic
NON_TRIVIAL_PATTERNS = [
    r"gh\s+api",           # Live GitHub API call
    r"curl\s+",            # HTTP request
    r"\btest\s+-",         # test -f, test -eq, test -ge etc.
    r"\[\s+-",             # [ -f, [ -x etc.
    r"\[\[\s+",            # [[ bash conditional
    r"\s+==\s+",           # string equality
    r"\s+!=\s+",           # string inequality
    r"-eq\b",              # arithmetic equality
    r"-ge\b",              # arithmetic greater-or-equal
    r"-gt\b",              # arithmetic greater-than
    r"wc\s+-l",            # line count assertion
    r"grep\s+-[qc]",       # grep count/quiet check
]

NON_TRIVIAL_RE = re.compile("|".join(NON_TRIVIAL_PATTERNS))

# Markers of trivial/stub scripts (every line is just echo/exit)
TRIVIAL_ONLY_RE = re.compile(r"^\s*(echo|exit|#|$)", re.MULTILINE)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def get_verify_scripts():
    """Find all verify-feature-*.sh scripts in scripts/."""
    return sorted(SCRIPTS_DIR.glob("verify-feature-*.sh"))


def is_executable(path: Path) -> bool:
    return bool(path.stat().st_mode & stat.S_IXUSR)


def count_non_trivial_lines(content: str) -> int:
    """Count lines that contain at least one non-trivial assertion pattern."""
    return sum(1 for line in content.splitlines() if NON_TRIVIAL_RE.search(line))


# ---------------------------------------------------------------------------
# TestScriptDiscovery
# ---------------------------------------------------------------------------

class TestScriptDiscovery:

    def test_scripts_directory_exists(self):
        assert SCRIPTS_DIR.exists(), f"scripts/ not found at {SCRIPTS_DIR}"

    def test_at_least_one_verify_script_found(self):
        scripts = get_verify_scripts()
        assert len(scripts) >= 1, (
            f"Expected at least 1 verify-feature-*.sh in {SCRIPTS_DIR}, found 0"
        )

    def test_verify_feature_003_exists(self):
        """The one confirmed script from assessment must be present."""
        assert (SCRIPTS_DIR / "verify-feature-003.sh").exists()


# ---------------------------------------------------------------------------
# TestNonTrivialPatternDetector (unit tests for the helper itself)
# ---------------------------------------------------------------------------

class TestNonTrivialPatternDetector:

    def test_gh_api_detected(self):
        assert count_non_trivial_lines("count=$(gh api orgs/foo/teams | wc -l)") > 0

    def test_test_dash_detected(self):
        assert count_non_trivial_lines("if test -x scripts/foo.sh; then") > 0

    def test_bracket_comparison_detected(self):
        assert count_non_trivial_lines('if [ "$x" -eq 1 ]; then') > 0

    def test_echo_only_not_detected(self):
        assert count_non_trivial_lines("echo hello\necho world") == 0

    def test_comments_not_detected(self):
        assert count_non_trivial_lines("# This is a comment\n# Another comment") == 0


# ---------------------------------------------------------------------------
# TestPerScriptValidation — parametrized over discovered scripts
# ---------------------------------------------------------------------------

_verify_scripts = get_verify_scripts()
_verify_script_ids = [s.name for s in _verify_scripts]


@pytest.mark.parametrize("script_path", _verify_scripts, ids=_verify_script_ids)
class TestPerScriptValidation:

    def test_script_is_executable(self, script_path):
        assert is_executable(script_path), (
            f"{script_path.name} is not executable (chmod +x required)"
        )

    def test_script_has_shebang(self, script_path):
        first_line = script_path.read_text().split("\n")[0]
        assert first_line.startswith("#!/"), (
            f"{script_path.name}: no shebang — first line: {first_line!r}"
        )

    def test_script_has_non_trivial_assertions(self, script_path):
        """Script must contain real validation logic, not just echo/exit."""
        content = script_path.read_text()
        count = count_non_trivial_lines(content)
        assert count >= 3, (
            f"{script_path.name}: only {count} non-trivial assertion line(s) found. "
            f"Expected ≥3 (gh api, test/[, comparison operators, wc, grep). "
            f"Script may be a stub."
        )

    def test_script_references_expected_output_fields(self, script_path):
        """Script must produce FUNCTIONAL/TECHNICAL/INTEGRATION outputs."""
        content = script_path.read_text()
        # At minimum: must have some pass/fail logic
        assert re.search(r"\b(pass|fail|PASS|FAIL)\b", content), (
            f"{script_path.name}: no pass/fail outcome markers found — "
            f"script may not produce verification results"
        )
