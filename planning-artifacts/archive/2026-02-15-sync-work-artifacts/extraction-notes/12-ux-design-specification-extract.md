# Extract: UX Design Specification

**Source:** `ux-design-specification.md`
**Date:** **2026-02-14** (Created AFTER all other planning docs)
**Size:** 2252 lines (77KB)
**Author:** Sally (UX Designer) with Jorge

---

## Document Metadata
- **Purpose:** Comprehensive UX design for AI-native infrastructure (dual-audience: humans + AI)
- **Format:** Detailed interaction design, user journeys, component patterns, wireframes
- **Status:** In-progress
- **CRITICAL:** Created Feb 14 AFTER Product Brief, Architecture, PRD, Action Plan (Feb 10-13)

---

## Key Content Summary

### Executive Summary (Lines 25-38)
**Core Innovation:** AI-native enterprise nervous system designed FROM INCEPTION for AI collaboration

**Primary Users:** 4 founding team members with detailed personas
**Key Challenges:** Dual-audience design, voice-enabled creation, progressive disclosure at scale, self-service operations, real-time intelligence

**Success Metrics:** Henry shapes ethos in 30 min, Patrick validates in 2 hours, Buck trusts security in 1 hour, Jorge enables 60-70% autonomous, new members onboard in 1-2 days

---

### UX Design Assumptions FOR JORGE'S REVIEW (Lines 42-71)
**5 assumptions requiring validation:**

**Assumption 1: Mobile Experience Deferred to Phase 2**
- Desktop-first (laptop/workstation), mobile-responsive but not mobile-optimized
- **Validation needed:** Is anyone working primarily from mobile?

**Assumption 2: Voice Input Optional for Everyone**
- Henry will use most frequently, but available to all founders
- Typing is default, voice is optional enhancement
- **Validation needed:** Confirm typing-first, voice-optional meets all needs

**Assumption 3: Dashboard Read-Only MVP**
- Informational only, no interactive filtering/drill-down
- **Validation needed:** Does leadership need interactive exploration in MVP?

**Assumption 4: Second Brain Uses Obsidian Optional**
- Markdown-first, Obsidian-compatible but not required
- **Validation needed:** Is team standardizing on Obsidian?

**Assumption 5: AI Agent Personas Not User Personas**
- AI agents treated as "technical users" (data structure design)
- **Validation needed:** Should we create AI agent personas/journey maps?

---

### User Personas (Lines 73-108) 🔥 ROLE CLARIFICATIONS

**Henry (CEO) - The Visionary Leader**
- Strategic direction, fundraising, brand steward
- **Aha Moment:** "AI permeates everywhere"
- Primary needs: Brand generation, investor materials, voice input
- Devices: MacBook Pro, iPhone

**Patrick (CTO) - The Quality Guardian**
- Technical architecture, infrastructure validation, engineering excellence
- **Aha Moment:** "SW development infrastructure is well done"
- Primary needs: Architecture docs, code review, security validation
- Devices: Linux workstation, MacBook Pro, Terminal-first

**Buck (VP Engineering) - The Security Watchdog** ⚠️ EXPANDED ROLE
- **Role:** Engineering projects, apps, backend infrastructure, token management, application security, code review, test infrastructure, compliance
- **Aha Moment:** "Security on autopilot"
- Primary needs: Automated security controls, engineering project delivery
- Devices: Linux workstation

**Jorge (VP AI-SecOps) - The AI & Security Infrastructure Architect** 🔥 CLEAR DELINEATION
- **Role:** AI infrastructure, security domain expert, DevOps automation, autonomous agent orchestration, skill creation, team enablement
- **Aha Moment:** "Implementation working with minimal issues"
- Primary needs: Autonomous agent infra, security standards, compliance tooling
- Devices: Linux workstation, Claude Code, Bash scripts

