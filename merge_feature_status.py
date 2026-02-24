#!/usr/bin/env python3
"""
Merge status from old feature_list.json into new one
"""
import json
import sys

def merge_status(old_file, new_file, output_file):
    """Merge status from old file into new file"""

    # Load both files
    with open(old_file, 'r') as f:
        old_data = json.load(f)

    with open(new_file, 'r') as f:
        new_data = json.load(f)

    # Create status lookup from old file
    status_map = {}
    for feature in old_data['features']:
        feature_id = feature['id']
        status_map[feature_id] = {
            'status': feature.get('status', 'pending'),
            'attempts': feature.get('attempts', 0),
            'implementation_notes': feature.get('implementation_notes', ''),
            'verification_results': feature.get('verification_results', {
                'functional': '',
                'technical': '',
                'integration': ''
            }),
            'last_updated': feature.get('last_updated', '')
        }

    # Update new features with old status
    features_updated = 0
    for feature in new_data['features']:
        feature_id = feature['id']
        if feature_id in status_map:
            old_status = status_map[feature_id]
            feature['status'] = old_status['status']
            feature['attempts'] = old_status['attempts']
            feature['implementation_notes'] = old_status['implementation_notes']
            feature['verification_results'] = old_status['verification_results']
            feature['last_updated'] = old_status['last_updated']
            if old_status['status'] != 'pending':
                features_updated += 1

    # Update metadata counts
    status_counts = {}
    for feature in new_data['features']:
        status = feature['status']
        status_counts[status] = status_counts.get(status, 0) + 1

    print(f"Merged status for {features_updated} completed features")
    print(f"Status breakdown:")
    for status, count in sorted(status_counts.items()):
        print(f"  {status}: {count}")

    # Write merged file
    with open(output_file, 'w') as f:
        json.dump(new_data, f, indent=2, ensure_ascii=False)

    print(f"Merged file written to {output_file}")

if __name__ == '__main__':
    # Find the most recent backup
    import glob
    import os

    backups = glob.glob('feature_list.json.backup-*')
    if not backups:
        print("No backup found!")
        sys.exit(1)

    old_file = max(backups, key=os.path.getctime)
    new_file = 'feature_list.json'
    output_file = 'feature_list_merged.json'

    print(f"Merging status from {old_file} into {new_file}")
    merge_status(old_file, new_file, output_file)
