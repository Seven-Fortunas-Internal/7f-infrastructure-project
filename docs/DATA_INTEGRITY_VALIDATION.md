# Data Integrity & Validation - Seven Fortunas Infrastructure

**Version:** 1.0
**Last Updated:** 2026-02-24
**Priority:** P1 (Critical)
**Target:** Zero data corruption incidents

---

## Overview

All data read and write operations include integrity validation to prevent corruption. JSON schema validation, checksums, and atomic writes ensure data reliability.

---

## Validation Strategy

### 1. JSON Schema Validation

**On write:**
```python
import json
import jsonschema

schema = {
    "type": "object",
    "properties": {
        "id": {"type": "string"},
        "status": {"enum": ["pending", "pass", "fail", "blocked"]},
        "attempts": {"type": "integer", "minimum": 0}
    },
    "required": ["id", "status", "attempts"]
}

# Validate before writing
try:
    jsonschema.validate(data, schema)
    with open('feature_list.json', 'w') as f:
        json.dump(data, f, indent=2)
except jsonschema.ValidationError as e:
    print(f"Validation failed: {e}")
    # Do not write invalid data
```

**On read:**
```python
# Validate JSON syntax
try:
    with open('feature_list.json', 'r') as f:
        data = json.load(f)
except json.JSONDecodeError as e:
    print(f"Corrupted JSON: {e}")
    # Attempt recovery from backup
```

---

### 2. Atomic Writes (Prevent Partial Corruption)

**Pattern: Write-Validate-Move**
```bash
# Write to temporary file
jq '.features[0].status = "pass"' feature_list.json > feature_list.json.tmp

# Validate temporary file
if jq empty feature_list.json.tmp 2>/dev/null; then
  # Valid - atomically replace original
  mv feature_list.json.tmp feature_list.json
else
  # Invalid - discard and keep original
  rm feature_list.json.tmp
  echo "ERROR: Invalid JSON, write aborted"
  exit 1
fi
```

**Benefits:**
- Original file never corrupted
- Power loss during write = original file intact
- Validation failure = no data loss

---

### 3. Checksums (Detect Silent Corruption)

**Generate checksum after write:**
```bash
# After writing data
sha256sum feature_list.json > feature_list.json.sha256

# Before reading data
if sha256sum -c feature_list.json.sha256 2>/dev/null; then
  echo "Data integrity verified"
else
  echo "WARNING: Data corruption detected"
  # Restore from backup
fi
```

---

## Validation Rules

### feature_list.json

**Required fields:**
```json
{
  "features": [
    {
      "id": "string (required)",
      "name": "string (required)",
      "status": "enum (pending|pass|fail|blocked)",
      "attempts": "integer >= 0",
      "verification_results": {
        "functional": "string",
        "technical": "string",
        "integration": "string"
      }
    }
  ]
}
```

**Validation script:**
```python
def validate_feature_list(data):
    assert "features" in data
    assert isinstance(data["features"], list)

    for feature in data["features"]:
        assert "id" in feature
        assert "status" in feature
        assert feature["status"] in ["pending", "pass", "fail", "blocked"]
        assert feature["attempts"] >= 0

    return True
```

---

### Dashboard JSON Data

**Required fields:**
```json
{
  "timestamp": "ISO 8601 string",
  "items": [
    {
      "title": "string",
      "url": "valid URL",
      "date": "ISO 8601 string"
    }
  ]
}
```

**Validation:**
```python
from datetime import datetime

def validate_dashboard_data(data):
    # Validate timestamp
    datetime.fromisoformat(data["timestamp"].replace('Z', '+00:00'))

    # Validate items
    for item in data["items"]:
        assert "title" in item
        assert "url" in item
        assert item["url"].startswith("http")

    return True
```

---

## Error Handling

### Corruption Detection

**Signs of corruption:**
- JSON syntax error (invalid braces, quotes)
- Missing required fields
- Invalid enum values
- Negative integers where positive expected
- Malformed timestamps/URLs

**Response:**
1. **Log error** (structured logging)
2. **Restore from backup**
3. **Alert if automatic recovery fails**

---

### Backup & Recovery

**Automatic backup before writes:**
```bash
# Before any destructive operation
cp feature_list.json feature_list.json.backup.$(date +%Y%m%d-%H%M%S)

# Modify file
jq '.features[0].status = "pass"' feature_list.json.backup.* > feature_list.json.tmp
mv feature_list.json.tmp feature_list.json
```

**Recovery from backup:**
```bash
# Find most recent backup
BACKUP=$(ls -t feature_list.json.backup.* | head -1)

# Restore
cp "$BACKUP" feature_list.json
echo "Restored from: $BACKUP"
```

---

## Success Criteria

NFR-10.2 is satisfied when:

1. ✅ JSON validation on all read/write operations
2. ✅ Atomic write pattern implemented
3. ✅ Backup before destructive operations
4. ✅ Corruption detection and recovery documented
5. ✅ Target: Zero data corruption incidents

---

**Owner:** Jorge (VP AI-SecOps)
**Review Date:** 2026-03-24 (monthly review)
