#!/usr/bin/env python3
"""
Project Progress Data Collection
Collects sprint velocity, feature completion, blockers from GitHub
"""

import os
import json
import sys
from datetime import datetime, timezone, timedelta

# GitHub API configuration
GITHUB_TOKEN = os.environ.get('GITHUB_TOKEN')
GITHUB_ORG = 'Seven-Fortunas'
PROJECT_REPO = '7f-infrastructure-project'

# File paths
FEATURE_LIST = 'feature_list.json'
VELOCITY_HISTORY = 'sprint-management/velocity-history.json'
OUTPUT_FILE = 'dashboards/project-progress/data/project-progress-latest.json'


def load_feature_list():
    """Load feature_list.json"""
    if not os.path.exists(FEATURE_LIST):
        return {"features": []}

    with open(FEATURE_LIST) as f:
        return json.load(f)


def load_velocity_history():
    """Load sprint velocity history"""
    if not os.path.exists(VELOCITY_HISTORY):
        return {"sprints": [], "averages": {"last_3_sprints": {"velocity": 0}}}

    with open(VELOCITY_HISTORY) as f:
        return json.load(f)


def calculate_metrics(features):
    """Calculate project metrics from feature list"""
    total = len(features)
    completed = sum(1 for f in features if f.get('status') == 'pass')
    in_progress = sum(1 for f in features if f.get('status') == 'in_progress')
    blocked = sum(1 for f in features if f.get('status') == 'blocked')
    pending = sum(1 for f in features if f.get('status') == 'pending')

    completion_rate = round((completed / total * 100), 1) if total > 0 else 0

    return {
        'total_features': total,
        'completed_features': completed,
        'in_progress_features': in_progress,
        'blocked_features': blocked,
        'pending_features': pending,
        'completion_rate': completion_rate
    }


def get_active_blockers(features):
    """Find features with blocked status"""
    blockers = []
    for f in features:
        if f.get('status') == 'blocked':
            blockers.append({
                'id': f.get('id'),
                'title': f.get('name'),
                'owner': 'Unassigned',
                'created': f.get('last_updated', datetime.now(timezone.utc).isoformat()),
                'reason': f.get('implementation_notes', 'No reason provided')
            })
    return blockers


def get_recent_features(features, limit=10):
    """Get recently updated features"""
    # Sort by last_updated, descending (handle None values)
    sorted_features = sorted(
        features,
        key=lambda f: f.get('last_updated') or '1900-01-01T00:00:00Z',
        reverse=True
    )

    return [{
        'id': f.get('id'),
        'name': f.get('name'),
        'status': f.get('status', 'pending'),
        'last_updated': f.get('last_updated', '')
    } for f in sorted_features[:limit]]


def calculate_days_to_release():
    """Calculate days to planned release"""
    # Assume release date is end of current month
    now = datetime.now(timezone.utc)
    last_day = (now.replace(day=28) + timedelta(days=4)).replace(day=1) - timedelta(days=1)
    days_remaining = (last_day - now).days
    return max(days_remaining, 0)


def generate_ai_summary(metrics, velocity, blockers):
    """Generate AI-powered weekly summary"""
    # TODO: Replace with actual Anthropic API call in production

    completion = metrics['completion_rate']
    velocity_val = velocity
    blocker_count = len(blockers)

    if completion >= 80:
        health = "excellent"
        emoji = "🚀"
    elif completion >= 60:
        health = "good"
        emoji = "✅"
    elif completion >= 40:
        health = "moderate"
        emoji = "⚠️"
    else:
        health = "needs attention"
        emoji = "🔴"

    summary = f"{emoji} <strong>Project Health: {health.title()}</strong><br><br>"
    summary += f"This week, the team achieved {completion}% feature completion with a sprint velocity of {velocity_val} points. "

    if blocker_count == 0:
        summary += "No active blockers - the team is executing smoothly. "
    elif blocker_count <= 2:
        summary += f"{blocker_count} blocker(s) identified and being addressed. "
    else:
        summary += f"⚠️ {blocker_count} blockers require immediate attention. "

    if metrics['in_progress_features'] > 0:
        summary += f"Currently {metrics['in_progress_features']} features in active development. "

    summary += f"Projected completion in {calculate_days_to_release()} days based on current velocity."

    return summary


