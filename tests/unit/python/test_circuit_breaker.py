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

    def test_report_no_blocked_features_branch(self, tmp_path):
        """Line 244: 'No blocked features.' branch when feature list has no blocked items."""
        features = _features(pass_count=10)
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
        assert "No blocked features" in content

    def test_report_includes_session_history(self, tmp_path):
        """Lines 260-261: session_history loop rendered in report."""
        features = _features(pass_count=5, blocked_count=1)
        fl = {"features": [
            {"id": f["id"], "name": "T", "status": f["status"],
             "category": "CI", "attempts": 1,
             "implementation_notes": "", "last_updated": "2026-01-01"}
            for f in features
        ]}
        prog = _progress(consecutive_failures=5, session_count=2)
        prog["session_history"] = [
            {"session_id": 1, "date": "2026-01-01", "success": True,
             "start_passing": 0, "end_passing": 5, "completion_rate": 0.5,
             "blocked_rate": 0.1},
            {"session_id": 2, "date": "2026-01-02", "success": False,
             "start_passing": 5, "end_passing": 5, "completion_rate": 0.5,
             "blocked_rate": 0.2},
        ]
        with patch.object(_mod, "get_project_root", return_value=tmp_path), \
             patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "load_feature_list", return_value=fl):
            report_path = _mod.generate_summary_report()
        content = Path(report_path).read_text()
        assert "Session 1" in content
        assert "Session 2" in content

# ---------------------------------------------------------------------------
# TestHelperFunctions — covers get_project_root and save_session_progress
# ---------------------------------------------------------------------------

class TestHelperFunctions:

    def test_get_project_root_returns_path(self):
        """Line 18: get_project_root() returns the project root as a Path."""
        result = _mod.get_project_root()
        assert isinstance(result, Path)
        assert result.exists()

    def test_save_session_progress_writes_file(self, tmp_path):
        """Lines 52-58: save_session_progress() writes JSON to session_progress.json."""
        progress = {"session_count": 1, "consecutive_failed_sessions": 0}
        with patch.object(_mod, "get_project_root", return_value=tmp_path):
            _mod.save_session_progress(progress)
        written = json.loads((tmp_path / "session_progress.json").read_text())
        assert written["session_count"] == 1
        assert "last_updated" in written  # timestamp added by save_session_progress


# ---------------------------------------------------------------------------
# P7-002: Mutation-killing tests — boundary values, key dict structure,
#         exact counter arithmetic
# ---------------------------------------------------------------------------


class TestCompletionRateBoundary:
    """Kill mutants that change >= to > for MIN_COMPLETION_RATE."""

    def test_49_percent_completion_fails(self):
        """49 pass / 100 total = 49% — just below threshold → failure."""
        h = _mod.calculate_session_health(_features(pass_count=49, pending_count=51))
        assert h["completion_rate"] == pytest.approx(0.49)
        assert h["success"] is False

    def test_50_percent_completion_passes(self):
        """50 pass / 100 total = exactly 50% → must pass (>= not >)."""
        h = _mod.calculate_session_health(_features(pass_count=50, pending_count=50))
        assert h["completion_rate"] == pytest.approx(0.50)
        assert h["success"] is True


class TestBlockedRateBoundary:
    """Kill mutants that change < to <= for MAX_BLOCKED_RATE."""

    def test_exactly_30_percent_blocked_fails(self):
        """30 blocked / 100 total = exactly 30% — NOT < 30% → failure."""
        h = _mod.calculate_session_health(
            _features(pass_count=70, blocked_count=30)
        )
        assert h["blocked_rate"] == pytest.approx(0.30)
        assert h["success"] is False  # 0.30 < 0.30 is False

    def test_29_percent_blocked_passes(self):
        """29 blocked / 100 total = 29% — < 30% → passes (if completion also ≥50%)."""
        h = _mod.calculate_session_health(
            _features(pass_count=71, blocked_count=29)
        )
        assert h["blocked_rate"] == pytest.approx(0.29)
        assert h["success"] is True


class TestCheckCircuitBreakerReturnStructure:
    """Kill mutants that remove keys from the returned dict."""

    def _check(self, consecutive_failures):
        prog = _progress(consecutive_failures=consecutive_failures)
        with patch.object(_mod, "load_session_progress", return_value=prog):
            return _mod.check_circuit_breaker()

    def test_triggered_returns_all_required_keys(self):
        """When triggered, all 4 keys must be present."""
        result = self._check(5)
        assert "should_terminate" in result
        assert "reason" in result
        assert "status" in result
        assert "exit_code" in result

    def test_not_triggered_returns_all_required_keys(self):
        """When healthy, all 4 keys must be present."""
        result = self._check(0)
        assert "should_terminate" in result
        assert "reason" in result
        assert "status" in result
        assert "exit_code" in result

    def test_not_triggered_should_terminate_is_false(self):
        result = self._check(0)
        assert result["should_terminate"] is False

    def test_triggered_should_terminate_is_true(self):
        result = self._check(5)
        assert result["should_terminate"] is True


