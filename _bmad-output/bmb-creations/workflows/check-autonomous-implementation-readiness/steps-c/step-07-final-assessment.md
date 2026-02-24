---
name: 'step-07-final-assessment'
description: 'Generate comprehensive readiness report with go/no-go decision'

outputFile: '{output_folder}/readiness-assessment-{project_name}.md'
goNoGoFramework: '../data/go-nogo-decision-framework.md'
actionItemPrioritizationFramework: '../data/action-item-prioritization-framework.md'
finalAssessmentOutputTemplate: '../data/final-assessment-output-template.md'
---

# Step 7: Final Assessment

## STEP GOAL:

To synthesize all analysis findings into a comprehensive readiness report with overall readiness score, go/no-go decision, prioritized action items, and recommendations for autonomous agent implementation.

## MANDATORY EXECUTION RULES (READ FIRST):

### Universal Rules:

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action
- 🔄 CRITICAL: This is the final step - no next step to load
- 📋 YOU ARE A FACILITATOR, not a content generator
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`

### Role Reinforcement:

- ✅ You are a Technical Program Manager delivering final assessment
- ✅ We engage in collaborative dialogue, not command-response
- ✅ You bring expertise in synthesizing technical assessments
- ✅ User brings project context for interpreting recommendations
- ✅ Together we determine implementation readiness

### Step-Specific Rules:

- 🎯 Focus on synthesizing ALL prior analysis steps
- 🚫 FORBIDDEN to introduce new analysis - synthesize existing
- 💬 Provide clear, actionable go/no-go decision with rationale
- 🎯 Prioritize action items by criticality (critical/high/medium/low)

## EXECUTION PROTOCOLS:

- 🎯 Synthesize all analysis dimensions into final report
- 💾 Complete the output file with final assessment sections
- 📖 Update frontmatter with final readiness_score and go_no_go decision
- 🚫 This is the completion step - finalize all outputs

## CONTEXT BOUNDARIES:

- Available: All prior analysis from steps 02-06
- Focus: Synthesis and decision-making
- Limits: No new analysis - use existing findings
- Dependencies: Completed analysis from all previous steps

## MANDATORY SEQUENCE

**CRITICAL:** Follow this sequence exactly. Do not skip, reorder, or improvise unless user explicitly requests a change.

### 1. Load All Analysis Results from Output File

Read `{outputFile}` frontmatter to retrieve all scores:
- `prd_completeness_score`
- `prd_quality_score`
- `appspec_coverage_score`
- `architecture_alignment_score`
- `feature_quality_score`
- `autonomous_readiness_score`

Display: "**Generating final readiness assessment...**"

### 2. Calculate Overall Readiness Score

**Weighted Average Calculation:**
- PRD Quality: 20% weight
- App Spec Coverage: 25% weight
- Architecture Alignment: 20% weight
- Feature Quality: 35% weight (highest weight - most critical for autonomous success)

**Overall Readiness Score** = (PRD * 0.20) + (Coverage * 0.25) + (Architecture * 0.20) + (Feature Quality * 0.35)

**Score Interpretation:**
- 90-100: Excellent - Ready for autonomous implementation
- 75-89: Good - Minor refinements recommended
- 60-74: Fair - Moderate improvements needed before implementation
- 45-59: Poor - Significant work required before implementation
- 0-44: Critical - Not ready for autonomous implementation

### 3. Determine Go/No-Go Decision

Apply decision logic per `{goNoGoFramework}`.

**Decision Framework:**
- **GO:** Score ≥75, no critical blockers, coverage ≥70, feature quality ≥70
- **CONDITIONAL GO:** Score 60-74, 1-2 blockers with mitigation, coverage 60-69
- **NO-GO:** Score <60, 3+ blockers, coverage <60, feature quality <60

Make decision and document rationale:

```
go_no_go: 'GO' | 'CONDITIONAL GO' | 'NO-GO'
decision_rationale: '{Clear explanation based on scores and blockers}'
```

Refer to framework for detailed criteria and examples.

### 4. Compile Dimension Breakdown

Create detailed breakdown of all assessment dimensions:

"**Dimension Breakdown:**

1. **PRD Analysis:** {prd_quality_score}/100
   - Strengths: {Key strengths from step-03}
   - Gaps: {Key gaps from step-03}

2. **App Spec Coverage:** {appspec_coverage_score}/100
   - Coverage: {coverage percentage}% of PRD requirements
   - Gaps: {count} requirements not covered

3. **Architecture Alignment:** {architecture_alignment_score}/100
   - Compliance: {Summary from step-05}
   - Violations: {count} architectural violations

4. **Feature Quality:** {feature_quality_score}/100
   - High-Quality Features: {count}/{total}
   - Critical Blockers: {count}"

### 5. Generate Prioritized Action Items

Extract all gaps, concerns, and recommendations from previous steps and prioritize per `{actionItemPrioritizationFramework}`.

**Priority Levels:**
- **Critical:** Blocks implementation (critical blockers, violations, 0% coverage items)
- **High:** Significant quality impact (moderate issues, partial gaps)
- **Medium:** Improvements during development (low-priority quality, enhancements)
- **Low:** Nice to have (documentation, process optimizations)

Generate action items with full detail:

"**Action Items Generated:**

**Critical ({count}):**
1. **{Title}** - Source: {step-XX}
   - Issue: {What's wrong}
   - Impact: {Why it blocks}
   - Fix: {How to address}
   - Effort: {Time estimate}

**High Priority ({count}):**
1. {Action item with full detail}

**Medium Priority ({count}):**
1. {Action item with full detail}

**Low Priority ({count}):**
1. {Action item with full detail}"

Refer to framework for detailed prioritization rules and examples.

### 6. Generate Implementation Recommendations

Based on the overall assessment, provide strategic recommendations:

**For GO decisions:**
- Recommended implementation approach
- Key success factors to monitor
- Risk mitigation strategies
- Suggested autonomous agent configuration

**For CONDITIONAL GO:**
- Conditions that must be met first
- Estimated effort to address conditions
- Recommended sequence of addressing gaps

**For NO-GO:**
- Critical improvements needed before reassessment
- Estimated effort to reach readiness
- Alternative approaches to consider

### 7. Complete Output File with Final Sections

Generate final assessment sections per `{finalAssessmentOutputTemplate}`.

**Template Structure:**
1. Overall Readiness Assessment (scores, decision, rationale)
2. Action Items (4 priority levels with full detail)
3. Recommendations for Autonomous Agent Success (strategy, risks, criteria, configuration)
4. Assessment footer (metadata)

**Update `{outputFile}` with three sections:**

**Section 1: Overall Readiness Assessment**
- Overall score with dimension breakdown
- Go/No-Go decision with rationale

**Section 2: Action Items**
- Critical, High, Medium, Low priority items
- Full detail: Issue, Impact, Suggested Fix, Effort

**Section 3: Recommendations**
- Implementation strategy (tailored to GO/CONDITIONAL/NO-GO)
- Risk mitigation strategies
- Success criteria (measurable)
- Autonomous agent configuration

Update frontmatter:
```yaml
analysis_phase: 'complete'
readiness_score: {overall_readiness_score}
go_no_go: '{GO | CONDITIONAL GO | NO-GO}'
critical_action_items_count: {count}
assessment_completed: {timestamp}
```

Refer to template for complete markdown format and field specifications.

### 8. Present Final Assessment Summary

Display comprehensive summary to user:

"**═══════════════════════════════════════**
**   IMPLEMENTATION READINESS ASSESSMENT   **
**═══════════════════════════════════════**

**Overall Readiness Score:** {readiness_score}/100

**Go/No-Go Decision:** {go_no_go}

**Assessment Summary:**
- PRD Quality: {prd_quality_score}/100 - {interpretation}
- App Spec Coverage: {appspec_coverage_score}/100 - {interpretation}
- Architecture Alignment: {architecture_alignment_score}/100 - {interpretation}
- Feature Quality: {feature_quality_score}/100 - {interpretation}

**Decision Rationale:**
{decision_rationale}

**Critical Action Items:** {count}
**High Priority Items:** {count}

**Readiness Interpretation:**
{Detailed interpretation of what the score means for autonomous implementation}

**Recommendation:**
{Clear recommendation on next steps}

**═══════════════════════════════════════**

**📄 Full Report:** {outputFile}

**Next Steps:**
{if GO: Proceed with autonomous agent implementation}
{if CONDITIONAL GO: Address conditions, then proceed}
{if NO-GO: Complete critical action items, re-run assessment}"

### 9. Offer Report Actions

Display final menu:

"**Assessment Complete! What would you like to do?**

[V] View full report
[S] Save report to different location
[E] Export action items as checklist
[X] Exit workflow

Please select: [V/S/E/X]"

Handle user selection:

**IF V:** Display or open the full report file
**IF S:** Prompt for new location and save copy
**IF E:** Extract action items to standalone checklist file
**IF X:** Exit workflow

### 10. Workflow Completion

"**✅ Autonomous Implementation Readiness Assessment Complete**

**Report Location:** {outputFile}
**Overall Readiness:** {readiness_score}/100 - {go_no_go}

Thank you for using check-autonomous-implementation-readiness workflow.

**Workflow complete.**"

## 🚨 SYSTEM SUCCESS/FAILURE METRICS:

### ✅ SUCCESS:

- All dimension scores retrieved and synthesized
- Overall readiness score calculated correctly
- Clear go/no-go decision made with rationale
- Action items prioritized and compiled
- Implementation recommendations provided
- Final assessment sections completed in output file
- Frontmatter updated with final scores and decision
- User understands assessment results and next steps

### ❌ SYSTEM FAILURE:

- Missing dimension scores
- Unclear or missing go/no-go decision
- Action items not prioritized by criticality
- Generic recommendations without specifics
- Incomplete output file
- Not updating frontmatter with final decision

**Master Rule:** The final assessment must synthesize ALL prior analysis. Every recommendation and action item must reference specific findings from previous steps. Generic assessments are FORBIDDEN - provide evidence-based, actionable conclusions.

**This is the final step. The workflow is now complete.**
