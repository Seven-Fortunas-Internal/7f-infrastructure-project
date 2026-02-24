#!/bin/bash
# SOC 2 Control Posture Checker
# Monitors GitHub organization settings for SOC 2 compliance in real-time
# Version: 1.0

set -euo pipefail

# Configuration
ORG="${1:-Seven-Fortunas-Internal}"
OUTPUT_DIR="compliance/soc2/reports"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
REPORT_FILE="${OUTPUT_DIR}/control-posture-${TIMESTAMP}.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

echo "=== SOC 2 Control Posture Check ==="
echo "Organization: $ORG"
echo "Timestamp: $TIMESTAMP"
echo ""

# Initialize results
CONTROLS_PASSED=0
CONTROLS_FAILED=0
CONTROLS_TOTAL=0

# Initialize JSON report
cat > "$REPORT_FILE" <<EOF
{
  "timestamp": "$TIMESTAMP",
  "organization": "$ORG",
  "controls": [],
  "summary": {
    "total": 0,
    "passed": 0,
    "failed": 0,
    "compliance_percentage": 0
  }
}
EOF

# Function to check a control
check_control() {
    local control_id="$1"
    local control_name="$2"
    local check_command="$3"
    local expected_value="$4"

    CONTROLS_TOTAL=$((CONTROLS_TOTAL + 1))

    echo "Checking $control_id: $control_name"

    # Execute the check
    actual_value=$(eval "$check_command" 2>/dev/null || echo "ERROR")

    # Determine pass/fail
    if [ "$actual_value" = "$expected_value" ]; then
        echo -e "  ${GREEN}✓ PASS${NC} (Expected: $expected_value, Actual: $actual_value)"
        CONTROLS_PASSED=$((CONTROLS_PASSED + 1))
        status="pass"
    else
        echo -e "  ${RED}✗ FAIL${NC} (Expected: $expected_value, Actual: $actual_value)"
        CONTROLS_FAILED=$((CONTROLS_FAILED + 1))
        status="fail"
    fi

    # Add to JSON report
    jq --arg id "$control_id" \
       --arg name "$control_name" \
       --arg status "$status" \
       --arg expected "$expected_value" \
       --arg actual "$actual_value" \
       '.controls += [{
         "control_id": $id,
         "control_name": $name,
         "status": $status,
         "expected_value": $expected,
         "actual_value": $actual,
         "checked_at": "'$TIMESTAMP'"
       }]' "$REPORT_FILE" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "$REPORT_FILE"
}

# CC6.1.1: Two-Factor Authentication (2FA)
check_control \
    "GH-ACCESS-001" \
    "Two-Factor Authentication Required" \
    "gh api /orgs/$ORG --jq '.two_factor_requirement_enabled'" \
    "true"

# CC6.1.2: Default Repository Permission
check_control \
    "GH-ACCESS-002" \
    "Default Repository Permission = None" \
    "gh api /orgs/$ORG --jq '.default_repository_permission'" \
    "none"

# CC6.6.1: Members Can Create Repositories
check_control \
    "GH-ACCESS-003" \
    "Members Cannot Create Public Repos" \
    "gh api /orgs/$ORG --jq '.members_can_create_public_repositories'" \
    "false"

# CC7.2.1: Branch Protection on Main
# Check if seven-fortunas-brain repository has branch protection
check_control \
    "GH-SEC-001" \
    "Branch Protection Enabled (seven-fortunas-brain)" \
    "gh api /repos/$ORG/seven-fortunas-brain/branches/main/protection 2>/dev/null && echo 'true' || echo 'false'" \
    "true"

# CC8.1.1: Secret Scanning
check_control \
    "GH-SEC-002" \
    "Secret Scanning Enabled (Org Level)" \
    "gh api /orgs/$ORG --jq '.advanced_security_enabled_for_new_repositories'" \
    "true"

# CC8.1.2: Dependabot Alerts
check_control \
    "GH-SEC-003" \
    "Dependabot Alerts Enabled (Org Level)" \
    "gh api /orgs/$ORG --jq '.dependabot_alerts_enabled_for_new_repositories'" \
    "true"

# Calculate compliance percentage
COMPLIANCE_PCT=0
if [ "$CONTROLS_TOTAL" -gt 0 ]; then
    COMPLIANCE_PCT=$((CONTROLS_PASSED * 100 / CONTROLS_TOTAL))
fi

# Update summary in JSON
jq --argjson total "$CONTROLS_TOTAL" \
   --argjson passed "$CONTROLS_PASSED" \
   --argjson failed "$CONTROLS_FAILED" \
   --argjson pct "$COMPLIANCE_PCT" \
   '.summary.total = $total |
    .summary.passed = $passed |
    .summary.failed = $failed |
    .summary.compliance_percentage = $pct' \
   "$REPORT_FILE" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "$REPORT_FILE"

# Print summary
echo ""
echo "=== Summary ==="
echo "Total Controls: $CONTROLS_TOTAL"
echo -e "Passed: ${GREEN}$CONTROLS_PASSED${NC}"
echo -e "Failed: ${RED}$CONTROLS_FAILED${NC}"
echo "Compliance: ${COMPLIANCE_PCT}%"
echo ""
echo "Report saved to: $REPORT_FILE"

# Create latest symlink
ln -sf "$(basename "$REPORT_FILE")" "${OUTPUT_DIR}/latest.json"

# Exit with error if any controls failed
if [ "$CONTROLS_FAILED" -gt 0 ]; then
    echo -e "${RED}WARNING: Control drift detected!${NC}"
    exit 1
else
    echo -e "${GREEN}All controls compliant.${NC}"
    exit 0
fi
