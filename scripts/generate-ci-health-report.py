#!/usr/bin/env python3
"""Generate CI Health Weekly Report (NFR-8.5)"""
import json
import os
import subprocess
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Any

REPO_OWNER = os.environ.get('GITHUB_REPOSITORY_OWNER', 'Seven-Fortunas-Internal')
REPO_NAME = os.environ.get('GITHUB_REPOSITORY', 'Seven-Fortunas-Internal/7f-infrastructure-project').split('/')[-1]
STATE_DIR = Path('compliance/ci-health/state')
REPORTS_DIR = Path('compliance/ci-health/reports')
REPORTS_DIR.mkdir(parents=True, exist_ok=True)

def fetch_workflow_runs() -> List[Dict[str, Any]]:
    """Fetch workflow runs from last 7 days via GitHub API"""
    since_date = (datetime.utcnow() - timedelta(days=7)).isoformat() + 'Z'
    cmd = [
        'gh', 'api',
        f'/repos/{REPO_OWNER}/{REPO_NAME}/actions/runs',
        '--paginate',
        '-q', f'.workflow_runs[] | select(.created_at >= "{since_date}")'
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
    if result.returncode != 0:
        print(f"Warning: GitHub API call failed: {result.stderr}")
        return []

    # Parse NDJSON output
    runs = []
    for line in result.stdout.strip().split('\n'):
        if line:
            try:
                runs.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    return runs

def load_state_files() -> Dict[str, Any]:
    """Load state files from compliance/ci-health/state/"""
    state_data = {
        'retry_outcomes': {},
        'failure_patterns': {}
    }

    if not STATE_DIR.exists():
        return state_data

    for state_file in STATE_DIR.glob('*.json'):
        try:
            with open(state_file) as f:
                data = json.load(f)
                workflow_name = state_file.stem
                state_data['retry_outcomes'][workflow_name] = data.get('retry_count', 0)
                state_data['failure_patterns'][workflow_name] = data.get('failure_category', 'unknown')
        except (json.JSONDecodeError, IOError):
            continue

    return state_data

def count_open_issues() -> int:
    """Count open issues with ci-failure label"""
    cmd = ['gh', 'issue', 'list', '--label', 'ci-failure', '--state', 'open', '--json', 'number']
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
    if result.returncode != 0:
        return 0

    try:
        issues = json.loads(result.stdout)
        return len(issues)
    except json.JSONDecodeError:
        return 0

def load_previous_report() -> Dict[str, Any]:
    """Load previous week's report for WoW delta calculation"""
    if not REPORTS_DIR.exists():
        return {}

    report_files = sorted(REPORTS_DIR.glob('ci-health-*.md'), reverse=True)
    if len(report_files) < 2:
        return {}

    prev_report = report_files[1]
    prev_data = {'total_runs': 0, 'retry_rate': 0.0, 'open_issues': 0}

    try:
        with open(prev_report) as f:
            content = f.read()
            for line in content.split('\n'):
                if 'Total Runs' in line and '|' in line:
                    parts = line.split('|')
                    if len(parts) >= 2:
                        try:
                            prev_data['total_runs'] = int(parts[1].strip())
                        except ValueError:
                            pass
                elif 'Retry Rate' in line and '|' in line:
                    parts = line.split('|')
                    if len(parts) >= 2:
                        try:
                            prev_data['retry_rate'] = float(parts[1].strip().replace('%', ''))
                        except ValueError:
                            pass
                elif 'Open Issues' in line and '|' in line:
                    parts = line.split('|')
                    if len(parts) >= 2:
                        try:
                            prev_data['open_issues'] = int(parts[1].strip())
                        except ValueError:
                            pass
    except IOError:
        pass

    return prev_data

def generate_report():
    """Generate CI health report"""
    runs = fetch_workflow_runs()
    state_data = load_state_files()
    open_issues = count_open_issues()
    prev_data = load_previous_report()

    total_runs = len(runs)
    failed_runs = [r for r in runs if r.get('conclusion') == 'failure']
    total_retries = sum(state_data['retry_outcomes'].values())
    retry_rate = (total_retries / total_runs * 100) if total_runs > 0 else 0.0

    is_baseline = not prev_data or prev_data.get('total_runs', 0) == 0
    delta_runs = total_runs - prev_data.get('total_runs', 0) if not is_baseline else 0
    delta_retry = retry_rate - prev_data.get('retry_rate', 0.0) if not is_baseline else 0.0
    delta_issues = open_issues - prev_data.get('open_issues', 0) if not is_baseline else 0

    report_date = datetime.utcnow().strftime('%Y-%m-%d')
    report_path = REPORTS_DIR / f'ci-health-{report_date}.md'

    with open(report_path, 'w') as f:
        f.write(f"# CI Health Report - Week of {report_date}\n\n")
        f.write("## Summary\n\n")
        f.write("| Metric | Value | WoW Delta |\n")
        f.write("|--------|-------|-----------|\n")

        if is_baseline:
            f.write(f"| Total Runs | {total_runs} | Baseline week |\n")
            f.write(f"| Retry Rate | {retry_rate:.1f}% | Baseline week |\n")
            f.write(f"| Open Issues | {open_issues} | Baseline week |\n")
        else:
            delta_runs_str = f"+{delta_runs}" if delta_runs > 0 else str(delta_runs)
            delta_retry_str = f"+{delta_retry:.1f}%" if delta_retry > 0 else f"{delta_retry:.1f}%"
            delta_issues_str = f"+{delta_issues}" if delta_issues > 0 else str(delta_issues)

            f.write(f"| Total Runs | {total_runs} | {delta_runs_str} |\n")
            f.write(f"| Retry Rate | {retry_rate:.1f}% | {delta_retry_str} |\n")
            f.write(f"| Open Issues | {open_issues} | {delta_issues_str} |\n")

        f.write("\n## Failure Patterns\n\n")
        f.write("| Workflow | Failures | Pattern |\n")
        f.write("|----------|----------|---------|\n")

        workflow_failures = {}
        for run in failed_runs:
            wf_name = run.get('name', 'unknown')
            workflow_failures[wf_name] = workflow_failures.get(wf_name, 0) + 1

        for wf_name, count in sorted(workflow_failures.items(), key=lambda x: x[1], reverse=True):
            pattern = state_data['failure_patterns'].get(wf_name, 'unknown')
            f.write(f"| {wf_name} | {count} | {pattern} |\n")

        if not workflow_failures:
            f.write("| No failures | 0 | N/A |\n")

        f.write("\n## Retry Outcomes\n\n")
        f.write("| Workflow | Retry Count |\n")
        f.write("|----------|-------------|\n")

        for wf_name, retry_count in sorted(state_data['retry_outcomes'].items(), key=lambda x: x[1], reverse=True):
            if retry_count > 0:
                f.write(f"| {wf_name} | {retry_count} |\n")

        if not any(count > 0 for count in state_data['retry_outcomes'].values()):
            f.write("| No retries | 0 |\n")

        f.write(f"\n---\n\n*Generated: {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')} UTC*\n")

    print(f"✓ Report generated: {report_path}")

if __name__ == '__main__':
    generate_report()