class TestRecordSessionCounterExactness:
    """Kill mutants that change += 1 to += 2 or reset to 1 instead of 0."""

    def _end_metrics(self, features):
        return {"features": features}

    def test_success_resets_counter_to_exactly_zero_not_one(self, tmp_path):
        """Counter must be 0 after success, not any other value."""
        prog = _progress(consecutive_failures=4)
        features = _features(pass_count=6, pending_count=4)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({"pass_count": 3}, self._end_metrics(features))
        saved = mock_save.call_args[0][0]
        assert saved["consecutive_failed_sessions"] == 0

    def test_failure_increments_by_exactly_one(self, tmp_path):
        """Counter must be prev + 1, not prev + 2 or any other value."""
        for start_val in (0, 1, 3):
            prog = _progress(consecutive_failures=start_val)
            features = _features(pass_count=3, pending_count=7)
            with patch.object(_mod, "load_session_progress", return_value=prog), \
                 patch.object(_mod, "save_session_progress") as mock_save:
                _mod.record_session({"pass_count": 0}, self._end_metrics(features))
            saved = mock_save.call_args[0][0]
            assert saved["consecutive_failed_sessions"] == start_val + 1, (
                f"Expected {start_val + 1}, got {saved['consecutive_failed_sessions']}"
            )


class TestGenerateSummaryReportContent:
    """Kill mutants in generate_summary_report content generation."""

    def _make_fl(self, features):
        return {"features": [
            {"id": f["id"], "name": "Test", "status": f["status"],
             "category": "CI", "attempts": 1,
             "implementation_notes": "note", "last_updated": "2026-01-01"}
            for f in features
        ]}

    def test_blocked_section_heading_present_when_blocked_features_exist(self, tmp_path):
        """Kill mutants that omit the blocked features loop."""
        features = _features(pass_count=3, blocked_count=2, pending_count=5)
        prog = _progress(consecutive_failures=5, session_count=5)
        with patch.object(_mod, "get_project_root", return_value=tmp_path), \
             patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "load_feature_list", return_value=self._make_fl(features)):
            report_path = _mod.generate_summary_report()
        content = Path(report_path).read_text()
        assert "Blocked Features" in content
        # Each blocked feature's ID should appear
        assert "B000" in content
        assert "B001" in content

    def test_reason_field_in_triggered_status_contains_count(self, tmp_path):
        """check_circuit_breaker reason must mention consecutive count."""
        prog = _progress(consecutive_failures=5, session_count=5)
        with patch.object(_mod, "load_session_progress", return_value=prog):
            result = _mod.check_circuit_breaker()
        assert result["reason"] is not None
        assert "5" in result["reason"]

    def test_reason_field_is_none_when_healthy(self, tmp_path):
        """check_circuit_breaker reason must be None when not triggered."""
        prog = _progress(consecutive_failures=0)
        with patch.object(_mod, "load_session_progress", return_value=prog):
            result = _mod.check_circuit_breaker()
        assert result["reason"] is None


# ---------------------------------------------------------------------------
# P7-002 (round 2): Targeted mutant-killing tests for surviving mutants
# ---------------------------------------------------------------------------


class TestLoadSessionProgressDefaultKeys:
    """Kill mutants 27-29: XX-prefix mutations on key names in default dict."""

    def test_default_circuit_breaker_threshold_key_exists_with_correct_value(self, tmp_path):
        with patch.object(_mod, "get_project_root", return_value=tmp_path):
            prog = _mod.load_session_progress()
        assert "threshold" in prog["circuit_breaker"]
        assert prog["circuit_breaker"]["threshold"] == _mod.MAX_CONSECUTIVE_FAILED_SESSIONS

    def test_default_circuit_breaker_triggers_is_empty_list(self, tmp_path):
        with patch.object(_mod, "get_project_root", return_value=tmp_path):
            prog = _mod.load_session_progress()
        assert "triggers" in prog["circuit_breaker"]
        assert prog["circuit_breaker"]["triggers"] == []

    def test_default_has_last_updated_as_nonempty_string(self, tmp_path):
        with patch.object(_mod, "get_project_root", return_value=tmp_path):
            prog = _mod.load_session_progress()
        assert "last_updated" in prog
        assert isinstance(prog["last_updated"], str)
        assert len(prog["last_updated"]) > 10


class TestSaveSessionProgressKeys:
    """Kill mutant 36: last_updated set to None instead of ISO string."""

    def test_save_adds_last_updated_as_nonempty_string(self, tmp_path):
        progress = {"session_count": 1, "consecutive_failed_sessions": 0}
        with patch.object(_mod, "get_project_root", return_value=tmp_path):
            _mod.save_session_progress(progress)
        written = json.loads((tmp_path / "session_progress.json").read_text())
        assert "last_updated" in written
        assert written["last_updated"] is not None
        assert isinstance(written["last_updated"], str)
        assert len(written["last_updated"]) > 10


