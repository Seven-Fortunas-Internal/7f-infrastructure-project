# Seven Fortunas Sprint Management - Business Terminology Guide

## Overview

The Seven Fortunas Sprint Management System supports dual terminology to accommodate both technical engineering projects and business operational projects.

## Terminology Mapping

### Technical Projects (Engineering)

**Hierarchy:**
```
Product Requirements Document (PRD)
    ↓
Epics (Major features or capabilities)
    ↓
User Stories (Specific user-facing functionality)
    ↓
Sprints (Time-boxed development iterations)
```

**Example:**
- **PRD:** "Seven Fortunas Infrastructure Platform"
- **Epic 1:** "GitHub Organization Setup and Security"
- **Story 1.1:** "Configure GitHub CLI Authentication"
- **Story 1.2:** "Create GitHub Organizations"
- **Sprint 1:** Stories 1.1-1.5 (2 weeks)

### Business Projects (Operations)

**Hierarchy:**
```
Initiative (Strategic business objective)
    ↓
Objectives (Key results or deliverables)
    ↓
Tasks (Specific actions to complete)
    ↓
Sprints (Time-boxed work iterations)
```

**Example:**
- **Initiative:** "SOC 2 Compliance Preparation"
- **Objective 1:** "Access Control Documentation"
- **Task 1.1:** "Document user provisioning process"
- **Task 1.2:** "Create access review checklist"
- **Sprint 1:** Tasks 1.1-1.5 (2 weeks)

## Implementation in BMAD Workflows

### Underlying Structure

Both terminologies use the **same BMAD workflow structure**:

```yaml
# Technical terminology
development_status:
  epic-1: in-progress
  1-1-configure-authentication: done
  1-2-create-organizations: in-progress
```

```yaml
# Business terminology (same structure, different labels)
development_status:
  objective-1: in-progress
  1-1-document-provisioning: done
  1-2-create-checklist: in-progress
```

### File Naming Conventions

**Technical Projects:**
- Epic file: `epics.md` or `epic-1.md`
- Story files: `stories/1-1-configure-authentication.md`
- Status file: `sprint-status.yaml`

**Business Projects:**
- Objective file: `objectives.md` or `objective-1.md`
- Task files: `tasks/1-1-document-provisioning.md`
- Status file: `sprint-status.yaml` (same)

### BMAD Workflow Invocation

**Technical Projects:**
```
/bmad-bmm-create-epic
/bmad-bmm-create-story
/bmad-bmm-sprint-planning
/bmad-bmm-sprint-status
```

**Business Projects:**
Use the **same workflows** but interpret terminology differently:
```
/bmad-bmm-create-epic    → Creates an Objective
/bmad-bmm-create-story   → Creates a Task
/bmad-bmm-sprint-planning → Generates sprint status for Objectives/Tasks
/bmad-bmm-sprint-status   → Updates Task status
```

## Configuration

### Project Type Declaration

Declare project type in `_bmad/bmm/config.yaml`:

```yaml
# Technical project
project_type: technical
terminology:
  level_1: epic
  level_2: story
  level_3: sprint
```

```yaml
# Business project
project_type: business
terminology:
  level_1: objective
  level_2: task
  level_3: sprint
```

### Dashboard Labels

Dashboards automatically adapt labels based on project type:

**Technical Dashboard:**
- "Epic Progress"
- "Stories Completed"
- "Sprint Velocity (Stories/Sprint)"

**Business Dashboard:**
- "Objective Progress"
- "Tasks Completed"
- "Sprint Velocity (Tasks/Sprint)"

## Usage Examples

### Scenario 1: Engineering Project (Infrastructure Build)

**Context:** Building the Seven Fortunas infrastructure

**Workflow:**
1. Create PRD with BMAD: `/bmad-bmm-create-prd`
2. Generate epics from PRD
3. Create story files: `/bmad-bmm-create-story`
4. Generate sprint status: `/bmad-bmm-sprint-planning`
5. Track progress: `/bmad-bmm-sprint-status`

**Language:**
- "Let's plan Epic 2 for the next sprint"
- "Story 3.4 is blocked on Story 3.2"
- "Sprint velocity is 8 stories per 2-week sprint"

### Scenario 2: Business Project (SOC 2 Compliance)

