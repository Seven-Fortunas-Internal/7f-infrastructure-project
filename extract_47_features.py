#!/usr/bin/env python3
"""
Parse app_spec.txt and extract ALL 47 FEATURE_XXX entries into structured JSON.
This extracts ONLY the FEATURE_XXX items (not NFRs).
"""

import json
import re
from pathlib import Path
from typing import List, Dict, Any

def extract_text_between_tags(content: str, tag: str) -> str:
    """Extract text between XML tags."""
    pattern = f'<{tag}>(.*?)</{tag}>'
    match = re.search(pattern, content, re.DOTALL)
    return match.group(1).strip() if match else ""

def find_feature_category(content: str, feature_pos: int) -> str:
    """Find the feature_group category for a feature by looking backwards."""
    # Look backwards from feature position to find nearest feature_group
    content_before = content[:feature_pos]

    # Find all feature_group tags before this position
    group_pattern = r'<feature_group\s+name="([^"]+)">'
    matches = list(re.finditer(group_pattern, content_before))

    if matches:
        # Return the last (nearest) feature_group name
        return matches[-1].group(1)

    return "Unknown"

def parse_dependencies(dep_text: str) -> List[str]:
    """Parse dependencies text into array of requirement IDs."""
    if not dep_text or dep_text.strip().lower() in ['none', '']:
        return []

    dependencies = []

    # Look for FR-X.Y patterns
    fr_matches = re.findall(r'FR-[\d.]+', dep_text)
    dependencies.extend(fr_matches)

    # Look for FEATURE_XXX patterns
    feature_matches = re.findall(r'FEATURE_\d+', dep_text)
    dependencies.extend(feature_matches)

    # Look for NFR-X.Y patterns
    nfr_matches = re.findall(r'NFR-[\d.]+', dep_text)
    dependencies.extend(nfr_matches)

    return dependencies

def extract_feature(content: str, match: re.Match) -> Dict[str, Any]:
    """Extract complete feature data from a feature match."""
    feature_id = match.group(1)
    feature_start = match.start()

    # Find the end of this feature block
    feature_end = content.find('</feature>', feature_start)
    if feature_end == -1:
        return None

    feature_block = content[feature_start:feature_end + 10]

    # Find category
    category = find_feature_category(content, feature_start)

    # Extract basic fields
    name = extract_text_between_tags(feature_block, 'name')
    description = extract_text_between_tags(feature_block, 'description')
    requirements = extract_text_between_tags(feature_block, 'requirements')
    dependencies_text = extract_text_between_tags(feature_block, 'dependencies')

    # Parse dependencies
    dependencies = parse_dependencies(dependencies_text)

    # Extract verification criteria
    vc_block = re.search(
        r'<verification_criteria>(.*?)</verification_criteria>',
        feature_block,
        re.DOTALL
    )

    verification_criteria = {
        "functional": "",
        "technical": "",
        "integration": ""
    }

    if vc_block:
        vc_content = vc_block.group(1)
        verification_criteria["functional"] = extract_text_between_tags(vc_content, 'functional')
        verification_criteria["technical"] = extract_text_between_tags(vc_content, 'technical')
        verification_criteria["integration"] = extract_text_between_tags(vc_content, 'integration')

    return {
        "id": feature_id,
        "name": name,
        "description": description,
        "category": category,
        "dependencies": dependencies,
        "requirements": requirements,
        "verification_criteria": verification_criteria
    }

def parse_app_spec(file_path: str) -> List[Dict[str, Any]]:
    """Parse app_spec.txt and extract all FEATURE_XXX items."""

    print(f"Reading {file_path}...")
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find all feature blocks (FEATURE_XXX and FEATURE_XXX_EXTENDED)
    feature_pattern = re.compile(r'<feature\s+id="(FEATURE_\d+(?:_EXTENDED)?)"[^>]*>')
    matches = list(feature_pattern.finditer(content))

    print(f"Found {len(matches)} FEATURE_XXX tags...")

    features = []
    for match in matches:
        feature = extract_feature(content, match)
        if feature:
            features.append(feature)

    # Sort by feature ID number (handle _EXTENDED suffix)
    def get_sort_key(feature):
        feature_id = feature['id'].replace('FEATURE_', '').replace('_EXTENDED', '')
        try:
            return int(feature_id)
        except ValueError:
            return 999  # Put non-numeric IDs at the end

    features.sort(key=get_sort_key)

    return features

def main():
    """Main entry point."""
    app_spec_path = '/home/ladmin/dev/GDF/7F_github/app_spec.txt'
    output_path = '/home/ladmin/dev/GDF/7F_github/extracted_features.json'

    print("=" * 60)
    print("Extracting 47 Features from app_spec.txt")
    print("=" * 60)

    features = parse_app_spec(app_spec_path)

    print(f"\n✓ Successfully extracted {len(features)} features")

    # Write to JSON file
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(features, f, indent=2, ensure_ascii=False)

    print(f"✓ Saved to {output_path}")

    # Print summary by category
    print("\n" + "=" * 60)
    print("Feature Summary by Category")
    print("=" * 60)

    categories = {}
    for feature in features:
        cat = feature['category']
        if cat not in categories:
            categories[cat] = []
        categories[cat].append(feature)

    for category, cat_features in sorted(categories.items()):
        print(f"\n{category} ({len(cat_features)} features):")
        for feature in cat_features:
            print(f"  {feature['id']}: {feature['name']}")

    # Validate we got 47
    print("\n" + "=" * 60)
    if len(features) == 47:
        print("✓ VALIDATION PASSED: Extracted exactly 47 features")
    else:
        print(f"⚠ WARNING: Expected 47 features, got {len(features)}")
    print("=" * 60)

if __name__ == '__main__':
    main()
