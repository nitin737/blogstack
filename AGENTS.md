# AI Agent Guidelines for Blogstack

This document provides instructions for AI coding agents working on the Blogstack blogging platform.

## Quick Reference

| Action        | Command                         |
| ------------- | ------------------------------- |
| Build all     | `./gradlew build`               |
| Build service | `./gradlew :<service>:bootJar`  |
| Run service   | `./gradlew :<service>:bootRun`  |
| Start infra   | `docker-compose up -d postgres` |
| Full stack    | `docker-compose up -d --build`  |

## Project Structure

```
blogging-platform/
├── common/                    # Shared libraries (always check before adding deps)
│   ├── common-core/           # Security, JWT, observability
│   ├── common-web/            # REST, OpenAPI (includes common-core)
│   └── common-events/         # Kafka event DTOs
├── api-gateway/               # Entry point - Spring Cloud Gateway
├── auth-service/              # OAuth2 + JWT (port 8082)
├── user-service/              # User profiles
├── post-service/              # Blog posts
├── comment-service/           # Comments
├── engagement-service/        # Likes, shares
├── subscription-service/      # Subscriptions
├── notification-service/      # Email/push
├── search-service/            # Elasticsearch
├── analytics-service/         # Tracking
└── config-service/            # Centralized config
```

## Critical Patterns

### When Creating a New Service

1. Add to `settings.gradle`:

   ```gradle
   include '<service-name>'
   ```

2. Create `<service>/build.gradle`:

   ```gradle
   plugins {
       id 'org.springframework.boot'
   }
   dependencies {
       implementation 'org.springframework.boot:spring-boot-starter-web'
       implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
       runtimeOnly 'org.postgresql:postgresql'
       implementation project(':common:common-core')
       implementation project(':common:common-web')
       // Add common-events if using Kafka
   }
   ```

3. Create entry point at `com.blogging.<service>.<Service>Application.java`

4. Add `application.yml` with required properties

### When Adding Database Tables

Always use Flyway migrations:

```
src/main/resources/db/migration/V<N>__<description>.sql
```

Example: `V1__create_posts.sql`, `V2__add_author_column.sql`

**Never** use `ddl-auto: create` in production configs.

### When Adding REST Endpoints

- Path pattern: `/api/v1/<resource>`
- Place in `controller/` package
- Use `@RestController` and `@RequestMapping`
- Return DTOs, not entities

### When Adding Entities

```java
@Entity
@Table(name = "table_name")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EntityName {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    // fields...
}
```

### When Adding Cross-Service Events

1. Define event DTO in `common-events`
2. Publisher: inject `KafkaTemplate<String, EventDto>`
3. Consumer: use `@KafkaListener` annotation

## Security Context

- `auth-service` is the **only** OAuth2 Authorization Server
- All other services are Resource Servers (validate JWTs)
- JWT secret configured in `blogging.security.jwt.secret-key`
- Import `common-core` for shared security config

## File Locations by Concern

| Need to...          | Look in                                                         |
| ------------------- | --------------------------------------------------------------- |
| Add API endpoint    | `<service>/src/main/java/com/blogging/<svc>/controller/`        |
| Add business logic  | `<service>/src/main/java/com/blogging/<svc>/service/`           |
| Add entity          | `<service>/src/main/java/com/blogging/<svc>/domain/model/`      |
| Add repository      | `<service>/src/main/java/com/blogging/<svc>/domain/repository/` |
| Add security config | `<service>/src/main/java/com/blogging/<svc>/config/`            |
| Add migration       | `<service>/src/main/resources/db/migration/`                    |
| Add Kafka event     | `common/common-events/event-models/`                            |

## Common Mistakes to Avoid

1. **Don't duplicate security logic** - Use `common-core`
2. **Don't skip Flyway** - All schema changes need migrations
3. **Don't expose entities in APIs** - Use DTOs in `dto/` package
4. **Don't hardcode ports** - Use `application.yml`
5. **Don't add deps to root** - Add to specific service `build.gradle`

## Architecture Docs

- [docs/architecture/auth-user-sync-flow.md](docs/architecture/auth-user-sync-flow.md) - Auth ↔ User event flow
- [docs/architecture/auth-db-er.md](docs/architecture/auth-db-er.md) - Auth database schema
- [docs/architecture/user-db-er.md](docs/architecture/user-db-er.md) - User database schema

## Testing Locally

```bash
# 1. Start database
docker-compose up -d postgres

# 2. Run auth service
./gradlew :auth-service:bootRun

# 3. Test OAuth flow
open http://localhost:8082/oauth2/authorization/google
```
