# Environment Variables Setup Guide

## Overview

This guide explains how to manage environment variables for local development and testing in the blogging platform.

## Quick Start

### 1. Set Up Root Environment Variables (for Docker Compose)

```bash
# Copy the example file
cp .env.example .env

# Edit .env and fill in your actual values
nano .env  # or use your preferred editor
```

### 2. Set Up Service-Specific Environment Variables (for local testing)

```bash
# Auth Service
cd auth-service
cp .env.example .env
nano .env

# Post Service
cd ../post-service
cp .env.example .env
nano .env
```

## Environment Variable Files

### Root `.env` (for Docker Compose)

Used when running services with `docker-compose up`. Contains:

- PostgreSQL credentials
- JWT secrets
- OAuth2 credentials
- Service ports

### Service `.env` Files (for local development)

Used when running individual services locally (e.g., `./gradlew bootRun`). Each service has its own `.env` file with service-specific configuration.

## Required Secrets

### JWT Secret

Generate a secure JWT secret:

```bash
# Option 1: Using OpenSSL
openssl rand -base64 64

# Option 2: Using Node.js
node -e "console.log(require('crypto').randomBytes(64).toString('base64'))"

# Option 3: Using Python
python3 -c "import secrets; print(secrets.token_urlsafe(64))"
```

### Google OAuth2 Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable Google+ API
4. Go to "Credentials" → "Create Credentials" → "OAuth 2.0 Client ID"
5. Set authorized redirect URIs:
   - `http://localhost:8080/oauth2/callback/google` (local)
   - `http://localhost:8080/login/oauth2/code/google` (Spring Security default)
6. Copy Client ID and Client Secret to your `.env` file

## Running the Application

### With Docker Compose (Recommended)

```bash
# Ensure root .env is configured
docker-compose up
```

### Individual Services (Local Development)

```bash
# Auth Service
cd auth-service
./gradlew bootRun

# Post Service
cd post-service
./gradlew bootRun
```

## Security Best Practices

### ✅ DO

- Use strong, randomly generated secrets (minimum 256 bits for JWT)
- Rotate secrets regularly
- Use different credentials for development, staging, and production
- Keep `.env` files out of version control
- Use secret management tools in production (AWS Secrets Manager, HashiCorp Vault)
- Share `.env.example` files, never `.env` files

### ❌ DON'T

- Commit `.env` files to Git
- Share secrets via email, Slack, or other communication channels
- Use production credentials in local development
- Hardcode secrets in application code
- Use simple or predictable secrets

## Troubleshooting

### Environment Variables Not Loading

**Spring Boot:**

```bash
# Check if .env file exists
ls -la .env

# Verify Spring Boot is reading environment variables
./gradlew bootRun --debug | grep -i "environment"
```

**Docker Compose:**

```bash
# Verify .env file is being read
docker-compose config

# Check environment variables in running container
docker-compose exec auth-service env | grep -i spring
```

### Database Connection Issues

1. Verify PostgreSQL credentials in `.env`
2. Check if PostgreSQL is running:
   ```bash
   docker-compose ps postgres
   ```
3. Test connection manually:
   ```bash
   psql -h localhost -U postgres -d auth_db
   ```

### OAuth2 Issues

1. Verify Google Client ID and Secret are correct
2. Check redirect URIs match exactly (including protocol and port)
3. Ensure Google+ API is enabled in Google Cloud Console
4. Check browser console for CORS errors

## Environment Variable Reference

### Auth Service

| Variable                     | Description                   | Example                                    | Required |
| ---------------------------- | ----------------------------- | ------------------------------------------ | -------- |
| `SPRING_DATASOURCE_URL`      | PostgreSQL connection URL     | `jdbc:postgresql://localhost:5432/auth_db` | Yes      |
| `SPRING_DATASOURCE_USERNAME` | Database username             | `postgres`                                 | Yes      |
| `SPRING_DATASOURCE_PASSWORD` | Database password             | `your-password`                            | Yes      |
| `JWT_SECRET`                 | Secret key for JWT signing    | `base64-encoded-secret`                    | Yes      |
| `JWT_EXPIRATION`             | JWT expiration time (ms)      | `86400000` (24h)                           | Yes      |
| `REFRESH_TOKEN_EXPIRATION`   | Refresh token expiration (ms) | `604800000` (7d)                           | Yes      |
| `GOOGLE_CLIENT_ID`           | Google OAuth2 Client ID       | `xxx.apps.googleusercontent.com`           | Yes      |
| `GOOGLE_CLIENT_SECRET`       | Google OAuth2 Client Secret   | `GOCSPX-xxx`                               | Yes      |
| `SERVER_PORT`                | Service port                  | `8080`                                     | No       |

### Post Service

| Variable                     | Description               | Example                                    | Required |
| ---------------------------- | ------------------------- | ------------------------------------------ | -------- |
| `SPRING_DATASOURCE_URL`      | PostgreSQL connection URL | `jdbc:postgresql://localhost:5432/post_db` | Yes      |
| `SPRING_DATASOURCE_USERNAME` | Database username         | `postgres`                                 | Yes      |
| `SPRING_DATASOURCE_PASSWORD` | Database password         | `your-password`                            | Yes      |
| `AUTH_SERVICE_URL`           | Auth service URL          | `http://localhost:8080`                    | Yes      |
| `SERVER_PORT`                | Service port              | `8081`                                     | No       |

## Production Deployment

For production environments, use proper secret management:

### AWS Secrets Manager

```yaml
# Example: Fetching secrets in ECS task definition
environment:
  - name: JWT_SECRET
    valueFrom: arn:aws:secretsmanager:region:account:secret:jwt-secret
```

### Kubernetes Secrets

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: auth-service-secrets
type: Opaque
data:
  jwt-secret: <base64-encoded-secret>
  google-client-id: <base64-encoded-id>
  google-client-secret: <base64-encoded-secret>
```

### HashiCorp Vault

```bash
# Store secret
vault kv put secret/auth-service jwt_secret="xxx" google_client_id="xxx"

# Retrieve in application
vault kv get -field=jwt_secret secret/auth-service
```

## Additional Resources

- [Spring Boot External Configuration](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config)
- [Docker Compose Environment Variables](https://docs.docker.com/compose/environment-variables/)
- [Google OAuth2 Setup](https://developers.google.com/identity/protocols/oauth2)
- [12-Factor App: Config](https://12factor.net/config)
