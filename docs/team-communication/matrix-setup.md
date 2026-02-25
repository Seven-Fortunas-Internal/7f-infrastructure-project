# Matrix Server Setup Guide (Phase 2)

## Overview

Matrix is a decentralized, E2E encrypted communication platform for real-time team chat.

**Status:** Phase 2 (Not yet deployed)
**Priority:** P2
**Timeline:** After MVP launch

## Why Matrix?

✅ **Self-hosted:** Full control over data
✅ **E2E encryption:** Secure sensitive discussions
✅ **Open source:** No vendor lock-in
✅ **GitHub integration:** Bot posts workflow updates
✅ **Bridges:** Connect to Slack, Discord, IRC

## Architecture

```
┌─────────────────────────────────────────────┐
│         Matrix Homeserver (Synapse)         │
│         VPS: 2GB RAM, 20GB SSD              │
│         matrix.sevenfortunas.com            │
└──────────────┬──────────────────────────────┘
               │
               ├──► GitHub Bot (maubot)
               │    Posts PR/issue/CI updates
               │
               ├──► Channels:
               │    #general, #engineering,
               │    #security, #product, etc.
               │
               └──► Clients:
                    Element (web, desktop, mobile)
```

## Deployment (Future)

### 1. Provision VPS

**Requirements:**
- 2 GB RAM minimum
- 20 GB SSD (scales with message history)
- Ubuntu 22.04 LTS
- Public IP + domain

**Providers:**
- DigitalOcean: $12/month (2GB droplet)
- Linode: $12/month
- Hetzner: €4.51/month (cheaper EU option)

### 2. Install Matrix Synapse

```bash
# Install dependencies
sudo apt update && sudo apt install -y \
  matrix-synapse-py3 postgresql python3-psycopg2

# Configure Synapse
sudo nano /etc/matrix-synapse/homeserver.yaml

# Key settings:
server_name: "matrix.sevenfortunas.com"
enable_registration: false  # Invite-only
registration_shared_secret: "<random secret>"
database:
  name: psycopg2
  args:
    user: synapse
    password: <db password>
    database: synapse
```

### 3. Set Up PostgreSQL

```bash
# Create database
sudo -u postgres createuser synapse -P
sudo -u postgres createdb synapse \
  --owner=synapse \
  --encoding=UTF8 \
  --locale=C \
  --template=template0

# Test connection
psql -U synapse -h localhost -d synapse
```

### 4. Configure Nginx Reverse Proxy

```nginx
server {
    listen 443 ssl http2;
    server_name matrix.sevenfortunas.com;

    ssl_certificate /etc/letsencrypt/live/matrix.sevenfortunas.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/matrix.sevenfortunas.com/privkey.pem;

    location ~ ^(/_matrix|/_synapse/client) {
        proxy_pass http://localhost:8008;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $host;
    }
}
```

### 5. Install Element Web Client

```bash
# Download Element
cd /var/www
wget https://github.com/vector-im/element-web/releases/latest/download/element-web.tar.gz
tar -xzf element-web.tar.gz
mv element-* element

# Configure
cat > /var/www/element/config.json << EOF
{
  "default_server_config": {
    "m.homeserver": {
      "base_url": "https://matrix.sevenfortunas.com",
      "server_name": "matrix.sevenfortunas.com"
    }
  }
}
EOF
```

### 6. Create User Accounts

```bash
# Register admin user
register_new_matrix_user -c /etc/matrix-synapse/homeserver.yaml

# Create founders
# Jorge
# Henry
# (Future team members)
```

### 7. Set Up GitHub Bot

**Using maubot:**

```bash
# Install maubot
pip3 install maubot

# Configure GitHub plugin
# - Create bot account: @github:matrix.sevenfortunas.com
# - Generate GitHub webhook secret
# - Configure webhook URL: https://matrix.sevenfortunas.com/maubot/github
```

