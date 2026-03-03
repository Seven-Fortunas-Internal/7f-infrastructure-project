"""
P0-001: Secret Detection Rate Tests
Requirement: FR-5.1 — detect-secrets + gitleaks must catch ≥99.5% of baseline secret patterns.

Strategy:
- Baseline cases (22): each tested individually; overall rate must be ≥99.5%
- Adversarial cases (9): tested individually; expected gaps are xfail (documented, not blocking)
- JSON report: emitted by the rate-gate test for machine-readable pass/fail
"""

import json
import subprocess
import tempfile
import time
from pathlib import Path

import pytest

# ---------------------------------------------------------------------------
# Tool paths
# ---------------------------------------------------------------------------
_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
_VENV_DS = _PROJECT_ROOT / "venv" / "bin" / "detect-secrets"
_DETECT_SECRETS = str(_VENV_DS) if _VENV_DS.exists() else "detect-secrets"
_GITLEAKS = "gitleaks"
_GITLEAKS_CONFIG = _PROJECT_ROOT / ".gitleaks.toml"

# ---------------------------------------------------------------------------
# Test data (mirrors tests/secret-detection/test_secret_patterns.py)
# ---------------------------------------------------------------------------
BASELINE_CASES = [
    # GitHub tokens
    ("github_pat",        "ghp_1234567890abcdefghijklmnopqrstuvwxyz12"),
    ("github_oauth",      "gho_1234567890abcdefghijklmnopqrstuvwxyz12"),
    ("github_user_token", "ghu_1234567890abcdefghijklmnopqrstuvwxyz12"),
    ("github_refresh",    "ghr_1234567890abcdefghijklmnopqrstuvwxyz12"),
    # AWS
    ("aws_access_key",    "AKIAIOSFODNN7EXAMPLE"),
    ("aws_secret",        "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"),
    # Anthropic
    ("anthropic_api",     "sk-ant-api03-1234567890abcdefghijklmnopqrstuvwxyz"),
    # OpenAI
    ("openai_api",        "sk-1234567890abcdefghijklmnopqrstuvwxyz"),
    # Slack
    ("slack_token",       "FAKE_SLACK_BOT_TOKEN_FOR_TESTING_ONLY"),
    ("slack_webhook",     "https://example.com/fake-slack-webhook-for-testing"),
    # Generic secrets
    ("api_key",           "api_key=FAKE_STRIPE_KEY_FOR_TESTING_ONLY"),
    ("password",          "password='P@ssw0rd!2024'"),
    ("token",             "bearer_token='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'"),
    # Base64
    ("base64_secret",     "c2VjcmV0X2tleT1za19saXZlXzEyMzQ1Njc4OTA="),
    # Env vars
    ("env_secret",        "export API_KEY=FAKE_STRIPE_KEY_FOR_TESTING_ONLY"),
    # Private keys
    ("rsa_private_key",   "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEA...\n"),
    ("ssh_private_key",   "-----BEGIN OPENSSH PRIVATE KEY-----\nb3BlbnNzaC1rZXktdjEA...\n"),
    # Database credentials
    ("db_connection",     "postgresql://user:password@localhost/dbname"),
    ("mysql_connection",  "mysql://root:MyPassword123@localhost:3306/database"),
    # JWT
    ("jwt_token",         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
                          ".eyJzdWIiOiIxMjM0NTY3ODkwIn0"
                          ".SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"),
    # Additional common patterns
    ("stripe_key",        "sk_live_FAKESTRIPEKEYFORTESTING1234567890"),
    ("generic_secret",    "SECRET_KEY=s3cr3tK3yTh4tIsV3ryL0ngAndH4rd"),
]

# Adversarial cases — tools may miss these; failures are documented, not blocking.
# xfail=True: expected to fail (tool limitation). xfail=False: should pass.
ADVERSARIAL_CASES = [
    # (secret_type, secret_value, expected_detected)
    ("split_github",    "ghp_" + "1234567890" + "abcdefghijklmnopqrstuvwxyz12", True),
    ("hex_secret",      "736b5f6c6976655f313233343536373839306162636465666768696a", False),
    ("reversed_key",    "21zxywvutsrqponmlkjihgfedcba0987654321_etadpu_khs", False),
    ("dotenv_secret",   "OPENAI_API_KEY=sk-1234567890abcdefghijklmnopqrstuv", True),
    ("json_secret",     '{"api_key": "FAKE_STRIPE_KEY_FOR_TESTING_ONLY"}', True),
    ("yaml_secret",     "api_key: FAKE_STRIPE_KEY_FOR_TESTING_ONLY", True),
    ("url_encoded",     "token=ghp%5F1234567890abcdefghijklmnopqrstuvwxyz12", False),
    ("comment_secret",  "# API_KEY=FAKE_STRIPE_KEY_FOR_TESTING_ONLY", True),
    ("multiline_secret",'secret_key = "FAKE_STRIPE_KEY_FOR_TESTING_ONLY"', True),
]

