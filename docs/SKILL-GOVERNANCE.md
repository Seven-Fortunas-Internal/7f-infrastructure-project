# Skill Governance Model

**Feature:** FR-3.4 - Skill Governance (Prevent Proliferation)
**Status:** Implemented
**Version:** 1.0.0
**Date:** 2026-02-17

---

## Purpose

Prevent duplicate skill creation, track usage patterns, and maintain a healthy skill ecosystem through systematic governance.

---

## Governance Principles

### 1. Search Before Create

**Rule:** Always search existing skills before creating a new one.

**Process:**
1. Check `.claude/commands/README.md` by category
2. Search `skills-registry.yaml` by keyword and use case
3. Use `7f-skill-creator` which includes built-in search guidance

**Benefits:**
- Avoid duplication
- Discover existing solutions
- Maintain skill quality

---

### 2. Usage Tracking

**Purpose:** Understand which skills are actually used.

**Implementation:**
- Automatic logging via `scripts/track-skill-usage.sh`
- Log format: `timestamp|skill-name|user|directory`
- Log location: `.claude/commands/.skill-usage.log`

**Metrics Tracked:**
- Total invocations per skill
- Last used timestamp
- Usage frequency (daily/weekly/monthly)
- User patterns

---

### 3. Quarterly Reviews

**Schedule:** Every 90 days

**Review Process:**

#### Step 1: Generate Usage Report

```bash
./scripts/analyze-skill-usage.sh
```

**Output:**
- Top 10 most used skills
- Unused skills (never invoked)
- Stale skills (not used in 90+ days)
- Consolidation candidates (similar names)

#### Step 2: Review Categories

**Review Questions:**
- Are tier assignments still accurate?
- Should any Tier 1 skills be demoted?
- Should any Tier 2 skills be promoted?
- Are there new workflow patterns emerging?

#### Step 3: Deprecation Decisions

**Deprecate skills if:**
- Never used AND >180 days old
- Stale (no use in 90+ days) AND Tier 3
- Superseded by newer skill
- Functionality merged into another skill

**Deprecation Process:**
1. Mark as deprecated in `skills-registry.yaml`
2. Add deprecation notice to skill frontmatter
3. Move to `.claude/commands/deprecated/` directory
4. Document replacement skill (if applicable)
5. Update README and registry

#### Step 4: Consolidation

**Consolidate skills if:**
- Similar names and overlapping functionality
- Can merge with feature flags or options
- Combined use cases still coherent

**Consolidation Process:**
1. Identify consolidation candidates (similar names)
2. Review functionality overlap
3. Design unified interface
4. Migrate to single skill with options
5. Deprecate redundant skills
6. Update documentation

#### Step 5: Documentation Update

**Update:**
- `skills-registry.yaml` - Remove/update deprecated skills
- `.claude/commands/README.md` - Update statistics and listings
- `SKILL-GOVERNANCE.md` - Record decisions and learnings

---

## Governance Roles

### Skill Owner (Jorge)

**Responsibilities:**
- Approve new skill creations
- Review quarterly reports
- Make deprecation decisions
- Maintain governance standards

**Time Commitment:** 2-3 hours per quarter

---

### Skill Curator (Automated)

**Responsibilities:**
- Track usage automatically
- Generate quarterly reports
- Flag consolidation candidates
- Suggest tier adjustments

**Implementation:** Scripts in `scripts/`

---

## Usage Tracking

### How It Works

**Automatic Logging:**
Skills can opt-in to usage tracking by calling:
```bash
./scripts/track-skill-usage.sh <skill-name>
```

**Manual Logging (for testing):**
```bash
# Log a skill invocation
./scripts/track-skill-usage.sh bmad-bmm-create-prd

# View raw log
cat .claude/commands/.skill-usage.log
```

---

### Usage Analytics

**Generate Report:**
```bash
./scripts/analyze-skill-usage.sh
```

**Report Sections:**
1. Total invocations
2. Top 10 most used skills
3. Skills used in last 30 days
4. Unused skills (never invoked)
5. Consolidation candidates
6. Stale skills (90+ days)
7. Governance recommendations

