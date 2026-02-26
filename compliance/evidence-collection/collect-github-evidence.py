#!/usr/bin/env python3
"""
GitHub Evidence Collection for SOC 2 Compliance
Collects evidence from GitHub API and exports to CISO Assistant format
"""

import os
import sys
import json
import requests
from datetime import datetime, timezone
from typing import Dict, List, Any

# GitHub API configuration
GITHUB_TOKEN = os.environ.get('GITHUB_TOKEN')
GITHUB_ORG = 'Seven-Fortunas'
GITHUB_INTERNAL_ORG = 'Seven-Fortunas-Internal'
API_BASE = 'https://api.github.com'

# Evidence output directory
EVIDENCE_DIR = os.environ.get('EVIDENCE_DIR', './evidence')


class GitHubEvidenceCollector:
    """Collects compliance evidence from GitHub"""

    def __init__(self, token: str, org: str):
        self.token = token
        self.org = org
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github.v3+json'
        })

    def _api_get(self, endpoint: str) -> Dict[str, Any]:
        """Make authenticated GET request to GitHub API"""
        url = f"{API_BASE}{endpoint}"
        response = self.session.get(url)
        response.raise_for_status()
        return response.json()

    def collect_2fa_status(self) -> Dict[str, Any]:
        """GH-AC-001: Two-Factor Authentication status"""
        print(f"Collecting 2FA status for {self.org}...")

        # Get all members
        members = self._api_get(f'/orgs/{self.org}/members')

        # Get members without 2FA
        members_no_2fa = self._api_get(f'/orgs/{self.org}/members?filter=2fa_disabled')

        total_members = len(members)
        members_with_2fa = total_members - len(members_no_2fa)
        compliance_rate = (members_with_2fa / total_members * 100) if total_members > 0 else 100

        evidence = {
            'control_id': 'GH-AC-001',
            'control_name': 'Two-Factor Authentication',
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'organization': self.org,
            'metrics': {
                'total_members': total_members,
                'members_with_2fa': members_with_2fa,
                'members_without_2fa': len(members_no_2fa),
                'compliance_rate': round(compliance_rate, 2)
            },
            'compliant': len(members_no_2fa) == 0,
            'evidence_data': {
                'members_without_2fa': [m['login'] for m in members_no_2fa]
            }
        }

        return evidence

    def collect_team_access(self) -> Dict[str, Any]:
        """GH-AC-002: Team-Based Access Control"""
        print(f"Collecting team access for {self.org}...")

        teams = self._api_get(f'/orgs/{self.org}/teams')

        team_details = []
        for team in teams:
            members = self._api_get(f"/teams/{team['id']}/members")
            team_details.append({
                'team_name': team['name'],
                'team_slug': team['slug'],
                'permission': team.get('permission', 'unknown'),
                'member_count': len(members),
                'members': [m['login'] for m in members]
            })

        evidence = {
            'control_id': 'GH-AC-002',
            'control_name': 'Team-Based Access Control',
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'organization': self.org,
            'metrics': {
                'total_teams': len(teams),
                'total_team_members': sum(t['member_count'] for t in team_details)
            },
            'compliant': len(teams) > 0,
            'evidence_data': {
                'teams': team_details
            }
        }

        return evidence

    def collect_branch_protection(self) -> Dict[str, Any]:
        """GH-AC-003: Branch Protection Rules"""
        print(f"Collecting branch protection for {self.org}...")

        repos = self._api_get(f'/orgs/{self.org}/repos')

        repo_protection = []
        for repo in repos:
            try:
                protection = self._api_get(f"/repos/{self.org}/{repo['name']}/branches/main/protection")
                repo_protection.append({
                    'repo_name': repo['name'],
                    'protected': True,
                    'required_reviews': protection.get('required_pull_request_reviews', {}).get('required_approving_review_count', 0),
                    'required_status_checks': protection.get('required_status_checks', {}).get('checks', []),
                    'enforce_admins': protection.get('enforce_admins', {}).get('enabled', False)
                })
            except requests.exceptions.HTTPError as e:
                if e.response.status_code == 404:
                    repo_protection.append({
                        'repo_name': repo['name'],
                        'protected': False
                    })

        protected_count = sum(1 for r in repo_protection if r['protected'])
        compliance_rate = (protected_count / len(repos) * 100) if repos else 0

        evidence = {
            'control_id': 'GH-AC-003',
            'control_name': 'Branch Protection Rules',
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'organization': self.org,
            'metrics': {
                'total_repos': len(repos),
                'protected_repos': protected_count,
                'unprotected_repos': len(repos) - protected_count,
                'compliance_rate': round(compliance_rate, 2)
            },
            'compliant': protected_count == len(repos),
            'evidence_data': {
                'repositories': repo_protection
            }
        }

        return evidence

    def collect_dependabot_alerts(self) -> Dict[str, Any]:
        """GH-MON-002: Dependabot Alerts Monitoring"""
        print(f"Collecting Dependabot alerts for {self.org}...")

        repos = self._api_get(f'/orgs/{self.org}/repos')

        all_alerts = []
        critical_count = 0
        high_count = 0

        for repo in repos:
            try:
                alerts = self._api_get(f"/repos/{self.org}/{repo['name']}/dependabot/alerts?state=open")
                for alert in alerts:
                    severity = alert.get('security_vulnerability', {}).get('severity', 'unknown')
                    all_alerts.append({
                        'repo_name': repo['name'],
                        'severity': severity,
                        'package': alert.get('security_vulnerability', {}).get('package', {}).get('name', 'unknown'),
                        'created_at': alert.get('created_at')
                    })
                    if severity == 'critical':
                        critical_count += 1
                    elif severity == 'high':
                        high_count += 1
            except requests.exceptions.HTTPError:
                # Repository doesn't have Dependabot enabled or no alerts
                pass

        evidence = {
            'control_id': 'GH-MON-002',
            'control_name': 'Dependabot Alerts Monitoring',
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'organization': self.org,
            'metrics': {
                'total_open_alerts': len(all_alerts),
                'critical_alerts': critical_count,
                'high_alerts': high_count
            },
            'compliant': critical_count == 0,
            'evidence_data': {
                'alerts': all_alerts
            }
        }

        return evidence

    def collect_secret_scanning(self) -> Dict[str, Any]:
        """GH-MON-003: Secret Scanning Alerts"""
        print(f"Collecting secret scanning alerts for {self.org}...")

        repos = self._api_get(f'/orgs/{self.org}/repos')

        all_alerts = []

        for repo in repos:
            try:
                alerts = self._api_get(f"/repos/{self.org}/{repo['name']}/secret-scanning/alerts?state=open")
                for alert in alerts:
                    all_alerts.append({
                        'repo_name': repo['name'],
                        'secret_type': alert.get('secret_type', 'unknown'),
                        'created_at': alert.get('created_at'),
                        'state': alert.get('state')
                    })
            except requests.exceptions.HTTPError:
                # Repository doesn't have secret scanning or no alerts
                pass

        evidence = {
            'control_id': 'GH-MON-003',
            'control_name': 'Secret Scanning Alerts',
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'organization': self.org,
            'metrics': {
                'total_open_alerts': len(all_alerts)
            },
            'compliant': len(all_alerts) == 0,
            'evidence_data': {
                'alerts': all_alerts
            }
        }

        return evidence

    def collect_all_evidence(self) -> List[Dict[str, Any]]:
        """Collect all SOC 2 evidence"""
        evidence_items = []

        try:
            evidence_items.append(self.collect_2fa_status())
        except Exception as e:
            print(f"Error collecting 2FA status: {e}")

        try:
            evidence_items.append(self.collect_team_access())
        except Exception as e:
            print(f"Error collecting team access: {e}")

        try:
            evidence_items.append(self.collect_branch_protection())
        except Exception as e:
            print(f"Error collecting branch protection: {e}")

        try:
            evidence_items.append(self.collect_dependabot_alerts())
        except Exception as e:
            print(f"Error collecting Dependabot alerts: {e}")

        try:
            evidence_items.append(self.collect_secret_scanning())
        except Exception as e:
            print(f"Error collecting secret scanning: {e}")

        return evidence_items


