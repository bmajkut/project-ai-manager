#!/bin/bash
# Redmine API Script for Linux/macOS
# Version: 1.0.0
# Author: Project AI Manager
# Function: Redmine API interactions via REST API

# Script configuration
SCRIPT_VERSION="1.0.0"
SCRIPT_AUTHOR="Project AI Manager"
SCRIPT_DESCRIPTION="Redmine API interaction script for Linux/macOS"

# Default values
ACTION=""
CONFIG_FILE="project-config.json"
DATA_FILE=""
OUTPUT_FILE=""

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
    
    # Create logs directory if it doesn't exist
    mkdir -p logs
    
    # Log to file
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "logs/operations.log"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 -a <action> [-c <config_file>] [-d <data_file>] [-o <output_file>]"
    echo ""
    echo "Options:"
    echo "  -a, --action       Required: Action to perform (get-projects, get-issues, create-issue, etc.)"
    echo "  -c, --config       Config file path (default: project-config.json)"
    echo "  -d, --data         Data file path for create/update operations"
    echo "  -o, --output       Output file path for results"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -a get-projects -c config.json"
    echo "  $0 -a create-issue -c config.json -d issue-data.json"
    echo "  $0 -a get-issues -c config.json -o issues.json"
    echo ""
    echo "Available actions:"
    echo "  - get-projects     - Get list of projects"
    echo "  - get-issues       - Get issues for a project"
    echo "  - create-issue     - Create new issue"
    echo "  - update-issue     - Update existing issue"
    echo "  - create-version   - Create new version"
    echo ""
    echo "Note: This script requires jq for JSON processing and curl for HTTP requests"
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    
    # Check for jq
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_message "ERROR" "Missing dependencies: ${missing_deps[*]}"
        echo "Please install missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            case $dep in
                "jq")
                    echo "  jq: sudo apt-get install jq (Ubuntu/Debian) or sudo yum install jq (CentOS/RHEL)"
                    ;;
                "curl")
                    echo "  curl: sudo apt-get install curl (Ubuntu/Debian) or sudo yum install curl (CentOS/RHEL)"
                    ;;
            esac
        done
        exit 1
    fi
}

# Function to load configuration
load_config() {
    local config_path="$1"
    
    if [ ! -f "$config_path" ]; then
        log_message "ERROR" "Configuration file not found: $config_path"
        exit 1
    fi
    
    # Validate JSON
    if ! jq empty "$config_path" 2>/dev/null; then
        log_message "ERROR" "Invalid JSON in configuration file: $config_path"
        exit 1
    fi
    
    log_message "INFO" "Configuration loaded from: $config_path"
    
    # Extract configuration values
    REDMINE_URL=$(jq -r '.redmine_config.url' "$config_path")
    API_KEY=$(jq -r '.redmine_config.api_key' "$config_path")
    PROJECT_ID=$(jq -r '.redmine_config.project_id' "$config_path")
    REDMINE_VERSION=$(jq -r '.redmine_config.version' "$config_path")
    
    # Validate required fields
    if [ "$REDMINE_URL" = "null" ] || [ "$API_KEY" = "null" ] || [ "$PROJECT_ID" = "null" ]; then
        log_message "ERROR" "Missing required configuration fields"
        exit 1
    fi
    
    log_message "INFO" "Configuration validated successfully"
}

# Function to make API calls
invoke_redmine_api() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    
    local url="${REDMINE_URL%/}$endpoint"
    local headers=(
        "X-Redmine-API-Key: $API_KEY"
        "Content-Type: application/json"
        "Accept: application/json"
    )
    
    local curl_opts=(
        "-s"
        "-w" "%{http_code}"
        "-H" "${headers[0]}"
        "-H" "${headers[1]}"
        "-H" "${headers[2]}"
        "-X" "$method"
        "--connect-timeout" "30"
        "--max-time" "60"
    )
    
    if [ -n "$data" ]; then
        curl_opts+=("-d" "$data")
    fi
    
    log_message "INFO" "Executing $method $url"
    
    # Execute curl and capture response
    local response
    response=$(curl "${curl_opts[@]}" "$url" 2>/dev/null)
    
    # Extract HTTP status code (last line)
    local http_code="${response##*$'\n'}"
    local response_body="${response%$'\n'*}"
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        log_message "INFO" "API call successful (HTTP $http_code)"
        echo "$response_body"
    else
        log_message "ERROR" "API call failed (HTTP $http_code): $response_body"
        return 1
    fi
}

# Function to get projects
get_projects() {
    log_message "INFO" "Fetching projects list"
    
    local response
    response=$(invoke_redmine_api "GET" "/projects.json")
    
    if [ $? -eq 0 ]; then
        if [ -n "$OUTPUT_FILE" ]; then
            echo "$response" > "$OUTPUT_FILE"
            log_message "INFO" "Projects list saved to: $OUTPUT_FILE"
        else
            echo "$response" | jq -r '.projects[] | "\(.id): \(.name) (\(.identifier))"'
        fi
    fi
}

