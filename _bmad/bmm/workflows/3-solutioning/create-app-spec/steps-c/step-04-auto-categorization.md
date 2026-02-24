---
name: 'step-04-auto-categorization'
description: 'Classify features into 7 domain categories'

nextStepFile: './step-05-criteria-generation.md'
outputFile: '{output_folder}/app_spec.txt'
categoriesDataFile: '../data/feature-categories.md'
advancedElicitationTask: '{project-root}/_bmad/core/workflows/advanced-elicitation/workflow.xml'
partyModeWorkflow: '{project-root}/_bmad/core/workflows/party-mode/workflow.md'
---

# Step 4: Auto-Categorization

## STEP GOAL:

To classify all extracted features into 7 domain categories using keyword analysis and context understanding.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`
- ⚙️ TOOL/SUBPROCESS FALLBACK: If subprocess unavailable, categorize in main thread

### Role Reinforcement:

- ✅ You are a Software Architect expert in feature classification
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in domain categorization and architectural patterns
- ✅ User brings project context and can adjust categories

### Step-Specific Rules:

- 🎯 Use subprocess Pattern 4 for parallel categorization if 30+ features
- 💬 Subprocess launches in parallel, each returns category assignment for features
- 🚫 FORBIDDEN to create custom categories - use only the 7 defined domains
- ⚙️ If subprocess unavailable, categorize features sequentially

## EXECUTION PROTOCOLS:

- 🎯 Load 7 domain categories from data file
- 💾 Assign category to each feature using keyword matching
- 📖 Validate distribution (no inappropriate domination)
- 🚫 Allow user to adjust categories before proceeding

## CONTEXT BOUNDARIES:

- Available: Extracted features from step 03 with IDs
- Focus: Domain categorization only
- Limits: Don't generate criteria yet, don't modify features
- Dependencies: Features extracted in step 03

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Load Domain Categories

Load {categoriesDataFile} to understand the 7 domain categories:

1. **Infrastructure & Foundation** - Core services, databases, authentication, data models
2. **User Interface** - Screens, components, interactions, forms, navigation
3. **Business Logic** - Workflows, calculations, rules, algorithms, processing
4. **Integration** - APIs, external services, data sync, webhooks, third-party connectors
5. **DevOps & Deployment** - CI/CD, monitoring, logging, infrastructure as code
6. **Security & Compliance** - Authorization, encryption, audit logging, compliance checks
7. **Testing & Quality** - Test infrastructure, validation, quality gates, test utilities

Display: "Loaded 7 domain categories for classification"

### 2. Determine Categorization Approach

Check feature count:

**If 30+ features:** Use subprocess Pattern 4 for parallel categorization
**If <30 features:** Categorize sequentially in main thread

### 3. Categorize Features

**For each feature, apply categorization logic:**

**Keyword matching patterns:**
- **Infrastructure:** "database", "auth", "login", "session", "model", "schema", "API key", "config"
- **UI:** "screen", "page", "form", "button", "navigation", "component", "dashboard", "view"
- **Business Logic:** "calculate", "process", "validate", "workflow", "rule", "algorithm", "compute"
- **Integration:** "API", "webhook", "external", "sync", "import", "export", "third-party", "connector"
- **DevOps:** "deploy", "CI/CD", "monitoring", "logging", "metrics", "infrastructure", "Docker"
- **Security:** "encrypt", "permission", "role", "audit", "compliance", "secure", "token"
- **Testing:** "test", "validation", "mock", "fixture", "quality", "coverage"

**Context analysis:**
- Read feature name and description
- Check PRD section context
- Consider dependencies (if feature depends on auth, likely Infrastructure or Security)

**If using subprocess (30+ features):**
- Launch subprocesses in parallel
- Each subprocess categorizes a subset of features
- Aggregate results from all subprocesses

**Subprocess return structure:**
```
{
  "feature_id": "FEATURE_001",
  "assigned_category": "Infrastructure & Foundation",
  "confidence": "high",
  "reasoning": "Contains authentication keywords and creates core session management"
}
```

### 4. Group Features by Category

Organize all features into their assigned categories:

```
Infrastructure & Foundation: [FEATURE_001, FEATURE_005, ...]
User Interface: [FEATURE_010, FEATURE_012, ...]
Business Logic: [FEATURE_015, FEATURE_020, ...]
Integration: [FEATURE_025, ...]
DevOps & Deployment: [FEATURE_030, ...]
Security & Compliance: [FEATURE_003, FEATURE_008, ...]
Testing & Quality: [FEATURE_040, ...]
```

### 5. Validate Distribution

Check category distribution:

**Warning conditions:**
- Any single category has >50% of all features (inappropriate domination)
- Fewer than 2 categories represented (too narrow)
- Infrastructure has <5% of features for complex project (likely missing foundational features)

**If warnings detected:** Flag for user review

### 6. Present Categorization Summary

"**Auto-Categorization Complete**

{count} features classified into 7 domain categories:

**Distribution:**
- Infrastructure & Foundation: {count} features ({percentage}%)
- User Interface: {count} features ({percentage}%)
- Business Logic: {count} features ({percentage}%)
- Integration: {count} features ({percentage}%)
- DevOps & Deployment: {count} features ({percentage}%)
- Security & Compliance: {count} features ({percentage}%)
- Testing & Quality: {count} features ({percentage}%)

{IF warnings:}
⚠️  **Distribution Warnings:**
{list warnings}

{IF no warnings:}
✅ Distribution looks balanced

**Sample categorization:**
- FEATURE_001 ({name}) → {category}
- FEATURE_002 ({name}) → {category}
- ...

**Options:**
[A]ccept categorization and continue
[R]ecategorize specific features
[C]ontinue with Advanced Elicitation review"

Wait for user selection.

### 7. Handle Recategorization (If User Selects R)

"**Which features should be recategorized?**

Enter feature IDs (comma-separated): "

Wait for user input (e.g., "FEATURE_005, FEATURE_012")

For each specified feature:
- Display current category
- Display available categories
- Ask user to select new category
- Update feature's category

After all recategorizations, return to step 6 menu.

### 8. Present MENU OPTIONS

Display: **[A] Advanced Elicitation [P] Party Mode [C] Continue to Criteria Generation**

#### EXECUTION RULES:

- ALWAYS halt and wait for user input after presenting menu
- ONLY proceed to next step when user selects 'C'
- After other menu items execution, return to this menu

#### Menu Handling Logic:

- IF A: Execute {advancedElicitationTask}, and when finished redisplay menu
- IF P: Execute {partyModeWorkflow}, and when finished redisplay menu
- IF C: Update {outputFile} frontmatter (add 'step-04-auto-categorization' to stepsCompleted), then load, read entire file, then execute {nextStepFile}
- IF Any other: "Please select A, P, or C.", redisplay menu

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS:

- All features assigned to one of 7 domain categories
- Keyword matching and context analysis applied
- Subprocess Pattern 4 used for 30+ features
- Distribution validated
- User given opportunity to adjust categories
- Ready to proceed to criteria generation

### ❌ SYSTEM FAILURE:

- Features assigned to custom categories (not one of the 7)
- Not using subprocess for large feature sets
- No distribution validation
- Proceeding with inappropriate domination (one category >50%)
- Not allowing user to adjust categories

**Master Rule:** Use only the 7 defined domain categories. Balance matters.
