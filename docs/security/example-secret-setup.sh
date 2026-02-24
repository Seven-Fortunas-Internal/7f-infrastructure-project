#!/bin/bash
# Example: Setting up a secret for testing
# DO NOT run this directly - it's a template

# Replace with actual values:
ORG_NAME="Seven-Fortunas-Internal"
SECRET_NAME="EXAMPLE_API_KEY"
SECRET_VALUE="your-actual-secret-value-here"

# Set secret
gh secret set "$SECRET_NAME" --org "$ORG_NAME" --body "$SECRET_VALUE"

# Verify it was created
gh api "orgs/$ORG_NAME/actions/secrets/$SECRET_NAME"
