# 🐳 Docker Compose Setup for Blogging Platform

This directory contains a production-ready Docker Compose configuration for the blogging platform monorepo with multiple microservices.

## 📁 Files Overview

- **`docker-compose.yml`** - Main configuration with all services
- **`docker-compose.override.yml`** - Development overrides (auto-merged)
- **`.env.docker`** - Environment variables template
- **`scripts/init-databases.sh`** - PostgreSQL multi-database initialization
- **`scripts/docker-manager.sh`** - Interactive management tool
- **`docs/DOCKER_GUIDE.md`** - Comprehensive reference guide

## 🏗️ Architecture

### Database Strategy

- **Single PostgreSQL instance** with multiple databases (one per service)
- Separate databases ensure proper microservices isolation
- Cost-effective for local development
- Easy to migrate to separate instances in production

### Services

```
┌─────────────────────────────────────────────────────────┐
│                     API Gateway (8080)                   │
└─────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼────────┐  ┌──────▼──────┐  ┌────────▼────────┐
│  Auth Service  │  │ User Service │  │  Post Service   │
│    (8081)      │  │    (8082)    │  │     (8083)      │
└────────────────┘  └──────────────┘  └─────────────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            │
                ┌───────────▼───────────┐
                │   PostgreSQL (5432)   │
                │  ┌─────────────────┐  │
                │  │ blogging_auth   │  │
                │  │ blogging_user   │  │
                │  │ blogging_post   │  │
                │  │ ... (8 DBs)     │  │
                │  └─────────────────┘  │
                └───────────────────────┘
```

## 🚀 Quick Start

### 1. Initial Setup

```bash
# Create environment file
cp .env.docker .env

# Make scripts executable (already done)
chmod +x scripts/*.sh

# Start all services
docker-compose up -d
```

### 2. Verify Services

```bash
# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Check health
./scripts/docker-manager.sh  # Select option 11
```

### 3. Access Services

- **API Gateway**: http://localhost:8080
- **Auth Service**: http://localhost:8081
- **User Service**: http://localhost:8082
- **PostgreSQL**: localhost:5432

## 🎯 Common Use Cases

### Start Only What You Need

```bash
# Infrastructure only
docker-compose up -d postgres config-service

# Specific service with dependencies
docker-compose up -d auth-service
# This automatically starts postgres and config-service
```

### Development Workflow

```bash
# 1. Start infrastructure
docker-compose up -d postgres config-service

# 2. Work on your service locally (outside Docker)
cd auth-service
./gradlew bootRun

# 3. When ready, test in Docker
docker-compose up -d --build auth-service
docker-compose logs -f auth-service
```

### Testing Changes

```bash
# Rebuild and restart a service
docker-compose up -d --build auth-service

# View logs
docker-compose logs -f auth-service

# If issues, check health
docker-compose ps auth-service
```

## 🗄️ Database Management

### Access PostgreSQL

```bash
# Using Docker Compose
docker-compose exec postgres psql -U postgres

# Connect to specific database
docker-compose exec postgres psql -U postgres -d blogging_auth
```

### Database Operations

```sql
-- List all databases
\l

-- Connect to database
\c blogging_auth

-- List tables
\dt

-- Run query
SELECT * FROM users;
```

### Backup & Restore

```bash
# Backup
docker-compose exec -T postgres pg_dump -U postgres blogging_auth > backup.sql

# Restore
docker-compose exec -T postgres psql -U postgres blogging_auth < backup.sql
```

## 🔧 Configuration

### Environment Variables

Edit `.env` file:

```env
POSTGRES_PASSWORD=your_secure_password
SPRING_PROFILES_ACTIVE=docker
LOGGING_LEVEL=INFO
```

### Port Customization

Edit `docker-compose.yml`:

```yaml
auth-service:
  ports:
    - "8091:8080" # Change external port
```

### Resource Limits

Add to service definition:

```yaml
deploy:
  resources:
    limits:
      cpus: "0.5"
      memory: 512M
```

## 🐛 Troubleshooting

### Service Won't Start

```bash
# Check logs
docker-compose logs auth-service

# Rebuild
docker-compose up -d --build auth-service

# Check dependencies
docker-compose ps postgres config-service
```

### Database Connection Failed

```bash
# Verify PostgreSQL is healthy
docker-compose ps postgres

# Check databases exist
docker-compose exec postgres psql -U postgres -c "\l"

# Restart PostgreSQL
docker-compose restart postgres
```

### Port Already in Use

```bash
# Find what's using the port
lsof -i :8080

# Kill the process or change port in docker-compose.yml
```

### Clean Start

```bash
# Stop everything
docker-compose down -v

# Remove all Docker resources
docker system prune -a --volumes

# Start fresh
docker-compose up -d
```

## 📊 Monitoring

### View Resource Usage

```bash
docker stats
```

### Check Health Status

```bash
# All services
docker-compose ps

# Specific service
docker inspect --format='{{json .State.Health}}' blogging-auth-service | jq
```

### Network Inspection

```bash
docker network inspect blogging-platform_blogging-network
```

## 🎨 Advanced Features

### Using the Interactive Manager

```bash
./scripts/docker-manager.sh
```

Features:

- ✅ Start/stop services
- 📋 View logs
- 🔨 Rebuild services
- 🗄️ Database access
- 🏥 Health checks
- 🧹 Clean operations

### Development Mode

The `docker-compose.override.yml` file is automatically merged and provides:

- Debug logging
- Log file volumes
- Development-specific settings

### Production Deployment

Create `docker-compose.prod.yml`:

```yaml
version: "3.8"
services:
  auth-service:
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: "1"
          memory: 1G
```

Run with:

```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## 📚 Service Ports Reference

| Service              | Port | Database              |
| -------------------- | ---- | --------------------- |
| API Gateway          | 8080 | -                     |
| Auth Service         | 8081 | blogging_auth         |
| User Service         | 8082 | blogging_user         |
| Post Service         | 8083 | blogging_post         |
| Comment Service      | 8084 | blogging_comment      |
| Engagement Service   | 8085 | blogging_engagement   |
| Subscription Service | 8086 | blogging_subscription |
| Notification Service | 8087 | blogging_notification |
| Search Service       | 8088 | -                     |
| Analytics Service    | 8089 | blogging_analytics    |
| Config Service       | 8888 | -                     |
| PostgreSQL           | 5432 | All databases         |

## 🔐 Security Best Practices

1. **Never commit `.env`** - Already in `.gitignore`
2. **Use strong passwords** - Change default in `.env`
3. **Run as non-root** - Already configured in Dockerfiles
4. **Limit resources** - Prevent DoS attacks
5. **Use secrets in production** - Not plain environment variables

## 📖 Additional Resources

- [Docker Compose Guide](docs/DOCKER_GUIDE.md) - Comprehensive reference
- [Docker Documentation](https://docs.docker.com/compose/)
- [Spring Boot Docker](https://spring.io/guides/gs/spring-boot-docker/)

## 🤝 Contributing

When adding a new service:

1. Create Dockerfile in service directory
2. Add service to `docker-compose.yml`
3. Add database to `scripts/init-databases.sh`
4. Update this README
5. Test with `docker-compose up -d --build <service>`

## 📝 Notes

- **Health checks** ensure services start in correct order
- **Named volumes** persist data between restarts
- **Bridge network** allows inter-service communication
- **Override file** is automatically merged in development
