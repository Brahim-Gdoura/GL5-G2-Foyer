#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Foyer App - Development Setup${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Function to start the application
start_app() {
    print_message "Starting Foyer application..."
    docker-compose up -d
    
    print_message "Waiting for services to be ready..."
    sleep 10
    
    print_message "Checking service status..."
    docker-compose ps
    
    echo ""
    print_message "Application is starting! Please wait 30-60 seconds for full initialization."
    echo ""
    echo -e "${GREEN}Access points:${NC}"
    echo "  - API: http://localhost:8083/tpFoyer17"
    echo "  - Swagger UI: http://localhost:8083/tpFoyer17/swagger-ui.html"
    echo "  - Health Check: http://localhost:8083/tpFoyer17/actuator/health"
    echo ""
}

# Function to stop the application
stop_app() {
    print_message "Stopping Foyer application..."
    docker-compose down
    print_message "Application stopped."
}

# Function to view logs
view_logs() {
    print_message "Viewing application logs (press Ctrl+C to exit)..."
    docker-compose logs -f spring_app
}

# Function to rebuild the application
rebuild_app() {
    print_message "Rebuilding Foyer application..."
    docker-compose down
    docker-compose build --no-cache
    docker-compose up -d
    print_message "Application rebuilt and restarted."
}

# Function to clean up
cleanup() {
    print_warning "This will remove all containers, volumes, and images. Are you sure? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_message "Cleaning up..."
        docker-compose down -v
        docker rmi foyer-app:latest 2>/dev/null || true
        print_message "Cleanup complete."
    else
        print_message "Cleanup cancelled."
    fi
}

# Function to run tests
run_tests() {
    print_message "Running tests..."
    ./mvnw clean test
}

# Function to build without Docker
build_local() {
    print_message "Building application locally..."
    ./mvnw clean package -DskipTests
    print_message "Build complete. JAR file is in target/"
}

# Main menu
show_menu() {
    echo ""
    echo "What would you like to do?"
    echo "1) Start application (Docker)"
    echo "2) Stop application"
    echo "3) View logs"
    echo "4) Rebuild application"
    echo "5) Run tests"
    echo "6) Build locally (Maven)"
    echo "7) Clean up (remove all containers and volumes)"
    echo "8) Exit"
    echo ""
    echo -n "Enter your choice [1-8]: "
}

# Main script
if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -r choice
        case $choice in
            1) start_app ;;
            2) stop_app ;;
            3) view_logs ;;
            4) rebuild_app ;;
            5) run_tests ;;
            6) build_local ;;
            7) cleanup ;;
            8) print_message "Goodbye!"; exit 0 ;;
            *) print_error "Invalid option. Please try again." ;;
        esac
    done
else
    # Command line mode
    case $1 in
        start) start_app ;;
        stop) stop_app ;;
        logs) view_logs ;;
        rebuild) rebuild_app ;;
        test) run_tests ;;
        build) build_local ;;
        clean) cleanup ;;
        *)
            echo "Usage: $0 {start|stop|logs|rebuild|test|build|clean}"
            echo "  Or run without arguments for interactive mode"
            exit 1
            ;;
    esac
fi
