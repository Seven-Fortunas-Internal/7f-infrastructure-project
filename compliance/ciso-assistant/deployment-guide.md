# CISO Assistant Deployment Guide

## Overview
CISO Assistant is an open-source GRC (Governance, Risk, and Compliance) platform that helps manage compliance frameworks like SOC 2.

## Deployment to Seven-Fortunas-Internal

### Prerequisites
- Access to Seven-Fortunas-Internal GitHub organization
- Docker and Docker Compose installed
- PostgreSQL database (can use Docker)

### Step 1: Fork CISO Assistant Repository

```bash
# Fork the official CISO Assistant repo to Seven-Fortunas-Internal
gh repo fork intuitem/ciso-assistant-community --org Seven-Fortunas-Internal --clone=false
```

### Step 2: Create Deployment Configuration

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: ciso_assistant
      POSTGRES_USER: ciso_user
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - ciso_network

  backend:
    image: ghcr.io/intuitem/ciso-assistant-community/backend:latest
    environment:
      DATABASE_URL: postgresql://ciso_user:${POSTGRES_PASSWORD}@db:5432/ciso_assistant
      SECRET_KEY: ${DJANGO_SECRET_KEY}
      ALLOWED_HOSTS: ${ALLOWED_HOSTS}
    depends_on:
      - db
    networks:
      - ciso_network
    ports:
      - "8000:8000"

  frontend:
    image: ghcr.io/intuitem/ciso-assistant-community/frontend:latest
    environment:
      BACKEND_URL: http://backend:8000
    depends_on:
      - backend
    networks:
      - ciso_network
    ports:
      - "3000:3000"

volumes:
  postgres_data:

networks:
  ciso_network:
    driver: bridge
```

### Step 3: Environment Configuration

Create `.env.example`:

```bash
# Database
POSTGRES_PASSWORD=changeme_strong_password

# Django Backend
DJANGO_SECRET_KEY=changeme_django_secret_key_at_least_50_chars_long
ALLOWED_HOSTS=localhost,127.0.0.1,your-domain.com

# Frontend
VITE_API_URL=http://localhost:8000
```

### Step 4: Deploy

```bash
# Copy environment template
cp .env.example .env

# Edit .env with secure values
nano .env

# Start services
docker-compose up -d

# Run migrations
docker-compose exec backend python manage.py migrate

# Create superuser
docker-compose exec backend python manage.py createsuperuser
```

### Step 5: Access CISO Assistant

- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- Admin: http://localhost:8000/admin

## Integration with Seven Fortunas

### GitHub Authentication
Configure CISO Assistant to use GitHub OAuth for authentication:

1. Create GitHub OAuth App in Seven-Fortunas-Internal
2. Add OAuth credentials to CISO Assistant settings
3. Enable GitHub SSO for team access

### GitHub API Integration
Configure CISO Assistant to pull evidence from GitHub:

1. Create GitHub Personal Access Token with org:read scope
2. Add to CISO Assistant as data source
3. Configure automated evidence collection (see evidence-collection/)

## Security Considerations

- Store secrets in GitHub Secrets (for CI/CD) or HashiCorp Vault (for production)
- Enable HTTPS/TLS for production deployments
- Implement IP allowlisting for admin access
- Enable audit logging
- Regular backups of PostgreSQL database
- Keep CISO Assistant updated to latest version

## Maintenance

### Backup Database
```bash
docker-compose exec db pg_dump -U ciso_user ciso_assistant > backup.sql
```

### Update CISO Assistant
```bash
docker-compose pull
docker-compose up -d
docker-compose exec backend python manage.py migrate
```

### Monitor Logs
```bash
docker-compose logs -f backend
docker-compose logs -f frontend
```

## Documentation
- Official Docs: https://intuitem.gitbook.io/ciso-assistant
- GitHub: https://github.com/intuitem/ciso-assistant-community
