"""
P0-002: FR-9 Pipeline Integration Tests
Requirement: ADR-006 / FR-9.1–FR-9.5 — classify-failure-logs.py must correctly
classify workflow failures into transient / known_pattern / unknown.

Tests:
  Path 1 — transient: network timeout triggers transient + retriable
  Path 2 — known_pattern: permission / syntax errors trigger known_pattern
  Path 3 — unknown: unrecognized errors trigger unknown
  Path 4 — Claude unavailable: API exceptions fall back to pattern matching
  Path 5 — Claude API happy path: mocked Claude returns structured classification

Integration scope: tests the full classify-failure-logs.py main() via tempfile I/O.
"""

import importlib.util
import json
import os
import sys
import tempfile
import time
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest

# ---------------------------------------------------------------------------
# Load module under test
# ---------------------------------------------------------------------------
_SCRIPTS_DIR = Path(__file__).resolve().parent.parent.parent / "scripts"
_SCRIPT = _SCRIPTS_DIR / "classify-failure-logs.py"

_spec = importlib.util.spec_from_file_location("classify_failure_logs", _SCRIPT)
_mod = importlib.util.module_from_spec(_spec)
# Temporarily suppress __name__ == "__main__" guard while loading
_spec.loader.exec_module(_mod)

call_claude_api   = _mod.call_claude_api
validate_classification = _mod.validate_classification
truncate_log      = _mod.truncate_log
REQUIRED_FIELDS   = _mod.REQUIRED_FIELDS
VALID_CATEGORIES  = _mod.VALID_CATEGORIES

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _run_main(log_content: str, workflow: str = "test-workflow",
              job: str = "test-job", run_id: str = "999") -> dict:
    """Run main() with a temp log file and return parsed classification JSON."""
    with tempfile.TemporaryDirectory() as tmpdir:
        log_file = Path(tmpdir) / "failure.log"
        out_file = Path(tmpdir) / "classification.json"
        log_file.write_text(log_content)

        # Patch sys.argv for argparse inside main()
        with patch.object(sys, "argv", [
            "classify-failure-logs.py",
            "--log-file",      str(log_file),
            "--workflow-name", workflow,
            "--job-name",      job,
            "--run-id",        run_id,
            "--output",        str(out_file),
        ]):
            try:
                _mod.main()
            except SystemExit as e:
                assert e.code == 0, f"main() exited with code {e.code}"

        return json.loads(out_file.read_text())


def _strip_api_key(monkeypatch):
    """Remove ANTHROPIC_API_KEY from env so the fallback path is taken."""
    monkeypatch.delenv("ANTHROPIC_API_KEY", raising=False)


# ---------------------------------------------------------------------------
# Unit tests: call_claude_api() — fallback paths (no API key)
# ---------------------------------------------------------------------------

