# 7f-dashboard-curator

**Seven Fortunas Custom Skill** - Curate and manage 7F Lens dashboard content

---

## Metadata

```yaml
source_bmad_skill: N/A (original Seven Fortunas skill)
created_by: Seven Fortunas Infrastructure Team
version: 1.0.0
created: 2026-02-17
integration: seven-fortunas-workspace/dashboards/
```

---

## Purpose

Curate, organize, and manage content for the 7F Lens dashboard platform. Automate the process of creating dashboard-ready content from Second Brain knowledge, ensuring consistent formatting and metadata.

---

## Usage

```bash
/7f-dashboard-curator <action> [options]
```

**Actions:**
- `create`: Create new dashboard widget/card
- `update`: Update existing dashboard content
- `publish`: Publish content to dashboard repository
- `validate`: Validate dashboard content structure
- `preview`: Generate HTML preview of dashboard
- `sources`: Manage dashboard data sources (RSS, Reddit, YouTube)

**Options:**
- `--source <path>`: Source file from Second Brain
- `--type <widget-type>`: Type of dashboard widget
- `--category <category>`: Dashboard category
- `--priority <level>`: Display priority (1-5)

**Source Management (All Dashboards):**
```bash
# Specify dashboard with DASHBOARD variable (ai, fintech, edutech, security)
DASHBOARD=ai  # or fintech, edutech, security

# Add RSS feed
python dashboards/$DASHBOARD/scripts/manage_sources.py add-rss --url URL --name NAME [--keywords KEYWORDS]

# Remove RSS feed
python dashboards/$DASHBOARD/scripts/manage_sources.py remove-rss --name NAME

# Add Reddit subreddit
python dashboards/$DASHBOARD/scripts/manage_sources.py add-reddit --subreddit SUBREDDIT

# Remove Reddit subreddit
python dashboards/$DASHBOARD/scripts/manage_sources.py remove-reddit --subreddit SUBREDDIT

# Add YouTube channel
python dashboards/$DASHBOARD/scripts/manage_sources.py add-youtube --channel CHANNEL_ID --name NAME

# List all sources
python dashboards/$DASHBOARD/scripts/manage_sources.py list

# Examples for each dashboard:
python dashboards/ai/scripts/manage_sources.py list
python dashboards/fintech/scripts/manage_sources.py list
python dashboards/edutech/scripts/manage_sources.py list
python dashboards/security/scripts/manage_sources.py list
```

---

## Workflow

### 1. Content Discovery

**Scan Second Brain for dashboard-worthy content:**
- Recent updates (last 7 days)
- High-priority concepts
- Frequently accessed documents
- Linked clusters (related content)

**Display candidates:**
```
Found 12 dashboard candidates:
1. [Concept] AI-SecOps Strategy (updated 2 days ago)
2. [Process] Incident Response SOP (high priority)
3. [Output] Q1 Architecture Review (frequently accessed)
...

Select items to curate (1-12, comma-separated):
```

### 2. Widget Creation

**Widget Types:**
- `insight-card`: Key insights and takeaways
- `metric-display`: Quantitative metrics
- `timeline-event`: Time-based events
- `concept-summary`: Concept overviews
- `process-status`: Process health indicators
- `relationship-map`: Linked concepts visualization
- `recent-activity`: Recent updates feed

**Generate widget JSON:**
```json
{
  "id": "widget-001",
  "type": "insight-card",
  "category": "security",
  "priority": 1,
  "title": "AI-SecOps Strategy",
  "summary": "Brief executive summary...",
  "content": {
    "main": "Full content...",
    "bullets": [
      "Key point 1",
      "Key point 2"
    ],
    "tags": ["ai", "security", "strategy"]
  },
  "metadata": {
    "source": "~/seven-fortunas-brain/Concepts/AI-SecOps-Strategy.md",
    "created": "2026-02-17T10:00:00Z",
    "updated": "2026-02-17T10:00:00Z",
    "author": "Jorge",
    "stakeholder": "Henry"
  },
  "display": {
    "icon": "shield",
    "color": "blue",
    "size": "medium"
  },
  "interactions": {
    "clickable": true,
    "expandable": true,
    "shareable": true
  }
}
```

### 3. Category Assignment

**Dashboard Categories:**
- `executive-overview`: High-level strategic view
- `security-posture`: Security metrics and status
- `infrastructure-health`: System health indicators
- `recent-activity`: Latest updates and changes
- `knowledge-graph`: Concept relationships
- `process-monitoring`: Process execution status
- `insights-recommendations`: AI-generated insights

**Auto-categorization rules:**
- SOPs → process-monitoring
- Metrics → security-posture or infrastructure-health
- Concepts → knowledge-graph
- Recent edits → recent-activity
- Strategic docs → executive-overview

### 4. Priority Calculation

**Priority algorithm:**
```
Priority = (
  stakeholder_relevance * 0.4 +
  recency * 0.3 +
  access_frequency * 0.2 +
  relationship_density * 0.1
)

Levels:
1 = Critical (always visible)
2 = High (top section)
3 = Medium (main section)
4 = Low (secondary section)
5 = Archive (hidden by default)
```

### 5. HTML Generation

Generate dashboard-ready HTML:
```html
<div class="7f-widget" data-id="widget-001" data-priority="1">
  <div class="widget-header">
    <span class="icon">🛡️</span>
    <h3>AI-SecOps Strategy</h3>
    <span class="category badge">security</span>
  </div>
  <div class="widget-body">
    <p class="summary">Brief executive summary...</p>
    <ul class="key-points">
      <li>Key point 1</li>
      <li>Key point 2</li>
    </ul>
  </div>
  <div class="widget-footer">
    <span class="author">Jorge</span>
    <span class="updated">2 days ago</span>
    <button class="expand">Read more →</button>
  </div>
</div>
```

