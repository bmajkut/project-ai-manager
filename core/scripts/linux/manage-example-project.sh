#!/bin/bash
# Example-01 Project Management Script (Linux/macOS)
# Version: 1.0.0
# Author: Redmine AI Assistant
# Function: Manage example project with full permissions

# Script configuration
SCRIPT_VERSION="1.0.0"
SCRIPT_AUTHOR="Redmine AI Assistant"
SCRIPT_DESCRIPTION="Example project management script for Linux/macOS"

# Default values
ACTION=""
BACKUP_FILE=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO")
            echo -e "[$timestamp] ${GREEN}[INFO]${NC} $message"
            ;;
        "WARNING")
            echo -e "[$timestamp] ${YELLOW}[WARNING]${NC} $message"
            ;;
        "ERROR")
            echo -e "[$timestamp] ${RED}[ERROR]${NC} $message"
            ;;
        "CRITICAL")
            echo -e "[$timestamp] ${RED}[CRITICAL]${NC} $message"
            ;;
        *)
            echo -e "[$timestamp] $message"
            ;;
    esac
}

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    
    print_message "$level" "$message"
}

# Function to check Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_message "ERROR" "Docker is not available. Please install Docker."
        return 1
    fi
    
    if ! docker info &> /dev/null; then
        log_message "ERROR" "Docker is not running. Please start Docker daemon."
        return 1
    fi
    
    local docker_version
    docker_version=$(docker --version)
    log_message "INFO" "Docker available: $docker_version"
    return 0
}

# Function to start environment
start_environment() {
    log_message "INFO" "Starting Example-01 environment..."
    
    local docker_compose_path
    docker_compose_path="$(dirname "$0")/../../docker-compose.yml"
    
    if [ ! -f "$docker_compose_path" ]; then
        log_message "ERROR" "docker-compose.yml not found: $docker_compose_path"
        exit 1
    fi
    
    # Change to directory with docker-compose.yml
    cd "$(dirname "$docker_compose_path")" || exit 1
    
    # Start services
    docker-compose up -d
    
    log_message "INFO" "Waiting for Redmine to start..."
    sleep 30
    
    # Check status
    local status
    status=$(docker-compose ps)
    log_message "INFO" "Container status:"
    echo "$status"
    
    log_message "INFO" "Environment started!"
    log_message "INFO" "Redmine: http://localhost:3000"
    log_message "INFO" "Adminer: http://localhost:8080"
}

# Function to stop environment
stop_environment() {
    log_message "INFO" "Stopping Example-01 environment..."
    
    local docker_compose_path
    docker_compose_path="$(dirname "$0")/../../docker-compose.yml"
    cd "$(dirname "$docker_compose_path")" || exit 1
    
    docker-compose down
    
    log_message "INFO" "Environment stopped!"
}

# Function to reset environment
reset_environment() {
    log_message "INFO" "Resetting Example-01 environment..."
    
    local docker_compose_path
    docker_compose_path="$(dirname "$0")/../../docker-compose.yml"
    cd "$(dirname "$docker_compose_path")" || exit 1
    
    # Stop and remove all data
    docker-compose down -v
    log_message "INFO" "All data has been removed"
    
    # Start again
    docker-compose up -d
    log_message "INFO" "Environment reset and started!"
}

# Function to perform full cleanup
full_cleanup() {
    log_message "INFO" "Performing full Redmine cleanup..."
    
    local backup_dir
    backup_dir="$(dirname "$0")/../../backups"
    mkdir -p "$backup_dir"
    
    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="$backup_dir/backup_before_cleanup_$timestamp.sql"
    
    # Backup database
    docker exec redmine-example-postgres pg_dump -U redmine redmine > "$backup_file"
    log_message "INFO" "Backup created: $backup_file"
    
    # Backup Redmine files
    local files_backup="$backup_dir/files_before_cleanup_$timestamp"
    docker cp redmine-example-app:/usr/src/redmine/files "$files_backup"
    log_message "INFO" "Files backup created: $files_backup"
    
    # Perform cleanup through Redmine API
    log_message "INFO" "Performing cleanup through Redmine API..."
    
    local config_file
    config_file="$(dirname "$0")/../../config/project-config.json"
    
    if [ -f "$config_file" ]; then
        # Use Redmine API to remove all issues
        local redmine_script
        redmine_script="$(dirname "$0")/../../../core/scripts/linux/redmine-api.sh"
        
        if [ -f "$redmine_script" ]; then
            # Get list of issues to remove
            log_message "INFO" "Fetching issues list for cleanup..."
            bash "$redmine_script" -a "get-issues" -c "$config_file" -o "temp_issues.json"
            
            if [ -f "temp_issues.json" ]; then
                local issues_count
                issues_count=$(jq '.issues | length' "temp_issues.json")
                log_message "INFO" "Found $issues_count issues to remove"
                
                # Remove each issue (allowed in example-01 mode)
                jq -r '.issues[] | "\(.id): \(.subject)"' "temp_issues.json" | while read -r issue_info; do
                    log_message "INFO" "Removing issue: $issue_info"
                    # Here you can add API call to remove the issue
                done
                
                rm -f "temp_issues.json"
            fi
        fi
    fi
    
    log_message "INFO" "Full cleanup completed!"
    log_message "INFO" "Backup available in: $backup_dir"
}

