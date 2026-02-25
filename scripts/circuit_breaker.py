#!/usr/bin/env python3
"""
Session-Level Circuit Breaker
Monitors session health and triggers termination when thresholds exceeded
"""

import json
from datetime import datetime
from pathlib import Path

# Circuit breaker thresholds
MIN_COMPLETION_RATE = 0.50  # 50%
MAX_BLOCKED_RATE = 0.30     # 30%
MAX_CONSECUTIVE_FAILED_SESSIONS = 5

def get_project_root():
    """Get project root directory"""
    return Path(__file__).parent.parent

def load_feature_list():
    """Load feature_list.json"""
    project_root = get_project_root()
    feature_file = project_root / "feature_list.json"

    with open(feature_file, 'r') as f:
        return json.load(f)

def load_session_progress():
    """Load session_progress.json"""
    project_root = get_project_root()
    progress_file = project_root / "session_progress.json"

    if not progress_file.exists():
        return {
            "session_count": 0,
            "consecutive_failed_sessions": 0,
            "last_session_success": True,
            "session_history": [],
            "circuit_breaker": {
                "status": "HEALTHY",
                "threshold": MAX_CONSECUTIVE_FAILED_SESSIONS,
                "triggers": []
            },
            "last_updated": datetime.utcnow().isoformat()
        }

    with open(progress_file, 'r') as f:
        return json.load(f)

def save_session_progress(progress):
    """Save session_progress.json"""
    project_root = get_project_root()
    progress_file = project_root / "session_progress.json"

    progress["last_updated"] = datetime.utcnow().isoformat()

    with open(progress_file, 'w') as f:
        json.dump(progress, f, indent=2)

def calculate_session_health(features):
    """
    Calculate session health metrics

    Returns:
        dict: Health metrics
    """
    total = len(features)
    if total == 0:
        return {"completion_rate": 0, "blocked_rate": 0, "success": False}

    pass_count = len([f for f in features if f["status"] == "pass"])
    blocked_count = len([f for f in features if f["status"] == "blocked"])

    completion_rate = pass_count / total
    blocked_rate = blocked_count / total

    # Session succeeds if completion rate >= 50% AND blocked rate < 30%
    success = completion_rate >= MIN_COMPLETION_RATE and blocked_rate < MAX_BLOCKED_RATE

    return {
        "total": total,
        "pass_count": pass_count,
        "blocked_count": blocked_count,
        "completion_rate": completion_rate,
        "blocked_rate": blocked_rate,
        "success": success
    }

def check_circuit_breaker():
    """
    Check if circuit breaker should trigger

    Returns:
        dict: Status with should_terminate flag
    """
    progress = load_session_progress()

    consecutive_failures = progress.get("consecutive_failed_sessions", 0)
    status = progress.get("circuit_breaker", {}).get("status", "HEALTHY")

    if consecutive_failures >= MAX_CONSECUTIVE_FAILED_SESSIONS:
        return {
            "should_terminate": True,
            "reason": f"Circuit breaker triggered: {consecutive_failures} consecutive failed sessions",
            "status": "TRIGGERED",
            "exit_code": 42
        }

    return {
        "should_terminate": False,
        "reason": None,
        "status": status,
        "exit_code": 0
    }

def record_session(start_metrics, end_metrics):
    """
    Record session results and update circuit breaker state

    Args:
        start_metrics (dict): Metrics at session start
        end_metrics (dict): Metrics at session end

    Returns:
        dict: Updated progress with circuit breaker status
    """
    progress = load_session_progress()

    session_num = progress.get("session_count", 0) + 1

    # Calculate session health
    health = calculate_session_health(end_metrics["features"])

    # Update consecutive failure counter
    if health["success"]:
        progress["consecutive_failed_sessions"] = 0
        progress["last_session_success"] = True
    else:
        progress["consecutive_failed_sessions"] = progress.get("consecutive_failed_sessions", 0) + 1
        progress["last_session_success"] = False

        # Record circuit breaker trigger
        if "triggers" not in progress.get("circuit_breaker", {}):
            progress["circuit_breaker"]["triggers"] = []

        progress["circuit_breaker"]["triggers"].append({
            "session": session_num,
            "timestamp": datetime.utcnow().isoformat(),
            "reason": f"Completion rate: {health['completion_rate']:.1%}, Blocked rate: {health['blocked_rate']:.1%}"
        })

    # Update session history
    session_record = {
        "session_id": session_num,
        "date": datetime.utcnow().strftime("%Y-%m-%d"),
        "start_passing": start_metrics.get("pass_count", 0),
        "end_passing": health["pass_count"],
        "blocked_count": health["blocked_count"],
        "completion_rate": health["completion_rate"],
        "blocked_rate": health["blocked_rate"],
        "success": health["success"]
    }

    progress["session_history"].append(session_record)
    progress["session_count"] = session_num

    # Update circuit breaker status
    breaker_status = check_circuit_breaker()
    progress["circuit_breaker"]["status"] = breaker_status["status"]

    save_session_progress(progress)

    return {
        "session_num": session_num,
        "health": health,
        "circuit_breaker": breaker_status,
        "consecutive_failures": progress["consecutive_failed_sessions"]
    }

