---
name: bmad-bmm-run-autonomous-implementation
description: Run autonomous implementation workflow (CREATE/EDIT/VALIDATE modes)
category: bmm-implementation
tags: [autonomous, implementation, workflow, bmad]
---

# Run Autonomous Implementation

**Workflow:** Autonomous feature implementation with circuit breaker protection

**Modes:**
- `--mode=create` (default): Initialize and run autonomous implementation
- `--mode=edit`: Edit tracking state (features, circuit breaker)
- `--mode=validate`: Validate tracking state integrity

**Usage:**
```bash
/bmad-bmm-run-autonomous-implementation [--mode=create|edit|validate]
```

---

**CRITICAL: Load the workflow from the project root and follow its instructions exactly!**

@{project-root}/_bmad-output/bmb-creations/workflows/run-autonomous-implementation/workflow.md
