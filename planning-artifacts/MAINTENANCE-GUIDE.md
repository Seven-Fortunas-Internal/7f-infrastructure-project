# Master Documents Maintenance Guide

**Purpose:** How to maintain and update the 6 master planning documents
**Audience:** Future agents, Jorge, team members
**Version:** 1.0

---

## Golden Rule: Update Masters, Don't Create New Docs

**DO:** Update existing master documents when information changes
**DON'T:** Create parallel documents that compete with masters

**Exception:** Temporary artifacts (spikes, POCs, phase-specific) can be separate docs

---

## When to Update Which Master

### master-product-strategy.md
**Update when:**
- Vision, mission, or strategic goals change
- New success metrics or aha moments added
- Stakeholder responsibilities evolve
- Product scope changes (new phases, features)
- Strategic timeline shifts
- Risk mitigation strategies change

**How to update:**
1. Read current version
2. Locate relevant section
3. Edit with clear explanation of change
4. Update document version in frontmatter
5. Add entry to CHANGELOG.md
6. Commit with descriptive message

**Example:**
```bash
# Read current
cat master-product-strategy.md | grep -A 5 "Henry (CEO)"

# Edit
# ... make changes ...

# Document
echo "## [1.1.0] - $(date +%Y-%m-%d) - Updated Henry's aha moment target (30 min → 20 min)" >> CHANGELOG.md

# Commit
git add master-product-strategy.md CHANGELOG.md
git commit -m "Update Henry's aha moment target

Reduced from 30 minutes to 20 minutes based on voice input improvements.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### master-requirements.md
**Update when:**
- New functional requirements (FRs) added → **Track as "growing list"**
- New non-functional requirements (NFRs) added → **Track as "growing list"**
- Existing requirements modified (acceptance criteria refined)
- Requirements deprecated (mark as such, don't delete)

**How to update:**
1. Identify correct FR/NFR category (1-7)
2. Add new requirement with next sequential number (e.g., FR-1.7 if FR-1.6 exists)
3. Include acceptance criteria, priority, owner
4. Update "Total Requirements" count in Executive Summary
5. Update CHANGELOG.md
6. Commit

**Example:**
```markdown
**FR-1.7: GitHub Advanced Security**
- **Requirement:** System SHALL enable GitHub Advanced Security (CodeQL, custom secret patterns)
- **Acceptance Criteria:**
  - ✅ CodeQL analysis runs on all PRs
  - ✅ Custom secret patterns configured (internal API keys, tokens)
  - ✅ Security dashboard shows Advanced Security metrics
- **Priority:** P2 (Phase 3)
- **Owner:** Jorge (SecOps)
```

**Update count:**
```markdown
**Total Requirements:** 49 → 50 (29 FRs + 21 NFRs)
```

---

### master-ux-specifications.md
**Update when:**
- User journeys change (new aha moments, modified flows)
- New interaction patterns identified
- Component specifications evolve
- UX principles change
- Accessibility requirements update

**How to update:**
1. Locate relevant section (User Personas, Core User Flows, Component Specs, Interaction Patterns)
2. Edit with clear rationale
3. If changing aha moments, validate with stakeholder first
4. Update CHANGELOG.md
5. Commit

**CRITICAL:** Don't change Buck/Jorge role attributions without Jorge's approval

---

### master-architecture.md
**Update when:**
- New Architectural Decision Records (ADRs) created
- System architecture changes (new components, integrations)
- Technology stack evolves (version upgrades, new tools)
- Security architecture updates (new layers, controls)
- Scalability targets change

**How to update ADRs:**
1. Add new ADR with sequential number (ADR-006, ADR-007, etc.)
2. Follow format: Decision, Rationale, Consequences
3. Reference in relevant master sections
4. Update CHANGELOG.md
5. Commit

**Example:**
```markdown
### ADR-006: Vector Search for Second Brain
**Decision:** Use Anthropic Claude API embeddings for semantic search (not local embeddings)
**Rationale:** Reduces infrastructure complexity, leverages Claude's understanding, cost-effective (<$10/month)
**Consequences:** Dependency on Claude API, but acceptable for Phase 2 scalability needs
```

---

### master-implementation.md
**Update when:**
- Timeline changes (MVP shifted, new phases added)
- Autonomous agent setup evolves
- Testing plan updates
- Deployment strategy changes (tier upgrades)
- Dependencies or risks change

**How to update:**
1. Update relevant timeline section
2. If changing release criteria, explain why
3. Update CHANGELOG.md with rationale
4. Commit

**Example:** If MVP extends from 5 days to 7 days:
```markdown
## Timeline: 7-Day MVP (Days 0-6) ← Updated from 5 days

