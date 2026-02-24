#!/usr/bin/env python3
"""
Parse app_spec.txt and extract all features and NFRs for autonomous implementation tracking.
"""

import re
import json
from datetime import datetime

def extract_text_between_tags(content, tag, start_pos=0):
    """Extract text between XML tags."""
    start_tag = f"<{tag}>"
    end_tag = f"</{tag}>"

    start = content.find(start_tag, start_pos)
    if start == -1:
        return None, -1

    start += len(start_tag)
    end = content.find(end_tag, start)

    if end == -1:
        return None, -1

    text = content[start:end].strip()
    # Clean up extra whitespace and newlines
    text = re.sub(r'\s+', ' ', text)
    text = re.sub(r'- ', '\n- ', text)  # Preserve list formatting
    return text.strip(), end + len(end_tag)

def extract_feature(content, feature_match):
    """Extract complete feature data from a feature block."""
    feature_id = feature_match.group(1)
    feature_tag = feature_match.group(0)

    # Get the full feature block
    feature_start = feature_match.start()
    feature_end = content.find('</feature>', feature_start)
    if feature_end == -1:
        return None

    feature_block = content[feature_start:feature_end + 10]

    # Extract basic fields
    name, _ = extract_text_between_tags(feature_block, 'name')
    description, _ = extract_text_between_tags(feature_block, 'description')
    requirements, _ = extract_text_between_tags(feature_block, 'requirements')
    dependencies, _ = extract_text_between_tags(feature_block, 'dependencies')

    # Extract verification criteria
    vc_start = feature_block.find('<verification_criteria>')
    vc_end = feature_block.find('</verification_criteria>')

    functional = technical = integration = ""
    if vc_start != -1 and vc_end != -1:
        vc_block = feature_block[vc_start:vc_end]
        functional, _ = extract_text_between_tags(vc_block, 'functional')
        technical, _ = extract_text_between_tags(vc_block, 'technical')
        integration, _ = extract_text_between_tags(vc_block, 'integration')

    # Extract phase and priority from feature tag
    phase_match = re.search(r'phase="([^"]+)"', feature_tag)
    priority_match = re.search(r'priority="([^"]+)"', feature_tag)

    phase = phase_match.group(1) if phase_match else "Unknown"
    priority = priority_match.group(1) if priority_match else "P0"

    # Determine category based on phase and priority
    if 'Infrastructure' in name or 'GitHub' in name or 'BMAD' in name:
        category = "Infrastructure & Foundation"
    elif 'Security' in name or 'Secret' in name or 'Vulnerability' in name or 'NFR-1' in name or 'NFR-5' in name:
        category = "Security & Compliance"
    elif 'Second Brain' in name or 'Voice' in name or 'NFR-2' in name:
        category = "Second Brain & Knowledge Management"
    elif 'Dashboard' in name or '7F Lens' in name or 'NFR-4' in name:
        category = "7F Lens Intelligence Platform"
    elif 'Test' in name or 'NFR-7' in name or 'Quality' in name:
        category = "Testing & Quality Assurance"
    elif 'Deployment' in name or 'CI/CD' in name or 'NFR-3' in name:
        category = "DevOps & Deployment"
    else:
        category = "Business Logic & Integration"

    return {
        "id": feature_id,
        "name": name or feature_id,
        "description": description or "",
        "category": category,
        "phase": phase,
        "priority": priority,
        "status": "pending",
        "attempts": 0,
        "dependencies": [dep.strip() for dep in (dependencies or "").split(',') if dep.strip() and dep.strip() != "None"],
        "requirements": requirements or "",
        "implementation_notes": "",
        "verification_criteria": {
            "functional": functional or "",
            "technical": technical or "",
            "integration": integration or ""
        },
        "verification_results": {
            "functional": "",
            "technical": "",
            "integration": ""
        },
        "last_updated": ""
    }

