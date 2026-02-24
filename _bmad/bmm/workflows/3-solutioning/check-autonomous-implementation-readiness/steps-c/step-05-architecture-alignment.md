---
name: 'step-05-architecture-alignment'
description: 'Check PRD and app_spec.txt alignment with architecture'

nextStepFile: './step-06-feature-quality.md'
outputFile: '{output_folder}/readiness-assessment-{project_name}.md'

advancedElicitationTask: '{project-root}/_bmad/core/workflows/advanced-elicitation/workflow.xml'
partyModeWorkflow: '{project-root}/_bmad/core/workflows/party-mode/workflow.md'
---

# Step 5: Architecture Alignment

## STEP GOAL:

To verify that PRD requirements and app_spec.txt features align with architectural constraints, decisions, and technical standards documented in architecture documentation.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Software Architect validating architectural compliance
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in architecture patterns and technical constraints
- ✅ User brings knowledge of project-specific architectural decisions
- ✅ Together we ensure architectural coherence

### Step-Specific Rules:

- 🎯 Focus ONLY on architectural alignment - not implementation details
- 🚫 FORBIDDEN to propose new architecture - validate against existing
- 💬 Reference specific ADRs, design docs, or architecture sections
- 🎯 Flag conflicts between requirements and architectural constraints

## EXECUTION PROTOCOLS:

- 🎯 Validate alignment with documented architecture
- 💾 Append architecture alignment section to output file
- 📖 Update frontmatter with architecture_alignment_score
- 🚫 If no architecture docs provided, note limitations in assessment

## CONTEXT BOUNDARIES:

- Available: PRD, app_spec.txt, architecture docs (if provided)
- Focus: Compliance with architectural constraints
- Limits: Don't design new architecture - validate existing
- Dependencies: Coverage analysis from step-04

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Check Architecture Documentation Availability

Read `{outputFile}` frontmatter to get `architecture_docs` array.

**IF architecture_docs is empty:**

Display:

"**⚠️ No Architecture Documentation Provided**

Architecture alignment assessment will be limited without formal architecture documentation.

**I can still check for:**
- Common architectural anti-patterns in requirements
- Technology stack consistency (if mentioned in PRD/app_spec)
- Basic architectural concerns (scalability, security, modularity)

**However, I cannot validate:**
- Compliance with specific ADRs
- Alignment with documented design patterns
- Adherence to project-specific technical standards

**Would you like to:**
[A] Proceed with limited architecture assessment
[P] Provide architecture documentation path now
[S] Skip architecture alignment (score will reflect unavailability)

Please select: [A/P/S]"

Handle response appropriately. If [P], gather path and load doc.

**IF architecture_docs is provided:**

Display: "**Loading architecture documentation for alignment validation...**"

Load all architecture documents.

### 2. Extract Architectural Constraints

**From architecture documentation, extract:**
- Technology stack requirements (languages, frameworks, databases)
- Design patterns mandated (microservices, monolith, event-driven, etc.)
- Integration patterns (APIs, messaging, data sync)
- Security requirements (authentication, authorization, encryption)
- Scalability constraints (horizontal/vertical scaling, stateless/stateful)
- Deployment constraints (cloud providers, containerization, CI/CD)

**From ADRs specifically, extract:**
- Decisions made (with ADR numbers)
- Rationale for decisions
- Consequences and trade-offs

Present extracted constraints:

"**Architectural Constraints Identified:**

**Technology Stack:**
- {List required/mandated technologies}

**Design Patterns:**
- {List mandated patterns}

**Key ADRs:**
- ADR-001: {Decision summary}
- ADR-002: {Decision summary}

**Critical Constraints:**
- {List non-negotiable architectural constraints}"

### 3. Validate PRD Alignment with Architecture

Check PRD requirements against architectural constraints:

**Check for conflicts:**
- Do any FRs/NFRs contradict architectural decisions?
- Do requirements assume technologies not in the stack?
- Are scalability requirements achievable with chosen architecture?

**Present findings:**

"**PRD Architectural Alignment:**

✅ **Aligned Requirements ({count}):**
- {FR/NFR-ID}: {Description} - Aligns with {ADR/Architecture pattern}

⚠️ **Potential Conflicts ({count}):**
- {FR/NFR-ID}: {Description} - Conflicts with {ADR/Constraint}: {Explanation}

❌ **Clear Violations ({count}):**
- {FR/NFR-ID}: {Description} - Violates {ADR/Constraint}: {Explanation}"

### 4. Validate app_spec.txt Alignment with Architecture

Check app_spec.txt features against architectural constraints:

**Check for architectural violations:**
- Do features propose technologies outside the stack?
- Do features violate design patterns?
- Do features ignore security/scalability constraints?

