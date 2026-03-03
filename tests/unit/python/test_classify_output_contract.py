"""
P4-001 — JSON Output Schema Contract: classify-failure-logs.py (FR-9.2 / SC-005)

PURPOSE:
    Guards the downstream JSON contract that create-issue and create-fix-pr jobs
    depend on. This test will FAIL if anyone modifies REQUIRED_FIELDS, VALID_CATEGORIES,
    or the output shape of call_claude_api / fallback paths — making schema drift
    immediately visible rather than silently breaking the sentinel pipeline at runtime.

WHAT THIS IS NOT:
    This is not a logic test (those live in test_classify_failure_logs.py).
    This is a schema/contract test: "does every possible output path produce
    a document that the downstream consumer can safely parse?"

SDD reference: sprint4-plan.md P4-001
SC reference : spec-corrections.md SC-005
"""
import json
import sys
import os
from pathlib import Path
from unittest.mock import patch, MagicMock
import pytest

# ---------------------------------------------------------------------------
# Import path setup — hyphenated filename requires importlib
# ---------------------------------------------------------------------------
import importlib.util

_SCRIPTS_DIR = Path(__file__).parent.parent.parent.parent / "scripts"
_spec = importlib.util.spec_from_file_location(
    "classify_failure_logs",
    _SCRIPTS_DIR / "classify-failure-logs.py"
)
_clf = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_clf)

REQUIRED_FIELDS = _clf.REQUIRED_FIELDS
VALID_CATEGORIES = _clf.VALID_CATEGORIES
call_claude_api = _clf.call_claude_api
validate_classification = _clf.validate_classification


# ---------------------------------------------------------------------------
# Downstream consumer shape — what create-issue and create-fix-pr expect
# ---------------------------------------------------------------------------

DOWNSTREAM_REQUIRED_FIELDS = {
    "category": str,
    "pattern": str,
    "is_retriable": bool,
    "root_cause": str,
    "suggested_fix": str,
}


# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

def assert_valid_contract(result: dict, source: str) -> None:
    """Assert result satisfies the downstream JSON contract."""
    assert isinstance(result, dict), f"{source}: output must be a dict"

    for field, expected_type in DOWNSTREAM_REQUIRED_FIELDS.items():
        assert field in result, f"{source}: missing required field '{field}'"
        assert isinstance(result[field], expected_type), (
            f"{source}: field '{field}' must be {expected_type.__name__}, "
            f"got {type(result[field]).__name__}"
        )

    assert result["category"] in VALID_CATEGORIES, (
        f"{source}: category '{result['category']}' not in {VALID_CATEGORIES}"
    )

    # String fields must be non-empty — downstream uses these for issue body rendering
    for field in ("pattern", "root_cause", "suggested_fix"):
        assert result[field].strip(), f"{source}: field '{field}' must not be empty"


# ===========================================================================
# 1. Constants contract — the declared schema itself
# ===========================================================================

class TestSchemaConstants:
    """The constants ARE the contract. If they change, all downstream breaks."""

    def test_required_fields_contains_all_downstream_fields(self):
        """Every field the downstream consumer reads must be in REQUIRED_FIELDS."""
        missing = set(DOWNSTREAM_REQUIRED_FIELDS.keys()) - set(REQUIRED_FIELDS)
        assert not missing, (
            f"REQUIRED_FIELDS is missing fields that downstream consumers need: {missing}. "
            "Adding fields to DOWNSTREAM_REQUIRED_FIELDS without updating REQUIRED_FIELDS "
            "means the script won't validate them — silent downstream breakage."
        )

    def test_required_fields_has_no_extra_undeclared_fields(self):
        """REQUIRED_FIELDS should not silently grow without updating downstream tests."""
        extra = set(REQUIRED_FIELDS) - set(DOWNSTREAM_REQUIRED_FIELDS.keys())
        assert not extra, (
            f"REQUIRED_FIELDS has fields not known to downstream consumers: {extra}. "
            "Either add them to DOWNSTREAM_REQUIRED_FIELDS in this test, or remove them."
        )

    def test_valid_categories_contains_exactly_three_values(self):
        """Sentinel create-fix-pr has conditional logic for each category. Count must be exact."""
        assert len(VALID_CATEGORIES) == 3, (
            f"Expected exactly 3 categories, got {len(VALID_CATEGORIES)}: {VALID_CATEGORIES}. "
            "create-fix-pr uses 'known_pattern' to trigger fix PR; "
            "create-issue uses 'transient' for P2 priority vs P1. "
            "Adding or removing a category requires updating both downstream jobs."
        )

    def test_valid_categories_contains_transient(self):
        assert "transient" in VALID_CATEGORIES

    def test_valid_categories_contains_known_pattern(self):
        assert "known_pattern" in VALID_CATEGORIES

    def test_valid_categories_contains_unknown(self):
        assert "unknown" in VALID_CATEGORIES

    def test_is_retriable_field_name_is_exact(self):
        """create-fix-pr reads .is_retriable directly — any typo breaks the pipeline."""
        assert "is_retriable" in REQUIRED_FIELDS, (
            "Field name 'is_retriable' not in REQUIRED_FIELDS. "
            "Downstream jobs use: jq -r '.is_retriable' — name must be exact."
        )