**Example Output:**
```
===================================================================
Seven Fortunas Skill Usage Analysis
===================================================================

Total Skill Invocations: 1,234

Top 10 Most Used Skills:
───────────────────────────────────────────────────────────────
  342 uses  bmad-bmm-create-prd
  198 uses  bmad-bmm-create-story
  156 uses  7f-dashboard-curator
   89 uses  bmad-bmb-code-review
   67 uses  7f-brand-system-generator
   ...

Unused Skills (Never Invoked):
───────────────────────────────────────────────────────────────
  - bmad-cis-summarize.md
  - bmad-bmb-create-docker.md
  ...

Stale Skills (Not Used in 90+ Days):
───────────────────────────────────────────────────────────────
  - bmad-tea-testarch-trace.md (last used >90 days ago)
  ...

Governance Recommendations:
⚠️  MEDIUM PRIORITY: 5 stale skills
   Action: Review Tier 3 skills not used in 90+ days

✅ Next quarterly review: 2026-05-17
```

---

## Consolidation Process

### Identifying Candidates

**Automated Detection:**
`analyze-skill-usage.sh` detects skills with:
- Similar names (2+ shared word components)
- Common prefixes/suffixes
- Related descriptions

**Manual Review:**
- Same category and tier
- Overlapping use cases
- Similar workflow steps

---

### Evaluation Criteria

**Consider consolidation if:**
- ✅ Both skills serve same stakeholder
- ✅ Use cases overlap >50%
- ✅ Can be unified with options/flags
- ✅ Combined complexity is manageable
- ✅ User experience improves

**DON'T consolidate if:**
- ❌ Serve different stakeholders
- ❌ Use cases are distinct
- ❌ Would create overly complex interface
- ❌ Both are high-usage (Tier 1)
- ❌ Different underlying workflows

---

### Consolidation Example

**Before:**
```
bmad-cis-generate-pptx.md  (Generate PowerPoint)
7f-pptx-generator.md       (Generate PowerPoint with 7F branding)
```

**After:**
```
7f-pptx-generator.md
  --template standard      (generic)
  --template seven-fortunas (branded, default)
  --bmad-workflow          (use BMAD CIS workflow)
```

**Result:**
- Single skill with options
- Functionality preserved
- Reduced maintenance burden
- Deprecated: bmad-cis-generate-pptx.md

---

## Quarterly Review Checklist

### Pre-Review (Week 1)

- [ ] Generate usage report (`analyze-skill-usage.sh`)
- [ ] Review tier assignments in `skills-registry.yaml`
- [ ] Identify unused skills (never invoked)
- [ ] Identify stale skills (90+ days)
- [ ] Flag consolidation candidates
- [ ] Gather feedback from users (if applicable)

---

### Review Meeting (Week 2)

**Agenda:**
1. Review usage statistics (15 min)
2. Discuss tier adjustments (15 min)
3. Evaluate deprecation candidates (20 min)
4. Review consolidation opportunities (15 min)
5. Plan actions (10 min)

**Participants:**
- Skill Owner (Jorge)
- Infrastructure Team
- Key stakeholders (Henry, if executive skills affected)

**Outputs:**
- Deprecation decisions
- Consolidation plan
- Tier adjustments
- Action items

---

### Post-Review (Weeks 3-4)

- [ ] Execute deprecations (move to deprecated/)
- [ ] Implement consolidations
- [ ] Update `skills-registry.yaml`
- [ ] Update `.claude/commands/README.md`
- [ ] Document decisions in `SKILL-GOVERNANCE.md`
- [ ] Communicate changes to users

---

## Metrics & KPIs

### Health Metrics

**Skill Proliferation:**
- Target: <120 total skills
- Alert: >150 total skills
- Action: Aggressive consolidation/deprecation

**Unused Skills:**
- Target: <10% unused
- Alert: >20% unused
- Action: Deprecation review

**Stale Skills (Tier 3):**
- Target: <5 skills >90 days
- Alert: >10 skills >90 days
- Action: Deprecation review

**Tier Distribution:**
- Tier 1: 5-10 skills (daily use)
- Tier 2: 20-30 skills (weekly use)
- Tier 3: 10-15 skills (monthly use)

---

### Usage Metrics

**Invocation Frequency:**
- Tier 1 skills: >20 uses/week
- Tier 2 skills: >5 uses/week
- Tier 3 skills: >1 use/month

**Tier Accuracy:**
- Measure: Actual usage vs. tier assignment
- Target: >80% alignment
- Action: Adjust tiers quarterly

---

## Deprecation Policy

### Criteria for Deprecation

