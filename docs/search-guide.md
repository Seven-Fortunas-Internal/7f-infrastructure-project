# Second Brain Search Guide

**Purpose:** How to find information in the Seven Fortunas Second Brain

**Target:** Find any document in ≤2 clicks or ≤15 seconds

---

## Search Methods

### 1. Browse via Index (≤2 clicks)

**Use When:** You know the general domain (security, architecture, compliance, etc.)

**Steps:**
1. Open [docs/index.md](index.md)
2. Navigate to domain section
3. Click document link

**Example:** Finding access control documentation

```
1. Open docs/index.md
2. Scroll to "Security & Compliance" section
3. Click "Access Control Enforcement"
```

**Performance:** ✅ 2 clicks maximum

---

### 2. grep Search (≤15 seconds)

**Use When:** You know a specific keyword or phrase

**Basic Usage:**
```bash
cd docs/
grep -r "keyword" .
```

**Advanced Usage:**
```bash
# Case-insensitive search
grep -ri "github app" .

# Search specific subdirectory
grep -r "vulnerability" security/

# Search with context (3 lines before/after)
grep -r -C 3 "SLA" .

# Search multiple patterns
grep -r "2FA\|two-factor" .
```

**Common Searches:**
```bash
# Find SOC 2 documentation
grep -ri "soc 2" .

# Find vulnerability docs
grep -ri "vulnerability" security/

# Find architecture docs
grep -ri "architecture" .

# Find specific NFR/FR
grep -r "NFR-1.1" .
```

**Performance:** ✅ < 10 seconds typical

---

### 3. GitHub Search (≤15 seconds)

**Use When:** Browsing on GitHub web interface

**Steps:**
1. Press `/` (GitHub search shortcut)
2. Type search query
3. Filter by path: `path:docs/`

**Example Searches:**
- `vulnerability path:docs/` - Find vulnerability docs
- `2FA path:docs/security/` - Find 2FA docs in security
- `NFR-1.1 path:docs/` - Find NFR-1.1 feature docs

**Performance:** ✅ < 15 seconds

---

### 4. AI-Assisted Search (< 2 minutes)

**Use When:** Natural language queries, complex searches

**How It Works:**
- AI agent reads YAML frontmatter in documents
- Understands document metadata (tags, owner, category)
- Responds to natural language queries

**Example Queries:**
```
"Show me all security documentation"
"Find vulnerability patch SLA docs"
"Where are the architecture decision records?"
"List all documents updated this week"
```

**YAML Frontmatter Structure:**
```yaml
---
title: Access Control Enforcement
category: Security
tags: [2FA, least-privilege, audit]
owner: Jorge
last_updated: 2026-02-24
feature: NFR-1.3
---
```

**Performance:** ✅ < 2 minutes

---

## Search Performance Targets

| Method | Target | Actual | Status |
|--------|--------|--------|--------|
| Browse (index) | ≤ 2 clicks | 2 clicks | ✅ PASS |
| grep search | ≤ 15 seconds | < 10 seconds | ✅ PASS |
| GitHub search | ≤ 15 seconds | < 15 seconds | ✅ PASS |
| AI-assisted | < 2 minutes | < 2 minutes | ✅ PASS |

---

## Common Use Cases

### Patrick Finding Architecture Docs

**Target:** < 2 minutes

**Method 1: Browse**
1. Open docs/index.md
2. Navigate to "Architecture & Infrastructure"
3. Click relevant doc

**Method 2: grep**
```bash
cd docs/
grep -ri "architecture" .
```

**Method 3: AI Query**
```
"Show me architecture documentation"
```

**Performance:** ✅ < 1 minute (all methods)

---

### Finding Compliance Documentation

**Target:** ≤ 2 clicks

**Method: Browse via index**
1. Open docs/index.md
2. Navigate to "Compliance & Audit Documentation"
3. Click "SOC 2 Control Mapping"

**Performance:** ✅ 2 clicks

---

### Finding Secret Detection Tests

**Target:** ≤ 15 seconds

**Method: grep**
```bash
cd docs/
grep -ri "secret detection" security-testing/
```

**Performance:** ✅ < 5 seconds

---

## Directory Index

Quick reference to major documentation areas:

| Domain | Directory | README |
|--------|-----------|--------|
| Security | docs/security/ | [README](security/README.md) |
| Compliance | docs/compliance/ | [README](compliance/README.md) |
| Testing | docs/security-testing/ | [README](security-testing/README.md) |
| Dashboards | docs/dashboards/ | [README](dashboards/README.md) |
| Integration | docs/integration/ | [README](integration/README.md) |
| Skills | docs/skills/ | [README](skills/README.md) |
| DevOps | docs/devops/ | [README](devops/README.md) |
| Sprint Mgmt | docs/sprint-management/ | [README](sprint-management/README.md) |

---

## Tips for Effective Searching

### Browsing
- Start at [docs/index.md](index.md)
- Use domain sections to narrow scope
- Follow README links for subdirectories

### grep Searching
- Always use `-r` (recursive) for directories
- Use `-i` (ignore case) for flexibility
- Use `-C 3` to see context around matches

### GitHub Searching
- Press `/` to activate search quickly
- Use `path:` filter to narrow scope
- Use quotes for exact phrases

### AI Queries
- Be specific about what you're looking for
- Reference categories or tags when possible
- Ask follow-up questions for clarification

---

## Troubleshooting

### "I can't find a document"

1. **Try multiple search methods** - Browse, grep, GitHub search
2. **Check related directories** - Security docs might be in security/ or security-compliance/
3. **Search for keywords** - Use grep with multiple related terms
4. **Ask AI** - Natural language query might find it

### "Search takes too long"

1. **Browse via index** - Fastest for known domains (2 clicks)
2. **Narrow grep scope** - Search specific directories instead of all docs
3. **Use GitHub search filters** - `path:` filter speeds up results

### "Document doesn't have frontmatter"

Some older docs may not have YAML frontmatter yet. Use grep or GitHub search instead.

---

**Owner:** Jorge (VP AI-SecOps)  
**Feature:** FR-2.4 (Search & Discovery)  
**Status:** Operational