class TestRecordSessionSavedDictKeys:
    """Kill mutants 94-153: XX-prefix key mutations in record_session saved dict."""

    def _em(self, features):
        return {"features": features}

    def test_saved_progress_session_count_incremented(self, tmp_path):
        """Mutant 94: 'session_count' → 'XXsession_countXX'."""
        prog = _progress(session_count=2)
        features = _features(pass_count=6, pending_count=4)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({"pass_count": 0}, self._em(features))
        saved = mock_save.call_args[0][0]
        assert "session_count" in saved
        assert saved["session_count"] == 3  # was 2, incremented to 3

    def test_saved_last_session_success_true_on_success(self, tmp_path):
        """Mutant 105: 'last_session_success' → 'XXlast_session_successXX' (success branch)."""
        prog = _progress(consecutive_failures=0)
        features = _features(pass_count=6, pending_count=4)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({"pass_count": 0}, self._em(features))
        saved = mock_save.call_args[0][0]
        assert "last_session_success" in saved
        assert saved["last_session_success"] is True

    def test_saved_last_session_success_false_on_failure(self, tmp_path):
        """Mutant 110: 'last_session_success' → 'XXlast_session_successXX' (failure branch)."""
        prog = _progress(consecutive_failures=0)
        features = _features(pass_count=3, pending_count=7)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({"pass_count": 0}, self._em(features))
        saved = mock_save.call_args[0][0]
        assert "last_session_success" in saved
        assert saved["last_session_success"] is False

    def test_failure_trigger_has_session_key(self, tmp_path):
        """Mutants 125-127: trigger dict key mutations ('session', 'timestamp', 'reason')."""
        prog = _progress(consecutive_failures=0)
        features = _features(pass_count=3, pending_count=7)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({"pass_count": 0}, self._em(features))
        saved = mock_save.call_args[0][0]
        triggers = saved["circuit_breaker"]["triggers"]
        assert len(triggers) == 1
        t = triggers[0]
        assert "session" in t
        assert "timestamp" in t
        assert "reason" in t

    def test_failure_trigger_session_value_is_session_number(self, tmp_path):
        """Trigger dict 'session' must equal the session number."""
        prog = _progress(consecutive_failures=0, session_count=4)
        features = _features(pass_count=3, pending_count=7)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({"pass_count": 0}, self._em(features))
        saved = mock_save.call_args[0][0]
        t = saved["circuit_breaker"]["triggers"][0]
        assert t["session"] == 5  # session_count was 4, so session_num = 5

    def test_session_history_entry_has_all_required_keys(self, tmp_path):
        """Mutants 130-147: session_record dict key mutations."""
        prog = _progress(session_count=0)
        features = _features(pass_count=6, blocked_count=2, pending_count=2)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({"pass_count": 3}, self._em(features))
        saved = mock_save.call_args[0][0]
        entry = saved["session_history"][0]
        assert "session_id" in entry
        assert "date" in entry
        assert "start_passing" in entry
        assert "end_passing" in entry
        assert "blocked_count" in entry
        assert "completion_rate" in entry
        assert "blocked_rate" in entry
        assert "success" in entry

    def test_session_history_entry_values_correct(self, tmp_path):
        """Session record values match what was passed in and calculated."""
        prog = _progress(session_count=2)
        features = _features(pass_count=6, blocked_count=2, pending_count=2)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({"pass_count": 4}, self._em(features))
        entry = mock_save.call_args[0][0]["session_history"][0]
        assert entry["session_id"] == 3          # session_count was 2 → session 3
        assert entry["start_passing"] == 4       # from start_metrics
        assert entry["end_passing"] == 6         # pass_count in features
        assert entry["blocked_count"] == 2
        assert entry["completion_rate"] == pytest.approx(0.6)
        assert entry["blocked_rate"] == pytest.approx(0.2)
        assert entry["success"] is True

    def test_circuit_breaker_status_updated_in_saved_progress(self, tmp_path):
        """Mutant 153: 'status' key in progress['circuit_breaker'] update."""
        prog = _progress(consecutive_failures=5)
        features = _features(pass_count=3, pending_count=7)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({"pass_count": 0}, self._em(features))
        saved = mock_save.call_args[0][0]
        assert "status" in saved["circuit_breaker"]
        assert saved["circuit_breaker"]["status"] == "TRIGGERED"

    def test_return_dict_has_all_required_keys(self, tmp_path):
        """Mutants 157-159: return dict key mutations in record_session."""
        prog = _progress(consecutive_failures=0)
        features = _features(pass_count=6, pending_count=4)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress"):
            result = _mod.record_session({"pass_count": 0}, self._em(features))
        assert "session_num" in result
        assert "health" in result
        assert "circuit_breaker" in result
        assert "consecutive_failures" in result


