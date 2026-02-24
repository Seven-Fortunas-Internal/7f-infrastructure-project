# Seven Fortunas Team Communication

## Overview

The Seven Fortunas team communication system provides both asynchronous and real-time communication channels integrated with the GitHub workflow.

**Approach:** Phased implementation
- **MVP (Phase 0):** GitHub Discussions for async communication
- **Phase 2:** Self-hosted Matrix server with GitHub Bot integration

---

## MVP: GitHub Discussions (Phase 0)

### Setup

GitHub Discussions is enabled for all Seven Fortunas repositories to provide:
- Asynchronous team communication
- Searchable Q&A
- Announcements and updates
- Feature requests and feedback

### Access

**Enable GitHub Discussions:**
```bash
# For organization repository
gh repo edit Seven-Fortunas-Internal/7f-infrastructure-project \
  --enable-discussions

# Verify discussions enabled
gh api repos/Seven-Fortunas-Internal/7f-infrastructure-project | jq '.has_discussions'
```

### Discussion Categories

#### 1. **Announcements** 📢
- Purpose: Official team announcements
- Format: Announcement (read-only replies)
- Examples:
  - Sprint planning results
  - New feature releases
  - Infrastructure updates

#### 2. **General** 💬
- Purpose: General team conversation
- Format: Open discussion
- Examples:
  - Sprint retrospectives
  - Process improvements
  - Informal updates

#### 3. **Q&A** ❓
- Purpose: Technical questions and answers
- Format: Q&A (mark best answer)
- Examples:
  - "How do I configure BMAD workflows?"
  - "What's the secret rotation schedule?"
  - "Where is the sprint dashboard?"

#### 4. **Ideas** 💡
- Purpose: Feature requests and proposals
- Format: Open discussion
- Examples:
  - New dashboard ideas
  - Integration proposals
  - Tool recommendations

#### 5. **Show and Tell** 🎨
- Purpose: Demos and achievements
- Format: Open discussion
- Examples:
  - New skill demonstrations
  - Dashboard screenshots
  - Automation wins

### Creating Discussions

#### Via GitHub Web UI

1. Navigate to repository
2. Click "Discussions" tab
3. Click "New discussion"
4. Select category
5. Enter title and body (supports Markdown)
6. Click "Start discussion"

#### Via GitHub CLI

```bash
# Create announcement
gh discussion create \
  --repo Seven-Fortunas-Internal/7f-infrastructure-project \
  --category "Announcements" \
  --title "Sprint 2026-W08 Complete" \
  --body "We completed 19 stories this sprint..."

# Create Q&A
gh discussion create \
  --repo Seven-Fortunas-Internal/7f-infrastructure-project \
  --category "Q&A" \
  --title "How to rotate API keys?" \
  --body "What's the procedure for rotating the Anthropic API key?"
```

### Searching Discussions

**Via Web UI:**
1. Go to Discussions tab
2. Use search box: "How to rotate"
3. Filter by category, author, label

**Via GitHub CLI:**
```bash
# Search discussions
gh search discussions \
  --repo Seven-Fortunas-Internal/7f-infrastructure-project \
  "API key rotation"

# List recent discussions
gh discussion list \
  --repo Seven-Fortunas-Internal/7f-infrastructure-project \
  --limit 20
```

### Notifications

**Automatic notifications for:**
- Discussions you created
- Discussions you commented on
- Discussions you're @mentioned in
- Discussions in categories you're watching

**Configure notifications:**
1. Repository → Discussions → Watch
2. Settings → Notifications → Customize email preferences

---

## Phase 2: Matrix Server + GitHub Bot

### Overview

**Matrix** is an open-source, decentralized communication protocol providing:
- Real-time messaging
- End-to-end encryption (E2EE)
- Self-hosted control
- GitHub integration via bots

### Architecture

