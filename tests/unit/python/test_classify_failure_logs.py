"""
P1-003 — classify-failure-logs.py Unit Tests (FR-9.2)

Coverage:
- truncate_log: short log passthrough, long log truncation, prefix added
- call_claude_api: successful mock API response, markdown code-block stripping,
  missing-field triggers fallback, exception triggers fallback
- Fallback classification: transient (timeout), transient (rate-limit),
  known_pattern (permission), known_pattern (syntax), unknown (no match)
- API unavailable: no ANTHROPIC_API_KEY, anthropic import error
- validate_classification: valid, missing field, bad category, non-bool is_retriable
- Constants: REQUIRED_FIELDS, VALID_CATEGORIES
"""

import json
import os
import sys
import importlib.util
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest

# ---------------------------------------------------------------------------
# Load the hyphen-named module via importlib
# ---------------------------------------------------------------------------

_scripts_dir = Path(__file__).parent.parent.parent.parent / "scripts"
_spec = importlib.util.spec_from_file_location(
    "classify_failure_logs",
    _scripts_dir / "classify-failure-logs.py"
)
clf = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(clf)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _valid_classification():
    return {
        "category": "transient",
        "pattern": "Network timeout",
        "is_retriable": True,
        "root_cause": "Temporary network issue.",
        "suggested_fix": "Retry the workflow.",
    }


def _make_mock_anthropic(response_text: str):
    """Return a mock anthropic module that yields response_text from the API."""
    mock_msg = MagicMock()
    mock_msg.content = [MagicMock(text=response_text)]

    mock_client = MagicMock()
    mock_client.messages.create.return_value = mock_msg

    mock_anthropic = MagicMock()
    mock_anthropic.Anthropic.return_value = mock_client
    return mock_anthropic


# ---------------------------------------------------------------------------
# TestTruncateLog
# ---------------------------------------------------------------------------

class TestTruncateLog:

    def test_short_log_returned_unchanged(self):
        content = "line1\nline2\nline3"
        result = clf.truncate_log(content, max_bytes=50000)
        assert result == content

    def test_long_log_is_truncated(self):
        # Build a log well over 50KB
        big_log = ("x" * 1000 + "\n") * 60
        result = clf.truncate_log(big_log, max_bytes=50000)
        assert len(result.encode("utf-8")) <= 51000  # within one line of the limit

    def test_truncated_log_adds_header(self):
        big_log = ("x" * 1000 + "\n") * 60
        result = clf.truncate_log(big_log, max_bytes=50000)
        assert result.startswith("[LOG TRUNCATED")


# ---------------------------------------------------------------------------
# TestCallClaudeApiSuccess
# ---------------------------------------------------------------------------

class TestCallClaudeApiSuccess:

    def test_successful_api_response_returned(self, monkeypatch):
        monkeypatch.setenv("ANTHROPIC_API_KEY", "test-key")
        payload = json.dumps(_valid_classification())
        mock_anthropic = _make_mock_anthropic(payload)

        with patch.dict(sys.modules, {"anthropic": mock_anthropic}):
            result = clf.call_claude_api("some log", "My Workflow", "my-job")

        assert result["category"] == "transient"
        assert result["is_retriable"] is True
        assert result["pattern"] == "Network timeout"

    def test_markdown_code_block_stripped(self, monkeypatch):
        monkeypatch.setenv("ANTHROPIC_API_KEY", "test-key")
        # Wrap response in triple-backtick markdown block
        payload = "```json\n" + json.dumps(_valid_classification()) + "\n```"
        mock_anthropic = _make_mock_anthropic(payload)

        with patch.dict(sys.modules, {"anthropic": mock_anthropic}):
            result = clf.call_claude_api("some log", "My Workflow", "my-job")

        assert result["category"] == "transient"

    def test_missing_field_in_response_triggers_fallback(self, monkeypatch):
        monkeypatch.setenv("ANTHROPIC_API_KEY", "test-key")
        # Response is missing 'root_cause' and 'suggested_fix'
        incomplete = {"category": "transient", "pattern": "...", "is_retriable": True}
        mock_anthropic = _make_mock_anthropic(json.dumps(incomplete))

        with patch.dict(sys.modules, {"anthropic": mock_anthropic}):
            # Must fall back to pattern-based (log has no recognizable pattern → unknown)
            result = clf.call_claude_api("nothing recognizable here", "W", "J")

        # Fallback should still return a valid structure
        assert result["category"] in clf.VALID_CATEGORIES
        assert all(f in result for f in clf.REQUIRED_FIELDS)

    def test_invalid_category_in_response_triggers_fallback(self, monkeypatch):
        """Lines 115-116: Claude returns a valid JSON with a category not in VALID_CATEGORIES."""
        monkeypatch.setenv("ANTHROPIC_API_KEY", "test-key")
        # All required fields present but category is not in VALID_CATEGORIES
        invalid_cat = {
            "category": "critical",  # not in {transient, known_pattern, unknown}
            "pattern": "Some pattern",
            "is_retriable": False,
            "root_cause": "Some cause",
            "suggested_fix": "Manual review",
        }
        mock_anthropic = _make_mock_anthropic(json.dumps(invalid_cat))
        with patch.dict(sys.modules, {"anthropic": mock_anthropic}):
            result = clf.call_claude_api("connection timed out", "W", "J")
        # Must fall back gracefully — category must be valid
        assert result["category"] in clf.VALID_CATEGORIES
        assert all(f in result for f in clf.REQUIRED_FIELDS)


# ---------------------------------------------------------------------------
# TestFallbackClassification (no API key → forced fallback)
# ---------------------------------------------------------------------------

