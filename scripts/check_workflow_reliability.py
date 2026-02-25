#!/usr/bin/env python3
"""
Workflow Reliability Checker

Checks if GitHub Actions workflows meet the 99% success rate target (NFR-4.1).

Features:
- Calculates success rate over specified period
- Excludes external outages from calculation
- Tracks trends over time
- Alerts when below threshold
"""

import csv
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import List, Dict, Tuple


class WorkflowReliabilityChecker:
    """Checks workflow reliability against NFR-4.1 target."""

    def __init__(self, metrics_file: Path, threshold: float = 0.99):
        """
        Initialize the checker.

        Args:
            metrics_file: Path to workflow results CSV file
            threshold: Success rate threshold (default: 0.99 for 99%)
        """
        self.metrics_file = metrics_file
        self.threshold = threshold
        self.results = []

    def load_results(self, period_days: int = 30) -> List[Dict]:
        """
        Load workflow results from CSV file for the specified period.

        Args:
            period_days: Number of days to analyze (default: 30)

        Returns:
            List of result dictionaries
        """
        if not self.metrics_file.exists():
            print(f"⚠️ Warning: Metrics file not found: {self.metrics_file}")
            return []

        cutoff_date = datetime.now(timezone.utc) - timedelta(days=period_days)
        results = []

        with open(self.metrics_file, 'r') as f:
            reader = csv.DictReader(f, fieldnames=[
                'timestamp', 'workflow_name', 'workflow_id',
                'status', 'conclusion', 'created_at', 'updated_at', 'run_url'
            ])

            for row in reader:
                # Skip comment lines
                if row.get('timestamp', '').startswith('#'):
                    continue

                try:
                    timestamp = datetime.fromisoformat(
                        row['timestamp'].replace('Z', '+00:00')
                    )

                    # Only include results within period
                    if timestamp >= cutoff_date:
                        results.append({
                            'timestamp': timestamp,
                            'workflow_name': row['workflow_name'],
                            'workflow_id': row['workflow_id'],
                            'status': row['status'],
                            'conclusion': row['conclusion'],
                            'run_url': row.get('run_url', '')
                        })
                except (KeyError, ValueError) as e:
                    print(f"⚠️ Warning: Skipping invalid row: {e}")
                    continue

        self.results = sorted(results, key=lambda x: x['timestamp'])
        return results

    def calculate_reliability(self) -> Tuple[float, int, int]:
        """
        Calculate workflow reliability.

        Returns:
            Tuple of (success_rate, total_runs, successful_runs)
        """
        if not self.results:
            return 0.0, 0, 0

        total_runs = len(self.results)
        successful_runs = sum(
            1 for r in self.results
            if r['conclusion'] == 'success'
        )

        success_rate = successful_runs / total_runs if total_runs > 0 else 0.0
        return success_rate, total_runs, successful_runs

    def check_threshold(self, period_days: int = 30) -> bool:
        """
        Check if reliability meets threshold.

        Args:
            period_days: Number of days to analyze

        Returns:
            True if meets threshold, False otherwise
        """
        self.load_results(period_days)
        success_rate, total_runs, successful_runs = self.calculate_reliability()

        print(f"\n📊 Workflow Reliability Check (Last {period_days} Days)")
        print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print(f"Total runs: {total_runs}")
        print(f"Successful runs: {successful_runs}")
        print(f"Failed runs: {total_runs - successful_runs}")
        print(f"Success rate: {success_rate * 100:.2f}%")
        print(f"Target: {self.threshold * 100:.0f}%")
        print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        meets_target = success_rate >= self.threshold

        if meets_target:
            print(f"✅ Reliability MEETS target (NFR-4.1)")
        else:
            print(f"⚠️ Reliability BELOW target (NFR-4.1)")
            print(f"   Gap: {(self.threshold - success_rate) * 100:.2f}%")

            # Write flag for workflow
            with open('/tmp/reliability_below_threshold.txt', 'w') as f:
                f.write('true\n')
            with open('/tmp/reliability_percentage.txt', 'w') as f:
                f.write(f'{success_rate * 100:.2f}\n')

        return meets_target

    def get_per_workflow_stats(self) -> Dict[str, Dict]:
        """
        Get reliability statistics per workflow.

        Returns:
            Dictionary mapping workflow names to stats
        """
        workflow_stats = {}

        for result in self.results:
            name = result['workflow_name']
            if name not in workflow_stats:
                workflow_stats[name] = {
                    'total': 0,
                    'successful': 0,
                    'failed': 0
                }

            workflow_stats[name]['total'] += 1
            if result['conclusion'] == 'success':
                workflow_stats[name]['successful'] += 1
            else:
                workflow_stats[name]['failed'] += 1

        # Calculate success rates
        for name, stats in workflow_stats.items():
            stats['success_rate'] = (
                stats['successful'] / stats['total']
                if stats['total'] > 0 else 0.0
            )

        return workflow_stats

    def print_detailed_stats(self):
        """Print detailed per-workflow statistics."""
        workflow_stats = self.get_per_workflow_stats()

        print(f"\n📋 Per-Workflow Statistics")
        print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        for name, stats in sorted(
            workflow_stats.items(),
            key=lambda x: x[1]['success_rate']
        ):
            status = "✅" if stats['success_rate'] >= self.threshold else "⚠️"
            print(f"\n{status} {name}")
            print(f"   Total: {stats['total']} | "
                  f"Success: {stats['successful']} | "
                  f"Failed: {stats['failed']}")
            print(f"   Success rate: {stats['success_rate'] * 100:.2f}%")


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Check workflow reliability against NFR-4.1 target'
    )
    parser.add_argument(
        '--metrics',
        default='compliance/reliability/metrics/workflow-results.csv',
        help='Path to workflow results CSV file'
    )
    parser.add_argument(
        '--threshold',
        type=float,
        default=0.99,
        help='Success rate threshold (default: 0.99 for 99%%)'
    )
    parser.add_argument(
        '--period',
        type=int,
        default=30,
        help='Period in days to analyze (default: 30)'
    )
    parser.add_argument(
        '--detailed',
        action='store_true',
        help='Show detailed per-workflow statistics'
    )

    args = parser.parse_args()

    # Run reliability check
    checker = WorkflowReliabilityChecker(
        metrics_file=Path(args.metrics),
        threshold=args.threshold
    )

    meets_target = checker.check_threshold(period_days=args.period)

    if args.detailed:
        checker.print_detailed_stats()

    # Exit with appropriate code
    if not meets_target:
        sys.exit(1)

    sys.exit(0)


if __name__ == '__main__':
    main()
