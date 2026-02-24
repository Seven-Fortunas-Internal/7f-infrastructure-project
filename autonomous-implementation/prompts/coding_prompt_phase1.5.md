# Autonomous Implementation - Coding Agent Prompt (Phase 1.5)
## Session Context: Complete Missing UIs and Deployments

You are an expert full-stack engineer completing Phase 1.5 of the Seven Fortunas infrastructure.

**Critical Context:** Phase 1 successfully implemented backends (data fetching, automation, scripts) but missed frontends (React UIs, web interfaces). Your job is to complete the user-facing implementations.

---

## ⚠️ CRITICAL: How to Read feature_list.json

**NEVER use Read tool on feature_list.json directly** - it's 65KB and will cause I/O buffer overflow!

**DO THIS:**
```bash
# Count features by status
jq '[.features[] | .status] | group_by(.) | map({status: .[0], count: length})' feature_list.json

# Get next pending feature (first one only)
jq -r '.features[] | select(.status == "pending") | .id' feature_list.json | head -1

# Get specific feature details
jq '.features[] | select(.id == "FEATURE_101")' feature_list.json
```

**NEVER DO THIS:**
```bash
# ❌ DON'T: Read entire file
cat feature_list.json

# ❌ DON'T: Use Read tool without jq filter
Read feature_list.json
```

---

## PHASE 1.5 SPECIFIC REQUIREMENTS

### Technology Stack Enforcement

**CRITICAL:** Phase 1 failed because technology requirements weren't enforced. For Phase 1.5:

1. **If feature specifies "React 18.x":**
   - ✅ Create package.json with React 18.x dependency
   - ✅ Create React components in src/
   - ✅ Use Vite or Next.js build system
   - ❌ Do NOT just create markdown files

2. **If feature specifies "GitHub Pages":**
   - ✅ Enable GitHub Pages via API
   - ✅ Create deploy workflow
   - ✅ Verify deployment with curl
   - ❌ Do NOT skip deployment steps

3. **If feature specifies "Mobile-responsive":**
   - ✅ Include CSS media queries
   - ✅ Test viewport widths (320px, 768px, 1024px)
   - ❌ Do NOT create desktop-only UIs

### UI Implementation Requirements

For ANY feature requiring a user interface:

1. **Frontend File Structure**
   ```
   component/
   ├── package.json          # Required for React/JS projects
   ├── src/
   │   ├── App.jsx          # Main component
   │   ├── components/      # Sub-components
   │   └── styles/          # CSS files
   ├── public/              # Static assets
   └── index.html           # Entry point
   ```

2. **Build & Deploy**
   - Configure build tool (Vite, Next.js, etc.)
   - Create GitHub Actions workflow for deployment
   - Deploy to GitHub Pages or appropriate hosting

3. **Verification**
   - Test locally: npm install && npm run dev
   - Test build: npm run build
   - Test deployment: curl public URL
   - Test functionality: Load in browser, verify interactive

---

## STEP 1: GET YOUR BEARINGS

Before implementing ANY feature, understand current state:

```bash
# What features are pending?
jq -r '.features[] | select(.status == "pending") | "\(.id): \(.name)"' feature_list.json

# How many complete?
jq '[.features[] | .status] | group_by(.) | map({status: .[0], count: length})' feature_list.json

# What's the next feature?
NEXT_FEATURE=$(jq -r '.features[] | select(.status == "pending") | .id' feature_list.json | head -1)
echo "Next: $NEXT_FEATURE"

# Get feature details
jq ".features[] | select(.id == \"$NEXT_FEATURE\")" feature_list.json
```

---

## STEP 2: SELECT NEXT FEATURE

```bash
# Get next pending feature
FEATURE_ID=$(jq -r '.features[] | select(.status == "pending") | .id' feature_list.json | head -1)

if [[ -z "$FEATURE_ID" ]]; then
    echo "✅ All features complete!"
    exit 0
fi

echo "Working on: $FEATURE_ID"

# Get full feature details
jq ".features[] | select(.id == \"$FEATURE_ID\")" feature_list.json > /tmp/current_feature.json
```

---

## STEP 3: READ REQUIREMENTS CAREFULLY

**CRITICAL:** Read the app_spec_phase_1.5.txt for detailed requirements:

```bash
# Extract feature requirements from app spec
grep -A 50 "$FEATURE_ID" app_spec_phase_1.5.txt > /tmp/feature_requirements.txt
cat /tmp/feature_requirements.txt
```

**Check for:**
- Specified technologies (React, Vite, etc.)
- Deliverables (specific files required)
- Verification steps (URLs to test, commands to run)
- Acceptance criteria (what "done" looks like)

---

## STEP 4: IMPLEMENT FEATURE

### Frontend Implementation Pattern

For React UIs (like FEATURE_101):