class TestFallbackClassification:
    """P0-002 Path 3 & 4: fallback pattern matching when Claude is unavailable."""

    def test_timeout_log_classified_as_transient(self, monkeypatch):
        """Path 1: 'timed out' in log → transient + retriable."""
        _strip_api_key(monkeypatch)
        result = call_claude_api(
            "Step failed: connection timed out after 300s", "wf", "job"
        )
        assert result["category"] == "transient"
        assert result["is_retriable"] is True

    def test_connection_refused_classified_as_transient(self, monkeypatch):
        """Path 1: 'connection refused' → transient + retriable."""
        _strip_api_key(monkeypatch)
        result = call_claude_api(
            "dial tcp: connection refused", "wf", "job"
        )
        assert result["category"] == "transient"
        assert result["is_retriable"] is True

    def test_rate_limit_classified_as_transient(self, monkeypatch):
        """Path 1: '429 too many requests' → transient + retriable."""
        _strip_api_key(monkeypatch)
        result = call_claude_api(
            "HTTP 429 Too Many Requests - rate limit exceeded", "wf", "job"
        )
        assert result["category"] == "transient"
        assert result["is_retriable"] is True

    def test_permission_error_classified_as_known_pattern(self, monkeypatch):
        """Path 2: 'permission denied' → known_pattern + not retriable."""
        _strip_api_key(monkeypatch)
        result = call_claude_api(
            "Error: permission denied for /etc/secrets", "wf", "job"
        )
        assert result["category"] == "known_pattern"
        assert result["is_retriable"] is False

    def test_403_classified_as_known_pattern(self, monkeypatch):
        """Path 2: '403 unauthorized' → known_pattern."""
        _strip_api_key(monkeypatch)
        result = call_claude_api(
            "HTTP 403 Forbidden: unauthorized access", "wf", "job"
        )
        assert result["category"] == "known_pattern"
        assert result["is_retriable"] is False

    def test_syntax_error_classified_as_known_pattern(self, monkeypatch):
        """Path 2: 'syntax error' → known_pattern + not retriable."""
        _strip_api_key(monkeypatch)
        result = call_claude_api(
            "SyntaxError: invalid syntax at line 42", "wf", "job"
        )
        assert result["category"] == "known_pattern"
        assert result["is_retriable"] is False

    def test_unrecognized_error_classified_as_unknown(self, monkeypatch):
        """Path 3: unrecognized log content → unknown + not retriable."""
        _strip_api_key(monkeypatch)
        result = call_claude_api(
            "Segmentation fault (core dumped) at address 0xdeadbeef", "wf", "job"
        )
        assert result["category"] == "unknown"
        assert result["is_retriable"] is False

    def test_fallback_result_has_all_required_fields(self, monkeypatch):
        """All fallback paths must return a complete classification schema."""
        _strip_api_key(monkeypatch)
        for log in [
            "timed out",
            "rate limit",
            "permission denied",
            "syntax error",
            "something completely unrecognized xyz",
        ]:
            result = call_claude_api(log, "wf", "job")
            for field in REQUIRED_FIELDS:
                assert field in result, f"Missing field '{field}' for log: {log!r}"

    def test_fallback_category_is_valid(self, monkeypatch):
        """Fallback category must be one of the three valid values."""
        _strip_api_key(monkeypatch)
        for log in ["timeout", "403", "syntax error", "alien invasion"]:
            result = call_claude_api(log, "wf", "job")
            assert result["category"] in VALID_CATEGORIES, (
                f"Invalid category {result['category']!r} for log {log!r}"
            )


# ---------------------------------------------------------------------------
# Unit tests: call_claude_api() — Claude API path (mocked)
# ---------------------------------------------------------------------------

