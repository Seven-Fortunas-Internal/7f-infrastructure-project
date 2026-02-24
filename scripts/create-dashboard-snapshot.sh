#!/bin/bash
# Dashboard Data Snapshot Script (NFR-3.3)
# Creates weekly snapshots of dashboard data for historical analysis

set -euo pipefail

# Configuration
TIMESTAMP=$(date -u +%Y-%m-%d)
DASHBOARDS_DIR="dashboards"

echo "=== Dashboard Data Snapshot ==="
echo "Timestamp: $TIMESTAMP"
echo ""

# Function to create snapshot for a dashboard
create_snapshot() {
    local dashboard="$1"
    local dashboard_dir="$DASHBOARDS_DIR/$dashboard"
    local archive_dir="$dashboard_dir/data/archive"
    local snapshot_dir="$archive_dir/$TIMESTAMP"

    echo "Creating snapshot for $dashboard..."

    # Create archive directory if it doesn't exist
    mkdir -p "$archive_dir"

    # Create snapshot directory
    mkdir -p "$snapshot_dir"

    # Snapshot dashboard data files
    if [ -d "$dashboard_dir/src" ]; then
        # Copy data files (exclude node_modules, dist, build)
        cp -r "$dashboard_dir/src" "$snapshot_dir/" 2>/dev/null || true
    fi

    # Capture metrics if available
    if [ -f "$dashboard_dir/metrics.json" ]; then
        cp "$dashboard_dir/metrics.json" "$snapshot_dir/" 2>/dev/null || true
    fi

    # Create snapshot metadata
    cat > "$snapshot_dir/snapshot-metadata.json" <<EOF
{
  "dashboard": "$dashboard",
  "snapshot_date": "$TIMESTAMP",
  "snapshot_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "files_captured": $(ls -1 "$snapshot_dir" 2>/dev/null | wc -l),
  "size_bytes": $(du -sb "$snapshot_dir" 2>/dev/null | cut -f1),
  "git_commit": "$(git rev-parse HEAD 2>/dev/null || echo 'unknown')"
}
EOF

    # Get snapshot size
    local size=$(du -sh "$snapshot_dir" 2>/dev/null | cut -f1)
    echo "  ✓ Snapshot created: $snapshot_dir ($size)"
}

# Find all dashboard directories
DASHBOARDS=$(ls -1 "$DASHBOARDS_DIR" 2>/dev/null | grep -v "README.md" || echo "")

if [ -z "$DASHBOARDS" ]; then
    echo "No dashboards found in $DASHBOARDS_DIR"
    exit 1
fi

# Create snapshots for each dashboard
SNAPSHOT_COUNT=0
for dashboard in $DASHBOARDS; do
    if [ -d "$DASHBOARDS_DIR/$dashboard" ]; then
        create_snapshot "$dashboard"
        SNAPSHOT_COUNT=$((SNAPSHOT_COUNT + 1))
    fi
done

echo ""
echo "=== Snapshot Summary ==="
echo "Dashboards snapshotted: $SNAPSHOT_COUNT"
echo "Snapshot date: $TIMESTAMP"

# Check archive retention (should have 12+ months)
echo ""
echo "=== Retention Check ==="
for dashboard in $DASHBOARDS; do
    if [ -d "$DASHBOARDS_DIR/$dashboard" ]; then
        archive_dir="$DASHBOARDS_DIR/$dashboard/data/archive"
        if [ -d "$archive_dir" ]; then
            snapshot_count=$(ls -1 "$archive_dir" 2>/dev/null | wc -l)
            oldest_snapshot=$(ls -1 "$archive_dir" 2>/dev/null | head -1 || echo "none")
            newest_snapshot=$(ls -1 "$archive_dir" 2>/dev/null | tail -1 || echo "none")

            echo "$dashboard: $snapshot_count snapshots (oldest: $oldest_snapshot, newest: $newest_snapshot)"

            # Calculate retention period (approximate)
            if [ "$snapshot_count" -ge 52 ]; then
                echo "  ✓ 12+ months of data (assuming weekly snapshots)"
            elif [ "$snapshot_count" -ge 12 ]; then
                echo "  ⚠ ${snapshot_count} snapshots (~${snapshot_count} weeks of data)"
            else
                echo "  ℹ $snapshot_count snapshots (building historical data)"
            fi
        fi
    fi
done

echo ""
echo "✓ Snapshot complete"
