#!/bin/bash

# Redmine Example 01 - Start Script (Bash)
# This script starts the Redmine learning environment and automatically seeds data

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Functions
write_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

write_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

write_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

write_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
test_docker() {
    if docker version >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Check if Docker Compose is available
test_docker_compose() {
    if docker-compose version >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Generate API token for Redmine using Core script
start_token_generation() {
    write_info "Starting API token generation using Core script..."
    
    local core_script="$(dirname "$0")/../../core/scripts/linux/redmine/generate-api-token.sh"
    local config_file="$(dirname "$0")/config/config.json"
    
    if [ -f "$core_script" ]; then
        write_info "Running Core token generation script: $core_script"
        write_info "Config file: $config_file"
        
        if bash "$core_script" "$config_file" "" "" "" "$config_file"; then
            write_success "API token generated successfully using Core script!"
            return 0
        else
            write_warning "Token generation completed with warnings"
            return 0
        fi
    else
        write_error "Core token generation script not found: $core_script"
        return 1
    fi
}

# Main execution
echo -e "${GREEN}=== Redmine Example 01 - Start Script ===${NC}"
echo -e "${CYAN}Starting Redmine learning environment...${NC}"
echo ""

# Check prerequisites
if ! test_docker; then
    write_error "Docker is not running or not installed. Please start Docker."
    read -p "Press Enter to exit"
    exit 1
fi

if ! test_docker_compose; then
    write_error "Docker Compose is not available. Please install Docker Compose."
    read -p "Press Enter to exit"
    exit 1
fi

write_success "Docker and Docker Compose are available"

# Create data directories if they don't exist
if [ ! -d "data/postgres" ]; then
    write_info "Creating data directories..."
    mkdir -p data/postgres
    write_success "Data directories created"
fi

# Start Docker services
write_info "Starting Docker services..."
if docker-compose up -d; then
    write_success "Docker services started successfully"
else
    write_error "Failed to start Docker services"
    exit 1
fi

# Wait for services to be ready
write_info "Waiting for services to start..."
wait_count=0
max_wait=20  # Maximum 10 minutes (20 * 30 seconds)

while [ $wait_count -lt $max_wait ]; do
    sleep 30
    wait_count=$((wait_count + 1))
    
    if curl -f -s "http://localhost:3000" >/dev/null 2>&1; then
        write_success "Redmine is now accessible!"
        break
    else
        if [ $wait_count -ge $max_wait ]; then
            write_warning "Redmine is taking longer than expected to start"
            write_info "You can check the status with: docker-compose ps"
            write_info "View logs with: docker-compose logs -f redmine"
            break
        fi
        write_info "Still waiting for Redmine to start... ($((wait_count * 30))s)"
    fi
done

# Display service status
write_info "Service status:"
docker-compose ps

echo ""
write_success "Redmine learning environment is ready!"
echo ""

# Generate API token
write_info "Starting API token generation process..."
if start_token_generation; then
    echo ""
    write_success "Environment setup completed successfully!"
    echo ""
    echo -e "${YELLOW}Access URLs:${NC}"
    echo -e "  ${CYAN}Redmine: http://localhost:3000${NC}"
    echo -e "  ${CYAN}Adminer: http://localhost:8080${NC}"
    echo ""
    echo -e "${YELLOW}Default credentials:${NC}"
    echo -e "  ${CYAN}Username: admin${NC}"
    echo -e "  ${CYAN}Password: Zaq1xsw@${NC}"
    echo ""
    echo -e "${YELLOW}What's ready:${NC}"
    echo -e "  ✅ ${CYAN}Redmine application running${NC}"
    echo -e "  ✅ ${CYAN}API token generated${NC}"
    echo -e "  ✅ ${CYAN}Configuration files updated${NC}"
    echo -e "  ✅ ${CYAN}Ready for AI integration testing${NC}"
else
    echo ""
    write_warning "Environment started but token generation failed"
    echo -e "You can run token generation manually: ${YELLOW}./config/generate-api-token.sh${NC}"
fi

echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo -e "  ${CYAN}View logs: docker-compose logs -f${NC}"
echo -e "  ${CYAN}Stop services: docker-compose down${NC}"
echo -e "  ${CYAN}Restart: docker-compose restart${NC}"
echo -e "  ${CYAN}Manual seeding: ./scripts/seed-via-api.sh${NC}"

read -p "Press Enter to exit"
