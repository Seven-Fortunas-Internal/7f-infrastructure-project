# Extract: Manual Testing Plan

**Source:** `manual-testing-plan.md`
**Date:** 2026-02-13
**Size:** 154 lines, 4KB
**Author:** Not specified (likely Mary/Jorge)

---

## Document Metadata
- **Purpose:** Define human-only testing (subjective, aesthetic, adversarial)
- **Assumption:** Autonomous agent validates 90%+ automatically
- **Human Testing Time:** 1-2 hours total
- **Status:** Complete

---

## Key Content Sections

### Prerequisites (Lines 11-19)
**Must be automated FIRST:**
- ✅ All structural tests passed (repos, files, syntax, API calls)
- ✅ feature_list.json shows 60-70% "pass" rate
- ✅ Zero critical failures
- Jorge reviews with: `cat feature_list.json | jq`

### Human Test 1: AI Collaboration Quality (Lines 21-41)
**Tester:** Henry (CEO)
**Duration:** 15 min
**Cannot automate:** Conversational quality is subjective

**Test:** `/7f-brand-system-generator` interactive session

**Evaluation Criteria:**
- AI asks clarifying questions naturally
- Conversation feels collaborative (not scripted)
- AI understands context from earlier answers
- 80% content acceptable (20% refinement needed)
- **Aha moment:** "AI permeates everywhere; I can shape our ethos easily"

### Human Test 2: Architecture Clarity (Lines 43-61)
**Tester:** Patrick (CTO)
**Duration:** 15 min
**Cannot automate:** Clarity requires human judgment

**Test:** Review architecture docs and ADRs

**Evaluation Criteria:**
- Architecture docs explain design decisions clearly
- ADRs provide rationale ("why" not just "what")
- Technical approach is sound
- **Aha moment:** "Infrastructure is well done"

### Human Test 3: Security Behavior (Lines 63-84)
**Tester:** Buck (VP Engineering)
**Duration:** 15 min
**Cannot automate:** Requires adversarial intent

**Test:** Attempt to commit secret (should be blocked)

**Evaluation Criteria:**
- Pre-commit hook blocks secret commit
- Attempting bypass (--no-verify) still fails
- Error messages guide fix
- **Aha moment:** "Security on autopilot"

### Human Test 4: Autonomous Agent Performance (Lines 86-103)
**Tester:** Jorge (VP AI-SecOps)
**Duration:** 15 min
**Cannot automate:** Overall validation requires judgment

**Test:** Review `feature_list.json` completion stats

**Evaluation Criteria:**
- 60-70% completion rate (18-25 features "pass")
- Blocked features are expected (not failures)
- Zero unexpected failures
- **Aha moment:** "Implementation working with minimal or no issues"

### Human Test 5: End-to-End Workflow (Lines 105-130)
**Tester:** Henry + Jorge
**Duration:** 30 min
**Cannot automate:** Tests entire user journey

**Test:** Brand generation → Presentation generation

**Evaluation Criteria:**
- Workflow feels natural (not clunky)
- Presentation uses brand colors correctly
- Slides look professional
- Ready to present (80% done, 20% refinement)

### Success Criteria (Lines 132-146)
**MVP passes if:**
- ✅ 4/5 aha moments achieved (80% threshold)
- ✅ AI collaboration feels natural
- ✅ Content/visual quality acceptable (80% done)
- ✅ Security works as expected
- ✅ Overall: "Impressive for 5-day build"

**If any test fails:**
- Document issue
- Assess severity (cosmetic vs. blocking)
- Address in Days 3-5 refinement

---

## Critical Information
- **Agent-first testing philosophy:** 90%+ automated, human only for subjective
- **4 founding team members each test:** Henry, Patrick, Buck, Jorge
- **5 aha moments** define success (one per founder + E2E workflow)
- **1-2 hours total human testing** (efficient)

---

## Key Principle (CRITICAL for Jorge)
> **"All venues for automated or agentic testing must be implemented first and exhausted before enlisting my help for testing. My testing is more prone to mistakes, delays and not as thorough as the BMAD agents like TEA, Murat, can deliver."**

This aligns with Jorge's Q2 answer about prioritizing automated/agentic testing.

---

## Ambiguities / Questions
- None - clear testing protocol

---

## Related Documents
- Implements testing philosophy from global CLAUDE.md
- Validates features defined in PRD
- Tests autonomous agent output from Autonomous Workflow Guide