def extract_nfr(content, nfr_match):
    """Extract NFR (non-functional requirement) data."""
    nfr_id = nfr_match.group(1)
    nfr_tag = nfr_match.group(0)

    # Get the full NFR block
    nfr_start = nfr_match.start()
    nfr_end = content.find('</requirement>', nfr_start)
    if nfr_end == -1:
        return None

    nfr_block = content[nfr_start:nfr_end + 14]

    # Extract basic fields
    name, _ = extract_text_between_tags(nfr_block, 'name')
    description, _ = extract_text_between_tags(nfr_block, 'description')
    requirements, _ = extract_text_between_tags(nfr_block, 'requirements')
    dependencies, _ = extract_text_between_tags(nfr_block, 'dependencies')

    # Extract verification criteria
    vc_start = nfr_block.find('<verification_criteria>')
    vc_end = nfr_block.find('</verification_criteria>')

    functional = technical = integration = ""
    if vc_start != -1 and vc_end != -1:
        vc_block = nfr_block[vc_start:vc_end]
        functional, _ = extract_text_between_tags(vc_block, 'functional')
        technical, _ = extract_text_between_tags(vc_block, 'technical')
        integration, _ = extract_text_between_tags(vc_block, 'integration')

    # Extract phase and priority from NFR tag
    phase_match = re.search(r'phase="([^"]+)"', nfr_tag)
    priority_match = re.search(r'priority="([^"]+)"', nfr_tag)

    phase = phase_match.group(1) if phase_match else "Unknown"
    priority = priority_match.group(1) if priority_match else "P0"

    # Determine category based on NFR ID
    if nfr_id.startswith('NFR-1') or nfr_id.startswith('NFR-5'):
        category = "Security & Compliance"
    elif nfr_id.startswith('NFR-2'):
        category = "Second Brain & Knowledge Management"
    elif nfr_id.startswith('NFR-3'):
        category = "DevOps & Deployment"
    elif nfr_id.startswith('NFR-4'):
        category = "7F Lens Intelligence Platform"
    elif nfr_id.startswith('NFR-6'):
        category = "Infrastructure & Foundation"
    elif nfr_id.startswith('NFR-7'):
        category = "Testing & Quality Assurance"
    else:
        category = "Business Logic & Integration"

    return {
        "id": nfr_id,
        "name": name or nfr_id,
        "description": description or "",
        "category": category,
        "phase": phase,
        "priority": priority,
        "status": "pending",
        "attempts": 0,
        "dependencies": [dep.strip() for dep in (dependencies or "").split(',') if dep.strip() and dep.strip() != "None"],
        "requirements": requirements or "",
        "implementation_notes": "",
        "verification_criteria": {
            "functional": functional or "",
            "technical": technical or "",
            "integration": integration or ""
        },
        "verification_results": {
            "functional": "",
            "technical": "",
            "integration": ""
        },
        "last_updated": ""
    }

def main():
    print("Parsing app_spec.txt...")

    with open('app_spec.txt', 'r') as f:
        content = f.read()

    # Extract all features
    feature_pattern = re.compile(r'<feature id="(FEATURE_\w+)"[^>]*>')
    feature_matches = list(feature_pattern.finditer(content))

    features = []
    for match in feature_matches:
        feature = extract_feature(content, match)
        if feature:
            features.append(feature)

    print(f"Extracted {len(features)} FEATURE_ items")

    # Extract all NFRs
    nfr_pattern = re.compile(r'<requirement id="(NFR-[\d.]+)"[^>]*>')
    nfr_matches = list(nfr_pattern.finditer(content))

    nfrs = []
    for match in nfr_matches:
        nfr = extract_nfr(content, match)
        if nfr:
            nfrs.append(nfr)

    print(f"Extracted {len(nfrs)} NFR- items")

    # Combine all items (features first, then NFRs)
    all_items = features + nfrs

    print(f"Total items: {len(all_items)}")

    # Create feature_list.json structure
    feature_list = {
        "metadata": {
            "project_name": "7F_github - Seven Fortunas AI-Native Enterprise Infrastructure",
            "total_features": len(all_items),
            "features_count": len(features),
            "nfrs_count": len(nfrs),
            "generated_from": "app_spec.txt",
            "generated_date": datetime.now().isoformat() + "Z",
            "autonomous_agent_ready": "true"
        },
        "features": all_items
    }

    # Write to feature_list.json
    with open('feature_list.json', 'w') as f:
        json.dump(feature_list, f, indent=2)

    print(f"\nGenerated feature_list.json with {len(all_items)} items")

    # Print summary by category
    categories = {}
    for item in all_items:
        cat = item['category']
        categories[cat] = categories.get(cat, 0) + 1

    print("\nFeatures by category:")
    for cat, count in sorted(categories.items()):
        print(f"  {cat}: {count}")

    print("\nDone!")

if __name__ == '__main__':
    main()
