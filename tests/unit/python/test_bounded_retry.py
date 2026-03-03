"""
P1-001: Unit tests for scripts/bounded_retry.py
Requirement: FR-7.2 — 3-attempt retry strategy with blocking and failure logging.
"""

import importlib.util
import json
import sys
import tempfile
from pathlib import Path
from unittest.mock import MagicMock, patch, call

import pytest

# ---------------------------------------------------------------------------
# Load module under test
# ---------------------------------------------------------------------------
_SCRIPT = Path(__file__).parents[3] / "scripts" / "bounded_retry.py"
_spec = importlib.util.spec_from_file_location("bounded_retry", _SCRIPT)
_mod = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_mod)


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

def _feature(feature_id="FEATURE_001", status="pending", attempts=0):
    return {
        "id": feature_id,
        "name": "Test Feature",
        "status": status,
        "attempts": attempts,
        "implementation_notes": "",
        "blocked_reason": "",
    }


def _feature_list(features):
    return {"features": features}


# ---------------------------------------------------------------------------
# TestExecuteWithTimeout
# ---------------------------------------------------------------------------

class TestExecuteWithTimeout:
    """execute_with_timeout() wraps subprocess with a timeout."""

    def test_success_returns_zero_exit(self):
        code, out, err = _mod.execute_with_timeout("exit 0", 10)
        assert code == 0

    def test_failure_returns_nonzero_exit(self):
        code, out, err = _mod.execute_with_timeout("exit 1", 10)
        assert code == 1

    def test_stdout_captured(self):
        code, out, err = _mod.execute_with_timeout("echo hello", 10)
        assert code == 0
        assert "hello" in out

    def test_timeout_returns_minus_one(self):
        code, out, err = _mod.execute_with_timeout("sleep 60", timeout=1)
        assert code == -1
        assert "Timeout" in err or "timeout" in err.lower()


# ---------------------------------------------------------------------------
# TestUpdateFeatureStatus
# ---------------------------------------------------------------------------

class TestUpdateFeatureStatus:
    """update_feature_status() modifies the in-memory feature_list.json."""

    def test_updates_status_to_pass(self):
        fl = _feature_list([_feature()])
        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list") as mock_save:
            _mod.update_feature_status("FEATURE_001", "pass", 1)
            saved = mock_save.call_args[0][0]
            feat = saved["features"][0]
            assert feat["status"] == "pass"
            assert feat["attempts"] == 1

    def test_appends_error_to_implementation_notes(self):
        fl = _feature_list([_feature()])
        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list") as mock_save:
            _mod.update_feature_status("FEATURE_001", "fail", 1, "something broke")
            saved = mock_save.call_args[0][0]
            feat = saved["features"][0]
            assert "something broke" in feat["implementation_notes"]

    def test_sets_blocked_reason_when_blocked(self):
        fl = _feature_list([_feature()])
        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list") as mock_save:
            _mod.update_feature_status("FEATURE_001", "blocked", 3, "all failed")
            saved = mock_save.call_args[0][0]
            feat = saved["features"][0]
            assert feat["blocked_reason"] != ""
            assert "3" in feat["blocked_reason"]

    def test_unknown_feature_id_does_not_crash(self):
        fl = _feature_list([_feature("FEATURE_001")])
        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list"):
            # Should not raise — just finds no match and saves unchanged
            _mod.update_feature_status("FEATURE_999", "pass", 1)


# ---------------------------------------------------------------------------
# TestBoundedRetryLogic
# ---------------------------------------------------------------------------

