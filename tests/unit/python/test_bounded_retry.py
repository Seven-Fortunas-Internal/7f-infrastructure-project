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
             patch.object(_mod, "save_feature_list"), \
             patch.object(_mod, "execute_with_timeout") as mock_exec:
            result = _mod.bounded_retry("FEATURE_001", "/fake/script.sh")
        assert result is False
        mock_exec.assert_not_called()  # must short-circuit, not enter retry loop

    def test_already_passed_returns_true_immediately(self):
        feat = _feature(status="pass")
        fl = _feature_list([feat])
        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list"), \
             patch.object(_mod, "execute_with_timeout") as mock_exec:
            result = _mod.bounded_retry("FEATURE_001", "/fake/script.sh")
        assert result is True
        mock_exec.assert_not_called()  # must short-circuit, not enter retry loop

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

    def test_already_blocked_prints_blocked_message(self, capsys):
        """The 'already blocked' print contains feature ID and no mutation prefix."""
        feat = _feature(status="blocked")
        fl = _feature_list([feat])
        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list"), \
             patch.object(_mod, "execute_with_timeout"):
            _mod.bounded_retry("FEATURE_001", "/fake/script.sh")
        out = capsys.readouterr().out
        assert "FEATURE_001" in out
        assert "XX" not in out

    def test_already_passed_prints_pass_message(self, capsys):
        """The 'already passed' print message contains the feature ID — no mutation prefix."""
        feat = _feature(status="pass")
        fl = _feature_list([feat])
        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list"), \
             patch.object(_mod, "execute_with_timeout"):
            _mod.bounded_retry("FEATURE_001", "/fake/script.sh")
        out = capsys.readouterr().out
        assert "FEATURE_001" in out
        assert "XX" not in out

    def test_success_prints_pass_message(self, capsys):
        """Successful attempt prints feature ID and 'PASSED' — no mutation prefix."""
        result, _ = self._run(_feature(), side_effects=[0])
        out = capsys.readouterr().out
        assert "FEATURE_001" in out
        assert "PASSED" in out
        assert "XX" not in out

    def test_failure_prints_fail_message(self, capsys):
        """Failed attempt prints 'FAILED' and 'BLOCKED' — no mutation prefix."""
        self._run(_feature(), side_effects=[1, 1, 1])
        out = capsys.readouterr().out
        assert "FAILED" in out
        assert "BLOCKED" in out
        assert "XX" not in out

    def test_blocked_after_max_attempts_log_attempt_called_with_blocked(self):
        """log_attempt is called with 'BLOCKED' approach AND 'BLOCKED' result on final failure."""
        mock_log = MagicMock()
        fl = _feature_list([_feature()])

        def fake_execute(cmd, timeout):
            return (1, "", "error")

        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list"), \
             patch.object(_mod, "log_attempt", side_effect=mock_log), \
             patch.object(_mod, "execute_with_timeout", side_effect=fake_execute):
            _mod.bounded_retry("FEATURE_001", "/fake/script.sh")

        # Find the call that used 'BLOCKED' as the approach
        blocked_calls = [c for c in mock_log.call_args_list if c.args[2] == "BLOCKED"]
        assert len(blocked_calls) == 1, "Expected exactly one BLOCKED approach call"
        # That call must also use 'BLOCKED' as the result (4th arg, index 3)
        assert blocked_calls[0].args[3] == "BLOCKED"

    def test_success_log_attempt_called_with_pass_result(self):
        """log_attempt is called with 'PASS' as result arg on success."""
        mock_log = MagicMock()
        fl = _feature_list([_feature()])

        def fake_execute(cmd, timeout):
            return (0, "ok", "")

        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list"), \
             patch.object(_mod, "log_attempt", side_effect=mock_log), \
             patch.object(_mod, "execute_with_timeout", side_effect=fake_execute):
            _mod.bounded_retry("FEATURE_001", "/fake/script.sh")

        # The single log call must have 'PASS' as the result (4th positional arg)
        assert mock_log.call_count == 1
        assert mock_log.call_args.args[3] == "PASS"

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


