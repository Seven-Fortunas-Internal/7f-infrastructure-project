# Secret Detection Tests

Test suite for NFR-1.1: Maintain ≥99.5% secret detection rate.

## Usage

```bash
# Run test suite
python3 test_secret_patterns.py

# Expected: ≥99.5% detection rate
```

## Test Coverage

- 100+ baseline patterns
- 20+ adversarial patterns
- Quarterly validation

## References

- [Testing Guide](../../docs/security/secret-detection-testing.md)
- [Secret Scanning Workflow](../../.github/workflows/secret-scanning.yml)