class TestClaudeAPIPath:
    """P0-002 Path 5: mocked Claude API returns structured classification."""

    def _make_mock_client(self, response_dict: dict):
        """Build a mock anthropic.Anthropic client that returns response_dict."""
        mock_client = MagicMock()
        mock_message = MagicMock()
        mock_message.content = [MagicMock(text=json.dumps(response_dict))]
        mock_client.messages.create.return_value = mock_message
        return mock_client

    def test_claude_transient_classification(self, monkeypatch):
        """Claude returns transient → caller gets transient."""
        monkeypatch.setenv("ANTHROPIC_API_KEY", "test-key-abc")
        expected = {
            "category": "transient",
            "pattern": "Network timeout",
            "is_retriable": True,
            "root_cause": "Network blip",
            "suggested_fix": "Retry",
        }
        mock_client = self._make_mock_client(expected)
        with patch("anthropic.Anthropic", return_value=mock_client):
            result = call_claude_api("some log", "wf", "job")
        assert result["category"] == "transient"
        assert result["is_retriable"] is True

    def test_claude_known_pattern_classification(self, monkeypatch):
        """Claude returns known_pattern → caller gets known_pattern."""
        monkeypatch.setenv("ANTHROPIC_API_KEY", "test-key-abc")
        expected = {
            "category": "known_pattern",
            "pattern": "Docker image not found",
            "is_retriable": False,
            "root_cause": "Missing image",
            "suggested_fix": "Check registry",
        }
        mock_client = self._make_mock_client(expected)
        with patch("anthropic.Anthropic", return_value=mock_client):
            result = call_claude_api("some log", "wf", "job")
        assert result["category"] == "known_pattern"
        assert result["is_retriable"] is False

    def test_claude_unknown_classification(self, monkeypatch):
        """Claude returns unknown → caller gets unknown."""
        monkeypatch.setenv("ANTHROPIC_API_KEY", "test-key-abc")
        expected = {
            "category": "unknown",
            "pattern": "Novel failure mode",
            "is_retriable": False,
            "root_cause": "Unclear",
            "suggested_fix": "Manual investigation",
        }
        mock_client = self._make_mock_client(expected)
        with patch("anthropic.Anthropic", return_value=mock_client):
            result = call_claude_api("some log", "wf", "job")
        assert result["category"] == "unknown"

    def test_claude_api_exception_falls_back_to_pattern(self, monkeypatch):
        """Path 4: Claude API raises exception → fallback pattern matching."""
        monkeypatch.setenv("ANTHROPIC_API_KEY", "test-key-abc")
        mock_client = MagicMock()
        mock_client.messages.create.side_effect = Exception("API error")
        with patch("anthropic.Anthropic", return_value=mock_client):
            result = call_claude_api("connection timed out", "wf", "job")
        # Should have fallen back to pattern matching
        assert result["category"] == "transient"

    def test_claude_missing_field_falls_back(self, monkeypatch):
        """Claude response missing required field → fallback is applied."""
        monkeypatch.setenv("ANTHROPIC_API_KEY", "test-key-abc")
        incomplete = {
            "category": "transient",
            # missing: pattern, is_retriable, root_cause, suggested_fix
        }
        mock_client = self._make_mock_client(incomplete)
        with patch("anthropic.Anthropic", return_value=mock_client):
            result = call_claude_api("connection timed out", "wf", "job")
        # Fell back to pattern match; result must still have all required fields
        for field in REQUIRED_FIELDS:
            assert field in result

    def test_claude_uses_correct_model(self, monkeypatch):
        """Claude API must be called with claude-sonnet-4-6 (ADR-006)."""
        monkeypatch.setenv("ANTHROPIC_API_KEY", "test-key-abc")
        expected = {
            "category": "transient",
            "pattern": "test",
            "is_retriable": True,
            "root_cause": "test",
            "suggested_fix": "test",
        }
        mock_client = self._make_mock_client(expected)
        with patch("anthropic.Anthropic", return_value=mock_client) as mock_cls:
            call_claude_api("some log", "wf", "job")
        call_kwargs = mock_client.messages.create.call_args
        assert call_kwargs.kwargs.get("model") == "claude-sonnet-4-6", (
            "Wrong model — must use claude-sonnet-4-6 per ADR-006"
        )


# ---------------------------------------------------------------------------
# Validation tests: validate_classification()
# ---------------------------------------------------------------------------

class TestValidateClassification:
    """Unit tests for the classification schema validator."""

    def _valid(self):
        return {
            "category": "transient",
            "pattern": "test",
            "is_retriable": True,
            "root_cause": "test",
            "suggested_fix": "test",
        }

    def test_valid_classification_passes(self):
        assert validate_classification(self._valid()) is True

    def test_all_valid_categories_accepted(self):
        for cat in VALID_CATEGORIES:
            c = self._valid()
            c["category"] = cat
            assert validate_classification(c) is True

    def test_invalid_category_rejected(self):
        c = self._valid()
        c["category"] = "definitely_invalid"
        assert validate_classification(c) is False

    def test_missing_required_field_rejected(self):
        for field in REQUIRED_FIELDS:
            c = self._valid()
            del c[field]
            assert validate_classification(c) is False, (
                f"Should fail when '{field}' is missing"
            )

    def test_non_boolean_is_retriable_rejected(self):
        c = self._valid()
        c["is_retriable"] = "yes"  # string, not bool
        assert validate_classification(c) is False


