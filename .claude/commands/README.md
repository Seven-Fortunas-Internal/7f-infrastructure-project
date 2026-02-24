# Seven Fortunas Skills Directory

**Organization:** Skills are organized by category and tier to prevent proliferation and ensure discoverability.

**Registry:** See `skills-registry.yaml` for complete skill catalog with tiers and use cases.

---

## Directory Structure

```
.claude/commands/
├── 7f/                          # Seven Fortunas Custom Skills (7 skills)
├── bmm/                         # Business Method Module (47 skills)
├── bmb/                         # Builder Module (20 skills)
├── cis/                         # Creative Intelligence System (15 skills)
├── skills-registry.yaml         # Complete registry with tier assignments
├── README.md                    # This file
└── [utility skills]             # Cross-cutting utilities (help, index, etc.)
```

---

## Skill Categories

### 7f/ - Seven Fortunas Custom Skills

**Purpose:** Custom skills designed specifically for Seven Fortunas workflows

**Key Skills:**
- `7f-dashboard-curator` (Tier 1) - Manage 7F Lens dashboard content
- `7f-brand-system-generator` (Tier 2) - Generate brand documentation
- `7f-excalidraw-generator` (Tier 2) - Create diagrams from text
- `7f-pptx-generator` (Tier 2) - Generate PowerPoint presentations
- `7f-repo-template` (Tier 2) - Create standardized repositories
- `7f-sop-generator` (Tier 2) - Generate Standard Operating Procedures
- `7f-skill-creator` (Tier 3) - Create new skills from YAML

**Naming Convention:** `7f-{skill-name}.md`

**Usage:** `/7f-skill-name`

---

### bmm/ - Business Method Module

**Purpose:** BMAD skills for business analysis, planning, and project management

**Key Skills (Tier 1 - Daily Use):**
- `bmad-bmm-create-prd` - Create Product Requirements Document
- `bmad-bmm-create-architecture` - Create architecture documentation
- `bmad-bmm-create-story` - Create user stories
- `bmad-bmm-create-epics-and-stories` - Create both epics and stories

**Key Skills (Tier 2 - Weekly Use):**
- `bmad-bmm-create-epic` - Create epics from PRD
- `bmad-bmm-create-product-brief` - Create product brief
- `bmad-bmm-create-sop` - Create SOPs
- `bmad-bmm-create-app-spec` - Create app_spec.txt from PRD

**Naming Convention:** `bmad-bmm-{skill-name}.md`

**Usage:** `/bmad-bmm-skill-name`

---

### bmb/ - Builder Module

**Purpose:** BMAD skills for workflow creation, validation, and infrastructure

**Key Skills (Tier 1 - Daily Use):**
- `bmad-bmb-code-review` - Perform structured code review

**Key Skills (Tier 2 - Weekly Use):**
- `bmad-bmb-create-workflow` - Create new BMAD workflow
- `bmad-bmb-validate-workflow` - Validate workflow structure
- `bmad-bmb-create-github-repo` - Create GitHub repository
- `bmad-bmb-configure-ci-cd` - Configure CI/CD pipelines
- `bmad-bmb-create-test` - Create test suite

**Naming Convention:** `bmad-bmb-{skill-name}.md`

**Usage:** `/bmad-bmb-skill-name`

---

### cis/ - Creative Intelligence System

**Purpose:** BMAD skills for creative content generation and problem solving

**Key Skills (Tier 2 - Weekly Use):**
- `bmad-cis-generate-content` - Generate creative content
- `bmad-cis-brand-voice` - Define brand voice guidelines
- `bmad-cis-generate-pptx` - Generate PowerPoint presentations
- `bmad-cis-generate-diagram` - Generate diagrams
- `bmad-cis-summarize` - Create document summaries

**Naming Convention:** `bmad-cis-{skill-name}.md`

**Usage:** `/bmad-cis-skill-name`

---

## Skill Tiers

Skills are organized into 3 tiers based on expected usage frequency:

### Tier 1: Daily Use (7 skills)

**Usage:** Multiple times per day
**Examples:** create-prd, create-story, code-review, dashboard-curator

**Characteristics:**
- Core workflow skills
- Essential for day-to-day operations
- High priority for maintenance and updates

### Tier 2: Weekly Use (24 skills)

**Usage:** Regularly but not daily
**Examples:** create-epic, brand-system-generator, create-workflow, generate-pptx

**Characteristics:**
- Important but not constantly needed
- Project-specific or phase-specific
- Medium priority for maintenance

### Tier 3: Monthly Use (4 skills)

**Usage:** Specialized scenarios, occasional need
**Examples:** skill-creator, transcribe-audio, create-docker

**Characteristics:**
- Specialized or advanced use cases
- Setup/configuration skills
- Lower priority but still maintained

---

## Search-Before-Create Guidance

**IMPORTANT:** Before creating a new skill, search existing skills to avoid duplication.

### How to Search

**1. Browse this README:**
- Review skills by category
- Check skill descriptions and use cases

