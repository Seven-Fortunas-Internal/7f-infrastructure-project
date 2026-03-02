---
name: create-docker
description: Create Docker container images with proper layering, security, and optimization
---

# Create Docker

**Goal:** Build containerized applications that are secure, efficient, and reproducible.

## Steps

1. **Analyze Application**: Understand app runtime, dependencies, requirements
2. **Write Dockerfile**: Create base image, install dependencies, copy code
3. **Optimize Layers**: Minimize image size through layer caching and cleanup
4. **Add Security**: Configure non-root users, security scans, minimal base images
5. **Test Build**: Build image locally and verify functionality
6. **Push to Registry**: Upload to Docker Hub, ECR, or private registry
7. **Document**: Create README with build/run instructions
8. **Automate**: Set up automated builds on code changes

## Tools

- Docker CLI and engine
- Multi-stage builds for optimization
- Container security scanners (Trivy, etc.)
- Container registries (Docker Hub, ECR, etc.)
- CI/CD integration for automated builds
