#!/bin/bash
# Analyze Skill Usage
# Generates usage reports and consolidation recommendations

set -e

USAGE_LOG=".claude/commands/.skill-usage.log"
COMMANDS_DIR=".claude/commands"

echo "==================================================================="
echo "Seven Fortunas Skill Usage Analysis"
echo "==================================================================="
echo ""

# Check if usage log exists
if [ ! -f "$USAGE_LOG" ]; then
    echo "⚠️  No usage data available yet."
    echo "Usage tracking will begin automatically as skills are used."
    exit 0
fi

# Total invocations
TOTAL_INVOCATIONS=$(wc -l < "$USAGE_LOG")
echo "Total Skill Invocations: $TOTAL_INVOCATIONS"
echo ""

# Top 10 most used skills
echo "Top 10 Most Used Skills:"
echo "───────────────────────────────────────────────────────────────"
awk -F'|' '{print $2}' "$USAGE_LOG" | \
    sort | uniq -c | sort -rn | head -10 | \
    awk '{printf "  %3d uses  %s\n", $1, $2}'
echo ""

# Skills used in last 30 days
THIRTY_DAYS_AGO=$(date -u -d '30 days ago' +%Y-%m-%d 2>/dev/null || date -u -v-30d +%Y-%m-%d)
RECENT_USES=$(awk -F'|' -v cutoff="$THIRTY_DAYS_AGO" '$1 >= cutoff' "$USAGE_LOG" | wc -l)
echo "Skills Used (Last 30 Days): $RECENT_USES"
echo ""

# Unused skills (never invoked)
echo "Unused Skills (Never Invoked):"
echo "───────────────────────────────────────────────────────────────"
ALL_SKILLS=$(find "$COMMANDS_DIR" -name "*.md" -type f | xargs -n1 basename | sort)
USED_SKILLS=$(awk -F'|' '{print $2}' "$USAGE_LOG" | sort -u)

UNUSED=0
while IFS= read -r skill; do
    skill_basename=$(basename "$skill" .md)
    if ! echo "$USED_SKILLS" | grep -q "^$skill_basename$"; then
        echo "  - $skill"
        ((UNUSED++))
    fi
done <<< "$ALL_SKILLS"

if [ "$UNUSED" -eq 0 ]; then
    echo "  (All skills have been used at least once)"
fi
echo ""
echo "Total Unused: $UNUSED skills"
echo ""

# Consolidation candidates (similar skill names)
echo "Consolidation Candidates (Similar Skill Names):"
echo "───────────────────────────────────────────────────────────────"

# Find skills with similar names (share 3+ word components)
CANDIDATES_FOUND=0

find "$COMMANDS_DIR" -name "*.md" -type f | \
    xargs -n1 basename | sed 's/.md$//' | \
    sort > /tmp/all_skills.txt

while IFS= read -r skill1; do
    # Extract key words from skill name
    words1=$(echo "$skill1" | tr '-' '\n' | grep -v '^bmad$' | grep -v '^7f$' | grep -v '^bmm$' | grep -v '^bmb$' | grep -v '^cis$')

    while IFS= read -r skill2; do
        if [ "$skill1" = "$skill2" ]; then
            continue
        fi

        words2=$(echo "$skill2" | tr '-' '\n' | grep -v '^bmad$' | grep -v '^7f$' | grep -v '^bmm$' | grep -v '^bmb$' | grep -v '^cis$')

        # Count shared words
        shared=0
        for word in $words1; do
            if echo "$words2" | grep -q "^$word$"; then
                ((shared++))
            fi
        done

        # If 2+ shared words, consider consolidation
        if [ "$shared" -ge 2 ]; then
            echo "  - Consider consolidating: $skill1 ↔ $skill2"
            ((CANDIDATES_FOUND++))
        fi
    done < /tmp/all_skills.txt
done < /tmp/all_skills.txt | sort -u | head -10

if [ "$CANDIDATES_FOUND" -eq 0 ]; then
    echo "  (No obvious consolidation candidates found)"
fi
echo ""

# Stale skills (not used in 90 days, Tier 3)
echo "Stale Skills (Not Used in 90+ Days, Consider Deprecation):"
echo "───────────────────────────────────────────────────────────────"

NINETY_DAYS_AGO=$(date -u -d '90 days ago' +%Y-%m-%d 2>/dev/null || date -u -v-90d +%Y-%m-%d)
RECENT_SKILLS=$(awk -F'|' -v cutoff="$NINETY_DAYS_AGO" '$1 >= cutoff {print $2}' "$USAGE_LOG" | sort -u)

STALE=0
while IFS= read -r skill; do
    skill_basename=$(basename "$skill" .md)
    if ! echo "$RECENT_SKILLS" | grep -q "^$skill_basename$"; then
        # Check if it was ever used
        if echo "$USED_SKILLS" | grep -q "^$skill_basename$"; then
            echo "  - $skill (last used >90 days ago)"
            ((STALE++))
        fi
    fi
done <<< "$ALL_SKILLS"

if [ "$STALE" -eq 0 ]; then
    echo "  (No stale skills found)"
fi
echo ""
echo "Total Stale: $STALE skills"
echo ""

# Recommendations
echo "==================================================================="
echo "Governance Recommendations"
echo "==================================================================="
echo ""

if [ "$UNUSED" -gt 10 ]; then
    echo "⚠️  HIGH PRIORITY: $UNUSED unused skills"
    echo "   Action: Review unused skills, deprecate or document use cases"
    echo ""
fi

if [ "$STALE" -gt 5 ]; then
    echo "⚠️  MEDIUM PRIORITY: $STALE stale skills"
    echo "   Action: Review Tier 3 skills not used in 90+ days"
    echo ""
fi

if [ "$CANDIDATES_FOUND" -gt 3 ]; then
    echo "⚠️  LOW PRIORITY: $CANDIDATES_FOUND consolidation candidates"
    echo "   Action: Review similar skills, consider merging functionality"
    echo ""
fi

echo "✅ Next quarterly review: $(date -u -d '90 days' +%Y-%m-%d 2>/dev/null || date -u -v+90d +%Y-%m-%d)"
echo ""

# Cleanup
rm -f /tmp/all_skills.txt
