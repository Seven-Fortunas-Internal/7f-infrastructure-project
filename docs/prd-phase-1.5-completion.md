# Seven Fortunas Infrastructure - Phase 1.5 Completion PRD

**Version:** 1.0
**Date:** 2026-02-18
**Purpose:** Complete missing UI and deployment features from Phase 1

---

## Executive Summary

Phase 1 autonomous implementation successfully created all backend infrastructure (data fetching, automation scripts, GitHub Actions) but stopped before implementing user-facing interfaces and deployments. Phase 1.5 completes the frontend implementations to make features accessible to users.

**Gap:** Autonomous agent validated local file creation but did not deploy to GitHub or create React UIs.

**Goal:** Complete all user-facing features so infrastructure is fully accessible via web browser.

---

## Background

### Phase 1 Accomplishments
- ✅ 42 features implemented (backends)
- ✅ 39 automation scripts created
- ✅ 10 GitHub Actions workflows
- ✅ Data fetching and caching functional
- ✅ GitHub repository structure established

### Phase 1 Gaps
- ❌ React UIs not built (specified in tech stack but not implemented)
- ❌ GitHub Pages not configured
- ❌ Dashboards not accessible via public URLs
- ❌ Website landing page not created
- ❌ Skills not fully deployed to seven-fortunas-brain

### Root Cause
Verification tests validated local artifacts only, not public deployment or UI technology requirements.

---

## Technology Stack

### Frontend
- **React 18.2+** - UI component library (REQUIRED)
- **Vite 4.x** - Build tool and dev server
- **CSS3** - Styling with mobile-responsive design
- **Fetch API** - Load JSON data from backend

### Deployment
- **GitHub Pages** - Static site hosting
- **GitHub Actions** - Build and deploy automation

### Backend (Already Complete)
- Python 3.11+ scripts
- GitHub Actions workflows
- JSON data caching

---

## Project Goals

1. **Build React dashboards** with mobile-responsive UI
2. **Enable GitHub Pages** for public accessibility
3. **Deploy company website** landing page
4. **Complete skill deployment** to seven-fortunas-brain
5. **Achieve zero 404 errors** on all user-facing links

---

## Features

### FR-1: AI Advancements Dashboard React UI

**Description:** Build React-based web UI for AI Advancements Dashboard to replace markdown table

**Current State:**
- Backend complete: data/cached_updates.json with 14 updates
- Automation complete: GitHub Actions updates every 6 hours
- Frontend missing: Only markdown table in README.md

**Requirements:**
- React 18.2+ single-page application
- Vite build configuration
- Components:
  - UpdateCard: Individual update display
  - SourceFilter: Filter by source dropdown
  - ErrorBanner: Show failed sources
  - LastUpdated: Timestamp display
  - SearchBar: Keyword search
- Mobile-responsive CSS (320px, 768px, 1024px breakpoints)
- Load data from `../data/cached_updates.json` relative path
- Build output to dist/ directory
- Deploy to GitHub Pages at `/dashboards/ai/`

**Acceptance Criteria:**
- Dashboard accessible at https://seven-fortunas.github.io/dashboards/ai/
- Displays all 14+ updates from cached_updates.json
- Error banner shows 4 failed sources
- Filter dropdown works (select source, see only those updates)
- Search works (type keyword, filter results)
- Mobile responsive (tested at 375px width)
- Build succeeds via npm run build
- GitHub Actions workflow deploys automatically

**Verification:**
- MUST verify React used: grep -q '"react": "^18' package.json
- MUST verify build succeeds: cd dashboards/ai && npm ci && npm run build
- MUST verify public URL: curl -I https://seven-fortunas.github.io/dashboards/ai/ | grep "200 OK"
- MUST verify components exist: ls src/components/UpdateCard.jsx src/components/SourceFilter.jsx

**Deliverables:**
- dashboards/ai/package.json with React 18.2+ dependency
- dashboards/ai/vite.config.js with base: '/dashboards/ai/'
- dashboards/ai/src/App.jsx
- dashboards/ai/src/components/ (UpdateCard, SourceFilter, ErrorBanner, SearchBar, LastUpdated)
- dashboards/ai/src/styles/dashboard.css with media queries
- dashboards/ai/dist/ (build output)
- .github/workflows/deploy-ai-dashboard.yml

**Dependencies:** None (backend already complete)

**Constraints:**
- MUST use React 18.x (not just markdown)
- MUST be mobile-responsive
- MUST deploy to GitHub Pages
- MUST verify public URL accessibility before marking complete

---

### FR-2: GitHub Pages Configuration

**Description:** Enable GitHub Pages for dashboards and website repositories

