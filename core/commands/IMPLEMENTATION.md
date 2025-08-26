# Command Implementation Guide

Guide for implementing new Cursor AI commands in the Project AI Manager system.

## 🏗️ Architecture Overview

Commands are organized in a hierarchical structure that follows the Core/Projects separation principle:

```
core/commands/
├── README.md                    # Main documentation
├── COMMANDS.md                  # Available commands list
├── IMPLEMENTATION.md            # This file
├── project/                     # Project management commands
├── redmine/                     # Redmine integration commands
├── docs/                        # Documentation generation commands
├── dev/                         # Development and deployment commands
└── utility/                     # System utility commands
```

## 📝 Command Structure

Each command consists of:

### 1. Command File (`command-name.md`)
- **Purpose** - What the command does
- **Usage** - How to use it
- **Parameters** - Required and optional parameters
- **Examples** - Usage examples
- **Workflow** - Step-by-step process
- **Output** - What the command produces

### 2. Implementation Logic
- **Validation** - Input validation and error handling
- **Execution** - Core command logic
- **Output** - Result formatting and display
- **Logging** - Operation logging and audit

## 🔧 Implementation Steps

### Step 1: Create Command Documentation
Create a new `.md` file in the appropriate category directory:

```markdown
# Command Name

Brief description of what the command does.

## 🎯 Purpose
Detailed explanation of the command's purpose.

## 📝 Usage
```
/command-name <parameters> [options]
```

## 🔧 Parameters
- **Required**: List required parameters
- **Optional**: List optional parameters with defaults

## 📋 Examples
Show usage examples with different parameters.

## 🔄 Workflow
1. Step 1
2. Step 2
3. Step 3

## 📤 Output
Describe what the command produces.
```

### Step 2: Define Command Logic
Implement the command logic following these patterns:

```python
# Example command implementation structure
def execute_command(project_name, **options):
    """
    Execute the command with given parameters.
    
    Args:
        project_name (str): Name of the project
        **options: Command options and flags
    
    Returns:
        dict: Command execution results
    """
    
    # 1. Validate inputs
    validate_project_exists(project_name)
    validate_options(options)
    
    # 2. Execute command logic
    result = perform_command_operation(project_name, options)
    
    # 3. Format output
    formatted_result = format_command_output(result)
    
    # 4. Log operation
    log_command_execution(project_name, options, result)
    
    return formatted_result
```

### Step 3: Add to Commands List
Update `core/commands/COMMANDS.md` to include the new command:

```markdown
### `/command-name`
Brief description of the command.
- **Usage**: `/command-name <parameters> [options]`
- **Example**: `/command-name my-project --option=value`
- **File**: `core/commands/category/command-name.md`
```

## 🎨 Command Categories

### Project Management (`project/`)
Commands for creating, managing, and configuring projects.

**Examples:**
- `/create-project` - Create new project from template
- `/list-projects` - List all projects
- `/project-info` - Show project details

**Patterns:**
- Always validate project existence
- Use templates from `core/templates/`
- Follow established project structure

### Redmine Integration (`redmine/`)
Commands for interacting with Redmine project management system.

**Examples:**
- `/fetch-redmine-tasks` - Get tasks from Redmine
- `/create-redmine-tasks` - Create tasks in Redmine
- `/validate-redmine-env` - Check Redmine configuration

**Patterns:**
- Use Core Redmine scripts
- Validate API connectivity
- Handle authentication errors gracefully

### Documentation Generation (`docs/`)
Commands for generating and managing project documentation.

**Examples:**
- `/generate-output-docs` - Create output documentation
- `/create-task-list` - Generate task lists
- `/generate-tasks-json` - Create JSON task data

**Patterns:**
- Analyze input files automatically
- Generate structured output
- Support multiple output formats

### Development (`dev/`)
Commands for development environment and deployment.

**Examples:**
- `/setup-dev-env` - Setup development environment
- `/run-tests` - Execute project tests
- `/deploy-project` - Deploy to target environment

**Patterns:**
- Use Core scripts for operations
- Support multiple environments
- Provide detailed error reporting

### Utility (`utility/`)
System utility and configuration commands.

**Examples:**
- `/help` - Show command help
- `/status` - System status
- `/config` - Configuration management

**Patterns:**
- Provide system-wide functionality
- Support configuration management
- Include help and documentation

## 🔍 Validation Patterns