def main():
    """Main execution"""
    print("Collecting project progress data...")

    # Load data
    feature_data = load_feature_list()
    velocity_data = load_velocity_history()

    features = feature_data.get('features', [])

    # Calculate metrics
    metrics = calculate_metrics(features)
    blockers = get_active_blockers(features)
    recent_features = get_recent_features(features)

    # Get velocity
    sprint_velocity = velocity_data.get('averages', {}).get('last_3_sprints', {}).get('velocity', 0)

    # Calculate velocity trend
    sprints = velocity_data.get('sprints', [])
    if len(sprints) >= 2:
        last_velocity = sprints[-1].get('delivered_points', 0) if sprints else 0
        prev_velocity = sprints[-2].get('delivered_points', 0) if len(sprints) > 1 else 0
        trend_pct = ((last_velocity - prev_velocity) / prev_velocity * 100) if prev_velocity > 0 else 0
        if trend_pct > 5:
            velocity_trend = f"↑ +{trend_pct:.1f}% from last sprint"
        elif trend_pct < -5:
            velocity_trend = f"↓ {trend_pct:.1f}% from last sprint"
        else:
            velocity_trend = "→ Stable"
    else:
        velocity_trend = "→ Baseline"

    # Generate AI summary
    ai_summary = generate_ai_summary(metrics, sprint_velocity, blockers)

    # Calculate estimated weeks remaining
    estimated_weeks = round(metrics['pending_features'] / max(sprint_velocity, 1), 1)

    # Determine burndown status
    total_points = metrics['total_features']
    remaining_points = metrics['pending_features'] + metrics['in_progress_features']
    completion_pct = metrics['completion_rate']

    if completion_pct >= 80:
        burndown_status = 'on_track'
    elif completion_pct >= 50:
        burndown_status = 'at_risk'
    else:
        burndown_status = 'blocked'

    # Get current sprint name
    current_sprint = sprints[-1].get('sprint_id', 'N/A') if sprints else 'Sprint 1'

    # Calculate team utilization (active features / total capacity)
    # Assume 10 features per sprint is 100% capacity
    capacity = 10
    active_features = metrics['in_progress_features'] + metrics['completed_features']
    team_utilization = min(round((active_features / capacity) * 100, 1), 100)

    # Compile output (nested structure matching index.html expectations)
    output = {
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'feature_completion': {
            'completed': metrics['completed_features'],
            'total_features': metrics['total_features'],
            'pending': metrics['pending_features'],
            'completion_rate': metrics['completion_rate'] / 100,  # Convert to 0-1 range
            'estimated_weeks_remaining': estimated_weeks
        },
        'sprint_velocity': {
            'average_velocity': sprint_velocity,
            'current_sprint': current_sprint,
            'trend': velocity_trend.split(' ')[0].lower()  # Extract just the arrow/direction
        },
        'burndown': {
            'remaining_points': remaining_points,
            'total_points': total_points,
            'status': burndown_status
        },
        'blockers': {
            'count': len(blockers),
            'top_blockers': blockers[:5]  # Top 5 blockers
        },
        'team_utilization': {
            'utilization_pct': team_utilization,
            'active_features': active_features,
            'capacity': capacity,
            'status': 'optimal' if 60 <= team_utilization <= 85 else ('underutilized' if team_utilization < 60 else 'overutilized')
        },
        # Legacy fields for backwards compatibility
        'generated_at': datetime.now(timezone.utc).isoformat(),
        'recent_features': recent_features,
        'ai_summary': ai_summary,
        'summary_generated': datetime.now(timezone.utc).isoformat()
    }

    # Write output
    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    with open(OUTPUT_FILE, 'w') as f:
        json.dump(output, f, indent=2)

    print(f"✓ Project data saved to {OUTPUT_FILE}")
    print(f"  Sprint Velocity: {sprint_velocity} points")
    print(f"  Completion Rate: {metrics['completion_rate']}%")
    print(f"  Active Blockers: {len(blockers)}")


if __name__ == '__main__':
    main()
