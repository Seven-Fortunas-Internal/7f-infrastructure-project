# Manual Testing Plan: Human Validation Only

**Purpose:** Test aspects that CANNOT be validated autonomously (subjective, aesthetic, adversarial)

**Assumption:** Autonomous agent has already validated 90%+ (repos exist, files valid, workflows run, security enabled)

**Human Testing Time:** 1-2 hours total

---

## Prerequisites (Automated by Agent)

✅ All structural tests passed (repos, files, syntax, API calls)
✅ feature_list.json shows 60-70% "pass" rate
✅ Zero critical failures (all "blocked" features are expected)

**Jorge reviews:** `cat feature_list.json | jq '.features[] | {id, status, blocked_reason}'`

---

## Human Test 1: AI Collaboration Quality (15 min)

**Tester:** Henry (CEO)
**Cannot be tested autonomously:** Conversational quality is subjective

**Test:**
```bash
cd seven-fortunas-brain
claude code
> /7f-brand-system-generator
# Interact conversationally for 10 minutes
```

**Human Evaluation:**
- [ ] AI asks clarifying questions naturally
- [ ] Conversation feels collaborative (not scripted)
- [ ] AI understands context from earlier answers
- [ ] 80% content acceptable (20% refinement needed)
- [ ] **Aha moment:** "AI permeates everywhere; I can shape our ethos easily"

---

## Human Test 2: Architecture Clarity (15 min)

**Tester:** Patrick (CTO)
**Cannot be tested autonomously:** Clarity/comprehensiveness requires human judgment

**Test:**
```bash
cd seven-fortunas-brain
cat docs/architecture/*.md
cat docs/architecture/decisions/ADR-*.md
```

**Human Evaluation:**
- [ ] Architecture docs explain design decisions clearly
- [ ] ADRs provide rationale (not just "what" but "why")
- [ ] Technical approach is sound (no obvious debt)
- [ ] **Aha moment:** "Infrastructure is well done"

---

## Human Test 3: Security Behavior (15 min)

**Tester:** Buck (VP Engineering)
**Cannot be tested autonomously:** Requires adversarial intent

**Test:**
```bash
cd dashboards
echo "ANTHROPIC_API_KEY=sk-ant-fake" > .env
git add .env
git commit -m "test"
# ❌ Should be BLOCKED by pre-commit hook
```

**Human Evaluation:**
- [ ] Pre-commit hook blocks secret commit
- [ ] Attempting bypass (--no-verify) still fails (GitHub Actions)
- [ ] Error messages guide fix
- [ ] **Aha moment:** "Security on autopilot"

---

## Human Test 4: Autonomous Agent Performance (15 min)

**Tester:** Jorge (VP AI-SecOps)
**Cannot be tested autonomously:** Overall validation requires human judgment

**Test:**
```bash
cd 7f-infrastructure-project
cat feature_list.json | jq '.features | group_by(.status) | map({status: .[0].status, count: length})'
```

**Human Evaluation:**
- [ ] 60-70% completion rate (18-25 features "pass")
- [ ] Blocked features are expected (not agent failures)
- [ ] Zero unexpected failures
- [ ] **Aha moment:** "Implementation working with minimal or no issues"

---

## Human Test 5: End-to-End Workflow (30 min)

**Tester:** Henry + Jorge
**Cannot be tested autonomously:** Tests entire user journey experience

**Test:** Generate brand → Create presentation
```bash
# Step 1: Brand generation (Henry)
> /7f-brand-system-generator
# [Conversational session]

# Step 2: Presentation generation (Henry)
> /7f-presentation-generator
# Topic: Seven Fortunas Series A Pitch
# [Conversational session]

# Step 3: Human validation
open presentations/seven-fortunas-pitch.pptx
```

**Human Evaluation:**
- [ ] Workflow feels natural (not clunky)
- [ ] Presentation uses brand colors correctly
- [ ] Slides look professional (visual layouts, not just bullets)
- [ ] Ready to present (80% done, 20% refinement)

---

## Success Criteria (All Human Tests)

**MVP passes human validation if:**
- ✅ 4/5 aha moments achieved (80% threshold)
- ✅ AI collaboration feels natural (not just functional)
- ✅ Content/visual quality acceptable (80% done)
- ✅ Security works as expected (blocks secrets)
- ✅ Overall: "Impressive for 5-day build"

**If any test fails:**
- Document issue
- Assess severity (cosmetic vs. blocking)
- Most issues can be addressed in Days 3-5 refinement

---

## Testing Complete

**Total Human Testing Time:** 1-2 hours
**Autonomous Testing Time:** Built into agent (automatic)

**Next:** Human refinement phase (Days 3-5) → MVP demo (Day 5)