# Function to get issues
get_issues() {
    log_message "INFO" "Fetching issues for project ID: $PROJECT_ID"
    
    local response
    response=$(invoke_redmine_api "GET" "/issues.json?project_id=$PROJECT_ID&limit=100")
    
    if [ $? -eq 0 ]; then
        if [ -n "$OUTPUT_FILE" ]; then
            echo "$response" > "$OUTPUT_FILE"
            log_message "INFO" "Issues list saved to: $OUTPUT_FILE"
        else
            echo "$response" | jq -r '.issues[] | "\(.id): \(.subject) [\(.status.name)]"'
        fi
    fi
}

# Function to create issue
create_issue() {
    if [ -z "$DATA_FILE" ]; then
        log_message "ERROR" "Data file is required for create-issue action"
        exit 1
    fi
    
    if [ ! -f "$DATA_FILE" ]; then
        log_message "ERROR" "Data file not found: $DATA_FILE"
        exit 1
    fi
    
    log_message "INFO" "Creating new issue from: $DATA_FILE"
    
    local issue_data
    issue_data=$(cat "$DATA_FILE")
    
    local response
    response=$(invoke_redmine_api "POST" "/issues.json" "$issue_data")
    
    if [ $? -eq 0 ]; then
        if [ -n "$OUTPUT_FILE" ]; then
            echo "$response" > "$OUTPUT_FILE"
            log_message "INFO" "New issue saved to: $OUTPUT_FILE"
        else
            local issue_id
            issue_id=$(echo "$response" | jq -r '.issue.id')
            log_message "INFO" "Issue created successfully with ID: $issue_id"
        fi
    fi
}

# Function to update issue
update_issue() {
    if [ -z "$DATA_FILE" ]; then
        log_message "ERROR" "Data file is required for update-issue action"
        exit 1
    fi
    
    if [ ! -f "$DATA_FILE" ]; then
        log_message "ERROR" "Data file not found: $DATA_FILE"
        exit 1
    fi
    
    log_message "INFO" "Updating issue from: $DATA_FILE"
    
    local update_data
    update_data=$(cat "$DATA_FILE")
    
    local issue_id
    issue_id=$(echo "$update_data" | jq -r '.id')
    
    if [ "$issue_id" = "null" ]; then
        log_message "ERROR" "Issue ID not found in update data"
        exit 1
    fi
    
    # Remove ID from update data
    local clean_data
    clean_data=$(echo "$update_data" | jq 'del(.id)')
    
    local response
    response=$(invoke_redmine_api "PUT" "/issues/$issue_id.json" "$clean_data")
    
    if [ $? -eq 0 ]; then
        log_message "INFO" "Issue $issue_id updated successfully"
    fi
}

# Function to create version
create_version() {
    if [ -z "$DATA_FILE" ]; then
        log_message "ERROR" "Data file is required for create-version action"
        exit 1
    fi
    
    if [ ! -f "$DATA_FILE" ]; then
        log_message "ERROR" "Data file not found: $DATA_FILE"
        exit 1
    fi
    
    log_message "INFO" "Creating new version from: $DATA_FILE"
    
    local version_data
    version_data=$(cat "$DATA_FILE")
    
    local response
    response=$(invoke_redmine_api "POST" "/versions.json" "$version_data")
    
    if [ $? -eq 0 ]; then
        if [ -n "$OUTPUT_FILE" ]; then
            echo "$response" > "$OUTPUT_FILE"
            log_message "INFO" "New version saved to: $OUTPUT_FILE"
        else
            local version_id
            version_id=$(echo "$response" | jq -r '.version.id')
            log_message "INFO" "Version created successfully with ID: $version_id"
        fi
    fi
}

# Main execution logic
main() {
    log_message "INFO" "Starting Redmine API Assistant (Linux/macOS)"
    
    # Check dependencies
    check_dependencies
    
    # Load configuration
    load_config "$CONFIG_FILE"
    
    # Execute action
    case $ACTION in
        "get-projects")
            get_projects
            ;;
        "get-issues")
            get_issues
            ;;
        "create-issue")
            create_issue
            ;;
        "update-issue")
            update_issue
            ;;
        "create-version")
            create_version
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
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--action)
            ACTION="$2"
            shift 2
            ;;
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -d|--data)
            DATA_FILE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
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

# Validate required parameters
if [ -z "$ACTION" ]; then
    log_message "ERROR" "Action parameter is required"
    show_usage
    exit 1
fi

# Execute main function
main "$@"