# ===========================================================================
# 2. Fallback output contract — all fallback paths must satisfy schema
# ===========================================================================

class TestFallbackOutputContract:
    """Every fallback path in call_claude_api must produce a schema-valid document."""

    def _get_fallback_output(self, log_content: str) -> dict:
        """Drive the fallback path by setting no API key."""
        with patch.dict(os.environ, {}, clear=True):
            os.environ.pop("ANTHROPIC_API_KEY", None)
            return call_claude_api(log_content, "Test Workflow", "test-job")

    def test_timeout_fallback_satisfies_contract(self):
        result = self._get_fallback_output("fatal: connection timed out after 30 seconds")
        assert_valid_contract(result, "timeout-fallback")

    def test_rate_limit_fallback_satisfies_contract(self):
        result = self._get_fallback_output("error: 429 Too Many Requests rate limit exceeded")
        assert_valid_contract(result, "rate-limit-fallback")

    def test_permission_denied_fallback_satisfies_contract(self):
        result = self._get_fallback_output("error: 403 permission denied insufficient permissions")
        assert_valid_contract(result, "permission-fallback")

    def test_syntax_error_fallback_satisfies_contract(self):
        result = self._get_fallback_output("SyntaxError: unexpected token on line 42")
        assert_valid_contract(result, "syntax-fallback")

    def test_unknown_error_fallback_satisfies_contract(self):
        result = self._get_fallback_output("some completely unrecognised error XYZ-9999")
        assert_valid_contract(result, "unknown-fallback")

    def test_empty_log_fallback_satisfies_contract(self):
        result = self._get_fallback_output("")
        assert_valid_contract(result, "empty-log-fallback")

    def test_timeout_fallback_is_retriable(self):
        """Transient failures MUST be retriable — sentinel depends on this for auto-retry."""
        result = self._get_fallback_output("connection timed out")
        assert result["is_retriable"] is True

    def test_permission_fallback_is_not_retriable(self):
        """Permission errors are not retriable — sentinel skips auto-retry for these."""
        result = self._get_fallback_output("403 permission denied")
        assert result["is_retriable"] is False

    def test_unknown_fallback_is_not_retriable(self):
        """Unknown failures are not retriable by default — conservative default."""
        result = self._get_fallback_output("some completely unknown error")
        assert result["is_retriable"] is False


# ===========================================================================
# 3. API output contract — Claude's response must be validated before use
# ===========================================================================