# ---------------------------------------------------------------------------
# TestLogAttempt (WC-004 mutation kills)
# ---------------------------------------------------------------------------

class TestLogAttempt:
    """Tests that exercise log_attempt directly to kill string-mutation survivors."""

    def test_log_attempt_writes_to_file(self, tmp_path):
        """log_attempt appends to autonomous_build_log.md."""
        log_file = tmp_path / "autonomous_build_log.md"
        with patch("builtins.open", create=True) as mock_open:
            mock_open.return_value.__enter__ = lambda s: s
            mock_open.return_value.__exit__ = MagicMock(return_value=False)
            mock_open.return_value.write = MagicMock()
            _mod.log_attempt("FEATURE_001", 1, "STANDARD", "PASS")
            assert mock_open.called
            # Should open in append mode
            call_args = mock_open.call_args
            assert call_args[0][0] == "autonomous_build_log.md"
            assert call_args[0][1] == "a"

    def test_log_attempt_written_content_contains_feature_id(self, tmp_path, monkeypatch):
        """The feature ID appears in the log entry written to disk."""
        monkeypatch.chdir(tmp_path)
        _mod.log_attempt("FEATURE_099", 2, "SIMPLIFIED", "FAIL")
        content = (tmp_path / "autonomous_build_log.md").read_text()
        assert "FEATURE_099" in content

    def test_log_attempt_written_content_contains_approach(self, tmp_path, monkeypatch):
        monkeypatch.chdir(tmp_path)
        _mod.log_attempt("FEATURE_001", 3, "MINIMAL", "FAIL")
        content = (tmp_path / "autonomous_build_log.md").read_text()
        assert "MINIMAL" in content

    def test_log_attempt_written_content_contains_result(self, tmp_path, monkeypatch):
        monkeypatch.chdir(tmp_path)
        _mod.log_attempt("FEATURE_001", 1, "STANDARD", "PASS")
        content = (tmp_path / "autonomous_build_log.md").read_text()
        assert "PASS" in content

    def test_log_attempt_written_content_contains_attempt_number(self, tmp_path, monkeypatch):
        monkeypatch.chdir(tmp_path)
        _mod.log_attempt("FEATURE_001", 2, "SIMPLIFIED", "FAIL")
        content = (tmp_path / "autonomous_build_log.md").read_text()
        assert "2" in content

    def test_log_attempt_with_error_msg_includes_error(self, tmp_path, monkeypatch):
        """When error_msg is provided it appears with **Error:** label (not XX**Error:**)."""
        monkeypatch.chdir(tmp_path)
        _mod.log_attempt("FEATURE_001", 1, "STANDARD", "FAIL", "something exploded")
        content = (tmp_path / "autonomous_build_log.md").read_text()
        assert "something exploded" in content
        assert "**Error:** something exploded" in content  # exact format, no XX prefix

    def test_log_attempt_without_error_no_error_section(self, tmp_path, monkeypatch):
        """When error_msg is None, no Error: line is added."""
        monkeypatch.chdir(tmp_path)
        _mod.log_attempt("FEATURE_001", 1, "STANDARD", "PASS", None)
        content = (tmp_path / "autonomous_build_log.md").read_text()
        assert "Error:" not in content

    def test_log_attempt_appends_not_overwrites(self, tmp_path, monkeypatch):
        """Multiple calls append to the same file — prior content is preserved."""
        monkeypatch.chdir(tmp_path)
        _mod.log_attempt("FEATURE_001", 1, "STANDARD", "FAIL", "err1")
        _mod.log_attempt("FEATURE_001", 2, "SIMPLIFIED", "PASS")
        content = (tmp_path / "autonomous_build_log.md").read_text()
        assert "err1" in content
        assert "FAIL" in content
        assert "PASS" in content

    def test_log_attempt_separator_present(self, tmp_path, monkeypatch):
        """The log entry ends with a --- separator."""
        monkeypatch.chdir(tmp_path)
        _mod.log_attempt("FEATURE_001", 1, "STANDARD", "PASS")
        content = (tmp_path / "autonomous_build_log.md").read_text()
        assert "---" in content

    def test_log_attempt_contains_timestamp(self, tmp_path, monkeypatch):
        """The log entry contains a formatted timestamp (year portion)."""
        from datetime import datetime, timezone
        monkeypatch.chdir(tmp_path)
        _mod.log_attempt("FEATURE_001", 1, "STANDARD", "PASS")
        content = (tmp_path / "autonomous_build_log.md").read_text()
        # log_attempt uses datetime.now(timezone.utc) — check year appears in content
        year = datetime.now(timezone.utc).strftime('%Y')
        assert year in content


