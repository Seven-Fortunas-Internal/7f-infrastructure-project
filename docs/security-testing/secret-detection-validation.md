# Secret Detection Rate Validation

## Overview

The Seven Fortunas secret detection system maintains a ≥99.5% detection rate with ≤0.5% false negative rate through regular testing and validation.

**Testing Framework:** NFR-1.1
**Detection System:** FR-5.1 (4-layer defense)

---

## Test Suite

### Baseline Test Suite (~100 cases)

**Location:** `tests/secret-detection/test-suite.sh`

**Test Categories:**
1. **GitHub Patterns** (20 tests)
   - Personal Access Tokens (ghp_*)
   - OAuth Tokens (gho_*)
   - App Tokens (ghu_*, ghs_*)
   - Fine-grained PATs

2. **AWS Credentials** (15 tests)
   - Access Keys (AKIA*)
   - Secret Access Keys
   - Session Tokens
   - KMS Keys

3. **API Keys** (25 tests)
   - Anthropic (sk-ant-*)
   - OpenAI (sk-proj-*, sk-*)
   - Stripe (sk_faketest_*, sk_test_*)
   - Slack (xoxb-*, xoxp-*)

4. **Private Keys** (15 tests)
   - SSH Private Keys
   - GPG Private Keys
   - TLS/SSL Certificates
   - JWT Signing Keys

5. **Other Secrets** (15 tests)
   - Database Connection Strings
   - Webhook URLs
   - OAuth Client Secrets
   - Service Account Keys

6. **Edge Cases** (10 tests)
   - Obfuscated secrets
   - Base64-encoded secrets
   - Secrets in environment variable format
   - Secrets in configuration files

**Running Tests:**
```bash
# Run full test suite
./tests/secret-detection/test-suite.sh

# View results
cat tests/secret-detection/test-results.json
```

---

## Jorge's Adversarial Testing (Day 3)

### Test Scenarios (20+)

**Purpose:** Attempt to bypass the 4-layer defense system with real-world attack patterns.

**Schedule:** MVP Day 3, then quarterly

#### Category 1: Obfuscation Attempts (5 tests)
1. **Base64 Encoding**
   ```
   api_key = base64_decode("c2stYW50LWFwaTA...")
   ```

2. **String Concatenation**
   ```python
   key = "ghp_" + "1234567890abcdefghij" + "klmnopqrstuvwxyz"
   ```

3. **Character Escaping**
   ```
   token = "gh\x70_1234567890..."
   ```

4. **Environment Variable Reference**
   ```bash
   export API_KEY="sk-ant-api03-..."
   ```

5. **Comment Hiding**
   ```python
   # API_KEY=ghp_1234567890abcdefghijklmnopqrstuvwxyz
   ```

#### Category 2: Format Variations (5 tests)
6. **JSON Format**
   ```json
   {"anthropic_key": "sk-ant-api03-..."}
   ```

7. **YAML Format**
   ```yaml
   credentials:
     api_key: sk-ant-api03-...
   ```

8. **TOML Format**
   ```toml
   [api]
   key = "sk-ant-api03-..."
   ```

9. **INI Format**
   ```ini
   [credentials]
   api_key=sk-ant-api03-...
   ```

10. **XML Format**
    ```xml
    <config><api_key>sk-ant-api03-...</api_key></config>
    ```

#### Category 3: Steganography (5 tests)
11. **Whitespace Encoding**
12. **Unicode Homoglyphs**
13. **Image EXIF Data**
14. **Zip File Comments**
15. **PDF Metadata**

#### Category 4: Real-World Patterns (5 tests)
16. **.env Files**
17. **Docker Secrets**
18. **Kubernetes ConfigMaps**
19. **Terraform Variables**
20. **CI/CD Config Files**

### Running Adversarial Tests

```bash
# Create adversarial test file
cat > /tmp/adversarial-test.txt <<EOF
# Test 1: Base64
api_key = "$(echo 'sk-ant-api03-abcdefg' | base64)"

# Test 2: Concatenation
key = "ghp_" + "1234567890abcdefghijklmnopqrstuvwxyz"
EOF

# Test with pre-commit hooks
git add /tmp/adversarial-test.txt
# Should be blocked

# Document results
echo "Test X: [DETECTED/MISSED] - Layer Y caught it" >> adversarial-results.txt
```

---

## Detection Rate Metrics

### Target Metrics

