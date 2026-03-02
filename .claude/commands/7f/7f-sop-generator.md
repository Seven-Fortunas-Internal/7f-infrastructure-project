---
description: "Generate Standard Operating Procedures (SOPs) for Seven Fortunas processes"
tags: ["sop", "procedures", "documentation", "compliance"]
source: "Adapted from BMAD workflows"
---

# SOP Generator Skill

Generate comprehensive Standard Operating Procedures (SOPs) for:
- **DevOps Processes:** Deployment procedures, incident response
- **Security Protocols:** Access control, secret management
- **Compliance:** SOC 2 procedures, audit processes
- **Team Workflows:** Code review, sprint ceremonies

## Usage

**Generate SOP:**
```bash
# Interactive mode
/7f-sop-generator

# Specific procedure
/7f-sop-generator --procedure="Incident Response" --category="security"

# From template
/7f-sop-generator --template="deployment"
```

## Features

- ✅ **Structured Format:** Follows industry-standard SOP structure
- ✅ **Version Control:** Tracks SOP revisions and approvals
- ✅ **Role-Based:** Specifies responsibilities by role (Jorge, Buck, Henry, etc.)
- ✅ **Compliance Ready:** SOC 2, ISO 27001 compatible format

## SOP Structure

```markdown
# SOP: {Title}

**Version:** 1.0
**Effective Date:** YYYY-MM-DD
**Owner:** {Role}
**Approval:** {Approver}

## Purpose
{Why this SOP exists}

## Scope
{What is covered}

## Roles & Responsibilities
{Who does what}

## Procedure
{Step-by-step instructions}

## Verification
{How to verify completion}

## Revision History
{Version tracking}
```

## Output

```
compliance/sops/
└── {procedure-name}-sop-v{version}.md
```

## Integration

- **Compliance:** Feeds into SOC 2 evidence collection (FR-5.4)
- **Training:** Used for team onboarding and process documentation
- **Based on:** BMAD bmm/workflows/create-sop

---

**Status:** MVP (Placeholder - Full implementation pending)
**Source:** Adapted from BMAD bmm/workflows/create-sop
