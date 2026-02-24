# run-autonomous-implementation Workflow

**Version:** 1.0.0
**Created:** 2026-02-17
**Status:** Foundation Complete

## Structure

```
run-autonomous-implementation/
├── workflow.md              # Entry point (mode routing)
├── data/                    # Reference data (6 files)
├── templates/               # Output templates (5 files)
├── steps-c/                 # CREATE mode (14 files)
├── steps-e/                 # EDIT mode (4 files)
└── steps-v/                 # VALIDATE mode (4 files)
```

## Total Files
- 1 workflow.md
- 6 data files
- 5 templates
- 23 step files
- **Total:** 35 files

## Next Steps
Build individual step files starting with CREATE mode steps.

## Invocation
```bash
/bmad-bmm-run-autonomous-implementation
```

## Modes
- CREATE: Autonomous implementation (Initializer + Coding Agent)
- EDIT: Modify feature statuses, circuit breaker settings
- VALIDATE: Verify implementation state, generate report