**Present findings:**

"**app_spec.txt Architectural Alignment:**

✅ **Architecturally Compliant Features ({count}):**
- {Feature Name}: {Compliance reason}

⚠️ **Architectural Concerns ({count}):**
- {Feature Name}: {Concern} - May conflict with {ADR/Constraint}

❌ **Architectural Violations ({count}):**
- {Feature Name}: {Violation description} - Violates {ADR/Constraint}"

### 5. Check Technology Stack Consistency

Verify technology consistency across PRD, app_spec.txt, and architecture:

**Technology mentions:**
- PRD mentions: {List technologies}
- app_spec.txt mentions: {List technologies}
- Architecture specifies: {List technologies}

**Consistency check:**
✅ All technologies aligned across documents
⚠️ Technology mismatches found: {List mismatches}

### 6. Calculate Architecture Alignment Score

**Scoring:**
- No architecture docs: Score 50 (baseline, note limitations)
- All requirements/features align: 90-100
- Minor concerns, no violations: 70-89
- Some violations, mostly resolved: 50-69
- Major violations unresolved: 0-49

**Architecture Alignment Score:** {score}/100

### 7. Identify Architectural Risks

List risks to implementation success:

"**Architectural Risks Identified:**

1. **{Risk Category}**: {Description}
   - Impact: {High/Medium/Low}
   - Mitigation: {Recommendation}

2. **{Risk Category}**: {Description}
   - Impact: {High/Medium/Low}
   - Mitigation: {Recommendation}"

### 8. Append Architecture Alignment to Output File

Update `{outputFile}` by appending:

```markdown
### 3. Architecture Alignment Assessment

**Alignment Score:** {score}/100

**Architectural Compliance:**
- {Areas where PRD/app_spec align with architecture}

**Misalignments:**
- {Areas where PRD/app_spec conflict with architecture}

**Technology Stack Consistency:**
- PRD Technologies: {list}
- app_spec Technologies: {list}
- Architecture Technologies: {list}
- Consistency: {✅ Aligned / ⚠️ Mismatches found}

**Key ADRs Validated:**
- ADR-{number}: {Decision} - {Compliance status}
- ADR-{number}: {Decision} - {Compliance status}

**Architectural Risks:**
- {Risk 1}: {Impact} - {Mitigation}
- {Risk 2}: {Impact} - {Mitigation}

**Recommendation:**
- {Specific recommendations for resolving misalignments}

---
```

Update frontmatter:
```yaml
analysis_phase: 'architecture-alignment-complete'
architecture_alignment_score: {score}
architectural_violations_count: {count}
```

### 9. Present Findings and Confirm

Present summary:

"**Architecture Alignment Assessment Complete**

**Alignment Score:** {score}/100

**Summary:**
- Compliant Requirements/Features: {count}
- Architectural Concerns: {count}
- Architectural Violations: {count}

**Critical Findings:** {Any major architectural violations that block implementation}

**Assessment:** {Requirements/features are architecturally sound / Violations require resolution}

**Next:** Feature Quality Review - We'll evaluate feature specifications for autonomous agent execution."

### 10. Present MENU OPTIONS

Display: **Select an Option:** [A] Advanced Elicitation [P] Party Mode [C] Continue to Feature Quality Review

#### EXECUTION RULES:

- ALWAYS halt and wait for user input after presenting menu
- ONLY proceed to next step when user selects 'C'
- After other menu items execution, return to this menu
- User can chat or ask questions - always respond and redisplay menu

#### Menu Handling Logic:

- IF A: Execute {advancedElicitationTask}
- IF P: Execute {partyModeWorkflow}
- IF C: Update frontmatter analysis_phase to 'feature-quality', then load, read entire file, then execute {nextStepFile}
- IF Any other: Help user respond, then redisplay menu

## 🚨 SYSTEM SUCCESS/FAILURE METRICS:

### ✅ SUCCESS:

- Architecture documentation availability checked
- Architectural constraints extracted (if docs available)
- PRD alignment validated with specific examples
- app_spec.txt alignment validated with specific examples
- Conflicts and violations identified with ADR/constraint references
- Alignment score calculated
- Analysis appended to output file
- Frontmatter updated

### ❌ SYSTEM FAILURE:

- Not checking for architecture docs availability
- Generic alignment assessment without specific references
- Missing conflict identification
- Not noting limitations when architecture docs unavailable
- Not appending analysis to output file

**Master Rule:** Architectural alignment must reference specific ADRs, design patterns, or constraints. Generic statements like "seems aligned" are FORBIDDEN. When architecture docs unavailable, explicitly note limitations.
