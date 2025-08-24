#!/bin/bash
# Example-01 Learning Project Startup Script
# Project AI Manager - Safe learning environment
# Author: Bartosz Majkut

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    Project AI Manager - Example-01${NC}"
echo -e "${BLUE}========================================${NC}"
echo
echo -e "${YELLOW}Starting learning environment...${NC}"
echo

# Check if Docker is running
if ! command -v docker &> /dev/null; then
    echo -e "${RED}ERROR: Docker is not installed!${NC}"
    echo "Please install Docker and try again."
    echo
    read -p "Press Enter to exit"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}ERROR: Docker is not running!${NC}"
    echo "Please start Docker and try again."
    echo
    read -p "Press Enter to exit"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "scripts/manage-example-project.sh" ]; then
    echo -e "${RED}ERROR: Please run this script from the example-01 directory!${NC}"
    echo
    read -p "Press Enter to exit"
    exit 1
fi

echo -e "${GREEN}Docker is running. Starting environment...${NC}"
echo

# Make the script executable
chmod +x scripts/manage-example-project.sh

# Start the environment
./scripts/manage-example-project.sh start

echo
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Environment startup completed!${NC}"
echo -e "${BLUE}========================================${NC}"
echo
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Open http://localhost:3000 in your browser"
echo "2. Login with admin/admin"
echo "3. Create project 'Example-01'"
echo "4. Get API key from My Account"
echo "5. Update config/project-config.json"
echo
echo -e "${BLUE}For detailed instructions, see QUICK-START.md${NC}"
echo
read -p "Press Enter to exit"
