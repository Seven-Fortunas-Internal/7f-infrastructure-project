#!/usr/bin/env python3
"""
Test Coverage Validator
Ensures all "pass" features have verification test results
"""

import json
import sys
from pathlib import Path

def get_project_root():
    """Get project root directory"""
    return Path(__file__).parent.parent

def load_feature_list():
    """Load feature_list.json"""
    project_root = get_project_root()
    feature_file = project_root / "feature_list.json"

    with open(feature_file, 'r') as f:
        return json.load(f)

def validate_test_coverage():
    """
    Validate that all passed features have test results

    Returns:
        dict: Validation results
    """
    data = load_feature_list()
    features = data.get("features", [])

    total_features = len(features)
    passed_features = [f for f in features if f.get("status") == "pass"]
    passed_count = len(passed_features)

    # Check for features marked "pass" without test results
    untested_passed = []
    for feature in passed_features:
        results = feature.get("verification_results", {})

        # Check if verification results exist and are not empty
        functional = results.get("functional", "")
        technical = results.get("technical", "")
        integration = results.get("integration", "")

        if not functional or not technical or not integration:
            untested_passed.append({
                "id": feature["id"],
                "name": feature["name"],
                "missing": {
                    "functional": not functional,
                    "technical": not technical,
                    "integration": not integration
                }
            })

    # Check for incomplete test results (not all "pass")
    incomplete_tests = []
    for feature in passed_features:
        results = feature.get("verification_results", {})
        functional = results.get("functional", "")
        technical = results.get("technical", "")
        integration = results.get("integration", "")

        if functional != "pass" or technical != "pass" or integration != "pass":
            incomplete_tests.append({
                "id": feature["id"],
                "name": feature["name"],
                "results": {
                    "functional": functional,
                    "technical": technical,
                    "integration": integration
                }
            })

    # Calculate coverage
    properly_tested = passed_count - len(untested_passed)
    coverage = (properly_tested / passed_count * 100) if passed_count > 0 else 0

    validation_result = {
        "total_features": total_features,
        "passed_features": passed_count,
        "properly_tested": properly_tested,
        "untested_passed": len(untested_passed),
        "incomplete_tests": len(incomplete_tests),
        "test_coverage": coverage,
        "valid": len(untested_passed) == 0 and len(incomplete_tests) == 0,
        "violations": untested_passed + incomplete_tests
    }

    return validation_result

def print_validation_report(result):
    """Print human-readable validation report"""

    print("=" * 60)
    print("Test Coverage Validation Report")
    print("=" * 60)
    print()

    print(f"Total Features:        {result['total_features']}")
    print(f"Passed Features:       {result['passed_features']}")
    print(f"Properly Tested:       {result['properly_tested']}")
    print(f"Test Coverage:         {result['test_coverage']:.1f}%")
    print()

    if result['valid']:
        print("✅ PASS: All passed features have complete test results")
        print()
        return True
    else:
        print("❌ FAIL: Some passed features lack complete test results")
        print()

        if result['untested_passed'] > 0:
            print(f"Features marked 'pass' without test results: {result['untested_passed']}")
            for violation in result['violations']:
                if 'missing' in violation:
                    print(f"  - {violation['id']}: {violation['name']}")
                    missing = [k for k, v in violation['missing'].items() if v]
                    print(f"    Missing: {', '.join(missing)}")
            print()

        if result['incomplete_tests'] > 0:
            print(f"Features with incomplete test results: {result['incomplete_tests']}")
            for violation in result['violations']:
                if 'results' in violation:
                    print(f"  - {violation['id']}: {violation['name']}")
                    print(f"    Results: {violation['results']}")
            print()

        return False

if __name__ == "__main__":
    result = validate_test_coverage()

    if "--json" in sys.argv:
        print(json.dumps(result, indent=2))
        sys.exit(0 if result['valid'] else 1)
    else:
        valid = print_validation_report(result)
        sys.exit(0 if valid else 1)