class TestGenerateSummaryReportDetailedContent:
    """Kill mutants 164-261: string content in generate_summary_report."""

    def _make_fl(self, features):
        return {"features": [
            {"id": f["id"], "name": "Test Feature", "status": f["status"],
             "category": "CI", "attempts": 1,
             "implementation_notes": "test note", "last_updated": "2026-01-01"}
            for f in features
        ]}

    def _run(self, tmp_path, features, prog=None):
        if prog is None:
            prog = _progress(consecutive_failures=5, session_count=5)
        with patch.object(_mod, "get_project_root", return_value=tmp_path), \
             patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "load_feature_list", return_value=self._make_fl(features)):
            report_path = _mod.generate_summary_report()
        return Path(report_path).read_text()

    def test_report_filename_is_autonomous_summary_report_md(self, tmp_path):
        """Mutant 164: filename 'autonomous_summary_report.md' → mutated string."""
        features = _features(pass_count=5, pending_count=5)
        prog = _progress(consecutive_failures=5, session_count=5)
        with patch.object(_mod, "get_project_root", return_value=tmp_path), \
             patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "load_feature_list", return_value=self._make_fl(features)):
            report_path = _mod.generate_summary_report()
        assert report_path.endswith("autonomous_summary_report.md")

    def test_pass_count_in_report_matches_features(self, tmp_path):
        """Mutant 171: == 'pass' → != 'pass' in pass_count filter."""
        features = _features(pass_count=7, blocked_count=2, pending_count=1)
        content = self._run(tmp_path, features)
        assert "7" in content   # pass count appears
        assert "Completed" in content

    def test_fail_count_in_report_is_zero_when_none(self, tmp_path):
        """Mutant 172: fail status filter mutation."""
        features = _features(pass_count=8, blocked_count=2)
        content = self._run(tmp_path, features)
        assert "Failed:** 0" in content

    def test_blocked_count_in_report_matches_features(self, tmp_path):
        """Mutant 175-176: blocked status filter mutation."""
        features = _features(pass_count=6, blocked_count=3, pending_count=1)
        content = self._run(tmp_path, features)
        assert "3" in content

    def test_pending_count_in_report_matches_features(self, tmp_path):
        """Mutant 179-180: pending status filter mutation."""
        features = _features(pass_count=6, blocked_count=1, pending_count=3)
        content = self._run(tmp_path, features)
        assert "Pending" in content
        assert "3" in content

    def test_total_features_count_in_report(self, tmp_path):
        """Total features must appear in report."""
        features = _features(pass_count=5, blocked_count=3, pending_count=2)
        content = self._run(tmp_path, features)
        assert "Total Features:** 10" in content

    def test_overall_statistics_heading_in_report(self, tmp_path):
        features = _features(pass_count=5, pending_count=5)
        content = self._run(tmp_path, features)
        assert "Overall Statistics" in content

    def test_circuit_breaker_status_heading_in_report(self, tmp_path):
        features = _features(pass_count=5, pending_count=5)
        content = self._run(tmp_path, features)
        assert "Circuit Breaker Status" in content

    def test_next_steps_heading_in_report(self, tmp_path):
        features = _features(pass_count=5, pending_count=5)
        content = self._run(tmp_path, features)
        assert "Next Steps" in content

    def test_session_history_heading_in_report(self, tmp_path):
        features = _features(pass_count=5, pending_count=5)
        content = self._run(tmp_path, features)
        assert "Session History" in content

    def test_consecutive_failed_sessions_shown_in_report(self, tmp_path):
        """Mutants 228-229: progress.get('consecutive_failed_sessions', 0) key mutation."""
        features = _features(pass_count=5, pending_count=5)
        prog = _progress(consecutive_failures=5, session_count=3)
        with patch.object(_mod, "get_project_root", return_value=tmp_path), \
             patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "load_feature_list", return_value=self._make_fl(features)):
            report_path = _mod.generate_summary_report()
        content = Path(report_path).read_text()
        assert "Consecutive Failed Sessions:** 5" in content

    def test_threshold_value_shown_in_report(self, tmp_path):
        """Mutant 230-231: MAX_CONSECUTIVE_FAILED_SESSIONS in report."""
        features = _features(pass_count=5, pending_count=5)
        content = self._run(tmp_path, features)
        assert "Threshold:** 5" in content

    def test_total_sessions_shown_in_report(self, tmp_path):
        """Mutants 232-233: progress.get('session_count', 0) key mutation."""
        features = _features(pass_count=5, pending_count=5)
        prog = _progress(consecutive_failures=5, session_count=7)
        with patch.object(_mod, "get_project_root", return_value=tmp_path), \
             patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "load_feature_list", return_value=self._make_fl(features)):
            report_path = _mod.generate_summary_report()
        content = Path(report_path).read_text()
        assert "Total Sessions:** 7" in content

    def test_blocked_feature_details_in_report(self, tmp_path):
        """Mutants 237-252: blocked feature loop content mutations."""
        fl = {"features": [
            {"id": "BLOCK_001", "name": "My Blocked Feature", "status": "blocked",
             "category": "Security", "attempts": 3,
             "implementation_notes": "blocked by dep", "last_updated": "2026-01-15"},
            {"id": "P000", "name": "Pass", "status": "pass",
             "category": "CI", "attempts": 1,
             "implementation_notes": "", "last_updated": "2026-01-01"},
        ]}
        prog = _progress(consecutive_failures=5, session_count=5)
        with patch.object(_mod, "get_project_root", return_value=tmp_path), \
             patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "load_feature_list", return_value=fl):
            report_path = _mod.generate_summary_report()
        content = Path(report_path).read_text()
        assert "BLOCK_001" in content
        assert "My Blocked Feature" in content
        assert "Security" in content
        assert "blocked by dep" in content
        assert "2026-01-15" in content

    def test_session_history_session_id_shown(self, tmp_path):
        """Mutants 256-261: session_history loop dict key mutations."""
        features = _features(pass_count=5, pending_count=5)
        prog = _progress(consecutive_failures=5, session_count=2)
        prog["session_history"] = [
            {
                "session_id": 1, "date": "2026-03-01", "success": True,
                "start_passing": 3, "end_passing": 5,
                "completion_rate": 0.50, "blocked_rate": 0.10,
            },
        ]
        with patch.object(_mod, "get_project_root", return_value=tmp_path), \
             patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "load_feature_list", return_value=self._make_fl(features)):
            report_path = _mod.generate_summary_report()
        content = Path(report_path).read_text()
        assert "Session 1" in content
        assert "2026-03-01" in content
        assert "50.0%" in content   # completion_rate rendered as percentage


# ---------------------------------------------------------------------------
# P7-002 (round 3): Second-pass targeted tests for remaining survivors
# ---------------------------------------------------------------------------


