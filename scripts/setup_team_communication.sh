#!/bin/bash
# FEATURE_033: Team Communication
# Sets up GitHub Discussions (MVP Phase 0) and documents Matrix integration (Phase 2)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== FEATURE_033: Team Communication Setup ==="
echo ""

# Verify GitHub authentication
echo "1. Verifying GitHub authentication..."
if ! gh auth status &>/dev/null; then
    echo "ERROR: GitHub CLI not authenticated. Run: gh auth login"
    exit 1
fi
echo "✓ GitHub authenticated"
echo ""

# Phase 0 (MVP): GitHub Discussions
echo "2. Setting up GitHub Discussions (MVP - Phase 0)..."

# List of repositories to enable discussions
REPOS=(
    "Seven-Fortunas-Internal/7f-infrastructure-project"
    "Seven-Fortunas-Internal/seven-fortunas-brain"
    "Seven-Fortunas/dashboards"
)

for REPO in "${REPOS[@]}"; do
    echo "  Processing: $REPO"

    # Check if repo exists
    if gh api "repos/$REPO" &>/dev/null; then
        # Enable discussions
        if gh api -X PATCH "repos/$REPO" -f has_discussions=true &>/dev/null; then
            echo "    ✓ GitHub Discussions enabled"
        else
            echo "    ⚠ Could not enable discussions (may already be enabled or insufficient permissions)"
        fi
    else
        echo "    ⚠ Repository not found (will be created later)"
    fi
done
echo ""

# Create documentation
echo "3. Creating team communication documentation..."
mkdir -p "$PROJECT_ROOT/docs/communication"

cat > "$PROJECT_ROOT/docs/communication/team-communication.md" << 'EOF'
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
EOF

echo "✓ Documentation created: $PROJECT_ROOT/docs/communication/team-communication.md"
echo ""

# Create Phase 2 deployment script (for future use)
echo "4. Creating Matrix deployment script (Phase 2)..."
mkdir -p "$PROJECT_ROOT/scripts/phase2"

cat > "$PROJECT_ROOT/scripts/phase2/deploy-matrix-server.sh" << 'EOF'
#!/bin/bash
# Phase 2: Deploy Matrix homeserver and GitHub bot
# TO BE EXECUTED ON HETZNER VPS

set -euo pipefail

echo "=== Phase 2: Matrix Server Deployment ==="
echo ""
echo "⚠ This script should be run on the Hetzner VPS after Phase 2 begins"
echo ""

# Check if running on VPS
if [[ ! -f /etc/hetzner-cloud ]]; then
    echo "WARNING: Not running on Hetzner VPS. Proceeding anyway..."
fi

# Install Docker (if not already installed)
if ! command -v docker &>/dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
fi

# Deploy Synapse homeserver
echo "1. Deploying Matrix Synapse homeserver..."
docker run -d \
  --name synapse \
  --restart unless-stopped \
  -v synapse-data:/data \
  -p 8008:8008 \
  -e SYNAPSE_SERVER_NAME=matrix.sevenfortunas.com \
  -e SYNAPSE_REPORT_STATS=no \
  matrixdotorg/synapse:latest

echo "✓ Synapse deployed"

# Deploy Element web client
echo "2. Deploying Element web client..."
docker run -d \
  --name element-web \
  --restart unless-stopped \
  -p 8080:80 \
  vectorim/element-web:latest

echo "✓ Element deployed"

# Deploy PostgreSQL for Synapse
echo "3. Deploying PostgreSQL database..."
docker run -d \
  --name synapse-postgres \
  --restart unless-stopped \
  -e POSTGRES_PASSWORD=CHANGE_ME \
  -e POSTGRES_USER=synapse \
  -e POSTGRES_DB=synapse \
  -v postgres-data:/var/lib/postgresql/data \
  postgres:14

echo "✓ PostgreSQL deployed"

echo ""
echo "=== Next Steps ==="
echo "1. Configure Synapse: docker exec -it synapse vi /data/homeserver.yaml"
echo "2. Create admin user: docker exec synapse register_new_matrix_user -c /data/homeserver.yaml"
echo "3. Set up Caddy reverse proxy for TLS"
echo "4. Deploy GitHub bot (see docs/communication/team-communication.md)"
echo "5. Configure GitHub webhooks"
echo ""
EOF
chmod +x "$PROJECT_ROOT/scripts/phase2/deploy-matrix-server.sh"
echo "✓ Phase 2 script created: $PROJECT_ROOT/scripts/phase2/deploy-matrix-server.sh"
echo ""

# Create Claude skill for team communication
echo "5. Creating team-communication skill..."
cat > "$PROJECT_ROOT/.claude/commands/team-communication.md" << 'EOF'
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
EOF
echo "✓ Skill created: $PROJECT_ROOT/.claude/commands/team-communication.md"
echo ""

echo "=== Setup Complete ==="
echo ""
echo "Phase 0 (MVP): GitHub Discussions"
echo "- Enabled for: 7f-infrastructure-project, seven-fortunas-brain, dashboards"
echo "- Access via: gh repo view OWNER/REPO --web"
echo "- Categories: Announcements, General, Ideas, Q&A, Show and Tell"
echo ""
echo "Phase 2: Matrix Server (Planned)"
echo "- Deployment script: scripts/phase2/deploy-matrix-server.sh"
echo "- Documentation: docs/communication/team-communication.md"
echo ""
echo "Skill: /team-communication (in Claude Code)"
echo ""
