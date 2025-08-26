# Available Cursor AI Commands

Complete list of all available commands for Project AI Manager automation.

## 🚀 Quick Start

To use any command, simply type it in the Cursor AI chat followed by parameters:

```
/command-name <parameters> [options]
```

## 📁 Project Management Commands

### `/create-project`
Creates a new project from templates.
- **Usage**: `/create-project <project-name> [options]`
- **Example**: `/create-project my-web-app --template=web-app`
- **File**: `core/commands/project/create-project.md`

### `/list-projects`
Lists all projects in the workspace.
- **Usage**: `/list-projects [options]`
- **Example**: `/list-projects --detailed`
- **File**: `core/commands/project/list-projects.md`

### `/project-info`
Shows detailed project information.
- **Usage**: `/project-info <project-name> [options]`
- **Example**: `/project-info my-project --config`
- **File**: `core/commands/project/project-info.md`

## 🔗 Redmine Integration Commands

### `/fetch-redmine-tasks`
Fetches tasks from Redmine project.
- **Usage**: `/fetch-redmine-tasks <project-name> [options]`
- **Example**: `/fetch-redmine-tasks my-project --status=open`
- **File**: `core/commands/redmine/fetch-redmine-tasks.md`

### `/create-redmine-tasks`
Creates tasks in Redmine from JSON data.
- **Usage**: `/create-redmine-tasks <project-name> [options]`
- **Example**: `/create-redmine-tasks my-project --dry-run`
- **File**: `core/commands/redmine/create-redmine-tasks.md`

### `/validate-redmine-env`
Validates Redmine environment configuration.
- **Usage**: `/validate-redmine-env <project-name> [options]`
- **Example**: `/validate-redmine-env my-project --fix`
- **File**: `core/commands/redmine/validate-redmine-env.md`

## 📚 Documentation Generation Commands

### `/generate-output-docs`
Generates output documentation from input.
- **Usage**: `/generate-output-docs <project-name> [options]`
- **Example**: `/generate-output-docs my-project --output-type=tasks`
- **File**: `core/commands/docs/generate-output-docs.md`

### `/create-task-list`
Creates task list in Markdown format.
- **Usage**: `/create-task-list <project-name> [options]`
- **Example**: `/create-task-list my-project --template=detailed`
- **File**: `core/commands/docs/create-task-list.md`

### `/generate-tasks-json`
Generates tasks.json from task descriptions.
- **Usage**: `/generate-tasks-json <project-name> [options]`
- **Example**: `/generate-tasks-json my-project --validate`
- **File**: `core/commands/docs/generate-tasks-json.md`

## 🛠️ Development Commands

### `/setup-dev-env`
Sets up development environment.
- **Usage**: `/setup-dev-env <project-name> [options]`
- **Example**: `/setup-dev-env my-project --docker`
- **File**: `core/commands/dev/setup-dev-env.md`

### `/run-tests`
Runs project tests.
- **Usage**: `/run-tests <project-name> [options]`
- **Example**: `/run-tests my-project --coverage`
- **File**: `core/commands/dev/run-tests.md`

### `/deploy-project`
Deploys project to target environment.
- **Usage**: `/deploy-project <project-name> [options]`
- **Example**: `/deploy-project my-project --staging`
- **File**: `core/commands/dev/deploy-project.md`

## 🔧 Utility Commands

### `/help`
Shows help for all commands.
- **Usage**: `/help [command-name]`
- **Example**: `/help create-project`
- **File**: `core/commands/utility/help.md`

### `/status`
Shows system status and health.
- **Usage**: `/status [options]`
- **Example**: `/status --detailed`
- **File**: `core/commands/utility/status.md`

### `/config`
Manages configuration settings.
- **Usage**: `/config [action] [options]`
- **Example**: `/config show --global`
- **File**: `core/commands/utility/config.md`

## 📋 Command Categories

| Category | Commands | Description |
|----------|----------|-------------|
| **Project** | 3 | Project creation and management |
| **Redmine** | 3 | Redmine integration and task management |
| **Documentation** | 3 | Documentation generation and management |
| **Development** | 3 | Development environment and deployment |
| **Utility** | 3 | System utilities and configuration |

## 🎯 Common Use Cases

### 1. New Project Setup
```bash
/create-project my-new-app --template=web-app
/generate-output-docs my-new-app
/create-redmine-tasks my-new-app
```

### 2. Existing Project Management
```bash
/project-info my-project
/fetch-redmine-tasks my-project --status=open
/generate-output-docs my-project --force
```

### 3. Development Workflow
```bash
/setup-dev-env my-project
/run-tests my-project
/deploy-project my-project --staging
```

## 🔍 Command Options

Most commands support these common options:

### Global Options
- `--help` - Show command help
- `--verbose` - Enable verbose output
- `--dry-run` - Preview without execution
- `--force` - Override safety checks

### Output Options
- `--format` - Output format (text, json, markdown)
- `--output` - Output file path
- `--quiet` - Suppress non-essential output

### Validation Options
- `--validate` - Validate data only
- `--fix` - Attempt to fix issues automatically
- `--strict` - Use strict validation rules

## 🚨 Error Handling

All commands provide:
- **Clear error messages** with specific details
- **Suggestions** for resolving issues
- **Fallback options** when possible
- **Logging** for audit and debugging

## 📚 Getting Help

### Command Help
```
/help <command-name>
```

### General Help
```
/help
```

### Examples
```
/help create-project --examples
```

## 🔒 Security Features

- **Workspace isolation** - Commands only operate within project workspace
- **Permission checking** - Respects project-specific rules
- **Audit logging** - All operations are logged
- **Validation** - Input validation and sanitization

## 🚀 Advanced Usage

### Command Chaining
Commands can be chained for complex workflows:
```bash
/create-project my-app && /generate-output-docs my-app && /create-redmine-tasks my-app
```

### Batch Operations
Some commands support batch processing:
```bash
/create-project project1,project2,project3 --template=web-app
```

### Custom Templates
Commands can use custom templates:
```bash
/create-project my-app --template=custom --template-path=./templates
```

---

**Note**: All commands follow the Core/Projects separation principle and respect established project patterns.