```
┌─────────────────┐        ┌──────────────────┐
│ GitHub Repos    │◄───────┤  GitHub Bot      │
│ - PRs           │        │  (matrix-bot)    │
│ - Issues        │        └────────┬─────────┘
│ - CI/CD         │                 │
│ - Alerts        │                 │
└─────────────────┘                 │
                                    ▼
                          ┌──────────────────┐
                          │  Matrix Server   │
                          │  (Synapse)       │
                          │  - Homeserver    │
                          │  - E2EE          │
                          │  - Channels      │
                          └────────┬─────────┘
                                   │
                          ┌────────▼─────────┐
                          │  Team Members    │
                          │  - Element       │
                          │  - Mobile App    │
                          │  - Web Client    │
                          └──────────────────┘
```

### Matrix Homeserver Deployment

**Server Requirements:**
- VPS with 2GB RAM minimum
- Ubuntu 22.04 LTS
- 20GB disk space
- Domain name for Matrix server

**Installation:**
```bash
# Install Synapse (Matrix homeserver)
sudo apt update
sudo apt install -y matrix-synapse-py3

# Configure homeserver
sudo nano /etc/matrix-synapse/homeserver.yaml

# Key configuration:
# server_name: "sevenfortunas.dev"
# enable_registration: false
# enable_registration_captcha: false
# registration_shared_secret: "<secret>"
# max_upload_size: "50M"
# url_preview_enabled: true

# Start Synapse
sudo systemctl enable matrix-synapse
sudo systemctl start matrix-synapse
```

**Create Admin User:**
```bash
# Register admin user
register_new_matrix_user -c /etc/matrix-synapse/homeserver.yaml \
  -u jorge \
  -p <password> \
  -a

# Output:
# Success! User @jorge:sevenfortunas.dev created (admin)
```

### Matrix Channels

**Channel Structure:**
- `#general:sevenfortunas.dev` - General team chat
- `#infrastructure:sevenfortunas.dev` - Infrastructure discussions
- `#github-prs:sevenfortunas.dev` - PR notifications
- `#github-issues:sevenfortunas.dev` - Issue notifications
- `#github-ci:sevenfortunas.dev` - CI/CD status updates
- `#github-security:sevenfortunas.dev` - Security alerts

**Create Channels:**
```bash
# Via Element (Matrix client)
# 1. Click "+"
# 2. Select "Create Room"
# 3. Name: "Infrastructure"
# 4. Address: #infrastructure:sevenfortunas.dev
# 5. Encryption: Enabled
# 6. Visibility: Private
```

### GitHub Bot Integration

**Bot Setup:**
```bash
# Install matrix-commander (Python bot)
pip3 install matrix-commander

# Login and save credentials
matrix-commander --login password \
  --user-login github-bot \
  --password <bot-password> \
  --homeserver https://matrix.sevenfortunas.dev \
  --device "GitHub-Bot" \
  --store ~/.config/matrix-commander

# Send test message
matrix-commander \
  --message "GitHub Bot connected" \
  --room "#general:sevenfortunas.dev"
```

**GitHub Webhook Handler:**
```python
#!/usr/bin/env python3
# github-matrix-bot.py - Forward GitHub events to Matrix

from flask import Flask, request
import subprocess
import json

app = Flask(__name__)

def send_matrix_message(room, message):
    """Send message to Matrix room"""
    subprocess.run([
        "matrix-commander",
        "--message", message,
        "--markdown",
        "--room", room
    ])

@app.route("/webhook", methods=["POST"])
def github_webhook():
    """Handle GitHub webhooks"""
    event = request.headers.get("X-GitHub-Event")
    payload = request.json

    if event == "pull_request":
        pr = payload["pull_request"]
        action = payload["action"]
        message = f"**PR {action}:** [{pr['title']}]({pr['html_url']}) by @{pr['user']['login']}"
        send_matrix_message("#github-prs:sevenfortunas.dev", message)

    elif event == "issues":
        issue = payload["issue"]
        action = payload["action"]
        message = f"**Issue {action}:** [{issue['title']}]({issue['html_url']}) by @{issue['user']['login']}"
        send_matrix_message("#github-issues:sevenfortunas.dev", message)

    elif event == "workflow_run":
        workflow = payload["workflow_run"]
        status = workflow["conclusion"]
        emoji = "✅" if status == "success" else "❌"
        message = f"{emoji} **CI/CD:** {workflow['name']} {status} - [{workflow['repository']['full_name']}]({workflow['html_url']})"
        send_matrix_message("#github-ci:sevenfortunas.dev", message)

    return {"status": "ok"}, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

**Configure GitHub Webhooks:**
```bash
# Add webhook to repository
gh api repos/Seven-Fortunas-Internal/7f-infrastructure-project/hooks \
  -X POST \
  -f name=web \
  -f active=true \
  -f events[]='pull_request' \
  -f events[]='issues' \
  -f events[]='workflow_run' \
  -f config[url]='https://matrix-bot.sevenfortunas.dev/webhook' \
  -f config[content_type]='json'
