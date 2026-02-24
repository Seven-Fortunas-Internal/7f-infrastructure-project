# CPG Outreach System - Project Kickoff Context

**Date:** 2026-02-15
**Session Type:** Planning / Requirements Gathering
**Participants:** Jorge (VP AI-SecOps), Henry (CEO), Patrick (CTO)
**Agent:** Wendy (Workflow Building Master)
**Status:** Context document for new project creation

---

## Executive Summary

Henry (CEO) and Patrick (CTO) initiated requirements for a **CPG Brand Lead-Finding and Outreach System** to support Seven Fortunas' "Building Wealth While You Spend" product offering. This system needs AI-powered lead generation, LinkedIn warm introduction automation, and meeting scheduling capabilities.

**Strategic Importance:** This is a revenue-generating business development capability distinct from Seven Fortunas' internal infrastructure project. It demonstrates the company's "AI permeates everything" philosophy applied to sales operations.

---

## Business Context

### Seven Fortunas Product Offering

**Product:** "Building Wealth While You Spend"
**Market:** CPG (Consumer Packaged Goods) brands globally
**Value Proposition:** Help CPG brand customers build wealth while purchasing products
**Target Customers:** CPG brands with mature loyalty programs

**Success Example:**
- **Grupo Aje:** Peruvian beverage company
- Status: Accepted follow-on call after teaser lunch
- Pattern: This is the type of brand Seven Fortunas wants to replicate

### Current Sales Challenge

**Manual Process Limitations:**
- Lead identification requires extensive web research
- Finding decision-makers is time-consuming
- No systematic way to leverage LinkedIn connections
- Outreach scripts created ad-hoc
- No tracking or learning system
- Doesn't scale beyond 1-2 leads/week

**Opportunity:**
- 4-5 qualified leads per week target (initial)
- Scale to 20-30 leads/week as process matures
- Capture learnings to continuously improve targeting and messaging
- Demonstrate AI-powered business development to investors

---

## Requirements Summary

### Core Capabilities Needed

#### 1. ICP Identification & Web Scouting
**Objective:** Find CPG brands globally that match Seven Fortunas' ideal customer profile

**Requirements:**
- Scout web for CPG brands with indicators of loyalty program maturity
- Qualify brands based on:
  - Industry segment (food, beverage, personal care, household goods)
  - Geographic presence (global or regional leaders)
  - Loyalty program sophistication
  - Digital transformation readiness
  - Alignment with "Building Wealth While You Spend" value prop
- Prioritize leads similar to Grupo Aje (proven fit)
- Generate target company list with qualification scores

**AI Agent Role:** Web research, company analysis, qualification scoring

#### 2. Decision-Maker Discovery
**Objective:** Identify the right person to contact at each target company

**Requirements:**
- Identify decision-makers by role:
  - CIO (Chief Information Officer) - for tech integration
  - CMO (Chief Marketing Officer) - for loyalty programs
  - CPO (Chief Product Officer) - for product innovation
  - C-suite (CEO, COO) - for strategic partnerships
  - Loyalty Program Directors/VPs - for operational decisions
- Use AI judgment to determine best entry point based on company size and structure
- Gather contact information (LinkedIn profile, company email patterns)

**AI Agent Role:** Organizational analysis, role mapping, contact research

#### 3. LinkedIn Connection Analysis
**Objective:** Find warm introduction paths through existing network

**Requirements:**
- Import user's (Jorge's) LinkedIn connections
- Import entire team's LinkedIn connections (aggregate view)
- Cross-reference target decision-makers with connection graph
- Identify 1st and 2nd degree connections
- Map warm introduction paths
- Prioritize leads with warm intro opportunities

**Integration Needed:** LinkedIn MCP (Model Context Protocol) or alternative

**AI Agent Role:** Network analysis, relationship mapping, introduction path finding

#### 4. Outreach Script Generation & Approval
**Objective:** Generate personalized outreach messages with human oversight

**Requirements:**

