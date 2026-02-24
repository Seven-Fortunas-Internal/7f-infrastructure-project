#!/usr/bin/env python3
"""
Rate Limit Usage Analyzer

Analyzes API rate limit usage and generates compliance reports (NFR-6.1).

Features:
- Usage statistics per API
- Compliance checking
- Violation analysis
- Trend reporting
"""

import json
import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict
from collections import defaultdict


class RateLimitAnalyzer:
    """Analyzes rate limit usage and compliance."""

    def __init__(self, metrics_dir: Path):
        """
        Initialize analyzer.

        Args:
            metrics_dir: Directory containing rate limit metrics
        """
        self.metrics_dir = metrics_dir
        self.github_metrics = []
        self.usage_metrics = []
        self.violations = []

    def load_metrics(self, days: int = 7):
        """
        Load metrics from files.

        Args:
            days: Number of days to analyze
        """
        cutoff = datetime.utcnow() - timedelta(days=days)

        # Load GitHub rate limit metrics
        github_file = self.metrics_dir / 'github-rate-limit.jsonl'
        if github_file.exists():
            with open(github_file, 'r') as f:
                for line in f:
                    metric = json.loads(line)
                    timestamp = datetime.fromisoformat(
                        metric['timestamp'].replace('Z', '+00:00')
                    )
                    if timestamp >= cutoff:
                        self.github_metrics.append(metric)

        # Load general API usage metrics
        usage_file = self.metrics_dir / 'api-usage.jsonl'
        if usage_file.exists():
            with open(usage_file, 'r') as f:
                for line in f:
                    metric = json.loads(line)
                    timestamp = datetime.fromisoformat(
                        metric['timestamp'].replace('Z', '+00:00')
                    )
                    if timestamp >= cutoff:
                        self.usage_metrics.append(metric)

        # Load violations
        violations_file = self.metrics_dir / 'violations.jsonl'
        if violations_file.exists():
            with open(violations_file, 'r') as f:
                for line in f:
                    violation = json.loads(line)
                    timestamp = datetime.fromisoformat(
                        violation['timestamp'].replace('Z', '+00:00')
                    )
                    if timestamp >= cutoff:
                        self.violations.append(violation)

    def analyze_github_usage(self) -> Dict:
        """
        Analyze GitHub API usage.

        Returns:
            Dictionary containing GitHub usage stats
        """
        if not self.github_metrics:
            return {'no_data': True}

        # Get latest metrics
        latest = self.github_metrics[-1]

        core_limit = latest['core']['limit']
        core_used = latest['core']['used']
        core_remaining = latest['core']['remaining']
        core_usage_pct = (core_used / core_limit * 100) if core_limit > 0 else 0

        # Calculate average usage over period
        total_used = sum(m['core']['used'] for m in self.github_metrics)
        avg_used = total_used / len(self.github_metrics)
        avg_usage_pct = (avg_used / core_limit * 100) if core_limit > 0 else 0

        return {
            'api': 'github',
            'limit': core_limit,
            'current_used': core_used,
            'current_remaining': core_remaining,
            'current_usage_pct': core_usage_pct,
            'avg_used': avg_used,
            'avg_usage_pct': avg_usage_pct,
            'samples': len(self.github_metrics),
            'compliant': core_usage_pct < 100
        }

    def analyze_api_usage(self) -> Dict[str, Dict]:
        """
        Analyze usage for all APIs.

        Returns:
            Dictionary mapping API names to usage stats
        """
        api_stats = defaultdict(lambda: {
            'total_requests': 0,
            'throttled_requests': 0,
            'violations': 0
        })

        for metric in self.usage_metrics:
            api = metric['api']
            api_stats[api]['total_requests'] += metric.get('total_requests', 0)
            api_stats[api]['throttled_requests'] += metric.get('throttled_requests', 0)
            api_stats[api]['violations'] += metric.get('violations', 0)

        return dict(api_stats)

    def analyze_violations(self) -> Dict:
        """
        Analyze rate limit violations.

        Returns:
            Dictionary containing violation statistics
        """
        if not self.violations:
            return {
                'total': 0,
                'by_api': {},
                'compliant': True
            }

        # Group by API
        by_api = defaultdict(int)
        for violation in self.violations:
            by_api[violation['api']] += 1

        return {
            'total': len(self.violations),
            'by_api': dict(by_api),
            'compliant': len(self.violations) == 0,
            'violations': self.violations
        }

    def generate_report(self, days: int = 7) -> str:
        """
        Generate compliance report.

        Args:
            days: Number of days analyzed

        Returns:
            Formatted report string
        """
        self.load_metrics(days)

        github_stats = self.analyze_github_usage()
        api_stats = self.analyze_api_usage()
        violation_stats = self.analyze_violations()

        # Report header
        report = f"""# API Rate Limit Compliance Report (NFR-6.1)

**Period:** Last {days} days
**Generated:** {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}
**Requirement:** System SHALL respect rate limits of all external APIs

---

## Compliance Status

"""

        # Overall compliance
        is_compliant = violation_stats['compliant'] and github_stats.get('compliant', True)

        if is_compliant:
            report += "### ✅ COMPLIANT\n\n"
            report += "All API usage is within rate limits.\n\n"
        else:
            report += "### ⚠️ NON-COMPLIANT\n\n"
            report += "Rate limit violations detected.\n\n"

        # GitHub API stats
        report += "## GitHub API\n\n"

        if github_stats.get('no_data'):
            report += "No data available.\n\n"
        else:
            status = "✅" if github_stats['compliant'] else "⚠️"
            report += f"""
{status} **Current Usage:** {github_stats['current_usage_pct']:.1f}%
- Limit: {github_stats['limit']} requests/hour
- Used: {github_stats['current_used']}
- Remaining: {github_stats['current_remaining']}

**Average Usage:** {github_stats['avg_usage_pct']:.1f}%
- Samples: {github_stats['samples']}
"""

        # Other APIs
        if api_stats:
            report += "\n## Other API Usage\n\n"

            for api, stats in sorted(api_stats.items()):
                report += f"""
### {api.upper()}
- Total Requests: {stats['total_requests']}
- Throttled: {stats['throttled_requests']}
- Violations: {stats['violations']}
"""

        # Violations
        report += "\n## Violations\n\n"

        if violation_stats['total'] == 0:
            report += "✅ No rate limit violations detected.\n\n"
        else:
            report += f"⚠️ **{violation_stats['total']} violations detected**\n\n"

            for api, count in violation_stats['by_api'].items():
                report += f"- {api.upper()}: {count} violations\n"

            report += "\n### Recent Violations\n\n"
            for v in violation_stats['violations'][:10]:  # Show last 10
                report += f"- {v['timestamp']}: {v['api']} - {v.get('violation_type', 'unknown')}\n"

        # Rate limit configuration
        report += "\n## Configured Rate Limits\n\n"
        report += """
| API | Limit | Period |
|-----|-------|--------|
| GitHub | 5,000 req | 1 hour (authenticated) |
| Claude | 50 req / 40,000 req | 1 minute / 1 day |
| Reddit | 60 req | 1 minute (unauthenticated) |
| OpenAI Whisper | ~50 req | 1 minute (conservative) |
| X API | 10,000 req | 1 month ($100/mo tier) |
"""

        # Recommendations
        report += "\n## Recommendations\n\n"

        if is_compliant:
            report += "Current API usage is compliant. Continue monitoring.\n\n"
        else:
            report += "**Action Required:**\n"
            report += "- Review violations and identify root cause\n"
            report += "- Implement additional throttling if needed\n"
            report += "- Consider caching to reduce API calls\n"
            report += "- Optimize workflow schedules to distribute load\n"

        report += "\n---\n\n*Report generated automatically by Rate Limit Analyzer*\n"

        return report


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Analyze API rate limit usage and compliance'
    )
    parser.add_argument(
        '--metrics-dir',
        default='compliance/rate-limits/metrics',
        help='Directory containing rate limit metrics'
    )
    parser.add_argument(
        '--days',
        type=int,
        default=7,
        help='Number of days to analyze (default: 7)'
    )
    parser.add_argument(
        '--output',
        help='Path to save report (optional)'
    )

    args = parser.parse_args()

    # Run analysis
    analyzer = RateLimitAnalyzer(metrics_dir=Path(args.metrics_dir))
    report = analyzer.generate_report(days=args.days)

    # Print report
    print(report)

    # Save report if requested
    if args.output:
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w') as f:
            f.write(report)
        print(f"\n📄 Report saved: {output_path}", file=sys.stderr)

    sys.exit(0)


if __name__ == '__main__':
    main()
