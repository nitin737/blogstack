.PHONY: help up down restart logs build clean ps health db-cli migrate infra manager setup

# Default target
help:
	@echo "╔════════════════════════════════════════════╗"
	@echo "║   Blogging Platform - Docker Commands     ║"
	@echo "╚════════════════════════════════════════════╝"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  up              Start all services"
	@echo "  down            Stop all services"
	@echo "  restart         Restart all services"
	@echo "  logs            View logs (all services)"
	@echo "  logs-SERVICE    View logs for specific service (e.g., make logs-auth)"
	@echo "  build           Rebuild all services"
	@echo "  build-SERVICE   Rebuild specific service (e.g., make build-auth)"
	@echo "  clean           Stop and remove all containers and volumes"
	@echo "  ps              Show running containers"
	@echo "  health          Show service health status"
	@echo "  db-cli          Access PostgreSQL CLI"
	@echo "  migrate         Run database migrations"
	@echo "  infra           Start only infrastructure (postgres + config)"
	@echo "  manager         Open interactive Docker manager"
	@echo ""
	@echo "Examples:"
	@echo "  make up              # Start everything"
	@echo "  make logs-auth       # View auth-service logs"
	@echo "  make build-auth      # Rebuild auth-service"
	@echo "  make clean           # Clean everything"
	@echo ""

# Start all services
up:
	@echo "🚀 Starting all services..."
	@docker-compose up -d
	@echo "✅ All services started!"
	@echo "💡 Run 'make health' to check status"

# Start only infrastructure
infra:
	@echo "🚀 Starting infrastructure services..."
	@docker-compose up -d postgres config-service
	@echo "✅ Infrastructure started!"

# Stop all services
down:
	@echo "🛑 Stopping all services..."
	@docker-compose down
	@echo "✅ All services stopped!"

# Restart all services
restart:
	@echo "🔄 Restarting all services..."
	@docker-compose restart
	@echo "✅ All services restarted!"

# View all logs
logs:
	@docker-compose logs -f

# View logs for specific services
logs-auth:
	@docker-compose logs -f auth-service

logs-user:
	@docker-compose logs -f user-service

logs-post:
	@docker-compose logs -f post-service

logs-comment:
	@docker-compose logs -f comment-service

logs-engagement:
	@docker-compose logs -f engagement-service

logs-subscription:
	@docker-compose logs -f subscription-service

logs-notification:
	@docker-compose logs -f notification-service

logs-search:
	@docker-compose logs -f search-service

logs-analytics:
	@docker-compose logs -f analytics-service

logs-gateway:
	@docker-compose logs -f api-gateway

logs-config:
	@docker-compose logs -f config-service

logs-postgres:
	@docker-compose logs -f postgres

# Rebuild all services
build:
	@echo "🔨 Rebuilding all services..."
	@docker-compose build
	@echo "✅ All services rebuilt!"

# Rebuild specific services
build-auth:
	@echo "🔨 Rebuilding auth-service..."
	@docker-compose up -d --build auth-service
	@echo "✅ auth-service rebuilt!"

build-user:
	@echo "🔨 Rebuilding user-service..."
	@docker-compose up -d --build user-service
	@echo "✅ user-service rebuilt!"

build-post:
	@echo "🔨 Rebuilding post-service..."
	@docker-compose up -d --build post-service
	@echo "✅ post-service rebuilt!"

build-comment:
	@echo "🔨 Rebuilding comment-service..."
	@docker-compose up -d --build comment-service
	@echo "✅ comment-service rebuilt!"

build-engagement:
	@echo "🔨 Rebuilding engagement-service..."
	@docker-compose up -d --build engagement-service
	@echo "✅ engagement-service rebuilt!"

build-subscription:
	@echo "🔨 Rebuilding subscription-service..."
	@docker-compose up -d --build subscription-service
	@echo "✅ subscription-service rebuilt!"

build-notification:
	@echo "🔨 Rebuilding notification-service..."
	@docker-compose up -d --build notification-service
	@echo "✅ notification-service rebuilt!"

build-search:
	@echo "🔨 Rebuilding search-service..."
	@docker-compose up -d --build search-service
	@echo "✅ search-service rebuilt!"

build-analytics:
	@echo "🔨 Rebuilding analytics-service..."
	@docker-compose up -d --build analytics-service
	@echo "✅ analytics-service rebuilt!"

build-gateway:
	@echo "🔨 Rebuilding api-gateway..."
	@docker-compose up -d --build api-gateway
	@echo "✅ api-gateway rebuilt!"

build-config:
	@echo "🔨 Rebuilding config-service..."
	@docker-compose up -d --build config-service
	@echo "✅ config-service rebuilt!"

# Clean everything
clean:
	@echo "⚠️  WARNING: This will remove all containers, networks, and volumes!"
	@read -p "Are you sure? (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		echo "🧹 Cleaning everything..."; \
		docker-compose down -v; \
		echo "✅ Everything cleaned!"; \
	else \
		echo "❌ Cancelled"; \
	fi

# Show running containers
ps:
	@docker-compose ps

# Show health status
health:
	@echo "🏥 Service health status:"
	@docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# Access PostgreSQL CLI
db-cli:
	@echo "🐘 Connecting to PostgreSQL..."
	@docker-compose exec postgres psql -U postgres

# Run database migrations
migrate:
	@echo "🔄 Running database migrations..."
	@echo "💡 This will run Flyway migrations for all services"
	@docker-compose exec auth-service ./gradlew flywayMigrate || true
	@docker-compose exec user-service ./gradlew flywayMigrate || true
	@docker-compose exec post-service ./gradlew flywayMigrate || true
	@docker-compose exec comment-service ./gradlew flywayMigrate || true
	@docker-compose exec engagement-service ./gradlew flywayMigrate || true
	@docker-compose exec subscription-service ./gradlew flywayMigrate || true
	@docker-compose exec notification-service ./gradlew flywayMigrate || true
	@docker-compose exec analytics-service ./gradlew flywayMigrate || true
	@echo "✅ Migrations completed!"

# Open interactive manager
manager:
	@./scripts/docker-manager.sh

# Setup environment
setup:
	@if [ ! -f .env ]; then \
		echo "📝 Creating .env file from template..."; \
		cp .env.docker .env; \
		echo "✅ .env file created. Please update it with your configuration."; \
	else \
		echo "✅ .env file already exists"; \
	fi
	@chmod +x scripts/*.sh
	@echo "✅ Scripts are executable"
	@echo "🎉 Setup complete! Run 'make up' to start services."
