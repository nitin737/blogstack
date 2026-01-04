# Developer Guide

This guide provides instructions for setting up and running the blogging platform services locally, specifically focusing on the Authentication Service.

## Prerequisites

- Docker & Docker Compose
- Java 21
- Gradle (via `gradlew` wrapper)

## Authentication Service (`auth-service`)

The `auth-service` handles Google OAuth 2.0 login, User persistence, and JWT issuance.

### 1. Configuration (Important)

Before running, ensure your Google Cloud Credentials are set up.
The service requires a **Redirect URI** configured in your Google Cloud Console:
`http://localhost:8082/login/oauth2/code/google`

### 2. Running Everything in Docker (Recommended)

**This is the primary method for local development.** Both the PostgreSQL database and the Auth Service run as Docker containers.

1.  **Build the Project JARs**:

    ```bash
    ./gradlew :auth-service:bootJar
    ```

2.  **Start the Full Stack**:

    ```bash
    docker-compose up -d --build
    ```

    This command will:

    - Start a PostgreSQL container (port 5432)
    - Build the `auth-service` Docker image from the `Dockerfile`
    - Start the `auth-service` container (port 8082)
    - Configure networking so the service can communicate with the database

3.  **Verify Status**:

    ```bash
    docker ps
    ```

    You should see both containers running:

    - `blogging-platform-auth-service`
    - `blogging-platform-postgres`

4.  **View Logs**:

    ```bash
    docker logs -f blogging-platform-auth-service
    ```

5.  **Stop the Stack**:

    ```bash
    docker-compose down
    ```

### 3. Local Development (Hybrid Mode)

Use this method if you want to run the **Database in Docker** but run the **Service locally** (e.g., for faster debugging in your IDE).

1.  **Start only the Database**:

    ```bash
    docker-compose up -d postgres
    ```

2.  **Run the Service**:
    ```bash
    ./gradlew :auth-service:bootRun
    ```
    - Ensure your `application.yml` points to `localhost:5432` (default).

### 4. Testing the Login Flow

1.  Open your browser to:
    [http://localhost:8082/oauth2/authorization/google](http://localhost:8082/oauth2/authorization/google)

2.  Log in with your Google Account.

3.  On success, you will see a JSON response with your JWT:
    ```json
    {
      "token": "eyJhbGciOiJIUzI1NiJ9..."
    }
    ```

## Troubleshooting

- **Port Conflicts**: Ensure ports `8082` and `5432` are free.
- **Database Connection**: If `auth-service` crashes immediately, check if `postgres` is ready. Docker Compose handles `depends_on`, but initial DB creation might take a few seconds.
- **Valid Redirect URI**: 400 errors from Google usually mean the Redirect URI in the Google Cloud Console does not match `http://localhost:8082/login/oauth2/code/google`.
