# Universal Step Execution Rules

**Purpose:** Standard execution rules for all step files in autonomous implementation workflow.

---

## MANDATORY EXECUTION RULES

### Universal Rules (Apply to ALL Steps)

- 🛑 **NEVER generate without user input**
- 📖 **Read complete step file before action**
- 🔄 **When loading with 'C', read entire file**
- 📋 **Facilitator, not generator**

### Role Structure (Varies by Step)

Each step defines:
- ✅ **Role:** What this step does
- ✅ **Collaborative dialogue:** How step interacts with user
- ✅ **You bring:** Agent's responsibilities
- ✅ **User brings:** User's input/artifacts

### Step-Specific Rules

Each step defines:
- 🎯 **Focus:** Primary objective
- 🚫 **Forbidden:** Actions to avoid
- 💬 **Approach:** Execution style

---

## EXECUTION PROTOCOLS (Standard)

Each step follows:
- 🎯 Follow MANDATORY SEQUENCE exactly
- 💾 Perform operations as specified
- 📖 Save/update tracking files appropriately

---

## CONTEXT BOUNDARIES (Standard)

Each step defines:
- **Available:** What data/files are accessible
- **Focus:** What this step accomplishes
- **Limits:** What this step does NOT do
- **Dependencies:** What must exist before this step

---

## SUCCESS/FAILURE CRITERIA (Standard)

### ✅ SUCCESS
Steps define what must be achieved for success.

### ❌ FAILURE
Steps define failure conditions and exit codes.

**Master Rule:** Each step has a specific success criteria that must be met.

---

**Version:** 1.0.0
**Applies To:** All step files in run-autonomous-implementation workflow
**Usage:** Reference this file instead of duplicating rules in each step