# ---------------------------------------------------------------------------
# TestUpdateFeatureStatusEdgeCases (kills surviving mutations in 45-56 range)
# ---------------------------------------------------------------------------

class TestUpdateFeatureStatusEdgeCases:
    """Additional update_feature_status tests to kill mutation survivors."""

    def test_appends_to_existing_implementation_notes(self):
        """Lines 56-57: existing notes are appended to, not replaced."""
        feat = _feature()
        feat["implementation_notes"] = "Previous note"
        fl = _feature_list([feat])
        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list") as mock_save:
            _mod.update_feature_status("FEATURE_001", "fail", 2, "new error")
            saved = mock_save.call_args[0][0]
            notes = saved["features"][0]["implementation_notes"]
            assert "Previous note" in notes
            assert "new error" in notes

    def test_blocked_reason_contains_attempt_count(self):
        """The blocked_reason string includes the attempt count as a number."""
        fl = _feature_list([_feature()])
        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list") as mock_save:
            _mod.update_feature_status("FEATURE_001", "blocked", 3)
            saved = mock_save.call_args[0][0]
            reason = saved["features"][0]["blocked_reason"]
            assert "3" in reason

    def test_non_blocked_status_does_not_set_blocked_reason(self):
        """blocked_reason is only set when status == 'blocked'."""
        fl = _feature_list([_feature()])
        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list") as mock_save:
            _mod.update_feature_status("FEATURE_001", "pass", 1)
            saved = mock_save.call_args[0][0]
            # blocked_reason must remain empty string (not set for pass)
            assert saved["features"][0]["blocked_reason"] == ""

    def test_last_updated_field_is_set(self):
        """last_updated is in ISO 8601 format: starts with YYYY (digits only, no XX prefix)."""
        fl = _feature_list([_feature()])
        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list") as mock_save:
            _mod.update_feature_status("FEATURE_001", "pass", 1)
            saved = mock_save.call_args[0][0]
            ts = saved["features"][0]["last_updated"]
            assert ts != ""
            assert ts[:4].isdigit()  # must start with year digits, not XX

    def test_implementation_notes_error_msg_format(self):
        """Error message in notes begins with '\n\nAttempt N failed: msg' (no XX prefix)."""
        fl = _feature_list([_feature()])
        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list") as mock_save:
            _mod.update_feature_status("FEATURE_001", "fail", 2, "disk full")
            saved = mock_save.call_args[0][0]
            notes = saved["features"][0]["implementation_notes"]
            assert "Attempt 2 failed" in notes
            assert "disk full" in notes
            assert notes.startswith("Attempt")  # no XX prefix for new notes

    def test_blocked_reason_starts_with_failed(self):
        """blocked_reason begins with 'Failed after' (no XX prefix)."""
        fl = _feature_list([_feature()])
        with patch.object(_mod, "load_feature_list", return_value=fl), \
             patch.object(_mod, "save_feature_list") as mock_save:
            _mod.update_feature_status("FEATURE_001", "blocked", 3)
            saved = mock_save.call_args[0][0]
            reason = saved["features"][0]["blocked_reason"]
            assert reason.startswith("Failed after")


# ---------------------------------------------------------------------------
# TestExecuteWithTimeoutDetails (kills mutations in 93-111 range)
# ---------------------------------------------------------------------------