**Bot features:**
- Post PR reviews to #engineering
- Post issue updates to relevant channels
- Post CI/CD status to #deployments
- Post security alerts to #security
- Post releases to #announcements

## Channel Structure

```
#general - General team chat
#engineering - Engineering discussions
#product - Product planning
#security - Security & compliance (private)
#deployments - CI/CD notifications
#random - Off-topic, fun
#support - Help and questions

Per-repo channels:
#repo-7f-infrastructure-project
#repo-seven-fortunas-brain
#repo-dashboards
```

## E2E Encryption

**Enable for sensitive channels:**

```
# In Element client:
1. Create room
2. Settings > Security & Privacy
3. Enable "End-to-end encryption"
4. Enable "Never send encrypted messages to unverified devices"
```

**Encryption best practices:**
- Enable for #security, #founders-only
- Disable for public channels (better performance)
- Back up encryption keys (recovery phrase)
- Verify device fingerprints

## Integration with GitHub

**Webhook configuration:**

```yaml
# .github/workflows/matrix-notify.yml
name: Notify Matrix

on:
  pull_request:
    types: [opened, closed, review_requested]
  issues:
    types: [opened, closed, labeled]
  workflow_run:
    workflows: ["CI/CD"]
    types: [completed]

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - name: Send to Matrix
        run: |
          curl -X POST "${{ secrets.MATRIX_WEBHOOK_URL }}" \
            -H "Content-Type: application/json" \
            -d '{
              "text": "PR #${{ github.event.number }}: ${{ github.event.pull_request.title }}",
              "channel": "#engineering"
            }'
```

## Cost Estimate

**Monthly costs:**
- VPS: $12/month (DigitalOcean 2GB)
- Domain: $1/month (sevenfortunas.com subdomain)
- Total: ~$13/month

**Compared to alternatives:**
- Slack Team: $8/user/month ($24/month for 3 users)
- Discord: Free (but not self-hosted)
- Microsoft Teams: $5/user/month

**Decision:** Matrix is cost-effective for small teams.

## Migration from GitHub Discussions

**Gradual migration:**

1. **Phase 0 (current):** GitHub Discussions only
2. **Phase 1:** Deploy Matrix, onboard founders
3. **Phase 2:** Create channels, set up GitHub Bot
4. **Phase 3:** Migrate async discussions to Matrix
5. **Phase 4:** GitHub Discussions for archival only

**Data migration:**
- Export discussions from GitHub (API)
- Post summaries to Matrix channels
- Link back to GitHub for history

## Backup and Disaster Recovery

**Database backups:**
```bash
# Daily backup script
pg_dump synapse | gzip > /backup/synapse-$(date +%Y%m%d).sql.gz

# Keep 30 days of backups
find /backup -name "synapse-*.sql.gz" -mtime +30 -delete
```

**Encryption key backup:**
- Export from Element: Settings > Security > Backup encryption keys
- Store in password manager (1Password, Bitwarden)
- Test restore annually

## Security Considerations

- ✅ Firewall (UFW): Allow only 443, 8448
- ✅ Fail2ban: Block brute-force login attempts
- ✅ Regular updates: `apt upgrade` weekly
- ✅ Monitoring: Uptime alerts
- ❌ Don't expose admin API publicly
- ❌ Don't allow public registration

## Alternative: Matrix.org Hosting

**If self-hosting is too complex:**

- Use matrix.org free hosting
- Usernames: @jorge:matrix.org
- Free, but data not self-hosted
- Still works with GitHub Bot

## References

- [Matrix.org Documentation](https://matrix.org/docs/)
- [Synapse Installation](https://github.com/matrix-org/synapse/blob/develop/INSTALL.md)
- [Element Web](https://element.io/)
- [Maubot GitHub Plugin](https://github.com/maubot/github)

---

**Status:** Phase 2 (Not deployed)
**Priority:** P2
**Owner:** Jorge (VP AI-SecOps)
**Estimated Effort:** 8 hours setup + 2 hours/month maintenance