class TestApiOutputContract:
    """When Claude API returns a response, it must be validated before downstream use."""

    def _make_mock_anthropic(self, payload: dict) -> MagicMock:
        """anthropic is imported lazily inside call_claude_api — patch sys.modules."""
        mock_msg = MagicMock()
        mock_msg.content = [MagicMock(text=json.dumps(payload))]
        mock_client = MagicMock()
        mock_client.messages.create.return_value = mock_msg
        mock_anthropic = MagicMock()
        mock_anthropic.Anthropic.return_value = mock_client
        return mock_anthropic

    def test_valid_api_response_satisfies_contract(self):
        valid_payload = {
            "category": "transient",
            "pattern": "Network timeout",
            "is_retriable": True,
            "root_cause": "Temporary connectivity issue.",
            "suggested_fix": "Retry the workflow."
        }
        with patch.dict(os.environ, {"ANTHROPIC_API_KEY": "test-key"}):  # pragma: allowlist secret
            with patch.dict(sys.modules, {"anthropic": self._make_mock_anthropic(valid_payload)}):
                result = call_claude_api("error log", "Workflow", "job")
        assert_valid_contract(result, "api-valid-response")

    def test_api_response_missing_field_falls_back_to_valid_contract(self):
        """If Claude omits a required field, fallback must still satisfy contract."""
        incomplete_payload = {
            "category": "transient",
            "pattern": "Network timeout",
            # missing: is_retriable, root_cause, suggested_fix
        }
        with patch.dict(os.environ, {"ANTHROPIC_API_KEY": "test-key"}):  # pragma: allowlist secret
            with patch.dict(sys.modules, {"anthropic": self._make_mock_anthropic(incomplete_payload)}):
                result = call_claude_api("connection timed out", "Workflow", "job")
        # Should fall back to pattern-based classification — still contract-valid
        assert_valid_contract(result, "api-missing-field-fallback")

    def test_api_response_invalid_category_falls_back_to_valid_contract(self):
        """If Claude hallucinates a category, fallback must still satisfy contract."""
        bad_category_payload = {
            "category": "critical",  # not in VALID_CATEGORIES
            "pattern": "Something bad",
            "is_retriable": False,
            "root_cause": "Unknown.",
            "suggested_fix": "Fix it."
        }
        with patch.dict(os.environ, {"ANTHROPIC_API_KEY": "test-key"}):  # pragma: allowlist secret
            with patch.dict(sys.modules, {"anthropic": self._make_mock_anthropic(bad_category_payload)}):
                result = call_claude_api("some error log", "Workflow", "job")
        assert_valid_contract(result, "api-bad-category-fallback")


# ===========================================================================
# 4. validate_classification contract — the gatekeeper function
# ===========================================================================

class TestValidateClassificationContract:
    """validate_classification is the last line of defence before downstream use."""

    def test_valid_document_passes(self):
        valid = {
            "category": "known_pattern",
            "pattern": "Protected branch push rejected",
            "is_retriable": False,
            "root_cause": "Branch protection rule blocked direct push.",
            "suggested_fix": "Use a pull request instead."
        }
        assert validate_classification(valid) is True

    def test_missing_any_required_field_fails(self):
        for field in REQUIRED_FIELDS:
            doc = {
                "category": "transient",
                "pattern": "x",
                "is_retriable": True,
                "root_cause": "x",
                "suggested_fix": "x"
            }
            del doc[field]
            assert validate_classification(doc) is False, (
                f"validate_classification should reject document missing '{field}'"
            )

    def test_invalid_category_fails(self):
        doc = {
            "category": "critical",
            "pattern": "x",
            "is_retriable": True,
            "root_cause": "x",
            "suggested_fix": "x"
        }
        assert validate_classification(doc) is False

    def test_non_boolean_is_retriable_fails(self):
        for bad_value in ("true", "false", 1, 0, None):
            doc = {
                "category": "transient",
                "pattern": "x",
                "is_retriable": bad_value,
                "root_cause": "x",
                "suggested_fix": "x"
            }
            assert validate_classification(doc) is False, (
                f"is_retriable={bad_value!r} should fail — downstream does boolean check"
            )


# ===========================================================================
# 5. JSON serialisability — output must be writable to a .json file
# ===========================================================================

class TestJsonSerialisability:
    """Downstream jobs write the output to a .json file then read it with jq.
    Any non-serialisable value would cause a silent write corruption."""

    def test_all_fallback_outputs_are_json_serialisable(self):
        test_logs = [
            "connection timed out",
            "rate limit 429",
            "permission denied 403",
            "syntax error line 42",
            "completely unknown xyz",
            "",
        ]
        with patch.dict(os.environ, {}, clear=True):
            os.environ.pop("ANTHROPIC_API_KEY", None)
            for log in test_logs:
                result = call_claude_api(log, "Workflow", "job")
                try:
                    serialised = json.dumps(result)
                    reparsed = json.loads(serialised)
                    assert reparsed == result
                except (TypeError, ValueError) as e:
                    pytest.fail(f"Output for log={repr(log)[:40]} is not JSON-serialisable: {e}")