**2. Search skills-registry.yaml:**
```bash
# Search by keyword
grep -i "keyword" skills-registry.yaml

# Search by use case
grep -A 3 "use_cases" skills-registry.yaml | grep -i "keyword"
```

**3. List all skills:**
```bash
# List all 7F skills
ls 7f/

# List all BMM skills
ls bmm/

# List all BMB skills
ls bmb/

# List all CIS skills
ls cis/
```

### When to Create a New Skill

**Create a new skill when:**
- ✅ No existing skill covers the use case
- ✅ Existing skill is too generic and needs specialization
- ✅ New workflow pattern emerges from repeated tasks
- ✅ Seven Fortunas-specific customization is needed

**DON'T create a new skill when:**
- ❌ Similar skill exists (adapt the existing one instead)
- ❌ Use case is one-time or rare (use manual approach)
- ❌ Skill would have <3 distinct use cases
- ❌ Functionality can be added to existing skill as option/flag

### Skill Creation Process

**1. Define in YAML first:**
```bash
/7f-skill-creator skill-definition.yaml
```

**2. Review generated skill:**
- Check naming convention
- Verify category placement
- Ensure no duplication

**3. Assign tier:**
- Tier 1: Will use multiple times per day
- Tier 2: Will use weekly
- Tier 3: Specialized/occasional use

**4. Update skills-registry.yaml:**
- Add skill to appropriate category
- Document use cases
- Assign tier

**5. Test skill:**
- Invoke skill and verify it works
- Test error handling
- Validate integration points

---

## Governance Rules

### Naming Conventions

**Seven Fortunas Custom Skills:**
- Format: `7f-{skill-name}.md`
- Example: `7f-dashboard-curator.md`
- Location: `7f/` directory

**BMAD Skills:**
- Format: `bmad-{module}-{skill-name}.md`
- Example: `bmad-bmm-create-prd.md`
- Location: `{module}/` directory (bmm/, bmb/, cis/)

### Directory Enforcement

**Validation script (future):** `scripts/validate-skills-organization.sh`

**Rules:**
- All skills must be in correct category directory
- No orphaned skills in root (except utilities)
- Naming convention must be followed
- All skills must be registered in skills-registry.yaml

### Tier Assignment

**Guidelines:**
- Tier 1: Used multiple times per day by most users
- Tier 2: Used regularly but not daily
- Tier 3: Specialized, occasional, or setup/configuration

**Review frequency:**
- Quarterly: Review tier assignments
- Adjust based on actual usage patterns
- Promote/demote skills as needed

---

## Skill Statistics

**Total Skills:** 99

**By Category:**
- 7F (Custom): 7 skills
- BMM (Business): 47 skills
- BMB (Builder): 20 skills
- CIS (Creative): 15 skills
- Utilities: 10 skills

**By Tier:**
- Tier 1 (Daily): 7 skills
- Tier 2 (Weekly): 24 skills
- Tier 3 (Monthly): 4 skills
- Not yet tiered: 64 skills (legacy BMAD skills, agents, utilities)

---

## Integration with Governance (FR-3.4)

**Skill organization supports:**
- Discoverability: Browse by category and tier
- Governance: Enforce naming and structure rules
- Quality: Review before create guidance
- Maintenance: Priority based on tier
- Usage tracking: Monitor tier accuracy

**See also:** FR-3.4 Governance model documentation

---

## Usage Examples

### Find a Skill

```bash
# Browse 7F skills
ls 7f/

# Search for diagram skills
grep -r "diagram" skills-registry.yaml

# Find Tier 1 (daily use) skills
grep -B 2 "tier: 1" skills-registry.yaml | grep "name:"
```

### Invoke a Skill

```bash
# Seven Fortunas custom skill
/7f-dashboard-curator

# BMAD business skill
/bmad-bmm-create-prd

# BMAD builder skill
/bmad-bmb-code-review
```

### Create a New Skill

```bash
# 1. Create YAML definition
cat > new-skill.yaml <<EOF
skill:
  name: 7f-example
  purpose: Example skill
  category: 7f
  # ... (full definition)
EOF

# 2. Generate skill
/7f-skill-creator new-skill.yaml

# 3. Verify placement
ls 7f/7f-example.md

# 4. Update registry
# Edit skills-registry.yaml to add new skill with tier
```

---

## Maintenance

**Quarterly Tasks:**
1. Review tier assignments (usage vs. tier)
2. Check for duplicate/similar skills
3. Update descriptions in registry
4. Archive unused skills (Tier 3 with no usage)
5. Update this README with current statistics

**On Skill Creation:**
1. Place in correct category directory
2. Follow naming convention
3. Add to skills-registry.yaml
4. Assign appropriate tier
5. Document use cases

**On Skill Deprecation:**
1. Mark as deprecated in registry
2. Move to `deprecated/` directory
3. Update README to reflect removal
4. Communicate to users

---

**Document Version:** 1.0.0
**Last Updated:** 2026-02-17
**Maintained By:** Seven Fortunas Infrastructure Team
**Registry:** skills-registry.yaml
