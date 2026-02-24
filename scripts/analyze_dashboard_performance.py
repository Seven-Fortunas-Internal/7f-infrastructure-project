#!/usr/bin/env python3
"""
Dashboard Performance Analyzer

Analyzes dashboard workflow performance metrics to ensure compliance
with NFR-2.2 (< 10 minutes per cycle).

Features:
- Performance trend analysis
- SLA compliance reporting
- Performance degradation detection
- Optimization recommendations
"""

import csv
import json
import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict, Any
from collections import defaultdict


class DashboardPerformanceAnalyzer:
    """Analyzes dashboard performance metrics."""

    def __init__(self, metrics_file: Path, target_duration: float = 10.0):
        """
        Initialize the analyzer.

        Args:
            metrics_file: Path to performance metrics CSV file
            target_duration: Performance target in minutes (default: 10)
        """
        self.metrics_file = metrics_file
        self.target_duration = target_duration
        self.metrics = []

    def load_metrics(self) -> List[Dict[str, Any]]:
        """
        Load performance metrics from CSV file.

        Returns:
            List of metric dictionaries
        """
        if not self.metrics_file.exists():
            print(f"⚠️ Warning: Metrics file not found: {self.metrics_file}")
            return []

        metrics = []
        with open(self.metrics_file, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                # Skip comment lines
                if row.get('timestamp', '').startswith('#'):
                    continue

                try:
                    metrics.append({
                        'timestamp': datetime.fromisoformat(row['timestamp'].replace('Z', '+00:00')),
                        'workflow_name': row['workflow_name'],
                        'workflow_id': row['workflow_id'],
                        'duration_minutes': float(row['duration_minutes']),
                        'conclusion': row['conclusion']
                    })
                except (KeyError, ValueError) as e:
                    print(f"⚠️ Warning: Skipping invalid row: {e}")
                    continue

        self.metrics = sorted(metrics, key=lambda x: x['timestamp'])
        return metrics

    def analyze_performance(self) -> Dict[str, Any]:
        """
        Analyze performance metrics.

        Returns:
            Dictionary containing analysis results
        """
        if not self.metrics:
            self.load_metrics()

        if not self.metrics:
            return {
                'total_runs': 0,
                'compliant_runs': 0,
                'non_compliant_runs': 0,
                'compliance_rate': 0.0,
                'average_duration': 0.0,
                'max_duration': 0.0,
                'min_duration': 0.0,
                'target_duration': self.target_duration,
                'workflow_stats': {},
                'recent_7_day_compliance': 0.0,
                'recent_7_day_runs': 0
            }

        # Calculate statistics
        total_runs = len(self.metrics)
        compliant_runs = sum(1 for m in self.metrics if m['duration_minutes'] <= self.target_duration)
        non_compliant_runs = total_runs - compliant_runs
        compliance_rate = (compliant_runs / total_runs * 100) if total_runs > 0 else 0.0

        durations = [m['duration_minutes'] for m in self.metrics]
        average_duration = sum(durations) / len(durations) if durations else 0.0
        max_duration = max(durations) if durations else 0.0
        min_duration = min(durations) if durations else 0.0

        # Per-workflow statistics
        workflow_stats = defaultdict(lambda: {'runs': 0, 'compliant': 0, 'total_duration': 0.0})
        for m in self.metrics:
            name = m['workflow_name']
            workflow_stats[name]['runs'] += 1
            workflow_stats[name]['total_duration'] += m['duration_minutes']
            if m['duration_minutes'] <= self.target_duration:
                workflow_stats[name]['compliant'] += 1

        # Calculate per-workflow compliance
        for name, stats in workflow_stats.items():
            stats['average_duration'] = stats['total_duration'] / stats['runs']
            stats['compliance_rate'] = (stats['compliant'] / stats['runs'] * 100) if stats['runs'] > 0 else 0.0

        # Recent trend (last 7 days)
        recent_cutoff = datetime.utcnow() - timedelta(days=7)
        recent_metrics = [m for m in self.metrics if m['timestamp'] >= recent_cutoff]
        recent_compliance = (
            sum(1 for m in recent_metrics if m['duration_minutes'] <= self.target_duration) / len(recent_metrics) * 100
            if recent_metrics else 0.0
        )

        return {
            'total_runs': total_runs,
            'compliant_runs': compliant_runs,
            'non_compliant_runs': non_compliant_runs,
            'compliance_rate': compliance_rate,
            'average_duration': average_duration,
            'max_duration': max_duration,
            'min_duration': min_duration,
            'target_duration': self.target_duration,
            'workflow_stats': dict(workflow_stats),
            'recent_7_day_compliance': recent_compliance,
            'recent_7_day_runs': len(recent_metrics)
        }

    def generate_report(self) -> str:
        """
        Generate a human-readable performance report.

        Returns:
            Formatted report string
        """
        analysis = self.analyze_performance()

        report = f"""
# Dashboard Performance Report (NFR-2.2)

Generated: {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}

## Performance Summary

**Target:** < {analysis['target_duration']} minutes per cycle

**Overall Statistics:**
- Total runs: {analysis['total_runs']}
- Compliant runs: {analysis['compliant_runs']} ({analysis['compliance_rate']:.1f}%)
- Non-compliant runs: {analysis['non_compliant_runs']}
- Average duration: {analysis['average_duration']:.2f} minutes
- Min duration: {analysis['min_duration']:.2f} minutes
- Max duration: {analysis['max_duration']:.2f} minutes

**Recent Trend (Last 7 Days):**
- Runs: {analysis['recent_7_day_runs']}
- Compliance rate: {analysis['recent_7_day_compliance']:.1f}%

## Per-Workflow Statistics

"""

        for workflow_name, stats in analysis['workflow_stats'].items():
            status = "✅" if stats['compliance_rate'] >= 90 else "⚠️"
            report += f"""
### {status} {workflow_name}
- Runs: {stats['runs']}
- Compliance: {stats['compliant']}/{stats['runs']} ({stats['compliance_rate']:.1f}%)
- Average duration: {stats['average_duration']:.2f} minutes
"""

        # Compliance assessment
        if analysis['compliance_rate'] >= 95:
            report += "\n## ✅ Compliance Status: EXCELLENT\n"
            report += "Performance consistently meets NFR-2.2 target.\n"
        elif analysis['compliance_rate'] >= 80:
            report += "\n## ⚠️ Compliance Status: GOOD\n"
            report += "Performance mostly meets target but has occasional violations.\n"
        elif analysis['compliance_rate'] >= 50:
            report += "\n## ⚠️ Compliance Status: NEEDS IMPROVEMENT\n"
            report += "Frequent performance violations. Optimization recommended.\n"
        else:
            report += "\n## ❌ Compliance Status: CRITICAL\n"
            report += "Performance consistently fails to meet target. Immediate action required.\n"

        # Recommendations
        if analysis['average_duration'] > analysis['target_duration']:
            report += "\n## Optimization Recommendations\n\n"
            report += "1. **Increase parallel API calls** - Current configuration may be too conservative\n"
            report += "2. **Enable response caching** - Reduce redundant API calls\n"
            report += "3. **Implement incremental updates** - Only fetch changed data\n"
            report += "4. **Review API timeout settings** - May be too long for slow endpoints\n"
            report += "5. **Consider workflow splitting** - Break large dashboards into smaller units\n"

        return report

    def save_report(self, output_path: Path):
        """
        Save performance report to file.

        Args:
            output_path: Path to save report
        """
        output_path.parent.mkdir(parents=True, exist_ok=True)

        report = self.generate_report()

        with open(output_path, 'w') as f:
            f.write(report)

        print(f"📄 Performance report saved: {output_path}")

    def check_compliance(self) -> bool:
        """
        Check if performance is compliant with NFR-2.2.

        Returns:
            True if compliant (>= 80% of runs meet target), False otherwise
        """
        analysis = self.analyze_performance()
        return analysis['compliance_rate'] >= 80


def main():
    """Main entry point for the analyzer."""
    import argparse

    parser = argparse.ArgumentParser(description='Analyze dashboard performance metrics')
    parser.add_argument('--metrics', default='dashboards/performance/metrics/dashboard-performance.csv',
                        help='Path to metrics CSV file')
    parser.add_argument('--target', type=float, default=10.0,
                        help='Performance target in minutes (default: 10)')
    parser.add_argument('--output', help='Path to save report (optional)')
    parser.add_argument('--check-compliance', action='store_true',
                        help='Exit with code 1 if not compliant')

    args = parser.parse_args()

    # Run analysis
    analyzer = DashboardPerformanceAnalyzer(
        metrics_file=Path(args.metrics),
        target_duration=args.target
    )

    # Generate and display report
    print(analyzer.generate_report())

    # Save report if requested
    if args.output:
        analyzer.save_report(Path(args.output))

    # Check compliance if requested
    if args.check_compliance:
        if not analyzer.check_compliance():
            print("\n❌ Performance is NOT compliant with NFR-2.2", file=sys.stderr)
            sys.exit(1)
        else:
            print("\n✅ Performance is compliant with NFR-2.2")

    sys.exit(0)


if __name__ == '__main__':
    main()
