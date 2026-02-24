---
description: Manage Seven Fortunas team communication channels
---

# team-communication Skill

**Purpose:** Guide team communication setup and usage across GitHub Discussions and Matrix

## What This Skill Does

This skill provides guidance for:
- Using GitHub Discussions effectively (Phase 0)
- Planning Matrix server deployment (Phase 2)
- Configuring GitHub Bot integration (Phase 2)
- Best practices for async and real-time communication

## Phase 0 (MVP): GitHub Discussions

### Enable Discussions
```bash
# For a repository
gh api -X PATCH repos/Seven-Fortunas-Internal/REPO_NAME -f has_discussions=true
```

### View Discussions
```bash
# Open repository discussions in browser
gh repo view Seven-Fortunas-Internal/7f-infrastructure-project --web

# Search discussions
gh search discussions --repo Seven-Fortunas-Internal/7f-infrastructure-project "search term"
```

### When to Use Discussions vs Issues
- **Discussions:** Architecture decisions, Q&A, brainstorming, announcements
- **Issues:** Bug reports, specific tasks, actionable work items

## Phase 2: Matrix Server

### Status
Not yet deployed. See deployment documentation:
- `docs/communication/team-communication.md`
- `scripts/phase2/deploy-matrix-server.sh`

### Planned Features
- Self-hosted Matrix homeserver (Synapse)
- GitHub Bot integration (posts PR/issue updates)
- E2E encryption for sensitive discussions
- Federation capability (optional)

## Common Tasks

### Start a Discussion
1. Navigate to repository on GitHub
2. Click "Discussions" tab
3. Click "New discussion"
4. Select category (Announcements, General, Ideas, Q&A, Show and Tell)
5. Write title and description
6. Click "Start discussion"

### Search Discussions
```bash
gh search discussions --repo OWNER/REPO "keyword"
```

### Migrate Discussion to Issue
If a discussion becomes actionable work:
1. Create issue referencing discussion
2. Link discussion URL in issue description
3. Update discussion with "Tracked in #123"

## Documentation

Full documentation: `docs/communication/team-communication.md`

---

**Owner:** Jorge (VP AI-SecOps)
**Phase 0 Status:** Implemented
**Phase 2 Status:** Planned
