#!/usr/bin/env python3
"""
Parse app_spec.txt XML and generate feature_list.json
"""
import xml.etree.ElementTree as ET
import json
from datetime import datetime

def parse_verification_criteria(feature_elem):
    """Extract verification criteria from feature element"""
    criteria = {
        "functional": "",
        "technical": "",
        "integration": ""
    }

    vc_elem = feature_elem.find('.//verification_criteria')
    if vc_elem is not None:
        for criterion_type in ['functional', 'technical', 'integration']:
            elem = vc_elem.find(criterion_type)
            if elem is not None and elem.text:
                # Clean up text: remove extra whitespace and dashes
                text = elem.text.strip()
                # Replace multiple dashes with single dash
                lines = [line.strip() for line in text.split('\n') if line.strip()]
                criteria[criterion_type] = '\n'.join(lines)

    return criteria

def parse_dependencies(feature_elem):
    """Extract dependencies from feature element"""
    deps_elem = feature_elem.find('.//dependencies')
    if deps_elem is not None and deps_elem.text:
        deps_text = deps_elem.text.strip()
        if deps_text.lower() == 'none':
            return []
        # Parse dependency text (e.g., "FR-1.4 (Authentication Verification)")
        deps = []
        for dep in deps_text.split(','):
            dep = dep.strip()
            if dep and not dep.lower().startswith('none'):
                deps.append(dep)
        return deps
    return []

def extract_category(feature_group_elem):
    """Extract category name from feature_group element"""
    name = feature_group_elem.get('name', 'Unknown')
    return name

def parse_app_spec(xml_file):
    """Parse app_spec.txt and extract all features"""

    # Read and parse XML
    with open(xml_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find the XML content (skip YAML frontmatter)
    xml_start = content.find('<?xml')
    if xml_start > 0:
        content = content[xml_start:]

    root = ET.fromstring(content)

    # Extract metadata
    metadata_elem = root.find('metadata')
    total_features = int(metadata_elem.find('total_features').text)

    features = []
    feature_counter = 1

    # Iterate through all feature groups
    for feature_group in root.findall('.//feature_group'):
        category = extract_category(feature_group)

        # Iterate through all features in this group
        for feature_elem in feature_group.findall('feature'):
            feature_id = feature_elem.get('id', f'FEATURE_{feature_counter:03d}')

            # Extract basic info
            name_elem = feature_elem.find('name')
            desc_elem = feature_elem.find('description')
            reqs_elem = feature_elem.find('requirements')

            name = name_elem.text.strip() if name_elem is not None and name_elem.text else "Unknown"
            description = desc_elem.text.strip() if desc_elem is not None and desc_elem.text else ""

            # Extract requirements (full text)
            requirements = ""
            if reqs_elem is not None and reqs_elem.text:
                requirements = reqs_elem.text.strip()

            # Parse verification criteria
            verification_criteria = parse_verification_criteria(feature_elem)

            # Parse dependencies
            dependencies = parse_dependencies(feature_elem)

            feature = {
                "id": feature_id,
                "name": name,
                "description": description,
                "category": category,
                "status": "pending",
                "attempts": 0,
                "dependencies": dependencies,
                "requirements": requirements,
                "implementation_notes": "",
                "verification_criteria": verification_criteria,
                "verification_results": {
                    "functional": "",
                    "technical": "",
                    "integration": ""
                },
                "last_updated": ""
            }

            features.append(feature)
            feature_counter += 1

    # Create final structure
    result = {
        "metadata": {
            "project_name": "7F_github - Seven Fortunas AI-Native Enterprise Infrastructure",
            "total_features": len(features),
            "generated_from": "app_spec.txt",
            "generated_date": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
            "autonomous_agent_ready": "true"
        },
        "features": features
    }

    return result

if __name__ == '__main__':
    import sys

    xml_file = 'app_spec.txt'
    output_file = 'feature_list.json'

    print(f"Parsing {xml_file}...")
    data = parse_app_spec(xml_file)

    print(f"Extracted {len(data['features'])} features")

    # Write to JSON
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"Generated {output_file}")
    print(f"Total features: {data['metadata']['total_features']}")

    # Print feature categories summary
    categories = {}
    for feature in data['features']:
        cat = feature['category']
        categories[cat] = categories.get(cat, 0) + 1

    print("\nFeatures by category:")
    for cat, count in sorted(categories.items()):
        print(f"  {cat}: {count} features")