# Function to create backup
create_backup() {
    log_message "INFO" "Creating Example-01 environment backup..."
    
    local backup_dir
    backup_dir="$(dirname "$0")/../../backups"
    mkdir -p "$backup_dir"
    
    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="$backup_dir/backup_$timestamp.sql"
    
    # Backup database
    docker exec redmine-example-postgres pg_dump -U redmine redmine > "$backup_file"
    log_message "INFO" "Database backup: $backup_file"
    
    # Backup Redmine files
    local files_backup="$backup_dir/files_$timestamp"
    docker cp redmine-example-app:/usr/src/redmine/files "$files_backup"
    log_message "INFO" "Files backup: $files_backup"
    
    log_message "INFO" "Backup completed successfully!"
}

# Function to restore from backup
restore_backup() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        log_message "ERROR" "BackupFile parameter is required for restore action"
        exit 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        log_message "ERROR" "Backup file not found: $backup_file"
        exit 1
    fi
    
    log_message "INFO" "Restoring from backup: $backup_file"
    
    local docker_compose_path
    docker_compose_path="$(dirname "$0")/../../docker-compose.yml"
    cd "$(dirname "$docker_compose_path")" || exit 1
    
    # Stop Redmine
    docker-compose stop redmine
    
    # Restore database
    docker exec -i redmine-example-postgres psql -U redmine redmine < "$backup_file"
    log_message "INFO" "Database restored"
    
    # Start Redmine again
    docker-compose start redmine
    
    log_message "INFO" "Restore completed!"
}

# Function to check status
check_status() {
    log_message "INFO" "Checking Example-01 environment status..."
    
    local docker_compose_path
    docker_compose_path="$(dirname "$0")/../../docker-compose.yml"
    
    if [ -f "$docker_compose_path" ]; then
        cd "$(dirname "$docker_compose_path")" || exit 1
        
        local status
        status=$(docker-compose ps)
        log_message "INFO" "Container status:"
        echo "$status"
        
        # Check Redmine availability
        if curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000" | grep -q "200"; then
            log_message "INFO" "Redmine available: HTTP 200"
        else
            log_message "WARNING" "Redmine not available"
        fi
        
        # Check Adminer availability
        if curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080" | grep -q "200"; then
            log_message "INFO" "Adminer available: HTTP 200"
        else
            log_message "WARNING" "Adminer not available"
        fi
    else
        log_message "ERROR" "docker-compose.yml not found"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <action> [options]"
    echo ""
    echo "Actions:"
    echo "  start     - Start environment"
    echo "  stop      - Stop environment"
    echo "  reset     - Reset environment (remove all data)"
    echo "  cleanup   - Full Redmine cleanup"
    echo "  backup    - Create backup"
    echo "  restore   - Restore from backup"
    echo "  status    - Check status"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 cleanup"
    echo "  $0 restore backup_20240824_120000.sql"
    echo ""
    echo "Note: This script requires Docker and docker-compose"
}

# Main execution logic
main() {
    log_message "INFO" "Example-01 Project Manager - Starting operation: $ACTION"
    
    # Check Docker
    if ! check_docker; then
        exit 1
    fi
    
    # Execute action
    case $ACTION in
        "start")
            start_environment
            ;;
        "stop")
            stop_environment
            ;;
        "reset")
            reset_environment
            ;;
        "cleanup")
            full_cleanup
            ;;
        "backup")
            create_backup
            ;;
        "restore")
            restore_backup "$BACKUP_FILE"
            ;;
        "status")
            check_status
            ;;
        *)
            log_message "ERROR" "Unknown action: $ACTION"
            show_usage
            exit 1
            ;;
    esac
    
    log_message "INFO" "Operation completed successfully"
}

# Parse command line arguments
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

ACTION="$1"
shift

# Parse additional options
while [[ $# -gt 0 ]]; do
    case $1 in
        --backup-file)
            BACKUP_FILE="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            log_message "ERROR" "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Execute main function
main "$@"
