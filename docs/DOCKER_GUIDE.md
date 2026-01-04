# Docker Compose Quick Reference

This guide provides quick commands and best practices for managing the blogging platform monorepo using Docker Compose.

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Common Commands](#common-commands)
- [Service Management](#service-management)
- [Database Management](#database-management)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## 🚀 Quick Start

### First Time Setup

1. **Create environment file:**

   ```bash
   cp .env.docker .env
   # Edit .env with your configuration
   ```

2. **Make scripts executable:**

   ```bash
   chmod +x scripts/init-databases.sh
   chmod +x scripts/docker-manager.sh
   ```

3. **Start all services:**

   ```bash
   docker-compose up -d
   ```

4. **Check service health:**
   ```bash
   docker-compose ps
   ```

### Using the Interactive Manager

For an easier experience, use the interactive Docker manager:

```bash
./scripts/docker-manager.sh
```

## 📝 Common Commands

### Starting Services

```bash
# Start all services
docker-compose up -d

# Start specific services
docker-compose up -d postgres config-service auth-service

# Start with logs visible
docker-compose up

# Start and rebuild
docker-compose up -d --build
```

### Stopping Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v

# Stop specific service
docker-compose stop auth-service
```

### Viewing Logs

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f auth-service

# View last 100 lines
docker-compose logs --tail=100 auth-service

# View logs from multiple services
docker-compose logs -f auth-service user-service
```

### Restarting Services

```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart auth-service

# Rebuild and restart
docker-compose up -d --build auth-service
```

## 🔧 Service Management

### Check Service Status

```bash
# List all containers
docker-compose ps

# Check health status
docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# View resource usage
docker stats
```

### Execute Commands in Containers

```bash
# Access container shell
docker-compose exec auth-service sh

# Run Gradle command
docker-compose exec auth-service ./gradlew clean build

# Check Java version
docker-compose exec auth-service java -version
```

### Scaling Services

```bash
# Scale a service (if stateless)
docker-compose up -d --scale post-service=3

# Note: Only scale stateless services without fixed ports
```

## 🗄️ Database Management

### Access PostgreSQL

```bash
# Connect to PostgreSQL CLI
docker-compose exec postgres psql -U postgres

# Connect to specific database
docker-compose exec postgres psql -U postgres -d blogging_auth

# Run SQL file
docker-compose exec -T postgres psql -U postgres -d blogging_auth < schema.sql
```

### Database Operations

```sql
-- List all databases
\l

-- Connect to database
\c blogging_auth

-- List tables
\dt

-- Describe table
\d users

-- Exit
\q
```

### Backup and Restore

```bash
# Backup single database
docker-compose exec -T postgres pg_dump -U postgres blogging_auth > backup_auth.sql

# Backup all databases
docker-compose exec -T postgres pg_dumpall -U postgres > backup_all.sql

# Restore database
docker-compose exec -T postgres psql -U postgres blogging_auth < backup_auth.sql
```

### Reset Database

```bash
# Stop services
docker-compose down

# Remove volumes
docker volume rm blogging-platform_postgres_data

# Start fresh
docker-compose up -d
```

## 🐛 Troubleshooting

### Service Won't Start

1. **Check logs:**

   ```bash
   docker-compose logs auth-service
   ```

2. **Check dependencies:**

   ```bash
   docker-compose ps
   # Ensure postgres and config-service are healthy
   ```

3. **Rebuild the service:**
   ```bash
   docker-compose up -d --build auth-service
   ```

### Database Connection Issues

1. **Verify PostgreSQL is running:**

   ```bash
   docker-compose ps postgres
   ```

2. **Check database exists:**

   ```bash
   docker-compose exec postgres psql -U postgres -c "\l"
   ```

3. **Test connection:**
   ```bash
   docker-compose exec postgres pg_isready -U postgres
   ```

### Port Conflicts

If you get port binding errors:

```bash
# Check what's using the port
lsof -i :8080

# Change port in docker-compose.yml or .env
# Example: "8081:8080" instead of "8080:8080"
```

### Out of Memory

```bash
# Check resource usage
docker stats

# Add memory limits in docker-compose.yml:
deploy:
  resources:
    limits:
      memory: 512M
```

### Clean Everything

```bash
# Nuclear option - removes everything
docker-compose down -v
docker system prune -a --volumes

# Then rebuild
docker-compose up -d --build
```

## ✅ Best Practices

### Development Workflow

1. **Start infrastructure first:**

   ```bash
   docker-compose up -d postgres config-service
   ```

2. **Wait for health checks:**

   ```bash
   docker-compose ps
   ```

3. **Start your service:**

   ```bash
   docker-compose up -d auth-service
   ```

4. **Watch logs:**
   ```bash
   docker-compose logs -f auth-service
   ```

### Performance Tips

- **Use BuildKit for faster builds:**

  ```bash
  DOCKER_BUILDKIT=1 docker-compose build
  ```

- **Limit log size:**

  ```yaml
  logging:
    driver: "json-file"
    options:
      max-size: "10m"
      max-file: "3"
  ```

- **Use multi-stage builds** (already implemented in Dockerfiles)

### Security

- **Never commit `.env` file** (already in `.gitignore`)
- **Use secrets for production:**
  ```yaml
  secrets:
    db_password:
      file: ./secrets/db_password.txt
  ```
- **Run as non-root user** (already implemented in Dockerfiles)

### Monitoring

```bash
# Monitor resource usage
docker stats

# Check container health
docker inspect --format='{{json .State.Health}}' blogging-auth-service | jq

# View network connections
docker network inspect blogging-platform_blogging-network
```

## 🎯 Service Ports

| Service              | Port | URL                         |
| -------------------- | ---- | --------------------------- |
| API Gateway          | 8080 | http://localhost:8080       |
| Auth Service         | 8081 | http://localhost:8081       |
| User Service         | 8082 | http://localhost:8082       |
| Post Service         | 8083 | http://localhost:8083       |
| Comment Service      | 8084 | http://localhost:8084       |
| Engagement Service   | 8085 | http://localhost:8085       |
| Subscription Service | 8086 | http://localhost:8086       |
| Notification Service | 8087 | http://localhost:8087       |
| Search Service       | 8088 | http://localhost:8088       |
| Analytics Service    | 8089 | http://localhost:8089       |
| Config Service       | 8888 | http://localhost:8888       |
| PostgreSQL           | 5432 | postgresql://localhost:5432 |

## 🗃️ Database Names

- `blogging_auth` - Authentication service
- `blogging_user` - User service
- `blogging_post` - Post service
- `blogging_comment` - Comment service
- `blogging_engagement` - Engagement service
- `blogging_subscription` - Subscription service
- `blogging_notification` - Notification service
- `blogging_analytics` - Analytics service

## 📚 Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Spring Boot Docker Guide](https://spring.io/guides/gs/spring-boot-docker/)
- [PostgreSQL Docker Hub](https://hub.docker.com/_/postgres)