**Context:** Preparing for SOC 2 audit

**Workflow:**
1. Create Initiative document (manual or BMAD-adapted)
2. Define Objectives (use epic structure)
3. Create Task files: `/bmad-bmm-create-story` (interpreted as task)
4. Generate sprint status: `/bmad-bmm-sprint-planning`
5. Track progress: `/bmad-bmm-sprint-status`

**Language:**
- "Let's plan Objective 2 for the next sprint"
- "Task 3.4 is blocked on Task 3.2"
- "Sprint velocity is 12 tasks per 2-week sprint"

## Best Practices

### Choosing Terminology

**Use Technical Terminology when:**
- Building software features
- Developing APIs or services
- Creating user interfaces
- Writing code

**Use Business Terminology when:**
- Documenting processes
- Completing compliance tasks
- Creating operational procedures
- Non-coding business deliverables

### Consistency Within Projects

**Rule:** Choose one terminology set per project and stick with it.

**Why:** Mixing terminology creates confusion in team communication and sprint planning.

**Example (Bad):**
- "Epic 1 has 3 tasks" ← Mixed terminology
- "Let's create a story for this objective" ← Mixed terminology

**Example (Good):**
- "Epic 1 has 3 stories" ← Consistent technical
- "Objective 1 has 3 tasks" ← Consistent business

### Cross-Project Communication

When discussing multiple projects with different terminologies:

**Approach 1: Use generic terms**
- "Work items" instead of stories/tasks
- "Components" instead of epics/objectives
- "Iteration" instead of sprint

**Approach 2: Specify project type**
- "In the infrastructure project (technical), we completed 8 stories"
- "In the compliance project (business), we completed 12 tasks"

## Technical Implementation Notes

### BMAD Workflow Adaptation

The BMAD workflows are **terminology-agnostic** at the core. The user-facing documentation and prompts use technical terminology by default, but the underlying data structures work identically for both.

**Future Enhancement:** BMAD workflows will support a `terminology_mode` configuration parameter that automatically adjusts prompts and labels.

### GitHub Integration

GitHub Projects sync uses **labels** to distinguish:
- `Type: Story` for technical work items
- `Type: Task` for business work items
- `Type: Epic` and `Type: Objective` for higher-level groupings

### Metrics and Reporting

Velocity calculations are **identical** regardless of terminology:
- Stories per sprint = Tasks per sprint (both count completed work items)
- Burndown charts work the same way
- Completion rates use the same formula

The only difference is presentation labels in dashboards and reports.

## Migration Between Terminologies

### Converting Technical → Business

If you start with technical terminology and need to switch:

1. **Rename files:**
   ```bash
   mv epics.md objectives.md
   mv stories/ tasks/
   ```

2. **Update sprint-status.yaml:**
   ```bash
   # Change references (if desired for clarity)
   sed -i 's/epic-/objective-/g' sprint-status.yaml
   ```

3. **Update config:**
   ```yaml
   project_type: business
   ```

4. **Regenerate with new context:**
   ```
   /bmad-bmm-sprint-planning
   ```

### Converting Business → Technical

Reverse the process above.

**Note:** The underlying workflow logic doesn't require these changes. This is purely for human clarity and communication.

## FAQ

### Q: Can I use custom terminology?

**A:** Yes, but you'll need to manually adapt BMAD prompts. The system is designed for the two standard sets (technical and business), but the data structures are flexible enough to support custom terms.

### Q: What if my project is hybrid (some coding, some documentation)?

**A:** Choose the terminology that represents the **majority** of work items. Alternatively, you could split into two projects (one technical, one business) with cross-dependencies.

### Q: Do GitHub Projects support both terminologies?

**A:** Yes. Use labels to distinguish:
- Technical: `Type: Epic`, `Type: Story`
- Business: `Type: Objective`, `Type: Task`

The Kanban columns (Backlog, In Progress, Review, Done) are shared.

### Q: How does this affect sprint velocity?

**A:** Velocity is calculated the same way regardless of terminology. A "story" and a "task" are both counted as 1 work item for velocity purposes.

However, technical stories may be larger/more complex than business tasks on average, so cross-project velocity comparisons may not be meaningful.

---

**Version:** 1.0
**Last Updated:** 2026-02-23
**Owner:** Jorge (VP AI-SecOps)
