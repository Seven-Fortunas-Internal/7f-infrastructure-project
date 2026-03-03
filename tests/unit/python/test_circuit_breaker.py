"""
P1-002: Unit tests for scripts/circuit_breaker.py
Requirement: FR-7.2 — 5-consecutive-failure trigger, exit code 42,
             summary report on trigger, reset on success.
"""

import importlib.util
import json
import tempfile
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest

# ---------------------------------------------------------------------------
# Load module under test
# ---------------------------------------------------------------------------
_SCRIPT = Path(__file__).parents[3] / "scripts" / "circuit_breaker.py"
_spec = importlib.util.spec_from_file_location("circuit_breaker", _SCRIPT)
_mod = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_mod)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _features(pass_count=0, blocked_count=0, fail_count=0, pending_count=0):
    """Build a minimal features list for health calculation tests."""
    features = []
    for i in range(pass_count):
        features.append({"id": f"F{i:03d}", "status": "pass"})
    for i in range(blocked_count):
        features.append({"id": f"B{i:03d}", "status": "blocked"})
    for i in range(fail_count):
        features.append({"id": f"X{i:03d}", "status": "fail"})
    for i in range(pending_count):
        features.append({"id": f"P{i:03d}", "status": "pending"})
    return features


def _progress(consecutive_failures=0, session_count=0):
    return {
        "session_count": session_count,
        "consecutive_failed_sessions": consecutive_failures,
        "last_session_success": consecutive_failures == 0,
        "session_history": [],
        "circuit_breaker": {
            "status": "HEALTHY",
            "threshold": _mod.MAX_CONSECUTIVE_FAILED_SESSIONS,
            "triggers": [],
        },
        "last_updated": "2026-01-01T00:00:00",
    }


# ---------------------------------------------------------------------------
# TestCalculateSessionHealth
# ---------------------------------------------------------------------------

class TestCalculateSessionHealth:
    """Health thresholds: completion ≥50% AND blocked <30% → success."""

    def test_empty_features_returns_failure(self):
        h = _mod.calculate_session_health([])
        assert h["completion_rate"] == 0
        assert h["blocked_rate"] == 0
        assert h["success"] is False

    def test_all_pass_is_success(self):
        h = _mod.calculate_session_health(_features(pass_count=10))
        assert h["completion_rate"] == 1.0
        assert h["blocked_rate"] == 0.0
        assert h["success"] is True

    def test_exactly_50_percent_pass_is_success(self):
        # 5 pass out of 10, 0 blocked → 50% completion, 0% blocked
        h = _mod.calculate_session_health(_features(pass_count=5, pending_count=5))
        assert h["completion_rate"] == pytest.approx(0.5)
        assert h["success"] is True

    def test_below_50_percent_pass_is_failure(self):
        # 4 pass out of 10 = 40%
        h = _mod.calculate_session_health(_features(pass_count=4, pending_count=6))
        assert h["completion_rate"] == pytest.approx(0.4)
        assert h["success"] is False

    def test_high_blocked_rate_causes_failure(self):
        # 6 pass, 4 blocked = 60% pass but 40% blocked → failure
        h = _mod.calculate_session_health(_features(pass_count=6, blocked_count=4))
        assert h["completion_rate"] == pytest.approx(0.6)
        assert h["blocked_rate"] == pytest.approx(0.4)
        assert h["success"] is False

    def test_blocked_rate_just_below_threshold_is_success(self):
        # 7 pass, 2 blocked, 1 pending = 70% pass, 20% blocked → success
        h = _mod.calculate_session_health(
            _features(pass_count=7, blocked_count=2, pending_count=1)
        )
        assert h["success"] is True

    def test_correct_counts_returned(self):
        h = _mod.calculate_session_health(
            _features(pass_count=6, blocked_count=2, pending_count=2)
        )
        assert h["pass_count"] == 6
        assert h["blocked_count"] == 2
        assert h["total"] == 10

    def test_thresholds_are_correct_constants(self):
        assert _mod.MIN_COMPLETION_RATE == 0.50
        assert _mod.MAX_BLOCKED_RATE == 0.30
        assert _mod.MAX_CONSECUTIVE_FAILED_SESSIONS == 5


# ---------------------------------------------------------------------------
# TestCheckCircuitBreaker
# ---------------------------------------------------------------------------

class TestCheckCircuitBreaker:
    """Triggers at 5 consecutive failures; returns exit code 42 when triggered."""

    def _check(self, consecutive_failures):
        prog = _progress(consecutive_failures=consecutive_failures)
        with patch.object(_mod, "load_session_progress", return_value=prog):
            return _mod.check_circuit_breaker()

    def test_zero_failures_healthy(self):
        status = self._check(0)
        assert status["should_terminate"] is False
        assert status["exit_code"] == 0
        assert status["status"] == "HEALTHY"

    def test_four_failures_not_triggered(self):
        status = self._check(4)
        assert status["should_terminate"] is False
        assert status["exit_code"] == 0

    def test_five_failures_triggers(self):
        status = self._check(5)
        assert status["should_terminate"] is True
        assert status["exit_code"] == 42
        assert status["status"] == "TRIGGERED"

    def test_ten_failures_still_triggered(self):
        status = self._check(10)
        assert status["should_terminate"] is True
        assert status["exit_code"] == 42

    def test_trigger_reason_mentions_count(self):
        status = self._check(5)
        assert "5" in status["reason"]