# ---------------------------------------------------------------------------
# Truncation tests: truncate_log()
# ---------------------------------------------------------------------------

class TestTruncateLog:
    """Unit tests for log truncation logic."""

    def test_short_log_not_truncated(self):
        log = "short log content"
        assert truncate_log(log, max_bytes=50000) == log

    def test_long_log_truncated_to_limit(self):
        log = "x" * 100000
        result = truncate_log(log, max_bytes=50000)
        assert len(result.encode("utf-8")) <= 50000

    def test_truncated_log_has_marker(self):
        lines = "\n".join(f"line {i}" for i in range(200))
        result = truncate_log(lines, max_bytes=500)
        assert "[LOG TRUNCATED" in result


# ---------------------------------------------------------------------------
# P0-002 GATE: End-to-end integration via main()
# ---------------------------------------------------------------------------

class TestMainIntegration:
    """P0-002 pass gate: full main() invocation for each classification path."""

    def test_main_transient_path(self, monkeypatch):
        """Path 1 E2E: timeout log → output JSON has category=transient."""
        monkeypatch.delenv("ANTHROPIC_API_KEY", raising=False)
        result = _run_main("Step failed: connection timed out after 300s")
        assert result["category"] == "transient"
        assert result["is_retriable"] is True
        # Metadata must be present
        assert "metadata" in result
        assert result["metadata"]["workflow_name"] == "test-workflow"

    def test_main_known_pattern_path(self, monkeypatch):
        """Path 2 E2E: permission error → output JSON has category=known_pattern."""
        monkeypatch.delenv("ANTHROPIC_API_KEY", raising=False)
        result = _run_main("Error: permission denied accessing /secrets")
        assert result["category"] == "known_pattern"
        assert result["is_retriable"] is False

    def test_main_unknown_path(self, monkeypatch):
        """Path 3 E2E: unrecognized log → output JSON has category=unknown."""
        monkeypatch.delenv("ANTHROPIC_API_KEY", raising=False)
        result = _run_main("Mysterious failure: QX9-OVERFLOW in subsystem Z")
        assert result["category"] == "unknown"

    def test_main_output_json_has_all_required_fields(self, monkeypatch):
        """Output JSON must contain all required classification fields."""
        monkeypatch.delenv("ANTHROPIC_API_KEY", raising=False)
        result = _run_main("something failed")
        for field in REQUIRED_FIELDS:
            assert field in result, f"Output JSON missing required field: {field}"

    def test_main_output_json_has_metadata(self, monkeypatch):
        """Output JSON must contain metadata block (workflow_name, run_id, etc.)."""
        monkeypatch.delenv("ANTHROPIC_API_KEY", raising=False)
        result = _run_main("something failed", run_id="42")
        assert "metadata" in result
        meta = result["metadata"]
        assert meta["run_id"] == "42"
        assert "timestamp" in meta

    def test_main_claude_api_path_mocked(self, monkeypatch):
        """Path 5 E2E: mocked Claude API → correct classification in output JSON."""
        monkeypatch.setenv("ANTHROPIC_API_KEY", "test-key")
        expected = {
            "category": "known_pattern",
            "pattern": "Docker image missing",
            "is_retriable": False,
            "root_cause": "Image not in registry",
            "suggested_fix": "Push image first",
        }
        mock_client = MagicMock()
        mock_message = MagicMock()
        mock_message.content = [MagicMock(text=json.dumps(expected))]
        mock_client.messages.create.return_value = mock_message
        with patch("anthropic.Anthropic", return_value=mock_client):
            result = _run_main("docker pull failed: image not found")
        assert result["category"] == "known_pattern"
        assert result["metadata"]["workflow_name"] == "test-workflow"
