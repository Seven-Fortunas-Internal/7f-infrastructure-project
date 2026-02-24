---
context-level: [1-universal | 2-domain | 3-specific | 4-ephemeral]
relevant-for:
  - [ai-agents | humans | developers | operations | executives]
last-updated: YYYY-MM-DD
author: [author-name]
status: [active | draft | archived | deprecated]
title: [optional: Document Title]
type: [optional: guide | runbook | standard | reference]
tags: [optional: list of tags]
description: [optional: Brief description for search/discovery]
---

# Document Title

Your markdown content here. This should be human-readable without needing to read the YAML frontmatter.

## Section 1

Content...

## Section 2

Content...

---

## Field Descriptions:

### Required Fields:

- **context-level**: Defines the scope/granularity of information
  - 1-universal: Fundamental concepts, applies everywhere (e.g., company mission)
  - 2-domain: Domain-specific knowledge (e.g., fintech regulations)
  - 3-specific: Specific procedures/runbooks (e.g., deploy guide)
  - 4-ephemeral: Time-sensitive info (e.g., incident notes)

- **relevant-for**: Who/what should consume this document (YAML list format)
  - ai-agents: AI systems processing this knowledge
  - humans: Human readers
  - developers: Software developers
  - operations: Operations/SRE teams
  - executives: Leadership/decision-makers
  - (add custom audiences as needed)

- **last-updated**: ISO 8601 date (YYYY-MM-DD) when document was last modified

- **author**: Name or identifier of primary author/maintainer

- **status**: Document lifecycle status
  - active: Current and maintained
  - draft: Work in progress
  - archived: No longer current but kept for reference
  - deprecated: Obsolete, replacement available

### Optional Fields:

- **title**: Document title (can also use H1 in markdown)
- **type**: Document type for categorization
- **tags**: List of searchable tags
- **description**: Brief summary for search/discovery
- **version**: Semantic version if needed
- **parent**: Path to parent document for hierarchy

## Usage Examples:

### Example 1: Universal Knowledge (Mission Statement)
```yaml
---
context-level: 1-universal
relevant-for:
  - humans
  - ai-agents
  - executives
last-updated: 2026-02-24
author: Jorge
status: active
title: "Company Mission"
---
```

### Example 2: Domain-Specific Knowledge (Fintech Guide)
```yaml
---
context-level: 2-domain
relevant-for:
  - developers
  - ai-agents
last-updated: 2026-02-24
author: Sarah
status: active
type: guide
tags: ["fintech", "compliance", "regulations"]
---
```

### Example 3: Specific Runbook (Deploy Procedure)
```yaml
---
context-level: 3-specific
relevant-for:
  - operations
  - developers
last-updated: 2026-02-24
author: DevOps Team
status: active
type: runbook
description: "Production deployment procedure for 7F Lens platform"
---
```

### Example 4: Ephemeral Document (Incident Notes)
```yaml
---
context-level: 4-ephemeral
relevant-for:
  - operations
  - developers
last-updated: 2026-02-24
author: Jorge
status: archived
type: incident
description: "Post-incident review: API outage 2026-02-20"
---
```
