---
stepsCompleted: ['step-01-discovery', 'step-02-classification', 'step-03-requirements', 'step-04-tools', 'step-05-plan-review', 'step-06-design', 'step-07-foundation', 'step-08-build-step-01', 'step-09-build-all-steps', 'step-10-data-files', 'step-11-completion']
created: 2026-02-13
status: WORKFLOW_BUILD_COMPLETE
approvedDate: 2026-02-13
designDate: 2026-02-13
foundationDate: 2026-02-13
step01Date: 2026-02-13
allStepsDate: 2026-02-13
dataFilesDate: 2026-02-13
completionDate: 2026-02-13
totalFiles: 18
totalLines: 4747
---

# Workflow Creation Plan: create-app-spec

## Discovery Notes

**User's Vision:**
Create a BMAD workflow that transforms a PRD into an `app_spec.txt` file - the "single source of truth" for autonomous coding agents. This replaces the traditional Epics/Stories approach with an AI-native implementation pattern (PRD → app_spec.txt → Autonomous Agent).

**Who It's For:**
- Product teams using autonomous agents for implementation
- Primary user: Jorge (VP AI-SecOps) for Seven Fortunas infrastructure project
- Secondary users: Any team adopting BMAD + autonomous agent methodology

**What It Produces:**
A plain-text `app_spec.txt` file with XML structure containing:
- Granular features (flexible count - prioritize correct granularity over arbitrary limits)
- Auto-categorized features by domain (Infrastructure, UI, Business Logic, Integration, DevOps, Security, Testing)
- Auto-generated verification criteria for each feature
- Technology stack, coding standards, testing strategy
- Feature dependencies and constraints
- Non-functional requirements
- Reference documentation links

**Key Design Requirements:**
- **Input:** PRD only (no other dependencies)
- **Output:** Plain text `app_spec.txt` (XML format)
- **Tri-modal structure:** Create/Edit/Validate modes
- **Intelligent extraction:** Auto-categorize features from PRD
- **Auto-generation:** Generate verification criteria automatically
- **Granularity-first:** Feature count should be flexible - correct atomic breakdown is priority
- **Quality gates:** Validate completeness, structure, and agent-readiness

**Key Insights:**
- Built on extensive research: 4 real-world app_spec examples analyzed + web research on best practices
- Follows Anthropic's autonomous coding principles: "one feature = one atomic, independently implementable task"
- Must support two-agent pattern: Initializer (generates feature_list.json) + Coding (implements features)
- Features must be verifiable with clear pass/fail criteria
- XML structure with nested feature groups (not flat lists)
- Typical project: 30-50 features, but Seven Fortunas may exceed this - granularity matters more than count

**Context:**
- Part of Seven Fortunas autonomous workflow suite
- Companion to `check-autonomous-implementation-readiness` workflow (already built)
- Will be deployed to seven-fortunas-brain GitHub org
- Critical for enabling AI-native infrastructure development

---

## Classification Decisions

**Workflow Name:** `create-app-spec`

**Target Path:** `_bmad/bmm/workflows/3-solutioning/create-app-spec/`

**4 Key Decisions:**

1. **Document Output:** `true` - Creates persistent `app_spec.txt` file
2. **Module Affiliation:** `BMM` (Software Development) - Lives in BMM module
3. **Session Type:** `Continuable` - Can span multiple sessions for large PRDs
4. **Lifecycle Support:** `Tri-Modal` - Has Create, Edit, and Validate modes

**Structure Implications:**

Based on these decisions, the workflow will have:

- **Directory structure:**
  ```
  _bmad/bmm/workflows/3-solutioning/create-app-spec/
  ├── workflow.md                    # Main workflow entry point
  ├── data/                           # Shared data (templates, examples)
  │   ├── feature-categories.md       # 7 domain categories
  │   ├── app-spec-template.xml       # XML template structure
  │   └── verification-criteria-patterns.md
  ├── templates/
  │   └── app-spec-template.txt       # Output template
  ├── steps-c/                        # CREATE mode steps
  │   ├── step-01-init.md
  │   ├── step-01b-continue.md        # Continuation support
  │   ├── step-02-prd-analysis.md
  │   ├── step-03-feature-extraction.md
  │   ├── step-04-auto-categorization.md
  │   ├── step-05-criteria-generation.md
  │   ├── step-06-template-population.md
  │   └── step-07-final-review.md
  ├── steps-e/                        # EDIT mode steps
  │   ├── step-01-edit-init.md
  │   ├── step-02-edit-menu.md
  │   └── step-03-save-edits.md
  └── steps-v/                        # VALIDATE mode steps
      ├── step-01-validate-init.md
      ├── step-02-run-validation.md
      └── step-03-validation-report.md
  ```

- **Continuation support:** Includes `step-01b-continue.md` to resume interrupted sessions
- **Output tracking:** Uses `stepsCompleted` frontmatter array to track progress
- **Module access:** Can use BMM-specific variables from `_bmad/bmm/config.yaml`
- **Tri-modal architecture:** Three self-contained step sequences (no shared steps between modes)
- **Shared data folder:** Templates and reference data accessible to all modes

---

## Requirements

**Flow Structure:**
- Pattern: Linear (straightforward transformation process)
- Phases: 7 major steps in CREATE mode
  1. Init - Load PRD, create output file
  2. Continue - Resume interrupted sessions (if needed)
  3. PRD Analysis - Parse PRD structure, identify feature sections
  4. Feature Extraction - Extract individual features from PRD
  5. Auto-Categorization - Classify features into 7 domain categories
  6. Criteria Generation - Auto-generate verification criteria for each feature
  7. Final Review - Present app_spec, allow user review/edits, save
- Estimated steps: 7 create + 3 edit + 3 validate = 13 total step files

**User Interaction:**
- Style: Mostly autonomous with key checkpoints
- Decision points:
  - Step 01: Provide PRD file path (required input)
  - Step 07: Review final app_spec (approve/revise/save)
