# Feature Category Distribution Standards

## 7 Required Domain Categories

Check feature categorization against these categories:

1. Infrastructure & Foundation
2. User Interface
3. Business Logic
4. Integration
5. DevOps & Deployment
6. Security & Compliance
7. Testing & Quality

## Distribution Assessment Rules

**Validation Checks:**
- All features assigned to one of 7 categories: {✅ Yes / ❌ No - {count} uncategorized}
- No custom categories outside 7 domains: {✅ Yes / ❌ No - {list custom categories}}
- Distribution balanced (no single category >60%): {✅ Yes / ⚠️ No - {category}: {percentage}%}
- Infrastructure category present (for non-trivial projects): {✅ Yes / ⚠️ Missing}
- At least 3 categories represented: {✅ Yes / ❌ Only {count} categories}

## Category Distribution Presentation Template

```
**Category Distribution:**
- Infrastructure: {count} features ({percentage}%)
- User Interface: {count} features ({percentage}%)
- Business Logic: {count} features ({percentage}%)
- Integration: {count} features ({percentage}%)
- DevOps: {count} features ({percentage}%)
- Security: {count} features ({percentage}%)
- Testing: {count} features ({percentage}%)
```

## Distribution Scoring Formula

**Distribution Score:** {0-100}
- 90-100: Balanced, all 7 categories, no category >40%
- 70-89: Good distribution, 5+ categories, no category >60%
- 50-69: Adequate, 3+ categories, some imbalance
- 0-49: Poor distribution or missing categories
