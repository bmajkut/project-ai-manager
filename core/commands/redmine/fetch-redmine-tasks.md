# Fetch Redmine Tasks Command

Fetches tasks from a Redmine project and displays them in a structured format.

## 🎯 Purpose

Retrieve current task information from Redmine projects for analysis and planning.

## 📝 Usage

```
/fetch-redmine-tasks <project-name> [options]
```

## 🔧 Parameters

### Required
- **`project-name`** - Name of the project in the `projects/` directory

### Optional
- **`--version`** - Filter by version (e.g., `v1.0.0`)
- **`--status`** - Filter by status (open, closed, in-progress)
- **`--assignee`** - Filter by assignee username
- **`--priority`** - Filter by priority (low, normal, high, urgent)
- **`--tracker`** - Filter by tracker (bug, feature, task, support)
- **`--limit`** - Maximum number of tasks to fetch (default: 100)

## 🔄 Workflow

1. **Validate** project exists and has Redmine configuration
2. **Check** Redmine connectivity and API access
3. **Fetch** tasks based on specified filters
4. **Format** task data for display
5. **Display** results in structured format
6. **Log** operation for audit purposes

## 📋 Examples

### Fetch All Tasks
```
/fetch-redmine-tasks my-project
```

### Fetch Tasks by Version
```
/fetch-redmine-tasks my-project --version=v1.0.0
```

### Fetch Open Tasks by Priority
```
/fetch-redmine-tasks my-project --status=open --priority=high
```

### Fetch Limited Results
```
/fetch-redmine-tasks my-project --limit=50 --status=open
```

## 📊 Output Format

```
📋 Redmine Tasks for Project: my-project
🔗 Project URL: https://redmine.example.com/projects/my-project

📝 Task Summary:
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

...
```

## ⚠️ Requirements

- Project must exist in `projects/` directory
- Project must have valid Redmine configuration
- Redmine API must be accessible
- Valid API token must be configured

## 🔍 Available Filters

### Status Filters
- `open` - Open tasks
- `closed` - Closed tasks
- `in-progress` - Tasks in progress
- `resolved` - Resolved tasks
- `feedback` - Tasks awaiting feedback

### Priority Filters
- `low` - Low priority
- `normal` - Normal priority
- `high` - High priority
- `urgent` - Urgent priority

### Tracker Filters
- `bug` - Bug reports
- `feature` - Feature requests
- `task` - General tasks
- `support` - Support requests

## 📤 Export Options

- **Display** - Show in chat (default)
- **Markdown** - Export as Markdown file
- **JSON** - Export as JSON file
- **CSV** - Export as CSV file

## 🔗 Related Commands

- `/create-redmine-tasks` - Create tasks in Redmine
- `/validate-redmine-env` - Validate Redmine environment
- `/project-info` - Show project information

## 🚨 Error Handling

- **Project not found**: Suggests available projects
- **Configuration missing**: Guides through setup process
- **API connection failed**: Provides troubleshooting steps
- **Authentication failed**: Suggests token regeneration

---

**Note**: This command uses the Core Redmine scripts and respects project-specific configurations.