class TestCheckCircuitBreakerStatusPassthrough:
    """Kill mutants 74-76: status variable pulled from wrong key returns wrong value."""

    def test_status_from_existing_non_healthy_circuit_breaker(self):
        """If circuit_breaker.status is 'TRIGGERED' and CB not tripped, returns it."""
        prog = _progress(consecutive_failures=2)
        prog["circuit_breaker"]["status"] = "TRIGGERED"
        with patch.object(_mod, "load_session_progress", return_value=prog):
            result = _mod.check_circuit_breaker()
        # Not triggered (2 < 5), so uses status from progress
        assert result["should_terminate"] is False
        assert result["status"] == "TRIGGERED"


class TestCheckCircuitBreakerReasonExactText:
    """Kill mutant 82: reason string has XX prefix — check exact start."""

    def test_reason_starts_with_circuit_breaker_triggered(self):
        prog = _progress(consecutive_failures=5)
        with patch.object(_mod, "load_session_progress", return_value=prog):
            result = _mod.check_circuit_breaker()
        assert result["reason"].startswith("Circuit breaker triggered")


class TestRecordSessionSurvivorDetails:
    """Kill mutants 105, 110, 117-130: edge cases in record_session logic."""

    def _em(self, features):
        return {"features": features}

    def test_last_session_success_becomes_true_when_starting_from_false(self, tmp_path):
        """Mutant 105: 'last_session_success' key mutation in success branch.
        Starting from False ensures the test detects the key change."""
        prog = _progress(consecutive_failures=2)  # last_session_success = False
        assert prog["last_session_success"] is False
        features = _features(pass_count=6, pending_count=4)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({"pass_count": 0}, self._em(features))
        saved = mock_save.call_args[0][0]
        assert saved["last_session_success"] is True

    def test_trigger_reason_contains_completion_rate_text(self, tmp_path):
        """Mutant 130: trigger reason 'Completion rate:...' → 'XX...XX'."""
        prog = _progress(consecutive_failures=0)
        features = _features(pass_count=3, pending_count=7)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({"pass_count": 0}, self._em(features))
        saved = mock_save.call_args[0][0]
        t = saved["circuit_breaker"]["triggers"][0]
        assert "Completion rate" in t["reason"]
        assert "Blocked rate" in t["reason"]

    def test_trigger_init_when_triggers_key_missing(self, tmp_path):
        """Mutants 117-122: init block runs only when 'triggers' key absent."""
        prog = _progress(consecutive_failures=0)
        # Remove 'triggers' key to force the init block to execute
        del prog["circuit_breaker"]["triggers"]
        features = _features(pass_count=3, pending_count=7)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({"pass_count": 0}, self._em(features))
        saved = mock_save.call_args[0][0]
        triggers = saved["circuit_breaker"]["triggers"]
        assert isinstance(triggers, list)
        assert len(triggers) == 1

    def test_existing_triggers_preserved_and_new_appended(self, tmp_path):
        """Mutants 117-118: inverted condition would wipe existing triggers."""
        prog = _progress(consecutive_failures=1)
        prog["circuit_breaker"]["triggers"] = [
            {"session": 1, "timestamp": "2026-01-01", "reason": "old trigger"}
        ]
        features = _features(pass_count=3, pending_count=7)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({"pass_count": 0}, self._em(features))
        saved = mock_save.call_args[0][0]
        triggers = saved["circuit_breaker"]["triggers"]
        # Original trigger preserved + new one appended = 2 triggers
        assert len(triggers) == 2
        assert triggers[0]["reason"] == "old trigger"


