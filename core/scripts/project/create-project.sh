#!/bin/bash
# Create Project Script for Project AI Manager
# Core script - for use in projects

# Default values
TEMPLATE="default"
DESCRIPTION=""
TYPE="web-app"
FRAMEWORK=""
FORCE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --template)
            TEMPLATE="$2"
            shift 2
            ;;
        --description)
            DESCRIPTION="$2"
            shift 2
            ;;
        --type)
            TYPE="$2"
            shift 2
            ;;
        --framework)
            FRAMEWORK="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            PROJECT_NAME="$1"
            shift
            ;;
    esac
done

# Check if project name is provided
if [[ -z "$PROJECT_NAME" ]]; then
    echo "❌ Error: Project name is required"
    echo "Usage: $0 <project-name> [options]"
    exit 1
fi

# Import common functions
source "$(dirname "$0")/../common/project-common.sh"

echo "🚀 Creating new project: $PROJECT_NAME"

# Validate project name
if ! test_project_name "$PROJECT_NAME"; then
    echo "❌ Error: Invalid project name: $PROJECT_NAME. Use lowercase with hyphens only."
    exit 1
fi

# Check if project exists
PROJECT_PATH="../../projects/$PROJECT_NAME"
if [[ -d "$PROJECT_PATH" && "$FORCE" != true ]]; then
    echo "❌ Error: Project '$PROJECT_NAME' already exists. Use --force to overwrite."
    exit 1
fi

# Validate template
if ! test_template "$TEMPLATE"; then
    echo "❌ Error: Template '$TEMPLATE' not found. Available templates: $(get_available_templates)"
    exit 1
fi

# Create project structure
echo "📁 Creating project structure..."
new_project_structure "$PROJECT_NAME" "$TEMPLATE"

# Customize configuration
echo "⚙️  Customizing configuration..."
set_project_configuration "$PROJECT_NAME" "$DESCRIPTION" "$TYPE" "$FRAMEWORK"

# Generate project files
echo "📝 Generating project files..."
new_project_files "$PROJECT_NAME" "$TEMPLATE"

# Setup git repository
echo "🔧 Setting up git repository..."
initialize_git_repository "$PROJECT_PATH"

echo "✅ Project '$PROJECT_NAME' created successfully!"
echo "📂 Location: $(realpath "$PROJECT_PATH")"
echo "🎯 Next steps:"
echo "   1. cd projects/$PROJECT_NAME"
echo "   2. Review configuration files"
echo "   3. Add input documentation to docs/input/"
echo "   4. Use /generate-output-docs to create specifications"
