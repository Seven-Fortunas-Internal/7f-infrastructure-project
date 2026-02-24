#!/usr/bin/env python3
"""
Workflow Reliability Report Generator

Generates monthly reports on GitHub Actions workflow reliability (NFR-4.1).

Features:
- Monthly reliability statistics
- Failure analysis and classification
- Trend analysis over time
- Recommendations for improvement
"""

import csv
import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict
from collections import defaultdict


class ReliabilityReportGenerator:
    """Generates workflow reliability reports."""

    def __init__(
        self,
        metrics_file: Path,
        classifications_file: Path,
        threshold: float = 0.99
    ):
        """
        Initialize the report generator.

        Args:
            metrics_file: Path to workflow results CSV
            classifications_file: Path to failure classifications CSV
            threshold: Success rate threshold (default: 0.99)
        """
        self.metrics_file = metrics_file
        self.classifications_file = classifications_file
        self.threshold = threshold
        self.results = []
        self.classifications = []

    def load_data(self, month: str = None):
        """
        Load workflow results and classifications.

        Args:
            month: Month to load (YYYY-MM format), None for current month
        """
        if month is None:
            month = datetime.utcnow().strftime('%Y-%m')

        # Load workflow results
        if self.metrics_file.exists():
            with open(self.metrics_file, 'r') as f:
                reader = csv.DictReader(f, fieldnames=[
                    'timestamp', 'workflow_name', 'workflow_id',
                    'status', 'conclusion', 'created_at', 'updated_at', 'run_url'
                ])

                for row in reader:
                    if row.get('timestamp', '').startswith('#'):
                        continue

                    try:
                        timestamp = datetime.fromisoformat(
                            row['timestamp'].replace('Z', '+00:00')
                        )

                        # Filter by month
                        if timestamp.strftime('%Y-%m') == month:
                            self.results.append({
                                'timestamp': timestamp,
                                'workflow_name': row['workflow_name'],
                                'workflow_id': row['workflow_id'],
                                'conclusion': row['conclusion'],
                                'run_url': row.get('run_url', '')
                            })
                    except (KeyError, ValueError):
                        continue

        # Load failure classifications
        if self.classifications_file.exists():
            with open(self.classifications_file, 'r') as f:
                reader = csv.DictReader(f, fieldnames=[
                    'timestamp', 'workflow_name', 'workflow_id',
                    'failure_type', 'failure_reason'
                ])

                for row in reader:
                    if row.get('timestamp', '').startswith('#'):
                        continue

                    try:
                        timestamp = datetime.fromisoformat(
                            row['timestamp'].replace('Z', '+00:00')
                        )

                        if timestamp.strftime('%Y-%m') == month:
                            self.classifications.append({
                                'timestamp': timestamp,
                                'workflow_name': row['workflow_name'],
                                'workflow_id': row['workflow_id'],
                                'failure_type': row['failure_type'],
                                'failure_reason': row['failure_reason']
                            })
                    except (KeyError, ValueError):
                        continue

    def calculate_statistics(self) -> Dict:
        """
        Calculate reliability statistics.

        Returns:
            Dictionary containing statistics
        """
        total_runs = len(self.results)
        successful_runs = sum(
            1 for r in self.results if r['conclusion'] == 'success'
        )
        failed_runs = total_runs - successful_runs

        # Calculate overall success rate
        overall_success_rate = (
            successful_runs / total_runs if total_runs > 0 else 0.0
        )

        # Classify failures
        internal_failures = sum(
            1 for c in self.classifications
            if c['failure_type'] == 'internal'
        )
        external_failures = sum(
            1 for c in self.classifications
            if c['failure_type'] == 'external'
        )

        # Calculate internal success rate (excluding external failures)
        internal_runs = total_runs - external_failures
        internal_successful = successful_runs
        internal_success_rate = (
            internal_successful / internal_runs
            if internal_runs > 0 else 0.0
        )

        # Per-workflow statistics
        workflow_stats = defaultdict(lambda: {
            'total': 0, 'successful': 0, 'failed': 0
        })

        for result in self.results:
            name = result['workflow_name']
            workflow_stats[name]['total'] += 1
            if result['conclusion'] == 'success':
                workflow_stats[name]['successful'] += 1
            else:
                workflow_stats[name]['failed'] += 1

        for name, stats in workflow_stats.items():
            stats['success_rate'] = (
                stats['successful'] / stats['total']
                if stats['total'] > 0 else 0.0
            )

        return {
            'total_runs': total_runs,
            'successful_runs': successful_runs,
            'failed_runs': failed_runs,
            'overall_success_rate': overall_success_rate,
            'internal_failures': internal_failures,
            'external_failures': external_failures,
            'internal_success_rate': internal_success_rate,
            'workflow_stats': dict(workflow_stats),
            'meets_target': internal_success_rate >= self.threshold
        }

    def generate_report(self, month: str = None) -> str:
        """
        Generate monthly reliability report.

        Args:
            month: Month to report on (YYYY-MM format)

        Returns:
            Formatted report string
        """
        if month is None:
            month = datetime.utcnow().strftime('%Y-%m')

        self.load_data(month)
        stats = self.calculate_statistics()

        # Report header
        report = f"""# Monthly Workflow Reliability Report

**Month:** {month}
**Generated:** {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}
**Requirement:** NFR-4.1 - GitHub Actions workflows SHALL succeed 99% of the time

---

## Executive Summary

"""

        # Compliance status
        if stats['meets_target']:
            report += "### ✅ Compliance Status: COMPLIANT\n\n"
            report += f"Workflow reliability meets the 99% success rate target.\n\n"
        else:
            report += "### ⚠️ Compliance Status: NON-COMPLIANT\n\n"
            report += f"Workflow reliability is below the 99% success rate target.\n\n"

        # Overall statistics
        report += f"""## Overall Statistics

- **Total Runs:** {stats['total_runs']}
- **Successful Runs:** {stats['successful_runs']}
- **Failed Runs:** {stats['failed_runs']}
- **Overall Success Rate:** {stats['overall_success_rate'] * 100:.2f}%

### Failure Classification

- **Internal Failures:** {stats['internal_failures']} (configuration errors, code bugs, rate limits)
- **External Failures:** {stats['external_failures']} (confirmed external service outages)
- **Internal Success Rate:** {stats['internal_success_rate'] * 100:.2f}% (excluding external outages)

**Target:** >= 99.0%
**Status:** {'✅ MEETS' if stats['meets_target'] else '❌ BELOW'} target

---

## Per-Workflow Statistics

"""

        # Per-workflow breakdown
        for name, wstats in sorted(
            stats['workflow_stats'].items(),
            key=lambda x: x[1]['success_rate']
        ):
            status = "✅" if wstats['success_rate'] >= self.threshold else "⚠️"
            report += f"""
### {status} {name}

- Total Runs: {wstats['total']}
- Successful: {wstats['successful']}
- Failed: {wstats['failed']}
- Success Rate: {wstats['success_rate'] * 100:.2f}%
"""

        # Failure analysis
        if stats['failed_runs'] > 0:
            report += "\n---\n\n## Failure Analysis\n\n"

            # Group failures by type
            internal_by_workflow = defaultdict(int)
            external_by_workflow = defaultdict(int)

            for classification in self.classifications:
                name = classification['workflow_name']
                if classification['failure_type'] == 'internal':
                    internal_by_workflow[name] += 1
                else:
                    external_by_workflow[name] += 1

            if internal_failures := stats['internal_failures']:
                report += f"### Internal Failures ({internal_failures} total)\n\n"
                for name, count in sorted(
                    internal_by_workflow.items(),
                    key=lambda x: x[1],
                    reverse=True
                ):
                    report += f"- **{name}:** {count} failures\n"

            if external_failures := stats['external_failures']:
                report += f"\n### External Failures ({external_failures} total)\n\n"
                for name, count in sorted(
                    external_by_workflow.items(),
                    key=lambda x: x[1],
                    reverse=True
                ):
                    report += f"- **{name}:** {count} failures (external outage)\n"

        # Recommendations
        report += "\n---\n\n## Recommendations\n\n"

        if stats['meets_target']:
            report += "Workflow reliability is meeting targets. Continue monitoring.\n\n"
            report += "**Suggested Actions:**\n"
            report += "- Monitor trends for early warning signs\n"
            report += "- Review failure patterns monthly\n"
            report += "- Document external outage classifications\n"
        else:
            gap = (self.threshold - stats['internal_success_rate']) * 100
            report += f"**Gap to Target:** {gap:.2f}%\n\n"
            report += "**Immediate Actions Required:**\n"

            if stats['internal_failures'] > stats['external_failures']:
                report += "- **Priority: Address internal failures**\n"
                report += "  - Review workflow configurations\n"
                report += "  - Fix code bugs and syntax errors\n"
                report += "  - Implement better error handling\n"
                report += "  - Add retry logic for transient failures\n"

            if stats['external_failures'] > 0:
                report += "- Verify external outage classifications\n"
                report += "- Consider fallback strategies for external dependencies\n"

            # Identify problematic workflows
            problem_workflows = [
                name for name, wstats in stats['workflow_stats'].items()
                if wstats['success_rate'] < self.threshold
            ]

            if problem_workflows:
                report += f"\n**Focus on problematic workflows:**\n"
                for name in problem_workflows:
                    report += f"- {name}\n"

        report += "\n---\n\n"
        report += "*Report generated automatically by Workflow Reliability Tracker*\n"

        return report

    def save_report(self, output_path: Path, month: str = None):
        """
        Save reliability report to file.

        Args:
            output_path: Path to save report
            month: Month to report on (YYYY-MM format)
        """
        output_path.parent.mkdir(parents=True, exist_ok=True)

        report = self.generate_report(month)

        with open(output_path, 'w') as f:
            f.write(report)

        print(f"📄 Reliability report saved: {output_path}")


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Generate monthly workflow reliability report'
    )
    parser.add_argument(
        '--metrics',
        default='compliance/reliability/metrics/workflow-results.csv',
        help='Path to workflow results CSV'
    )
    parser.add_argument(
        '--classifications',
        default='compliance/reliability/metrics/failure-classifications.csv',
        help='Path to failure classifications CSV'
    )
    parser.add_argument(
        '--output',
        required=True,
        help='Path to save report'
    )
    parser.add_argument(
        '--month',
        help='Month to report on (YYYY-MM format), default: current month'
    )
    parser.add_argument(
        '--threshold',
        type=float,
        default=0.99,
        help='Success rate threshold (default: 0.99)'
    )

    args = parser.parse_args()

    # Generate report
    generator = ReliabilityReportGenerator(
        metrics_file=Path(args.metrics),
        classifications_file=Path(args.classifications),
        threshold=args.threshold
    )

    generator.save_report(
        output_path=Path(args.output),
        month=args.month
    )

    # Check if below threshold and write flag for workflow
    stats = generator.calculate_statistics()
    if not stats['meets_target']:
        with open('/tmp/reliability_below_threshold.txt', 'w') as f:
            f.write('true\n')
        with open('/tmp/reliability_percentage.txt', 'w') as f:
            f.write(f"{stats['internal_success_rate'] * 100:.2f}\n")

    sys.exit(0)


if __name__ == '__main__':
    main()
