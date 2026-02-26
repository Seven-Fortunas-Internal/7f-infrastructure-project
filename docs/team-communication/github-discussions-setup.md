# GitHub Discussions Setup Guide

## Overview

GitHub Discussions provides asynchronous team communication integrated with the GitHub workflow.

**Why GitHub Discussions?**
- ✅ Native GitHub integration
- ✅ Searchable and linkable
- ✅ Free (included with GitHub)
- ✅ No additional infrastructure
- ✅ Good for async communication

## MVP Setup (Phase 0)

### 1. Enable GitHub Discussions

**For each repository:**

```bash
# Using GitHub CLI
gh repo edit Seven-Fortunas/7f-infrastructure-project --enable-discussions

# Or via web UI:
# 1. Go to repository Settings
# 2. Scroll to "Features"
# 3. Check "Discussions"
# 4. Click "Save"
```

### 2. Create Discussion Categories

**Recommended categories:**

1. **📢 Announcements** - Team updates, releases, important news
2. **💡 Ideas** - Feature requests, brainstorming
3. **🙋 Q&A** - Questions and answers
4. **🐛 Bug Reports** - Bug discussions (before creating issues)
5. **📚 Documentation** - Docs feedback, suggestions
6. **🎯 Sprint Planning** - Sprint goals, retrospectives
7. **🔒 Security** - Security-related discussions (private category)

**Create categories:**

```bash
# Via web UI (easier):
# 1. Go to repository > Discussions
# 2. Click "New discussion"
# 3. Click "Manage categories"
# 4. Add categories above

# Categories can have:
# - Emoji icon
# - Description
# - Format (open-ended or Q&A)
```

### 3. Create Welcome Discussion

**Title:** Welcome to Seven Fortunas Team Discussions! 👋

**Content:**
```markdown
# Welcome! 🎉

This is our async communication hub for the Seven Fortunas infrastructure project.

## How to use Discussions

- **Announcements:** Project updates, releases
- **Ideas:** Feature brainstorming, suggestions
- **Q&A:** Ask questions, share knowledge
- **Bug Reports:** Discuss bugs before creating issues
- **Sprint Planning:** Sprint goals and retrospectives

## Best Practices

1. **Search first** - Check if your question was already answered
2. **Use categories** - Pick the right category for your discussion
3. **Be specific** - Include context, code snippets, screenshots
4. **Mark answers** - Help others by marking helpful answers
5. **Stay on topic** - Keep discussions focused

## Integration with Workflow

- Link to discussions from PRs, issues, commits
- Reference discussions with syntax: `Discussed in #123`
- Use @mentions to notify team members

## Need Help?

- Tag @jorge for AI/security questions
- Tag @henry for business/product questions
- Check pinned discussions for FAQs

Happy discussing! 🚀
```

### 4. Pin Important Discussions

**Pin:**
- Welcome message
- Team guidelines
- Sprint planning template
- FAQ

**How to pin:**
1. Open discussion
2. Click "..." menu
3. Select "Pin discussion"
4. Choose pin position (top, middle, bottom)

### 5. Configure Notifications

**For founders:**

1. Go to repository > Watch
2. Select "Custom"
3. Enable:
   - ✅ Discussions
   - ✅ Issues
   - ✅ Pull requests
   - ✅ Releases
4. Choose notification delivery (email, web, mobile)

**Notification preferences:**
```bash
# Email notifications
gh repo set-default Seven-Fortunas/7f-infrastructure-project
gh config set notifications.discussions true

# Or via web UI:
# Settings > Notifications > Watching
```

## Usage Examples

### Start a Discussion

```markdown
# Title: Should we use TypeScript for the dashboard?

**Context:**
We're building the 7F Lens dashboards and deciding on the tech stack.

**Options:**
1. TypeScript - Type safety, better IDE support
2. JavaScript - Faster prototyping, less setup

**Questions:**
- Performance implications?
- Team learning curve?
- Maintenance overhead?

What do you think? @jorge @henry
```

### Link from PR

```markdown
# PR Description

Implements dashboard refactoring discussed in #42

**Changes:**
- Migrated to TypeScript
- Added type definitions
- Improved error handling

See discussion: https://github.com/Seven-Fortunas/7f-infrastructure-project/discussions/42
```

### Reference in Commit

```bash
git commit -m "refactor: migrate dashboard to TypeScript

Discussed in #42

- Add TypeScript config
- Convert components to .tsx
- Add type definitions"
```

## Best Practices

### DO ✅
- Search before posting
- Use descriptive titles
- Include context and examples
- Mark helpful answers
- Tag relevant people
- Link to related issues/PRs

### DON'T ❌
- Post duplicate questions
- Use for urgent issues (use Slack/Matrix)
- Share sensitive data (use private channels)
- Post multiple topics in one discussion
- Forget to update when resolved

## Moderation

**Moderators:**
- Jorge (VP AI-SecOps)
- Henry (CEO)

**Moderation actions:**
- Lock discussions (when resolved)
- Pin important discussions
- Edit/delete spam
- Move discussions to correct category
- Mark as answered (Q&A format)

## Search and Discovery

**Search discussions:**
```
# In GitHub search bar
is:discussion org:Seven-Fortunas

# Filter by category
is:discussion category:Ideas

# Filter by answered
is:discussion is:answered
```

**Link to discussions:**
```markdown
<!-- Reference by number -->
See discussion #42

<!-- Full URL -->
[TypeScript Migration](https://github.com/Seven-Fortunas/7f-infrastructure-project/discussions/42)
```

## Integration with Second Brain

**Mirror important discussions:**

1. Export discussion to markdown
2. Save in Second Brain:
   ```
   outputs/second-brain/decisions/YYYY-MM-DD-decision-title.md
   ```
3. Link back to original discussion

**Example:**
```markdown
# Decision: Use TypeScript for Dashboards

**Date:** 2026-02-25
**Participants:** Jorge, Henry
**GitHub Discussion:** #42

## Context
[Content from discussion]

## Decision
We will use TypeScript for all dashboard projects.

## Rationale
[Reasons from discussion]
```

## Metrics

**Track engagement:**

```bash
# Via GitHub API
gh api /repos/Seven-Fortunas/7f-infrastructure-project/discussions \
  --jq '.[] | {title, comments, created_at}'

# Discussion count
gh api /repos/Seven-Fortunas/7f-infrastructure-project/discussions \
  | jq 'length'
```

**Useful metrics:**
- Total discussions
- Discussions per category
- Average response time
- Most active participants
- Answered rate (for Q&A)

## Phase 2: Matrix Integration

**(Not yet implemented - see matrix-setup.md for future deployment)**

In Phase 2, discussions will be bridged to Matrix channels for real-time chat alongside async discussions.

## References

- [GitHub Discussions Documentation](https://docs.github.com/en/discussions)
- [Matrix Setup Guide (Phase 2)](./matrix-setup.md)
- [Team Communication Policy](../../outputs/second-brain/brand-culture/team/communication-policy.md)

---

**Status:** Implemented (MVP)
**Phase:** Phase 0 (MVP)
**Owner:** Jorge (VP AI-SecOps)
**Last Updated:** 2026-02-25
