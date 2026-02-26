# Secret Detection Testing

NFR-1.1: Maintain ≥99.5% secret detection rate with ≤0.5% false negative rate.

## Test Suite

**Location:** `tests/secret-detection/test_secret_patterns.py`

**Coverage:**
- 100+ baseline patterns (GitHub, AWS, Anthropic, OpenAI, Slack, generic)
- 20+ adversarial patterns (split, encoded, obfuscated, embedded)

## Running Tests

```bash
# Install dependencies
pip install detect-secrets gitleaks

# Run test suite
python3 tests/secret-detection/test_secret_patterns.py

# Expected output:
# Overall Detection Rate: X/Y (Z%)
# Target: ≥99.5% detection, ≤0.5% false negative
```

## Test Categories

### Baseline Patterns (100+ cases)

1. **GitHub tokens** - PAT, OAuth, user tokens
2. **AWS credentials** - Access keys, secret keys
3. **AI API keys** - Anthropic, OpenAI
4. **Slack tokens** - Bot tokens, webhooks
5. **Generic secrets** - API keys, passwords, bearer tokens
6. **Encoded secrets** - Base64, hex
7. **Private keys** - RSA, SSH
8. **Database credentials** - PostgreSQL, MySQL
9. **JWT tokens**

### Adversarial Patterns (20+ cases)

1. **Split secrets** - Secret constructed from parts
2. **Encoded variants** - Hex, URL-encoded
3. **Obfuscated** - Reversed, mangled
4. **Environment variables** - .env files
5. **Embedded** - JSON, YAML
6. **Comments** - Commented out but still sensitive
7. **Multi-line** - Spans multiple lines

## Quarterly Validation

**Schedule:** Every 3 months (Jan, Apr, Jul, Oct)

**Process:**

1. Run test suite
2. Review detection rate
3. Update patterns if needed
4. Document gaps
5. Report to security dashboard

**Automation:**

```yaml
# .github/workflows/quarterly-secret-detection-validation.yml
name: Quarterly Secret Detection Validation

on:
  schedule:
    # Run on 1st of Jan, Apr, Jul, Oct at 9am UTC
    - cron: '0 9 1 1,4,7,10 *'
  workflow_dispatch:

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install tools
        run: |
          pip install detect-secrets
          # gitleaks already in GitHub Actions
      - name: Run test suite
        run: python3 tests/secret-detection/test_secret_patterns.py
      - name: Upload results
        uses: actions/upload-artifact@v4
        with:
          name: secret-detection-results
          path: results/
```

## Known Gaps

**Documented gaps (acceptable):**

1. **Split secrets** - Constructed programmatically
2. **Custom encoding** - Non-standard encodings
3. **Dynamically generated** - Secrets created at runtime

**Pattern updates needed:**

- Review false negatives quarterly
- Add new patterns as services emerge
- Update regex for API changes

## Detection Rate Metrics

**Current rate:** See latest test run

**Historical rates:**
- 2026-02-25: 95.0% (baseline before full test suite)
- 2026-03-01: Target ≥99.5% (after pattern updates)

**False negative log:**

Track missed secrets:

```json
{
  "date": "2026-02-25",
  "secret_type": "split_github_token",
  "reason": "Constructed from string concatenation",
  "action": "Document as known gap"
}
```

## Integration

**Security Dashboard:**

Detection rate displayed in:
- Dashboards: `dashboards/compliance/index.html`
- Metric: `secret_detection_rate`
- Update: Daily via workflow

**Alerting:**

If detection rate < 99.5%:
- Create GitHub issue
- Notify #security channel
- Schedule pattern review

## References

- [Test Suite](../../tests/secret-detection/test_secret_patterns.py)
- [Secret Scanning Workflow](../../.github/workflows/secret-scanning.yml)
- [Quarterly Validation Workflow](../../.github/workflows/quarterly-secret-detection-validation.yml)

---

**Target:** ≥99.5% detection, ≤0.5% false negative
**Status:** Implemented
**Owner:** Jorge (VP AI-SecOps)
**Last Updated:** 2026-02-25
