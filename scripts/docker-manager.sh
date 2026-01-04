#!/bin/bash

# ============================================
# Docker Compose Helper Scripts
# ============================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_message "$RED" "❌ Docker is not running. Please start Docker and try again."
        exit 1
    fi
    print_message "$GREEN" "✅ Docker is running"
}

# Function to create .env file if it doesn't exist
setup_env() {
    if [ ! -f .env ]; then
        print_message "$YELLOW" "⚠️  .env file not found. Creating from .env.docker template..."
        cp .env.docker .env
        print_message "$GREEN" "✅ .env file created. Please update it with your configuration."
    else
        print_message "$GREEN" "✅ .env file exists"
    fi
}

# Function to make init script executable
setup_scripts() {
    if [ -f ./scripts/init-databases.sh ]; then
        chmod +x ./scripts/init-databases.sh
        print_message "$GREEN" "✅ Database initialization script is executable"
    fi
}

# Main menu
show_menu() {
    echo ""
    print_message "$BLUE" "╔════════════════════════════════════════════╗"
    print_message "$BLUE" "║   Blogging Platform - Docker Manager      ║"
    print_message "$BLUE" "╚════════════════════════════════════════════╝"
    echo ""
    echo "1)  Start all services"
    echo "2)  Start only infrastructure (Postgres + Config)"
    echo "3)  Start specific service"
    echo "4)  Stop all services"
    echo "5)  Restart all services"
    echo "6)  View logs (all services)"
    echo "7)  View logs (specific service)"
    echo "8)  Rebuild and restart service"
    echo "9)  Clean everything (remove volumes)"
    echo "10) Show running containers"
    echo "11) Show service health status"
    echo "12) Access PostgreSQL CLI"
    echo "13) Run database migrations"
    echo "14) Exit"
    echo ""
}

# Start all services
start_all() {
    print_message "$BLUE" "🚀 Starting all services..."
    docker-compose up -d
    print_message "$GREEN" "✅ All services started!"
    print_message "$YELLOW" "💡 Run './docker-manager.sh' and select option 11 to check health status"
}

# Start infrastructure only
start_infrastructure() {
    print_message "$BLUE" "🚀 Starting infrastructure services..."
    docker-compose up -d postgres config-service
    print_message "$GREEN" "✅ Infrastructure services started!"
}

# Start specific service
start_specific() {
    echo ""
    echo "Available services:"
    echo "  - postgres"
    echo "  - config-service"
    echo "  - auth-service"
    echo "  - user-service"
    echo "  - post-service"
    echo "  - comment-service"
    echo "  - engagement-service"
    echo "  - subscription-service"
    echo "  - notification-service"
    echo "  - search-service"
    echo "  - analytics-service"
    echo "  - api-gateway"
    echo ""
    read -p "Enter service name: " service_name
    print_message "$BLUE" "🚀 Starting $service_name..."
    docker-compose up -d "$service_name"
    print_message "$GREEN" "✅ $service_name started!"
}

# Stop all services
stop_all() {
    print_message "$YELLOW" "🛑 Stopping all services..."
    docker-compose down
    print_message "$GREEN" "✅ All services stopped!"
}

# Restart all services
restart_all() {
    print_message "$YELLOW" "🔄 Restarting all services..."
    docker-compose restart
    print_message "$GREEN" "✅ All services restarted!"
}

# View all logs
view_logs_all() {
    print_message "$BLUE" "📋 Showing logs for all services (Ctrl+C to exit)..."
    docker-compose logs -f
}

# View specific service logs
view_logs_specific() {
    read -p "Enter service name: " service_name
    print_message "$BLUE" "📋 Showing logs for $service_name (Ctrl+C to exit)..."
    docker-compose logs -f "$service_name"
}

# Rebuild and restart service
rebuild_service() {
    read -p "Enter service name: " service_name
    print_message "$BLUE" "🔨 Rebuilding $service_name..."
    docker-compose up -d --build "$service_name"
    print_message "$GREEN" "✅ $service_name rebuilt and restarted!"
}

# Clean everything
clean_all() {
    print_message "$RED" "⚠️  WARNING: This will remove all containers, networks, and volumes!"
    read -p "Are you sure? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        print_message "$YELLOW" "🧹 Cleaning everything..."
        docker-compose down -v
        print_message "$GREEN" "✅ Everything cleaned!"
    else
        print_message "$YELLOW" "❌ Cancelled"
    fi
}

# Show running containers
show_containers() {
    print_message "$BLUE" "📦 Running containers:"
    docker-compose ps
}

# Show service health status
show_health() {
    print_message "$BLUE" "🏥 Service health status:"
    echo ""
    docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
}

# Access PostgreSQL CLI
postgres_cli() {
    print_message "$BLUE" "🐘 Connecting to PostgreSQL..."
    docker-compose exec postgres psql -U postgres
}

# Run database migrations
run_migrations() {
    print_message "$BLUE" "🔄 Running database migrations..."
    print_message "$YELLOW" "💡 This will run Flyway migrations for all services"
    
    services=("auth-service" "user-service" "post-service" "comment-service" "engagement-service" "subscription-service" "notification-service" "analytics-service")
    
    for service in "${services[@]}"; do
        print_message "$BLUE" "Running migrations for $service..."
        docker-compose exec "$service" ./gradlew flywayMigrate || true
    done
    
    print_message "$GREEN" "✅ Migrations completed!"
}

# Main script
main() {
    check_docker
    setup_env
    setup_scripts
    
    while true; do
        show_menu
        read -p "Enter your choice [1-14]: " choice
        
        case $choice in
            1) start_all ;;
            2) start_infrastructure ;;
            3) start_specific ;;
            4) stop_all ;;
            5) restart_all ;;
            6) view_logs_all ;;
            7) view_logs_specific ;;
            8) rebuild_service ;;
            9) clean_all ;;
            10) show_containers ;;
            11) show_health ;;
            12) postgres_cli ;;
            13) run_migrations ;;
            14) 
                print_message "$GREEN" "👋 Goodbye!"
                exit 0
                ;;
            *)
                print_message "$RED" "❌ Invalid option. Please try again."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main function
main