### Project Validation
```python
def validate_project(project_name):
    """Validate project exists and is accessible."""
    project_path = f"projects/{project_name}"
    
    if not os.path.exists(project_path):
        raise CommandError(f"Project '{project_name}' not found")
    
    if not os.path.exists(f"{project_path}/config/project-config.json"):
        raise CommandError(f"Project '{project_name}' missing configuration")
    
    return project_path
```

### Parameter Validation
```python
def validate_parameters(params, required, optional=None):
    """Validate command parameters."""
    missing = [p for p in required if p not in params]
    
    if missing:
        raise CommandError(f"Missing required parameters: {', '.join(missing)}")
    
    if optional:
        invalid = [p for p in params if p not in required + optional]
        if invalid:
            raise CommandError(f"Invalid parameters: {', '.join(invalid)}")
```

## 📤 Output Formatting

### Success Output
```python
def format_success_output(message, data=None):
    """Format successful command output."""
    output = {
        "status": "success",
        "message": message,
        "timestamp": datetime.now().isoformat(),
        "data": data or {}
    }
    
    return output
```

### Error Output
```python
def format_error_output(error, suggestions=None):
    """Format error command output."""
    output = {
        "status": "error",
        "error": str(error),
        "timestamp": datetime.now().isoformat(),
        "suggestions": suggestions or []
    }
    
    return output
```

## 🔒 Security Considerations

### Input Sanitization
```python
def sanitize_input(input_string):
    """Sanitize user input to prevent injection attacks."""
    # Remove potentially dangerous characters
    sanitized = re.sub(r'[<>"\']', '', input_string)
    
    # Limit length
    if len(sanitized) > 1000:
        raise CommandError("Input too long")
    
    return sanitized
```

### Path Validation
```python
def validate_path(path):
    """Validate file path is within workspace bounds."""
    workspace_root = os.getcwd()
    absolute_path = os.path.abspath(path)
    
    if not absolute_path.startswith(workspace_root):
        raise CommandError("Path outside workspace bounds")
    
    return absolute_path
```

## 📊 Logging and Audit

### Command Logging
```python
def log_command_execution(command_name, project_name, options, result):
    """Log command execution for audit purposes."""
    log_entry = {
        "timestamp": datetime.now().isoformat(),
        "command": command_name,
        "project": project_name,
        "options": options,
        "result": result,
        "user": get_current_user(),
        "workspace": os.getcwd()
    }
    
    # Write to log file
    with open("core/commands/command.log", "a") as f:
        json.dump(log_entry, f)
        f.write("\n")
```

## 🧪 Testing Commands

### Unit Tests
```python
def test_command_validation():
    """Test command parameter validation."""
    # Test valid parameters
    result = validate_parameters(
        {"project": "test", "option": "value"},
        ["project"],
        ["option"]
    )
    assert result is True
    
    # Test missing required parameter
    with pytest.raises(CommandError):
        validate_parameters({}, ["project"])
```

### Integration Tests
```python
def test_command_execution():
    """Test full command execution."""
    result = execute_command("test-project", option="value")
    
    assert result["status"] == "success"
    assert "test-project" in result["message"]
    assert result["data"]["project"] == "test-project"
```

## 🚀 Best Practices

### 1. Follow Established Patterns
- Use consistent parameter naming
- Follow the same output format
- Implement similar error handling

### 2. Respect Core/Projects Separation
- Commands should not modify Core files
- Use Core scripts for operations
- Respect project-specific rules

### 3. Provide Clear Feedback
- Show progress for long operations
- Provide helpful error messages
- Include suggestions for resolution

### 4. Handle Errors Gracefully
- Validate inputs early
- Provide fallback options
- Log errors for debugging

### 5. Support Multiple Formats
- Text output for chat
- JSON output for automation
- Markdown output for documentation

## 🔗 Integration Points

### Core Scripts
Commands should use existing Core scripts when possible:
- `core/scripts/windows/redmine/` - Redmine operations
- `core/scripts/linux/redmine/` - Linux Redmine operations
- `core/scripts/common/` - Common utilities

### Templates
Use templates from `core/templates/`:
- `project-config.json` - Project configuration template
- `project-template.md` - Project documentation template

### Configuration
Read configuration from:
- `core/config/` - System configuration
- `projects/*/config/` - Project-specific configuration

---

**Note**: This guide ensures all commands follow consistent patterns and respect the established architecture principles.