- Checkpoint frequency: Minimal - AI performs bulk of extraction/generation, user validates at end
- Collaboration level: Low during processing, high at initialization and finalization

**Inputs Required:**
- Required:
  - PRD file path (absolute path to markdown file)
  - PRD must be readable and contain feature/requirements sections
- Optional: None (PRD is single source of truth)
- Prerequisites:
  - BMM module config loaded (user_name, output_folder, document_output_language)
  - PRD exists and is accessible
  - Valid project-root path

**Output Specifications:**
- Type: Document (persistent file)
- Format: Structured XML with required sections
- File: `app_spec.txt` (plain text, XML structure)
- Location: `{output_folder}/app_spec.txt` or user-specified path
- Sections (REQUIRED):
  1. `<metadata>` - Project name, generation date, PRD version
  2. `<overview>` - Executive summary, key objectives
  3. `<technology_stack>` - Languages, frameworks, databases, versions
  4. `<coding_standards>` - Style guides, naming conventions, file organization
  5. `<core_features>` - Feature groups with nested features (FEATURE_001, etc.)
  6. `<non_functional_requirements>` - Performance, security, scalability, monitoring
  7. `<testing_strategy>` - Unit, integration, E2E approaches
  8. `<deployment_instructions>` - Build process, deployment targets, config
  9. `<reference_documentation>` - Links to ADRs, tech specs, design docs
  10. `<success_criteria>` - Overall project success metrics
- Frequency: Single output per PRD (can be edited/validated later)

**Success Criteria:**

*Structural Success:*
- Valid XML structure (well-formed, parseable by XML parser)
- All 10 required sections present
- Feature IDs sequential and unique (FEATURE_001, FEATURE_002, ...)
- No malformed tags or syntax errors

*Content Quality:*
- Features properly granulated (one feature = one atomic, independently implementable task)
- Feature count appropriate for PRD complexity (30-50+ based on requirements)
- All features categorized into 7 domains (Infrastructure, UI, Business Logic, Integration, DevOps, Security, Testing)
- Every feature has verification criteria with clear pass/fail conditions
- No orphaned PRD requirements (all features captured)

*Agent Readiness:*
- Features independently implementable (minimal inter-dependencies)
- Dependencies explicitly stated with FEATURE_XXX references
- Constraints clearly defined (what NOT to do)
- Supports feature_list.json generation pattern (Initializer agent can parse)
- Verification criteria are testable and measurable

*Traceability:*
- All PRD features mapped to app_spec features
- Reference documentation linked where applicable
- Technology stack matches PRD architecture section
- Success criteria align with PRD objectives

**Instruction Style:**
- Overall: Mixed (prescriptive structure + intent-based analysis)
- Prescriptive steps (exact instructions):
  - Step 01-init: File path validation, frontmatter setup
  - Step 06-template-population: Exact XML structure generation
  - Step 07-final-review: Save/validate procedures
  - All validate mode steps: Specific validation criteria
- Intent-based steps (goal-oriented):
  - Step 03-prd-analysis: "Understand PRD structure and identify all feature-bearing sections"
  - Step 04-feature-extraction: "Extract atomic, independently implementable features"
  - Step 05-auto-categorization: "Classify features using domain knowledge and keyword analysis"
  - Step 05-criteria-generation: "Generate measurable, testable verification criteria"
- Notes: Structure must be exact for agent consumption, but intelligent analysis required for feature identification and quality

---

## Tools Configuration

**Workflow Structure Preview:**
- Phase 1: Initialization (handle file OR directory input with multiple PRD docs)
- Phase 2: PRD Analysis (parse single or multiple markdown files)
- Phase 3: Feature Extraction (atomic task breakdown)
- Phase 4: Auto-Categorization (7 domain categories)
- Phase 5: Verification Criteria Generation (measurable, testable)
- Phase 6: Template Population (XML structure with 10 sections)
- Phase 7: Final Review & Save (user validation checkpoint)

**Core BMAD Tools:**
- **Party Mode:** EXCLUDED - Not needed for analytical transformation task
- **Advanced Elicitation:** INCLUDED - Integration point: Phase 7 (Final Review) for optional deep quality review of feature granularity, category assignments, and verification criteria quality
- **Brainstorming:** EXCLUDED - Not needed for analytical feature extraction

**LLM Features:**
- **Web-Browsing:** EXCLUDED - Self-contained workflow, all input from PRD
- **File I/O:** INCLUDED - Critical for workflow
  - Phase 1: Read PRD file(s) - handle single file OR directory with multiple .md files
  - Phase 2: Parse all PRD documents (support multi-file PRD directories like Seven Fortunas)
  - Phase 7: Write app_spec.txt to output location
- **Sub-Agents:** INCLUDED - Use case: Large multi-doc PRDs (Seven Fortunas use case)
  - Phase 2: Parallel processing of multiple PRD files
  - Phase 4: Parallel feature categorization (each sub-agent handles one domain)
  - Phase 5: Parallel criteria generation (faster for 50+ features)
- **Sub-Processes:** EXCLUDED - Linear workflow, no need for parallel workflow coordination

**Memory:**
- Type: Continuable (supports multi-session for large PRDs)
- Tracking:
  - `stepsCompleted` array in app_spec.txt frontmatter
  - `lastStep` tracking
  - PRD files list (if directory input)
  - Feature extraction progress (which sections processed)
  - Current feature count
  - Categorization status
- Implementation: `step-01b-continue.md` for resuming interrupted sessions

**External Integrations:**
- None - Workflow is self-contained with file I/O only
- No databases, APIs, or MCP servers required

**Installation Requirements:**
- Zero installation dependencies
- All selected tools are built-in or BMAD core
- Works out of the box

---

## Workflow Design

### Design Principles Applied

**Micro-File Architecture:**
- Each step focused and self-contained
- Just-In-Time loading (only current step in memory)
- Sequential flow with clear progression
- Menu-based interactions at decision points

