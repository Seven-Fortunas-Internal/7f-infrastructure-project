# Feature Categories for App Spec

This document defines the 7 domain categories used for feature classification in the create-app-spec workflow.

## Purpose

Features extracted from PRDs are automatically categorized into these 7 domains to provide:
- Logical organization for autonomous agents
- Clear separation of concerns
- Balanced distribution across architectural layers

## The 7 Domain Categories

### 1. Infrastructure & Foundation

**Description:** Core services, data models, authentication, and foundational systems that other features depend on.

**Typical features:**
- Database schema and models
- Authentication and session management
- API key management
- Configuration systems
- Core data structures
- Caching layers
- Message queues

**Keyword patterns:**
- database, schema, model, entity
- auth, login, session, token, credentials
- API key, secrets, config, settings
- cache, redis, memcached
- queue, message broker

**Example features:**
- User authentication system
- Database schema for orders
- Session management service
- Configuration loader

---

### 2. User Interface

**Description:** Screens, components, forms, navigation, and all user-facing interactive elements.

**Typical features:**
- Web pages and screens
- UI components and widgets
- Forms and input validation
- Navigation menus
- Dashboards and data visualizations
- Modal dialogs and alerts

**Keyword patterns:**
- screen, page, view, UI
- component, widget, element
- form, input, button, dropdown
- navigation, menu, sidebar
- dashboard, chart, graph, visualization
- modal, dialog, popup, alert

**Example features:**
- User profile page
- Dashboard with sales metrics
- Login form component
- Navigation menu with role-based items

---

### 3. Business Logic

**Description:** Workflows, calculations, rules, algorithms, and processing logic that implements business requirements.

**Typical features:**
- Business process workflows
- Calculation engines
- Validation rules
- Data transformations
- Business rule engines
- Approval workflows
- Notification logic

**Keyword patterns:**
- calculate, compute, process
- validate, verify, check
- workflow, process, pipeline
- rule, logic, algorithm
- transform, convert, format
- approve, reject, review

**Example features:**
- Order total calculation with tax
- Inventory availability checker
- Payment processing workflow
- Data validation rules

---

### 4. Integration

**Description:** APIs, external services, data synchronization, webhooks, and third-party connectors.

**Typical features:**
- REST/GraphQL APIs
- External service integrations (payment gateways, email services)
- Data import/export
- Webhooks (inbound and outbound)
- Third-party API clients
- Data synchronization

**Keyword patterns:**
- API, endpoint, REST, GraphQL
- integration, connector, adapter
- external, third-party, service
- webhook, callback
- sync, import, export
- payment gateway, email service

**Example features:**
- Stripe payment integration
- Slack notification webhook
- Customer data import from CSV
- Salesforce API connector

---

### 5. DevOps & Deployment

**Description:** CI/CD, infrastructure, monitoring, logging, and deployment automation.

**Typical features:**
- CI/CD pipelines
- Containerization (Docker, Kubernetes)
- Infrastructure as code
- Monitoring and alerting
- Log aggregation
- Deployment scripts
- Health checks and readiness probes

**Keyword patterns:**
- CI/CD, pipeline, deploy
- Docker, Kubernetes, container
- infrastructure, terraform, cloudformation
- monitoring, metrics, observability
- logging, logs, log aggregation
- alert, notification, incident
- health check, readiness, liveness

**Example features:**
- GitHub Actions CI/CD pipeline
- Kubernetes deployment manifests
- Application monitoring with Prometheus
- Centralized logging with ELK stack

---

### 6. Security & Compliance

**Description:** Authorization, encryption, audit logging, compliance checks, and security controls.

**Typical features:**
- Role-based access control (RBAC)
- Encryption (data at rest, in transit)
- Audit logging
- Compliance checks (GDPR, HIPAA, SOC2)
- Security scanning
- Rate limiting
- Input sanitization

**Keyword patterns:**
- authorization, permission, role, RBAC
- encrypt, encryption, decrypt
- audit, audit log, compliance
- security, secure, vulnerability
- rate limit, throttle
- sanitize, escape, XSS, SQL injection
- GDPR, HIPAA, SOC2, PCI

**Example features:**
- Role-based access control system
- Encryption for sensitive data fields
- Audit log for admin actions
- GDPR compliance data deletion

---

### 7. Testing & Quality

**Description:** Test infrastructure, test data management, quality gates, and test utilities.

**Typical features:**
- Test frameworks and runners
- Mock data generators
- Test fixtures and factories
- Quality gates and coverage checks
- Load testing infrastructure
- Test automation utilities

**Keyword patterns:**
- test, testing, unit test, integration test
- mock, fixture, factory, seed
- coverage, quality, gate
- load test, performance test, stress test
- test automation, test runner

**Example features:**
- Unit test suite for authentication
- Mock data generator for user entities
- Test fixtures for order scenarios
- CI quality gate with 80% coverage requirement

---

## Categorization Guidelines

### Single Category Assignment

Each feature must be assigned to **exactly one** category. Use these guidelines:

1. **Primary purpose wins:** Categorize based on the feature's main purpose, not secondary effects
2. **Context matters:** Consider where the feature fits in the overall architecture
3. **When uncertain:** Choose the category that best describes what the feature *does*, not what it *uses*

### Distribution Expectations

For a balanced app_spec:
- **Infrastructure:** 10-20% (foundational features)
- **User Interface:** 20-30% (for user-facing apps)
- **Business Logic:** 25-35% (core functionality)
- **Integration:** 5-15% (depends on external dependencies)
- **DevOps:** 5-10% (deployment and monitoring)
- **Security:** 5-15% (depends on compliance requirements)
- **Testing:** 5-10% (test infrastructure)

**Warning flags:**
- Any single category >60% (inappropriate domination)
- Infrastructure <5% for complex projects (likely missing foundational features)
- Fewer than 3 categories (scope too narrow)

### Edge Cases

**Feature spans multiple categories:**
- Example: "User login with audit logging"
- Categorize by primary purpose: **Infrastructure** (authentication is the main goal)
- Audit logging is a secondary effect, not the primary purpose

**Feature could fit two categories equally:**
- Example: "API endpoint for user profile"
- Consider: Is it primarily about the API (Integration) or the data it returns (Business Logic)?
- If external-facing API: **Integration**
- If internal business logic exposed via API: **Business Logic**

**Testing-related features for other categories:**
- Example: "Unit tests for payment calculation"
- If it's test infrastructure/framework: **Testing & Quality**
- If it's verification criteria for a business logic feature: Include as criteria, not a separate feature

---

## Usage in Workflow

This document is loaded by:
- **step-04-auto-categorization.md** - Uses keyword patterns for automated classification
- **step-02-edit-menu.md** - Displays categories when user recategorizes features

**Automated categorization process:**
1. Parse feature name and description
2. Match against keyword patterns for each category
3. Assign to category with strongest match
4. Validate distribution after all features categorized
5. Allow user to adjust any miscategorizations

---

**Version:** 1.0
**Last Updated:** 2026-02-13
**Used By:** create-app-spec workflow (step-04)
