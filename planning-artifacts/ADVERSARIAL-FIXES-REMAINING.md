# Remaining Adversarial Fixes

**Status:** In Progress
**Date:** 2026-02-16

## master-requirements.md (11 fixes remaining of 25)

✅ **COMPLETED (14/25):**
1. FR-1.4: Added script creation responsibility
2. FR-1.1: Added placeholder logo fallback
3. FR-1.5: Changed "exactly 10" to "10 repositories, extensible"
4. FR-2.3: Removed single device dependency
5. FR-2.4: Clarified "2 clicks or 15 seconds"
6. FR-3.1: Added BMAD update policy
7. FR-3.2: Clarified 8 custom skills breakdown
8. FR-4.1: Added max staleness threshold (7 days)
9. FR-5.1: Added owner for quarterly pattern updates
10. FR-7.2: Defined simplification criteria
11. FR-7.5: Listed all 20 workflows explicitly
12. FR-8.1: Made sprint duration configurable
13. FR-8.3: Clarified "daily-updated" not "real-time"
14. FR-8.4: Fixed GitHub CLI secret retrieval (API/web UI, not CLI)

❌ **REMAINING (11/25):**
15. FR-8.5: Fix "unlimited message history" → "1-2 years based on disk"
16. NFR-1.1: Fix fake OWASP benchmark → industry patterns
17. NFR-2.3: Fix fake Copilot benchmarks → observational data
18. NFR-4.1: Add backup decision authority (Buck if Jorge unavailable)
19. NFR-4.3: Fix "quarterly" timing inconsistency
20. NFR-6.1: Fix non-existent X API free tier
21. NFR-8.2: Define paging mechanism (PagerDuty/SMS)
22. NFR-9.1: Fix unrealistic $50/month budget → $130-150/month Phase 2
23. NFR-9.2: Define approval workflow
24. NFR-10.1: Add rollback SLA
25. FR-8.2: Add cost scaling note

## master-architecture.md (25 fixes needed)

**Critical Fixes:**
1. Line 107: Fix detection rate contradiction (95% → ≥99.5%)
2. Line 214: Fix GitHub Projects rate limit description
3. Line 220: Fix X API tier (remove free tier claim)
4. Line 232: Remove invented time estimates or add disclaimer
5. Lines 424-461: Remove Python GitHub API code (reference scripts/ instead)
6. Lines 512-543: Remove Python circuit breaker code
7. Lines 634-645: Remove Dependabot YAML config
8. Line 682: Justify 90-day Claude API key rotation
9. Line 740: Fix GitHub audit log retention (not 180 days on free tier)
10. Line 782: Reconcile budget ($5-7 vs $50)
11. Line 852-862: Remove debug mode bash script
12. Add missing architectural diagrams note
13. Remove all implementation code snippets (10+ instances)
14. Fix Git LFS mention (not specified in data architecture)
15. Fix Cloudflare free tier limit (100K req/day)
16. Fix HNSW complexity (O(log n) average, O(n) worst)
17. Fix Phase 4 rearchitecture note
18. Fix RPO off-by-one error
19. ADR-001: Add cost comparison
20. ADR-004: Fix ROI breakeven claim
21. Line 71: Fix Matrix backup inconsistency (RTO 4h, RPO 24h)
22. Add architectural diagrams
23. Line 66: VPS-only contradiction check
24. Line 215: GitHub Secrets rate limit note
25. Fix detection rate 95% → 99.5%

## master-bmad-integration.md (25 fixes needed)

**Critical Fixes:**
1. Line 20: Fix ROI 87% → 81% (correct math)
2. Line 20: Fix timeline 1.8 weeks → 1.75 weeks
3. Line 58: Update Jorge rate to realistic $150-200/h
4. Line 77: Clarify all ROI is estimated
5. Line 86 vs 95: Fix MVP skill count (25 or 26?)
6. Lines 110-116: Fix skill numbering (starts at 7 not 9)
7. Line 259: Fix "GitHub Codespaces always-on" claim
8. Line 286: Add v6.0.0 existence verification
9. Line 329: Remove fake claude-code test command
10. Line 465 vs 154: Fix 7f-manage-profile phase (1.5 or 2?)
11. Lines 571-597: Remove fuzzy matching Python code
12. Line 658: Remove premature deprecation planning
13. Line 740: Fix scoring inconsistency (2.5 points interpretation)
14. Line 782: Define security standards criteria
15. Lines 856-869: Remove regression test bash script
16. Line 916 vs 979: Fix contradictory security patch guidance
17. Line 989: Fix critical bug SLA (48h → <8h)
18. Line 992: Account for weekend unavailability
19. Lines 1040-1054: Remove dependency YAML schema
20. Lines 1059-1082: Remove dependency validation Python code
21. Line 1174: Make bmad_base_version required not optional
22. Line 1240: Fix invented version 2.3.1
23. Add error handling for missing skills
24. Add maintenance cost to ROI
25. Define skill archival retention policy

## master-implementation.md (25 fixes needed)

**Critical Fixes:**
1. Line 36: Clarify "8-9 hours + 2h buffer" math
2. Line 108: Fix broken validation logic (jq true check)
3. Line 112-118: Fix validation mismatch (categories not validated)
4. Line 171-177 vs 149: Fix schema mismatch (5 criteria vs 4 fields)
5. Lines 283-340: Minimize validate_environment.sh code (reference file)
6. Line 312: Fix gh auth grep parsing
7. Line 400: Complete JSON fix recovery procedure
8. Line 427: Note script needs creation
9. Line 478: Add bc prerequisite check
10. Line 494: Fix "should" false positive flagging
11. Line 613: Fix 100% vs 99.5% detection rate
12. Line 620: Fix 30min vs 3h Henry brand time
13. Line 639: Inline or summarize Plan B
14. Line 653: Reconcile 16h vs 6-8h Jorge time
15. Line 675-681: Fix Tier 2 count (says 10, lists 8)
16. Line 697: Fix useless cost range ($0.05-5)
17. Line 707: Fix "3+" to "3 additional"
18. Line 722: Fix 100% secret detection → 99.5%
19. Lines 282-374: Minimize bash code (move to scripts/)
20. Add rollback procedures for Day 0
21. Line 434-455: Make warnings actionable
22. Day 3 timing: Fix overlapping afternoon (Buck + Jorge)
23. Line 263: Reconcile 9-14h min vs 12-16h estimate
24. Line 269-271: Define "leadership demo" audience
25. Line 591: Make Patrick's rating objective

---

## Approach

Due to file size and token limits, I'll:
1. Complete master-requirements.md remaining 11 fixes
2. Move to master-architecture.md (prioritize critical fixes)
3. Move to master-bmad-integration.md (prioritize critical fixes)
4. Move to master-implementation.md (prioritize critical fixes)
5. Update CHANGELOG.md with all fixes

**Priority:** Critical contradictions and incorrect technical specs first, then code removal, then minor improvements.
