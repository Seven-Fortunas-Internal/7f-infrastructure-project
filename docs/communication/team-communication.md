# Seven Fortunas Team Communication

## Overview
Seven Fortunas uses a phased approach to team communication, starting with GitHub-native tools and expanding to self-hosted infrastructure.

## Phase 0 (MVP): GitHub Discussions

### What is GitHub Discussions?
GitHub Discussions provides asynchronous, threaded communication integrated directly into GitHub repositories.

### Enabled Repositories
- **7f-infrastructure-project:** Infrastructure planning and implementation
- **seven-fortunas-brain:** Second Brain content and knowledge management
- **dashboards:** 7F Lens platform development

### Accessing Discussions
```bash
# Via GitHub CLI
gh repo view Seven-Fortunas-Internal/7f-infrastructure-project --web

# Via Web
https://github.com/Seven-Fortunas-Internal/7f-infrastructure-project/discussions
```

### Discussion Categories
Each repository has the following categories:

**Announcements** 📢
- Company announcements
- Feature releases
- Security advisories
- Change notifications

**General** 💬
- General discussion
- Questions and answers
- Team coordination

**Ideas** 💡
- Feature requests
- Improvement suggestions
- Brainstorming

**Q&A** ❓
- Technical questions
- Best practices
- How-to discussions

**Show and Tell** 🎨
- Demos
- Success stories
- Implementation showcases

### Best Practices

**Use Discussions For:**
- Architecture decisions
- Feature planning
- Knowledge sharing
- Cross-repository coordination
- Long-form discussions

**Use Issues For:**
- Bug reports
- Specific tasks
- Actionable work items

**Use Pull Requests For:**
- Code review
- Implementation discussion
- Technical feedback

### Searching Discussions
```bash
# Search across all discussions
gh search discussions --repo Seven-Fortunas-Internal/7f-infrastructure-project "search term"

# Search specific category
# (via web interface, filter by category)
```

## Phase 2: Matrix Server (Self-Hosted)

### Why Matrix?
- **Self-hosted:** Full data control on Seven Fortunas VPS
- **E2E encryption:** Secure sensitive discussions
- **Federation:** Optional future federation with partners
- **GitHub integration:** Bot posts updates to channels
- **Open source:** No vendor lock-in

### Architecture

**Matrix Homeserver**
- Deployment: Docker container on Hetzner VPS
- Server: Synapse (official Matrix homeserver)
- Database: PostgreSQL (persistent storage)
- Reverse proxy: Caddy (automatic TLS)

**GitHub Bot**
- Purpose: Post GitHub events to Matrix channels
- Events monitored:
  - Pull request reviews
  - Issue updates
  - CI/CD status (success/failure)
  - Security alerts (Dependabot, code scanning)
  - Deployment notifications

**Channel Structure**
```
#general                    # Company-wide announcements
#random                     # Off-topic
#infrastructure             # 7f-infrastructure-project
#second-brain               # seven-fortunas-brain
#dashboards                 # dashboards repo
#security-alerts            # Critical security notifications
#ci-cd                      # Automated build/deploy status
```

### Matrix Setup (Phase 2 Implementation)

#### 1. Deploy Matrix Homeserver
```bash
# On VPS (Hetzner)
docker run -d \
  --name synapse \
  -v synapse-data:/data \
  -p 8008:8008 \
  matrixdotorg/synapse:latest

# Generate config
docker exec synapse generate

# Configure server name, database, registration
docker exec synapse vim /data/homeserver.yaml
```

#### 2. Install Element Web Client
```bash
# Deploy Element (web client) for browser access
docker run -d \
  --name element-web \
  -p 8080:80 \
  vectorim/element-web:latest
```

#### 3. Create GitHub Bot
```python
# matrix-github-bot.py (simplified)
from matrix_nio import AsyncClient
import aiohttp

class GitHubMatrixBot:
    def __init__(self, homeserver, access_token):
        self.client = AsyncClient(homeserver)
        self.client.access_token = access_token

    async def post_message(self, room_id, message):
        await self.client.room_send(
            room_id=room_id,
            message_type="m.room.message",
            content={"msgtype": "m.text", "body": message}
        )

    async def handle_github_webhook(self, event):
        # Parse GitHub webhook
        if event["action"] == "opened":
            message = f"PR #{event['number']}: {event['title']}"
            await self.post_message("!infrastructure:matrix.sevenfortunas.com", message)
```

