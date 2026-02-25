#!/bin/bash
# Generate SOC 2 control drift alert body for GitHub issue
# Usage: COMPLIANCE_PCT=95 FAILED_CONTROLS="..." ./generate-soc2-alert-body.sh > /tmp/issue-body.md

TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M:%S')

cat << EOF
## SOC 2 Control Drift Alert

**Timestamp:** ${TIMESTAMP} UTC
**Organization:** Seven-Fortunas-Internal
**Compliance:** ${COMPLIANCE_PCT:-unknown}%

### Failed Controls

${FAILED_CONTROLS:-None}

### Action Required

Review the control posture report and remediate failed controls:

\`\`\`bash
cat compliance/soc2/reports/latest.json | jq '.controls[] | select(.status == "fail")'
\`\`\`

Full report: [latest.json](../blob/main/compliance/soc2/reports/latest.json)

---
*Generated automatically by the SOC 2 Control Monitoring workflow.*
*Alert triggered within 15 minutes of control drift (NFR-1.5 compliance).*
EOF
