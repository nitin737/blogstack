# Build stage
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /build

# Copy Gradle wrapper and build files
COPY ../../gradle gradle
COPY ../../gradlew ../../build.gradle ../../settings.gradle ./

# Copy this service
COPY . ./engagement-service

# Build the service
WORKDIR /build/engagement-service
RUN ../gradlew build -x test --no-daemon

# Runtime stage
FROM eclipse-temurin:21-jre-alpine

# Metadata
LABEL maintainer="nitin127001@gmail.com"
LABEL version="1.0"
LABEL description="Engagement Service for Blogging Platform"

# Create non-root user
RUN addgroup -S spring && adduser -S spring -G spring

# Set working directory
WORKDIR /app

# Copy JAR from build stage
COPY --from=builder /build/engagement-service/build/libs/*.jar app.jar

# Change ownership to non-root user
RUN chown spring:spring app.jar

# Switch to non-root user
USER spring:spring

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Optimized JVM settings
ENTRYPOINT ["java", \
    "-XX:+UseContainerSupport", \
    "-XX:MaxRAMPercentage=75.0", \
    "-XX:+ExitOnOutOfMemoryError", \
    "-Djava.security.egd=file:/dev/./urandom", \
    "-jar", "app.jar"]
