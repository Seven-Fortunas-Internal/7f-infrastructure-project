---
name: 'step-06-template-population'
description: 'Build complete XML structure with all 10 required sections'

nextStepFile: './step-07-final-review.md'
outputFile: '{output_folder}/app_spec.txt'
templateFile: '../templates/app-spec-template.txt'
---

# Step 6: Template Population

## STEP GOAL:

To build the complete XML structure with all 10 required sections, populating with features, categories, and metadata.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: When loading next step with 'C', ensure entire file is read
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Technical Writer creating structured specifications
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in XML structure and documentation standards
- ✅ User brings project details and requirements

### Step-Specific Rules:

- 🎯 Follow EXACT XML structure from template - this is prescriptive
- 🚫 FORBIDDEN to deviate from 10 required sections or XML format
- 💬 This is automated population - user input minimal
- 🚪 This step auto-proceeds after population (no A/P menu)

## EXECUTION PROTOCOLS:

- 🎯 Load template, populate all sections systematically
- 💾 Write complete XML structure to output file
- 📖 Validate XML well-formedness
- 🚫 This is population only - review happens in step 07

## CONTEXT BOUNDARIES:

- Available: Features with categories and criteria from steps 03-05, PRD analysis from step 02
- Focus: XML structure population
- Limits: No modifications to features, exact structure required
- Dependencies: All feature extraction and criteria generation complete

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Load Template

Load {templateFile} to understand XML structure.

Display: "Building complete app_spec.txt with 10 required sections..."

### 2. Gather All Data

Collect all information needed for population:
- Features with IDs, names, descriptions, categories, criteria (from steps 03-05)
- PRD path and files (from frontmatter)
- Project name (from config or user)
- Technology stack (from PRD analysis step 02)
- Non-functional requirements (from PRD analysis step 02)
- Current date, user name (from config)

### 3. Populate Section 1: Metadata

```xml
<metadata>
  <project_name>{project_name}</project_name>
  <generated_from>PRD at {prd_path}</generated_from>
  <generated_date>{current_date}</generated_date>
  <generated_by>{user_name}</generated_by>
  <autonomous_agent_ready>true</autonomous_agent_ready>
</metadata>
```

### 4. Populate Section 2: Overview

Extract from PRD (introduction, overview, or executive summary sections):
- Project purpose and vision
- Key objectives
- Success metrics at high level

```xml
<overview>
{executive_summary_from_prd}

Key Objectives:
- {objective_1}
- {objective_2}
- {objective_3}
</overview>
```

### 5. Populate Section 3: Technology Stack

From PRD analysis (step 02 findings):

```xml
<technology_stack>
Languages: {languages_from_prd}
Frameworks: {frameworks_from_prd}
Databases: {databases_from_prd}
Deployment: {deployment_targets_from_prd}
Key Libraries: {libraries_from_prd}
</technology_stack>
```

### 6. Populate Section 4: Coding Standards

From PRD or use BMM defaults:

```xml
<coding_standards>
Style Guide: {style_guide_from_prd or language defaults}
Naming Conventions: {conventions_from_prd or standards}
File Organization: {structure_from_prd or best practices}
Code Review: {review_process_if_specified}
Documentation: {doc_standards_if_specified}
</coding_standards>
```

### 7. Populate Section 5: Core Features (CRITICAL)

For each category with features:

```xml
<core_features>
  <feature_group name="Infrastructure & Foundation">
    <feature id="FEATURE_001">
      <name>{feature_name}</name>
      <description>{feature_description}</description>
      <requirements>
        - {requirement_1}
        - {requirement_2}
      </requirements>
      <acceptance_criteria>
        {FOR EACH verification criterion:}
        - {functional_criterion}
        - {technical_criterion}
        - {integration_criterion}
      </acceptance_criteria>
      <dependencies>
        {IF dependencies exist:}
        - FEATURE_XXX
        {ELSE:}
        - None
      </dependencies>
      <constraints>
        - {constraint_derived_from_requirements or "Follow coding standards"}
      </constraints>
    </feature>
    {REPEAT for all features in this category}
  </feature_group>

  <feature_group name="User Interface">
    {REPEAT feature structure for all UI features}
  </feature_group>

  {REPEAT for all 7 categories that have features}
</core_features>
```

