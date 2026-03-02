#!/usr/bin/env python3
"""
Parse app_spec.txt and extract all features with verification criteria.
"""
import xml.etree.ElementTree as ET
import json
from datetime import datetime
import sys

def parse_app_spec(file_path):
    """Parse app_spec.txt and extract features."""

    # Read the file and skip the YAML frontmatter
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find the XML start (after the YAML frontmatter)
    xml_start = content.find('<?xml')
    if xml_start == -1:
        print("Error: No XML content found", file=sys.stderr)
        sys.exit(1)

    xml_content = content[xml_start:]

    # Parse XML
    root = ET.fromstring(xml_content)

    # Extract metadata
    metadata = root.find('metadata')
    project_name = metadata.find('project_name').text
    total_features = int(metadata.find('total_features').text)

    # Extract phase architecture
    phase_arch = metadata.find('phase_architecture')
    phase_a_text = phase_arch.find('.//phase_a/features').text
    phase_a_features = set(phase_a_text.split(',')) if phase_a_text else set()

    phase_c_text = phase_arch.find('.//phase_c/features').text
    phase_c_features = set(phase_c_text.split(',')) if phase_c_text else set()

    # Extract all features
    features = []
    for feature in root.findall('.//feature'):
        feature_id = feature.get('id')

        # Determine phase group
        if feature_id in phase_a_features:
            phase_group = "A"
        elif feature_id in phase_c_features:
            phase_group = "C"
        else:
            phase_group = "B"

        # Extract basic info
        name_elem = feature.find('name')
        desc_elem = feature.find('description')
        req_elem = feature.find('requirements')
        deps_elem = feature.find('dependencies')

        name = name_elem.text if name_elem is not None else ""
        description = desc_elem.text if desc_elem is not None else ""

        # Extract requirements (can be multi-line)
        requirements = ""
        if req_elem is not None:
            requirements = ET.tostring(req_elem, encoding='unicode', method='text').strip()

        # Extract dependencies
        dependencies = []
        if deps_elem is not None and deps_elem.text:
            dep_text = deps_elem.text.strip()
            if dep_text and dep_text.lower() != 'none':
                # Parse dependencies - can be comma-separated or parenthetical references
                for dep in dep_text.split(','):
                    dep = dep.strip()
                    # Extract FR-X.Y patterns
                    if 'FR-' in dep:
                        # Find the FR reference and map to feature ID
                        # We'll keep the raw dependency text for now
                        dependencies.append(dep)

        # Extract verification criteria
        verification_elem = feature.find('verification_criteria')
        verification_criteria = {
            "functional": "",
            "technical": "",
            "integration": ""
        }

        if verification_elem is not None:
            func_elem = verification_elem.find('functional')
            tech_elem = verification_elem.find('technical')
            integ_elem = verification_elem.find('integration')

            if func_elem is not None:
                verification_criteria['functional'] = ET.tostring(func_elem, encoding='unicode', method='text').strip()
            if tech_elem is not None:
                verification_criteria['technical'] = ET.tostring(tech_elem, encoding='unicode', method='text').strip()
            if integ_elem is not None:
                verification_criteria['integration'] = ET.tostring(integ_elem, encoding='unicode', method='text').strip()

        # Determine category from feature group structure
        category = "Unknown"
        parent = None
        for ancestor in root.iter():
            if feature in list(ancestor):
                if ancestor.tag == 'feature_group':
                    category = ancestor.get('name', 'Unknown')
                    break

        feature_data = {
            "id": feature_id,
            "name": name,
            "description": description,
            "category": category,
            "status": "pending",
            "attempts": 0,
            "phase_group": phase_group,
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

        features.append(feature_data)

    return {
        "metadata": {
            "project_name": project_name,
            "total_features": len(features),
            "generated_from": "app_spec.txt",
            "generated_date": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
            "autonomous_agent_ready": "true"
        },
        "features": features
    }

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: parse_app_spec.py <path_to_app_spec.txt>", file=sys.stderr)
        sys.exit(1)

    result = parse_app_spec(sys.argv[1])
    print(json.dumps(result, indent=2))
