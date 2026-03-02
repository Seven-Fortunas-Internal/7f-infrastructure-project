---
title: Incident Escalation and On-Call
description: Escalation procedures, on-call rotation, and incident management
---

# Incident Escalation and On-Call

## On-Call Rotation

### Current On-Call
- **Primary On-Call**: [Name/Team] - Contact: [phone/slack]
- **Secondary On-Call**: [Name/Team] - Contact: [phone/slack]
- **Manager On-Call**: [Name] - Contact: [phone/slack]

### On-Call Responsibilities
- **Response Time**: Answer within 15 minutes for pages
- **Investigation**: Triage and investigate incidents
- **Communication**: Keep team informed of status
- **Escalation**: Escalate when necessary
- **Post-Incident**: Participate in post-mortem

### On-Call Schedule
- **Duration**: 1 week per rotation
- **Schedule**: Posted in #oncall Slack channel
- **Updates**: Notify #oncall of changes
- **Handoff**: 10am Monday transition
- **Coverage**: Ensure no gaps between rotations

## Incident Severity Levels

### Level 1 (Critical) 🔴
**Impact**: All or most users affected; service down
- **Response Time**: Immediate (< 5 min)
- **SLA**: Restore within 1 hour
- **Escalation**: Automatic to on-call manager
- **Communication**: Notify executive team
- **Example**: Production database down, API returns 500s

### Level 2 (High) 🟠
**Impact**: Significant functionality degraded; some users affected
- **Response Time**: 30 minutes
- **SLA**: Begin mitigation within 1 hour
- **Escalation**: Escalate if not resolved in 30 min
- **Communication**: Notify relevant stakeholders
- **Example**: Payment processing slower, 10% error rate

### Level 3 (Medium) 🟡
**Impact**: Moderate degradation; workaround available
- **Response Time**: 2 hours
- **SLA**: Begin mitigation within 4 hours
- **Escalation**: Escalate if affecting business
- **Communication**: Update relevant teams
- **Example**: Dashboard performance slow, feature partially broken

### Level 4 (Low) 🟢
**Impact**: Minor functionality issues; no user impact
- **Response Time**: Next business day
- **SLA**: Address within 1 week
- **Escalation**: Schedule for triage
- **Communication**: Log for tracking
- **Example**: Minor UI bug, low-priority feature not working

## Escalation Flowchart

```
┌─────────────────────┐
│  Incident Detected  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────────┐
│  Classify Severity      │
│  Level 1-4              │
└──────────┬──────────────┘
           │
      ┌────┴────────────────────┐
      │                         │
      ▼                         ▼
 LEVEL 1-2                LEVEL 3-4
      │                         │
      ▼                         ▼
 Escalate to          Log in system
 On-Call Manager          │
      │                   ▼
      │             Scheduled for
      │             regular triage
      ▼
 Page on-call engineer
 │
 ▼
 (Not responsive in 15 min?)
 │
 ▼
 Page secondary on-call
 │
 ▼
 (Still not responsive in 15 min?)
 │
 ▼
 Page manager on-call
```

## Escalation Contacts

### On-Call Team
| Role | Primary | Secondary | Manager |
|------|---------|-----------|---------|
| Infrastructure | [Name] | [Name] | [Manager] |
| Application | [Name] | [Name] | [Manager] |
| Database | [Name] | [Name] | [Manager] |
| Security | [Name] | [Name] | [Manager] |

### Executive Escalation
- **VP Engineering**: [Name] - [Phone]
- **CTO**: [Name] - [Phone]
- **CEO**: [Name] - [Phone]

### Paging
- **PagerDuty**: [URL]
- **Slack**: `/incident` command
- **Phone Tree**: [Details]

## Incident Response Procedures

### Initial Response (First 5 minutes)
1. Acknowledge the incident
2. Determine severity level
3. Create incident ticket
4. Assemble response team
5. Begin investigation
6. Notify affected customers (if applicable)

### Ongoing Response
- **Status Updates**: Every 15 minutes
- **Communication**: Status page updates
- **Escalation**: Follow escalation procedures
- **Documentation**: Log all actions
- **Mitigation**: Implement fixes or workarounds

### Resolution
- Implement fix or rollback
- Verify service restored
- Monitor for recurrence
- Communicate resolution
- Schedule post-incident review

### Post-Incident (Within 24 hours)
- Write incident summary
- Schedule post-mortem
- Document root cause
- Identify action items
- Assign follow-ups

## Communication Templates

### Initial Alert
```
🚨 [SEVERITY] Incident: [Service Name]

Status: Investigating
Affected: [Service/Users]
Impact: [User-facing impact]
ETA: [Investigation in progress]

Updates: [Status page URL]
```

### Status Update
```
🔄 Update: [Service Name]

Current Status: [Status]
What We're Doing: [Actions taken]
ETA for Resolution: [Time estimate]
Next Update: [In X minutes]
```

### Resolution Notification
```
✅ Resolved: [Service Name]

The incident has been resolved.
Affected Services: [List]
Duration: [Time]
Root Cause: [Brief description]
Post-Mortem: [Scheduled for Date/Time]
```

## SLA Targets

| Severity | Response | Resolution |
|----------|----------|------------|
| Level 1  | < 5 min  | < 1 hour   |
| Level 2  | < 30 min | < 4 hours  |
| Level 3  | < 2 hours| < 1 day    |
| Level 4  | < 1 day  | < 1 week   |

## Status Page

- **URL**: [status.example.com]
- **Updates**: Automated from incident system
- **Manual Updates**: #statuspage Slack channel
- **Subscribers**: [Number] email subscribers

## War Room Procedures

### Setting Up War Room
1. Create incident-focused Slack channel
2. Invite response team
3. Pin incident summary
4. Post status update template
5. Start video call (if Level 1)

### During War Room
- **Facilitator**: On-call manager
- **Frequency**: 15-minute syncs
- **Participants**: Engineering, product, support
- **Notes**: Taken by designated person
- **Decisions**: Recorded and communicated

### War Room Artifacts
- Incident timeline
- Actions taken and by whom
- System changes made
- Decisions and rationale
- Contact information used

## Post-Incident Reviews

### Timing
- **Level 1**: Within 24 hours
- **Level 2**: Within 48 hours
- **Level 3**: Within 1 week
- **Level 4**: Optional, if improvement identified

### Attendees
- Incident responders
- Service owners
- Leadership observer
- Facilitator

### Format
1. **Timeline**: What happened when
2. **Impact**: Business and customer impact
3. **Root Cause**: Why did it happen
4. **Contributing Factors**: What made it worse
5. **Action Items**: Preventive measures
6. **Close Out**: Review and assign ownership

### Follow-Up
- Action items tracked in JIRA
- Weekly review of status
- Progress on severity levels
- Trend analysis for patterns