class TestGenerateSummaryReportPreciseContent:
    """Kill mutants 176-252: precise format checks for report content."""

    def _make_fl(self, features):
        return {"features": [
            {"id": f["id"], "name": "Feature", "status": f["status"],
             "category": "CI", "attempts": 2,
             "implementation_notes": "detail", "last_updated": "2026-02-15"}
            for f in features
        ]}

    def _run(self, tmp_path, features, prog=None, fl=None):
        if prog is None:
            prog = _progress(consecutive_failures=5, session_count=5)
        if fl is None:
            fl = self._make_fl(features)
        with patch.object(_mod, "get_project_root", return_value=tmp_path), \
             patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "load_feature_list", return_value=fl):
            report_path = _mod.generate_summary_report()
        return Path(report_path).read_text()

    def test_fail_count_nonzero_in_report(self, tmp_path):
        """Mutant 176: fail filter uses 'XXfailXX' — count would be 0 instead of 2."""
        features = _features(pass_count=6, fail_count=2, pending_count=2)
        content = self._run(tmp_path, features)
        assert "Failed:** 2" in content

    def test_blocked_count_exact_format_in_report(self, tmp_path):
        """Mutants 179-180: blocked filter inverted/wrong-string — count wrong."""
        features = _features(pass_count=6, blocked_count=3, pending_count=1)
        content = self._run(tmp_path, features)
        assert "Blocked:** 3" in content

    def test_pending_count_exact_format_in_report(self, tmp_path):
        """Mutants 183-184: pending filter inverted/wrong-string — count wrong."""
        features = _features(pass_count=6, blocked_count=1, pending_count=3)
        content = self._run(tmp_path, features)
        assert "Pending:** 3" in content

    def test_pass_percentage_exact_format(self, tmp_path):
        """Mutants 191-193: pass_count/total*100 vs pass_count*total*100 etc."""
        # 7 pass out of 10 = 70.0%
        features = _features(pass_count=7, blocked_count=2, pending_count=1)
        content = self._run(tmp_path, features)
        assert "70.0%" in content

    def test_blocked_percentage_exact_format(self, tmp_path):
        """Mutants 194-196: blocked_count/total*100 mutated."""
        features = _features(pass_count=7, blocked_count=2, pending_count=1)
        content = self._run(tmp_path, features)
        assert "20.0%" in content

    def test_fail_percentage_exact_format(self, tmp_path):
        """Mutants 197-199: fail_count/total*100 mutated."""
        features = _features(pass_count=6, fail_count=2, blocked_count=1, pending_count=1)
        content = self._run(tmp_path, features)
        assert "20.0%" in content  # fail 2/10

    def test_pending_percentage_exact_format(self, tmp_path):
        """Mutants 200-202: pending_count/total*100 mutated."""
        features = _features(pass_count=7, blocked_count=2, pending_count=1)
        content = self._run(tmp_path, features)
        assert "10.0%" in content  # 1/10 pending

    def test_report_starts_with_autonomous_heading(self, tmp_path):
        """Mutant 207: report f-string starts with 'XX#...'."""
        features = _features(pass_count=5, pending_count=5)
        content = self._run(tmp_path, features)
        assert content.startswith("# Autonomous Implementation Summary Report")

    def test_blocked_feature_hash_heading_format(self, tmp_path):
        """Mutant 220: blocked feature loop uses '### ' heading."""
        fl = {"features": [
            {"id": "BLK_001", "name": "Hard Feature", "status": "blocked",
             "category": "DevOps", "attempts": 3,
             "implementation_notes": "complex dep", "last_updated": "2026-02-01"},
        ]}
        prog = _progress(consecutive_failures=5, session_count=5)
        content = self._run(tmp_path, _features(), prog=prog, fl=fl)
        assert "### BLK_001: Hard Feature" in content

    def test_no_blocked_features_message_not_xx_prefixed(self, tmp_path):
        """Mutant 223: 'No blocked features.' becomes 'XXNo blocked features.'."""
        features = _features(pass_count=10)
        content = self._run(tmp_path, features)
        # Must start exactly at a line boundary, not with XX prefix
        assert "No blocked features." in content
        assert "XXNo blocked features." not in content

    def test_session_history_success_emoji(self, tmp_path):
        """Mutants 229-233: ✅ emoji mutated or logic inverted."""
        features = _features(pass_count=5, pending_count=5)
        prog = _progress(consecutive_failures=5, session_count=1)
        prog["session_history"] = [
            {"session_id": 1, "date": "2026-03-01", "success": True,
             "start_passing": 3, "end_passing": 5,
             "completion_rate": 0.50, "blocked_rate": 0.00},
        ]
        content = self._run(tmp_path, features, prog=prog)
        assert "✅" in content  # successful session shows green checkmark

    def test_session_history_failure_emoji(self, tmp_path):
        """Mutant 232: ❌ becomes 'XX❌XX'."""
        features = _features(pass_count=5, pending_count=5)
        prog = _progress(consecutive_failures=5, session_count=1)
        prog["session_history"] = [
            {"session_id": 1, "date": "2026-03-01", "success": False,
             "start_passing": 2, "end_passing": 3,
             "completion_rate": 0.30, "blocked_rate": 0.05},
        ]
        content = self._run(tmp_path, features, prog=prog)
        assert "❌" in content  # failed session shows red X

    def test_session_history_passing_range_format(self, tmp_path):
        """Mutants 240-243: start_passing/end_passing key or default mutations."""
        features = _features(pass_count=5, pending_count=5)
        prog = _progress(consecutive_failures=5, session_count=1)
        prog["session_history"] = [
            {"session_id": 1, "date": "2026-03-01", "success": True,
             "start_passing": 3, "end_passing": 7,
             "completion_rate": 0.70, "blocked_rate": 0.05},
        ]
        content = self._run(tmp_path, features, prog=prog)
        assert "3 → 7" in content

    def test_session_history_completion_percentage_format(self, tmp_path):
        """Mutants 244-247: completion_rate*100 vs *101 etc."""
        features = _features(pass_count=5, pending_count=5)
        prog = _progress(consecutive_failures=5, session_count=1)
        prog["session_history"] = [
            {"session_id": 1, "date": "2026-03-01", "success": True,
             "start_passing": 3, "end_passing": 7,
             "completion_rate": 0.70, "blocked_rate": 0.05},
        ]
        content = self._run(tmp_path, features, prog=prog)
        assert "Completion: 70.0%" in content

    def test_session_history_blocked_percentage_format(self, tmp_path):
        """Mutants 248-251: blocked_rate*100 vs *101 etc."""
        features = _features(pass_count=5, pending_count=5)
        prog = _progress(consecutive_failures=5, session_count=1)
        prog["session_history"] = [
            {"session_id": 1, "date": "2026-03-01", "success": True,
             "start_passing": 3, "end_passing": 7,
             "completion_rate": 0.70, "blocked_rate": 0.15},
        ]
        content = self._run(tmp_path, features, prog=prog)
        assert "Blocked: 15.0%" in content

    def test_session_history_bold_session_format(self, tmp_path):
        """Mutants 237, 239, 252: '- **Session N**' line format."""
        features = _features(pass_count=5, pending_count=5)
        prog = _progress(consecutive_failures=5, session_count=1)
        prog["session_history"] = [
            {"session_id": 3, "date": "2026-03-15", "success": True,
             "start_passing": 2, "end_passing": 5,
             "completion_rate": 0.50, "blocked_rate": 0.00},
        ]
        content = self._run(tmp_path, features, prog=prog)
        assert "- **Session 3**" in content
        assert "2026-03-15" in content


