# Extract: User Journeys

**Source:** `prd/user-journeys.md`
**Date:** Not specified (part of PRD created Feb 13)
**Size:** 267 lines
**Author:** Part of PRD by Mary with Jorge

---

## Document Metadata
- **Purpose:** Detailed narratives for 4 founding team members' success journeys
- **Format:** Story-based (Opening Scene → Rising Action → Climax → Resolution)
- **Key Innovation:** Each journey reveals specific requirements

---

## Key Content Sections

### Journey 1: Henry (CEO) - Brand System with AI (Lines 3-49)
**Opening:** Brand bottleneck - scattered notes, no cohesive vision
**Rising Action:** Discovers `/7f-brand-system-generator` skill, conversational AI session
**Climax - Aha Moment:** "AI permeates everywhere. I can shape our organization's ethos easily."
**Resolution:** 2 hours to generate brand docs, investor pitch, website copy, social messaging

**Requirements Revealed:**
- Voice input system (OpenAI Whisper)
- Custom `7f-brand-system-generator` skill
- Second Brain brand structure
- AI collaboration workflows (iterative generation + refinement)

**Timeline:** 30 minutes to generate, 80% quality, 20% refinement

---

### Journey 2: Patrick (CTO) - Infrastructure Quality (Lines 52-104)
**Opening:** Technical debt worry from moving fast
**Rising Action:** Reviews ADRs, tests infrastructure, runs code review skill
**Climax - Aha Moment:** "Using AI to accomplish tasks is effortless. SW development infrastructure is well done."
**Resolution:** Infrastructure has quality gates, stops worrying about technical debt

**Requirements Revealed:**
- Architecture documentation (ADRs, technical specs)
- Code review workflows (`/bmad-bmm-code-review`)
- Security automation (Dependabot, secret scanning, branch protection)
- BMAD skill library (encoded best practices)
- GitHub CLI automation

**Key Test:** AI identifies race condition, suggests fix, references ADR-006

---

### Journey 3: Buck (VP Engineering) - Security Autopilot (Lines 106-169)
**Opening:** Security paranoia from previous hack ($50K crypto mining incident)
**Rising Action:** Tests security controls, attempts to commit secrets
**Climax - Aha Moment:** "It's flagging any attempts to push sensitive data. Code review and test infrastructure already configured."
**Resolution:** Trusts automated controls, shifts from prevention to response

**Requirements Revealed:**
- Pre-commit hooks (detect-secrets)
- GitHub security features (secret scanning, Dependabot, CodeQL)
- Branch protection rules
- 2FA enforcement
- Security dashboard
- Automated testing

**Test Results:**
- ✅ Pre-commit hook blocks secrets
- ✅ `--no-verify` bypass fails (GitHub Actions catches)
- ✅ Base64-encoded secrets caught
- ✅ 13 dependency alerts triaged

---

### Journey 4: Jorge (VP AI-SecOps) - Autonomous Agent Success (Lines 172-229)
**Opening:** Enabler bottleneck - team relies on Jorge for everything
**Rising Action:** Launches autonomous agent, monitors progress hourly
**Climax - Aha Moment:** "The implementation is working with minimal or no issues."
**Resolution:** Shifts from "do everything" to "enable everything"

**Requirements Revealed:**
- Autonomous agent infrastructure (Claude Code SDK)
- Bounded retry logic (max 3 attempts)
- Testing built into development cycle
- Feature tracking (`feature_list.json`)
- Clear error logging
- Meta-skill for skill creation
- BMAD library deployment

**Progress Timeline:**
- Hour 2: GitHub orgs created ✅
- Hour 4: BMAD deployed ✅
- Hour 6: Second Brain scaffolded ✅
- Hour 8: AI dashboard implemented ✅
- End of Day 1: 18 features completed (64%), 3 blocked, 7 pending

**Quality:** Zero broken features, all tests passed

---

### Additional User Types (Lines 232-246)
**Future personas documented:**
5. Operations/Admin User - GitHub org management
6. Support/Troubleshooting User - Debug workflows
7. External Contributor - Open source contribution

---

### Journey Requirements Summary (Lines 249-265)
**12 capabilities revealed across all journeys:**
1. Voice Input System (Henry)
2. Custom Skill Creation (Henry, Jorge)
3. Second Brain Content Structure (Henry, Patrick)
4. AI Collaboration Workflows (Henry)
5. Architecture Documentation (Patrick)
6. Code Review Automation (Patrick)
7. Security Automation (Buck) - **CRITICAL**
8. GitHub CLI Automation (Patrick, Buck, Jorge)
9. Autonomous Agent Infrastructure (Jorge)
10. Feature Tracking System (Jorge)
11. BMAD Library Deployment (All)
12. Dashboard Auto-Update (Future)

---

## Critical Information
- **4 "aha moments" are success criteria** for MVP
- **Each journey reveals technical requirements** (not just user stories)
- **Narrative format** helps understand user emotions and expectations
- **Specific timelines** provided (30 min brand gen, 2 hours total for Henry)
- **Quality thresholds** defined (80% AI-generated, 20% human refinement)

---

## Ambiguities / Questions
- None - journeys are detailed and complete

---

## Related Documents
- Informs Functional Requirements (what features enable these journeys)
- Validates Innovation Analysis (autonomous agent success)
- Supports Manual Testing Plan (validates "aha moments")
