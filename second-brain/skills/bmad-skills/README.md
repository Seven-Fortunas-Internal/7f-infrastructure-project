---
title: BMAD Skills
description: BMAD framework skills and standard modules
---

# BMAD Skills

## What is BMAD?

BMAD (Behavioral Modeling and Design) is a framework for creating reusable, composable skills and workflows. BMAD skills are standardized components that can be combined to build complex automation and intelligence systems.

## Core BMAD Skills

### Workflow Management
- **workflow-create**: Create new workflows from specifications
- **workflow-validate**: Validate workflow structure and configuration
- **workflow-execute**: Execute workflows with monitoring
- **workflow-schedule**: Schedule workflows for execution
- **workflow-template**: Create workflow templates for reuse

### Task Automation
- **task-orchestrate**: Coordinate multi-step tasks
- **task-retry**: Handle task failures with retry logic
- **task-parallel**: Run tasks in parallel
- **task-sequence**: Run tasks in sequence with dependencies
- **task-monitor**: Monitor task progress and status

### Integration Patterns
- **http-request**: Make HTTP calls to APIs
- **data-transform**: Transform data between formats
- **event-trigger**: Trigger actions on events
- **webhook-receive**: Receive webhooks
- **webhook-send**: Send webhooks to external systems

### Data Processing
- **data-parse**: Parse various data formats (JSON, CSV, XML, etc.)
- **data-validate**: Validate data against schemas
- **data-filter**: Filter and select data
- **data-aggregate**: Aggregate and summarize data
- **data-cache**: Cache data for performance

## BMAD Module Reference

### Core Modules
- **bmad.workflow**: Workflow creation and execution
- **bmad.task**: Task orchestration and management
- **bmad.integrations**: Integration patterns
- **bmad.data**: Data processing utilities
- **bmad.security**: Security and authentication

### Utility Modules
- **bmad.logging**: Structured logging
- **bmad.metrics**: Performance metrics and monitoring
- **bmad.errors**: Error handling and custom exceptions
- **bmad.config**: Configuration management
- **bmad.testing**: Testing utilities

## Skill Development

### Best Practices for BMAD Skills
1. **Single Responsibility**: Each skill should do one thing well
2. **Clear Interfaces**: Well-defined inputs and outputs
3. **Error Handling**: Comprehensive error handling
4. **Logging**: Debug-level logging throughout
5. **Documentation**: Clear documentation with examples
6. **Testing**: Unit and integration test coverage
7. **Composition**: Design skills to work together

### Skill Structure
```
skill-name/
  ├── skill.yaml           # Skill metadata and configuration
  ├── handler.py           # Main skill implementation
  ├── schema.json          # Input/output JSON schema
  ├── tests/
  │   ├── test_handler.py
  │   └── fixtures/
  ├── docs/
  │   └── README.md
  └── examples/
      └── example.yaml
```

### Skill Template
```yaml
# skill.yaml
name: skill-name
version: 1.0.0
description: What this skill does
module: bmad.skills.skill-name

inputs:
  input_name:
    type: string
    description: Description of input
    required: true

outputs:
  output_name:
    type: string
    description: Description of output

errors:
  SKILL_ERROR: Error description
  VALIDATION_ERROR: Validation failure

tags:
  - category
  - use-case
```

## Common Skills

### Frequently Used BMAD Skills
- `workflow-create`: 90% of workflow use cases
- `task-orchestrate`: 75% of automation needs
- `http-request`: 60% of integrations
- `data-transform`: 50% of data pipelines
- `task-monitor`: Essential for production workflows

### Skills You Should Know
1. **workflow-create**: Required for any workflow
2. **task-orchestrate**: Essential for multi-step processes
3. **error-handler**: Critical for reliability
4. **logging-setup**: Important for debugging
5. **metrics-collect**: Important for monitoring

## Integration with Seven Fortunas

Seven Fortunas builds on BMAD by extending the framework with:
- Custom domain-specific skills
- Integration with AI models
- AI-native workflow patterns
- Enhanced monitoring and observability
- Custom authentication and authorization

See `../custom-skills/` for Seven Fortunas-specific skills.