# ---------------------------------------------------------------------------
# P7-002 (round 4): Final 12-mutant kill sweep to reach ≥85%
# ---------------------------------------------------------------------------


class TestFinalMutantKills:
    """Precision tests to kill the last killable surviving mutants."""

    # --- record_session edge cases ---

    def _em(self, features):
        return {"features": features}

    def test_session_num_when_session_count_key_absent(self, tmp_path):
        """Mutant 95: progress.get('session_count', 1) default vs 0.
        Without the key: original returns 1, mutant returns 2."""
        prog = {"consecutive_failed_sessions": 0, "last_session_success": True,
                "session_history": [], "circuit_breaker": {"status": "HEALTHY",
                "threshold": 5, "triggers": []}, "last_updated": "2026-01-01"}
        # No 'session_count' key — default is used
        features = _features(pass_count=6, pending_count=4)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            result = _mod.record_session({}, self._em(features))
        assert result["session_num"] == 1
        assert mock_save.call_args[0][0]["session_count"] == 1

    def test_start_passing_zero_when_key_absent_in_start_metrics(self, tmp_path):
        """Mutant 136: start_metrics.get('pass_count', 0) default vs 1.
        Empty start_metrics: original gives start_passing=0, mutant gives 1."""
        prog = _progress(consecutive_failures=0)
        features = _features(pass_count=6, pending_count=4)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({}, self._em(features))  # empty start_metrics
        entry = mock_save.call_args[0][0]["session_history"][0]
        assert entry["start_passing"] == 0  # default 0, not 1

    def test_trigger_reason_starts_with_completion_rate(self, tmp_path):
        """Mutant 130: reason starts with 'XXCompletion rate...' — check exact start."""
        prog = _progress(consecutive_failures=0)
        features = _features(pass_count=3, pending_count=7)
        with patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "save_session_progress") as mock_save:
            _mod.record_session({"pass_count": 0}, self._em(features))
        t = mock_save.call_args[0][0]["circuit_breaker"]["triggers"][0]
        assert t["reason"].startswith("Completion rate")

    # --- check_circuit_breaker status default ---

    def test_status_default_healthy_when_status_key_absent(self):
        """Mutant 76: default 'XXHEALTHYXX' vs 'HEALTHY' when 'status' key missing."""
        prog = _progress(consecutive_failures=2)
        del prog["circuit_breaker"]["status"]  # remove "status" key
        with patch.object(_mod, "load_session_progress", return_value=prog):
            result = _mod.check_circuit_breaker()
        assert result["status"] == "HEALTHY"  # must use default, not "XXHEALTHYXX"

    # --- generate_summary_report precise format ---

    def _make_fl(self, features):
        return {"features": [
            {"id": f["id"], "name": "Feature", "status": f["status"],
             "category": "CI", "attempts": 2,
             "implementation_notes": "detail", "last_updated": "2026-02-15"}
            for f in features
        ]}

    def _run(self, tmp_path, features, prog=None, fl=None):
        if prog is None:
            prog = _progress(consecutive_failures=5, session_count=5)
        if fl is None:
            fl = self._make_fl(features)
        with patch.object(_mod, "get_project_root", return_value=tmp_path), \
             patch.object(_mod, "load_session_progress", return_value=prog), \
             patch.object(_mod, "load_feature_list", return_value=fl):
            report_path = _mod.generate_summary_report()
        return Path(report_path).read_text()

    def test_generated_date_ends_with_utc_newline(self, tmp_path):
        """Mutant 190: strftime 'XX%Y-%m-%d ... UTCXX' — 'UTC\\n' absent in mutant."""
        features = _features(pass_count=5, pending_count=5)
        content = self._run(tmp_path, features)
        assert "UTC\n" in content  # original ends with ' UTC\n', mutant ends with 'UTCXX\n'

    def test_blocked_feature_attempts_count_in_report(self, tmp_path):
        """Mutant 214: feature.get('XXattemptsXX', 0) — always 0, never 2."""
        fl = {"features": [
            {"id": "BLK_001", "name": "Hard Feature", "status": "blocked",
             "category": "DevOps", "attempts": 2,
             "implementation_notes": "dep missing", "last_updated": "2026-02-01"},
        ]}
        prog = _progress(consecutive_failures=5, session_count=5)
        content = self._run(tmp_path, _features(), prog=prog, fl=fl)
        assert "Attempts:** 2" in content  # mutant would show "Attempts:** 0"

    def test_blocked_feature_heading_not_xx_prefixed(self, tmp_path):
        """Mutant 220: '### heading' becomes 'XX### heading' — check newline prefix."""
        fl = {"features": [
            {"id": "BLK_001", "name": "Hard Feature", "status": "blocked",
             "category": "DevOps", "attempts": 1,
             "implementation_notes": "detail", "last_updated": "2026-02-01"},
        ]}
        prog = _progress(consecutive_failures=5, session_count=5)
        content = self._run(tmp_path, _features(), prog=prog, fl=fl)
        assert "\n### BLK_001" in content  # '\n###' not '\nXX###'

    def test_session_history_success_emoji_followed_by_newline(self, tmp_path):
        """Mutant 229: ✅ → 'XX✅XX' — '✅\\n' absent in mutant."""
        features = _features(pass_count=5, pending_count=5)
        prog = _progress(consecutive_failures=5, session_count=1)
        prog["session_history"] = [
            {"session_id": 1, "date": "2026-03-01", "success": True,
             "start_passing": 3, "end_passing": 5,
             "completion_rate": 0.50, "blocked_rate": 0.00},
        ]
        content = self._run(tmp_path, features, prog=prog)
        assert "✅\n" in content  # ✅ immediately followed by newline

    def test_session_history_failure_emoji_followed_by_newline(self, tmp_path):
        """Mutant 232: ❌ → 'XX❌XX' — '❌\\n' absent in mutant."""
        features = _features(pass_count=5, pending_count=5)
        prog = _progress(consecutive_failures=5, session_count=1)
        prog["session_history"] = [
            {"session_id": 1, "date": "2026-03-01", "success": False,
             "start_passing": 2, "end_passing": 3,
             "completion_rate": 0.30, "blocked_rate": 0.05},
        ]
        content = self._run(tmp_path, features, prog=prog)
        assert "❌\n" in content  # ❌ immediately followed by newline

    def test_session_history_line_starts_with_dash_not_xx(self, tmp_path):
        """Mutant 252: '- **Session...' becomes 'XX- **Session...' — check '\\n- **'."""
        features = _features(pass_count=5, pending_count=5)
        prog = _progress(consecutive_failures=5, session_count=1)
        prog["session_history"] = [
            {"session_id": 5, "date": "2026-03-20", "success": True,
             "start_passing": 2, "end_passing": 5,
             "completion_rate": 0.50, "blocked_rate": 0.00},
        ]
        content = self._run(tmp_path, features, prog=prog)
        assert "\n- **Session 5**" in content  # '\n-' not '\nXX-'

    def test_session_id_default_na_not_xx_na_xx(self, tmp_path):
        """Mutant 237: session_id default 'XXN/AXX' vs 'N/A' — test with missing key."""
        features = _features(pass_count=5, pending_count=5)
        prog = _progress(consecutive_failures=5, session_count=1)
        prog["session_history"] = [
            {"date": "2026-03-01", "success": True,  # no session_id key
             "start_passing": 3, "end_passing": 5,
             "completion_rate": 0.50, "blocked_rate": 0.00},
        ]
        content = self._run(tmp_path, features, prog=prog)
        assert "Session N/A" in content  # original default 'N/A', not 'XXN/AXX'

    def test_session_date_default_na_not_xx_na_xx(self, tmp_path):
        """Mutant 239: date default 'XXN/AXX' vs 'N/A' — test with missing key."""
        features = _features(pass_count=5, pending_count=5)
        prog = _progress(consecutive_failures=5, session_count=1)
        prog["session_history"] = [
            {"session_id": 1, "success": True,  # no date key
             "start_passing": 3, "end_passing": 5,
             "completion_rate": 0.50, "blocked_rate": 0.00},
        ]
        content = self._run(tmp_path, features, prog=prog)
        assert "(N/A)" in content  # original default 'N/A', not 'XXN/AXX'


