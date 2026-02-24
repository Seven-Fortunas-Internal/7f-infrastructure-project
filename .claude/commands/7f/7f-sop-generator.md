# 7f-sop-generator

**Seven Fortunas Custom Skill** - Generate Standard Operating Procedures (SOPs)

---

## Metadata

```yaml
source_bmad_skill: bmad-bmm-document-project
adapted_by: Seven Fortunas Infrastructure Team
version: 1.0.0
created: 2026-02-17
integration: Second Brain (Processes/)
```

---

## Purpose

Generate comprehensive, structured Standard Operating Procedures (SOPs) following Seven Fortunas documentation standards and compliance requirements.

---

## Usage

```bash
/7f-sop-generator <process-name> [--template <template-type>] [--compliance <framework>]
```

**Arguments:**
- `<process-name>`: Name of the process/procedure
- `--template`: SOP template type (default: standard)
- `--compliance`: Compliance framework (ISO27001, SOC2, NIST, GDPR)

**Template Types:**
- `standard`: General business process
- `technical`: Technical/IT procedures
- `security`: Security operations
- `incident-response`: Incident handling
- `change-management`: Change control

---

## Workflow

### 1. Initialize SOP Structure

Prompt for key information:
- Process owner
- Review frequency
- Approval authority
- Target audience
- Risk level

### 2. Generate SOP Document

Create structured markdown with:

```markdown
---
title: [Process Name] - Standard Operating Procedure
document_id: SOP-[YYYY]-[NNN]
version: 1.0.0
owner: [Process Owner]
approved_by: [Approver]
approval_date: [Date]
review_frequency: [Monthly/Quarterly/Annual]
next_review: [Date]
compliance_frameworks: [ISO27001, SOC2, etc.]
risk_level: [Low/Medium/High/Critical]
---

# [Process Name] - SOP

## 1. Purpose
[Why this procedure exists]

## 2. Scope
[What is covered, what is not]

## 3. Definitions
[Key terms and acronyms]

## 4. Roles & Responsibilities
- **Process Owner:** [Name/Role]
- **Executor:** [Who performs the tasks]
- **Approver:** [Who approves changes]
- **Stakeholders:** [Who needs to be informed]

## 5. Prerequisites
- Required access/permissions
- Required tools/systems
- Required training/certifications
- Required documentation

## 6. Procedure Steps

### Step 1: [Action]
**Who:** [Role]
**When:** [Trigger/Schedule]
**How:**
1. [Detailed instruction]
2. [Detailed instruction]
3. [Detailed instruction]

**Expected Outcome:** [What success looks like]
**Validation:** [How to verify completion]

### Step 2: [Action]
[Repeat structure]

## 7. Decision Points
[Flowchart or decision tree for conditional logic]

## 8. Error Handling
**Common Issues:**
1. [Issue]: [Resolution steps]
2. [Issue]: [Resolution steps]

**Escalation Path:**
- Level 1: [First responder]
- Level 2: [Manager/SME]
- Level 3: [Executive/Emergency]

## 9. Compliance Requirements
[Specific compliance controls addressed by this SOP]

## 10. Success Metrics
- [KPI 1]: [Target]
- [KPI 2]: [Target]
- [KPI 3]: [Target]

## 11. Related Documents
- [Link to related SOPs]
- [Link to policies]
- [Link to runbooks]

## 12. Revision History
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0   | [Date] | [Author] | Initial version |

## 13. Approval Signatures
- **Prepared by:** [Name], [Date]
- **Reviewed by:** [Name], [Date]
- **Approved by:** [Name], [Date]
```

### 3. Compliance Mapping

If `--compliance` flag used, add section:

```markdown
## Compliance Control Mapping

### ISO 27001 Controls
- A.12.1.1 Documented operating procedures
- A.12.1.2 Change management

### SOC2 Controls
- CC7.1 System operations
- CC7.2 Change management
```

### 4. Save to Second Brain

Save output to:
```
~/seven-fortunas-workspace/seven-fortunas-brain/Processes/SOPs/[process-name]-sop.md
```

### 5. Generate Supporting Artifacts

Optional outputs:
- Quick reference card (1-page PDF)
- Training checklist
- Audit evidence log

### 6. Verification

- Validate YAML frontmatter
- Check all sections present
- Ensure document ID unique
- Verify compliance mappings (if applicable)

---

## Error Handling

**Input Errors:**
- Missing required fields: Prompt for input
- Invalid compliance framework: Show available options
- Duplicate document ID: Auto-increment

**Processing Errors:**
- Template not found: Fallback to standard template
- Invalid markdown structure: Fix automatically

**Output Errors:**
- Directory doesn't exist: Create automatically
- File already exists: Append version number
- Write permissions denied: Display error with path

---

## Integration Points

- **Second Brain:** Saves to Processes/SOPs/
- **BMAD Library:** Follows documentation patterns
- **Compliance Frameworks:** Maps to control requirements

---

## Example Usage

```bash
# Standard business process
/7f-sop-generator "Employee Onboarding"

# Technical procedure with template
/7f-sop-generator "Database Backup" --template technical

# Security procedure with compliance
/7f-sop-generator "Incident Response" --template incident-response --compliance ISO27001,SOC2

# Change management
/7f-sop-generator "Production Deployment" --template change-management --compliance NIST
```

---

## Dependencies

- BMAD Library (FR-3.1) ✅
- Second Brain Structure (FR-2.1) ✅
- Compliance framework templates (optional)

---

## Notes

This skill automates SOP creation following industry best practices and compliance requirements. SOPs are living documents that require regular review and updates. The generated structure ensures consistency across all Seven Fortunas operational procedures.

**Compliance Note:** While this skill generates compliant document structures, final compliance validation should be performed by qualified compliance professionals.