**Step 4a: Team Member → Warm Contact Script**
- Generate message from Seven Fortunas team member to their LinkedIn connection
- Context: "Can you introduce me to [Decision-Maker] at [Company]?"
- Explain why: Seven Fortunas product relevance
- **Human Checkpoint:** User reviews script, selects [Y] Approve | [E] Edit | [N] Skip
- Only proceed if approved

**Step 4b: Warm Contact → ICP Script**
- Generate introduction message from warm contact to decision-maker
- Context: "I'd like to introduce you to [Team Member] from Seven Fortunas"
- Value proposition tailored to company's context
- **Human Checkpoint:** User reviews script, selects [Y] Approve | [E] Edit | [N] Skip
- Only send if approved

**Step 4c: Message Sending**
- Send via LinkedIn InMail or email
- Log in CRM/tracking system
- Track delivery and opens (if possible)

**Critical Requirement:** NEVER auto-send without explicit human approval

**AI Agent Role:** Script generation, personalization, tone calibration

#### 5. Meeting Scheduling
**Objective:** Coordinate meeting times and send calendar invites

**Requirements:**
- Capture ICP's preferred meeting times
- Check Seven Fortunas team member availability
- Propose meeting times
- **Human Checkpoint:** "OK to schedule now?"
- Generate calendar invite (Google Calendar, Zoom link, etc.)
- Send to all parties
- Sync with CRM

**Integration Needed:** Google Calendar API, Zoom API, Calendly, or manual generation

**AI Agent Role:** Scheduling logic, invite generation

#### 6. Iteration & Learning System
**Objective:** Continuously improve outreach effectiveness

**Requirements:**
- Track metrics:
  - Response rate (% of warm intros that get response)
  - Meeting booking rate (% that convert to meetings)
  - Meeting → deal rate (% that progress to deal discussions)
  - Time to response (how long before they reply)
- Analyze what works:
  - Which script variations get best responses
  - Which decision-maker roles respond best
  - Which company characteristics predict success
  - Which warm intro paths are most effective
- Generate insights report after each campaign (e.g., every 10-20 leads)
- Use insights to update:
  - ICP criteria (refine targeting)
  - Script templates (improve messaging)
  - Outreach timing (optimize send times)
- Support Phase 3 iterations between user and ICP
  - Capture conversation themes
  - Refine value proposition based on objections/questions
  - Update messaging for future leads

**AI Agent Role:** Analytics, pattern recognition, recommendation generation

#### 7. Campaign Definition (Meta-Workflow)
**Objective:** Framework for defining outreach campaigns with different parameters

**Requirements:**
- Define campaign parameters:
  - ICP criteria (industry segment, geography, company size)
  - Messaging theme (which benefits to emphasize)
  - Target volume (how many leads)
  - Execution schedule (one-time vs periodic)
  - Success metrics (response rate targets)
- Save campaign configuration as template
- Support multiple simultaneous campaigns (e.g., beverages in LATAM, food brands in Asia)
- Track campaign-level metrics

**Why Meta-Workflow:** This specific campaign may run once or irregularly, but the framework should support recurring and varied campaigns

**AI Agent Role:** Campaign design guidance, template management

---

## Technical Integration Requirements

### 1. LinkedIn Integration

**Requirement:** Access user's LinkedIn network to identify warm connections

**Options Identified:**
- **LinkedIn MCP (Model Context Protocol)** - Evaluate if available
- **LinkedIn Sales Navigator API** - Henry/Patrick likely have access
- **LinkedIn API (official)** - Limited functionality for messaging
- **Alternative: Manual CSV export** - User exports connections, workflow processes
- **Alternative: Web scraping** - Legal/ethical concerns

**Evaluation Needed:**
- LinkedIn MCP capabilities and maturity
- Sales Navigator API access and features
- Cost and complexity of each option
- Legal/compliance considerations

**Recommendation:** Research in technical research phase

### 2. Calendar & Meeting Integration

**Requirement:** Schedule meetings and send calendar invites