#### 4. Configure GitHub Webhooks
```bash
# For each repository
gh api repos/Seven-Fortunas-Internal/7f-infrastructure-project/hooks \
  -f name=web \
  -f config[url]=https://matrix.sevenfortunas.com/github-webhook \
  -f config[content_type]=json \
  -f events[]=pull_request \
  -f events[]=issues \
  -f events[]=push
```

### E2E Encryption

Matrix supports end-to-end encryption for sensitive discussions:

**Creating Encrypted Rooms**
```
/create #security-private (encrypted)
/invite @founder1:matrix.sevenfortunas.com
/invite @founder2:matrix.sevenfortunas.com
```

**Key Management**
- Each user manages their own encryption keys
- Cross-signing for device verification
- Key backup to homeserver (optional, password-protected)

### Message Retention

**Default Policy:**
- Public channels: 1 year retention
- Private channels: Indefinite retention
- Configurable per-room

**Disk Space Management:**
- Monitor VPS storage: `df -h`
- Purge old messages: `matrix-synapse-purge-history`
- Archive important discussions to Second Brain

### Migration from GitHub Discussions to Matrix

**Timeline:** After Phase 2 Matrix deployment

**Process:**
1. Archive important GitHub Discussions to Second Brain
2. Create corresponding Matrix channels
3. Post migration notice in GitHub Discussions
4. Redirect team to Matrix for real-time chat
5. Keep GitHub Discussions for long-form, searchable content

**Parallel Use:**
- GitHub Discussions: Architecture decisions, RFCs, knowledge base
- Matrix: Real-time chat, quick coordination, social interaction

## Comparison

| Feature | GitHub Discussions | Matrix Server |
|---------|-------------------|---------------|
| **Type** | Asynchronous forum | Real-time chat |
| **Hosting** | GitHub (cloud) | Self-hosted VPS |
| **Search** | Excellent (GitHub search) | Good (full-text search) |
| **GitHub Integration** | Native | Via bot (webhook) |
| **E2E Encryption** | No | Yes |
| **Mobile App** | GitHub mobile | Element mobile |
| **Cost** | Free (included with GitHub) | VPS cost (~$10/mo) |
| **Data Control** | GitHub owns | Full control |
| **Federation** | No | Optional |

## Usage Guidelines

### When to Use GitHub Discussions
- Architecture decisions requiring documentation
- Feature proposals with long-form explanation
- Q&A that should be searchable by future team members
- Announcements that need to be easily referenced

### When to Use Matrix (Phase 2)
- Quick questions and coordination
- Real-time collaboration during implementation
- Social/team building conversations
- Sensitive discussions requiring E2E encryption

### When to Use GitHub Issues
- Bug reports
- Specific, actionable tasks
- Work that needs to be tracked in sprint/project boards

### When to Use Pull Requests
- Code review and implementation discussion
- Technical feedback on specific changes

## Troubleshooting

### GitHub Discussions Not Enabled
```bash
# Enable manually via CLI
gh api -X PATCH repos/OWNER/REPO -f has_discussions=true

# Or via web interface:
# Repo Settings → Features → Discussions (check the box)
```

### Matrix Homeserver Issues (Phase 2)
```bash
# Check container logs
docker logs synapse

# Restart homeserver
docker restart synapse

# Check database connection
docker exec synapse psql -U synapse
```

### GitHub Bot Not Posting (Phase 2)
```bash
# Verify webhook delivery
gh api repos/OWNER/REPO/hooks/HOOK_ID/deliveries

# Check bot logs
docker logs matrix-github-bot

# Test webhook manually
curl -X POST https://matrix.sevenfortunas.com/github-webhook \
  -H "Content-Type: application/json" \
  -d '{"action": "test"}'
```

## Resources

### Phase 0 (GitHub Discussions)
- [GitHub Discussions Documentation](https://docs.github.com/en/discussions)
- [Best Practices for Discussions](https://docs.github.com/en/discussions/guides/best-practices-for-community-conversations-on-github)

### Phase 2 (Matrix)
- [Matrix Protocol](https://matrix.org/)
- [Synapse Homeserver](https://github.com/matrix-org/synapse)
- [Element Client](https://element.io/)
- [Matrix-GitHub Bridge](https://github.com/matrix-org/matrix-appservice-github)

---

**Last Updated:** 2026-02-17
**Owner:** Jorge (VP AI-SecOps)
**Phase 0 Status:** Implemented
**Phase 2 Status:** Planned
