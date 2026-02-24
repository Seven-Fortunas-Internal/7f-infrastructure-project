# Data Migration & Versioning - Seven Fortunas Infrastructure

**Version:** 1.0
**Last Updated:** 2026-02-24
**Priority:** P2
**Target:** RTO <30 minutes for schema changes

---

## Overview

All data formats in the Seven Fortunas infrastructure support backward-compatible changes with automated migration and rollback support.

---

## Data Format Versioning

### Schema Version Header

All JSON data files include a version field:

```json
{
  "schema_version": "1.0.0",
  "data": {
    ...
  }
}
```

**Version format:** Semantic Versioning (MAJOR.MINOR.PATCH)
- **MAJOR:** Breaking changes (incompatible with old versions)
- **MINOR:** New fields (backward-compatible)
- **PATCH:** Bug fixes (backward-compatible)

---

## Migration Strategy

### Backward-Compatible Changes (Preferred)

**Add new fields with defaults:**

```json
// Schema v1.0.0
{
  "schema_version": "1.0.0",
  "name": "Example",
  "value": 42
}

// Schema v1.1.0 (backward-compatible)
{
  "schema_version": "1.1.0",
  "name": "Example",
  "value": 42,
  "new_field": "default_value"  // New field with default
}
```

**Old code can still read v1.1.0 data** (ignores unknown fields)

---

### Breaking Changes (Requires Migration)

**Rename or remove fields:**

```json
// Schema v1.0.0
{
  "schema_version": "1.0.0",
  "old_name": "value"
}

// Schema v2.0.0 (breaking change - requires migration)
{
  "schema_version": "2.0.0",
  "new_name": "value"  // Field renamed
}
```

**Migration required** to convert v1.0.0 → v2.0.0

---

## Automated Migration

### Migration Script Pattern

```bash
#!/bin/bash
# migrate-data-v1-to-v2.sh

set -e

echo "Migrating data from schema v1.0.0 to v2.0.0..."

# Backup original data
cp data.json data.json.backup.$(date +%Y%m%d-%H%M%S)

# Run migration with jq
jq '
  if .schema_version == "1.0.0" then
    {
      schema_version: "2.0.0",
      data: (.data | {
        new_name: .old_name  # Rename field
      })
    }
  else
    .  # Already migrated, no change
  end
' data.json > data.json.tmp

# Validate migrated data
if jq empty data.json.tmp 2>/dev/null; then
  mv data.json.tmp data.json
  echo "Migration successful"
else
  echo "Migration failed - validation error"
  rm data.json.tmp
  exit 1
fi
```

---

### Rollback Procedure

```bash
#!/bin/bash
# rollback-migration.sh

set -e

BACKUP=$(ls -t data.json.backup.* | head -1)

if [ -z "$BACKUP" ]; then
  echo "No backup found - cannot rollback"
  exit 1
fi

echo "Rolling back to: $BACKUP"
cp "$BACKUP" data.json
echo "Rollback complete"
```

**RTO:** <5 minutes for file copy

---

## Version Compatibility Matrix

| Schema Version | Can Read | Can Write |
|----------------|----------|-----------|
| v1.0.0 | v1.0.0 | v1.0.0 |
| v1.1.0 | v1.0.0, v1.1.0 | v1.1.0 |
| v2.0.0 | v2.0.0 | v2.0.0 |

**Backward compatibility:** v1.1.0 can read v1.0.0 (ignores missing fields)
**Breaking change:** v2.0.0 cannot read v1.x.x (requires migration)

---

## Data Files Requiring Versioning

### 1. feature_list.json

**Current version:** Implicit v1.0.0
**Future migrations:**
- Add new fields (backward-compatible)
- Change status values (breaking - requires migration)

**Migration RTO:** <10 minutes (single file, ~65KB)

---

### 2. Dashboard Data (JSON)

**Example:** dashboards/data/ai-advancements.json

**Current version:** Implicit v1.0.0
**Future migrations:**
- Add new data sources (backward-compatible)
- Change data structure (breaking - requires migration)

**Migration RTO:** <15 minutes (7 dashboards)

---

### 3. Metrics Files (JSON)

**Location:** metrics/metrics-*.json

**Current version:** Implicit v1.0.0
**Future migrations:**
- Add new metrics (backward-compatible)
- Remove metrics (breaking - archive old data)

**Migration RTO:** <30 minutes (90 days retention = ~360 files)

---

## Migration Testing

### Pre-Migration Checklist

- [ ] Backup all data files
- [ ] Test migration script on copy
- [ ] Validate migrated data (JSON syntax, schema)
- [ ] Test rollback procedure
- [ ] Document migration steps
- [ ] Notify team of downtime (if any)

---

### Migration Success Criteria

1. ✅ All data files migrated successfully
2. ✅ No data loss or corruption
3. ✅ New schema validated
4. ✅ Old backups retained
5. ✅ RTO <30 minutes achieved

---

## Rollback Support

### Automatic Backups

```bash
# Before any schema change
for file in *.json; do
  cp "$file" "$file.backup.$(date +%Y%m%d-%H%M%S)"
done
```

**Retention:** 30 days
**Location:** Same directory with `.backup.*` suffix

---

### Rollback Testing

```bash
# Test rollback procedure monthly
./scripts/rollback-migration.sh

# Verify data integrity after rollback
jq empty data.json
```

---

## Success Criteria

NFR-10.1 is satisfied when:

1. ✅ Schema versioning documented
2. ✅ Migration script pattern provided
3. ✅ Rollback procedure documented
4. ✅ RTO target <30min for schema changes
5. ✅ Backward compatibility strategy defined

---

**Owner:** Jorge (VP AI-SecOps)
**Review Date:** 2026-03-24 (monthly review)
