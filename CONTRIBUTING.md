# Contributing to Seven Fortunas

Thank you for your interest in contributing! This document provides guidelines
for contributing to this project.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a new branch for your feature/fix
4. Make your changes
5. Test your changes thoroughly
6. Commit with clear, descriptive messages
7. Push to your fork
8. Open a Pull Request

## Commit Message Format

Use conventional commits:

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: feat, fix, docs, style, refactor, test, chore

Example:
```
feat(dashboard): Add AI updates feed

- Implement RSS feed fetching
- Add caching layer
- Create responsive UI components

Closes #123
```

## Code Review Process

1. All submissions require review
2. Maintainers will provide feedback within 48 hours
3. Address feedback and update PR
4. Once approved, maintainers will merge

## Testing

- Write tests for new features
- Ensure all tests pass before submitting PR
- Add integration tests where applicable

## Documentation

- Update README.md for new features
- Add inline comments for complex logic
- Update API documentation if applicable

## Questions?

Open an issue for questions or discussion.

Thank you for contributing!

## Workflow Sentinel (FR-9.1)

The Workflow Sentinel monitors all GitHub Actions workflows for failures.

### Monitored Workflows

The sentinel workflow (`.github/workflows/workflow-sentinel.yml`) triggers on `workflow_run` completion events for the following workflows:

- AI Weekly Summary
- Auto-Merge Dependabot
- Collect Metrics
- Collect SOC2 Evidence
- Compliance Evidence Collection
- Dashboard Auto-Update (Optimized)
- Dashboard Data Snapshot
- Dependabot Auto-Merge (SLA Compliance)
- Deploy AI Dashboard
- Deploy Website
- Monitor API Rate Limits
- Monitor Dashboard Performance
- Monitor Dependency Resilience
- Monthly Access Control Audit
- Monthly Vulnerability SLA Audit
- Pre-Commit Validation
- Project Dashboard Update
- Quarterly Secret Detection Validation
- Rate Limit Monitoring
- Secret Scanning
- Track Workflow Reliability
- Update AI Dashboard
- Validate Secrets Detection
- Weekly AI Summary

### Adding a New Workflow

When adding a new workflow to `.github/workflows/`, follow these steps to ensure it's monitored by the sentinel:

1. **Create your workflow file** in `.github/workflows/your-workflow.yml`
2. **Add the workflow name** to the sentinel trigger list:
   - Edit `.github/workflows/workflow-sentinel.yml`
   - Add your workflow name (from the `name:` field) to the `workflows:` list
   - Use the exact name as it appears in your workflow file
3. **Test the integration:**
   - Trigger your workflow manually
   - Intentionally cause a failure (if safe to do so)
   - Verify the sentinel detects it and records failure metadata
4. **Update this documentation:** Add your workflow name to the list above

### Failure Detection

- **Detection Latency SLA:** <5 minutes from job completion
- **Failure Metadata:** Recorded in `compliance/workflow-failures/failures.jsonl`
- **Job Logs:** Saved to `compliance/workflow-failures/logs/`
- **Integration:** Feeds into FR-9.2 (AI Log Analysis)

### Sentinel Behavior

- Triggers only on `conclusion: failure`
- Concurrency: 1 run per triggering workflow (prevents race conditions)
- Records: workflow name, run ID, conclusion, failed job names, timestamp, run URL
- Fetches job logs via GitHub API for failed jobs
