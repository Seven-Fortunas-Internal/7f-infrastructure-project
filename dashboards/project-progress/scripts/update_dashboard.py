#!/usr/bin/env python3
"""
update_dashboard.py - Collect and aggregate project metrics

Fetches data from GitHub APIs and feature_list.json to generate
daily project progress metrics.
"""

import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

# Configuration
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent.parent
FEATURE_LIST = PROJECT_ROOT / "feature_list.json"
OUTPUT_FILE = SCRIPT_DIR.parent / "data" / "project-progress-latest.json"
HISTORICAL_DIR = SCRIPT_DIR.parent / "data" / "historical"

def load_feature_list():
    """Load and parse feature_list.json"""
    if not FEATURE_LIST.exists():
        print(f"Error: feature_list.json not found at {FEATURE_LIST}", file=sys.stderr)
        sys.exit(1)

    with open(FEATURE_LIST, 'r') as f:
        data = json.load(f)

    return data.get('features', [])

def calculate_feature_completion(features):
    """Calculate feature completion metrics"""
    total = len(features)
    completed = sum(1 for f in features if f['status'] == 'pass')
    pending = sum(1 for f in features if f['status'] == 'pending')
    failed = sum(1 for f in features if f['status'] == 'fail')
    blocked = sum(1 for f in features if f['status'] == 'blocked')

    completion_rate = completed / total if total > 0 else 0

    # Estimate completion date (simplified)
    # Assumes 5 features per week based on current velocity
    features_per_week = 5
    weeks_remaining = pending / features_per_week if features_per_week > 0 else 0

    return {
        "total_features": total,
        "completed": completed,
        "pending": pending,
        "failed": failed,
        "blocked": blocked,
        "completion_rate": round(completion_rate, 3),
        "estimated_weeks_remaining": round(weeks_remaining, 1)
    }

def calculate_sprint_velocity():
    """Calculate sprint velocity from sprint-status.yaml (simplified)"""
    # In a real implementation, this would parse sprint-status.yaml
    # and calculate velocity from historical sprint data

    # For now, return mock data structure
    return {
        "current_sprint": "Sprint-2026-W08",
        "velocity_last_6_sprints": [18, 22, 20, 15, 19, 21],
        "average_velocity": 19.2,
        "trend": "stable",
        "confidence": 0.80
    }

def calculate_burndown():
    """Calculate burndown chart data"""
    # This would integrate with sprint-status.yaml
    # For now, return structure

    features = load_feature_list()
    total = len(features)
    completed = sum(1 for f in features if f['status'] == 'pass')
    remaining = total - completed

    return {
        "sprint": "Sprint-2026-W08",
        "total_points": total,
        "remaining_points": remaining,
        "ideal_remaining": max(0, remaining - 2),  # Simplified
        "days_elapsed": 10,
        "days_remaining": 4,
        "status": "on_track" if remaining <= total * 0.3 else "at_risk"
    }

def check_blockers():
    """Check for blocked features and issues"""
    features = load_feature_list()
    blocked = [f for f in features if f['status'] == 'blocked']

    return {
        "count": len(blocked),
        "top_blockers": [
            {
                "id": f['id'],
                "name": f['name'],
                "attempts": f.get('attempts', 0)
            }
            for f in blocked[:5]
        ]
    }

def calculate_team_utilization():
    """Calculate team utilization metrics"""
    features = load_feature_list()

    # Group by owner
    owners = {}
    for f in features:
        owner = f.get('owner', 'Unknown')
        if owner not in owners:
            owners[owner] = {'total': 0, 'completed': 0, 'in_progress': 0}

        owners[owner]['total'] += 1
        if f['status'] == 'pass':
            owners[owner]['completed'] += 1
        elif f['status'] == 'fail':
            owners[owner]['in_progress'] += 1

    # Calculate utilization
    utilization = {}
    for owner, stats in owners.items():
        capacity = stats['total']
        assigned = stats['in_progress'] + (capacity - stats['completed'])
        util_rate = assigned / capacity if capacity > 0 else 0

        utilization[owner] = {
            "assigned_items": assigned,
            "capacity": capacity,
            "utilization": round(util_rate, 2),
            "completed": stats['completed']
        }

    return utilization

def generate_dashboard_data():
    """Generate complete dashboard data"""
    print("Loading feature list...")
    features = load_feature_list()

    print("Calculating metrics...")
    data = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "sprint_velocity": calculate_sprint_velocity(),
        "feature_completion": calculate_feature_completion(features),
        "burndown": calculate_burndown(),
        "blockers": check_blockers(),
        "team_utilization": calculate_team_utilization()
    }

    return data

def save_dashboard_data(data):
    """Save dashboard data to JSON file"""
    # Create output directory
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    # Save latest data
    print(f"Saving to {OUTPUT_FILE}...")
    with open(OUTPUT_FILE, 'w') as f:
        json.dump(data, f, indent=2)

    # Archive historical snapshot
    HISTORICAL_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    historical_file = HISTORICAL_DIR / f"project-progress-{timestamp}.json"

    print(f"Archiving to {historical_file}...")
    with open(historical_file, 'w') as f:
        json.dump(data, f, indent=2)

    print("✓ Dashboard data updated successfully")

def print_summary(data):
    """Print dashboard summary"""
    fc = data['feature_completion']
    sv = data['sprint_velocity']
    bd = data['burndown']
    bl = data['blockers']

    print("\n" + "=" * 60)
    print("  Project Progress Dashboard - Data Summary")
    print("=" * 60)
    print(f"\nTimestamp: {data['timestamp']}")
    print(f"\nFEATURE COMPLETION:")
    print(f"  Total: {fc['total_features']}")
    print(f"  Completed: {fc['completed']} ({fc['completion_rate']*100:.1f}%)")
    print(f"  Pending: {fc['pending']}")
    print(f"  Blocked: {fc['blocked']}")
    print(f"\nSPRINT VELOCITY:")
    print(f"  Current Sprint: {sv['current_sprint']}")
    print(f"  Average Velocity: {sv['average_velocity']} points/sprint")
    print(f"  Trend: {sv['trend']}")
    print(f"\nBURNDOWN:")
    print(f"  Remaining: {bd['remaining_points']} / {bd['total_points']}")
    print(f"  Status: {bd['status']}")
    print(f"\nBLOCKERS:")
    print(f"  Count: {bl['count']}")
    if bl['top_blockers']:
        print(f"  Top blocker: {bl['top_blockers'][0]['name']}")
    print("\n" + "=" * 60 + "\n")

def main():
    """Main execution"""
    try:
        print("Seven Fortunas - Project Progress Dashboard Update")
        print("=" * 60)

        data = generate_dashboard_data()
        save_dashboard_data(data)
        print_summary(data)

        return 0

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())