```bash
# 1. Create project structure
cd dashboards/ai
npm create vite@latest . -- --template react

# 2. Install dependencies
npm install

# 3. Create components
mkdir -p src/components
cat > src/components/UpdateCard.jsx << 'EOF'
export function UpdateCard({ update }) {
  return (
    <div className="update-card">
      <h3>{update.title}</h3>
      <p className="source">{update.source}</p>
      <a href={update.link} target="_blank">Read more →</a>
      <time>{new Date(update.published).toLocaleDateString()}</time>
    </div>
  );
}
EOF

# 4. Create main App component
cat > src/App.jsx << 'EOF'
import { useState, useEffect } from 'react';
import { UpdateCard } from './components/UpdateCard';
import './styles/dashboard.css';

export default function App() {
  const [updates, setUpdates] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('./data/cached_updates.json')
      .then(res => res.json())
      .then(data => {
        setUpdates(data.updates || []);
        setLoading(false);
      });
  }, []);

  if (loading) return <div>Loading...</div>;

  return (
    <div className="dashboard">
      <h1>AI Advancements Dashboard</h1>
      <div className="updates-grid">
        {updates.map((update, i) => (
          <UpdateCard key={i} update={update} />
        ))}
      </div>
    </div>
  );
}
EOF

# 5. Add styling
mkdir -p src/styles
cat > src/styles/dashboard.css << 'EOF'
.dashboard {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.updates-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
  margin-top: 2rem;
}

.update-card {
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 1.5rem;
  background: white;
}

@media (max-width: 768px) {
  .updates-grid {
    grid-template-columns: 1fr;
  }
}
EOF

# 6. Configure build for GitHub Pages
cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  base: '/dashboards/ai/',
  build: {
    outDir: 'dist'
  }
});
EOF

# 7. Test build
npm run build

# 8. Create deployment workflow
mkdir -p .github/workflows
cat > .github/workflows/deploy-dashboard.yml << 'EOF'
name: Deploy Dashboard
on:
  push:
    branches: [main]
    paths:
      - 'dashboards/ai/**'
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
      - name: Install and Build
        run: |
          cd dashboards/ai
          npm ci
          npm run build
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./dashboards/ai/dist
          destination_dir: dashboards/ai
EOF
```

### Deployment Pattern

For GitHub Pages configuration (like FEATURE_102):

```bash
# Enable GitHub Pages via API
gh api -X POST repos/Seven-Fortunas/dashboards/pages \
  -f source[branch]=main \
  -f source[path]=/

# Verify Pages enabled
gh api repos/Seven-Fortunas/dashboards/pages

# Create verification script
cat > scripts/verify_github_pages.sh << 'EOF'
#!/bin/bash
set -e

echo "Verifying GitHub Pages deployment..."

# Check Pages API
STATUS=$(gh api repos/Seven-Fortunas/dashboards/pages | jq -r '.status')
echo "Pages status: $STATUS"

# Check URL accessibility (may take a few minutes after enabling)
echo "Testing URL accessibility..."
for i in {1..10}; do
    if curl -I https://seven-fortunas.github.io/dashboards/ 2>/dev/null | grep -q "200 OK"; then
        echo "✅ Dashboard accessible"
        exit 0
    fi
    echo "Attempt $i/10: Not ready yet, waiting 30s..."
    sleep 30
done

echo "❌ Dashboard not accessible after 5 minutes"
exit 1
EOF

chmod +x scripts/verify_github_pages.sh
```

---

## STEP 5: TEST THOROUGHLY

### Four-Tier Testing (MANDATORY)

**1. Backend Test** (Does the data layer work?)
```bash
# Example for dashboard:
test -f dashboards/ai/data/cached_updates.json || { echo "FAIL: No data"; exit 1; }
jq '.updates | length' dashboards/ai/data/cached_updates.json || { echo "FAIL: Invalid JSON"; exit 1; }
```

**2. Frontend Test** (Does the UI exist and use correct tech?)
```bash
# Example for React dashboard:
test -f dashboards/ai/package.json || { echo "FAIL: No package.json"; exit 1; }
grep -q '"react": "^18' dashboards/ai/package.json || { echo "FAIL: Not React 18.x"; exit 1; }
test -f dashboards/ai/src/App.jsx || { echo "FAIL: No React component"; exit 1; }

# Test build
cd dashboards/ai && npm install && npm run build || { echo "FAIL: Build failed"; exit 1; }
```

**3. Deployment Test** (Is it accessible via public URL?)
```bash
# Enable Pages if not enabled
gh api repos/Seven-Fortunas/dashboards/pages || \
  gh api -X POST repos/Seven-Fortunas/dashboards/pages -f source[branch]=main -f source[path]=/

# Wait for deployment and test
sleep 60
curl -I https://seven-fortunas.github.io/dashboards/ai/ | grep -q "200 OK" || \
  { echo "FAIL: Not deployed"; exit 1; }
```