### 6. Publish to Dashboard

**Save to dashboard repository:**
```
~/seven-fortunas-workspace/dashboards/
├── src/
│   ├── widgets/
│   │   └── widget-001.json
│   ├── categories/
│   │   └── security.json
│   └── index.html
└── public/
    └── dashboard.html (generated)
```

**Git workflow:**
```bash
cd ~/seven-fortunas-workspace/dashboards/
git add src/widgets/widget-001.json
git commit -m "feat(dashboard): Add AI-SecOps Strategy widget"
git push
```

### 7. Verification

**Validate widget:**
- JSON schema validation
- Required fields present
- Valid category and priority
- HTML renders correctly
- Links resolve properly
- Images load (if any)

**Preview:**
- Generate local HTML preview
- Open in browser
- Verify responsive layout

### 8. Source Management (FR-4.3)

**Add Data Source (All Dashboards):**
```bash
# Specify dashboard directory (ai, fintech, edutech, security)
DASHBOARD=ai  # or fintech, edutech, security
cd dashboards/$DASHBOARD

# Add RSS feed with validation
python scripts/manage_sources.py add-rss \
  --url "https://blog.example.com/feed.xml" \
  --name "Example Blog" \
  --keywords "ai,ml,devops"

# Add Reddit subreddit
python scripts/manage_sources.py add-reddit --subreddit "kubernetes"

# Add YouTube channel
python scripts/manage_sources.py add-youtube \
  --channel "UCXuqSBlHAE6Xw-yeJA0Tunw" \
  --name "Channel Name"
```

**Remove Data Source:**
```bash
# Remove RSS feed
python scripts/manage_sources.py remove-rss --name "Example Blog"

# Remove Reddit subreddit
python scripts/manage_sources.py remove-reddit --subreddit "kubernetes"
```

**List All Sources:**
```bash
python scripts/manage_sources.py list
```

**Trigger Dashboard Update:**
After modifying sources, trigger dashboard rebuild via GitHub Actions:
```bash
# AI Dashboard
gh workflow run update-dashboard.yml --repo dashboards/ai

# Fintech Dashboard
gh workflow run update-dashboard.yml --repo dashboards/fintech

# EduTech Dashboard
gh workflow run update-dashboard.yml --repo dashboards/edutech

# Security Dashboard
gh workflow run update-dashboard.yml --repo dashboards/security
```

**Verification:**
- Sources added to `sources.yaml` with proper YAML structure
- URL validation performed (RSS feeds test-fetched before saving)
- Changes logged to `config/source_changes.log` audit trail
- Dashboard update workflow triggered (manual or automatic 6-hour cron)

---

## Error Handling

**Source Errors:**
- File not found: Display error, suggest search
- Invalid markdown: Attempt to parse, warn about issues
- Missing metadata: Use defaults, log warning

**Widget Errors:**
- Invalid widget type: Show available types
- Missing required fields: Prompt for input
- Duplicate widget ID: Auto-generate unique ID

**Publish Errors:**
- Dashboard repo not found: Display setup instructions
- Git conflicts: Show merge resolution steps
- Push failed: Check authentication, retry

**Preview Errors:**
- Browser not available: Save HTML to file
- Port in use: Try alternate port
- Template not found: Use basic template

---

## Integration Points

- **Second Brain:** Sources content from all sections
- **Dashboard Repo:** Publishes to dashboards GitHub repo
- **7F Lens Platform:** Powers 7F Lens dashboard UI
- **BMAD Library:** Respects BMAD content patterns

---

## Example Usage

```bash
# Interactive mode: select from recent content
/7f-dashboard-curator create

# Create widget from specific source
/7f-dashboard-curator create --source ~/seven-fortunas-brain/Concepts/Strategy.md --type insight-card

# Update existing widget
/7f-dashboard-curator update widget-001 --priority 1

# Validate all dashboard content
/7f-dashboard-curator validate

# Preview dashboard locally
/7f-dashboard-curator preview

# Publish to dashboard repository
/7f-dashboard-curator publish --commit-message "Update security widgets"
```

---

## Dashboard Stakeholder Views

**Henry's View (Executive):**
- Executive overview
- Strategic insights
- High-level metrics
- Recent decisions

**Jorge's View (Technical):**
- Infrastructure health
- Security posture
- Process monitoring
- Technical debt

**Combined View (7F Lens):**
- All categories
- Full knowledge graph
- Complete activity feed
- Search and filter

---

## Widget Templates

**Insight Card:**
- Title + summary
- 3-5 key bullets
- Tags for filtering
- Expand for full content

**Metric Display:**
- Large number/percentage
- Trend indicator (↑↓→)
- Sparkline chart
- Context label

**Timeline Event:**
- Date/time stamp
- Event description
- Actor (who)
- Impact level

**Process Status:**
- Process name
- Health indicator (🟢🟡🔴)
- Last run timestamp
- Quick action button

---

## Dependencies

- Second Brain Structure (FR-2.1) ✅
- BMAD Library (FR-3.1) ✅
- Dashboard repository (dashboards)
- jq (JSON processing)
- Git (for publishing)

---

## Notes

This skill is the content engine for 7F Lens dashboards. It automates the transformation of Second Brain knowledge into dashboard-optimized widgets, ensuring consistent formatting and metadata.

**Key Innovation:** Automatic content discovery and categorization based on Second Brain structure and access patterns. The dashboard becomes a living view of organizational knowledge.

**Stakeholder-Specific Views:** Content can be filtered by stakeholder, showing Henry high-level strategic views and Jorge technical operational views, all from the same underlying data.
