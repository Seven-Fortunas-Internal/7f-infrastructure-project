#!/usr/bin/env python3
import json
from datetime import datetime, timezone

# Read feature list
with open('feature_list.json') as f:
    data = json.load(f)

# Update FEATURE_056
for feature in data['features']:
    if feature['id'] == 'FEATURE_056':
        feature['status'] = 'pass'
        feature['attempts'] = 1
        feature['verification_results'] = {
            'functional': 'pass',
            'technical': 'pass',
            'integration': 'pass'
        }
        feature['last_updated'] = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
        break

# Write back
with open('feature_list.json', 'w') as f:
    json.dump(data, f, indent=2)

# Count statuses
counts = {}
for feature in data['features']:
    status = feature['status']
    counts[status] = counts.get(status, 0) + 1

print(f"Updated FEATURE_056 to pass")
print(f"Pass: {counts.get('pass', 0)}, Pending: {counts.get('pending', 0)}, Fail: {counts.get('fail', 0)}, Blocked: {counts.get('blocked', 0)}")