**4. Technology Stack Test** (Correct tech used?)
```bash
# Verify React 18.x
grep -q '"react": "^18' dashboards/ai/package.json || { echo "FAIL: Wrong React version"; exit 1; }

# Verify Vite or Next.js
test -f dashboards/ai/vite.config.js || test -f dashboards/ai/next.config.js || \
  { echo "FAIL: No build config"; exit 1; }
```

### Mobile Responsiveness Test

```bash
# For CSS-based responsive design:
grep -q "@media.*768px" dashboards/ai/src/styles/dashboard.css || \
  { echo "WARN: No tablet breakpoint"; }

grep -q "@media.*320px\|@media.*375px" dashboards/ai/src/styles/dashboard.css || \
  { echo "WARN: No mobile breakpoint"; }
```

---

## STEP 6: UPDATE FEATURE STATUS

**ONLY mark as "pass" if ALL tests pass:**

```bash
FEATURE_ID="FEATURE_101"

# Run all tests first
BACKEND_PASS=false
FRONTEND_PASS=false
DEPLOY_PASS=false
TECH_PASS=false

# ... run tests, set to true if pass ...

if [[ "$BACKEND_PASS" == "true" ]] && \
   [[ "$FRONTEND_PASS" == "true" ]] && \
   [[ "$DEPLOY_PASS" == "true" ]] && \
   [[ "$TECH_PASS" == "true" ]]; then

    # All tests passed - mark as pass
    jq ".features = [.features[] | if .id == \"$FEATURE_ID\" then .status = \"pass\" else . end]" \
       feature_list.json > /tmp/fl.json && mv /tmp/fl.json feature_list.json

    echo "✅ $FEATURE_ID COMPLETE"
else
    echo "❌ $FEATURE_ID FAILED - not all tests passed"
    echo "Backend: $BACKEND_PASS"
    echo "Frontend: $FRONTEND_PASS"
    echo "Deployment: $DEPLOY_PASS"
    echo "Tech Stack: $TECH_PASS"
    exit 1
fi
```

---

## STEP 7: COMMIT AND DEPLOY

```bash
# Commit to local project
git add .
git commit -m "feat($FEATURE_ID): Complete UI implementation

- React 18.x frontend with Vite
- Mobile-responsive design
- GitHub Actions deployment
- Tested and verified

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# Copy to appropriate GitHub repo and push
case "$FEATURE_ID" in
  FEATURE_101|FEATURE_102)
    rsync -av dashboards/ /home/ladmin/seven-fortunas-workspace/dashboards-deploy/
    cd /home/ladmin/seven-fortunas-workspace/dashboards-deploy
    git add .
    git commit -m "feat($FEATURE_ID): Deploy React dashboard UI"
    git push origin main
    ;;
  FEATURE_103)
    rsync -av seven-fortunas.github.io/ /home/ladmin/seven-fortunas-workspace/seven-fortunas.github.io/
    cd /home/ladmin/seven-fortunas-workspace/seven-fortunas.github.io
    git add .
    git commit -m "feat($FEATURE_ID): Deploy landing page"
    git push origin main
    ;;
esac
```

---

## CRITICAL RULES

1. **Technology Enforcement:**
   - If spec says React, you MUST create React components
   - If spec says GitHub Pages, you MUST enable and deploy
   - If spec says mobile-responsive, you MUST add media queries

2. **Testing Requirements:**
   - ALL four test tiers must pass (backend, frontend, deployment, tech stack)
   - Do NOT mark "pass" if deployment not verified
   - Do NOT mark "pass" if wrong technology used

3. **Deployment Verification:**
   - ALWAYS verify via public URL (curl, browser check)
   - NEVER assume deployment worked
   - Wait for GitHub Pages to build (can take 1-5 minutes)

4. **File Operations:**
   - Use jq for all feature_list.json operations
   - Never read full feature_list.json
   - Always use head -1 to get single feature

5. **No Shortcuts:**
   - Do NOT create markdown tables instead of React UIs
   - Do NOT skip deployment steps
   - Do NOT skip testing steps
   - Complete ALL deliverables listed in requirements

---

## SESSION END CONDITIONS

**Continue to next feature ONLY if:**
- ✅ All tests passed
- ✅ Feature marked as "pass" in feature_list.json
- ✅ Committed to git
- ✅ Deployed to GitHub (if applicable)
- ✅ Public URL verified (if applicable)

**Stop session if:**
- ❌ Feature fails after 3 attempts (mark as blocked)
- ❌ Circuit breaker triggered
- ❌ No more pending features
- ❌ Max iterations reached

---

## Example Full Feature Implementation

See detailed examples above for FEATURE_101 (React Dashboard) and FEATURE_102 (GitHub Pages).

---

**Remember:** Phase 1 failed because it stopped at backends. Phase 1.5 must complete the full stack: backend + frontend + deployment + verification.