```

### End-to-End Encryption

**Enable E2EE for Sensitive Channels:**
```bash
# In Element client:
# 1. Create new room
# 2. Room Settings → Security & Privacy
# 3. Enable "Encryption" toggle
# 4. Set "History Visibility" to "Invited users only"

# Encrypted rooms:
# - #infrastructure:sevenfortunas.dev (E2EE)
# - #github-security:sevenfortunas.dev (E2EE)
```

**Key Backup:**
```bash
# Element → Settings → Security & Privacy → Encryption
# 1. Set up Key Backup (passphrase or recovery key)
# 2. Store recovery key in password manager
# 3. Test restore on another device
```

---

## Usage Comparison

| Feature | GitHub Discussions (MVP) | Matrix (Phase 2) |
|---------|--------------------------|------------------|
| **Real-time messaging** | ❌ No | ✅ Yes |
| **Async discussions** | ✅ Yes | ✅ Yes |
| **Searchable** | ✅ Yes | ✅ Yes |
| **End-to-end encryption** | ❌ No | ✅ Yes |
| **Self-hosted** | ❌ No | ✅ Yes |
| **GitHub integration** | ✅ Native | ✅ Via Bot |
| **Mobile app** | ✅ GitHub Mobile | ✅ Element |
| **Message editing** | ✅ Yes | ✅ Yes |
| **Threading** | ✅ Yes | ✅ Yes |
| **Notifications** | ✅ Email | ✅ Push |
| **Cost** | Free | $5-10/month (VPS) |

---

## Best Practices

### GitHub Discussions

1. **Use appropriate categories**
   - Announcements for official updates
   - Q&A for technical questions
   - Ideas for proposals

2. **Write clear titles**
   - Good: "How to rotate ANTHROPIC_API_KEY?"
   - Bad: "Question about keys"

3. **Mark answers**
   - In Q&A discussions, mark the best answer
   - Helps future searches

4. **Link to related issues/PRs**
   - Reference #123 for issues
   - Reference PR #456
   - Creates automatic links

### Matrix (Phase 2)

1. **Channel organization**
   - Keep channels topic-focused
   - Use #general for off-topic
   - Create project-specific channels as needed

2. **Enable encryption for sensitive topics**
   - Infrastructure credentials
   - Security incidents
   - Compliance discussions

3. **Bot message formatting**
   - Use Markdown for rich formatting
   - Include direct links to GitHub
   - Add emojis for status (✅❌⚠️)

---

## Troubleshooting

### GitHub Discussions

**Issue: Discussions tab not visible**
```bash
# Enable discussions
gh repo edit REPO --enable-discussions
```

**Issue: Cannot create discussion**
- Verify you have write access to repository
- Check repository settings → Features → Discussions

### Matrix (Phase 2)

**Issue: Cannot connect to homeserver**
```bash
# Check Synapse status
sudo systemctl status matrix-synapse

# View logs
sudo journalctl -u matrix-synapse -f
```

**Issue: GitHub Bot not posting**
```bash
# Test bot manually
matrix-commander --message "Test" --room "#general:sevenfortunas.dev"

# Check webhook deliveries in GitHub
gh api repos/REPO/hooks/HOOK_ID/deliveries
```

---

## See Also

- [GitHub Discussions Docs](https://docs.github.com/en/discussions)
- [Matrix.org](https://matrix.org/)
- [Element Client](https://element.io/)
- FR-8.5: Team Communication

---

**MVP Status:** Operational (GitHub Discussions enabled)
**Phase 2 Status:** Documentation complete, deployment pending
**Last Updated:** 2026-02-24
**Owner:** Jorge (VP AI-SecOps)
