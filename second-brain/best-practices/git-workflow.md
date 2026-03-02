---
title: Git Workflow and Branching Strategy
description: Version control standards and collaboration practices
---

# Git Workflow and Branching Strategy

## Branching Strategy

### Branch Types

#### Main Branches
- **main**: Production-ready code. Always deployable.
  - Requires all tests passing
  - Requires code review approval
  - Protected branch (no force push)
  - Tagged for each release

- **develop**: Integration branch. Base for feature branches.
  - Reflects current development progress
  - Should be relatively stable
  - Can be deployed to staging
  - Protected branch (no direct commits)

#### Supporting Branches

**Feature Branches** (`feature/TICKET-ID-description`)
- Created from: `develop`
- Merged back into: `develop`
- Deletion: Delete after merge
- Lifetime: Days to weeks
- Example: `feature/FEAT-101-user-authentication`

**Release Branches** (`release/v1.2.3`)
- Created from: `develop`
- Merged back into: `main` and `develop`
- Deletion: Keep for bugfix tracking
- Lifetime: Release cycle duration
- Example: `release/v2.0.0`

**Hotfix Branches** (`hotfix/TICKET-ID-description`)
- Created from: `main`
- Merged back into: `main` and `develop`
- Deletion: Delete after merge
- Lifetime: Days
- Example: `hotfix/SEC-999-sql-injection`

**Experiment Branches** (`experiment/description`)
- Created from: `develop` or `feature/*`
- Merged back into: Feature branch (if successful)
- Deletion: Delete if abandoned
- Lifetime: Hours to days
- Example: `experiment/vue-to-react-migration`

## Commit Conventions

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation change
- **style**: Formatting (no code logic change)
- **refactor**: Code reorganization
- **perf**: Performance improvement
- **test**: Test additions or changes
- **ci**: CI/CD configuration
- **chore**: Dependency, tooling, config

### Scope (Optional)
- Component or area of code
- Examples: `auth`, `api`, `frontend`, `database`

### Subject
- Imperative mood: "add" not "added"
- No period at end
- Lowercase
- Max 50 characters

### Body (Optional)
- Explain what and why, not how
- Wrap at 72 characters
- Separate from subject with blank line
- Bullet points are okay

### Footer (Optional)
- Reference issues: `Closes #123`
- Breaking changes: `BREAKING CHANGE: description`
- Co-authors: `Co-Authored-By: Name <email>`

### Examples

**Good:**
```
feat(auth): add multi-factor authentication

Implement TOTP-based MFA for enhanced security.
- Add QR code generation for TOTP setup
- Add verification during login
- Add recovery code generation

Closes #456
```

**Bad:**
```
Updated stuff
ADDED NEW AUTHENTICATION FEATURES AND FIXED BUGS AND IMPROVED PERFORMANCE
feat: multiple changes across different areas
```

## Pull Request Process

### Opening a PR
1. Create branch from `develop` (for feature) or `main` (for hotfix)
2. Push branch to remote
3. Open PR with descriptive title and description
4. Reference related issues
5. Add labels (feature, bug, enhancement, etc.)

### PR Description Template
```markdown
## Description
Brief description of changes

## Changes
- Change 1
- Change 2
- Change 3

## Related Issues
Closes #123

## Testing
How to test these changes:
1. Step 1
2. Step 2

## Breaking Changes
(if any)

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No console errors/warnings
- [ ] No performance degradation
```

### Code Review
1. Assign reviewers (min 1, ideally 2)
2. Reviewers assess:
   - Correctness and logic
   - Test coverage
   - Performance implications
   - Security concerns
   - Code style adherence
   - Documentation completeness

3. Review types:
   - **Approve**: Good to merge
   - **Request Changes**: Must address before merge
   - **Comment**: Suggestions but not blocking

### Merging
1. Resolve all conversations
2. Rebase on latest `develop` (for feature)
3. Ensure all CI checks pass
4. Merge only when approved
5. Delete feature branch
6. Update issue status

## Conflict Resolution

### Prevention
- Keep branches short-lived (<3 days)
- Sync frequently with `develop`
- Communicate about overlapping changes

### Resolution
1. Fetch latest from remote: `git fetch origin`
2. Rebase on target: `git rebase origin/develop`
3. Fix conflicts in editor
4. Test thoroughly after resolving
5. Force push (if rebase): `git push -f origin feature/branch`

### Merge Strategies
- **Squash**: Combine commits into one (for small changes)
- **Rebase**: Rewrite history onto target (linear history)
- **Merge**: Create merge commit (preserves history)
- **Default**: Squash for features, merge for releases

## Release Management

### Version Numbering
- **Semantic Versioning**: MAJOR.MINOR.PATCH
  - MAJOR: Breaking changes
  - MINOR: New features (backward compatible)
  - PATCH: Bug fixes (backward compatible)
- Example: `v1.2.3` (major: 1, minor: 2, patch: 3)

### Release Process
1. Create `release/vX.Y.Z` from `develop`
2. Update version numbers and CHANGELOG
3. Run full test suite
4. Create release PR for review
5. Fix any critical bugs on release branch
6. Merge to `main` and tag: `v1.2.3`
7. Merge back to `develop`
8. Create release notes on GitHub
9. Deploy to production

### CHANGELOG Format
```markdown
## [1.2.3] - 2024-03-01

### Added
- New user authentication feature
- Dashboard customization

### Fixed
- SQL injection vulnerability
- Memory leak in background service

### Changed
- API response format (breaking)
- Performance optimization

### Security
- Updated cryptography library
```

## Tagging

### Tag Naming
- Release tags: `v1.2.3` (semantic version)
- Milestone tags: `milestone-1.2` (for tracking)
- Annotated tags for releases: `git tag -a v1.2.3 -m "Release 1.2.3"`
- Lightweight tags for references: `git tag checkpoint-feature-101`

### Tag Protection
- Protect release tags on GitHub
- Require review for release tags
- Automate release process from tags

## Best Practices

### Daily Workflow
```bash
# Start feature
git checkout develop
git pull origin develop
git checkout -b feature/TICKET-description

# During development
git add <files>
git commit -m "feat(scope): description"
git push origin feature/TICKET-description

# Before PR
git fetch origin
git rebase origin/develop
git push -f origin feature/TICKET-description
```

### Code Review Standards
- Review within 24 hours
- Provide constructive feedback
- Praise good practices
- Question assumptions respectfully
- Test locally before approval

### Commit Frequency
- Commit logically coherent changes
- Avoid massive commits (>400 lines)
- Avoid trivial single-line commits
- Atomic commits (single feature per commit when possible)

### History Maintenance
- Keep history clean and readable
- Use rebase for interactive history editing
- Squash work-in-progress commits
- Avoid merge commits in feature branches

## Troubleshooting

### Undo Last Commit (not pushed)
```bash
git reset --soft HEAD~1
```

### Undo Published Commit
```bash
git revert COMMIT_HASH
```

### Fix Commit Message
```bash
git commit --amend --no-edit
```

### Restore Deleted Branch
```bash
git reflog
git checkout -b restored-branch COMMIT_HASH
```

### Clean Up Local Branches
```bash
git branch -d feature/old-branch  # Safe delete
git branch -D feature/force-delete  # Force delete
```