| Metric | Target | Status |
|--------|--------|--------|
| **Detection Rate** | ≥99.5% | Monitored quarterly |
| **False Negative Rate** | ≤0.5% | Monitored quarterly |
| **False Positive Rate** | ≤5% | Monitored quarterly |
| **Detection Latency (Pre-commit)** | <30 seconds | Measured daily |
| **Detection Latency (GitHub Actions)** | <5 minutes | Measured daily |

### Measurement Procedure

**Formula:**
```
Detection Rate = (Detected Secrets / Total Secrets) × 100%
False Negative Rate = (Missed Secrets / Total Secrets) × 100%
False Positive Rate = (False Alarms / Total Scans) × 100%
```

**Data Collection:**
```bash
# Extract metrics from test results
DETECTED=$(jq '.detected' tests/secret-detection/test-results.json)
TOTAL=$(jq '.total_tests' tests/secret-detection/test-results.json)
DETECTION_RATE=$(jq '.detection_rate' tests/secret-detection/test-results.json)

# Log to security dashboard
echo "{\"date\": \"$(date -u +%Y-%m-%d)\", \"detection_rate\": $DETECTION_RATE}" \
  >> security-metrics.jsonl
```

---

## Quarterly Validation

### Schedule

- **Q1 2026:** Week of March 24
- **Q2 2026:** Week of June 23
- **Q3 2026:** Week of September 22
- **Q4 2026:** Week of December 21

### Validation Process

**1. Update Pattern Database (Week 1)**
```bash
# Pull latest patterns from GitHub Advisory Database
gh api /meta | jq '.secret_scanning_patterns' > patterns-update.json

# Merge with existing patterns
./scripts/merge-secret-patterns.sh
```

**2. Run Baseline Test Suite (Week 2)**
```bash
# Run full test suite
./tests/secret-detection/test-suite.sh

# Review results
if [ $(jq '.detection_rate' test-results.json) >= 99.5 ]; then
  echo "PASS"
else
  echo "FAIL - Review missed patterns"
fi
```

**3. Jorge's Adversarial Testing (Week 3)**
```bash
# Run adversarial scenarios
./tests/secret-detection/adversarial-tests.sh

# Document results
git add adversarial-results-Q1-2026.md
git commit -m "docs: Q1 2026 adversarial test results"
```

**4. Update Documentation (Week 4)**
```bash
# Update known gaps
cat >> docs/security-testing/known-gaps.md <<EOF
## Q1 2026 Gaps
- Pattern X: Missed in 2/100 tests
- Mitigation: Added custom regex
EOF

# Update detection patterns
git add .github/workflows/secret-scanning.yml
git commit -m "feat: Add pattern for X detection (Q1 2026 validation)"
```

---

## Known Gaps

### Current Limitations

1. **Obfuscation Detection** (95% detection)
   - Base64-encoded secrets: 98% detection
   - String concatenation: 90% detection
   - Mitigation: Pattern entropy analysis

2. **Proprietary API Key Formats** (90% detection)
   - Custom vendor formats
   - Mitigation: Manual pattern addition after discovery

3. **Secrets in Binary Files** (0% detection)
   - Images, PDFs, zip files
   - Mitigation: File type filtering (binary files rejected)

### Gap Tracking

**Process:**
1. When secret bypasses detection → log in `false-negatives.jsonl`
2. Quarterly review → prioritize high-severity gaps
3. Add new patterns → re-run validation
4. Document mitigation → update security dashboard

---

## Integration with Security Dashboard

### Metrics Displayed

**Dashboard:** `dashboards/security/`

**Metrics:**
- Detection rate (line chart, last 4 quarters)
- False negative rate (line chart, last 4 quarters)
- Pattern coverage (pie chart by category)
- Adversarial test results (table)

**Data Feed:**
```bash
# Export metrics for dashboard
jq '{
  detection_rate: .detection_rate,
  false_negative_rate: .false_negative_rate,
  timestamp: .timestamp
}' tests/secret-detection/test-results.json \
  > dashboards/security/data/detection-metrics-latest.json
```

---

## See Also

- [FR-5.1: Secret Detection & Prevention](../../scripts/setup-secret-detection.sh)
- [Security Dashboard](../../dashboards/security/README.md)
- [GitHub Secret Scanning Patterns](https://github.com/github/gh-secret-scanning-patterns)
- [TruffleHog Documentation](https://github.com/trufflesecurity/trufflehog)

---

**Version:** 1.0
**Last Updated:** 2026-02-24
**Owner:** Jorge (VP AI-SecOps)
**Next Validation:** Q2 2026 (Week of June 23)