**Automatic Deprecation (180 days):**
- Never used AND >180 days old
- Tier 3 AND no use in 180+ days

**Manual Review Required:**
- Stale (90-179 days) Tier 3 skills
- Superseded by newer skills
- Consolidation targets

---

### Deprecation Process

**1. Mark as Deprecated:**
Update skill frontmatter:
```yaml
---
name: 'old-skill'
description: '...'
deprecated: true
deprecated_date: '2026-02-17'
replacement: '7f-new-skill'
deprecation_reason: 'Superseded by 7f-new-skill with better functionality'
---
```

**2. Add Deprecation Notice:**
Add to top of skill:
```markdown
# ⚠️  DEPRECATED

**This skill is deprecated as of 2026-02-17.**

**Replacement:** Use `/7f-new-skill` instead.

**Reason:** Superseded by new skill with better functionality.

---
```

**3. Move to Deprecated Directory:**
```bash
mkdir -p .claude/commands/deprecated/
mv .claude/commands/7f/7f-old-skill.md .claude/commands/deprecated/
```

**4. Update Registry:**
Remove from `skills-registry.yaml` or move to deprecated section.

**5. Update Documentation:**
Update `.claude/commands/README.md` statistics.

**6. Communicate:**
Notify users via:
- Commit message
- Project changelog
- Direct communication (if high-usage skill)

---

## Search-Before-Create Implementation

### Built into 7f-skill-creator

**Process:**
1. User provides YAML definition
2. Skill-creator extracts keywords from:
   - Skill name
   - Purpose/description
   - Use cases
3. Searches existing skills:
   - Fuzzy match on skill names
   - Keyword match in descriptions
   - Use case overlap
4. Displays similar skills:
   ```
   ⚠️  Similar skills found:

   1. bmad-cis-generate-content
      - Description: Generate creative content
      - Use cases: content creation, marketing
      - Similarity: 75%

   2. 7f-brand-system-generator
      - Description: Generate brand system documentation
      - Use cases: brand development, content strategy
      - Similarity: 60%

   Continue with new skill creation? [y/N]:
   ```

5. User decides:
   - Adapt existing skill
   - Create new skill
   - Consolidate with existing

---

### Manual Search Commands

**Search by keyword:**
```bash
grep -i "keyword" .claude/commands/skills-registry.yaml
```

**Search by use case:**
```bash
grep -A 3 "use_cases" .claude/commands/skills-registry.yaml | grep -i "keyword"
```

**Browse by category:**
```bash
ls .claude/commands/{7f,bmm,bmb,cis}/
```

---

## Future Enhancements

### Phase 2: Advanced Analytics

- Usage heatmaps (time of day, day of week)
- User personas (which users use which skills)
- Workflow patterns (skill invocation sequences)
- Success/failure rates per skill

---

### Phase 2: AI-Powered Recommendations

- Semantic similarity detection (not just keyword matching)
- Proactive consolidation suggestions
- Skill recommendation engine (suggest skills based on context)
- Natural language skill search

---

### Phase 2: Automated Governance

- Auto-deprecate skills based on policy
- Auto-adjust tiers based on usage
- Auto-generate consolidation PRs
- CI/CD integration (block PRs with duplicate skills)

---

## Verification

### Functional Criteria ✅

- [x] 7f-skill-creator searches existing skills before creating new
- [x] Usage tracking operational (scripts/track-skill-usage.sh)
- [x] Quarterly review process documented (this file)

### Technical Criteria ✅

- [x] Skill search uses fuzzy matching (similar names detection)
- [x] Usage tracking logs skill invocations (log format defined)
- [x] Consolidation recommendations generated automatically (analyze-skill-usage.sh)

### Integration Criteria ✅

- [x] Skill governance integrates with organization system (FR-3.3)
- [x] Governance metrics tracked (KPIs defined)

---

## References

- Skills Registry: `.claude/commands/skills-registry.yaml`
- Skills README: `.claude/commands/README.md`
- Usage Tracker: `scripts/track-skill-usage.sh`
- Usage Analyzer: `scripts/analyze-skill-usage.sh`
- Validation: `scripts/validate-skills-organization.sh`

---

**Document Version:** 1.0.0
**Last Updated:** 2026-02-17
**Next Review:** 2026-05-17 (Q2 2026)
**Owner:** Jorge (VP AI-SecOps)
**Maintained By:** Seven Fortunas Infrastructure Team
