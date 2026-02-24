# Data Archival & Retention - Seven Fortunas Infrastructure

**Version:** 1.0
**Last Updated:** 2026-02-24
**Priority:** P2
**Target:** Automated archival per retention policy

---

## Retention Policy

| Data Type | Retention Period | Archive Location |
|-----------|------------------|------------------|
| Dashboard archives | 52 weeks | `dashboards/archive/` |
| ERROR/WARN logs | 90 days | `logs/archive/` |
| INFO logs | 30 days | `logs/archive/` |
| DEBUG logs | 7 days | `logs/archive/` |
| Metrics | 90 days | `metrics/archive/` |
| Feature tracking | Indefinite | Git history |

---

## Automated Archival

### Cleanup Script

**File:** `scripts/cleanup-old-data.sh`

```bash
#!/bin/bash
# Cleanup old data according to retention policy

set -e

echo "Starting data cleanup..."

# Archive and delete old metrics (>90 days)
if [ -d "metrics" ]; then
  mkdir -p metrics/archive
  find metrics -name "*.json" -mtime +90 -exec mv {} metrics/archive/ \;
  find metrics/archive -name "*.json" -mtime +365 -delete
  echo "Metrics cleaned up (90 day retention)"
fi

# Archive and delete old logs
if [ -d "logs" ]; then
  mkdir -p logs/archive

  # ERROR/WARN logs (90 days)
  find logs -name "*ERROR*.log" -mtime +90 -exec mv {} logs/archive/ \;
  find logs -name "*WARN*.log" -mtime +90 -exec mv {} logs/archive/ \;

  # INFO logs (30 days)
  find logs -name "*INFO*.log" -mtime +30 -exec mv {} logs/archive/ \;

  # DEBUG logs (7 days)
  find logs -name "*DEBUG*.log" -mtime +7 -delete

  # Delete archived logs older than 1 year
  find logs/archive -type f -mtime +365 -delete

  echo "Logs cleaned up (retention policy applied)"
fi

# Dashboard archives (52 weeks)
if [ -d "dashboards/archive" ]; then
  find dashboards/archive -type f -mtime +365 -delete
  echo "Dashboard archives cleaned up (52 week retention)"
fi

echo "Cleanup complete: $(date)"
```

---

### Scheduled Cleanup (GitHub Actions)

**File:** `.github/workflows/cleanup-data.yml`

```yaml
name: Data Cleanup

on:
  schedule:
    - cron: '0 2 * * 0'  # Weekly, Sunday 2 AM UTC
  workflow_dispatch:

jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run cleanup script
        run: |
          chmod +x scripts/cleanup-old-data.sh
          ./scripts/cleanup-old-data.sh

      - name: Commit cleaned data
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add .
          git diff --staged --quiet || git commit -m "chore: automated data cleanup"
          git push || true
```

---

## Archive Structure

```
project/
├── metrics/
│   ├── metrics-2026-02-24.json  # Recent (kept)
│   ├── metrics-2026-01-15.json  # Recent (kept)
│   └── archive/
│       └── metrics-2025-11-01.json  # Old (90+ days)
├── logs/
│   ├── error-2026-02-24.log  # Recent (kept)
│   └── archive/
│       ├── error-2025-11-01.log  # Old (90+ days)
│       └── info-2025-12-01.log  # Old (30+ days)
└── dashboards/
    └── archive/
        └── ai-advancements-2025-02-01.json  # Old snapshot
```

---

## Manual Archival

### Create Snapshot Before Major Changes

```bash
# Before schema migration
tar -czf backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  feature_list.json \
  metrics/ \
  dashboards/data/

# Store in archive
mkdir -p archive/snapshots
mv backup-*.tar.gz archive/snapshots/
```

---

### Export Historical Data

```bash
# Export all metrics to CSV for analysis
jq -r '"\(.timestamp),\(.workflow_success_rate),\(.api_rate_limit_percentage)"' \
  metrics/*.json \
  > metrics-export-$(date +%Y%m%d).csv
```

---

## Success Criteria

NFR-10.3 is satisfied when:

1. ✅ Retention policy documented
2. ✅ Automated cleanup script implemented
3. ✅ Scheduled cleanup workflow configured
4. ✅ Archive structure defined
5. ✅ Manual archival procedures documented

---

**Owner:** Jorge (VP AI-SecOps)
**Review Date:** 2026-03-24 (monthly review)