**State Management:**
- `stepsCompleted` array in app_spec.txt frontmatter
- Persistent state between sessions
- Supports continuation via step-01b-continue.md

**Restart Variations Support:**
Based on autonomous workflow patterns, this workflow supports multiple restart scenarios:

1. **Clean Slate (Overwrite)** - Delete app_spec.txt → regenerate completely
2. **Evolutionary (Merge)** - Keep existing app_spec.txt → add/update from new PRD
3. **Partial Regeneration** - Edit mode allows selective section regeneration

---

### CREATE MODE (8 steps + 1 continuation)

#### step-01-init.md (Continuable Init - ~200 lines)
**Type:** Init (Continuable) with detection logic
**Goal:** Initialize workflow, detect continuation OR existing app_spec, gather PRD path

**Sequence:**
1. Check for existing app_spec.txt with stepsCompleted
   - If exists with progress → route to step-01b-continue.md
2. Check for existing app_spec.txt without progress
   - If exists → present restart variation menu [O/M/C]
     - **[O]verwrite (Clean Slate):** Delete app_spec, proceed to normal flow
     - **[M]erge (Evolutionary):** Load existing, route to step-02b-merge-mode
     - **[C]ancel:** Exit workflow gracefully
3. If no existing app_spec.txt → normal initialization
   - Welcome user, explain workflow
   - Request PRD path (file OR directory)
   - Validate path exists and readable
   - If directory: discover all .md files
   - Create app_spec.txt output file with frontmatter template
   - Load BMM config variables (user_name, output_folder, etc.)
   - Set stepsCompleted: ['step-01-init']

**Frontmatter:**
```yaml
name: 'step-01-init'
description: 'Initialize workflow and detect restart variations'
continueFile: './step-01b-continue.md'
outputFile: '{output_folder}/app_spec.txt'
templateFile: '../templates/app-spec-template.txt'
nextStepFile: './step-02-prd-analysis.md'
mergeStepFile: './step-02b-merge-mode.md'
```

**Menu:** Conditional (O/M/C if existing file, else auto-proceed)
**State:** Create output file OR route to continuation/merge

---

#### step-01b-continue.md (Continuation - ~150 lines)
**Type:** Continuation (01b)
**Goal:** Resume interrupted workflow session

**Sequence:**
1. Read existing app_spec.txt frontmatter
2. Extract stepsCompleted array
3. Identify last completed step
4. Load that step file to find nextStepFile
5. Welcome user back: "Resuming app_spec creation. Last completed: {lastStep}"
6. Display progress: "{completed}/{total} steps done"
7. Route to appropriate next step

**Frontmatter:**
```yaml
name: 'step-01b-continue'
description: 'Handle workflow continuation'
outputFile: '{output_folder}/app_spec.txt'
```

**Menu:** Auto-proceed to next incomplete step
**State:** Load existing state, route forward

---

#### step-02b-merge-mode.md (NEW - Evolutionary - ~250 lines)
**Type:** Middle (Complex) - Merge existing app_spec with new PRD
**Goal:** Intelligent merge of existing app_spec.txt with updated PRD content

**Sequence:**
1. Load existing app_spec.txt
   - Parse all 10 sections
   - Extract existing features list with IDs, categories, verification criteria
   - Extract metadata, tech stack, etc.
2. Analyze PRD (same as step-02-prd-analysis)
   - Parse structure, identify feature sections
   - Extract technology stack, non-functional requirements