class TestBoundedRetryLogic:
    """bounded_retry() implements the 3-attempt loop with status transitions."""

    def _run(self, feature, side_effects):
        """
        Run bounded_retry with mocked file I/O and subprocess.
        side_effects: list of return codes for each execute_with_timeout call.
        """
        fl = _feature_list([feature.copy()])
        saved_states = []

        def fake_save(data):
            saved_states.append(json.loads(json.dumps(data)))

        return_codes = iter(side_effects)

        def fake_execute(cmd, timeout):
            code = next(return_codes, 1)
            if code == 0:
                return (0, "ok", "")
            return (1, "", "error")

        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list", side_effect=fake_save), \
             patch.object(_mod, "log_attempt"), \
             patch.object(_mod, "execute_with_timeout", side_effect=fake_execute):
            result = _mod.bounded_retry("FEATURE_001", "/fake/script.sh")

        return result, saved_states

    def test_already_blocked_returns_false_immediately(self):
        feat = _feature(status="blocked")
        fl = _feature_list([feat])
        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list"):
            result = _mod.bounded_retry("FEATURE_001", "/fake/script.sh")
        assert result is False

    def test_already_passed_returns_true_immediately(self):
        feat = _feature(status="pass")
        fl = _feature_list([feat])
        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list"):
            result = _mod.bounded_retry("FEATURE_001", "/fake/script.sh")
        assert result is True

    def test_feature_not_found_returns_false(self):
        fl = _feature_list([_feature("FEATURE_002")])
        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list"):
            result = _mod.bounded_retry("FEATURE_001", "/fake/script.sh")
        assert result is False

    def test_succeeds_on_attempt_1(self):
        result, states = self._run(_feature(), side_effects=[0])
        assert result is True
        # Final save should have status='pass'
        final = states[-1]["features"][0]
        assert final["status"] == "pass"

    def test_fails_attempt_1_succeeds_attempt_2(self):
        result, states = self._run(_feature(), side_effects=[1, 0])
        assert result is True
        final = states[-1]["features"][0]
        assert final["status"] == "pass"

    def test_fails_attempt_1_and_2_succeeds_attempt_3(self):
        result, states = self._run(_feature(), side_effects=[1, 1, 0])
        assert result is True
        final = states[-1]["features"][0]
        assert final["status"] == "pass"

    def test_fails_all_3_attempts_returns_false(self):
        result, states = self._run(_feature(), side_effects=[1, 1, 1])
        assert result is False
        final = states[-1]["features"][0]
        assert final["status"] == "blocked"

    def test_blocked_after_max_attempts_sets_blocked_reason(self):
        result, states = self._run(_feature(), side_effects=[1, 1, 1])
        final = states[-1]["features"][0]
        assert final["blocked_reason"] != ""

    def test_max_attempts_is_3(self):
        """Verify MAX_ATTEMPTS constant — changing it would be a spec violation."""
        assert _mod.MAX_ATTEMPTS == 3

    def test_approaches_are_standard_simplified_minimal(self):
        assert _mod.APPROACHES[1] == "STANDARD"
        assert _mod.APPROACHES[2] == "SIMPLIFIED"
        assert _mod.APPROACHES[3] == "MINIMAL"

    def test_timeout_is_30_minutes(self):
        assert _mod.TIMEOUT_SECONDS == 1800

    def test_timeout_treated_as_failure(self):
        """A timed-out command (-1 exit code) is treated as a failed attempt."""
        fl = _feature_list([_feature()])
        saved_states = []

        def fake_save(data):
            saved_states.append(json.loads(json.dumps(data)))

        def fake_execute(cmd, timeout):
            return (-1, "", "Timeout after 1800 seconds")

        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list", side_effect=fake_save), \
             patch.object(_mod, "log_attempt"), \
             patch.object(_mod, "execute_with_timeout", side_effect=fake_execute):
            result = _mod.bounded_retry("FEATURE_001", "/fake/script.sh")

        assert result is False
        final = saved_states[-1]["features"][0]
        assert final["status"] == "blocked"

    def test_resumes_from_existing_attempt_count(self):
        """If attempts=1 already, only attempts 2 and 3 are run."""
        feat = _feature(status="pending", attempts=1)
        execute_calls = []

        fl = _feature_list([feat.copy()])

        def fake_execute(cmd, timeout):
            execute_calls.append(cmd)
            return (1, "", "error")

        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list"), \
             patch.object(_mod, "log_attempt"), \
             patch.object(_mod, "execute_with_timeout", side_effect=fake_execute):
            _mod.bounded_retry("FEATURE_001", "/fake/script.sh")

        # Should only have run attempts 2 and 3
        assert len(execute_calls) == 2
