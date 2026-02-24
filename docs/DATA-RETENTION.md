# Dashboard Data Retention & Historical Analysis (NFR-3.3)

**Version:** 1.0
**Last Updated:** 2024-02-24
**Requirement:** NFR-3.3 - Data Growth (Historical Analysis)

## Requirement

System SHALL store 12+ months of dashboard data for trend analysis.

**Target:** 12 months of weekly snapshots
**Measurement:** `dashboards/*/data/archive/` directory size

## Overview

The Seven Fortunas infrastructure implements automated weekly snapshots of dashboard data to enable historical trend analysis. This supports compliance auditing, performance tracking, and business intelligence.

## Snapshot System

### 1. Snapshot Frequency

**Schedule:** Weekly (Sundays at 00:00 UTC)
**Automation:** GitHub Actions workflow
**Retention:** 12 months (52 weekly snapshots)

### 2. What Gets Snapshotted

For each dashboard in `dashboards/`:
- Dashboard source files (`src/`)
- Metrics data (`metrics.json`)
- Snapshot metadata (timestamp, size, git commit)

### 3. Archive Structure

```
dashboards/
├── ai/
│   └── data/
│       └── archive/
│           ├── 2026-02-24/
│           │   ├── src/
│           │   ├── metrics.json
│           │   └── snapshot-metadata.json
│           ├── 2026-03-02/
│           ├── 2026-03-09/
│           └── ... (52 weeks total)
├── compliance/
│   └── data/archive/...
├── edutech/
│   └── data/archive/...
└── ... (all dashboards)
```

### 4. Snapshot Metadata

Each snapshot includes metadata for tracking:

```json
{
  "dashboard": "ai",
  "snapshot_date": "2026-02-24",
  "snapshot_time": "2026-02-24T21:42:51Z",
  "files_captured": 2,
  "size_bytes": 12126,
  "git_commit": "c6baa27043d8052d741a6f320eb04e0005c1b595"
}
```

## Usage

### Create Manual Snapshot

```bash
./scripts/create-dashboard-snapshot.sh
```

**Output:**
- Creates timestamped snapshot for all dashboards
- Reports snapshot size and file count
- Checks retention policy compliance

### View Snapshot History

```bash
# List all snapshots for a dashboard
ls -1 dashboards/ai/data/archive/

# View snapshot metadata
cat dashboards/ai/data/archive/2026-02-24/snapshot-metadata.json

# Calculate total archive size
du -sh dashboards/ai/data/archive/
```

### Compare Snapshots (Trend Analysis)

```bash
# Compare two snapshots
diff -r \
  dashboards/ai/data/archive/2026-02-24/src/ \
  dashboards/ai/data/archive/2026-03-02/src/

# Track metric changes over time
for snapshot in dashboards/ai/data/archive/*/; do
  date=$(basename "$snapshot")
  metrics=$(jq '.some_metric' "$snapshot/metrics.json" 2>/dev/null || echo "N/A")
  echo "$date: $metrics"
done
```

### Restore from Snapshot

```bash
# Restore dashboard from a specific snapshot
SNAPSHOT_DATE="2026-02-24"
DASHBOARD="ai"

cp -r "dashboards/${DASHBOARD}/data/archive/${SNAPSHOT_DATE}/src" \
      "dashboards/${DASHBOARD}/src-restored"

echo "Restored to dashboards/${DASHBOARD}/src-restored"
```

## Automated Snapshot Workflow

**Workflow:** `.github/workflows/dashboard-data-snapshot.yml`

### Schedule
- **Trigger:** Every Sunday at 00:00 UTC
- **Manual:** Can be triggered via GitHub Actions UI

### Steps
1. **Create Snapshot** - Run `create-dashboard-snapshot.sh`
2. **Commit to Repository** - Add snapshots to Git
3. **Check Retention** - Report snapshot counts and sizes
4. **Cleanup Old Data** - Remove snapshots older than 12 months (52 weeks)

### Retention Policy
- **Keep:** Last 52 snapshots (12 months of weekly data)
- **Remove:** Snapshots older than 52 weeks
- **Alert:** If total snapshots exceed 100 (>2 years)

## Storage Projections

### Current State (Week 1)
- **Dashboards:** 7
- **Snapshots per dashboard:** 1
- **Average snapshot size:** ~10 KB
- **Total archive size:** ~70 KB

### Projected at 12 Months (52 Weeks)
- **Dashboards:** 7
- **Snapshots per dashboard:** 52
- **Average snapshot size:** ~10 KB
- **Total archive size:** ~3.6 MB (7 × 52 × 10 KB)