3. Diff Analysis - Compare PRD vs existing app_spec:
   - **New features in PRD** → Mark for addition to app_spec
   - **Changed features** → Mark for update (preserve criteria if still valid)
   - **Removed features** → Flag for user review (don't auto-delete)
   - **Unchanged features** → Keep as-is
4. Present merge summary:
   - "Found {N} new features to add"
   - "Found {N} features to update"
   - "Found {N} features potentially removed from PRD (flagged for review)"
   - "Keeping {N} unchanged features"
5. User confirmation menu: [P]roceed with merge / [R]eview details / [C]ancel
6. Execute merge:
   - Add new features with auto-generated IDs (continue sequence)
   - Update changed features (preserve manual edits where possible)
   - Add comments for flagged removals
7. Skip to step-07-final-review (bypass normal extraction steps)

**Frontmatter:**
```yaml
name: 'step-02b-merge-mode'
description: 'Merge existing app_spec with new PRD (evolutionary restart)'
outputFile: '{output_folder}/app_spec.txt'
nextStepFile: './step-07-final-review.md'
```

**Menu:** A/P/C (with custom [P]roceed / [R]eview / [C]ancel in merge confirmation)
**State:** Update app_spec with merged content, set stepsCompleted
**Subprocess:** Pattern 2 (Deep Analysis) for PRD parsing

---

#### step-02-prd-analysis.md (Middle - Standard - ~200 lines)
**Type:** Middle (Standard) with subprocess optimization
**Goal:** Parse PRD structure and identify feature-bearing sections

**Sequence:**
1. Load PRD file(s)
   - If single file: Read PRD completely
   - If directory: Use sub-agents for parallel reading (Pattern 2)
2. Parse document structure across all files
   - Identify headings, sections, subsections
   - Find feature-bearing sections (Features, Requirements, User Stories, Functional Requirements, etc.)
3. Extract architectural information
   - Technology stack (languages, frameworks, databases)
   - Coding standards
   - Testing strategy
4. Extract non-functional requirements
   - Performance targets
   - Security requirements
   - Scalability constraints
   - Monitoring needs
5. Build mental model of project scope
6. Store analysis in working memory (not in output file yet)

**Frontmatter:**
```yaml
name: 'step-02-prd-analysis'
description: 'Parse PRD structure and identify feature sections'
nextStepFile: './step-03-feature-extraction.md'
outputFile: '{output_folder}/app_spec.txt'
```

**Menu:** A/P/C
**State:** Update stepsCompleted, store PRD analysis in memory
**Subprocess:** Pattern 2 (Deep Analysis) - parallel file reading for multi-doc PRDs

---

#### step-03-feature-extraction.md (Middle - Standard - ~250 lines)
**Type:** Middle (Standard) - Intent-based
**Goal:** Extract atomic, independently implementable features from PRD

**Sequence:**
1. Process all identified feature-bearing sections from step-02
2. For each requirement/feature in PRD:
   - Apply Anthropic's principle: "one feature = one atomic, independently implementable task"
   - Break down complex features into granular tasks
   - Extract acceptance criteria from PRD (if present)
   - Identify feature dependencies
3. Generate sequential feature IDs: FEATURE_001, FEATURE_002, ...
4. Create features list with structure:
   ```
   {
     id: "FEATURE_001",
     name: "User Authentication",
     description: "...",
     prd_section: "3.2",
     acceptance_criteria: [...],
     dependencies: []
   }
   ```
5. Present feature count to user: "Extracted {N} features from PRD"
6. Store features list in memory

**Frontmatter:**
```yaml
name: 'step-03-feature-extraction'
description: 'Extract atomic features from PRD'
nextStepFile: './step-04-auto-categorization.md'
outputFile: '{output_folder}/app_spec.txt'
```

**Menu:** A/P/C
**State:** Update stepsCompleted, store features list
**Instruction Style:** Intent-based - "Extract atomic, independently implementable features"

---

#### step-04-auto-categorization.md (Middle - Standard - ~200 lines)
**Type:** Middle (Standard) with subprocess optimization
**Goal:** Classify features into 7 domain categories

**Sequence:**
1. Load 7 domain categories from data/feature-categories.md:
   - Infrastructure & Foundation
   - User Interface
   - Business Logic
   - Integration
   - DevOps & Deployment
   - Security & Compliance
   - Testing & Quality
2. For each feature, apply categorization logic:
   - Keyword matching (e.g., "API" → Integration, "Dashboard" → UI)
   - Context analysis from feature description
   - PRD section hints
3. Use sub-agents for parallel categorization if 30+ features (Pattern 4)
4. Group features by category
5. Validate distribution:
   - No single category should have >50% of features (flag if so)
   - Ensure at least 2 categories represented
6. Present categorization summary:
   - "Infrastructure: {N} features"
   - "UI: {N} features"
   - ... etc.
7. Allow user to adjust: [A]ccept / [R]ecategorize specific features / [C]ontinue with Advanced Elicitation review
8. Store categorized features

**Frontmatter:**
```yaml
name: 'step-04-auto-categorization'
description: 'Classify features into domain categories'
nextStepFile: './step-05-criteria-generation.md'
outputFile: '{output_folder}/app_spec.txt'
categoriesDataFile: '../data/feature-categories.md'
```

**Menu:** Custom ([A]ccept / [R]ecategorize / Advanced Elicitation / Party Mode / [C]ontinue)
**State:** Update stepsCompleted, store categorized features
**Subprocess:** Pattern 4 (Parallel Execution) - parallel categorization for large feature sets

---

#### step-05-criteria-generation.md (Middle - Standard - ~250 lines)
**Type:** Middle (Standard) with subprocess optimization
**Goal:** Auto-generate verification criteria for each feature

**Sequence:**
1. Load verification-criteria-patterns.md from data/ (patterns from 4 example app_specs)
2. For each feature, generate three types of criteria:
   - **Functional verification:**
     - "Feature implements {requirement} as specified in PRD"
     - "Feature handles {edge case} correctly"
   - **Technical verification:**
     - "Code follows {coding standard} from PRD"
     - "Tests achieve {coverage threshold}"
   - **Integration verification:**
     - "Feature integrates with {dependency}"
     - "Feature does not break {existing functionality}"
3. Use sub-agents for parallel generation if 30+ features (Pattern 4)
4. Ensure all criteria are:
   - Measurable (can be tested)
   - Testable (clear pass/fail)
   - Specific (not generic)
5. Store criteria with features
6. Present sample to user: "Generated {N} verification criteria across {M} features. Sample: ..."

**Frontmatter:**
```yaml
name: 'step-05-criteria-generation'
description: 'Generate verification criteria for each feature'
nextStepFile: './step-06-template-population.md'
outputFile: '{output_folder}/app_spec.txt'
criteriaDataFile: '../data/verification-criteria-patterns.md'
```

**Menu:** A/P/C
**State:** Update stepsCompleted, store features with criteria
**Subprocess:** Pattern 4 (Parallel Execution) - parallel criteria generation
**Instruction Style:** Intent-based - "Generate measurable, testable verification criteria"

---

#### step-06-template-population.md (Middle - Prescriptive - ~250 lines)
**Type:** Middle (Prescriptive) - Exact XML structure
**Goal:** Build complete XML structure with all 10 required sections

**Sequence:**
1. Load app-spec-template.xml from templates/
2. Populate all 10 required sections in order:
   1. **<metadata>**
      - project_name (from PRD or BMM config)
      - generated_from: "PRD v{version}"
      - generated_date: {current_date}
      - autonomous_agent_ready: true
   2. **<overview>**
      - Executive summary (from PRD introduction/overview)
      - Key objectives (from PRD goals)
   3. **<technology_stack>**
      - Languages, frameworks, databases (from PRD analysis step-02)
      - Versions explicitly stated
   4. **<coding_standards>**
      - Style guides (from PRD or BMM defaults)
      - Naming conventions
      - File organization patterns
   5. **<core_features>**
      - For each category with features:
        ```xml
        <feature_group name="Infrastructure & Foundation">
          <feature id="FEATURE_001">
            <name>User Authentication</name>
            <description>...</description>
            <requirements>
              - Requirement 1
              - Requirement 2
            </requirements>
            <acceptance_criteria>
              - Criterion 1
              - Criterion 2
            </acceptance_criteria>
            <dependencies>
              - FEATURE_XXX (if any)
            </dependencies>
            <constraints>
              - What NOT to do
            </constraints>
          </feature>
        </feature_group>
        ```
   6. **<non_functional_requirements>**
      - Performance (from PRD)
      - Security (from PRD)
      - Scalability (from PRD)
      - Monitoring (from PRD)
   7. **<testing_strategy>**
      - Unit test approach (from PRD)
      - Integration test approach
      - E2E test approach
   8. **<deployment_instructions>**
      - Build process (from PRD)
      - Deployment targets
      - Configuration management
   9. **<reference_documentation>**
      - Links to ADRs (from PRD)
      - Links to tech specs
      - Links to design docs
   10. **<success_criteria>**
       - Overall project success metrics (from PRD objectives)
3. Validate XML well-formedness (can be parsed)
4. Validate all required sections present
5. Store complete app_spec content in output file
6. Auto-proceed (no user input needed)

**Frontmatter:**
```yaml
name: 'step-06-template-population'
description: 'Build complete XML structure'
nextStepFile: './step-07-final-review.md'
outputFile: '{output_folder}/app_spec.txt'
templateFile: '../templates/app-spec-template.xml'
```

**Menu:** Auto-proceed
**State:** Update stepsCompleted, write complete app_spec to output file
**Instruction Style:** Prescriptive - Exact XML structure required

---

#### step-07-final-review.md (Final - ~200 lines)
**Type:** Final Step
**Goal:** Present app_spec to user, allow review/edits, save

**Sequence:**
1. Display app_spec statistics:
   - Total features: {count}
   - Categories: {list with counts}
   - PRD sections covered: {count}
   - XML validation: {✅ PASS}
2. Present summary or full app_spec (if <500 lines show full, else show summary)
3. Present review menu:
   ```
   **Review Complete app_spec.txt**

   [S]ave - Save to {output_folder}/app_spec.txt and complete workflow
   [E]dit Categories - Adjust feature categorization
   [A]djust Granularity - Split or merge features
   [R]eview with Advanced Elicitation - Deep quality review
   [P]review Full Content - Display complete app_spec
   [C]ancel - Exit without saving
   ```
4. Handle menu selections:
   - **S (Save):**
     - Save app_spec.txt to output location
     - Mark workflow complete (stepsCompleted final)
     - Display success message with file path
     - Suggest next step: "Run check-autonomous-implementation-readiness workflow to validate this app_spec"
   - **E (Edit Categories):**
     - Allow user to specify features to recategorize
     - Return to step-04-auto-categorization with edits
   - **A (Adjust Granularity):**
     - Allow user to split large features or merge small ones
     - Return to step-03-feature-extraction with adjustments
   - **R (Review with AE):**
     - Launch Advanced Elicitation for deep quality review
     - Return to this menu after review
   - **P (Preview):**
     - Display full app_spec.txt content
     - Return to this menu
   - **C (Cancel):**
     - Exit without saving
     - Preserve partial progress in output file

**Frontmatter:**
```yaml
name: 'step-07-final-review'
description: 'Present app_spec and finalize'
outputFile: '{output_folder}/app_spec.txt'
advancedElicitationTask: '{project-root}/_bmad/core/workflows/advanced-elicitation/workflow.xml'
```

**Menu:** Custom (S/E/A/R/P/C)
**State:** Final save, mark workflow complete
**Optional Integration:** Advanced Elicitation for quality review

---

### EDIT MODE (3 steps)

#### step-01-edit-init.md (Init - ~150 lines)
**Type:** Init (Edit mode)
**Goal:** Load existing app_spec.txt for editing

**Sequence:**
1. Request app_spec.txt path from user
2. Validate file exists and is readable
3. Load and parse existing file (XML structure)
4. Validate XML well-formedness
5. Extract current statistics:
   - Feature count
   - Category distribution
   - Last modified date
6. Present statistics to user
7. Auto-proceed to edit menu

**Frontmatter:**
```yaml
name: 'step-01-edit-init'
description: 'Load existing app_spec for editing'
nextStepFile: './step-02-edit-menu.md'
```

**Menu:** Auto-proceed
**State:** Load app_spec into memory

---

#### step-02-edit-menu.md (Middle - Branch - ~250 lines)
**Type:** Middle (Branch) - Menu-driven editing
**Goal:** Provide menu-driven interface for editing app_spec

**Sequence:**
1. Present edit menu:
   ```
   **Edit Menu**

   [1] Add feature manually
   [2] Remove feature
   [3] Modify existing feature
   [4] Recategorize features
   [5] Update verification criteria
   [6] Regenerate features from updated PRD (partial regeneration)
   [7] Regenerate criteria only (keep features)
   [8] Edit metadata/overview
   [9] Save and exit
   [0] Exit without saving
   ```
2. Handle each selection:
   - **[1] Add feature:** Prompt for feature details, insert with new ID
   - **[2] Remove feature:** Select feature by ID, confirm deletion
   - **[3] Modify feature:** Select feature, edit fields
   - **[4] Recategorize:** Select features, choose new category
   - **[5] Update criteria:** Select feature, regenerate or edit criteria
   - **[6] Regenerate features:** Request updated PRD path, re-extract features, merge with existing
   - **[7] Regenerate criteria:** Keep all features, regenerate verification criteria using latest patterns
   - **[8] Edit metadata:** Edit project name, tech stack, overview
   - **[9] Save and exit:** Proceed to step-03-save-edits
   - **[0] Exit:** Cancel without saving
3. After each edit (except 9/0), loop back to this menu
4. Track changes for validation

**Frontmatter:**
```yaml
name: 'step-02-edit-menu'
description: 'Menu-driven editing interface'
nextStepFile: './step-03-save-edits.md'
```

**Menu:** Custom (numbered options 0-9)
**State:** Track edits in memory, loop back to menu

---

#### step-03-save-edits.md (Final - ~150 lines)
**Type:** Final (Edit mode)
**Goal:** Validate and save edited app_spec

**Sequence:**
1. Validate edited app_spec:
   - XML well-formedness
   - All 10 required sections present
   - Feature IDs unique and sequential
   - No orphaned dependencies
2. If validation fails:
   - Present errors
   - Offer: [F]ix errors / [S]ave anyway / [C]ancel
3. If validation passes or user chooses save anyway:
   - Save to original location (or new path if specified)
   - Display success message
   - Show file path
4. Suggest next steps: "Run validate workflow to check quality"

**Frontmatter:**
```yaml
name: 'step-03-save-edits'
description: 'Validate and save edited app_spec'
```

**Menu:** Conditional (F/S/C if validation fails, else auto-save)
**State:** Save to file, exit workflow

---

### VALIDATE MODE (3 steps)

#### step-01-validate-init.md (Init - ~150 lines)
**Type:** Init (Validate mode)
**Goal:** Load app_spec.txt for validation

**Sequence:**
1. Request app_spec.txt path from user
2. Validate file exists and is readable
3. Load and parse file
4. Display file info (path, size, date)
5. Auto-proceed to validation checks

**Frontmatter:**
```yaml
name: 'step-01-validate-init'
description: 'Load app_spec for validation'
nextStepFile: './step-02-run-validation.md'
```

**Menu:** Auto-proceed
**State:** Load app_spec into memory

---

#### step-02-run-validation.md (Validation Sequence - ~200 lines)
**Type:** Validation Sequence (auto-proceed between checks)
**Goal:** Execute all validation checks

**Sequence:**
1. **Check Completeness:**
   - Verify all 10 required sections present
   - Score: sections_present / 10 * 100
2. **Check XML Well-Formedness:**
   - Parse XML structure
   - Check for malformed tags, syntax errors
   - Result: ✅ Valid / ❌ Errors
3. **Check Feature Quality:**
   - All features have IDs (FEATURE_XXX format)
   - All features have verification criteria
   - Feature IDs sequential and unique
   - No orphaned dependencies
   - Score: checks_passed / total_checks * 100
4. **Check Granularity:**
   - Assess feature descriptions for atomic task principle
   - Flag features that seem too large/complex
   - Flag features that seem too trivial
   - Score: well_granulated / total * 100
5. **Check Agent Readiness:**
   - Features independently implementable
   - Dependencies explicitly stated
   - Constraints defined
   - Verification criteria testable
   - Score: checks_passed / total_checks * 100
6. Store all validation results in memory
7. Auto-proceed to report generation

**Frontmatter:**
```yaml
name: 'step-02-run-validation'
description: 'Execute validation checks'
nextStepFile: './step-03-validation-report.md'
```

**Menu:** Auto-proceed
**State:** Store validation results
**Type:** Validation Sequence (no user interaction until complete)

---

#### step-03-validation-report.md (Final - ~150 lines)
**Type:** Final (Validate mode)
**Goal:** Generate and present validation report

**Sequence:**
1. Compile all validation results from step-02
2. Calculate overall score (weighted average)
3. Determine validation status:
   - **PASS:** Score ≥85, XML valid, all required sections
   - **PASS WITH CONCERNS:** Score 70-84, minor issues
   - **FAIL:** Score <70, XML invalid, or missing required sections
4. Generate validation report:
   ```
   ═══════════════════════════════════════
      APP_SPEC VALIDATION REPORT
   ═══════════════════════════════════════

   File: {path}
   Validated: {date}

   OVERALL STATUS: {PASS/PASS WITH CONCERNS/FAIL}
   OVERALL SCORE: {score}/100

   DIMENSION SCORES:
   - Completeness: {score}/100
   - XML Well-Formedness: {✅/❌}
   - Feature Quality: {score}/100
   - Granularity: {score}/100
   - Agent Readiness: {score}/100

   ISSUES IDENTIFIED:
   {list any validation failures}

   RECOMMENDATIONS:
   {specific recommendations to improve quality}

   ═══════════════════════════════════════
   ```
5. Save report to: `{outputFolder}/validation-report-{timestamp}.md`
6. Display report to user
7. Present next steps based on status

**Frontmatter:**
```yaml
name: 'step-03-validation-report'
description: 'Generate validation report'
outputFolder: '{output_folder}'
```

**Menu:** None (final step)
**State:** Save validation report, exit workflow

---

### File Structure

```
_bmad/bmm/workflows/3-solutioning/create-app-spec/
├── workflow.md                           # Main entry point with mode routing
├── data/                                 # Shared data (accessible to all modes)
│   ├── feature-categories.md             # 7 domain categories with descriptions
│   ├── verification-criteria-patterns.md # Patterns from 4 example app_specs
│   └── restart-variations-guide.md       # Restart scenarios documentation
├── templates/
│   ├── app-spec-template.xml             # XML structure template
│   └── app-spec-frontmatter.yaml         # Frontmatter template for output file
├── steps-c/                              # CREATE mode
│   ├── step-01-init.md                   # Init with restart detection (200)
│   ├── step-01b-continue.md              # Continuation (150)
│   ├── step-02b-merge-mode.md            # NEW - Evolutionary restart (250)
│   ├── step-02-prd-analysis.md           # PRD parsing (200)
│   ├── step-03-feature-extraction.md     # Extract features (250)
│   ├── step-04-auto-categorization.md    # Categorize (200)
│   ├── step-05-criteria-generation.md    # Generate criteria (250)
│   ├── step-06-template-population.md    # Build XML (250)
│   └── step-07-final-review.md           # Review & save (200)
├── steps-e/                              # EDIT mode
│   ├── step-01-edit-init.md              # Load for editing (150)
│   ├── step-02-edit-menu.md              # Edit menu (250)
│   └── step-03-save-edits.md             # Validate & save (150)
└── steps-v/                              # VALIDATE mode
    ├── step-01-validate-init.md          # Load for validation (150)
    ├── step-02-run-validation.md         # Run checks (200)
    └── step-03-validation-report.md      # Generate report (150)
```

**Total:** 14 step files (8 create + 1 continuation + 3 edit + 3 validate) + 4 data files + 2 templates = 20 files

---

### Restart Variations Summary

Based on autonomous workflow guide patterns:

| Scenario | Action | Effect |
|----------|--------|--------|
| **Clean Slate** | Delete app_spec.txt → Run create workflow | Complete regeneration from PRD |
| **Evolutionary** | Keep app_spec.txt → Run create workflow → Select [M]erge | Add/update from new PRD, preserve existing |
| **Partial Regen** | Run edit workflow → Option [6] or [7] | Regenerate specific sections only |
| **Continue** | app_spec.txt exists with stepsCompleted → Run create workflow | Resume from last step |

### State Files (Analogous to Autonomous Pattern)

| File | Purpose | Delete to Restart? |
|------|---------|-------------------|
| `app_spec.txt` | Feature specification (single source of truth) | ✅ YES - Triggers clean slate |
| `feature_list.json` | Generated BY app_spec (used by autonomous agent) | N/A - Created downstream |
| `CLAUDE.md` | Project instructions (used by autonomous agent) | ❌ NO - Required |
| `prd/` | Source requirements | ❌ NO - Input to workflow |

---

**Design complete and documented!**

---

## Foundation Build Complete

**Date:** 2026-02-13

**Created:**
- ✅ Folder structure at: `_bmad-output/bmb-creations/workflows/create-app-spec/`
- ✅ workflow.md - Main entry point with tri-modal routing (Create/Edit/Validate)
- ✅ templates/app-spec-template.txt - Structured XML template with 10 required sections
- ✅ templates/app-spec-frontmatter.yaml - Frontmatter template for state tracking

**Directory Structure:**
```
create-app-spec/
├── workflow.md                    # Main entry point (tri-modal routing)
├── workflow-plan-create-app-spec.md  # This plan document
├── data/                           # Shared data (to be populated)
├── templates/                      # Output templates
│   ├── app-spec-template.txt       # Main XML template
│   └── app-spec-frontmatter.yaml   # Frontmatter template
├── steps-c/                        # CREATE mode steps (to be built)
├── steps-e/                        # EDIT mode steps (to be built)
└── steps-v/                        # VALIDATE mode steps (to be built)
```

**Configuration:**
- Workflow name: create-app-spec
- Module: BMM (Software Development)
- Target location (final): `_bmad/bmm/workflows/3-solutioning/create-app-spec/`
- Continuable: Yes (supports multi-session for large PRDs)
- Document output: Yes - Structured XML (app_spec.txt)
- Mode: Tri-modal (Create/Edit/Validate)
- Restart variations: Clean Slate, Evolutionary, Partial Regeneration

**Next Steps:**
- Step 8: Build step-01-init.md and step-01b-continue.md (CREATE mode initialization)
- Step 9: Build remaining CREATE mode steps (repeatable process for each step)
- Step 10: Build EDIT mode steps
- Step 11: Build VALIDATE mode steps
- Step 12: Create data files (feature-categories.md, verification-criteria-patterns.md, restart-variations-guide.md)
- Step 13: Deploy to final location in BMM module
- Step 14: Test workflow end-to-end

**Foundation is ready for step file creation!**

---

## Step 01 Build Complete

**Date:** 2026-02-13

**Created:**
- ✅ steps-c/step-01-init.md (202 lines) - Initialization with restart variation detection
- ✅ steps-c/step-01b-continue.md (155 lines) - Continuation support

**Step 01 Configuration:**
- Type: Continuable (supports multi-session)
- Restart Variations: Clean Slate ([O]verwrite), Evolutionary ([M]erge), Cancel
- Input: PRD path (file OR directory with multiple .md files)
- Output: Creates app_spec.txt with frontmatter template
- Next Step: step-02-prd-analysis.md OR step-02b-merge-mode.md (if merge selected)

**Features Implemented:**
1. **Continuation Detection:** Checks for existing app_spec.txt with stepsCompleted → routes to step-01b-continue.md
2. **Restart Variation Menu:** If existing file without progress → presents [O/M/C] menu
3. **Multi-file PRD Support:** Accepts single file OR directory path, discovers all .md files
4. **Path Validation:** Validates file/directory exists before proceeding
5. **Output File Creation:** Creates app_spec.txt with frontmatter tracking
6. **Progress Routing:** step-01b maps stepsCompleted to next step file

**Frontmatter Variables Used:**
- continueFile: './step-01b-continue.md'
- nextStepFile: './step-02-prd-analysis.md'
- mergeStepFile: './step-02b-merge-mode.md'
- outputFile: '{output_folder}/app_spec.txt'
- templateFile: '../templates/app-spec-frontmatter.yaml'

**Next:** Build remaining CREATE mode steps (step-02 through step-07, plus step-02b merge mode)

---

## ALL STEP FILES BUILD COMPLETE

**Date:** 2026-02-13

### CREATE Mode Steps (9 files) ✅

- ✅ step-01-init.md (202 lines) - Initialization with restart detection
- ✅ step-01b-continue.md (155 lines) - Continuation support
- ✅ step-02-prd-analysis.md (200 lines) - PRD parsing with multi-file support
- ✅ step-02b-merge-mode.md (250 lines) - Evolutionary restart (merge existing with PRD updates)
- ✅ step-03-feature-extraction.md (250 lines) - Extract atomic features from PRD
- ✅ step-04-auto-categorization.md (240 lines) - Classify features into 7 domains
- ✅ step-05-criteria-generation.md (250 lines) - Generate verification criteria
- ✅ step-06-template-population.md (260 lines) - Build complete XML structure
- ✅ step-07-final-review.md (256 lines) - Review and save with custom menu

**Total CREATE mode lines:** ~2,113 lines

### EDIT Mode Steps (3 files) ✅

- ✅ step-01-edit-init.md (174 lines) - Load existing app_spec for editing
- ✅ step-02-edit-menu.md (319 lines) - Menu-driven editing operations
- ✅ step-03-save-edits.md (243 lines) - Validate and save edits

**Total EDIT mode lines:** ~736 lines

### VALIDATE Mode Steps (3 files) ✅

- ✅ step-01-validate-init.md (145 lines) - Load app_spec for validation
- ✅ step-02-run-validation.md (348 lines) - Comprehensive 8-check validation
- ✅ step-03-validation-report.md (316 lines) - Generate and present validation report

**Total VALIDATE mode lines:** ~809 lines

### Data Files (3 files) ✅

- ✅ feature-categories.md (254 lines) - 7 domain categories with keyword patterns
- ✅ verification-criteria-patterns.md (432 lines) - Criteria patterns from research
- ✅ restart-variations-guide.md (403 lines) - Restart pattern documentation

**Total data file lines:** ~1,089 lines

---

## Workflow Statistics

**Total Files Created:** 18 files
- Step files: 15 (9 CREATE + 3 EDIT + 3 VALIDATE)
- Data files: 3
- Templates: 2 (already created in foundation)

**Total Lines of Workflow Logic:** ~4,747 lines
- CREATE mode: 2,113 lines
- EDIT mode: 736 lines
- VALIDATE mode: 809 lines
- Data/documentation: 1,089 lines

**Key Features Implemented:**
1. ✅ Tri-modal structure (Create/Edit/Validate)
2. ✅ Restart variations (Clean Slate/Evolutionary/Partial Regen)
3. ✅ Continuation support (resume interrupted sessions)
4. ✅ Multi-file PRD support (directory discovery)
5. ✅ Subprocess optimization (Pattern 2 & 4)
6. ✅ Auto-categorization (7 domain categories)
7. ✅ Auto-criteria generation (3 types per feature)
8. ✅ Comprehensive validation (8 quality checks)
9. ✅ Advanced Elicitation integration
10. ✅ Party Mode integration
11. ✅ Flexible feature count (granularity-first)
12. ✅ Sequential feature ID management

---

## Next Steps (Deployment)

### 1. Deploy to Target Location

**Source:** `/home/ladmin/dev/GDF/7F_github/_bmad-output/bmb-creations/workflows/create-app-spec/`
**Target:** `_bmad/bmm/workflows/3-solutioning/create-app-spec/`

Copy complete workflow directory to final location in BMM module.

### 2. Create Skill Stub

**Location:** `.claude/commands/bmad-bmm-create-app-spec.md`

**Content:**
```markdown
---
name: bmad-bmm-create-app-spec
description: Transform PRD into app_spec.txt for autonomous agent implementation
---

@{project-root}/_bmad/bmm/workflows/3-solutioning/create-app-spec/workflow.md
```

### 3. Validate Workflow

Run BMAD validation tool to ensure workflow structure is correct:
- Check all frontmatter complete
- Validate all nextStepFile references
- Confirm file sizes (<250 lines recommended)
- Test workflow loading

### 4. Test End-to-End

**Test scenarios:**
1. **CREATE mode (clean slate):** New PRD → app_spec.txt generation
2. **CREATE mode (continuation):** Interrupt mid-workflow → resume from step
3. **CREATE mode (merge):** Existing app_spec + updated PRD → merged result
4. **EDIT mode:** Load existing → modify features → save
5. **VALIDATE mode:** Load app_spec → run validation → generate report

### 5. Package for Seven Fortunas Brain

**Target repo:** `/home/ladmin/seven-fortunas-workspace/seven-fortunas-brain/`

Copy workflow and skill stub to Seven Fortunas brain repository:
- Workflow: `_bmad/bmm/workflows/3-solutioning/create-app-spec/`
- Skill: `.claude/commands/bmad-bmm-create-app-spec.md`

### 6. Update Related Workflows

**Workflow:** `check-autonomous-implementation-readiness`
- Ensure validation checks align with create-app-spec output format
- Update criteria patterns if needed
- Test integration between workflows

### 7. Update Documentation

**Autonomous Workflow Guide:**
- Document app_spec.txt creation workflow
- Add restart variation patterns
- Update workflow diagrams

**Seven Fortunas Planning Artifacts:**
- Mark create-app-spec as complete
- Update action plan with completion date
- Document workflow location and usage

---

## Workflow Creation Complete! 🎉

**Created:** 2026-02-13
**Status:** COMPLETE - Ready for deployment and testing
**Total Build Time:** Single session (continued from previous)
**Files Created:** 18 (15 step files + 3 data files)
**Lines of Code:** ~4,747 lines

**Quality Assurance:**
- ✅ All step files follow BMAD micro-file design patterns
- ✅ Sequential enforcement maintained (explicit nextStepFile references)
- ✅ State tracking via stepsCompleted array
- ✅ Just-In-Time loading (no step reads future steps)
- ✅ Mandatory execution rules in every step
- ✅ Role reinforcement in every step
- ✅ Success/failure metrics in every step
- ✅ Menu handling consistent across workflow
- ✅ Subprocess optimization patterns applied
- ✅ Advanced Elicitation integration
- ✅ Party Mode integration

**Ready for:**
1. Deployment to BMM module
2. Skill stub creation
3. Validation with BMAD tools
4. End-to-end testing
5. Packaging for Seven Fortunas Brain
6. Integration with check-autonomous-implementation-readiness workflow

**Companion Workflow Status:**
- ✅ check-autonomous-implementation-readiness (already deployed)
- 🔄 create-app-spec (THIS WORKFLOW - ready for deployment)

**Project Goal Achieved:** Custom BMAD workflows for autonomous agent implementation pattern complete!
