# Jorge's Guidance - Conflict Resolutions

**Date:** 2026-02-15
**Session:** Document Sync Phase 1

---

## Conflict #1: GitHub Account Authentication ✅ RESOLVED

**Jorge's Guidance:**
> "please update Autonomous Workflow Guide to mention use jorge-at-sf"

**Resolution:**
- ✅ Updated Autonomous Workflow Guide Prerequisites section to include:
  - Explicit requirement to authenticate as jorge-at-sf (NOT jorge-at-gd)
  - Verification command: `gh auth status | grep jorge-at-sf`
  - Account switching instructions if authenticated incorrectly
  - Explanation of why jorge-at-sf is critical (proper ownership)

**Status:** RESOLVED - Document updated

---

## Conflict #2: Buck vs Jorge Responsibilities ✅ CLARIFIED

**Jorge's Guidance:**
> "Buck is VP of Engineering so he has a lot of responsibilities. Jorge is VP of AI and SecOps (Security Operations) so anything related to AI and Security should be referenced to Jorge, not Buck. Anything about product development should be Buck's."

**Clear Delineation:**

**Buck (VP Engineering):**
- Product development
- Engineering projects
- Apps development
- Backend infrastructure
- Engineering delivery
- **Application security** (app-level: auth, API security, PCI compliance)

**Jorge (VP AI-SecOps):**
- AI infrastructure
- **Security Operations (SecOps)** (infrastructure: secret scanning, Dependabot, audit logs)
- Security architecture
- **Compliance** (SOC 2, GDPR, audit requirements)
- DevOps automation
- Autonomous agents
- **Security Testing** (adversarial testing of security controls)

**Action Items:**
1. ✅ Review UX Design Specification for misattributions - FOUND CRITICAL ISSUE
2. Verify Functional Requirements correctly assign AI/Security to Jorge
3. Check User Journeys for role clarity
4. Update any docs that incorrectly assign security to Buck

**CRITICAL FINDING from UX Spec (Feb 14):**
- **Buck's User Journey (Lines 846-952) is SECURITY TESTING** - This is WRONG
- Journey shows: Pre-commit hook testing, bypass attempts, encoded secrets, security dashboard
- **Should be Jorge's journey** (Security Testing = SecOps)
- **Buck's journey should focus on engineering delivery** (apps, backend, product development)

**Buck's Aha Moment:**
- **Current (WRONG):** "Security on autopilot"
- **Should be (CORRECT):** Engineering delivery focused (apps work well, infrastructure supports development)

**Status:** CRITICAL CONFLICT IDENTIFIED - UX spec needs major correction

---

## Medium Conflicts: Skill Count ✅ CLARIFIED

**Jorge's Guidance:**
> "Skill count is to be a growing list. Please make sure to track the latest."

**Understanding:**
- Skill count is NOT fixed at 26 or 25
- Skills will be added over time
- Need to track LATEST count as source of truth
- Document should show skill count evolution

**Current Status (MVP - Feb 10-13):**
- 18 BMAD skills (adopted)
- 5 adapted skills (brand-voice, pptx, excalidraw, sop, skill-creator)
- 3 custom skills (manage-profile, dashboard-curator, repo-template)
- **Total: 26 operational skills in MVP**

**Tracking Approach:**
- Master documents should show "26 skills (MVP baseline)"
- Note that skill count will grow in Phase 1.5, Phase 2, Phase 3
- Each phase should document skill additions

**Status:** CLARIFIED - Will track as growing list

---

## Medium Conflicts: Feature Count ✅ CLARIFIED

**Jorge's Guidance:**
> "Feature count is also another growing list that must be kept tracked of."

**Understanding:**
- Feature count is NOT fixed at 28
- Features will be added over time
- Need to track LATEST count as source of truth
- Document should show feature evolution

**Current Status (MVP - Feb 10-13):**
- 28 Functional Requirements (high-level features)
- May expand to 30-50 detailed tasks in feature_list.json
- **Total: 28 features in MVP**

**Tracking Approach:**
- Master documents should show "28 features (MVP baseline)"
- Note that feature count will grow in Phase 1.5, Phase 2, Phase 3
- Each phase should document feature additions

**Status:** CLARIFIED - Will track as growing list

---

## Medium Conflicts: Timeline Terminology ⏸️ INVESTIGATING

**Jorge's Guidance:**
> "Not sure about the Timeline terminology reference."

**Issue:**
- Some docs say "3 days"
- Some docs say "5 days"
- Action Plan says "Days 0-5" (6-day span)

**Investigation Plan:**
- Review remaining documents for timeline references
- Identify source of "3 days" reference
- Clarify if it's 3 days autonomous + 2 days refinement = 5 days total

**Status:** INVESTIGATING - Will clarify in remaining reads

---

## Phase 1 Continuation Plan

**Remaining Tasks:**
1. ✅ Fix Conflict #1 (Autonomous Workflow Guide updated)
2. ⏭️ Read Architecture Document (2600 lines remaining)
3. ⏭️ Read PRD Main (1500 lines remaining)
4. ⏭️ Read UX Design Specification (1200 lines remaining - PRIORITY)
   - Special attention: Verify Buck vs Jorge responsibilities
   - Check for security misattributions
5. ⏭️ Update Conflict Log with findings
6. ⏭️ Update Content Inventory with complete extractions
7. ⏭️ Check in with Jorge for Phase 1 completion review

**Expected Token Usage:** ~55K remaining of 200K budget (sufficient)

---

**Document Status:** Living guidance document - will update as Phase 1 progresses