**Rationale:** Autonomous agent completed 55% (below 60-70% target), requiring 2 additional days for Jorge's manual implementation.
```

---

### master-bmad-integration.md
**Update when:**
- New skills added (BMAD adopted, adapted, or custom) → **Track as "growing list"**
- Skills deprecated or consolidated
- BMAD version upgraded
- Usage patterns change
- Governance policies update

**How to update:**
1. Add new skill to appropriate category (BMAD/Adapted/Custom)
2. Update total skill count
3. Update CHANGELOG.md
4. Commit

**Example:**
```markdown
### 8 Custom Skills (Built from Scratch) ← Updated from 3

...

27. **7f-github-ops**
    - Purpose: Advanced GitHub operations (create org, configure teams, permissions)
    - Why Custom: Complex orchestration, Seven Fortunas-specific patterns
    - Owner: Jorge
```

**Update count:**
```markdown
## Available Skills (29 Total) ← Updated from 26

- 18 BMAD Skills (Adopted As-Is)
- 5 Adapted Skills (BMAD-Based, Customized)
- 6 Custom Skills (Built from Scratch) ← Updated from 3
```

---

## When to Create a New Document (Not Update Master)

**Create separate document when:**
- ✅ Temporary artifact (spike, POC, experiment)
- ✅ Phase-specific content (Phase 1.5 SOC 2 Mapping Spreadsheet)
- ✅ Reference material (not core planning)
- ✅ Working document (not final, not authoritative)

**Examples:**
- `phase-1.5-soc2-mapping.xlsx` (temporary, phase-specific)
- `phase-2-dashboard-mockups.pdf` (reference material)
- `spike-vector-search-comparison.md` (experiment, not final decision)

**Do NOT create:**
- ❌ `requirements-v2.md` (update master-requirements.md instead)
- ❌ `new-architecture-decisions.md` (add ADRs to master-architecture.md)
- ❌ `updated-timeline.md` (update master-implementation.md)

---

## Update Process Checklist

**For every master update:**
- [ ] Read current version first
- [ ] Make changes with clear rationale
- [ ] Update document version in frontmatter (if major change)
- [ ] Update index.md if document structure changed significantly
- [ ] Add entry to CHANGELOG.md (date, what changed, why)
- [ ] Commit with descriptive message
- [ ] Push to GitHub (if working in repo)

**For critical changes (role attributions, success criteria, architecture decisions):**
- [ ] Discuss with Jorge before updating
- [ ] Document approval in commit message
- [ ] Notify team of change (Slack, email)

---

## Version Numbering

**Semantic versioning for masters:**
- **Major (1.0 → 2.0):** Significant restructuring, role changes, scope changes
- **Minor (1.0 → 1.1):** New requirements, ADRs, skills (growing lists)
- **Patch (1.1.0 → 1.1.1):** Typo fixes, clarifications, formatting

**Update version in frontmatter:**
```yaml
---
version: 1.1.0  # Updated from 1.0.0
---
```

---

## Git Commit Convention

**Format:**
```
<type>: <brief description>

<detailed explanation>

<rationale/context>

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Types:**
- `feat:` New requirement, skill, ADR
- `update:` Modify existing content
- `fix:` Correct error or clarify
- `docs:` Documentation-only change
- `refactor:` Restructure without changing content

**Example:**
```
feat: Add FR-5.6 for CISO Assistant integration

Added new functional requirement FR-5.6 under Security & Compliance
category for Phase 1.5 CISO Assistant integration.

Includes acceptance criteria for GitHub → CISO Assistant evidence sync,
control mapping, and real-time compliance dashboard.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## Avoiding Document Proliferation

**Problem:** Over time, teams create parallel docs (requirements-v2, architecture-new, etc.) that compete with masters

**Solution:**
1. **Search first:** Before creating doc, search for existing master
2. **Update master:** Default to updating existing master, not creating new
3. **Consult index:** Check index.md to see which master covers your topic
4. **Ask:** If unsure, ask Jorge or check CLAUDE.md

**Quarterly review (Jorge):**
- Audit for parallel documents
- Consolidate or archive duplicates
- Update masters with any missed information

---

## Contact

**Questions about maintenance:** Jorge (VP AI-SecOps)
**AI agent issues:** See CLAUDE.md for agent-specific guidance
**Process questions:** Reference DOCUMENT-SYNC-EXECUTION-PLAN.md (archived)

---

**Guide Version:** 1.0
**Last Updated:** 2026-02-15
**Owner:** Jorge (VP AI-SecOps)
