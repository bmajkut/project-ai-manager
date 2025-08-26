#!/bin/bash
# Generate API Token Script for Redmine
# Core script - for use in projects

set -e

# Default values
CREDENTIALS_FILE="${1:-}"
REDMINE_URL="${2:-}"
USERNAME="${3:-}"
PASSWORD="${4:-}"
CONFIG_FILE="${5:-}"

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

load_credentials() {
    local credentials_file="$1"
    
    if [ ! -f "$credentials_file" ]; then
        echo "Credentials file not found: $credentials_file" >&2
        return 1
    fi
    
    # Source the credentials file
    source "$credentials_file"
    
    # Validate required fields
    if [ -z "$REDMINE_USERNAME" ] || [ -z "$REDMINE_PASSWORD" ] || [ -z "$REDMINE_URL" ]; then
        echo "Missing required credentials in $credentials_file" >&2
        return 1
    fi
    
    return 0
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

get_basic_auth_header() {
    local username="$1"
    local password="$2"
    echo -n "${username}:${password}" | base64
}

get_user_info() {
    local redmine_url="$1"
    local auth_header="$2"
    
    response=$(curl -s -w "%{http_code}" -H "Authorization: Basic $auth_header" \
        -H "Content-Type: application/json" \
        "$redmine_url/users/current.json" 2>/dev/null)
    
    http_code="${response: -3}"
    if [ "$http_code" -eq 200 ]; then
        echo "${response%???}" | jq -r '.user'
        return 0
    else
        echo "Error getting user info: HTTP $http_code" >&2
        return 1
    fi
}

create_api_token() {
    local redmine_url="$1"
    local auth_header="$2"
    local username="$3"
    
    body=$(cat <<EOF
{
  "key": {
    "name": "AI Manager Token",
    "user_id": 1
  }
}
EOF
)
    
    response=$(curl -s -w "%{http_code}" -H "Authorization: Basic $auth_header" \
        -H "Content-Type: application/json" \
        -X POST \
        -d "$body" \
        "$redmine_url/users/1/api_keys.json" 2>/dev/null)
    
    http_code="${response: -3}"
    if [ "$http_code" -eq 201 ]; then
        echo "${response%???}" | jq -r '.api_key.key'
        return 0
    else
        echo "Error creating API token: HTTP $http_code" >&2
        return 1
    fi
}

update_redmine_config() {
    local config_file="$1"
    local api_token="$2"
    
    if [ -f "$config_file" ]; then
        # Update the API token in the JSON file
        temp_file=$(mktemp)
        jq --arg token "$api_token" '.redmine.api_token = $token' "$config_file" > "$temp_file"
        jq --arg now "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" '.last_updated = $now' "$temp_file" > "$config_file"
        rm "$temp_file"
        
        echo "✅ Updated $config_file with API token" >&2
        return 0
    else
        echo "Warning: Config file not found: $config_file" >&2
        return 1
    fi
}

# Main execution
echo -e "${CYAN}=== Redmine API Token Generator (Core) ===${NC}"

# Load credentials
if [ -n "$CREDENTIALS_FILE" ] && [ -f "$CREDENTIALS_FILE" ]; then
    write_info "Loading credentials from: $CREDENTIALS_FILE"
    if load_credentials "$CREDENTIALS_FILE"; then
        REDMINE_URL="$REDMINE_URL"
        USERNAME="$REDMINE_USERNAME"
        PASSWORD="$REDMINE_PASSWORD"
    else
        write_error "Failed to load credentials"
        exit 1
    fi
elif [ -n "$REDMINE_URL" ] && [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
    write_info "Using provided credentials"
else
    write_error "Either provide CREDENTIALS_FILE or all three: REDMINE_URL, USERNAME, PASSWORD"
    exit 1
fi

echo -e "${YELLOW}Redmine URL:${NC} $REDMINE_URL"
echo -e "${YELLOW}Username:${NC} $USERNAME"

if [ -n "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}Config File:${NC} $CONFIG_FILE"
    
    # Validate config file
    if [ ! -f "$CONFIG_FILE" ]; then
        write_error "Config file not found: $CONFIG_FILE"
        exit 1
    fi
fi

# Get authentication header
write_info "Getting authentication header..."
auth_header=$(get_basic_auth_header "$USERNAME" "$PASSWORD")

# Get user info to verify connection
write_info "Verifying connection..."
user_info=$(get_user_info "$REDMINE_URL" "$auth_header")

if [ $? -eq 0 ]; then
    user_name=$(echo "$user_info" | jq -r '.firstname + " " + .lastname')
    user_id=$(echo "$user_info" | jq -r '.id')
    
    write_success "Connected successfully as: $user_name"
    write_info "User ID: $user_id"
    
    # Create API token
    write_info "Creating API token..."
    api_token=$(create_api_token "$REDMINE_URL" "$auth_header" "$USERNAME")
    
    if [ $? -eq 0 ]; then
        write_success "API token created successfully!"
        echo -e "${GREEN}Token:${NC} $api_token"
        
        # Update config file if provided
        if [ -n "$CONFIG_FILE" ]; then
            if update_redmine_config "$CONFIG_FILE" "$api_token"; then
                write_success "Configuration updated successfully!"
                write_info "Project is ready for Core script usage"
            else
                write_warning "Config file update failed"
            fi
        fi
        
        write_info "Next steps:"
        echo "1. Copy the API token above"
        echo "2. Update your configuration files if needed"
        echo "3. Use the token in your Core scripts"
    else
        write_error "Failed to create API token"
        exit 1
    fi
else
    write_error "Failed to connect to Redmine. Check URL and credentials."
    exit 1
fi
