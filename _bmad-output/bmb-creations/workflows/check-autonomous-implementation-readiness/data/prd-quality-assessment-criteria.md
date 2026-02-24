# PRD Quality Assessment Criteria

## PRD Structure Completeness

**Required Sections:**
- Executive Summary / Overview
- Success Criteria / Goals
- User Journeys / Use Cases
- Functional Requirements
- Non-Functional Requirements
- Domain Requirements / Business Rules
- Out of Scope / Constraints

**Scoring Bands:**
- **90-100:** All required sections present and substantive
- **70-89:** Most sections present, some thin
- **50-69:** Several missing sections
- **0-49:** Major sections missing

---

## Functional Requirements Quality Dimensions

### 1. Clarity
- Are FRs specific and unambiguous?
- No vague language like "user-friendly" without definition
- Clear actors, actions, and outcomes

### 2. Testability
- Can each FR be verified/tested?
- Observable and measurable outcomes
- Clear pass/fail criteria

### 3. Completeness
- Do FRs cover all user journeys?
- Edge cases and error handling included
- No critical workflows missing

### 4. Acceptance Criteria
- Does each FR have clear AC?
- AC is specific and testable
- AC aligns with FR intent

**Scoring Bands:**
- **90-100:** All FRs clear, testable, complete
- **70-89:** Most FRs high quality, some ambiguous
- **50-69:** Many FRs lack clarity or testability
- **0-49:** FRs severely lacking in quality

---

## Non-Functional Requirements Quality Dimensions

### 1. Coverage
- **Security:** Authentication, authorization, data protection
- **Performance:** Response times, throughput, resource limits
- **Scalability:** Growth handling, load capacity
- **Reliability:** Uptime, fault tolerance, recovery

### 2. Specificity
- Are NFRs measurable (not vague)?
- Quantitative metrics provided (e.g., "99.9% uptime", "response < 200ms")
- Clear thresholds for acceptable performance

### 3. Feasibility
- Are NFRs realistic and achievable?
- Aligned with available resources and technology
- No contradictory NFRs

### 4. Priority
- Are critical NFRs identified?
- Must-have vs. nice-to-have clearly marked
- Trade-offs acknowledged

**Scoring Bands:**
- **90-100:** Comprehensive NFR coverage, all measurable and realistic
- **70-89:** Good coverage, some vague NFRs
- **50-69:** Limited coverage, many unmeasurable NFRs
- **0-49:** NFRs severely lacking or absent

---

## Success Criteria Quality Dimensions

### 1. Clarity
- Are success metrics clear and measurable?
- No ambiguous terms like "successful" without definition
- Specific quantitative or qualitative indicators

### 2. Alignment
- Do success criteria align with requirements?
- Criteria match project goals and FRs
- No missing critical success measures

### 3. Feasibility
- Are goals realistic?
- Achievable within constraints
- Time-bound and resource-appropriate

**Scoring Bands:**
- **90-100:** All criteria clear, measurable, aligned, and realistic
- **70-89:** Most criteria well-defined, some ambiguity
- **50-69:** Success criteria vague or misaligned
- **0-49:** Success criteria absent or unusable

---

**Analysis Guidance:**

1. **Evidence-Based Scoring:** Always reference specific PRD sections, FR IDs, or NFR IDs
2. **No Generic Comments:** Avoid "mostly good" - provide specific examples
3. **Flag Ambiguities:** Note any requirements requiring clarification
4. **Be Objective:** Use rubric consistently across all PRDs