**Current State:**
- Repositories exist but GitHub Pages not configured
- Attempting to access https://seven-fortunas.github.io/dashboards/ returns 404

**Requirements:**
- Enable GitHub Pages on Seven-Fortunas/dashboards repository
- Configure to serve from main branch, root directory
- Enable GitHub Pages on Seven-Fortunas/seven-fortunas.github.io
- Verify Pages build succeeds
- Create verification script

**Acceptance Criteria:**
- GitHub Pages enabled (check via API)
- Pages status shows "built" not "building" or "errored"
- https://seven-fortunas.github.io/dashboards/ returns 200 OK
- https://seven-fortunas.github.io/ returns 200 OK

**Verification:**
- MUST verify via API: gh api repos/Seven-Fortunas/dashboards/pages | jq '.status' == "built"
- MUST verify URL: curl -I https://seven-fortunas.github.io/dashboards/ | grep "200 OK"
- MUST wait for build: Retry up to 5 minutes for Pages to build after enabling

**Deliverables:**
- GitHub Pages enabled via gh api call
- scripts/verify_github_pages.sh verification script
- Documentation of Pages configuration

**Dependencies:** None

**Constraints:**
- MUST verify public URL accessibility
- MUST handle Pages build delay (can take 1-5 minutes)

---

### FR-3: Company Website Landing Page

**Description:** Create professional landing page for seven-fortunas.github.io

**Current State:**
- Repository exists (seven-fortunas.github.io)
- No content deployed

**Requirements:**
- Professional HTML/CSS landing page
- Company branding (use placeholder - will be refined by CEO)
- Links to dashboards
- About section (mission statement)
- Contact information
- Mobile-responsive design
- Optional: Simple navigation menu

**Acceptance Criteria:**
- Landing page accessible at https://seven-fortunas.github.io/
- Page renders correctly in browser
- Links to AI dashboard work (navigate to dashboard)
- Mobile responsive (tested at 375px width)
- Valid HTML5 markup

**Verification:**
- MUST verify URL: curl -I https://seven-fortunas.github.io/ | grep "200 OK"
- MUST verify HTML: Load in browser, check rendering
- MUST verify links: Click dashboard link, verify navigation works

**Deliverables:**
- seven-fortunas.github.io/index.html
- seven-fortunas.github.io/styles.css
- seven-fortunas.github.io/assets/ (images, logo placeholder)
- seven-fortunas.github.io/README.md

**Dependencies:** FR-2 (GitHub Pages configuration)

**Constraints:**
- Use placeholder branding only (CEO will apply real branding)
- Keep design simple and professional
- MUST be mobile-responsive

---

### FR-4: Second Brain Search Enhancement

**Description:** Enhance existing search script for Second Brain knowledge base

**Current State:**
- scripts/search-second-brain.sh exists but basic
- No web interface

**Requirements:**
- Enhance CLI search with fuzzy matching
- Support frontmatter field search (--tag, --author, --context-level)
- Rank results by relevance
- Optional: Simple web search interface (HTML form + JavaScript)

**Acceptance Criteria:**
- CLI search works: ./scripts/search-second-brain.sh "BMAD" returns results
- Frontmatter search works: ./scripts/search-second-brain.sh --tag "security"
- Results include file path, matched line, and frontmatter excerpt
- Web interface optional but nice to have

**Verification:**
- MUST verify CLI: ./scripts/search-second-brain.sh "BMAD" | grep -q "README"
- MUST verify tag search: ./scripts/search-second-brain.sh --tag "architecture" returns tagged files
- Optional: Load web interface in browser

**Deliverables:**
- Enhanced scripts/search-second-brain.sh with fuzzy matching
- Optional: second-brain-public/search.html web interface

**Dependencies:** None

**Constraints:**
- CLI must work (web interface optional)

---

### FR-5: Skills Deployment Completion

**Description:** Deploy remaining 6 Seven Fortunas skills to seven-fortunas-brain repository

**Current State:**
- 4 skills deployed to seven-fortunas-brain (7f-sprint-dashboard, 7f-secrets-manager, 7f-dashboard-curator, team-communication)
- 6 skills exist locally in .claude/commands/7f/ but not deployed

**Requirements:**
- Copy 6 remaining skills from local to seven-fortunas-brain repo
- Update skills-registry.yaml to include new skills
- Test skill invocation (verify skill stubs reference correct paths)
- Commit and push to GitHub

**Acceptance Criteria:**
- All 10 Seven Fortunas skills present in seven-fortunas-brain/.claude/commands/
- skills-registry.yaml lists all 10 skills with descriptions
- Skills accessible via /7f-skill-name commands (verified by checking stub files)

