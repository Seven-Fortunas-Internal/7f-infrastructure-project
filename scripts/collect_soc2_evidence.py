#!/usr/bin/env python3
"""
SOC 2 Evidence Collection Script
Collects evidence from GitHub for SOC 2 compliance
"""

import json
import os
import sys
from datetime import datetime
from pathlib import Path
import subprocess

class SOC2EvidenceCollector:
    def __init__(self, org_name="Seven-Fortunas-Internal"):
        self.org_name = org_name
        self.evidence_dir = Path(f"compliance/evidence/{datetime.utcnow().strftime('%Y-%m-%d')}")
        self.evidence_dir.mkdir(parents=True, exist_ok=True)

        print(f"=== SOC 2 Evidence Collection ===")
        print(f"Organization: {self.org_name}")
        print(f"Date: {datetime.utcnow().strftime('%Y-%m-%d')}")
        print(f"Output: {self.evidence_dir}")
        print()

    def run_gh_api(self, endpoint):
        """Run GitHub API call via gh CLI"""
        try:
            result = subprocess.run(
                ['gh', 'api', endpoint],
                capture_output=True,
                text=True,
                check=True
            )
            return json.loads(result.stdout)
        except subprocess.CalledProcessError as e:
            print(f"Error calling API {endpoint}: {e.stderr}")
            return None
        except json.JSONDecodeError as e:
            print(f"Error parsing JSON from {endpoint}: {e}")
            return None

    def collect_2fa_status(self):
        """Collect 2FA status for all organization members"""
        print("Collecting 2FA status...")

        members = self.run_gh_api(f"/orgs/{self.org_name}/members")
        if not members:
            print("  ✗ Failed to fetch members")
            return

        # Get detailed member info
        member_details = []
        for member in members:
            detail = self.run_gh_api(f"/users/{member['login']}")
            if detail:
                member_details.append({
                    'login': member['login'],
                    'name': detail.get('name', 'N/A'),
                    'created_at': detail.get('created_at'),
                    'two_factor_enabled': detail.get('two_factor_authentication', False)
                })

        output_file = self.evidence_dir / '2fa_status.json'
        with open(output_file, 'w') as f:
            json.dump({
                'organization': self.org_name,
                'collected_at': datetime.utcnow().isoformat(),
                'member_count': len(member_details),
                'members': member_details
            }, f, indent=2)

        print(f"  ✓ 2FA status saved: {output_file}")

    def collect_access_control_config(self):
        """Collect organization access control configuration"""
        print("Collecting access control configuration...")

        org_config = self.run_gh_api(f"/orgs/{self.org_name}")
        if not org_config:
            print("  ✗ Failed to fetch org config")
            return

        access_control = {
            'organization': self.org_name,
            'collected_at': datetime.utcnow().isoformat(),
            'default_repository_permission': org_config.get('default_repository_permission'),
            'members_can_create_repositories': org_config.get('members_can_create_repositories'),
            'members_can_create_public_repositories': org_config.get('members_can_create_public_repositories'),
            'members_can_create_private_repositories': org_config.get('members_can_create_private_repositories'),
            'two_factor_requirement_enabled': org_config.get('two_factor_requirement_enabled'),
        }

        output_file = self.evidence_dir / 'access_control_config.json'
        with open(output_file, 'w') as f:
            json.dump(access_control, f, indent=2)

        print(f"  ✓ Access control config saved: {output_file}")

    def collect_secret_scanning_alerts(self):
        """Collect secret scanning alerts for all repositories"""
        print("Collecting secret scanning alerts...")

        repos = self.run_gh_api(f"/orgs/{self.org_name}/repos")
        if not repos:
            print("  ✗ Failed to fetch repos")
            return

        all_alerts = []
        for repo in repos:
            repo_name = repo['name']
            alerts = self.run_gh_api(f"/repos/{self.org_name}/{repo_name}/secret-scanning/alerts")

            if alerts and isinstance(alerts, list):
                for alert in alerts:
                    all_alerts.append({
                        'repository': repo_name,
                        'number': alert.get('number'),
                        'state': alert.get('state'),
                        'secret_type': alert.get('secret_type'),
                        'created_at': alert.get('created_at'),
                        'resolved_at': alert.get('resolved_at')
                    })

        output_file = self.evidence_dir / 'secret_scanning_alerts.json'
        with open(output_file, 'w') as f:
            json.dump({
                'organization': self.org_name,
                'collected_at': datetime.utcnow().isoformat(),
                'alert_count': len(all_alerts),
                'alerts': all_alerts
            }, f, indent=2)

        print(f"  ✓ Secret scanning alerts saved: {output_file}")

    def collect_dependabot_alerts(self):
        """Collect Dependabot alerts for all repositories"""
        print("Collecting Dependabot alerts...")

        repos = self.run_gh_api(f"/orgs/{self.org_name}/repos")
        if not repos:
            print("  ✗ Failed to fetch repos")
            return

        all_alerts = []
        for repo in repos:
            repo_name = repo['name']
            alerts = self.run_gh_api(f"/repos/{self.org_name}/{repo_name}/dependabot/alerts")

            if alerts and isinstance(alerts, list):
                for alert in alerts:
                    all_alerts.append({
                        'repository': repo_name,
                        'number': alert.get('number'),
                        'state': alert.get('state'),
                        'severity': alert.get('security_advisory', {}).get('severity'),
                        'created_at': alert.get('created_at'),
                        'fixed_at': alert.get('fixed_at')
                    })

        output_file = self.evidence_dir / 'dependabot_alerts.json'
        with open(output_file, 'w') as f:
            json.dump({
                'organization': self.org_name,
                'collected_at': datetime.utcnow().isoformat(),
                'alert_count': len(all_alerts),
                'alerts': all_alerts
            }, f, indent=2)

        print(f"  ✓ Dependabot alerts saved: {output_file}")

    def collect_branch_protection(self):
        """Collect branch protection status for all repositories"""
        print("Collecting branch protection status...")

        repos = self.run_gh_api(f"/orgs/{self.org_name}/repos")
        if not repos:
            print("  ✗ Failed to fetch repos")
            return

        protection_status = []
        for repo in repos:
            repo_name = repo['name']
            default_branch = repo.get('default_branch', 'main')

            protection = self.run_gh_api(
                f"/repos/{self.org_name}/{repo_name}/branches/{default_branch}/protection"
            )

            if protection:
                protection_status.append({
                    'repository': repo_name,
                    'branch': default_branch,
                    'protected': True,
                    'required_reviews': protection.get('required_pull_request_reviews', {}).get('required_approving_review_count', 0),
                    'required_status_checks': len(protection.get('required_status_checks', {}).get('contexts', [])),
                    'enforce_admins': protection.get('enforce_admins', {}).get('enabled', False)
                })
            else:
                protection_status.append({
                    'repository': repo_name,
                    'branch': default_branch,
                    'protected': False
                })

        output_file = self.evidence_dir / 'branch_protection.json'
        with open(output_file, 'w') as f:
            json.dump({
                'organization': self.org_name,
                'collected_at': datetime.utcnow().isoformat(),
                'repository_count': len(protection_status),
                'protection_status': protection_status
            }, f, indent=2)

        print(f"  ✓ Branch protection status saved: {output_file}")

    def collect_audit_log(self):
        """Collect organization audit log (last 7 days)"""
        print("Collecting audit log...")

        # Note: Audit log requires organization owner permissions
        # Format: /orgs/{org}/audit-log?phrase=created:>YYYY-MM-DD
        from_date = (datetime.utcnow() - timedelta(days=7)).strftime('%Y-%m-%d')
        audit_log = self.run_gh_api(f"/orgs/{self.org_name}/audit-log?phrase=created:>{from_date}")

        if not audit_log:
            print("  ⚠  Audit log requires organization owner permissions")
            audit_log = []

        output_file = self.evidence_dir / 'audit_log.json'
        with open(output_file, 'w') as f:
            json.dump({
                'organization': self.org_name,
                'collected_at': datetime.utcnow().isoformat(),
                'period': f'Last 7 days (from {from_date})',
                'event_count': len(audit_log) if isinstance(audit_log, list) else 0,
                'events': audit_log if isinstance(audit_log, list) else []
            }, f, indent=2)

        print(f"  ✓ Audit log saved: {output_file}")

    def generate_summary(self):
        """Generate evidence collection summary"""
        print("\nGenerating summary...")

        summary = {
            'organization': self.org_name,
            'collection_date': datetime.utcnow().isoformat(),
            'evidence_collected': [
                '2fa_status.json',
                'access_control_config.json',
                'secret_scanning_alerts.json',
                'dependabot_alerts.json',
                'branch_protection.json',
                'audit_log.json'
            ],
            'status': 'complete'
        }

        output_file = self.evidence_dir / 'summary.json'
        with open(output_file, 'w') as f:
            json.dump(summary, f, indent=2)

        print(f"  ✓ Summary saved: {output_file}")
        print("\n=== Evidence Collection Complete ===")

    def run(self):
        """Main execution flow"""
        self.collect_2fa_status()
        self.collect_access_control_config()
        self.collect_secret_scanning_alerts()
        self.collect_dependabot_alerts()
        self.collect_branch_protection()
        self.collect_audit_log()
        self.generate_summary()

if __name__ == '__main__':
    from datetime import timedelta

    try:
        collector = SOC2EvidenceCollector()
        collector.run()
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
