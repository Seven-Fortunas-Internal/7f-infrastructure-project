---
title: Custom Skills for Seven Fortunas
description: Organization-specific skills and extensions
---

# Custom Skills

## Seven Fortunas Custom Skills

This directory contains skills developed specifically for Seven Fortunas use cases, extending the BMAD framework with domain-specific capabilities.

## Skill Catalog

### Infrastructure Skills
- **deploy-infrastructure**: Deploy cloud infrastructure (AWS, GCP, Azure)
- **configure-kubernetes**: Configure and manage Kubernetes clusters
- **setup-monitoring**: Deploy monitoring and alerting systems
- **manage-secrets**: Secure secret management and rotation
- **backup-systems**: Configure and test backup strategies

### AI Integration Skills
- **call-llm**: Call large language models (Claude, GPT, etc.)
- **prompt-template**: Template-based prompt generation
- **embeddings-generate**: Generate vector embeddings
- **rag-retrieve**: Retrieve context for RAG pipelines
- **model-evaluate**: Evaluate and test AI models

### Data Processing Skills
- **sync-data**: Sync data between systems
- **transform-financial**: Transform financial data
- **enrich-data**: Enrich data with additional context
- **validate-compliance**: Validate data for compliance
- **aggregate-metrics**: Aggregate metrics for dashboards

### Integration Skills
- **github-api**: Interact with GitHub API
- **slack-notify**: Send notifications to Slack
- **email-send**: Send transactional emails
- **webhook-parse**: Parse and validate webhooks
- **api-proxy**: Proxy and transform API calls

### Operational Skills
- **incident-create**: Create and manage incidents
- **runbook-execute**: Execute operational runbooks
- **alert-escalate**: Escalate alerts based on rules
- **health-check**: Check system health and status
- **audit-log**: Log audit events for compliance

## Custom Skill Development

### Getting Started
1. Create new skill directory: `<skill-name>/`
2. Write `handler.py` with `handle()` function
3. Create `skill.yaml` with metadata
4. Add tests in `tests/`
5. Document in `docs/README.md`
6. Register skill in framework

### Seven Fortunas Skill Template
```python
# handler.py
from bmad.skill import Skill, SkillInput, SkillOutput, SkillError

class YourSkill(Skill):
    """Your custom skill for Seven Fortunas."""

    def handle(self, inputs: SkillInput) -> SkillOutput:
        """
        Execute the skill.

        Args:
            inputs: Skill inputs

        Returns:
            SkillOutput with results

        Raises:
            SkillError: If operation fails
        """
        try:
            # Your implementation
            result = self._process(inputs)
            return SkillOutput(success=True, data=result)
        except Exception as e:
            raise SkillError(f"Operation failed: {e}")

    def _process(self, inputs: SkillInput):
        """Internal processing logic."""
        # Implementation
        pass
```

### Skill Configuration
```yaml
# skill.yaml
name: your-custom-skill
version: 1.0.0
description: What this skill does
author: Seven Fortunas
module: skills.custom.your_custom_skill
tags:
  - infrastructure
  - ai
  - integration

inputs:
  param1:
    type: string
    description: Parameter description
    required: true
    default: null

  param2:
    type: integer
    description: Another parameter
    required: false
    default: 10

outputs:
  result:
    type: object
    description: The result of the operation

errors:
  INVALID_INPUT: Invalid input parameter
  OPERATION_FAILED: Operation failed
  TIMEOUT: Operation timed out

dependencies:
  - bmad-core>=2.0.0
  - requests>=2.28.0

metadata:
  supports_async: true
  supports_retry: true
  timeout_seconds: 300
```

## Integration Examples

### Example 1: Deploy Infrastructure Skill
```python
# deploy infrastructure to AWS
outputs:
  - call: deploy-infrastructure
    inputs:
      provider: aws
      config: ${infrastructure_config}
      region: us-east-1
      tags:
        environment: production
        owner: seven-fortunas
```

### Example 2: AI Integration Skill
```python
# Call LLM with templated prompt
outputs:
  - call: call-llm
    inputs:
      model: claude-3-opus
      system_prompt: "You are an infrastructure expert"
      user_prompt: ${user_query}
      max_tokens: 1000
```

### Example 3: Data Processing Skill
```python
# Transform and validate financial data
outputs:
  - call: transform-financial
    inputs:
      source_format: csv
      target_format: json
      validation_schema: financial_schema.json
      enrich: true
```

## Testing Custom Skills

### Unit Testing
```python
# tests/test_handler.py
import unittest
from handler import YourSkill
from bmad.skill import SkillInput

class TestYourSkill(unittest.TestCase):
    def setUp(self):
        self.skill = YourSkill()

    def test_success(self):
        inputs = SkillInput(param1="value")
        result = self.skill.handle(inputs)
        self.assertTrue(result.success)
        self.assertIsNotNone(result.data)

    def test_validation_error(self):
        inputs = SkillInput(param1="")
        with self.assertRaises(Exception):
            self.skill.handle(inputs)
```

### Integration Testing
- Test skill within workflow context
- Verify error handling and recovery
- Test with real API calls (if applicable)
- Load testing for performance-sensitive skills

## Skill Deployment

### Local Testing
```bash
# Test skill locally
bmad skill test skills/custom/your-skill/

# Validate skill configuration
bmad skill validate skills/custom/your-skill/
```

### Production Deployment
```bash
# Package skill
bmad skill package skills/custom/your-skill/

# Deploy skill
bmad skill deploy your-skill --environment production

# Verify deployment
bmad skill status your-skill
```

## Best Practices

### Design
- ✅ Single responsibility per skill
- ✅ Clear, documented inputs and outputs
- ✅ Graceful error handling
- ✅ Reasonable default values
- ❌ Hard-coded values (use configuration)
- ❌ Direct secret management (use secret stores)

### Implementation
- ✅ Type hints throughout
- ✅ Comprehensive logging
- ✅ Input validation
- ✅ Timeout handling
- ✅ Retry logic where appropriate
- ❌ Silent failures
- ❌ Unhandled exceptions

### Testing
- ✅ Unit tests with >80% coverage
- ✅ Integration tests
- ✅ Error path testing
- ✅ Load/performance testing
- ✅ Security testing
- ❌ Skipped tests
- ❌ Hard-coded test data

### Documentation
- ✅ Clear README with examples
- ✅ Inline code comments for complex logic
- ✅ Example workflows using the skill
- ✅ Troubleshooting guide
- ❌ Outdated documentation
- ❌ Assumption of knowledge

## Versioning

- **MAJOR**: Breaking API changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

Update version in `skill.yaml` before deploying changes.

## Support and Maintenance

### Getting Help
- Check skill documentation
- Review example workflows
- Consult BMAD framework docs
- Post in #skills Slack channel
- File issues on GitHub

### Maintenance
- Keep dependencies updated
- Monitor for security issues
- Respond to error reports
- Iterate based on feedback
- Archive deprecated skills
