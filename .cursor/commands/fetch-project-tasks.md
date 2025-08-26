# Fetch Project Tasks

Fetches the list of tasks from the current project in Redmine.

## Purpose
- Retrieve all tasks for the current project
- Display task summary and statistics
- Show task details with status, priority, assignee
- Export task data in various formats

## Usage
```
/fetch-project-tasks [options]
```

## Examples
- `/fetch-project-tasks` (fetches all tasks)
- `/fetch-project-tasks --status=open` (only open tasks)
- `/fetch-project-tasks --priority=high` (high priority tasks)
- `/fetch-project-tasks --version=v1.0.0` (tasks for specific version)

## Auto-Detection
The command automatically detects the current project:
- Must be in a subdirectory of `projects/` directory
- Reads project name from `config/project-config.json`
- Uses stored API token for authentication

## Options
- `--status`: Filter by status (open, closed, in-progress, resolved)
- `--priority`: Filter by priority (low, normal, high, urgent)
- `--tracker`: Filter by tracker (bug, feature, task, support)
- `--assignee`: Filter by assignee username
- `--version`: Filter by version (e.g., `v1.0.0`)
- `--limit`: Maximum number of tasks to fetch (default: 100)

## Output Format
```
📋 Project Tasks: my-project
🔗 Redmine URL: https://redmine.example.com/projects/my-project

📊 Summary:
- Total Tasks: 25
- Open: 15 | In Progress: 8 | Closed: 2
- High Priority: 5 | Normal: 18 | Low: 2

📋 Task List:
1. [TASK-123] Development Environment Setup
   Status: In Progress | Priority: High | Assignee: john.doe
   Version: v1.0.0 | Tracker: Task

2. [TASK-124] Authentication System Implementation
   Status: Open | Priority: High | Assignee: jane.smith
   Version: v1.0.0 | Tracker: Feature
```

## Export Options
- **Display** - Show in chat (default)
- **Markdown** - Export as Markdown file
- **JSON** - Export as JSON file
- **CSV** - Export as CSV file

## Core Scripts Used
- `core/scripts/redmine/fetch-tasks.ps1` (Windows)
- `core/scripts/redmine/fetch-tasks.sh` (Linux)
- `core/scripts/common/redmine-common.ps1` (Common functions)

## Requirements
- Must be in project directory
- Project must have valid Redmine configuration
- Redmine API must be accessible