def generate_summary_report():
    """Generate autonomous_summary_report.md on circuit breaker trigger"""
    project_root = get_project_root()
    report_file = project_root / "autonomous_summary_report.md"

    progress = load_session_progress()
    features = load_feature_list()["features"]

    # Calculate statistics
    total = len(features)
    pass_count = len([f for f in features if f["status"] == "pass"])
    fail_count = len([f for f in features if f["status"] == "fail"])
    blocked_count = len([f for f in features if f["status"] == "blocked"])
    pending_count = len([f for f in features if f["status"] == "pending"])

    # Get blocked features with reasons
    blocked_features = [f for f in features if f["status"] == "blocked"]

    # Generate report
    report = f"""# Autonomous Implementation Summary Report

**Generated:** {datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")}
**Reason:** Circuit breaker triggered

---

## Overall Statistics

- **Total Features:** {total}
- **Completed:** {pass_count} ({pass_count/total*100:.1f}%)
- **Blocked:** {blocked_count} ({blocked_count/total*100:.1f}%)
- **Failed:** {fail_count} ({fail_count/total*100:.1f}%)
- **Pending:** {pending_count} ({pending_count/total*100:.1f}%)

---

## Circuit Breaker Status

- **Status:** TRIGGERED
- **Consecutive Failed Sessions:** {progress.get('consecutive_failed_sessions', 0)}
- **Threshold:** {MAX_CONSECUTIVE_FAILED_SESSIONS}
- **Total Sessions:** {progress.get('session_count', 0)}

---

## Blocked Features

"""

    if blocked_features:
        for feature in blocked_features:
            report += f"""### {feature['id']}: {feature['name']}

**Category:** {feature['category']}
**Attempts:** {feature.get('attempts', 0)}
**Last Updated:** {feature.get('last_updated', 'N/A')}

**Implementation Notes:**
{feature.get('implementation_notes', 'No notes provided')}

---

"""
    else:
        report += "No blocked features.\n\n---\n\n"

    report += """## Next Steps

1. **Review blocked features** - Identify common patterns or root causes
2. **Manual intervention** - Address blockers that require human expertise
3. **Update dependencies** - Install missing tools or configure external services
4. **Resume autonomous run** - Restart agent after resolving blockers

---

## Session History

"""

    for session in progress.get("session_history", [])[-10:]:  # Last 10 sessions
        success_emoji = "✅" if session.get("success", False) else "❌"
        report += f"""- **Session {session.get('session_id', 'N/A')}** ({session.get('date', 'N/A')}): {success_emoji}
  - Passing: {session.get('start_passing', 0)} → {session.get('end_passing', 0)}
  - Completion: {session.get('completion_rate', 0)*100:.1f}%
  - Blocked: {session.get('blocked_rate', 0)*100:.1f}%

"""

    report += """---

**End of Report**
"""

    with open(report_file, 'w') as f:
        f.write(report)

    print(f"✓ Summary report generated: {report_file}")
    return str(report_file)

if __name__ == "__main__":
    # Test circuit breaker
    import sys

    if len(sys.argv) > 1 and sys.argv[1] == "check":
        status = check_circuit_breaker()
        print(json.dumps(status, indent=2))
        sys.exit(status["exit_code"])

    elif len(sys.argv) > 1 and sys.argv[1] == "report":
        generate_summary_report()

    else:
        print("Usage:")
        print("  python circuit_breaker.py check   # Check circuit breaker status")
        print("  python circuit_breaker.py report  # Generate summary report")
