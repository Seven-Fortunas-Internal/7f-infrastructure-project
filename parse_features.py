#!/usr/bin/env python3
import xml.etree.ElementTree as ET
import json
from datetime import datetime

# Read the app_spec.txt file
with open('/home/ladmin/dev/GDF/7F_github/app_spec.txt', 'r') as f:
    content = f.read()

# Find the XML portion (skip YAML frontmatter)
xml_start = content.find('<?xml')
xml_content = content[xml_start:]

# Parse XML
root = ET.fromstring(xml_content)

# Extract features
features = []
for feature in root.findall('.//feature'):
    feature_id = feature.get('id')
    priority = feature.get('priority', 'P0')
    phase = feature.get('phase', '')

    name_elem = feature.find('name')
    desc_elem = feature.find('description')
    reqs_elem = feature.find('requirements')
    deps_elem = feature.find('dependencies')

    # Extract verification criteria
    ver_criteria = feature.find('verification_criteria')
    functional = ''
    technical = ''
    integration = ''

    if ver_criteria is not None:
        func_elem = ver_criteria.find('functional')
        tech_elem = ver_criteria.find('technical')
        integ_elem = ver_criteria.find('integration')

        if func_elem is not None:
            functional = func_elem.text.strip() if func_elem.text else ''
        if tech_elem is not None:
            technical = tech_elem.text.strip() if tech_elem.text else ''
        if integ_elem is not None:
            integration = integ_elem.text.strip() if integ_elem.text else ''

    # Determine category from feature group parent
    category = ''
    for fg in root.findall('.//feature_group'):
        if feature in fg.findall('.//feature'):
            category = fg.get('name', '')
            break

    # Extract dependencies
    dependencies = []
    if deps_elem is not None and deps_elem.text:
        dep_text = deps_elem.text.strip()
        if dep_text and dep_text.lower() != 'none':
            dependencies = [dep_text]

    feature_data = {
        'id': feature_id,
        'name': name_elem.text.strip() if name_elem is not None and name_elem.text else '',
        'description': desc_elem.text.strip() if desc_elem is not None and desc_elem.text else '',
        'category': category,
        'priority': priority,
        'phase': phase,
        'status': 'pending',
        'attempts': 0,
        'dependencies': dependencies,
        'requirements': reqs_elem.text.strip() if reqs_elem is not None and reqs_elem.text else '',
        'implementation_notes': '',
        'verification_criteria': {
            'functional': functional,
            'technical': technical,
            'integration': integration
        },
        'verification_results': {
            'functional': '',
            'technical': '',
            'integration': ''
        },
        'last_updated': ''
    }

    features.append(feature_data)

# Sort features by ID
features.sort(key=lambda x: x['id'])

# Create feature_list.json
feature_list = {
    'metadata': {
        'project_name': '7F_github - Seven Fortunas AI-Native Enterprise Infrastructure',
        'total_features': len(features),
        'generated_from': 'app_spec.txt',
        'generated_date': datetime.now().isoformat() + 'Z',
        'autonomous_agent_ready': 'true'
    },
    'features': features
}

# Write feature_list.json
with open('/home/ladmin/dev/GDF/7F_github/feature_list.json', 'w') as f:
    json.dump(feature_list, f, indent=2)

print(f"✓ Generated feature_list.json with {len(features)} features")
print(f"\nFeatures by category:")

# Count by category
categories = {}
for f in features:
    cat = f['category'] or 'Uncategorized'
    categories[cat] = categories.get(cat, 0) + 1

for cat, count in sorted(categories.items()):
    print(f"  {cat}: {count} features")
