#!/usr/bin/env python3
import json
from datetime import datetime, timezone

# Read feature list for counts
with open('feature_list.json') as f:
    data = json.load(f)

counts = {'pass': 0, 'pending': 0, 'fail': 0, 'blocked': 0}
for feature in data['features']:
    status = feature['status']
    counts[status] = counts.get(status, 0) + 1

# Read and update progress file
with open('claude-progress.txt') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if line.startswith('features_completed='):
        new_lines.append(f'features_completed={counts["pass"]}\n')
    elif line.startswith('features_pending='):
        new_lines.append(f'features_pending={counts["pending"]}\n')
    elif line.startswith('features_fail='):
        new_lines.append(f'features_fail={counts["fail"]}\n')
    elif line.startswith('features_blocked='):
        new_lines.append(f'features_blocked={counts["blocked"]}\n')
    elif line.startswith('last_updated='):
        new_lines.append(f'last_updated={datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")}\n')
    else:
        new_lines.append(line)

new_lines.append('- FEATURE_057: PASS\n')

with open('claude-progress.txt', 'w') as f:
    f.writelines(new_lines)

print(f"Updated: pass={counts['pass']}, pending={counts['pending']}")