**CRITICAL:** Include ALL features extracted, grouped by their assigned category.

### 8. Populate Section 6: Non-Functional Requirements

From PRD analysis:

```xml
<non_functional_requirements>
  <performance>
{performance_requirements_from_prd}
  </performance>
  <security>
{security_requirements_from_prd}
  </security>
  <scalability>
{scalability_requirements_from_prd}
  </scalability>
  <monitoring>
{monitoring_requirements_from_prd or defaults}
  </monitoring>
</non_functional_requirements>
```

### 9. Populate Section 7: Testing Strategy

From PRD or use best practices:

```xml
<testing_strategy>
Unit Testing: {unit_test_approach_from_prd or standard approach}
Integration Testing: {integration_test_approach}
E2E Testing: {e2e_test_approach}
Test Coverage: {coverage_targets_from_prd or 80% minimum}
Test Framework: {framework_from_tech_stack}
</testing_strategy>
```

### 10. Populate Section 8: Deployment Instructions

From PRD or architecture section:

```xml
<deployment_instructions>
Build Process: {build_steps_from_prd}
Deployment Target: {target_environment_from_prd}
Configuration Management: {config_approach_from_prd}
Environment Variables: {env_vars_if_specified}
</deployment_instructions>
```

### 11. Populate Section 9: Reference Documentation

From PRD or architecture docs:

```xml
<reference_documentation>
{IF architecture doc referenced:}
Architecture Document: {path_or_link}
{IF ADRs referenced:}
Architecture Decision Records: {path_or_link}
{IF design docs referenced:}
Design Documents: {path_or_link}
{ELSE if none:}
See PRD at {prd_path} for additional context
</reference_documentation>
```

### 12. Populate Section 10: Success Criteria

From PRD objectives:

```xml
<success_criteria>
{success_metrics_from_prd_objectives}

Feature Completion: All {feature_count} features implemented and verified
Test Coverage: {coverage_target}% across all features
Quality Gate: All verification criteria passing
Autonomous Agent Completion: feature_list.json shows all features with status "pass"
</success_criteria>
```

### 13. Validate XML Well-Formedness

Check generated XML:
- All opening tags have closing tags
- Proper nesting maintained
- No syntax errors
- All 10 sections present

**If validation errors:** Fix before proceeding

### 14. Write Complete App Spec to Output File

Write the complete XML structure to {outputFile}, preserving frontmatter:

```yaml
---
stepsCompleted: ['step-01-init', 'step-02-prd-analysis', 'step-03-feature-extraction', 'step-04-auto-categorization', 'step-05-criteria-generation', 'step-06-template-population']
lastStep: 'step-06-template-population'
created_date: '{date}'
user_name: '{user_name}'
project_name: '{project_name}'
prd_path: '{prd_path}'
prd_files: [{list}]
feature_count: {count}
workflow_status: 'ready_for_review'
---

{COMPLETE XML STRUCTURE FROM STEPS 3-12}
```

### 15. Present Completion Summary

"**Template Population Complete**

✅ All 10 required sections populated
✅ {feature_count} features organized into {category_count} categories
✅ XML structure validated (well-formed)
✅ app_spec.txt written to: {outputFile}

**File size:** {size} KB
**Feature groups:** {list categories with feature counts}

**Next:** Review complete app_spec before finalizing.

**Auto-proceeding to final review...**"

### 16. Auto-Proceed to Next Step

**No menu - this step auto-proceeds after population.**

Update {outputFile} frontmatter (confirm stepsCompleted includes 'step-06-template-population'), then load, read entire file, then execute {nextStepFile}.

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS:

- All 10 required sections populated with correct XML structure
- All features included in core_features section
- Features grouped by assigned categories
- XML is well-formed (valid structure)
- Complete app_spec written to output file
- Frontmatter updated with all completed steps
- Ready for final review

### ❌ SYSTEM FAILURE:

- Missing any of the 10 required sections
- Malformed XML (syntax errors)
- Features not grouped by category
- Incorrect XML nesting
- Not all features included
- Not validating XML before writing
- Deviating from template structure

**Master Rule:** Follow EXACT XML structure. All 10 sections required. Validate before writing.