# ---------------------------------------------------------------------------
# HIGH-005: generate_summary_report handles missing feature_list.json
# ---------------------------------------------------------------------------


class TestGenerateSummaryReportWithoutFeatureList:
    """HIGH-005: generate_summary_report must not raise when feature_list.json is missing."""

    def test_generate_summary_report_without_feature_list(self, tmp_path):
        """HIGH-005: generate_summary_report must not raise when feature_list.json missing."""
        # tmp_path has session_progress.json but NO feature_list.json
        with patch.object(_mod, "get_project_root", return_value=tmp_path):
            with patch.object(_mod, "load_session_progress", return_value={
                "session_count": 1, "consecutive_failed_sessions": 0,
                "last_session_success": True, "session_history": [],
                "circuit_breaker": {"status": "HEALTHY", "threshold": 5, "triggers": []}
            }):
                result = _mod.generate_summary_report()
        assert result is not None
        report_file = tmp_path / "autonomous_summary_report.md"
        assert report_file.exists()

    def test_report_total_is_zero_when_feature_list_missing(self, tmp_path):
        """HIGH-005: When feature_list.json is missing, total=0 and no division by zero."""
        with patch.object(_mod, "get_project_root", return_value=tmp_path):
            with patch.object(_mod, "load_session_progress", return_value={
                "session_count": 0, "consecutive_failed_sessions": 0,
                "last_session_success": True, "session_history": [],
                "circuit_breaker": {"status": "HEALTHY", "threshold": 5, "triggers": []}
            }):
                result = _mod.generate_summary_report()
        content = (tmp_path / "autonomous_summary_report.md").read_text()
        assert "Total Features:** 0" in content
        # Percentages should be 0.0% not raise ZeroDivisionError
        assert "0.0%" in content

    def test_load_feature_list_returns_empty_when_file_missing(self, tmp_path):
        """HIGH-005: load_feature_list returns {'features': []} when file absent."""
        with patch.object(_mod, "get_project_root", return_value=tmp_path):
            result = _mod.load_feature_list()
        assert result == {"features": []}

    def test_load_feature_list_returns_empty_on_invalid_json(self, tmp_path):
        """HIGH-005: load_feature_list returns {'features': []} on malformed JSON."""
        bad_json = tmp_path / "feature_list.json"
        bad_json.write_text("{ not valid json }")
        with patch.object(_mod, "get_project_root", return_value=tmp_path):
            result = _mod.load_feature_list()
        assert result == {"features": []}
