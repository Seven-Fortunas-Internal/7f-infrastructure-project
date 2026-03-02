#!/bin/bash
# Update progress tracking files

PASS_COUNT=$(jq '[.features[] | select(.status == "pass")] | length' feature_list.json)
PENDING_COUNT=$(jq '[.features[] | select(.status == "pending")] | length' feature_list.json)
FAIL_COUNT=$(jq '[.features[] | select(.status == "fail")] | length' feature_list.json)
BLOCKED_COUNT=$(jq '[.features[] | select(.status == "blocked")] | length' feature_list.json)

sed -i "s/^features_completed=.*/features_completed=$PASS_COUNT/" claude-progress.txt
sed -i "s/^features_pending=.*/features_pending=$PENDING_COUNT/" claude-progress.txt
sed -i "s/^features_fail=.*/features_fail=$FAIL_COUNT/" claude-progress.txt
sed -i "s/^features_blocked=.*/features_blocked=$BLOCKED_COUNT/" claude-progress.txt
sed -i "s/^last_updated=.*/last_updated=$(date -u +%Y-%m-%dT%H:%M:%SZ)/" claude-progress.txt

echo "" >> claude-progress.txt
echo "- FEATURE_012: PASS (FR-3.2: Custom Seven Fortunas Skills)" >> claude-progress.txt

echo "Updated: $PASS_COUNT complete, $PENDING_COUNT pending"
