---
name: 'step-02-document-discovery'
description: 'Load and validate all required documents'

nextStepFile: './step-03-prd-analysis.md'
outputFile: '{output_folder}/readiness-assessment-{project_name}.md'

advancedElicitationTask: '{project-root}/_bmad/core/workflows/advanced-elicitation/workflow.xml'
partyModeWorkflow: '{project-root}/_bmad/core/workflows/party-mode/workflow.md'
---

# Step 2: Document Discovery

## STEP GOAL:

To load, validate, and summarize all required documents (PRD, app_spec.txt, architecture docs) for the readiness assessment.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Technical Program Manager and Software Architect hybrid
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in document analysis and validation
- ✅ User brings their project documentation
- ✅ Together we ensure all required materials are accessible

### Step-Specific Rules:

- 🎯 Focus ONLY on loading and validating document accessibility
- 🚫 FORBIDDEN to perform deep analysis yet - that comes in subsequent steps
- 💬 Provide brief summaries to confirm correct documents loaded
- 🎯 Use subprocess optimization (Pattern 2) for multi-document analysis

## EXECUTION PROTOCOLS:

- 🎯 Load all documents using file I/O
- 💾 Append document inventory section to output file
- 📖 Update frontmatter analysis_phase to 'document-discovery'
- 🚫 Keep summaries brief - full analysis comes later

## CONTEXT BOUNDARIES:

- Available: Document paths from step-01 frontmatter
- Focus: Validate accessibility and basic metadata
- Limits: No deep content analysis yet
- Dependencies: Initialized output file with document paths

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Load Document Paths from Output File

Read `{outputFile}` frontmatter to retrieve:
- `prd_path`
- `appspec_path`
- `architecture_docs` (array, may be empty)

Display: "**Loading documents for assessment...**"

### 2. Load and Validate PRD

Load the PRD file at `{prd_path}`.

**Extract basic metadata:**
- File size (approximate line count or KB)
- Has frontmatter: yes/no
- Main sections identified (count level 2 headers)

**Brief summary:**
"✅ **PRD Loaded**
- Path: {prd_path}
- Size: ~{line_count} lines
- Sections: {section_count} main sections identified
- Format: {has_frontmatter ? 'Structured with frontmatter' : 'Standard markdown'}"

### 3. Load and Validate app_spec.txt

Load the app_spec.txt file at `{appspec_path}`.

**Extract basic metadata:**
- File size
- Feature count (approximate by searching for feature markers)
- Structure format (freeform, numbered, sectioned)

**Brief summary:**
"✅ **app_spec.txt Loaded**
- Path: {appspec_path}
- Size: ~{line_count} lines
- Features identified: ~{feature_count} features
- Format: {format_type}"

### 4. Load and Validate Architecture Documentation (If Provided)

**IF architecture_docs array is not empty:**

For each architecture document:
- Load file at specified path
- Extract metadata (size, sections)
- Brief summary

"✅ **Architecture Documentation Loaded**
- Document count: {architecture_docs.length}
- Documents:
  1. {doc1_path} - ~{size} - {type}
  2. {doc2_path} - ~{size} - {type}"

**IF architecture_docs array is empty:**

"⚠️ **No Architecture Documentation**
- Architecture alignment assessment will be limited
- Proceeding with PRD and app_spec.txt analysis only"

### 5. Validate Document Relationships

Perform basic validation checks:

**Check 1: PRD and app_spec.txt alignment**
- Do both documents reference the same project?
- Are there obvious version mismatches?

**Check 2: Document completeness**
- Does PRD have required sections (requirements, goals, etc.)?
- Does app_spec.txt have feature specifications?

Present findings:

"**Document Relationship Validation:**
✅ PRD and app_spec.txt appear to reference the same project
✅ PRD has core requirement sections
✅ app_spec.txt contains feature specifications

[Or note any concerns if validation fails]"

### 6. Append Document Inventory to Output File

Update `{outputFile}` by appending below the frontmatter:

```markdown
## Document Inventory

**PRD Location:** {prd_path}
**App Spec Location:** {appspec_path}
**Architecture Documentation:** {architecture_docs or 'None provided'}
**Assessment Date:** {created_date}
**Assessed By:** {user_name}

### Loaded Documents Summary

**PRD:**
- Size: ~{line_count} lines
- Sections: {section_count} main sections
- Format: {format_type}

**app_spec.txt:**
- Size: ~{line_count} lines
- Features: ~{feature_count} identified
- Format: {format_type}

**Architecture Docs:**
{list_of_architecture_docs or 'None provided - alignment assessment will be limited'}

---
```

Update frontmatter: `analysis_phase: 'document-discovery-complete'`

### 7. Confirm Readiness for Analysis

Present checkpoint:

"**Document Discovery Complete**

All required documents have been loaded and validated. Ready to begin detailed analysis.

**Next:** PRD Analysis - We'll evaluate PRD completeness and quality across key dimensions."

### 8. Present MENU OPTIONS

Display: **Select an Option:** [A] Advanced Elicitation [P] Party Mode [C] Continue to PRD Analysis

#### EXECUTION RULES:

- ALWAYS halt and wait for user input after presenting menu
- ONLY proceed to next step when user selects 'C'
- After other menu items execution, return to this menu
- User can chat or ask questions - always respond and redisplay menu

#### Menu Handling Logic:

- IF A: Execute {advancedElicitationTask}, and when finished redisplay the menu
- IF P: Execute {partyModeWorkflow}, and when finished redisplay the menu
- IF C: Update frontmatter analysis_phase to 'prd-analysis', then load, read entire file, then execute {nextStepFile}
- IF Any other: Help user respond, then redisplay menu

## 🚨 SYSTEM SUCCESS/FAILURE METRICS:

### ✅ SUCCESS:

- All documents loaded successfully
- Basic metadata extracted from each document
- Document relationships validated
- Document inventory appended to output file
- Frontmatter updated with analysis phase
- User confirms readiness to proceed

### ❌ SYSTEM FAILURE:

- Not loading all specified documents
- Skipping validation checks
- Not appending inventory to output file
- Not updating frontmatter
- Proceeding without user confirmation
- Performing deep analysis instead of basic validation

**Master Rule:** Document discovery validates accessibility and basic structure only. Deep analysis is FORBIDDEN at this step - it belongs in subsequent analysis steps.