### Projected at 24 Months (With Retention)
- **Snapshots retained:** 52 (automatic cleanup)
- **Total archive size:** ~3.6 MB (constant with retention policy)

**Assessment:** Negligible storage impact ✅

## Monitoring & Alerts

### Weekly Snapshot Report

Included in workflow output:
```
=== Retention Policy Check ===
Target: 12 months (52 weekly snapshots)

ai: 4 snapshots, 40K total
compliance: 4 snapshots, 32K total
edutech: 4 snapshots, 32K total
...
```

### Storage Alerts

**Warning if:**
- Snapshot count exceeds 52 (retention policy not working)
- Total archive size exceeds 10 MB (unusually large snapshots)
- Snapshot creation fails (workflow error)

**GitHub Actions will:**
- Comment on failed workflow runs
- Send email notifications (if configured)

## Trend Analysis Use Cases

### 1. Performance Tracking
```bash
# Extract Lighthouse scores over time
for snapshot in dashboards/ai/data/archive/*/; do
  date=$(basename "$snapshot")
  score=$(jq '.lighthouse.performance' "$snapshot/metrics.json" 2>/dev/null || echo "N/A")
  echo "$date: $score"
done | sort
```

### 2. Compliance Posture
```bash
# Track SOC 2 compliance over time
for snapshot in dashboards/compliance/data/archive/*/; do
  date=$(basename "$snapshot")
  compliance=$(jq '.soc2.compliance_pct' "$snapshot/metrics.json" 2>/dev/null || echo "N/A")
  echo "$date: $compliance%"
done | sort
```

### 3. Code Growth
```bash
# Track dashboard code size over time
for snapshot in dashboards/ai/data/archive/*/; do
  date=$(basename "$snapshot")
  lines=$(wc -l "$snapshot/src"/*.tsx 2>/dev/null | tail -1 | awk '{print $1}' || echo "0")
  echo "$date: $lines lines of code"
done | sort
```

### 4. Audit Trail
```bash
# Show which git commit each snapshot corresponds to
for snapshot in dashboards/*/data/archive/*/; do
  dashboard=$(echo "$snapshot" | cut -d'/' -f2)
  date=$(basename "$snapshot")
  commit=$(jq -r '.git_commit' "$snapshot/snapshot-metadata.json" 2>/dev/null || echo "unknown")
  echo "$dashboard @ $date: $commit"
done | sort
```

## Verification

### Functional Verification
```bash
# Test snapshot creation
./scripts/create-dashboard-snapshot.sh

# Verify archive directory exists
ls -la dashboards/ai/data/archive/

# Verify metadata exists
cat dashboards/ai/data/archive/*/snapshot-metadata.json | head -10
```

### Technical Verification
```bash
# Check workflow exists
test -f .github/workflows/dashboard-data-snapshot.yml && echo "PASS"

# Verify weekly schedule
grep "cron: '0 0 \* \* 0'" .github/workflows/dashboard-data-snapshot.yml && echo "PASS"

# Verify retention cleanup
grep "head -n \$((snapshot_count - 52))" .github/workflows/dashboard-data-snapshot.yml && echo "PASS"
```

### Integration Verification
```bash
# Verify all dashboards have archive capability
for dashboard in dashboards/*/; do
  dashboard_name=$(basename "$dashboard")
  if [ "$dashboard_name" != "README.md" ]; then
    test -d "${dashboard}data/archive" && echo "$dashboard_name: PASS" || echo "$dashboard_name: FAIL"
  fi
done
```

## Troubleshooting

### Snapshot Creation Failed

**Problem:** Workflow fails with "permission denied"
**Solution:** Ensure `GITHUB_TOKEN` has write permissions in workflow

### Archive Directory Missing

**Problem:** `data/archive/` doesn't exist
**Solution:** Run `./scripts/create-dashboard-snapshot.sh` manually once

### Retention Policy Not Working

**Problem:** More than 52 snapshots accumulating
**Solution:** Check cleanup step in workflow is executing

### Large Archive Size

**Problem:** Archive exceeds expected size
**Solution:** Check if binary files or `node_modules` being snapshotted (they shouldn't be)

## References

- **Requirement:** NFR-3.3 (Data Growth - Historical Analysis)
- **Workflow:** `.github/workflows/dashboard-data-snapshot.yml`
- **Script:** `scripts/create-dashboard-snapshot.sh`
- **Related:** NFR-3.2 (Repository Growth), FEATURE_015 (Dashboard Auto-Update)

---

**Owner:** Jorge (VP AI-SecOps)
**Status:** Snapshot system operational, building 12-month history