**Verification:**
- MUST verify count: ls .claude/commands/7f*.md | wc -l == 10
- MUST verify registry: grep -c "7f-" .claude/commands/skills-registry.yaml == 10
- MUST verify GitHub: gh api repos/Seven-Fortunas-Internal/seven-fortunas-brain/contents/.claude/commands | jq '[.[] | select(.name | startswith("7f-"))] | length' == 10

**Deliverables:**
- 6 additional skill files in seven-fortunas-brain/.claude/commands/
- Updated .claude/commands/skills-registry.yaml
- Git commit to seven-fortunas-brain

**Dependencies:** None

**Constraints:**
- Skills must follow BMAD skill stub format
- Registry must be valid YAML

---

## Non-Functional Requirements

### Performance
- Dashboard page load: < 2 seconds (Largest Contentful Paint)
- GitHub Pages build: < 3 minutes after push
- Search results: < 1 second for CLI search

### Usability
- Mobile-first responsive design (320px minimum width)
- Accessible navigation (keyboard and screen reader friendly)
- Clear error messages for failed data sources

### Reliability
- GitHub Actions workflows: 95% success rate
- Pages deployment: Auto-retry on failure
- Graceful degradation: Show cached data if API fails

### Security
- No secrets in frontend code
- HTTPS only (GitHub Pages default)
- Content Security Policy headers

---

## Testing Strategy

### Four-Tier Testing (MANDATORY)

Every feature MUST pass all four test tiers before marking complete:

#### 1. Backend Test
Verify data layer, APIs, and automation work correctly.

**Example for FR-1:**
```bash
test -f dashboards/ai/data/cached_updates.json && echo "PASS: Data exists"
jq '.updates | length' dashboards/ai/data/cached_updates.json && echo "PASS: Valid JSON"
```

#### 2. Frontend Test
Verify UI exists and uses specified technologies.

**Example for FR-1:**
```bash
test -f dashboards/ai/package.json && echo "PASS: Package file exists"
grep -q '"react": "^18' dashboards/ai/package.json && echo "PASS: React 18.x"
test -f dashboards/ai/src/App.jsx && echo "PASS: React component exists"
cd dashboards/ai && npm ci && npm run build && echo "PASS: Build succeeds"
```

#### 3. Deployment Test
Verify feature accessible via public URL.

**Example for FR-1:**
```bash
# Wait for GitHub Pages build (up to 5 minutes)
for i in {1..10}; do
  if curl -I https://seven-fortunas.github.io/dashboards/ai/ 2>/dev/null | grep -q "200 OK"; then
    echo "PASS: Dashboard accessible"
    break
  fi
  echo "Waiting for Pages build... ($i/10)"
  sleep 30
done
```

#### 4. Technology Stack Test
Verify implementation uses technologies specified in tech stack.

**Example for FR-1:**
```bash
grep -q '"react": "^18' dashboards/ai/package.json && echo "PASS: React 18.x used"
grep -q '"vite":' dashboards/ai/package.json && echo "PASS: Vite build tool"
grep -q "@media.*768px" dashboards/ai/src/styles/dashboard.css && echo "PASS: Responsive design"
```

### Test Automation
- All tests MUST be automated (no manual browser testing required)
- Tests run via bash scripts
- Exit code 0 = pass, non-zero = fail

---

## Success Criteria

Phase 1.5 is complete when:

- ✅ All 5 features implemented and passing all 4 test tiers
- ✅ All dashboards accessible via public URLs (no 404 errors)
- ✅ GitHub Pages configured and working
- ✅ React 18.x used for AI dashboard (verified in package.json)
- ✅ Mobile-responsive design implemented (media queries present)
- ✅ Company website landing page deployed
- ✅ All skills deployed to seven-fortunas-brain
- ✅ Zero verification test failures
- ✅ All changes committed and pushed to GitHub
- ✅ Documentation updated (READMEs)

---

## Constraints

- Use React 18.x for dashboards (not plain HTML or markdown tables)
- GitHub Pages only (no external hosting)
- Free tier GitHub features only (no paid features)
- Mobile-first responsive design (minimum 320px width)
- All tests must be automated and pass

---

## Out of Scope (Phase 2)

- Additional dashboard UIs (fintech, edutech, security) - Phase 2
- Voice input integration - Phase 2
- Advanced search features (semantic search, AI-powered) - Phase 2
- Custom domain configuration - Phase 2
- Dashboard authentication/authorization - Phase 2

---

## Acceptance & Sign-off

**Product Owner:** Jorge (VP AI-SecOps)
**Stakeholders:** Founding team
**Target Completion:** 2026-02-19 (24 hours after Phase 1.5 start)

---

**Document Version:** 1.0
**Last Updated:** 2026-02-18
**Author:** Claude Sonnet 4.5 with Jorge
