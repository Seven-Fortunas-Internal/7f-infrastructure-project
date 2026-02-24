# Debugging & Troubleshooting Guide - Seven Fortunas Infrastructure

**Version:** 1.0
**Last Updated:** 2026-02-24
**Priority:** P1 (Critical)
**Target MTTR:** < 30 minutes for common issues

---

## Quick Reference

| Issue | Symptom | Quick Fix | MTTR Target |
|-------|---------|-----------|-------------|
| [GitHub Auth Failed](#1-github-authentication-failure) | `gh` commands return 401 | `gh auth login` | 5 min |
| [Workflow Failed](#2-github-actions-workflow-failure) | Workflow run shows red X | Check logs, re-run | 10 min |
| [API Rate Limit](#3-api-rate-limit-exceeded) | HTTP 403 responses | Wait 1 hour or optimize | 15 min |
| [Dashboard Not Updating](#4-dashboard-not-updating) | Stale data on live site | Trigger workflow manually | 10 min |
| [Build Failed](#5-build-failure-vite-react) | Build error in CI/CD | Check dependencies, rebuild | 20 min |
| [Agent Stuck/Blocked](#6-autonomous-agent-stuck) | Feature attempts = 3 | Review logs, mark skip | 15 min |
| [Secret Scanning Alert](#7-secret-exposed) | GitHub security alert | Revoke secret, rotate | 30 min |

---

## Common Issues & Solutions

### 1. GitHub Authentication Failure

**Symptoms:**
- `gh` commands return "HTTP 401: Unauthorized"
- API calls fail with authentication error
- Workflows fail with permission denied

**Root Cause:**
- GitHub token expired
- Token not configured
- Insufficient token permissions

**Diagnosis:**
```bash
# Check current auth status
gh auth status

# Expected output if working:
# ✓ Logged in to github.com as <username> (<token>)
# ✓ Token: gho_****
```

**Solution:**
```bash
# Re-authenticate
gh auth login

# Select options:
# - GitHub.com
# - HTTPS
# - Authenticate with browser

# Verify fix
gh auth status
gh api user
```

**Prevention:**
- Use GitHub Apps with auto-refresh tokens
- Set token expiration reminders
- Store backup tokens securely

**MTTR Target:** 5 minutes

---

### 2. GitHub Actions Workflow Failure

**Symptoms:**
- Workflow run shows red X (failed)
- Email notification of failure
- Metrics show success rate < 95%

**Root Cause:**
- Code bug
- Dependency issue
- API rate limit
- Infrastructure outage

**Diagnosis:**
```bash
# List recent workflow runs
gh run list --limit 10

# View specific failed run
gh run view <run-id>

# Download logs for analysis
gh run download <run-id> --name logs
```

**Solution - Generic:**
```bash
# 1. Check logs for error message
gh run view <run-id> --log-failed

# 2. Identify failure step
# Look for "Error:" or "FAILED" in output

# 3. Fix issue (varies by error)
# - Code fix: Create PR, merge, re-run
# - Dependency: Update package.json/requirements.txt
# - Rate limit: Wait or optimize
# - Infrastructure: Check GitHub Status

# 4. Re-run workflow
gh run rerun <run-id>
```

**Solution - Specific Errors:**

**Error: "npm ERR! 404 Not Found"**
```bash
# Dependency not found - check package.json
npm install  # Verify locally
# Fix package name/version, commit, push
```

**Error: "HTTP 429: Rate limit exceeded"**
```bash
# See section 3: API Rate Limit Exceeded
```

**Error: "Build failed - exit code 1"**
```bash
# See section 5: Build Failure (Vite/React)
```

**Prevention:**
- Run tests locally before push
- Use branch protection (require CI pass)
- Monitor workflow success metrics
- Set up pre-commit hooks

**MTTR Target:** 10 minutes

---

### 3. API Rate Limit Exceeded

**Symptoms:**
- HTTP 403 responses from GitHub API
- Workflow fails with "API rate limit exceeded"
- `gh` commands return rate limit error

**Root Cause:**
- Too many API calls in 1 hour window
- Multiple workflows running concurrently
- Dashboard update fetching too frequently

**Diagnosis:**
```bash
# Check current rate limit status
gh api rate_limit

# Output shows:
# - limit: 5000 (or 1000 for unauthenticated)
# - remaining: <count>
# - reset: <timestamp>

# Calculate time until reset
RESET=$(gh api rate_limit --jq '.rate.reset')
echo "Rate limit resets at: $(date -d @$RESET)"
```

**Solution - Immediate:**
```bash
# Option 1: Wait for reset (up to 1 hour)
RESET=$(gh api rate_limit --jq '.rate.reset')
WAIT=$((RESET - $(date +%s)))
echo "Wait $WAIT seconds ($((WAIT/60)) minutes)"

# Option 2: Pause non-critical workflows
gh workflow disable <workflow-name>

# Option 3: Use authenticated requests (higher limit)
# Ensure GITHUB_TOKEN is set in workflows
```

**Solution - Long-term:**
```bash
# 1. Add caching to reduce API calls
# 2. Implement exponential backoff
# 3. Use GraphQL instead of REST (fewer calls)
# 4. Reduce workflow frequency (e.g., 6h instead of 1h)
```

**Prevention:**
- Monitor rate limit usage (see metrics workflow)
- Add rate limit checks before API calls
- Cache responses where possible
- Use conditional requests (If-Modified-Since)

**MTTR Target:** 15 minutes

---

### 4. Dashboard Not Updating

**Symptoms:**
- Dashboard shows stale data (>24h old)
- Last updated timestamp not changing
- Data sources not refreshing

**Root Cause:**
- Workflow not running (disabled or failed)
- Deployment not triggering
- Data source unavailable

**Diagnosis:**
```bash
# Check dashboard workflow status
gh run list --workflow=update-dashboards.yml --limit 5

# Check last successful run
gh run list --workflow=update-dashboards.yml --status=success --limit 1

# Check if workflow is enabled
gh workflow view update-dashboards.yml

# Check GitHub Pages deployment
gh api repos/Seven-Fortunas/dashboards/pages
```

**Solution:**
```bash
# 1. Manually trigger dashboard update
gh workflow run update-dashboards.yml

# 2. Wait for completion (usually 2-5 minutes)
sleep 60
gh run list --workflow=update-dashboards.yml --limit 1

# 3. Verify deployment
# Visit https://seven-fortunas.github.io/dashboards/ai-advancements

# 4. If still stale, check data source availability
curl -I https://github.com/anthropics/anthropic-sdk-python/releases.atom
# Should return HTTP 200

# 5. Check GitHub Pages settings
gh api repos/Seven-Fortunas/dashboards/pages --jq '.status'
# Should return "built"
```

**Prevention:**
- Monitor dashboard freshness (metrics workflow)
- Set up alerts for >48h stale data
- Add health checks to workflows
- Document data source dependencies

**MTTR Target:** 10 minutes

---

### 5. Build Failure (Vite/React)

**Symptoms:**
- `npm run build` fails
- Vite build error
- Missing dependencies
- Type errors

**Root Cause:**
- Dependency mismatch
- TypeScript errors
- Missing environment variables
- Incorrect build configuration

**Diagnosis:**
```bash
# Run build locally to see full error
npm run build

# Common errors:
# - "Cannot find module 'X'" → Missing dependency
# - "Type error: ..." → TypeScript issue
# - "Failed to resolve entry" → Wrong path in vite.config.js
```

**Solution - Missing Dependency:**
```bash
# Install missing package
npm install <package-name>

# Update package.json and commit
git add package.json package-lock.json
git commit -m "fix: add missing dependency"
git push
```

**Solution - TypeScript Error:**
```bash
# Fix type errors in code
# Or add type assertion as temporary fix
# @ts-ignore (use sparingly!)

# Rebuild
npm run build
```

**Solution - Vite Config Issue:**
```bash
# Check vite.config.js
# Common issues:
# - Wrong base path for GitHub Pages
# - Missing plugins
# - Incorrect build output directory

# Example fix for GitHub Pages subdirectory:
# vite.config.js
export default {
  base: '/dashboards/',  # Must match repo name
  build: {
    outDir: 'dist'
  }
}
```

**Prevention:**
- Run `npm run build` before committing
- Use TypeScript strict mode
- Set up pre-commit hooks (lint, type-check, build)
- Pin dependency versions

**MTTR Target:** 20 minutes

---

### 6. Autonomous Agent Stuck/Blocked

**Symptoms:**
- Feature `attempts >= 3`
- Feature status = "fail" or "blocked"
- No progress for multiple iterations

**Root Cause:**
- External dependency unavailable
- Impossible requirement
- Bug in implementation logic
- Missing permissions

**Diagnosis:**
```bash
# Check feature status
jq '.features[] | select(.status == "blocked" or .status == "fail")' feature_list.json

# Review specific feature
jq '.features[] | select(.id == "FEATURE_XXX")' feature_list.json

# Check autonomous build log
tail -100 autonomous_build_log.md | grep "FEATURE_XXX"

# Review error messages
grep -A 10 "FEATURE_XXX" issues.log
```

**Solution - External Dependency:**
```bash
# Mark as blocked with clear reason
# Human intervention required

# Update feature_list.json manually or via script
# Set implementation_notes to explain blocker

# Example: API requires paid account, waiting for approval
```

**Solution - Impossible Requirement:**
```bash
# Simplify requirement
# Update app_spec.txt with MINIMAL approach
# Re-run agent on that feature
```

**Solution - Missing Permissions:**
```bash
# Grant required permissions
# Example: GitHub token needs workflow write access

# Update token scopes
gh auth refresh -s workflow

# Re-run agent
```

**Prevention:**
- Define clear success criteria
- Identify external dependencies upfront
- Set realistic bounded retry limits (3 attempts)
- Document blockers immediately

**MTTR Target:** 15 minutes

---

### 7. Secret Exposed (Security Incident)

**Symptoms:**
- GitHub secret scanning alert
- Security notification email
- Red banner on repository page

**Root Cause:**
- Secret committed to git history
- Secret in public file (.env committed)
- Secret in logs/screenshots

**Diagnosis:**
```bash
# Check security alerts
gh api /repos/Seven-Fortunas/7F_github/secret-scanning/alerts

# Find commit that exposed secret
gh api /repos/Seven-Fortunas/7F_github/secret-scanning/alerts/<alert-id> \
  --jq '.locations[].details.path'
```

**Solution - CRITICAL (Do within 30 minutes):**
```bash
# 1. REVOKE the exposed secret IMMEDIATELY
# For GitHub token:
gh auth refresh  # This invalidates old token

# For API keys:
# - Log into service provider
# - Revoke/delete compromised key
# - Generate new key

# 2. Rotate all related credentials
# Update secrets in GitHub Actions
gh secret set ANTHROPIC_API_KEY < new_key.txt

# 3. Remove secret from git history (if in public repo)
# Use BFG Repo Cleaner or git filter-branch
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch <file-with-secret>" \
  --prune-empty --tag-name-filter cat -- --all

# 4. Force push (DANGER: coordinate with team)
git push --force --all

# 5. Verify secret is gone
gh api /repos/Seven-Fortunas/7F_github/secret-scanning/alerts/<alert-id>

# 6. Close alert once verified
gh api /repos/Seven-Fortunas/7F_github/secret-scanning/alerts/<alert-id> \
  -X PATCH -f state=resolved -f resolution=revoked
```

**Prevention:**
- Never commit .env files (add to .gitignore)
- Use GitHub Actions secrets (never hardcode)
- Enable secret scanning
- Use pre-commit hooks (detect-secrets)
- Regularly audit commits for secrets

**MTTR Target:** 30 minutes (CRITICAL)

---

## Debugging Tools & Commands

### Log Analysis

```bash
# View recent workflow logs
gh run list --limit 10
gh run view <run-id> --log

# Download logs locally
gh run download <run-id>

# Search logs for errors
gh run view <run-id> --log | grep -i "error\|fail\|exception"

# View structured logs (if using structured_logger.py)
cat logs/workflow.jsonl | jq 'select(.severity == "ERROR")'
```

### API Debugging

```bash
# Test API endpoint
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/Seven-Fortunas/7F_github

# Check response headers
curl -I -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/Seven-Fortunas/7F_github

# Verbose output
curl -v -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/Seven-Fortunas/7F_github
```

### Workflow Debugging

```bash
# List all workflows
gh workflow list

# View workflow definition
gh workflow view <workflow-name>

# Run workflow with specific inputs
gh workflow run <workflow-name> -f input1=value1

# Watch workflow run in real-time
gh run watch <run-id>
```

### Dashboard Debugging

```bash
# Check if site is live
curl -I https://seven-fortunas.github.io/dashboards/

# Check asset loading
curl -I https://seven-fortunas.github.io/dashboards/assets/index.js

# Validate JSON data
curl https://seven-fortunas.github.io/dashboards/data/ai-advancements.json | jq .

# Check build output
cd autonomous-implementation/dashboards
npm run build
ls -lh dist/
```

---

## MTTR Tracking

Track Mean Time To Resolution for each issue category:

```bash
# Log incident
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ),<issue-type>,started" >> incidents.log

# Log resolution
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ),<issue-type>,resolved" >> incidents.log

# Calculate MTTR
# (Add to metrics collection workflow)
```

**Example incidents.log:**
```
2026-02-24T14:00:00Z,auth-failure,started
2026-02-24T14:03:00Z,auth-failure,resolved
2026-02-24T15:30:00Z,workflow-failure,started
2026-02-24T15:42:00Z,workflow-failure,resolved
```

---

## Escalation Path

| Issue Severity | Response Time | Escalate To | Escalate After |
|----------------|---------------|-------------|----------------|
| P0 (Critical) | < 30 min | Team Lead | 1 hour |
| P1 (High) | < 2 hours | Team Lead | 4 hours |
| P2 (Medium) | < 8 hours | Team | 24 hours |
| P3 (Low) | < 48 hours | Team | 1 week |

**Critical (P0) Issues:**
- Production outage
- Security breach
- Data loss

**High (P1) Issues:**
- Workflow failures >5%
- API rate limit exceeded
- Dashboard offline >48h

---

## Success Criteria

NFR-8.3 is satisfied when:

1. ✅ Debugging guide exists with common issues
2. ✅ MTTR targets defined for each issue type
3. ✅ Quick reference table available
4. ✅ Debugging commands documented
5. ✅ Escalation path defined

**Target:** MTTR < 30 minutes for common issues

---

**Owner:** Jorge (VP AI-SecOps)
**Review Date:** 2026-03-24 (monthly review)
