# Create Redmine Tasks Command

Creates tasks in Redmine from JSON data using the Core Redmine scripts.

## 🎯 Purpose

Automate the creation of multiple tasks in Redmine projects from structured data.

## 📝 Usage

```
/create-redmine-tasks <project-name> [options]
```

## 🔧 Parameters

### Required
- **`project-name`** - Name of the project in the `projects/` directory

### Optional
- **`--file`** - Path to tasks JSON file (default: `docs/output/tasks.json`)
- **`--dry-run`** - Preview tasks without creating them
- **`--batch-size`** - Number of tasks to create per batch (default: 10)
- **`--validate-only`** - Only validate data without creating tasks

## 🔄 Workflow

1. **Validate** project exists and has Redmine configuration
2. **Check** Redmine connectivity and API access
3. **Load** tasks data from JSON file
4. **Validate** task data structure and required fields
5. **Create** tasks in Redmine using Core scripts
6. **Report** creation results and any errors
7. **Log** operation for audit purposes

## 📋 Examples

### Create Tasks from Default File
```
/create-redmine-tasks my-project
```

### Create Tasks from Specific File
```
/create-redmine-tasks my-project --file=docs/custom-tasks.json
```

### Preview Tasks (Dry Run)
```
/create-redmine-tasks my-project --dry-run
```

### Validate Data Only
```
/create-redmine-tasks my-project --validate-only
```

## 📊 Task Data Structure

The JSON file should contain tasks in this format:

```json
{
  "project": {
    "name": "Project Name",
    "identifier": "project-identifier"
  },
  "versions": [
    {
      "name": "v1.0.0",
      "description": "First version",
      "due_date": "2025-12-31"
    }
  ],
  "tasks": [
    {
      "subject": "Task Title",
      "description": "Task description with details",
      "tracker": "Task",
      "priority": "High",
      "estimated_hours": 80,
      "version": "v1.0.0",
      "start_date": "2025-08-25"
    }
  ]
}
```

## ⚠️ Requirements

- Project must exist in `projects/` directory
- Project must have valid Redmine configuration
- Redmine API must be accessible
- Valid API token must be configured
- JSON file must follow required structure

## 🔍 Validation Rules

### Required Fields
- `subject` - Task title (non-empty string)
- `description` - Task description (non-empty string)
- `tracker` - Valid tracker name
- `priority` - Valid priority level
- `version` - Must exist in Redmine project

### Optional Fields
- `estimated_hours` - Numeric value
- `start_date` - Valid date format (YYYY-MM-DD)
- `assignee` - Valid Redmine username
- `category` - Valid category name

## 📤 Output Format

```
🚀 Creating Redmine Tasks for Project: my-project
🔗 Project URL: https://redmine.example.com/projects/my-project

📊 Task Creation Summary:
- Total Tasks: 15
- Successfully Created: 14
- Failed: 1
- Skipped: 0

✅ Successfully Created:
1. [TASK-125] Development Environment Setup
2. [TASK-126] Authentication System Implementation
3. [TASK-127] Database Configuration
...

❌ Failed to Create:
1. Task: "Invalid Task" - Error: Invalid tracker name

📝 Next Steps:
- Review failed tasks and fix data
- Verify task assignments and priorities
- Check task dependencies and relationships
```

## 🚨 Error Handling

- **Invalid data**: Shows specific validation errors
- **API failures**: Retries with exponential backoff
- **Authentication issues**: Suggests token refresh
- **Network problems**: Provides retry options

## 🔗 Related Commands

- `/fetch-redmine-tasks` - Fetch existing tasks
- `/validate-redmine-env` - Validate Redmine environment
- `/generate-tasks-json` - Generate tasks JSON from descriptions

## 📋 Batch Processing

For large numbers of tasks, the command processes them in batches:
- **Default batch size**: 10 tasks
- **Configurable**: Use `--batch-size` option
- **Progress tracking**: Shows batch progress
- **Error isolation**: Failed tasks don't stop batch processing

---

**Note**: This command uses the Core Redmine scripts and follows the established workflow patterns.
