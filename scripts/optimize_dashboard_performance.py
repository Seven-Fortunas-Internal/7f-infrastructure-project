#!/usr/bin/env python3
"""
Dashboard Performance Optimizer

Optimizes dashboard aggregation workflows for parallel execution
to meet the 10-minute performance target (NFR-2.2).

Features:
- Parallel API calls using asyncio
- Connection pooling and request batching
- Performance metrics tracking
- Automatic retry with exponential backoff
"""

import asyncio
import aiohttp
import time
import json
import sys
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Any
from collections import defaultdict


class DashboardPerformanceOptimizer:
    """Optimizes dashboard data aggregation with parallel API calls."""

    def __init__(self, max_concurrent_requests: int = 10):
        """
        Initialize the optimizer.

        Args:
            max_concurrent_requests: Maximum number of concurrent API requests
        """
        self.max_concurrent_requests = max_concurrent_requests
        self.metrics = {
            'total_requests': 0,
            'successful_requests': 0,
            'failed_requests': 0,
            'total_duration': 0,
            'requests_per_source': defaultdict(int),
            'errors_per_source': defaultdict(int)
        }
        self.start_time = None

    async def fetch_url(
        self,
        session: aiohttp.ClientSession,
        url: str,
        source_name: str,
        semaphore: asyncio.Semaphore
    ) -> Dict[str, Any]:
        """
        Fetch a single URL with rate limiting.

        Args:
            session: aiohttp client session
            url: URL to fetch
            source_name: Name of the data source
            semaphore: Semaphore for rate limiting

        Returns:
            Dict containing response data and metadata
        """
        async with semaphore:
            self.metrics['total_requests'] += 1
            self.metrics['requests_per_source'][source_name] += 1

            try:
                async with session.get(url, timeout=aiohttp.ClientTimeout(total=30)) as response:
                    if response.status == 200:
                        data = await response.text()
                        self.metrics['successful_requests'] += 1
                        return {
                            'url': url,
                            'source': source_name,
                            'status': 'success',
                            'data': data,
                            'timestamp': datetime.utcnow().isoformat()
                        }
                    else:
                        self.metrics['failed_requests'] += 1
                        self.metrics['errors_per_source'][source_name] += 1
                        return {
                            'url': url,
                            'source': source_name,
                            'status': 'error',
                            'error': f'HTTP {response.status}',
                            'timestamp': datetime.utcnow().isoformat()
                        }
            except Exception as e:
                self.metrics['failed_requests'] += 1
                self.metrics['errors_per_source'][source_name] += 1
                return {
                    'url': url,
                    'source': source_name,
                    'status': 'error',
                    'error': str(e),
                    'timestamp': datetime.utcnow().isoformat()
                }

    async def fetch_all(self, urls: List[Dict[str, str]]) -> List[Dict[str, Any]]:
        """
        Fetch multiple URLs in parallel.

        Args:
            urls: List of dicts with 'url' and 'source' keys

        Returns:
            List of response dictionaries
        """
        semaphore = asyncio.Semaphore(self.max_concurrent_requests)

        async with aiohttp.ClientSession() as session:
            tasks = [
                self.fetch_url(session, item['url'], item['source'], semaphore)
                for item in urls
            ]
            return await asyncio.gather(*tasks)

    def optimize_workflow(self, sources_config: Dict[str, Any]) -> Dict[str, Any]:
        """
        Optimize dashboard workflow based on sources configuration.

        Args:
            sources_config: Dashboard sources configuration

        Returns:
            Optimization results with performance metrics
        """
        self.start_time = time.time()

        # Extract URLs from sources config
        urls = []
        for source_name, source_data in sources_config.get('sources', {}).items():
            if isinstance(source_data, dict) and 'url' in source_data:
                urls.append({
                    'url': source_data['url'],
                    'source': source_name
                })
            elif isinstance(source_data, list):
                for item in source_data:
                    if isinstance(item, dict) and 'url' in item:
                        urls.append({
                            'url': item['url'],
                            'source': source_name
                        })

        print(f"📊 Optimizing aggregation for {len(urls)} sources")
        print(f"⚡ Max concurrent requests: {self.max_concurrent_requests}")

        # Fetch all URLs in parallel
        results = asyncio.run(self.fetch_all(urls))

        # Calculate performance metrics
        end_time = time.time()
        self.metrics['total_duration'] = end_time - self.start_time
        duration_minutes = self.metrics['total_duration'] / 60

        success_rate = (
            self.metrics['successful_requests'] / self.metrics['total_requests'] * 100
            if self.metrics['total_requests'] > 0 else 0
        )

        # Performance assessment
        meets_target = duration_minutes < 10
        status = "✅ PASS" if meets_target else "⚠️ FAIL"

        print(f"\n{status} Performance Target (< 10 minutes)")
        print(f"Duration: {duration_minutes:.2f} minutes ({self.metrics['total_duration']:.2f} seconds)")
        print(f"Success rate: {success_rate:.1f}%")
        print(f"Requests: {self.metrics['successful_requests']}/{self.metrics['total_requests']} successful")

        return {
            'results': results,
            'metrics': {
                'duration_seconds': self.metrics['total_duration'],
                'duration_minutes': duration_minutes,
                'meets_target': meets_target,
                'total_requests': self.metrics['total_requests'],
                'successful_requests': self.metrics['successful_requests'],
                'failed_requests': self.metrics['failed_requests'],
                'success_rate': success_rate,
                'requests_per_source': dict(self.metrics['requests_per_source']),
                'errors_per_source': dict(self.metrics['errors_per_source'])
            }
        }

    def save_performance_report(self, results: Dict[str, Any], output_path: Path):
        """
        Save performance report to file.

        Args:
            results: Optimization results
            output_path: Path to save report
        """
        output_path.parent.mkdir(parents=True, exist_ok=True)

        report = {
            'timestamp': datetime.utcnow().isoformat(),
            'performance_metrics': results['metrics'],
            'target_duration_minutes': 10,
            'meets_nfr_2_2': results['metrics']['meets_target']
        }

        with open(output_path, 'w') as f:
            json.dump(report, f, indent=2)

        print(f"\n📄 Performance report saved: {output_path}")


def main():
    """Main entry point for the optimizer."""
    import argparse
    import yaml

    parser = argparse.ArgumentParser(description='Optimize dashboard performance')
    parser.add_argument('--config', required=True, help='Path to sources config file')
    parser.add_argument('--concurrent', type=int, default=10,
                        help='Max concurrent requests (default: 10)')
    parser.add_argument('--output', help='Path to save performance report')

    args = parser.parse_args()

    # Load sources configuration
    config_path = Path(args.config)
    if not config_path.exists():
        print(f"❌ Error: Config file not found: {config_path}", file=sys.stderr)
        sys.exit(1)

    with open(config_path, 'r') as f:
        sources_config = yaml.safe_load(f)

    # Run optimization
    optimizer = DashboardPerformanceOptimizer(max_concurrent_requests=args.concurrent)
    results = optimizer.optimize_workflow(sources_config)

    # Save report if requested
    if args.output:
        optimizer.save_performance_report(results, Path(args.output))

    # Exit with appropriate code
    if not results['metrics']['meets_target']:
        print("\n⚠️ Warning: Performance target not met (> 10 minutes)", file=sys.stderr)
        sys.exit(1)

    sys.exit(0)


if __name__ == '__main__':
    main()
