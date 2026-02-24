# Secret Detection Validation

## Overview
Seven Fortunas maintains ≥99.5% secret detection rate through comprehensive testing and quarterly validation.

## Targets

- **Detection Rate:** ≥99.5%
- **False Negative Rate:** ≤0.5%
- **False Positive Rate:** ≤5%
- **Detection Latency:** <30 seconds (pre-commit), <5 minutes (GitHub Actions)

## Test Suites

### Baseline Test Suite
**Location:** `tests/secret-detection/baseline/test-patterns.txt`
**Cases:** ~138 test cases covering:
- GitHub tokens (40 cases)
- AWS credentials (20 cases)
- API keys (40 cases)
- Database connection strings (10 cases)
- Private keys (10 cases)
- Passwords in URLs (5 cases)
- Environment variables (5 cases)
- Slack webhooks (3 cases)
- High-entropy strings (5 cases)

**Run:** `./tests/secret-detection/run-baseline-tests.sh`

### Adversarial Test Suite (Day 3)
**Location:** `tests/secret-detection/adversarial/`
**Owner:** Jorge
**Cases:** 20+ scenarios testing:
- Obfuscation techniques
- Context variations
- Edge cases
- False positive scenarios
- Timing challenges

**Target:** ≥99% detection rate

## Detection Tools

Seven Fortunas uses a defense-in-depth approach with multiple tools:

1. **gitleaks** (primary)
   - Pre-commit hook
   - GitHub Actions
   - Pattern-based detection

2. **TruffleHog** (secondary)
   - GitHub Actions
   - Entropy-based detection
   - Regex patterns

3. **detect-secrets** (tertiary)
   - Pre-commit hook
   - Plugin-based architecture

4. **GitHub Advanced Security** (optional)
   - Code scanning
   - Secret scanning
   - Push protection

## Validation Process

### Baseline Validation (Automated)
```bash
# Run baseline test suite
./tests/secret-detection/run-baseline-tests.sh

# View results
cat tests/secret-detection/results/baseline-test-TIMESTAMP.json
```

### Quarterly Validation (Scheduled)
```bash
# Run full validation (baseline + adversarial)
./scripts/quarterly-secret-detection-validation.sh
```

**Schedule:** Quarterly (every 3 months)
**Trigger:** After pattern updates or tool version upgrades

### Adversarial Testing (On-Demand)
```bash
# Jorge's adversarial tests (Day 3)
./tests/secret-detection/run-adversarial-tests.sh
```

## Detection Rate Calculation

```
Detection Rate = (Secrets Detected / Total Secrets) × 100
False Negative Rate = (Secrets Missed / Total Secrets) × 100
False Positive Rate = (False Alarms / Total Detections) × 100
```

**Example:**
- Total secrets: 138
- Detected: 137
- Missed: 1
- Detection rate: 99.28%
- False negative rate: 0.72%

## Detection Latency

### Pre-commit Hook
- **Target:** <30 seconds
- **Measurement:** `time pre-commit run gitleaks`

### GitHub Actions
- **Target:** <5 minutes
- **Measurement:** GitHub Actions workflow duration

## Known Gaps

Document any known detection gaps:

| Gap | Description | Mitigation | Status |
|-----|-------------|------------|--------|
| Obfuscated Base64 | Secrets encoded multiple times | Manual review in sensitive files | Open |
| Image EXIF | Secrets in image metadata | Separate EXIF scanner (Phase 3) | Planned |

## Pattern Updates

### When to Update Patterns
- After detecting a false negative in production
- After quarterly validation identifies gaps
- After new secret types are introduced (new API provider)
- After tool version upgrades

### Update Process
1. Add new pattern to detection tools:
   - `gitleaks.toml` (gitleaks)
   - `.trufflehog.yaml` (TruffleHog)
   - `.secrets.baseline` (detect-secrets)
2. Add test case to `baseline/test-patterns.txt`
3. Run baseline validation
4. Commit changes if detection rate maintained

## Metrics Dashboard Integration

Detection rate metrics feed into the security dashboard:

- Current detection rate (%)
- False negative rate (%)
- Last validation date
- Trend over time (quarterly comparisons)

## Troubleshooting

### Low Detection Rate
1. Check if tools are up to date: `gitleaks version`, `trufflehog --version`
2. Review missed secrets: manually inspect test patterns not detected
3. Update patterns in tool configurations
4. Re-run validation

### High False Positive Rate
1. Review false positives log
2. Add exceptions to tool configurations
3. Use `.gitignore` patterns for test/example files
4. Re-run validation

### Slow Detection (>30s pre-commit)
1. Profile pre-commit hook: `time pre-commit run`
2. Reduce file scope (e.g., skip `node_modules/`)
3. Consider disabling entropy-based detection for speed
4. Optimize regex patterns

## References

- [gitleaks Configuration](https://github.com/gitleaks/gitleaks#configuration)
- [TruffleHog Documentation](https://github.com/trufflesecurity/trufflehog)
- [detect-secrets Guide](https://github.com/Yelp/detect-secrets)
- Seven Fortunas Secret Detection (FEATURE_019)

---

**Last Updated:** 2026-02-17
**Owner:** Jorge (VP AI-SecOps)
**Review Cycle:** Quarterly