class TestFallbackClassification:

    def _classify(self, log_text, monkeypatch):
        """Remove API key to force the pattern-based fallback path."""
        monkeypatch.delenv("ANTHROPIC_API_KEY", raising=False)
        return clf.call_claude_api(log_text, "W", "J")

    def test_timeout_log_classified_as_transient(self, monkeypatch):
        result = self._classify("Step failed: connection timed out after 30s", monkeypatch)
        assert result["category"] == "transient"
        assert result["is_retriable"] is True

    def test_rate_limit_log_classified_as_transient(self, monkeypatch):
        result = self._classify("Error 429: too many requests, rate limit exceeded", monkeypatch)
        assert result["category"] == "transient"
        assert result["is_retriable"] is True

    def test_permission_denied_classified_as_known_pattern(self, monkeypatch):
        result = self._classify("fatal: permission denied (403 Forbidden)", monkeypatch)
        assert result["category"] == "known_pattern"
        assert result["is_retriable"] is False

    def test_syntax_error_classified_as_known_pattern(self, monkeypatch):
        result = self._classify("SyntaxError: invalid syntax on line 42", monkeypatch)
        assert result["category"] == "known_pattern"
        assert result["is_retriable"] is False

    def test_unrecognized_log_classified_as_unknown(self, monkeypatch):
        result = self._classify("Some completely unrecognized error occurred.", monkeypatch)
        assert result["category"] == "unknown"
        assert result["is_retriable"] is False


# ---------------------------------------------------------------------------
# TestApiUnavailable (import error path)
# ---------------------------------------------------------------------------

class TestApiUnavailable:

    def test_anthropic_import_error_triggers_fallback(self, monkeypatch):
        monkeypatch.setenv("ANTHROPIC_API_KEY", "test-key")
        # Remove anthropic from sys.modules so the import inside the function fails
        with patch.dict(sys.modules, {"anthropic": None}):
            result = clf.call_claude_api("timeout occurred", "W", "J")
        # Should still return a valid fallback result
        assert result["category"] in clf.VALID_CATEGORIES
        assert all(f in result for f in clf.REQUIRED_FIELDS)

    def test_all_fallback_results_have_required_fields(self, monkeypatch):
        monkeypatch.delenv("ANTHROPIC_API_KEY", raising=False)
        for log_text in [
            "connection timed out",
            "rate limit exceeded",
            "permission denied",
            "syntax error",
            "something completely new",
        ]:
            result = clf.call_claude_api(log_text, "W", "J")
            for field in clf.REQUIRED_FIELDS:
                assert field in result, f"Missing '{field}' for log: {log_text!r}"


# ---------------------------------------------------------------------------
# TestValidateClassification
# ---------------------------------------------------------------------------

class TestValidateClassification:

    def test_valid_classification_returns_true(self):
        assert clf.validate_classification(_valid_classification()) is True

    def test_missing_required_field_returns_false(self):
        bad = _valid_classification()
        del bad["root_cause"]
        assert clf.validate_classification(bad) is False

    def test_invalid_category_returns_false(self):
        bad = _valid_classification()
        bad["category"] = "critical"  # Not in VALID_CATEGORIES
        assert clf.validate_classification(bad) is False

    def test_is_retriable_not_boolean_returns_false(self):
        bad = _valid_classification()
        bad["is_retriable"] = "yes"  # String, not bool
        assert clf.validate_classification(bad) is False


# ---------------------------------------------------------------------------
# TestConstants
# ---------------------------------------------------------------------------

class TestConstants:

    def test_required_fields_present(self):
        assert set(clf.REQUIRED_FIELDS) == {
            "category", "pattern", "is_retriable", "root_cause", "suggested_fix"
        }

    def test_valid_categories(self):
        assert set(clf.VALID_CATEGORIES) == {"transient", "known_pattern", "unknown"}


# ---------------------------------------------------------------------------
# TestMain — covers lines 188-245 (CLI entry point)
# ---------------------------------------------------------------------------

class TestMain:

    def test_main_writes_classification_json(self, tmp_path, monkeypatch):
        """main() reads a log file, classifies it (fallback), writes JSON output."""
        log_file = tmp_path / "test.log"
        log_file.write_text("connection timed out after 30s")
        output_file = tmp_path / "out" / "classification.json"

        monkeypatch.setattr(sys, "argv", [
            "classify-failure-logs.py",
            "--log-file", str(log_file),
            "--workflow-name", "Test Workflow",
            "--job-name", "test-job",
            "--run-id", "99999",
            "--output", str(output_file),
        ])
        monkeypatch.delenv("ANTHROPIC_API_KEY", raising=False)

        with pytest.raises(SystemExit) as exc_info:
            clf.main()

        assert exc_info.value.code == 0
        assert output_file.exists()
        data = json.loads(output_file.read_text())
        assert data["category"] in clf.VALID_CATEGORIES
        assert all(f in data for f in clf.REQUIRED_FIELDS)
        assert data["metadata"]["workflow_name"] == "Test Workflow"
        assert data["metadata"]["run_id"] == "99999"

    def test_main_exits_1_for_missing_log_file(self, tmp_path, monkeypatch):
        """main() exits 1 when the log file does not exist."""
        monkeypatch.setattr(sys, "argv", [
            "classify-failure-logs.py",
            "--log-file", str(tmp_path / "nonexistent.log"),
            "--workflow-name", "W",
            "--job-name", "J",
            "--run-id", "1",
            "--output", str(tmp_path / "out.json"),
        ])
        monkeypatch.delenv("ANTHROPIC_API_KEY", raising=False)

        with pytest.raises(SystemExit) as exc_info:
            clf.main()

        assert exc_info.value.code == 1
