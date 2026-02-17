# CRITICAL: UX Spec Corrections Required

**Date:** 2026-02-15
**Issue:** UX Design Specification (Feb 14) has incorrect user journey for Buck

---

## Problem Statement

The UX Design Specification (created Feb 14, AFTER all other docs) incorrectly attributes Security Testing journey to Buck (VP Engineering). This journey should belong to Jorge (VP AI-SecOps).

---

## Incorrect Content in UX Spec

### Buck's User Journey (Lines 846-952) - WRONG ATTRIBUTION

**Current content shows Buck doing:**
- **Test 1:** Commit secret → Pre-commit hook blocks ✅
- **Test 2:** Bypass with --no-verify → GitHub Actions catches ✅
- **Test 3:** Base64-encoded secret → GitHub secret scanning alerts ✅
- **Test 4:** Security dashboard review → 100% compliance ✅
- **Reaction:** "Security is on autopilot"

**This is Security Testing (SecOps) - Jorge's domain, NOT Buck's**

### Buck's Aha Moment (Lines 98-99) - WRONG FOCUS

**Current:**
> "It's flagging any attempts to push sensitive data. Security on autopilot."

**Problem:** This is about security infrastructure, not engineering delivery

---

## Correct Attributions (Per Jorge's Guidance)

### Buck (VP Engineering)

**Responsibilities:**
- Product development
- Engineering projects
- Apps development
- Backend infrastructure
- Engineering delivery
- **Application security** (app-level: authentication, API security, PCI compliance for apps)

**Correct Aha Moment (SHOULD BE):**
- Focus on engineering delivery
- Example: "Infrastructure supports rapid development. Apps deploy smoothly. Team is productive."
- NOT about security automation

**Correct User Journey (SHOULD BE):**
1. Buck deploys new microservice
2. Uses infrastructure to set up CI/CD
3. Configures app-level security (API auth, rate limiting)
4. Tests deployment pipeline
5. Observes smooth engineering delivery
6. **Reaction:** "Engineering infrastructure works. Team can ship fast."

---

### Jorge (VP AI-SecOps)

**Responsibilities:**
- AI infrastructure
- **Security Operations (SecOps)** - infrastructure security
- Security architecture
- **Compliance** (SOC 2, GDPR)
- DevOps automation
- Autonomous agents
- **Security Testing** - adversarial testing of security controls

**Correct Aha Moment:**
- "Implementation working with minimal issues" (current in other docs - correct)

**Correct User Journey (SHOULD INCLUDE SECURITY TESTING):**
- Jorge tests security controls (pre-commit hooks, secret scanning, Dependabot)
- Adversarial testing (attempt commits, bypass hooks, encoded secrets)
- Reviews security dashboard
- **Reaction:** "Security controls work. Infrastructure is protected."

**Note:** Jorge's journey in earlier docs focuses on autonomous agent (correct). Security testing journey should be ADDITIONAL, not replacement.

---

## Documents Requiring Updates

### Priority 1: UX Design Specification (Feb 14)

**Lines 93-100:** Buck's persona
- ✅ Keep: Engineering projects, apps, backend
- ✅ Keep: Application security
- ❌ Remove: "code review, test infrastructure" (or clarify as app-level, not infrastructure)
- ❌ Remove: "compliance" → Move to Jorge

**Lines 846-952:** Journey 3: Buck Tests Security Controls
- ❌ **ENTIRE JOURNEY IS WRONG** - This is Jorge's Security Testing journey
- ✅ **REPLACE with Buck's engineering delivery journey** (new content needed)

**Line 98-99:** Buck's Aha Moment
- ❌ Current: "Security on autopilot"
- ✅ Replace: Engineering delivery focused

---

### Priority 2: User Journeys (Feb 10)

**Check Journey 3:** Buck (VP Engineering) - Security Autopilot (Lines 106-169)
- Verify if this has same issue as UX spec
- If yes, update to engineering delivery focus

---

### Priority 3: Functional Requirements (Feb 10)

**Verify Buck's requirements:**
- Check if any FRs incorrectly assign compliance to Buck
- Move compliance FRs to Jorge if needed

---

### Priority 4: Manual Testing Plan (Feb 13)

**Check Buck's aha moment test:**
- Verify if test is security-focused or engineering-focused
- Update if needed

---

## Recommended Master Document Approach

When creating master documents in Phase 2:

1. **Use earlier docs (Feb 10-13) as primary source** for Buck's role
2. **Discard UX spec (Feb 14) Journey 3** - it's incorrect
3. **Create NEW Buck journey** focused on engineering delivery
4. **Use UX spec (Feb 14) Journey 3** as template for **Jorge's security testing** (additional journey)
5. **Update Buck's aha moment** to engineering delivery focus

---

## Summary

**What Happened:**
- UX spec (Feb 14) created AFTER other docs
- Sally (UX Designer) misattributed Security Testing to Buck
- Buck's entire user journey and aha moment are wrong

**Correct Attribution:**
- Security Testing (adversarial testing of infrastructure security controls) = **Jorge (SecOps)**
- Engineering Delivery (apps, backend, product development) = **Buck (VP Engineering)**
- Application Security (app-level auth, API security) = **Buck (VP Engineering)**
- Compliance (SOC 2, GDPR, audit) = **Jorge (AI-SecOps)**

**Impact:**
- Critical correction needed before MVP implementation
- Buck's success moment needs redefinition
- Jorge's journeys need expansion to include security testing

---

**Status:** Documented for Phase 2 master document creation
