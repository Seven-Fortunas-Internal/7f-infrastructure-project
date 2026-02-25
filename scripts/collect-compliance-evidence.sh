#!/bin/bash
# Collect compliance evidence from GitHub for SOC 2 audit
# Runs daily via GitHub Actions

set -e

ORG="${1:-Seven-Fortunas}"
OUTPUT_DIR="compliance/evidence/$(date +%Y-%m-%d)"

echo "=== Collecting Compliance Evidence for $ORG ==="
echo "Output: $OUTPUT_DIR"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# 1. Organization Settings (CC6.1, CC6.2)
echo "1. Collecting organization settings..."
gh api "/orgs/$ORG" > "$OUTPUT_DIR/org-settings.json"
echo "✓ Org settings collected"

# 2. Security Alerts (CC7.1)
echo "2. Collecting security alerts..."
{
  echo "{"
  echo "  \"secret_scanning_alerts\": $(gh api /orgs/$ORG/secret-scanning/alerts --jq 'length'),"
  echo "  \"dependabot_alerts\": $(gh api /orgs/$ORG/dependabot/alerts --jq 'length')"
  echo "}"
} > "$OUTPUT_DIR/security-alerts.json"
echo "✓ Security alerts collected"

# 3. Access Controls (CC6.3)
echo "3. Collecting access controls..."
gh api "/orgs/$ORG/teams" > "$OUTPUT_DIR/teams.json"
gh api "/orgs/$ORG/members" > "$OUTPUT_DIR/members.json"
echo "✓ Access controls collected"

# 4. Branch Protection Rules (CC8.1, CC8.3)
echo "4. Collecting branch protection rules..."
{
  echo "["
  gh api "/orgs/$ORG/repos" --jq '.[].name' | while read repo; do
    echo "  {"
    echo "    \"repo\": \"$repo\","
    echo "    \"protection\": $(gh api "/repos/$ORG/$repo/branches/main/protection" 2>/dev/null || echo 'null')"
    echo "  },"
  done | sed '$ s/,$//'
  echo "]"
} > "$OUTPUT_DIR/branch-protection.json"
echo "✓ Branch protection rules collected"

# 5. Audit Events (CC6.6, CC7.2)
echo "5. Collecting audit events (last 30 days)..."
gh api "/orgs/$ORG/audit-log?per_page=100" > "$OUTPUT_DIR/audit-events.json"
echo "✓ Audit events collected"

# 6. Create summary
echo "6. Creating evidence summary..."
cat > "$OUTPUT_DIR/summary.md" << EOF
# Compliance Evidence Summary
**Date:** $(date -u +%Y-%m-%d)
**Organization:** $ORG

## Files Collected
- org-settings.json (Organization security settings)
- security-alerts.json (Active security alerts)
- teams.json (Team structure)
- members.json (Member list)
- branch-protection.json (Repository protection rules)
- audit-events.json (Audit log - last 30 days)

## Control Status
$(jq -r '
  "- 2FA Required: \(.two_factor_requirement_enabled)",
  "- Default Permission: \(.default_repository_permission)",
  "- Members Can Create Repos: \(.members_can_create_repositories)"
' "$OUTPUT_DIR/org-settings.json")

## Security Alerts
$(jq -r '
  "- Secret Scanning Alerts: \(.secret_scanning_alerts)",
  "- Dependabot Alerts: \(.dependabot_alerts)"
' "$OUTPUT_DIR/security-alerts.json")

## Evidence Collection Status
✓ All evidence collected successfully
EOF

echo "✓ Summary created"

# 7. Update latest symlink
echo "7. Updating latest symlink..."
cd compliance/evidence
rm -f latest
ln -s "$(date +%Y-%m-%d)" latest
cd ../..
echo "✓ Latest symlink updated"

echo ""
echo "✓ Evidence collection complete: $OUTPUT_DIR"