# ---------------------------------------------------------------------------
# TestLoadSessionProgressDefault
# ---------------------------------------------------------------------------

class TestLoadSessionProgressDefault:
    """load_session_progress() returns a safe default when file doesn't exist."""

    def test_returns_default_when_file_missing(self, tmp_path):
        with patch.object(_mod, "get_project_root", return_value=tmp_path):
            progress = _mod.load_session_progress()
        assert progress["session_count"] == 0
        assert progress["consecutive_failed_sessions"] == 0
        assert progress["last_session_success"] is True
        assert progress["circuit_breaker"]["status"] == "HEALTHY"

    def test_default_has_empty_session_history(self, tmp_path):
        with patch.object(_mod, "get_project_root", return_value=tmp_path):
            progress = _mod.load_session_progress()
        assert progress["session_history"] == []

    def test_loads_existing_file(self, tmp_path):
        data = _progress(consecutive_failures=3, session_count=2)
        (tmp_path / "session_progress.json").write_text(json.dumps(data))
        with patch.object(_mod, "get_project_root", return_value=tmp_path):
            loaded = _mod.load_session_progress()
        assert loaded["consecutive_failed_sessions"] == 3
        assert loaded["session_count"] == 2


# ---------------------------------------------------------------------------
# TestRecordSession
# ---------------------------------------------------------------------------

class TestRecordSession:
    """record_session() updates consecutive failure count and circuit breaker."""

    def _end_metrics(self, features):
        return {"features": features}

    def test_successful_session_resets_consecutive_failures(self, tmp_path):
        prog = _progress(consecutive_failures=3)
        # 6 pass out of 10 = success
        features = _features(pass_count=6, pending_count=4)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            result = _mod.record_session({"pass_count": 3}, self._end_metrics(features))
        assert result["consecutive_failures"] == 0
        saved = mock_save.call_args[0][0]
        assert saved["consecutive_failed_sessions"] == 0

    def test_failed_session_increments_consecutive_failures(self, tmp_path):
        prog = _progress(consecutive_failures=2)
        # 3 pass out of 10 = failure (below 50%)
        features = _features(pass_count=3, pending_count=7)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            result = _mod.record_session({"pass_count": 3}, self._end_metrics(features))
        assert result["consecutive_failures"] == 3
        saved = mock_save.call_args[0][0]
        assert saved["consecutive_failed_sessions"] == 3

    def test_session_added_to_history(self, tmp_path):
        prog = _progress(consecutive_failures=0)
        features = _features(pass_count=8, pending_count=2)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({"pass_count": 5}, self._end_metrics(features))
        saved = mock_save.call_args[0][0]
        assert len(saved["session_history"]) == 1
        assert saved["session_count"] == 1

    def test_successful_session_last_session_success_true(self, tmp_path):
        prog = _progress(consecutive_failures=0)
        features = _features(pass_count=6, pending_count=4)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({"pass_count": 3}, self._end_metrics(features))
        saved = mock_save.call_args[0][0]
        assert saved["last_session_success"] is True

    def test_failed_session_last_session_success_false(self, tmp_path):
        prog = _progress(consecutive_failures=0)
        features = _features(pass_count=3, pending_count=7)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({"pass_count": 3}, self._end_metrics(features))
        saved = mock_save.call_args[0][0]
        assert saved["last_session_success"] is False


# ---------------------------------------------------------------------------
# TestGenerateSummaryReport
# ---------------------------------------------------------------------------

class TestGenerateSummaryReport:
    """generate_summary_report() writes a markdown report on circuit breaker trigger."""

    def test_report_file_created(self, tmp_path):
        features = _features(pass_count=3, blocked_count=2, pending_count=5)
        fl = {"features": [
            {"id": f["id"], "name": "Test", "status": f["status"],
             "category": "CI", "attempts": 1,
             "implementation_notes": "note", "last_updated": "2026-01-01"}
            for f in features
        ]}
        prog = _progress(consecutive_failures=5, session_count=5)
        with patch.object(_mod, "get_project_root", return_value=tmp_path), \
             patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "load_feature_list", return_value=fl):
            report_path = _mod.generate_summary_report()
        assert Path(report_path).exists()

    def test_report_contains_circuit_breaker_heading(self, tmp_path):
        features = _features(pass_count=5, blocked_count=5)
        fl = {"features": [
            {"id": f["id"], "name": "T", "status": f["status"],
             "category": "CI", "attempts": 1,
             "implementation_notes": "", "last_updated": "2026-01-01"}
            for f in features
        ]}
        prog = _progress(consecutive_failures=5, session_count=5)
        with patch.object(_mod, "get_project_root", return_value=tmp_path), \
             patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "load_feature_list", return_value=fl):
            report_path = _mod.generate_summary_report()
        content = Path(report_path).read_text()
        assert "Circuit Breaker" in content
        assert "TRIGGERED" in content
