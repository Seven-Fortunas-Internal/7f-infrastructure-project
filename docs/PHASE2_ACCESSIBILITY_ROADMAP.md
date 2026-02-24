# Phase 2 Accessibility Improvements - Roadmap

**Status:** Planning
**Priority:** P3
**Target Date:** Post-Phase 1 Completion

## Overview

Phase 2 will expand accessibility of the Seven Fortunas infrastructure beyond CLI-only workflows, enabling broader team participation and reducing technical barriers.

---

## Objectives

1. **Reduce CLI dependency** - Enable non-technical users to contribute
2. **Improve mobile access** - Allow team members to monitor progress on mobile devices
3. **Enable remote development** - Support cloud-based development environments
4. **Enhance dashboard usability** - Make data visualizations accessible and responsive

---

## Target Improvements

### 1. GitHub Codespaces Integration

**Current State:**
- Development requires local clone + CLI tools (gh, git, jq, Claude CLI)
- Barriers: Installation complexity, environment setup, CLI expertise required

**Phase 2 Target:**
- One-click Codespaces environment with pre-installed tools
- Pre-configured devcontainer.json with all dependencies
- Browser-based development (no local setup required)
- Visual Studio Code web interface for non-CLI users

**Implementation Tasks:**
- [ ] Create `.devcontainer/devcontainer.json` with all required tools
- [ ] Add postCreateCommand to auto-configure environment
- [ ] Test Codespaces launch from github.com (single-click access)
- [ ] Document Codespaces workflow for non-technical team members
- [ ] Configure secrets injection (ANTHROPIC_API_KEY, GH_TOKEN)

**Success Criteria:**
- New team member can start contributing within 5 minutes
- No local installation required
- All BMAD skills work in Codespaces environment

---

### 2. Web-Based Alternatives

**Current State:**
- Second Brain requires CLI navigation (cd, ls, cat, grep)
- Dashboard updates require running shell scripts
- No GUI for skill invocation

**Phase 2 Target:**
- Web UI for Second Brain browsing/search
- Dashboard auto-refresh (no manual trigger)
- Skill launcher GUI (select skill → fill form → run)

**Implementation Tasks:**
- [ ] Build Second Brain web viewer (Next.js + search)
- [ ] Create dashboard admin panel (Vite + React)
- [ ] Develop skill launcher web app (form-based skill invocation)
- [ ] Add authentication (GitHub OAuth)
- [ ] Deploy to GitHub Pages or Vercel

**Success Criteria:**
- Non-CLI users can browse Second Brain via web browser
- Dashboards update automatically (no manual intervention)
- Skills can be invoked through web forms

---

### 3. Mobile-Responsive Dashboards

**Current State:**
- Dashboards are desktop-only (fixed-width layouts)
- Charts don't scale on mobile screens
- No mobile testing performed

**Phase 2 Target:**
- All dashboards render correctly on mobile (320px - 768px widths)
- Charts responsive (Recharts responsive containers)
- Touch-friendly navigation (hamburger menus, large tap targets)

**Implementation Tasks:**
- [ ] Audit all 7 dashboards for mobile responsiveness
- [ ] Add CSS media queries (@media max-width: 768px)
- [ ] Replace fixed widths with flexbox/grid
- [ ] Test on real devices (iOS Safari, Android Chrome)
- [ ] Add mobile navigation patterns (collapsible sidebar)
- [ ] Optimize chart rendering for small screens

**Success Criteria:**
- All dashboards render correctly on iPhone SE (375px width)
- No horizontal scrolling required
- Touch targets ≥ 44px (Apple Human Interface Guidelines)
- Dashboard load time < 3s on 3G connection

---

## Measurement & Validation

### User Feedback Channels

**Quantitative Metrics:**
- GitHub Codespaces usage count (GitHub Insights)
- Dashboard mobile traffic percentage (Plausible Analytics)
- Skill launcher web app usage vs CLI usage
- New contributor time-to-first-contribution

**Qualitative Feedback:**
- User interviews (non-technical team members)
- GitHub Discussions feedback threads
- Support ticket analysis (accessibility-related issues)

**Targets:**
- ≥ 30% of team uses Codespaces (vs local development)
- ≥ 20% of dashboard traffic from mobile devices
- Time-to-first-contribution < 1 hour (vs current 4+ hours)
- ≥ 80% user satisfaction score (accessibility survey)

---

## Dependencies

**Prerequisite:**
- Phase 1 complete (all core infrastructure functional)

**External Dependencies:**
- GitHub Codespaces enabled on org (free for public repos)
- Vercel/GitHub Pages for web app hosting
- Claude API quota (for skill launcher)

**Blockers:**
- None identified (all improvements are additive)

---

## Timeline Estimate

**Total Duration:** 6-8 weeks

| Milestone | Duration | Deliverables |
|-----------|----------|--------------|
| Codespaces Setup | 1 week | devcontainer.json, documentation |
| Second Brain Web Viewer | 2 weeks | Search UI, markdown rendering |
| Dashboard Responsiveness | 2 weeks | Mobile CSS, chart optimization |
| Skill Launcher UI | 2 weeks | Form builder, skill execution |
| Testing & Refinement | 1 week | Mobile testing, user feedback |

---

## Success Criteria (Overall)

**Phase 2 is complete when:**

1. ✅ GitHub Codespaces one-click launch works
2. ✅ Second Brain has web-based search interface
3. ✅ All dashboards are mobile-responsive (tested on 3 devices)
4. ✅ Skill launcher web app deployed and functional
5. ✅ ≥ 3 non-CLI users successfully contribute
6. ✅ User satisfaction ≥ 80% (post-implementation survey)

---

**Document Version:** 1.0
**Last Updated:** 2026-02-24
**Owner:** Jorge (VP AI-SecOps)
**Status:** Planning (Not Started)
