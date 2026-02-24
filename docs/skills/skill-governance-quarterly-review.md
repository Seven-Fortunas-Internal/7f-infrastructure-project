# Skill Governance: Quarterly Review Process

**Owner:** Jorge (VP AI-SecOps)
**Frequency:** Quarterly (every 90 days)
**Purpose:** Prevent skill proliferation, maintain quality, consolidate duplicates

---

## Process Overview

Every quarter, the Seven Fortunas team reviews skill usage patterns to:
1. Identify and deprecate unused/stale skills
2. Consolidate duplicate or similar skills
3. Promote high-value skills to higher tiers
4. Update documentation and governance metrics

---

## Step 1: Generate Usage Report

**Timeline:** Day 1 of quarter
**Owner:** Automation / Jorge

```bash
cd /home/ladmin/dev/GDF/7F_github
./scripts/analyze-skill-usage.sh > reports/skill-usage-Q$(date +%q)-$(date +%Y).txt
```

**Output:**
- Total invocations
- Top 10 most used skills
- Unused skills (never invoked)
- Stale skills (not used in 90+ days)
- Consolidation candidates (similar names/descriptions)
- Governance recommendations

---

## Step 2: Review Unused Skills

**Timeline:** Day 2-5 of quarter
**Owner:** Jorge + Team

For each unused skill:
- [ ] Determine if it was created for specific scenario (not yet encountered)
- [ ] Check if it was superseded by another skill
- [ ] Decide: **Keep**, **Deprecate**, or **Merge** with similar skill

**Actions:**
- **Keep:** Add usage notes to skills-registry.yaml, document use case clearly
- **Deprecate:** Move to `.claude/commands/.deprecated/` with deprecation date
- **Merge:** Consolidate functionality into related skill, add redirect

---

## Step 3: Review Stale Skills (90+ Days)

**Timeline:** Day 6-10 of quarter
**Owner:** Jorge + Team

For each stale skill:
- [ ] Was it used previously? (Check usage log history)
- [ ] Is it seasonal/periodic? (e.g., quarterly reporting skills)
- [ ] Has business need changed?
- [ ] Is it Tier 3 (monthly use) - acceptable to be stale

**Actions:**
- **Keep (Tier 3):** Document periodic usage pattern
- **Downgrade:** Move from Tier 2 → Tier 3 if usage dropped
- **Deprecate:** If no longer needed, move to `.deprecated/`

---

## Step 4: Consolidation Review

**Timeline:** Day 11-15 of quarter
**Owner:** Jorge + Team

For each consolidation candidate:
- [ ] Do both skills serve distinct purposes?
- [ ] Is one a specialization of the other?
- [ ] Can functionality be merged without loss?

**Consolidation Strategy:**
1. **Merge similar skills:** Combine into single skill with flags/options
2. **Create skill family:** Keep separate but cross-reference in docs
3. **Redirect deprecated → canonical:** Update old skill to call new one

**Example:**
```bash
# Old skill: 7f-create-dashboard.md
# New skill: 7f-dashboard-curator.md (more comprehensive)
# Action: Deprecate old skill, add redirect to new skill
```

---

## Step 5: Tier Adjustments

**Timeline:** Day 16-18 of quarter
**Owner:** Jorge

Based on usage data:
- **Promote to higher tier:** Skills used more frequently than tier suggests
- **Demote to lower tier:** Skills used less frequently than tier suggests

**Tier Definitions:**
- **Tier 1 (Daily):** 15+ uses/week
- **Tier 2 (Weekly):** 3-14 uses/week
- **Tier 3 (Monthly):** 1-12 uses/month

**Update:** Modify skills-registry.yaml with new tier assignments

---

## Step 6: Documentation Updates

**Timeline:** Day 19-20 of quarter
**Owner:** Jorge

- [ ] Update `.claude/commands/README.md` with tier changes
- [ ] Document deprecated skills in `.deprecated/CHANGELOG.md`
- [ ] Update skills-registry.yaml with new metadata
- [ ] Regenerate skill organization docs

---

## Step 7: Commit and Communicate

**Timeline:** Day 21 of quarter
**Owner:** Jorge

```bash
# Commit changes
git add .claude/commands/
git commit -m "chore: Q$(date +%q)-$(date +%Y) skill governance review

- Deprecated: [list]
- Consolidated: [list]
- Tier changes: [list]
- Metrics: [summary]
"

# Communicate to team
# - Post summary in team chat
# - Update skill governance dashboard
# - Send email with changes
```

---

## Metrics Tracked

### Usage Metrics
- Total skill invocations (quarter vs. previous quarter)
- Average invocations per skill
- Top 10 most used skills
- Unused skill count
- Stale skill count (90+ days)

### Governance Metrics
- Skills deprecated this quarter
- Skills consolidated this quarter
- Tier changes (promotions/demotions)
- Consolidation candidates remaining
- Skill proliferation rate (new skills created vs. deprecated)

### Quality Metrics
- Skills with documented use cases (% of total)
- Skills with tier assignments (% of total)
- Skills with last-used date (% of total)
- Average skill age (creation date to now)

---

## Automation Opportunities

Future enhancements to reduce manual effort:

1. **Auto-flag stale skills:** GitHub Action runs monthly, creates issues for stale skills
2. **Usage dashboard:** Real-time metrics visible in 7F Lens
3. **Deprecation workflow:** Automated process to deprecate skill (move file, update docs, notify)
4. **Fuzzy matching:** Detect similar skill names during creation (prevent duplicates upfront)
5. **Quarterly review reminder:** Calendar invite + pre-generated report

---

## Related Documents

- `.claude/commands/README.md` - Skill organization structure
- `.claude/commands/skills-registry.yaml` - Complete skill registry with tiers
- `scripts/analyze-skill-usage.sh` - Usage analysis script
- `scripts/track-skill-usage.sh` - Usage tracking script
- `.claude/commands/.deprecated/CHANGELOG.md` - Deprecated skills history

---

**Last Updated:** 2026-02-23
**Next Review:** Q2 2026 (April 1, 2026)