def save_evidence(evidence: List[Dict[str, Any]], output_dir: str):
    """Save evidence to JSON files"""
    os.makedirs(output_dir, exist_ok=True)

    timestamp = datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')

    # Save combined evidence
    output_file = os.path.join(output_dir, f'github-evidence-{timestamp}.json')
    with open(output_file, 'w') as f:
        json.dump({
            'collection_timestamp': datetime.now(timezone.utc).isoformat(),
            'evidence_count': len(evidence),
            'evidence': evidence
        }, f, indent=2)

    print(f"\nEvidence saved to: {output_file}")

    # Generate compliance summary
    compliant_count = sum(1 for e in evidence if e.get('compliant', False))
    print(f"\nCompliance Summary:")
    print(f"  Total controls checked: {len(evidence)}")
    print(f"  Compliant controls: {compliant_count}")
    print(f"  Non-compliant controls: {len(evidence) - compliant_count}")
    print(f"  Compliance rate: {round(compliant_count / len(evidence) * 100, 2)}%")


def main():
    """Main execution"""
    if not GITHUB_TOKEN:
        print("Error: GITHUB_TOKEN environment variable not set")
        sys.exit(1)

    print("GitHub Evidence Collection for SOC 2 Compliance")
    print("=" * 60)

    # Collect evidence for both organizations
    all_evidence = []

    for org in [GITHUB_ORG, GITHUB_INTERNAL_ORG]:
        print(f"\nCollecting evidence for {org}...")
        collector = GitHubEvidenceCollector(GITHUB_TOKEN, org)
        evidence = collector.collect_all_evidence()
        all_evidence.extend(evidence)

    # Save evidence
    save_evidence(all_evidence, EVIDENCE_DIR)


if __name__ == '__main__':
    main()
