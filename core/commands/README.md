# Core Commands - Cursor AI Automation

This directory contains Cursor AI commands that can be used to automate common project operations.

## 🚀 Available Commands

### Project Management
- **`create-project`** - Create new project from template
- **`list-projects`** - List all projects in the workspace
- **`project-info`** - Show detailed project information

### Redmine Integration
- **`fetch-redmine-tasks`** - Fetch tasks from Redmine project
- **`create-redmine-tasks`** - Create tasks in Redmine from JSON data
- **`validate-redmine-env`** - Validate Redmine environment configuration

### Documentation Generation
- **`generate-output-docs`** - Generate output documentation from input
- **`create-task-list`** - Create task list in Markdown format
- **`generate-tasks-json`** - Generate tasks.json from task descriptions

### Development
- **`setup-dev-env`** - Setup development environment
- **`run-tests`** - Run project tests
- **`deploy-project`** - Deploy project to target environment

### Utility
- **`help`** - Show command help and documentation
- **`status`** - Show system status and health
- **`config`** - Manage configuration settings

## 📖 Usage

### In Cursor AI Chat
Simply type the command name followed by any required parameters:

```
/create-project my-new-project
/fetch-redmine-tasks project-name
/generate-output-docs input-file.md
```

### Command Parameters
Most commands support parameters that can be specified after the command:

```
/create-project project-name --template=web-app --description="My web application"
/fetch-redmine-tasks project-name --version=v1.0 --status=open
```

## 🔧 Command Structure

Each command follows this structure:
1. **Command Name** - The main action to perform
2. **Parameters** - Required and optional parameters
3. **Options** - Command-specific options and flags
4. **Output** - What the command produces

## 📁 Command Files

Commands are organized by category:
- `project/` - Project management commands
- `redmine/` - Redmine integration commands  
- `docs/` - Documentation generation commands
- `dev/` - Development and deployment commands
- `utility/` - System utility and configuration commands

## 🎯 Benefits

- **Automation** - Reduce manual repetitive tasks
- **Consistency** - Ensure all projects follow the same patterns
- **Efficiency** - Speed up project setup and management
- **Integration** - Seamless workflow between Cursor AI and project tools

## 🔒 Security

- Commands only operate within the project workspace
- No external API calls without explicit permission
- All operations are logged for audit purposes
- Commands respect project-specific rules and constraints

---

**Note:** These commands are designed to work with the Project AI Manager architecture and follow the Core/Projects separation principles.
