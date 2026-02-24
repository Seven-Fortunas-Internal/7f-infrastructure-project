#!/bin/bash
#
# Track Monthly Costs - Seven Fortunas Infrastructure
# Target: <10% month-over-month increase
#
# Usage: ./scripts/track-costs.sh

set -e

MONTH=$(date +%Y-%m)
COSTS_FILE="costs/costs-$MONTH.json"

echo "Tracking costs for $MONTH..."

# Get GitHub Actions usage (requires admin access)
ACTIONS_MINUTES=$(gh api /repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)/actions/usage --jq '.total_minutes_used' 2>/dev/null || echo "0")

# Get storage usage
STORAGE_MB=$(du -sm . | cut -f1)

# Get repository count
REPO_COUNT=$(gh repo list Seven-Fortunas --limit 100 --json name --jq 'length' 2>/dev/null || echo "8")

# Create cost report
cat > "$COSTS_FILE" <<EOF
{
  "month": "$MONTH",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "github": {
    "actions_minutes_used": $ACTIONS_MINUTES,
    "actions_minutes_limit": "unlimited (public repos)",
    "repository_count": $REPO_COUNT,
    "storage_mb": $STORAGE_MB
  },
  "estimated_monthly_cost_usd": 0,
  "notes": "All services on free tier"
}
EOF

echo "Cost report saved to: $COSTS_FILE"
cat "$COSTS_FILE" | jq .

# Calculate MoM change if previous month exists
PREV_MONTH=$(date -d '1 month ago' +%Y-%m)
PREV_FILE="costs/costs-$PREV_MONTH.json"

if [ -f "$PREV_FILE" ]; then
  echo ""
  echo "Month-over-Month Analysis:"

  CURRENT=$(jq '.github.actions_minutes_used' "$COSTS_FILE")
  PREVIOUS=$(jq '.github.actions_minutes_used' "$PREV_FILE")

  if [ "$PREVIOUS" != "0" ]; then
    INCREASE=$(echo "scale=2; (($CURRENT - $PREVIOUS) * 100 / $PREVIOUS)" | bc)
    echo "Actions minutes: $PREVIOUS → $CURRENT ($INCREASE% change)"

    if [ "$(echo "$INCREASE > 10" | bc)" -eq 1 ]; then
      echo "⚠️  WARNING: Cost increase ${INCREASE}% exceeds 10% threshold"
    else
      echo "✅ OK: Cost increase ${INCREASE}% within 10% threshold"
    fi
  fi
fi