**Options to Evaluate:**
- **Google Calendar API** - Most common, good documentation
- **Microsoft Outlook/365 API** - For enterprise users
- **Calendly API** - User-friendly scheduling UI
- **Zoom API** - For generating meeting links
- **Google Meet** - Alternative to Zoom

**Integration Strategy:**
- Support multiple providers via adapter pattern
- Start with Google Calendar (most common)
- Add others based on team preference

**Evaluation Needed:**
- API documentation quality
- OAuth setup complexity
- Feature comparison (recurring meetings, availability checking, etc.)

### 3. CRM / Lead Management System

**Requirement:** Track leads, activities, and pipeline

**Open-Source Options to Evaluate:**
- **Twenty** - Modern React-based CRM (GitHub: ~8k stars)
- **EspoCRM** - PHP-based, mature (GitHub: ~1.7k stars)
- **SuiteCRM** - Open-source Salesforce alternative (GitHub: ~4k stars)
- **Odoo CRM** - Part of full business suite (GitHub: ~35k stars)
- **Monica** - Personal CRM, simpler (GitHub: ~21k stars)
- **Krayin** - Laravel-based (GitHub: ~9k stars)

**Evaluation Criteria:**
- Self-hosted vs cloud deployment
- API quality (RESTful, well-documented)
- BMAD workflow integration ease
- Maintenance burden (updates, security patches)
- License type (truly open-source?)
- Community support and activity
- Scalability (handles 100s of leads → 1000s)

**Recommendation:** Research during technical research phase

### 4. Messaging / Email

**Requirement:** Send outreach messages

**Options:**
- **LinkedIn InMail** (via Sales Navigator or API)
- **Email** (Gmail API, SMTP)
- **Manual** (generate text for user to copy/paste)

**Phase Approach:**
- **POC:** Manual copy/paste (no integration needed)
- **V1:** Email automation (Gmail API)
- **V2:** LinkedIn automation (if feasible)

---

## Phasing & Timeline

### POC (Proof of Concept) - Week 1
**Objective:** Validate approach with manual process

**Scope:**
- Manual lead research (use existing BMAD Market Research workflow)
- Manual LinkedIn checking (spreadsheet)
- AI-assisted script generation (Tech Writer agent)
- Manual sending and tracking
- Test with 2-3 leads including Grupo Aje follow-up

**Deliverables:**
- 2-3 outreach attempts completed
- Response rate measured
- Learnings captured

**Success Metric:** At least 1 response from warm intro

**Automation Level:** ~10% (only script generation)

### V1 (First Production Version) - Weeks 2-4
**Objective:** Build custom BMAD workflows with integrations

**Scope:**
- 6 custom BMAD workflows (campaign definition, lead discovery, connection analysis, outreach, scheduling, analytics)
- LinkedIn MCP or Sales Navigator integration
- Basic CRM integration (selected open-source option)
- Email automation (Gmail API)
- Calendar automation (Google Calendar API)
- Human approval gates at all critical points
- Process 4-5 leads per week

**Deliverables:**
- 6 workflows validated and deployed
- All integrations functional
- 15-20 leads processed
- Metrics dashboard (response rates, meeting rates)

**Success Metrics:**
- 30%+ response rate from warm intros
- 10%+ meeting booking rate
- 4-5 leads per week throughput
- <2 hours per week of human time required

**Automation Level:** ~70% (human approval gates remain)

### V2 (Enhanced Version) - Months 2-3
**Objective:** Scale and optimize

**Scope:**
- Advanced analytics and learning system
- A/B testing for scripts
- Campaign templates library
- LinkedIn automation (if not in V1)
- Integration with Seven Fortunas CRM (if enterprise CRM adopted)
- Support 20-30 leads per week
- Multi-campaign management

**Deliverables:**
- Campaign template library (5+ templates)
- Analytics dashboard with trends
- Automated improvement recommendations
- 80+ leads processed