class TestExecuteWithTimeoutDetails:
    """Additional execute_with_timeout tests for mutation coverage."""

    def test_stderr_captured_on_failure(self):
        code, out, err = _mod.execute_with_timeout("echo errout >&2; exit 1", 10)
        assert code == 1
        assert "errout" in err

    def test_timeout_stdout_is_empty(self):
        code, out, err = _mod.execute_with_timeout("sleep 60", timeout=1)
        assert code == -1
        assert out == ""

    def test_timeout_message_contains_seconds(self):
        code, out, err = _mod.execute_with_timeout("sleep 60", timeout=1)
        assert err.startswith("Timeout")  # must begin with Timeout, not XX/garbage
        assert "1" in err  # timeout value appears in message

    def test_exception_returns_minus_one(self):
        """A non-timeout exception in subprocess.run → returns -1 (not +1)."""
        with patch("subprocess.run", side_effect=OSError("mock OS error")):
            code, out, err = _mod.execute_with_timeout("anything", 10)
        assert code == -1  # must be exactly -1, not +1

    def test_success_stdout_returned(self):
        code, out, err = _mod.execute_with_timeout("printf 'specific_output'", 10)
        assert "specific_output" in out


# ---------------------------------------------------------------------------
# TestMain (kills mutations in 142-160 range)
# ---------------------------------------------------------------------------

class TestMain:
    """Tests for the main() CLI entry point."""

    def test_main_wrong_args_exits_1(self, capsys):
        """main() exits 1 if argument count != 2 — usage message has no XX prefix."""
        with patch.object(sys, "argv", ["bounded_retry.py"]):
            with pytest.raises(SystemExit) as exc_info:
                _mod.main()
        assert exc_info.value.code == 1
        out = capsys.readouterr().out
        assert "Usage" in out
        assert "XX" not in out

    def test_main_missing_script_exits_1(self, tmp_path, capsys):
        """main() exits 1 if implementation_script does not exist — error has no XX prefix."""
        nonexistent = str(tmp_path / "no_such_script.sh")
        with patch.object(sys, "argv", ["bounded_retry.py", "FEATURE_001", nonexistent]):
            with pytest.raises(SystemExit) as exc_info:
                _mod.main()
        assert exc_info.value.code == 1
        out = capsys.readouterr().out
        assert "XX" not in out

    def test_main_success_exits_0(self, tmp_path):
        """main() exits 0 when bounded_retry returns True."""
        script = tmp_path / "impl.sh"
        script.write_text("#!/bin/bash\nexit 0\n")
        script.chmod(0o755)
        fl = _feature_list([_feature()])
        with patch.object(sys, "argv", ["bounded_retry.py", "FEATURE_001", str(script)]), \
             patch.object(_mod, "bounded_retry", return_value=True):
            with pytest.raises(SystemExit) as exc_info:
                _mod.main()
        assert exc_info.value.code == 0

    def test_main_failure_exits_1(self, tmp_path):
        """main() exits 1 when bounded_retry returns False."""
        script = tmp_path / "impl.sh"
        script.write_text("#!/bin/bash\nexit 0\n")
        script.chmod(0o755)
        with patch.object(sys, "argv", ["bounded_retry.py", "FEATURE_001", str(script)]), \
             patch.object(_mod, "bounded_retry", return_value=False):
            with pytest.raises(SystemExit) as exc_info:
                _mod.main()
        assert exc_info.value.code == 1

    def test_main_passes_feature_id_and_script_to_bounded_retry(self, tmp_path):
        """main() extracts feature_id and script path from sys.argv correctly."""
        script = tmp_path / "impl.sh"
        script.write_text("#!/bin/bash\n")
        script.chmod(0o755)
        captured = {}
        def fake_bounded_retry(fid, script_path):
            captured["fid"] = fid
            captured["script"] = script_path
            return True
        with patch.object(sys, "argv", ["bounded_retry.py", "FEATURE_007", str(script)]), \
             patch.object(_mod, "bounded_retry", side_effect=fake_bounded_retry):
            with pytest.raises(SystemExit):
                _mod.main()
        assert captured["fid"] == "FEATURE_007"
        assert captured["script"] == str(script)