# ---------------------------------------------------------------------------
# Core detection helper
# ---------------------------------------------------------------------------

def _detect(secret_value: str) -> tuple[bool, str]:
    """
    Run detect-secrets + gitleaks on a temp file containing the secret.
    Returns (detected: bool, scanner: str).
    """
    with tempfile.NamedTemporaryFile(mode="w", suffix=".py", delete=False) as f:
        f.write(f"SECRET = '{secret_value}'\n")
        tmp = Path(f.name)

    try:
        # --- detect-secrets ---
        r = subprocess.run(
            [_DETECT_SECRETS, "scan", str(tmp)],
            capture_output=True, text=True, timeout=30,
        )
        try:
            ds_out = json.loads(r.stdout)
            if ds_out.get("results"):          # non-empty → something found
                return (True, "detect-secrets")
        except (json.JSONDecodeError, KeyError):
            pass

        # --- gitleaks ---
        gl_args = [_GITLEAKS, "detect", "--source", str(tmp), "--no-git"]
        if _GITLEAKS_CONFIG.exists():
            gl_args += ["--config", str(_GITLEAKS_CONFIG)]
        r_gl = subprocess.run(gl_args, capture_output=True, text=True, timeout=30)
        if r_gl.returncode == 1:               # gitleaks returns 1 when secrets found
            return (True, "gitleaks")

        return (False, "none")
    finally:
        tmp.unlink(missing_ok=True)


# ---------------------------------------------------------------------------
# P0-001a — Baseline parametrized tests
# ---------------------------------------------------------------------------

@pytest.mark.parametrize(
    "secret_type,secret_value",
    BASELINE_CASES,
    ids=[c[0] for c in BASELINE_CASES],
)
def test_baseline_secret_detected(secret_type: str, secret_value: str) -> None:
    """Each baseline secret pattern must be caught by detect-secrets or gitleaks."""
    detected, scanner = _detect(secret_value)
    assert detected, (
        f"MISSED baseline secret [{secret_type}]: neither detect-secrets nor gitleaks "
        f"flagged this pattern. This is a false-negative gap in FR-5.1 coverage."
    )


# ---------------------------------------------------------------------------
# P0-001b — Adversarial parametrized tests (xfail where tools are known-limited)
# ---------------------------------------------------------------------------

@pytest.mark.parametrize(
    "secret_type,secret_value,expected",
    ADVERSARIAL_CASES,
    ids=[c[0] for c in ADVERSARIAL_CASES],
)
def test_adversarial_secret(secret_type: str, secret_value: str, expected: bool) -> None:
    """
    Adversarial patterns. Cases marked expected=False are known tool gaps
    (hex/reversed/url-encoded secrets are outside current tooling scope).
    These are documented, not blocking.
    """
    detected, _scanner = _detect(secret_value)
    if not expected:
        # Known gap — document it but don't fail CI
        pytest.xfail(
            f"Known gap: [{secret_type}] obfuscation technique not detected by current tools. "
            f"Tracking for future tooling improvements."
        )
    assert detected, (
        f"MISSED adversarial secret [{secret_type}]: expected detection but tools missed it."
    )


# ---------------------------------------------------------------------------
# P0-001 GATE — Overall baseline detection rate ≥99.5%
# ---------------------------------------------------------------------------

def test_baseline_detection_rate_gate() -> None:
    """
    P0-001 pass gate: baseline detection rate must be ≥99.5% (FR-5.1).
    Emits JSON result in the 7F test output contract format.
    """
    start = time.time()

    results_detail = []
    detected = 0

    for secret_type, secret_value in BASELINE_CASES:
        is_detected, scanner = _detect(secret_value)
        if is_detected:
            detected += 1
        results_detail.append({
            "secret_type": secret_type,
            "detected": is_detected,
            "scanner": scanner,
        })

    total = len(BASELINE_CASES)
    rate = (detected / total * 100) if total > 0 else 0.0
    passed = rate >= 99.5
    duration_ms = int((time.time() - start) * 1000)

    report = {
        "test_id": "P0-001",
        "requirement": "FR-5.1",
        "description": "Secret detection rate ≥99.5% across baseline patterns",
        "status": "PASS" if passed else "FAIL",
        "message": f"Baseline detection rate: {detected}/{total} ({rate:.2f}%)",
        "duration_ms": duration_ms,
        "detail": {
            "detected": detected,
            "total": total,
            "rate_pct": round(rate, 2),
            "threshold_pct": 99.5,
            "cases": results_detail,
        },
    }

    print(f"\n{json.dumps(report, indent=2)}")

    assert passed, (
        f"P0-001 FAIL: baseline detection rate {rate:.2f}% < 99.5% threshold. "
        f"Missed {total - detected}/{total} patterns. "
        f"See JSON output for which patterns were not caught."
    )