**CRITICAL FINDING:** UX spec (Feb 14) significantly expands Buck's role beyond security to include:
- Engineering projects (NEW)
- Apps and backend infrastructure (NEW)
- Token management (NEW)
- Code review and test infrastructure (NEW)
- Compliance (NEW - but Jorge clarified this should be Jorge's)

**Jorge's Clarification:**
- **Buck = VP Engineering:** Product development, engineering projects, apps, backend
- **Jorge = VP AI-SecOps:** AI infrastructure + Security Operations (SecOps) + Compliance

---

### Core User Experience (Lines 123-149)
**Three fundamental UX flows:**

**1. Knowledge Creation & Management (Second Brain)**
- Speak/write → AI structures → Human refines → Team finds instantly
- Voice input → Transcription → AI structuring → Progressive disclosure

**2. Infrastructure Operations (GitHub + BMAD Skills)**
- Describe need → AI configures → System validates → Audit trail
- Natural language intent → Skill execution → Approval (if needed) → Automated setup

**3. Intelligence Gathering (7F Lens Dashboards)**
- Open dashboard → Latest trends → AI summary → Actionable insights
- Automated collection → AI summarization → Structured markdown → Weekly review

---

### Platform Strategy (Lines 151-186)
**Primary Platform: Desktop-First, Terminal-Friendly**

**Device Distribution:**
- 70% Linux workstations + MacBook Pro (technical workflows)
- 20% Mobile (content review, Slack, email)
- 10% Tablets/other

**Interface Strategy:**
- Second Brain: Markdown + Obsidian/VS Code (platform-agnostic)
- BMAD Skills: Claude Code CLI (conversational, terminal)
- Dashboards: GitHub Pages (web, mobile-responsive markdown)
- Voice Input: OpenAI Whisper (MacOS native, Linux CLI)

---

### Effortless Interactions (Lines 188-239)

**Interaction 1: Finding Information (<30 seconds)**
- README at every directory level
- YAML frontmatter filtering
- AI-powered search
- Three-level hierarchy (never >3 clicks deep)

**Interaction 2: Creating Infrastructure (2 minutes)**
- Natural language skill invocation
- Intelligent defaults (security pre-configured)
- Context-aware suggestions
- Approval workflow for risky operations

**Interaction 3: Voice Content Creation (10 minutes)**
- Single command to start
- Real-time feedback
- AI auto-structuring (extract key points, add headings)
- Human refinement loop (20% editing)

**Interaction 4: Staying Informed (5 minutes dashboard review)**
- Auto-update every 6 hours
- AI-generated weekly summary
- Structured markdown (scannable)
- Graceful degradation

**Interaction 5: Onboarding New Team Members (1-2 days)**
- Single onboarding README
- User profile via skill
- AI agent personalized guidance
- Pre-configured access

---

### Critical Success Moments (Lines 241-273)

**Success Moment 1: Henry's Brand Creation (30 Minutes)**
- Voice input → AI structuring → 20% refinement → Polished brand docs
- Make-or-break: If voice transcription bad, Henry wastes 6 hours typing

**Success Moment 2: Patrick's Infrastructure Validation (2 Hours)**
- GitHub CLI → Architecture docs (ADRs) → Security validation → Code review skill
- Make-or-break: If quality poor, Patrick loses confidence

**Success Moment 3: Buck's Security Testing (1 Hour)** 🔥 SECURITY FOCUS
- Pre-commit blocks → GitHub Actions catches bypass → Secret scanning alerts
- Make-or-break: If one test passes, Buck manually reviews every commit
- **Note:** Buck's journey is SECURITY TESTING, not engineering delivery

**Success Moment 4: Jorge's Autonomous Agent Launch (Days 1-2)**
- Feature tracking → Bounded retries → Test-before-commit → 60-70% completion
- Make-or-break: If agent stuck/broken, Jorge spends more time debugging

---

### Experience Principles (Lines 275-308)

**Principle 1: Voice-Enabled for Creators, Terminal-First for Builders**
- Henry thinks by speaking, Patrick/Buck/Jorge think in terminal commands

**Principle 2: Progressive Disclosure for Humans, Structured Data for AI**
- YAML frontmatter (machine) + Markdown body (human) + README (both)

**Principle 3: Conversational Infrastructure, Not Memorized Commands**
- Natural language BMAD skills vs CLI syntax memorization

**Principle 4: Trust but Verify, Not Block and Review**
- Risk-based approval (Pattern A: approve-then-execute; Pattern B: execute-then-review)

**Principle 5: Make the Infrastructure the Demo**
- Transparent progress tracking, decision logging, "making of" documentation

**Principle 6: Optimize for Team Scale (4 → 50), Not Individual Efficiency**
- Self-service patterns, documented processes, automated onboarding

---

### User Journeys - Detailed Interaction Design (Lines 649-1086)

**Journey 1: Henry Creates Brand Documentation (30 Minutes)**
- Terminal: `/7f-brand-system-generator`
- Voice-enabled dialogue: Henry speaks, AI structures
- Progressive refinement: AI extracts key points
- Auto-saves to Second Brain
- **Time:** 30 min vs 6 weeks with consultant

**Journey 2: Patrick Validates Infrastructure Quality (2 Hours)**
- GitHub CLI exploration: Check org structure, security settings
- Architecture docs review: Read ADRs, see decision rationale
- Code review skill test: AI references ADRs, catches race condition
- **Patrick's reaction:** "AI isn't just syntax checking"

**Journey 3: Buck Tests Security Controls (1 Hour)** 🔥 SECURITY FOCUS
- Test 1: Commit secret → Pre-commit hook blocks ✅
- Test 2: Bypass with --no-verify → GitHub Actions catches ✅
- Test 3: Base64-encoded secret → GitHub secret scanning alerts ✅
- Test 4: Security dashboard review → 100% compliance ✅
- **Buck's reaction:** "Security is on autopilot"
- **FINDING:** Buck's entire journey is SECURITY TESTING (not engineering delivery)

**Journey 4: Jorge Launches Autonomous Agent (Days 1-2)**
- Initialize agent: `./scripts/run_autonomous_continuous.sh`
- Monitor progress: `tail -f autonomous_build_log.md`
- End of Day 1: 18 features (64%), 3 blocked, 7 pending
- Zero broken features, bounded retries working
- **Jorge's reaction:** "Actually working"

---

### MVP Dashboard UX Design (Lines 1087-1440)

**AI Advancements Dashboard:**
- Auto-update every 6 hours
- Sections: Weekly Summary (AI-generated), Research (arXiv), Frameworks (GitHub), Community (Reddit), Industry News (blogs)
- Mobile-responsive markdown

**User Flow 1: Quick Scan (5 Minutes)**
- Read AI-generated weekly summary → Scan key trends → Done

**User Flow 2: Deep Dive (15 Minutes)**
- Weekly summary → Framework updates → Research papers → Community sentiment → Historical analysis

**User Flow 3: Mobile Quick Check (2 Minutes)**
- Open on phone → Read AI synthesis → Bookmark link → Done

**Automation Workflows:**
- `update-ai-dashboard.yml`: Cron every 6 hours
- `weekly-ai-summary.yml`: Cron Sundays 9am (Claude API synthesis)

**Configuration via Skill:** `/7f-dashboard-curator` (add sources without YAML editing)

---

### Second Brain UX Design (Lines 1441-1680)

**Progressive Disclosure Navigation:**
- **Level 1 (Overview):** Root README.md (always loaded)
- **Level 2 (Domain):** Directory README.md (loaded when relevant)
- **Level 3 (Detail):** Specific documents (loaded on-demand)

**YAML Frontmatter Filtering:**
- `context-level`: overview | domain | detail
- `relevant-for`: [skill-names, user-roles, domains]
- `last-updated`, `author`, `status`

**AI Agent Context Loading:**
- Query: "Load brand context" → Returns brand-system/ docs
- Query: "Load architecture for API" → Returns ADRs matching "API"
- Query: "Onboard new engineer" → Returns progressive onboarding path

**Obsidian Integration (Optional):**
- Wikilinks, frontmatter, graph view, daily notes
- NOT REQUIRED: Works with any markdown editor

**Content Creation:**
- Human-generated: Patrick writes ADR (manual YAML, markdown)
- AI-generated: Henry uses skill (AI adds YAML, structures content)

**Search & Discovery:**
- Browsing: 2 clicks, <15 seconds
- Searching: grep, Obsidian Quick Switcher, GitHub search
- AI-assisted: "Where are API auth docs?" → AI finds relevant

---

### Voice Input UX Design (Lines 1682-1890)

**Cross-Platform:**
- MacOS: `brew install openai-whisper` (native)
- Linux: `pip install openai-whisper` (CLI)

**Universal Pattern: Type First, Voice Optional**
- Typing is default
- Voice is optional (user types `voice` to activate)
- Voice only shown if mic available (silent hardware check)

**Visual Feedback States:**
1. Idle: `> _ (type here, or type 'voice' to speak)` (only if mic detected)
2. Recording: `🎤 Recording... (press Enter to stop)`
3. Processing: `⏳ Transcribing...` (10-30 seconds)
4. Transcribed: Show text, `(y/n/retry)`
5. AI Structuring: Extract key points, add headings (optional)
6. Final Output: Structured content, `(save/edit)`

**Error Handling:**
- No microphone: Inform user, fallback to typing
- API failure: Retry shorter, split recording, or type
- Poor audio quality: Show confidence score, allow retry

**Mixed Modality Example:**
- Jorge dictates long ADR context (5 min speaking)
- Types short consequences section
- **Time:** 15 min vs 1 hour typing

---

### Design System Components (Lines 1892-2080)

**Component 1: Skill Invocation UI**
- Header: Skill name, description
- Current step in multi-step process
- User prompt with options
- Context-aware suggestions

**Component 2: Status Indicators**
- In Progress: Progress bar, elapsed/estimated time
- Success: ✅ with details
- Error: ❌ with suggestions
- Warning: ⚠️ with confirmation

**Component 3: Approval Workflows**
- High-Risk (delete repo): Type name to confirm, cannot undo warning
- Low-Risk (create repo): Summary, simple y/n

**Component 4: Progress Tracking (Autonomous Agent)**
- Terminal dashboard: Overall progress, current task, recent completions, blocked features, next up

**Component 5: Data Tables**
- Markdown tables for structured data
- Mobile-responsive (horizontal scroll)
- Most important column first

---

### Responsive Design & Accessibility (Lines 2081-2130)

**Mobile Experience (Phase 2 Priority):**
- **MVP:** Read-optimized (dashboards, Second Brain, GitHub)
- **Defers:** Voice input, BMAD skills, repo creation, code review
- **Phase 2:** PWA, mobile skills, voice on mobile, approval workflows

**Accessibility (WCAG 2.1 AA):**
- Color contrast: 4.5:1 text, 3:1 UI
- Keyboard navigation: All interactive elements via Tab
- Screen reader: Semantic HTML, ARIA labels, table headers
- Voice input: Alternative typing, clear errors, retry options

---

### UX Documentation & Handoff (Lines 2132-2214)

**Priority 1: Critical UX Requirements (Non-Negotiable MVP)**
1. README.md at every directory level
2. YAML frontmatter schema
3. Three-level hierarchy strict enforcement
4. Risk-based approval workflows
5. Skill invocation consistency
6. Dashboard markdown structure
7. Git commit conventions
8. Security feedback clarity

**Priority 2: Nice-to-Have (Defer to Days 3-5)**
1. Voice input integration
2. Obsidian wikilink syntax
3. Dashboard collapsible sections
4. Mobile responsive tables
5. Custom CSS styling
6. Historical dashboard archives

**Days 3-5 Refinement Tasks:**
- Jorge: Test skills, unblock features, review security, polish errors
- Henry: Replace placeholder brand, test voice, review dashboards
- Patrick: Review agent output, test quality, validate ADRs
- Buck: Run security control tests, review dashboard, sign off

**Design Debt Log:**
- Phase 1.5: Brand refinement, voice polish, dashboard filters, mobile optimization
- Phase 2: Additional dashboards, real-time updates, AI chat, visualizations
- Phase 3: Collaborative editing, version control UI, advanced search, personalization

---

## Critical Information

**Document Date:** Feb 14, 2026 (CREATED AFTER Product Brief, Architecture, PRD, Action Plan dated Feb 10-13)

**Impact:** Most recent document, likely contains updates not reflected in earlier docs

**Role Clarifications (VERIFIED WITH JORGE):**
- **Buck (VP Engineering):** Product development, engineering projects, apps, backend infrastructure
- **Jorge (VP AI-SecOps):** AI infrastructure + Security Operations (SecOps) + Compliance
- **UX spec incorrectly attributes some security/compliance to Buck** - should be Jorge per his clarification

**Skill Count:** Document references 26 skills (consistent with Product Brief)

**Feature Count:** Document references 28 features in MVP (consistent with Functional Requirements)

**Timeline:** Document references 5-day MVP execution (Days 0-5)

**Voice Input:** OPTIONAL for all users (not required), typing is default

**Buck's User Journey:** Focuses on SECURITY TESTING (adversarial testing of security controls), not engineering project delivery

---

## Ambiguities / Questions

**Role Attribution:**
- UX spec (Line 93-100) lists Buck with compliance responsibilities
- Jorge clarified: Compliance should be Jorge's (VP AI-SecOps), not Buck's
- Need to verify: Should Functional Requirements be updated to reflect this?

**Security vs Engineering:**
- Buck's user journey (Line 846-952) is 100% security testing
- Buck's persona (Line 93-100) includes engineering projects, apps, backend
- Inconsistency: Journey doesn't show engineering delivery, only security validation
- **Clarification:** Buck is VP Engineering with security responsibilities, but Jorge owns SecOps infrastructure

**Voice Input Assumption:**
- Document assumes voice is optional for everyone
- Jorge's guidance: Confirm typing-first, voice-optional meets all needs
- **Status:** Assumed correct unless Jorge objects

---

## Related Documents
- Created Feb 14 AFTER Product Brief (Feb 10), Architecture (Feb 10), PRD (Feb 10-13), Action Plan (Feb 10)
- References all foundational documents
- Provides detailed UX implementation of Product Brief vision
- Expands on User Journeys detailed narratives
- Complements Functional/Non-Functional Requirements with interaction design
