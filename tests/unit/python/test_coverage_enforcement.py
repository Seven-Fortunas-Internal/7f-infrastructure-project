"""
P4-002 — P0 Script Coverage Enforcement Gate (NFR-5.5 / R-013)

PURPOSE:
    Asserts that each P0-risk script reaches ≥60% line coverage when exercised
    by its dedicated test suite. Fails CI if any script falls below the threshold,
    making coverage regression immediately visible rather than silently degrading.

WHAT THIS IS NOT:
    This is not a logic test. It is a meta-test / quality gate: "does the existing
    test suite exercise enough of each P0-risk script's lines?"

P0-risk scripts (bounded_retry, circuit_breaker, classify-failure-logs) are the
sentinel pipeline's core — failures here directly cause missed CI alert delivery.
Hence the coverage gate applies to these three first.

SDD reference: sprint4-plan.md P4-002
Risk reference: R-013 (coverage blind spot)
NFR reference : NFR-5.5 (coverage target — baseline 60%, Sprint 5 target 75%)
"""
import json
import os
import subprocess
import sys
from pathlib import Path

import pytest

_PROJECT_ROOT = Path(__file__).parent.parent.parent.parent
_SCRIPTS_DIR = _PROJECT_ROOT / "scripts"
_UNIT_TEST_DIR = Path(__file__).parent

# NFR-5.5 Sprint 5 threshold — WC-006 raised from 60% (Sprint 4) to 75% (Sprint 5)
# Sprint 6 target: 80% (NFR-5.5 final goal)
COVERAGE_THRESHOLD = 75  # percent

# P0-risk scripts and their dedicated test suite files
P0_RISK_SCRIPTS = [
    ("bounded_retry.py", "test_bounded_retry.py"),
    ("circuit_breaker.py", "test_circuit_breaker.py"),
    ("classify-failure-logs.py", "test_classify_failure_logs.py"),
]


# ===========================================================================
# 1. Coverage gate — each P0-risk script must reach COVERAGE_THRESHOLD
# ===========================================================================

class TestCoverageEnforcement:
    """Coverage gate: every P0-risk script must reach COVERAGE_THRESHOLD."""

    @pytest.mark.parametrize("script_name,test_file", P0_RISK_SCRIPTS)
    def test_p0_script_meets_threshold(self, script_name, test_file, tmp_path):
        """
        Run dedicated test suite under `coverage run` (isolated from parent
        pytest-cov session) and assert coverage >= 60%.

        Uses COVERAGE_FILE in tmp_path to avoid conflict with the outer
        pytest-cov process, and passes --no-cov to the inner pytest to
        prevent nested plugin activation.
        """
        script_path = _SCRIPTS_DIR / script_name
        test_path = _UNIT_TEST_DIR / test_file
        cov_data_file = tmp_path / ".coverage"
        report_path = tmp_path / "coverage.json"

        assert script_path.exists(), f"P0-risk script not found: {script_path}"
        assert test_path.exists(), f"Dedicated test suite not found: {test_path}"

        # Isolate coverage data from outer pytest-cov session
        env = os.environ.copy()
        env["COVERAGE_FILE"] = str(cov_data_file)

        # Step 1: Run the test suite under `coverage run`
        #   --include limits measurement to the target script only
        #   --no-cov suppresses the outer pytest-cov plugin in the subprocess
        run_result = subprocess.run(
            [
                sys.executable, "-m", "coverage", "run",
                f"--include={script_path}",
                "--branch",
                "-m", "pytest",
                "--no-cov",               # prevent nested pytest-cov activation
                "-p", "no:cacheprovider",
                "--tb=short", "-q",
                str(test_path),
            ],
            capture_output=True,
            text=True,
            cwd=str(_PROJECT_ROOT),
            env=env,
        )

        assert cov_data_file.exists(), (
            f"No coverage data file generated for {script_name}.\n"
            f"stdout:\n{run_result.stdout[-1000:]}\n"
            f"stderr:\n{run_result.stderr[-500:]}"
        )

        # Step 2: Export to JSON for programmatic threshold check
        json_result = subprocess.run(
            [
                sys.executable, "-m", "coverage", "json",
                "-o", str(report_path),
                f"--include={script_path}",
            ],
            capture_output=True,
            text=True,
            cwd=str(_PROJECT_ROOT),
            env=env,
        )

        assert report_path.exists(), (
            f"Coverage JSON report not generated for {script_name}.\n"
            f"json stdout:\n{json_result.stdout}\n"
            f"json stderr:\n{json_result.stderr}"
        )

        data = json.loads(report_path.read_text())

        # Locate this script's entry in the coverage report
        pct = None
        for file_key, file_data in data.get("files", {}).items():
            if Path(file_key).name == script_name:
                pct = file_data["summary"]["percent_covered"]
                break

        assert pct is not None, (
            f"Script '{script_name}' not found in coverage report.\n"
            f"Report file keys: {list(data.get('files', {}).keys())}"
        )

        assert pct >= COVERAGE_THRESHOLD, (
            f"{script_name}: coverage {pct:.1f}% < {COVERAGE_THRESHOLD}% threshold (NFR-5.5).\n"
            f"Run locally to see uncovered lines:\n"
            f"  pytest --cov=scripts/{script_name} --cov-report=term-missing "
            f"tests/unit/python/{test_file}\n"
            f"subprocess stdout:\n{run_result.stdout[-2000:]}"
        )


# ===========================================================================
# 2. Threshold constant guard — prevents silent lowering of the bar
# ===========================================================================

class TestCoverageThresholdConstants:
    """Guards threshold and P0-script list — changing either requires a test update."""

    def test_threshold_is_75_percent(self):
        """NFR-5.5 Sprint 5 threshold is 75%; Sprint 6 target is 80%."""
        assert COVERAGE_THRESHOLD == 75, (
            f"Coverage threshold changed from 75 to {COVERAGE_THRESHOLD}. "
            "Update sprint5-plan.md P5-004 and this assertion if intentional."
        )

    def test_p0_scripts_list_has_three_entries(self):
        """bounded_retry, circuit_breaker, classify-failure-logs — exactly 3 P0-risk scripts."""
        assert len(P0_RISK_SCRIPTS) == 3, (
            f"Expected 3 P0-risk scripts, got {len(P0_RISK_SCRIPTS)}. "
            "Update sprint4-plan.md P4-002 if a new P0-risk script is added."
        )

    def test_p0_scripts_list_contains_bounded_retry(self):
        names = [s for s, _ in P0_RISK_SCRIPTS]
        assert "bounded_retry.py" in names

    def test_p0_scripts_list_contains_circuit_breaker(self):
        names = [s for s, _ in P0_RISK_SCRIPTS]
        assert "circuit_breaker.py" in names

    def test_p0_scripts_list_contains_classify_failure_logs(self):
        names = [s for s, _ in P0_RISK_SCRIPTS]
        assert "classify-failure-logs.py" in names
