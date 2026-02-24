# Adversarial Secret Detection Tests

## Purpose
Jorge's adversarial testing (20+ scenarios) to validate secret detection under challenging conditions.

## Test Categories

### 1. Obfuscation Techniques
- Base64 encoded secrets
- Hex encoded secrets
- URL encoded secrets
- Split secrets across multiple lines
- Secrets in comments

### 2. Context Variations
- Secrets in JSON
- Secrets in YAML
- Secrets in environment files
- Secrets in configuration files
- Secrets in scripts

### 3. Edge Cases
- Very long secrets (>1000 characters)
- Secrets with special characters
- Secrets in binary files
- Secrets in compressed archives
- Secrets in image EXIF data

### 4. False Positive Tests
- Placeholder secrets (REPLACE_ME, YOUR_API_KEY_HERE)
- Test credentials (test, example, dummy)
- Documentation examples
- Template variables

### 5. Timing Tests
- Large files (>10MB) with secrets
- Many secrets in single file (>100)
- Secrets at end of very large files

## Execution (Day 3)

Jorge will create test cases in `adversarial-tests.txt` and run:

```bash
./run-adversarial-tests.sh
```

Target: ≥99% detection rate on adversarial tests

## Results

Results saved to: `tests/secret-detection/results/adversarial-test-TIMESTAMP.json`
