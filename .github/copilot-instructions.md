# Blogstack Copilot Instructions

## Architecture Overview

This is a **Spring Boot 3.2 microservices monorepo** for a blogging platform. All services share a common base package `com.blogging.<service>`.

### Service Boundaries

| Service                | Port | Responsibility                                      |
| ---------------------- | ---- | --------------------------------------------------- |
| `api-gateway`          | 8080 | Spring Cloud Gateway, routes all external traffic   |
| `auth-service`         | 8082 | Google OAuth2 login, JWT issuance, user credentials |
| `user-service`         | -    | User profiles, roles (separate from auth)           |
| `post-service`         | -    | Blog post CRUD, content management                  |
| `comment-service`      | -    | Comments on posts                                   |
| `engagement-service`   | -    | Likes, shares                                       |
| `subscription-service` | -    | User-to-user/topic subscriptions                    |
| `notification-service` | -    | Email/push via `spring-boot-starter-mail`           |
| `search-service`       | -    | Elasticsearch integration                           |
| `analytics-service`    | -    | User behavior tracking                              |

### Cross-Service Communication

- **Sync flow**: Auth → emits `UserCreatedEvent` → User Service creates profile (see [auth-user-sync-flow.md](docs/architecture/auth-user-sync-flow.md))
- **Event bus**: Kafka via `common-events` module for async communication
- **Shared UUID**: `auth-service` and `user-service` share the same user UUID as primary key

## Shared Libraries (`common/`)

Always import these for new services:

```gradle
implementation project(':common:common-core')   // Security, logging, observability
implementation project(':common:common-web')    // REST utilities, OpenAPI (springdoc)
implementation project(':common:common-events') // Kafka event models
```

- `common-core`: JWT validation, Spring Security OAuth2 resource server config, Micrometer/OpenTelemetry tracing
- `common-web`: Auto-imports `common-core`, adds SpringDoc OpenAPI UI at `/swagger-ui.html`
- `common-events`: Kafka event DTOs, requires `spring-kafka`

## Build & Run Commands

```bash
# Build entire project
./gradlew build

# Build specific service JAR
./gradlew :auth-service:bootJar

# Run service locally (requires DB in Docker)
./gradlew :auth-service:bootRun

# Start full Docker stack (Postgres + auth-service)
docker-compose up -d --build

# Start only database for hybrid development
docker-compose up -d postgres
```

## Code Conventions

### Package Structure (per service)

```
com.blogging.<service>/
├── <Service>Application.java   # @SpringBootApplication entry point
├── config/                     # @Configuration classes (SecurityConfig, etc.)
├── controller/                 # @RestController, endpoints under /api/<resource>
├── domain/
│   ├── model/                  # JPA @Entity classes
│   ├── repository/             # Spring Data JPA repositories
│   └── event/                  # Domain events for Kafka
├── dto/                        # Request/Response DTOs
├── service/                    # Business logic @Service classes
├── mapper/                     # DTO ↔ Entity mappers
└── exception/                  # Service-specific exceptions
```

### Database Migrations

- Use **Flyway** for schema migrations
- Place scripts in `src/main/resources/db/migration/`
- Naming: `V<version>__<description>.sql` (e.g., `V1__create_user_credentials.sql`)

### API Design

- REST endpoints: `/api/v1/<resource>` (versioned)
- JSON request/response bodies
- Use standard HTTP status codes

### Security Pattern

- `auth-service`: OAuth2 Authorization Server (Google login → JWT)
- Other services: OAuth2 Resource Servers validating JWTs
- Protected services import `common-core` for shared security config
- JWT config in `application.yml` under `blogging.security.jwt.*`

### Entity Design

- Use Lombok (`@Data`, `@Builder`, `@NoArgsConstructor`, `@AllArgsConstructor`)
- JPA with PostgreSQL (`@Entity`, `@Table`)
- ID strategy: `@GeneratedValue(strategy = GenerationType.IDENTITY)` for auto-increment

## Key Configuration

### application.yml pattern

```yaml
server:
  port: <service-port>
spring:
  application:
    name: <service-name>
  datasource:
    url: jdbc:postgresql://localhost:5432/<db_name>
blogging:
  security:
    jwt:
      secret-key: <shared-secret>
      expiration: 86400000
```

## Testing Auth Flow

1. Start: `docker-compose up -d`
2. Open: http://localhost:8082/oauth2/authorization/google
3. Login with Google → receive JWT token

## Adding a New Service

1. Create directory: `<service-name>/src/main/java/com/blogging/<service>/`
2. Add to `settings.gradle`: `include '<service-name>'`
3. Create `build.gradle` with Spring Boot plugin and common dependencies
4. Add `@SpringBootApplication` entry point
5. Create `application.yml` with service config
6. Add Flyway migrations if using database