**Success Metrics:**
- 40%+ response rate (improved from V1 learnings)
- 15%+ meeting booking rate
- 20-30 leads per week throughput
- <3 hours per week of human time for 3x the volume

**Automation Level:** ~85% (approval gates + analytics review)

---

## Strategic Alignment

### How This Fits Seven Fortunas' Vision

**From Planning Artifacts:**

**"AI Permeates Everything" (Henry's Goal):**
✅ Sales/BD operations AI-powered, not just engineering
✅ Demonstrates AI value to non-technical stakeholders
✅ Shows investors Seven Fortunas practices what it preaches

**"Productivity & Scalability" (Core Success Metric):**
✅ 4-5 leads/week manual → 20-30 leads/week automated
✅ Learning system compounds value over time
✅ Templates enable campaign replication (new markets)

**"BMAD-First Methodology":**
✅ Custom workflows extend BMAD library
✅ Reusable patterns for other outreach domains
✅ Demonstrates BMAD applicability beyond engineering

**"Demonstrate to Leadership" (Funding Goal):**
✅ Tangible ROI: measurable increase in qualified meetings
✅ Professional, systematic approach impresses investors
✅ Shows AI capability in revenue-generating function

### Pattern for Future Initiatives

**This project establishes a pattern:**
- Other outreach domains: healthcare, retail, government
- Other automated operations: customer onboarding, partner engagement
- Other AI-powered workflows: content marketing, competitive intelligence

**Reusable Components:**
- LinkedIn connection analysis
- Script generation framework
- Approval gate patterns
- Learning/iteration system
- CRM integration adapters

---

## Human-in-the-Loop Philosophy

### Why Approval Gates Are Critical

**Risk Mitigation:**
- Prevent embarrassing automated mistakes (wrong person, bad timing, tone-deaf message)
- Ensure compliance with privacy laws (GDPR, CAN-SPAM)
- Maintain brand reputation (every message represents Seven Fortunas)
- Respect relationships (warm intros are social capital)

**Quality Assurance:**
- Human judgment on message appropriateness
- Context awareness AI can't fully capture
- Relationship nuances (e.g., "I know Bob is going through a tough time, skip for now")
- Strategic decisions (e.g., "This lead is too important, I'll handle personally")

**Learning Enhancement:**
- Human edits teach AI what works
- Approval patterns reveal preferences
- Skips provide negative examples
- Successful outcomes validate approach

### Where Approval Gates Are Mandatory

1. **After ICP List Generation:** Review target companies before researching
2. **After Decision-Maker Identification:** Confirm right person before scripting
3. **After Script Generation (Team → Warm Contact):** Review before sending
4. **After Script Generation (Warm Contact → ICP):** Review before sending
5. **Before Meeting Scheduling:** Confirm time/date before booking

### Where Automation Can Proceed

- Web research and company discovery (AI can explore freely)
- LinkedIn connection graph analysis (no external contact)
- Script drafting (human reviews before sending)
- Data logging and CRM updates (no external impact)
- Analytics and insights generation (inform human decisions)

**Philosophy:** "Automate research and preparation, require approval for external actions"

---

## Success Metrics

### Immediate Success (POC)
- ✅ 2-3 outreach attempts completed
- ✅ At least 1 response received
- ✅ Process documented and learnings captured

### V1 Success (First Production)
- ✅ 30%+ response rate from warm introductions
- ✅ 10%+ meeting booking rate
- ✅ 15-20 leads contacted in 4 weeks
- ✅ <2 hours per week of human oversight time
- ✅ Zero compliance issues or relationship damage

### V2 Success (Scaled Production)
- ✅ 40%+ response rate (improved targeting/messaging)
- ✅ 15%+ meeting booking rate
- ✅ 80+ leads contacted in 3 months
- ✅ <3 hours per week for 3x volume (improved automation)
- ✅ 3+ campaign templates operational

### Business Impact
- ✅ 5+ qualified meetings scheduled from warm intros
- ✅ At least 1 deal progressing to pilot/contract discussions
- ✅ System pays for itself (meetings → revenue > build cost)
- ✅ Founders can run campaigns without Jorge as bottleneck
- ✅ Pattern replicable for other markets/products

---

## Questions Answered

### Q1: Lead Volume & Campaign Periodicity
**Answer:** 4-5 leads per week initially, scaling to 20-30 as process matures. Need meta-workflow for defining campaigns with different periodicity (one-time, weekly, monthly, quarterly).

### Q2: LinkedIn Access
**Answer:** Henry and Patrick likely have LinkedIn Sales Navigator or can easily acquire it. Evaluate Sales Navigator API capabilities.

### Q3: Automation Philosophy
**Answer:** Maximum automation with responsible human checkpoints. POC can be manual to learn, but V1 should be heavily automated. Goal is to demonstrate "AI permeates everything" while maintaining quality and compliance.

---

## Recommended Planning Process

### Phase 0: Project Setup (15 minutes)
**Create separate project structure:**

```bash
# Option A: New directory in current workspace
mkdir -p /home/ladmin/dev/GDF/cpg-outreach-system

# Option B: New GitHub repo (recommended if separate product)
cd /home/ladmin/seven-fortunas-workspace
git clone [new-repo-url] cpg-outreach-system
cd cpg-outreach-system
```

**Initialize BMAD in new project:**
```bash
npx bmad-method install
```

### Phase 1: Discovery & Research (2-4 hours, 1 session)

**Brainstorming:**
```
/bmad-brainstorming
Topic: "CPG Brand Outreach System - Lead generation and warm introduction automation"
```

**Technical Research:**
```
/bmad-bmm-technical-research
Topics:
1. LinkedIn MCP vs Sales Navigator API vs alternatives
2. Google Calendar / Calendly / Zoom APIs
3. Open-source CRM comparison (Twenty, EspoCRM, SuiteCRM, Odoo, Monica, Krayin)
```

**Domain Research:**
```
/bmad-bmm-domain-research
Topics:
1. B2B sales outreach methodologies
2. LinkedIn warm introduction best practices
3. CPG industry decision-making processes
4. GDPR and privacy compliance for automated outreach
```

**Outputs:**
- `brainstorming-session-{date}.md`
- `technical-research-{date}.md`
- `domain-research-{date}.md`

### Phase 2: Product Brief (1-2 hours, 1 session)

```
/bmad-bmm-create-product-brief
```

**Content:**
- Executive Summary (vision, problem, solution)
- Core Components (7 capabilities outlined above)
- Success Criteria (metrics per phase)
- Phasing (POC → V1 → V2)
- Strategic alignment with Seven Fortunas

**Output:** `product-brief-cpg-outreach-{date}.md`

### Phase 3: Architecture (2-3 hours, 1 session)

```
/bmad-bmm-create-architecture
```

**Architecture Decision Records (ADRs):**
1. LinkedIn integration strategy
2. CRM selection and deployment
3. Calendar/meeting integration approach
4. Data flow architecture
5. Human-in-the-loop design patterns
6. Learning system architecture

**Output:** `architecture-cpg-outreach-{date}.md`

### Phase 4: PRD (3-4 hours, 1 session)

```
/bmad-bmm-create-prd
```

**Detailed Requirements:**
- 9 Functional Requirements (FR-1 through FR-9 outlined above)
- Non-Functional Requirements (privacy, scalability, integration)
- User journeys (Henry, Patrick, Jorge perspectives)
- Success metrics per phase

**Output:** `prd-cpg-outreach-{date}.md`

### Phase 5: Workflow Design (8-16 hours, 6-12 sessions)

**Create 6 custom BMAD workflows:**

1. `/bmad-bmb-create-workflow` - Campaign Definition Meta-Workflow
2. `/bmad-bmb-create-workflow` - Lead Discovery & Qualification
3. `/bmad-bmb-create-workflow` - LinkedIn Connection Analysis
4. `/bmad-bmb-create-workflow` - Outreach Script Generation & Execution
5. `/bmad-bmb-create-workflow` - Meeting Scheduling
6. `/bmad-bmb-create-workflow` - Campaign Analytics & Iteration

**Validate each:**
```
/bmad-bmb-validate-workflow
```

**Outputs:** 6 workflow directories with complete implementation

### Phase 6: POC Execution (Week 1)

**Manual process with existing BMAD skills:**
- Market research for 3-5 CPG brands
- Manual LinkedIn connection checking
- AI-assisted script generation
- Manual outreach
- Track results

**Success:** At least 1 response from 2-3 attempts

### Phase 7: V1 Development (Weeks 2-4)

**Build integrations:**
- LinkedIn MCP/API
- Gmail API
- Google Calendar API
- Selected CRM deployment and integration

**Deploy workflows:**
- Test with real leads
- Iterate based on feedback
- Document learnings

**Success:** 4-5 leads per week, 30%+ response rate

---

## Repository Structure (Recommended)

```
cpg-outreach-system/
├── _bmad/                          # BMAD library
│   ├── bmm/workflows/outreach/     # Custom workflows
│   │   ├── campaign-definition/
│   │   ├── lead-discovery/
│   │   ├── connection-analysis/
│   │   ├── outreach-execution/
│   │   ├── meeting-scheduling/
│   │   └── campaign-analytics/
│   └── _config/
│       └── bmad-help.csv           # Workflow registry
├── _bmad-output/
│   ├── planning-artifacts/         # Planning docs
│   │   ├── product-brief.md
│   │   ├── architecture.md
│   │   ├── prd.md
│   │   ├── brainstorming-session.md
│   │   ├── technical-research.md
│   │   └── domain-research.md
│   ├── campaigns/                  # Campaign execution logs
│   │   ├── 2026-02-cpg-latam/
│   │   ├── 2026-03-cpg-asia/
│   │   └── templates/
│   └── analytics/                  # Metrics and insights
│       ├── response-rates.md
│       ├── meeting-conversion.md
│       └── campaign-comparisons.md
├── integrations/                   # Integration adapters
│   ├── linkedin/
│   │   ├── mcp-adapter.js
│   │   └── sales-navigator-api.js
│   ├── calendar/
│   │   ├── google-calendar.js
│   │   └── calendly.js
│   ├── crm/
│   │   └── [selected-crm]-adapter.js
│   └── email/
│       └── gmail-api.js
├── docs/                           # User documentation
│   ├── setup-guide.md
│   ├── workflow-usage.md
│   └── integration-guides/
├── scripts/                        # Utility scripts
│   ├── export-linkedin-connections.js
│   ├── import-to-crm.js
│   └── generate-analytics.js
├── .claude/
│   └── commands/                   # Skill stubs
└── README.md
```

---

## Next Steps (Immediate Actions)

### Decision Required: Project Location

**Option A: New Directory in Current Workspace**
```bash
cd /home/ladmin/dev/GDF
mkdir cpg-outreach-system
cd cpg-outreach-system
npx bmad-method install
```

**Pros:**
- Quick setup
- Keeps related projects together
- Easy to reference Seven Fortunas context

**Cons:**
- Not version controlled (unless you init git)
- Harder to share with team
- No GitHub org visibility

**Option B: New GitHub Repository**
```bash
# In Seven-Fortunas-Internal org (private)
cd /home/ladmin/seven-fortunas-workspace
git clone git@github.com:Seven-Fortunas-Internal/cpg-outreach-system.git
cd cpg-outreach-system
npx bmad-method install
```

**Pros:**
- Version controlled from start
- Team collaboration enabled
- Professional structure
- Part of Seven Fortunas ecosystem
- Can evolve into product eventually

**Cons:**
- Requires creating GitHub repo first
- More formal (but that's good)

**Recommendation:** **Option B** - Create GitHub repo in Seven-Fortunas-Internal org

### Step-by-Step to Launch

**1. Create GitHub Repository (5 minutes)**
- Go to https://github.com/orgs/Seven-Fortunas-Internal
- Create new repository: `cpg-outreach-system`
- Make it private
- Initialize with README
- Clone locally

**2. Initialize BMAD (2 minutes)**
```bash
cd /home/ladmin/seven-fortunas-workspace/cpg-outreach-system
npx bmad-method install
```

**3. Copy This Context Document (1 minute)**
```bash
cp /home/ladmin/dev/GDF/7F_github/SESSION-2026-02-15-cpg-outreach-system-project-kickoff.md \
   /home/ladmin/seven-fortunas-workspace/cpg-outreach-system/PROJECT-CONTEXT.md
```

**4. Start Discovery Phase (immediately)**
```bash
cd /home/ladmin/seven-fortunas-workspace/cpg-outreach-system
# Open Claude Code in this directory
# Run: /bmad-brainstorming
```

---

## Key Contacts & Roles

**Project Sponsors:**
- **Henry (CEO)** - Business champion, will use for strategic outreach
- **Patrick (CTO)** - Technical champion, may configure integrations

**Project Lead:**
- **Jorge (VP AI-SecOps)** - Project owner, BMAD expert, integration architect

**Primary Users:**
- Henry, Patrick, Jorge (founding team members doing outreach)
- Future: BD team members as company scales

**Decision Authority:**
- Integration choices: Patrick (CTO)
- Campaign strategy: Henry (CEO)
- Workflow design: Jorge with BMAD methodology

---

## Success Definition

**This project succeeds when:**
1. ✅ Founding team can generate 4-5 qualified CPG brand leads per week
2. ✅ 30%+ of warm intros get responses (V1 target)
3. ✅ 10%+ of leads convert to meetings (V1 target)
4. ✅ System operates with <2 hours per week of human oversight
5. ✅ Learning system continuously improves targeting and messaging
6. ✅ Pattern is reusable for other markets and products
7. ✅ Demonstrates "AI permeates everything" to investors

**This project demonstrates strategic value when:**
- ✅ Sales pipeline measurably improves
- ✅ Founders can operate system without Jorge as bottleneck
- ✅ Investors see professional, AI-powered business operations
- ✅ Pattern extends to other domains (customer success, partnerships, recruiting)

---

## References

**Seven Fortunas Planning Artifacts:**
- Product Brief: `/home/ladmin/dev/GDF/7F_github/_bmad-output/planning-artifacts/product-brief-7F_github-2026-02-10.md`
- Architecture: `/home/ladmin/dev/GDF/7F_github/_bmad-output/planning-artifacts/architecture-7F_github-2026-02-10.md`
- PRD: `/home/ladmin/dev/GDF/7F_github/_bmad-output/planning-artifacts/prd/prd.md`

**BMAD Resources:**
- BMAD Custom Workflow Lifecycle Guide: `/home/ladmin/dev/GDF/7F_github/_bmad-output/BMAD-Custom-Workflow-Lifecycle-Guide.md`
- Workflow Creation: `/bmad-bmb-create-workflow`
- Workflow Validation: `/bmad-bmb-validate-workflow`

**Related Example:**
- Transcribe Audio Workflow: Demonstrates human approval gates, multi-step process, data flow patterns

---

## Document Version History

- **v1.0** (2026-02-15): Initial context document created by Wendy (Workflow Building Master)
- Future versions will be maintained in the new project repository

---

## Handoff to New Project

**This document provides:**
✅ Complete business context and requirements
✅ Technical integration research topics
✅ Recommended planning process (6 phases)
✅ Success criteria and metrics
✅ Timeline and phasing approach
✅ Strategic alignment with Seven Fortunas vision

**Next step in NEW project:**
1. Create GitHub repository
2. Initialize BMAD
3. Copy this document as PROJECT-CONTEXT.md
4. Start Phase 1: Discovery & Research (`/bmad-brainstorming`)

**Ready to launch!** 🚀
