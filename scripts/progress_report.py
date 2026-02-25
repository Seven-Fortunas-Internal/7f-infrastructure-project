#!/usr/bin/env python3
"""
Progress Reporter
Real-time progress tracking dashboard for autonomous implementation
"""

import json
import sys
from datetime import datetime
from pathlib import Path

def get_project_root():
    """Get project root directory"""
    return Path(__file__).parent.parent

def load_feature_list():
    """Load feature_list.json"""
    project_root = get_project_root()
    with open(project_root / "feature_list.json", 'r') as f:
        return json.load(f)

def load_session_progress():
    """Load session_progress.json"""
    project_root = get_project_root()
    progress_file = project_root / "session_progress.json"

    if not progress_file.exists():
        return {}

    with open(progress_file, 'r') as f:
        return json.load(f)

def calculate_statistics(features):
    """Calculate detailed statistics"""
    total = len(features)

    # Status counts
    pass_count = len([f for f in features if f["status"] == "pass"])
    pending_count = len([f for f in features if f["status"] == "pending"])
    fail_count = len([f for f in features if f["status"] == "fail"])
    blocked_count = len([f for f in features if f["status"] == "blocked"])

    # Category breakdown
    categories = {}
    for feature in features:
        cat = feature.get("category", "Unknown")
        if cat not in categories:
            categories[cat] = {"total": 0, "pass": 0, "pending": 0, "fail": 0, "blocked": 0}

        categories[cat]["total"] += 1
        status = feature.get("status", "pending")
        if status in categories[cat]:
            categories[cat][status] += 1

    # Attempts breakdown
    attempt_stats = {1: 0, 2: 0, 3: 0, "3+": 0}
    for feature in features:
        attempts = feature.get("attempts", 0)
        if attempts == 0:
            continue
        elif attempts <= 3:
            attempt_stats[attempts] += 1
        else:
            attempt_stats["3+"] += 1

    return {
        "total": total,
        "pass": pass_count,
        "pending": pending_count,
        "fail": fail_count,
        "blocked": blocked_count,
        "completion_rate": (pass_count / total * 100) if total > 0 else 0,
        "categories": categories,
        "attempts": attempt_stats
    }

def print_progress_bar(completed, total, width=50):
    """Print a progress bar"""
    percent = (completed / total * 100) if total > 0 else 0
    filled = int(width * completed / total) if total > 0 else 0
    bar = "█" * filled + "░" * (width - filled)
    return f"[{bar}] {percent:.1f}% ({completed}/{total})"

def print_dashboard(stats, session_progress):
    """Print progress dashboard"""
    print("=" * 70)
    print("SEVEN FORTUNAS AUTONOMOUS IMPLEMENTATION - PROGRESS DASHBOARD")
    print("=" * 70)
    print()

    # Overall progress
    print("OVERALL PROGRESS")
    print("-" * 70)
    print(print_progress_bar(stats["pass"], stats["total"], 60))
    print()
    print(f"  ✅ Completed:  {stats['pass']:2d}  ({stats['pass']/stats['total']*100:.1f}%)")
    print(f"  ⏳ Pending:    {stats['pending']:2d}  ({stats['pending']/stats['total']*100:.1f}%)")
    print(f"  ❌ Failed:     {stats['fail']:2d}  ({stats['fail']/stats['total']*100:.1f}%)")
    print(f"  🚫 Blocked:    {stats['blocked']:2d}  ({stats['blocked']/stats['total']*100:.1f}%)")
    print()

    # Session info
    print("SESSION INFO")
    print("-" * 70)
    session_count = session_progress.get("session_count", 0)
    last_updated = session_progress.get("last_updated", "N/A")
    circuit_status = session_progress.get("circuit_breaker", {}).get("status", "UNKNOWN")

    print(f"  Sessions Completed:     {session_count}")
    print(f"  Circuit Breaker:        {circuit_status}")
    print(f"  Last Updated:           {last_updated}")
    print()

    # Category breakdown
    print("PROGRESS BY CATEGORY")
    print("-" * 70)
    for cat_name, cat_stats in sorted(stats["categories"].items()):
        cat_percent = (cat_stats["pass"] / cat_stats["total"] * 100) if cat_stats["total"] > 0 else 0
        print(f"  {cat_name[:40]:<40} {cat_stats['pass']:2d}/{cat_stats['total']:2d} ({cat_percent:5.1f}%)")
    print()

    # Attempt statistics (if any features attempted)
    total_attempts = sum(stats["attempts"].values())
    if total_attempts > 0:
        print("RETRY ATTEMPTS")
        print("-" * 70)
        print(f"  First attempt success:  {stats['attempts'][1]}")
        print(f"  Second attempt:         {stats['attempts'][2]}")
        print(f"  Third attempt:          {stats['attempts'][3]}")
        print(f"  Blocked (3+ attempts):  {stats['attempts']['3+']}")
        print()

    print("=" * 70)
    print()

def print_json_report(stats, session_progress):
    """Print JSON report"""
    report = {
        "timestamp": datetime.utcnow().isoformat(),
        "statistics": stats,
        "session_progress": session_progress
    }
    print(json.dumps(report, indent=2))

if __name__ == "__main__":
    data = load_feature_list()
    features = data.get("features", [])
    session_progress = load_session_progress()

    stats = calculate_statistics(features)

    if "--json" in sys.argv:
        print_json_report(stats, session_progress)
    else:
        print_dashboard(stats, session_progress)

    # Exit with non-zero if there are blocked features
    sys.exit(1 if stats["blocked"] > 0 else 0)
