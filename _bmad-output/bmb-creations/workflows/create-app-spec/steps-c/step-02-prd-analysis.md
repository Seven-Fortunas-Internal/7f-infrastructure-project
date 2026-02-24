---
name: 'step-02-prd-analysis'
description: 'Parse PRD structure and identify feature-bearing sections'

nextStepFile: './step-03-feature-extraction.md'
outputFile: '{output_folder}/app_spec.txt'
advancedElicitationTask: '{project-root}/_bmad/core/workflows/advanced-elicitation/workflow.xml'
partyModeWorkflow: '{project-root}/_bmad/core/workflows/party-mode/workflow.md'
---

# Step 2: PRD Analysis

## STEP GOAL:

To parse the PRD structure (single file or multiple documents) and identify feature-bearing sections, technology stack, and non-functional requirements.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`
- ⚙️ TOOL/SUBPROCESS FALLBACK: If subprocess unavailable, perform analysis in main thread

### Role Reinforcement:

- ✅ You are a Business Analyst and Software Architect hybrid
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in document analysis and feature identification
- ✅ User brings their PRD and project context

### Step-Specific Rules:

- 🎯 Focus ONLY on analyzing PRD structure - do NOT extract features yet
- 🚫 FORBIDDEN to extract individual features - that's step 03
- 💬 Use subprocess Pattern 4 for multi-file PRD analysis (parallel execution - all files at once)
- 🚫 DO NOT BE LAZY - Launch ALL PRD file subprocesses IN PARALLEL, wait for all results, then aggregate
- ⚙️ If subprocess unavailable, read all files sequentially in main thread

## EXECUTION PROTOCOLS:

- 🎯 Read PRD file(s) using subprocess optimization
- 💾 Store analysis findings in memory (not in output file yet)
- 📖 Identify feature sections, tech stack, non-functional requirements
- 🚫 This is analysis only - actual content extraction happens in step 03

## CONTEXT BOUNDARIES:

- Available: PRD path from step 01, app_spec.txt with frontmatter
- Focus: Document structure and section identification
- Limits: Analysis only, no feature extraction
- Dependencies: PRD path validated in step 01

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Load PRD Path from Output

Read {outputFile} frontmatter:
- Extract `prd_path`
- Extract `prd_files` array (empty if single file)

Display: "Analyzing PRD at: {prd_path}"

### 2. Read PRD File(s) with Subprocess Pattern 4 (Parallel Execution)

**If single file (prd_files array is empty):**
- Read PRD file completely
- Parse document structure
- Continue to step 3

**If multiple files (prd_files array has entries):**
- Display: "Multi-document PRD detected. Reading {count} files in parallel..."
- **SUBPROCESS PATTERN 4 - Parallel Execution:**
  - Launch ALL subprocesses simultaneously (one per PRD file)
  - Each subprocess reads its file and analyzes structure:
    - Document headings (# ## ### levels)
    - Section names
    - Presence of feature/requirement keywords
    - Technology stack mentions
    - Non-functional requirement sections
  - Wait for ALL subprocesses to complete
  - Aggregate findings from all subprocesses at once
- Display: "✅ Parallel analysis complete - {count} files processed simultaneously"
- Continue to step 3

**Subprocess return structure (one per file):**
```
{
  "file": "prd.md",
  "headings": ["# Project Overview", "## Features", "### User Management"],
  "feature_sections": ["Features", "Requirements", "User Stories"],
  "tech_stack_sections": ["Architecture", "Technology Stack"],
  "nfr_sections": ["Performance", "Security", "Scalability"]
}
```

**Performance benefit:** For N files, Pattern 4 processes all in ~1x time instead of N×time (sequential).
**Example:** 5-file PRD completes in ~1 minute instead of ~5 minutes.

### 3. Parse Document Structure

Across all PRD files, identify:

**Feature-bearing sections** (where features/requirements are listed):
- Common patterns: "Features", "Requirements", "User Stories", "Functional Requirements", "Capabilities"
- Look for numbered lists, bullet points under these headings
- Note: These are WHERE to find features, not the features themselves

**Architecture sections** (technology information):
- Common patterns: "Architecture", "Technology Stack", "Tech Stack", "Implementation", "Technologies"
- Contains: Languages, frameworks, databases, deployment targets

**Non-functional requirement sections** (performance, security, etc.):
- Common patterns: "Non-Functional Requirements", "Performance", "Security", "Scalability", "Reliability"
- Contains: Response time targets, security requirements, scale expectations

Store findings in memory.

### 4. Build Mental Model of Project Scope

Based on all PRD sections analyzed, create internal understanding of:
- **Project type:** Web app, mobile app, API, desktop app, CLI tool, etc.
- **Complexity level:** Simple (5-15 features), Medium (15-40 features), Complex (40+ features)
- **Domain:** Business app, DevOps tool, security tool, data platform, etc.
- **Key themes:** What are the major capability areas?

This mental model will guide feature extraction in step 03.

### 5. Present Analysis Summary

"**PRD Analysis Complete**

{IF single file:}
Analyzed: {prd_path}

{IF multiple files:}
Analyzed {count} PRD documents:
{list file names}

**Structure identified:**
- Feature sections: {list section names where features are found}
- Technology stack: {identified in sections: X, Y}
- Non-functional requirements: {identified in sections: X, Y}

**Project scope assessment:**
- Type: {project_type}
- Estimated complexity: {simple/medium/complex}
- Domain: {domain}

**Next:** Extract individual features from identified sections."

### 6. Present MENU OPTIONS

Display: **[A] Advanced Elicitation [P] Party Mode [C] Continue to Feature Extraction**

#### EXECUTION RULES:

- ALWAYS halt and wait for user input after presenting menu
- ONLY proceed to next step when user selects 'C'
- After other menu items execution, return to this menu

#### Menu Handling Logic:

- IF A: Execute {advancedElicitationTask}, and when finished redisplay menu
- IF P: Execute {partyModeWorkflow}, and when finished redisplay menu
- IF C: Update {outputFile} frontmatter (add 'step-02-prd-analysis' to stepsCompleted), then load, read entire file, then execute {nextStepFile}
- IF Any other: "Please select A, P, or C.", redisplay menu

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS:

- All PRD files read using subprocess Pattern 4 (parallel execution for multi-file)
- All subprocesses launched simultaneously for multi-file PRDs
- Feature-bearing sections identified across all files
- Technology stack sections identified
- Non-functional requirement sections identified
- Mental model of project scope established
- Analysis summary presented to user
- Ready to proceed to feature extraction

### ❌ SYSTEM FAILURE:

- Not using subprocess Pattern 4 for multi-file PRD analysis (sequential instead of parallel)
- Extracting features instead of just identifying sections
- Missing key sections (features, tech stack, NFRs)
- Not building mental model of project scope
- Proceeding without analysis summary
- Not launching all subprocesses in parallel (performance loss)

**Master Rule:** This is ANALYSIS ONLY - identify WHERE features are, not WHAT they are.
